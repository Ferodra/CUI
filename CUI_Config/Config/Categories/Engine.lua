local E, L = unpack(CUI) -- Engine
local CO, CD, L = E:LoadModules("Config", "Config_Dialog", "Locale")

local _

local Index = 99999

CD:InitializeOptionsCategory("engine", "Camera", Index)

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
					name = L["CameraDesc"] .. " |cffFF0000" .. L["CameraDescSec"] .. "|r.",
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
					name = L["ActioncamDesc"],
					fontSize = "small",
				},
				notificationToggle = {
					order = 1,
					type = "toggle",
					name = L["HideNotification"],
					desc = L["HideNotificationDesc"],
					set = function(info, value) CO.db.profile.engine.hideActioncamNotification = value; end,
					get = function() return CO.db.profile.engine.hideActioncamNotification end
				},
				test_cameraHeadMovementStrength = {
					order = 3,
					type = 'range',
					name = L["HeadTracking"],
					desc = L["HeadTrackingDesc"],
					min = 0, max = 5, step = 0.1,
					width = "full",
				},
				test_cameraOverShoulder = {
					order = 4,
					type = 'range',
					name = L["ShoulderOffset"],
					desc = L["ShoulderOffsetDesc"],
					min = -5, max = 5, step = 0.1,
					width = "full",
				},
				cameraHeader = {
					order = 10,
					type = "header",
					name = L["DynamicPitch"],
				},
				test_cameraDynamicPitch = {
					order = 15,
					type = "toggle",
					name = L["DynamicPitch"],
					desc = L["DynamicPitchDesc"],
					width = "full",
				},
				test_cameraDynamicPitchBaseFovPad = {
					order = 16,
					type = 'range',
					name = L["BaseFoVPad"],
					desc = L["BaseFoVPadDesc"],
					min = 0, max = 1, step = 0.01,
					disabled = function() return not CO.db.profile.CVars.test_cameraDynamicPitch end,
				},
				test_cameraDynamicPitchBaseFovPadFlying = {
					order = 17,
					type = 'range',
					name = L["FlyingFoVPad"],
					desc = L["FlyingFoVPadDesc"],
					min = 0, max = 1, step = 0.01,
					disabled = function() return not CO.db.profile.CVars.test_cameraDynamicPitch end,
				},
				focusEnemyHeader = {
					order = 24,
					type = "header",
					name = "|cffbc1a32" .. L["EnemyFocus"] .. "|r",
				},
				test_cameraTargetFocusEnemyEnable = {
					order = 25,
					type = "toggle",
					name = "|cffbc1a32" .. L["EnemyFocus"] .. "|r",
					desc = L["EnemyFocusDesc"],
					width = "full",
				},
				test_cameraTargetFocusEnemyStrengthPitch = {
					order = 26,
					type = 'range',
					name = "|cffbc1a32" .. L["FocusPitch"] .. "|r",
					desc = L["FocusPitchDesc"],
					min = 0, max = 1, step = 0.01,
					width = "full",
					disabled = function() return not CO.db.profile.CVars.test_cameraTargetFocusEnemyEnable end,
				},
				test_cameraTargetFocusEnemyStrengthYaw = {
					order = 27,
					type = 'range',
					name = "|cffbc1a32" .. L["FocusYaw"] .. "|r",
					desc = L["FocusYawDesc"],
					min = 0, max = 1, step = 0.01,
					width = "full",
					disabled = function() return not CO.db.profile.CVars.test_cameraTargetFocusEnemyEnable end,
				},
				focusFriendlyHeader = {
					order = 30,
					type = "header",
					name = "|cff1a65bc" .. L["FriendlyFocus"] .. "|r",
				},
				test_cameraTargetFocusInteractEnable = {
					order = 31,
					type = "toggle",
					name = "|cff1a65bc" .. L["FriendlyFocus"] .. "|r",
					desc = L["FriendlyFocusDesc"],
					width = "full",
				},
				test_cameraTargetFocusInteractStrengthPitch = {
					order = 32,
					type = 'range',
					name = "|cff1a65bc" .. L["FocusPitch"] .. "|r",
					desc = L["FocusPitchDesc"],
					min = 0, max = 1, step = 0.01,
					width = "full",
					disabled = function() return not CO.db.profile.CVars.test_cameraTargetFocusInteractEnable end,
				},
				test_cameraTargetFocusInteractStrengthYaw = {
					order = 33,
					type = 'range',
					name = "|cff1a65bc" .. L["FocusYaw"] .. "|r",
					desc = L["FocusYawDesc"],
					min = 0, max = 1, step = 0.01,
					width = "full",
					disabled = function() return not CO.db.profile.CVars.test_cameraTargetFocusInteractEnable end,
				},
			},
		},
	},
}