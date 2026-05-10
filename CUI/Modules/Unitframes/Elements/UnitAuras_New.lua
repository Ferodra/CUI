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
local sort				= table.sort
local tinsert			= table.insert
local pairs				= pairs
local type				= type
local UnitAura							= C_TooltipInfo.GetUnitAura
local GetAuraDataByIndex 				= C_UnitAuras and C_UnitAuras.GetAuraDataByIndex
local UnpackAuraData 					= AuraUtil and AuraUtil.UnpackAuraData
local DebuffTypeColor					= DebuffTypeColor
local UnitExists						= UnitExists
local UnitCanAttack						= UnitCanAttack
local GetAuraDuration 					= C_UnitAuras.GetAuraDuration
local GetAuraApplicationDisplayCount 	= C_UnitAuras.GetAuraApplicationDisplayCount
local GetAuraDispelTypeColor			= C_UnitAuras.GetAuraDispelTypeColor
local GetAuraDataByAuraInstanceID		= C_UnitAuras.GetAuraDataByAuraInstanceID
----------------------------------------------

local MouseOverUpdater = CreateFrame("Frame", "CUI_UnitAurasMouseoverUpdater")
local AuraCache = {['Buffs'] = {}, ['Debuffs'] = {}}
local AuraCacheHandler = CreateFrame('Frame')
local Module = {}
Module.Frames = {}
Module.Holders = {}

Module.AURA_SIZE 			= 32 -- X and Y size
Module.HOLDER_TYPES			= {"Buffs", "Debuffs"}
Module.AURA_TYPES 			= {"HELPFUL", "HARMFUL"}

local buffFilter, debuffFilter = 'HELPFUL', 'HARMFUL'

local Masque = E.Libs.Masque
local MasqueGroup_Buffs = Masque and Masque:Group("CUI", format("%s %s", L["unit"], L["Buffs"]))
local MasqueGroup_Debuffs = Masque and Masque:Group("CUI", format("%s %s", L["unit"], L["Debuffs"]))

local ForceUpdateInfo = {['isFullUpdate'] = true}


----------------------------------
-- AURA CHACHING BEGIN
----------------------------------

local DebuffFilter = {
	['limited'] = 'HARMFUL|PLAYER',
	['all'] = 'HARMFUL'
}

local function SortAuras(a, b)
	if(a.isPlayerAura ~= b.isPlayerAura) then
		return a.isPlayerAura
	end

	return a.auraInstanceID < b.auraInstanceID
end


local function AuraCache_OnEvent(self, event, unit, info)
	local Cache, CacheType, BuffsChanged, DebuffsChanged

    if info.isFullUpdate then
		
        local Data, Type
		local CurrentAuraIndex = 1

		-- Write buffs and debuffs separately, because GetAuraDataByIndex NEEDS a filter. It will only return buffs otherwise

		-- Buffs
		if self.Buffs.Enabled then
			wipe(self.Buffs.AuraCache)

			while true do
				--if CurrentAuraIndex > self.Buffs.Num_Auras then break end

				Data = GetAuraDataByIndex(self.Owner.unit, CurrentAuraIndex, "HELPFUL")

				if (not (Data and Data.name)) then break end
				self.Buffs.AuraCache[Data.auraInstanceID] = Module:ProcessAuraData(self, Data)

				CurrentAuraIndex = CurrentAuraIndex + 1
			end

			CurrentAuraIndex = 1

			BuffsChanged = true
		end

		-- Debuffs
		if self.Debuffs.Enabled then
			wipe(self.Debuffs.AuraCache)

			while true do
				--if CurrentAuraIndex > self.Debuffs.Num_Auras then break end

				Data = GetAuraDataByIndex(self.Owner.unit, CurrentAuraIndex, DebuffFilter[self.isHostileUnit and 'limited' or 'all'])

				if (not (Data and Data.name)) then break end
				self.Debuffs.AuraCache[Data.auraInstanceID] = Module:ProcessAuraData(self, Data)

				CurrentAuraIndex = CurrentAuraIndex + 1
			end

			DebuffsChanged = true
		end
		
	end
	if info.addedAuras then
		for _, Data in pairs(info.addedAuras) do
			if not Data.isHarmful then
				if self.Buffs.Enabled then
					self.Buffs.AuraCache[Data.auraInstanceID] = Module:ProcessAuraData(self, Data)
					
					if self.Buffs.AuraCache[Data.auraInstanceID] then
						BuffsChanged = true
					end
				end
			else
				if self.Debuffs.Enabled then
					self.Debuffs.AuraCache[Data.auraInstanceID] = Module:ProcessAuraData(self, Data)

					if self.Debuffs.AuraCache[Data.auraInstanceID] then
						DebuffsChanged = true
					end
				end
			end
        end
	end
	if info.updatedAuraInstanceIDs then
		local Data
		for _, auraInstanceID in pairs(info.updatedAuraInstanceIDs) do
			Data = Module:GetAuraData(unit, auraInstanceID)

			if self.Buffs.AuraCache[auraInstanceID] then
				self.Buffs.AuraCache[auraInstanceID] = Data

				BuffsChanged = true
			elseif self.Debuffs.AuraCache[auraInstanceID] then
				self.Debuffs.AuraCache[auraInstanceID] = Data

				DebuffsChanged = true
			end
        end
	end
	if info.removedAuraInstanceIDs then
		for _, auraInstanceID in pairs(info.removedAuraInstanceIDs) do
			if self.Buffs.AuraCache[auraInstanceID] then
				self.Buffs.AuraCache[auraInstanceID] = nil

				BuffsChanged = true
			elseif self.Debuffs.AuraCache[auraInstanceID] then
				self.Debuffs.AuraCache[auraInstanceID] = nil

				DebuffsChanged = true
			end
        end
	end

	Module:ApplyAuras(self, BuffsChanged, DebuffsChanged)
end

function Module:ApplyAuras(Frame, BuffsChanged, DebuffsChanged)
	if BuffsChanged then
		self:RebuildSortedAuras(Frame.Buffs)

		for index, slot in pairs(Frame.Buffs.AuraSlot) do
			slot.IsActive = false
		end

		local Slot, Index = nil, 1
		for auraInstanceID, AuraData in ipairs(Frame.Buffs.SortedAuras) do
			Slot = self:GetNextAvailableSlot(Frame.Buffs)
			self:ApplyAuraDataToSlot(Slot, AuraData)

			Index = Index + 1
		end

		for i=Index, #Frame.Buffs.AuraSlot do
			Frame.Buffs.AuraSlot[i]:Hide()
		end

		self:UpdateHolderSize(Frame.Buffs, true)
	end
	if DebuffsChanged then
		self:RebuildSortedAuras(Frame.Debuffs)

		for index, slot in ipairs(Frame.Debuffs.AuraSlot) do
			slot.IsActive = false
		end

		local Slot, Index = nil, 1
		for auraInstanceID, AuraData in ipairs(Frame.Debuffs.SortedAuras) do
			Slot = self:GetNextAvailableSlot(Frame.Debuffs)
			self:ApplyAuraDataToSlot(Slot, AuraData)

			Index = Index + 1
		end

		for i=Index, #Frame.Debuffs.AuraSlot do
			Frame.Debuffs.AuraSlot[i]:Hide()
		end

		self:UpdateHolderSize(Frame.Debuffs, true)
	end
end

function Module:ProcessAuraData(Frame, Data)
    Data.type = Data.isHarmful and "HARMFUL" or "HELPFUL"

	-- Filter out non-player debuffs on hostiles
	if Frame.isHostileUnit and Data.isHarmful then
		if not Data.isFromPlayerOrPlayerPet then
			return nil
		end
	end
	
    return Data
end

function Module:RebuildSortedAuras(Holder)
	wipe(Holder.SortedAuras)

	for auraInstanceID in next, Holder.AuraCache do
		tinsert(Holder.SortedAuras, Holder.AuraCache[auraInstanceID])
	end

	sort(Holder.SortedAuras, SortAuras)
end

function Module:GetAuraData(unit, auraInstanceID)
    return GetAuraDataByAuraInstanceID(unit, auraInstanceID)
end

function Module:SetupAuraCaching(Frame)
    Frame.Auras:RegisterUnitEvent('UNIT_AURA', Frame.unit)
    Frame.Auras:SetScript('OnEvent', AuraCache_OnEvent)
end

function Module:GetNextAvailableSlot(Holder)
	local AvailableSlot = false
	local NumActive = 0
	-- Check if any existing slot isn't in use currently
	for i=1, #Holder.AuraSlot do
		--print(i, Holder.AuraSlot[i].IsActive)
		if not Holder.AuraSlot[i].IsActive then
			AvailableSlot = Holder.AuraSlot[i]
			break
		else
			NumActive = i
		end
	end

	-- If we're at display limit, return invalid index
	if NumActive >= Holder.Num_Auras then return false end

	-- Create a new slot if we didn't find an unused one
	if not AvailableSlot then
		Holder.AuraSlot[#Holder.AuraSlot + 1] = self:CreateSlot(Holder, #Holder.AuraSlot + 1)
	end
	
	return AvailableSlot or Holder.AuraSlot[#Holder.AuraSlot]
end

----------------------------------
-- AURA CHACHING END
----------------------------------

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
					
					self:PopulateSlot(Holder, i, 1, AuraType, AuraType, 136081, "none", GetTime() + 7200, 7200, true, true, nil, nil)
					
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

local function SortByPriority(a,b)
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
		Slot.FontOverlay = CreateFrame("Frame", nil, Slot)
		Slot.FontOverlay:SetAllPoints(true)
	Slot.Count = self:InitFont(Slot, Slot.FontOverlay, "Count")
	
	if not CO.db.char.unitframe.unitBuffs.useMasque and not CO.db.char.unitframe.unitDebuffs.useMasque then return end
	
	local Target
	if Type == "Buffs" and CO.db.char.unitframe.unitBuffs.useMasque then
		Target = MasqueGroup_Buffs
	elseif Type == "Debuffs" and CO.db.char.unitframe.unitDebuffs.useMasque then
		Target = MasqueGroup_Debuffs
	end
	if Target then
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
            AutoCast = nil
        }

		Target:AddButton(Slot, ButtonData)
		-- Don't ReSkin here, as it will: Impact performance, due to rapid creation of buttons and cause flickering, since the whole group is being iterated
		--Target:ReSkin()
		
		if Slot.__MSQ_BaseFrame then
			Slot.__MSQ_BaseFrame:SetFrameLevel(2) --Lower the framelevel to fix issue with buttons created during combat
		end
	end
	
	-- Hide initially
	Slot:Hide()
	Slot.IsActive = false
end

----------------------------------
-- AURA TOOLTIP
----------------------------------
	local TooltipUpdateFrequency = 0.25
	local function BuildTooltip(self)
		if not Module.TestMode then
			GameTooltip:SetOwner(self)
			GameTooltip:SetUnitAuraByAuraInstanceID(self.Owner.Owner.unit, self.AuraInstanceID)
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
			--FI:AddSpellIDToUnitAurabarsFilter(self.SpellID, self:GetParent().Owner.unit, self.Duration)
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
				OtherHolder = Frame.Auras[(Type == "Buffs") and "Debuffs" or "Buffs"]
				
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
			OtherHolder = Frame.Auras[(Type == "Buffs") and "Debuffs" or "Buffs"]
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
						Slot.IsActive = false
					end
					
					-- if not Holder:IsEventRegistered("UNIT_AURA") then
						-- Holder:RegisterEvent("PLAYER_ENTERING_WORLD")
						-- Holder:RegisterUnitEvent("UNIT_AURA", Holder.unit)
					-- end
				else
					-- Just scale down, since we may want to anchor stuff
					for k, Slot in pairs(Holder.AuraSlot) do
						Slot:Hide() -- To hide not required slots. Will be shown on next update
						Slot.IsActive = false
					end

					wipe(Holder.AuraCache)
					Module:DisableHolder(Holder)
				end
			end
			
			if RefreshUnitOnly then return end
			
			if MasqueGroup_Debuffs then MasqueGroup_Debuffs:ReSkin() end
			if MasqueGroup_Buffs then MasqueGroup_Buffs:ReSkin() end
		end
		
		if not Module.TestMode then
			-- Force Update
			--Module:UpdateIcons(Frame, ForceUpdateInfo)
			Module:SetupAuraCaching(Frame)
			Frame.Auras:ForceUpdate()
		else
			--Module:ToggleTestMode(true)
		end
	
	-------------------------------------------------------------------------
end

local function UpdateUnit(self)
	--local Unit = self.Frame.unit
	--ConfigLoader(self.Frame, nil, true)
	ConfigLoader(self.Frame)
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
		Slot.Cooldown.Time.Owner = Slot.Cooldown
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
	
	function Module:RepositionSlot(Holder, Index)
		local RepositioningSlot = Holder.AuraSlot[Index]
		--if not RepositioningSlot.IsActive then return end
		
		if Holder.HasCenterPositioning then return end

        local PrefixX, PrefixY, OffsetX, OffsetY
			
		if Holder.Position:find("RIGHT") then
			PrefixX = -1
		else
			PrefixX = 1
		end
		if Holder.Position:find("BOTTOM") then
			PrefixY = -1
		else
			PrefixY = 1
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
		OffsetX = ((Holder.SlotSize * Holder.CurrentColumn) + (Holder.GapX * Holder.CurrentColumn)) * PrefixX
		OffsetY = ((Holder.SlotSize * Holder.CurrentRow) + (Holder.GapY * Holder.CurrentRow)) * PrefixY
		
		-- If the current button should be in next row
		if Index % Holder.NumPerRow == 0 then
			Holder.CurrentRow = Holder.CurrentRow + 1
			Holder.CurrentColumn = 0
		else
			Holder.CurrentColumn = Holder.CurrentColumn + 1
		end
		
		E:MoveFrame(RepositioningSlot, OffsetX, OffsetY)

		Holder.RepositionedSlotNum = Holder.RepositionedSlotNum + 1
	end
	
	function Module:UpdateSlotPositions(Holder)
		--sort(Holder.AuraSlot, SortAuras)
		
		if not Holder.HasCenterPositioning then
			
			local Slot
			
			Holder.CurrentColumn = 0
			Holder.CurrentRow = 0
			Holder.RepositionedSlotNum = 1
			
			for i = 1, #Holder.AuraSlot do
				Slot = Holder.AuraSlot[i]
				if not Slot then return end
				
				self:RepositionSlot(Holder, i)
			end
		else
			self:UpdateCenterPositioning(Holder)
		end
	end

	local function PostToggle_Time(self, state)
		self.Owner:SetHideCountdownNumbers(not state)
	end
	
	local FontPath_Base = "db.profile.unitframe.units.%s.%s.%s"
	local function GetFontPath(Holder, ConfigKey, Type)
		return (FontPath_Base):format(ConfigKey or Holder.ConfigKey or Holder.Owner.ConfigKey, lower(Holder.Type), Type)
	end

	-- We use this method to create slots on the fly while updating auras
	function Module:CreateSlot(Holder, Index)
		local Slot = Holder.AuraSlot[Index]

		if not Slot then
			
			Slot = CreateFrame("Button", format("CUI_%sAuraIcon%s", Holder.Owner.unit, Index), Holder)
			
			Slot.Owner = Holder
			Slot:SetSize(Holder.SlotSize, Holder.SlotSize)
			self:CreateIcon(Slot, Holder.Type)
			
			Slot:SetAlpha(Holder.SlotAlpha or 1)
			Slot:EnableMouse(not Holder.ClickThrough)

			-- Allows us to automagically hide/show the countdown numbers based on whether or not the font should be shown
			Slot.Cooldown.Time.PostToggle = PostToggle_Time
			
			E:RegisterAutoFont(Slot.Cooldown.Time, GetFontPath(Holder, Holder.ConfigKey, 'time'))
			E:RegisterAutoFont(Slot.Count, GetFontPath(Holder, Holder.ConfigKey, 'count'))
			
			Holder.CurrentColumn = 0
			Holder.CurrentRow = 0
			Holder.RepositionedSlotNum = 1
			Holder.AuraSlot[Index] = Slot

			-- Reposition all
			Module:UpdateSlotPositions(Holder)
		end
		
		return Slot
	end

	function Module:ClearSlot(Slot)
		if not Slot then return end

		Slot.IsActive = false
		Slot:Hide()
	end
	
	function Module:PopulateSlot(Slot, AuraType, AuraUnitFaction, Texture, DType, ExpirationTime, UnitCaster, Duration, IsBossDebuff, IsCastByPlayer, AuraName, SpellID, AuraInstanceID)
		local Unit = Slot.Owner.Owner.unit

		Slot.IsActive = true
		
		Slot.Name 		= AuraName
		Slot.Duration 	= Duration
		Slot.Expiration = ExpirationTime
		Slot.SpellID 	= SpellID
		Slot.AuraInstanceID = AuraInstanceID
		if Unit == 'player' or Unit == 'target' then
			--Slot.Priority = FI:GetAuraPriority(CO.db.profile.auras.units[Unit].aurabars.filterType, SpellID)
			Slot.Priority = 99
		else
			Slot.Priority = 1
		end
		
		Slot.Count:Show()
		Slot.Count:SetText(GetAuraApplicationDisplayCount(Unit, AuraInstanceID, 2, 99))
		
		Slot.Tex:SetTexture(Texture)

		local Duration = GetAuraDuration(Unit, AuraInstanceID)
		if Duration then
			Slot.Cooldown:SetCooldownFromDurationObject(Duration, true)
		else			
			Slot.Cooldown:Clear()
		end

		--if CO.db.profile.unitframe.desaturateOtherDebuffs and AuraType == 'HARMFUL' and AuraUnitFaction == AuraType and UnitCaster ~= 'player' then
		if AuraType == 'HARMFUL' and AuraUnitFaction == AuraType and UnitCaster ~= 'player' then
			if not IsCastByPlayer then
				Slot.Tex:SetDesaturated(true)
			else
				Slot.Tex:SetDesaturated(false)
			end
		end
		
		E:ColorizeAuraButton(Slot, DType, Unit, AuraType, AuraName, SpellID, CO.db.profile.unitframe.aurasDefaultBorderColor, nil, AuraInstanceID, E.Curves.Auras)

		Slot:Show()
	end

----------------------------------
-- SLOT END
----------------------------------

----------------------------------
-- HOLDER
----------------------------------
	
	function Module:UpdateHolderSize(Holder, UpdateSlotNum)
		-- Fires whenever the icons are being updated
		-- Requires Slot Num per Row, GapX, GapY, SlotSize and Num of active Slots

		if UpdateSlotNum then
			Holder.ActiveSlots = 0
			for i=1, #Holder.AuraSlot do
				if Holder.AuraSlot[i].IsActive then
					Holder.ActiveSlots = Holder.ActiveSlots + 1
				end
			end
		end
		
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

	function Module:CreateHolder(Frame, Type)
		local Holder = Frame[Type]

		if not Holder then
			-- Profile unit holds the unit + index for raid40. Name is required, so the user can attach stuff to this holder
			Holder = CreateFrame("Frame", format("%s%sHolder", Frame.ConfigKey, Type), Frame.Overlay)
			Holder:SetFrameStrata("MEDIUM")
			Holder:SetSize(1, 1)
			Holder.Owner = Frame
			Holder.ConfigKey = Frame.ConfigKey
			Holder.Type = Type
			Holder.AuraType = (Type == "Debuffs") and E.STR.HARMFUL or E.STR.HELPFUL
			Holder.ActiveSlots = 0
			Holder.AuraCache = {}
			Holder.AuraSlot = {}
			Holder.SortedAuras = {}
			
			if not Frame.AuraHolders then Frame.AuraHolders = {} end
			tinsert(Frame.AuraHolders, Holder)

			Frame.Auras[Type] = Holder
		end
	end
	
	function Module:BuildAuras(Frame)
		if not Frame.Auras.Buffs then
			for _, Type in pairs(Module.HOLDER_TYPES) do
				Module:CreateHolder(Frame, Type)
			end
			
			self:RegisterHolder(Frame, Frame.unit)
			self:LoadConfig(Frame) -- Initial update
		end
	end


----------------------------------
-- HOLDER END
----------------------------------


function Module:IsUnitFromType(Unit, Compare)
	if not Compare then return false end
	
	return Compare:find(Unit)
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

function Module:RunFullUpdate(Holder)
	
end

function Module:ApplyAuraDataToSlot(Slot, AuraData)
	if not Slot or not AuraData then return false end
	
	--if (AuraData.isHarmful and true and UnitCanAttack(Slot.Owner.unit, "player")) or (AuraData.isHarmful and not UnitCanAttack(Slot.Owner.unit, "player")) or AuraData.isHelpful then
		self:PopulateSlot(Slot, Slot.Owner.Type, Slot.Owner.Owner.AuraUnitFaction, AuraData.icon, AuraData.dispelName, AuraData.expirationTime, AuraData.sourceUnit, AuraData.duration, AuraData.isBossAura, AuraData.isFromPlayerOrPlayerPet, AuraData.name, AuraData.spellId, AuraData.auraInstanceID)
	--end

	self:UpdateHolderSize(Slot.Owner, true)

	return true
end

function Module:ForceUpdate()
	self.isHostileUnit = UnitCanAttack("player", self.Owner.unit)
	AuraCache_OnEvent(self, nil, nil, ForceUpdateInfo)
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
	F.Auras = CreateFrame('Frame')
	F.Auras.Frame = F
	F.Auras.unit = F.unit
	F.Auras.Owner = F
	F.Auras.Enable = self.Enable
	F.Auras.Disable = self.Disable
	F.Auras.ForceUpdate = self.ForceUpdate
	F.Auras.UpdateUnit = UpdateUnit

	self:BuildAuras(F)
	
	tinsert(Module.Frames, F)
end

---------- Add Module
UF:RegisterModule("Auras", Module)