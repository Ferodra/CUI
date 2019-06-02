local E, L = unpack(CUI) -- Engine
local CO, CD, L = E:LoadModules("Config", "Config_Dialog", "Locale")

--------------------------------------------------------------------
local _
local format			= string.format
local pairs				= pairs
--------------------------------------------------------------------

local Index = 99999

local AllFonts = {"%s", "stancebar", "zonebar", "extrabar", "petbar"}
local TempConfig_ArtFill = { }
local TempConfig_Font = { ["hotkey"] = {}, ["cooldown"] = {}, ["count"] = {}, ["macro"] = {} }
local FlyOutDirections = { ["UP"] = L["Up"], ["LEFT"] = L["Left"], ["RIGHT"] = L["Right"], ["DOWN"] = L["Down"] }
local ShowTooltipConditions = { ["disabled"] = L["Disabled"], ["enabled"] = L["Enabled"], ["nocombat"] = L["Hide in Combat"] }
local BarFade = {["none"] = L["DoNothing"], ["fadeOut"] = L["FadeOut"], ["fadeIn"] = L["FadeIn"]}

local function UpdateFont(bar)
	-- Check if target exists
	local target = E:GetTablePath(format("db.profile.actionbar.%s", bar), CO)
	if target then
		for type, _ in pairs(TempConfig_Font) do
			if target[type] then
				for k, v in pairs(TempConfig_Font[type]) do
					target[type][k] = v
				end
			end
		end
	end
end
local function UpdateAllFonts()
	for k,v in pairs(AllFonts) do
		if v == "%s" then
			for i = 1, 10 do
				UpdateFont(format("bar%s", i))
			end
		else
			UpdateFont(v)
		end
	end
	
	E:UpdateAllFonts()
end

local function UpdateArtFill(type)
	-- Check if target exists
	local target = E:GetTablePath(format("db.profile.actionbar.%s.artFill", type), CO)
	
	if target then
		for k, v in pairs(TempConfig_ArtFill) do
			target[k] = v
		end
	end
end

local function UpdateAllArtFill()
	for k,v in pairs(AllFonts) do
		if v == "%s" then
			for i = 1, 10 do
				UpdateArtFill(format("bar%s", i))
			end
		else
			UpdateArtFill(v)
		end
	end
	
	E:GetModule("Actionbars"):UpdateArtFill()
end

local function GetOptionsTable_AllBackground(order)
	local config = {
		type = "group",
		order = order,
		name = L["Background"],
		get = function(info) return TempConfig_ArtFill[ info[#info] ] end,
		set = function(info, value) TempConfig_ArtFill[ info[#info] ] = value; UpdateAllArtFill() end,
		args = {
			enable = {
				type = "toggle",
				order = 1,
				name = L["Enable"],
				width = "full",
			},
			valuesHeader = {
				type = "header",
				name = L["Values"],
				order = 10,
			},
			paddingX = {
				order = 11,
				type = 'range',
				name = L["PaddingH"],
				desc = L["PaddingHDesc"],
				min = 0, max = 50, step = 0.1,
			},
			paddingY = {
				order = 12,
				type = 'range',
				name = L["PaddingV"],
				desc = L["PaddingVDesc"],
				min = 0, max = 50, step = 1,
			},
			borderSize = {
				order = 13,
				type = 'range',
				name = L["BorderSize"],
				min = -5, max = 5, step = 0.1,
			},
			colorHeader = {
				type = "header",
				name = L["Colors"],
				order = 20,
			},
			borderColor = {
				name = L["BorderColor"],
				type = "color",
				hasAlpha = true,
				order = 21,
				get = function(info)
					local c = TempConfig_ArtFill.borderColor or {0,0,0,1}
					return c[1], c[2], c[3], c[4]
				end,
				set = function(info, r, g, b, a)
					if not TempConfig_ArtFill.borderColor then TempConfig_ArtFill.borderColor = {0,0,0,1} end
					local c = TempConfig_ArtFill.borderColor
					c[1], c[2], c[3], c[4] = r, g, b, a
					E:GetModule("Actionbars"):UpdateArtFill();
				end,
			},
			backgroundColor = {
				name = L["BackgroundColor"],
				type = "color",
				hasAlpha = true,
				order = 22,
				get = function(info)
					local c = TempConfig_ArtFill.backgroundColor or {0.1,0.1,0.1,1}
					return c[1], c[2], c[3], c[4]
				end,
				set = function(info, r, g, b, a)
					if not TempConfig_ArtFill.backgroundColor then TempConfig_ArtFill.backgroundColor = {0.1,0.1,0.1,1} end
					local c = TempConfig_ArtFill.backgroundColor
					c[1], c[2], c[3], c[4] = r, g, b, a
					UpdateAllArtFill()
				end,
			},
		},
	}
	
	return config
end

-- We have to override some provided default setters/getters here to make this work
local function GetOptionsTable_AllFonts(type, order)
	
	-- We need one group for each font type
	local config = {
		type = "group",
		order = order,
		name = L[E:firstToUpper(type)],
		get = function(info) return TempConfig_Font[type][ info[#info] ] end,
		set = function(info, value) TempConfig_Font[type][ info[#info] ] = value; UpdateAllFonts() end,
		args = CD:AddFontOptions()
	}
	
	-- Should not be affected by disabled state
	for k,v in pairs(config.args) do
		if v.disabled then
			v.disabled = false
		end
		if k == "fontColor" then
			v.get = function(info)
					local c = TempConfig_Font[type].fontColor or {1,1,1,1}
					
					return c[1], c[2], c[3], c[4]
			end
			v.set = function(info, r, g, b, a)
					if not TempConfig_Font[type].fontColor then TempConfig_Font[type].fontColor = {1,1,1,1} end
					local color = TempConfig_Font[type].fontColor
					
					color[1], color[2], color[3], color[4] = r, g, b, a
					UpdateAllFonts()
			end
		elseif k == "fontShadowColor" then
			v.get = function(info)
					local c = TempConfig_Font[type].fontShadowColor or {1,1,1,1}
					
					return c[1], c[2], c[3], c[4]
			end
			v.set = function(info, r, g, b, a)
					if not TempConfig_Font[type].fontShadowColor then TempConfig_Font[type].fontShadowColor = {0,0,0,0} end
					local color = TempConfig_Font[type].fontShadowColor
					
					
					color[1], color[2], color[3], color[4] = r, g, b, a
					UpdateAllFonts()
			end
		end
		if k == "enable" then
			v.hidden = true
		end
	end
	
	config.args.warning = {
		type = "description",
		order = 1,
		name = "|cffFF0000" .. L["AllWarning"] .."\n\n|r",
		fontSize = "small",
	}
	
	return config
end

local function GetOptionsTable_Actionbar(index, indexOrder)
	
	local barNum = "bar" .. index
	local config = {
		order = indexOrder,
		type = 'group',
		name = format("%s %s", L["Actionbar"], index),
		childGroups = "tab",
		args = {
			barGroup = {
				type = "group",
				order = 1,
				name = L["Bar"],
				get = function(info) return CO.db.profile.actionbar[barNum][ info[#info] ] end,
				set = function(info, value) CO.db.profile.actionbar[barNum][ info[#info] ] = value; E:GetModule("Actionbars"):UpdateActionbar(index); E:GetModule("Actionbars"):UpdateActionButtonStyle() end,
				args = {
					warningDesc = {
						type = "description",
						order = 1,
						hidden = not (index > 7),
						name = "|cffFF0000" .. L["BarReservedWarning"] .. "\n\n|r",
						fontSize = "small",
					},
					enable = {
						type = "toggle",
						order = 11,
						name = L["Enable"],
					},
					showGrid = {
						type = "toggle",
						order = 12,
						name = L["ShowGrid"],
						disabled = function() return not CO.db.profile.actionbar[barNum].enable end,
					},
					clickOnDown = {
						type = "toggle",
						order = 13,
						name = L["ClickOnDown"],
						disabled = function() return not CO.db.profile.actionbar[barNum].enable end,
					},
					showTooltip = {
						type = "select",
						order = 15,
						name = L["ABTooltip"],
						values = ShowTooltipConditions,
						disabled = function() return not CO.db.profile.actionbar[barNum].enable end,
					},
					positionHeader = {
						order = 20,
						type = "header",
						name = L["Positioning"],
					},
					visibilityCondition = {
						order = 40,
						type = 'input',
						name = L["Visibility"],
						desc = L["VisibilityDesc"] .. "\n[pet] [petbattle] [combat] [vehicle] [flying] [form:N] [stealth]\n\n\n" .. L["VisibilityDescSec"] .. " https://wow.gamepedia.com/Macro_conditionals",
						width = "full",
						disabled = function() return not CO.db.profile.actionbar[barNum].enable end,
					},
					defaultVisibility = {
						order = 41,
						type = "execute",
						name = L["DefVisibility"],
						desc = L["DefVisibilityDesc"],
						func = function()
							CO.db.profile.actionbar["bar" .. index].visibilityCondition = E.ConfigDefaults.profile.actionbar["bar" .. index].visibilityCondition
							E:GetModule("Actionbars"):UpdateActionbar(index)
						end,
						disabled = function() return not CO.db.profile.actionbar[barNum].enable end,
					},
					header = {
						order = 50,
						type = "header",
						name = L["ButtonConfig"],
					},
					flyoutDirection = {
						type = 'select',
						order = 51,
						name = L["FlyoutDirection"],
						desc = L["FlyoutDirectionDesc"],
						values = FlyOutDirections,
						disabled = function() return not CO.db.profile.actionbar[barNum].enable end,
					},
					buttonsPerRow = {
						order = 52,
						type = 'range',
						name = L["ButtonsPerRow"],
						desc = L["ButtonsPerRowDesc"],
						min = -12, max = 12, step = 1,
						disabled = function() return not CO.db.profile.actionbar[barNum].enable end,
					},
					buttonNum = {
						order = 53,
						type = 'range',
						name = L["ButtonCount"],
						desc = L["ButtonCountDesc"],
						min = 1, max = 12, step = 1,
						disabled = function() return not CO.db.profile.actionbar[barNum].enable end,
					},
					buttonSizeMultiplier = {
						order = 54,
						type = 'range',
						name = L["ButtonSize"],
						desc = L["ButtonSizeDesc"],
						min = 0.1, max = 5, step = 0.05,
						disabled = function() return not CO.db.profile.actionbar[barNum].enable end,
					},
					buttonGap = {
						order = 55,
						type = 'range',
						name = L["ButtonGap"],
						desc = L["ButtonGapDesc"],
						min = -50, max = 50, step = 1,
						disabled = function() return not CO.db.profile.actionbar[barNum].enable end,
					},
				},
			},
			fadeGroup = {
				type = "group",
				order = 3,
				name = L["Fading"],
				get = function(info) return CO.db.profile.actionbar[barNum][ info[#info] ] end,
				set = function(info, value) CO.db.profile.actionbar[barNum][ info[#info] ] = value; E:GetModule("Actionbars"):UpdateActionbar(index); end,
				args = {
					showOnMouseOver = {
						type = "toggle",
						order = 2,
						name = L["Mouseover"],
						desc = L["MouseoverDesc"],
					},
					fadeInCombat = {
						order = 3,
						type = "select",
						name = L["InCombat"],
						desc = L["InCombatBarFadeDesc"],
						values = BarFade,
					},
					newLine1 = {type = "description", name = "", order = 10},
					alphaActive = {
						order = 11,
						type = 'range',
						name = L["AlphaActive"],
						desc = L["AlphaActiveDesc"],
						min = 0, max = 1, step = 0.01,
						disabled = function() return CO.db.profile.actionbar[barNum].fadeInCombat == "none" and not CO.db.profile.actionbar[barNum].showOnMouseOver end,
					},
					alphaInactive = {
						order = 12,
						type = 'range',
						name = L["AlphaInactive"],
						desc = L["AlphaInactiveDesc"],
						min = 0, max = 1, step = 0.01,
						disabled = function() return CO.db.profile.actionbar[barNum].fadeInCombat == "none" and not CO.db.profile.actionbar[barNum].showOnMouseOver end,
					},
					newLine2 = {type = "description", name = "", order = 20},
					fadeInSpeed = {
						order = 21,
						type = 'range',
						name = L["FadeInTime"],
						desc = L["FadeInTimeDesc"],
						min = 0, max = 2, step = 0.01,
						disabled = function() return CO.db.profile.actionbar[barNum].fadeInCombat == "none" and not CO.db.profile.actionbar[barNum].showOnMouseOver end,
					},
					fadeOutSpeed = {
						order = 22,
						type = 'range',
						name = L["FadeOutTime"],
						desc = L["FadeOutTimeDesc"],
						min = 0, max = 2, step = 0.01,
						disabled = function() return CO.db.profile.actionbar[barNum].fadeInCombat == "none" and not CO.db.profile.actionbar[barNum].showOnMouseOver end,
					},
				},
			},
			backgroundGroup = {
				type = "group",
				order = 4,
				name = L["Background"],
				get = function(info) return CO.db.profile.actionbar[barNum].artFill[ info[#info] ] end,
				set = function(info, value) CO.db.profile.actionbar[barNum].artFill[ info[#info] ] = value; E:GetModule("Actionbars"):UpdateArtFill(); end,
				args = {
					enable = {
						type = "toggle",
						order = 1,
						name = L["Enable"],
						width = "full",
					},
					valuesHeader = {
						type = "header",
						name = L["Values"],
						order = 10,
					},
					paddingX = {
						order = 11,
						type = 'range',
						name = L["PaddingH"],
						desc = L["PaddingHDesc"],
						min = 0, max = 50, step = 0.1,
						disabled = function() return not CO.db.profile.actionbar[barNum].artFill.enable end,
					},
					paddingY = {
						order = 12,
						type = 'range',
						name = L["PaddingV"],
						desc = L["PaddingVDesc"],
						min = 0, max = 50, step = 1,
						disabled = function() return not CO.db.profile.actionbar[barNum].artFill.enable end,
					},
					borderSize = {
						order = 13,
						type = 'range',
						name = L["BorderSize"],
						min = -5, max = 5, step = 0.1,
						disabled = function() return not CO.db.profile.actionbar[barNum].artFill.enable end,
					},
					colorHeader = {
						type = "header",
						name = L["Colors"],
						order = 20,
					},
					borderColor = {
						name = L["BorderColor"],
						type = "color",
						hasAlpha = true,
						order = 21,
						get = function(info)
							local c = CO.db.profile.actionbar[barNum].artFill.borderColor
							return c[1], c[2], c[3], c[4]
						end,
						set = function(info, r, g, b, a)
							local c = CO.db.profile.actionbar[barNum].artFill.borderColor
							c[1], c[2], c[3], c[4] = r, g, b, a
							E:GetModule("Actionbars"):UpdateArtFill();
						end,
						disabled = function() return not CO.db.profile.actionbar[barNum].artFill.enable end,
					},
					backgroundColor = {
						name = L["BackgroundColor"],
						type = "color",
						hasAlpha = true,
						order = 22,
						get = function(info)
							local c = CO.db.profile.actionbar[barNum].artFill.backgroundColor
							return c[1], c[2], c[3], c[4]
						end,
						set = function(info, r, g, b, a)
							local c = CO.db.profile.actionbar[barNum].artFill.backgroundColor
							c[1], c[2], c[3], c[4] = r, g, b, a
							E:GetModule("Actionbars"):UpdateArtFill();
						end,
						disabled = function() return not CO.db.profile.actionbar[barNum].artFill.enable end,
					},
				},
			},
		},
	}
	
	local Fonts = {{Path = format("db.profile.actionbar.%s.hotkey", barNum), Order = 100, GroupName = L["Hotkey"]}, {Path = format("db.profile.actionbar.%s.cooldown", barNum), Order = 200, GroupName = L["Cooldown"]}, {Path = format("db.profile.actionbar.%s.count", barNum), Order = 300, GroupName = L["Count"]}, {Path = format("db.profile.actionbar.%s.macro", barNum), Order = 400, GroupName = L["Macro"]}}
	for k,v in pairs(CD:GetFontOptions(Fonts)) do
		config.args[k] = v
	end
	for k,v in pairs(CD:GetMoverOptions("CUI_ActionBar" .. index .. "Mover", 21, true)) do
		config.args.barGroup.args[k] = v
	end

	return config
end

local function GetOptionsTable_Totembar(index)
	
	local config = {
		order = indexOrder,
		type = 'group',
		name = L["Totem Bar"],
		childGroups = "tab",
		args = {
			barGroup = {
				type = "group",
				order = 1,
				name = L["Bar"],
				get = function(info) return CO.db.profile.actionbar.totembar[ info[#info] ] end,
				set = function(info, value) CO.db.profile.actionbar.totembar[ info[#info] ] = value; E:GetModule("Bar_Totem"):LoadProfile(); end,
				args = {
					header = {
						order = 1,
						type = "header",
						name = L["Totem Bar"],
					},
					enable = {
						type = "toggle",
						order = 2,
						name = L["Enable"],
						width = "full",
					},
					positionHeader = {
						order = 13,
						type = "header",
						name = L["Positioning"],
					},
					styleHeader = {
						order = 30,
						type = "header",
						name = L["Styling"],
					},
					header = {
						order = 40,
						type = "header",
						name = L["ButtonConfig"],
					},
					buttonsPerRow = {
						order = 41,
						type = 'range',
						name = L["ButtonsPerRow"],
						desc = L["ButtonsPerRowDesc"],
						min = -MAX_TOTEMS, max = MAX_TOTEMS, step = 1,
						disabled = function() return not CO.db.profile.actionbar.totembar.enable end,
					},
					buttonSizeMultiplier = {
						order = 42,
						type = 'range',
						name = L["ButtonSize"],
						desc = L["ButtonSizeDesc"],
						min = 0.1, max = 5, step = 0.05,
						disabled = function() return not CO.db.profile.actionbar.totembar.enable end,
					},
					buttonGap = {
						order = 43,
						type = 'range',
						name = L["ButtonGap"],
						desc = L["ButtonGapDesc"],
						min = -50, max = 50, step = 1,
						disabled = function() return not CO.db.profile.actionbar.totembar.enable end,
					},
				},
			},
		},
	}
	
	local Fonts = {{Path = "db.profile.actionbar.totembar.duration", Order = 100, GroupName = "Duration"}}
	for k,v in pairs(CD:GetFontOptions(Fonts)) do
		config.args[k] = v
	end
	
	for k,v in pairs(CD:GetMoverOptions("CUI_TotemBarMover", 14, true)) do
		config.args.barGroup.args[k] = v
	end

	return config
end

local function GetOptionsTable_Petbar(index, indexOrder)
	
	local config = {
		order = indexOrder,
		type = 'group',
		name = L["Pet Bar"],
		childGroups = "tab",
		args = {
			barGroup = {
				type = "group",
				order = 1,
				name = L["Bar"],
				get = function(info) return CO.db.profile.actionbar.petbar[ info[#info] ] end,
				set = function(info, value) CO.db.profile.actionbar.petbar[ info[#info] ] = value; E:GetModule("Actionbars"):UpdateActionbar("petbar"); E:GetModule("Actionbars"):UpdateActionButtonStyle() end,
				args = {
					enable = {
						type = "toggle",
						order = 2,
						name = L["Enable"],
						width = "full",
					},
					positionHeader = {
						order = 13,
						type = "header",
						name = L["Positioning"],
					},
					styleHeader = {
						order = 30,
						type = "header",
						name = L["Styling"],
					},
					visibilityCondition = {
						order = 31,
						type = 'input',
						name = L["Visibility"],
						desc = L["VisibilityDesc"] .. "\n[pet] [petbattle] [combat] [vehicle] [flying] [form:N] [stealth]\n\n\n" .. L["VisibilityDescSec"] .. " https://wow.gamepedia.com/Macro_conditionals",
						width = "full",
						disabled = function() return not CO.db.profile.actionbar.petbar.enable end,
					},
					defaultVisibility = {
						order = 32,
						type = "execute",
						name = L["DefVisibility"],
						desc = L["DefVisibilityDesc"],
						func = function()
							CO.db.profile.actionbar.petbar.visibilityCondition = E.ConfigDefaults.profile.actionbar["petbar"].visibilityCondition
							E:GetModule("Actionbars"):UpdateActionbar("petbar")
						end,
						disabled = function() return not CO.db.profile.actionbar.petbar.enable end,
					},
					header = {
						order = 40,
						type = "header",
						name = L["ButtonConfig"],
					},
					buttonsPerRow = {
						order = 42,
						type = 'range',
						name = L["ButtonsPerRow"],
						desc = L["ButtonsPerRowDesc"],
						min = -12, max = 12, step = 1,
						disabled = function() return not CO.db.profile.actionbar.petbar.enable end,
					},
					buttonSizeMultiplier = {
						order = 43,
						type = 'range',
						name = L["ButtonSize"],
						desc = L["ButtonSizeDesc"],
						min = 0.1, max = 5, step = 0.05,
						disabled = function() return not CO.db.profile.actionbar.petbar.enable end,
					},
					buttonGap = {
						order = 44,
						type = 'range',
						name = L["ButtonGap"],
						desc = L["ButtonGapDesc"],
						min = -50, max = 50, step = 1,
						disabled = function() return not CO.db.profile.actionbar.petbar.enable end,
					},
				},
			},
			fadeGroup = {
				type = "group",
				order = 3,
				name = L["Fading"],
				get = function(info) return CO.db.profile.actionbar.petbar[ info[#info] ] end,
				set = function(info, value) CO.db.profile.actionbar.petbar[ info[#info] ] = value; E:GetModule("Actionbars"):UpdateActionbar("petbar"); end,
				args = {
					showOnMouseOver = {
						type = "toggle",
						order = 2,
						name = L["Mouseover"],
						desc = L["MouseoverDesc"],
					},
					fadeInCombat = {
						order = 3,
						type = "select",
						name = L["InCombat"],
						desc = L["InCombatBarFadeDesc"],
						values = BarFade,
					},
					newLine1 = {type = "description", name = "", order = 10},
					alphaActive = {
						order = 11,
						type = 'range',
						name = L["AlphaActive"],
						desc = L["AlphaActiveDesc"],
						min = 0, max = 1, step = 0.01,
						disabled = function() return CO.db.profile.actionbar.petbar.fadeInCombat == "none" and not CO.db.profile.actionbar.petbar.showOnMouseOver end,
					},
					alphaInactive = {
						order = 12,
						type = 'range',
						name = L["AlphaInactive"],
						desc = L["AlphaInactiveDesc"],
						min = 0, max = 1, step = 0.01,
						disabled = function() return CO.db.profile.actionbar.petbar.fadeInCombat == "none" and not CO.db.profile.actionbar.petbar.showOnMouseOver end,
					},
					newLine2 = {type = "description", name = "", order = 20},
					fadeInSpeed = {
						order = 21,
						type = 'range',
						name = L["FadeInTime"],
						desc = L["FadeInTimeDesc"],
						min = 0, max = 2, step = 0.01,
						disabled = function() return CO.db.profile.actionbar.petbar.fadeInCombat == "none" and not CO.db.profile.actionbar.petbar.showOnMouseOver end,
					},
					fadeOutSpeed = {
						order = 22,
						type = 'range',
						name = L["FadeOutTime"],
						desc = L["FadeOutTimeDesc"],
						min = 0, max = 2, step = 0.01,
						disabled = function() return CO.db.profile.actionbar.petbar.fadeInCombat == "none" and not CO.db.profile.actionbar.petbar.showOnMouseOver end,
					},
				},
			},
			backgroundGroup = {
				type = "group",
				order = 4,
				name = L["Background"],
				get = function(info) return CO.db.profile.actionbar.petbar.artFill[ info[#info] ] end,
				set = function(info, value) CO.db.profile.actionbar.petbar.artFill[ info[#info] ] = value; E:GetModule("Actionbars"):UpdateArtFill(); end,
				args = {
					enable = {
						type = "toggle",
						order = 1,
						name = L["Enable"],
						width = "full",
					},
					valuesHeader = {
						type = "header",
						name = L["Values"],
						order = 10,
					},
					paddingX = {
						order = 11,
						type = 'range',
						name = L["PaddingH"],
						desc = L["PaddingHDesc"],
						min = 0, max = 50, step = 0.1,
						disabled = function() return not CO.db.profile.actionbar.petbar.artFill.enable end,
					},
					paddingY = {
						order = 12,
						type = 'range',
						name = L["PaddingV"],
						desc = L["PaddingVDesc"],
						min = 0, max = 50, step = 1,
						disabled = function() return not CO.db.profile.actionbar.petbar.artFill.enable end,
					},
					borderSize = {
						order = 13,
						type = 'range',
						name = L["BorderSize"],
						min = -5, max = 5, step = 0.1,
						disabled = function() return not CO.db.profile.actionbar.petbar.artFill.enable end,
					},
					colorHeader = {
						type = "header",
						name = L["Colors"],
						order = 20,
					},
					borderColor = {
						name = L["BorderColor"],
						type = "color",
						hasAlpha = true,
						order = 21,
						get = function(info)
							local c = CO.db.profile.actionbar.petbar.artFill.borderColor
							return c[1], c[2], c[3], c[4]
						end,
						set = function(info, r, g, b, a)
							local c = CO.db.profile.actionbar.petbar.artFill.borderColor
							c[1], c[2], c[3], c[4] = r, g, b, a
							E:GetModule("Actionbars"):UpdateArtFill();
						end,
						disabled = function() return not CO.db.profile.actionbar.petbar.artFill.enable end,
					},
					backgroundColor = {
						name = L["BackgroundColor"],
						type = "color",
						hasAlpha = true,
						order = 22,
						get = function(info)
							local c = CO.db.profile.actionbar.petbar.artFill.backgroundColor
							return c[1], c[2], c[3], c[4]
						end,
						set = function(info, r, g, b, a)
							local c = CO.db.profile.actionbar.petbar.artFill.backgroundColor
							c[1], c[2], c[3], c[4] = r, g, b, a
							E:GetModule("Actionbars"):UpdateArtFill();
						end,
						disabled = function() return not CO.db.profile.actionbar.petbar.artFill.enable end,
					},
				},
			},
		},
	}
	
	local Fonts = {{Path = "db.profile.actionbar.petbar.hotkey", Order = 100, GroupName = L["Hotkey"]}, {Path = "db.profile.actionbar.petbar.cooldown", Order = 200, GroupName = L["Cooldown"]}, {Path = "db.profile.actionbar.petbar.count", Order = 300, GroupName = L["Count"]}, {Path = "db.profile.actionbar.petbar.macro", Order = 400, GroupName = L["Macro"]}}
	for k,v in pairs(CD:GetFontOptions(Fonts)) do
		config.args[k] = v
	end
	
	for k,v in pairs(CD:GetMoverOptions("CUI_PetActionbarMover", 14, true)) do
		config.args.barGroup.args[k] = v
	end

	return config
end

local function GetOptionsTable_Stancebar(indexOrder)
	
	local config = {
		order = indexOrder,
		type = 'group',
		name = L["Stancebar"],
		childGroups = "tab",
		args = {
			barGroup = {
				type = "group",
				order = 1,
				name = L["Bar"],
				get = function(info) return CO.db.profile.actionbar.stancebar[ info[#info] ] end,
				set = function(info, value) CO.db.profile.actionbar.stancebar[ info[#info] ] = value; E:GetModule("Actionbars"):UpdateActionbar("stancebar") end,
				args = {
					header = {
						order = 1,
						type = "header",
						name = L["Stancebar"],
					},
					enable = {
						type = "toggle",
						order = 2,
						name = L["Enable"],
						width = "full",
					},
					positionHeader = {
						order = 13,
						type = "header",
						name = L["Positioning"],
					},
					configHeader = {
						order = 40,
						type = "header",
						name = L["ButtonConfig"],
					},
					buttonsPerRow = {
						order = 41,
						type = 'range',
						name = L["ButtonsPerRow"],
						desc = L["ButtonsPerRowDesc"],
						min = -12, max = 12, step = 1,
						disabled = function() return not CO.db.profile.actionbar.stancebar.enable end,
					},
					buttonSizeMultiplier = {
						order = 43,
						type = 'range',
						name = L["ButtonSize"],
						desc = L["ButtonSizeDesc"],
						min = 0.1, max = 5, step = 0.05,
						disabled = function() return not CO.db.profile.actionbar.stancebar.enable end,
					},
					buttonGap = {
						order = 44,
						type = 'range',
						name = L["ButtonGap"],
						desc = L["ButtonGapDesc"],
						min = -50, max = 50, step = 1,
						disabled = function() return not CO.db.profile.actionbar.stancebar.enable end,
					},
				},
			},
			fadeGroup = {
				type = "group",
				order = 3,
				name = L["Fading"],
				get = function(info) return CO.db.profile.actionbar.stancebar[ info[#info] ] end,
				set = function(info, value) CO.db.profile.actionbar.stancebar[ info[#info] ] = value; E:GetModule("Actionbars"):UpdateActionbar("stancebar"); end,
				args = {
					showOnMouseOver = {
						type = "toggle",
						order = 2,
						name = L["Mouseover"],
						desc = L["MouseoverDesc"],
					},
					fadeInCombat = {
						order = 3,
						type = "select",
						name = L["InCombat"],
						desc = L["InCombatBarFadeDesc"],
						values = BarFade,
					},
					newLine1 = {type = "description", name = "", order = 10},
					alphaActive = {
						order = 11,
						type = 'range',
						name = L["AlphaActive"],
						desc = L["AlphaActiveDesc"],
						min = 0, max = 1, step = 0.01,
						disabled = function() return CO.db.profile.actionbar.stancebar.fadeInCombat == "none" and not CO.db.profile.actionbar.stancebar.showOnMouseOver end,
					},
					alphaInactive = {
						order = 12,
						type = 'range',
						name = L["AlphaInactive"],
						desc = L["AlphaInactiveDesc"],
						min = 0, max = 1, step = 0.01,
						disabled = function() return CO.db.profile.actionbar.stancebar.fadeInCombat == "none" and not CO.db.profile.actionbar.stancebar.showOnMouseOver end,
					},
					newLine2 = {type = "description", name = "", order = 20},
					fadeInSpeed = {
						order = 21,
						type = 'range',
						name = L["FadeInTime"],
						desc = L["FadeInTimeDesc"],
						min = 0, max = 2, step = 0.01,
						disabled = function() return CO.db.profile.actionbar.stancebar.fadeInCombat == "none" and not CO.db.profile.actionbar.stancebar.showOnMouseOver end,
					},
					fadeOutSpeed = {
						order = 22,
						type = 'range',
						name = L["FadeOutTime"],
						desc = L["FadeOutTimeDesc"],
						min = 0, max = 2, step = 0.01,
						disabled = function() return CO.db.profile.actionbar.stancebar.fadeInCombat == "none" and not CO.db.profile.actionbar.stancebar.showOnMouseOver end,
					},
				},
			},
			backgroundGroup = {
				type = "group",
				order = 4,
				name = L["Background"],
				get = function(info) return CO.db.profile.actionbar.stancebar.artFill[ info[#info] ] end,
				set = function(info, value) CO.db.profile.actionbar.stancebar.artFill[ info[#info] ] = value; E:GetModule("Actionbars"):UpdateArtFill(); end,
				args = {
					enable = {
						type = "toggle",
						order = 1,
						name = L["Enable"],
						width = "full",
					},
					valuesHeader = {
						type = "header",
						name = L["Values"],
						order = 10,
					},
					paddingX = {
						order = 11,
						type = 'range',
						name = L["PaddingH"],
						desc = L["PaddingHDesc"],
						min = 0, max = 50, step = 0.1,
						disabled = function() return not CO.db.profile.actionbar.stancebar.artFill.enable end,
					},
					paddingY = {
						order = 12,
						type = 'range',
						name = L["PaddingV"],
						desc = L["PaddingVDesc"],
						min = 0, max = 50, step = 1,
						disabled = function() return not CO.db.profile.actionbar.stancebar.artFill.enable end,
					},
					borderSize = {
						order = 13,
						type = 'range',
						name = L["BorderSize"],
						min = -5, max = 5, step = 0.1,
						disabled = function() return not CO.db.profile.actionbar.stancebar.artFill.enable end,
					},
					colorHeader = {
						type = "header",
						name = L["Colors"],
						order = 20,
					},
					borderColor = {
						name = L["BorderColor"],
						type = "color",
						hasAlpha = true,
						order = 21,
						get = function(info)
							local c = CO.db.profile.actionbar.stancebar.artFill.borderColor
							return c[1], c[2], c[3], c[4]
						end,
						set = function(info, r, g, b, a)
							local c = CO.db.profile.actionbar.stancebar.artFill.borderColor
							c[1], c[2], c[3], c[4] = r, g, b, a
							E:GetModule("Actionbars"):UpdateArtFill();
						end,
						disabled = function() return not CO.db.profile.actionbar.stancebar.artFill.enable end,
					},
					backgroundColor = {
						name = L["BackgroundColor"],
						type = "color",
						hasAlpha = true,
						order = 22,
						get = function(info)
							local c = CO.db.profile.actionbar.stancebar.artFill.backgroundColor
							return c[1], c[2], c[3], c[4]
						end,
						set = function(info, r, g, b, a)
							local c = CO.db.profile.actionbar.stancebar.artFill.backgroundColor
							c[1], c[2], c[3], c[4] = r, g, b, a
							E:GetModule("Actionbars"):UpdateArtFill();
						end,
						disabled = function() return not CO.db.profile.actionbar.stancebar.artFill.enable end,
					},
				},
			},
		},
	}
	
	local Fonts = {{Path = "db.profile.actionbar.stancebar.hotkey", Order = 100, GroupName = L["Hotkey"]}, {Path = "db.profile.actionbar.stancebar.cooldown", Order = 200, GroupName = L["Cooldown"]}, {Path = "db.profile.actionbar.stancebar.count", Order = 300, GroupName = L["Count"]}, {Path = "db.profile.actionbar.stancebar.macro", Order = 400, GroupName = L["Macro"]}}
	for k,v in pairs(CD:GetFontOptions(Fonts)) do
		config.args[k] = v
	end
	
	for k,v in pairs(CD:GetMoverOptions("CUI_StanceBarMover", 14, true)) do
		config.args.barGroup.args[k] = v
	end

	return config
end

local function GetOptionsTable_Extrabar(indexOrder)
	
	local config = {
		order = indexOrder,
		type = 'group',
		name = "Extra Button",
		childGroups = "tab",
		args = {
			barGroup = {
				type = "group",
				order = 1,
				name = "Button",
				get = function(info) return CO.db.profile.actionbar.extrabar[ info[#info] ] end,
				set = function(info, value) CO.db.profile.actionbar.extrabar[ info[#info] ] = value; E:GetModule("Actionbars"):UpdateExtraActionButton() end,
				args = {
					positionHeader = {
						order = 1,
						type = "header",
						name = L["Positioning"],
					},
					styleHeader = {
						order = 20,
						type = "header",
						name = L["ButtonConfig"],
					},
					buttonSizeMultiplier = {
						order = 21,
						type = 'range',
						name = L["ButtonSize"],
						desc = L["ButtonSizeDesc"],
						min = 0.1, max = 5, step = 0.05,
					},
				},
			},
		},
	}
	
	local Fonts = {{Path = "db.profile.actionbar.extrabar.hotkey", Order = 100, GroupName = L["Hotkey"]}, {Path = "db.profile.actionbar.extrabar.cooldown", Order = 200, GroupName = L["Cooldown"]}, {Path = "db.profile.actionbar.extrabar.count", Order = 300, GroupName = L["Count"]}, {Path = "db.profile.actionbar.extrabar.macro", Order = 400, GroupName = L["Macro"]}}
	for k,v in pairs(CD:GetFontOptions(Fonts)) do
		config.args[k] = v
	end
	
	for k,v in pairs(CD:GetMoverOptions("ExtraActionBarFrameMover", 2, true)) do
		config.args.barGroup.args[k] = v
	end

	return config
end

local function GetOptionsTable_Zonebar(indexOrder)
	
	local config = {
		order = indexOrder,
		type = 'group',
		name = "Zone Button",
		childGroups = "tab",
		args = {
			barGroup = {
				type = "group",
				order = 1,
				name = "Button",
				get = function(info) return CO.db.profile.actionbar.zonebar[ info[#info] ] end,
				set = function(info, value) CO.db.profile.actionbar.zonebar[ info[#info] ] = value; E:GetModule("Actionbars"):UpdateZoneActionButton() end,
				args = {
					positionHeader = {
						order = 1,
						type = "header",
						name = L["Positioning"],
					},
					styleHeader = {
						order = 20,
						type = "header",
						name = L["ButtonConfig"],
					},
					buttonSizeMultiplier = {
						order = 20,
						type = 'range',
						name = L["ButtonSize"],
						desc = L["ButtonSizeDesc"],
						min = 0.1, max = 5, step = 0.05,
					},
				},
			},
		},
	}
	
	local Fonts = {{Path = "db.profile.actionbar.zonebar.hotkey", Order = 100, GroupName = L["Hotkey"]}, {Path = "db.profile.actionbar.zonebar.cooldown", Order = 200, GroupName = L["Cooldown"]}, {Path = "db.profile.actionbar.zonebar.count", Order = 300, GroupName = L["Count"]}, {Path = "db.profile.actionbar.zonebar.macro", Order = 400, GroupName = L["Macro"]}}
	for k,v in pairs(CD:GetFontOptions(Fonts)) do
		config.args[k] = v
	end
	
	for k,v in pairs(CD:GetMoverOptions("ZoneAbilityFrameMover", 2, true)) do
		config.args.barGroup.args[k] = v
	end

	return config
end

local function GetOptionsTable_MicroMenu(indexOrder)
	
	local config = {
		order = indexOrder,
		type = 'group',
		name = L["Micromenu"],
		get = function(info) return CO.db.profile.actionbar.micromenu[ info[#info] ] end,
		set = function(info, value) CO.db.profile.actionbar.micromenu[ info[#info] ] = value; E:GetModule("Actionbars"):UpdateMicroMenu() end,
		args = {
			enable = {
				type = "toggle",
				order = 1,
				name = L["Enable"],
				width = "full",
			},
			positionHeader = {
				order = 2,
				type = "header",
				name = L["Positioning"],
			},
			styleHeader = {
				order = 20,
				type = "header",
				name = L["ButtonConfig"],
			},
			buttonSizeMultiplier = {
				order = 21,
				type = 'range',
				name = L["ButtonSize"],
				desc = L["ButtonSizeDesc"],
				width = "full",
				min = 0.1, max = 5, step = 0.05,
				disabled = function() return not CO.db.profile.actionbar.micromenu.enable end,
			},
			borderSize = {
				order = 22,
				type = 'range',
				name = L["BorderSize"],
				width = "full",
				min = -10, max = 10, step = 0.1,
				disabled = function() return not CO.db.profile.actionbar.micromenu.enable end,
			},
			borderUseClassColor = {
				type = "toggle",
				order = 23,
				name = L["UseClassColor"],
				desc = L["UseClassColorDesc"],
				get = function() return CO.db.profile.actionbar.micromenu.borderColor.useClassColor end,
				set = function(info, value) CO.db.profile.actionbar.micromenu.borderColor.useClassColor = value; E:GetModule("Actionbars"):UpdateMicroMenu(); end,
			},
			borderColor = {
				name = L["BorderColor"],
				type = "color",
				hasAlpha = true,
				order = 24,
				get = function(info)
					local c = E:ParseDBColor(CO.db.profile.actionbar.micromenu.borderColor)
					return c[1], c[2], c[3], c[4] or 1
				end,
				set = function(info, r, g, b, a)
					local c = E:ParseDBColor(CO.db.profile.actionbar.micromenu.borderColor)
					c[1], c[2], c[3], c[4] = r, g, b, a or 1
					
					E:GetModule("Actionbars"):UpdateMicroMenu()
				end,
				disabled = function() return not CO.db.profile.actionbar.micromenu.enable end,
			}
		},
	}
	
	for k,v in pairs(CD:GetMoverOptions("MicroMenuMover", 3, true)) do
		config.args[k] = v
	end

	return config
end

local function GetABOptions_All()
	local config = {
		allStyle = {
			type = "group",
			order = 1,
			name = L["Style"],
			args = {
				borderHeader = {
					order = 1,
					type = "header",
					name = L["ButtonBorderTexture"],
				},
				borderTextureColor = {
				  name = L["BorderColor"],
				  type = "color",
				  hasAlpha = true,
				  order = 2,
				  get = function(info)
						local c = CO.db.profile.actionbar.global.borderTextureColor
						return c.r, c.g, c.b, c.a
				  end,
				  set = function(info, r, g, b, a)
						local c = CO.db.profile.actionbar.global.borderTextureColor
						c.r, c.g, c.b, c.a = r, g, b, a
						E:GetModule("Actionbars"):UpdateActionButtonStyle()
				  end,
				  disabled = function() return CO.db.profile.actionbar.useMasque end,
				},
				borderTextureBlendMode = {
					type = 'select',
					order = 3,
					name = L["BlendMode"],
					values = E.BlendModes,
					get = function(info)
						return CO.db.profile.actionbar.global.borderTextureBlendMode
					end,
					set = function(info, value)
						CO.db.profile.actionbar.global.borderTextureBlendMode = value
						E:GetModule("Actionbars"):UpdateActionButtonStyle()
					end,
					disabled = function() return CO.db.profile.actionbar.useMasque end,
				},
				normalHeader = {
					order = 10,
					type = "header",
					name = L["ButtonNormalTexture"],
				},
				normalTextureColor = {
				  name = L["NormalColor"],
				  type = "color",
				  hasAlpha = true,
				  order = 11,
				  get = function(info)
						local c = CO.db.profile.actionbar.global.normalTextureColor
						return c.r, c.g, c.b, c.a
				  end,
				  set = function(info, r, g, b, a)
						local c = CO.db.profile.actionbar.global.normalTextureColor
						c.r, c.g, c.b, c.a = r, g, b, a
						E:GetModule("Actionbars"):UpdateActionButtonStyle()
				  end,
				  disabled = function() return CO.db.profile.actionbar.useMasque end,
				},
				normalTextureBlendMode = {
					type = 'select',
					order = 12,
					name = L["BlendMode"],
					values = E.BlendModes,
					get = function(info)
						return CO.db.profile.actionbar.global.normalTextureBlendMode
					end,
					set = function(info, value)
						CO.db.profile.actionbar.global.normalTextureBlendMode = value
						E:GetModule("Actionbars"):UpdateActionButtonStyle()
					end,
					disabled = function() return CO.db.profile.actionbar.useMasque end,
				},
				highlightHeader = {
					order = 20,
					type = "header",
					name = L["ButtonHTexture"],
				},
				highlightTextureColor = {
				  name = L["HighlightColor"],
				  type = "color",
				  hasAlpha = true,
				  order = 21,
				  get = function(info)
						local c = CO.db.profile.actionbar.global.highlightTextureColor
						return c.r, c.g, c.b, c.a
				  end,
				  set = function(info, r, g, b, a)
						local c = CO.db.profile.actionbar.global.highlightTextureColor
						c.r, c.g, c.b, c.a = r, g, b, a
						E:GetModule("Actionbars"):UpdateActionButtonStyle()
				  end,
				  disabled = function() return CO.db.profile.actionbar.useMasque end,
				},
				highlightTextureBlendMode = {
					type = 'select',
					order = 22,
					name = L["BlendMode"],
					values = E.BlendModes,
					get = function(info)
						return CO.db.profile.actionbar.global.highlightTextureBlendMode
					end,
					set = function(info, value)
						CO.db.profile.actionbar.global.highlightTextureBlendMode = value
						E:GetModule("Actionbars"):UpdateActionButtonStyle()
					end,
					disabled = function() return CO.db.profile.actionbar.useMasque end,
				},
				pushedHeader = {
					order = 23,
					type = "header",
					name = L["ButtonPTexture"],
				},
				pushedTextureColor = {
				  name = L["PushedColor"],
				  type = "color",
				  hasAlpha = true,
				  order = 24,
				  get = function(info)
						local c = CO.db.profile.actionbar.global.pushedTextureColor
						return c.r, c.g, c.b, c.a
				  end,
				  set = function(info, r, g, b, a)
						local c = CO.db.profile.actionbar.global.pushedTextureColor
						c.r, c.g, c.b, c.a = r, g, b, a
						E:GetModule("Actionbars"):UpdateActionButtonStyle()
				  end,
				  disabled = function() return CO.db.profile.actionbar.useMasque end,
				},
				pushedTextureBlendMode = {
					type = 'select',
					order = 25,
					name = L["BlendMode"],
					values = E.BlendModes,
					get = function(info)
						return CO.db.profile.actionbar.global.pushedTextureBlendMode
					end,
					set = function(info, value)
						CO.db.profile.actionbar.global.pushedTextureBlendMode = value
						E:GetModule("Actionbars"):UpdateActionButtonStyle()
					end,
					disabled = function() return CO.db.profile.actionbar.useMasque end,
				},
				
				masqueHeader = {
					order = 26,
					type = "header",
					name = L["AdditionalAddOns"],
				},
				useMasque = {
					type = "toggle",
					order = 27,
					name = L["UseMasque"],
					desc = L["UseMasqueDesc"],
					get = function() return CO.db.profile.actionbar.useMasque end,
					set = function(info, value) CO.db.profile.actionbar.useMasque = value; CO:ProfileUpdate(); if value == false then CD:ShowNotification("RELOAD_NOTIFICATION") end end,
				},
				functionHeader = {
					order = 50,
					type = "header",
					name = L["GlobalFunctions"],
				},
				clearAllButtons = {
					type = "execute",
					name = L["ClearAllSlots"],
					desc = L["ClearAllSlotsDesc"],
					width = "full",
					order = 51,
					func = function()
						CD:ShowNotification("CLEAR_ACTIONBARS_NOTIFICATION")
					end
				},
			},
		},
		hotkey = GetOptionsTable_AllFonts("hotkey", 100), cooldown = GetOptionsTable_AllFonts("cooldown", 200), count = GetOptionsTable_AllFonts("count", 300), macro = GetOptionsTable_AllFonts("macro", 400),
		background = GetOptionsTable_AllBackground(2),
	}
	
	return config
end

CD.Options.args.actionbar = {
	name = L["Actionbars"],
	type = 'group',
	order = Index,
	disabled = false,
	childGroups = "tree",
	args = {
		
		all = {
			type = "group",
			order = 0,
			name = L["All"],
			childGroups = "tab",
			args = GetABOptions_All(),
		},
		
		bar1 = GetOptionsTable_Actionbar(1,1),
		bar2 = GetOptionsTable_Actionbar(2,2),
		bar3 = GetOptionsTable_Actionbar(3,3),
		bar4 = GetOptionsTable_Actionbar(4,4),
		bar5 = GetOptionsTable_Actionbar(5,5),
		bar6 = GetOptionsTable_Actionbar(6,6),
		bar7 = GetOptionsTable_Actionbar(7,7),
		bar8 = GetOptionsTable_Actionbar(8,8),
		bar9 = GetOptionsTable_Actionbar(9,9),
		bar10 = GetOptionsTable_Actionbar(10,10),
		totembar = GetOptionsTable_Totembar(14),
		petbar = GetOptionsTable_Petbar(15),
		stancebar = GetOptionsTable_Stancebar(20),
		extrabar = GetOptionsTable_Extrabar(30),
		zonebar = GetOptionsTable_Zonebar(40),
		micromenu = GetOptionsTable_MicroMenu(50),
	},
}