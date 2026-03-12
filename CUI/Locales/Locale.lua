local E = select(2, ...) -- Engine

local Locale = GetLocale()

do 
	E[2] = E[1].Libs.AceLocale:GetLocale('CUI', Locale)
	
	local L = E[2]
	
	-- Additional strings
	L["VisibilityDesc_FULL"] = L["VisibilityDesc"] .. "\n[pet] [petbattle] [combat] [vehicle] [flying] [form:N] [stealth]\n\n\n" .. L["VisibilityDescSec"] .. " https://wow.gamepedia.com/Macro_conditionals"
end