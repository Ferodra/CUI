---@class E, L
local E, L = unpack(select(2, ...)) -- Engine, Locale
---@class CO
local CO = E:LoadModules("Config")

-- Goes into CO.db.global
function CO:GetGlobalDefaults()
	local defaults = {
		['accountData'] = {
			['timePlayed'] = {
				['enable'] = true,
				['total'] = 0
			},
			['armory'] = {
				['enable'] = true,
			},
			['characters'] = {}, -- Stores individual characters
		},
		['itemDB'] = {
			['enable'] = true,
			['data'] = {
				['WARBANK'] = {},
			},
		},
		['misc'] = {
			['collectionsShowHelmet'] = true,
		},
		['utility'] = {
			
		},
		['blizzard'] = {
			
		},
		['communication'] = {
			['autoCheckVersion'] = true,
		},
		['chat'] = {
			['clearInputFocusOnClick'] = false,
		},
		['tagFontRules'] = {
			['allowPercentageForSmallValues'] = false,
			['usePercentageThreshold'] = true,
			['percentageThreshold'] = 200000,
		},
		['numberFormat'] = 'METRIC',
		['revertCVarsOnDisable'] = true,
		['customArmory'] = {
			['enabled'] = true,
			['overrideBackground'] = true,
			['classBackground'] = 'PLAYER_CLASS',
			['showItemlevel'] = true,
			['showEnchants'] = true,
			['showGems'] = true,
			['useCustomBackground'] = false,
			['customBackgroundPath'] = [[Interface/AddOns/CUI/Textures/]],
		},
		['colors'] = {
			['units'] = {},
		},
		['filters'] = {
			['auras'] = {
				[1] = {
					['name'] = 'Aurabars Whitelist',
					['type'] = 1,
					['isProtected'] = true,
					['entries'] = {},
				},
				[2] = {
					['name'] = 'Aurabars Blacklist',
					['type'] = 2,
					['isProtected'] = true,
					['entries'] = {},
				},
				[3] = {
					['name'] = 'Raid Debuffs Whitelist',
					['type'] = 1,
					['isProtected'] = true,
					['entries'] = {
						[57723] = {["enabled"] = true},
						[80354] = {["enabled"] = true},
						[264689] = {["enabled"] = true},
						
						[298425] = {["enabled"] = true},
						[303672] = {["enabled"] = true},
						[297333] = {["enabled"] = true},
						[292133] = {["enabled"] = true},
						[294715] = {["enabled"] = true},
						[302999] = {["enabled"] = true},
						[292971] = {["enabled"] = true},
						[294711] = {["enabled"] = true},
						[298164] = {["enabled"] = true},
						[292127] = {["enabled"] = true},
						[298242] = {["enabled"] = true},
						[298569] = {["enabled"] = true},
						[295444] = {["enabled"] = true},
						[299575] = {["enabled"] = true},
						[292307] = {["enabled"] = true},
						[303227] = {["enabled"] = true},
						[301830] = {["enabled"] = true},
						[293509] = {["enabled"] = true},
						[297564] = {["enabled"] = true},
						[297586] = {["enabled"] = true},
						[292138] = {["enabled"] = true},
						[297656] = {["enabled"] = true},
						[299914] = {["enabled"] = true},
						[298156] = {["enabled"] = true},
						[296944] = {["enabled"] = true},
						[295779] = {["enabled"] = true},
						[296746] = {["enabled"] = true},
						[296566] = {["enabled"] = true},
					},
				},
			},
		},
	}
	
	return defaults
end