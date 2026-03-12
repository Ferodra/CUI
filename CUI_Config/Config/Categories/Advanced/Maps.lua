local E, L = unpack(CUI) -- Engine
local CO, CD = E:LoadModules("Config", "Config_Dialog")

local _
local Module = {}

function Module:Disable()
	CD.Options.args.maps = nil
end

function Module:Enable()
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
					enable = {
						type = "toggle",
						order = 1,
						name = L['EnableModule'],
						get = function() return CO.db.char.minimap.enable end,
						set = function(info, value) CO.db.char.minimap.enable = value; CD:ShowNotification('CHARACTERSETTING_NOTIFICATION') end,
					},
					generalGroup = {
						type = "group",
						name = L["General"],
						order = 1,
						disabled = function() return CO.db.char.minimap.enable end,
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
								set = function(info, value) CO.db.profile.minimap.scale = value; E:LoadModule("Minimap"):LoadConfig(); end,
							},
							BorderGroup = {
								type = "group",
								name = "Minimap Border",
								order = 23,
								guiInline = true,
								args = {
									rgbaUseClassColor = {
										type = "toggle",
										order = 1,
										name = L["UseClassColor"],
										desc = L["UseClassColorDesc"],
										get = function() return CO.db.profile.minimap.borderColor.useClassColor end,
										set = function(info, value) CO.db.profile.minimap.borderColor.useClassColor = value; E:LoadModule("Minimap"):LoadConfig(); end,
									},
									rgba = {
										name = L["Color"],
										type = "color",
										hasAlpha = true,
										order = 2,
										get = function(info)
											local c = E:ParseDBColor(CO.db.profile.minimap.borderColor)
											return c[1], c[2], c[3], c[4] or 1
										end,
										set = function(info, r, g, b, a)
											local c = E:ParseDBColor(CO.db.profile.minimap.borderColor)
											c[1], c[2], c[3], c[4] = r, g, b, a or 1
											
											E:LoadModule("Minimap"):LoadConfig();
										end,
										disabled = function() return CO.db.profile.minimap.borderColor.useClassColor end,
									},
								},
							},
							addonIconsGroup = {
								type = "group",
								name = "Addon Icon Border",
								order = 23,
								guiInline = true,
								args = {
									rgbaUseClassColor = {
										type = "toggle",
										order = 26,
										name = L["UseClassColor"],
										desc = L["UseClassColorDesc"],
										get = function() return CO.db.profile.minimap.dbIconRgb.useClassColor end,
										set = function(info, value) CO.db.profile.minimap.dbIconRgb.useClassColor = value; E:LoadModule("Minimap"):LoadConfig(); end,
									},
									rgba = {
										name = L["Color"],
										type = "color",
										hasAlpha = true,
										order = 27,
										get = function(info)
											local c = E:ParseDBColor(CO.db.profile.minimap.dbIconRgb)
											return c[1], c[2], c[3], c[4] or 1
										end,
										set = function(info, r, g, b, a)
											local c = E:ParseDBColor(CO.db.profile.minimap.dbIconRgb)
											c[1], c[2], c[3], c[4] = r, g, b, a or 1
											
											E:LoadModule("Minimap"):LoadConfig();
										end,
										disabled = function() return CO.db.profile.minimap.dbIconRgb.useClassColor end,
									},
								},
							},							
						},
					},
					clockGroup = {
						type = "group",
						name = L["Clock"],
						order = 5,
						childGroups = "tab",
						get = function(info) return CO.db.profile.minimap.clock[ info[#info] ] end,
						set = function(info, value) CO.db.profile.minimap.clock[ info[#info] ] = value; E:LoadModule("Minimap"):LoadConfig(); end,
						disabled = function() return CO.db.char.minimap.enable end,
						args = {
							generalGroup = {
								type = "group",
								name = L["General"],
								order = 1,
								args = {
									position = {
										type = 'select',
										order = 1,
										name = L["Position"],
										values = E.Positions,
									},
									xOffset = {
										order = 2,
										type = 'range',
										name = L["XOffset"],
										min = -300, max = 300, step = 1,
									},
									yOffset = {
										order = 3,
										type = 'range',
										name = L["YOffset"],
										min = -300, max = 300, step = 1,
									},
									newLine = CD:GetNewLine(5),
									width = {
										order = 10,
										type = 'range',
										name = L["Width"],
										min = 1, max = 800, step = 1,
										--disabled = DisabledFunc,
									},
									height = {
										order = 11,
										type = 'range',
										name = L["Height"],
										min = 1, max = 800, step = 1,
										--disabled = DisabledFunc,
									},
									newLine2 = CD:GetNewLine(15),
									
									backgroundGroup = {
										type = "group",
										name = "Background",
										order = 16,
										guiInline = true,
										args = {
											rgbaUseClassColor = {
												type = "toggle",
												order = 26,
												name = L["UseClassColor"],
												desc = L["UseClassColorDesc"],
												get = function() return CO.db.profile.minimap.clock.backgroundColor.useClassColor end,
												set = function(info, value) CO.db.profile.minimap.clock.backgroundColor.useClassColor = value; E:LoadModule("Minimap"):LoadConfig(); end,
											},
											rgba = {
												name = L["Color"],
												type = "color",
												hasAlpha = true,
												order = 27,
												get = function(info)
													local c = E:ParseDBColor(CO.db.profile.minimap.clock.backgroundColor)
													return c[1], c[2], c[3], c[4] or 1
												end,
												set = function(info, r, g, b, a)
													local c = E:ParseDBColor(CO.db.profile.minimap.clock.backgroundColor)
													c[1], c[2], c[3], c[4] = r, g, b, a or 1
													
													E:LoadModule("Minimap"):LoadConfig();
												end,
												--disabled = function() return CO.db.profile.minimap.clock.backgroundColor.useClassColor end,
											},
										},
									},
									borderGroup = {
										type = "group",
										name = "Border",
										order = 17,
										guiInline = true,
										args = {
											rgbaUseClassColor = {
												type = "toggle",
												order = 26,
												name = L["UseClassColor"],
												desc = L["UseClassColorDesc"],
												get = function() return CO.db.profile.minimap.clock.borderColor.useClassColor end,
												set = function(info, value) CO.db.profile.minimap.clock.borderColor.useClassColor = value; E:LoadModule("Minimap"):LoadConfig(); end,
											},
											rgba = {
												name = L["Color"],
												type = "color",
												hasAlpha = true,
												order = 27,
												get = function(info)
													local c = E:ParseDBColor(CO.db.profile.minimap.clock.borderColor)
													return c[1], c[2], c[3], c[4] or 1
												end,
												set = function(info, r, g, b, a)
													local c = E:ParseDBColor(CO.db.profile.minimap.clock.borderColor)
													c[1], c[2], c[3], c[4] = r, g, b, a or 1
													
													E:LoadModule("Minimap"):LoadConfig();
												end,
												--disabled = function() return CO.db.profile.minimap.clock.borderColor.useClassColor end,
											},
										},
									},	
								},
							},
							
						},
					},
					vanillaGroup = {
						type = "group",
						name = "Vanilla Buttons",
						order = 100,
						disabled = function() return CO.db.char.minimap.enable end,
						args = {
							zoneText = {
								order = 23,
								type = 'toggle',
								name = "Zone Text",
								get = function() return CO.db.profile.minimap.zoneText.enable end,
								set = function(info, value) CO.db.profile.minimap.zoneText.enable = value; E:LoadModule("Minimap"):LoadConfig(); end,
							},
							worldMapButton = {
								order = 24,
								type = 'toggle',
								name = "Worldmap Button",
								get = function() return CO.db.profile.minimap.worldMapButton.enable end,
								set = function(info, value) CO.db.profile.minimap.worldMapButton.enable = value; E:LoadModule("Minimap"):LoadConfig(); end,
							},
							mailIcon = {
								order = 24,
								type = 'toggle',
								name = "Mail Icon",
								get = function() return CO.db.profile.minimap.mailIcon.enable end,
								set = function(info, value) CO.db.profile.minimap.mailIcon.enable = value; E:LoadModule("Minimap"):LoadConfig(); end,
							},
						}
					},
					customGroup = {
						type = "group",
						name = "Custom Buttons",
						order = 200,
						disabled = function() return CO.db.char.minimap.enable end,
						args = {
							customMailIcon = {
								order = 1,
								type = 'toggle',
								name = "Custom Mail Icon",
								get = function() return CO.db.profile.minimap.customMailIcon.enable end,
								set = function(info, value) CO.db.profile.minimap.customMailIcon.enable = value; E:LoadModule("Minimap"):LoadConfig(); end,
							},
							generalGroup = {
								type = "group",
								name = L["Mail Icon"],
								order = 2,
								guiInline = true,
								get = function(info) return CO.db.profile.minimap.customMailIcon[ info[#info] ] end,
								set = function(info, value) CO.db.profile.minimap.customMailIcon[ info[#info] ] = value; E:LoadModule("Minimap"):LoadConfig(); end,
								hidden = function() return not CO.db.profile.minimap.customMailIcon.enable end,
								args = {
									position = {
										type = 'select',
										order = 1,
										name = L["Position"],
										values = E.Positions,
									},
									xOffset = {
										order = 2,
										type = 'range',
										name = L["XOffset"],
										min = -300, max = 300, step = 1,
									},
									yOffset = {
										order = 3,
										type = 'range',
										name = L["YOffset"],
										min = -300, max = 300, step = 1,
									},
									scale = {
										order = 4,
										type = 'range',
										name = L["Scale"],
										min = 0.1, max = 5, step = 0.1,
									},
									newLine = CD:GetNewLine(5),
									rgbaUseClassColor = {
										type = "toggle",
										order = 6,
										name = L["UseClassColor"],
										desc = L["UseClassColorDesc"],
										get = function() return CO.db.profile.minimap.customMailIcon.rgba.useClassColor end,
										set = function(info, value) CO.db.profile.minimap.customMailIcon.rgba.useClassColor = value; E:LoadModule("Minimap"):LoadConfig(); end,
									},
									rgba = {
										name = L["Color"],
										type = "color",
										hasAlpha = true,
										order = 7,
										get = function(info)
											local c = E:ParseDBColor(CO.db.profile.minimap.customMailIcon.rgba)
											return c[1], c[2], c[3], c[4] or 1
										end,
										set = function(info, r, g, b, a)
											local c = E:ParseDBColor(CO.db.profile.minimap.customMailIcon.rgba)
											c[1], c[2], c[3], c[4] = r, g, b, a or 1
											
											E:LoadModule("Minimap"):LoadConfig();
										end,
										--disabled = function() return CO.db.profile.minimap.clock.backgroundColor.useClassColor end,
									},
								},
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
					-- MapGroup = {
						-- name = L["Map"],
						-- type = 'group',
						-- order = 1,
						-- args = {
						
						-- },
					-- },
				},
			},
			
		},
	}

	do
		for k,v in pairs(CD:GetMoverOptions("CUI_MinimapHolderMover", 2, true)) do
			CD.Options.args.maps.args.minimapGroup.args.generalGroup.args[k] = v
		end
		
		local WorldmapFonts = {{Path = "db.profile.worldmap.coords", Order = 100, GroupName = L["Coordinates"]}}
		for k,v in pairs(CD:GetFontOptions(WorldmapFonts)) do
			CD.Options.args.maps.args.worldmapGroup.args[k] = v
		end
		
		local MinimapFonts = {{Path = "db.profile.minimap.clock.text", Order = 5, GroupName = L["Time"]}}
		for k,v in pairs(CD:GetFontOptions(MinimapFonts)) do
			CD.Options.args.maps.args.minimapGroup.args.clockGroup.args[k] = v
		end
	end
end

CD:RegisterConfigModule(Module, 'Advanced')