local E, L = unpack(select(2, ...)) -- Engine, Locale

-- Key: Power ID
-- Value: Separated[true/false]
E.PowerTypesDisplayType = {
	[0]		=	false, -- MANA
	[1]		=	false, -- RAGE
	[2]		=	false, -- FOCUS
	[3]		=	false, -- ENERGY
	[4]		=	true, -- COMBO_POINTS
	[5]		=	true, -- RUNES
	[6]		=	false, -- RUNIC_POWER
	[7]		=	true, -- SOUL_SHARDS
	[8]		=	false, -- LUNAR_POWER
	[9]		=	true, -- HOLY_POWER
	[10]	=	false, -- ALTERNATE_POWER
	[11]	=	false, -- MAELSTROM
	[12]	=	true, -- CHI
	[13]	=	false, -- INSANITY
	[14]	=	false, -- OBSOLETE
	[15]	=	false, -- OBSOLETE2
	[16]	=	true, -- ARCANE_CHARGES
	[17]	=	false, -- FURY
	[18]	=	false, -- PAIN
	[30]	=	false, -- STAGGER
}