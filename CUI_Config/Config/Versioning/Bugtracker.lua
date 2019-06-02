local E, L = unpack(CUI) -- Engine
local CO, CD, L = E:LoadModules("Config", "Config_Dialog", "Locale")

local Major = [[|cff1784d1• Health Absorb does not differentiate between damage or heal absorb (Not a bug technically, just not implemented yet)|r]]

local Minor = [[|cff1784d1• Toggling the player nameplate via blizzard options is not being registered by CUIs getter
• Hotkeys for disabled actionbuttons still work (not sure if you can call this a bug or a feature)
• When changing display resolution, the UI is scattered all over the place and needs an reload
• Resetting the anchors just works one time and then requires a reload|r]]

CD.Options.args.bugtracker = {
	type = "group",
	name = "Bugtracker",
	order = -3,
	args = {
		Debug = {
			order = 0,
			type = "toggle",
			name = "Debug",
			desc = "Controls the status of the CUI Debugging Mode. Only for developers!",
			get = function() return CO.db.global.debugMode end,
			set = function(info, value) CO.db.global.debugMode = value; E.Debug = value; end,
		},
		HeaderMajor = {
			order = 1,
			type = "header",
			name = "Major",
		},
		ContentMajor = {
			order = 2,
			type = "description",
			name = Major,
			fontSize = "medium",
		},
		HeaderMinor = {
			order = 3,
			type = "header",
			name = "Minor",
		},
		ContentMinor = {
			order = 4,
			type = "description",
			name = Minor,
			fontSize = "medium",
		},
	}
}