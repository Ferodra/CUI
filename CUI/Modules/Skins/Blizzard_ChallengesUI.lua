local E = unpack(select(2, ...)) -- Engine, Locale
local CO, Module = E:LoadModules("Config", "Blizzard_ChallengesUI")
Module.Autoload = true

local C_MythicPlus_GetWeeklyChestRewardLevel 	= C_MythicPlus.GetWeeklyChestRewardLevel
local C_CurrencyInfo_GetCurrencyInfo			= C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo or GetCurrencyInfo
local C_AddOns_IsAddOnLoaded					= C_AddOns.IsAddOnLoaded
local BreakUpLargeNumbers	= BreakUpLargeNumbers
local LEVEL					= LEVEL
local _

local CurrencyID = 1718 -- Titan Residuum
local CurrencyName, _, CurrencyTexture = C_CurrencyInfo_GetCurrencyInfo(CurrencyID)
local Residuum = {
	[2] = 80,
	[3] = 80,
	[4] = 170,
	[5] = 170,
	[6] = 170,
	[7] = 550,
	[8] = 550,
	[9] = 550,
	[10] = 1700,
	[11] = 1790,
	[12] = 1880,
	[13] = 1970,
	[14] = 2060,
	[15] = 2150,
	[16] = 2240,
	[17] = 2330,
	[18] = 2420,
	[19] = 2510,
	[20] = 2600,
	[21] = 2665,
	[22] = 2730,
	[23] = 2795,
	[24] = 2860,
	[25] = 2915
}
local EchoesPerLevel = 100
local EchoesID = 1803 -- Echoes of Ny'alotha
local EchoesName, _, EchoesTexture = C_CurrencyInfo_GetCurrencyInfo(EchoesID)

local StartIndex, EndIndex = 2, 25

local function GetCurrencyCurrentAmount()
	return select(2, C_CurrencyInfo_GetCurrencyInfo(CurrencyID))
end

local function GetEchoesCurrentAmount()
	return select(2, C_CurrencyInfo_GetCurrencyInfo(EchoesID)) 
end

local function GetEchoesRewardAmountForLevel(Level)
	return EchoesPerLevel * Level
end

local BaseFormat = "%s%s%s"
local function GetCurrencyRewardAmount(level)
	local Amount
	local Prefix, Suffix = "", ""
	
	if level < 1 then
		Amount = 0
	elseif level < StartIndex then
		Prefix = "<"
		Amount = Residuum[StartIndex]
	elseif level > EndIndex then
		Suffix = "+"
		Amount = Residuum[EndIndex]
	else
		Amount = Residuum[level]
	end
	
	
	return BaseFormat:format(Prefix, BreakUpLargeNumbers(Amount), Suffix)
end

-- Level, Reward
local function GetRewardLevel()
	return C_MythicPlus_GetWeeklyChestRewardLevel()
end

function Module:Update()
	local Level, Reward = GetRewardLevel()
	-- Level is 0 and Reward -1 without any M+ done this week
	
	self.ResiduumFrame.Amount:SetText(GetCurrencyRewardAmount(Level))
	self.EchoesFrame.Amount:SetText(BreakUpLargeNumbers(GetEchoesRewardAmountForLevel(Level)))
end

local function Currency_OnEnter(self)
	GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
	
	local Link = GetCurrencyLink(CurrencyID, GetCurrencyCurrentAmount())
	GameTooltip:SetHyperlink(Link)
	
	-- Grab all the lines and store then
	local Lines = {}
	for i=1,GameTooltip:NumLines() do
		Lines[i] = {}
		Lines[i][1] = _G["GameTooltipTextLeft" .. i]:GetText()
		Lines[i][2] = {_G["GameTooltipTextLeft" .. i]:GetTextColor()}
	end
	GameTooltip:Hide() -- Reset immediately
	
	-- We resetted the tooltip, as we got our description, so set owner again
	
	-- We cannot just set the hyperlink, as this does result in the attached info disappearing. Probably an AddOn that tries to alter it.
	GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
	
	-- Insert all Lines again
	for i=1, #Lines do
		GameTooltip:AddLine(Lines[i][1], unpack(Lines[i][2]))
	end
	
	local Level, Reward = GetRewardLevel()
	
	-- Add all Reward Levels of Currency
	GameTooltip:AddLine("\n")
	for i=StartIndex, EndIndex do
		if Residuum[i] then
			if Level == i or Level > EndIndex and EndIndex == i then
				GameTooltip:AddDoubleLine(LEVEL .. " " .. i, BreakUpLargeNumbers(Residuum[i]), 1, 0.82, 0, 1, 0.82, 0)
			else
				GameTooltip:AddDoubleLine(LEVEL .. " " .. i, BreakUpLargeNumbers(Residuum[i]), 0.5, 0.5, 0.5, 0.5, 0.5, 0.5)
			end
		end
	end
	
	GameTooltip:Show()
end

local function Echoes_OnEnter(self)
	GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
	
	local Link = GetCurrencyLink(EchoesID, GetEchoesCurrentAmount())
	GameTooltip:SetHyperlink(Link)
	
	-- Grab all the lines and store then
	local Lines = {}
	for i=1,GameTooltip:NumLines() do
		Lines[i] = {}
		Lines[i][1] = _G["GameTooltipTextLeft" .. i]:GetText()
		Lines[i][2] = {_G["GameTooltipTextLeft" .. i]:GetTextColor()}
	end
	GameTooltip:Hide() -- Reset immediately
	
	-- We resetted the tooltip, as we got our description, so set owner again
	
	-- We cannot just set the hyperlink, as this does result in the attached info disappearing. Probably an AddOn that tries to alter it.
	GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
	
	-- Insert all Lines again
	for i=1, #Lines do
		GameTooltip:AddLine(Lines[i][1], unpack(Lines[i][2]))
	end
	
	local Level, Reward = GetRewardLevel()
	
	-- Add all Reward Levels of Currency
	GameTooltip:AddLine("\n")
	for i=StartIndex, EndIndex do
		if Residuum[i] then
			if Level == i or Level > EndIndex and EndIndex == i then
				--GameTooltip:AddDoubleLine(LEVEL .. " " .. i, BreakUpLargeNumbers(Residuum[i]), 1, 0.82, 0, 1, 0.82, 0)
				GameTooltip:AddDoubleLine(LEVEL .. " " .. i, BreakUpLargeNumbers(GetEchoesRewardAmountForLevel(i)), 1, 0.82, 0, 1, 0.82, 0)
			else
				--GameTooltip:AddDoubleLine(LEVEL .. " " .. i, BreakUpLargeNumbers(Residuum[i]), 0.5, 0.5, 0.5, 0.5, 0.5, 0.5)
				GameTooltip:AddDoubleLine(LEVEL .. " " .. i, BreakUpLargeNumbers(GetEchoesRewardAmountForLevel(i)), 0.5, 0.5, 0.5, 0.5, 0.5, 0.5)
			end
		end
	end
	
	GameTooltip:Show()
end

local function Currency_OnLeave()
	GameTooltip:Hide()
end

function Module:NewCurrencyIcon(Parent, Name, Texture, OnEnter, OnLeave, OffsetX, OffsetY)
	-- MAIN FRAME
	local CurrencyFrame = CreateFrame("Frame", Name, Parent)
	--CurrencyFrame:SetPoint("TOPLEFT", Parent, "BOTTOMLEFT")
	--CurrencyFrame:SetPoint("TOPRIGHT", Parent, "BOTTOMRIGHT")
	CurrencyFrame:SetPoint("TOP", Parent, "BOTTOM", OffsetX or 0, OffsetY or 0)
	CurrencyFrame:SetSize(80, 20)
	
	CurrencyFrame:SetScript('OnEnter', OnEnter)
	CurrencyFrame:SetScript('OnLeave', OnLeave)
	
	-- TEXT
	local Amount = CurrencyFrame:CreateFontString(nil)
		E:InitializeFontFrame(Amount, "OVERLAY", "FRIZQT__.TTF", 11, {1, 0.82, 0}, 1, {9, -5}, "100000", 0, 0, CurrencyFrame, "TOP", {1,1})
	
	CurrencyFrame.Amount = Amount
	
	local Media = CO.db.profile.media
	local Defaults = E.ConfigDefaults.profile.media
	
	E:SetFontInfo(Amount,  E.Media:Fetch("font", Media.generalFont or (Defaults and Defaults.generalFont or "FRIZQT__.TTF")), "OUTLINE", Media.generalFontSize or Defaults.generalFontSize or 12 + 2, nil)
	E:UpdateFont(Amount)
	
	-- ICON
	local Icon = CurrencyFrame:CreateTexture("OVERLAY")
	Icon:SetSize(18, 18)
	Icon:SetPoint("RIGHT", Amount, "LEFT", -3, 0)
	Icon:SetTexture(Texture)
	
	CurrencyFrame.Icon = Icon
	
	return CurrencyFrame
end

function Module:LoadCurrencyReward()
	self.MPlusFrame = _G.ChallengesFrame
	local WeeklyChest = self.MPlusFrame.WeeklyInfo.Child.WeeklyChest
	
	self.ResiduumFrame = self:NewCurrencyIcon(WeeklyChest, "CUI_TitanResiduumAmount", CurrencyTexture, Currency_OnEnter, Currency_OnLeave, -35, 0)
	self.EchoesFrame = self:NewCurrencyIcon(WeeklyChest, "CUI_EchoesOfNyalothaAmount", EchoesTexture, Echoes_OnEnter, Currency_OnLeave, 35, 0)
	
	self.MPlusFrame:HookScript("OnShow", function()
		Module:Update()
	end)
	self:SetScript('OnEvent', function(self, event)
		self:Update()
	end)
	
	self:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE")
	self:RegisterEvent("CHALLENGE_MODE_MEMBER_INFO_UPDATED")
    self:RegisterEvent("CHALLENGE_MODE_LEADERS_UPDATE")
	self:RegisterEvent("CHALLENGE_MODE_COMPLETED")
	self:RegisterEvent("CHALLENGE_MODE_RESET")
	
	self:Update()
end

-- /run CUI_TitanResiduumAmount.Amount:SetText(9999)
function Module:Load()
	self:LoadCurrencyReward()
end

function Module:Init()
	E:FireOnAddOnLoaded(self, "Load", "Blizzard_ChallengesUI")
	
	--[[if not _G.ChallengesFrame then
		self:SetScript("OnEvent", function(self, event, AddOn)
			if C_AddOns_IsAddOnLoaded(AddOn) then
				if AddOn == 'Blizzard_ChallengesUI' then
					self:Load()
				end
			end
		end)
		self:RegisterEvent("ADDON_LOADED")
	else
		self:Load()
	end]]--
	
end

E:AddModule("Blizzard_ChallengesUI", Module)