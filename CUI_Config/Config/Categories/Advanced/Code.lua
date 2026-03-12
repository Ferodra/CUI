local E, L = unpack(CUI) -- Engine
local CO, CD, TT, CODE = E:LoadModules("Config", "Config_Dialog", "Tooltip", "CustomCode")

local _
local Module = {}

function Module:Disable()
	CD.Options.args.code = nil
end

function Module:Enable()
	CD.Options.args.code = {
		name = "|cffd93232Experimental Area|r",
		type = 'group',
		order = CD:GetAutoSortIndex(),
		disabled = false,
		hidden = function() return not CO.db.global.debugMode end,
		args = {
			code = {
				type = 'input',
				order = 5,
				name = 'Custom Code',
				multiline = true,
				width = 'full',
				set = function(info, value) CO.db.profile.code.testFunc = value end,
				get = function() return CO.db.profile.code.testFunc end,
			},
			newLine = {type='description',name='',order=10},
			run = {
				type = 'execute',
				name = 'RUN',
				order = 15,
				func = function() local Func = CODE:LoadFunction(CO.db.profile.code.testFunc); if Func then Func(); end end,
			},
		},
		
	}
end

CD:RegisterConfigModule(Module, 'Advanced')