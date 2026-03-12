local E, L = unpack(CUI) -- Engine
local CD = E:LoadModules("Config_Dialog")

local _
local lower = string.lower
local GetSpellBookItemInfo 		= C_SpellBook.GetSpellBookItemInfo or GetSpellBookItemInfo
local SpellCache = {}
local CachedNum = 0

function CD:GetSpellLoadButton(order)
	local Config = {
		type = "execute",
		order = order,
		name = "Load Spells",
		desc = "This function will load every spell definition in the game to basically guarantee that it will be found when you enter aura names.\nIf a match was found, you will be shown an additional icon next to the input box. On mouseover, you will see what IDs are available. Then, simply enter the correct ID.\n\nNOTE: This is NOT required for Spells which are in your Spellbook or (learned) Talents!",
		hidden = function() return CD:IsSpellCacheInitialized() end,
		func = function() CD:InitSpellCache() end
	}
	
	return Config
end

function CD:GetSpellFromCache(name)
	if not name then return end
	return SpellCache[lower(name)]
end

function CD:InitSpellCache()
	if self.SpellCacheInitialized then return end
	
    local id = 0
    local misses = 0
	local resetId = 0

	while misses < 400 do
		id = id + 1
		local name, _, icon = E:GetSpellInfo(id)

		if(icon == 136243) then -- 136243 is the a gear icon, we can ignore those spells
		  misses = 0;
		elseif name and name ~= "" then
		  name = lower(name)
		  SpellCache[name] = SpellCache[name] or {}
		  SpellCache[name][id] = SpellCache[name][id] or {}
		  SpellCache[name][id].Icon = icon
		  CachedNum = CachedNum + 1
		  misses = 0
		else
		  misses = misses + 1
		end
	end
	
	self.SpellCacheInitialized = true
	E:print(("%d Spell Definitions loaded!"):format(CachedNum))
end

function CD:GetSpellMatchNumber(name)
	local Matches = self:GetSpellFromCache(name)
	local Num = 0
	
	if Matches then
		for ID, _ in pairs(Matches) do
			Num = Num + 1
		end
	end
	
	return Num
end

function CD:GetSpellMatchHeader(name)
	
	local Cache = CD:GetSpellFromCache(name)
	
	if Cache then
		for ID, _ in pairs(Cache) do
			if not Cache[ID].Desc then
				local spell = Spell:CreateFromSpellID(ID)
				spell:ContinueOnSpellLoad(function()
					Cache[ID].Desc = spell:GetSpellDescription()
				end)
			end
		end
	end
	
	return CD:GetSpellMatchNumber(name) .. " Matches"
end

function CD:GetSpellMatchTooltip(name)
	if not name then return "" end
	local Cache = SpellCache[lower(name)]
	if(Cache) then
		local descText
		
		for id, _ in pairs(Cache) do
		  local name, _, icon = E:GetSpellInfo(id)
		  if(icon) then
			if Cache[id].Desc then
				descText = (descText or "") .. "\n|T"..icon..":0|t: "..id.."\n|cFFFFD700"..(Cache[id].Desc ~= "" and Cache[id].Desc or "Spell Description could not be loaded!").."|r\n"
			else
				descText = (descText or "") .. "\n|T"..icon..":0|t: "..id
			end
		  end
		end
		return descText
	else
		return ""
	end
end

function CD:GetIcon(name)
	local IDs = self:GetSpellFromCache(name)
	
	if IDs then
		for _, Data in pairs(IDs) do
			return Data.Icon
		end
	end
	
	return 136243
end

function CD:IsSpellCacheInitialized()
	return self.SpellCacheInitialized
end