local E, L = unpack(CUI) -- Engine
local CO, CD = E:LoadModules("Config", "Config_Dialog")

local NUMBER_FORMATS = {
	["METRIC"] = "Metric (K, M, G, T)",
	["ENGLISH"] = "English (K, M, B, T)",
	["GERMAN"] = "German (Tsd, Mio, Mrd, Bio)",
	["KOREAN"] = "Korean (천, 만, 억)",
	["CHINESE"] = "Chinese (W, Y)",
}

local BackgroundClasses = E:TableDeepCopy(E.ClassNames)
BackgroundClasses['PLAYER_CLASS'] = ('<<%s>> (%s)'):format(L["YourCurrentClass"], L["Automatic"])
-- Colorize class selection
do
	local Hex, Color, RGB, SetColor
	for k, v in pairs(BackgroundClasses) do
		SetColor = E:GetClassColorByClassName(k)
		if SetColor then
			Color = SetColor
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
	name = '|cff1784d1' .. L["Global"] .. '|r',
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
					name = L["CheckVersion"],
					desc = "When enabled, CUI will periodically check if a new version is available.\n\nNOTE: This is a global setting and is not being saved in your character profile!",
					--get = function() return CO.db.global.communication.autoCheckVersion end,
					get = function() return false end,
					--set = function(info, value) CO.db.global.communication.autoCheckVersion = value; E:LoadModule("Communication"):UpdateVersionCheckTicker(); end,
					set = function(info, value) print("Stop it D:") end,
					disabled = true,
				},
				cameraDesc = {
						type = "description",
						order = 21.5,
						name = "The Version Checking feature currently is fully disabled, as it contains some critical issues that require thorough fixing",
						fontSize = "small",
					},
				revertCVarsOnDisable = {
					type = "toggle",
					order = 22,
					name = "Revert CVars on Shutdown",
					desc = "This functionality will revert every altered (by CUI) CVar back to it's previous state (default). So, when you disable CUI, there should be no leftover CVars. When first enabling this, all CVars already should have their default state, otherwise this won't work as expected!",
					get = function() return CO.db.global.revertCVarsOnDisable end,
					set = function(info, value) CO.db.global.revertCVarsOnDisable = value end,
					hidden = true,
				},
				newLine = {type="description", name="", order=25},
				numberFormat = {
					name = L["NumberFormat"],
					type = "select",
					order = 26,
					values = NUMBER_FORMATS,
					get = function(info) return CO.db.global.numberFormat end,
					set = function(info, value) CO.db.global.numberFormat = value; E:LoadModule('Core'):InitNumberSuffix(); E:UpdateAllTagFonts() end,
				},
				newLine2 = {type="description", name="", order=30},
				enableItemDB = {
					type = "toggle",
					order = 31,
					name = "Log Character Data",
					desc = "This functionality saves every item and currency on every one of your characters so that you can see all item counts in corresponding tooltips",
					get = function() return CO.db.global.itemDB.enable end,
					set = function(info, value) CO.db.global.itemDB.enable = value; E:LoadModule('ItemDB'):LoadConfig() end,
				},
				SetMilitaryTimeState = {
					type = "toggle",
					order = 36,
					name = "Use Military Time",
					desc = "Blizzard toggle for broken military time switch",
					get = function() return CO.db.global.blizzard.useMilitaryTime end,
					set = function(info, value) CO.db.global.blizzard.useMilitaryTime = value; E:LoadModule('Blizzard'):SetMilitaryTimeState() end,
					hidden = true,
				},
			},
		},
		
		armoryGroup = {
			type = "group",
			name = "Armory",
			order = 2,
			args = {
				enabled = {
					type = "toggle",
					order = 9,
					width = "full",
					name = L["Enable"],
					desc = L["ArmoryEnableDesc"],
					get = function() return CO.db.global.customArmory.enabled end,
					set = function(info, value) CO.db.global.customArmory.enabled = value; E:LoadModule("Armory"):LoadConfig(); end,
				},
				showItemlevel = {
					type = "toggle",
					order = 10,
					name = L["ArmoryItemlevel"],
					desc = L["ArmoryItemlevelDesc"],
					get = function() return CO.db.global.customArmory.showItemlevel end,
					set = function(info, value) CO.db.global.customArmory.showItemlevel = value; E:LoadModule("Armory"):LoadConfig(); end,
					disabled = function() return not CO.db.global.customArmory.enabled end,
				},
				showEnchants = {
					type = "toggle",
					order = 11,
					name = L["ArmoryEnchant"],
					desc = L["ArmoryEnchantDesc"],
					get = function() return CO.db.global.customArmory.showEnchants end,
					set = function(info, value) CO.db.global.customArmory.showEnchants = value; E:LoadModule("Armory"):LoadConfig(); end,
					disabled = function() return not CO.db.global.customArmory.enabled end,
				},
				showGems = {
					type = "toggle",
					order = 12,
					name = L["ArmoryGem"],
					desc = L["ArmoryGemDesc"],
					get = function() return CO.db.global.customArmory.showGems end,
					set = function(info, value) CO.db.global.customArmory.showGems = value; E:LoadModule("Armory"):LoadConfig(); end,
					disabled = function() return not CO.db.global.customArmory.enabled end,
				},
				newLine = {type="description", name="", order=15},
				overrideBackground = {
					type = "toggle",
					order = 16,
					name = L["ArmoryOverrideBackground"],
					desc = L["ArmoryOverrideBackgroundDesc"],
					get = function() return CO.db.global.customArmory.overrideBackground end,
					set = function(info, value) CO.db.global.customArmory.overrideBackground = value; E:LoadModule("Armory"):LoadConfig(); end,
					disabled = function() return not CO.db.global.customArmory.enabled end,
				},
				backgroundGroup = {
						type = "group",
						name = "Background",
						order = 20,
						guiInline = true,
						hidden = function() return not CO.db.global.customArmory.overrideBackground end,
						args = {
								useCustomBackground = {
								type = "toggle",
								order = 17,
								name = L["CustomTexture"],
								desc = L["CustomTextureDesc"],
								get = function() return CO.db.global.customArmory.useCustomBackground end,
								set = function(info, value) CO.db.global.customArmory.useCustomBackground = value; E:LoadModule("Armory"):LoadConfig(); end,
								disabled = function() return not CO.db.global.customArmory.enabled or not CO.db.global.customArmory.overrideBackground end,
							},
							customBackgroundPath = {
								type = "input",
								order = 18,
								name = L["TexturePath"],
								width = "double",
								get = function() return CO.db.global.customArmory.customBackgroundPath end,
								set = function(info, value) CO.db.global.customArmory.customBackgroundPath = value; E:LoadModule("Armory"):LoadConfig(); end,
								disabled = function() return not CO.db.global.customArmory.enabled or not CO.db.global.customArmory.overrideBackground end,
								hidden = function() return not CO.db.global.customArmory.useCustomBackground end,
							},
							classBackground = {
								type = "select",
								order = 18,
								width = 1.25,
								name = L["ArmoryBackgroundOfClass"],
								desc = L["ArmoryBackgroundOfClassDesc"],
								get = function() return CO.db.global.customArmory.classBackground end,
								set = function(info, value) CO.db.global.customArmory.classBackground = value; E:LoadModule("Armory"):LoadConfig() end,
								values = BackgroundClasses,
								disabled = function() return not CO.db.global.customArmory.enabled or not CO.db.global.customArmory.overrideBackground end,
								hidden = function() return CO.db.global.customArmory.useCustomBackground end,
							},
						},
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
					get = function() return CO.db.profile.media.overrideWorldNameFont end,
					set = function(info, value) CO.db.profile.media.overrideWorldNameFont = value; CD:ShowNotification("RELOG_NOTIFICATION"); end,
				},
				overrideWorldDamageFont = {
					type = "toggle",
					order = 12,
					name = L["OverrideWorldDamageFont"],
					desc = L["WorldDamageFontDesc"],
					get = function() return CO.db.profile.media.overrideWorldDamageFont end,
					set = function(info, value) CO.db.profile.media.overrideWorldDamageFont = value; CD:ShowNotification("RELOG_NOTIFICATION"); end,
				},
				overrideWorldDefaultFont = {
					type = "toggle",
					order = 13,
					name = L["OverrideWorldDefaultFont"],
					desc = L["WorldDefaultFontDesc"],
					get = function() return CO.db.profile.media.overrideWorldDefaultFont end,
					set = function(info, value) CO.db.profile.media.overrideWorldDefaultFont = value; CD:ShowNotification("RELOG_NOTIFICATION"); end,
				},
				newLine = {type="description", name="", order=14},
				worldNameFont = {
				  name = L["WorldNameFont"],
				  dialogControl = "LSM30_Font",
				  type = "select",
				  desc = L["WorldNameFontDesc"],
				  order = 15,
				  values = CO.AceGUIWidgetLSMlists["font"],
				  get = function(info) return CO.db.profile.media.worldNameFont end,
				  set = function(info, value) CO.db.profile.media.worldNameFont = value; CD:ShowNotification("RELOG_NOTIFICATION"); end,
				  disabled = function() return not CO.db.profile.media.overrideWorldNameFont end,
				},
				worldDamageFont = {
				  name = L["WorldDamageFont"],
				  dialogControl = "LSM30_Font",
				  type = "select",
				  desc = L["WorldDamageFontDesc"],
				  order = 16,
				  values = CO.AceGUIWidgetLSMlists["font"],
				  get = function(info) return CO.db.profile.media.worldDamageFont end,
				  set = function(info, value) CO.db.profile.media.worldDamageFont = value; CD:ShowNotification("RELOG_NOTIFICATION"); end,
				  disabled = function() return not CO.db.profile.media.overrideWorldDamageFont end,
				},
				worldDefaultFont = {
				  type = "select",
				  order = 17,
				  name = L["WorldDefaultFont"],
				  desc = L["WorldDefaultFontDesc"],
				  dialogControl = "LSM30_Font",
				  values = CO.AceGUIWidgetLSMlists["font"],
				  get = function(info) return CO.db.profile.media.worldDefaultFont end,
				  set = function(info, value) CO.db.profile.media.worldDefaultFont = value; CD:ShowNotification("RELOG_NOTIFICATION"); end,
				  disabled = function() return not CO.db.profile.media.overrideWorldDefaultFont end,
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
					get = function() return CO.db.profile.media.overrideGeneralFont end,
					set = function(info, value) CO.db.profile.media.overrideGeneralFont = value; CD:ShowNotification("RELOAD_NOTIFICATION"); end,
				},
				generalFontSize = {
					name = L["FontHeight"],
					type = "range",
					order = 22,
					min = 6, max = 90, step = 1,
					get = function(info) return CO.db.profile.media.generalFontSize or 12 end,
					set = function(info, value) CO.db.profile.media.generalFontSize = value; E:LoadModule("ArtLib"):UpdateFonts() end,
					disabled = function() return not CO.db.profile.media.overrideGeneralFont end,
				},
				generalFont = {
					name = "General Font",
					dialogControl = "LSM30_Font",
					type = "select",
					desc = L["OverrideGlobalFontDesc"],
					order = 23,
					values = CO.AceGUIWidgetLSMlists["font"],
					get = function(info) return CO.db.profile.media.generalFont end,
					set = function(info, value) CO.db.profile.media.generalFont = value; E:LoadModule("ArtLib"):UpdateFonts() end,
					disabled = function() return not CO.db.profile.media.overrideGeneralFont end,
				},
			},
		},
	},
}