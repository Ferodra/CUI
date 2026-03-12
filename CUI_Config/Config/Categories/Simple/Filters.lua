local E, L = unpack(CUI) -- Engine
local CO, CD = E:LoadModules("Config", "Config_Dialog")

local _
local Module = {}

local Index = CD:GetAutoSortIndex()

function Module:Disable()
	CD.Options.args.filters = nil
end

function Module:Enable()
	CD.Options.args.filters = {
		name = "Filters",
		type = 'group',
		childGroups = "tab",
		order = Index,
		disabled = false,
		get = function(info) return CO.db.profile.chat[ info[#info] ] end,
		set = function(info, value) CO.db.profile.chat[ info[#info] ] = value; E:LoadModule("Filters"):LoadConfig() end,
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
	}
end

CD:RegisterConfigModule(Module, 'Simple')