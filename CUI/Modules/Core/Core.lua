local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, CORE = E:LoadModules("Config", "Core")

--[[-----------
	Number Suffix
-----------]]--

function CORE:InitNumberSuffix()
	local DBSuffix = CO.db.global.numberFormat
	
	if DBSuffix == "METRIC" then
		E.NumberFormatFunc = E.FormatNumber_Metric
	elseif DBSuffix == "GERMAN" then
		E.NumberFormatFunc = E.FormatNumber_German
	elseif DBSuffix == "ENGLISH" then
		E.NumberFormatFunc = E.FormatNumber_English
	elseif DBSuffix == "CHINESE" then
		E.NumberFormatFunc = E.FormatNumber_Chinese
	elseif DBSuffix == "KOREAN" then
		E.NumberFormatFunc = E.FormatNumber_Korean
	else
		E.NumberFormatFunc = E.FormatNumber_Metric
	end
	
	E.NumberFormatSuffix = DBSuffix
end

function CORE:LoadConfig()
	self:InitNumberSuffix()
end

function CORE:Init()
	self:LoadConfig()
	
	E.PlayerName = UnitName('player')
end

E:AddModule("Core", CORE)