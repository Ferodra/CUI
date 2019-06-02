local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, L, TT = E:LoadModules("Config", "Locale", "Tooltip")

TT.Hook = LibStub("AceHook-3.0")

--[[-------------------------------------------------------------------------

	We are caching globals, since making those functions local,
	results in a slight performance boost and therefore
	in less CPU time. Exactly what we are aiming for.

-------------------------------------------------------------------------]]--
local _
local _G							= _G
local select						= select
local GameTooltip_SetDefaultAnchor 	= GameTooltip_SetDefaultAnchor
local GetCreatureDifficultyColor 	= GetCreatureDifficultyColor
local UnitFactionGroup 				= UnitFactionGroup
local UnitName 						= UnitName
local UnitAura 						= UnitAura
local UnitLevel 					= UnitLevel
local UnitClass 					= UnitClass
local UnitRace 						= UnitRace
local GetGuildInfo 					= GetGuildInfo
local UnitHealth 					= UnitHealth
local format						= string.format
local SOURCE						= SOURCE
-----------------------------------------------------------------------------

TT.CurrentTooltipAnchor = nil
TT.FactionColors = {
	ALLIANCE 	= {100, 149, 237},
	HORDE 		= {178, 34, 34}
}
TT.HexFactionColors = {
	ALLIANCE 	= E:RgbToHex(TT.FactionColors.ALLIANCE),
	HORDE 		= E:RgbToHex(TT.FactionColors.HORDE)
}

TT.BackdropTemplate = {
	  bgFile = "", 
	  edgeFile = [[Interface\Buttons\WHITE8X8]],
	  tile = true,
	  tileSize = 16,
	  edgeSize = 1, 
	  insets = { left = 0, right = 0, top = 0, bottom = 0 }
}

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

function TT:GetLevelLine(tooltip, offset)
	for i=offset, tooltip:NumLines() do
		self.levelLineTipText = _G["GameTooltipTextLeft"..i]
		if(self.levelLineTipText:GetText() and self.levelLineTipText:GetText():find(LEVEL)) then
			return self.levelLineTipText
		end
	end
end

function TT:HasIDText(tooltip)
	for i=1, tooltip:NumLines() do
		self.levelLineTipText = _G["GameTooltipTextLeft"..i]
		if(self.levelLineTipText:GetText() and self.levelLineTipText:GetText():find(ID .. ":")) then
			return self.levelLineTipText
		end
	end
end

-- self = GameTooltip
-- This happens through the hook
function TT:UpdateAuraTooltip(Unit, Index, Filter)
	-- When there is no owner name, the tooltip is most likely supposed to be positioned at a fixed position. We shouldn't mess with that.
		--if not self or not self:GetOwner():GetName() then return end
	
	-- Failsafes
	if Unit and Index and Filter then
		_, _, _, _, _, _, self.AuraSource, _, _, self.CurrentAuraID = UnitAura(Unit, Index, Filter)
		
		if self.AuraSource and self.AuraSource ~= "" and self.CurrentAuraID and self.CurrentAuraID ~= "" then
			self:AddLine(" ")
			self:AddDoubleLine(format("%s: %s" , SOURCE, E:GetColorizedUnitName(self.AuraSource)), format("ID: %s", self.CurrentAuraID))
		elseif self.AuraSource and self.AuraSource ~= "" then
			self:AddLine(" ")
			self:AddLine(format("%s: %s" , SOURCE, E:GetColorizedUnitName(self.AuraSource)))
		elseif self.CurrentAuraID and self.CurrentAuraID ~= "" then
			self:AddLine(" ")
			self:AddLine(format("%s: %d" , ID,  self.CurrentAuraID))
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
	
	TT:UpdateStyle(nil, self.CurrentStyle)
end

function TT:UpdatePetTooltip(Unit, Index, Filter)
	self.CurrentStyle = TT:GetStyleData("Spell")
	self.CurrentStyle.BorderR = 0.7
	self.CurrentStyle.BorderG = 0.7
	self.CurrentStyle.BorderB = 0.7
	self.CurrentStyle.BorderA = 0.35
	
	TT:UpdateStyle(true, self.CurrentStyle)
end

function TT:UpdateSpellTooltip()

	self.CurrentStyle = TT:GetStyleData("Spell")
	self.CurrentStyle.BorderR = 0.7
	self.CurrentStyle.BorderG = 0.7
	self.CurrentStyle.BorderB = 0.7
	self.CurrentStyle.BorderA = 0.35
	
	self:UpdateStyle(true, self.CurrentStyle)

	_, self.CurrentSpellID = GameTooltip:GetSpell()
	if not self.CurrentSpellID then
		return
	else
		if not self:HasIDText(GameTooltip) then
			GameTooltip:AddLine(format("%s: %s\n" , ID, self.CurrentSpellID))
		end
	end
end

function TT:UpdateUnitTooltip(object)
	if object:IsForbidden() then return end
	
	_, self.unit = GameTooltip:GetUnit()
	if not self.unit then return end
	
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
			self.factionLine = _G["GameTooltipTextLeft" .. self.lineOffset + 1]
			-- Add faction
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
					GameTooltip:AddLine(string.format("|c%s%s|r", self.factionColor, FACTION_HORDE))
				elseif self.factionGroup == FACTION_ALLIANCE then
					self.factionColor = self.HexFactionColors.ALLIANCE
					GameTooltip:AddLine(string.format("|c%s%s|r", self.factionColor, FACTION_ALLIANCE))
				end
			end
		end
	end
	
	self:SetTooltipTarget(self)
	
	self.classColor = E:GetUnitReactionColor(self.unit)
	
	self.CurrentStyle = self:GetStyleData("Unit")
	
	self.CurrentStyle.BorderR = self.classColor.r
	self.CurrentStyle.BorderG = self.classColor.g
	self.CurrentStyle.BorderB = self.classColor.b
	self.CurrentStyle.BorderA = 0.35
	self.CurrentStyle.BackgroundA = self.db.background["alpha"]
	
	self:UpdateStyle(false, self.CurrentStyle)
	
	GameTooltipStatusBar:SetStatusBarTexture(E.db.unitframe.units.all.barTexturePath)
	GameTooltipStatusBar.text:SetText(E:readableNumber(UnitHealth(self.unit), 2) .. " / " .. E:readableNumber(UnitHealthMax(self.unit), 2))
end

function TT:SetTooltipTarget(object)
	object.GroupTargetText = ""
	object.GroupTargetTextEntries = 0
	object.GroupTargetTextNewLine = true -- Control variable for new lines

	if UnitExists(object.unit .. "target") then
		GameTooltip:AddLine(format("<%s: %s>", TARGET, E:GetColorizedUnitName(object.targetUnit)))
	end
	if not IsInRaid() then
		if IsInGroup() then
			
			for i=1,4 do
				if UnitExists(format("party%starget", i)) and UnitIsUnit(object.unit, format("party%starget", i)) then
					if object.GroupTargetText == "" then
						object.GroupTargetText = E:GetColorizedUnitName(format("party%s", i))
					else
						if not object.GroupTargetTextNewLine then
							object.GroupTargetText = format("%s, %s", object.GroupTargetText, E:GetColorizedUnitName(format("party%s", i)))
						else
							object.GroupTargetText = format("%s%s", object.GroupTargetText, E:GetColorizedUnitName(format("party%s", i)))
						end
					end
					
					object.GroupTargetTextEntries = object.GroupTargetTextEntries + 1
					
					if object.GroupTargetTextEntries % 4 < 1 then
						object.GroupTargetText = object.GroupTargetText .. "\n"
						object.GroupTargetTextNewLine = true
					else
						object.GroupTargetTextNewLine = nil
					end
				end
			end
		end
	else
		for i=1,40 do
			if UnitExists(format("raid%starget", i)) and UnitIsUnit(object.unit, format("raid%starget", i)) then
				if object.GroupTargetText == "" then
					object.GroupTargetText = E:GetColorizedUnitName(format("raid%s", i))
				else
					--object.GroupTargetText = format("%s, %s", object.GroupTargetText, UnitName(format("raid%s", i)))
					if not object.GroupTargetTextNewLine then
						object.GroupTargetText = format("%s, %s", object.GroupTargetText, E:GetColorizedUnitName(format("raid%s", i)))
					else
						object.GroupTargetText = format("%s%s", object.GroupTargetText, E:GetColorizedUnitName(format("raid%s", i)))
					end
				end
				
				object.GroupTargetTextEntries = object.GroupTargetTextEntries + 1
				
				if object.GroupTargetTextEntries % 4 < 1 then
					object.GroupTargetText = object.GroupTargetText .. "\n"
					object.GroupTargetTextNewLine = true
				else
					object.GroupTargetTextNewLine = nil
				end
			end
		end
	end
	
	if object.GroupTargetText ~= "" then
		GameTooltip:AddLine(format("<%s %s> %s", TARGET, L["of"], object.GroupTargetText))
	end
end

function TT:UpdateItemTooltip()
	
	self.CurrentName, self.CurrentLink = GameTooltip:GetItem()
	if not self.CurrentName then return end
	
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
	
		self.CurrentStyle.BackgroundA = self.db.background["alpha"]
		
		-- Fix for Pawn
		if not PawnCommon or (PawnCommon and not PawnCommon.ColorTooltipBorder) then
			self.CurrentStyle.BorderR = self.CurrentColor.r
			self.CurrentStyle.BorderG = self.CurrentColor.g
			self.CurrentStyle.BorderB = self.CurrentColor.b
			self.CurrentStyle.BorderSize = 1
		else
			self.CurrentStyle.OverrideBorder = false
		end
	end
	
	self:UpdateStyle(true, self.CurrentStyle)
end

-- I have no idea what fires this
function TT:UpdateQuestTooltip()
	self:UpdateStyle(nil, self:GetStyleData("Quest"))
end

function TT:UpdateFonts()
	GameTooltipHeaderText:SetFont(E.Media:Fetch("font", self.db.header["fontType"]), self.db.header["fontSize"], self.db.header["fontFlags"])
	GameTooltipText:SetFont(E.Media:Fetch("font", self.db.body["fontType"]), self.db.body["fontSize"], self.db.body["fontFlags"])
	GameTooltipStatusBar.text:SetFont(E.Media:Fetch("font", self.db.statusbar["fontType"]), self.db.statusbar["fontSize"], self.db.statusbar["fontFlags"])
end

-- Style update based on the provided style table
-- Note: This can be used by plugins to easily change the tooltips style!
function TT:UpdateStyle(modPosition, styleData, applyStyle)
	-- Fallback
	if not styleData then styleData = self:GetStyleData("Default") end
		
	-- Wether the tooltip position should be modified
	-- Fix for Bug#002: Check if object has the GetOwner method, since autocomplete frames also are handled by CUI and are not the same as tooltips
	if TT.CurrentTooltip.GetAnchorType and (modPosition and TT.CurrentTooltip:GetAnchorType() ~= "ANCHOR_CURSOR") or (TT.CurrentTooltip.GetOwner and (TT.CurrentTooltip:GetOwner() == UIParent and TT.CurrentTooltip:GetAnchorType() == "ANCHOR_NONE")) then
		TT.CurrentTooltip:ClearAllPoints()
		
		if TT.StatusBarIsShown then
			TT.CurrentTooltip:SetPoint("BOTTOMRIGHT", self.CurrentTooltipAnchor, "BOTTOMRIGHT", 0, 10)
		else
			TT.CurrentTooltip:SetPoint("BOTTOMRIGHT", self.CurrentTooltipAnchor, "BOTTOMRIGHT", 0, 0)
		end
	end
	
	if applyStyle ~= false then
		-- Get missing data
		if styleData.OverrideBorder and (not styleData.BorderR or not styleData.BorderG or not styleData.BorderB) then
			styleData.BorderR, styleData.BorderG, styleData.BorderB = 1, 1, 1
		end
		if not styleData.BackdropR or not styleData.BackdropG or not styleData.BackdropB then
			styleData.BackdropR, styleData.BackdropG, styleData.BackdropB = TT.CurrentTooltip:GetBackdropColor()
		end
		
		-- Set border size
		self.BackdropTemplate.edgeSize = styleData.BorderSize
		
		TT.CurrentTooltip:SetBackdrop(self.BackdropTemplate)
		TT.CurrentTooltip:SetBackdropColor(styleData.BackdropR, styleData.BackdropG, styleData.BackdropB, styleData.BackdropA or self.db.background["alpha"] or 1)
		
		if styleData.OverrideBorder then
			TT.CurrentTooltip:SetBackdropBorderColor(styleData.BorderR, styleData.BorderG, styleData.BorderB, styleData.BorderA)
		end
	end
end

function TT:OverrideStyle()
	if not self then return end
	
	TT.CurrentTooltip = self
	TT:UpdateStyle(false)
end

function TT:UpdateTooltip(Parent)
	if not self then return end
	
	TT.CurrentTooltip = self
	
	-- ActionButton Tooltip
	if E.TooltipOwnedByActionButton == true then
		TT:UpdateStyle(true)
		
		return
	end
	
	-- If there is an owner
	if TT.CurrentTooltip.GetOwner and TT.CurrentTooltip:GetOwner() and TT.CurrentTooltip:GetOwner():GetName() then
		if TT.CurrentTooltip:GetOwner() == UIParent then
			if not string.find(TT.CurrentTooltip:GetName(), "ItemRef") then
				TT:UpdateStyle(true)
			else
				TT:UpdateStyle()
			end
			
			return
		elseif TT.CurrentTooltip:GetOwner() == PlayerPowerBarAlt then
			TT:UpdateStyle(true)
			
			return
		end
	else
		TT:UpdateStyle(false)
		
		return
	end
	
	-- Update if Tooltip is not an Item or Unit
	if (not (TT.CurrentTooltip == GameTooltip and TT.CurrentTooltip:GetItem()))
		and (not (TT.CurrentTooltip == GameTooltip and TT.CurrentTooltip:GetUnit())) then
		TT:UpdateStyle(false)
	end
end

function TT:UpdateStatusBar()
	_, self.Max = self:GetMinMaxValues()
	self.Current = self:GetValue()
	if self.Max then
		self.text:SetText(format("%s / %s", E:readableNumber(self.Current, 2), E:readableNumber(self.Max, 2)))
	end
end

function TT:SetupAnchor()
	
	self.CurrentTooltipAnchor = E:NewFrame("Frame", "TooltipAnchor", "MEDIUM", 100, 50, _, E.Parent)
	
	GameTooltip_SetDefaultAnchor(GameTooltip, self.CurrentTooltipAnchor)
	E:CreateMover(self.CurrentTooltipAnchor, L["tooltipAnchor"])
end

function TT:SetupHandlers()
	GameTooltip:HookScript("OnTooltipSetUnit", function(self) TT:UpdateUnitTooltip(self) end)
	GameTooltip:HookScript("OnTooltipSetItem", function(self) TT:UpdateItemTooltip(self) end)
	GameTooltip:HookScript("OnTooltipSetQuest", function(self) TT:UpdateQuestTooltip(self) end)
	GameTooltip:HookScript("OnTooltipSetSpell", function(self) TT:UpdateSpellTooltip(self) end)
	
	hooksecurefunc(GameTooltip, "SetUnitAura", TT.UpdateAuraTooltip)
	hooksecurefunc(GameTooltip, "SetUnitBuff", TT.UpdateAuraTooltip)
	hooksecurefunc(GameTooltip, "SetUnitDebuff", TT.UpdateAuraTooltip)
	hooksecurefunc(GameTooltip, "SetPetAction", TT.UpdatePetTooltip)
	
	hooksecurefunc(GameTooltip, "SetOwner", TT.UpdateTooltip)
	--hooksecurefunc("UnitPowerBarAlt_OnEnter", TT.UpdateTooltip)
	
	TT.Hook:SecureHook("GameTooltip_SetDefaultAnchor", TT.UpdateTooltip)
	TT.Hook:SecureHook("GameTooltip_UpdateStyle", TT.OverrideStyle)
	TT.Hook:SecureHookScript(GameTooltipStatusBar, 'OnValueChanged', TT.UpdateStatusBar)
	
	local Tooltips = {
		--GameTooltip,
		ItemRefTooltip,
		ItemRefShoppingTooltip1,
		ItemRefShoppingTooltip2,
		ItemRefShoppingTooltip3,
		AutoCompleteBox,
		FriendsTooltip,
		ShoppingTooltip1,
		ShoppingTooltip2,
		ShoppingTooltip3,
		WorldMapTooltip,
		WorldMapCompareTooltip1,
		WorldMapCompareTooltip2,
		WorldMapCompareTooltip3,
		ReputationParagonTooltip,
		StoryTooltip,
		EmbeddedItemTooltip,
		QuestScrollFrame.WarCampaignTooltip,
	}

	for _, Tooltip in pairs(Tooltips) do
		if Tooltip then
			TT.Hook:SecureHookScript(Tooltip, "OnShow", TT.UpdateTooltip)
		end
	end
	
	GameTooltipStatusBar:SetScript("OnShow",function(self)
		-- Fix for random bug
		if GameTooltip and GameTooltip:GetUnit() then
			TT.StatusBarIsShown = true
			TT:UpdateStyle(true, nil, false)
		else
			self:Hide()
		end
	end)
	GameTooltipStatusBar:SetScript("OnHide",function(self)
		TT.StatusBarIsShown = nil
		TT:UpdateStyle(true, nil, false)
	end)

	-- hooksecurefunc("SetCVar", print) -- To find out what CVars there are
end

function TT:LoadProfile()
	self:UpdateFonts()
end
function TT:UpdateDB()
	self.db = E.db.tooltip
end
function TT:Init()
	self:UpdateDB()
	
	GameTooltipStatusBar.text = GameTooltipStatusBar:CreateFontString(nil, "OVERLAY")
	E:InitializeFontFrame(GameTooltipStatusBar.text, "OVERLAY", "FRIZQT__.TTF", 12, {1,1,1}, 1, {0,0}, "10101", 200, 100, GameTooltipStatusBar, "CENTER", {0,0})
	
	self:SetupAnchor()
	self:SetupHandlers()
	
	--self.BackdropTemplate.bgFile = self.db.background["backgroundFile"]
	self.BackdropTemplate.bgFile = [[Interface\Buttons\WHITE8X8]]
	
	self:UpdateFonts()
	
	if IsAddOnLoaded("Pawn") and PawnCommon and PawnCommon.ColorTooltipBorder then
		E:print("Pawn detected. Its option to colorize tooltip borders is enabled. CUI colorization disabled.")
	end
end

E:AddModule("Tooltip", TT)