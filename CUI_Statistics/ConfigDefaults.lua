local E, L = unpack(CUI) -- Engine
local CO = E:LoadModules("Config")
local ST = select(2, ...)

ST.ConfigDefaults = {
	global = {
		['timePlayed'] = {
			['enable'] = true,
			['total'] = 0
		},
		['armory'] = {
			['enable'] = true,
		},
		['characters'] = {}, -- Stores individual characters
	},
}

