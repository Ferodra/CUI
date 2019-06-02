local E, L = unpack(CUI) -- Engine
local CO, CD, L = E:LoadModules("Config", "Config_Dialog", "Locale")

local NUMBER_FORMATS = {
	["METRIC"] = "Metric (K, M, G, T)",
	["ENGLISH"] = "English (K, M, B, T)",
	["GERMAN"] = "German (Tsd, Mio, Mrd, Bio)",
	["KOREAN"] = "Korean (천, 만, 억)",
	["CHINESE"] = "Chinese (W, Y)",
}

local BackgroundClasses = {['PLAYER_CLASS'] = '<<Your Current Class>>'}
FillLocalizedClassList(BackgroundClasses)

-- Colorize class selection
do
	local Hex, Color, RGB
	for k, v in pairs(BackgroundClasses) do
		if CO.db.profile.colors.classes[k] then
			Color = CO.db.profile.colors.classes[k]
			RGB = {Color[1], Color[2], Color[3]}
			
			Hex = E:RgbToHex(RGB, true)
		else
			Hex = E:RgbToHex(E:GetUnitReactionColor("player", false), true)
		end
		
		BackgroundClasses[k] = string.format("|c%s%s|r", Hex, v)
	end
end

CD.Options.args.global = {
	type = "group",
	name = L["Global"],
	order = 1,
	childGroups = "tab",
	args = {
		generalGroup = {
			type = "group",
			name = L["General"],
			order = 1,
			args = {
				autoCheckVersion = {
					type = "toggle",
					order = 21,
					name = "Check Version",
					desc = "When enabled, CUI will periodically check if a new version is available.\n\nNOTE: This is a global setting and is not being saved in your character profile!",
					get = function() return CO.db.global.communication.autoCheckVersion end,
					set = function(info, value) CO.db.global.communication.autoCheckVersion = value; E:GetModule("Communication"):UpdateVersionCheck(); end,
				},
				numberFormat = {
					name = "Number Format",
					type = "select",
					order = 22,
					values = NUMBER_FORMATS,
					get = function(info) return CO.db.global.numberFormat end,
					set = function(info, value) CO.db.global.numberFormat = value; CD:ShowNotification("RELOAD_NOTIFICATION") end,
				},
			},
		},
		
		armoryGroup = {
			type = "group",
			name = "Armory",
			order = 2,
			args = {
				customArmory = {
					type = "toggle",
					order = 9,
					width = "full",
					name = "Custom Armory",
					desc = "When enabled, CUI will add various information next to each gear slot in the armory frame. This controls the inspect frame as well as your own character panel",
					get = function() return CO.db.profile.customArmory end,
					set = function(info, value) CO.db.profile.customArmory = value; CD:ShowNotification("RELOAD_NOTIFICATION") end,
				},
				customArmoryShowItemlevel = {
					type = "toggle",
					order = 10,
					name = L["Armory Itemlevel"],
					desc = L["Armory Itemlevel Desc"],
					get = function() return CO.db.profile.customArmoryShowItemlevel end,
					set = function(info, value) CO.db.profile.customArmoryShowItemlevel = value; CD:ShowNotification("RELOAD_NOTIFICATION") end,
					disabled = function() return not CO.db.profile.customArmory end,
				},
				customArmoryShowEnchants = {
					type = "toggle",
					order = 11,
					name = "Show Enchant Info",
					desc = "When enabled, you'll be informed about missing essential enchants on each piece of gear gear",
					get = function() return CO.db.profile.customArmoryShowEnchants end,
					set = function(info, value) CO.db.profile.customArmoryShowEnchants = value; CD:ShowNotification("RELOAD_NOTIFICATION") end,
					disabled = function() return not CO.db.profile.customArmory end,
				},
				customArmoryShowGems = {
					type = "toggle",
					order = 12,
					name = "Show Gem Info",
					desc = "When enabled, Gem Slots will be shown next to the corresponding gear slots",
					get = function() return CO.db.profile.customArmoryShowGems end,
					set = function(info, value) CO.db.profile.customArmoryShowGems = value; CD:ShowNotification("RELOAD_NOTIFICATION") end,
					disabled = function() return not CO.db.profile.customArmory end,
				},
				newLine = {type="description", name="", order=15},
				customArmoryBackground = {
					type = "toggle",
					order = 16,
					name = L["Armory Class BG"],
					desc = L["Armory Class BG Desc"],
					get = function() return CO.db.profile.customArmoryBackground end,
					set = function(info, value) CO.db.profile.customArmoryBackground = value; CD:ShowNotification("RELOAD_NOTIFICATION") end,
					disabled = function() return not CO.db.profile.customArmory end,
				},
				customArmoryBackgroundTexture = {
					type = "toggle",
					order = 17,
					name = "Use Custom Texture",
					desc = "Lets you specify your own texture for your character panel (only!)",
					get = function() return CO.db.profile.customArmoryBackgroundTexture end,
					set = function(info, value) CO.db.profile.customArmoryBackgroundTexture = value; E:GetModule("Armory"):LoadProfile(); end,
					disabled = function() return not CO.db.profile.customArmory or not CO.db.profile.customArmoryBackground end,
				},
				customArmoryBackgroundTexturePath = {
					type = "input",
					order = 18,
					name = "Texture Path",
					width = "double",
					get = function() return CO.db.profile.customArmoryBackgroundTexturePath end,
					set = function(info, value) CO.db.profile.customArmoryBackgroundTexturePath = value; E:GetModule("Armory"):LoadProfile(); end,
					disabled = function() return not CO.db.profile.customArmory or not CO.db.profile.customArmoryBackground end,
					hidden = function() return not CO.db.profile.customArmoryBackgroundTexture end,
				},
				customArmoryBackgroundUseClass = {
					type = "select",
					order = 18,
					name = "Select Class Background",
					desc = "Choose which class background you want to use in your own armory",
					get = function() return CO.db.profile.customArmoryBackgroundUseClass end,
					set = function(info, value) CO.db.profile.customArmoryBackgroundUseClass = value; E:GetModule("Armory"):LoadProfile() end,
					values = BackgroundClasses,
					disabled = function() return not CO.db.profile.customArmory or not CO.db.profile.customArmoryBackground end,
					hidden = function() return CO.db.profile.customArmoryBackgroundTexture end,
				},
			},
		},
		
		mediaGroup = {
			type = "group",
			name = L["Media"],
			order = 3,
			args = {
				overrideWorldNameFont = {
					type = "toggle",
					order = 11,
					name = L["OverrideWorldNameFont"],
					desc = L["WorldNameFontDesc"],
					get = function() return CO.db.profile.global.overrideWorldNameFont end,
					set = function(info, value) CO.db.profile.global.overrideWorldNameFont = value; CD:ShowNotification("RELOAD_NOTIFICATION"); end,
				},
				overrideDamageFont = {
					type = "toggle",
					order = 12,
					name = L["OverrideWorldDamageFont"],
					desc = L["WorldDamageFontDesc"],
					get = function() return CO.db.profile.global.overrideDamageFont end,
					set = function(info, value) CO.db.profile.global.overrideDamageFont = value; CD:ShowNotification("RELOAD_NOTIFICATION"); end,
				},
				overrideDefaultFont = {
					type = "toggle",
					order = 13,
					name = L["OverrideWorldDefaultFont"],
					desc = L["WorldDefaultFontDesc"],
					get = function() return CO.db.profile.global.overrideDefaultFont end,
					set = function(info, value) CO.db.profile.global.overrideDefaultFont = value; CD:ShowNotification("RELOAD_NOTIFICATION"); end,
				},
				newLine = {type="description", name="", order=14},
				worldNameFont = {
				  name = L["WorldNameFont"],
				  dialogControl = "LSM30_Font",
				  type = "select",
				  desc = L["WorldNameFontDesc"],
				  order = 15,
				  values = CO.AceGUIWidgetLSMlists["font"],
				  get = function(info) return CO.db.profile.global.worldNameFont end,
				  set = function(info, value) CO.db.profile.global.worldNameFont = value end,
				  disabled = function() return not CO.db.profile.global.overrideWorldNameFont end,
				},
				worldDamageFont = {
				  name = L["WorldDamageFont"],
				  dialogControl = "LSM30_Font",
				  type = "select",
				  desc = L["WorldDamageFontDesc"],
				  order = 16,
				  values = CO.AceGUIWidgetLSMlists["font"],
				  get = function(info) return CO.db.profile.global.worldDamageFont end,
				  set = function(info, value) CO.db.profile.global.worldDamageFont = value end,
				  disabled = function() return not CO.db.profile.global.overrideDamageFont end,
				},
				worldDefaultFont = {
				  name = L["WorldDefaultFont"],
				  dialogControl = "LSM30_Font",
				  type = "select",
				  desc = L["WorldDefaultFontDesc"],
				  order = 17,
				  values = CO.AceGUIWidgetLSMlists["font"],
				  get = function(info) return CO.db.profile.global.worldDefaultFont end,
				  set = function(info, value) CO.db.profile.global.worldDefaultFont = value end,
				  disabled = function() return not CO.db.profile.global.overrideDefaultFont end,
				},
				generalHeader = {
					order = 20,
					type = "header",
					name = "General Font",
				},
				overrideGeneralFont = {
					type = "toggle",
					order = 21,
					name = L["OverrideGlobalFont"],
					desc = L["OverrideGlobalFontDesc"],
					get = function() return CO.db.profile.global.overrideGeneralFont end,
					set = function(info, value) CO.db.profile.global.overrideGeneralFont = value; CD:ShowNotification("RELOAD_NOTIFICATION"); end,
				},
				generalFontSize = {
					name = L["FontHeight"],
					type = "range",
					order = 22,
					min = 6, max = 90, step = 1,
					get = function(info) return CO.db.profile.global.generalFontSize end,
					set = function(info, value) CO.db.profile.global.generalFontSize = value; E:GetModule("ArtLib"):UpdateFonts() end,
					disabled = function() return not CO.db.profile.global.overrideGeneralFont end,
				},
				generalFont = {
					name = "General Font",
					dialogControl = "LSM30_Font",
					type = "select",
					desc = L["OverrideGlobalFontDesc"],
					order = 23,
					values = CO.AceGUIWidgetLSMlists["font"],
					get = function(info) return CO.db.profile.global.generalFont end,
					set = function(info, value) CO.db.profile.global.generalFont = value; E:GetModule("ArtLib"):UpdateFonts() end,
					disabled = function() return not CO.db.profile.global.overrideGeneralFont end,
				},
			},
		},
		
		statisticsGroup = {
			type = "group",
			name = L["Statistics"],
			order = -1,
			args = {
				enable = {
					type = "toggle",
					name = L["EnableLogging"],
					order = 0,
					get = function(info) return CO.db.global.timePlayed.enable end,
					set = function(info, value) CO.db.global.timePlayed.enable = value; CD:ShowNotification("RELOAD_NOTIFICATION") end,
				},
				deleteCharacter = {
					type = "select",
					name = L["RemoveCharacter"],
					order = 1,
					values = E:GetModule("PlayTime"):GetAllCharacters(),
					get = function(info) return true end,
					set = function(info, value) E:GetModule("PlayTime"):RemoveCharacter(value) end,
				},
				update = {
					type = "execute",
					name = "Update",
					order = 2,
					func = function() E:GetModule("PlayTime"):PerformRequest(); CD.Options.args.global.args.statisticsGroup.args.update.name = ". . ." end,
					disabled = function() return not CO.db.global.timePlayed.enable or CD.Options.args.global.args.statisticsGroup.args.update.name == ". . ." end,
				},
				totalPlaytimeHeader = {
					type = "header",
					name = L["YourPlaytime"],
					order = 10,
				},
				totalTime = {
					type = "description",
					name = E:GetModule("PlayTime"):GetTotalPlaytime(),
					fontSize = "large",
					order = 15,
				},
				playtimeHeader = {
					type = "header",
					name = L["CharacterPlaytime"],
					order = 20,
				},
				characterList = {
					type = "description",
					name = E:GetModule("PlayTime"):GetCharacterList(),
					fontSize = "medium",
					order = 25,
				},
			},
		},
	},
}