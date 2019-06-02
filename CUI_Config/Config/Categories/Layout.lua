local E, L = unpack(CUI) -- Engine
local CO, CD, L = E:LoadModules("Config", "Config_Dialog", "Locale")

local BarStyles = {
	["integrated"] = "Integrated",
	["integratedReversed"] = "Integrated (Reversed)",
	["integratedFlipped"] = "Integrated (Flipped)",
	["integratedReversedFlipped"] = "Integrated (Rev., Flipped)",
	["normal"] = "Normal Bar",
}

CD.Options.args.system = {
	type = "group",
	name = "System",
	order = 99999,
	childGroups = "tab",
	get = function(info) return CO.db.profile.system[ info[#info] ] end,
	set = function(info, value) CO.db.profile.system[ info[#info] ] = value; E:GetModule("Layout"):LoadProfile() end,
	args = {
		layoutFrames = {
			type = "group",
			name = "Layout Textures",
			order = 1,
			args = {
				layoutHeader = {
					order = 1,
					type = "header",
					name = "Toggle Layout Textures",
				},
				enableTop = {
					order = 2,
					type = "toggle",
					name = "Top Bar",
				},
				enableBottom = {
					order = 3,
					type = "toggle",
					name = "Bottom Bar",
				},
				enableBottomLeft = {
					order = 4,
					type = "toggle",
					name = "Bottom Left Corner",
				},
				enableBottomRight = {
					order = 5,
					type = "toggle",
					name = "Bottom Right Corner",
				},
			},
		},
		
		layoutFonts = {
			type = "group",
			name = "Layout Fonts",
			order = 2,
			childGroups = "tab",
			args = {
				layoutVarsHeader = {
					order = 10,
					type = "header",
					name = "Layout Variables",
				},
				layoutUpdateFrequency = {
					type = "range",
					order = 11,
					min = 0,
					max = 60,
					softMin = 0,
					softMax = 1,
					name = "Layout Update Frequency",
					desc = "Controls the amount of time that has to pass between each update of the FPS and Latency.\n0 = Real-Time\nYou can use hard values from 0 to 60\n\nThis feature may impact the games performance when using high update frequencies (Low values)",
					get = function() return CO.db.profile.system.layoutUpdateFrequency end,
					set = function(info, value) CO.db.profile.system.layoutUpdateFrequency = value end,
					disabled = function() return (not CO.db.profile.layout.fps.enable and not CO.db.profile.layout.ping.enable) end,
				},
				coordsUpdateFrequency = {
					type = "range",
					order = 12,
					min = 0,
					max = 60,
					softMin = 0,
					softMax = 1,
					name = "Coordinates Update Frequency",
					desc = "Controls the amount of time that has to pass between each update.\n0 = Real-Time\nYou can use hard values from 0 to 60\n\nThis feature may impact the games performance when using high update frequencies (Low values)",
					get = function() return CO.db.profile.system.coordsUpdateFrequency end,
					set = function(info, value) CO.db.profile.system.coordsUpdateFrequency = value end,
					disabled = function() return (not CO.db.profile.layout.coordx.enable and not CO.db.profile.layout.coordy.enable) end,
				},
				layoutHeader = {
					order = 99,
					type = "header",
					name = "Advanced Options",
				},
			},
		},
		
		barExperience = {
			type = "group",
			name = "Experience Bar",
			order = 3,
			childGroups = "tab",
			args = {
				barGroup = {
					type = "group",
					order = 1,
					name = "Bar",
					get = function(info) return CO.db.profile.layout.barExperience[ info[#info] ] end,
					set = function(info, value) CO.db.profile.layout.barExperience[ info[#info] ] = value; E:GetModule("Bar_Experience"):LoadProfile() end,
					args = {
						enable = {
							order = 0,
							type = "toggle",
							name = L["Enable"],
							width = "full",
						},
						positionHeader = {
							order = 1,
							type = "header",
							name = L["Positioning"],
						},
						position = {
							type = 'select',
							order = 2,
							name = "Position",
							desc = "Screen position of this frame",
							values = E.Positions,
							disabled = function() return not CO.db.profile.layout.barExperience.enable end,
						},
						offsetX = {
							order = 3,
							type = 'range',
							name = L["XOffset"],
							desc = "Allows hard values from -2000 to 2000",
							softMin = -200, softMax = 200, step = 1,
							min = -2000, max = 2000,
							disabled = function() return not CO.db.profile.layout.barExperience.enable end,
						},
						offsetY = {
							order = 4,
							type = 'range',
							name = L["YOffset"],
							desc = "Allows hard values from -2000 to 2000",
							softMin = -200, softMax = 200, step = 1,
							min = -2000, max = 2000,
							disabled = function() return not CO.db.profile.layout.barExperience.enable end,
						},
						styleHeader = {
							order = 9,
							type = "header",
							name = "Style",
						},
						style = {
							type = 'select',
							order = 10,
							name = "Bar Style",
							desc = "Choose a style for this bar!",
							values = BarStyles,
							disabled = function() return not CO.db.profile.layout.barExperience.enable end,
						},
						newLine3 = {type="description", name="", order = 15},
						width = {
							order = 16,
							type = 'range',
							name = L["Width"],
							desc = "Allows hard values from 1 to 10000",
							softMin = 1, softMax = 2500, step = 1,
							min = 1, max = 10000,
							disabled = function() return not CO.db.profile.layout.barExperience.enable end,
						},
						height = {
							order = 17,
							type = 'range',
							name = L["Height"],
							desc = "Allows hard values from 1 to 10000",
							softMin = 1, softMax = 2500, step = 1,
							min = 1, max = 10000,
							disabled = function() return not CO.db.profile.layout.barExperience.enable end,
						},
						borderSize = {
							order = 18,
							type = 'range',
							name = L["BorderSize"],
							min = -5, max = 5, step = 0.1,
							disabled = function() return (CO.db.profile.layout.barExperience.style == "integrated" or CO.db.profile.layout.barExperience.style == "integratedReversed" or not CO.db.profile.layout.barExperience.enable) end,
						},
						newLine2 = {type="description", name="", order = 20},
						backgroundColor = {
							name = L["BackgroundColor"],
							type = "color",
							hasAlpha = true,
							order = 21,
							get = function(info)
								local c = CO.db.profile.layout.barExperience.backgroundColor
								return c[1], c[2], c[3], c[4]
							end,
							set = function(info, r, g, b, a)
								local color = CO.db.profile.layout.barExperience.backgroundColor
								color[1], color[2], color[3], color[4] = r, g, b, a
								
								E:GetModule("Bar_Experience"):LoadProfile()
							end,
							disabled = function() return not CO.db.profile.layout.barExperience.enable end,
						},
						borderColor = {
							name = L["BorderColor"],
							type = "color",
							hasAlpha = true,
							order = 22,
							get = function(info)
								local c = CO.db.profile.layout.barExperience.borderColor
								return c[1], c[2], c[3], c[4]
							end,
							set = function(info, r, g, b, a)
								local color = CO.db.profile.layout.barExperience.borderColor
								color[1], color[2], color[3], color[4] = r, g, b, a
								
								E:GetModule("Bar_Experience"):LoadProfile()
							end,
							disabled = function() return (CO.db.profile.layout.barExperience.style == "integrated" or CO.db.profile.layout.barExperience.style == "integratedReversed" or not CO.db.profile.layout.barExperience.enable) end,
						},
						newLine1 = {type="description", name="", order = 30},
						reverseFill = {
							order = 31,
							type = "toggle",
							name = "Bar Inverse Fill",
							desc = "Inverts the Fill Direction",
							disabled = function() return (CO.db.profile.layout.barExperience.style == "integrated" or CO.db.profile.layout.barExperience.style == "integratedReversed" or not CO.db.profile.layout.barExperience.enable) end,
						},
						fillOrientation = {
							type = 'select',
							order = 32,
							name = "Fill Direction",
							desc = "How the individual bars should be filled. Vertical or Horizontal.",
							values = CD.SortBarOrientation,
							disabled = function() return (CO.db.profile.layout.barExperience.style == "integrated" or CO.db.profile.layout.barExperience.style == "integratedReversed" or not CO.db.profile.layout.barExperience.enable) end,
						},
					},
				},
				
			},
		},
		barAzerite = {
			type = "group",
			name = "Azerite Bar",
			order = 4,
			childGroups = "tab",
			args = {
				barGroup = {
					type = "group",
					order = 1,
					name = "Bar",
					get = function(info) return CO.db.profile.layout.barAzerite[ info[#info] ] end,
					set = function(info, value) CO.db.profile.layout.barAzerite[ info[#info] ] = value; E:GetModule("Bar_Azerite"):LoadProfile() end,
					args = {
						enable = {
							order = 0,
							type = "toggle",
							name = L["Enable"],
							width = "full",
						},
						positionHeader = {
							order = 1,
							type = "header",
							name = L["Positioning"],
						},
						position = {
							type = 'select',
							order = 2,
							name = "Position",
							desc = "Screen position of this frame",
							values = E.Positions,
							disabled = function() return not CO.db.profile.layout.barAzerite.enable end,
						},
						offsetX = {
							order = 3,
							type = 'range',
							name = L["XOffset"],
							desc = "Allows hard values from -2000 to 2000",
							softMin = -200, softMax = 200, step = 1,
							min = -2000, max = 2000,
							disabled = function() return not CO.db.profile.layout.barAzerite.enable end,
						},
						offsetY = {
							order = 4,
							type = 'range',
							name = L["YOffset"],
							desc = "Allows hard values from -2000 to 2000",
							softMin = -200, softMax = 200, step = 1,
							min = -2000, max = 2000,
							disabled = function() return not CO.db.profile.layout.barAzerite.enable end,
						},
						styleHeader = {
							order = 5,
							type = "header",
							name = "Style",
						},
						style = {
							type = 'select',
							order = 10,
							name = "Bar Style",
							desc = "Choose a style for this bar!",
							values = BarStyles,
							disabled = function() return not CO.db.profile.layout.barAzerite.enable end,
						},
						newLine3 = {type="description", name="", order = 15},
						width = {
							order = 16,
							type = 'range',
							name = L["Width"],
							desc = "Allows hard values from 1 to 10000",
							softMin = 1, softMax = 2500, step = 1,
							min = 1, max = 10000,
							disabled = function() return not CO.db.profile.layout.barAzerite.enable end,
						},
						height = {
							order = 17,
							type = 'range',
							name = L["Height"],
							desc = "Allows hard values from 1 to 10000",
							softMin = 1, softMax = 2500, step = 1,
							min = 1, max = 10000,
							disabled = function() return not CO.db.profile.layout.barAzerite.enable end,
						},
						borderSize = {
							order = 18,
							type = 'range',
							name = L["BorderSize"],
							min = -5, max = 5, step = 0.1,
							disabled = function() return (CO.db.profile.layout.barAzerite.style == "integrated" or CO.db.profile.layout.barAzerite.style == "integratedReversed" or not CO.db.profile.layout.barAzerite.enable) end,
						},
						newLine2 = {type="description", name="", order = 20},
						backgroundColor = {
							name = L["BackgroundColor"],
							type = "color",
							hasAlpha = true,
							order = 21,
							get = function(info)
								local c = CO.db.profile.layout.barAzerite.backgroundColor
								return c[1], c[2], c[3], c[4]
							end,
							set = function(info, r, g, b, a)
								local color = CO.db.profile.layout.barAzerite.backgroundColor
								color[1], color[2], color[3], color[4] = r, g, b, a
								
								E:GetModule("Bar_Azerite"):LoadProfile()
							end,
							disabled = function() return not CO.db.profile.layout.barAzerite.enable end,
						},
						borderColor = {
							name = L["BorderColor"],
							type = "color",
							hasAlpha = true,
							order = 22,
							get = function(info)
								local c = CO.db.profile.layout.barAzerite.borderColor
								return c[1], c[2], c[3], c[4]
							end,
							set = function(info, r, g, b, a)
								local color = CO.db.profile.layout.barAzerite.borderColor
								color[1], color[2], color[3], color[4] = r, g, b, a
								
								E:GetModule("Bar_Azerite"):LoadProfile()
							end,
							disabled = function() return (CO.db.profile.layout.barAzerite.style == "integrated" or CO.db.profile.layout.barAzerite.style == "integratedReversed" or not CO.db.profile.layout.barAzerite.enable) end,
						},
						newLine1 = {type="description", name="", order = 30},
						reverseFill = {
							order = 31,
							type = "toggle",
							name = "Bar Inverse Fill",
							desc = "Inverts the Fill Direction",
							disabled = function() return (CO.db.profile.layout.barAzerite.style == "integrated" or CO.db.profile.layout.barAzerite.style == "integratedReversed" or not CO.db.profile.layout.barAzerite.enable) end,
						},
						fillOrientation = {
							type = 'select',
							order = 32,
							name = "Fill Direction",
							desc = "How the individual bars should be filled. Vertical or Horizontal.",
							values = CD.SortBarOrientation,
							disabled = function() return (CO.db.profile.layout.barAzerite.style == "integrated" or CO.db.profile.layout.barAzerite.style == "integratedReversed" or not CO.db.profile.layout.barAzerite.enable) end,
						},
					},
				},
				
			},
		},
		barHonor = {
			type = "group",
			name = "Honor Bar",
			order = 5,
			childGroups = "tab",
			args = {
				barGroup = {
					type = "group",
					order = 1,
					name = "Bar",
					get = function(info) return CO.db.profile.layout.barHonor[ info[#info] ] end,
					set = function(info, value) CO.db.profile.layout.barHonor[ info[#info] ] = value; E:GetModule("Bar_Honor"):LoadProfile() end,
					args = {
						enable = {
							order = 0,
							type = "toggle",
							name = L["Enable"],
							width = "full",
						},
						positionHeader = {
							order = 1,
							type = "header",
							name = L["Positioning"],
						},
						position = {
							type = 'select',
							order = 2,
							name = "Position",
							desc = "Screen position of this frame",
							values = E.Positions,
							disabled = function() return not CO.db.profile.layout.barHonor.enable end,
						},
						offsetX = {
							order = 3,
							type = 'range',
							name = L["XOffset"],
							desc = "Allows hard values from -2000 to 2000",
							softMin = -200, softMax = 200, step = 1,
							min = -2000, max = 2000,
							disabled = function() return not CO.db.profile.layout.barHonor.enable end,
						},
						offsetY = {
							order = 4,
							type = 'range',
							name = L["YOffset"],
							desc = "Allows hard values from -2000 to 2000",
							softMin = -200, softMax = 200, step = 1,
							min = -2000, max = 2000,
							disabled = function() return not CO.db.profile.layout.barHonor.enable end,
						},
						styleHeader = {
							order = 10,
							type = "header",
							name = "Style",
						},
						style = {
							type = 'select',
							order = 11,
							name = "Bar Style",
							desc = "Choose a style for this bar!",
							values = BarStyles,
							disabled = function() return not CO.db.profile.layout.barHonor.enable end,
						},
						newLine3 = {type="description", name="", order = 12},
						width = {
							order = 13,
							type = 'range',
							name = L["Width"],
							desc = "Allows hard values from 1 to 10000",
							softMin = 1, softMax = 2500, step = 1,
							min = 1, max = 10000,
							disabled = function() return not CO.db.profile.layout.barHonor.enable end,
						},
						height = {
							order = 14,
							type = 'range',
							name = L["Height"],
							desc = "Allows hard values from 1 to 10000",
							softMin = 1, softMax = 2500, step = 1,
							min = 1, max = 10000,
							disabled = function() return not CO.db.profile.layout.barHonor.enable end,
						},
						borderSize = {
							order = 15,
							type = 'range',
							name = L["BorderSize"],
							min = -5, max = 5, step = 0.1,
							disabled = function() return (CO.db.profile.layout.barHonor.style == "integrated" or CO.db.profile.layout.barHonor.style == "integratedReversed" or not CO.db.profile.layout.barHonor.enable) end,
						},
						newLine2 = {type="description", name="", order = 16},
						borderColor = {
							name = L["BorderColor"],
							type = "color",
							hasAlpha = true,
							order = 17,
							get = function(info)
								local c = CO.db.profile.layout.barHonor.borderColor
								return c[1], c[2], c[3], c[4]
							end,
							set = function(info, r, g, b, a)
								local color = CO.db.profile.layout.barHonor.borderColor
								color[1], color[2], color[3], color[4] = r, g, b, a
								
								E:GetModule("Bar_Honor"):LoadProfile()
							end,
							disabled = function() return (CO.db.profile.layout.barHonor.style == "integrated" or CO.db.profile.layout.barHonor.style == "integratedReversed" or not CO.db.profile.layout.barHonor.enable) end,
						},
						overlayColor = {
							name = "Overlay Color",
							type = "color",
							hasAlpha = true,
							order = 18,
							get = function(info)
								local c = CO.db.profile.layout.barHonor.overlayColor
								return c[1], c[2], c[3], c[4]
							end,
							set = function(info, r, g, b, a)
								local color = CO.db.profile.layout.barHonor.overlayColor
								color[1], color[2], color[3], color[4] = r, g, b, a
								
								E:GetModule("Bar_Honor"):LoadProfile()
							end,
							disabled = function() return not CO.db.profile.layout.barHonor.enable end,
						},
						backgroundColor = {
							name = L["BackgroundColor"],
							type = "color",
							hasAlpha = true,
							order = 19,
							get = function(info)
								local c = CO.db.profile.layout.barHonor.backgroundColor
								return c[1], c[2], c[3], c[4]
							end,
							set = function(info, r, g, b, a)
								local color = CO.db.profile.layout.barHonor.backgroundColor
								color[1], color[2], color[3], color[4] = r, g, b, a
								
								E:GetModule("Bar_Honor"):LoadProfile()
							end,
							disabled = function() return not CO.db.profile.layout.barHonor.enable end,
						},
						newLine1 = {type="description", name="", order = 30},
						reverseFill = {
							order = 31,
							type = "toggle",
							name = "Bar Inverse Fill",
							desc = "Inverts the Fill Direction",
							disabled = function() return (CO.db.profile.layout.barHonor.style == "integrated" or CO.db.profile.layout.barHonor.style == "integratedReversed" or not CO.db.profile.layout.barHonor.enable) end,
						},
						fillOrientation = {
							type = 'select',
							order = 32,
							name = "Fill Direction",
							desc = "How the individual bars should be filled. Vertical or Horizontal.",
							values = CD.SortBarOrientation,
							disabled = function() return (CO.db.profile.layout.barHonor.style == "integrated" or CO.db.profile.layout.barHonor.style == "integratedReversed" or not CO.db.profile.layout.barHonor.enable) end,
						},
					},
				},
				
			},
		},
		barReputation = {
			type = "group",
			name = "Reputation Bar",
			order = 6,
			childGroups = "tab",
			args = {
				barGroup = {
					type = "group",
					order = 1,
					name = "Bar",
					get = function(info) return CO.db.profile.layout.barReputation[ info[#info] ] end,
					set = function(info, value) CO.db.profile.layout.barReputation[ info[#info] ] = value; E:GetModule("Bar_Reputation"):LoadProfile() end,
					args = {
						enable = {
							order = 0,
							type = "toggle",
							name = L["Enable"],
							width = "full",
						},
						positionHeader = {
							order = 1,
							type = "header",
							name = L["Positioning"],
						},
						position = {
							type = 'select',
							order = 2,
							name = "Position",
							desc = "Screen position of this frame",
							values = E.Positions,
							disabled = function() return not CO.db.profile.layout.barReputation.enable end,
						},
						offsetX = {
							order = 3,
							type = 'range',
							name = L["XOffset"],
							desc = "Allows hard values from -2000 to 2000",
							softMin = -200, softMax = 200, step = 1,
							min = -2000, max = 2000,
							disabled = function() return not CO.db.profile.layout.barReputation.enable end,
						},
						offsetY = {
							order = 4,
							type = 'range',
							name = L["YOffset"],
							desc = "Allows hard values from -2000 to 2000",
							softMin = -200, softMax = 200, step = 1,
							min = -2000, max = 2000,
							disabled = function() return not CO.db.profile.layout.barReputation.enable end,
						},
						styleHeader = {
							order = 10,
							type = "header",
							name = "Style",
						},
						style = {
							type = 'select',
							order = 11,
							name = "Bar Style",
							desc = "Choose a style for this bar!",
							values = BarStyles,
							disabled = function() return not CO.db.profile.layout.barReputation.enable end,
						},
						newLine3 = {type="description", name="", order = 12},
						width = {
							order = 13,
							type = 'range',
							name = L["Width"],
							desc = "Allows hard values from 1 to 10000",
							softMin = 1, softMax = 2500, step = 1,
							min = 1, max = 10000,
							disabled = function() return not CO.db.profile.layout.barReputation.enable end,
						},
						height = {
							order = 14,
							type = 'range',
							name = L["Height"],
							desc = "Allows hard values from 1 to 10000",
							softMin = 1, softMax = 2500, step = 1,
							min = 1, max = 10000,
							disabled = function() return not CO.db.profile.layout.barReputation.enable end,
						},
						borderSize = {
							order = 15,
							type = 'range',
							name = L["BorderSize"],
							min = -5, max = 5, step = 0.1,
							disabled = function() return (CO.db.profile.layout.barReputation.style == "integrated" or CO.db.profile.layout.barReputation.style == "integratedReversed" or not CO.db.profile.layout.barReputation.enable) end,
						},
						newLine2 = {type="description", name="", order = 16},
						borderColor = {
							name = L["BorderColor"],
							type = "color",
							hasAlpha = true,
							order = 17,
							get = function(info)
								local c = CO.db.profile.layout.barReputation.borderColor
								return c[1], c[2], c[3], c[4]
							end,
							set = function(info, r, g, b, a)
								local color = CO.db.profile.layout.barReputation.borderColor
								color[1], color[2], color[3], color[4] = r, g, b, a
								
								E:GetModule("Bar_Reputation"):LoadProfile()
							end,
							disabled = function() return (CO.db.profile.layout.barReputation.style == "integrated" or CO.db.profile.layout.barReputation.style == "integratedReversed" or not CO.db.profile.layout.barReputation.enable) end,
						},
						backgroundColor = {
							name = L["BackgroundColor"],
							type = "color",
							hasAlpha = true,
							order = 19,
							get = function(info)
								local c = CO.db.profile.layout.barReputation.backgroundColor
								return c[1], c[2], c[3], c[4]
							end,
							set = function(info, r, g, b, a)
								local color = CO.db.profile.layout.barReputation.backgroundColor
								color[1], color[2], color[3], color[4] = r, g, b, a
								
								E:GetModule("Bar_Reputation"):LoadProfile()
							end,
							disabled = function() return not CO.db.profile.layout.barReputation.enable end,
						},
						newLine1 = {type="description", name="", order = 30},
						reverseFill = {
							order = 31,
							type = "toggle",
							name = "Bar Inverse Fill",
							desc = "Inverts the Fill Direction",
							disabled = function() return (CO.db.profile.layout.barReputation.style == "integrated" or CO.db.profile.layout.barReputation.style == "integratedReversed" or not CO.db.profile.layout.barReputation.enable) end,
						},
						fillOrientation = {
							type = 'select',
							order = 32,
							name = "Fill Direction",
							desc = "How the individual bars should be filled. Vertical or Horizontal.",
							values = CD.SortBarOrientation,
							disabled = function() return (CO.db.profile.layout.barReputation.style == "integrated" or CO.db.profile.layout.barReputation.style == "integratedReversed" or not CO.db.profile.layout.barReputation.enable) end,
						},
					},
				},
				
			},
		},
	},
}


local Fonts = {{Path = "db.profile.layout.fps", Order = 100, GroupName = "FPS"}, {Path = "db.profile.layout.ping", Order = 200, GroupName = "Latency"}, {Path = "db.profile.layout.zone", Order = 300, GroupName = "Zone"}, {Path = "db.profile.layout.coordx", Order = 400, GroupName = "Coordinates X"},{Path = "db.profile.layout.coordy", Order = 500, GroupName = "Coordinates Y"}}
for k,v in pairs(CD:GetFontOptions(Fonts)) do
	CD.Options.args.system.args.layoutFonts.args[k] = v
end

CD.Options.args.system.args.layoutFonts.args.Zone.args.fontColor.hidden = true

local BEFonts = {{Path = "db.profile.layout.barExperience.font", Order = 100, GroupName = L["Font"]}}
for k,v in pairs(CD:GetFontOptions(BEFonts)) do
	CD.Options.args.system.args.barExperience.args[k] = v
end

local AZFonts = {{Path = "db.profile.layout.barAzerite.font", Order = 100, GroupName = L["Font"]}}
for k,v in pairs(CD:GetFontOptions(AZFonts)) do
	CD.Options.args.system.args.barAzerite.args[k] = v
end

local BHFonts = {{Path = "db.profile.layout.barHonor.font", Order = 100, GroupName = L["Font"]}}
for k,v in pairs(CD:GetFontOptions(BHFonts)) do
	CD.Options.args.system.args.barHonor.args[k] = v
end

local BRFonts = {{Path = "db.profile.layout.barReputation.font", Order = 100, GroupName = L["Font"]}}
for k,v in pairs(CD:GetFontOptions(BRFonts)) do
	CD.Options.args.system.args.barReputation.args[k] = v
end