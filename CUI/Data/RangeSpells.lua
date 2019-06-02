local E, L = unpack(select(2, ...)) -- Engine, Locale

E.RangeSpells = {
	["DRUID"] = {
		["enemy"] = {
			8921, -- Moonfire
		},
		["friendly"] = {
			8936, -- Regrowth
		},
		["resurrect"] = {
			50769, -- Resurrect
		},
		["pet"] = {},
	},
	["MAGE"] = {
		["enemy"] = {
			118, -- Polymorph
			116, -- Frostbolt
			133, -- Fireball
			30451, -- Arcane Strike
		},
		["friendly"] = {
			130, -- Slow Fall
		},
		["resurrect"] = {},
		["pet"] = {},
	},
	["SHAMAN"] = {
		["enemy"] = {
			187837, -- Lightning Bolt
			188196, -- Lightning Bolt
			403, -- Lightning Bolt
		},
		["friendly"] = {
			188070, -- Healing Surge
			8004, -- Healing Surge
		},
		["resurrect"] = {
			2008, -- Ancient Spirits
		},
		["pet"] = {},
	},
	["PALADIN"] = {
		["enemy"] = {
			20473, -- Holy Shock
			20271, -- Judgement
			62124, -- Hand of Reckoning
		},
		["friendly"] = {
			19750, -- Flash of Light
			633, -- Lay on Hands
		},
		["resurrect"] = {
			7328, -- Redemption
		},
		["pet"] = {},
	},
	["DEATHKNIGHT"] = {
		["enemy"] = {
			49576, -- Death Grip
			47541, -- Death Coil
		},
		["friendly"] = {},
		["resurrect"] = {
			61999, -- Raise Ally
		},
		["pet"] = {},
	},
	["HUNTER"] = {
		["enemy"] = {
			75, -- Auto Shot
		},
		["friendly"] = {},
		["resurrect"] = {},
		["pet"] = {
			982, -- Mend Pet
		},
	},
	["PRIEST"] = {
		["enemy"] = {
			585, -- Smite
			589, -- Shadow Word: Pain
		},
		["friendly"] = {
			2061, -- Flash Heal
			17, -- Power Word: Shield
		},
		["resurrect"] = {
			2006, -- Resurrect
		},
		["pet"] = {},
	},
	["DEMONHUNTER"] = {
		["enemy"] = {
			183752, -- Consume Magic
			185123, -- Throw Glaive
			204021, -- Fiery Brand
		},
		["friendly"] = {},
		["resurrect"] = {},
		["pet"] = {},
	},
	["WARRIOR"] = {
		["enemy"] = {
			355, -- Taunt
			100, -- Charge
		},
		["friendly"] = {
			198304, -- Intercept
		},
		["resurrect"] = {},
		["pet"] = {},
	},
	["ROGUE"] = {
		["enemy"] = {
			1725, -- Distract
		},
		["friendly"] = {
			57934, -- Tricks of Trade
		},
		["resurrect"] = {},
		["pet"] = {},
	},
	["MONK"] = {
		["enemy"] = {
			117952, -- Crackling Jade Lightning
		},
		["friendly"] = {
			116670, -- Vivify
		},
		["resurrect"] = {
			115178, -- Resuscitate
		},
		["pet"] = {},
	},
	["WARLOCK"] = {
		["enemy"] = {
			234153, -- Drain Life
		},
		["friendly"] = {
			20707, -- Soul Stone
		},
		["resurrect"] = {
			20707, -- Soul Stone
		},
		["pet"] = {
			755, -- Health Funnel
		},
	},
}