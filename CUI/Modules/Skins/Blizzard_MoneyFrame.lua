local E = unpack(select(2, ...)) -- Engine, Locale
local CO, ItemDB, Module = E:LoadModules("Config", "ItemDB", "Blizzard_MoneyFrame")
Module.Autoload = true

local _
local RAID_CLASS_COLORS		 	= RAID_CLASS_COLORS
local HONOR_LIFETIME		 	= HONOR_LIFETIME

local function OnEnter(self)
	GameTooltip:SetOwner(self, 'TOPLEFT')
	
	local Data = ItemDB:GetCurrencyInfo('Money', 'amount')
	
	if not Data or Data.Total < 1 then GameTooltip:Hide(); return end
	
	local Color = {}
	GameTooltip:AddLine(HONOR_LIFETIME .. ": " .. E:FormatMoney(Data.Total, true))
	if Data.WARBANK > 0 then
		GameTooltip:AddLine(ACCOUNT_BANK_PANEL_TITLE .. ": " .. E:FormatMoney(Data.WARBANK, true))
	end
	GameTooltip:AddLine(' ')
	
	
	for i=1, #Data.Chars do
		if Data.Chars[i].amount > 0 then
			Color = RAID_CLASS_COLORS[Data.Chars[i].class or "PRIEST"]
			GameTooltip:AddDoubleLine(Data.Chars[i].name, E:FormatMoney(Data.Chars[i].amount, true), Color.r, Color.g, Color.b, Color.r, Color.g, Color.b)
		end
	end
	
	GameTooltip:Show()
end

local function OnLeave(self)
	GameTooltip:Hide()
end

local Frames = {
	"AccountBankPanel%sButton",
	"BankFrameMoneyFrame%sButton",
	"ContainerFrame1MoneyFrame%sButton", 
	"ContainerFrameCombinedBags%sButton",
}
local FrameCurrencyTypes = {"Gold", "Silver", "Copper"}
function Module:Init()
	local FrameName
	
	for _, FormatName in pairs(Frames) do
		for _, CurrencyType in pairs(FrameCurrencyTypes) do
			FrameName = format(FormatName, CurrencyType)
			local Frame = _G[FrameName]
			
			if Frame then
				Frame:EnableMouse(true)
				Frame:HookScript('OnEnter', OnEnter)
				Frame:HookScript('OnLeave', OnLeave)
			end
		end
	end
end

E:AddModule("Blizzard_MoneyFrame", Module)