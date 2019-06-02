local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, L = E:LoadModules("Config", "Locale")

--[[-------------------------------------------------
	
	This part of the CUI API is responsible
	to handle all user-defined color information
	across the API
	
-------------------------------------------------]]--

---------------------------------------------------
local _
local format 					= string.format
local select 					= select
local UnitClass 				= UnitClass
local UnitIsPlayer 				= UnitIsPlayer
local UnitIsFriend 				= UnitIsFriend
local UnitIsEnemy 				= UnitIsEnemy
local UnitReaction 				= UnitReaction
---------------------------------------------------
local UnitReactionDefault, UnitReactionColor, UnitReactionClassName, UnitReactionProfileTarget, UnitReactionClassProfileTarget, UnitReactionReaction, ReturnTable
UnitReactionDefault = {1, 1, 1}


-- Retrieve class color of unit (@param1)
function E:GetUnitClassColor(unit)
	return self.ClassColors[select(3, UnitClass(unit))]
end

-- Retrieve power color of unit (@param1)
function E:GetUnitPowerColor(unit)
	return CO.db.profile.colors.powers[select(2,UnitPowerType(unit))] or self.PowerColors[UnitPowerType(unit)]
end

-- Retrieve alternate power color of id (@param1)
function E:GetAltPowerColor(id)
	return CO.db.profile.colors.powers[E.PowerTypes[id]] or self.PowerColors[id]
end

local DefaultReturnParse = {1,1,1,1}
local ClassColorCache = {}
-- Retrieve an actual class color table when color is "class"
function E:ParseDBColor(colorEntry, unit)
	if type(colorEntry) == "table" then
		if colorEntry.useClassColor then
			if not unit then unit = "player" end
			
			-- Get color on a per-value basis so nothing can be altered accidentally (except alpha)
			for k,v in pairs(E:GetUnitClassColor(unit)) do
				ClassColorCache[k] = v
			end
			
			-- Use Alpha from color table on class colors
			if colorEntry[1] == "table" and colorEntry[1][4] then
				ClassColorCache[4] = colorEntry[1][4]
			end
			return ClassColorCache
		else
			if type(colorEntry[1]) == "table" then -- There's no class color info
				return colorEntry[1]
			else
				return colorEntry
			end
		end
	end
	
	-- Fallback if something goes horribly wrong
	return DefaultReturnParse
end

ReturnTable = {}
function E:GetUnitReactionColor(Unit, ReturnRGB)	
	UnitReactionColor = UnitReactionDefault
	_, UnitReactionClassName = UnitClass(Unit)
	
	-- Soft-Empty table
	for k, v in pairs(ReturnTable) do
		ReturnTable[k] = nil
	end
	
	UnitReactionReaction 		= UnitReaction(Unit, "player") -- Get reaction towards player
	if UnitReactionReaction then
		if not UnitIsPlayer(Unit) then
			
			if not UnitIsFriend(Unit, "player") and UnitIsEnemy(Unit, "player") then
				UnitReactionReaction = 1
			end
			
			if UnitReactionReaction >= 5 then
				UnitReactionColor = CO.db.profile.colors.reactions["friendly"]
			elseif UnitReactionReaction == 4 then
				UnitReactionColor = CO.db.profile.colors.reactions["neutral"]
			elseif UnitReactionReaction == 3 then
				UnitReactionColor = CO.db.profile.colors.reactions["unfriendly"]
			else
				UnitReactionColor = CO.db.profile.colors.reactions["hostile"]
			end
		else
			if UnitReactionReaction >= 5 then  
				UnitReactionColor = CO.db.profile.colors.classes[UnitReactionClassName]
			else
				UnitReactionColor = CO.db.profile.colors.reactions["hostile"]
			end
		end
	elseif UnitReactionClassName then
		UnitReactionColor = CO.db.profile.colors.classes[UnitReactionClassName]
	end
	
	if ReturnRGB == nil or ReturnRGB == true then
		ReturnTable.r = UnitReactionColor[1]
		ReturnTable.g = UnitReactionColor[2]
		ReturnTable.b = UnitReactionColor[3]
	else
		ReturnTable[1] = UnitReactionColor[1]
		ReturnTable[2] = UnitReactionColor[2]
		ReturnTable[3] = UnitReactionColor[3]
	end
	
	return ReturnTable
end

-- Compact method to retrieve a unit name string in user-defined class colors
local Name, Class, Hex
function E:GetColorizedUnitName(Unit)
	Name = UnitName(Unit)
	_, Class = UnitClass(Unit)
	
	if Name and Class then
		Hex = self:RgbToHex(self:GetUnitReactionColor(Unit, false), true)
		
		if Hex then
			return format("|c%s%s|r", Hex, Name)
		else
			return Name
		end
	end
	
	return Name
end

function E:GetCustomAuraColor(SpellID)
	if CO.db.profile.colors.auras[SpellID] and CO.db.profile.colors.auras[SpellID].enabled then
		return CO.db.profile.colors.auras[SpellID].color
	end
end

function E:GetAuraColor(DType, Unit, AuraType, AuraName, SpellID, DefaultColor)
	if AuraName or SpellID then
		SpellID = select(7, GetSpellInfo(AuraName)) or SpellID
		
		local Color = E:GetCustomAuraColor(SpellID)
		if Color then return Color end
	end
	-- If no custom color entry exists, continue
	
	if AuraType == E.STR.HARMFUL then
		-- Blizz already provides a list of possible colors
		if DType then
			return DebuffTypeColor[DType]
		else
			return DebuffTypeColor["none"]
		end
	else
		if not DefaultColor or DefaultColor and DefaultColor.useClassColor and Unit then
			return E:GetUnitReactionColor(Unit)
		else
			return E:ParseDBColor(DefaultColor)
		end
	end
end

-- Post-Init Hook!
--E:Hook(E, "OnEnable", function()
--	DBReactions = CO.db.profile.colors.reactions
--	DBColors 	= CO.db.profile.colors.classes
--end)