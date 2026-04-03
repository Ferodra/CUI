local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF, FI = E:LoadModules("Config", "Unitframes", "Filters")

----------------------------------------------
local _
local CreateFrame		= CreateFrame
local max				= math.max
local floor				= math.floor
local ceil				= math.ceil
local format			= string.format
local lower				= string.lower
local tinsert			= table.insert
local pairs				= pairs
local type				= type
local UnitAura				= C_TooltipInfo.GetUnitAura
local GetAuraDataByIndex 	= C_UnitAuras and C_UnitAuras.GetAuraDataByIndex
local UnpackAuraData 		= AuraUtil and AuraUtil.UnpackAuraData
local DebuffTypeColor	= DebuffTypeColor
local UnitExists		= UnitExists
local UnitCanAttack		= UnitCanAttack
local GetAuraDuration 		= C_UnitAuras.GetAuraDuration
local GetAuraApplicationDisplayCount = C_UnitAuras.GetAuraApplicationDisplayCount
local GetAuraDispelTypeColor	= C_UnitAuras.GetAuraDispelTypeColor
----------------------------------------------

local MouseOverUpdater = CreateFrame("Frame", "CUI_UnitAurasMouseoverUpdater")
local Module = {}
Module.Frames = {}

Module.Auras = {}
Module.Holders = {}

Module.AURA_SIZE 			= 32 -- X and Y size
Module.HOLDER_TYPES			= {"Buffs", "Debuffs"}
Module.AURA_TYPES 			= {"HELPFUL", "HARMFUL"}

local Masque = E.Libs.Masque
local MasqueGroup_Buffs = Masque and Masque:Group("CUI", format("%s %s", L["unit"], L["Buffs"]))
local MasqueGroup_Debuffs = Masque and Masque:Group("CUI", format("%s %s", L["unit"], L["Debuffs"]))

--[[---------------------------------------------

	Aura Table:
		Module.Auras
			-> [Unit]
				-> [AuraClass](HELPFUL or HARMFUL)
					-> [AuraIndex]
						-> [1] = AuraName
						-> [2] = AuraTexture
						-> [3] = AuraCount
						-> [4] = AuraDType
						-> [5] = AuraDuration
						-> [6] = AuraExpirationTime
				-> AuraUnitFaction = HELPFUL or HARMFUL, based on faction towards player

------------------------------------------------]]

function Module:ToggleTestMode(state)
	
	self.TestMode = state
	local Holder, Slot, AuraType
	
	for Unit, Entry in pairs(self.Holders) do
		for _, Type in pairs(Module.HOLDER_TYPES) do
			
			Holder = Entry[Type]
			
			if state then
				AuraType = (Type == "Buffs") and "HELPFUL" or "HARMFUL"
				
				-- Create missing slots
				for i = 1, Holder.Num_Auras do
					Holder.AuraSlot[i] = (Holder.AuraSlot[i] or self:CreateSlot(Holder, i))
				end
				
				for i = 1, #Holder.AuraSlot do
					
					Slot = Holder.AuraSlot[i]
					
					self:PopulateSlot(Slot, Unit, 1, AuraType, AuraType, 136081, 2, "none", GetTime() + 7200, 7200, true, true, nil, nil)
					Slot:Show()
					
					Holder.ActiveSlots = i
				end
				
				self:UpdateHolderSize(Holder)
				self:UpdateSlotPositions(Holder)
			else
				-- if not Holder:IsEventRegistered("UNIT_AURA") then
					-- Holder:RegisterEvent("PLAYER_ENTERING_WORLD")
					-- Holder:RegisterUnitEvent("UNIT_AURA", Holder.unit)
				-- end
				
				Holder.ActiveSlots = 0
			end
		end
		
		if not state then
			--Module:UpdateIcons(Unit)
		end
	end
end

local function SortAuras(a,b)
	if a and b then
		if a:IsShown() and b:IsShown() then
			if a.Priority > b.Priority then
				return true
			elseif a.Priority < b.Priority then
				return false
			else
				if a:GetParent().SortDirection == "+" then
					return a.Expiration > b.Expiration
				else
					return a.Expiration < b.Expiration
				end
			end
			
		elseif a:IsShown() then
			return true
		end
	end
end

local function SortByName(a,b)
	if a and b then
		if a:IsShown() and b:IsShown() then
			if a:GetParent().SortDirection == "+" then
				return a.Name > b.Name
			else
				return a.Name < b.Name
			end
		elseif a:IsShown() then
			return true
		end
	end
end

local function SortByDuration(a,b)
	if a and b then
		if a:IsShown() and b:IsShown() then
			if a:GetParent().SortDirection == "+" then
				return a.Duration > b.Duration
			else
				return a.Duration < b.Duration
			end
		elseif a:IsShown() then
			return true
		end
	end
end

function Module:CreateIcon(Slot, Type)
	Slot.Tex = Slot:CreateTexture(nil, "BACKGROUND")
	Slot.Tex:SetParent(Slot)
	Slot.Tex:SetAllPoints(Slot)
	
	Slot.Highlight = Slot:CreateTexture(nil, "HIGHLIGHT")
	Slot.Highlight:SetColorTexture(1, 1, 1, 0.45)
	
	--E:SkinButtonIcon(Slot.Tex, {0.3, 0.3, 0.8, 1})
	
	self:SetupInteraction(Slot)
	self:SetupCooldown(Slot)
	
	--Slot.Cooldown.Time = CreateFrame("Frame", nil, Slot.Cooldown)
	--Slot.Cooldown.Time:Hide()
	--Slot.Cooldown.Time:SetAllPoints()
	--Slot.Cooldown.Time:SetScript("OnUpdate", self.Cooldown_OnUpdate)
	--Slot.Cooldown.Time.Text = self:InitFont(Slot, Slot.Cooldown.Time, "Time")

	
	
	--hooksecurefunc(Slot.Cooldown, "SetCooldown", Module.Cooldown_Set)
	
		Slot.FontOverlay = CreateFrame("Frame", nil, Slot)
		Slot.FontOverlay:SetAllPoints(true)
	Slot.Count = self:InitFont(Slot, Slot.FontOverlay, "Count")
	
	if not CO.db.char.unitframe.unitBuffs.useMasque and not CO.db.char.unitframe.unitDebuffs.useMasque then return end
	
	local ButtonData = {
		FloatingBG = nil,
		Icon = Slot.Tex,
		Cooldown = Slot.Cooldown,
		Flash = nil,
		Pushed = nil,
		Normal = nil,
		Disabled = nil,
		Checked = nil,
		Border = nil,
		AutoCastable = nil,
		Highlight = Slot.Highlight,
		HotKey = nil,
		Count = false,
		Name = nil,
		Duration = false,
		AutoCast = nil,
	}
	
	local Target
	if Type == "Buffs" and CO.db.char.unitframe.unitBuffs.useMasque then
		Target = MasqueGroup_Buffs
	elseif Type == "Debuffs" and CO.db.char.unitframe.unitDebuffs.useMasque then
		Target = MasqueGroup_Debuffs
	end
	if Target then
		Target:AddButton(Slot, ButtonData)
		-- Don't ReSkin here, as it will: Impact performance, due to rapid creation of buttons and cause flickering, since the whole group is being iterated
		--Target:ReSkin()
		
		if Slot.__MSQ_BaseFrame then
			Slot.__MSQ_BaseFrame:SetFrameLevel(2) --Lower the framelevel to fix issue with buttons created during combat
		end
	end
	
	-- Hide initially
	Slot:Hide()
end

----------------------------------
-- AURA TOOLTIP
----------------------------------
	local TooltipUpdateFrequency = 0.25
	local function BuildTooltip(self)
		if not Module.TestMode then
			GameTooltip:SetOwner(self)
			GameTooltip:SetUnitAura(self:GetParent().Owner.unit, self.RealIndex, self.AuraClass)
		end
	end
	
	local function AuraMouseOver_OnUpdate(self, elapsed)
		self.UpdateDelay = (self.UpdateDelay or 0) + elapsed
		
		if self.UpdateDelay >= TooltipUpdateFrequency then
			BuildTooltip(self.Slot)
			
			self.UpdateDelay = 0
		end
	end

	local function SetAuraMouseUpdater(Slot, state)
		if not state then
			MouseOverUpdater:SetScript("OnUpdate", nil)
		else
			MouseOverUpdater.Slot = Slot
			MouseOverUpdater:SetScript("OnUpdate", AuraMouseOver_OnUpdate)
			AuraMouseOver_OnUpdate(MouseOverUpdater, TooltipUpdateFrequency + 1) -- Force update to prevent flashing
		end
	end

	local function AuraButton_OnEnter(self)
		SetAuraMouseUpdater(self, true)
	end
	local function AuraButton_OnLeave(self)
		SetAuraMouseUpdater(self, false)
		GameTooltip:Hide()
	end
	local function AuraButton_OnClick(self, button, state)
		if IsShiftKeyDown() then
			FI:AddSpellIDToUnitAurabarsFilter(self.SpellID, self:GetParent().Owner.unit, self.Duration)
		end
	end

	function Module:SetupInteraction(Slot)
		Slot:SetScript("OnEnter", AuraButton_OnEnter)
		Slot:SetScript("OnLeave", AuraButton_OnLeave)
		Slot:SetScript("OnClick", AuraButton_OnClick)
		
		Slot:RegisterForClicks('RightButtonUp')
	end
	
----------------------------------
-- AURA TOOLTIP END
----------------------------------

----------------------------------
-- LOAD PROFILE
----------------------------------
local function GetHolderAnchor(Holder)
	local AnchorFrame, PositionConflict = nil, false
	
	if Holder.AttachTo == "Frame" then
		AnchorFrame = Holder.Owner
	else
		if (Holder.AttachTo == Holder.OtherHolder.Type and Holder.OtherHolder.AttachTo == Holder.Type) or Holder.Type == Holder.AttachTo then
			PositionConflict = true
			AnchorFrame = Holder.Owner
		else
			AnchorFrame = Holder.OtherHolder
		end
	end
	
	return AnchorFrame, PositionConflict
end
local function ConfigLoader(UnitOrFrame, Frame, RefreshUnitOnly)	
	if not Frame then
		if type(UnitOrFrame) == "string" then
			-- Frame = UF.Frames[UnitOrFrame]
			-- @TODO
			-- I would like something more performant, but for now this is enough.
			Frame = UF:GetUnitframe(UnitOrFrame)
		elseif type(UnitOrFrame) == "table" then
			Frame = UnitOrFrame
		end
	end
	
	if not Frame then return end
	
	-------------------------------------------------------------------------
		local AnchorFrame
		local Config = Module.db.units[Frame.ConfigKey]
		local Type, OtherHolder, HolderConfig, OtherHolderConfig, PositionConflict
		
		if not RefreshUnitOnly then
			-- Let's update those bois first, before we get into any trouble, as the settings are dependent on each other
			for k, Holder in pairs(Frame.AuraHolders) do
				Holder:ClearAllPoints()
				
				Type = Holder.Type
				HolderConfig = Config[lower(Type)]
				OtherHolder = Frame[(Type == "Buffs") and "Debuffs" or "Buffs"]
				
				Holder.OtherHolder 		= OtherHolder
				Holder.Enabled 			= HolderConfig.enable
				Holder.NumPerRow 		= HolderConfig.numPerRow
				Holder.MaxWraps 		= HolderConfig.maxWraps
				Holder.Num_Auras		= Holder.NumPerRow * Holder.MaxWraps
				Holder.Position			= HolderConfig.position
				Holder.AttachTo			= HolderConfig.attachTo
				Holder.SlotSize 		= HolderConfig.size
				Holder.GapX 			= HolderConfig.gapX
				Holder.GapY 			= HolderConfig.gapY
				Holder.OffsetX 			= HolderConfig.offsetX
				Holder.OffsetY 			= HolderConfig.offsetY
				Holder.SortDirection	= HolderConfig.sortDirection
				Holder.SortBy			= HolderConfig.sortBy
				Holder.FilterType		= HolderConfig.filterType
				Holder.ClickThrough 	= HolderConfig.clickThrough
				Holder.SlotAlpha		= HolderConfig.alpha
				Holder.MinDuration		= HolderConfig.minDuration
			end
		end
		
		for k, Holder in pairs(Frame.AuraHolders) do
			Type = Holder.Type
			OtherHolder = Frame[(Type == "Buffs") and "Debuffs" or "Buffs"]
			OtherHolderConfig = Config[lower((Type == "Buffs") and "Debuffs" or "Buffs")]
			
			if not RefreshUnitOnly then
				if Holder.Position == "CENTER" or Holder.Position == "TOP" or Holder.Position == "BOTTOM" then
					Holder.HasCenterPositioning = true
				else
					Holder.SlotAnchor	= ((Holder.Position:find("TOP")) and "BOTTOM" or "TOP") .. ((Holder.Position:find("LEFT")) and "LEFT" or "RIGHT")
					Holder.HasCenterPositioning = false
				end
				
				-- Position regardless of status, as we still can anchor things to it and need updated positioning therefore
				AnchorFrame, PositionConflict = GetHolderAnchor(Holder)
				Holder:SetPoint(E:InversePosition(Holder.Position), AnchorFrame, Holder.Position, Holder.OffsetX, Holder.OffsetY)
				
				if PositionConflict then
					E:print("There is an issue with the " .. Frame.ConfigKey .. " " .. Type .. ", because they are attached to " .. Holder.AttachTo .. ", creating a loop!")
				end
				
				if Holder.Enabled then		
					for k, Slot in pairs(Holder.AuraSlot) do
						Slot:SetSize(Holder.SlotSize, Holder.SlotSize)
						Slot:EnableMouse(not Holder.ClickThrough)
						
						if Holder.SlotAlpha then
							Slot:SetAlpha(Holder.SlotAlpha)
						end
						
						Slot:Hide() -- To hide not required slots. Will be shown on next update
					end
					
					-- if not Holder:IsEventRegistered("UNIT_AURA") then
						-- Holder:RegisterEvent("PLAYER_ENTERING_WORLD")
						-- Holder:RegisterUnitEvent("UNIT_AURA", Holder.unit)
					-- end
				else
					-- Just scale down, since we may want to anchor stuff
					for k, Slot in pairs(Holder.AuraSlot) do
						Slot:Hide() -- To hide not required slots. Will be shown on next update
					end
					Module:DisableHolder(Holder)
				end
			end
			
			Frame.AuraEventHandler:UnregisterAllEvents()
			
			if Holder.Enabled or OtherHolder.Enabled then
				Frame.AuraEventHandler:RegisterUnitEvent("UNIT_AURA", Frame.unit)
				Frame.AuraEventHandler:SetScript("OnEvent", Module.Auras_OnEvent)
			else
				Frame.AuraEventHandler:SetScript("OnEvent", nil)
			end
			
			if RefreshUnitOnly then return end
			
			if MasqueGroup_Debuffs then MasqueGroup_Debuffs:ReSkin() end
			if MasqueGroup_Buffs then MasqueGroup_Buffs:ReSkin() end
		end
		
		if not Module.TestMode then
			-- Force Update
			Module:UpdateIcons(Frame)
		else
			--Module:ToggleTestMode(true)
		end
	
	-------------------------------------------------------------------------
end

local function UpdateUnit(self)
	--local Unit = self.Frame.unit
	ConfigLoader(self.Frame, nil, true)
end

function Module:DisableHolder(Holder)
	if not Holder.OtherHolder.Enabled or Holder.ActiveSlots <= 0 then
		Holder:SetSize(1, 1)
		return
	end
	
	if Holder.OtherHolder.Position:find("LEFT") or Holder.OtherHolder.Position:find("RIGHT") then
		Holder:SetSize(1, Holder.SlotSize)
	end
	if Holder.OtherHolder.Position:find("TOP") or Holder.OtherHolder.Position:find("BOTTOM") then
		Holder:SetSize(Holder.SlotSize, 1)
	end
end

-- No unit/frame = Update all
-- Otherwise only the specified unit-set or frame will be updated
-- This makes the config less laggy, as we are dealing with so many frames here
function Module:LoadConfig(Unit, ForSingleFrame)
	
	if Unit and ForSingleFrame then
		ConfigLoader(Unit)
	end
	
	if not Unit then
		for _, Frame in pairs(Module.Frames) do
			ConfigLoader(Frame)
		end
	else
		UF:PerformForUnits(Unit, ConfigLoader)
	end
end

----------------------------------
-- COOLDOWN TIMER
----------------------------------
function Module:SetupCooldown(Slot)
	Slot.Cooldown = CreateFrame("Cooldown", nil, Slot, "CooldownFrameTemplate")
	Slot.Cooldown:SetHideCountdownNumbers(false)
	Slot.Cooldown:SetParent(Slot)
	Slot.Cooldown:SetAllPoints(Slot)
	Slot.Cooldown:SetReverse(true)
	Slot.Cooldown:Show()

	Slot.Cooldown.Time = Slot.Cooldown:GetRegions()
end

function Module:Cooldown_Set(start, duration)
	if (duration > 1.5) then
		local timer = self.Time
		timer.start = start
		timer.duration = duration
		timer.enabled = true
		timer.nextUpdate = 0

		timer:Show()
	elseif self.timer then
		self.timer:Hide()
		self.timer.enabled = false
	end
end

function Module:Cooldown_OnUpdate(elapsed)
	if self.nextUpdate > 0 then
		self.nextUpdate = self.nextUpdate - elapsed
		return
	end
	
	if not self.enabled then return end

	self.remaining = self.duration - (GetTime() - self.start)
	
	if self.remaining > 0.05 then
		if self.remaining > 0 and self.remaining < 15 then
			self.Text:SetText(E:FormatTime(self.remaining, 1))
			self.nextUpdate = 0
		elseif self.remaining > 15 then
			self.Text:SetText(E:FormatTime(self.remaining, 0))
			self.nextUpdate = 0.5
		else
			self.Text:SetText("")
		end
	else
		self:Hide()
		self.enabled = false
	end
end
----------------------------------
-- COOLDOWN TIMER END
----------------------------------

----------------------------------
-- SLOT
----------------------------------
	function Module:UpdateCenterPositioning(Holder)
		E:SortFrames(Holder.AuraSlot, Holder, Holder.SlotSize, Holder.SlotSize, 1, Holder.NumPerRow, nil, nil, 1, 1, true)
	end

	-- @TODO: Center requires active positioning
	function Module:GetGrowthDirection(Size, Direction, NumCurrent, NumVisible, Gap)
		Gap = Gap or 1
		
		if Direction == "UP" or Direction == "RIGHT" then
			return Size + Gap
		elseif Direction == "DOWN" or Direction == "LEFT" then
			return (Size + Gap) * (-1)
		elseif Direction == "CENTER" and NumCurrent and NumVisible then
			return (NumCurrent - NumVisible / 2) * (Size + Gap) - Size / 2
		end
	end

	local InitFontData = {["Time"] = {"CENTER", 0, 0, 0, 0, "CENTER"}, ["Count"] = {"BOTTOMRIGHT", 0, 0, -2, 2, "RIGHT"}} -- Alignment, Width, Height, XOffset, YOffset, JustifyH
	function Module:InitFont(Slot, Parent, Font)
		local v = InitFontData[Font]
		Parent = Parent or Slot
				
		Slot[Font] = Slot:CreateFontString(nil, "ARTWORK")
		E:InitializeFontFrame(Slot[Font], "ARTWORK", "FRIZQT__.TTF", 11, {1,0.96,0.41}, 1, {0,0}, "", v[2], v[3], Parent, v[1], {0, 0}, "OUTLINE")
		Slot[Font]:ClearAllPoints()
		Slot[Font]:SetParent(Parent)
		Slot[Font]:SetJustifyH(v[6])
		Slot[Font]:SetPoint(v[1], Parent, v[1], v[4], v[5])
		
		return Slot[Font]
	end
	
	local RepositioningSlot
	function Module:RepositionSlot(Holder, Index)
		RepositioningSlot = Holder.AuraSlot[Index]
		
		if Holder.HasCenterPositioning then return end
			
		if Holder.Position:find("RIGHT") then
			RepositioningSlot.MathPrefix_X = -1
		else
			RepositioningSlot.MathPrefix_X = 1
		end
		if Holder.Position:find("BOTTOM") then
			RepositioningSlot.MathPrefix_Y = -1
		else
			RepositioningSlot.MathPrefix_Y = 1
		end
		
		-- Prevent random flashing
		if Holder.SlotAnchor then
			if select(1, RepositioningSlot:GetPoint()) ~= Holder.SlotAnchor then
				RepositioningSlot:ClearAllPoints()
			end
			
			RepositioningSlot:SetPoint(Holder.SlotAnchor, Holder, Holder.SlotAnchor)
			RepositioningSlot.PointCache = Holder.SlotAnchor
		end
		
		-- We have to use the previous column and row values to make it work properly
		RepositioningSlot.XOffset = ((Holder.SlotSize * Holder.CurrentColumn) + (Holder.GapX * Holder.CurrentColumn)) * RepositioningSlot.MathPrefix_X
		RepositioningSlot.YOffset = ((Holder.SlotSize * Holder.CurrentRow) + (Holder.GapY * Holder.CurrentRow)) * RepositioningSlot.MathPrefix_Y
		
		-- If the current button should be in next row
		if Index % Holder.NumPerRow == 0 then
			Holder.CurrentRow = Holder.CurrentRow + 1
			Holder.CurrentColumn = 0
		else
			Holder.CurrentColumn = Holder.CurrentColumn + 1
		end
		
		E:MoveFrame(RepositioningSlot, RepositioningSlot.XOffset, RepositioningSlot.YOffset)
	end
	
	function Module:UpdateSlotPositions(Holder)
		--sort(Holder.AuraSlot, SortAuras)
		
		if not Holder.HasCenterPositioning then
			
			local Slot
			
			Holder.CurrentColumn = 0
			Holder.CurrentRow = 0
			
			for i = 1, #Holder.AuraSlot do
				Slot = Holder.AuraSlot[i]
				if not Slot then return end
				
				self:RepositionSlot(Holder, i)
			end
		else
			self:UpdateCenterPositioning(Holder)
		end
	end
	
	local FontPath_Base = "db.profile.unitframe.units.%s.%s.%s"
	local function GetFontPath(Holder, ConfigKey, Type)
		return (FontPath_Base):format(ConfigKey or Holder.ConfigKey or Holder.Owner.ConfigKey, lower(Holder.Type), Type)
	end

	-- We use this method to create slots on the fly while updating auras
	function Module:CreateSlot(Holder, Index, ConfigKey)
		local Slot = Holder.AuraSlot[Index]

		if not Slot then
			
			Slot = CreateFrame("Button", format("CUI_AuraIcon%s", Index), Holder)
			Slot:SetSize(Holder.SlotSize, Holder.SlotSize)
			self:CreateIcon(Slot, Holder.Type)
			
			Slot:SetAlpha(Holder.SlotAlpha or 1)
			Slot:EnableMouse(not Holder.ClickThrough)
			
			E:RegisterAutoFont(Slot.Cooldown.Time, GetFontPath(Holder, ConfigKey or Holder.Owner.ConfigKey, 'time'))
			E:RegisterAutoFont(Slot.Count, GetFontPath(Holder, ConfigKey or Holder.Owner.ConfigKey, 'count'))
			
			Holder.CurrentColumn = 0
			Holder.CurrentRow = 0
			Holder.AuraSlot[Index] = Slot

			self:RepositionSlot(Holder, Index)
		end
		
		return Slot
	end
	
	function Module:PopulateSlot(Slot, Unit, RealIndex, AuraType, AuraUnitFaction, Texture, Count, DType, ExpirationTime, UnitCaster, Duration, IsBossDebuff, IsCastByPlayer, AuraName, SpellID, AuraInstanceID)
		Slot.RealIndex = RealIndex -- Used for tooltips
		Slot.AuraClass = AuraType -- Used for tooltips
		
		Slot.Name 		= AuraName
		Slot.Duration 	= Duration
		Slot.Expiration = ExpirationTime
		Slot.SpellID 	= SpellID
		if Unit == 'player' or Unit == 'target' then
			--Slot.Priority = FI:GetAuraPriority(CO.db.profile.auras.units[Unit].aurabars.filterType, SpellID)
			Slot.Priority = 99
		else
			Slot.Priority = 1
		end
		
		Slot.DisplayCount = GetAuraApplicationDisplayCount(Unit, AuraInstanceID, 2, 99)
		
		Slot.Count:Show()
		Slot.Count:SetText(Slot.DisplayCount)
		-- if Count > 1 then
			-- Slot.Count:SetText(Count)
			-- Slot.Count:Show()
		-- else
			-- Slot.Count:Hide()
		-- end
		
		Slot.Tex:SetTexture(Texture)

		local Duration = GetAuraDuration(Unit, AuraInstanceID)
		if Duration then
			--self.RunOnUpdate = true
			Slot.Cooldown:SetCooldownFromDurationObject(Duration, true)
		else			
			--self.RunOnUpdate = false
			Slot.Cooldown:Clear()
		end
		--if CO.db.profile.unitframe.desaturateOtherDebuffs and AuraType == 'HARMFUL' and AuraUnitFaction == AuraType and UnitCaster ~= 'player' then
		-- if not IsCastByPlayer then
			-- Slot.Tex:SetDesaturated(true)
		-- else
			-- Slot.Tex:SetDesaturated(false)
		-- end
		
		E:ColorizeAuraButton(Slot, DType, Unit, AuraType, AuraName, SpellID, CO.db.profile.unitframe.aurasDefaultBorderColor, nil, AuraInstanceID, E.Curves.Auras)
	end

----------------------------------
-- SLOT END
----------------------------------

----------------------------------
-- HOLDER
----------------------------------
	
	function Module:UpdateHolderSize(Holder)
		-- Fires whenever the icons are being updated
		-- Requires Slot Num per Row, GapX, GapY, SlotSize and Num of active Slots
		
		if Holder.ActiveSlots and Holder.ActiveSlots > 0 then
			Holder.SizeX = ((Holder.NumPerRow / Holder.ActiveSlots) <= 1) and ((Holder.NumPerRow * (Holder.SlotSize + Holder.GapX) - Holder.GapX)) or ((Holder.ActiveSlots * (Holder.SlotSize + Holder.GapX) - Holder.GapX))
			Holder.SizeY = (max((ceil(Holder.ActiveSlots / Holder.NumPerRow)), 1) * (Holder.SlotSize + Holder.GapY)) - Holder.GapY
			
			Holder:SetSize(Holder.SizeX, Holder.SizeY)
		else
			Module:DisableHolder(Holder)
		end
	end
	
	function Module:RegisterHolder(Holder, Unit)
		if not self.Holders[Unit] then
			self.Holders[Unit] = {}
		end
		
		tinsert(self.Holders[Unit], Holder)
	end

	function Module:SetFrameEvent(Frame)
		Frame.AuraEventHandler = CreateFrame('Frame')
		Frame.AuraEventHandler.Owner = Frame
	end

	function Module:CreateHolder(Frame, Type)
		local Holder = Frame[Type]

		if not Holder then
			-- Profile unit holds the unit + index for raid40. Name is required, so the user can attach stuff to this holder
			Holder = CreateFrame("Frame", format("%s%sHolder", Frame.ConfigKey, Type), Frame.Overlay)
			Holder:SetFrameStrata("MEDIUM")
			Holder.Owner = Frame
			Holder.unit = Frame.unit
			Holder.ConfigKey = Frame.ConfigKey
			Holder.Type = Type
			Holder.ActiveSlots = 0
			Holder.AuraSlot = {}
			
			if not Frame.AuraHolders then Frame.AuraHolders = {} end
			tinsert(Frame.AuraHolders, Holder)

			Frame[Type] = Holder
		end
	end
	
	function Module:BuildAuras(Frame)
		if not Frame.Buffs then
			for _, Type in pairs(Module.HOLDER_TYPES) do
				Module:CreateHolder(Frame, Type)
			end
			self:SetFrameEvent(Frame)
			
			self:RegisterHolder(Frame, Frame.unit)
			self:LoadConfig(Frame) -- Initial update
		end
	end

----------------------------------
-- HOLDER END
----------------------------------

function Module:IsUnitFromType(Unit, Compare)
	if not Compare then return false end
	local Concat
	
	-- if UF.ToCreate[Unit] then
		-- for i = 1, UF.ToCreate[Unit] do
			-- Concat = Compare .. i
			-- if Concat == Unit then
				-- return true
			-- end
		-- end
	-- end
	
	return Compare:find(Unit)
	
	--return UnitIsUnit(Unit, Compare)
end

function Module:Auras_OnEvent(event, unit)
	if not UnitExists(self.Owner.unit) or (event == 'UNIT_AURA' and not UnitIsUnit(self.Owner.unit, unit)) then return end	
	
	Module:UpdateIcons(self.Owner)
end

function Module:ShouldShowAura(Holder, Type, AuraUnitFaction, AuraName, AuraDuration, SpellID, AuraCaster, IsBossDebuff, IsCastByPlayer)
	local Filtered, FilterType = FI:IsFiltered(Holder.FilterType, SpellID)
	--print("SPELL ID: "..SpellID)
	-- If Blacklisted
	if Filtered then
		return false
	-- If Whitelisted
	elseif not Filtered and FilterType == 'Whitelist' then
		return true
	end
	
	-- If is Debuff from Boss
	if IsBossDebuff then
		return true
	-- If is below min duration
	elseif Holder.MinDuration > AuraDuration then
		return false
	-- If was cast by player
	elseif AuraCaster == "player" then
		return true
	end

	-- If is debuff that is NOT from a group member
	if Type == 'HARMFUL' and (AuraCaster ~= "" and (not self:IsUnitFromType("raid", AuraCaster) and not self:IsUnitFromType("party", AuraCaster))) then
		return true
	end
	
	return true
end

function Module:UpdateHolderIcons(Holder, Type, AuraUnitFaction)
	if Holder.Enabled then
		local FrameIndex, CurrentAuraIndex = 1, 1
		local AuraName, AuraTexture, AuraCount, AuraDType, AuraDuration, AuraExpirationTime, AuraCaster, SpellID, IsBossDebuff, IsCastByPlayer
		local Data
		
		-- Iterate until we reach the last auraID of the unit
		-- We do not stop after N auras, as there could be auras that are whitelisted by the user and would risk losing them
		while true do
			--AuraName, AuraTexture, AuraCount, AuraDType, AuraDuration, AuraExpirationTime, AuraCaster, _, _, SpellID, _, IsBossDebuff, IsCastByPlayer = UnpackAuraData(GetAuraDataByIndex(Holder.Owner.unit, CurrentAuraIndex, Type))
			
			Data = GetAuraDataByIndex(Holder.Owner.unit, CurrentAuraIndex, Type)
			--self.AuraName, self.AuraTexture, self.AuraCount, self.AuraDType, self.AuraDuration, self.AuraExpirationTime, self.AuraSpellID = 
			--local Data.name, Data.icon, Data.applications, Data.dispelName, Data.duration, Data.expirationTime, Data.sourceUnit, Data.isStealable, Data.nameplateShowPersonal, Data.spellId, Data.canApplyAura, Data.isBossAura, Data.isFromPlayerOrPlayerPet, Data.nameplateShowAll, Data.timeMod
			
			if Data then
				AuraName, AuraTexture, AuraCount, AuraDType, AuraDuration, AuraExpirationTime, AuraCaster, SpellID, IsBossDebuff, IsCastByPlayer = Data.name, Data.icon, Data.applications, Data.dispelName, Data.duration, Data.expirationTime, Data.sourceUnit, Data.spellId, Data.isBossAura, Data.isFromPlayerOrPlayerPet
				
				if AuraName and FrameIndex <= Holder.Num_Auras then
					
					--if self:ShouldShowAura(Holder, Type, AuraUnitFaction, AuraName, AuraDuration, SpellID, AuraCaster, IsBossDebuff, IsCastByPlayer) then
					if true then
						Holder.AuraSlot[FrameIndex] = (Holder.AuraSlot[FrameIndex] or self:CreateSlot(Holder, FrameIndex))
						
						self:PopulateSlot(Holder.AuraSlot[FrameIndex], Holder.Owner.unit, CurrentAuraIndex, Type, AuraUnitFaction, AuraTexture, AuraCount, AuraDType, AuraExpirationTime, AuraCaster, AuraDuration, IsBossDebuff, IsCastByPlayer, AuraName, SpellID, Data.auraInstanceID)
						
						Holder.AuraSlot[FrameIndex]:Show()
						
						FrameIndex = FrameIndex + 1
					end
					
					CurrentAuraIndex = CurrentAuraIndex + 1
				else
					break
				end
			
			else
				break
			end
		end
		
		Holder.ActiveSlots = FrameIndex - 1
		self:UpdateHolderSize(Holder)
	else
		Holder.ActiveSlots = 0
	end
		
	for i = (Holder.ActiveSlots + 1), (Holder.Num_Auras or 0) do
		if Holder.AuraSlot[i] then
			Holder.AuraSlot[i]:Hide()
		end
	end
	
	self:UpdateSlotPositions(Holder)
end

function Module:UpdateIcons(Frame)
	if not Frame.Auras then return end
	
	AuraUnitFaction = UnitCanAttack(Frame.unit, E.STR.player) and E.STR.HARMFUL or E.STR.HELPFUL
	
	Module:UpdateHolderIcons(Frame.Buffs, 'HELPFUL', AuraUnitFaction)
	Module:UpdateHolderIcons(Frame.Debuffs, 'HARMFUL', AuraUnitFaction)
end

function Module:ForceUpdate()
	Module:UpdateIcons(self.Frame)
end

function Module:UpdateAll()
	for _, Frame in pairs(self.Frames) do
		Frame.Auras:ForceUpdate()
	end
end

function Module:Enable()
	
end

function Module:Disable()
	
end

function Module:Create(F)
	self:BuildAuras(F)
	F.Auras = {}
	F.Auras.Frame = F
	F.Auras.unit = F.unit
	F.Auras.Enable = self.Enable
	F.Auras.Disable = self.Disable
	F.Auras.ForceUpdate = self.ForceUpdate
	F.Auras.UpdateUnit = UpdateUnit
	
	tinsert(Module.Frames, F)
end

---------- Add Module
UF:RegisterModule("Auras", Module)