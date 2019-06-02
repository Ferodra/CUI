local E, L = unpack(CUI) -- Engine
local CO, CD, L = E:LoadModules("Config", "Config_Dialog", "Locale")

local _

local Index = 99999

CD:InitializeOptionsCategory("chat", "Chat", Index)

CD.Options.args.chat = {
	name = "Chat",
	type = 'group',
	childGroups = "tab",
	order = Index,
	disabled = false,
	args = {
		generalChat = {
			name = "General",
			type = "group",
			order = 1,
			get = function(info) return CO.db.profile.chat[ info[#info] ] end,
			set = function(info, value) CO.db.profile.chat[ info[#info] ] = value; E:GetModule("Chat"):LoadProfile() end,
			args = {
				fontType = {
				  name = "Chat Font",
				  dialogControl = "LSM30_Font",
				  type = "select",
				  desc = "The Font that is used by the Chat",
				  order = 1,
				  values = CO.AceGUIWidgetLSMlists["font"],
				},
				showRoles = {
					order = 5,
					type = "toggle",
					name = "Show Roles",
					width = "full",
				},
			},
		},
	},
}