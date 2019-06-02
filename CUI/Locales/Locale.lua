local E, L = unpack(select(2, ...)) -- Engine, Locale
local L, LOC_deDE, LOC_enUS = E:LoadModules("Locale", "Locale_deDE", "Locale_enUS")

local Locale = GetLocale()

function L:Init()
	if Locale == "enUS" then
		L = LOC_enUS
		
	elseif Locale == "deDE" then
		L = LOC_deDE
	elseif Locale == "enGB" then
		L = LOC_enUS
	else
		L = LOC_enUS -- More to come hopefully
	end
	
	-- CLASSES
	FillLocalizedClassList(L)
end

L:Init()

E:AddModule("Locale", L)