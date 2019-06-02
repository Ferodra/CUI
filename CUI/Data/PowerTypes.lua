local E, L = unpack(select(2, ...)) -- Engine, Locale

-- Key: Power ID
-- Value: Power Name
E.PowerTypes = {
	[0]		=	"MANA",
	[1]		=	"RAGE",
	[2]		=	"FOCUS",
	[3]		=	"ENERGY",
	[4]		=	"COMBO_POINTS",
	[5]		=	"RUNES",
	[6]		=	"RUNIC_POWER",
	[7]		=	"SOUL_SHARDS",
	[8]		=	"LUNAR_POWER",
	[9]		=	"HOLY_POWER",
	[10]	=	"ALTERNATE_POWER",
	[11]	=	"MAELSTROM",
	[12]	=	"CHI",
	[13]	=	"INSANITY",
	[14]	=	"OBSOLETE",
	[15]	=	"OBSOLETE2",
	[16]	=	"ARCANE_CHARGES",
	[17]	=	"FURY",
	[18]	=	"PAIN",
	[30]	=	"STAGGER",
	[31]	=	"RUNE_READY",
	[32]	=	"RUNE_NOT_READY",
}