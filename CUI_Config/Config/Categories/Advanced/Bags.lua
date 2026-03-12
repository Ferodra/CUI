local E, L = unpack(CUI) -- Engine
local CO, CD = E:LoadModules("Config", "Config_Dialog")

local Module = {}

local AUTOSELL_MAX_ILVL_GEMS = 385
local AUTOSELL_MAX_ILVL = 500

function Module:Disable()
	CD.Options.args.bags = nil
end

function Module:Enable()
	CD.Options.args.bags = {
		name = L["Bags"],
		type = 'group',
		order = CD:GetAutoSortIndex(),
		childGroups = "tab",
		args = {
			main = {
				order = 1,
				type = 'group',
				name = L["General"],
				get = function(info) return CO.db.profile.bags[ info[#info] ] end,
				set = function(info, value) CO.db.profile.bags[ info[#info] ] = value; E:LoadModule("Bags"):LoadConfig() end,
				args = {
					enable = {
						order = 1,
						type = "toggle",
						name = L["Enable"],
						width = "full",
					},
					positionHeader = {
						type = "header",
						order = 10,
						name = L["Positioning"],
					},
					styleHeader = {
						type = "header",
						order = 20,
						name = L["Styling"],
					},
					buttonsPerRow = {
						order = 21,
						type = 'range',
						name = L["ButtonsPerRow"],
						desc = L["ButtonsPerRowDesc"],
						min = -5, max = 5, step = 1,
						disabled = function() return not CO.db.profile.bags.enable end,
					},
					buttonSizeMultiplier = {
						order = 22,
						type = 'range',
						name = L["ButtonSize"],
						desc = L["ButtonSizeDesc"],
						min = 0.1, max = 5, step = 0.05,
						disabled = function() return not CO.db.profile.bags.enable end,
					},
					buttonGap = {
						order = 23,
						type = 'range',
						name = L["ButtonGap"],
						desc = L["ButtonGapDesc"],
						min = -50, max = 50, step = 1,
						disabled = function() return not CO.db.profile.bags.enable end,
					},
					masqueHeader = {
						name = "Masque",
						type = "header",
						order = 50,
					},
					bags = {
						type = "toggle",
						order = 51,
						name = L["UseMasque"],
						desc = L["UseMasqueDesc"],
						get = function() return CO.db.char.bags.useMasque end,
						set = function(info, value) CO.db.char.bags.useMasque = value; CD:ShowNotification("CHARACTERSETTING_NOTIFICATION") end,
					},
				},
			},
			utility = {
				order = 10,
				type = 'group',
				name = "Autosell",
				args = {
					sellGreys = {
						type = "toggle",
						order = 1,
						name = L["Autosell Greys"],
						desc = L["When enabled, grey items from your bag will automatically be sold"],
						get = function() return CO.db.profile.utility.autoSellGreys end,
						set = function(info, value) CO.db.profile.utility.autoSellGreys = value; E:LoadModule("Misc_Features"):LoadConfig(); end,
					},
					newLine0 = CD:GetNewLine(1.25),
					autoSellOldGems = {
						order = 1.5,
						type = 'toggle',
						name = "Sell Old Gems",
						desc = "When enabled, old gems automatically will be sold",
						get = function() return CO.db.profile.utility.autoSellOldGems end,
						set = function(info, value) CO.db.profile.utility.autoSellOldGems = value; E:LoadModule("Misc_Features"):LoadConfig(); end,
					},
					GemItemLevelGroup = {
						type = "group",
						name = "Gem Options",
						order = 1.75,
						guiInline = true,
						hidden = function() return not CO.db.profile.utility.autoSellOldGems end,
						args = {
							autoSellOldGemsBelowIlvl = {
								order = 4,
								type = 'range',
								name = "Sell Below Ilvl",
								desc = "Let's you specify what itemlevel gems should be below to be sold",
								min = 1, max = AUTOSELL_MAX_ILVL_GEMS, step = 1,
								get = function() return CO.db.profile.utility.autoSellOldGemsBelowIlvl end,
								set = function(info, value) CO.db.profile.utility.autoSellOldGemsBelowIlvl = value; E:LoadModule("Misc_Features"):LoadConfig(); end,
							},
						},
					},
					newLine = CD:GetNewLine(2),
					enableSellBelowIlvl = {
						type = "toggle",
						order = 3,
						name = "Auto Sell Below Ilvl",
						desc = "When enabled, items below the specified itemlevel will automatically be sold. Cannot be set to current expansion itemlevel range.",
						get = function() return CO.db.profile.utility.autoSellBelowIlvlEnable end,
						set = function(info, value) CO.db.profile.utility.autoSellBelowIlvlEnable = value; E:LoadModule("Misc_Features"):LoadConfig(); end,
					},
					-- guiInline
					ItemLevelGroup = {
						type = "group",
						name = "Autosell Options",
						order = 5,
						guiInline = true,
						hidden = function() return not CO.db.profile.utility.autoSellBelowIlvlEnable end,
						args = {
							enableSellBelowIlvlAtMaxlevel = {
								type = "toggle",
								order = 3.5,
								name = "Only At Max Level",
								desc = "Only auto sell items below the specified itemlevel when you actually are at max level. This is to prevent automatically selling your entire gear while leveling.",
								get = function() return CO.db.profile.utility.autoSellBelowIlvlEnableAtMaxlevel end,
								set = function(info, value) CO.db.profile.utility.autoSellBelowIlvlEnableAtMaxlevel = value; E:LoadModule("Misc_Features"):LoadConfig(); end,
								disabled = function() return not CO.db.profile.utility.autoSellBelowIlvlEnable end,
							},
							sellBelowIlvl = {
								order = 4,
								type = 'range',
								name = "Sell Below Ilvl",
								desc = "Let's you specify what items should be sold automatically",
								min = 1, max = AUTOSELL_MAX_ILVL, step = 1,
								get = function() return CO.db.profile.utility.autoSellBelowIlvl end,
								set = function(info, value) CO.db.profile.utility.autoSellBelowIlvl = value; E:LoadModule("Misc_Features"):LoadConfig(); end,
								disabled = function() return not CO.db.profile.utility.autoSellBelowIlvlEnable end,
							},
							newLine2 = CD:GetNewLine(5),
							autoSellNoBoE = {
								order = 6,
								type = 'toggle',
								name = "Exclude BoE's",
								desc = "When enabled, BoE's that are NOT yet Soulbound won't be sold automatically",
								get = function() return CO.db.profile.utility.autoSellNoBoE end,
								set = function(info, value) CO.db.profile.utility.autoSellNoBoE = value; E:LoadModule("Misc_Features"):LoadConfig(); end,
								disabled = function() return not CO.db.profile.utility.autoSellBelowIlvlEnable end,
							},
							autoSellNoUncollectedTransmog = {
								order = 7,
								type = 'toggle',
								name = "Exclude Uncollected Transmog",
								desc = "When enabled, uncollected Transmog won't be sold.\n\nNOTE: As of Patch 10.0, you seem to automatically unlock transmog when you sell the item. But i'll just leave this option in anyway!",
								get = function() return CO.db.profile.utility.autoSellNoUncollectedTransmog end,
								set = function(info, value) CO.db.profile.utility.autoSellNoUncollectedTransmog = value; E:LoadModule("Misc_Features"):LoadConfig(); end,
								disabled = function() return not CO.db.profile.utility.autoSellBelowIlvlEnable or CO.db.profile.utility.autoSellNoBoE end,
							},
						},
					},
					newLine3 = CD:GetNewLine(10),
					sellGreysReport = {
						type = "toggle",
						order = 11,
						name = L["Autosell Greys Report"],
						desc = L["Reports what has been sold and how much revenue you earned"],
						get = function() return CO.db.profile.utility.autoSellGreysReport end,
						set = function(info, value) CO.db.profile.utility.autoSellGreysReport = value; end,
						disabled = function() return not CO.db.profile.utility.autoSellGreys and not CO.db.profile.utility.autoSellOldGems and not CO.db.profile.utility.autoSellBelowIlvlEnable end,
					},
				},
			},
		},
		
	}

	for k,v in pairs(CD:GetMoverOptions("CUI_BagBarHolderMover", 11, true)) do
		CD.Options.args.bags.args.main.args[k] = v
	end
end

CD:RegisterConfigModule(Module, 'Advanced')