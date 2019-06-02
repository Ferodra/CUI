local E, L = unpack(select(2, ...)) -- Engine, Locale
local A, CO = E:LoadModules("Armory", "Config")

--[[--------------------
	Armory Extension	
--------------------]]--

local _
local tonumber				= tonumber
local GetItemInfo			= GetItemInfo
local ITEM_QUALITY_COLORS	= ITEM_QUALITY_COLORS
local ITEM_LEVEL			= ITEM_LEVEL
local Module = {}

-----------------------------------------

function Module:GetInfo(ItemLink)
	
	local ItemRarity, RarityColor, RarityColorHex, ItemLevel, Output
	
	-- If Item exists
	if ItemLink then
		_, _ , ItemRarity, _ = GetItemInfo(ItemLink)
		RarityColor = ITEM_QUALITY_COLORS[ItemRarity]
		RarityColorHex = RarityColor["hex"]
		
		ItemLevel = tonumber(A:GetTooltipData(ItemLink, ITEM_LEVEL, "%d+"))
		
		if ItemLevel and ItemLevel > 1 then
			Output = ("%s%s|r"):format(RarityColorHex, ItemLevel)
		else
			Output = ""
		end
	else
		Output = ""
	end
	
	return Output, RarityColor
end

---------- Add Module
A.Modules["Itemlevel"] = Module