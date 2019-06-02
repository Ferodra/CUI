local E, L = unpack(select(2, ...)) -- Engine, Locale

-- @TODO: Profile Data needs a "restore default" button!
--[[----------------------------------------

	This CUI Module is responsible
	for all on-demand font text value updates
	
	Other things like a power-type based
	text-color have to be done externally
	
--]]----------------------------------------

--------------------------------------------
local match					= string.match
local tinsert				= table.insert
local select				= select
local pairs					= pairs
local wipe					= wipe
local UnitExists			= UnitExists
local UnitSex				= UnitSex
local UnitHealth			= UnitHealth
local UnitHealthMax			= UnitHealthMax
local UnitPower				= UnitPower
local UnitPowerMax			= UnitPowerMax
local UnitClass				= UnitClass
local UnitName				= UnitName
local UnitInRaid			= UnitInRaid
local GetRaidRosterInfo		= GetRaidRosterInfo
local GetGuildInfo			= GetGuildInfo
local UnitLevel				= UnitLevel
local GetMaxPlayerLevel		= GetMaxPlayerLevel
local UnitClassification	= UnitClassification
local LOCALIZED_CLASS_NAMES_MALE 	= LOCALIZED_CLASS_NAMES_MALE
local LOCALIZED_CLASS_NAMES_FEMALE 	= LOCALIZED_CLASS_NAMES_FEMALE
--------------------------------------------

local EventHandler = CreateFrame('Frame')
EventHandler.EventFrames = {}
local Classifications = { ["worldboss"] = "Worldboss", ["rareelite"] = "Rare-Elite", ["elite"] = "Elite", ["rare"] = "Rare", ["normal"] = "", ["trivial"] = "", ["minus"] = "" }

---------------------------------------------------------------------------------
	
	-- Those getters ALWAYS must return something. Otherwise the parser below
	-- will be in big trouble!
	
	local function Properties_GetHealth(Unit)
		return UnitHealth(Unit)
	end
	
	local function Properties_GetHealthFormatted(Unit)
		return E:readableNumber(UnitHealth(Unit), 2)
	end

	local function Properties_GetHealthMax(Unit)
		return UnitHealthMax(Unit)
	end
	
	local function Properties_GetHealthMaxFormatted(Unit)
		return E:readableNumber(UnitHealthMax(Unit), 2)
	end

	local function Properties_GetHealthPct(Unit)
		local Max = UnitHealthMax(Unit)
		if Max > 0 then
			return E:Round((UnitHealth(Unit) / Max) * 100, 2) .. "%%"
		else
			return ""
		end
	end
	
	-------------------------------------------
	
	local function Properties_GetPower(Unit)
		return UnitPower(Unit)
	end

	local function Properties_GetPowerFormatted(Unit)
		return E:readableNumber(UnitPower(Unit), 2)
	end

	local function Properties_GetPowerMax(Unit)
		return UnitPowerMax(Unit)
	end
	
	local function Properties_GetPowerMaxFormatted(Unit)
		return E:readableNumber(UnitPowerMax(Unit), 2)
	end

	local function Properties_GetPowerPct(Unit)
		local Max = UnitPowerMax(Unit)
		if Max > 0 then
			return E:Round((UnitPower(Unit) / Max) * 100, 2) .. "%%"
		else
			return ""
		end
	end
	
	-------------------------------------------
	
	local function Properties_GetName(Unit)
		return UnitName(Unit)
	end
	
	local function Properties_GetClass(Unit)
		if not UnitExists(Unit) then return nil end
		return (UnitSex(Unit) <= 2) and (LOCALIZED_CLASS_NAMES_MALE[select(2, UnitClass(Unit))]) or (LOCALIZED_CLASS_NAMES_FEMALE[select(2, UnitClass(Unit))])
	end
	
	local function Properties_GetClassification(Unit)
		if not UnitExists(Unit) then return nil end
		return Classifications[UnitClassification(Unit) or "normal"]
	end
	
	local RGIndex
	local function Properties_GetRaidGroup(Unit)
		RGIndex = UnitInRaid(Unit)
		if RGIndex then
			return select(3, GetRaidRosterInfo(RGIndex))
		end
		
		return ""
	end
	
	-------------------------------------------
	
	local function Properties_GetLevel(Unit)
		return UnitLevel(Unit)
	end
	
	local function Properties_GetLevelMax()
		return GetMaxPlayerLevel()
	end
	
	local function Properties_GetGuildName(Unit)
		return select(1, GetGuildInfo(Unit))
	end
	
	local function Properties_GetGuildRankName(Unit)
		return select(2, GetGuildInfo(Unit))
	end
	
	local function Properties_GetNewLine()
		return "\n"
	end
	
	
---------------------------------------------------------------------------------

----------------------------------------
-- Hardcoded escaped strings for better loading times
local Properties = {
	["health"] 				= {"%[health%]", Properties_GetHealth},						-- Returns the Units Health
	["health-formatted"] 	= {"%[health%-formatted%]", Properties_GetHealthFormatted},	-- Returns the Units Health formatted
	["health-pct"] 			= {"%[health%-pct%]", Properties_GetHealthPct},				-- Returns the Units Health Percentage
	["health-max"] 			= {"%[health%-max%]", Properties_GetHealthMax},				-- Returns the Units Max-Health
	["health-max-formatted"]= {"%[health%-max%-formatted%]", Properties_GetHealthMaxFormatted},	-- Returns the Units Max-Health formatted
	["power"] 				= {"%[power%]", Properties_GetPower},						-- Returns the Units Power
	["power-formatted"] 	= {"%[power%-formatted%]", Properties_GetPowerFormatted},	-- Returns the Units Power formatted
	["power-max"] 			= {"%[power%-max%]", Properties_GetPowerMax},				-- Returns the Units Max-Power
	["power-max-formatted"] = {"%[power%-max%-formatted%]", Properties_GetPowerMaxFormatted},	-- Returns the Units Max-Power formatted
	["power-pct"] 			= {"%[power%-pct%]", Properties_GetPowerPct},				-- Returns the Units Power Percentage
	["name"] 				= {"%[name%]", Properties_GetName},							-- Returns the Units Name
	["class"] 				= {"%[class%]", Properties_GetClass},						-- Returns the Units Class Name
	["classification"]		= {"%[classification%]", Properties_GetClassification},		-- Returns the Units Classification
	["raidgroup"] 			= {"%[raidgroup%]", Properties_GetRaidGroup},				-- Returns the Units Raid Group
	["level"] 				= {"%[level%]", Properties_GetLevel},						-- Returns the Units Level
	["level-max"] 			= {"%[level%-max%]", Properties_GetLevelMax},				-- Returns the currently possible Max-Level
	["guild-name"] 			= {"%[guild%-name%]", Properties_GetGuildName},				-- Returns the units guild name
	["guild-rank-name"] 	= {"%[guild%-rank%-name%]", Properties_GetGuildRankName},	-- Returns the units guild rank name
	
	["newline"] 			= {"%[newline%]", Properties_GetNewLine},					-- Creates a new line
}
-- Property Events we wanna listen to to automatically update values
-- No Event indicates that no event for this thing exists and simply should be updated on demand (target switch or such)
local Properties_Events = {
	["health"] 				= {"UNIT_HEALTH_FREQUENT"},
	["health-formatted"] 	= {"UNIT_HEALTH_FREQUENT"},
	["health-pct"] 			= {"UNIT_HEALTH_FREQUENT"},
	["health-max"] 			= {"UNIT_MAXHEALTH"},
	["health-max-formatted"]= {"UNIT_MAXHEALTH"},
	["power"] 				= {"UNIT_POWER_FREQUENT", "UNIT_DISPLAYPOWER"},
	["power-formatted"] 	= {"UNIT_POWER_FREQUENT", "UNIT_DISPLAYPOWER"},
	["power-pct"] 			= {"UNIT_POWER_FREQUENT", "UNIT_DISPLAYPOWER"},
	["power-max"] 			= {"UNIT_MAXPOWER", "UNIT_DISPLAYPOWER"},
	["power-max-formatted"] = {"UNIT_MAXPOWER", "UNIT_DISPLAYPOWER"},
	["name"] 				= {"UNIT_NAME_UPDATE", "UNIT_CONNECTION"},
	["class"] 				= {""},
	["classification"]		= {"UNIT_CLASSIFICATION_CHANGED"},
	["raidgroup"] 			= {"GROUP_ROSTER_UPDATE", "UPDATE_INSTANCE_INFO"},
	["level"] 				= {"UNIT_LEVEL"},
	["level-max"] 			= {"PLAYER_GUILD_UPDATE"},
	["guild-name"] 			= {"PLAYER_GUILD_UPDATE"},
	["guild-rank-name"] 	= {"PLAYER_GUILD_UPDATE"},
	--["faction"] 			= {"UPDATE_FACTION"},
	
	["newline"] 			= {""},
}
local Strings 	= {}
local Fonts 	= {}
----------------------------------------

local function TagFont_Update(self)
	self:SetText(E:ParseString(self.TagStr, self.TagUnit))
	
	-- Additional updating
	if self.PostUpdate then self:PostUpdate() end
end

local function EventHandler_OnEvent(self, event, unit)
	for _, Font in pairs(self.EventFrames[event]) do
		
		-- Check if event unit is for the current font
		if not unit or (unit and unit == Font.TagUnit) then
			TagFont_Update(Font)
		end
	end
end

local function EventHandler_UpdateEvents()
	
	-- Clear to be on the safe side
	EventHandler:UnregisterAllEvents()
	wipe(EventHandler.EventFrames)
	
	for _, Data in pairs(Fonts) do
		for _, Event in pairs(Data.Events) do
			if Event ~= "" then
				if not EventHandler:IsEventRegistered(Event) then
					EventHandler:RegisterEvent(Event)
				end
				
				if not EventHandler.EventFrames[Event] then
					EventHandler.EventFrames[Event] = {}
				end
				tinsert(EventHandler.EventFrames[Event], Data.Font)
			end
		end
	end
end

function E:RegisterTagFontPostUpdate(font, func)
	font.PostUpdate = func
end

-- Registers a font to automatically update on required events
function E:RegisterTagFont(font, str, unit)
	local Data = {}
	
	font.ForceUpdate 	= TagFont_Update
	font.TagStr 		= str
	font.TagUnit 		= unit
	
	Data.Font 	= font
	Data.Str 	= str
	Data.Unit 	= unit
	Data.Events = {}
	
	-- Write all required events for this Font
	for k, v in pairs(Properties) do
		-- Use pattern name to find property
		if match(str, v[1]) then
			-- Lookup key events
			for _, event in pairs(Properties_Events[k]) do
				-- Add event(s) to table
				tinsert(Data.Events, event)
			end
		end
	end
	
	self:RegisterString(str)
	tinsert(Fonts, Data)
	EventHandler_UpdateEvents()
end

 -- Registers a string for a cache-like system so we don't have to iterate through every possible property on every update
function E:RegisterString(str)
	if str and str ~= "" and not Strings[str] then
		Strings[str] = {}
		
		self:UpdateProperties(str)
	end
end

-- Caches the required properties to minimize the processing time on update
function E:UpdateProperties(str)
	if Strings[str] then
		wipe(Strings[str])
	end
	
	for k, v in pairs(Properties) do
		-- Use pattern name to find property
		if match(str, v[1]) then
			-- Add property key to cache
			tinsert(Strings[str], k)
		end
	end
end

-- The core of the string format parser
function E:ParseString(str, unit)
	if Strings[str] then
		for _, v in pairs(Strings[str]) do
			str = self:StringReplace(str, Properties[v][1], Properties[v][2](unit) or "n.A.")
		end
	else
		return "error"
	end
	
	return str
end

EventHandler:SetScript('OnEvent', EventHandler_OnEvent)

-- E:RegisterString(TestString)
-- E:ParseString(TestString, "player")
-- /run CUI:RegisterString("[health] / [max-health] - Group: [raidgroup]")
-- /run print(CUI:ParseString("[health] / [max-health] - Group: [raidgroup]", "player"))