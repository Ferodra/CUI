local E, L = unpack(CUI) -- Engine
local CO, CD = E:LoadModules("Config", "Config_Dialog")

local Module = {}

function Module:Disable()
	CD.Options.args.layout = nil
end

function Module:Enable()

	local Layout = E:LoadModule("Layout")
	local LoadConfig = function()
		Layout:LoadConfig()
	end
	
	CD.Options.args.layout = {
	type = "group",
	name = "Layout",
	order = 99999,
	childGroups = "tab",
	get = function(info) return CO.db.profile.layout.stateControl.textures[ info[#info] ] end,
	set = function(info, value) CO.db.profile.layout.stateControl.textures[ info[#info] ] = value; LoadConfig() end,
	args = {
		layoutFrames = {
			type = "group",
			name = L["LayoutTextures"],
			order = 1,
			args = {
				enableTop = {
					order = 2,
					type = "toggle",
					name = L["TopBar"],
				},
				enableBottom = {
					order = 3,
					type = "toggle",
					name = L["BottomBar"],
				},
				enableBottomLeft = {
					order = 4,
					type = "toggle",
					name = L["BottomLeftCorner"],
					disabled = function() return not CO.db.profile.layout.stateControl.textures.enableBottom end,
				},
				enableBottomRight = {
					order = 5,
					type = "toggle",
					name = L["BottomRightCorner"],
					disabled = function() return not CO.db.profile.layout.stateControl.textures.enableBottom end,
				},
				newLine2 = {type = "description", name = "", order = 19},
				additionalHideConditions = {
					type = 'input',
					order = 20,
					name = "Hide Layout When",
					desc = 'Lets you specify a custom macro conditional to control in what situations the layout frames should be visible.\n\nSome possible values:\n[group:party] [group:raid] [combat] [vehicle] [flying] [form:N] [stealth]\n\nIMPORTANT: The result of the conditional ALWAYS has to return either a "0"(hidden) or a "1"(shown) in order to make it work!\n\n More info about this topic at: ' .. CD.MacroConditionalURL,
					multiline = true,
					width = 'full',
					get = function(info) return CO.db.profile.layout.stateControl[ info[#info] ] end,
					set = function(info, value) CO.db.profile.layout.stateControl[ info[#info] ] = value; LoadConfig() end,
					--hidden = function() return not CO.db.profile.layout.stateControl.autoHideGeneral end,
					--disabled = function() return not CO.db.profile.layout.stateControl.additionalHideConditions end,
				},
				resetCondition = {
					order = 22,
					type = "execute",
					name = L["DefVisibility"],
					desc = L["DefVisibilityDesc"],
					func = function()
						CO.db.profile.layout.stateControl.additionalHideConditions = E.ConfigDefaults.profile.layout.stateControl.additionalHideConditions
						LoadConfig()
					end,
					--hidden = function() return not CO.db.profile.layout.stateControl.autoHideGeneral end,
					--disabled = function() return not CO.db.profile.layout.stateControl.useCustomCondition end,
				},
			},
		},
		
		layoutFonts = {
			type = "group",
			name = L["LayoutFonts"],
			order = 2,
			childGroups = "tab",
			args = {
				layoutUpdateFrequency = {
					type = "range",
					order = 11,
					min = 0,
					max = 60,
					softMin = 0,
					softMax = 1,
					name = L["SystemUpdateFrequency"],
					desc = "Controls the amount of time (in seconds) that has to pass between each update of the FPS and Latency.\n0 = Real-Time\nYou can use hard values from 0 to 60\n\nThis feature may impact the games performance when using high update frequencies (Low values)",
					get = function() return CO.db.profile.layout.stateControl.layoutUpdateFrequency end,
					set = function(info, value) CO.db.profile.layout.stateControl.layoutUpdateFrequency = value end,
					disabled = function() return (not CO.db.profile.layout.fps.enable and not CO.db.profile.layout.ping.enable) end,
				},
				coordsUpdateFrequency = {
					type = "range",
					order = 12,
					min = 0,
					max = 60,
					softMin = 0,
					softMax = 1,
					name = L["CoordinatesUpdateFrequency"],
					desc = "Controls the amount of time (in seconds) that has to pass between each update.\n0 = Real-Time\nYou can use hard values from 0 to 60\n\nThis feature may impact the games performance when using high update frequencies (Low values)",
					get = function() return CO.db.profile.layout.stateControl.coordsUpdateFrequency end,
					set = function(info, value) CO.db.profile.layout.stateControl.coordsUpdateFrequency = value end,
					disabled = function() return (not CO.db.profile.layout.coordx.enable and not CO.db.profile.layout.coordy.enable) end,
				},
				layoutHeader = {
					order = 99,
					type = "header",
					name = L["AdvancedOptions"],
				},
			},
		},
	},
}


	local Fonts = {{Path = "db.profile.layout.fps", Order = 100, GroupName = L["FPS"]}, {Path = "db.profile.layout.ping", Order = 200, GroupName = L["Latency"]}, {Path = "db.profile.layout.zone", Order = 300, GroupName = L["Zone"]}, {Path = "db.profile.layout.coordx", Order = 400, GroupName = L["CoordinatesX"]},{Path = "db.profile.layout.coordy", Order = 500, GroupName = L["CoordinatesY"]}}
	for k,v in pairs(CD:GetFontOptions(Fonts)) do
		CD.Options.args.layout.args.layoutFonts.args[k] = v
	end
end

CD:RegisterConfigModule(Module, 'Advanced')