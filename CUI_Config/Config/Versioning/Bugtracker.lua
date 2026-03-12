local E, L = unpack(CUI) -- Engine
local CO, CD = E:LoadModules("Config", "Config_Dialog")

-- CPU Profiling
-- /run SetCVar("scriptProfile", 0 or 1)

local Major = [[|cff1784d1There currently are no known major bugs|r]]

local Minor = [[|cff1784d1• The Armory mode sometimes takes a moment (or re-opening of the inspect for the unit) to properly update gems. In case of doubt, check for yourself in the item tooltip.
• Allied Nameplates are not always skinned. Not a bug, simply not fully implemented yet
• When changing display resolution, the UI is scattered all over the place and needs an reload|r]]

CD.Options.args.bugtracker = {
	type = "group",
	name = '|cff1784d1' .. 'Bugtracker' .. '|r',
	order = -3,
	args = {
		Debug = {
			order = 0,
			type = "toggle",
			name = "Debug",
			desc = "Controls the status of the CUI Debugging Mode. Only for developers!\nUse CUI:debugprint(str) to make use of it.",
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