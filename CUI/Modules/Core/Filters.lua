local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, Module, BA = E:LoadModules("Config", "Filters", "Bar_Auras")

---------------------------------------------------
local pairs 					= pairs
local select 					= select
local GetSpellBookItemInfo 		= C_SpellBook and C_SpellBook.GetSpellBookItemInfo or GetSpellBookItemInfo
---------------------------------------------------

Module.Data = {}
E.AuraFilters = Module.Data

Module.Types = {['Whitelist'] = 1, ['Blacklist'] = 2}
Module.TypesByID = {
	[1] = 'Whitelist',
	[2] = 'Blacklist',
}

-- Runtime cache, so we speed up recurring lookups.
-- This is to avoid having to lookup the potentially massive table of entries every single time
local FilterCache = {}

-- Reference table to search for filter names
local RecursiveIdentifier = {}
function Module:UpdateRecursiveTable()
	wipe(RecursiveIdentifier)
	self:ClearCache()
	
	for index, data in pairs(self.Data) do
		RecursiveIdentifier[data.name] = index
	end
end

-- We call this from config whenever we altered settings.
function Module:ClearCache()
	wipe(FilterCache)
end

local function GetFilterTableByName(name)
	local Index = RecursiveIdentifier[name]
	if Index then
		return Module.Data[Index]
	end
end

---------------------------------------------
	
	function Module:IsProtected(filterIdentifier)
		local tbl = self:GetFilterData(filterIdentifier)
		if not tbl then return nil end
		
		return (tbl.isProtected) and true or false
	end
	
	function Module:AddSpellIDToUnitAurabarsFilter(spellID, unit, duration)
		if unit ~= "player" and unit ~= "target" then
			E:print("Functionality for this is coming soon(tm)")
			return
		end
		local Filter = self:GetFilterData(CO.db.profile.auras.units[unit].aurabars.filterType)
		
		if not Filter.entries[spellID] and duration > 1 then
			E:print(spellID .. " was added to the " .. unit .. " aura bars filter.")
			Filter.entries[spellID] = {enabled = true}
			
			Module:UpdateRecursiveTable()
			BA:UpdateAuras(unit, true)
		elseif Filter.entries[spellID] then
			E:print(spellID .. " already exists for the " .. unit .. " aura bars filter.")
		end
	end
	
	-- FilterIdentifier HAS to be either the filter index or the name
	function Module:Add(filterIdentifier, id, data)
		if not filterIdentifier or not id or not data then return end
		
		local tbl = self:GetFilterData(filterIdentifier)
		if not tbl then return end
		
		if not tbl[id] then
			tbl[id] = data
		end
	end
	
	-- Method to safely remove filters
	-- @return: Success (bool)
	function Module:Remove(ID)
		if not ID then return false end
		
		local tbl = self.Data[ID]
		if not tbl then return false end
		
		if self:IsProtected(ID) then return false end
		
		-- Search for dependencies first to cleanly remove the filter entry
		for _, data in pairs(CO.db.profile.unitframe.units) do
			if data.buffs.filterType == tbl.name then
				data.buffs.filterType = -1
			end
			if data.debuffs.filterType == tbl.name then
				data.debuffs.filterType = -1
			end
		end
		
		for _, data in pairs(CO.db.profile.auras.units) do
			if data.aurabars then
				if data.aurabars.filterType == tbl.name then
					data.aurabars.filterType = -1
				end
			end
		end
		
		
		self.Data[ID] = nil
		self:UpdateRecursiveTable()
		
		return true
	end
	
	-- Use this for select values
	function Module:GetAvailableFilters()
		local Filters = {}
		
		for k,v in pairs(self.Data) do
			Filters[k] = v.name
		end
		
		Filters[-1] = "None"
		
		return Filters
	end
	
	function Module:GetFilterData(filterIdentifier)
		return GetFilterTableByName(filterIdentifier) or self.FilterDB[filterIdentifier]
	end
	
	function Module:GetFilterType(filterIdentifier)
		local Data = self:GetFilterData(filterIdentifier)
		return Data and self.TypesByID[Data.type] or nil
	end
	
	function Module:GetAuraPriority(Filter, SpellID)
		local Data = self:GetFilterData(Filter)
		
		if Data and Data.entries[SpellID] then
			return Data.entries[SpellID].priority or 1
		end
		
		return 1
	end
	
	-- Checks wether or not the given id should be filtered according to the filter type
	-- Return: true = Should be filtered; false = Should NOT be filtered
	function Module:CheckAuraID(Filter, id)
		if not Filter then return false end
		
		if Filter.entries[id] and Filter.entries[id].enabled then
			return not (Filter.type == 1)
		end
		
		-- If there are additional spell ID's we could check
		if self.AdditionalSpellIDs[id] then
			for _, AdditionalSpellID in pairs(self.AdditionalSpellIDs[id]) do
				if Filter.entries[AdditionalSpellID] and Filter.entries[AdditionalSpellID].enabled then
					return not (Filter.type == 1)
				end
			end
		end
		
		-- Default Filter behaviour
		return Filter.type == 1
	end
	
	-- Tries to resolve the AuraSpellID to a SpellID the player has in their spellbook
	-- This solves cases where a spellbook spellID was added as a filter spell
	-- This also uses possible extra ID data from our spellbook
	local function CheckSpellbookForAuraIDMatch(Filter, id)		
		-- Resolve to Name
		local Name = E:GetSpellInfo(id)
		local Info = E:GetSpellbookSpellInfoByName(Name)
		
		local SpellbookID, Type
		local CheckResult = false
		if Info then
			for ID, Data in pairs(Info) do
				if Module.AdditionalSpellIDs[ID] and not Module:CheckAuraID(Filter, ID) then
					SpellbookID = ID
					Type = unpack(Data)
					
					break
				end
			end
		end
		
		if SpellbookID then
			return false
		else
			return true
		end
	end
	
	-- Checks if the aura ID should be filtered (not shown)
	-- Return: true = Should be filtered; false = Should NOT be filtered
	function Module:IsFiltered(filterIdentifier, id)
		if not filterIdentifier or (filterIdentifier and filterIdentifier < 1) then return false end
		
		-- Return cached data
		if FilterCache[filterIdentifier]  then
			if FilterCache[filterIdentifier][id] then
				return FilterCache[filterIdentifier][id][1], FilterCache[filterIdentifier][id][2]
			end
		else
			FilterCache[filterIdentifier] = {}
		end
		
		--------------------------------------------------------
		local Filter = self:GetFilterData(filterIdentifier)
		local Result = self:CheckAuraID(Filter, id) and CheckSpellbookForAuraIDMatch(Filter, id)
		--------------------------------------------------------
		
		-- Cache data if it doesn't exist yet
		if not FilterCache[filterIdentifier][id] then
			FilterCache[filterIdentifier][id] = {}
			FilterCache[filterIdentifier][id][1] = Result
			FilterCache[filterIdentifier][id][2] = self:GetFilterType(filterIdentifier)
		end
		
		return Result, self:GetFilterType(filterIdentifier)
	end

---------------------------------------------

function Module:UpdateDB()
	self.FilterDB = CO.db.global.filters.auras
end

function Module:Init()	
	self.Data = self.FilterDB
	self:UpdateRecursiveTable()
end

E:AddModule('Filters', Module)