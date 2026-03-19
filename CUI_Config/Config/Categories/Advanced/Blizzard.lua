local E, L = unpack(CUI) -- Engine
local CO, CD = E:LoadModules("Config", "Config_Dialog")

local Module = {}

CD.MirrorTimer_GrowthDirections = {
	["UP"] = L["Up"],
	["DOWN"] = L["Down"],
}

function Module:Disable()
	CD.Options.args.blizzard = nil
end

function Module:Enable()
	CD.Options.args.blizzard = {
		name =  CD:GetNewFeatureString("Blizzard"),
		type = 'group',
		order = CD:GetAutoSortIndex(),
		childGroups = "tab",
		args = {
			enableGameplayFeatures = {
				type = "toggle",
				order = 0,
				name = "CUI Gameplay Feature Movers",
				desc = "When enabled, CUI will create its own movers for the Blizzard 'Gameplay Enhancements' features. This isn't strictly neccessary, but can make configuration a bit easier.",
				get = function() return CO.db.char.blizzard.useGameplayFeatureMovers end,
				set = function(info, value) CO.db.char.blizzard.useGameplayFeatureMovers = value; CD:ShowNotification('CHARACTERSETTING_NOTIFICATION') end,
			},
			talkingHead = {
				order = 1,
				type = 'group',
				name =  "Talking Head",
				get = function(info) return CO.db.profile.blizzard.talkingHead[ info[#info] ] end,
				set = function(info, value) CO.db.profile.blizzard.talkingHead[ info[#info] ] = value; E:LoadModule("Blizzard_TalkingHeadUI"):LoadConfig() end,
				args = {
					positionHeader = {
						type = "header",
						order = 10,
						name = L["Positioning"],
					},
					generalHeader = {
						type = "header",
						order = 20,
						name = L["General"],
					},
					scale = {
						type = "range",
						order = 21,
						name = L["Scale"],
						min = 0.3, max = 3,
					},
				},
			},
			infoFrame = {
				order = 5,
				type = 'group',
				name = "Info Frame",
				get = function(info) return CO.db.profile.blizzard.infoFrame[ info[#info] ] end,
				set = function(info, value) CO.db.profile.blizzard.infoFrame[ info[#info] ] = value; end,
				args = {
					positionHeader = {
						type = "header",
						order = 10,
						name = L["Positioning"],
					},
				},
			},
			uiWidget = {
				order = 10,
				type = 'group',
				name = "UI Widget",
				get = function(info) return CO.db.profile.blizzard.uiWidget[ info[#info] ] end,
				set = function(info, value) CO.db.profile.blizzard.uiWidget[ info[#info] ] = value; end,
				args = {
					positionHeader = {
						type = "header",
						order = 10,
						name = L["Positioning"],
					},
				},
			},
			durabilityFrame = {
				order = 12.5,
				type = 'group',
				name = "Durability Frame",
				get = function(info) return CO.db.profile.blizzard.durabilityFrame[ info[#info] ] end,
				set = function(info, value) CO.db.profile.blizzard.durabilityFrame[ info[#info] ] = value; end,
				args = {
					positionHeader = {
						type = "header",
						order = 10,
						name = L["Positioning"],
					},
				},
			},
			mirrortimer = {
				order = 15,
				type = 'group',
				name = L["MirrorTimer"],
				get = function(info) return CO.db.profile.blizzard.mirrortimer[ info[#info] ] end,
				set = function(info, value) CO.db.profile.blizzard.mirrortimer[ info[#info] ] = value; end,
				childGroups = "tab",
				args = {
					enable = {
						type = "toggle",
						order = 1,
						name = L["Enable"],
					},
					enableSkin = {
						type = "toggle",
						order = 2,
						name = "Enable Skin",
						desc = "Wether or not to use a skinned version of this element",
					},
					generalGroup = {
						type = "group",
						order = 10,
						name = "General",
						disabled = function() return not CO.db.profile.blizzard.mirrortimer.enable end,
						get = function(info) return CO.db.profile.blizzard.mirrortimer[ info[#info] ] end,
						args = {
							positionHeader = {
								type = "header",
								order = 10,
								name = L["Positioning"],
							},
							miscHeader = {
								type = "header",
								order = 50,
								name = L["Misc"],
							},
							growthDirection = {
								name = L["GrowthDirection"],
								type = "select",
								order = 55,
								values = CD.MirrorTimer_GrowthDirections,
								set = function(info, value) CO.db.profile.blizzard.mirrortimer[ info[#info] ] = value; E:LoadModule("Blizzard_Mirrortimers"):UpdateBarPosition() end,
							},
						},
						
					},
					
				},
			},
			dungeonReadyDialog = {
				order = 20,
				type = 'group',
				name = CD:GetNewFeatureString("Dungeon Popup"),
				get = function(info) return CO.db.profile.blizzard.dungeonReadyDialog[ info[#info] ] end,
				set = function(info, value) CO.db.profile.blizzard.dungeonReadyDialog[ info[#info] ] = value; E:LoadModule("Blizzard_LFGDungeonReadyDialog"):LoadConfig() end,
				args = {
					timerHeader = {
						type = "header",
						order = 5,
						name = "Time Left Bar",
					},
					enable = {
						type = "toggle",
						order = 10,
						name = L["Enable"],
						desc = "Enables a timer bar for the queue popup",
					},
					hideBigWigs = {
						type = "toggle",
						order = 11,
						name = "Hide BigWigs",
						desc = "When enabled, the BigWigs queue timer will be hidden [When installed. There's no internal BigWigs option for that]",
					},
				},
			},
			dungeonQueue = {
				order = 21,
				type = 'group',
				name = CD:GetNewFeatureString("Dungeon Queue"),
				args = {
					header = {
						type = "header",
						order = 5,
						name = L["Positioning"],
					},
				},
			},
			chatBubbles = {
				order = 30,
				type = 'group',
				name = CD:GetNewFeatureString("Chat Bubbles"),
				get = function(info) return CO.db.profile.blizzard.chatBubbles[ info[#info] ] end,
				set = function(info, value) CO.db.profile.blizzard.chatBubbles[ info[#info] ] = value; E:LoadModule("Blizzard_ChatBubbles"):LoadConfig() end,
				childGroups = "tab",
				args = {
					enable = {
						type = "toggle",
						order = 5,
						name = L['Enable'],
						desc = "Enables a skinned variant of Chat Bubbles",
						get = function(info) return CO.db.char.blizzard.chatBubbles[ info[#info] ] end,
						set = function(info, value) CO.db.char.blizzard.chatBubbles[ info[#info] ] = value; CD:ShowNotification("CHARACTERSETTING_NOTIFICATION") end,
					},
					
					generalGroup = {
						type = "group",
						order = 10,
						name = "General",
						disabled = function() return not CO.db.char.blizzard.chatBubbles.enable end,
						get = function(info) return CO.db.profile.blizzard.chatBubbles[ info[#info] ] end,
						args = {
							borderSize = {
								type = "range",
								order = 10,
								name = "Border Size",
								min = 0, max = 10, step = 0.1,
								set = function(info, value)
									if value == 0 then
										value = 0.1
									end
									CO.db.profile.blizzard.chatBubbles.borderSize = value
									E:LoadModule("Blizzard_ChatBubbles"):LoadConfig()
								end,
							},
							borderColor = {
								name = L["BorderColor"],
								type = "color",
								hasAlpha = true,
								order = 11,
								get = function(info)
									local c = CO.db.profile.blizzard.chatBubbles.borderColor or {0,0,0,1}
									return c[1], c[2], c[3], c[4]
								end,
								set = function(info, r, g, b, a)
									if not CO.db.profile.blizzard.chatBubbles.borderColor then CO.db.profile.blizzard.chatBubbles.borderColor = {0,0,0,1} end
									local c = CO.db.profile.blizzard.chatBubbles.borderColor
									c[1], c[2], c[3], c[4] = r, g, b, a
									E:LoadModule("Blizzard_ChatBubbles"):LoadConfig()
								end,
								hidden = true,
							},
							backgroundColor = {
								name = L["BackgroundColor"],
								type = "color",
								hasAlpha = true,
								order = 12,
								get = function(info)
									local c = CO.db.profile.blizzard.chatBubbles.backgroundColor or {0,0,0,1}
									return c[1], c[2], c[3], c[4]
								end,
								set = function(info, r, g, b, a)
									if not CO.db.profile.blizzard.chatBubbles.backgroundColor then CO.db.profile.blizzard.chatBubbles.backgroundColor = {0,0,0,1} end
									local c = CO.db.profile.blizzard.chatBubbles.backgroundColor
									c[1], c[2], c[3], c[4] = r, g, b, a
									E:LoadModule("Blizzard_ChatBubbles"):LoadConfig()
								end,
							},
						},
					},
					
				},
			},
			objectiveTracker = {
				order = 35,
				type = 'group',
				name = CD:GetNewFeatureString("Objective Tracker"),
				childGroups = "tab",
				get = function(info) return CO.db.profile.blizzard.objectiveTracker[ info[#info] ] end,
				set = function(info, value) CO.db.profile.blizzard.objectiveTracker[ info[#info] ] = value; E:LoadModule("Blizzard"):UpdateTrackerAutoHide() end,
				args = {
					positionHeader = {
						type = "header",
						order = 1,
						name = L["Positioning"],
					},
					visibilityHeader = {
						type = "header",
						order = 10,
						name = L["Visibility"],
					},
					autoHideGeneral = {
						type = "toggle",
						order = 11,
						name = "Auto Hide",
						desc = "Wether or not to automatically hide the objective tracker during boss encounters or in arena",
					},
					newLine1 = {type = "description", name = "", order = 10},
					useCustomCondition = {
						type = "toggle",
						order = 15,
						name = "Custom Condition",
						desc = "",
						hidden = function() return not CO.db.profile.blizzard.objectiveTracker.autoHideGeneral end,
					},
					newLine2 = {type = "description", name = "", order = 19},
					customHideCondition = {
						type = 'input',
						order = 20,
						name = L["Visibility"],
						desc = 'Lets you specify a custom macro conditional to control in what situations the objective tracker should be visible.\n\nSome possible values:\n[group:party] [group:raid] [combat] [vehicle] [flying] [form:N] [stealth]\n\nIMPORTANT: The result of the conditional ALWAYS has to return either a "0"(hidden) or a "1"(shown) in order to make it work!\n\n More info about this topic at: ' .. CD.MacroConditionalURL,
						multiline = true,
						width = 'full',
						hidden = function() return not CO.db.profile.blizzard.objectiveTracker.autoHideGeneral end,
						disabled = function() return not CO.db.profile.blizzard.objectiveTracker.useCustomCondition end,
					},
					resetCondition = {
						order = 22,
						type = "execute",
						name = L["DefVisibility"],
						desc = L["DefVisibilityDesc"],
						func = function()
							CO.db.profile.blizzard.objectiveTracker.customHideCondition = E.ConfigDefaults.profile.blizzard.objectiveTracker.customHideCondition
							E:LoadModule("Blizzard"):UpdateTrackerAutoHide()
						end,
						hidden = function() return not CO.db.profile.blizzard.objectiveTracker.autoHideGeneral end,
						disabled = function() return not CO.db.profile.blizzard.objectiveTracker.useCustomCondition end,
					},
				},
			},
			playerHighlight = {
				order = 40,
				type = 'group',
				name = CD:GetNewFeatureString("Player Highlight"),
				childGroups = "tab",
				get = function(info) return CO.db.profile.utility[ info[#info] ] end,
				set = function(info, value) CO.db.profile.utility[ info[#info] ] = value end,
				args = {
					positionHeader = {
						type = "header",
						order = 1,
						name = L["Player Highlight"],
					},
					disablePlayerHighlightOnLogin = {
						type = "toggle",
						order = 5,
						name = "Disable Highlight On Login",
						desc = "By default, the player highlight will always return to an enabled state when you've set it to something and use a keybind to disable it. Enabling this option will force the highlight to always be disabled on login.",
					},
				},
			},
		},
		
	}
	
	local MoverConfigData = {
		{"ObjectiveTrackerFrameMover", 2, "Options.args.blizzard.args.objectiveTracker.args"},
		{"TalkingHeadFrameMover", 11, "Options.args.blizzard.args.talkingHead.args"},
		{"UIWidgetTopCenterContainerFrameMover", 11, "Options.args.blizzard.args.infoFrame.args"},
		{"UIWidgetBelowMinimapContainerFrameMover", 11, "Options.args.blizzard.args.uiWidget.args"},
		{"MirrorTimerHolderMover", 11, "Options.args.blizzard.args.mirrortimer.args.generalGroup.args"},
		{"DurabilityFrameMover", 11, "Options.args.blizzard.args.durabilityFrame.args"},
		{"CUI_QueueStatusButtonHolderMover", 11, "Options.args.blizzard.args.dungeonQueue.args"},
	}
	
	CD:AddMoverConfigs(MoverConfigData)
	
	Fonts = {{Path = "db.profile.blizzard.chatBubbles.name", Order = 200, GroupName = L["Name"]}, {Path = "db.profile.blizzard.chatBubbles.text", Order = 300, GroupName = "Text"}}
	for k,v in pairs(CD:GetFontOptions(Fonts)) do
		CD.Options.args.blizzard.args.chatBubbles.args[k] = v
	end
	
	CD.Options.args.blizzard.args.chatBubbles.args[L['Name']].disabled = function()
		return not CO.db.char.blizzard.chatBubbles.enable
	end
	CD.Options.args.blizzard.args.chatBubbles.args["Text"].disabled = function()
		return not CO.db.char.blizzard.chatBubbles.enable
	end
	
	local Mirrortimer_Fonts_Disabledfunc = function() return not CO.db.profile.blizzard.mirrortimer.enable or not CO.db.profile.blizzard.mirrortimer.enableSkin end
	local Fonts = {{Path = "db.profile.blizzard.mirrortimer.text", Order = 100, GroupName = L["Text"]}, {Path = "db.profile.blizzard.mirrortimer.time", Order = 200, GroupName = L["Time"]}}
	for k,v in pairs(CD:GetFontOptions(Fonts, Mirrortimer_Fonts_Disabledfunc)) do
		CD.Options.args.blizzard.args.mirrortimer.args[k] = v
	end
end

CD:RegisterConfigModule(Module, 'Advanced')