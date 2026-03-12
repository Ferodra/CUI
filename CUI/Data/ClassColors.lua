local E, L = unpack(select(2, ...)) -- Engine, Locale

-- Default class colors that are being used as profile default values
E.ClassColors = {
	[0] 	= {0.00, 0.00, 0.00},	-- No class at all
	[1] 	= {0.78, 0.61, 0.43},	-- Warrior
	[2] 	= {0.96, 0.55, 0.73},	-- Paladin
	[3] 	= {0.67, 0.83, 0.45},	-- Hunter
	[4] 	= {1.00, 0.96, 0.41},	-- Rogue
	[5] 	= {1.00, 1.00, 1.00},	-- Priest
	[6] 	= {0.77, 0.12, 0.23},	-- DeathKnight
	[7] 	= {0.00, 0.44, 0.87},	-- Shaman
	[8] 	= {0.41, 0.80, 0.94},	-- Mage
	[9] 	= {0.58, 0.51, 0.79},	-- Warlock
	[10] 	= {0.33, 1.00, 0.52},	-- Monk
	[11] 	= {1.00, 0.49, 0.04},	-- Druid
	[12] 	= {0.64, 0.19, 0.79},	-- DemonHunter
	[13] 	= {0.20, 0.58, 0.50},	-- Evoker
}

-- Used to resolve class names as how they are returned by some functions [GetPlayerInfoByGUID]
E.ClassIDByName = {
	["WARRIOR"] 	= 1,
	["PALADIN"] 	= 2,
	["HUNTER"] 		= 3,
	["ROGUE"] 		= 4,
	["PRIEST"] 		= 5,
	["DEATHKNIGHT"] = 6,
	["SHAMAN"] 		= 7,
	["MAGE"] 		= 8,
	["WARLOCK"] 	= 9,
	["MONK"] 		= 10,
	["DRUID"] 		= 11,
	["DEMONHUNTER"] = 12,
	["EVOKER"] 		= 13
}