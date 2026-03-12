local E, L = unpack(CUI) -- Engine
local CO, CD = E:LoadModules("Config", "Config_Dialog")

--------------------------------------------------------------------
local _
local format			= string.format
local pairs				= pairs
local GetCVarBool 		= C_CVar.GetCVarBool
local SetCVar 			= C_CVar.SetCVar
--------------------------------------------------------------------

local Index = CD:GetAutoSortIndex()
local Module = {}

local AllFonts = {"%s", "stancebar", "zonebar", "extrabar", "petbar"}
local TempConfig_ArtFill = { }
local TempConfig_Font = { ["hotkey"] = {}, ["cooldown"] = {}, ["count"] = {}, ["macro"] = {} }
local FlyOutDirections = { ["UP"] = L["Up"], ["LEFT"] = L["Left"], ["RIGHT"] = L["Right"], ["DOWN"] = L["Down"] }
local ShowTooltipConditions = { ["disabled"] = L["Disabled"], ["enabled"] = L["Enabled"], ["nocombat"] = L["Hide in Combat"] }
local BarFade = {["none"] = L["DoNothing"], ["fadeOut"] = L["CombatFadeOut"], ["fadeIn"] = L["CombatFadeIn"], ["custom"] = L["Custom"]}

local MacroConditionalURL = "https://wow.gamepedia.com/Macro_conditionals"
CD.MacroConditionalURL = MacroConditionalURL

local function UpdateFont(bar)
	-- Check if target exists
	local target = E:GetTableByPath(format("db.profile.actionbar.%s", bar), CO)
	if target then
		for fontType, _ in pairs(TempConfig_Font) do
			if target[fontType] then
				for k, v in pairs(TempConfig_Font[fontType]) do
					if k == 'fontColor' then
						if type(target[fontType][k]) ~= "table" then
							target[fontType][k] = {['useClassColor'] = false, {1,1,1,1}}
						end
						target[fontType][k][1] = v[1]
						target[fontType][k][2] = v[2]
						target[fontType][k][3] = v[3]
						target[fontType][k][4] = v[4]
						target[fontType][k].useClassColor = v.useClassColor
					else
						target[fontType][k] = v
					end
				end
			end
		end
		
		if target['cooldown'] then
			target.cooldownFormat = TempConfig_Font.cooldown.cooldownFormat
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
	local target = E:GetTableByPath(format("db.profile.actionbar.%s.artFill", type), CO)
	
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
	
	E:LoadModule("Actionbars"):UpdateArtFill()
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
				min = 0, max = 5, step = 0.1,
				set = function(info, value)
					if value == 0 then
						value = 0.1
					end
					
					TempConfig_ArtFill[ info[#info] ] = value
					UpdateAllArtFill()
				end,
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
					E:LoadModule("Actionbars"):UpdateArtFill();
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
local function GetOptionsTable_AllFonts(fontType, order)
	
	-- We need one group for each font type
	local config = {
		type = "group",
		order = order,
		name = L[E:firstToUpper(fontType)],
		get = function(info) return TempConfig_Font[fontType][ info[#info] ] end,
		set = function(info, value) TempConfig_Font[fontType][ info[#info] ] = value; UpdateAllFonts() end,
		args = CD:AddFontOptions()
	}
	
	if type(TempConfig_Font[fontType].fontColor) ~= "table" then
		 TempConfig_Font[fontType].fontColor = {['useClassColor'] = false, {1,1,1,1}}
	end
	
	-- Should not be affected by disabled state
	for k,v in pairs(config.args) do
		if v.disabled then
			v.disabled = false
		end
		if k == "fontColorUseClass" then
			v.get = function(info)
					return TempConfig_Font[fontType].fontColor.useClassColor
			end
			v.set = function(info, value)
					TempConfig_Font[fontType].fontColor.useClassColor = value
					UpdateAllFonts()
			end
		elseif k == "fontColorRgba" then
			v.get = function(info)
					local c = E:ParseDBColor(TempConfig_Font[fontType].fontColor)
					
					return c[1], c[2], c[3], c[4]
			end
			v.set = function(info, r, g, b, a)
					--if not TempConfig_Font[type].fontColor then TempConfig_Font[type].fontColor = {1,1,1,1} end
					local c = E:ParseDBColor(TempConfig_Font[fontType].fontColor)
					
					c[1], c[2], c[3], c[4] = r, g, b, a
					UpdateAllFonts()
			end
		elseif k == "fontShadowColor" then
			v.get = function(info)
					local c = TempConfig_Font[fontType].fontShadowColor or {1,1,1,1}
					
					return c[1], c[2], c[3], c[4]
			end
			v.set = function(info, r, g, b, a)
					if not TempConfig_Font[fontType].fontShadowColor then TempConfig_Font[fontType].fontShadowColor = {0,0,0,0} end
					local color = TempConfig_Font[fontType].fontShadowColor
					
					
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
	local DisabledFunc = function() return not CO.db.profile.actionbar[barNum].enable end
	
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
				set = function(info, value) CO.db.profile.actionbar[barNum][ info[#info] ] = value; E:LoadModule("Actionbars"):UpdateActionbar(index); E:LoadModule("Actionbars"):UpdateActionButtonStyle() end,
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
						disabled = DisabledFunc,
					},
					showTooltip = {
						type = "select",
						order = 15,
						name = L["ABTooltip"],
						values = ShowTooltipConditions,
						disabled = DisabledFunc,
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
						disabled = DisabledFunc,
					},
					defaultVisibility = {
						order = 41,
						type = "execute",
						name = L["DefVisibility"],
						desc = L["DefVisibilityDesc"],
						func = function()
							CO.db.profile.actionbar["bar" .. index].visibilityCondition = E.ConfigDefaults.profile.actionbar["bar" .. index].visibilityCondition
							E:LoadModule("Actionbars"):UpdateActionbar(index)
						end,
						disabled = DisabledFunc,
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
						disabled = DisabledFunc,
					},
					buttonsPerRow = {
						order = 52,
						type = 'range',
						name = L["ButtonsPerRow"],
						desc = L["ButtonsPerRowDesc"],
						min = -12, max = 12, step = 1,
						disabled = DisabledFunc,
					},
					buttonNum = {
						order = 53,
						type = 'range',
						name = L["ButtonCount"],
						desc = L["ButtonCountDesc"],
						min = 1, max = 12, step = 1,
						disabled = DisabledFunc,
					},
					buttonSizeMultiplier = {
						order = 54,
						type = 'range',
						name = L["ButtonSize"],
						desc = L["ButtonSizeDesc"],
						min = 0.1, max = 5, step = 0.05,
						disabled = DisabledFunc,
					},
					buttonGap = {
						order = 55,
						type = 'range',
						name = L["ButtonGap"],
						desc = L["ButtonGapDesc"],
						min = -50, max = 50, step = 1,
						disabled = DisabledFunc,
					},
				},
			},
			fadeGroup = {
				type = "group",
				order = 3,
				name = L["Fading"],
				get = function(info) return CO.db.profile.actionbar[barNum][ info[#info] ] end,
				set = function(info, value) CO.db.profile.actionbar[barNum][ info[#info] ] = value; E:LoadModule("Actionbars"):UpdateActionbar(index); end,
				disabled = DisabledFunc,
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
						name = L["Behaviour"],
						desc = L["InCombatBarFadeDesc"],
						values = BarFade,
					},
					fadeCondition = {
						type = "input",
						order = 4,
						name = "Custom Condition",
						desc = L["ActionbarFadeConditionDesc"] .. " " .. MacroConditionalURL,
						width = "full",
						hidden = function() return CO.db.profile.actionbar[barNum].fadeInCombat ~= "custom" end,
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
				set = function(info, value) CO.db.profile.actionbar[barNum].artFill[ info[#info] ] = value; E:LoadModule("Actionbars"):UpdateArtFill(); end,
				disabled = DisabledFunc,
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
						min = 0, max = 5, step = 0.1,
						set = function(info, value)
							if value == 0 then
								value = 0.1
							end
							
							CO.db.profile.actionbar[barNum].artFill[ info[#info] ] = value; E:LoadModule("Actionbars"):UpdateArtFill(); 
						end,
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
							E:LoadModule("Actionbars"):UpdateArtFill();
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
							E:LoadModule("Actionbars"):UpdateArtFill();
						end,
						disabled = function() return not CO.db.profile.actionbar[barNum].artFill.enable end,
					},
				},
			},
			flashGroup = {
				type = "group",
				order = 5,
				name = CD:GetNewFeatureString("Flash"),
				get = function(info) return CO.db.profile.actionbar[barNum].flash[ info[#info] ] end,
				set = function(info, value) CO.db.profile.actionbar[barNum].flash[ info[#info] ] = value; E:LoadModule("Actionbars"):UpdateAllFlashes(); end,
				disabled = DisabledFunc,
				args = {
					enable = {
						type = "toggle",
						order = 1,
						name = L["Enable"],
						width = "full",
					},
					newLine1 = {type = "description", name = "", order = 1.5},
					-- valuesHeader = {
						-- type = "header",
						-- name = L["Values"],
						-- order = 10,
					-- },
					blendMode = {
						type = 'select',
						order = 3,
						name = L["BlendMode"],
						values = E.BlendModes,
						disabled = function() return not CO.db.profile.actionbar[barNum].flash.enable end,
					},
					showAboveCooldown = {
						type = "toggle",
						order = 4,
						name = "Show Above Cooldown",
						desc = "When enabled, the flash effect is displayed above the cooldown animation, instead of below, making it clearly visible while the action is not technically ready. This is just a preference based option",
						disabled = function() return not CO.db.profile.actionbar[barNum].flash.enable end,
					},
					-- flashDrawLayer = {
						-- type = 'select',
						-- order = 4,
						-- name = "Draw Layer",
						-- values = E.BlendModes,
						-- disabled = function() return CO.db.char.actionbar.useMasque end,
					-- },
					newLine2 = {type = "description", name = "", order = 5},
					fadeInTime = {
						order = 11,
						type = 'range',
						name = L["FadeInTime"],
						--desc = L["PaddingHDesc"],
						min = 0, max = 1, step = 0.001,
						disabled = function() return not CO.db.profile.actionbar[barNum].flash.enable end,
					},
					fadeOutTime = {
						order = 12,
						type = 'range',
						name = L["FadeOutTime"],
						--desc = L["PaddingVDesc"],
						min = 0, max = 1, step = 0.001,
						disabled = function() return not CO.db.profile.actionbar[barNum].flash.enable end,
					},
					colorHeader = {
						type = "header",
						name = "Look",
						order = 20,
					},
					-- rgba = {
						-- name = COLOR,
						-- type = "color",
						-- hasAlpha = true,
						-- order = 21,
						-- get = function(info)
							-- local c = CO.db.profile.actionbar[barNum].flash.rgba
							-- return c[1], c[2], c[3], c[4]
						-- end,
						-- set = function(info, r, g, b, a)
							-- local c = CO.db.profile.actionbar[barNum].flash.rgba
							-- c[1], c[2], c[3], c[4] = r, g, b, a
							-- E:LoadModule("Actionbars"):UpdateAllFlashes();
						-- end,
						-- disabled = function() return not CO.db.profile.actionbar[barNum].flash.enable end,
					-- },
					
					
					
					rgbaUseClassColor = {
						type = "toggle",
						order = 21,
						name = L["UseClassColor"],
						desc = L["UseClassColorDesc"],
						get = function() return CO.db.profile.actionbar[barNum].flash.rgba.useClassColor end,
						set = function(info, value) CO.db.profile.actionbar[barNum].flash.rgba.useClassColor = value; E:LoadModule("Actionbars"):UpdateAllFlashes(); end,
					},
					rgba = {
						name = L["Color"],
						type = "color",
						hasAlpha = true,
						order = 22,
						get = function(info)
							local c = E:ParseDBColor(CO.db.profile.actionbar[barNum].flash.rgba)
							return c[1], c[2], c[3], c[4] or 1
						end,
						set = function(info, r, g, b, a)
							local c = E:ParseDBColor(CO.db.profile.actionbar[barNum].flash.rgba)
							c[1], c[2], c[3], c[4] = r, g, b, a or 1
							
							E:LoadModule("Actionbars"):UpdateAllFlashes();
						end,
						disabled = function() return CO.db.profile.actionbar[barNum].flash.rgba.useClassColor end,
					},
				},
			},
		},
	}
	
	local Fonts = {{Path = format("db.profile.actionbar.%s.hotkey", barNum), Order = 100, GroupName = L["Hotkey"]}, {Path = format("db.profile.actionbar.%s.cooldown", barNum), Order = 200, GroupName = L["Cooldown"]}, {Path = format("db.profile.actionbar.%s.count", barNum), Order = 300, GroupName = L["Count"]}, {Path = format("db.profile.actionbar.%s.macro", barNum), Order = 400, GroupName = L["Macro"]}}
	for k,v in pairs(CD:GetFontOptions(Fonts, DisabledFunc)) do
		config.args[k] = v
	end
	for k,v in pairs(CD:GetMoverOptions("CUI_ActionBar" .. index .. "Mover", 21, true, DisabledFunc)) do
		config.args.barGroup.args[k] = v
	end
	
	if config.args[L["Cooldown"]] then
		config.args[L["Cooldown"]].args.filterType = {
			order = 5,
			type = 'select',
			name = L["NumberFormatting"],
			values = function() return E:GetAvailableNumberFormats() end,
			get = function()
				local value = CO.db.profile.actionbar[barNum].cooldownFormat
				
				if value == nil then
					return -1
				else
					return value
				end
			end,
			set = function(info, value)
				if value == -1 then
					value = nil
				end
				CO.db.profile.actionbar[barNum].cooldownFormat = value
				E:LoadModule("Actionbars"):UpdateActionbar(index)
			end,
			disabled = config.args[L["Cooldown"]].args.width.disabled,
		}
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
				set = function(info, value) CO.db.profile.actionbar.totembar[ info[#info] ] = value; E:LoadModule("Bar_Totem"):LoadConfig(); end,
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
					borderUseClassColor = {
						type = "toggle",
						order = 31,
						name = L["UseClassColor"],
						desc = L["UseClassColorDesc"],
						get = function() return CO.db.profile.actionbar.totembar.borderColor.useClassColor end,
						set = function(info, value) CO.db.profile.actionbar.totembar.borderColor.useClassColor = value; E:LoadModule("Bar_Totem"):LoadConfig(); end,
					},
					borderColor = {
						name = L["BorderColor"],
						type = "color",
						hasAlpha = true,
						order = 32,
						get = function(info)
							local c = E:ParseDBColor(CO.db.profile.actionbar.totembar.borderColor)
							return c[1], c[2], c[3], c[4] or 1
						end,
						set = function(info, r, g, b, a)
							local c = E:ParseDBColor(CO.db.profile.actionbar.totembar.borderColor)
							c[1], c[2], c[3], c[4] = r, g, b, a or 1
							
							E:LoadModule("Bar_Totem"):LoadConfig()
						end,
						disabled = function() return not CO.db.profile.actionbar.totembar.enable end,
					},
					headerButtons = {
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
				set = function(info, value) CO.db.profile.actionbar.petbar[ info[#info] ] = value; E:LoadModule("Actionbars"):UpdateActionbar("petbar"); E:LoadModule("Actionbars"):UpdateActionButtonStyle() end,
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
							E:LoadModule("Actionbars"):UpdateActionbar("petbar")
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
				set = function(info, value) CO.db.profile.actionbar.petbar[ info[#info] ] = value; E:LoadModule("Actionbars"):UpdateActionbar("petbar"); end,
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
						name = L["Behaviour"],
						desc = L["InCombatBarFadeDesc"],
						values = BarFade,
					},
					fadeCondition = {
						type = "input",
						order = 4,
						name = "Custom Condition",
						desc = L["ActionbarFadeConditionDesc"] .. " " .. MacroConditionalURL,
						width = "full",
						hidden = function() return CO.db.profile.actionbar.petbar.fadeInCombat ~= 'custom' end,
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
				set = function(info, value) CO.db.profile.actionbar.petbar.artFill[ info[#info] ] = value; E:LoadModule("Actionbars"):UpdateArtFill(); end,
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
						min = 0, max = 5, step = 0.1,
						set = function(info, value)
							if value == 0 then
								value = 0.1
							end
							
							CO.db.profile.actionbar.petbar.artFill[ info[#info] ] = value; E:LoadModule("Actionbars"):UpdateArtFill();
						end,
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
							E:LoadModule("Actionbars"):UpdateArtFill();
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
							E:LoadModule("Actionbars"):UpdateArtFill();
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
				set = function(info, value) CO.db.profile.actionbar.stancebar[ info[#info] ] = value; E:LoadModule("Actionbars"):UpdateActionbar("stancebar") end,
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
				set = function(info, value) CO.db.profile.actionbar.stancebar[ info[#info] ] = value; E:LoadModule("Actionbars"):UpdateActionbar("stancebar"); end,
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
						name = L["Behaviour"],
						desc = L["InCombatBarFadeDesc"],
						values = BarFade,
					},
					fadeCondition = {
						type = "input",
						order = 4,
						name = "Custom Condition",
						desc = L["ActionbarFadeConditionDesc"] .. " " .. MacroConditionalURL,
						width = "full",
						hidden = function() return CO.db.profile.actionbar.stancebar.fadeInCombat ~= 'custom' end,
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
				set = function(info, value) CO.db.profile.actionbar.stancebar.artFill[ info[#info] ] = value; E:LoadModule("Actionbars"):UpdateArtFill(); end,
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
						min = 0, max = 5, step = 0.1,
						set = function(info, value)
							if value == 0 then
								value = 0.1
							end
							
							CO.db.profile.actionbar.stancebar.artFill[ info[#info] ] = value; E:LoadModule("Actionbars"):UpdateArtFill();
						end,
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
							E:LoadModule("Actionbars"):UpdateArtFill();
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
							E:LoadModule("Actionbars"):UpdateArtFill();
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

local function GetOptionsTable_ExtraAbilites(indexOrder)
	
	local config = {
		order = indexOrder,
		type = 'group',
		name = "Extra Abilites",
		childGroups = "tab",
		args = {
			General = {
				type = 'group',
				name = "General",
				childGroups = "tab",
				order = 1,
				args = {
					positionHeader = {
						order = 1,
						type = "header",
						name = L["Positioning"],
					},
				},
			},
			ExtraGroup = {
				type = 'group',
				name = "Extra Button",
				childGroups = "tab",
				order = 2,
				args = {
					barGroup = {
						type = "group",
						order = 1,
						name = "Button",
						get = function(info) return CO.db.profile.actionbar.extrabar[ info[#info] ] end,
						set = function(info, value) CO.db.profile.actionbar.extrabar[ info[#info] ] = value; E:LoadModule("Actionbars"):UpdateExtraActionButton() end,
						args = {
							-- positionHeader = {
								-- order = 1,
								-- type = "header",
								-- name = L["Positioning"],
							-- },
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
			},
			ZoneGroup = {
				order = 3,
				type = 'group',
				name = "Zone Button",
				childGroups = "tab",
				args = {
					barGroup = {
						type = "group",
						order = 1,
						name = "Button",
						get = function(info) return CO.db.profile.actionbar.zonebar[ info[#info] ] end,
						set = function(info, value) CO.db.profile.actionbar.zonebar[ info[#info] ] = value; E:LoadModule("Actionbars"):UpdateZoneActionButton() end,
						args = {
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
			},
		},
	}
	
	-- Mover Config
	for k,v in pairs(CD:GetMoverOptions("ExtraAbilityFrameHolderMover", 2, true)) do
		config.args.General.args[k] = v
	end
	
	-- Additional Extra Button Config
	local Fonts = {{Path = "db.profile.actionbar.extrabar.hotkey", Order = 100, GroupName = L["Hotkey"]}, {Path = "db.profile.actionbar.extrabar.cooldown", Order = 200, GroupName = L["Cooldown"]}, {Path = "db.profile.actionbar.extrabar.count", Order = 300, GroupName = L["Count"]}, {Path = "db.profile.actionbar.extrabar.macro", Order = 400, GroupName = L["Macro"]}}
	for k,v in pairs(CD:GetFontOptions(Fonts)) do
		config.args.ExtraGroup.args[k] = v
	end
	
	if config.args.ExtraGroup.args[L["Cooldown"]] then
		config.args.ExtraGroup.args[L["Cooldown"]].args.filterType = {
			order = 5,
			type = 'select',
			name = L["NumberFormatting"],
			values = function() return E:GetAvailableNumberFormats() end,
			get = function()
				local value = CO.db.profile.actionbar.extrabar.cooldownFormat
				
				if value == nil then
					return -1
				else
					return value
				end
			end,
			set = function(info, value)
				if value == -1 then
					value = nil
				end
				CO.db.profile.actionbar.extrabar.cooldownFormat = value
				E:LoadModule("Actionbars"):UpdateExtraActionButton()
			end,
			disabled = config.args.ExtraGroup.args[L["Cooldown"]].args.width.disabled,
		}
	end
	
	-- Additional Zone Button Config
	local Fonts = {{Path = "db.profile.actionbar.zonebar.cooldown", Order = 200, GroupName = L["Cooldown"]}, {Path = "db.profile.actionbar.zonebar.count", Order = 300, GroupName = L["Count"]}, {Path = "db.profile.actionbar.zonebar.macro", Order = 400, GroupName = L["Macro"]}}
	for k,v in pairs(CD:GetFontOptions(Fonts)) do
		config.args.ZoneGroup.args[k] = v
	end
	
	if config.args.ZoneGroup.args[L["Cooldown"]] then
		config.args.ZoneGroup.args[L["Cooldown"]].args.filterType = {
			order = 5,
			type = 'select',
			name = L["NumberFormatting"],
			values = function() return E:GetAvailableNumberFormats() end,
			get = function()
				local value = CO.db.profile.actionbar.zonebar.cooldownFormat
				
				if value == nil then
					return -1
				else
					return value
				end
			end,
			set = function(info, value)
				if value == -1 then
					value = nil
				end
				CO.db.profile.actionbar.zonebar.cooldownFormat = value
				E:LoadModule("Actionbars"):UpdateZoneActionButton()
			end,
			disabled = config.args.ZoneGroup.args[L["Cooldown"]].args.width.disabled,
		}
	end

	return config
end

local function GetOptionsTable_MicroMenu(indexOrder)
	
	local config = {
		order = indexOrder,
		type = 'group',
		name = L["Micromenu"],
		get = function(info) return CO.db.profile.actionbar.micromenu[ info[#info] ] end,
		set = function(info, value) CO.db.profile.actionbar.micromenu[ info[#info] ] = value; E:LoadModule("Actionbars"):UpdateMicroMenu() end,
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
				min = 0, max = 10, step = 0.1,
				set = function(info, value)
					if value == 0 then
						value = 0.1
					end
					
					CO.db.profile.actionbar.micromenu[ info[#info] ] = value; E:LoadModule("Actionbars"):UpdateMicroMenu()
				end,
				disabled = function() return not CO.db.profile.actionbar.micromenu.enable end,
			},
			borderUseClassColor = {
				type = "toggle",
				order = 23,
				name = L["UseClassColor"],
				desc = L["UseClassColorDesc"],
				get = function() return CO.db.profile.actionbar.micromenu.borderColor.useClassColor end,
				set = function(info, value) CO.db.profile.actionbar.micromenu.borderColor.useClassColor = value; E:LoadModule("Actionbars"):UpdateMicroMenu(); end,
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
					
					E:LoadModule("Actionbars"):UpdateMicroMenu()
				end,
				disabled = function() return not CO.db.profile.actionbar.micromenu.enable end,
			}
		},
	}
	
	for k,v in pairs(CD:GetMoverOptions("MicroMenu_CUIMover", 3, true)) do
		config.args[k] = v
	end

	return config
end

local GLOBAL_DISABLEDFUNC = function() return not CO.db.char.actionbar.enable end

local function GetABOptions_All()
	local config = {
		enable = {
			type = 'toggle',
			order = 0.1,
			name = L['EnableModule'],
			desc = 'Controls the state of the actionbar module. When disabled, you\'re just left with Blizzard actionbars and their textures etc.\n\nOn The upside, you then can use alternate AddOns like Bartender or Dominos to handle all actionbars.\n\nRequires a reload after enabling/disabling to take effect.\n\nThis is a character setting and is not being saved in your profile!',
			get = function(info) return CO.db.char.actionbar.enable end,
			set = function(info, value) CO.db.char.actionbar.enable = value; CD:ShowNotification('CHARACTERSETTING_NOTIFICATION') end,
		},
		allStyle = {
			type = "group",
			order = 1,
			name = L["Style"],
			disabled = GLOBAL_DISABLEDFUNC,
			args = {
				enableOverride = {
					type = "toggle",
					order = 0.8,
					width = "full",
					name = L['CharacterSetting'] .. " Override Spell Queue Window",
					desc = "When enabled, CUI override the Spell Queue Window CVar",
					get = function() return CO.db.char.CVars.overrideSpellQueueWindow end,
					set = function(info, value) CO.db.char.CVars.overrideSpellQueueWindow = value; if not value then CD:ShowNotification("CHARACTERSETTING_NOTIFICATION") end end,
				},
				clickOnDown = {
						type = "toggle",
						order = 0.85,
						name = L["ClickOnDown"],
						get = function() return GetCVarBool('ActionButtonUseKeyDown') and true or false end,
						set = function(info, value) SetCVar('ActionButtonUseKeyDown', value and 1 or 0) end,
					},
				spellQueue = {
					order = 0.9,
					type = 'range',
					name = L['CharacterSetting'] .. ' Spell Queue Window',
					desc = 'Overrides WoW\'s time how long a used spell is being kept in a queue before executing when it becomes ready. Time is in milliseconds.\n\nNote: Default value is 400!',
					min = 0, max = 400, step = 1,
					width = "full",
					get = function() return CO.db.char.CVars.spellQueueWindow end,
					set = function(info, value) CO.db.char.CVars.spellQueueWindow = value; E:UpdateCVars(); end,
					hidden = function() return not CO.db.char.CVars.overrideSpellQueueWindow end,
				},
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
						E:LoadModule("Actionbars"):UpdateActionButtonStyle()
				  end,
				  disabled = function() return CO.db.char.actionbar.useMasque end,
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
						E:LoadModule("Actionbars"):UpdateActionButtonStyle()
					end,
					disabled = function() return CO.db.char.actionbar.useMasque end,
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
						E:LoadModule("Actionbars"):UpdateActionButtonStyle()
				  end,
				  disabled = function() return CO.db.char.actionbar.useMasque end,
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
						E:LoadModule("Actionbars"):UpdateActionButtonStyle()
					end,
					disabled = function() return CO.db.char.actionbar.useMasque end,
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
						E:LoadModule("Actionbars"):UpdateActionButtonStyle()
				  end,
				  disabled = function() return CO.db.char.actionbar.useMasque end,
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
						E:LoadModule("Actionbars"):UpdateActionButtonStyle()
					end,
					disabled = function() return CO.db.char.actionbar.useMasque end,
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
						E:LoadModule("Actionbars"):UpdateActionButtonStyle()
				  end,
				  disabled = function() return CO.db.char.actionbar.useMasque end,
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
						E:LoadModule("Actionbars"):UpdateActionButtonStyle()
					end,
					disabled = function() return CO.db.char.actionbar.useMasque end,
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
					get = function() return CO.db.char.actionbar.useMasque end,
					set = function(info, value) CO.db.char.actionbar.useMasque = value; CD:ShowNotification("CHARACTERSETTING_NOTIFICATION") end,
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
	
	config.cooldown.args.filterType = {
		order = 5,
		type = 'select',
		name = L["NumberFormatting"],
		values = function() return E:GetAvailableNumberFormats() end,
		get = function()
			
			local value = TempConfig_Font.cooldown.cooldownFormat
			
			if value then
				return value
			end
		end,
		set = function(info, value)
			if value == -1 then
				value = nil
			end
			TempConfig_Font.cooldown.cooldownFormat = value
			UpdateAllFonts()
			E:LoadModule("Actionbars"):LoadConfig()
		end,
		disabled = config.cooldown.args.width.disabled,
	}
	
	config.hotkey.disabled 		= GLOBAL_DISABLEDFUNC
	config.cooldown.disabled 	= GLOBAL_DISABLEDFUNC
	config.count.disabled 		= GLOBAL_DISABLEDFUNC
	config.macro.disabled 		= GLOBAL_DISABLEDFUNC
	config.background.disabled 	= GLOBAL_DISABLEDFUNC
	
	return config
end

function Module:Disable()
	CD.Options.args.actionbar = nil
end

function Module:Enable()
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
				name = "|cffF2A72E" .. L["All"] .. "|r",
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
			--extrabar = GetOptionsTable_Extrabar(30),
			--zonebar = GetOptionsTable_Zonebar(40),
			extraAbilities = GetOptionsTable_ExtraAbilites(40),
			micromenu = GetOptionsTable_MicroMenu(50),
		},
	}
	
	CD.Options.args.actionbar.args.bar1.disabled 			= GLOBAL_DISABLEDFUNC
	CD.Options.args.actionbar.args.bar2.disabled 			= GLOBAL_DISABLEDFUNC
	CD.Options.args.actionbar.args.bar3.disabled 			= GLOBAL_DISABLEDFUNC
	CD.Options.args.actionbar.args.bar4.disabled 			= GLOBAL_DISABLEDFUNC
	CD.Options.args.actionbar.args.bar5.disabled 			= GLOBAL_DISABLEDFUNC
	CD.Options.args.actionbar.args.bar6.disabled 			= GLOBAL_DISABLEDFUNC
	CD.Options.args.actionbar.args.bar7.disabled 			= GLOBAL_DISABLEDFUNC
	CD.Options.args.actionbar.args.bar8.disabled 			= GLOBAL_DISABLEDFUNC
	CD.Options.args.actionbar.args.bar9.disabled 			= GLOBAL_DISABLEDFUNC
	CD.Options.args.actionbar.args.bar10.disabled 			= GLOBAL_DISABLEDFUNC
	CD.Options.args.actionbar.args.totembar.disabled 		= GLOBAL_DISABLEDFUNC
	CD.Options.args.actionbar.args.petbar.disabled 			= GLOBAL_DISABLEDFUNC
	CD.Options.args.actionbar.args.stancebar.disabled 		= GLOBAL_DISABLEDFUNC
	--CD.Options.args.actionbar.args.extrabar.disabled 		= GLOBAL_DISABLEDFUNC
	--CD.Options.args.actionbar.args.zonebar.disabled 		= GLOBAL_DISABLEDFUNC
	CD.Options.args.actionbar.args.extraAbilities.disabled 	= GLOBAL_DISABLEDFUNC
	CD.Options.args.actionbar.args.micromenu.disabled 		= GLOBAL_DISABLEDFUNC
end

CD:RegisterConfigModule(Module, 'Advanced')