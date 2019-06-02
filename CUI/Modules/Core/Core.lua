local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, CORE = E:LoadModules("Config", "Core")

--[[-----------
	Number Suffix
-----------]]--

function CORE:InitNumberSuffix()
	E.NumberFormatSuffix = CO.db.global.numberFormat
	
	if E.NumberFormatSuffix == "METRIC" then
		E.NumberFormatFunc = E.FormatNumber_Metric
	elseif E.NumberFormatSuffix == "GERMAN" then
		E.NumberFormatFunc = E.FormatNumber_German
	elseif E.NumberFormatSuffix == "ENGLISH" then
		E.NumberFormatFunc = E.FormatNumber_English
	elseif E.NumberFormatSuffix == "CHINESE" then
		E.NumberFormatFunc = E.FormatNumber_Chinese
	elseif E.NumberFormatSuffix == "KOREAN" then
		E.NumberFormatFunc = E.FormatNumber_Korean
	else
		E.NumberFormatFunc = E.FormatNumber_Metric
	end
end

function CORE:LoadProfile()
	self:InitNumberSuffix()
end

function CORE:Init()
	self:LoadProfile()
end

E:AddModule("Core", CORE)