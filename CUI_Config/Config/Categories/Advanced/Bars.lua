local E, L = unpack(CUI) -- Engine
local CO, CD = E:LoadModules("Config", "Config_Dialog")

local Module = {}
local BarStyles = {
	["integrated"] = "Integrated",
	["integratedReversed"] = "Integrated (Reversed)",
	["integratedFlipped"] = "Integrated (Flipped)",
	["integratedReversedFlipped"] = "Integrated (Rev., Flipped)",
	["normal"] = "Normal Bar",
}

function Module:Disable()
	CD.Options.args.bars = nil
end

function Module:Enable()	
	CD.Options.args.bars = {
	type = "group",
	name = L["Bars"],
	order = 99999,
	childGroups = "tab",
	args = {
		general = {
			type = "group",
			name = L["General"],
			order = 1,
			childGroups = "tab",
			args = {
				mainBarTexture = {
					type = "select", dialogControl = 'LSM30_Statusbar',
					order = index,
					name = L["BarTexture"],
					desc = "Main statusbar texture.",
					values = CO.AceGUIWidgetLSMlists["statusbar"],
					get = function(info) return CO.db.profile.unitframe.units.all.barTexture end,
					set = function(info, value) CO.db.profile.unitframe.units.all.barTexture = value; E:UpdateAllBarTextures() end,
				},
			},
		},
		barExperience = {
			type = "group",
			name = L["Experience"],
			order = 3,
			childGroups = "tab",
			args = {
				barGroup = {
					type = "group",
					order = 1,
					name = L["Bar"],
					get = function(info) return CO.db.profile.layout.barExperience[ info[#info] ] end,
					set = function(info, value) CO.db.profile.layout.barExperience[ info[#info] ] = value; E:LoadModule("Bar_Experience"):LoadConfig() end,
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
							name = L["BarStyle"],
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
							softMin = 1, softMax = floor(GetScreenWidth()), step = 1,
							min = 1, max = 10000,
							disabled = function() return not CO.db.profile.layout.barExperience.enable end,
						},
						height = {
							order = 17,
							type = 'range',
							name = L["Height"],
							desc = "Allows hard values from 1 to 10000",
							softMin = 1, softMax = floor(GetScreenHeight()), step = 1,
							min = 1, max = 10000,
							disabled = function() return not CO.db.profile.layout.barExperience.enable end,
						},
						borderSize = {
							order = 18,
							type = 'range',
							name = L["BorderSize"],
							min = 0, max = 5, step = 0.1,
							set = function(info, value)
								if value == 0 then
									value = 0.1
								end
								
								CO.db.profile.layout.barExperience[ info[#info] ] = value; E:LoadModule("Bar_Experience"):LoadConfig()
							end,
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
								
								E:LoadModule("Bar_Experience"):LoadConfig()
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
								
								E:LoadModule("Bar_Experience"):LoadConfig()
							end,
							disabled = function() return (CO.db.profile.layout.barExperience.style == "integrated" or CO.db.profile.layout.barExperience.style == "integratedReversed" or not CO.db.profile.layout.barExperience.enable) end,
						},
						newLine1 = {type="description", name="", order = 30},
						reverseFill = {
							order = 31,
							type = "toggle",
							name = L["BarFillInverse"],
							desc = "Inverts the Fill Direction",
							disabled = function() return (CO.db.profile.layout.barExperience.style == "integrated" or CO.db.profile.layout.barExperience.style == "integratedReversed" or not CO.db.profile.layout.barExperience.enable) end,
						},
						fillOrientation = {
							type = 'select',
							order = 32,
							name = L["BarFillDirection"],
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
			name = L["Azerite"],
			order = 4,
			childGroups = "tab",
			args = {
				barGroup = {
					type = "group",
					order = 1,
					name = L["Bar"],
					get = function(info) return CO.db.profile.layout.barAzerite[ info[#info] ] end,
					set = function(info, value) CO.db.profile.layout.barAzerite[ info[#info] ] = value; E:LoadModule("Bar_Azerite"):LoadConfig() end,
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
							name = L["BarStyle"],
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
							softMin = 1, softMax = floor(GetScreenWidth()), step = 1,
							min = 1, max = 10000,
							disabled = function() return not CO.db.profile.layout.barAzerite.enable end,
						},
						height = {
							order = 17,
							type = 'range',
							name = L["Height"],
							desc = "Allows hard values from 1 to 10000",
							softMin = 1, softMax = floor(GetScreenHeight()), step = 1,
							min = 1, max = 10000,
							disabled = function() return not CO.db.profile.layout.barAzerite.enable end,
						},
						borderSize = {
							order = 18,
							type = 'range',
							name = L["BorderSize"],
							min = 0, max = 5, step = 0.1,
							set = function(info, value)
								if value == 0 then
									value = 0.1
								end
								
								CO.db.profile.layout.barAzerite[ info[#info] ] = value; E:LoadModule("Bar_Azerite"):LoadConfig() 
							end,
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
								
								E:LoadModule("Bar_Azerite"):LoadConfig()
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
								
								E:LoadModule("Bar_Azerite"):LoadConfig()
							end,
							disabled = function() return (CO.db.profile.layout.barAzerite.style == "integrated" or CO.db.profile.layout.barAzerite.style == "integratedReversed" or not CO.db.profile.layout.barAzerite.enable) end,
						},
						newLine1 = {type="description", name="", order = 30},
						reverseFill = {
							order = 31,
							type = "toggle",
							name = L["BarFillInverse"],
							desc = "Inverts the Fill Direction",
							disabled = function() return (CO.db.profile.layout.barAzerite.style == "integrated" or CO.db.profile.layout.barAzerite.style == "integratedReversed" or not CO.db.profile.layout.barAzerite.enable) end,
						},
						fillOrientation = {
							type = 'select',
							order = 32,
							name = L["BarFillDirection"],
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
			name = L["Honor"],
			order = 5,
			childGroups = "tab",
			args = {
				barGroup = {
					type = "group",
					order = 1,
					name = L["Bar"],
					get = function(info) return CO.db.profile.layout.barHonor[ info[#info] ] end,
					set = function(info, value) CO.db.profile.layout.barHonor[ info[#info] ] = value; E:LoadModule("Bar_Honor"):LoadConfig() end,
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
							name = L["BarStyle"],
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
							softMin = 1, softMax = floor(GetScreenWidth()), step = 1,
							min = 1, max = 10000,
							disabled = function() return not CO.db.profile.layout.barHonor.enable end,
						},
						height = {
							order = 14,
							type = 'range',
							name = L["Height"],
							desc = "Allows hard values from 1 to 10000",
							softMin = 1, softMax = floor(GetScreenHeight()), step = 1,
							min = 1, max = 10000,
							disabled = function() return not CO.db.profile.layout.barHonor.enable end,
						},
						borderSize = {
							order = 15,
							type = 'range',
							name = L["BorderSize"],
							min = 0, max = 5, step = 0.1,
							set = function(info, value)
								if value == 0 then
									value = 0.1
								end
								
								CO.db.profile.layout.barHonor[ info[#info] ] = value; E:LoadModule("Bar_Honor"):LoadConfig() 
							end,
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
								
								E:LoadModule("Bar_Honor"):LoadConfig()
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
								
								E:LoadModule("Bar_Honor"):LoadConfig()
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
								
								E:LoadModule("Bar_Honor"):LoadConfig()
							end,
							disabled = function() return not CO.db.profile.layout.barHonor.enable end,
						},
						newLine1 = {type="description", name="", order = 30},
						reverseFill = {
							order = 31,
							type = "toggle",
							name = L["BarFillInverse"],
							desc = "Inverts the Fill Direction",
							disabled = function() return (CO.db.profile.layout.barHonor.style == "integrated" or CO.db.profile.layout.barHonor.style == "integratedReversed" or not CO.db.profile.layout.barHonor.enable) end,
						},
						fillOrientation = {
							type = 'select',
							order = 32,
							name = L["BarFillDirection"],
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
			name = L["Reputation"],
			order = 6,
			childGroups = "tab",
			args = {
				barGroup = {
					type = "group",
					order = 1,
					name = L["Bar"],
					get = function(info) return CO.db.profile.layout.barReputation[ info[#info] ] end,
					set = function(info, value) CO.db.profile.layout.barReputation[ info[#info] ] = value; E:LoadModule("Bar_Reputation"):LoadConfig() end,
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
							name = L["BarStyle"],
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
							softMin = 1, softMax = floor(GetScreenWidth()), step = 1,
							min = 1, max = 10000,
							disabled = function() return not CO.db.profile.layout.barReputation.enable end,
						},
						height = {
							order = 14,
							type = 'range',
							name = L["Height"],
							desc = "Allows hard values from 1 to 10000",
							softMin = 1, softMax = floor(GetScreenHeight()), step = 1,
							min = 1, max = 10000,
							disabled = function() return not CO.db.profile.layout.barReputation.enable end,
						},
						borderSize = {
							order = 15,
							type = 'range',
							name = L["BorderSize"],
							min = 0, max = 5, step = 0.1,
							set = function(info, value)
								if value == 0 then
									value = 0.1
								end
								
								CO.db.profile.layout.barReputation[ info[#info] ] = value; E:LoadModule("Bar_Reputation"):LoadConfig() 
							end,
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
								
								E:LoadModule("Bar_Reputation"):LoadConfig()
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
								
								E:LoadModule("Bar_Reputation"):LoadConfig()
							end,
							disabled = function() return not CO.db.profile.layout.barReputation.enable end,
						},
						newLine1 = {type="description", name="", order = 30},
						reverseFill = {
							order = 31,
							type = "toggle",
							name = L["BarFillInverse"],
							desc = "Inverts the Fill Direction",
							disabled = function() return (CO.db.profile.layout.barReputation.style == "integrated" or CO.db.profile.layout.barReputation.style == "integratedReversed" or not CO.db.profile.layout.barReputation.enable) end,
						},
						fillOrientation = {
							type = 'select',
							order = 32,
							name = L["BarFillDirection"],
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

	local BEFonts = {{Path = "db.profile.layout.barExperience.font", Order = 100, GroupName = L["Font"]}}
	for k,v in pairs(CD:GetFontOptions(BEFonts)) do
	CD.Options.args.bars.args.barExperience.args[k] = v
	end

	local AZFonts = {{Path = "db.profile.layout.barAzerite.font", Order = 100, GroupName = L["Font"]}}
	for k,v in pairs(CD:GetFontOptions(AZFonts)) do
	CD.Options.args.bars.args.barAzerite.args[k] = v
	end

	local BHFonts = {{Path = "db.profile.layout.barHonor.font", Order = 100, GroupName = L["Font"]}}
	for k,v in pairs(CD:GetFontOptions(BHFonts)) do
	CD.Options.args.bars.args.barHonor.args[k] = v
	end

	local BRFonts = {{Path = "db.profile.layout.barReputation.font", Order = 100, GroupName = L["Font"]}}
	for k,v in pairs(CD:GetFontOptions(BRFonts)) do
	CD.Options.args.bars.args.barReputation.args[k] = v
	end
end

CD:RegisterConfigModule(Module, 'Advanced')