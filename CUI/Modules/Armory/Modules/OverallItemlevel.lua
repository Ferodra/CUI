local E, L = unpack(select(2, ...)) -- Engine, Locale
local A, CO = E:LoadModules("Armory", "Config")

--[[--------------------
	Armory Extension	
--------------------]]--

local _
local tonumber				= tonumber
local select				= select
local pairs					= pairs
local GetInventoryItemLink	= GetInventoryItemLink
local format				= string.format
local max					= math.max
local GetItemInfo			= GetItemInfo
local ITEM_LEVEL			= ITEM_LEVEL
local Module = {}

local Base_ItemlevelString = ITEM_LEVEL:gsub(" %%d", ": %%s")
local ArmorSlots = {1,2,3,5,6,7,8,9,10,11,12,13,14,15} -- Those MUST be counted in
local DoubleValueTypes = {['INVTYPE_2HWEAPON']=true, ['INVTYPE_RANGEDRIGHT']=true, ['INVTYPE_RANGED']=true}
local DoubleExceptions = {[2] = 19} -- Wands

-----------------------------------------

local function GetItemIlvl(ItemLink)
	return select(3, A.Modules["Itemlevel"]:GetInfo(ItemLink))
end

local function ShouldDoubleWeapon(Main_Location, Off_Location, Main_ItemClass, Main_SubClass, IsFuryWarrior)
	return not Off_Location and DoubleValueTypes[Main_Location] and DoubleExceptions[Main_ItemClass] ~= Main_SubClass
end

-- This lib assumes that we already have stored the itemlevel values for each gear slot!
function Module:GetInfo(Unit)
	
	Unit = Unit or 'player'
	
	-- Apparently, the API doesn't really care wether or not the unit is a fury warrior, when it comes to itemlevel calculation, 
	-- as the ilvls will not match when keeping this in.
	--local IsFuryWarrior = select(2, UnitClass(Unit)) == 'WARRIOR' and GetInspectSpecialization(Unit) == E.SpecializationIDs.WARRIOR.FURY
	
	local Itemlevel, Overall_Itemlevel = 0, 0
	local ItemType, ItemSubtype, ItemLink
	
	-- ARMOR
	for k, Slot in pairs(ArmorSlots) do
		ItemLink = GetInventoryItemLink(Unit, Slot)
		
		-- ARMOR
		if Slot < 16 then
			if not ItemLink then
				Itemlevel = 0
			else
				Itemlevel = GetItemIlvl(ItemLink)
			end
			
			Overall_Itemlevel = Overall_Itemlevel + Itemlevel
		end
	end
	
	-- Separate Armor and Weapon processing, so we can access both easier down below
	
	-- MAIN-HAND
	local Main_Itemlevel, Main_Quality, Main_Location, Main_ItemClass, Main_SubClass = 0
		ItemLink = GetInventoryItemLink(Unit, 16)
	if ItemLink then
		Main_Itemlevel = GetItemIlvl(ItemLink)
		_,_, Main_Quality,_,_,_,_,_, Main_Location,_,_, Main_ItemClass, Main_SubClass = GetItemInfo(ItemLink)
	end
	
	-- OFF-HAND
	local Off_Itemlevel, Off_Location = 0
		ItemLink = GetInventoryItemLink(Unit, 17)
	if ItemLink then
		Off_Itemlevel = GetItemIlvl(ItemLink)
		_,_,_,_,_,_,_,_, Off_Location = GetItemInfo(ItemLink)
	end
	
	if Main_Location or Off_Location then
		if Main_Quality == 6 or ShouldDoubleWeapon(Main_Location, Off_Location, Main_ItemClass, Main_SubClass) then
			Overall_Itemlevel = Overall_Itemlevel + max(Main_Itemlevel, Off_Itemlevel) * 2
		else
			Overall_Itemlevel = Overall_Itemlevel + Main_Itemlevel + Off_Itemlevel
		end
	end
	
	local Output = Overall_Itemlevel
	
	if Overall_Itemlevel > 0 then
		Output = format('%0.2f', E:Round(Overall_Itemlevel / 16, 2))
	end
	
	return Output, Base_ItemlevelString:format(Output)
	
end

---------- Add Module
A.Modules["OverallItemlevel"] = Module