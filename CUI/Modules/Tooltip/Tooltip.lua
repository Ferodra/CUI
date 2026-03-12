local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, TT, ItemDB = E:LoadModules("Config", "Tooltip", "ItemDB")

TT.Hook = LibStub("AceHook-3.0")

--[[-------------------------------------------------------------------------

	We are caching globals, since making those functions local,
	results in a slight performance boost and therefore
	in less CPU time. Exactly what we are aiming for.

-------------------------------------------------------------------------]]--
local _
local _G							= _G
local select						= select
local format						= string.format
local match							= string.match
local GameTooltip_SetDefaultAnchor 	= GameTooltip_SetDefaultAnchor
local GetCreatureDifficultyColor 	= GetCreatureDifficultyColor
local UnitFactionGroup 				= UnitFactionGroup
local UnitName 						= UnitName
local UnitAura						= C_TooltipInfo.GetUnitAura
local GetAuraDataByIndex 			= C_UnitAuras and C_UnitAuras.GetAuraDataByIndex
local UnpackAuraData 				= AuraUtil and AuraUtil.UnpackAuraData
local UnitLevel 					= UnitLevel
local UnitClass 					= UnitClass
local UnitRace 						= UnitRace
local GetGuildInfo 					= GetGuildInfo
local UnitHealth 					= UnitHealth
local UnitHealthMax 					= UnitHealthMax
local UnitIsDeadOrGhost				= UnitIsDeadOrGhost
local SOURCE						= SOURCE
local C_CurrencyInfo_GetCurrencyInfo		= C_CurrencyInfo.GetCurrencyInfo or GetCurrencyInfo
local C_CurrencyInfo_GetCurrencyListInfo	= C_CurrencyInfo.GetCurrencyListInfo or GetCurrencyListInfo
local C_CurrencyInfo_ExpandCurrencyList		= C_CurrencyInfo.ExpandCurrencyList or ExpandCurrencyList
local C_CurrencyInfo_GetCurrencyListLink	= C_CurrencyInfo.GetCurrencyListLink or GetCurrencyListLink
local C_AddOns_IsAddOnLoaded				= C_AddOns.IsAddOnLoaded
local GetDisplayedItem				 = TooltipUtil and TooltipUtil.GetDisplayedItem
-----------------------------------------------------------------------------

TT.TooltipMover = nil
TT.FactionColors = {
	ALLIANCE 	= {100, 149, 237},
	HORDE 		= {178, 34, 34}
}
TT.HexFactionColors = {
	ALLIANCE 	= E:RgbToHex(TT.FactionColors.ALLIANCE),
	HORDE 		= E:RgbToHex(TT.FactionColors.HORDE)
}

TT.BackdropTemplate = {
	  bgFile = "Interface\\AddOns\\CUI\\Textures\\borders\\WHITE8X8", 
	  edgeFile = "Interface\\AddOns\\CUI\\Textures\\borders\\WHITE8X8",
	  tile = true,
	  tileSize = 16,
	  edgeSize = 1, 
	  insets = { left = 0, right = 0, top = 0, bottom = 0 }
}

local AUCTION_CATEGORY_GEMS	= AUCTION_CATEGORY_GEMS -- Basically the most accurate thing we could go for
local GEM		= AUCTION_CATEGORY_GEMS:sub(1, -3)
local ITEMLEVEL_STR	= ITEM_LEVEL:sub(1, -3)

function TT:IsOwnedByActionBar(Tooltip)
	local Owner = Tooltip:GetOwner()
	
	if Owner and Owner:GetName() then
		return Owner:GetName():find("ActionBar")
	end
end

-- This is an easy approach to style tooltips. Just query the style table,
-- change values according to the tooltip shown and push the update via
-- TT:UpdateStyle(modPosition, styleData)
function TT:GetStyleData(type)
	-- Fallback
	if not self.TooltipStyles[type] then type = "Default"; E:debugprint("Tooltip-Style fallback to Default. Queried style not found!") end
	
	for k, v in pairs(self.TooltipStyles[type]) do
		self.CurrentTooltipStyle[type][k] = v
	end
	
	self.CurrentTooltipStyle[type].Type = type
	
	return self.CurrentTooltipStyle[type]
end

function TT:FindTextInLine(Tooltip, Text, Offset)
	local TooltipName = Tooltip:GetName()
	local Line
	
	for i=(Offset or 1), Tooltip:NumLines() do
		Line = _G[TooltipName .. "TextLeft"..i]
		if(Line and Line:GetText() and Line:GetText():find(Text)) then
			return Line
		end
	end
end

function TT:GetLevelLine(tooltip, offset)
	return self:FindTextInLine(tooltip, LEVEL, offset)
end

function TT:HasIDText(tooltip)
	return self:FindTextInLine(tooltip, ID .. ":")
end

-- self = GameTooltip
-- This happens through the hook
function TT:UpdateAuraTooltip(Unit, Index, Filter)
	if not TT.Enabled then return end
	-- When there is no owner name, the tooltip is most likely supposed to be positioned at a fixed position. We shouldn't mess with that.
		--if not self or not self:GetOwner():GetName() then return end
	
	-- Failsafes
	if Unit and Index and Filter then
		local AuraName, AuraTexture, AuraCount, AuraDType, AuraDuration, AuraExpirationTime, AuraSource, AuraStealable, _, SpellID = UnpackAuraData(GetAuraDataByIndex(Unit, Index, Filter))
		
		if AuraSource and AuraSource ~= "" and SpellID and SpellID ~= "" then
			self:AddLine(" ")
			self:AddDoubleLine(format("%s: %s" , SOURCE, E:GetColorizedUnitName(AuraSource)), format("ID: %s", SpellID))
		elseif AuraSource and AuraSource ~= "" then
			self:AddLine(" ")
			self:AddLine(format("%s: %s" , SOURCE, E:GetColorizedUnitName(self.AuraSource)))
		elseif SpellID and SpellID ~= "" then
			self:AddLine(" ")
			self:AddLine(format("%s: %d" , ID,  SpellID))
		end
		
		self:Show() -- Fix for height issues due to new line (This seems to just happen on auras somehow)
	end
	
	if Unit then
		self.CurrentStyle = TT:GetStyleData("Aura")
		
		self.CurrentColor = E:GetUnitReactionColor(Unit)
		if self.CurrentColor then
			self.CurrentStyle.BorderR = self.CurrentColor.r
			self.CurrentStyle.BorderG = self.CurrentColor.g
			self.CurrentStyle.BorderB = self.CurrentColor.b
		end
	end
	
	TT:UpdateStyle(self, nil, self.CurrentStyle)
end

function TT:UpdatePetTooltip(Unit, Index, Filter)
	if not TT.Enabled then return end
	
	self.CurrentStyle = TT:GetStyleData("Spell")
	self.CurrentStyle.BorderR = 0.7
	self.CurrentStyle.BorderG = 0.7
	self.CurrentStyle.BorderB = 0.7
	self.CurrentStyle.BorderA = 0.35
	
	TT:UpdateStyle(self, true, self.CurrentStyle)
end

function TT:UpdateSpellTooltip(Tooltip, ReturnOnly)
	if not TT.Enabled or Tooltip:IsForbidden() then return end
	
	local Owner = Tooltip:GetOwner()
	
	self.CurrentStyle = TT:GetStyleData("Spell")
	self.CurrentStyle.BorderR = 0.7
	self.CurrentStyle.BorderG = 0.7
	self.CurrentStyle.BorderB = 0.7
	self.CurrentStyle.BorderA = 0.35
	
	if Owner then
		--print(Owner, Owner:GetName())
	end
	
	if not ReturnOnly then
		self:UpdateStyle(Tooltip, true, self.CurrentStyle)
	else
		return self.CurrentStyle
	end

	_, self.CurrentSpellID = Tooltip:GetSpell()
	if not self.CurrentSpellID then
		return
	else
		if not self:HasIDText(Tooltip) then
			Tooltip:AddLine(format("%s: %s\n" , ID, self.CurrentSpellID))
		end
	end
	
	Tooltip:Show()
end

function TT:UpdateUnitTooltip(object, ReturnOnly)
	if object:IsForbidden() or not TT.Enabled or object ~= GameTooltip then return end
	
	_, self.unit = object:GetUnit()
	if not self.unit then return end
	
	if not ReturnOnly then
		self.targetUnit = self.unit .. "target"
		self.CurrentName, self.realm = UnitName(self.unit)
		
		self.TooltipUnitReactionColor  = E:GetUnitReactionColor(self.unit, false)
		self.TooltipUnitReactionHex = E:RgbToHex(self.TooltipUnitReactionColor, true)
		if not self.realm then self.realm = "" end
		if UnitIsUnit(self.unit, "player") then
			-- if UnitIsPlayer(self.unit) then self.realm = select(2, UnitFullName(self.unit)) or "" end
		end
		
		if self.realm and self.realm ~= "" then self.realm = format(" - %s", self.realm) end
		
		if not self.db then return end
		
		-- Prevent random Lua-errors
		if self.CurrentName and self.realm then
			GameTooltipTextLeft1:SetFormattedText("|c%s%s%s|r", self.TooltipUnitReactionHex, self.CurrentName, self.realm)
		end
		
		-- Colorize Race and Class
		if UnitIsPlayer(self.unit) then
			
			self.localeClass, self.class = UnitClass(self.unit)
			self.guildName, self.guildRankName, _, self.guildRealm = GetGuildInfo(self.unit)
			self.race, self.englishRace = UnitRace(self.unit)
			self.level = UnitLevel(self.unit)
			_, self.factionGroup = UnitFactionGroup(self.unit)
			
			self.classColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[self.class] or RAID_CLASS_COLORS[self.class]
			
			self.lineOffset = 2
			if self.guildName then
				self.guildLine = GameTooltipTextLeft2
				
				if self.guildRealm then
					self.guildLine:SetFormattedText("|c%s<%s - %s>|r [%s]", TT.HexFactionColors.ALLIANCE, self.guildName, self.guildRealm, self.guildRankName)
				else
					self.guildLine:SetFormattedText("|c%s<%s>|r [%s]", TT.HexFactionColors.ALLIANCE, self.guildName, self.guildRankName)
				end
				
				self.lineOffset = 3
			end
			
			
			self.levelLine = self:GetLevelLine(object, self.lineOffset)
			if(self.levelLine) then
				self.diffColor = GetCreatureDifficultyColor(UnitLevel(self.unit))
				if(self.factionGroup and englishRace == "Pandaren") then
					self.race = self.factionGroup.." "..self.race
				end
				self.levelLine:SetFormattedText("%s |cff%02x%02x%02x%s|r - |c%s%s, %s|r (%s)", LEVEL, self.diffColor.r * 255, self.diffColor.g * 255, self.diffColor.b * 255, self.level > 0 and self.level or "??", self.classColor.colorStr, self.race or '', self.localeClass, PLAYER)
				
				-- Color faction
				local prevLine = _G["GameTooltipTextLeft" .. self.lineOffset + 1]
				self.factionLine = _G["GameTooltipTextLeft" .. self.lineOffset + 2]
				
				-- Add faction
				if prevLine and type(prevLine) == "string" then
					if self.factionLine and (prevLine and prevLine.GetText and not (prevLine:GetText() and string.find(prevLine:GetText(), FACTION_ALLIANCE) or string.find(prevLine:GetText(), FACTION_HORDE))) then
						if self.factionLine:GetText() == FACTION_ALLIANCE or self.factionLine:GetText() == FACTION_HORDE then
							if self.factionGroup == FACTION_HORDE then
								self.factionColor = self.HexFactionColors.HORDE
								self.factionLine:SetFormattedText("|c%s%s|r", self.factionColor, FACTION_HORDE)
							elseif self.factionGroup == FACTION_ALLIANCE then
								self.factionColor = self.HexFactionColors.ALLIANCE
								self.factionLine:SetFormattedText("|c%s%s|r", self.factionColor, FACTION_ALLIANCE)
							end
						else
							if self.factionGroup == FACTION_HORDE then
								self.factionColor = self.HexFactionColors.HORDE
								object:AddLine(string.format("|c%s%s|r", self.factionColor, FACTION_HORDE))
							elseif self.factionGroup == FACTION_ALLIANCE then
								self.factionColor = self.HexFactionColors.ALLIANCE
								object:AddLine(string.format("|c%s%s|r", self.factionColor, FACTION_ALLIANCE))
							end
						end
					end
				end
			end
		end
		
		self:SetTooltipTarget(object)
	end
	
	self.classColor = E:GetUnitReactionColor(self.unit)
	
	self.CurrentStyle = self:GetStyleData("Unit")
	
	self.CurrentStyle.BorderR = self.classColor.r
	self.CurrentStyle.BorderG = self.classColor.g
	self.CurrentStyle.BorderB = self.classColor.b
	self.CurrentStyle.BorderA = 0.35
	self.CurrentStyle.BackgroundA = self.db.background.rgba[4]
	
	
	if not ReturnOnly then
		self:UpdateStyle(object, true, self.CurrentStyle)
	
		GameTooltipStatusBar:SetStatusBarTexture(E.Media:Fetch("statusbar", CO.db.profile.unitframe.units.all.barTexture))
		GameTooltipStatusBar.text:SetText(E:readableNumber(UnitHealth(self.unit), 2) .. " / " .. E:readableNumber(UnitHealthMax(self.unit), 2))
	else
		return self.CurrentStyle
	end
end

local NamesPerLine = 4
local function CheckUnitHasTargetedUnit(self, Tooltip, UnitType, i)
	local Unit = format("%s%s", UnitType, i)
	
	if UnitExists(format("%starget", Unit)) and UnitIsUnit(self.unit, format("%starget", Unit)) then
		if self.GroupTargetText == "" then
			self.GroupTargetText = E:GetColorizedUnitName(Unit)
		else
			if not self.GroupTargetTextNewLine then
				self.GroupTargetText = format("%s, %s", self.GroupTargetText, E:GetColorizedUnitName(Unit))
			else
				self.GroupTargetText = format("%s%s", self.GroupTargetText, E:GetColorizedUnitName(Unit))
			end
		end
		
		self.GroupTargetTextEntries = self.GroupTargetTextEntries + 1
		
		if self.GroupTargetTextEntries % NamesPerLine < 1 then
			self.GroupTargetText = self.GroupTargetText .. "\n"
			self.GroupTargetTextNewLine = true
		else
			self.GroupTargetTextNewLine = nil
		end
	end
end

-- Handles adding lines regarding a unit being targeted by someone in the players' party or raid
function TT:SetTooltipTarget(Tooltip)
	if not TT.Enabled then return end
	
	self.GroupTargetText = ""
	self.GroupTargetTextEntries = 0
	self.GroupTargetTextNewLine = true -- Control variable for new lines

	if UnitExists(self.unit .. "target") then
		Tooltip:AddLine(format("<%s: %s>", TARGET, E:GetColorizedUnitName(self.targetUnit)))
	end
	if not IsInRaid() then
		if IsInGroup() then
			for i=1,4 do
				CheckUnitHasTargetedUnit(self, Tooltip, "party", i)
			end
		end
	else
		for i=1,40 do
			CheckUnitHasTargetedUnit(self, Tooltip, "raid", i)
		end
	end
	
	if self.GroupTargetText ~= "" then
		Tooltip:AddLine(format("<%s %s> %s", TARGET, L["of"], self.GroupTargetText))
	end
end

local ItemCountSourcesBaseStr = "%s%s: %s, "
local Enum_ItemCountSources = {
	['bags'] = BACKPACK_TOOLTIP,
	['bank'] = BANK,
	--['void'] = VOID_STORAGE,
	['equipped'] = L["Equipped"],
	['warbank']	= ACCOUNT_BANK_PANEL_TITLE,
	['reagentbank']	= REAGENT_BANK,
}

--for k,n in pairs(_G) do if n=="Ausgerüstet" then print(k) end end

function TT:AddItemCounts(Tooltip, ItemID)
	if not self.db.showItemCounts then return end
	if (ArkInventory and ArkInventory.db.option.tooltip.itemcount.enable) or (Bagnon and Bagnon.sets.tipCount) then return end
	
	local Data = ItemDB:GetItemInfo(ItemID)
	if not Data or Data.Total < 1 then return end
	
	local CountText, CountBase, FormattedName, Color, CountTypes = nil, nil, nil, nil, {}
	
	for name, charData in pairs(Data.Chars) do
		CountText, CountBase, FormattedName = "", "", ""
		wipe(CountTypes)
		--E:print_r(charData)
		for type, name in pairs(Enum_ItemCountSources) do
			if type ~= 'warbank' and charData[type] > 0 then
				CountBase = format(ItemCountSourcesBaseStr, CountBase, name, '%s')
				tinsert(CountTypes, charData[type])
			end
		end
		
		CountBase = CountBase:sub(1, -3)
		CountText = (CountBase):format(unpack(CountTypes))
		
		Color = RAID_CLASS_COLORS[charData.Class or "PRIEST"]
		Tooltip:AddDoubleLine(name, CountText, Color.r, Color.g, Color.b, Color.r, Color.g, Color.b)
	end
	
	if Data.WARBANK > 0 then
		Tooltip:AddLine(Enum_ItemCountSources.warbank .. ": " .. Data.WARBANK)
	end
	
	Tooltip:AddLine(HONOR_LIFETIME .. ": " .. Data.Total)
end

function TT:UpdateCurrencyTooltip(index)
	local link = C_CurrencyInfo_GetCurrencyListLink(index)
	if not link then return end
	local id = tonumber(match(link,"currency:(%d+)"))	
	
	--if not self.db.showItemCounts then return end
	--if (ArkInventory and ArkInventory.db.option.tooltip.itemcount.enable) or (Bagnon and Bagnon.sets.tipCount) then return end
	
	local Data = ItemDB:GetCurrencyInfo(id, 'amount')
	if not Data or Data.Total < 1 then return end
	
	local Color = {}
	
	self:AddLine("\n")
	self:AddLine(ID .. ": " .. id)
	
	for i=1, #Data.Chars do
		if Data.Chars[i].amount > 0 then
			Color = RAID_CLASS_COLORS[Data.Chars[i].class or "PRIEST"]
			self:AddDoubleLine(Data.Chars[i].name, BreakUpLargeNumbers(Data.Chars[i].amount), Color.r, Color.g, Color.b, Color.r, Color.g, Color.b)
		end
	end
	
	self:AddLine(HONOR_LIFETIME .. ": " .. BreakUpLargeNumbers(Data.Total))
	self:Show()
end

function TT:UpdateItemTooltip(Tooltip, ReturnOnly)
	if not TT.Enabled then return end
	
	self.CurrentName, self.CurrentLink = GetDisplayedItem(Tooltip)
	if not self.CurrentLink then return end
	
	local ItemID = GetItemInfoInstant(self.CurrentLink)
	if ItemID then
		if not self:HasIDText(Tooltip) then
			Tooltip:AddLine(format("%s: %s\n" , ID, ItemID))
			
			self:AddItemCounts(Tooltip, ItemID)
		end
		
		local _, _, rarity, ilvl, _, itemType,_,_, itemEquipLoc,_,_,_,_, bindType = GetItemInfo(ItemID)
		
		if itemType:find(GEM) then
			local IlvlLine = GameTooltipTextLeft2:GetText()
			if IlvlLine and not IlvlLine:find(ITEMLEVEL_STR) then
				GameTooltipTextLeft2:SetFormattedText("%s\n%s: %s", IlvlLine, ITEMLEVEL_STR:sub(1,-2), ilvl)
			end
		end
		
		Tooltip:Show()
	end
	
	self.CurrentStyle = self:GetStyleData("Item")
	
	self.CurrentColor = ITEM_QUALITY_COLORS[E:GetItemLinkInfo(self.CurrentLink).itemRarity] or ITEM_QUALITY_COLORS[1]
	
	-- PawnCommon.ColorTooltipBorder
	
	if self.CurrentLink and (C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(self.CurrentLink) or C_AzeriteItem.IsAzeriteItemByID(self.CurrentLink)) then		
		self.CurrentStyle.BackgroundR = nil
		self.CurrentStyle.BackgroundG = nil
		self.CurrentStyle.BackgroundB = nil
		self.CurrentStyle.BackgroundA = nil
		
		self.CurrentStyle.BorderR = 1
		self.CurrentStyle.BorderG = 0.85
		self.CurrentStyle.BorderB = 0
		self.CurrentStyle.BorderA = 1
	else
	
		self.CurrentStyle.BackgroundA = self.db.background.rgba[4]
		
		-- Fix for Pawn
		if not PawnCommon or (PawnCommon and not PawnCommon.ColorTooltipBorder) then
			self.CurrentStyle.BorderR = self.CurrentColor.r
			self.CurrentStyle.BorderG = self.CurrentColor.g
			self.CurrentStyle.BorderB = self.CurrentColor.b
		else
			self.CurrentStyle.OverrideBorder = false
		end
	end
	
	if not ReturnOnly then
		self:UpdateStyle(Tooltip, false, self.CurrentStyle)
	else
		return self.CurrentStyle
	end
end

-- I have no idea what fires this
function TT:UpdateQuestTooltip(tooltip)
	if not TT.Enabled then return end
	
	self:UpdateStyle(tooltip, nil, self:GetStyleData("Quest"))
end

function TT:UpdateFonts()
	if self.Enabled then		
		GameTooltipHeaderText:SetFont(E.Media:Fetch("font", self.db.header["fontType"]), self.db.header["fontSize"], self.db.header["fontFlags"])
		GameTooltipText:SetFont(E.Media:Fetch("font", self.db.body["fontType"]), self.db.body["fontSize"], self.db.body["fontFlags"])
		GameTooltipStatusBar.text:SetFont(E.Media:Fetch("font", self.db.statusbar["fontType"]), self.db.statusbar["fontSize"], self.db.statusbar["fontFlags"])
	else
		GameTooltipHeaderText:SetFont(unpack(GameTooltipHeaderText.Font))
		GameTooltipText:SetFont(unpack(GameTooltipText.Font))
		GameTooltipStatusBar.text:SetFont(unpack(GameTooltipStatusBar.text.Font))
	end
end

local function UpdateBackdrop(NineSlice, elapsed)
	if not TT.Enabled then return end
	--TT.BackdropElapsed = (TT.BackdropElapsed or 0) + elapsed
	
	--if TT.BackdropElapsed > 0 then
		if not NineSlice or NineSlice:IsForbidden() or not TT.db.background then return end

		if not NineSlice.SetBackdrop then
			_G.Mixin(NineSlice, _G.BackdropTemplateMixin)
			NineSlice:HookScript('OnSizeChanged', NineSlice.OnBackdropSizeChanged)
		end
		
		--TT.BackdropElapsed = 0
	--end
end

function TT:GetUpdatedStyle(Tooltip)
	if not Tooltip then return end
	
	if Tooltip:GetSpell() then
		return self:UpdateSpellTooltip(Tooltip, true)
	elseif Tooltip:GetItem() then
		return self:UpdateItemTooltip(Tooltip, true)
	elseif Tooltip:GetUnit() then
		return self:UpdateUnitTooltip(Tooltip, true)
	end
end

-- Style update based on the provided style table
-- Note: This can be used by plugins to easily change the tooltips style!
function TT:UpdateStyle(tooltip, modPosition, styleData, applyStyle)
	if not tooltip or not TT.Enabled or tooltip:IsForbidden() or tooltip.IsEmbedded or not tooltip.NineSlice then return end
	
	-- Fix for Bug#002: Check if object has the GetOwner method, since autocomplete frames also are handled by CUI and are not the same as tooltips
	if modPosition and tooltip.GetOwner then
		local AnchorType = tooltip:GetAnchorType()
		
		if not (AnchorType ~= "ANCHOR_NONE" or tooltip == NamePlateTooltip) then
			
			-- Whether the tooltip position should be modified
			if not E:TableContainsValue(TT.StyleOnlyTooltips, tooltip) or tooltip == GameTooltip then
				if (AnchorType ~= "ANCHOR_CURSOR") then
					tooltip:ClearAllPoints()
					tooltip:SetPoint("BOTTOMRIGHT", TT.TooltipMover, "BOTTOMRIGHT", 0, TT.StatusBarIsShown and 10 or 0)
				end
			end
		end
	end
	
	-- Stop if there's no style and the tooltip shows an spell/item/unit to prevent unecessary border overrides (also looks weird)
	if not styleData and (tooltip.GetSpell) and (tooltip:GetSpell() or tooltip:GetItem() or tooltip:GetUnit()) then
			styleData = TT:GetUpdatedStyle(tooltip)
				
			if not styleData then return end
		end
	if applyStyle ~= false then
		-- Fallback
		styleData = styleData or self:GetStyleData("Default")
		
		-- Get missing data
		if styleData.OverrideBorder and (not styleData.BorderR or not styleData.BorderG or not styleData.BorderB) then
			styleData.BorderR, styleData.BorderG, styleData.BorderB = 1, 1, 1
		end
		
		if tooltip.Delimiter1 then tooltip.Delimiter1:SetTexture() end
		if tooltip.Delimiter2 then tooltip.Delimiter2:SetTexture() end
		
		-- For now, we let the user control a global RGBA for the background
		UpdateBackdrop(tooltip.NineSlice)
		
		-- Set border size
		self.BackdropTemplate.edgeSize = styleData.BorderSize
		
		tooltip.NineSlice:SetBackdrop({
		  bgFile = TT.BackdropTemplate.bgFile, 
		  edgeFile = TT.BackdropTemplate.edgeFile,
		  edgeSize = styleData.BorderSize,
		})
		
		local r,g,b,a = unpack(TT.db.background.rgba)
		tooltip.NineSlice:SetBackdropColor(r,g,b,a, true)
		
		if styleData.OverrideBorder then
			if tooltip.NineSlice then
				tooltip.NineSlice:SetBorderColor(styleData.BorderR, styleData.BorderG, styleData.BorderB)
			else
				tooltip:SetBorderColor(styleData.BorderR, styleData.BorderG, styleData.BorderB, styleData.BorderA)
			end
		end
	end
end

function TT:OverrideStyle()
	if not self or not TT.Enabled then return end
	
	TT:UpdateStyle(self, false)
end

function TT:UpdateTooltip(Parent)
	if not self or not TT.Enabled then return end
	
	TT:UpdateStyle(self, true)
end

function TT:UpdateStatusBar(value)
	if self:IsForbidden() or not value or not TT.Enabled or InCombatLockdown() then return end

	local _, unit = self:GetParent():GetUnit()
	if not unit then
		local frame = E:GetMouseFocus()
		if frame and frame.GetAttribute then
			unit = frame:GetAttribute('unit')
		end
	end
	
	if unit and UnitIsDeadOrGhost(unit) then
		self.text:SetText(_G.DEAD)
		-- Fix for bar flicker on dead units
		self:SetValue(0)
	else
		local MAX, _
		if unit then -- try to get the real health values if possible
			value, MAX = UnitHealth(unit), UnitHealthMax(unit)
		else
			_, MAX = self:GetMinMaxValues()
		end

		-- return what we got
		--if value > 0 and MAX == 1 then
			--self.text:SetFormattedText('%d%%', floor(value * 100))
		--else
			self.text:SetText(format("%s / %s", E:readableNumber(value, 2), E:readableNumber(MAX, 2)))
		--end
	end
end

function TT:SetupAnchor()
	self.TooltipMover = E:NewFrame("Frame", "TooltipAnchor", "MEDIUM", 100, 50, _, E.Parent)
	
	GameTooltip_SetDefaultAnchor(GameTooltip, self.TooltipMover)
	E:CreateMover(self.TooltipMover, L["tooltipAnchor"], nil, nil, nil, nil, "misc")
end

function TT:UpdateStyleOnly()
	TT:UpdateStyle(self, false)
end

function TT:UpdatePositionOnly()
	TT:UpdateStyle(self, true, nil, false)
end

local function SetByItemID(Tooltip, id)
	if Tooltip:IsForbidden() or not TT.Enabled then return end
	
	if Tooltip.AddLine then
		Tooltip:AddLine(format("%s: %s\n" , ID, id))
		Tooltip:Show()
	end
end
local function OnTooltipSetItem(Tooltip)
	TT:UpdateItemTooltip(Tooltip)
end
local function OnTooltipSetUnit(Tooltip)
	TT:UpdateUnitTooltip(Tooltip)
end
local function OnTooltipSetQuest(Tooltip)
	TT:UpdateQuestTooltip(Tooltip)
end
local function OnTooltipSetSpell(Tooltip)
	TT:UpdateSpellTooltip(Tooltip)
end

function TT:SetupHandlers()

	-- Replace 'Enum.TooltipDataType.Item' with an appropriate type for the tooltip
	-- data you are wanting to process; eg. use 'Enum.TooltipDataType.Spell' for
	-- replacing usage of OnTooltipSetSpell.
	--
	-- If you wish to respond to all tooltip data updates, you can instead replace
	-- the enum with 'TooltipDataProcessor.AllTypes' (or the string "ALL").

	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnTooltipSetItem)
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, OnTooltipSetUnit)
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Quest, OnTooltipSetQuest)
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, OnTooltipSetSpell)
	
	hooksecurefunc(GameTooltip, "SetUnitAura", self.UpdateAuraTooltip)
	hooksecurefunc(GameTooltip, "SetUnitBuff", self.UpdateAuraTooltip)
	hooksecurefunc(GameTooltip, "SetUnitDebuff", self.UpdateAuraTooltip)
	hooksecurefunc(GameTooltip, "SetPetAction", self.UpdatePetTooltip)
	hooksecurefunc(GameTooltip, "SetCurrencyToken", self.UpdateCurrencyTooltip)
	hooksecurefunc(GameTooltip, "SetToyByItemID", SetByItemID)
	
	hooksecurefunc("EmbeddedItemTooltip_SetItemByID", SetByItemID)
	
	hooksecurefunc("SharedTooltip_SetBackdropStyle", self.UpdateStyleOnly)
	hooksecurefunc("GameTooltip_SetDefaultAnchor", self.UpdatePositionOnly)
	GameTooltip:HookScript("OnShow", self.UpdateStyleOnly)	
	
	hooksecurefunc("UnitPowerBarAlt_OnEnter", self.UpdateTooltip)

	for _, Tooltip in pairs(self.StyleOnlyTooltips) do
		if Tooltip then
			self.Hook:SecureHookScript(Tooltip, "OnShow", self.UpdateStyleOnly)
			self:UpdateStyleOnly(Tooltip)
		end
	end
	
	-- Initial update, because otherwise the first show-up wouldn't be styled
	self:UpdateStyleOnly(GameTooltip)
	
	-- Despite all hooks and events, World objects that show tooltips simply aren't always affected by the styling and revert back to a default backdrop somehow
	-- This has an extremely low cpu usage, so we basically can neglect it in that regards
	--TT.Hook:SecureHookScript(GameTooltip, "OnUpdate", UpdateBackdrop)
	
	self.Hook:SecureHookScript(GameTooltipStatusBar, 'OnValueChanged', TT.UpdateStatusBar)
	GameTooltipStatusBar:SetScript("OnShow",function(self)
		-- Fix for random bug
		if GameTooltip and GameTooltip:GetUnit() then
			TT.StatusBarIsShown = true
			TT:UpdateStyle(GameTooltip, true, nil, false)
			
			if TT.Enabled then
				self.text:Show()
			else
				self.text:Hide()
			end
		else
			self:Hide()
		end
	end)
	GameTooltipStatusBar:SetScript("OnHide",function(self)
		TT.StatusBarIsShown = nil
		TT:UpdateStyle(GameTooltip, true, nil, false)
	end)
end

function TT:Enable()
	if not self.Initalized then				
		self:UpdateFonts()
		
		if C_AddOns_IsAddOnLoaded("Pawn") and PawnCommon and PawnCommon.ColorTooltipBorder then
			E:print("Pawn detected. Its option to colorize tooltip borders is enabled. CUI colorization disabled.")
		end
		
		self.Initalized = true
	end
	
	self.Enabled = true
	self.TooltipMover.ForceMoverEnabled = nil
end

function TT:Disable()
	self.Enabled = nil
	self.TooltipMover.ForceMoverEnabled = false
	
	GameTooltipStatusBar:SetStatusBarTexture(GameTooltipStatusBar.BarTexture)
end

function TT:LoadConfig()
	if self.db.enable then
		self:Enable()
	else
		self:Disable()
	end
	
	self:UpdateFonts()
end
function TT:UpdateDB()
	self.db = CO.db.profile.tooltip
end
function TT:Init()
	self:UpdateDB()
	
	GameTooltipStatusBar.text = GameTooltipStatusBar:CreateFontString(nil, "OVERLAY")
	E:InitializeFontFrame(GameTooltipStatusBar.text, "OVERLAY", "FRIZQT__.TTF", 12, {1,1,1}, 1, {0,0}, "10101", 200, 100, GameTooltipStatusBar, "CENTER", {0,0})
	
	if not GameTooltip.NineSlice.SetBackdrop then
		_G.Mixin(GameTooltip.NineSlice, _G.BackdropTemplateMixin)
		GameTooltip.NineSlice:SetBackdrop(self.BackdropTemplate)
	end
	
	-- remove default tip backdrop
	if (GameTooltip.NineSlice) then		
		GameTooltip.NineSlice.layoutType = nil;
		GameTooltip.NineSlice.layoutTextureKit = nil;
		GameTooltip.NineSlice.backdropInfo = nil;
	end
	
	GameTooltip.layoutType = nil;
	GameTooltip.layoutTextureKit = nil;
	GameTooltip.backdropInfo = nil;
	
	-- Cache default font sizes
	GameTooltipHeaderText.Font = {GameTooltipHeaderText:GetFont()}
	GameTooltipText.Font = {GameTooltipText:GetFont()}
	GameTooltipStatusBar.text.Font = {GameTooltipStatusBar.text:GetFont()}
	
	GameTooltipStatusBar.BarTexture = GameTooltipStatusBar:GetStatusBarTexture():GetTexture()
	
	E.Libs.LibSmooth:SmoothBar(GameTooltipStatusBar)
	
	self:SetupAnchor()
	self:SetupHandlers()
	
	self:LoadConfig()
end

E:AddModule("Tooltip", TT)