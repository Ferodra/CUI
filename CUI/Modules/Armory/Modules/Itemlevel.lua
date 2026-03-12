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
	
	local ItemRarity, RarityColor, RarityColorHex, ItemLevel, Output, RawItemlevel
	
	-- If Item exists
	if ItemLink then
		_, _ , ItemRarity, _ = GetItemInfo(ItemLink)
		
		--if not RarityColor then
		--	print(ItemLink, ItemRarity, ITEM_QUALITY_COLORS)
		--end
		if ItemRarity then
			RarityColor = ITEM_QUALITY_COLORS[ItemRarity]
			RarityColorHex = RarityColor["hex"]
			
			ItemLevel = GetDetailedItemLevelInfo(ItemLink)
			--ItemLevel = tonumber(E.ScanningTooltip:GetData(ItemLink, ITEM_LEVEL, "%d+"))
			RawItemlevel = ItemLevel
			
			if ItemLevel and ItemLevel > 1 then
				Output = ("%s%s|r"):format(RarityColorHex, ItemLevel)
			else
				Output = ""
			end
		else
			-- This happens sometimes - not sure why, but let's just handle it
			Output = ""
			RawItemlevel = 0
			RarityColor = ITEM_QUALITY_COLORS[1]
		end
	else
		Output = ""
	end
	
	return Output, RarityColor, RawItemlevel
end

---------- Add Module
A.Modules["Itemlevel"] = Module