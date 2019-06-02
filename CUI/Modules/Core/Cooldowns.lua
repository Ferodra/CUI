local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, L = E:LoadModules("Config", "Locale")

--[[-------------------------------------------------
	
	This part of the CUI API is responsible
	to handle all user-defined number formats
	across the API
	
-------------------------------------------------]]--

---------------------------------------------------
local _
local format 					= string.format
local select 					= select
---------------------------------------------------

-- !IMPORTANT! - Ascending Threshold order
-- [Identifier/Name] -> {{Threshold = 0, Decimals = 1, ColorRGB, ColorHEX}, {Threshold = 1, Decimals = 0, ColorRGB, ColorHEX}}
local Cache = {}
local Paths = {}

-- Prepares the format for being used and caches the result.
-- This way, we just have to convert to HEX once.
-- [Data] can be a DB entry key in CO.db.profile.cooldowns
function E:CacheNumberFormat(Identifier, Data)
	if not Data and not CO.db.profile.numberFormats[Identifier] then return end
	
	local DataSet
	if not Data then
		Data = CO.db.profile.numberFormats[Identifier]
	end
	if not Data then return end
	
	for i = 1, #Data do
		DataSet = Data[i]
		
		-- Failsafe
		if not DataSet['ColorRGB'] then
			DataSet['ColorRGB'] = {1, 1, 1}
		end
		if not DataSet['Threshold'] then
			DataSet['Threshold'] = 0
		end
		if not DataSet['Decimals'] then
			DataSet['Decimals'] = 0
		end
		
		if DataSet['ColorRGB'] then
			DataSet['ColorHEX'] = E:RgbToHex(DataSet['ColorRGB'], true)
		end
		
		-- Failsafe
		DataSet.Threshold = tonumber(DataSet.Threshold)
	end
	
	-- Write to cache as copy so we don't write the HEX colors to the database
	Cache[Identifier] = E:TableDeepCopy(Data)
end

function E:RegisterNumberFormatDBPath(Path)
	if not Paths[Path] then
		Paths[Path] = true
	end
end

function E:RenameNumberFormat(Format, NewFormat)
	local Current
	for _, Path in pairs(Paths) do
		Current = E:GetTablePath(Path, CO)
		if Current == Format then
			Current = NewFormat
		end
	end
end

-- Actually writes the cooldown text to the specified frame
-- Is being used instead of SetText
function E:WriteNumberFormat(Font, Identifier, Value)
	if Identifier and Cache[Identifier] and #Cache[Identifier] > 0 then
		for i = 1, #Cache[Identifier] do
			-- If current DataSet should be used
			if Cache[Identifier][i].Threshold <= Value and (not Cache[Identifier][i+1] or (Cache[Identifier][i+1] and Cache[Identifier][i+1].Threshold >= Value)) then
				Font:SetText(format("|c%s%s|r", Cache[Identifier][i].ColorHEX, E:GetFloat(Value, Cache[Identifier][i].Decimals)))
			end
		end
	else
		Font:SetText(E:GetFloat(Value, 1))
	end
end












