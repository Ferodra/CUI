local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, L, UF = E:LoadModules("Config", "Locale", "Unitframes")

----------------------------------------------
local _
local CreateFrame		= CreateFrame
local max				= math.max
local floor				= math.floor
local ceil				= math.ceil
local format			= string.format
local tinsert			= table.insert
local pairs				= pairs
local type				= type
local UnitAura			= UnitAura
local DebuffTypeColor	= DebuffTypeColor
local UnitExists		= UnitExists
local UnitCanAttack		= UnitCanAttack
----------------------------------------------

local MouseOverUpdater = CreateFrame("Frame")
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
				-> UnitAuraClass = HELPFUL or HARMFUL, based on faction towards player

------------------------------------------------]]

function Module:ToggleTestMode(state)
	
	self.TestMode = state
	local Holder, Slot, AuraType
	
	for Unit, Entry in pairs(self.Holders) do
		for _, Type in pairs(Module.HOLDER_TYPES) do
			
			Holder = Entry[Type]
			
			if state then
				
				Holder:UnregisterAllEvents()
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
				if not Holder:IsEventRegistered("UNIT_AURA") then
					Holder:RegisterEvent("PLAYER_ENTERING_WORLD")
					Holder:RegisterUnitEvent("UNIT_AURA", Holder.Unit)
				end
				
				Holder.ActiveSlots = 0
			end
		end
		
		if not state then
			Module:UpdateIcons(Unit)
		end
	end
end

local function SortByExpiration(a,b)
	if a and b then
		if a:IsShown() and b:IsShown() then
			if a:GetParent().SortDirection == "+" then
				return a.Expiration > b.Expiration
			else
				return a.Expiration < b.Expiration
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
	Slot.Tex:SetSize(32, 32)
	
	Slot.Highlight = Slot:CreateTexture(nil, "HIGHLIGHT")
	Slot.Highlight:SetColorTexture(1, 1, 1, 0.45)
	
	--E:SkinButtonIcon(Slot.Tex, {0.3, 0.3, 0.8, 1})
	
	self:SetupTooltip(Slot)
	self:SetupCooldown(Slot)
	
	Slot.Cooldown.Time = CreateFrame("Frame", nil, Slot.Cooldown)
	Slot.Cooldown.Time:Hide()
	Slot.Cooldown.Time:SetAllPoints()
	Slot.Cooldown.Time:SetScript("OnUpdate", self.Cooldown_OnUpdate)
	Slot.Cooldown.Time.Text = self:InitFont(Slot, Slot.Cooldown.Time, "Time")
	
	hooksecurefunc(Slot.Cooldown, "SetCooldown", Module.Cooldown_Set)
	
		Slot.FontOverlay = CreateFrame("Frame", nil, Slot)
		Slot.FontOverlay:SetAllPoints(true)
	Slot.Count = self:InitFont(Slot, Slot.FontOverlay, "Count")
	
	if not CO.db.profile.unitframe.unitBuffs.useMasque and not CO.db.profile.unitframe.unitDebuffs.useMasque then return end
	
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
	if Type == "Buffs" and CO.db.profile.unitframe.unitBuffs.useMasque then
		Target = MasqueGroup_Buffs
	elseif Type == "Debuffs" and CO.db.profile.unitframe.unitDebuffs.useMasque then
		Target = MasqueGroup_Debuffs
	end
	if Target then
		Target:AddButton(Slot, ButtonData)
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
	
	local function BuildTooltip(self)
		if not Module.TestMode then
			GameTooltip:SetOwner(self)
			GameTooltip:SetUnitAura(self:GetParent():GetParent().Unit, self.RealIndex, self.AuraClass)
		end
	end
	
	local function AuraMouseOver_OnUpdate(self, elapsed)
		self.UpdateDelay = (self.UpdateDelay or 0) + elapsed
		
		if self.UpdateDelay >= 0.25 then
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
			AuraMouseOver_OnUpdate(MouseOverUpdater, 999) -- Force update to prevent flashing
		end
	end

	local function AuraButton_OnEnter(self)
		SetAuraMouseUpdater(self, true)
	end
	local function AuraButton_OnLeave(self)
		SetAuraMouseUpdater(self, false)
		GameTooltip:Hide()
	end

	function Module:SetupTooltip(Slot)
		Slot:SetScript("OnEnter", AuraButton_OnEnter)
		Slot:SetScript("OnLeave", AuraButton_OnLeave)
	end
	
----------------------------------
-- AURA TOOLTIP END
----------------------------------

----------------------------------
-- LOAD PROFILE
----------------------------------
local function ConfigLoader(UnitOrFrame)	
	local Frame
	
	if type(UnitOrFrame) == "string" then
		Frame = UF.Frames[UnitOrFrame]
	elseif type(UnitOrFrame) == "table" then
		Frame = UnitOrFrame
	end
	
	if not Frame then return end
	
	-------------------------------------------------------------------------
		local ProfileTarget = Module.db.units[Frame.ProfileUnit]
		
		for i=1, #Module.Holders[Frame.Unit] do
		-- Aura config
			-- Let's clear those bois first, before we get into any trouble
			for _, Type in pairs(Module.HOLDER_TYPES) do
				Module.Holders[Frame.Unit][i][Type]:ClearAllPoints()
			end
			
			for _, Type in pairs(Module.HOLDER_TYPES) do
				local Holder, OtherHolder, Profile, OtherProfile, PositionConflict
				Holder = Module.Holders[Frame.Unit][i][Type]
				Profile = ProfileTarget[string.lower(Type)]
				OtherHolder = Module.Holders[Frame.Unit][i][(Type == "Buffs") and "Debuffs" or "Buffs"]
				OtherProfile = ProfileTarget[string.lower((Type == "Buffs") and "Debuffs" or "Buffs")]
				
				Holder.OtherHolder = OtherHolder
				Holder.Enabled 		= Profile.enable
				Holder.NumPerRow 	= Profile.numPerRow
				Holder.MaxWraps 	= Profile.maxWraps
				Holder.Num_Auras	= Holder.NumPerRow * Holder.MaxWraps
				Holder.Position		= Profile.position
				Holder.AttachTo		= Profile.attachTo
				Holder.SlotSize 	= Profile.size
				Holder.GapX 		= Profile.gapX
				Holder.GapY 		= Profile.gapY
				Holder.OffsetX 		= Profile.offsetX
				Holder.OffsetY 		= Profile.offsetY
				Holder.SortDirection= Profile.sortDirection
				Holder.SortBy		= Profile.sortBy
				
				if Holder.Position == "CENTER" or Holder.Position == "TOP" or Holder.Position == "BOTTOM" then
					Holder.HasCenterPositioning = true
				else
					Holder.SlotAnchor	= ((Holder.Position:find("TOP")) and "BOTTOM" or "TOP") .. ((Holder.Position:find("LEFT")) and "LEFT" or "RIGHT")
					Holder.HasCenterPositioning = false
				end
				
				if Profile.enable then
					
					PositionConflict = false
					
					-- Position
					if Holder.AttachTo == "Frame" then
						Holder:SetPoint(E:InversePosition(Holder.Position), Module.Holders[Frame.Unit][i], Holder.Position, Holder.OffsetX, Holder.OffsetY)
					elseif Holder.AttachTo == "Buffs" then
						if OtherHolder.AttachTo ~= "Buffs" and OtherProfile.attachTo ~= "Debuffs" and Type ~= "Buffs" then
							Holder:SetPoint(E:InversePosition(Holder.Position), Module.Holders[Frame.Unit][i].Buffs, Holder.Position, Holder.OffsetX, Holder.OffsetY)
						else
							PositionConflict = true
						end
					elseif Holder.AttachTo == "Debuffs" then
						if OtherHolder.AttachTo ~= "Debuffs" and OtherProfile.attachTo ~= "Buffs" and Type ~= "Debuffs" then
							Holder:SetPoint(E:InversePosition(Holder.Position), Module.Holders[Frame.Unit][i].Debuffs, Holder.Position, Holder.OffsetX, Holder.OffsetY)
						else
							PositionConflict = true
						end
					end
					
					if PositionConflict then
						Holder:SetPoint(E:InversePosition(Holder.Position), Module.Holders[Frame.Unit][i], Holder.Position, Holder.OffsetX, Holder.OffsetY)
						E:print("There is an issue with the " .. Frame.ProfileUnit .. " " .. Type .. ", because they are attached to " .. Holder.AttachTo .. ", which is attached to " .. OtherProfile.attachTo)
					end
					
					for k, Slot in pairs(Holder.AuraSlot) do
						Slot:SetSize(Holder.SlotSize, Holder.SlotSize)
						
						Slot:Hide() -- To hide not required slots. Will be shown on next update
					end
					
					if not Holder:IsEventRegistered("UNIT_AURA") then
						Holder:RegisterEvent("PLAYER_ENTERING_WORLD")
						Holder:RegisterUnitEvent("UNIT_AURA", Holder.Unit)
					end
				else
					-- Just scale down, since we may want to anchor stuff
					Holder:UnregisterAllEvents()
					Module:DisableHolder(Holder)
					Holder:ClearAllPoints()
					Holder:SetPoint(E:InversePosition(Holder.Position), Module.Holders[Frame.Unit][i], Holder.Position, Holder.OffsetX, Holder.OffsetY)
				end
			end
			
			if not Module.TestMode then
				-- Force Update
				Module:UpdateIcons(Frame.Unit)
			else
				Module:ToggleTestMode(true)
			end
			
			if MasqueGroup_Debuffs then MasqueGroup_Debuffs:ReSkin() end
			if MasqueGroup_Buffs then MasqueGroup_Buffs:ReSkin() end
		end
	
	-------------------------------------------------------------------------
end

function Module:DisableHolder(Holder)
	if not Holder.OtherHolder.Enabled then
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
function Module:LoadProfile(Unit)
	
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
	Slot.Cooldown:SetHideCountdownNumbers(true)
	Slot.Cooldown:SetParent(Slot)
	Slot.Cooldown:SetAllPoints(Slot)
	Slot.Cooldown:SetReverse(true)
	Slot.Cooldown:Show()
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

	local CurrentVisible
	function Module:UpdateCenterPositioning(Holder)
		CurrentVisible = Holder.ActiveSlots
		
		for i = 1, #Holder.AuraSlot do
			if select(1, Holder.AuraSlot[i]:GetPoint()) ~= "CENTER" then
				Holder.AuraSlot[i]:ClearAllPoints()
			end
			Holder.AuraSlot[i]:SetPoint("CENTER", Holder, "CENTER", Module:GetGrowthDirection(Holder.SlotSize, "CENTER", i, CurrentVisible, Holder.GapX), 0)
		end
	end

	-- @TODO: Center requires active positioning
	local GrowthDirection
	function Module:GetGrowthDirection(Size, Direction, NumCurrent, NumVisible, Gap)
		Gap = Gap or 1
		
		if Direction == "UP" or Direction == "RIGHT" then
			GrowthDirection = Size + Gap
		elseif Direction == "DOWN" or Direction == "LEFT" then
			GrowthDirection = (Size + Gap) * (-1)
		elseif Direction == "CENTER" and NumCurrent and NumVisible then
			GrowthDirection = (NumCurrent - NumVisible / 2) * (Size + Gap) - Size / 2
		end
		
		return GrowthDirection
	end

	local InitFontData = {["Time"] = {"CENTER", 0, 0, 0, 0, "MIDDLE"}, ["Count"] = {"BOTTOMRIGHT", 0, 0, -2, 2, "RIGHT"}} -- Alignment, Width, Height, XOffset
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
	
	local RepositioningSlot, RepositioningOffsetX, RepositioningOffsetY
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
		if not RepositioningSlot.PointCache or RepositioningSlot.PointCache ~= Holder.SlotAnchor then
			RepositioningSlot:ClearAllPoints()
		end
		
		RepositioningSlot:SetPoint(Holder.SlotAnchor, Holder, Holder.SlotAnchor)
		RepositioningSlot.PointCache = Holder.SlotAnchor
		
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
		sort(Holder.AuraSlot, SortByExpiration)
		
		local Slot
		
		if not Holder.HasCenterPositioning then
			
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

	-- We use this method to create slots on the fly while updating auras
	function Module:CreateSlot(Holder, Index, ProfileUnit)
		if Holder.AuraSlot[Index] then return end
		
		Holder.AuraSlot[Index] = CreateFrame("Button", format("CUI_AuraIcon%s", Index), Holder)
		Holder.AuraSlot[Index]:SetSize(Holder.SlotSize, Holder.SlotSize)
		
		Holder.AuraSlot[Index]:EnableMouse(true)
		
		self:CreateIcon(Holder.AuraSlot[Index], Holder.Type)
		
		E:RegisterPathFont(Holder.AuraSlot[Index].Cooldown.Time.Text, "db.profile.unitframe.units." .. (ProfileUnit or Holder.ProfileUnit or Holder.Parent.ProfileUnit) .. "."  .. string.lower(Holder.Type) .. ".time")
		E:RegisterPathFont(Holder.AuraSlot[Index].Count, "db.profile.unitframe.units." .. (ProfileUnit or Holder.ProfileUnit or Holder.Parent.ProfileUnit) .. "."  .. string.lower(Holder.Type) .. ".count")
		
		Holder.CurrentColumn = 0
		Holder.CurrentRow = 0
		
		self:RepositionSlot(Holder, Index)
		
		return Holder.AuraSlot[Index]
	end
	
	function Module:PopulateSlot(Slot, Unit, RealIndex, AuraType, UnitAuraClass, Texture, Count, DType, ExpirationTime, Duration, IsBossDebuff, IsCastByPlayer, AuraName, SpellID)
		Slot.RealIndex = RealIndex -- Used for tooltips
		Slot.AuraClass = AuraType -- Used for tooltips
		
		Slot.Name 		= AuraName
		Slot.Duration 	= Duration
		Slot.Expiration = ExpirationTime
		
		if Count > 1 then
			Slot.Count:SetText(Count)
			Slot.Count:Show()
		else
			Slot.Count:Hide()
		end
		
		Slot.Tex:SetTexture(Texture)
		E:ColorizeAuraButton(Slot, DType, Unit, AuraType, AuraName, SpellID, CO.db.profile.unitframe.aurasDefaultBorderColor)
		
		if Slot.Cooldown and ExpirationTime and Duration and Duration > 0 then
			Slot.Cooldown:SetCooldown(ExpirationTime - Duration, Duration)
			Slot.Cooldown:Show()
		else
			Slot.Cooldown:Hide()
		end
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
		
		if Holder.ActiveSlots > 0 then
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
		
		table.insert(self.Holders[Unit], Holder)
	end

	function Module:SetHolderEvent(Holder, Unit)
		Holder:RegisterEvent("PLAYER_ENTERING_WORLD")
		Holder:RegisterUnitEvent("UNIT_AURA", Unit)
		
		Holder:SetScript("OnEvent", Module.Holder_OnEvent)
	end

	function Module:CreateHolder(Frame, Type)
		if not Frame[Type] then
			-- Profile unit holds the unit + index for raid40. Name is not really needed, but why not
			Frame[Type] = CreateFrame("Frame", format("%s%sHolder", Frame.ProfileUnit, Type), Frame)
			Frame[Type]:SetFrameStrata("LOW")
			Frame[Type].Parent = Frame
			Frame[Type].Unit = Frame.Unit
			Frame[Type].ProfileUnit = Frame.ProfileUnit
			Frame[Type].Type = Type
			Frame[Type].AuraSlot = {}
			
			self:SetHolderEvent(Frame[Type], Frame.Unit)
		end
	end
	
	function Module:BuildAuras(Frame)
		if not Frame.Buffs then
			for _, Type in pairs(Module.HOLDER_TYPES) do
				Module:CreateHolder(Frame, Type)
			end
			
			self:RegisterHolder(Frame, Frame.Unit)
			self:LoadProfile(Frame) -- Initial update
		end
	end

----------------------------------
-- HOLDER END
----------------------------------

local Concat
function Module:IsUnitFromType(Unit, Compare)
	if not Compare then return false end
	
	if UF.ToCreate[Unit] then
		for i = 1, UF.ToCreate[Unit] do
			Concat = Compare .. i
			if Concat == Unit then
				return true
			end
		end
	end
	
	return false
end

function Module:Holder_OnEvent(event, unit)
	if not UnitExists(self.Unit) or (event == 'UNIT_AURA' and not UnitIsUnit(self.Unit, unit)) then return end
	
	Module:UpdateIcons(self.Unit)
end

function Module:ShouldShowAura(AuraName, SpellID, AuraCaster, IsBossDebuff, IsCastByPlayer)
	if IsBossDebuff then
		return true
	elseif IsCastByPlayer then
		return true
	end

	if AuraCaster ~= "" and (not self:IsUnitFromType("raid", AuraCaster) and not self:IsUnitFromType("party", AuraCaster)) then
		return true
	end
	
	return false
end

local CurrentHolder, CurrentSlot, AuraName, AuraTexture, AuraCount, AuraDType, AuraDuration, AuraExpirationTime, AuraType, CurrentAuraIndex, IterationIndex, IsBossDebuff, IsCastByPlayer, AuraCaster, RealIndex, SpellID
function Module:UpdateIcons(Unit)
	
	UnitAuraClass = UnitCanAttack(Unit, E.STR.player) and E.STR.HARMFUL or E.STR.HELPFUL
	
	
	-- Buffs
	for i=1, #self.Holders[Unit] do
		CurrentHolder = self.Holders[Unit][i].Buffs
		
			if CurrentHolder.Enabled then
				IterationIndex = 0
				CurrentAuraIndex = 1
				
				-- Iterate until we reach the last auraID of the unit
				for i = 1, CurrentHolder.Num_Auras do
					AuraName, AuraTexture, AuraCount, AuraDType, AuraDuration, AuraExpirationTime, AuraCaster, _, _, SpellID, _, IsBossDebuff, IsCastByPlayer = UnitBuff(Unit, CurrentAuraIndex)
					
					if AuraName then
						CurrentHolder.AuraSlot[i] = (CurrentHolder.AuraSlot[i] or self:CreateSlot(CurrentHolder, i))
						
						-- Used for tooltips
						RealIndex = CurrentAuraIndex
						AuraType = "HELPFUL"
						
						self:PopulateSlot(CurrentHolder.AuraSlot[i], Unit, RealIndex, AuraType, UnitAuraClass, AuraTexture, AuraCount, AuraDType, AuraExpirationTime, AuraDuration, IsBossDebuff, IsCastByPlayer, AuraName, SpellID)
						
						IterationIndex = IterationIndex + 1
						CurrentAuraIndex = CurrentAuraIndex + 1
						
						CurrentHolder.AuraSlot[i]:Show()
					end
				end
				
				CurrentHolder.ActiveSlots = IterationIndex
				self:UpdateHolderSize(CurrentHolder)
			else
				CurrentHolder.ActiveSlots = 0
			end
		
		for i = (CurrentHolder.ActiveSlots + 1), (CurrentHolder.Num_Auras or 0) do
			if CurrentHolder.AuraSlot[i] then
				CurrentHolder.AuraSlot[i]:Hide()
			end
		end
		
		self:UpdateSlotPositions(CurrentHolder)
		
		
		-- Debuffs
		CurrentHolder = self.Holders[Unit][i].Debuffs
			if CurrentHolder.Enabled then
				FrameIndex = 1
				CurrentAuraIndex = 1
				
				-- Iterate until we reach the last aura of the unit
				while true do
					
					AuraName, AuraTexture, AuraCount, AuraDType, AuraDuration, AuraExpirationTime, AuraCaster, _, _, SpellID, _, IsBossDebuff, IsCastByPlayer = UnitDebuff(Unit, CurrentAuraIndex)
					
					if AuraName and FrameIndex <= CurrentHolder.Num_Auras then
						if self:ShouldShowAura(AuraName, SpellID, AuraCaster, IsBossDebuff, IsCastByPlayer) then
							CurrentHolder.AuraSlot[FrameIndex] = (CurrentHolder.AuraSlot[FrameIndex] or self:CreateSlot(CurrentHolder, FrameIndex))
							
							-- Used for tooltips
							RealIndex = CurrentAuraIndex
							AuraType = "HARMFUL"
							
							self:PopulateSlot(CurrentHolder.AuraSlot[FrameIndex], Unit, RealIndex, AuraType, UnitAuraClass, AuraTexture, AuraCount, AuraDType, AuraExpirationTime, AuraDuration, IsBossDebuff, IsCastByPlayer, AuraName, SpellID)
							CurrentHolder.AuraSlot[FrameIndex]:Show()
							
							FrameIndex = FrameIndex + 1
							CurrentAuraIndex = CurrentAuraIndex + 1
						end
					else
						break
					end
				end
				
				CurrentHolder.ActiveSlots = FrameIndex - 1
				self:UpdateHolderSize(CurrentHolder)
			else
				CurrentHolder.ActiveSlots = 0
			end
		
		for i = (CurrentHolder.ActiveSlots + 1), (CurrentHolder.Num_Auras or 0) do
			if CurrentHolder.AuraSlot[i] then
				CurrentHolder.AuraSlot[i]:Hide()
			end
		end
		
		self:UpdateSlotPositions(CurrentHolder)
	end
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
	F.Auras.Unit = F.Unit
	F.Auras.Enable = self.Enable
	F.Auras.Disable = self.Disable
	F.Auras.ForceUpdate = self.Holder_OnEvent
	
	table.insert(Module.Frames, F)
end

---------- Add Module
UF:RegisterModule("Auras", Module)