local E, L = unpack(CUI) -- Engine
local CO, CD = E:LoadModules("Config", "Config_Dialog")


CD.Options.args.character = {
	type = "group",
	name = '|cff1784d1' .. CHARACTER .. '|r',
	order = 2,
	childGroups = "tab",
	args = {
		wrapperGroup = {
			type = "group",
			name = 'Main',
			order = 0,
			childGroups = "tree",
			args = {
				note = {
					type = 'description',
					name = "|cff1784d1" .. L["CharacterWideNote"] .. "|r",
					order = 1,
				},
				useGlobal = {
					type = "toggle",
					order = 1,
					width = "full",
					name = "Use Globally",
					desc = "When enabled, character specific settings will instead be used globally (Global profile, meaning changing it on one char will change it on every other as well",
					get = function() return CO.db.global.useGlobalCharacterDB end,
					set = function(info, value) CO.db.global.useGlobalCharacterDB = value; CD:ShowNotification("RELOAD_NOTIFICATION") end,
				},
				actionbarGroup = {
					type = "group",
					name = L["Actionbars"],
					order = 5,
					args = {
						enable = {
							type = 'toggle',
							order = 0.1,
							name = L['EnableModule'],
							desc = 'Controls the state of the actionbar module. When disabled, you\'re just left with Blizzard actionbars and their textures etc.\n\nOn The upside, you then can use alternate AddOns like Bartender or Dominos to handle all actionbars.\n\nRequires a reload after enabling/disabling to take effect.\n\nThis is a character setting and is not being saved in your profile!',
							get = function(info) return CO.db.char.actionbar.enable end,
							set = function(info, value) CO.db.char.actionbar.enable = value; CD:ShowNotification('CHARACTERSETTING_NOTIFICATION') end,
						},
						enableOverride = {
							type = "toggle",
							order = 1,
							width = "full",
							name = "Override Spell Queue Window",
							desc = "When enabled, CUI override the Spell Queue Window CVar",
							get = function() return CO.db.char.CVars.overrideSpellQueueWindow end,
							set = function(info, value) CO.db.char.CVars.overrideSpellQueueWindow = value; if not value then CD:ShowNotification("CHARACTERSETTING_NOTIFICATION") end end,
						},
						spellQueue = {
							order = 2,
							type = 'range',
							name = 'Spell Queue Window',
							desc = 'Overrides WoW\'s time how long a used spell is being kept in a queue before executing when it becomes ready. Time is in milliseconds.\n\nNote: Default value is 400!',
							min = 0, max = 400, step = 1,
							width = "full",
							get = function() return CO.db.char.CVars.spellQueueWindow end,
							set = function(info, value) CO.db.char.CVars.spellQueueWindow = value; E:UpdateCVars(); end,
							hidden = function() return not CO.db.char.CVars.overrideSpellQueueWindow end,
						},
					},
				},
				blizzardGroup = {
					type = 'group',
					name = "Blizzard",
					order = 10,
					args = {
						useGameplayFeatureMovers = {
							type = "toggle",
							order = 1,
							name = "CUI Gameplay Feature Movers",
							get = function() return CO.db.char.blizzard.useGameplayFeatureMovers end,
							set = function(info, value) CO.db.char.blizzard.useGameplayFeatureMovers = value; CD:ShowNotification('CHARACTERSETTING_NOTIFICATION') end,
						},
					},
				},
				unitframeGroup = {
					type = 'group',
					name = L['Unitframes'],
					order = 12,
					args = {
						enable = {
							type = 'toggle',
							order = 1,
							name = L['EnableModule'],
							desc = 'Controls the state of the unitframe module. When disabled, you\'re just left with Blizzard unitframes and their textures etc.\n\nOn The upside, you then can use alternate unitframe AddOns to handle it all.\n\nRequires a reload after enabling/disabling to take effect.\n\nThis is a character setting and is not being saved in your profile!',
							get = function(info) return CO.db.char.unitframe.enable end,
							set = function(info, value) CO.db.char.unitframe.enable = value; CD:ShowNotification('CHARACTERSETTING_NOTIFICATION') end,
						},
					},
				},
				masqueGroup = {
					type = "group",
					name = "Masque",
					order = 15,
					args = {
						actionbars = {
							type = "toggle",
							order = 5,
							name = L["Actionbars"],
							desc = L["UseMasqueDesc"],
							get = function() return CO.db.char.actionbar.useMasque end,
							set = function(info, value) CO.db.char.actionbar.useMasque = value; CD:ShowNotification("CHARACTERSETTING_NOTIFICATION") end,
						},
						bags = {
							type = "toggle",
							order = 10,
							name = L["Bags"],
							desc = L["UseMasqueDesc"],
							get = function() return CO.db.char.bags.useMasque end,
							set = function(info, value) CO.db.char.bags.useMasque = value; CD:ShowNotification("CHARACTERSETTING_NOTIFICATION") end,
						},
						spacer_01 = {type='description',name='',order=14},
						aurasBuffs = {
							type = "toggle",
							order = 15,
							name = L["Buffs"],
							desc = L["UseMasqueDesc"],
							get = function() return CO.db.char.unitframe.buffs.useMasque end,
							set = function(info, value) CO.db.char.unitframe.buffs.useMasque = value; CD:ShowNotification("CHARACTERSETTING_NOTIFICATION") end,
						},
						aurasDebuffs = {
							type = "toggle",
							order = 20,
							name = L["Debuffs"],
							desc = L["UseMasqueDesc"],
							get = function() return CO.db.char.unitframe.debuffs.useMasque end,
							set = function(info, value) CO.db.char.unitframe.debuffs.useMasque = value; CD:ShowNotification("CHARACTERSETTING_NOTIFICATION") end,
						},
						spacer_02 = {type='description',name='',order=24},
						unitBuffs = {
							type = "toggle",
							order = 25,
							name = L["unit"] .. " " .. L["Buffs"],
							desc = L["UseMasqueDesc"],
							get = function() return CO.db.char.unitframe.unitBuffs.useMasque end,
							set = function(info, value) CO.db.char.unitframe.unitBuffs.useMasque = value; CD:ShowNotification("CHARACTERSETTING_NOTIFICATION") end,
						},
						unitDebuffs = {
							type = "toggle",
							order = 30,
							name = L["unit"] .. " " .. L["Debuffs"],
							desc = L["UseMasqueDesc"],
							get = function() return CO.db.char.unitframe.unitDebuffs.useMasque end,
							set = function(info, value) CO.db.char.unitframe.unitDebuffs.useMasque = value; CD:ShowNotification("CHARACTERSETTING_NOTIFICATION") end,
						},
						spacer_03 = {type='description',name='',order=34},
						aurabars = {
							type = "toggle",
							order = 35,
							name = L["Aura Bars"],
							desc = L["UseMasqueDesc"],
							get = function() return CO.db.char.auras.generalAurabars.useMasque end,
							set = function(info, value) CO.db.char.auras.generalAurabars.useMasque = value; CD:ShowNotification("CHARACTERSETTING_NOTIFICATION") end,
						},
					},
				},
				nameplateGroup = {
					type = "group",
					name = L["Nameplates"],
					order = 20,
					args = {
						CVarHeader = {
							type = "header",
							order = 0,
							name = L["CVars"],
						},
						showPlayerNameplate = {
							type = "toggle",
							order = 1,
							name = DISPLAY_PERSONAL_RESOURCE,
							desc = L["Personal Nameplate Desc"] .. " " .. L["CVarsDesc"],
							get = function() return E:GetBlizzCVar("nameplateShowSelf", true) end,
							set = function(info, value) CO.db.profile.CVars.nameplateShowSelf = value; SetCVar("nameplateShowSelf", value, DISPLAY_PERSONAL_RESOURCE) end,
						},
						nameplateShowAll = {
							type = "toggle",
							order = 2,
							name = UNIT_NAMEPLATES_AUTOMODE,
							desc = L["ShowAllNameplatesDesc"] .. " " .. L["CVarsDesc"],
							get = function() return E:GetBlizzCVar("nameplateShowAll", true) end,
							set = function(info, value) CO.db.profile.CVars.nameplateShowAll = value; SetCVar("nameplateShowAll", value, "UNIT_NAMEPLATES_AUTOMODE") end,
						},
						
						ModuleHeader = {
							type = "header",
							order = 10,
							name = L["General"],
						},
						enableOverride = {
							type = "toggle",
							order = 11,
							name = L["EnableModule"],
							desc = "When enabled, CUI will handle most of the nameplate functionality",
							get = function() return CO.db.char.nameplates.enable end,
							set = function(info, value) CO.db.char.nameplates.enable = value; CD:ShowNotification("CHARACTERSETTING_NOTIFICATION") end,
						},
					},
				},
				
				mapGroup = {
					type = 'group',
					name = L["Maps"],
					order = 25,
					args = {
						minimapHeader = {
							type = "header",
							order = 0,
							name = L["Minimap"],
						},
						enable = {
							type = "toggle",
							order = 1,
							name = L['EnableModule'],
							get = function() return CO.db.char.minimap.enable end,
							set = function(info, value) CO.db.char.minimap.enable = value; CD:ShowNotification('CHARACTERSETTING_NOTIFICATION') end,
						},
					},
				},

				playerAuraGroup = {
					type = 'group',
					name = L["Buffs and Debuffs"],
					order = 30,
					args = {
						enable = {
							type = "toggle",
							order = 1,
							name = L['EnableModule'],
							desc = 'Controls the state of this module. When disabled, you\'re just left with Blizzard frames instead of customizable ones.',
							get = function() return CO.db.char.auras.playerAuras.enable end,
							set = function(info, value) CO.db.char.auras.playerAuras.enable = value; CD:ShowNotification("CHARACTERSETTING_NOTIFICATION") end,
						},
					},
				},
			},
		},
	},
}