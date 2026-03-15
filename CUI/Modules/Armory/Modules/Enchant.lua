local E, L = unpack(select(2, ...)) -- Engine, Locale
local A, CO = E:LoadModules("Armory", "Config")

--[[--------------------
	Armory Extension	
--------------------]]--

local _
local GetItemInfoInstant		= GetItemInfoInstant
local EnchantString				= E:firstToUpper(ACTION_ENCHANT_APPLIED)
local Module = {}


local ENCHANTED_TOOLTIP_LINE = ENCHANTED_TOOLTIP_LINE
local EnchantMatchKey = ENCHANTED_TOOLTIP_LINE:gsub('%%s', '(.+)')

-- Those tables can be modified at any time
	-- Slot Whitelist for displaying missing enchants
do
	if E.IsRetail then
		Module.EnchantSlots = {
			[1] = true, 	-- Head
			[2] = false, 	-- Neck
			[3] = true, 	-- Shoulder
			[5] = true, 	-- Chest
			[6] = false, 	-- Waist
			[7] = true, 	-- Legs
			[8] = true, 	-- Feet
			[9] = false, 	-- Wrist
			[10] = false, 	-- Hand
			[11] = true, 	-- Finger 1
			[12] = true, 	-- Finger 2
			[13] = false, 	-- Trinket 1
			[14] = false, 	-- Trinket 2
			[15] = false, 	-- Cloak
			[16] = true, 	-- Weapon 1
			[17] = true, 	-- Weapon 2
		}
	else
		Module.EnchantSlots = {
			-- [10] = true, -- Hand
			[11] = true, 	-- Finger 1
			[12] = true, 	-- Finger 2
			[16] = true, 	-- Weapon 1
			[17] = true, 	-- Weapon 2
		}
	end
end
	-- Item Class Blacklist
	-- Data from: https://wow.gamepedia.com/ItemType
	Module.NonEnchantableSubIDs = {
		[2] = {11, 12, 14, 16, 17, 19, 20}, -- Weapons: Fishing Poles, Misc, Wands
		[4] = {6}, -- Armor: Shields
	}


-----------------------------------------

function Module:ItemShouldBeEnchanted(ItemLink)
	local _, _, _, ItemEquipLoc, _, itemClassID, itemSubClassID = GetItemInfoInstant(ItemLink)
	local Slots = A.ItemInvTypeToSlot[ItemEquipLoc]
	
	-- Off-Hand Only Equipment like Books etc. cannot be enchanted!
	if ItemEquipLoc == 'INVTYPE_HOLDABLE' then return false end
	
	-- This will return the required count when more than one slot is given
	-- A.e.: Ring Slots are 11 and 12. Even if we remove Slot 11 from the table above, we'll always be notified when
	-- less than one enchant is present
	for _, Slot in pairs(Slots) do
		if self.EnchantSlots[Slot] then
			if self.NonEnchantableSubIDs[itemClassID] then
				if E:TableContainsValue(self.NonEnchantableSubIDs[itemClassID], itemSubClassID) then
					return false
				else
					return true
				end
			else
				return true
			end
		else
			return false
		end
	end
end

function Module:GetInfo(ItemLink)
	
	local Output = ""
	local IsEnchanted = false
	
	if ItemLink then							
		Enchant = E.ScanningTooltip:GetData(ItemLink, EnchantMatchKey, EnchantMatchKey)
		
		if Enchant then
			Output = ("|cff3ef434%s|r"):format(Enchant)
			IsEnchanted = true
		elseif self:ItemShouldBeEnchanted(ItemLink) then
			Output = ("|cfff42f10%s|r"):format(EnchantString)
		end
	end
	
	return Output, IsEnchanted
end

---------- Add Module
A.Modules["Enchant"] = Module