local E, L = unpack(select(2, ...)) -- Engine, Locale

E.PowerColors = {
	[0]		=	{0.00,0.44,0.87}, 	-- Mana
	[1]		=	{1,0,0}, 			-- Rage
	[2]		=	{1,0.5,0.25}, 		-- Focus
	[3]		=	{1,1,0}, 			-- Energy
	[4]		=	{1,0.96,0.41}, 		-- Combo Points
	[5]		=	{0.5,0.5,0.5}, 		-- Runes
	[6]		=	{0,0.82,1}, 		-- Runic Power
	[7]		=	{0.5,0.32,0.55},	-- Soul Shards
	[8]		=	{0.3,0.52,0.9}, 	-- Lunar Power
	[9]		=	{0.95,0.9,0.6}, 	-- Holy Power
	[10]	=	{0.8,0.6,0}, 		-- Ammo Slot (Probably Vehicles)
	[11]	=	{0,0.5,1}, 			-- Maelstrom
	[12]	=	{0.71,1,00.92}, 	-- Chi
	[13]	=	{0.4,0,0.8}, 		-- Insanity
	[16]	=	{0.1,0.1,0.98}, 	-- Arcane Charges
	[17]	=	{0.788,0.259,0.992},-- Fury
	[18]	=	{1,0.61,0}, 		-- Pain
	[30]	=	{
					["light"] = {0, 0.7, 0},
					["medium"] = {0.7, 0.7, 0},
					["heavy"] = {0.7, 0, 0},
				}, 					-- Stagger
	[31]	=	{0.77, 0.12, 0.23}, -- Rune Ready
	[32]	=	{0.15, 0.15, 0.15} 	-- Rune Not Ready
}