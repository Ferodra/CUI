---@class E, L
local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO = E:LoadModules("Config")

--[[-------------------------------------------------
	
	This part of the CUI API is responsible
	to handle all user-defined number formats
	across the API
	
-------------------------------------------------]]--

---------------------------------------------------
local _
local format 					= string.format
local pow 						= math.pow
local select 					= select
local tonumber 					= tonumber
---------------------------------------------------

-- !IMPORTANT! - Ascending Threshold order
-- [Identifier/Name] -> {{Threshold = 0, Decimals = 1, ColorRGB, ColorHEX}, {Threshold = 1, Decimals = 0, ColorRGB, ColorHEX}}
local Cache = {}
local Paths = {}

E.FormatTypesList = {
	["Time"] 				= "Time",
	["ActionbarCooldown"] 	= "Actionbar Cooldown",
}

-- Prepares the format for being used and caches the result.
-- This way, we just have to convert to HEX once.
-- [Data] can be a DB entry key in CO.db.profile.numberFormats
function E:CacheNumberFormat(Identifier, Data)
	if not Data and not CO.db.profile.numberFormats[Identifier] then return end
	
	local DataSet = {}
	Data = Data or CO.db.profile.numberFormats[Identifier]
	
	if not Data then return end
	
	for i = 1, #Data do		
		if not Data[i]['Threshold'] then Data[i]['Threshold'] = 0 end
		if not Data[i]['Decimals'] then Data[i]['Decimals'] = 0 end
		if not Data[i]['ColorRGB'] then Data[i]['ColorRGB'] = {1, 1, 1} end
		
		if not DataSet[i] then DataSet[i] = {} end
		DataSet[i]['Threshold'] = Data[i]['Threshold']
		DataSet[i]['Decimals'] 	= Data[i]['Decimals']
		DataSet[i]['ColorHEX'] 	= E:RgbToHex(Data[i]['ColorRGB'], true)
		
		-- Failsafe
		DataSet[i].Threshold = tonumber(DataSet[i].Threshold)
	end
	
	DataSet.formatType = Data.formatType
	
	-- Write to cache as copy so we don't write the HEX colors to the database
	Cache[Identifier] = E:TableDeepCopy(DataSet)
end

function E:RegisterNumberFormatDBPath(Path)
	if not Paths[Path] then
		Paths[Path] = true
	end
end

function E:RenameNumberFormat(Name, NewName)
	local Current
	for _, Path in pairs(Paths) do
		Current = E:GetTableByPath(Path, CO)
		if Current == Name then
			Current = NewName
		end
	end
end

function E:GetAvailableNumberFormats()
	local Formats = {}
		
	for name, _ in pairs(CO.db.profile.numberFormats) do
		Formats[name] = name
	end
	
	Formats[-1] = "None"
	
	return Formats
end

function E:RebuildNumberFormatCache()
	wipe(Cache)
	
	for identifier, data in pairs(CO.db.profile.numberFormats) do
		E:CacheNumberFormat(identifier, data)
	end
end

function E:GetNumberFormatNextUpdate(places)
	return 1 / pow(10, places)
end

-- Returns the current index to be used for the given value
local function GetCacheIndex(Identifier, Value)
	for i = 1, #Cache[Identifier] do
		-- If current DataSet should be used
		if Cache[Identifier][i].Threshold <= Value and (not Cache[Identifier][i+1] or (Cache[Identifier][i+1] and Cache[Identifier][i+1].Threshold >= Value)) then
			return i
		end
	end
end

-- Actually writes the formatted number to the specified font object
-- Is being used instead of SetText
-- Returns the amount of time when the next update should be performed
function E:WriteNumberFormat(Font, Identifier, Value, OverrideText)
	if Identifier and Cache[Identifier] and #Cache[Identifier] > 0 then
		local Index = GetCacheIndex(Identifier, Value)
		
		if Cache[Identifier].formatType == 'ActionbarCooldown' then
			Font:SetText(format("|c%s%s|r", Cache[Identifier][Index].ColorHEX, OverrideText or (E:GetFormattedCooldownTime(Value, Cache[Identifier][Index].Decimals))))
		else
			Font:SetText(format("|c%s%s|r", Cache[Identifier][Index].ColorHEX, OverrideText or (E:GetFloat(Value, Cache[Identifier][Index].Decimals))))
		end
		
		return E:GetNumberFormatNextUpdate(Cache[Identifier][Index].Decimals)
	else
		Font:SetText(E:GetFloat(Value, 1))
		return 0.075
	end
	
	-- Failsafe
	return 1
end