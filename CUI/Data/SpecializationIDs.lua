---@class E, L
local E, L = unpack(select(2, ...)) -- Engine, Locale

-- All current Spec IDs for easy reference in config environment
E.SpecializationIDs = {
	['MAGE'] = {
		['ARCANE']			=	62,
		['FIRE']			=	63,
		['FROST']			=	64,
	},
	['PALADIN'] = {
		['HOLY']			=	65,
		['PROTECTION']		=	66,
		['RETRIBUTION']		=	67,
	},
	['WARRIOR'] = {
		['ARMS']			=	71,
		['FURY']			=	72,
		['PROTECTION']		=	73,
	},
	['DRUID'] = {
		['BALANCE']			=	102,
		['FERAL']			=	103,
		['GUARDIAN']		=	104,
		['RESTORATION']		=	105,
	},
	['DEATHKNIGHT'] = {
		['BLOOD']			=	250,
		['FROST']			=	251,
		['UNHOLY']			=	252,
	},
	['HUNTER'] = {
		['BEAST MASTERY']	=	253,
		['MARKSMANSHIP']	=	254,
		['SURVIVAL']		=	255,
	},
	['PRIEST'] = {
		['DISCIPLINE']		=	256,
		['HOLY']			=	257,
		['SHADOW']			=	258,
	},
	['ROGUE'] = {
		['ASSASSINATION']	=	259,
		['OUTLAW']			=	260,
		['SUBTLETY']		=	261,
	},
	['SHAMAN'] = {
		['ELEMENTAL']		=	262,
		['ENHANCEMENT']		=	263,
		['RESTORATION']		=	264,
	},
	['WARLOCK'] = {
		['AFFLICTION']		=	265,
		['DEMONOLOGY']		=	266,
		['DESTRUCTION']		=	267,
	},
	['MONK'] = {
		['BREWMASTER']		=	268,
		['WINDWALKER']		=	269,
		['MISTWEAVER']		=	270,
	},
	['DEMONHUNTER'] = {
		['HAVOC']			=	577,
		['VENGEANCE']		=	578,
	},
}