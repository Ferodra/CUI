local E, L = unpack(CUI) -- Engine
local CO, CD = E:LoadModules("Config", "Config_Dialog")

local _
local Module = {}

local Index = CD:GetAutoSortIndex()

function Module:Disable()
	CD.Options.args.chat = nil
end

function Module:Enable()
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
				set = function(info, value) CO.db.profile.chat[ info[#info] ] = value; E:LoadModule("Chat"):LoadConfig() end,
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
					positionHeader = {
						order = 10,
						type = "header",
						name = L["Positioning"],
					},
				},
			},
		},
	}
	
	for k,v in pairs(CD:GetMoverOptions("ChatParentMover", 11, true)) do
		CD.Options.args.chat.args.generalChat.args[k] = v
	end
end

CD:RegisterConfigModule(Module, 'Advanced')