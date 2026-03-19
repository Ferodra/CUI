---@class E
local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO = E:LoadModules('Config')

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
local UnitReactionDefault = {1, 1, 1}


function E:GetClassColorByClassName(ClassName)
	return CO.db.profile.colors.classes[ClassName] or self.ClassColors[E.ClassIDByName[ClassName]]
end

-- Retrieve class color of unit (@param1)
function E:GetUnitClassColor(unit)
	return self.ClassColors[select(3, UnitClass(unit))] or UnitReactionDefault
end

-- Retrieve power color of unit (@param1)
function E:GetUnitPowerColor(unit)
	local CurrentUnitPowerType = UnitPowerType(unit)
	if not CurrentUnitPowerType then
		CurrentUnitPowerType = 'MANA'
	end
	
	return CO.db.profile.colors.powers[CurrentUnitPowerType] or self.PowerColors[CurrentUnitPowerType]
end

-- Retrieve alternate power color of id (@param1)
function E:GetAltPowerColor(id)
	if self.PowerTypes[id] then
		if CO.db.profile.colors.powers[self.PowerTypes[id]] then
			return CO.db.profile.colors.powers[self.PowerTypes[id]]
		end
	end
	
	return self.PowerColors[id] or self.PowerColors[0]
end

local DefaultReturnParse = {1,1,1,1}
-- Retrieve an actual class color table when colorEntry has key "useClassColor"
-- DO NOT USE unpack WITH THIS METHODS RETURN TABLE
-- If you want to get the proper alpha value that's also configurable WITH enabled class color,
-- use standard indexing like (tbl[1], tbl[2], tbl[3] ,tbl[4])
function E:ParseDBColor(colorEntry, unit)
	if type(colorEntry) == 'table' then
		if colorEntry.useClassColor then
			unit = unit or 'player'
			
			local ClassColorCache = {}
			
			-- Get color on a per-value basis so nothing can be altered accidentally (except alpha)
			for k,v in pairs(E:GetUnitClassColor(unit)) do
				ClassColorCache[k] = v
			end
			
			-- Use Alpha from color table on class colors
			if type(colorEntry[1]) == 'table' and colorEntry[1][4] then
				if not ClassColorCache.HasMeta then
					ClassColorCache[4] = nil
					
					-- We need the metatable to pull values from the actual DB color table
					-- This allows us to sort of "harden" the class color table against changes
					setmetatable(ClassColorCache, {
						__index = function(tbl, key)
							if key == 4 then
								return colorEntry[1][4]
							end
						end,
						__newindex = function(tbl, key, value)
							if key == 4 then
								colorEntry[1][4] = value
								-- Reset immediately, so we continue calling this
								rawset(tbl, key, nil)
							end
							
						end
					})
					
					ClassColorCache.HasMeta = true
				end
			end
			return ClassColorCache
		else
			if type(colorEntry[1]) == 'table' then -- There's no class color info
				return colorEntry[1]
			else
				return colorEntry
			end
		end
	end
	
	-- Fallback if something goes horribly wrong
	return DefaultReturnParse
end

local ReturnTable = {}
function E:GetUnitReactionColor(Unit, ReturnRGB, IgnoreCustoms)
	
	-- Soft-Empty table
	for k, v in pairs(ReturnTable) do
		ReturnTable[k] = nil
	end
	
	-- Unit Name Coloring
	if not IgnoreCustoms then
		local Name = UnitName(Unit)
		
		if not issecretvalue(Name) then
			local Tbl = CO.db.global.colors.units[Name]
			
			if Tbl and Tbl.enabled and Tbl.color then
			
				if ReturnRGB == nil or ReturnRGB == true then
					ReturnTable.r = Tbl.color.r
					ReturnTable.g = Tbl.color.g
					ReturnTable.b = Tbl.color.b
				else
					ReturnTable[1] = Tbl.color.r
					ReturnTable[2] = Tbl.color.g
					ReturnTable[3] = Tbl.color.b
				end
			
				return ReturnTable
			end
		end
	end
	
	local ReactionColor = UnitReactionDefault
	local ClassName = select(2, UnitClass(Unit))
	local UnitReaction	= UnitReaction(Unit, 'player') -- Get reaction towards player
	
	if UnitReaction then
		if not UnitIsPlayer(Unit) then
			if not UnitIsFriend(Unit, 'player') and UnitIsEnemy(Unit, 'player') then
				UnitReaction = 1
			end
			
			if UnitReaction >= 5 then
				ReactionColor = CO.db.profile.colors.reactions.friendly
			elseif UnitReaction == 4 then
				ReactionColor = CO.db.profile.colors.reactions.neutral
			elseif UnitReaction == 3 then
				ReactionColor = CO.db.profile.colors.reactions.unfriendly
			else
				ReactionColor = CO.db.profile.colors.reactions.hostile
			end
		else
			if UnitReaction >= 5 then  
				ReactionColor = self:GetClassColorByClassName(ClassName)
				if not ReactionColor then
					-- Probably a new class, so just return neutral as failsafe
					ReactionColor = CO.db.profile.colors.reactions.neutral
				end
			else
				ReactionColor = CO.db.profile.colors.reactions.hostile
			end
		end
	elseif ClassName then
		ReactionColor = self:GetClassColorByClassName(ClassName)
	end
	
	if ReturnRGB == nil or ReturnRGB == true then
		ReturnTable.r = ReactionColor[1]
		ReturnTable.g = ReactionColor[2]
		ReturnTable.b = ReactionColor[3]
	else
		ReturnTable[1] = ReactionColor[1]
		ReturnTable[2] = ReactionColor[2]
		ReturnTable[3] = ReactionColor[3]
	end
	
	return ReturnTable
end

-- Basically a copy function. Just.. do not touch, since i don't remember why we needed this. It was important though.
-- It probably was for getting rid of the DB table reference
function E:GetMappedColorTable(Source, FromRGB)
	
	local Target = {}
	
	if not FromRGB then
		Target[1] = Source[1]
		Target[2] = Source[2]
		Target[3] = Source[3]
	else
		Target.r = Source.r
		Target.g = Source.g
		Target.b = Source.b
	end
	
	return Target
end

function E:GetColorizedClassName(ClassID)
	return self:GetClassColorizedText(select(1, GetClassInfo(ClassID)), ClassID)
end

function E:GetClassColorizedText(Text, ClassID)
	
	local Hex, Color, ClassName
	
	_, ClassName = GetClassInfo(ClassID)
	Color = CO.db.profile.colors.classes[ClassName]
	Hex = self:RgbToHex(E:GetMappedColorTable(Color, false), true)
	
	return format('|c%s%s|r', Hex, Text)
end

-- Compact method to retrieve a unit name string in user-defined class colors
local Name, Class, Hex
function E:GetColorizedUnitName(Unit)
	Name = UnitName(Unit)
	_, Class = UnitClass(Unit)
	
	if Name and Class then
		Hex = self:RgbToHex(self:GetUnitReactionColor(Unit, false), true)
		
		if Hex then
			return format('|c%s%s|r', Hex, Name)
		else
			return Name
		end
	end
	
	return Name
end

function E:GetCustomAuraColor(SpellID)
	if not issecretvalue(SpellID) and CO.db.profile.colors.auras[SpellID] and CO.db.profile.colors.auras[SpellID].enabled then
		return CO.db.profile.colors.auras[SpellID].color
	end
end

local DTypeColors = {
	['Curse'] = {0.6,0,1},
	['Disease'] = {0.6,0.4,0},
	['Magic'] = {0.2,0.6,1},
	['Poison'] = {0,0.6,0},
	['Others'] = {0.8,0,0},
	['none'] = {0.8,0,0}
}

function E:GetAuraColor(DType, Unit, AuraType, AuraName, SpellID, DefaultColor)
	if SpellID then
		if not SpellID then
			SpellID = AuraName and select(7, E.GetSpellInfo(AuraName)) or SpellID
		end
		
		local Color = E:GetCustomAuraColor(SpellID)
		if Color then return Color end
	end
	-- If no custom color entry exists, continue
	
	if AuraType == 'HARMFUL' then
		-- Blizz already provides a list of possible colors
		if DType then
			return DTypeColors[DType]
		else
			return DTypeColors.none
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
--E:Hook(E, 'OnEnable', function()
--	DBReactions = CO.db.profile.colors.reactions
--	DBColors 	= CO.db.profile.colors.classes
--end)