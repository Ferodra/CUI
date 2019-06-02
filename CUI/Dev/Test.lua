local E, L = unpack(select(2, ...)) -- Engine, Locale
-- General testing file for snippets etc

local function Test()
	
end

local function Debug()
	if E.Debug then
		Test()
	else
		E:print("Debug mode is disabled!")
	end
end

SlashCmdList.CUI_DEVTEST = Debug