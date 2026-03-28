local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF = E:LoadModules('Config', 'Unitframes')

-- @TODO: Profile Data needs a "restore default" button!
--[[----------------------------------------

	This CUI Module is responsible
	for all on-demand font text value updates
	
	Other things like a power-type based
	text-color have to be done externally
	for now.
	
--]]----------------------------------------

--------------------------------------------
local format				= string.format
local gmatch				= string.gmatch
local match					= string.match
local tinsert				= table.insert
local tremove				= table.remove
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
local UnitIsUnit			= UnitIsUnit
local UnitInRaid			= UnitInRaid
local GetRaidRosterInfo		= GetRaidRosterInfo
local GetGuildInfo			= GetGuildInfo
local UnitLevel				= UnitLevel
local GetMaxPlayerLevel		= GetMaxPlayerLevel
local UnitClassification	= UnitClassification
local LOCALIZED_CLASS_NAMES_MALE 	= LOCALIZED_CLASS_NAMES_MALE
local LOCALIZED_CLASS_NAMES_FEMALE 	= LOCALIZED_CLASS_NAMES_FEMALE
--------------------------------------------

local Classifications = { ["worldboss"] = "Worldboss", ["rareelite"] = "Rare-Elite", ["elite"] = "Elite", ["rare"] = "Rare", ["normal"] = "", ["trivial"] = "", ["minus"] = "" }
local EventHandler = CreateFrame('Frame', "CUI_TagFontEventFrame")
EventHandler.EventFrames = {}

---------------------------------------------------------------------------------
	
	-- Those getters ALWAYS must return something. Otherwise the parser below
	-- will be in big trouble!
	
	local function Properties_GetHealth(Unit)
		return UnitHealth(Unit) or 0
	end
	
	local function Properties_GetHealthFormatted(Unit)
		return E:readableNumber(Properties_GetHealth(Unit), 2) or 0
	end

	local function Properties_GetHealthMax(Unit)
		return UnitHealthMax(Unit) or 0
	end
	
	local function Properties_GetHealthMaxFormatted(Unit)
		return E:readableNumber(UnitHealthMax(Unit), 2) or 0
	end

	local function Properties_GetHealthPct(Unit)
		--local Max = UnitHealthMax(Unit)
		--if Max > 0 then
		--	return E:Round((UnitHealth(Unit) / Max) * 100, 2) .. "%%"
		--else
		--	return " "
		--end
		
		return format('%.2f %%', UnitHealthPercent(Unit, true, CurveConstants.ScaleTo100)) or " "
		--return format('%%.%df', UnitHealthPercent(Unit, true, ScaleTo100)) or " "
	end
	
	local MissingHealthFormat = "-%s"
	local function Properties_GetMissingHealth(Unit)
		local Diff = Properties_GetHealthMax(Unit) - Properties_GetHealth(Unit)
		if Diff > 0 then
			return format(MissingHealthFormat, Diff)
		else
			return " "
		end
	end
	
	local function Properties_GetMissingHealthFormatted(Unit)
		local Diff = Properties_GetHealthMax(Unit) - Properties_GetHealth(Unit)
		if Diff > 0 then
			return format(MissingHealthFormat, E:readableNumber(Diff))
		else
			return " "
		end
	end
	
	local function Properties_GetMissingHealthPct(Unit)
		local Max = UnitHealthMax(Unit)
		if Max > 0 then
			return format(MissingHealthFormat, E:Round(100 - ((UnitHealth(Unit) / Max) * 100), 2) .. "%%")
		else
			return " "
		end
		
		--return format(MissingHealthFormat, (100 - Properties_GetHealthPct(Unit)))
	end
	
	-------------------------------------------
	
	local function Properties_GetPower(Unit)
		return UnitPower(Unit) or 0
	end

	local function Properties_GetPowerFormatted(Unit)
		return E:readableNumber(UnitPower(Unit), 2) or 0
	end

	local function Properties_GetPowerMax(Unit)
		return UnitPowerMax(Unit) or 0
	end
	
	local function Properties_GetPowerMaxFormatted(Unit)
		return E:readableNumber(UnitPowerMax(Unit), 2) or 0
	end

	local function Properties_GetPowerPct(Unit)
		-- local Max = UnitPowerMax(Unit)
		-- -- @TODO: Move these out of this function, so we don't have to access the config all the time
		-- local AllowSmall = CO.db.global.tagFontRules.allowPercentageForSmallValues
		-- local UseThreshold = CO.db.global.tagFontRules.usePercentageThreshold
		-- local Threshold = CO.db.global.tagFontRules.percentageThreshold
		
		-- if Max > 0 and ((not AllowSmall and UnitPowerType(Unit) == 0) or AllowSmall) and ((UseThreshold and Max >= Threshold) or not UseThreshold) then
			-- return E:Round((UnitPowerPercent(Unit) / Max) * 100, 2) .. "%%"
		-- else
			-- return " "
		-- end
		
		return format('%.2f %%', UnitPowerPercent(Unit, nil, true, CurveConstants.ScaleTo100)) or " "
	end
	
	-------------------------------------------
	
	local function Properties_GetName(Unit)
		return UnitName(Unit) or " "
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
		
		return " "
	end
	
	-------------------------------------------
	
	local function Properties_GetLevel(Unit)
		return UnitLevel(Unit) or 0
	end
	
	local function Properties_GetLevelMax()
		return E.UNIT_MAXLEVEL or 0
	end
	
	local function Properties_GetLevelExceptMax(Unit)
		local Level = UnitLevel(Unit)
		
		if Level == E.UNIT_MAXLEVEL then
			return " "
		end
		return Level or 0
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
-- /dump string.gmatch("%[health%-max%-formatted%] %[health%-missing%]", "%[(.-+)%]")
----------------------------------------
-- Hardcoded escaped strings to make our lives easier (a lot)
local Properties = {
	["health"] 						= {"%[health%]", Properties_GetHealth},						-- Returns the Units Health
	["health-missing"] 				= {"%[health%-missing%]", Properties_GetMissingHealth},		-- Returns the Units missing Health
	["health-formatted"] 			= {"%[health%-formatted%]", Properties_GetHealthFormatted},	-- Returns the Units Health formatted
	["health-missing-formatted"]	= {"%[health%-missing%-formatted%]", Properties_GetMissingHealthFormatted}, -- Returns the Units missing Health
	["health-pct"] 					= {"%[health%-pct%]", Properties_GetHealthPct},				-- Returns the Units Health Percentage
	["health-missing-pct"]			= {"%[health%-missing%-pct%]", Properties_GetMissingHealthPct},	-- Returns the Units missing Health
	["health-max"] 					= {"%[health%-max%]", Properties_GetHealthMax},				-- Returns the Units Max-Health
	["health-max-formatted"]		= {"%[health%-max%-formatted%]", Properties_GetHealthMaxFormatted},	-- Returns the Units Max-Health formatted
	["power"] 						= {"%[power%]", Properties_GetPower},						-- Returns the Units Power
	["power-fast"] 					= {"%[power%]", Properties_GetPower},						-- Returns the Units Power
	["power-formatted"] 			= {"%[power%-formatted%]", Properties_GetPowerFormatted},	-- Returns the Units Power formatted
	["power-formatted-fast"] 		= {"%[power%-formatted%]", Properties_GetPowerFormatted},	-- Returns the Units Power formatted
	["power-max"] 					= {"%[power%-max%]", Properties_GetPowerMax},				-- Returns the Units Max-Power
	["power-max-formatted"] 		= {"%[power%-max%-formatted%]", Properties_GetPowerMaxFormatted},	-- Returns the Units Max-Power formatted
	["power-pct"] 					= {"%[power%-pct%]", Properties_GetPowerPct},				-- Returns the Units Power Percentage
	["power-pct-fast"] 				= {"%[power%-pct%]", Properties_GetPowerPct},				-- Returns the Units Power Percentage
	["name"] 						= {"%[name%]", Properties_GetName},							-- Returns the Units Name
	["class"] 						= {"%[class%]", Properties_GetClass},						-- Returns the Units Class Name
	["classification"]				= {"%[classification%]", Properties_GetClassification},		-- Returns the Units Classification
	["raidgroup"] 					= {"%[raidgroup%]", Properties_GetRaidGroup},				-- Returns the Units Raid Group
	["level"] 						= {"%[level%]", Properties_GetLevel},						-- Returns the Units Level
	["level-max"] 					= {"%[level%-max%]", Properties_GetLevelMax},				-- Returns the currently possible Max-Level
	["level-except-max"] 			= {"%[level%-except%-max%]", Properties_GetLevelExceptMax},	-- Returns the Units level, as long as it's not the maxlevel
	["guild-name"] 					= {"%[guild%-name%]", Properties_GetGuildName},				-- Returns the units guild name
	["guild-rank-name"] 			= {"%[guild%-rank%-name%]", Properties_GetGuildRankName},	-- Returns the units guild rank name
	
	["newline"] 					= {"%[newline%]", Properties_GetNewLine},					-- Creates a new line
}
-- Property Events we wanna listen to to automatically update values
-- No Event indicates that no event for this thing exists and simply should be updated on demand
local Properties_Events = {
	["health"] 						= {"UNIT_HEALTH"},
	["health-missing"] 				= {"UNIT_HEALTH", "UNIT_MAXHEALTH"},
	["health-formatted"] 			= {"UNIT_HEALTH"},
	["health-missing-formatted"] 	= {"UNIT_HEALTH", "UNIT_MAXHEALTH"},
	["health-pct"] 					= {"UNIT_HEALTH"},
	["health-missing-pct"] 			= {"UNIT_HEALTH", "UNIT_MAXHEALTH"},
	["health-max"] 					= {"UNIT_MAXHEALTH"},
	["health-max-formatted"]		= {"UNIT_MAXHEALTH"},
	["power"] 						= {"UNIT_POWER_UPDATE", "UNIT_DISPLAYPOWER"},
	["power-fast"] 					= {"UNIT_POWER_FREQUENT", "UNIT_DISPLAYPOWER"},
	["power-formatted"] 			= {"UNIT_POWER_UPDATE", "UNIT_DISPLAYPOWER"},
	["power-formatted-fast"] 		= {"UNIT_POWER_FREQUENT", "UNIT_DISPLAYPOWER"},
	["power-pct"] 					= {"UNIT_POWER_UPDATE", "UNIT_DISPLAYPOWER"},
	["power-pct-fast"] 				= {"UNIT_POWER_FREQUENT", "UNIT_DISPLAYPOWER"},
	["power-max"] 					= {"UNIT_MAXPOWER", "UNIT_DISPLAYPOWER"},
	["power-max-formatted"] 		= {"UNIT_MAXPOWER", "UNIT_DISPLAYPOWER"},
	["name"] 						= {"UNIT_NAME_UPDATE", "UNIT_CONNECTION"},
	["class"] 						= {""},
	["classification"]				= {"UNIT_CLASSIFICATION_CHANGED"},
	["raidgroup"] 					= {"GROUP_JOINED", "GROUP_ROSTER_UPDATE", "UPDATE_INSTANCE_INFO"},
	["level"] 						= {"UNIT_LEVEL"},
	["level-max"] 					= {""},
	["level-except-max"] 			= {"UNIT_LEVEL"},
	["guild-name"] 					= {"PLAYER_GUILD_UPDATE"},
	["guild-rank-name"] 			= {"PLAYER_GUILD_UPDATE"},
	--["faction"] 					= {"UPDATE_FACTION"},
	
	["newline"] 					= {""},
}
local Strings 	= {}
local Fonts 	= {}
----------------------------------------

local function TagFont_Update(self)
	self:SetText(E:ParseString(self.TagStr, self.Owner.unit))
	
	-- Additional updating
	if self.PostUpdate then self:PostUpdate() end
end

local function TagFont_UpdateUnit(self, unit)
	self.TagUnit		= unit
	self.IsUnitGrouped 	= UF:IsUnitGrouped(unit)
	self:ForceUpdate()
end

local function ForceUpdateAllGroup()
	for _, Fonts in pairs(EventHandler.EventFrames) do
		for _, Font in pairs(Fonts) do
			if Font.Enable and Font.IsUnitGrouped and UnitExists(Font.Owner.unit) then
				TagFont_Update(Font)
			end
		end
	end
end

local function EventHandler_OnEvent(self, event, unit, ...)
	-- This is to prevent false values when first joining a group
	if event == 'GROUP_ROSTER_UPDATE' then
		ForceUpdateAllGroup(event, unit)
		return
	end
	
	for Key, Font in pairs(self.EventFrames[event]) do
		-- Check if event unit is for the current font
		--if Font.Enable then print(Font) end
		--if Font.Enable and not unit or (unit and ((Font.Owner.unit == unit or UnitIsUnit(Font.Owner.unit, unit)) and UnitExists(Font.Owner.unit))) then
		if Font.Enable then
			if Font.Owner.unit == unit and Font.Owner.Health:IsVisible() then
				--print(Font.Owner:GetName(), Font.Enable, Font:GetName())
				TagFont_Update(Font)
			end
		else
			-- Failsafe, should a font slip through the tinsert filter for some reason
			E:debugprint("Removing disabled font:", Font:GetName())
			-- Remove disabled font
			self.EventFrames[event][Key] = nil
		end
	end
end

local function EventHandler_UpdateEvents()
	
	-- Clear to be on the safe side
	EventHandler:UnregisterAllEvents()
	EventHandler:RegisterEvent('GROUP_ROSTER_UPDATE')
	wipe(EventHandler.EventFrames)
	
	for _, Data in pairs(Fonts) do
		if Data.Font.Enable then
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
		else
			E:debugprint("Skipping for Tag event handling: ", Data.Font:GetName())
		end
	end
end

function E:RebuildTagFontEventTable()
	EventHandler_UpdateEvents()
end

function E:RegisterTagFontPostUpdate(font, func)
	font.PostUpdate = func
end

local function FillFontData(Data, font, str, unit)
	Data.Font 		= font
	Data.Str 		= str
	Data.unit 		= unit
end

-- Registers a font to automatically update on required events
-- @PARAM1 (font): 		The font object to handle
-- @PARAM2 (string): 	A string with tags
-- @PARAM3 (string): 	The unit the handler should listen to
-- @PARAM4 (function): 	(Optional) A function to run after the main update

function E:RegisterTagFont(font, str, unit, postUpdate)
	
	local Data = {}
	
	font.ForceUpdate 	= TagFont_Update
	font.UpdateUnit 	= TagFont_UpdateUnit
	font.TagStr 		= str
	font.TagUnit 		= unit
	
	FillFontData(Data, font, str, unit)
	Data.Events = {}
	
	-- Only update when an actual function is passed to prevent nil-ing already set functions when updating the string
	if postUpdate then
		self:RegisterTagFontPostUpdate(font, postUpdate)
	end
	
	self:RegisterString(str)
	
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
	
	-- Check if object already was registered
	local IsUpdate = false
	for k,v in pairs(Fonts) do
		if v.Font == font then
			IsUpdate = true
			break
		end
	end

	-- Only refresh when this object already existed before
	-- else insert into managed objects
	if IsUpdate then
		font:ForceUpdate()
	else
		tinsert(Fonts, Data)
	end
	
	EventHandler_UpdateEvents()
end

function E:GetNumOfStrTagParts(str)
	return #E:SplitAt(str, '[')
end

function E:GetTagFunction(str)
	for k, v in pairs(Properties) do
		-- Use pattern name to find property
		if match(str, v[1]) then
			-- Lookup key events
			return Properties[k][2]
		end
	end 
end


-- oUF style prototype
--[[ local BracketPattern = '%[..-%]+'
local Data = {}
local tagstr = 'HP: [health][newline]Mana:[power]'
local FormatString = tagstr:gsub('%%', '%%%%'):gsub(BracketPattern, '%%s')

for bracket in tagstr:gmatch(BracketPattern) do
	print(bracket)
	table.insert(Data, #Data+1)
end

print(FormatString:format(unpack(Data))) ]]

 -- Registers a string for a cache-like system so we don't have to iterate through every possible property on every update
function E:RegisterString(str)
	if str and str ~= "" and not Strings[str] then
		Strings[str] = {}
		Strings[str].Data = {}
		Strings[str].NumOfParts = self:GetNumOfStrTagParts(str)
		Strings[str].Parts = {}
		local Parts = E:SplitAt(str, '[')
		
		for i, v in ipairs(Parts) do
			-- Write function ref to part, if it exists
			Strings[str].Parts[#Strings[str].Parts+1] = E:GetTagFunction(v)
			--Strings[str].Parts[#Strings[str].Parts+1] = Properties[v]
			
		end
		--E:print_r(Strings[str].Parts)
		
		--self:UpdateProperties(str)
	end
end

-- Caches the required properties to minimize the processing time on update
function E:UpdateProperties(str)
	if Strings[str] then
		wipe(Strings[str].Data)
	end
	
	for k, v in pairs(Properties) do
		-- Use pattern name to find property
		--if match(str, v[1]) then
			-- Add property key to cache
			--tinsert(Strings[str].Data, k)
		--end
	end
end

function E:UpdateAllTagFonts()
	for _, Data in pairs(Fonts) do
		TagFont_Update(Data.Font)
	end
end

-- The core of the string format parser
function E:ParseString(str, unit)
	local retStr = " "
	
	if Strings[str] then
		wipe(Strings[str].Data)
		for i, v in ipairs(Strings[str].Parts) do
			Strings[str].Data[i] = v(unit)
		end
		
		local Prev
		for i, v in ipairs(Strings[str].Data) do
			if v then
				-- WrapString NEEDS any value on each arg. Empty strings will result in it returning nil
				retStr = C_StringUtil.WrapString(retStr or " ", v, " ")
			end
		end
	else
		return "error"
	end
	
	return retStr
end

EventHandler:SetScript('OnEvent', EventHandler_OnEvent)
EventHandler:RegisterEvent('GROUP_ROSTER_UPDATE')

-- E:RegisterString(TestString)
-- E:ParseString(TestString, "player")
-- /run CUI[1]:RegisterString("[health] / [max-health] - Group: [raidgroup]")
-- /run print(CUI[1]:ParseString("[health] / [max-health] - Group: [raidgroup]", "player"))