local E, L = unpack(CUI) -- Engine
local CO = E:LoadModules("Config")
local ST = select(2, ...)

local tinsert = table.insert
local additionalKeys = {}

local CurrentCharacterKey

function ST:PrepareCharacterData(charKey)
	local db = self.db.global.characters
	
	-- Create new key if needed
	if not db[charKey] then db[charKey] = {} end
	
	for _, name in pairs(additionalKeys) do
		if not db[charKey][name] then
			db[charKey][name] = {}
		end
	end
	
	return db[charKey]
end

function ST:RegisterCharacterDataKey(name)
	tinsert(additionalKeys, name)
end

function ST:GetCurrentCharacterKey()
	return CurrentCharacterKey
end

-- Writes basic character data
function ST:InitCurrentCharacter()
	local realmKey = GetRealmName()
	CurrentCharacterKey = UnitName("player") .. " - " .. realmKey
	
	self:PrepareCharacterData(CurrentCharacterKey)
	
	local class = select(2, UnitClass("player"))
	local specID = GetSpecializationInfo(GetSpecialization())
	local level = UnitLevel("player")
	local race = select(2, UnitRace("player"))
	local sex = UnitSex("player")
	local faction = UnitFactionGroup("player")
	
	local DB = self.db.global.characters[CurrentCharacterKey]
	DB["class"] = class
	DB["specID"] = specID
	DB["level"] = level
	DB["race"] = race
	DB["faction"] = faction
	DB["sex"] = sex
end