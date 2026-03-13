---@class E, L
local E, L = unpack(select(2, ...)) -- Engine, Locale
---@class CO
local CO = E:LoadModules("Config")

-- Goes into in CO.db.char
-- Table has the same structure as the main profile table!
function CO:GetCharacterDefaults()
	local defaults = {
		['auras'] = {
			['generalAurabars'] = {
				['useMasque'] = false,
			},
		},
		['bags'] = {
			['useMasque'] = false,
		},
		['blizzard'] = {
			['chatBubbles'] = {
				['enable'] = true,
			},
			['useGameplayFeatureMovers'] = false,
		},
		['CVars'] = {
			['overrideSpellQueueWindow'] = false,
			['spellQueueWindow'] = 400,
		},
		['actionbar'] = {
			['enable'] = true,
			['useMasque'] = false,
		},
		['unitframe'] = {
			['enable'] = false,
			['unitBuffs'] = {
				['useMasque'] = false,
			},
			['unitDebuffs'] = {
				['useMasque'] = false,
			},
			['buffs'] = {
				['useMasque'] = false,
			},
			['debuffs'] = {
				['useMasque'] = false,
			},
		},
		['nameplates'] = {
			['enable'] = false,
		},
		['minimap'] = {
			['enable'] = false,
		}
	}
	
	return defaults
end