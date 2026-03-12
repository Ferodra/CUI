local E, L = unpack(CUI) -- Engine
local CO, CD = E:LoadModules("Config", "Config_Dialog")

local _

local Module = {}
local Index = CD:GetAutoSortIndex()

function Module:Disable()
	CD.Options.args.engine = nil
end

function Module:Enable()
	CD.Options.args.engine = {
		name = L["Camera"],
		type = 'group',
		childGroups = "tab",
		order = Index,
		disabled = false,
		args = {
			generalCamera = {
				name = L["Camera"],
				type = "group",
				order = 1,
				args = {
					cameraHeader = {
						order = 1,
						type = "header",
						name = L["Camera"],
					},
					cameraDesc = {
						type = "description",
						order = 2,
						name = L["CameraDesc"] .. " |cffFF0000" .. L["CameraDescSec"] .. "|r",
						fontSize = "small",
					},
					yawSpeed = {
						order = 3,
						type = 'range',
						name = L["YawSpeed"],
						desc = L["YawSpeedDesc"],
						min = 0, max = 200, step = 0.05,
						width = "full",
						get = function() return CO.db.profile.CVars.cameraYawMoveSpeed end,
						set = function(info, value) CO.db.profile.CVars.cameraYawMoveSpeed = value; E:UpdateCVars(); end,
					},
					pitchSpeed = {
						order = 4,
						type = 'range',
						name = L["PitchSpeed"],
						desc = L["PitchSpeedDesc"],
						min = 0, max = 200, step = 0.05,
						width = "full",
						get = function() return CO.db.profile.CVars.cameraPitchMoveSpeed end,
						set = function(info, value) CO.db.profile.CVars.cameraPitchMoveSpeed = value; E:UpdateCVars(); end,
					},
					presetHeader = {
						order = 10,
						type = "header",
						name = L["Presets"],
					},
					presetFullHD = {
						order = 11,
						type = "execute",
						name = L["PresetFullHD"],
						func = function() CO.db.profile.CVars.cameraYawMoveSpeed = 0; CO.db.profile.CVars.cameraPitchMoveSpeed = 0; E:UpdateCVars(); CD:ShowNotification("RELOAD_NOTIFICATION"); end
					},
					presetUltraHD = {
						order = 12,
						type = "execute",
						name = L["Preset4K"],
						func = function() CO.db.profile.CVars.cameraYawMoveSpeed = 47; CO.db.profile.CVars.cameraPitchMoveSpeed = 35; E:UpdateCVars(); end
					},
				},
			},
			cameraFixes = {
				name = L["Fixes"],
				type = "group",
				order = 1.5,
				args = {
					fixesHeader = {
						order = 20,
						type = "header",
						name = Fixes,
					},
					fixFollowStyle = {
						order = 21,
						type = "execute",
						name = "Fix Camera Follow",
						desc = "Sometimes, the game will bug out and the camera will stop moving behind the character, regardless of what settings are used in the Blizzard options. Should the problem continue to occur, chances are one of your enabled AddOns is messing with SaveView in some way. This button resets the view style to default to fix this issue.\n\nSource: https://us.forums.blizzard.com/en/wow/t/camera-following-style-problembug/442862/16",
						func = function() ResetView(2); SetView(2) end
					},
				},
			},
			actioncam = {
				name = L["Actioncam"],
				type = "group",
				order = 2,
				get = function(info) return CO.db.profile.CVars[ info[#info] ] end,
				set = function(info, value) CO.db.profile.CVars[ info[#info] ] = value; E:UpdateCVars(); end,
				args = {
					cameraDesc = {
						type = "description",
						order = 0,
						--name = L["ActioncamDesc"] .. "\n|cffFF0000" .. L["ActioncamDescWarning"] .. "|r",
						name = L["ActioncamDesc"],
						fontSize = "small",
					},
					enableActioncam = {
						type = "toggle",
						order = 1,
						name = L["EnableModule"],
						desc = "When enabled, CUI will handle most of the Actioncam features. Disable when using an external AddOn for this.",
						get = function() return CO.db.profile.engine.enableActioncam end,
						set = function(info, value) CO.db.profile.engine.enableActioncam = value; CD:ShowNotification("RELOAD_NOTIFICATION") end,
					},
					SPACER_1 = {type = "description", order = 2, name = ''},
					notificationToggle = {
						order = 5,
						type = "toggle",
						name = L["HideNotification"],
						desc = L["HideNotificationDesc"],
						set = function(info, value) CO.db.profile.engine.hideActioncamNotification = value; end,
						get = function() return CO.db.profile.engine.hideActioncamNotification end,
						hidden = function() return not CO.db.profile.engine.enableActioncam end,
					},
					test_cameraHeadMovementStrength = {
						order = 6,
						type = 'range',
						name = L["HeadTracking"],
						desc = L["HeadTrackingDesc"],
						min = 0, max = 5, step = 0.01,
						width = "full",
						hidden = function() return not CO.db.profile.engine.enableActioncam end,
					},
					test_cameraOverShoulder = {
						order = 7,
						type = 'range',
						name = L["ShoulderOffset"],
						desc = L["ShoulderOffsetDesc"],
						min = -5, max = 5, step = 0.1,
						width = "full",
						hidden = function() return not CO.db.profile.engine.enableActioncam end,
					},
					cameraHeader = {
						order = 10,
						type = "header",
						name = L["DynamicPitch"],
						hidden = function() return not CO.db.profile.engine.enableActioncam end,
					},
					test_cameraDynamicPitch = {
						order = 15,
						type = "toggle",
						name = L["DynamicPitch"],
						desc = L["DynamicPitchDesc"],
						width = "full",
						hidden = function() return not CO.db.profile.engine.enableActioncam end,
					},
					test_cameraDynamicPitchBaseFovPad = {
						order = 16,
						type = 'range',
						name = L["BaseFoVPad"],
						desc = L["BaseFoVPadDesc"],
						min = 0, max = 1, step = 0.01,
						hidden = function() return not CO.db.profile.CVars.test_cameraDynamicPitch or not CO.db.profile.engine.enableActioncam end,
					},
					test_cameraDynamicPitchBaseFovPadFlying = {
						order = 17,
						type = 'range',
						name = L["FlyingFoVPad"],
						desc = L["FlyingFoVPadDesc"],
						min = 0, max = 1, step = 0.01,
						hidden = function() return not CO.db.profile.CVars.test_cameraDynamicPitch or not CO.db.profile.engine.enableActioncam end,
					},
					focusEnemyHeader = {
						order = 24,
						type = "header",
						name = "|cffbc1a32" .. L["EnemyFocus"] .. "|r",
						hidden = function() return not CO.db.profile.engine.enableActioncam end,
					},
					test_cameraTargetFocusEnemyEnable = {
						order = 25,
						type = "toggle",
						name = "|cffbc1a32" .. L["EnemyFocus"] .. "|r",
						desc = L["EnemyFocusDesc"],
						width = "full",
						hidden = function() return not CO.db.profile.engine.enableActioncam end,
					},
					test_cameraTargetFocusEnemyStrengthPitch = {
						order = 26,
						type = 'range',
						name = "|cffbc1a32" .. L["FocusPitch"] .. "|r",
						desc = L["FocusPitchDesc"],
						min = 0, max = 1, step = 0.01,
						width = "full",
						hidden = function() return not CO.db.profile.CVars.test_cameraTargetFocusEnemyEnable or not CO.db.profile.engine.enableActioncam end,
					},
					test_cameraTargetFocusEnemyStrengthYaw = {
						order = 27,
						type = 'range',
						name = "|cffbc1a32" .. L["FocusYaw"] .. "|r",
						desc = L["FocusYawDesc"],
						min = 0, max = 1, step = 0.01,
						width = "full",
						hidden = function() return not CO.db.profile.CVars.test_cameraTargetFocusEnemyEnable or not CO.db.profile.engine.enableActioncam end,
					},
					focusFriendlyHeader = {
						order = 30,
						type = "header",
						name = "|cff1a65bc" .. L["FriendlyFocus"] .. "|r",
						hidden = function() return not CO.db.profile.engine.enableActioncam end,
					},
					test_cameraTargetFocusInteractEnable = {
						order = 31,
						type = "toggle",
						name = "|cff1a65bc" .. L["FriendlyFocus"] .. "|r",
						desc = L["FriendlyFocusDesc"],
						width = "full",
						hidden = function() return not CO.db.profile.engine.enableActioncam end,
					},
					test_cameraTargetFocusInteractStrengthPitch = {
						order = 32,
						type = 'range',
						name = "|cff1a65bc" .. L["FocusPitch"] .. "|r",
						desc = L["FocusPitchDesc"],
						min = 0, max = 1, step = 0.01,
						width = "full",
						hidden = function() return not CO.db.profile.CVars.test_cameraTargetFocusInteractEnable or not CO.db.profile.engine.enableActioncam end,
					},
					test_cameraTargetFocusInteractStrengthYaw = {
						order = 33,
						type = 'range',
						name = "|cff1a65bc" .. L["FocusYaw"] .. "|r",
						desc = L["FocusYawDesc"],
						min = 0, max = 1, step = 0.01,
						width = "full",
						hidden = function() return not CO.db.profile.CVars.test_cameraTargetFocusInteractEnable or not CO.db.profile.engine.enableActioncam end,
					},
				},
			},
		},
	}
end

CD:RegisterConfigModule(Module, 'Advanced')