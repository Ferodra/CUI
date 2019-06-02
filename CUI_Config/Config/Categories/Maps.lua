local E, L = unpack(CUI) -- Engine
local CO, CD, L = E:LoadModules("Config", "Config_Dialog", "Locale")

local _

CD.Options.args.maps = {
	name = L["Maps"],
	type = 'group',
	order = 99999,
	disabled = false,
	childGroups = "tab",
	args = {
---------------------------------------------
-- MINIMAP
---------------------------------------------
		minimapGroup = {
			name = L["Minimap"],
			type = 'group',
			order = 1,
			childGroups = "tab",
			args = {
				generalGroup = {
					type = "group",
					name = L["General"],
					order = 1,
					args = {
						minimapPositioning = {
							order = 1,
							type = "header",
							name = L["Positioning"],
						},
						minimapHeader = {
							order = 20,
							type = "header",
							name = "Styling",
						},
						scale = {
							order = 22,
							type = 'range',
							name = L["Scale"],
							desc = "Set the minimap scaling factor",
							min = 0.01, max = 10, step = 0.01,
							width = "full",
							get = function() return CO.db.profile.minimap.scale end,
							set = function(info, value) CO.db.profile.minimap.scale = value; E:GetModule("Minimap"):LoadProfile(); end,
						},
					},
				},
				vanillaGroup = {
					type = "group",
					name = "Vanilla Buttons",
					order = 100,
					args = {
						zoneText = {
							order = 23,
							type = 'toggle',
							name = "Zone Text",
							get = function() return CO.db.profile.minimap.zoneText.enable end,
							set = function(info, value) CO.db.profile.minimap.zoneText.enable = value; E:GetModule("Minimap"):LoadProfile(); end,
						},
						worldMapButton = {
							order = 24,
							type = 'toggle',
							name = "Worldmap Button",
							get = function() return CO.db.profile.minimap.worldMapButton.enable end,
							set = function(info, value) CO.db.profile.minimap.worldMapButton.enable = value; E:GetModule("Minimap"):LoadProfile(); end,
						},
						mailIcon = {
							order = 24,
							type = 'toggle',
							name = "Mail Icon",
							get = function() return CO.db.profile.minimap.mailIcon.enable end,
							set = function(info, value) CO.db.profile.minimap.mailIcon.enable = value; E:GetModule("Minimap"):LoadProfile(); end,
						},
					}
				},
				customGroup = {
					type = "group",
					name = "Custom Buttons",
					order = 200,
					args = {
						customMailIcon = {
							order = 1,
							type = 'toggle',
							name = "Custom Mail Icon",
							get = function() return CO.db.profile.minimap.customMailIcon.enable end,
							set = function(info, value) CO.db.profile.minimap.customMailIcon.enable = value; E:GetModule("Minimap"):LoadProfile(); end,
						},
					}
				},
				
			},
		},
---------------------------------------------
-- WORLDMAP
---------------------------------------------
		worldmapGroup = {
			name = L["Worldmap"],
			type = 'group',
			order = 2,
			childGroups = "tab",
			args = {
				MapGroup = {
					name = L["Map"],
					type = 'group',
					order = 1,
					args = {
					
					},
				},
			},
		},
		
	},
}

do
	for k,v in pairs(CD:GetMoverOptions("CUI_MinimapHolderMover", 2, true)) do
		CD.Options.args.maps.args.minimapGroup.args.generalGroup.args[k] = v
	end
	
	local Fonts = {{Path = "db.profile.worldmap.coords", Order = 100, GroupName = L["Coordinates"]}}
	for k,v in pairs(CD:GetFontOptions(Fonts)) do
		CD.Options.args.maps.args.worldmapGroup.args[k] = v
	end
end