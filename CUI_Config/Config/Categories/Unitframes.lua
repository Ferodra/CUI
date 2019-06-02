local E, L = unpack(CUI) -- Engine
local CO, CD, L, UF, BA = E:LoadModules("Config", "Config_Dialog", "Locale", "Unitframes", "Bar_Auras")

local _
local format = string.format

CD:InitializeOptionsCategory("unitframe", L["Unitframes"], 99999)

local sortDirectionsHorizontal = {
	["+"] = "Left > Right",
	["-"] = "Right > Left",
}

local sortDirectionsVertical = {
	["+"] = "Bottom > Top",
	["-"] = "Top > Bottom",
}

--------------------------------------------------------------------------
CD.AuraGrowthDirections = {
	["X"] = {["LEFT"] = "LEFT", ["RIGHT"] = "RIGHT"},
	["Y"] = {["UP"] = "UP", ["DOWN"] = "DOWN"},
}
CD.AuraSortDirections = {
	["+"] = "Ascending",
	["-"] = "Descending",
}
CD.AuraSortMethods = {
	["INDEX"] = "Index",
	["DURATION"] = "Duration",
	["TIME"] = "Time",
	["NAME"] = "Name",
}
CD.AuraAttachPoints = {
	["Frame"] = "Frame",
	["Buffs"] = "Buffs",
	["Debuffs"] = "Debuffs",
}
--------------------------------------------------------------------------

local OnlyAurasFromType = {
	[""] = "(All)",
	["HELPFUL"] = "Buffs",
	["HARMFUL"] = "Debuffs",
}

local GroupNames = {
	"player", "target", "targettarget", "focus", "focustarget", "pet", "arena", "party", "boss", "raid", "raid40"
}
local TextTypes = {
	"name", "health", "power", "level"
}

CD.DummyMode = false
local DummyShowIndex = true

local function ToggleIndex(state)
	
	local self = E:GetModule("Unitframes")
	
	for k,v in pairs(self.Frames) do
		if state then
			if CO.db.profile.unitframe.dummyShowIndex == true and CD.DummyMode then
				v.Fonts.Index:Show()
			end
		else
			v.Fonts.Index:Hide()
		end
	end
end

local function ToggleAuras(state)
	
	local UAUR = UF.Modules["Auras"]
	
	if state then
		if CO.db.profile.unitframe.dummyShowAuras == true and CD.DummyMode then
			UAUR:ToggleTestMode(true)
		end
	else
		UAUR:ToggleTestMode(false)
	end
end

local function SetUnitDummys(state)
	
	local self = E:GetModule("Unitframes")
	
	-- Set dummy units
	for k, v in pairs(self.Frames) do
		if state == true then
			v:SetAttribute("unit", "player")
			v.Unit = "player"
			
			v.Fonts.Level.Unit = "player"
			v.Fonts.Name.Unit = "player"
		else
			v:SetAttribute("unit", v.BackupUnit)
			v.Unit = v.BackupUnit
			
			v.Fonts.Level.Unit = v.BackupUnit			
			v.Fonts.Name.Unit = v.BackupUnit
		end
		
		-- Also temporarily override module unit(s) and push update
		for _, ufmodule in pairs(v) do
			if type(ufmodule) == "table" and ufmodule.ForceUpdate then
				if state == true then
					ufmodule.Unit = "player"
					ufmodule:ForceUpdate()
				else
					ufmodule.Unit = v.BackupUnit
					ufmodule:ForceUpdate()
				end
			end
		end
	end
	
	-- Update based on new values
	self:UpdateAllUF()
	
	-- Override
	for k,v in pairs(self.Frames) do
		if state == true then
			-- MISC MODULES OVERRIDE
				v:SetScript("OnShow", nil)
				
				v.Role.T:SetTexture(self.RoleTexture["DAMAGER"])
				v.Role:Show()
				--v.Leader
				--v.TargetIcon
				--v.RezIcon
			-- MISC MODULES OVERRIDE END
		else
			-- MISC MODULES OVERRIDE
				v:SetScript("OnShow", v.OnEvent)
			-- MISC MODULES OVERRIDE END
		end
	end
	
	ToggleIndex(state)
	--ToggleAuras(state)
	self:OverrideHolderVisibility(state)
end

local function ToggleCombatIndicator()
	local CI = UF.Frames.player.CombatIndicator
	local db = CO.db.profile.unitframe.units.player.combatIndicator
	
	if CI then
		if not CI.testState then
			if CI.enableGlow then UIFrameFadeIn(CI.Border, db.glowFadeIn, 0, 1) end
			if CI.enableIcon then UIFrameFadeIn(CI.Icon, db.iconFadeIn, 0, 1) end
			
			CI.testState = true
		else
			if CI.enableGlow then UIFrameFadeOut(CI.Border, db.glowFadeOut, 1, 0) end
			if CI.enableIcon then UIFrameFadeOut(CI.Icon, db.iconFadeOut, 1, 0) end			
			
			CI.testState = false
		end
	end
end

function ToggleResIndicator(unit)
	for k,v in pairs(UF.Frames[unit]) do
		if k == "ResurrectIndicator" then
			if not v.TestState then
				
				v:Show()
				
				v.TestState = true
			else
				v:ForceUpdate()
				
				v.TestState = false
			end
		end
	end
end

function ToggleReadyCheck(unit)
	for k,v in pairs(UF.Frames[unit]) do
		if k == "ReadyCheckIndicator" then
			if not v.TestState then
				
				local Key = E:GetRandomTableKey(UF.ReadyCheckStates)
				local Color = CO.db.profile.colors.readycheck[Key]
				
				v.T:SetTexture(UF.ReadyCheckStates[Key])
				v.T:SetVertexColor(Color[1], Color[2], Color[3])
				
				v:Show()
				
				v.TestState = true
			else
				v:Hide()
				
				v.TestState = false
			end
		end
	end
end

function ToggleSummonIndicator(unit)
	for k,v in pairs(UF.Frames[unit]) do
		if k == "SummonIndicator" then
			if not v.TestState then
				
				v.T:SetAtlas('Raid-Icon-SummonPending')
				v:Show()
				
				v.TestState = true
			else
				v:ForceUpdate()
				
				v.TestState = false
			end
		end
	end
end

local function ToggleRoleIcon(unit)
	for k,v in pairs(UF.Frames[unit]) do
		if k == "Role" then
			if not v.TestState then
				
				v.T:SetTexture(E:GetRandomTableEntry(UF.RoleTexture))
				v:Show()
				
				v.TestState = true
			else
				v:ForceUpdate()
				
				v.TestState = false
			end
		end
	end
end

local function ToggleLeaderIcon(unit)
	for k,v in pairs(UF.Frames[unit]) do
		if k == "LeaderIcon" then
			if not v.TestState then
				v.T:SetTexture([[Interface\GroupFrame\UI-Group-LeaderIcon]])
				v:Show()
				
				v.TestState = true
			else
				v:ForceUpdate()
				
				v.TestState = false
			end
		end
	end
end

local function ToggleTargetIcon(unit)
	for k,v in pairs(UF.Frames[unit]) do
		if k == "TargetIcon" then
			if not v.TestState then
				if not v.T:GetTexture() then
					v.T:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
				end
				SetRaidTargetIconTexture(v.T, 1)
				v:Show()
				
				v.TestState = true
			else
				v:ForceUpdate()
				
				v.TestState = false
			end
		end
	end
end

local function GetOptionsTable_General(groupName)
	
	local ClusterConfig = UF:GetClusterConfig(CO.db.profile.unitframe.units[groupName].UFInfo.cluster.clusterName)
	
	local config = {
		order = 100,
		type = 'group',
		name = L["General"],
		get = function(info) return CO.db.profile.unitframe.units[groupName][ info[#info] ] end,
		set = function(info, value) CO.db.profile.unitframe.units[groupName][ info[#info] ] = value; UF:LoadHolderConfig(groupName); UF:LoadProfileForUnits(groupName); end,
		args = {
		generalHeader = {
				type = "header",
				name = L["Positioning"],
				order = 1,
			},
		enableAttach = {
			type = "toggle",
			order = 2,
			name = L["AttachMode"],
			width = "full",
			set = function(info, value) CO.db.profile.movers[UF:GetUFMover(groupName):GetName()]["enableAttach"] = value end,
			get = function(info) return CO.db.profile.movers[UF:GetUFMover(groupName):GetName()]["enableAttach"] end,
			},
		attachFrame = {
			type = "input",
			order = 3,
			name = L["AttachToFrame"],
			width = "double",
			set = function(info, value) CO.db.profile.movers[UF:GetUFMover(groupName):GetName()]["attachTo"][1] = value end,
			get = function(info) 
				E:LoadMoverPositions(UF:GetUFMover(groupName):GetName())
				return CO.db.profile.movers[UF:GetUFMover(groupName):GetName()]["attachTo"][1]
			end,
			disabled = function() return CO.db.profile.movers[UF:GetUFMover(groupName):GetName()]["enableAttach"] == false end,
			},
		attachFrameSelect = {
			type = "execute",
			order = 4,
			name = L["FrameChooserButton"],
			func = function()
				CD:ToggleFrameChooser(CO.db.profile.movers[UF:GetUFMover(groupName):GetName()]["attachTo"])
			end,
			disabled = function() return CO.db.profile.movers[UF:GetUFMover(groupName):GetName()]["enableAttach"] == false end,
			},
		position = {
				type = 'select',
				order = 10,
				name = "Position",
				desc = "Repositions this frame to a specific corner of your screen. Keep in mind your offsets when wondering where they went!",
				values = E.Positions,
				get = function(info)
					return CO.db.profile.movers[UF:GetUFMover(groupName):GetName()]["point"]
				end,
				set = function(info, value)
					local MoverName = UF:GetUFMover(groupName):GetName()
						CO.db.profile.movers[MoverName]["point"] = value
						CO.db.profile.movers[MoverName]["relativePoint"] = value
						E:LoadMoverPositions(MoverName)
				end,
			},
		xOffset = {
				order = 11,
				type = 'range',
				name = L["XOffset"],
				desc = "Moves this frame along the X axis [horizontal]\n\nSupports hard values from -1920 to 1920",
				softMin = -500, softMax = 500, step = 1,
				min = -1920, max = 1920, step = 1,
				get = function(info)
					return CO.db.profile.movers[UF:GetUFMover(groupName):GetName()]["xOffset"]
				end,
				set = function(info, value)
					local MoverName = UF:GetUFMover(groupName):GetName()
						CO.db.profile.movers[MoverName]["xOffset"] = value
						E:LoadMoverPositions(MoverName)
				end,
			},
		yOffset = {
				order = 12,
				type = 'range',
				name = L["YOffset"],
				desc = "Moves this frame along the Ý axis [vertical]\n\nSupports hard values from -1920 to 1920",
				softMin = -500, softMax = 500, step = 1,
				min = -1920, max = 1920, step = 1,
				get = function(info)
					return CO.db.profile.movers[UF:GetUFMover(groupName):GetName()]["yOffset"]
				end,
				set = function(info, value)
					local MoverName = UF:GetUFMover(groupName):GetName()
						CO.db.profile.movers[MoverName]["yOffset"] = value
						E:LoadMoverPositions(MoverName)
				end,
			},
		rangeHeader = {
			type = "header",
			name = "Range Indicator",
			order = 100,
			hidden = (groupName == "player"),
			},
		rangeIndicator = {
			type = "toggle",
			order = 101,
			hidden = (groupName == "player"),
			name = "Enable",
			desc = "When enabled, this unitframe will become slightly transparent when the unit is a certain distance away from you.",
			width = "full",
			},
		},
	}
	
	
	
		if groupName == "raid" or groupName == "raid40" or groupName == "party" or groupName == "arena" or groupName == "boss" then
			local extension = {
				groupHeader = {
					order = 50,
					type = "header",
					name = "Frame Cluster",
				},
				perRow = {
					order = 51,
					type = 'range',
					name = "Frames Per Row",
					desc = "Limits the number of frames that should be displayed in one row",
					width = "full", -- Feels better
					min = 1, max = 40, step = 1,
					get = function() return ClusterConfig.perRow end,
					set = function(info, value) ClusterConfig.perRow = value; UF:LoadHolderConfig(groupName) end,
				},
				gapX = {
					order = 55,
					type = 'range',
					name = "X Gap",
					desc = "Modifies the horizontal gap between each member of this cluster",
					width = "full", -- Feels better
					min = 0, max = 50, step = 1,
					get = function() return ClusterConfig.gapX end,
					set = function(info, value) ClusterConfig.gapX = value; UF:LoadHolderConfig(groupName) end,
				},
				gapY = {
					order = 56,
					type = 'range',
					name = "Y Gap",
					desc = "Modifies the vertical gap between each member of this cluster",
					width = "full", -- Feels better
					min = 0, max = 50, step = 1,
					get = function() return ClusterConfig.gapY end,
					set = function(info, value) ClusterConfig.gapY = value; UF:LoadHolderConfig(groupName) end,
				},
				inverseStartX = {
					type = 'toggle',
					order = 57,
					name = "Inverse Horizontal",
					desc = "Inverts the Horizontal sort direction",
					get = function() return ClusterConfig.inverseStartX end,
					set = function(info, value) ClusterConfig.inverseStartX = value; UF:LoadHolderConfig(groupName) end,
				},
				inverseStartY = {
					type = 'toggle',
					order = 58,
					name = "Inverse Vertical",
					desc = "Inverts the Vertical sort direction",
					get = function() return ClusterConfig.inverseStartY end,
					set = function(info, value) ClusterConfig.inverseStartY = value; UF:LoadHolderConfig(groupName) end,
				},
				visibilityCondition = {
					order = 59,
					type = 'input',
					name = "Visibility",
					desc = "A string of macro conditionals to determine, whether the cluster should be displayed.\nSome possible values:\n[group:party] [group:raid] [combat] [vehicle] [flying] [form:N] [stealth]\n\nFind more at https://wow.gamepedia.com/Macro_conditionals",
					width = "full",
					get = function() return ClusterConfig.visibilityCondition end,
					set = function(info, value) ClusterConfig.visibilityCondition = value; UF:LoadHolderConfig(groupName) end,
				},
				defaultVisibility = {
					order = 60,
					type = "execute",
					name = "Default Visiblity",
					desc = "In case you want to reset the visiblity string to default",
					func = function()
						ClusterConfig.visibilityCondition = E.ConfigDefaults.profile.unitframe.units[groupName].visibilityCondition
						UF:LoadHolderConfig(groupName)
					end,
				},
			}
			
			for k,v in pairs(extension) do
				config.args[k] = v
			end
		end
	
	

	return config
end

local function GetOptionsTable_HealthBar(groupName)
	
	local config = {
		order = 101,
		type = 'group',
		name = L["Health Bar"],
		get = function(info) return CO.db.profile.unitframe.units[groupName].health[ info[#info] ] end,
		set = function(info, value) CO.db.profile.unitframe.units[groupName].health[ info[#info] ] = value; UF.Modules["BarHealth"]:LoadProfile(); UF:LoadProfileForUnits(groupName); UF.Modules["HealPrediction"]:LoadProfile(); UF:LoadHolderConfig(groupName) end,
		args = {
			position = {
				type = "execute",
				order = 1,
				name = L["Position"],
				func = function() CD.ACD:SelectGroup("CUI", "unitframe", groupName, "generalGroup") end,
			},
			newLine5 = {type="description", name="", order=5},
			width = {
				order = 10,
				type = 'range',
				name = L["Width"],
				min = 1, max = 800, step = 1,
			},
			height = {
				order = 11,
				type = 'range',
				name = L["Height"],
				min = 1, max = 800, step = 1,
			},
			newLine = {type="description", name="", order=15},
			barBorderSize = {
				order = 16,
				type = 'range',
				name = L["BorderSize"],
				min = -20, max = 20, step = 0.1,
			},
			barBorderColor = {
				order = 17,
				type = 'color',
				name = L["BorderColor"],
				hasAlpha = true,
				get = function(info)
					local c = CO.db.profile.unitframe.units[groupName].health.barBorderColor
					return c[1], c[2], c[3], c[4]
				end,
				set = function(info, r, g, b, a)
					local c = CO.db.profile.unitframe.units[groupName].health.barBorderColor
					c[1], c[2], c[3], c[4] = r, g, b, a
					
					UF.Modules["BarHealth"]:LoadProfile();
				end,
			},
			newLine2 = {type="description", name="", order=20},
			barBackgroundColor = {
				order = 21,
				type = 'color',
				name = L["BackgroundColor"],
				hasAlpha = true,
				get = function(info)
					local c = CO.db.profile.unitframe.units[groupName].health.barBackgroundColor
					return c[1], c[2], c[3], c[4]
				end,
				set = function(info, r, g, b, a)
					local c = CO.db.profile.unitframe.units[groupName].health.barBackgroundColor
					c[1], c[2], c[3], c[4] = r, g, b, a
					
					UF.Modules["BarHealth"]:LoadProfile();
				end,
			},
			newLine3 = {type="description", name="", order=25},
			overrideBarTexture = {
				order = 26,
				type = "toggle",
				name = "Override Bar Texture",
				desc = "Uses the override Texture when enabled. Uses global Texture when disabled.",
			},
			barTexture = {
				type = "select", dialogControl = 'LSM30_Statusbar',
				order = 27,
				name = "Override Texture",
				values = CO.AceGUIWidgetLSMlists["statusbar"],
				disabled = function() return not CO.db.profile.unitframe.units[groupName].health.overrideBarTexture end,
			},
			barSystemHeader = {
				type = "header",
				order = 30,
				name = "Bar System",
			},
			barInverseFill = {
				order = 31,
				type = "toggle",
				name = "Bar Inverse Fill",
				desc = "Inverts the fill direction of this bar",
			},
			barOrientation = {
				type = 'select',
				order = 32,
				name = "Fill Direction",
				desc = "How the bar should be filled. Vertical or Horizontal.",
				values = CD.SortBarOrientation,
			},
			fastUpdate = {
				order = 33,
				type = 'toggle',
				hidden = not (groupName ~= "player" and groupName ~= "target"),
				name = "Fast Update",
				desc = "Increases the update speed of that bar. Can decrease performance when used too often, be careful!",
				width = "full",
			},
			barSmooth = {
				order = 34,
				type = 'toggle',
				name = "Smooth Bar",
				desc = "Smoothes out the bar value transition at the cost of performance.",
				width = "full",
			},
		},
	}

	return config
end

local function GetOptionsTable_PowerBar(groupName)
	
	local config = {
		order = 102,
		type = 'group',
		name = L["Power Bar"],
		get = function(info) return CO.db.profile.unitframe.units[groupName].power[ info[#info] ] end,
		set = function(info, value) CO.db.profile.unitframe.units[groupName].power[ info[#info] ] = value; UF.Modules["BarPower"]:LoadProfile(); UF:LoadHolderConfig(groupName) end,
		args = {
			barWidth = {
				order = 10,
				type = 'range',
				name = L["Width"],
				min = 1, max = 800, step = 1,
			},
			barHeight = {
				order = 11,
				type = 'range',
				name = L["Height"],
				min = 1, max = 800, step = 1,
			},
			newLine = {type="description", name="", order=15},
			barPosition = {
				type = 'select',
				order = 16,
				name = L["Position"],
				values = E.Positions,
			},
			barXOffset = {
				order = 17,
				type = 'range',
				name = L["XOffset"],
				min = -300, max = 300, step = 1,
			},
			barYOffset = {
				order = 18,
				type = 'range',
				name = L["YOffset"],
				min = -300, max = 300, step = 1,
			},
			newLine2 = {type="description", name="", order=20},
			barBorderSize = {
				order = 21,
				type = 'range',
				name = L["BorderSize"],
				min = -20, max = 20, step = 0.1,
			},
			barBorderColor = {
				order = 22,
				type = 'color',
				name = L["BorderColor"],
				hasAlpha = true,
				get = function(info)
					local c = CO.db.profile.unitframe.units[groupName].power.barBorderColor
					return c[1], c[2], c[3], c[4]
				end,
				set = function(info, r, g, b, a)
					local c = CO.db.profile.unitframe.units[groupName].power.barBorderColor
					c[1], c[2], c[3], c[4] = r, g, b, a
					
					UF.Modules["BarPower"]:LoadProfile();
				end,
			},
			barBackgroundColor = {
				order = 23,
				type = 'color',
				name = L["BackgroundColor"],
				hasAlpha = true,
				get = function(info)
					local c = CO.db.profile.unitframe.units[groupName].power.barBackgroundColor
					return c[1], c[2], c[3], c[4]
				end,
				set = function(info, r, g, b, a)
					local c = CO.db.profile.unitframe.units[groupName].power.barBackgroundColor
					c[1], c[2], c[3], c[4] = r, g, b, a
					
					UF.Modules["BarPower"]:LoadProfile();
				end,
			},
			newLine3 = {type="description", name="", order=24},
			overrideBarTexture = {
				order = 25,
				type = "toggle",
				name = "Override Bar Texture",
				desc = "Uses the override Texture when enabled. Uses global Texture when disabled.",
			},
			barTexture = {
				type = "select", dialogControl = 'LSM30_Statusbar',
				order = 26,
				name = "Override Texture",
				values = CO.AceGUIWidgetLSMlists["statusbar"],
				disabled = function() return not CO.db.profile.unitframe.units[groupName].power.overrideBarTexture end,
			},
			barSystemHeader = {
				type = "header",
				order = 30,
				name = "Bar System",
			},
			barInverseFill = {
				order = 31,
				type = "toggle",
				name = "Bar Inverse Fill",
				desc = "Inverts the fill direction of this bar",
			},
			barOrientation = {
				type = 'select',
				order = 32,
				name = "Fill Direction",
				desc = "How the bar should be filled. Vertical or Horizontal.",
				values = CD.SortBarOrientation,
			},
			fastUpdate = {
				order = 33,
				type = 'toggle',
				hidden = not (groupName ~= "player" and groupName ~= "target"),
				name = "Fast Update",
				desc = "Increases the update speed of that bar. Can decrease performance when used too often, be careful!",
				width = "full",
			},
			barSmooth = {
				order = 34,
				type = 'toggle',
				name = "Smooth Bar",
				desc = "Smoothes out the bar value transition at the cost of performance.",
				width = "full",
			},
		},
	}

	return config
end

local function GetAdvancedCastbarTextConfig(groupName, fontType, order)
	local config = {
		enable = {
			type = "toggle",
			order = order + 1,
			name = L["Enable"],
			width = "full",
		},
		width = {
			order = order + 2,
			type = 'range',
			name = L["Width"],
			desc = "Width of the font container. Used for horizontal alignment. Leave at 0 if unsure",
			min = 0, max = 500, step = 1,
			disabled = function() return not CO.db.profile.unitframe.units[groupName].castbar.fonts[fontType]["enable"] end,
		},
		positionHeader = {
			order = order + 10,
			type = "header",
			name = L["Positioning"],
		},
		position = {
			type = 'select',
			order = order + 11,
			name = L["Position"],
			values = E.Positions,
			disabled = function() return not CO.db.profile.unitframe.units[groupName].castbar.fonts[fontType]["enable"] end,
		},
		xOffset = {
			order = order + 12,
			type = 'range',
			name = L["XOffset"],
			desc = L["XOffset"],
			min = -300, max = 300, step = 1,
			disabled = function() return not CO.db.profile.unitframe.units[groupName].castbar.fonts[fontType]["enable"] end,
		},
		yOffset = {
			order = order + 13,
			type = 'range',
			name = L["YOffset"],
			desc = L["YOffset"],
			min = -300, max = 300, step = 1,
			disabled = function() return not CO.db.profile.unitframe.units[groupName].castbar.fonts[fontType]["enable"] end,
		},
		horizontalAlign = {
			name = L["HorizontalAlign"],
			type = "select",
			desc = "Sets the horizontal growth direction of this font. Left sets the growth to right. Right sets it to left. Just like in any text-processing program. To reposition the font, use the position dropdown. Is being affected by the font container width.",
			order = order + 14,
			-- style = "dropdown",
			values = CD.FontHorizontalAlign,
			disabled = function() return not CO.db.profile.unitframe.units[groupName].castbar.fonts[fontType]["enable"] end,
		},
		styleHeader = {
			order = order + 20,
			type = "header",
			name = L["FontStyle"],
		},
		fontHeight = {
			order = order + 21,
			type = 'range',
			name = L["FontHeight"],
			desc = L["FontHeight"],
			min = 3, max = 90, step = 1,
			disabled = function() return not CO.db.profile.unitframe.units[groupName].castbar.fonts[fontType]["enable"] end,
		},
		fontType = {
		  name = L["FontType"],
		  dialogControl = "LSM30_Font",
		  type = "select",
		  desc = L["FontType"],
		  order = order + 22,
		  values = CO.AceGUIWidgetLSMlists["font"],
		  disabled = function() return not CO.db.profile.unitframe.units[groupName].castbar.fonts[fontType]["enable"] end,
		},
		fontFlags = {
		  name = L["FontFlags"],
		  type = "select",
		  desc = L["FontFlags"],
		  order = order + 23,
		  values = CD.FontFlags,
		  disabled = function() return not CO.db.profile.unitframe.units[groupName].castbar.fonts[fontType]["enable"] end,
		},
		fontColor = {
			name = "Font Color",
			type = "color",
			hasAlpha = true,
			order = order + 24,
			get = function(info)
					local c = CO.db.profile.unitframe.units[groupName].castbar.fonts[fontType]["fontColor"]
					return c[1], c[2], c[3], c[4]
			end,
			set = function(info, r, g, b, a)
					local color = CO.db.profile.unitframe.units[groupName].castbar.fonts[fontType]["fontColor"]
					color[1], color[2], color[3], color[4] = r, g, b, a
					E:GetModule("Bar_Cast"):LoadProfile()
			end,
			disabled = function() return not CO.db.profile.unitframe.units[groupName].castbar.fonts[fontType]["enable"] end,
		},
		shadowHeader = {
			order = order + 30,
			type = "header",
			name = L["TextShadow"],
		},
		fontShadowColor = {
		  name = L["TextShadowColor"],
		  type = "color",
		  hasAlpha = true,
		  order = order + 31,
		  get = function(info)
				local c = CO.db.profile.unitframe.units[groupName].castbar.fonts[fontType]["fontShadowColor"]
					return c[1], c[2], c[3], c[4]
		  end,
		  set = function(info, r, g, b, a)
				local color = CO.db.profile.unitframe.units[groupName].castbar.fonts[fontType]["fontShadowColor"]
				color[1], color[2], color[3], color[4] = r, g, b, a
				E:GetModule("Bar_Cast"):LoadProfile()
		  end,
		  disabled = function() return not CO.db.profile.unitframe.units[groupName].castbar.fonts[fontType]["enable"] end,
		},
		xFontShadowOffset = {
			order = order + 32,
			type = 'range',
			name = L["XOffset"],
			min = -10, max = 10, step = 1,
			disabled = function() return not CO.db.profile.unitframe.units[groupName].castbar.fonts[fontType]["enable"] end,
		},
		yFontShadowOffset = {
			order = order + 33,
			type = 'range',
			name = L["YOffset"],
			min = -10, max = 10, step = 1,
			disabled = function() return not CO.db.profile.unitframe.units[groupName].castbar.fonts[fontType]["enable"] end,
		},
	}
	
	return config
end

local function GetOptionsTable_CastBar(groupName)
	
	local config = {
		order = 101,
		type = 'group',
		name = L["Castbar"],
		childGroups = "tab",
		get = function(info) return CO.db.profile.unitframe.units[groupName].castbar[ info[#info] ] end,
		set = function(info, value) CO.db.profile.unitframe.units[groupName].castbar[ info[#info] ] = value; E:GetModule("Bar_Cast"):LoadProfile() end,
		args = {
			enable = {
				type = "toggle",
				order = 1,
				name = L["Enable"],
			},
			show = {
				type = "execute",
				order = 2,
				name = L["Toggle"],
				func = function()
					UF:PerformForUnits(groupName, E:GetModule("Bar_Cast").Toggle)
				end,
			},
			barSettings = {
				type = "group",
				order = 5,
				name = L["Bar"],
				args = {
					barHeader = {
						type = "header",
						name = "Bar Settings",
						order = 10,
					},
					width = {
						order = 10,
						type = 'range',
						name = L["Width"],
						min = 1, max = 800, step = 1,
					},
					height = {
						order = 11,
						type = 'range',
						name = L["Height"],
						min = 1, max = 800, step = 1,
					},
					barPosition = {
						type = 'select',
						order = 12,
						name = L["Position"],
						hidden = (groupName == "player" or groupName == "target" or groupName == "focus" or groupName == "targettarget" or groupName == "pet" or groupName == "focustarget"),
						values = E.Positions,
					},
					barOffsetX = {
						order = 13,
						type = 'range',
						name = L["XOffset"],
						hidden = (groupName == "player" or groupName == "target" or groupName == "focus" or groupName == "targettarget" or groupName == "pet" or groupName == "focustarget"),
						min = -300, max = 300, step = 1,
					},
					barOffsetY = {
						order = 14,
						type = 'range',
						name = L["YOffset"],
						hidden = (groupName == "player" or groupName == "target" or groupName == "focus" or groupName == "targettarget" or groupName == "pet" or groupName == "focustarget"),
						min = -300, max = 300, step = 1,
					},
					barSystemHeader = {
						type = "header",
						order = 30,
						name = "Bar System",
					},
					barInverseFill = {
						order = 31,
						type = "toggle",
						name = "Bar Inverse Fill",
						desc = "Inverts the fill direction of this bar",
					},
					barOrientation = {
						type = 'select',
						order = 32,
						name = "Fill Direction",
						desc = "How the bar should be filled. Vertical or Horizontal.",
						values = CD.SortBarOrientation,
					},
					barStyle = {
						order = 40,
						type = "header",
						name = "Bar Style"
					},
					sparkWidth = {
						order = 41,
						type = "range",
						name = "Spark Width",
						desc = "Hard max is at 512",
						softMin = 8, softMax = 128,
						min = 1, max = 512, step = 1
					},
					sparkHeight = {
						order = 42,
						type = "range",
						name = "Spark Height",
						desc = "Hard max is at 512",
						softMin = 8, softMax = 128,
						min = 1, max = 512, step = 1
					},
					barBorderSize = {
						order = 43,
						type = 'range',
						name = L["BorderSize"],
						min = -20, max = 20, step = 0.1,
					},
					barBorderColor = {
						name = L["BorderColor"],
						type = "color",
						hasAlpha = true,
						order = 44,
						get = function(info)
							local c = CO.db.profile.unitframe.units[groupName].castbar.barBorderColor
							return c[1], c[2], c[3], c[4]
						end,
						set = function(info, r, g, b, a)
							local color = CO.db.profile.unitframe.units[groupName].castbar.barBorderColor
							color[1], color[2], color[3], color[4] = r, g, b, a
							E:GetModule("Bar_Cast"):LoadProfile()
						end,
					},
				},
			},
			iconSettings = {
				type = "group",
				order = 6,
				name = L["Icon"],
				args = {
					iconHeader = {
						type = "header",
						name = "Icon Settings",
						order = 20,
					},
					enableIcon = {
						type = "toggle",
						order = 21,
						name = "Enable Icon",
						width = "full",
					},
					iconSize = {
						order = 22,
						type = 'range',
						name = "Icon Size",
						min = 1, max = 90, step = 0.5,
						width = "full",
					},
					iconOffsetX = {
						order = 23,
						type = 'range',
						name = L["XOffset"],
						min = -300, max = 300, step = 1,
					},
					iconOffsetY = {
						order = 24,
						type = 'range',
						name = L["YOffset"],
						min = -300, max = 300, step = 1,
					},
					iconPosition = {
						type = 'select',
						order = 25,
						name = L["Position"],
						values = E.Positions,
					},
				},
			},
			
			
		},
	}
	
	if (groupName == "player" or groupName == "target" or groupName == "focus" or groupName == "pet" or groupName == "targettarget" or groupName == "focustarget") then
		for k,v in pairs(CD:GetMoverOptions(format("CUI_%sCastbar1Mover", groupName), 12, true)) do
			config.args.barSettings.args[k] = v
		end
	end
	local Fonts = {{Path = format("db.profile.unitframe.units.%s.castbar.fonts.time", groupName), Order = 100, GroupName = L["Time"]}, {Path = format("db.profile.unitframe.units.%s.castbar.fonts.name", groupName), Order = 200, GroupName = L["Name"]}}
	for k,v in pairs(CD:GetFontOptions(Fonts)) do
		config.args[k] = v
	end

	return config
end

local function GetOptionsTable_MaxLevel(groupName, tableType)
	local doNotShowOnMaxLevel
	
	if tableType == "level" then
		doNotShowOnMaxLevel = {
			type = "toggle",
			order = 2,
			name = L["NotOnMaxlevel"],
		}
	end
	
	return doNotShowOnMaxLevel
end



-- tableType such as "name", "level" or "power" . . . .
local function GetOptionsTable_Text(groupName, tableType)
	
	local config = {
		order = 100,
		type = 'group',
		name = L[E:firstToUpper(tableType)],
		get = function(info) return CO.db.profile.unitframe.units[groupName].fonts[tableType][ info[#info] ] end,
		set = function(info, value) CO.db.profile.unitframe.units[groupName].fonts[tableType][ info[#info] ] = value; UF:LoadProfileForUnits(groupName, "fonts") end,
		args = {
			enable = {
				type = "toggle",
				order = 2,
				name = L["Enable"],
				width = "full",
			},
			width = {
				order = 3,
				type = 'range',
				name = L["Width"],
				desc = "Width of the font container. Used for horizontal alignment. Leave at 0 if unsure",
				min = 0, max = 500, step = 1,
				disabled = function() return not CO.db.profile.unitframe.units[groupName].fonts[tableType].enable end,
			},
			positionHeader = {
				order = 30,
				type = "header",
				name = L["Positioning"],
			},
			position = {
				type = 'select',
				order = 31,
				name = L["Position"],
				values = E.Positions,
				disabled = function() return not CO.db.profile.unitframe.units[groupName].fonts[tableType].enable end,
			},
			xOffset = {
				order = 32,
				type = 'range',
				name = L["XOffset"],
				min = -300, max = 300, step = 1,
				disabled = function() return not CO.db.profile.unitframe.units[groupName].fonts[tableType].enable end,
			},
			yOffset = {
				order = 33,
				type = 'range',
				name = L["YOffset"],
				min = -300, max = 300, step = 1,
				disabled = function() return not CO.db.profile.unitframe.units[groupName].fonts[tableType].enable end,
			},
			horizontalAlign = {
				name = L["HorizontalAlign"],
				type = "select",
				desc = "Sets the horizontal growth direction of this font. Left sets the growth to right. Right sets it to left. Just like in any text-processing program. To reposition the font, use the position dropdown. Is being affected by the font container width.",
				order = 34,
				-- style = "dropdown",
				values = CD.FontHorizontalAlign,
				disabled = function() return not CO.db.profile.unitframe.units[groupName].fonts[tableType].enable end,
			},
			styleHeader = {
				order = 40,
				type = "header",
				name = L["FontStyle"],
			},
			fontHeight = {
				order = 41,
				type = 'range',
				name = L["FontHeight"],
				min = 3, max = 90, step = 1,
				disabled = function() return not CO.db.profile.unitframe.units[groupName].fonts[tableType].enable end,
			},
			fontType = {
			  name = L["FontType"],
			  dialogControl = "LSM30_Font",
			  type = "select",
			  order = 42,
			  values = CO.AceGUIWidgetLSMlists["font"],
			  disabled = function() return not CO.db.profile.unitframe.units[groupName].fonts[tableType].enable end,
			},
			fontFlags = {
			  name = L["FontFlags"],
			  type = "select",
			  order = 43,
			  values = CD.FontFlags,
			  disabled = function() return not CO.db.profile.unitframe.units[groupName].fonts[tableType].enable end,
			},
			fontColor = {
				name = L["FontColor"],
				type = "color",
				hasAlpha = true,
				order = 45,
				hidden = not (tableType == "health" or tableType == "level"),
				get = function(info)
						local c = CO.db.profile.unitframe.units[groupName].fonts[tableType]["fontColor"]
						return c[1], c[2], c[3], c[4]
				end,
				set = function(info, r, g, b, a)
						local color = CO.db.profile.unitframe.units[groupName].fonts[tableType]["fontColor"]
						color[1], color[2], color[3], color[4] = r, g, b, a
						UF:LoadProfileForUnits(groupName, "fonts")
				end,
				disabled = function() return not CO.db.profile.unitframe.units[groupName].fonts[tableType].enable end,
			},
			textFormat = {
				order = 46,
				type = 'input',
				name = "Text-Format",
				desc = "A string of various format types for this font.\nPossible values:\n[health], [health-formatted], [health-max], [health-max-formatted], [health-pct]\n\n[power], [power-formatted], [power-max], [power-max-formatted], [power-pct]\n\n[name], [level], [level-max]\n\n[class], [raidgroup], [guild-name], [guild-rank-name]\n\n[newline]",
				width = "full",
				disabled = function() return not CO.db.profile.unitframe.units[groupName].fonts[tableType].enable end,
			},
			shadowHeader = {
				order = 50,
				type = "header",
				name = L["TextShadow"],
			},
			fontShadowColor = {
			  name = L["TextShadowColor"],
			  type = "color",
			  hasAlpha = true,
			  order = 51,
			  get = function(info)
					local c = CO.db.profile.unitframe.units[groupName].fonts[tableType]["fontShadowColor"]
						return c[1], c[2], c[3], c[4]
			  end,
			  set = function(info, r, g, b, a)
					local color = CO.db.profile.unitframe.units[groupName].fonts[tableType]["fontShadowColor"]
					color[1], color[2], color[3], color[4] = r, g, b, a
					UF:LoadProfileForUnits(groupName, "fonts")
			  end,
			  disabled = function() return not CO.db.profile.unitframe.units[groupName].fonts[tableType].enable end,
			},
			xFontShadowOffset = {
				order = 52,
				type = 'range',
				name = L["XOffset"],
				min = -10, max = 10, step = 1,
				disabled = function() return not CO.db.profile.unitframe.units[groupName].fonts[tableType].enable end,
			},
			yFontShadowOffset = {
				order = 53,
				type = 'range',
				name = L["YOffset"],
				min = -10, max = 10, step = 1,
				disabled = function() return not CO.db.profile.unitframe.units[groupName].fonts[tableType].enable end,
			},
			doNotShowOnMaxLevel = GetOptionsTable_MaxLevel(groupName, tableType),
		},
	}

	return config
end

local function GetOptionsTable_BarTexture(index)
	local barTexture = {
		type = "select", dialogControl = 'LSM30_Statusbar',
		order = index,
		name = "StatusBar Texture",
		desc = "Main statusbar texture.",
		values = CO.AceGUIWidgetLSMlists["statusbar"],
		get = function(info) return CO.db.profile.unitframe.units.all.barTexture end,
		set = function(info, value) CO.db.profile.unitframe.units.all.barTexture = value; E:UpdateAllBarTextures() end,
	}

	return barTexture
end

local function GetOptionsTable_Portrait(groupName)

	local config = {
		order = -1,
		type = 'group',
		name = L["Portrait"],
		get = function(info) return CO.db.profile.unitframe.units[groupName].portrait[ info[#info] ] end,
		set = function(info, value) CO.db.profile.unitframe.units[groupName].portrait[ info[#info] ] = value; UF.Modules["Portrait"]:LoadProfile(); UF.Modules["BarHealth"]:LoadProfile(); end,
		args = {
			header = {
				order = 1,
				type = "header",
				name = L["Portrait"],
			},
			enable = {
				type = "toggle",
				order = 2,
				name = L["Enable"],
				width = "full",
			},
			alpha = {
				order = 3,
				type = 'range',
				name = "Alpha",
				min = 0, max = 1, step = 0.01,
				disabled = function() return not CO.db.profile.unitframe.units[groupName].portrait.enable end,
			},
			cutOff = {
				type = "toggle",
				order = 4,
				name = "Cutoff",
				desc = "Wether the portrait should be cutoff at the healthbar.\n\nNOTE: To make this fully work, the Healthbar Background should not be Transparent!",
				disabled = function() return not CO.db.profile.unitframe.units[groupName].portrait.enable end,
			},
			newLine = {type="description", name="", order=5},
			zoom = {
				order = 10,
				type = 'range',
				name = "Portrait Zoom",
				desc = "Controls the focus multiplier by how focused the camera is on the units head",
				min = 0, max = 1, step = 0.01,
				disabled = function() return not CO.db.profile.unitframe.units[groupName].portrait.enable end,
			},
			rotation = {
				order = 11,
				type = 'range',
				name = "Model Rotation",
				desc = "Controls the units rotation",
				min = 0, max = 10, step = 0.01,
				disabled = function() return not CO.db.profile.unitframe.units[groupName].portrait.enable end,
			},
			camDistanceScale = {
				order = 12,
				type = 'range',
				name = "Camera Distance",
				desc = "Controls the distance between camera and unit",
				min = 0.01, max = 10, step = 0.01,
				disabled = function() return not CO.db.profile.unitframe.units[groupName].portrait.enable end,
			},
		},
	}

	return config
end

local function GetOptionsTable_Auras(type, groupName, index)
	
	local dbType = string.lower(type)
	
	local config = {
		order = index,
		type = 'group',
		name = L[type],
		childGroups = "tab",
		args = {
			iconGroup = {
				type = 'group',
				name = L["Icon"],
				order = 1,
				get = function(info) return CO.db.profile.unitframe.units[groupName][dbType][ info[#info] ] end,
				set = function(info, value) CO.db.profile.unitframe.units[groupName][dbType][ info[#info] ]  = value; UF.Modules["Auras"]:LoadProfile(groupName); end,
				args = {
					enable = {
						type = "toggle",
						order = 1,
						name = L["Enable"],
					},
					position = {
						type = 'select',
						order = 2,
						name = L["Position"],
						desc = "Attachment point of the aura frame",
						values = E.Positions,
						disabled = function() return not CO.db.profile.unitframe.units[groupName][dbType].enable end,
					},
					attachTo = {
						type = 'select',
						order = 3,
						name = "Attach To",
						values = CD.AuraAttachPoints,
						disabled = function() return not CO.db.profile.unitframe.units[groupName][dbType].enable end,
					},
					newline1 = {type = "description", name = "", order = 5},
					sortBy = {
						order = 6,
						name = "Sort By",
						type = "select",
						values = CD.AuraSortMethods,
					},
					sortDirection = {
						order = 7,
						name = "Sort Direction",
						type = "select",
						values = CD.AuraSortDirections,
					},
					newline2 = {type = "description", name = "", order = 10},
					offsetX = {
						order = 12,
						type = 'range',
						name = L["XOffset"],
						min = -500, max = 500, step = 1,
						disabled = function() return not CO.db.profile.unitframe.units[groupName][dbType].enable end,
					},
					offsetY = {
						order = 13,
						type = 'range',
						name = L["YOffset"],
						min = -500, max = 500, step = 1,
						disabled = function() return not CO.db.profile.unitframe.units[groupName][dbType].enable end,
					},
					newline3 = {type = "description", name = "", order = 20},
					gapX = {
						order = 21,
						type = 'range',
						name = "Gap X",
						min = -20, max = 20, step = 1,
						disabled = function() return not CO.db.profile.unitframe.units[groupName][dbType].enable end,
					},
					gapY = {
						order = 21,
						type = 'range',
						name = "Gap Y",
						min = -20, max = 20, step = 1,
						disabled = function() return not CO.db.profile.unitframe.units[groupName][dbType].enable end,
					},
					newline4 = {type = "description", name = "", order = 25},
					size = {
						order = 26,
						type = 'range',
						width = "full",
						name = "Slot Size",
						min = 4, max = 80, step = 1,
						disabled = function() return not CO.db.profile.unitframe.units[groupName][dbType].enable end,
					},
					newline5 = {type = "description", name = "", order = 30},
					numPerRow = {
						order = 31,
						type = 'range',
						width = "double",
						name = "Per Row",
						min = 1, max = 20, step = 1,
						disabled = function() return not CO.db.profile.unitframe.units[groupName][dbType].enable end,
					},
					maxWraps = {
						order = 32,
						type = 'range',
						name = "Max Wraps",
						min = 1, max = 20, step = 1,
						disabled = function() return not CO.db.profile.unitframe.units[groupName][dbType].enable end,
					},
				},
			},
		},
	}
	
	local Fonts = {{Path = format("db.profile.unitframe.units.%s.%s.time", groupName, dbType), Order = 100, GroupName = L["Time"]}, {Path = format("db.profile.unitframe.units.%s.%s.count", groupName, dbType), Order = 200, GroupName = L["Count"]}}
	for k,v in pairs(CD:GetFontOptions(Fonts)) do
		config.args[k] = v
	end
	
	return config
end

local function GetOptionsTable_AuraBars(groupName)
	
	local config = {
		order = -1,
		type = 'group',
		name = L["Aura Bars"],
		get = function(info) return CO.db.profile.auras.units[groupName].aurabars[ info[#info] ] end,
		set = function(info, value) CO.db.profile.auras.units[groupName].aurabars[ info[#info] ]  = value; E:GetModule("Bar_Auras"):LoadProfile() end,
		childGroups = "tab",
		args = {
			barGroup = {
				type = 'group',
				name = L["Bars"],
				order = 1,
				args = {
					enable = {
						type = "toggle",
						order = 11,
						name = L["Enable"],
					},
					toggle = {
						order = 12,
						type = "execute",
						name = L["Toggle"],
						func = function()
							local BA = E:GetModule("Bar_Auras")
							BA:ToggleBars(groupName)
						end,
						disabled = function() return not CO.db.profile.auras.units[groupName].aurabars.enable end,
					},
					positionHeader = {
						order = 20,
						type = "header",
						name = L["Positioning"],
					},
					BarHeader = {
						order = 30,
						type = "header",
						name = "Bar Settings",
					},
					barNum = {
						order = 31,
						type = 'range',
						name = L["Number of Bars"],
						min = 1, max = 30, step = 1,
						disabled = function() return not CO.db.profile.auras.units[groupName].aurabars.enable end,
					},
					width = {
						order = 32,
						type = 'range',
						name = L["Width"],
						min = 1, max = 750, step = 1,
						disabled = function() return not CO.db.profile.auras.units[groupName].aurabars.enable end,
					},
					height = {
						order = 33,
						type = 'range',
						name = L["Height"],
						min = 1, max = 125, step = 1,
						disabled = function() return not CO.db.profile.auras.units[groupName].aurabars.enable end,
					},
					gapY = {
						order = 34,
						type = 'range',
						name = "Gap Y",
						min = 0, max = 100, step = 1,
						disabled = function() return not CO.db.profile.auras.units[groupName].aurabars.enable end,
					},
				},
			},
			styleGroup = {
				type = 'group',
				name = L["Style"],
				order = 2,
				args = {
					iconSize = {
						order = 1,
						type = 'range',
						name = "Icon Size",
						min = 1, max = 128, step = 1,
						disabled = function() return not CO.db.profile.auras.units[groupName].aurabars.enable end,
					},
					newLine = {type="description", name="", order= 5},
					autoColorBarBorder = {
						order = 6,
						type = "toggle",
						name = "Auto Bar Border Color",
						disabled = function() return not CO.db.profile.auras.units[groupName].aurabars.enable end,
					},
					barBorderColor = {
						name = "Bar Border Color",
						type = "color",
						hasAlpha = true,
						order = 7,
						get = function(info)
							local c = CO.db.profile.auras.units[groupName].aurabars.barBorderColor
							return c.r, c.g, c.b, c.a
						end,
						set = function(info, r, g, b, a)
							local c = CO.db.profile.auras.units[groupName].aurabars.barBorderColor
							c.r, c.g, c.b, c.a = r, g, b, a
							
							E:GetModule("Bar_Auras"):LoadProfile()
						end,
						disabled = function() return not CO.db.profile.auras.units[groupName].aurabars.enable or CO.db.profile.auras.units[groupName].aurabars.autoColorBarBorder end,
					},
					newLine2 = {type="description", name="", order= 10},
					autoColorIconBorder = {
						order = 11,
						type = "toggle",
						name = "Auto Icon Border Color",
						disabled = function() return not CO.db.profile.auras.units[groupName].aurabars.enable end,
					},
					iconBorderColor = {
						name = "Icon Border Color",
						type = "color",
						hasAlpha = true,
						order = 12,
						get = function(info)
							local c = CO.db.profile.auras.units[groupName].aurabars.iconBorderColor
							return c.r, c.g, c.b, c.a
						end,
						set = function(info, r, g, b, a)
							local c = CO.db.profile.auras.units[groupName].aurabars.iconBorderColor
							c.r, c.g, c.b, c.a = r, g, b, a
							
							E:GetModule("Bar_Auras"):LoadProfile()
						end,
						disabled = function() return not CO.db.profile.auras.units[groupName].aurabars.enable or CO.db.profile.auras.units[groupName].aurabars.autoColorIconBorder end,
					},
					newLine3 = {type="description", name="", order= 15},
					backgroundColor = {
						name = L["BackgroundColor"],
						type = "color",
						hasAlpha = true,
						order = 16,
						get = function(info)
							local c = CO.db.profile.auras.units[groupName].aurabars.backgroundColor
							return c[1], c[2], c[3], c[4]
						end,
						set = function(info, r, g, b, a)
							local c = CO.db.profile.auras.units[groupName].aurabars.backgroundColor
							c[1], c[2], c[3], c[4] = r, g, b, a
							
							E:GetModule("Bar_Auras"):LoadProfile()
						end,
						disabled = function() return not CO.db.profile.auras.units[groupName].aurabars.enable end,
					},
					newLine4 = {type="description", name="", order= 20},
					invertGrowth = {
						type = "toggle",
						order = 17,
						name = "Invert Growth",
						width = "full",
					},
				},
			},
		},
	}
	
	local Fonts = {{Path = "db.profile.auras.units." .. groupName .. ".aurabars.name", Order = 100, GroupName = L["Name"]}, {Path = "db.profile.auras.units." .. groupName .. ".aurabars.time", Order = 200, GroupName = L["Time"]}}
	for k,v in pairs(CD:GetFontOptions(Fonts)) do
		config.args[k] = v
	end
	
	for k,v in pairs(CD:GetMoverOptions("AuraBarContainer" .. groupName .. "Mover", 21, true)) do
		config.args.barGroup.args[k] = v
	end
	
	
	
	return config
end

local function GetOptionsTable_CombatIndicator()
	--[[
		["glowSize"] = 7,
		["glowColor"] = {0.9, 0, 0, 1},
		["glowFadeIn"] = 2,
		["glowFadeOut"] = 5,
		["iconPosition"] = "CENTER",
		["iconOffsetX"] = 0,
		["iconOffsetY"] = 15,
		["iconSize"] = 25,
		["iconFadeIn"] = 1,
		["iconFadeOut"] = 2,
	]]
	local config = {
		order = 110,
		type = 'group',
		name = L["Combat Indicator"],
		get = function(info) return CO.db.profile.unitframe.units.player.combatIndicator[ info[#info] ] end,
		set = function(info, value) CO.db.profile.unitframe.units.player.combatIndicator[ info[#info] ]  = value; UF:LoadProfileForUnits("player"); end,
		args = {
			toggle = {
				type = "execute",
				order = 1,
				name = L["Toggle"],
				func = function() ToggleCombatIndicator() end,
			},
			enableGlow = {
				type = "toggle",
				order = 2,
				name = "Glow",
			},
			enableIcon = {
				type = "toggle",
				order = 3,
				name = L["Icon"],
			},
			newLine1 = {type="description", name="", order = 10},
			iconHeader = {
				type = "header",
				order = 11,
				name = L["Icon"],
			},
			iconPosition = {
				type = 'select',
				order = 12,
				name = "Icon Position",
				desc = "Attachment point to the unitframe",
				values = E.Positions,
				disabled = function() return not CO.db.profile.unitframe.units.player.combatIndicator.enableIcon end,
			},
			iconOffsetX = {
				order = 13,
				type = 'range',
				name = L["XOffset"],
				min = -100, max = 100, step = 1,
				disabled = function() return not CO.db.profile.unitframe.units.player.combatIndicator.enableIcon end,
			},
			iconOffsetY = {
				order = 14,
				type = 'range',
				name = L["YOffset"],
				min = -100, max = 100, step = 1,
				disabled = function() return not CO.db.profile.unitframe.units.player.combatIndicator.enableIcon end,
			},
			iconSize = {
				order = 14,
				type = 'range',
				name = L["Size"],
				min = 0, max = 90, step = 1,
				disabled = function() return not CO.db.profile.unitframe.units.player.combatIndicator.enableIcon end,
			},
			newLine2 = {type="description", name="", order = 20},
			glowHeader = {
				type = "header",
				order = 21,
				name = "Glow",
			},
			glowSize = {
				order = 22,
				type = 'range',
				name = "Glow Size",
				min = 0, max = 90, step = 1,
				disabled = function() return not CO.db.profile.unitframe.units.player.combatIndicator.enableGlow end,
			},
			glowColor = {
				name = "Glow Color",
				type = "color",
				hasAlpha = true,
				order = 23,
				get = function(info)
					local c = CO.db.profile.unitframe.units.player.combatIndicator.glowColor
					return c[1], c[2], c[3], c[4]
					end,
				set = function(info, r, g, b, a)
					local c = CO.db.profile.unitframe.units.player.combatIndicator.glowColor
					c[1], c[2], c[3], c[4] = r, g, b, a

					UF:LoadProfileForUnits("player")
					end,
				disabled = function() return not CO.db.profile.unitframe.units.player.combatIndicator.enableGlow end,
			},
			animHeader = {
				type = "header",
				order = 30,
				name = "Animation",
			},
			glowFadeIn = {
				order = 31,
				type = 'range',
				name = "Glow Fade In",
				desc = "Time (in seconds) it takes the glow to fade in",
				min = 0, max = 15, step = 0.01,
				disabled = function() return not CO.db.profile.unitframe.units.player.combatIndicator.enableGlow end,
			},
			glowFadeOut = {
				order = 32,
				type = 'range',
				name = "Glow Fade Out",
				desc = "Time (in seconds) it takes the glow to fade out",
				min = 0, max = 15, step = 0.01,
				disabled = function() return not CO.db.profile.unitframe.units.player.combatIndicator.enableGlow end,
			},
			newLine3 = {type="description", name="", order = 40},
			iconFadeIn = {
				order = 41,
				type = 'range',
				name = "Icon Fade In",
				desc = "Time (in seconds) it takes the icon to fade in",
				min = 0, max = 15, step = 0.01,
				disabled = function() return not CO.db.profile.unitframe.units.player.combatIndicator.enableIcon end,
			},
			iconFadeOut = {
				order = 42,
				type = 'range',
				name = "Icon Fade Out",
				desc = "Time (in seconds) it takes the icon to fade out",
				min = 0, max = 15, step = 0.01,
				disabled = function() return not CO.db.profile.unitframe.units.player.combatIndicator.enableIcon end,
			},
		},
	}
	
	return config
end

local function GetOptionsTable_ReadyCheck(groupName)
	local config = {
		order = -4,
		type = 'group',
		name = L["Ready Check"],
		get = function(info) return CO.db.profile.unitframe.units[groupName].readyCheckIndicator[ info[#info] ] end,
		set = function(info, value) CO.db.profile.unitframe.units[groupName].readyCheckIndicator[ info[#info] ]  = value; UF.Modules["ReadyCheckIndicator"]:LoadProfile(); end,
		args = {
			enable = {
				type = "toggle",
				order = 2,
				name = L["Enable"],
			},
			toggle = {
				type = "execute",
				order = 3,
				name = L["Toggle"],
				func = function() UF:PerformForUnits(groupName, ToggleReadyCheck) end,
			},
			colorOptions = {
				type = "execute",
				order = 4,
				name = L["Colors"],
				func = function() CD.ACD:SelectGroup("CUI", "colors", "readycheckGroup") end,
			},
			newLine1 = {type="description", name="", order = 10},
			position = {
				type = 'select',
				order = 11,
				name = L["Position"],
				desc = "Attachment point to the unitframe",
				values = E.Positions,
			},
			offsetX = {
				order = 12,
				type = 'range',
				name = L["XOffset"],
				min = -50, max = 50, step = 1,
			},
			offsetY = {
				order = 13,
				type = 'range',
				name = L["YOffset"],
				min = -50, max = 50, step = 1,
			},
			newLine2 = {type="description", name="", order = 20},
			size = {
				order = 21,
				type = 'range',
				name = "Size",
				min = 3, max = 90, step = 1,
			},
		},
	}
	
	return config
end

local function GetOptionsTable_SummonIndicator(groupName)
	local config = {
		order = -5,
		type = 'group',
		name = L["Summon Icon"],
		get = function(info) return CO.db.profile.unitframe.units[groupName].summonIndicator[ info[#info] ] end,
		set = function(info, value) CO.db.profile.unitframe.units[groupName].summonIndicator[ info[#info] ]  = value; UF.Modules["SummonIndicator"]:LoadProfile(); end,
		args = {
			enable = {
				type = "toggle",
				order = 2,
				name = L["Enable"],
			},
			toggle = {
				type = "execute",
				order = 3,
				name = L["Toggle"],
				func = function() UF:PerformForUnits(groupName, ToggleSummonIndicator) end,
			},
			newLine1 = {type="description", name="", order = 10},
			position = {
				type = 'select',
				order = 11,
				name = "Position",
				desc = "Attachment point to the unitframe",
				values = E.Positions,
			},
			offsetX = {
				order = 12,
				type = 'range',
				name = L["XOffset"],
				min = -50, max = 50, step = 1,
			},
			offsetY = {
				order = 13,
				type = 'range',
				name = L["YOffset"],
				min = -50, max = 50, step = 1,
			},
			newLine2 = {type="description", name="", order = 20},
			size = {
				order = 21,
				type = 'range',
				name = "Size",
				min = 3, max = 90, step = 1,
			},
		},
	}
	
	return config
end

local function GetOptionsTable_ResIndicator(groupName)
	local config = {
		order = -6,
		type = 'group',
		name = L["Res Indicator"],
		get = function(info) return CO.db.profile.unitframe.units[groupName].resIndicator[ info[#info] ] end,
		set = function(info, value) CO.db.profile.unitframe.units[groupName].resIndicator[ info[#info] ]  = value; UF.Modules["ResurrectIndicator"]:LoadProfile(); end,
		args = {
			enable = {
				type = "toggle",
				order = 2,
				name = L["Enable"],
			},
			toggle = {
				type = "execute",
				order = 3,
				name = L["Toggle"],
				func = function() UF:PerformForUnits(groupName, ToggleResIndicator) end,
			},
			newLine1 = {type="description", name="", order = 10},
			position = {
				type = 'select',
				order = 11,
				name = "Position",
				desc = "Attachment point to the unitframe",
				values = E.Positions,
			},
			offsetX = {
				order = 12,
				type = 'range',
				name = L["XOffset"],
				min = -50, max = 50, step = 1,
			},
			offsetY = {
				order = 13,
				type = 'range',
				name = L["YOffset"],
				min = -50, max = 50, step = 1,
			},
			newLine2 = {type="description", name="", order = 20},
			size = {
				order = 21,
				type = 'range',
				name = "Size",
				min = 3, max = 90, step = 1,
			},
		},
	}
	
	return config
end

local function GetOptionsTable_RoleIcon(groupName)
	
	local config = {
		order = -3,
		type = 'group',
		name = L["Role Icon"],
		get = function(info) return CO.db.profile.unitframe.units[groupName].roleIcon[ info[#info] ] end,
		set = function(info, value) CO.db.profile.unitframe.units[groupName].roleIcon[ info[#info] ]  = value; UF.Modules["RoleIndicator"]:LoadProfile(); end,
		args = {
			enable = {
				type = "toggle",
				order = 2,
				name = L["Enable"],
			},
			toggle = {
				type = "execute",
				order = 3,
				name = L["Toggle"],
				func = function() UF:PerformForUnits(groupName, ToggleRoleIcon) end,
			},
			newLine1 = {type="description", name="", order = 10},
			position = {
				type = 'select',
				order = 11,
				name = "Position",
				desc = "Attachment point to the unitframe",
				values = E.Positions,
			},
			offsetX = {
				order = 12,
				type = 'range',
				name = L["XOffset"],
				min = -50, max = 50, step = 1,
			},
			offsetY = {
				order = 13,
				type = 'range',
				name = L["YOffset"],
				min = -50, max = 50, step = 1,
			},
			newLine2 = {type="description", name="", order = 20},
			size = {
				order = 21,
				type = 'range',
				name = "Size",
				min = 3, max = 90, step = 1,
			},
		},
	}
	
	return config
end

local function GetOptionsTable_Leader(groupName)
	
	local config = {
		order = -2,
		type = 'group',
		name = L["Leader Icon"],
		get = function(info) return CO.db.profile.unitframe.units[groupName].leaderIcon[ info[#info] ] end,
		set = function(info, value) CO.db.profile.unitframe.units[groupName].leaderIcon[ info[#info] ]  = value; UF.Modules["LeaderIcon"]:LoadProfile() end,
		args = {
			enable = {
				type = "toggle",
				order = 2,
				name = L["Enable"],
			},
			toggle = {
				type = "execute",
				order = 3,
				name = L["Toggle"],
				func = function() UF:PerformForUnits(groupName, ToggleLeaderIcon) end,
			},
			newLine1 = {type="description", name="", order = 10},
			position = {
				type = 'select',
				order = 11,
				name = "Position",
				desc = "Attachment point to the unitframe",
				values = E.Positions,
			},
			offsetX = {
				order = 12,
				type = 'range',
				name = L["XOffset"],
				min = -50, max = 50, step = 1,
			},
			offsetY = {
				order = 13,
				type = 'range',
				name = L["YOffset"],
				min = -50, max = 50, step = 1,
			},
			newLine2 = {type="description", name="", order = 20},
			size = {
				order = 21,
				type = 'range',
				name = "Size",
				min = 3, max = 90, step = 1,
			},
		},
	}
	
	return config
end

local function GetOptionsTable_TargetIcon(groupName)
	
	local config = {
		order = -1,
		type = 'group',
		name = L["Target Icon"],
		get = function(info) return CO.db.profile.unitframe.units[groupName].targetIcon[ info[#info] ] end,
		set = function(info, value) CO.db.profile.unitframe.units[groupName].targetIcon[ info[#info] ]  = value; UF.Modules["TargetIcon"]:LoadProfile(); end,
		args = {
			enable = {
				type = "toggle",
				order = 2,
				name = L["Enable"],
			},
			toggle = {
				type = "execute",
				order = 3,
				name = L["Toggle"],
				func = function() UF:PerformForUnits(groupName, ToggleTargetIcon) end,
			},
			newLine1 = {type="description", name="", order = 10},
			position = {
				type = 'select',
				order = 11,
				name = "Position",
				desc = "Attachment point to the unitframe",
				values = E.Positions,
			},
			offsetX = {
				order = 12,
				type = 'range',
				name = L["XOffset"],
				min = -50, max = 50, step = 1,
			},
			offsetY = {
				order = 13,
				type = 'range',
				name = L["YOffset"],
				min = -50, max = 50, step = 1,
			},
			newLine2 = {type="description", name="", order = 20},
			size = {
				order = 21,
				type = 'range',
				name = "Size",
				min = 3, max = 90, step = 1,
			},
		},
	}
	
	return config
end

local function GetOptionsTable_Absorption(groupName)
	
	local config = {
		order = -10,
		type = 'group',
		name = L["Absorption"],
		get = function(info) return CO.db.profile.unitframe.units[groupName].health[ info[#info] ] end,
		set = function(info, value) CO.db.profile.unitframe.units[groupName].health[ info[#info] ]  = value; UF:LoadProfileForUnits(groupName); end,
		args = {
			enableAbsorb = {
				type = "toggle",
				order = 2,
				name = L["Enable"],
			},
			newLine1 = {type="description", name="", order = 10},
			absorbUseStripes = {
				type = "toggle",
				order = 11,
				name = "Use Stripes",
			},
			absorbTextureSizeMultiplier = {
				type = 'range',
				order = 12,
				name = "Texture Size Multiplier",
				desc = "Controls the final texture tiling",
				min = 0, max = 25,
				disabled = function() return not CO.db.profile.unitframe.units[groupName].health.absorbUseStripes end,
			},
			newLine2 = {type="description", name="", order = 20},
			absorbBorderColor = {
				name = L["BorderColor"],
				type = "color",
				hasAlpha = true,
				order = 21,
				get = function(info)
						--print(index)
						local c = CO.db.profile.unitframe.units[groupName].health.absorbBorderColor
						return c[1], c[2], c[3], c[4]
				end,
				set = function(info, r, g, b, a)
					local c = CO.db.profile.unitframe.units[groupName].health.absorbBorderColor
					
					c[1], c[2], c[3], c[4] = r, g, b, a
					
					UF:LoadProfileForUnits(groupName)
				end,
			},
			absorbTextureColor = {
				name = "Texture Color",
				type = "color",
				hasAlpha = true,
				order = 22,
				get = function(info)
						--print(index)
						local c = CO.db.profile.unitframe.units[groupName].health.absorbTextureColor
						return c[1], c[2], c[3], c[4]
				end,
				set = function(info, r, g, b, a)
					local c = CO.db.profile.unitframe.units[groupName].health.absorbTextureColor
					
					c[1], c[2], c[3], c[4] = r, g, b, a
					
					UF:LoadProfileForUnits(groupName)
				end,
			},
		},
	}
	
	return config
end

local function GetOptionsTable_AlternatePower(groupName)
	
	local config = {
		order = 200,
		type = 'group',
		name = L["Alternate Power"],
		childGroups = "tab",
		args = {
			Bars = {
				order = 1,
				type = 'group',
				name = "Bars",
				get = function(info) return CO.db.profile.unitframe.units[groupName].alternatePower[ info[#info] ] end,
				set = function(info, value) CO.db.profile.unitframe.units[groupName].alternatePower[ info[#info] ] = value; E:GetModule("Alternate_Power"):LoadProfile() end,
				args = {
					-- Position will be filled in by for loop below
					header = {
						order = 10,
						type = "header",
						name = "Size",
					},
					width = {
						order = 11,
						type = 'range',
						name = L["Width"],
						desc = "Width",
						min = 1, max = 800, step = 1,
					},
					height = {
						order = 12,
						type = 'range',
						name = L["Height"],
						desc = "Height",
						min = 1, max = 800, step = 1,
					},
					headerStyle = {
						order = 20,
						type = "header",
						name = "Style",
					},
					gap = {
						order = 21,
						type = 'range',
						name = "Gap",
						desc = "Gap",
						min = 0, max = 50, step = 0.1,
					},
					reverseFill = {
						order = 23,
						type = "toggle",
						name = "Bar Inverse Fill",
						desc = "Inverts the Fill Direction",
					},
					fillOrientation = {
						type = 'select',
						order = 24,
						name = "Fill Direction",
						desc = "How the individual bars should be filled. Vertical or Horizontal.",
						values = CD.SortBarOrientation,
					},
					barTexture = {
						type = "select", dialogControl = 'LSM30_Statusbar',
						order = 25,
						name = "StatusBar Texture",
						desc = "Main statusbar texture.",
						values = CO.AceGUIWidgetLSMlists["statusbar"],
					},
					headerBackground = {
						order = 30,
						type = "header",
						name = L["Background"],
					},
					backgroundColor = {
						name = L["BackgroundColor"],
						type = "color",
						hasAlpha = true,
						order = 31,
						get = function(info)
								--print(index)
								local c = CO.db.profile.unitframe.units[groupName].alternatePower.backgroundColor
								return c[1], c[2], c[3], c[4]
						end,
						set = function(info, r, g, b, a)
							local c = CO.db.profile.unitframe.units[groupName].alternatePower.backgroundColor
							
							c[1], c[2], c[3], c[4] = r, g, b, a
							
							UF:LoadProfileForUnits(groupName)
						end,
					},
					headerBorder = {
						order = 40,
						type = "header",
						name = "Border",
					},
					borderColor = {
						name = L["BorderColor"],
						type = "color",
						hasAlpha = true,
						order = 41,
						get = function(info)
								--print(index)
								local c = CO.db.profile.unitframe.units[groupName].alternatePower.borderColor
								return c[1], c[2], c[3], c[4]
						end,
						set = function(info, r, g, b, a)
							local c = CO.db.profile.unitframe.units[groupName].alternatePower.borderColor
							
							c[1], c[2], c[3], c[4] = r, g, b, a
							
							UF:LoadProfileForUnits(groupName)
						end,
					},
					borderSize = {
						order = 42,
						type = 'range',
						name = L["BorderSize"],
						desc = L["BorderSize"],
						min = -20, max = 20, step = 0.1,
					},
				},
			},
			Background = {
				order = 2,
				type = 'group',
				name = L["Background"],
				get = function(info) return CO.db.profile.unitframe.units[groupName].alternatePower.artFill[ info[#info] ] end,
				set = function(info, value) CO.db.profile.unitframe.units[groupName].alternatePower.artFill[ info[#info] ] = value; E:GetModule("Alternate_Power"):LoadProfile() end,
				args = {
					enable = {
						type = "toggle",
						order = 1,
						name = L["Enable"],
						width = "full",
					},
					valuesHeader = {
						type = "header",
						name = "Values",
						order = 10,
					},
					paddingX = {
						order = 11,
						type = 'range',
						name = "Horizontal Padding",
						desc = "Controls the amount of horizontal 'overflow' for the fill frame",
						min = 0, max = 50, step = 0.1,
						disabled = function() return not CO.db.profile.unitframe.units[groupName].alternatePower.artFill.enable end,
					},
					paddingY = {
						order = 12,
						type = 'range',
						name = "Vertical Padding",
						desc = "Controls the amount of vertical 'overflow' for the fill frame",
						min = 0, max = 50, step = 1,
						disabled = function() return not CO.db.profile.unitframe.units[groupName].alternatePower.artFill.enable end,
					},
					borderSize = {
						order = 13,
						type = 'range',
						name = L["BorderSize"],
						min = -5, max = 5, step = 0.1,
						disabled = function() return not CO.db.profile.unitframe.units[groupName].alternatePower.artFill.enable end,
					},
					colorHeader = {
						type = "header",
						name = "Colors",
						order = 20,
					},
					borderColor = {
						name = L["BorderColor"],
						type = "color",
						hasAlpha = true,
						order = 21,
						get = function(info)
							local c = CO.db.profile.unitframe.units[groupName].alternatePower.artFill.borderColor
							return c[1], c[2], c[3], c[4]
						end,
						set = function(info, r, g, b, a)
							local c = CO.db.profile.unitframe.units[groupName].alternatePower.artFill.borderColor
							c[1], c[2], c[3], c[4] = r, g, b, a
							E:GetModule("Alternate_Power"):LoadProfile();
						end,
						disabled = function() return not CO.db.profile.unitframe.units[groupName].alternatePower.artFill.enable end,
					},
					backgroundColor = {
						name = L["BackgroundColor"],
						type = "color",
						hasAlpha = true,
						order = 22,
						get = function(info)
							local c = CO.db.profile.unitframe.units[groupName].alternatePower.artFill.backgroundColor
							return c[1], c[2], c[3], c[4]
						end,
						set = function(info, r, g, b, a)
							local c = CO.db.profile.unitframe.units[groupName].alternatePower.artFill.backgroundColor
							c[1], c[2], c[3], c[4] = r, g, b, a
							E:GetModule("Alternate_Power"):LoadProfile();
						end,
						disabled = function() return not CO.db.profile.unitframe.units[groupName].alternatePower.artFill.enable end,
					},
				},
			},
			Data = {
				order = 3,
				type = 'group',
				name = "Data",
				get = function(info) return CO.db.profile.unitframe.units[groupName].alternatePower.data[ info[#info] ] end,
				set = function(info, value) CO.db.profile.unitframe.units[groupName].alternatePower.data[ info[#info] ] = value; E:GetModule("Alternate_Power"):LoadProfile() end,
				args = {
					monkStaggerMax = {
						order = 5,
						type = 'range',
						name = "Monk Stagger Max",
						desc = "Controls the maximum value of the stagger bar for Brewmaster Monks.\nThe value is a percentage of the Monks Maximum HP.\nDefault: 60%",
						min = 1, max = 100, step = 1,
					},
				},
			},
		},
	}
	
	for k,v in pairs(CD:GetMoverOptions("CUI_AlternatePowerMover", 2, true)) do
		config.args.Bars.args[k] = v
	end

	return config
end

CD.Options.args.unitframe = {
	name = L["Unitframes"],
	type = 'group',
	order = 99999,
	disabled = false,
	args = {
		
	},
}

CD.Options.args.unitframe.args.all = {
	name = L["All"],
	type = 'group',
	order = 1,
	childGroups = "tab",
	disabled = false,
	args = {
		generalGroup = {
			type = "group",
			order = 1,
			name = L["General"],
			args = {
				header = {
					order = 1,
					type = "header",
					name = "Dummy Mode",
				},
				partyDummy = {
					order = 2,
					type = "execute",
					name = "Enable",
					width = "full",
					func = function()
						CD.DummyMode = not CD.DummyMode
						CD.Options.args.unitframe.args.all.args.generalGroup.args.partyDummy.name = CD.DummyMode and "Disable" or "Enable"
						
						SetUnitDummys(CD.DummyMode)
					end,
				},
				dummyShowIndex = {
					order = 3,
					type = "toggle",
					name = "Show Unitframe Index",
					get = function()
						return CO.db.profile.unitframe.dummyShowIndex
					end,
					set = function(info, value)
						CO.db.profile.unitframe.dummyShowIndex = value
						
						ToggleIndex(value)
					end,
				},
				dummyShowAuras = {
					order = 4,
					type = "toggle",
					name = "Show Dummy Auras",
					hidden = true,
					get = function()
						return CO.db.profile.unitframe.dummyShowAuras
					end,
					set = function(info, value)
						CO.db.profile.unitframe.dummyShowAuras = value
						
						ToggleAuras(value)
					end,
				},
				newline = {type='description', name='', order=5},
				barTexture = GetOptionsTable_BarTexture(10),
				newline2 = {type='description', name='', order=15},
				classColor = {
					type = "execute",
					order = 16,
					name = "Class Colors",
					func = function() CD.ACD:SelectGroup("CUI", "colors", "classGroup") end,
				},
				reactionColor = {
					type = "execute",
					order = 17,
					name = "Reaction Colors",
					func = function() CD.ACD:SelectGroup("CUI", "colors", "reactionGroup") end,
				},
				readyCheckColor = {
					type = "execute",
					order = 18,
					name = "Readycheck Colors",
					func = function() CD.ACD:SelectGroup("CUI", "colors", "readycheckGroup") end,
				},
				castbarColor = {
					type = "execute",
					order = 19,
					name = "Castbar Colors",
					func = function() CD.ACD:SelectGroup("CUI", "colors", "castbarGroup") end,
				},
				powerColor = {
					type = "execute",
					order = 20,
					name = "Power Colors",
					func = function() CD.ACD:SelectGroup("CUI", "colors", "powerGroup") end,
				},
			},
		},
		miscGroup = {
			type = "group",
			order = 2,
			name = L["Misc"],
			args = {
				rangeHeader = {
					order = 30,
					type = "header",
					name = "Range Indicator",
				},
				rangeAlpha = {
					order = 31,
					name = "Out Of Range Alpha",
					type = "range",
					min = 0, max = 1, step = 0.01,
					get = function() return CO.db.profile.unitframe.units.all.outOfRangeAlpha end,
					set = function(info, value) CO.db.profile.unitframe.units.all.outOfRangeAlpha = value end,
				},
				highlightHeader = {
					order = 50,
					type = "header",
					name = "Unit Highlight",
				},
				highlightEnable = {
					order = 51,
					type = "toggle",
					name = "Mouseover Highlight",
					desc = "When enabled, the mouseover unit will be highlighted on all unitframes",
					get = function(info) return CO.db.profile.unitframe.units.all.highlight.enable end,
					set = function(info, value) CO.db.profile.unitframe.units.all.highlight.enable = value; UF.Modules["Highlight"]:LoadProfile(); end,
				},
				highlightColor = {
					name = "Highlight Color",
					type = "color",
					hasAlpha = true,
					order = 52,
					get = function(info)
						local c = CO.db.profile.unitframe.units.all.highlight.color
						return c[1], c[2], c[3], c[4] or 1
					end,
					set = function(info, r, g, b, a)
						local c = CO.db.profile.unitframe.units.all.highlight.color
						c[1], c[2], c[3], c[4] = r, g, b, a or 1
						
						UF.Modules["Highlight"]:LoadProfile();
					end,
					disabled = function() return not CO.db.profile.unitframe.units.all.highlight.enable end,
				},
				highlightBlendMode = {
					type = 'select',
					order = 53,
					name = L["BlendMode"],
					values = E.BlendModes,
					get = function(info)
						return CO.db.profile.unitframe.units.all.highlight.blendMode
					end,
					set = function(info, value)
						CO.db.profile.unitframe.units.all.highlight.blendMode = value
						UF.Modules["Highlight"]:LoadProfile();
					end,
					disabled = function() return not CO.db.profile.unitframe.units.all.highlight.enable end,
				},
				fadeTime = {
					order = 54,
					name = "Fade Time",
					desc = "Time in seconds it takes the highlight to fade. Set to 0 to disable animation",
					type = "range",
					min = 0, max = 1, step = 0.01,
					get = function() return CO.db.profile.unitframe.units.all.highlight.fadeTime end,
					set = function(info, value) CO.db.profile.unitframe.units.all.highlight.fadeTime = value; UF.Modules["Highlight"]:LoadProfile(); end,
					disabled = function() return not CO.db.profile.unitframe.units.all.highlight.enable end,
				},
				targetHighlightHeader = {
					order = 60,
					type = "header",
					name = "Unit Target Highlight",
				},
				targetHighlightEnable = {
					order = 61,
					type = "toggle",
					name = "Target Highlight",
					desc = "When enabled, the targeted unit will be highlighted on all unitframes",
					get = function(info) return CO.db.profile.unitframe.units.all.targetHighlight.enable end,
					set = function(info, value) CO.db.profile.unitframe.units.all.targetHighlight.enable = value; UF.Modules["TargetHighlight"]:LoadProfile(); end,
				},
				targetHighlightColor = {
					name = "Highlight Color",
					type = "color",
					hasAlpha = true,
					order = 62,
					get = function(info)
						local c = CO.db.profile.unitframe.units.all.targetHighlight.color
						return c[1], c[2], c[3], c[4] or 1
					end,
					set = function(info, r, g, b, a)
						local c = CO.db.profile.unitframe.units.all.targetHighlight.color
						c[1], c[2], c[3], c[4] = r, g, b, a or 1
						
						UF.Modules["TargetHighlight"]:LoadProfile();
					end,
					disabled = function() return not CO.db.profile.unitframe.units.all.targetHighlight.enable end,
				},
				targetFadeTime = {
					order = 63,
					name = "Highlight Fade Time",
					desc = "Time in seconds it takes the target highlight to fade. Set to 0 to disable animation",
					type = "range",
					min = 0, max = 1, step = 0.01,
					get = function() return CO.db.profile.unitframe.units.all.targetHighlight.fadeTime end,
					set = function(info, value) CO.db.profile.unitframe.units.all.targetHighlight.fadeTime = value; UF.Modules["TargetHighlight"]:LoadProfile(); end,
					disabled = function() return not CO.db.profile.unitframe.units.all.targetHighlight.enable end,
				},
				targetBorderSize = {
					order = 64,
					name = "Border Size",
					desc = "Size of the border around a units healthbar",
					type = "range",
					min = -3, max = 3, step = 0.1,
					get = function() return CO.db.profile.unitframe.units.all.targetHighlight.borderSize end,
					set = function(info, value) CO.db.profile.unitframe.units.all.targetHighlight.borderSize = value; UF.Modules["TargetHighlight"]:LoadProfile(); end,
					disabled = function() return not CO.db.profile.unitframe.units.all.targetHighlight.enable end,
				},
			}
		},
		healthGroup = {
			type = "group",
			order = 3,
			name = L["Health"],
			args = {
				colorByValue = {
					order = 41,
					type = "toggle",
					name = L["Color By Value"],
					get = function(info) return CO.db.profile.unitframe.units.all.health[ info[#info] ] end,
					set = function(info, value) CO.db.profile.unitframe.units.all.health[ info[#info] ] = value; UF.Modules["BarHealth"]:LoadProfile(); UF:UpdateAllUF(); end,
				},
			}
		},
		auraGroup = {
			type = "group",
			order = 4,
			name = L["Auras"],
			args = {
				BorderDescription = {
					type = "description",
					order = 1,
					name = "Choose how the default border color should be defined",
				},
				newLine = {type = "description", order = 5, name = ""},
				borderUseClassColor = {
					type = "toggle",
					order = 6,
					name = L["UseUnitClassColor"],
					desc = L["UseUnitClassColorDesc"],
					get = function() return CO.db.profile.unitframe.aurasDefaultBorderColor.useClassColor end,
					set = function(info, value) CO.db.profile.unitframe.aurasDefaultBorderColor.useClassColor = value; UF.Modules["Auras"]:UpdateAll(); end,
				},
				borderColor = {
					name = L["BorderColor"],
					type = "color",
					hasAlpha = true,
					order = 7,
					get = function(info)
						local c = E:ParseDBColor(CO.db.profile.unitframe.aurasDefaultBorderColor)
						return c[1], c[2], c[3], c[4] or 1
					end,
					set = function(info, r, g, b, a)
						local c = E:ParseDBColor(CO.db.profile.unitframe.aurasDefaultBorderColor)
						c[1], c[2], c[3], c[4] = r, g, b, a or 1
						
						UF.Modules["Auras"]:UpdateAll();
					end,
					disabled = function() return CO.db.profile.unitframe.aurasDefaultBorderColor.useClassColor end,
				},
				masqueHeader = {
					name = "Masque",
					type = "header",
					order = 15,
				},
				useMasqueBuffs = {
					type = "toggle",
					order = 16,
					name = L["Buffs"],
					desc = L["UseMasqueDesc"],
					get = function() return CO.db.profile.unitframe.unitBuffs.useMasque end,
					set = function(info, value) CO.db.profile.unitframe.unitBuffs.useMasque = value; CD:ShowNotification("RELOAD_NOTIFICATION") end,
				},
				useMasqueDebuffs = {
					type = "toggle",
					order = 17,
					name = L["Debuffs"],
					desc = L["UseMasqueDesc"],
					get = function() return CO.db.profile.unitframe.unitDebuffs.useMasque end,
					set = function(info, value) CO.db.profile.unitframe.unitDebuffs.useMasque = value; CD:ShowNotification("RELOAD_NOTIFICATION") end,
				},
				useMasqueAurabars = {
					type = "toggle",
					order = 18,
					name = L["Aura Bars"],
					desc = L["UseMasqueDesc"],
					get = function() return CO.db.profile.auras.generalAurabars.useMasque end,
					set = function(info, value) CO.db.profile.auras.generalAurabars.useMasque = value; CD:ShowNotification("RELOAD_NOTIFICATION") end,
				},
				
			}
		},
	},
}

CD.Options.args.unitframe.args.player = {
	name = L["Player"],
	type = 'group',
	order = 2,
	childGroups = "tab",
	args = {
		generalGroup =  GetOptionsTable_General("player"),
		name = GetOptionsTable_Text("player", "name"),
		health = GetOptionsTable_Text("player", "health"),
		power = GetOptionsTable_Text("player", "power"),
		level = GetOptionsTable_Text("player", "level"),
		portrait = GetOptionsTable_Portrait("player"),
		combatIndicator = GetOptionsTable_CombatIndicator(),
		readycheckicon = GetOptionsTable_ReadyCheck("player"),
		summonIcon = GetOptionsTable_SummonIndicator("player"),
		resIndicator = GetOptionsTable_ResIndicator("player"),
		roleIcon = GetOptionsTable_RoleIcon("player"),
		targetIcon = GetOptionsTable_TargetIcon("player"),
		leaderIcon = GetOptionsTable_Leader("player"),
		buffs = GetOptionsTable_Auras("Buffs", "player", 200),
		debuffs = GetOptionsTable_Auras("Debuffs", "player", 201),
		aurabars = GetOptionsTable_AuraBars("player"),
		absorb = GetOptionsTable_Absorption("player"),
		barHealth = GetOptionsTable_HealthBar("player"),
		barPower = GetOptionsTable_PowerBar("player"),
		alternatePower = GetOptionsTable_AlternatePower("player"),
		castbar = GetOptionsTable_CastBar("player"),
	},
}

CD.Options.args.unitframe.args.pet = {
	name = L["Pet"],
	type = 'group',
	order = 1,
	childGroups = "tab",
	args = {
		generalGroup =  GetOptionsTable_General("pet"),
		name = GetOptionsTable_Text("pet", "name"),
		health = GetOptionsTable_Text("pet", "health"),
		power = GetOptionsTable_Text("pet", "power"),
		level = GetOptionsTable_Text("pet", "level"),
		portrait = GetOptionsTable_Portrait("pet"),
		targetIcon = GetOptionsTable_TargetIcon("pet"),
		buffs = GetOptionsTable_Auras("Buffs", "pet", 200),
		debuffs = GetOptionsTable_Auras("Debuffs", "pet", 201),
		absorb = GetOptionsTable_Absorption("pet"),
		barHealth = GetOptionsTable_HealthBar("pet"),
		barPower = GetOptionsTable_PowerBar("pet"),
		castbar = GetOptionsTable_CastBar("pet"),
	},
	
}

CD.Options.args.unitframe.args.target = {
	name = L["Target"],
	type = 'group',
	order = 3,
	childGroups = "tab",
	args = {
		generalGroup =  GetOptionsTable_General("target"),
		name = GetOptionsTable_Text("target", "name"),
		health = GetOptionsTable_Text("target", "health"),
		power = GetOptionsTable_Text("target", "power"),
		level = GetOptionsTable_Text("target", "level"),
		portrait = GetOptionsTable_Portrait("target"),
		roleIcon = GetOptionsTable_RoleIcon("target"),
		targetIcon = GetOptionsTable_TargetIcon("target"),
		resIndicator = GetOptionsTable_ResIndicator("target"),
		summonIcon = GetOptionsTable_SummonIndicator("target"),
		leaderIcon = GetOptionsTable_Leader("target"),
		buffs = GetOptionsTable_Auras("Buffs", "target", 200),
		debuffs = GetOptionsTable_Auras("Debuffs", "target", 201),
		aurabars = GetOptionsTable_AuraBars("target"),
		absorb = GetOptionsTable_Absorption("target"),
		barHealth = GetOptionsTable_HealthBar("target"),
		barPower = GetOptionsTable_PowerBar("target"),
		castbar = GetOptionsTable_CastBar("target"),
	},
	
}

CD.Options.args.unitframe.args.targettarget = {
	name = L["TargetTarget"],
	type = 'group',
	order = 4,
	childGroups = "tab",
	args = {
		generalGroup =  GetOptionsTable_General("targettarget"),
		name = GetOptionsTable_Text("targettarget", "name"),
		health = GetOptionsTable_Text("targettarget", "health"),
		power = GetOptionsTable_Text("targettarget", "power"),
		level = GetOptionsTable_Text("targettarget", "level"),
		portrait = GetOptionsTable_Portrait("targettarget"),
		roleIcon = GetOptionsTable_RoleIcon("targettarget"),
		targetIcon = GetOptionsTable_TargetIcon("targettarget"),
		resIndicator = GetOptionsTable_ResIndicator("targettarget"),
		leaderIcon = GetOptionsTable_Leader("targettarget"),
		buffs = GetOptionsTable_Auras("Buffs", "targettarget", 200),
		debuffs = GetOptionsTable_Auras("Debuffs", "targettarget", 201),
		absorb = GetOptionsTable_Absorption("targettarget"),
		barHealth = GetOptionsTable_HealthBar("targettarget"),
		barPower = GetOptionsTable_PowerBar("targettarget"),
		castbar = GetOptionsTable_CastBar("targettarget"),
	},
	
}

CD.Options.args.unitframe.args.focus = {
	name = L["Focus"],
	type = 'group',
	order = 5,
	childGroups = "tab",
	args = {
		generalGroup =  GetOptionsTable_General("focus"),
		name = GetOptionsTable_Text("focus", "name"),
		health = GetOptionsTable_Text("focus", "health"),
		power = GetOptionsTable_Text("focus", "power"),
		level = GetOptionsTable_Text("focus", "level"),
		portrait = GetOptionsTable_Portrait("focus"),
		roleIcon = GetOptionsTable_RoleIcon("focus"),
		targetIcon = GetOptionsTable_TargetIcon("focus"),
		resIndicator = GetOptionsTable_ResIndicator("focus"),
		leaderIcon = GetOptionsTable_Leader("focus"),
		buffs = GetOptionsTable_Auras("Buffs", "focus", 200),
		debuffs = GetOptionsTable_Auras("Debuffs", "focus", 201),
		absorb = GetOptionsTable_Absorption("focus"),
		barHealth = GetOptionsTable_HealthBar("focus"),
		barPower = GetOptionsTable_PowerBar("focus"),
		castbar = GetOptionsTable_CastBar("focus"),
	},
	
}

CD.Options.args.unitframe.args.focustarget = {
	name = L["FocusTarget"],
	type = 'group',
	order = 6,
	childGroups = "tab",
	args = {
		generalGroup =  GetOptionsTable_General("focustarget"),
		name = GetOptionsTable_Text("focustarget", "name"),
		health = GetOptionsTable_Text("focustarget", "health"),
		power = GetOptionsTable_Text("focustarget", "power"),
		level = GetOptionsTable_Text("focustarget", "level"),
		portrait = GetOptionsTable_Portrait("focustarget"),
		roleIcon = GetOptionsTable_RoleIcon("focustarget"),
		targetIcon = GetOptionsTable_TargetIcon("focustarget"),
		resIndicator = GetOptionsTable_ResIndicator("focustarget"),
		leaderIcon = GetOptionsTable_Leader("focustarget"),
		buffs = GetOptionsTable_Auras("Buffs", "focustarget", 200),
		debuffs = GetOptionsTable_Auras("Debuffs", "focustarget", 201),
		absorb = GetOptionsTable_Absorption("focustarget"),
		barHealth = GetOptionsTable_HealthBar("focustarget"),
		barPower = GetOptionsTable_PowerBar("focustarget"),
		castbar = GetOptionsTable_CastBar("focustarget"),
	},
	
}

CD.Options.args.unitframe.args.arena = {
	name = L["Arena"],
	type = 'group',
	order = 7,
	childGroups = "tab",
	args = {
		generalGroup =  GetOptionsTable_General("arena"),
		name = GetOptionsTable_Text("arena", "name"),
		health = GetOptionsTable_Text("arena", "health"),
		power = GetOptionsTable_Text("arena", "power"),
		level = GetOptionsTable_Text("arena", "level"),
		portrait = GetOptionsTable_Portrait("arena"),
		readycheckicon = GetOptionsTable_ReadyCheck("arena"),
		resIndicator = GetOptionsTable_ResIndicator("arena"),
		roleIcon = GetOptionsTable_RoleIcon("arena"),
		targetIcon = GetOptionsTable_TargetIcon("arena"),
		leaderIcon = GetOptionsTable_Leader("arena"),
		buffs = GetOptionsTable_Auras("Buffs", "arena", 200),
		debuffs = GetOptionsTable_Auras("Debuffs", "arena", 201),
		absorb = GetOptionsTable_Absorption("arena"),
		barHealth = GetOptionsTable_HealthBar("arena"),
		barPower = GetOptionsTable_PowerBar("arena"),
		castbar = GetOptionsTable_CastBar("arena"),
	},
	
}

CD.Options.args.unitframe.args.party = {
	name = L["Party"],
	type = 'group',
	order = 8,
	childGroups = "tab",
	args = {
		generalGroup =  GetOptionsTable_General("party"),
		name = GetOptionsTable_Text("party", "name"),
		health = GetOptionsTable_Text("party", "health"),
		power = GetOptionsTable_Text("party", "power"),
		level = GetOptionsTable_Text("party", "level"),
		portrait = GetOptionsTable_Portrait("party"),
		readycheckicon = GetOptionsTable_ReadyCheck("party"),
		summonIcon = GetOptionsTable_SummonIndicator("party"),
		resIndicator = GetOptionsTable_ResIndicator("party"),
		roleIcon = GetOptionsTable_RoleIcon("party"),
		targetIcon = GetOptionsTable_TargetIcon("party"),
		leaderIcon = GetOptionsTable_Leader("party"),
		buffs = GetOptionsTable_Auras("Buffs", "party", 200),
		debuffs = GetOptionsTable_Auras("Debuffs", "party", 201),
		absorb = GetOptionsTable_Absorption("party"),
		barHealth = GetOptionsTable_HealthBar("party"),
		barPower = GetOptionsTable_PowerBar("party"),
		castbar = GetOptionsTable_CastBar("party"),
	},
	
}

CD.Options.args.unitframe.args.raid = {
	name = L["Raid"],
	type = 'group',
	order = 9,
	childGroups = "tab",
	args = {
		generalGroup = GetOptionsTable_General("raid"),
		name = GetOptionsTable_Text("raid", "name"),
		health = GetOptionsTable_Text("raid", "health"),
		power = GetOptionsTable_Text("raid", "power"),
		level = GetOptionsTable_Text("raid", "level"),
		portrait = GetOptionsTable_Portrait("raid"),
		readycheckicon = GetOptionsTable_ReadyCheck("raid"),
		summonIcon = GetOptionsTable_SummonIndicator("raid"),
		resIndicator = GetOptionsTable_ResIndicator("raid"),
		roleIcon = GetOptionsTable_RoleIcon("raid"),
		targetIcon = GetOptionsTable_TargetIcon("raid"),
		leaderIcon = GetOptionsTable_Leader("raid"),
		buffs = GetOptionsTable_Auras("Buffs", "raid", 200),
		debuffs = GetOptionsTable_Auras("Debuffs", "raid", 201),
		absorb = GetOptionsTable_Absorption("raid"),
		barHealth = GetOptionsTable_HealthBar("raid"),
		barPower = GetOptionsTable_PowerBar("raid"),
		-- castbar = GetOptionsTable_CastBar("raid"),
	},
}

CD.Options.args.unitframe.args.raid40 = {
	name = L["Raid40"],
	type = 'group',
	order = 10,
	childGroups = "tab",
	args = {
		generalGroup = GetOptionsTable_General("raid40"),
		name = GetOptionsTable_Text("raid40", "name"),
		health = GetOptionsTable_Text("raid40", "health"),
		power = GetOptionsTable_Text("raid40", "power"),
		level = GetOptionsTable_Text("raid40", "level"),
		portrait = GetOptionsTable_Portrait("raid40"),
		readycheckicon = GetOptionsTable_ReadyCheck("raid40"),
		summonIcon = GetOptionsTable_SummonIndicator("raid40"),
		resIndicator = GetOptionsTable_ResIndicator("raid40"),
		roleIcon = GetOptionsTable_RoleIcon("raid40"),
		targetIcon = GetOptionsTable_TargetIcon("raid40"),
		leaderIcon = GetOptionsTable_Leader("raid40"),
		buffs = GetOptionsTable_Auras("Buffs", "raid40", 200),
		debuffs = GetOptionsTable_Auras("Debuffs", "raid40", 201),
		absorb = GetOptionsTable_Absorption("raid40"),
		barHealth = GetOptionsTable_HealthBar("raid40"),
		barPower = GetOptionsTable_PowerBar("raid40"),
		-- castbar = GetOptionsTable_CastBar("raid40"),
	},
}

CD.Options.args.unitframe.args.boss = {
	name = L["Boss"],
	type = 'group',
	order = 11,
	childGroups = "tab",
	args = {
		generalGroup =  GetOptionsTable_General("boss"),
		name = GetOptionsTable_Text("boss", "name"),
		health = GetOptionsTable_Text("boss", "health"),
		power = GetOptionsTable_Text("boss", "power"),
		level = GetOptionsTable_Text("boss", "level"),
		portrait = GetOptionsTable_Portrait("boss"),
		targetIcon = GetOptionsTable_TargetIcon("boss"),
		buffs = GetOptionsTable_Auras("Buffs", "boss", 200),
		debuffs = GetOptionsTable_Auras("Debuffs", "boss", 201),
		absorb = GetOptionsTable_Absorption("boss"),
		barHealth = GetOptionsTable_HealthBar("boss"),
		barPower = GetOptionsTable_PowerBar("boss"),
		castbar = GetOptionsTable_CastBar("boss"),
	},
	
}