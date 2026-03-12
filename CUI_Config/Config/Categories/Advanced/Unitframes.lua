local E, L = unpack(CUI) -- Engine
local CO, CD, UF, BA, FI = E:LoadModules("Config", "Config_Dialog", "Unitframes", "Bar_Auras", "Filters")

local format 		= string.format
local lower 		= string.lower
local upper 		= string.upper
local tinsert		= table.insert
local _
local SelectedSpec
local Module = {}

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
	["+"] = L["Ascending"],
	["-"] = L["Descending"],
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
CD.PortraitStyles = {
	["3D"] = "3D",
	["2D"] = "2D",
}
CD.HeaderSortDirections = {
	["ASC"] = L["Ascending"],
	["DESC"] = L["Descending"],
}
CD.HeaderSortMethods = {
	["INDEX"] = "Index",
	["NAME"] = "Name",
	["NAMELIST"] = "Namelist",
}
local DIRECTION_TO_ATTRIBUTES = {
	--DOWN = "Down",
	DOWN_RIGHT = L["DOWN_RIGHT"],
	DOWN_LEFT = L["DOWN_LEFT"],
	RIGHT_DOWN = L["RIGHT_DOWN"],
	RIGHT_UP = L["RIGHT_UP"],
	LEFT_DOWN = L["LEFT_DOWN"],
	LEFT_UP = L["LEFT_UP"],
	--UP = "Up",
	UP_RIGHT = L["UP_RIGHT"],
	UP_LEFT = L["UP_LEFT"],
}
local GroupByOptions = {}
do
	for k, _ in pairs(UF.headerGroupBy) do
		GroupByOptions[k] = L[(lower(k)):gsub("^%l", string.upper)]
	end
end
local GroupByOptions_Small = E:TableDeepCopy(GroupByOptions)
GroupByOptions_Small["GROUP"] = nil

local SupportedClassSpecifics = {250,268}
local SupportedClassSpecifics_NameOverride = {
	[250] = L.DEATHKNIGHT,
}
local SupportedClassSpecifics_IconOverride = {
	[250] = 135771,
}

local CategoryColors = {
	["CoreModules"] = "|cFF22E37F%s|r",
	["Fonts"] 		= "|cFFEB951C%s|r",
	["Auras"] 		= "|cFFA068ED%s|r",
	["Symbols"] 	= "|cFF0CADED%s|r"
}
local CategoryOrders = {
	["Font_health"] = 201,
	["Font_power"] = 202,
	["Font_name"] = 203,
	["Font_level"] = 204,
	["Health"] = 205,
	["Power"] = 206,
	["Absorption"] = 207,
	["Castbar"] = 208,
	["ClassPower"] = 209,
	["AlternatePower"] = 210,
	["ThreatBar"] = 211,
	["Portrait"] = 211.5,
	["AuraBars"] = 212,
	["Buffs"] = 213,
	["Debuffs"] = 214,
	["ResurrectIndicator"] = 216,
	["SummonIndicator"] = 217,
	["ReadyCheckIndicator"] = 218,
	["RestingIndicator"] = 219,
	["RoleIcon"] = 220,
	["CombatIndicator"] = 221,
	["LeaderIcon"] = 222,
	["TargetIcon"] = 223	
}
--------------------------------------------------------------------------
local OverrideFont_EnableHeight, OverrideFont_EnableType, OverrideFont_EnableFlags, OverrideFont_EnableShadow
-- Override Types define the actual db name of that option
local OverrideFont_Types = {'fontHeight', 'fontType', 'fontFlags', 'xFontShadowOffset', 'yFontShadowOffset', 'fontShadowColor'}
local OverrideFont_Height, OverrideFont_Type, OverrideFont_Flags, OverrideFont_ShadowColor, OverrideFont_ShadowX, OverrideFont_ShadowY
local OverrideFonts_EnabledUnits = {}
local DB_UNITS_TO_LOCALIZED = {
	["player"] = L["Player"],
	["pet"] = L["Pet"],
	["target"] = L["Target"],
	["targettarget"] = L["TargetTarget"],
	["focus"] = L["Focus"],
	["focustarget"] = L["FocusTarget"],
	["raid"] = L["Raid"],
	["raid40"] = L["Raid40"],
	["party"] = L["Party"],
	["arena"] = L["Arena"],
	["boss"] = L["Boss"],
	["maintank"] = L["Maintank"],
}

-- Targeting Sounds
local SOUNDSELECT_SITUATIONS_SELECTED
local SOUNDSELECT_SITUATIONS = {
	["npc"] 	= "Friendly Target",
	["aggro"] 	= "Hostile Target",
	["neutral"] = "Neutral Target",
	["lost"] 	= "Target Lost",
}

local All_showCastingTarget

CD.DummyMode = false
local DummyShowIndex = true

local function ApplyGlobalFontOverride()
	
	local OverrideValue
	
	for _, OverrideType in pairs(OverrideFont_Types) do
		if OverrideType == 'fontHeight' and OverrideFont_EnableHeight then
			OverrideValue = OverrideFont_Height
		elseif OverrideType == 'fontType' and OverrideFont_EnableType then
			OverrideValue = OverrideFont_Type
		elseif OverrideType == 'fontFlags' and OverrideFont_EnableFlags then
			OverrideValue = OverrideFont_Flags
		elseif OverrideType == 'xFontShadowOffset' and OverrideFont_EnableShadow then
			OverrideValue = OverrideFont_ShadowX
		elseif OverrideType == 'yFontShadowOffset' and OverrideFont_EnableShadow then
			OverrideValue = OverrideFont_ShadowY
		elseif OverrideType == 'fontShadowColor' and OverrideFont_EnableShadow then
			OverrideValue = OverrideFont_ShadowColor
		end
		
		if OverrideValue then
			for unit, config in pairs(CO.db.profile.unitframe.units) do
				if OverrideFonts_EnabledUnits[unit] and config.fonts then
					for name, font in pairs(config.fonts) do
						if font[OverrideType] then
							
							if type(font[OverrideType]) == 'table' and type(OverrideValue) == 'table' then
								E:TableMerge(font[OverrideType], OverrideValue)
							elseif type(font[OverrideType]) == type(OverrideValue) then
								font[OverrideType] = OverrideValue
							end
						end
					end
				end
			end
		end
	end
	
	
	UF:LoadConfig('fonts')
end

local GlobalAbsorb_Data = {
	enableAbsorb = nil,
	absorbUseStripes = nil,
	absorbTextureSizeMultiplier = nil,	
	absorbBorderColor = nil,	
	absorbTextureColor = nil,	
}
local function GlobalAbsorb_Update()
	for TypeName, OverrideValue in pairs(GlobalAbsorb_Data) do
		if OverrideValue ~= nil then
			--for _, config in pairs(CO.db.profile.unitframe.units[groupName].health)
			for _, config in pairs(CO.db.profile.unitframe.units) do
				if config.health then
					config.health[TypeName] = OverrideValue
				end
			end
		end
	end
	
	UF:LoadConfig()
end

local function ToggleIndex(state, limit)
	
	local self = E:LoadModule("Unitframes")
	
	for k,v in pairs(self.Frames) do
		if not limit or (k == limit) then
			for _, Frame in pairs(v) do
				CD:AddIndexFont(Frame)
				
				if state then
					if CO.db.profile.unitframe.dummyShowIndex == true and (CD.DummyMode or limit) then
						Frame.Fonts.Index:Show()
						Frame.Fonts.Index:Update(Frame.RealIndex)
					end
				else
					Frame.Fonts.Index:Hide()
				end
			end
		end
	end
end
						
-- This is broken atm, so don't use plz
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

local Toggles = {}
local function ToggleHeaderFrame(groupName)
	
	local self = E:LoadModule("Unitframes")
	
	if Toggles[groupName] == nil then
		-- I have NO idea how we could possibly circumvent this. But enabling,disabling and enabling again seems to work fine
		UF.Headers:ForceToggle(Toggles[groupName], groupName); Toggles[groupName] = true
		UF.Headers:ForceToggle(Toggles[groupName], groupName); Toggles[groupName] = false
		UF.Headers:ForceToggle(Toggles[groupName], groupName); Toggles[groupName] = true
		UF.Headers:ForceToggle(Toggles[groupName], groupName); Toggles[groupName] = false
	elseif Toggles[groupName] ~= nil then
		UF.Headers:ForceToggle(Toggles[groupName], groupName); Toggles[groupName] = not Toggles[groupName]
	end
	
	ToggleIndex(not Toggles[groupName], groupName)
end

local function SetUnitDummys(state)
	-- Set dummy units
	for k, v in pairs(UF.Frames) do
		-- Prevent showing of disabled unitframes
		if v.ForceMoverEnabled ~= false then
			if not UF:HasFrameKeyHeader(k) then
				for _, Frame in pairs(v) do
					if state == true then
						Frame:SetAttribute("unit", "player")
						
						UnregisterUnitWatch(Frame)
						RegisterUnitWatch(Frame, true)
						
						Frame.unit = "player"
						
						Frame.Fonts.Level.unit = "player"
						Frame.Fonts.Name.unit = "player"
						Frame.Fonts.Health.unit = "player"
						Frame.Fonts.Power.unit = "player"
						
						Frame:Show()
					else
						Frame:SetAttribute("unit", Frame.BackupUnit)
						
						UnregisterUnitWatch(Frame)
						RegisterUnitWatch(Frame)
						
						Frame.unit = Frame.BackupUnit
						
						Frame.Fonts.Level.unit = Frame.BackupUnit	
						Frame.Fonts.Name.unit = Frame.BackupUnit
						Frame.Fonts.Health.unit = Frame.BackupUnit
						Frame.Fonts.Power.unit = Frame.BackupUnit
					end
					
					-- Also temporarily override module unit(s) and push update
					for _, ufmodule in pairs(Frame) do
						if type(ufmodule) == "table" and ufmodule.ForceUpdate then
							if state == true then
								ufmodule.unit = "player"
								ufmodule:ForceUpdate()
							else
								ufmodule.unit = v.BackupUnit
								ufmodule:ForceUpdate()
							end
						end
					end
				end
			end
		end
	end
	
	-- Update based on new values
	UF:UpdateAllUF()
	
	-- Override
	for k,v in pairs(UF.Frames) do
		if not UF:HasFrameKeyHeader(k) then
			for _, Frame in pairs(v) do
				if state == true then
					-- MISC MODULES OVERRIDE
						Frame:SetScript("OnShow", nil)
						if Frame.Role then
							Frame.Role.T:SetTexture(UF.RoleTexture["DAMAGER"])
							Frame.Role:Show()
						end
						--v.Leader
						--v.TargetIcon
						--v.RezIcon
					-- MISC MODULES OVERRIDE END
				else
					-- MISC MODULES OVERRIDE
						Frame:SetScript("OnShow", Frame.OnEvent)
					-- MISC MODULES OVERRIDE END
				end
			end
		end
	end
	
	--UF.Headers:ForceToggle(state)
	
	ToggleIndex(state)
	--ToggleAuras(state)
	UF:OverrideHolderVisibility(state, nil, true)
end

local function ToggleCombatIndicator()
	local CI = UF.Frames.player[1].CombatIndicator
	local db = CO.db.profile.unitframe.units.player.combatIndicator
	
	if CI then
		if not CI.testState then
			if CI.enableGlow then E:UIFrameFadeIn(CI.Border, db.glowFadeIn, CI.Border:GetAlpha(), 1) end
			if CI.enableIcon then E:UIFrameFadeIn(CI.Icon, db.iconFadeIn, CI.Icon:GetAlpha(), 1) end
			
			CI.testState = true
		else
			if CI.enableGlow then E:UIFrameFadeOut(CI.Border, db.glowFadeOut, CI.Border:GetAlpha(), 0) end
			if CI.enableIcon then E:UIFrameFadeOut(CI.Icon, db.iconFadeOut, CI.Icon:GetAlpha(), 0) end			
			
			CI.testState = false
		end
	end
end

function ToggleResIndicator(unit, frame)
	if not frame then return end
	
	local Element = frame.ResurrectIndicator
	if not Element then return end
	
	if Element then
		if not Element.TestState then
			
			Element:Show()
			
			Element.TestState = true
		else
			Element:ForceUpdate()
			
			Element.TestState = false
		end
	end
end

function ToggleReadyCheck(unit, frame)
	if not frame then return end
	
	local Element = frame.ReadyCheckIndicator
	if not Element then return end
	
	if Element then
		if not Element.TestState then
			
			local Key = E:GetRandomTableKey(UF.ReadyCheckStates)
			local Color = CO.db.profile.colors.readycheck[Key]
			
			Element.T:SetTexture(UF.ReadyCheckStates[Key])
			Element.T:SetVertexColor(Color[1], Color[2], Color[3])
			Element:Show()
			
			Element.TestState = true
		else
			Element:ForceUpdate()
			Element.T:SetTexture(nil)
			
			Element.TestState = false
		end
	end
end

function ToggleSummonIndicator(unit, frame)
	if not frame then return end
	
	local Element = frame.SummonIndicator
	if not Element then return end
	
	if Element then
		if not Element.TestState then
			
			Element.T:SetAtlas('Raid-Icon-SummonPending')
			Element:Show()
			
			Element.TestState = true
		else
			Element:ForceUpdate()
			
			Element.TestState = false
		end
	end
end

local function ToggleRoleIcon(unit, frame)
	if not frame then return end
	
	local Element = frame.Role
	if not Element then return end
	
	if Element then
		if not Element.TestState then
			
			Element.T:SetTexture(E:GetRandomTableEntry(UF.RoleTexture))
			Element:Show()
			
			Element.TestState = true
		else
			Element:ForceUpdate()
			
			Element.TestState = false
		end
	end
end

local function ToggleLeaderIcon(unit, frame)
	if not frame then return end
	
	local Element = frame.LeaderIcon
	if not Element then return end
	
	if Element then
		if not Element.TestState then
			
			Element.T:SetTexture([[Interface\GroupFrame\UI-Group-LeaderIcon]])
			Element:Show()
			
			Element.TestState = true
		else
			Element:ForceUpdate()
			
			Element.TestState = false
		end
	end
end

local function ToggleTargetIcon(unit, frame)
	if not frame then return end
	
	local Element = frame.TargetIcon
	if not Element then return end
	
	if Element then
		if not Element.TestState then
			if not Element.T:GetTexture() then
				Element.T:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
			end
			SetRaidTargetIconTexture(Element.T, math.random(1, 8))
			Element:Show()
			
			Element.TestState = true
		else
			Element:ForceUpdate()
			
			Element.TestState = false
		end
	end
end

local DisabledColor = "|cFF808080"
-- We don't have to add any |r here, as the one already in place should serve just fine
local function GetLabel(Name, Disabled)
	if Name:find(DisabledColor) then
		if not Disabled then
			Name = Name:gsub(DisabledColor, "")
			--Name = Name:sub()
		end
	else
		if Disabled then
			-- Split up already set color and
			local NewName = Name:sub(11) -- Color always has a length of 10
			NewName = DisabledColor .. NewName
			
			-- Add original color back to preserve it for other state
			local Color = Name:sub(1, 10)
			Name = Color .. NewName
		end
	end
	
	return Name
end

local function IsGroupDisabled(groupName)
	return not CO.db.profile.unitframe.units[groupName].enable
end

local function GetOptionsTable_General(groupName)
	if not CO.db.char.unitframe.enable then return end
	
	local ClusterConfig = CO.db.profile.unitframe.units[groupName].UFInfo.cluster
	local HeaderConfig = CO.db.profile.unitframe.units[groupName].headers
	local AttachHiddenFunc = function() return CO.db.profile.movers[UF:GetUFMover(groupName):GetName()]["enableAttach"] == false end
	local IsDisabled = function() return IsGroupDisabled(groupName) end
	
	local config = {
		order = 100,
		type = 'group',
		name = L["General"],
		get = function(info) return CO.db.profile.unitframe.units[groupName][ info[#info] ] end,
		set = function(info, value) CO.db.profile.unitframe.units[groupName][ info[#info] ] = value; UF:LoadHolderConfig(groupName); UF:LoadProfileForUnits(groupName); end,
		args = {
		enable = {
			order = 1,
			type = "toggle",
			name = L["Enable"],
			set = function(info, value)
				CO.db.profile.unitframe.units[groupName].enable = value; UF:LoadHolderConfig(groupName); UF:LoadProfileForUnits(groupName);
				
				-- Refresh so we get the correct category coloring
				CD:RefreshConfigGUI("unitframe", groupName)
				
				-- Refresh display
				if CD.DummyMode then
					SetUnitDummys(false)
					SetUnitDummys(true)
				end
			end,
		},
		toggle = {
			type = 'execute',
			name = 'Toggle',
			order = 1.5,
			func = function()
				ToggleHeaderFrame(groupName)
			end,
			hidden = function() return not (groupName == 'raid' or groupName == 'raid40' or groupName == 'party' or groupName == 'maintank') end,
		},
		generalHeader = {
			type = "header",
			name = L["Positioning"],
			order = 2,
		},
		rangeHeader = {
			type = "header",
			name = L["RangeIndicator"],
			order = 100,
			hidden = (groupName == "player"),
			},
		rangeIndicator = {
			type = "toggle",
			order = 101,
			hidden = (groupName == "player"),
			name = L["Enable"],
			desc = "When enabled, this unitframe will become slightly transparent when the unit is a certain distance away from you.",
			width = "full",
			},
		},
	}
	
	local RowColumnNameFunc = function(value)
		local Explode = E:FullSplit(value, "_")
		local NewName = ""
		if Explode then
			if (Explode[1] == "UP" or Explode[1] == "DOWN") then
					NewName = L["GroupsPerColumn"]
			elseif (Explode[1] == "LEFT" or Explode[1] == "RIGHT") then
					NewName = L["GroupsPerRow"]
			end
		end
		
		return NewName
	end
	local GroupByToUse
	if groupName == "raid" or groupName == "raid40" then
		GroupByToUse = GroupByOptions
	else
		GroupByToUse = GroupByOptions_Small
	end
	
	
	
		if groupName == "raid" or groupName == "raid40" or groupName == "party" or groupName == "arena" or groupName == "boss" or groupName== "maintank" then
			local extension
			if groupName ~= "boss" and groupName ~= "arena" then
				extension = {
					groupHeader = {
						order = 50,
						type = "header",
						name = "Frame Cluster",
					},
					growthDirection = {
						order = 54,
						type = 'select',
						name = L["GrowthDirection"],
						desc = "How the unitframes should grow",
						values = DIRECTION_TO_ATTRIBUTES,
						get = function(info)
							return HeaderConfig.growthDirection
						end,
						set = function(info, value)
							HeaderConfig.growthDirection = value
							UF.Headers:LoadConfig(groupName)
							
							-- Cosmetic
							extension.groupConfig.args.perRow.name = RowColumnNameFunc(value)
						end,
					},
					sortDirection = {
						order = 55,
						name = L["SortDirection"],
						type = "select",
						values = CD.HeaderSortDirections,
						disabled = DisabledFunc,
						get = function(info)
							return HeaderConfig.attr_SortDir
						end,
						set = function(info, value)
							HeaderConfig.attr_SortDir = value
							UF.Headers:LoadConfig(groupName)
						end, 
					},
					sortMethod = {
						order = 56,
						name = L["SortMethod"],
						type = "select",
						values = CD.HeaderSortMethods,
						disabled = DisabledFunc,
						get = function(info)
							return HeaderConfig.attr_SortMethod
						end,
						set = function(info, value)
							HeaderConfig.attr_SortMethod = value
							UF.Headers:LoadConfig(groupName)
						end, 
					},
					groupBy = {
						order = 57,
						name = L["GroupBy"],
						type = "select",
						values = GroupByToUse,
						disabled = DisabledFunc,
						get = function(info)
							return HeaderConfig.groupBy
						end,
						set = function(info, value)
							HeaderConfig.groupBy = value
							UF.Headers:LoadConfig(groupName)
						end, 
					},
					groupConfig = {
						type = "group",
						order = 60,
						name = L["GroupConfig"],
						guiInline = true,
						hidden = function() return UF.RegisteredHeaderClusters[groupName].GroupSize < 2 end,
						args = {
							perRow = {
								order = 55,
								type = 'range',
								name = L["GroupsPerColumn"],
								desc = "Limits the number of groups that should be displayed in one row or column - based on the growth direction",
								width = "full", -- Feels better
								min = 1, max = UF.RegisteredHeaderClusters[groupName].GroupSize, step = 1,
								get = function() 
									-- Cosmetic
									return HeaderConfig.perRow;
								end,
								set = function(info, value) HeaderConfig.perRow = value; UF.Headers:LoadConfig(groupName) end,
							},
							groupGapX = {
								order = 55.5,
								type = 'range',
								name = L["GroupGap"] .. " X",
								desc = "The X gap size between groups",
								--width = "full", -- Feels better
								min = 1, max = 200, step = 1,
								get = function() return HeaderConfig.groupGapX end,
								set = function(info, value) HeaderConfig.groupGapX = value; UF.Headers:LoadConfig(groupName) end,
							},
							groupGapY = {
								order = 55.75,
								type = 'range',
								name = L["GroupGap"] .. " Y",
								desc = "The Y gap size between groups",
								--width = "full", -- Feels better
								min = 1, max = 200, step = 1,
								get = function() return HeaderConfig.groupGapY end,
								set = function(info, value) HeaderConfig.groupGapY = value; UF.Headers:LoadConfig(groupName) end,
							},
						},
					},
					unitConfig = {
						type = "group",
						order = 61,
						name = L["UnitConfig"]	,
						guiInline = true,
						args = {
							gapX = {
								order = 56,
								type = 'range',
								name = "X " .. L["Gap"],
								desc = "The horizontal gap between each unitframe in a group",
								--width = "full", -- Feels better
								min = 0, max = 50, step = 1,
								get = function() return HeaderConfig.gapX end,
								set = function(info, value) HeaderConfig.gapX = value; UF.Headers:LoadConfig(groupName) end,
							},
							gapY = {
								order = 57,
								type = 'range',
								name = "Y " .. L["Gap"],
								desc = "The vertical gap between each unitframe in a group",
								--width = "full", -- Feels better
								min = 0, max = 50, step = 1,
								get = function() return HeaderConfig.gapY end,
								set = function(info, value) HeaderConfig.gapY = value; UF.Headers:LoadConfig(groupName) end,
							},
							NewLine55 = CD:GetNewLine(58),
							showPlayer = {
								order = 59,
								type = "toggle",
								name = "Show Player",
								get = function() return HeaderConfig.attr_ShowPlayer end,
								set = function(info, value) HeaderConfig.attr_ShowPlayer = value; UF.Headers:LoadConfig(groupName) end,
								hidden = function() return groupName == 'raid' or groupName == 'raid40' end,
							},
						},
					},
					
					visibilityCondition = {
						order = 62,
						type = 'input',
						name = L["Visibility"],
						desc = L["VisibilityDesc_FULL"],
						width = "full",
						get = function() return ClusterConfig.visibilityCondition end,
						set = function(info, value) ClusterConfig.visibilityCondition = value; UF:LoadHolderConfig(groupName) end,
					},
					defaultVisibility = {
						order = 63,
						type = "execute",
						name = L["DefVisibility"],
						desc = "In case you want to reset the visiblity string to default",
						func = function()
							ClusterConfig.visibilityCondition = E.ConfigDefaults.profile.unitframe.units[groupName].visibilityCondition
							UF:LoadHolderConfig(groupName)
						end,
					},
				}
				
				extension.groupConfig.args.perRow.name = RowColumnNameFunc(HeaderConfig.growthDirection)
			else
				extension = {
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
						name = L["Visibility"],
						desc = L["VisibilityDesc_FULL"],
						width = "full",
						get = function() return ClusterConfig.visibilityCondition end,
						set = function(info, value) ClusterConfig.visibilityCondition = value; UF:LoadHolderConfig(groupName) end,
					},
					defaultVisibility = {
						order = 60,
						type = "execute",
						name = L["DefVisibility"],
						desc = "In case you want to reset the visiblity string to default",
						func = function()
							ClusterConfig.visibilityCondition = E.ConfigDefaults.profile.unitframe.units[groupName].visibilityCondition
							UF:LoadHolderConfig(groupName)
						end,
					},
				}
			end
			
			for k,v in pairs(extension) do
				config.args[k] = v
			end
		end
		
	for k,v in pairs(config.args) do
		if k ~= 'enable' then
			config.args[k].disabled = IsDisabled
		end
	end

	local Mover = UF:GetUFMover(groupName)
	if Mover then
		for k,v in pairs(CD:GetMoverOptions(Mover:GetName(), 3, true, IsDisabled)) do
			config.args[k] = v
		end
	end
	
	

	return config
end

local function GetOptionsTable_HealthBar(groupName)
	local Name = GetLabel(CategoryColors['CoreModules']:format(L["Health Bar"]), IsGroupDisabled(groupName))
	
	local config = {
		order = CategoryOrders.Health,
		type = 'group',
		name = Name,
		get = function(info) return CO.db.profile.unitframe.units[groupName].health[ info[#info] ] end,
		set = function(info, value) CO.db.profile.unitframe.units[groupName].health[ info[#info] ] = value; UF.Modules["Health"]:LoadConfig(); UF.Modules["HealthAbsorb"]:LoadConfig(); UF.Modules["HealPrediction"]:LoadConfig(); UF:LoadHolderConfig(groupName) end,
		args = {
			position = {
				type = "execute",
				order = 1,
				name = L["Position"],
				func = function() CD.ACD:SelectGroup("CUI", "unitframe", groupName, "generalGroup") end,
			},
			sizeGroup = {
				type = 'group',
				order = 5,
				name = L['Size'],
				guiInline = true,
				hidden = DisabledFunc,
				args = {
					width = {
						order = 10,
						type = 'range',
						name = L["Width"],
						min = 1, max = 800, step = 1,
						set = function(info, value) CO.db.profile.unitframe.units[groupName].health[ info[#info] ] = value;
							UF.Modules["Health"]:LoadConfig(); UF:LoadProfileForUnits(groupName); UF.Modules["HealPrediction"]:LoadConfig(); UF:LoadHolderConfig(groupName)
							if groupName == "raid" or groupName == "raid40" or groupName == "party" or groupName == "arena" or groupName== "maintank" then
								UF.Headers:LoadConfig(groupName)
							end
						end,
					},
					height = {
						order = 11,
						type = 'range',
						name = L["Height"],
						min = 1, max = 800, step = 1,
						set = function(info, value) CO.db.profile.unitframe.units[groupName].health[ info[#info] ] = value;
							UF.Modules["Health"]:LoadConfig(); UF:LoadProfileForUnits(groupName); UF.Modules["HealPrediction"]:LoadConfig(); UF:LoadHolderConfig(groupName)
							if groupName == "raid" or groupName == "raid40" or groupName == "party" or groupName == "arena" or groupName== "maintank" then
								UF.Headers:LoadConfig(groupName)
							end
						end,
					},
				},
			},
			styleGroup = {
				type = 'group',
				order = 20,
				name = L['Style'],
				guiInline = true,
				args = {
					barBorderSize = {
						order = 10,
						type = 'range',
						name = L["BorderSize"],
						min = 0, max = 20, step = 0.1,
						set = function(info, value)
							if value == 0 then
								value = 0.1
							end
							
							CO.db.profile.unitframe.units[groupName].health[ info[#info] ] = value; UF.Modules["Health"]:LoadConfig(); UF:LoadProfileForUnits(groupName); UF.Modules["HealPrediction"]:LoadConfig(); UF:LoadHolderConfig(groupName)
						end,
					},
					newLine = {type="description", name="", order=15},
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
							
							UF.Modules["Health"]:LoadConfig();
						end,
					},
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
							
							UF.Modules["Health"]:LoadConfig();
						end,
					},
					newLine2_5 = {type="description", name="", order=22},
					useStaticColor = {
						order = 23,
						type = "toggle",
						name = "Use Static Color",
						desc = "Lets you choose a solid color that's always displayed on this bar. Disables Class Coloring.",
					},
					staticColor = {
						order = 24,
						type = 'color',
						name = "Static Color",
						hasAlpha = true,
						get = function(info)
							local c = CO.db.profile.unitframe.units[groupName].health.staticColor
							return c[1], c[2], c[3], c[4]
						end,
						set = function(info, r, g, b, a)
							local c = CO.db.profile.unitframe.units[groupName].health.staticColor
							c[1], c[2], c[3], c[4] = r, g, b, a
							
							UF.Modules["Health"]:LoadConfig();
						end,
						hidden = function() return not CO.db.profile.unitframe.units[groupName].health.useStaticColor end,
					},
					newLine2_5 = {type="description", name="", order=25},
					overrideBarTexture = {
						order = 26,
						type = "toggle",
						name = L["OverrideBarTexture"],
						desc = "Uses the override Texture when enabled. Uses global Texture when disabled.",
					},
					barTexture = {
						type = "select", dialogControl = 'LSM30_Statusbar',
						order = 27,
						name = L["OverrideTexture"],
						values = CO.AceGUIWidgetLSMlists["statusbar"],
						hidden = function() return not CO.db.profile.unitframe.units[groupName].health.overrideBarTexture end,
					},
				},
			},
			barSystem = {
				type = 'group',
				order = 30,
				name = 'Bar Configuration',
				guiInline = true,
				args = {
					barInverseFill = {
						order = 31,
						type = "toggle",
						name = L["BarFillInverse"],
						desc = "Inverts the fill direction of this bar",
					},
					barOrientation = {
						type = 'select',
						order = 32,
						name = L["BarFillDirection"],
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
						name = L["SmoothBar"],
						desc = "Smoothes out the bar value transition at the cost of performance.",
						width = "full",
					},
				},
			},
		},
	}

	return config
end

local function GetOptionsTable_PowerBar(groupName)
	local Name = GetLabel(CategoryColors['CoreModules']:format(L["Power Bar"]), IsGroupDisabled(groupName))
	local DisabledFunc = function() return not CO.db.profile.unitframe.units[groupName].power.enable end
	
	local config = {
		order = CategoryOrders.Power,
		type = 'group',
		name = Name,
		get = function(info) return CO.db.profile.unitframe.units[groupName].power[ info[#info] ] end,
		set = function(info, value) CO.db.profile.unitframe.units[groupName].power[ info[#info] ] = value; UF.Modules["Power"]:LoadConfig(); UF:LoadHolderConfig(groupName) end,
		args = {
			enable = {
				type = 'toggle',
				order = 1,
				name = L['Enable'],
			},
			newLine0 = CD:GetNewLine(5),
			sizeGroup = {
				type = 'group',
				order = 5,
				name = L['Size'],
				guiInline = true,
				hidden = DisabledFunc,
				args = {
					barWidth = {
						order = 10,
						type = 'range',
						name = L["Width"],
						min = 1, max = 800, step = 1,
						hidden = function() return CO.db.profile.unitframe.units[groupName].power.autoWidth end,
					},
					barHeight = {
						order = 11,
						type = 'range',
						name = L["Height"],
						min = 1, max = 800, step = 1,
						hidden = function() return CO.db.profile.unitframe.units[groupName].power.autoHeight end,
					},
					autoWidth = {
						order = 12,
						type = "toggle",
						name = "Auto Width",
						desc = "Automatically adjusts the bar width to the healthbar",
						width = 0.6,
					},
					autoHeight = {
						order = 13,
						type = "toggle",
						name = "Auto Height",
						desc = "Automatically adjusts the bar height to the healthbar",
						width = 0.6,
					},
					newLine = CD:GetNewLine(15),
					adjustAutoWidth = {
						order = 16,
						type = 'range',
						min = -100, max = 100, step = 1,
						name = "Adjust Auto Width",
						desc = "Adjusts the automatic width",
						hidden = function() return not CO.db.profile.unitframe.units[groupName].power.autoWidth end,
					},
					adjustAutoHeight = {
						order = 17,
						type = 'range',
						min = -100, max = 100, step = 1,
						name = "Adjust Auto Height",
						desc = "Adjusts the automatic height",
						hidden = function() return not CO.db.profile.unitframe.units[groupName].power.autoHeight end,
					},
				},
			},
			
			positionGroup = {
				type = 'group',
				order = 20,
				name = L['Position'],
				guiInline = true,
				hidden = DisabledFunc,
				args = {
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
				},
			},
			newLine2 = CD:GetNewLine(20),
			styleGroup = {
				type = 'group',
				order = 20,
				name = L['Style'],
				guiInline = true,
				hidden = DisabledFunc,
				args = {
					barBorderSize = {
						order = 21,
						type = 'range',
						name = L["BorderSize"],
						min = 0, max = 20, step = 0.1,
						set = function(info, value)
							if value == 0 then
								value = 0.1
							end
							
							CO.db.profile.unitframe.units[groupName].power[ info[#info] ] = value; UF.Modules["Power"]:LoadConfig(); UF:LoadHolderConfig(groupName)
						end,
					},
					newLine2_5 = CD:GetNewLine(21.5),
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
							
							UF.Modules["Power"]:LoadConfig();
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
							
							UF.Modules["Power"]:LoadConfig();
						end,
					},
					newLine3 = CD:GetNewLine(24),
					hideWhenEmpty = {
						order = 25,
						type = "toggle",
						name = "Hide when empty",
						desc = "When enabled, the bar will be hidden when it's empty",
					},
					newLine4 = CD:GetNewLine(30),
					overrideBarTexture = {
						order = 31,
						type = "toggle",
						name = L["OverrideBarTexture"],
						desc = "Uses the override Texture when enabled. Uses global Texture when disabled.",
					},
					barTexture = {
						type = "select", dialogControl = 'LSM30_Statusbar',
						order = 32,
						name = L["OverrideTexture"],
						values = CO.AceGUIWidgetLSMlists["statusbar"],
						disabled = function() return DisabledFunc() or not CO.db.profile.unitframe.units[groupName].power.overrideBarTexture end,
					},
				},
			},
			barSystem = {
				type = 'group',
				order = 30,
				name = 'Bar Configuration',
				guiInline = true,
				hidden = DisabledFunc,
				args = {
					barInverseFill = {
						order = 31,
						type = "toggle",
						name = L["BarFillInverse"],
						desc = "Inverts the fill direction of this bar",
					},
					barOrientation = {
						type = 'select',
						order = 32,
						name = L["BarFillDirection"],
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
						name = L["SmoothBar"],
						desc = "Smoothes out the bar value transition at the cost of performance.",
						width = "full",
					},
				},
			},
		},
	}

	return config
end

local function GetOptionsTable_ThreatBar(groupName)
	local Name = GetLabel(CategoryColors['CoreModules']:format(L["Threat Bar"]), IsGroupDisabled(groupName))
	
	local DisabledFunc = function() return not CO.db.profile.unitframe.units[groupName].threat.enable end
	
	local config = {
		order = CategoryOrders.ThreatBar,
		type = 'group',
		name = Name,
		get = function(info) return CO.db.profile.unitframe.units[groupName].threat[ info[#info] ] end,
		set = function(info, value) CO.db.profile.unitframe.units[groupName].threat[ info[#info] ] = value; UF.Modules["Threat"]:LoadConfig() end,
		args = {
			enable = {
				order = 5,
				type = "toggle",
				name = L["Enable"],
			},
			newLine0 = {type="description", name="", order=7},
			width = {
				order = 10,
				type = 'range',
				name = L["Width"],
				min = 1, max = 800, step = 1,
				hidden = function() return CO.db.profile.unitframe.units[groupName].threat.autoWidth end,
				disabled = DisabledFunc,
			},
			height = {
				order = 11,
				type = 'range',
				name = L["Height"],
				min = 1, max = 800, step = 1,
				hidden = function() return CO.db.profile.unitframe.units[groupName].threat.autoHeight end,
				disabled = DisabledFunc,
			},
			autoWidth = {
				order = 12,
				type = "toggle",
				name = "Auto Width",
				desc = "Automatically adjusts the bar width to the healthbar",
				width = 0.6,
				disabled = DisabledFunc,
			},
			autoHeight = {
				order = 13,
				type = "toggle",
				name = "Auto Height",
				desc = "Automatically adjusts the bar height to the healthbar",
				width = 0.6,
				disabled = DisabledFunc,
			},
			newLine = {type="description", name="", order=15},
			position = {
				type = 'select',
				order = 16,
				name = L["Position"],
				values = E.Positions,
				disabled = DisabledFunc,
			},
			xOffset = {
				order = 17,
				type = 'range',
				name = L["XOffset"],
				min = -300, max = 300, step = 1,
				disabled = DisabledFunc,
			},
			yOffset = {
				order = 18,
				type = 'range',
				name = L["YOffset"],
				min = -300, max = 300, step = 1,
				disabled = DisabledFunc,
			},
			newLine2 = {type="description", name="", order=20},
			barBorderSize = {
				order = 21,
				type = 'range',
				name = L["BorderSize"],
				min = 0, max = 20, step = 0.1,
				set = function(info, value)
					if value == 0 then
						value = 0.1
					end
					
					CO.db.profile.unitframe.units[groupName].threat[ info[#info] ] = value; UF.Modules["Threat"]:LoadConfig()
				end,
				disabled = DisabledFunc,
			},
			barBorderColor = {
				order = 22,
				type = 'color',
				name = L["BorderColor"],
				hasAlpha = true,
				get = function(info)
					local c = CO.db.profile.unitframe.units[groupName].threat.barBorderColor
					return c[1], c[2], c[3], c[4]
				end,
				set = function(info, r, g, b, a)
					local c = CO.db.profile.unitframe.units[groupName].threat.barBorderColor
					c[1], c[2], c[3], c[4] = r, g, b, a
					
					UF.Modules["Threat"]:LoadConfig()
				end,
				disabled = DisabledFunc,
			},
			barBackgroundColor = {
				order = 23,
				type = 'color',
				name = L["BackgroundColor"],
				hasAlpha = true,
				get = function(info)
					local c = CO.db.profile.unitframe.units[groupName].threat.barBackgroundColor
					return c[1], c[2], c[3], c[4]
				end,
				set = function(info, r, g, b, a)
					local c = CO.db.profile.unitframe.units[groupName].threat.barBackgroundColor
					c[1], c[2], c[3], c[4] = r, g, b, a
					
					UF.Modules["Threat"]:LoadConfig();
				end,
				disabled = DisabledFunc,
			},
			newLine3 = {type="description", name="", order=24},
			overrideBarTexture = {
				order = 25,
				type = "toggle",
				name = "Override Bar Texture",
				desc = "Uses the override Texture when enabled. Uses global Texture when disabled.",
				disabled = DisabledFunc,
			},
			barTexture = {
				type = "select", dialogControl = 'LSM30_Statusbar',
				order = 26,
				name = "Override Texture",
				values = CO.AceGUIWidgetLSMlists["statusbar"],
				disabled = function() return DisabledFunc() or not CO.db.profile.unitframe.units[groupName].threat.overrideBarTexture end,
			},
			barSystemHeader = {
				type = "header",
				order = 30,
				name = "Bar System",
			},
			barInverseFill = {
				order = 31,
				type = "toggle",
				name = L["BarFillInverse"],
				desc = "Inverts the fill direction of this bar",
				disabled = DisabledFunc,
			},
			barOrientation = {
				type = 'select',
				order = 32,
				name = L["BarFillDirection"],
				desc = "How the bar should be filled. Vertical or Horizontal.",
				values = CD.SortBarOrientation,
				disabled = DisabledFunc,
			},
			barSmooth = {
				order = 34,
				type = 'toggle',
				name = L["SmoothBar"],
				desc = "Smoothes out the bar value transition at the cost of performance.",
				width = "full",
				disabled = DisabledFunc,
			},
		},
	}

	return config
end

local function GetOptionsTable_UnitAlternatePower(groupName)
	local Name = GetLabel(CategoryColors['CoreModules']:format(L["ALTERNATE_POWER"]), IsGroupDisabled(groupName))
	
	local DisabledFunc = function() return not CO.db.profile.unitframe.units[groupName].altPower.enable end
	
	local config = {
		order = CategoryOrders.AlternatePower,
		type = 'group',
		name = Name,
		get = function(info) return CO.db.profile.unitframe.units[groupName].altPower[ info[#info] ] end,
		set = function(info, value) CO.db.profile.unitframe.units[groupName].altPower[ info[#info] ] = value; UF.Modules["AlternatePower"]:LoadConfig() end,
		args = {
			enable = {
				order = 5,
				type = "toggle",
				name = L["Enable"],
			},
			newLine0 = {type="description", name="", order=7},
			width = {
				order = 10,
				type = 'range',
				name = L["Width"],
				min = 1, max = 800, step = 1,
				hidden = function() return CO.db.profile.unitframe.units[groupName].altPower.autoWidth end,
				disabled = DisabledFunc,
			},
			height = {
				order = 11,
				type = 'range',
				name = L["Height"],
				min = 1, max = 800, step = 1,
				hidden = function() return CO.db.profile.unitframe.units[groupName].altPower.autoHeight end,
				disabled = DisabledFunc,
			},
			autoWidth = {
				order = 12,
				type = "toggle",
				name = "Auto Width",
				desc = "Automatically adjusts the bar width to the healthbar",
				width = 0.6,
				disabled = DisabledFunc,
			},
			autoHeight = {
				order = 13,
				type = "toggle",
				name = "Auto Height",
				desc = "Automatically adjusts the bar height to the healthbar",
				width = 0.6,
				disabled = DisabledFunc,
			},
			newLine = {type="description", name="", order=15},
			position = {
				type = 'select',
				order = 16,
				name = L["Position"],
				values = E.Positions,
				disabled = DisabledFunc,
			},
			offsetX = {
				order = 17,
				type = 'range',
				name = L["XOffset"],
				min = -300, max = 300, step = 1,
				disabled = DisabledFunc,
			},
			offsetY = {
				order = 18,
				type = 'range',
				name = L["YOffset"],
				min = -300, max = 300, step = 1,
				disabled = DisabledFunc,
			},
			newLine2 = {type="description", name="", order=20},
			barBorderSize = {
				order = 21,
				type = 'range',
				name = L["BorderSize"],
				min = 0, max = 20, step = 0.1,
				set = function(info, value)
					if value == 0 then
						value = 0.1
					end
					
					CO.db.profile.unitframe.units[groupName].altPower[ info[#info] ] = value; UF.Modules["AlternatePower"]:LoadConfig()
				end,
				disabled = DisabledFunc,
			},
			barBorderColor = {
				order = 22,
				type = 'color',
				name = L["BorderColor"],
				hasAlpha = true,
				get = function(info)
					local c = CO.db.profile.unitframe.units[groupName].altPower.barBorderColor
					return c[1], c[2], c[3], c[4]
				end,
				set = function(info, r, g, b, a)
					local c = CO.db.profile.unitframe.units[groupName].altPower.barBorderColor
					c[1], c[2], c[3], c[4] = r, g, b, a
					
					UF.Modules["AlternatePower"]:LoadConfig()
				end,
				disabled = DisabledFunc,
			},
			barBackgroundColor = {
				order = 23,
				type = 'color',
				name = L["BackgroundColor"],
				hasAlpha = true,
				get = function(info)
					local c = CO.db.profile.unitframe.units[groupName].altPower.barBackgroundColor
					return c[1], c[2], c[3], c[4]
				end,
				set = function(info, r, g, b, a)
					local c = CO.db.profile.unitframe.units[groupName].altPower.barBackgroundColor
					c[1], c[2], c[3], c[4] = r, g, b, a
					
					UF.Modules["AlternatePower"]:LoadConfig();
				end,
				disabled = DisabledFunc,
			},
			newLine3 = {type="description", name="", order=24},
			overrideBarTexture = {
				order = 25,
				type = "toggle",
				name = "Override Bar Texture",
				desc = "Uses the override Texture when enabled. Uses global Texture when disabled.",
				disabled = DisabledFunc,
			},
			barTexture = {
				type = "select", dialogControl = 'LSM30_Statusbar',
				order = 26,
				name = "Override Texture",
				values = CO.AceGUIWidgetLSMlists["statusbar"],
				disabled = function() return DisabledFunc() or not CO.db.profile.unitframe.units[groupName].altPower.overrideBarTexture end,
			},
			barSystemHeader = {
				type = "header",
				order = 30,
				name = "Bar System",
			},
			barInverseFill = {
				order = 31,
				type = "toggle",
				name = L["BarFillInverse"],
				desc = "Inverts the fill direction of this bar",
				disabled = DisabledFunc,
			},
			barOrientation = {
				type = 'select',
				order = 32,
				name = L["BarFillDirection"],
				desc = "How the bar should be filled. Vertical or Horizontal.",
				values = CD.SortBarOrientation,
				disabled = DisabledFunc,
			},
			barSmooth = {
				order = 34,
				type = 'toggle',
				name = L["SmoothBar"],
				desc = "Smoothes out the bar value transition at the cost of performance.",
				width = "full",
				disabled = DisabledFunc,
			},
		},
	}

	return config
end

local function GetAdvancedCastbarTextConfig(groupName, fontType, order)
	
	local DisabledFunc = function() return not CO.db.profile.unitframe.units[groupName].castbar.fonts[fontType].enable end
	
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
			disabled = DisabledFunc,
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
			disabled = DisabledFunc,
		},
		xOffset = {
			order = order + 12,
			type = 'range',
			name = L["XOffset"],
			desc = L["XOffset"],
			min = -300, max = 300, step = 1,
			disabled = DisabledFunc,
		},
		yOffset = {
			order = order + 13,
			type = 'range',
			name = L["YOffset"],
			desc = L["YOffset"],
			min = -300, max = 300, step = 1,
			disabled = DisabledFunc,
		},
		horizontalAlign = {
			name = L["HorizontalAlign"],
			type = "select",
			desc = "Sets the horizontal growth direction of this font. Left sets the growth to right. Right sets it to left. Just like in any text-processing program. To reposition the font, use the position dropdown. Is being affected by the font container width.",
			order = order + 14,
			-- style = "dropdown",
			values = CD.FontHorizontalAlign,
			disabled = DisabledFunc,
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
			disabled = DisabledFunc,
		},
		fontType = {
		  name = L["FontType"],
		  dialogControl = "LSM30_Font",
		  type = "select",
		  desc = L["FontType"],
		  order = order + 22,
		  values = CO.AceGUIWidgetLSMlists["font"],
		  disabled = DisabledFunc,
		},
		fontFlags = {
		  name = L["FontFlags"],
		  type = "select",
		  desc = L["FontFlags"],
		  order = order + 23,
		  values = CD.FontFlags,
		  disabled = DisabledFunc,
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
					UF.Modules["Castbar"]:LoadConfig()
			end,
			disabled = DisabledFunc,
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
				UF.Modules["Castbar"]:LoadConfig()
		  end,
		  disabled = DisabledFunc,
		},
		xFontShadowOffset = {
			order = order + 32,
			type = 'range',
			name = L["XOffset"],
			min = -10, max = 10, step = 1,
			disabled = DisabledFunc,
		},
		yFontShadowOffset = {
			order = order + 33,
			type = 'range',
			name = L["YOffset"],
			min = -10, max = 10, step = 1,
			disabled = DisabledFunc,
		},
	}
	
	return config
end

local function GetOptionsTable_CastBar(groupName)
	local Name = GetLabel(CategoryColors['CoreModules']:format(L["Castbar"]), IsGroupDisabled(groupName))
	
	local DisabledFunc = function() return not CO.db.profile.unitframe.units[groupName].castbar.enable end
	
	local config = {
		order = CategoryOrders.Castbar,
		type = 'group',
		name = Name,
		childGroups = "tab",
		get = function(info) return CO.db.profile.unitframe.units[groupName].castbar[ info[#info] ] end,
		set = function(info, value) CO.db.profile.unitframe.units[groupName].castbar[ info[#info] ] = value; UF.Modules["Castbar"]:LoadConfig() end,
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
					UF:PerformForUnits(groupName, UF.Modules["Castbar"].Toggle)
				end,
				disabled = DisabledFunc,
			},
			barSettings = {
				type = "group",
				order = 5,
				name = L["Bar"],
				disabled = DisabledFunc,
				args = {
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
						name = L["BarFillInverse"],
						desc = "Inverts the fill direction of this bar",
					},
					barOrientation = {
						type = 'select',
						order = 32,
						name = L["BarFillDirection"],
						desc = "How the bar should be filled. Vertical or Horizontal.",
						values = CD.SortBarOrientation,
					},
					showCastingTarget = {
						order = 33,
						type = "toggle",
						name = CD:GetNewFeatureString("Show Target Name"),
						desc = "When enabled, the name of the unit, the cast is going to affect, is being shown in the name text",
					},
					barStyle = {
						order = 40,
						type = "header",
						name = L["BarStyle"]
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
						min = 0, max = 20, step = 0.1,
						set = function(info, value)
							if value == 0 then
								value = 0.1
							end
							
							CO.db.profile.unitframe.units[groupName].castbar[ info[#info] ] = value; UF.Modules["Castbar"]:LoadConfig()
						end,
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
							UF.Modules["Castbar"]:LoadConfig()
						end,
					},
				},
			},
			iconSettings = {
				type = "group",
				order = 6,
				name = L["Icon"],
				disabled = DisabledFunc,
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
		for k,v in pairs(CD:GetMoverOptions(format("CUI_%sCastbar1Mover", groupName), 12, true, DisabledFunc)) do
			config.args.barSettings.args[k] = v
		end
	end
	local Fonts = {{Path = format("db.profile.unitframe.units.%s.castbar.fonts.time", groupName), Order = 100, GroupName = L["Time"]}, {Path = format("db.profile.unitframe.units.%s.castbar.fonts.name", groupName), Order = 200, GroupName = L["Name"]}}
	for k,v in pairs(CD:GetFontOptions(Fonts, DisabledFunc)) do
		config.args[k] = v
	end

	return config
end

local function GetOptionsTable_MaxLevel(groupName, tableType, disabledFunc)
	local doNotShowOnMaxLevel
	
	if tableType == "level" then
		doNotShowOnMaxLevel = {
			type = "toggle",
			order = 2,
			name = L["NotOnMaxlevel"],
			disabled = disabledFunc,
		}
	end
	
	return doNotShowOnMaxLevel
end



-- tableType such as "name", "level" or "power" . . . .
local function GetOptionsTable_Text(groupName, tableType)
	local Name = GetLabel(CategoryColors['Fonts']:format(L[E:firstToUpper(tableType)]), IsGroupDisabled(groupName))
	
	local DisabledFunc = function() return not CO.db.profile.unitframe.units[groupName].fonts[tableType].enable end
	
	local config = {
		order = CategoryOrders["Font_" .. tableType],
		type = 'group',
		name = Name,
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
				disabled = DisabledFunc,
			},
			height = {
				order = 3,
				type = 'range',
				name = L["Height"],
				desc = "Height of the font container. Used for vertical alignment. Leave at 0 if unsure",
				min = 0, max = 500, step = 1,
				disabled = DisabledFunc,
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
				disabled = DisabledFunc,
			},
			xOffset = {
				order = 32,
				type = 'range',
				name = L["XOffset"],
				min = -300, max = 300, step = 1,
				disabled = DisabledFunc,
			},
			yOffset = {
				order = 33,
				type = 'range',
				name = L["YOffset"],
				min = -300, max = 300, step = 1,
				disabled = DisabledFunc,
			},
			horizontalAlign = {
				name = L["HorizontalAlign"],
				type = "select",
				desc = L["HAlignFontDesc"],
				order = 34,
				-- style = "dropdown",
				values = CD.FontHorizontalAlign,
				disabled = DisabledFunc,
			},
			verticalAlign = {
				name = L["VerticalAlign"],
				type = "select",
				desc = L["VAlignFontDesc"],
				order = 34,
				-- style = "dropdown",
				values = CD.FontVerticalAlign,
				disabled = DisabledFunc,
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
				disabled = DisabledFunc,
			},
			fontType = {
			  name = L["FontType"],
			  dialogControl = "LSM30_Font",
			  type = "select",
			  order = 42,
			  values = CO.AceGUIWidgetLSMlists["font"],
			  disabled = DisabledFunc,
			},
			fontFlags = {
			  name = L["FontFlags"],
			  type = "select",
			  order = 43,
			  values = CD.FontFlags,
			  disabled = DisabledFunc,
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
				disabled = DisabledFunc,
			},
			textFormat = {
				order = 46,
				type = 'input',
				name = "Text-Format",
				desc = "A string of various format types for this font.\nPossible values:\n[health], [health-formatted], [health-max], [health-max-formatted], [health-pct], [health-missing], [health-missing-formatted], [health-missing-pct]\n\n[power], [power-formatted], [power-max], [power-max-formatted], [power-pct]\n\n[name], [level], [level-max], [level-except-max]\n\n[class], [raidgroup], [guild-name], [guild-rank-name]\n\n[newline]",
				width = "full",
				disabled = DisabledFunc,
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
			  disabled = DisabledFunc,
			},
			xFontShadowOffset = {
				order = 52,
				type = 'range',
				name = L["XOffset"],
				min = -10, max = 10, step = 1,
				disabled = DisabledFunc,
			},
			yFontShadowOffset = {
				order = 53,
				type = 'range',
				name = L["YOffset"],
				min = -10, max = 10, step = 1,
				disabled = DisabledFunc,
			},
			doNotShowOnMaxLevel = GetOptionsTable_MaxLevel(groupName, tableType, DisabledFunc),
		},
	}

	return config
end

local function GetOptionsTable_Portrait(groupName)
	local Name = GetLabel(CategoryColors['CoreModules']:format(L["Portrait"]), IsGroupDisabled(groupName))
	local DisabledFunc = function() return not CO.db.profile.unitframe.units[groupName].portrait.enable end
	local FloatingDisabledFunc = function() return DisabledFunc() or CO.db.profile.unitframe.units[groupName].portrait.overlay end

	local config = {
		order = CategoryOrders.Portrait,
		type = 'group',
		name = Name,
		get = function(info) return CO.db.profile.unitframe.units[groupName].portrait[ info[#info] ] end,
		set = function(info, value) CO.db.profile.unitframe.units[groupName].portrait[ info[#info] ] = value; UF.Modules["Portrait"]:LoadConfig(); UF.Modules["Health"]:LoadConfig(); end,
		args = {
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
				disabled = DisabledFunc,
			},
			styleHeader = {
				order = 5,
				type = "header",
				name = L["Style"],
			},
			style = {
				order = 6,
				name = "Style",
				type = "select",
				values = CD.PortraitStyles,
				disabled = DisabledFunc,
			},
			overlay = {
				order = 7,
				type = "toggle",
				name = "Overlay",
				desc = "Wether the portrait should overlay the Healthbar.",
				width = 0.5,
				disabled = DisabledFunc,
			},
			cutOff = {
				type = "toggle",
				order = 8,
				name = "Cutoff",
				desc = "Wether the portrait should be cutoff at the healthbar.\n\nNOTE: To make this fully work, the Healthbar Background should not be Transparent!",
				width = 0.5,
				disabled = DisabledFunc,
				hidden = function() return not (CO.db.profile.unitframe.units[groupName].portrait.overlay) end,
			},
			newline1 = {type = "description", name = "", order = 8.5},
			width = {
				order = 9,
				type = 'range',
				name = L["Width"],
				min = 5, max = 500, step = 1,
				disabled = FloatingDisabledFunc,
			},
			height = {
				order = 9.1,
				type = 'range',
				name = L["Height"],
				min = 5, max = 500, step = 1,
				disabled = FloatingDisabledFunc,
			},
			positionHeader = {
				order = 10,
				type = "header",
				name = L["Positioning"],
			},
			position = {
				type = 'select',
				order = 11,
				name = L["Position"],
				desc = "Attachment point of the aura frame",
				values = E.Positions,
				disabled = FloatingDisabledFunc,
			},
			offsetX = {
				order = 12,
				type = 'range',
				name = L["XOffset"],
				min = -500, max = 500, step = 1,
				disabled = FloatingDisabledFunc,
			},
			offsetY = {
				order = 13,
				type = 'range',
				name = L["YOffset"],
				min = -500, max = 500, step = 1,
				disabled = FloatingDisabledFunc,
			},
			cameraHeader = {
				order = 20,
				type = "header",
				name = L["Camera"],
			},
			zoom = {
				order = 21,
				type = 'range',
				name = "Portrait Zoom",
				desc = "Controls the focus multiplier by how focused the camera is on the units head",
				min = 0, max = 1, step = 0.01,
				disabled = DisabledFunc,
			},
			rotation = {
				order = 22,
				type = 'range',
				name = "Model Rotation",
				desc = "Controls the units rotation",
				min = 0, max = 10, step = 0.01,
				disabled = DisabledFunc,
			},
			camDistanceScale = {
				order = 23,
				type = 'range',
				name = "Camera Distance",
				desc = "Controls the distance between camera and unit",
				min = 0.01, max = 10, step = 0.01,
				disabled = DisabledFunc,
			},
		},
	}

	return config
end

local function GetOptionsTable_Auras(type, groupName)
	local Name = GetLabel(CategoryColors['Auras']:format(L[type]), IsGroupDisabled(groupName))
	
	local dbType = string.lower(type)
	local DisabledFunc = function() return not CO.db.profile.unitframe.units[groupName][dbType].enable end
	
	local config = {
		order = CategoryOrders[type],
		type = 'group',
		name = Name,
		childGroups = "tab",
		args = {
			iconGroup = {
				type = 'group',
				name = L["Icon"],
				order = 1,
				get = function(info) return CO.db.profile.unitframe.units[groupName][dbType][ info[#info] ] end,
				set = function(info, value) CO.db.profile.unitframe.units[groupName][dbType][ info[#info] ]  = value; UF.Modules["Auras"]:LoadConfig(groupName); end,
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
						disabled = DisabledFunc,
					},
					attachTo = {
						type = 'select',
						order = 3,
						name = "Attach To",
						values = CD.AuraAttachPoints,
						disabled = DisabledFunc,
					},
					newline1 = {type = "description", name = "", order = 5},
					sortBy = {
						order = 6,
						name = "Sort By",
						type = "select",
						values = CD.AuraSortMethods,
						disabled = DisabledFunc,
					},
					sortDirection = {
						order = 7,
						name = L["SortDirection"],
						type = "select",
						values = CD.AuraSortDirections,
						disabled = DisabledFunc,
					},
					newline2 = {type = "description", name = "", order = 10},
					offsetX = {
						order = 12,
						type = 'range',
						name = L["XOffset"],
						min = -500, max = 500, step = 0.1,
						disabled = DisabledFunc,
					},
					offsetY = {
						order = 13,
						type = 'range',
						name = L["YOffset"],
						min = -500, max = 500, step = 0.1,
						disabled = DisabledFunc,
					},
					newline3 = {type = "description", name = "", order = 20},
					gapX = {
						order = 21,
						type = 'range',
						name = L["Gap"] .. " X",
						min = -20, max = 20, step = 0.1,
						disabled = DisabledFunc,
					},
					gapY = {
						order = 21,
						type = 'range',
						name = L["Gap"] .. " Y",
						min = -20, max = 20, step = 0.1,
						disabled = DisabledFunc,
					},
					newline4 = {type = "description", name = "", order = 25},
					size = {
						order = 26,
						type = 'range',
						width = "full",
						name = "Slot Size",
						min = 4, max = 80, step = 0.1,
						disabled = DisabledFunc,
					},
					newline5 = {type = "description", name = "", order = 30},
					numPerRow = {
						order = 31,
						type = 'range',
						width = "double",
						name = "Per Row",
						min = 1, max = 20, step = 1,
						disabled = DisabledFunc,
					},
					maxWraps = {
						order = 32,
						type = 'range',
						name = "Max Wraps",
						min = 1, max = 20, step = 1,
						disabled = DisabledFunc,
					},
					newline6 = {type = "description", name = "", order = 35},
					clickThrough = {
						order = 37,
						type = 'toggle',
						name = 'Click Through',
						disabled = DisabledFunc,
					},
					alpha = {
						order = 38,
						type = 'range',
						width = "double",
						name = "Alpha",
						min = 0, max = 1, step = 0.01,
						disabled = DisabledFunc,
						get = function() return CO.db.profile.unitframe.units[groupName][dbType].alpha or 1 end,
					},
				},
			},
			conditionGroup = {
				type = 'group',
				name = L['Conditions'],
				order = 5,
				get = function(info) return CO.db.profile.unitframe.units[groupName][dbType][ info[#info] ] end,
				set = function(info, value) CO.db.profile.unitframe.units[groupName][dbType][ info[#info] ]  = value; UF.Modules["Auras"]:LoadConfig(groupName); end,
				disabled = DisabledFunc,
				args = {
					filterType = {
						order = 2,
						type = 'select',
						name = L['FilterType'],
						values = function() return FI:GetAvailableFilters() end,
						disabled = DisabledFunc,
					},
					minDuration = {
						order = 5,
						type = 'range',
						width = "double",
						name = "Min Duration To Show",
						desc = "What minimum duration (in seconds) an aura should have to show them",
						min = 0, max = 7200, step = 1,
						disabled = DisabledFunc,
					},
				},
			},
		},
	}
	
	local Fonts = {
		{Path = format("db.profile.unitframe.units.%s.%s.time", groupName, dbType), Order = 100, GroupName = L["Time"]}, 
		{Path = format("db.profile.unitframe.units.%s.%s.count", groupName, dbType), Order = 200, GroupName = L["Count"]}
	}
	for k,v in pairs(CD:GetFontOptions(Fonts, DisabledFunc)) do
		config.args[k] = v
	end
	
	return config
end

local function GetOptionsTable_AuraBars(groupName)
	local Name = GetLabel(CategoryColors['Auras']:format(L["Aura Bars"]), IsGroupDisabled(groupName))
	
	local DisabledFunc = function() return not CO.db.profile.auras.units[groupName].aurabars.enable end
	
	local config = {
		order = CategoryOrders.AuraBars,
		type = 'group',
		name = Name,
		get = function(info) return CO.db.profile.auras.units[groupName].aurabars[ info[#info] ] end,
		set = function(info, value) CO.db.profile.auras.units[groupName].aurabars[ info[#info] ]  = value; E:LoadModule("Bar_Auras"):LoadConfig() end,
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
							local BA = E:LoadModule("Bar_Auras")
							BA:ToggleBars(groupName)
						end,
						disabled = DisabledFunc,
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
					maxThreshold = {
						order = 34,
						type = 'range',
						name = "Max Duration",
						desc = "The maximum duration (in seconds) an aura is allowed to have to be displayed.\n\nNOTE: This only uses the maximum duration of an aura. It does not affect auras which at some point pass this value (ticking down)",
						min = 1, softMax = 600, max = 36000, step = 1,
						disabled = DisabledFunc,
					},
					barNum = {
						order = 35,
						type = 'range',
						name = L["Number of Bars"],
						min = 1, max = 30, step = 1,
						disabled = DisabledFunc,
					},
					width = {
						order = 36,
						type = 'range',
						name = L["Width"],
						min = 1, max = 750, step = 1,
						disabled = DisabledFunc,
					},
					height = {
						order = 37,
						type = 'range',
						name = L["Height"],
						min = 1, max = 125, step = 1,
						disabled = DisabledFunc,
					},
					gapY = {
						order = 38,
						type = 'range',
						name = "Gap Y",
						min = 0, max = 100, step = 1,
						disabled = DisabledFunc,
					},
					filterType = {
						order = 39,
						type = 'select',
						name = 'Filter Type',
						values = function() return FI:GetAvailableFilters() end,
						disabled = DisabledFunc,
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
						disabled = DisabledFunc,
					},
					newLine = {type="description", name="", order= 5},
					autoColorBarBorder = {
						order = 6,
						type = "toggle",
						name = "Auto Bar Border Color",
						disabled = DisabledFunc,
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
							
							E:LoadModule("Bar_Auras"):LoadConfig()
						end,
						disabled = function() return not CO.db.profile.auras.units[groupName].aurabars.enable or CO.db.profile.auras.units[groupName].aurabars.autoColorBarBorder end,
					},
					newLine2 = {type="description", name="", order= 10},
					autoColorIconBorder = {
						order = 11,
						type = "toggle",
						name = "Auto Icon Border Color",
						disabled = DisabledFunc,
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
							
							E:LoadModule("Bar_Auras"):LoadConfig()
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
							
							E:LoadModule("Bar_Auras"):LoadConfig()
						end,
						disabled = DisabledFunc,
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
	
	local Fonts = {
		{Path = "db.profile.auras.units." .. groupName .. ".aurabars.name", Order = 100, GroupName = L["Name"]},
		{Path = "db.profile.auras.units." .. groupName .. ".aurabars.time", Order = 200, GroupName = L["Time"]}
	}
	for k,v in pairs(CD:GetFontOptions(Fonts, DisabledFunc)) do
		config.args[k] = v
	end
	
	for k,v in pairs(CD:GetMoverOptions("AuraBarContainer" .. groupName .. "Mover", 21, true, DisabledFunc)) do
		config.args.barGroup.args[k] = v
	end
	
	
	
	return config
end

local function GetOptionsTable_Restingindicator()
	local Name = GetLabel(CategoryColors['Symbols']:format(L["RestingIndicator"]), IsGroupDisabled("player"))
	
	local DisabledFunc = function() return not CO.db.profile.unitframe.units.player.restingIndicator.enable end
	
	local config = {
		order = CategoryOrders.RestingIndicator,
		type = 'group',
		name = Name,
		get = function(info) return CO.db.profile.unitframe.units.player.restingIndicator[ info[#info] ] end,
		set = function(info, value) CO.db.profile.unitframe.units.player.restingIndicator[ info[#info] ]  = value; UF.Modules["RestingIndicator"]:LoadConfig(); end,
		args = {
			enable = {
				type = "toggle",
				order = 1,
				name = L["Enable"],
			},
			animMode = {
				type = "toggle",
				order = 1.1,
				name = "Use Animation",
				disabled = DisabledFunc,
			},
			newLine0 = {type="description", name="", order=1.5},
			position = {
				type = 'select',
				order = 2,
				name = L["Position"],
				values = E.Positions,
				disabled = DisabledFunc,
			},
			offsetX = {
				order = 3,
				type = 'range',
				name = L["XOffset"],
				min = -300, max = 300, step = 1,
				disabled = DisabledFunc,
			},
			offsetY = {
				order = 4,
				type = 'range',
				name = L["YOffset"],
				min = -300, max = 300, step = 1,
				disabled = DisabledFunc,
			},
			size = {
				order = 5,
				type = 'range',
				name = L["Size"],
				min = 1, max = 90, step = 1,
				disabled = DisabledFunc,
			},
		}
	}
	
	return config
end

local function GetOptionsTable_CombatIndicator()
	local Name = GetLabel(CategoryColors['Symbols']:format(L["Combat Indicator"]), IsGroupDisabled("player"))
	
	local DisabledFunc_Icon = function() return not CO.db.profile.unitframe.units.player.combatIndicator.enableIcon end
	local DisabledFunc_Glow = function() return not CO.db.profile.unitframe.units.player.combatIndicator.enableGlow end
	
	local config = {
		order = CategoryOrders.CombatIndicator,
		type = 'group',
		name = Name,
		get = function(info) return CO.db.profile.unitframe.units.player.combatIndicator[ info[#info] ] end,
		set = function(info, value) CO.db.profile.unitframe.units.player.combatIndicator[ info[#info] ]  = value; UF.Modules["CombatIndicator"]:LoadConfig() end,
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
				disabled = DisabledFunc_Icon,
			},
			iconOffsetX = {
				order = 13,
				type = 'range',
				name = L["XOffset"],
				min = -100, max = 100, step = 1,
				disabled = DisabledFunc_Icon,
			},
			iconOffsetY = {
				order = 14,
				type = 'range',
				name = L["YOffset"],
				min = -100, max = 100, step = 1,
				disabled = DisabledFunc_Icon,
			},
			iconSize = {
				order = 14,
				type = 'range',
				name = L["Size"],
				min = 0, max = 90, step = 1,
				disabled = DisabledFunc_Icon,
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
				disabled = DisabledFunc_Glow,
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

					UF.Modules["CombatIndicator"]:LoadConfig()
					end,
				disabled = DisabledFunc_Glow,
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
				disabled = DisabledFunc_Glow,
			},
			glowFadeOut = {
				order = 32,
				type = 'range',
				name = "Glow Fade Out",
				desc = "Time (in seconds) it takes the glow to fade out",
				min = 0, max = 15, step = 0.01,
				disabled = DisabledFunc_Glow,
			},
			newLine3 = {type="description", name="", order = 40},
			iconFadeIn = {
				order = 41,
				type = 'range',
				name = "Icon Fade In",
				desc = "Time (in seconds) it takes the icon to fade in",
				min = 0, max = 15, step = 0.01,
				disabled = DisabledFunc_Icon,
			},
			iconFadeOut = {
				order = 42,
				type = 'range',
				name = "Icon Fade Out",
				desc = "Time (in seconds) it takes the icon to fade out",
				min = 0, max = 15, step = 0.01,
				disabled = DisabledFunc_Icon,
			},
		},
	}
	
	return config
end

local function GetOptionsTable_ReadyCheck(groupName)
	local Name = GetLabel(CategoryColors['Symbols']:format(L["Ready Check"]), IsGroupDisabled(groupName))
	
	local DisabledFunc = function() return not CO.db.profile.unitframe.units[groupName].readyCheckIndicator.enable end
	
	local config = {
		order = CategoryOrders.ReadyCheckIndicator,
		type = 'group',
		name = Name,
		get = function(info) return CO.db.profile.unitframe.units[groupName].readyCheckIndicator[ info[#info] ] end,
		set = function(info, value) CO.db.profile.unitframe.units[groupName].readyCheckIndicator[ info[#info] ]  = value; UF.Modules["ReadyCheckIndicator"]:LoadConfig(); end,
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
				disabled = DisabledFunc,
			},
			colorOptions = {
				type = "execute",
				order = 4,
				name = L["Colors"],
				func = function() CD.ACD:SelectGroup("CUI", "colors", "readycheckGroup") end,
				disabled = DisabledFunc,
			},
			newLine1 = {type="description", name="", order = 10},
			position = {
				type = 'select',
				order = 11,
				name = L["Position"],
				desc = "Attachment point to the unitframe",
				values = E.Positions,
				disabled = DisabledFunc,
			},
			offsetX = {
				order = 12,
				type = 'range',
				name = L["XOffset"],
				min = -300, max = 300, step = 1,
				disabled = DisabledFunc,
			},
			offsetY = {
				order = 13,
				type = 'range',
				name = L["YOffset"],
				min = -300, max = 300, step = 1,
				disabled = DisabledFunc,
			},
			newLine2 = {type="description", name="", order = 20},
			size = {
				order = 21,
				type = 'range',
				name = "Size",
				min = 3, max = 90, step = 1,
				disabled = DisabledFunc,
			},
		},
	}
	
	return config
end

local function GetOptionsTable_SummonIndicator(groupName)
	local Name = GetLabel(CategoryColors['Symbols']:format(L["Summon Icon"]), IsGroupDisabled(groupName))
	
	local DisabledFunc = function() return not CO.db.profile.unitframe.units[groupName].summonIndicator.enable end
	
	local config = {
		order = CategoryOrders.SummonIndicator,
		type = 'group',
		name = Name,
		get = function(info) return CO.db.profile.unitframe.units[groupName].summonIndicator[ info[#info] ] end,
		set = function(info, value) CO.db.profile.unitframe.units[groupName].summonIndicator[ info[#info] ]  = value; UF.Modules["SummonIndicator"]:LoadConfig(); end,
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
				disabled = DisabledFunc,
			},
			newLine1 = {type="description", name="", order = 10},
			position = {
				type = 'select',
				order = 11,
				name = "Position",
				desc = "Attachment point to the unitframe",
				values = E.Positions,
				disabled = DisabledFunc,
			},
			offsetX = {
				order = 12,
				type = 'range',
				name = L["XOffset"],
				min = -300, max = 300, step = 1,
				disabled = DisabledFunc,
			},
			offsetY = {
				order = 13,
				type = 'range',
				name = L["YOffset"],
				min = -300, max = 300, step = 1,
				disabled = DisabledFunc,
			},
			newLine2 = {type="description", name="", order = 20},
			size = {
				order = 21,
				type = 'range',
				name = "Size",
				min = 3, max = 90, step = 1,
				disabled = DisabledFunc,
			},
		},
	}
	
	return config
end

local function GetOptionsTable_ResIndicator(groupName)
	local Name = GetLabel(CategoryColors['Symbols']:format(L["Res Indicator"]), IsGroupDisabled(groupName))
	
	local DisabledFunc = function() return not CO.db.profile.unitframe.units[groupName].resIndicator.enable end
	
	local config = {
		order = CategoryOrders.ResurrectIndicator,
		type = 'group',
		name = Name,
		get = function(info) return CO.db.profile.unitframe.units[groupName].resIndicator[ info[#info] ] end,
		set = function(info, value) CO.db.profile.unitframe.units[groupName].resIndicator[ info[#info] ]  = value; UF.Modules["ResurrectIndicator"]:LoadConfig(); end,
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
				disabled = DisabledFunc,
			},
			newLine1 = {type="description", name="", order = 10},
			position = {
				type = 'select',
				order = 11,
				name = "Position",
				desc = "Attachment point to the unitframe",
				values = E.Positions,
				disabled = DisabledFunc,
			},
			offsetX = {
				order = 12,
				type = 'range',
				name = L["XOffset"],
				min = -300, max = 300, step = 1,
				disabled = DisabledFunc,
			},
			offsetY = {
				order = 13,
				type = 'range',
				name = L["YOffset"],
				min = -300, max = 300, step = 1,
				disabled = DisabledFunc,
			},
			newLine2 = {type="description", name="", order = 20},
			size = {
				order = 21,
				type = 'range',
				name = "Size",
				min = 3, max = 90, step = 1,
				disabled = DisabledFunc,
			},
		},
	}
	
	return config
end

local function GetOptionsTable_RoleIcon(groupName)
	local Name = GetLabel(CategoryColors['Symbols']:format(L["Role Icon"]), IsGroupDisabled(groupName))
	
	local DisabledFunc = function() return not CO.db.profile.unitframe.units[groupName].roleIcon.enable end
	
	local config = {
		order = CategoryOrders.RoleIcon,
		type = 'group',
		name = Name,
		get = function(info) return CO.db.profile.unitframe.units[groupName].roleIcon[ info[#info] ] end,
		set = function(info, value) CO.db.profile.unitframe.units[groupName].roleIcon[ info[#info] ]  = value; UF.Modules["RoleIndicator"]:LoadConfig(); end,
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
				disabled = DisabledFunc,
			},
			newLine1 = {type="description", name="", order = 10},
			position = {
				type = 'select',
				order = 11,
				name = "Position",
				desc = "Attachment point to the unitframe",
				values = E.Positions,
				disabled = DisabledFunc,
			},
			offsetX = {
				order = 12,
				type = 'range',
				name = L["XOffset"],
				min = -300, max = 300, step = 1,
				disabled = DisabledFunc,
			},
			offsetY = {
				order = 13,
				type = 'range',
				name = L["YOffset"],
				min = -300, max = 300, step = 1,
				disabled = DisabledFunc,
			},
			newLine2 = {type="description", name="", order = 20},
			size = {
				order = 21,
				type = 'range',
				name = "Size",
				min = 3, max = 90, step = 1,
				disabled = DisabledFunc,
			},
		},
	}
	
	return config
end

local function GetOptionsTable_Leader(groupName)
	local Name = GetLabel(CategoryColors['Symbols']:format(L["Leader Icon"]), IsGroupDisabled(groupName))
	
	local DisabledFunc = function() return not CO.db.profile.unitframe.units[groupName].leaderIcon.enable end
	
	local config = {
		order = CategoryOrders.LeaderIcon,
		type = 'group',
		name = Name,
		get = function(info) return CO.db.profile.unitframe.units[groupName].leaderIcon[ info[#info] ] end,
		set = function(info, value) CO.db.profile.unitframe.units[groupName].leaderIcon[ info[#info] ]  = value; UF.Modules["LeaderIcon"]:LoadConfig() end,
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
				disabled = DisabledFunc,
			},
			newLine1 = {type="description", name="", order = 10},
			position = {
				type = 'select',
				order = 11,
				name = "Position",
				desc = "Attachment point to the unitframe",
				values = E.Positions,
				disabled = DisabledFunc,
			},
			offsetX = {
				order = 12,
				type = 'range',
				name = L["XOffset"],
				min = -300, max = 300, step = 1,
				disabled = DisabledFunc,
			},
			offsetY = {
				order = 13,
				type = 'range',
				name = L["YOffset"],
				min = -300, max = 300, step = 1,
				disabled = DisabledFunc,
			},
			newLine2 = {type="description", name="", order = 20},
			size = {
				order = 21,
				type = 'range',
				name = "Size",
				min = 3, max = 90, step = 1,
				disabled = DisabledFunc,
			},
		},
	}
	
	return config
end

local function GetOptionsTable_TargetIcon(groupName)
	local Name = GetLabel(CategoryColors['Symbols']:format(L["Target Icon"]), IsGroupDisabled(groupName))
	
	local DisabledFunc = function() return not CO.db.profile.unitframe.units[groupName].targetIcon.enable end
	
	local config = {
		order = CategoryOrders.TargetIcon,
		type = 'group',
		name = Name,
		get = function(info) return CO.db.profile.unitframe.units[groupName].targetIcon[ info[#info] ] end,
		set = function(info, value) CO.db.profile.unitframe.units[groupName].targetIcon[ info[#info] ]  = value; UF.Modules["TargetIcon"]:LoadConfig(); end,
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
				disabled = DisabledFunc,
			},
			newLine1 = {type="description", name="", order = 10},
			position = {
				type = 'select',
				order = 11,
				name = "Position",
				desc = "Attachment point to the unitframe",
				values = E.Positions,
				disabled = DisabledFunc,
			},
			offsetX = {
				order = 12,
				type = 'range',
				name = L["XOffset"],
				min = -300, max = 300, step = 1,
				disabled = DisabledFunc,
			},
			offsetY = {
				order = 13,
				type = 'range',
				name = L["YOffset"],
				min = -300, max = 300, step = 1,
				disabled = DisabledFunc,
			},
			newLine2 = {type="description", name="", order = 20},
			size = {
				order = 21,
				type = 'range',
				name = "Size",
				min = 3, max = 90, step = 1,
				disabled = DisabledFunc,
			},
		},
	}
	
	return config
end

local function GetOptionsTable_Absorption(groupName)
	local Name = GetLabel(CategoryColors['CoreModules']:format(L["Absorption"]), IsGroupDisabled(groupName))
	
	local DisabledFunc_Damage = function() return not CO.db.profile.unitframe.units[groupName].health.absorbs.damage.enable end
	local DisabledFunc_Healing = function() return not CO.db.profile.unitframe.units[groupName].health.absorbs.healing.enable end
	
	local config = {
		order = CategoryOrders.Absorption,
		type = 'group',
		name = Name,
		childGroups = 'tree',
		args = {
			damage = {
				type = 'group',
				name = 'Damage',
				get = function(info) return CO.db.profile.unitframe.units[groupName].health.absorbs.damage[ info[#info] ] end,
				set = function(info, value) CO.db.profile.unitframe.units[groupName].health.absorbs.damage[ info[#info] ]  = value; UF.Modules["HealthAbsorb"]:LoadConfig(); end,
				args = {
					enable = {
						type = "toggle",
						order = 2,
						name = L["Enable"],
					},
					newLine0 = {type="description", name="", order = 5},
					alpha = {
						type = 'range',
						order = 6,
						name = 'Alpha',
						min = 0, max = 1,
						disabled = DisabledFunc_Damage,
					},
					newLine1 = {type="description", name="", order = 10},
					useStripes = {
						type = "toggle",
						order = 11,
						name = L["UseStripes"],
						disabled = DisabledFunc_Damage,
					},
					textureSizeMultiplier = {
						type = 'range',
						order = 12,
						name = L["TextureSizeMultiplier"],
						desc = "Controls the final texture tiling",
						min = 0, max = 25,
						disabled = function() return DisabledFunc_Damage() or not CO.db.profile.unitframe.units[groupName].health.absorbs.damage.useStripes end,
					},
					newLine2 = {type="description", name="", order = 20},
					borderColor = {
						name = L["BorderColor"],
						type = "color",
						hasAlpha = true,
						order = 21,
						get = function(info)
								--print(index)
								local c = CO.db.profile.unitframe.units[groupName].health.absorbs.damage.borderColor
								return c[1], c[2], c[3], c[4]
						end,
						set = function(info, r, g, b, a)
							local c = CO.db.profile.unitframe.units[groupName].health.absorbs.damage.borderColor
							
							c[1], c[2], c[3], c[4] = r, g, b, a
							
							UF.Modules["HealthAbsorb"]:LoadConfig();
						end,
						disabled = DisabledFunc_Damage,
					},
					textureColor = {
						name = "Texture Color",
						type = "color",
						hasAlpha = true,
						order = 22,
						get = function(info)
								--print(index)
								local c = CO.db.profile.unitframe.units[groupName].health.absorbs.damage.textureColor
								return c[1], c[2], c[3], c[4]
						end,
						set = function(info, r, g, b, a)
							local c = CO.db.profile.unitframe.units[groupName].health.absorbs.damage.textureColor
							
							c[1], c[2], c[3], c[4] = r, g, b, a
							
							UF.Modules["HealthAbsorb"]:LoadConfig();
						end,
						disabled = DisabledFunc_Damage,
					},
				},
			},
			healing = {
				type = 'group',
				name = 'Healing',
				get = function(info) return CO.db.profile.unitframe.units[groupName].health.absorbs.healing[ info[#info] ] end,
				set = function(info, value) CO.db.profile.unitframe.units[groupName].health.absorbs.healing[ info[#info] ]  = value; UF.Modules["HealthAbsorb"]:LoadConfig(); end,
				args = {
					enable = {
						type = "toggle",
						order = 2,
						name = L["Enable"],
					},
					newLine0 = {type="description", name="", order = 5},
					alpha = {
						type = 'range',
						order = 6,
						name = 'Alpha',
						min = 0, max = 1,
						disabled = DisabledFunc_Healing,
					},
					newLine1 = {type="description", name="", order = 10},
					useStripes = {
						type = "toggle",
						order = 11,
						name = L["UseStripes"],
						disabled = DisabledFunc_Healing,
					},
					textureSizeMultiplier = {
						type = 'range',
						order = 12,
						name = L["TextureSizeMultiplier"],
						desc = "Controls the final texture tiling",
						min = 0, max = 25,
						disabled = function() return DisabledFunc_Healing() or not CO.db.profile.unitframe.units[groupName].health.absorbs.healing.useStripes end,
					},
					newLine2 = {type="description", name="", order = 20},
					borderColor = {
						name = L["BorderColor"],
						type = "color",
						hasAlpha = true,
						order = 21,
						get = function(info)
								--print(index)
								local c = CO.db.profile.unitframe.units[groupName].health.absorbs.healing.borderColor
								return c[1], c[2], c[3], c[4]
						end,
						set = function(info, r, g, b, a)
							local c = CO.db.profile.unitframe.units[groupName].health.absorbs.healing.borderColor
							
							c[1], c[2], c[3], c[4] = r, g, b, a
							
							UF.Modules["HealthAbsorb"]:LoadConfig();
						end,
						disabled = DisabledFunc_Healing,
					},
					textureColor = {
						name = "Texture Color",
						type = "color",
						hasAlpha = true,
						order = 22,
						get = function(info)
								--print(index)
								local c = CO.db.profile.unitframe.units[groupName].health.absorbs.healing.textureColor
								return c[1], c[2], c[3], c[4]
						end,
						set = function(info, r, g, b, a)
							local c = CO.db.profile.unitframe.units[groupName].health.absorbs.healing.textureColor
							
							c[1], c[2], c[3], c[4] = r, g, b, a
							
							UF.Modules["HealthAbsorb"]:LoadConfig();
						end,
						disabled = DisabledFunc_Healing,
					},
				},
			},
			
		},
	}
	
	return config
end

local function GetOptionsTable_ClassPower(groupName)
	local Name = GetLabel(CategoryColors['CoreModules']:format(L["Alternate Power"]), IsGroupDisabled(groupName))
	
	local config = {
		order = CategoryOrders.ClassPower,
		type = 'group',
		name = Name,
		childGroups = "tab",
		args = {
			Bars = {
				order = 1,
				type = 'group',
				name = L["Bars"],
				get = function(info) return CO.db.profile.unitframe.units[groupName].alternatePower[ info[#info] ] end,
				set = function(info, value) CO.db.profile.unitframe.units[groupName].alternatePower[ info[#info] ] = value; E:LoadModule("Classpower"):LoadConfig() end,
				args = {
					-- Position will be filled in by for loop below
					header = {
						order = 10,
						type = "header",
						name = L["Size"],
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
					segmentConfig = {
						type = "group",
						order = 30,
						name = "Segments",
						guiInline = true,
						args = {
							gap = {
								order = 1,
								type = 'range',
								name = L["Gap"],
								min = 0, max = 50, step = 0.1,
							},
							reverseFill = {
								order = 2,
								type = "toggle",
								name = L["BarFillInverse"],
								desc = "Inverts the Fill Direction",
							},
							fillOrientation = {
								type = 'select',
								order = 3,
								name = L["BarFillDirection"],
								desc = "How the individual bars should be filled. Vertical or Horizontal.",
								values = CD.SortBarOrientation,
							},
							barTexture = {
								type = "select", dialogControl = 'LSM30_Statusbar',
								order = 4,
								name = L["BarTexture"],
								desc = "Main statusbar texture.",
								values = CO.AceGUIWidgetLSMlists["statusbar"],
							},
							newline = {type='description', name='', order=10},
							backgroundColor = {
								name = L["BackgroundColor"],
								type = "color",
								hasAlpha = true,
								order = 11,
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
							borderColor = {
								name = L["BorderColor"],
								type = "color",
								hasAlpha = true,
								order = 12,
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
								order = 13,
								type = 'range',
								name = L["BorderSize"],
								desc = L["BorderSize"],
								min = 0, max = 20, step = 0.1,
								set = function(info, value)
									if value == 0 then
										value = 0.1
									end
									
									CO.db.profile.unitframe.units[groupName].alternatePower[ info[#info] ] = value; E:LoadModule("Classpower"):LoadConfig()
								end,
							},
						},
					},
				},
			},
			Background = {
				order = 2,
				type = 'group',
				name = L["Background"],
				get = function(info) return CO.db.profile.unitframe.units[groupName].alternatePower.artFill[ info[#info] ] end,
				set = function(info, value) CO.db.profile.unitframe.units[groupName].alternatePower.artFill[ info[#info] ] = value; E:LoadModule("Classpower"):LoadConfig() end,
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
						disabled = function() return not CO.db.profile.unitframe.units[groupName].alternatePower.artFill.enable end,
					},
					paddingY = {
						order = 12,
						type = 'range',
						name = L["PaddingV"],
						desc = L["PaddingVDesc"],
						min = 0, max = 50, step = 1,
						disabled = function() return not CO.db.profile.unitframe.units[groupName].alternatePower.artFill.enable end,
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
							
							CO.db.profile.unitframe.units[groupName].alternatePower.artFill[ info[#info] ] = value; E:LoadModule("Classpower"):LoadConfig()
						end,
						disabled = function() return not CO.db.profile.unitframe.units[groupName].alternatePower.artFill.enable end,
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
							local c = CO.db.profile.unitframe.units[groupName].alternatePower.artFill.borderColor
							return c[1], c[2], c[3], c[4]
						end,
						set = function(info, r, g, b, a)
							local c = CO.db.profile.unitframe.units[groupName].alternatePower.artFill.borderColor
							c[1], c[2], c[3], c[4] = r, g, b, a
							E:LoadModule("Classpower"):LoadConfig();
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
							E:LoadModule("Classpower"):LoadConfig();
						end,
						disabled = function() return not CO.db.profile.unitframe.units[groupName].alternatePower.artFill.enable end,
					},
				},
			},
			Data = {
				order = 3,
				type = 'group',
				name = L["ClassSpecific"],
				get = function(info) return CO.db.profile.unitframe.units[groupName].alternatePower.data[ info[#info] ] end,
				set = function(info, value) CO.db.profile.unitframe.units[groupName].alternatePower.data[ info[#info] ] = value; E:LoadModule("Classpower"):LoadConfig() end,
				args = {
					SpecBasedSettings_Select = {
						name = SPECIALIZATION,
						type = 'select',
						order = 5,
						values = function(self)
							local IconSet = E:GetAllSpecInfo()
							local SpecData
							local SpecID
							local Values = {}
							
							for ClassIndex = 1, #IconSet do
								for SpecIndex = 1, #IconSet[ClassIndex] do
									SpecID = IconSet[ClassIndex][SpecIndex].SpecID
									if E:TableContainsValue(SupportedClassSpecifics, SpecID) then
										SpecData = IconSet[ClassIndex][SpecIndex]
										
										Values[SpecID] = '|T' .. (SupportedClassSpecifics_IconOverride[SpecID] or SpecData.IconID or 'error') .. ':0|t ' .. E:GetClassColorizedText(SupportedClassSpecifics_NameOverride[SpecID] or SpecData.SpecName, ClassIndex)
									end
								end
							end
							
							return Values
						end,
						get = function() return SelectedSpec end,
						set = function(info, value) SelectedSpec = value; --[[print(SelectedSpec)]] end,
					},
					newLine_1 = CD:GetNewLine(7),
					BREWMASTER_StaggerMax = {
						order = 10,
						type = 'range',
						name = "Maximum Stagger Percentage",
						desc = "Controls the maximum value of the stagger bar for Brewmaster Monks.\nThe value is a percentage of the Monks Maximum HP.\nDefault: 60%",
						min = 1, max = 100, step = 1,
						hidden = function() return not (SelectedSpec == E.SpecializationIDs.MONK.BREWMASTER) end,
					},
					DEATHKNIGHT_InverseCooldown = {
						order = 11,
						type = 'toggle',
						name = "Inverse Rune Cooldown",
						hidden = function() return not (SelectedSpec == E.SpecializationIDs.DEATHKNIGHT.BLOOD or SelectedSpec == E.SpecializationIDs.DEATHKNIGHT.FROST or SelectedSpec == E.SpecializationIDs.DEATHKNIGHT.UNHOLY) end,
					},
					DEATHKNIGHT_ColorBySpec = {
						order = 12,
						type = 'toggle',
						name = "Rune Color By Spec",
						hidden = function() return not (SelectedSpec == E.SpecializationIDs.DEATHKNIGHT.BLOOD or SelectedSpec == E.SpecializationIDs.DEATHKNIGHT.FROST or SelectedSpec == E.SpecializationIDs.DEATHKNIGHT.UNHOLY) end,
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

function Module:Disable()
	CD.Options.args.unitframe = nil
end

function Module:Enable()
	local GLOBAL_DISABLEDFUNC = function() return not CO.db.char.unitframe.enable end
	
	CD.Options.args.unitframe = {
		name = L["Unitframes"],
		type = 'group',
		order = 99999,
		disabled = false,
		args = {
			select_01 = {
				type = "execute",
				order = 5,
				name = L["All"],
				func = function() CD.ACD:SelectGroup("CUI", "unitframe", "all") end,
				--disabled = GLOBAL_DISABLEDFUNC,
			},
			newline = {type='description', name='', order=6},
			select_02 = {
				type = "execute",
				order = 10,
				name = L["Player"],
				func = function() CD.ACD:SelectGroup("CUI", "unitframe", "player") end,
				disabled = GLOBAL_DISABLEDFUNC,
			},
			select_03 = {
				type = "execute",
				order = 15,
				name = L["Pet"],
				func = function() CD.ACD:SelectGroup("CUI", "unitframe", "pet") end,
				disabled = GLOBAL_DISABLEDFUNC,
			},
			newline2 = {type='description', name='', order=16},
			select_04 = {
				type = "execute",
				order = 20,
				name = L["Target"],
				func = function() CD.ACD:SelectGroup("CUI", "unitframe", "target") end,
				disabled = GLOBAL_DISABLEDFUNC,
			},
			select_05 = {
				type = "execute",
				order = 25,
				name = L["TargetTarget"],
				func = function() CD.ACD:SelectGroup("CUI", "unitframe", "targettarget") end,
				disabled = GLOBAL_DISABLEDFUNC,
			},
			newline3 = {type='description', name='', order=26},
			select_06 = {
				type = "execute",
				order = 30,
				name = L["Focus"],
				func = function() CD.ACD:SelectGroup("CUI", "unitframe", "focus") end,
				disabled = GLOBAL_DISABLEDFUNC,
			},
			select_07 = {
				type = "execute",
				order = 35,
				name = L["FocusTarget"],
				func = function() CD.ACD:SelectGroup("CUI", "unitframe", "focustarget") end,
				disabled = GLOBAL_DISABLEDFUNC,
			},
			newline4 = {type='description', name='', order=36},
			select_08 = {
				type = "execute",
				order = 40,
				name = L["Arena"],
				func = function() CD.ACD:SelectGroup("CUI", "unitframe", "arena") end,
				disabled = GLOBAL_DISABLEDFUNC,
			},
			select_09 = {
				type = "execute",
				order = 45,
				name = L["Party"],
				func = function() CD.ACD:SelectGroup("CUI", "unitframe", "party") end,
				disabled = GLOBAL_DISABLEDFUNC,
			},
			newline5 = {type='description', name='', order=46},
			select_10 = {
				type = "execute",
				order = 50,
				name = L["Raid"],
				func = function() CD.ACD:SelectGroup("CUI", "unitframe", "raid") end,
				disabled = GLOBAL_DISABLEDFUNC,
			},
			select_11 = {
				type = "execute",
				order = 55,
				name = L["Raid40"],
				func = function() CD.ACD:SelectGroup("CUI", "unitframe", "raid40") end,
				disabled = GLOBAL_DISABLEDFUNC,
			},
			newline6 = {type='description', name='', order=56},
			select_12 = {
				type = "execute",
				order = 60,
				name = L["Boss"],
				func = function() CD.ACD:SelectGroup("CUI", "unitframe", "boss") end,
				disabled = GLOBAL_DISABLEDFUNC,
			},
		},
	}

	CD.Options.args.unitframe.args.all = {
		name = "|cffF2A72E" .. L["All"] .. "|r",
		type = 'group',
		order = 0,
		childGroups = "tab",
		disabled = false,
		args = {
			enable = {
				type = 'toggle',
				order = 0.1,
				name = L['EnableModule'],
				desc = 'Controls the state of the unitframe module. When disabled, you\'re just left with Blizzard unitframes and their textures etc.\n\nOn The upside, you then can use alternate unitframe AddOns to handle it all.\n\nRequires a reload after enabling/disabling to take effect.\n\nThis is a character setting and is not being saved in your profile!',
				get = function(info) return CO.db.char.unitframe.enable end,
				set = function(info, value) CO.db.char.unitframe.enable = value; CD:ShowNotification('CHARACTERSETTING_NOTIFICATION') end,
			},
			generalGroup = {
				type = "group",
				order = 1,
				name = L["General"],
				disabled = GLOBAL_DISABLEDFUNC,
				args = {
					header = {
						order = 1,
						type = "header",
						name = "Dummy Mode",
					},
					partyDummy = {
						order = 2,
						type = "execute",
						name = L["Enable"],
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
					-- dummyShowAuras = {
						-- order = 4,
						-- type = "toggle",
						-- name = "Show Dummy Auras",
						-- hidden = true,
						-- get = function()
							-- return CO.db.profile.unitframe.dummyShowAuras
						-- end,
						-- set = function(info, value)
							-- CO.db.profile.unitframe.dummyShowAuras = value
							
							-- ToggleAuras(value)
						-- end,
					-- },
					newline = {type='description', name='', order=5},
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
				disabled = GLOBAL_DISABLEDFUNC,
				args = {
					rangeHeader = {
						order = 30,
						type = "header",
						name = L["RangeIndicator"],
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
						set = function(info, value) CO.db.profile.unitframe.units.all.highlight.enable = value; UF.Modules["Highlight"]:LoadConfig(); end,
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
							
							UF.Modules["Highlight"]:LoadConfig();
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
							UF.Modules["Highlight"]:LoadConfig();
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
						set = function(info, value) CO.db.profile.unitframe.units.all.highlight.fadeTime = value; UF.Modules["Highlight"]:LoadConfig(); end,
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
						set = function(info, value) CO.db.profile.unitframe.units.all.targetHighlight.enable = value; UF.Modules["TargetHighlight"]:LoadConfig(); end,
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
							
							UF.Modules["TargetHighlight"]:LoadConfig();
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
						set = function(info, value) CO.db.profile.unitframe.units.all.targetHighlight.fadeTime = value; UF.Modules["TargetHighlight"]:LoadConfig(); end,
						disabled = function() return not CO.db.profile.unitframe.units.all.targetHighlight.enable end,
					},
					targetBorderSize = {
						order = 64,
						name = "Border Size",
						desc = "Size of the border around a units healthbar",
						type = "range",
						min = -3, max = 3, step = 0.1,
						get = function() return CO.db.profile.unitframe.units.all.targetHighlight.borderSize end,
						set = function(info, value) 
							
							if value == 0 then
								value = 0.1
							end
							
							CO.db.profile.unitframe.units.all.targetHighlight.borderSize = value; UF.Modules["TargetHighlight"]:LoadConfig(); end,
						disabled = function() return not CO.db.profile.unitframe.units.all.targetHighlight.enable end,
					},
					targetSoundHeader = {
						order = 70,
						type = "header",
						name = "Sounds",
					},
					targetSoundEnable = {
						order = 71,
						type = "toggle",
						name = "Target Sounds",
						width = 2.5,
						desc = "When enabled, sounds will be played when you select a target, or lose it. Just like in the vanilla UI!",
						get = function(info) return CO.db.profile.unitframe.units.all.targetSounds.enable end,
						set = function(info, value) CO.db.profile.unitframe.units.all.targetSounds.enable = value; UF.Modules["TargetSounds"]:LoadConfig(); end,
					},
					detailedSelect = {
						order = 80,
						type = "select",
						name = "Situation",
						values = SOUNDSELECT_SITUATIONS,
						get = function(info) return SOUNDSELECT_SITUATIONS_SELECTED end,
						set = function(info, value) SOUNDSELECT_SITUATIONS_SELECTED = value end,
						hidden = function() return not CO.db.profile.unitframe.units.all.targetSounds.enable end,
					},
					detailedGroup = {
						order = 99,
						type = "group",
						guiInline = true,
						name = "Situations",
						args = {
							customPath = {
								order = 1,
								type = "input",
								name = "Custom Path",
								width = 2.5,
								desc = "Path of the sound to use for this situation. Can be a Soundkit-ID, or a path to a custom sound",
								get = function(info) return tostring(CO.db.profile.unitframe.units.all.targetSounds.situations[SOUNDSELECT_SITUATIONS_SELECTED]) end,
								set = function(info, value) CO.db.profile.unitframe.units.all.targetSounds.situations[SOUNDSELECT_SITUATIONS_SELECTED] = value end,
							},
							test = {
								order = 80,
								type = "execute",
								name = "Test Sound",
								silentClick = true,
								func = function()
									local DB = CO.db.profile.unitframe.units.all.targetSounds.situations[SOUNDSELECT_SITUATIONS_SELECTED]
									PlaySound(tonumber(DB) or DB)
								end,
							},
							newLine1 = {type="description", name="", order = 90},
							reset = {
								order = 99,
								type = "execute",
								name = "Reset to Default",
								func = function()
									CO.db.profile.unitframe.units.all.targetSounds.situations[SOUNDSELECT_SITUATIONS_SELECTED] = E.ConfigDefaults.profile.unitframe.units.all.targetSounds.situations[SOUNDSELECT_SITUATIONS_SELECTED]
								end,
							},
						},
						hidden = function() return not CO.db.profile.unitframe.units.all.targetSounds.enable or not SOUNDSELECT_SITUATIONS_SELECTED end,
					},
				}
			},
			healthGroup = {
				type = "group",
				order = 3,
				name = L["Health"],
				disabled = GLOBAL_DISABLEDFUNC,
				args = {
					colorByValue = {
						order = 1,
						type = "toggle",
						name = L["Color By Value"],
						get = function(info) return CO.db.profile.unitframe.units.all.health[ info[#info] ] end,
						set = function(info, value) CO.db.profile.unitframe.units.all.health[ info[#info] ] = value; UF.Modules["Health"]:LoadConfig(); UF:UpdateAllUF(); end,
					},
				}
			},
			absorbGroup = {
				type = "group",
				order = 3.1,
				name = L["Absorption"],
				disabled = GLOBAL_DISABLEDFUNC,
				args = {
					desc = {
						type = "description",
						order = 0.5,
						name = "|cffF2A72E" .. L["GlobalAbsorb_Desc"] .. "|r",
					},
					enableAbsorb = {
						order = 1,
						type = "toggle",
						name = L["Enable"],
						get = function(info) return GlobalAbsorb_Data.enableAbsorb end,
						set = function(info, value) GlobalAbsorb_Data.enableAbsorb = value; end,
					},
					newLine1 = {type="description", name="", order = 10},
					absorbUseStripes = {
						type = "toggle",
						order = 11,
						name = L["UseStripes"],
						disabled = function() return not GlobalAbsorb_Data.enableAbsorb end,
						get = function(info) return GlobalAbsorb_Data.absorbUseStripes end,
						set = function(info, value) GlobalAbsorb_Data.absorbUseStripes = value; end,
					},
					absorbTextureSizeMultiplier = {
						type = 'range',
						order = 12,
						name = L["TextureSizeMultiplier"],
						desc = "Controls the final texture tiling",
						min = 0, max = 25,
						get = function(info) return GlobalAbsorb_Data.absorbTextureSizeMultiplier end,
						set = function(info, value) GlobalAbsorb_Data.absorbTextureSizeMultiplier = value; end,
						disabled = function() return not GlobalAbsorb_Data.enableAbsorb or not GlobalAbsorb_Data.absorbUseStripes end,
					},
					newLine2 = {type="description", name="", order = 20},
					absorbBorderColor = {
						name = L["BorderColor"],
						type = "color",
						hasAlpha = true,
						order = 21,
						get = function(info)
								--print(index)
								local c = GlobalAbsorb_Data.absorbBorderColor or {1, 1, 1, 1}
								return c[1], c[2], c[3], c[4]
						end,
						set = function(info, r, g, b, a)
							if not GlobalAbsorb_Data.absorbBorderColor then
								GlobalAbsorb_Data.absorbBorderColor = {1,1,1,1}
							end
							local c = GlobalAbsorb_Data.absorbBorderColor
							
							c[1], c[2], c[3], c[4] = r, g, b, a
						end,
						disabled = function() return not GlobalAbsorb_Data.enableAbsorb end,
					},
					absorbTextureColor = {
						name = "Texture Color",
						type = "color",
						hasAlpha = true,
						order = 22,
						get = function(info)
								--print(index)
								local c = GlobalAbsorb_Data.absorbTextureColor or {1, 1, 1, 1}
								return c[1], c[2], c[3], c[4]
						end,
						set = function(info, r, g, b, a)
							if not GlobalAbsorb_Data.absorbTextureColor then
								GlobalAbsorb_Data.absorbTextureColor = {1,1,1,1}
							end
							local c = GlobalAbsorb_Data.absorbTextureColor
							
							c[1], c[2], c[3], c[4] = r, g, b, a
						end,
						disabled = function() return not GlobalAbsorb_Data.enableAbsorb end,
					},
					newLine3 = {type="description", name="", order = 25},
					apply = {
						order = 26,
						type = 'execute',
						name = L["ApplyChanges"],
						desc = 'Apply the changes you just made',
						func = function() GlobalAbsorb_Update(); end,
					},
				}
			},
			auraGroup = {
				type = "group",
				order = 4,
				name = L["Auras"],
				disabled = GLOBAL_DISABLEDFUNC,
				args = {
					BorderDescription = {
						type = "description",
						order = 1,
						name = "|cffF2A72EChoose how the default border color should be defined|r",
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
					newLine2 = {type = "description", order = 10, name = ""},
					desaturateOtherDebuffs = {
						type = "toggle",
						order = 11,
						name = L["DesaturateOtherDebuffs"],
						desc = L["DesaturateOtherDebuffsDesc"],
						get = function() return CO.db.profile.unitframe.desaturateOtherDebuffs end,
						set = function(info, value) CO.db.profile.unitframe.desaturateOtherDebuffs = value; UF.Modules["Auras"]:UpdateAll(); end,
					},
					preventOthersDebuffs = {
						type = "toggle",
						order = 12,
						name = L["PreventOthersDebuffs"],
						desc = L["PreventOthersDebuffsDesc"],
						get = function() return CO.db.profile.unitframe.preventOthersDebuffs end,
						set = function(info, value) CO.db.profile.unitframe.preventOthersDebuffs = value; UF.Modules["Auras"]:LoadConfig(); end,
					},
					allowGroupDebuffs = {
						type = "toggle",
						order = 13,
						name = L["AllowGroupDebuffs"],
						desc = L["AllowGroupDebuffsDesc"],
						get = function() return CO.db.profile.unitframe.allowGroupDebuffs end,
						set = function(info, value) CO.db.profile.unitframe.allowGroupDebuffs = value; UF.Modules["Auras"]:LoadConfig(); end,
						hidden = function() return not CO.db.profile.unitframe.preventOthersDebuffs end,
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
						get = function() return CO.db.char.unitframe.unitBuffs.useMasque end,
						set = function(info, value) CO.db.char.unitframe.unitBuffs.useMasque = value; CD:ShowNotification("CHARACTERSETTING_NOTIFICATION") end,
					},
					useMasqueDebuffs = {
						type = "toggle",
						order = 17,
						name = L["Debuffs"],
						desc = L["UseMasqueDesc"],
						get = function() return CO.db.char.unitframe.unitDebuffs.useMasque end,
						set = function(info, value) CO.db.char.unitframe.unitDebuffs.useMasque = value; CD:ShowNotification("CHARACTERSETTING_NOTIFICATION") end,
					},
					useMasqueAurabars = {
						type = "toggle",
						order = 18,
						name = L["Aura Bars"],
						desc = L["UseMasqueDesc"],
						get = function() return CO.db.char.auras.generalAurabars.useMasque end,
						set = function(info, value) CO.db.char.auras.generalAurabars.useMasque = value; CD:ShowNotification("CHARACTERSETTING_NOTIFICATION") end,
					},
					
				}
			},
			castbarGroup = {
				type = "group",
				order = 5,
				name = CD:GetNewFeatureString(L["Castbar"]),
				disabled = GLOBAL_DISABLEDFUNC,
				args = {
					flashSize = {
						order = 54,
						name = "Flash Size",
						desc = "Size of the Flash that is being displayed at the end of a cast. Set to 0 to effectively disable it",
						type = "range",
						min = 0, max = 20, step = 0.5,
						get = function() return CO.db.profile.unitframe.units.all.castbar.flashSize end,
						set = function(info, value) CO.db.profile.unitframe.units.all.castbar.flashSize = value; E:LoadModule('Castbar'):LoadConfig(); end,
					},
					flashFadeInTime = {
						order = 54.1,
						name = "Flash Fade In Time",
						desc = "Default: 0.05",
						type = "range",
						min = 0, max = 1, step = 0.01,
						get = function() return CO.db.profile.unitframe.units.all.castbar.flashFadeInTime end,
						set = function(info, value) CO.db.profile.unitframe.units.all.castbar.flashFadeInTime = value; E:LoadModule('Castbar'):LoadConfig(); end,
					},
					flashFadeOutTime = {
						order = 54.2,
						name = "Flash Fade Out Time",
						desc = "Default: 0.35",
						type = "range",
						min = 0, max = 1, step = 0.01,
						get = function() return CO.db.profile.unitframe.units.all.castbar.flashFadeOutTime end,
						set = function(info, value) CO.db.profile.unitframe.units.all.castbar.flashFadeOutTime = value; E:LoadModule('Castbar'):LoadConfig(); end,
					},
					showCastingTarget = {
						order = 55,
						type = "toggle",
						name = CD:GetNewFeatureString("Show Target Name"),
						desc = "When enabled, the name of the unit, the cast is going to affect, is being shown in the name text.\n\nNOTE: This option also is available for each individual castbar!",
						get = function() return All_showCastingTarget end,
						set = function(info, value)
							All_showCastingTarget = value
							
							for k,v in pairs(CO.db.profile.unitframe.units) do
								if v.castbar then
									v.castbar.showCastingTarget = value
								end
							end
							
							E:LoadModule('Castbar'):LoadConfig()
						end,
					},
				},
			},
			fontGroup = {
				type = "group",
				order = 6,
				name = L["Font"],
				disabled = GLOBAL_DISABLEDFUNC,
				args = {
					desc = {
						type = "description",
						order = 0.1,
						name = "|cffF2A72EThis section allows you to configure the font module for ALL selected unitframes at ONCE.\nTo make a change, a setting has to be changed at least once to take effect when you click the apply button!|r",
					},
					units = {
						order = 0.25,
						guiInline = true,
						type = "group",
						name = "Units",
						args = {
							ALL = {
								type = "execute",
								order = 9998,
								name = "All",
								func = function()
									for unit, _ in ipairs(UF.Frames) do
										OverrideFonts_EnabledUnits[unit] = true
									end
								end
							},
							NONE = {
								type = "execute",
								order = 9999,
								name = "None",
								func = function()
									wipe(OverrideFonts_EnabledUnits)
								end
							},
						},
					},
					enableHeight = {
						order = 0.5,
						type = 'execute',
						name = 'Enable Height',
						desc = 'Enables the global font type override. Use with caution!',
						func = function()
							OverrideFont_EnableHeight = not OverrideFont_EnableHeight;
							CD.Options.args.unitframe.args.all.args.fontGroup.args.enableHeight.name = OverrideFont_EnableHeight and "Disable Height" or "Enable Height"
						end,
						-- hidden = function() return OverrideFont_EnableHeight end,
					},
					fontHeight = {
						order = 1,
						type = 'range',
						name = L["FontHeight"],
						desc = L["FontHeight"],
						min = 3, max = 40, step = 1,
						get = function() return OverrideFont_Height end,
						set = function(info, value) OverrideFont_Height = value; end,
						disabled = function() return not OverrideFont_EnableHeight end,
					},
					newline1 = {type='description',name='',order=5},
					enableType = {
						order = 6,
						type = 'execute',
						name = 'Enable Font Type',
						desc = 'Enables the global font type override. Use with caution!',
						func = function()
							OverrideFont_EnableType = not OverrideFont_EnableType;
							CD.Options.args.unitframe.args.all.args.fontGroup.args.enableType.name = OverrideFont_EnableType and "Disable Font Type" or "Enable Font Type"
						end,
						-- hidden = function() return OverrideFont_EnableType end,
					},
					fontType = {
					  name = L["FontType"],
					  dialogControl = "LSM30_Font",
					  type = "select",
					  desc = L["FontType"],
					  order = 7,
					  values = CO.AceGUIWidgetLSMlists["font"],
					  get = function() return OverrideFont_Type end,
					  set = function(info, value) OverrideFont_Type = value; end,
					  disabled = function() return not OverrideFont_EnableType end,
					},
					newline2 = {type='description',name='',order=10},
					enableFlags = {
						order = 11,
						type = 'execute',
						name = 'Enable Flags',
						desc = 'Enables the global font flags override. Use with caution!',
						func = function()
						OverrideFont_EnableFlags = not OverrideFont_EnableFlags;
							CD.Options.args.unitframe.args.all.args.fontGroup.args.enableFlags.name = OverrideFont_EnableFlags and "Disable Flags"
							or "Enable Flags"
						end,
						-- hidden = function() return OverrideFont_EnableFlags end,
					},
					fontFlags = {
					  name = L["FontFlags"],
					  type = "select",
					  desc = L["FontFlags"],
					  order = 12,
					  values = CD.FontFlags,
					  get = function() return OverrideFont_Flags end,
					  set = function(info, value) OverrideFont_Flags = value; end,
					  disabled = function() return not OverrideFont_EnableFlags end,
					},
					newline3 = {type='description',name='',order=15},
					enableShadow = {
						order = 16,
						type = 'execute',
						name = 'Enable Shadow',
						desc = 'Enables the global font flags override. Use with caution!',
						func = function()
							OverrideFont_EnableShadow = not OverrideFont_EnableShadow;
							CD.Options.args.unitframe.args.all.args.fontGroup.args.enableShadow.name = OverrideFont_EnableShadow and "Disable Shadow" or "Enable Shadow"
						end,
						-- hidden = function() return OverrideFont_EnableShadow end,
					},
					shadowColor = {
						name = L["TextShadowColor"],
						type = "color",
						order = 17,
						get = function()
							if not OverrideFont_ShadowColor then
								OverrideFont_ShadowColor = {0,0,0,1}
							end
							local c = OverrideFont_ShadowColor
							return c[1], c[2], c[3], c[4]
						end,
					
						set = function(info, r, g, b, a)
							if not OverrideFont_ShadowColor then
								OverrideFont_ShadowColor = {}
							end
							local c = OverrideFont_ShadowColor
							c[1], c[2], c[3], c[4] = r, g, b, a
						end,
						disabled = function() return not OverrideFont_EnableShadow end,
					},
					xFontShadowOffset = {
						order = 18,
						type = 'range',
						name = L["xOffset"],
						width = 0.75,
						min = -10, max = 10, step = 1,
						get = function() return OverrideFont_ShadowX end,
						set = function(info, value) OverrideFont_ShadowX = value; end,
						disabled = function() return not OverrideFont_EnableShadow end,
					},
					yFontShadowOffset = {
						order = 19,
						type = 'range',
						name = L["yOffset"],
						width = 0.75,
						min = -10, max = 10, step = 1,
						get = function() return OverrideFont_ShadowY end,
						set = function(info, value) OverrideFont_ShadowY = value; end,
						disabled = function() return not OverrideFont_EnableShadow end,
					},
					
					
					
					
					newline_last = {type='description',name='',order=99998},
					apply = {
						order = 99999,
						type = 'execute',
						name = L["ApplyChanges"],
						desc = 'Apply the changes you just made',
						func = function() ApplyGlobalFontOverride(); end,
						disabled = function() return not (OverrideFont_EnableFlags or OverrideFont_EnableType or OverrideFont_EnableHeight or OverrideFont_EnableShadow) end,
					},
				},
			},
		},
	}

	CD.Options.args.unitframe.args.player = {
		name = L["Player"],
		type = 'group',
		order = 2,
		childGroups = "tab",
		hidden = GLOBAL_DISABLEDFUNC,
		args = {
			generalGroup =  GetOptionsTable_General("player"),
			name = GetOptionsTable_Text("player", "name"),
			health = GetOptionsTable_Text("player", "health"),
			power = GetOptionsTable_Text("player", "power"),
			level = GetOptionsTable_Text("player", "level"),
			portrait = GetOptionsTable_Portrait("player"),
			combatIndicator = GetOptionsTable_CombatIndicator(),
			restingIndicator = GetOptionsTable_Restingindicator(),
			readycheckicon = GetOptionsTable_ReadyCheck("player"),
			summonIcon = GetOptionsTable_SummonIndicator("player"),
			resIndicator = GetOptionsTable_ResIndicator("player"),
			roleIcon = GetOptionsTable_RoleIcon("player"),
			targetIcon = GetOptionsTable_TargetIcon("player"),
			leaderIcon = GetOptionsTable_Leader("player"),
			buffs = GetOptionsTable_Auras("Buffs", "player"),
			debuffs = GetOptionsTable_Auras("Debuffs", "player"),
			aurabars = GetOptionsTable_AuraBars("player"),
			absorb = GetOptionsTable_Absorption("player"),
			barHealth = GetOptionsTable_HealthBar("player"),
			barPower = GetOptionsTable_PowerBar("player"),
			alternatePower = GetOptionsTable_ClassPower("player"),
			castbar = GetOptionsTable_CastBar("player"),
			unitAlternatePower = GetOptionsTable_UnitAlternatePower("player"),
		},
	}

	CD.Options.args.unitframe.args.pet = {
		name = L["Pet"],
		type = 'group',
		order = 1,
		childGroups = "tab",
		hidden = GLOBAL_DISABLEDFUNC,
		args = {
			generalGroup =  GetOptionsTable_General("pet"),
			name = GetOptionsTable_Text("pet", "name"),
			health = GetOptionsTable_Text("pet", "health"),
			power = GetOptionsTable_Text("pet", "power"),
			level = GetOptionsTable_Text("pet", "level"),
			portrait = GetOptionsTable_Portrait("pet"),
			targetIcon = GetOptionsTable_TargetIcon("pet"),
			buffs = GetOptionsTable_Auras("Buffs", "pet"),
			debuffs = GetOptionsTable_Auras("Debuffs", "pet"),
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
		hidden = GLOBAL_DISABLEDFUNC,
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
			buffs = GetOptionsTable_Auras("Buffs", "target"),
			debuffs = GetOptionsTable_Auras("Debuffs", "target"),
			aurabars = GetOptionsTable_AuraBars("target"),
			absorb = GetOptionsTable_Absorption("target"),
			barHealth = GetOptionsTable_HealthBar("target"),
			barPower = GetOptionsTable_PowerBar("target"),
			castbar = GetOptionsTable_CastBar("target"),
			threat = GetOptionsTable_ThreatBar("target"),
			unitAlternatePower = GetOptionsTable_UnitAlternatePower("target"),
		},
		
	}

	CD.Options.args.unitframe.args.targettarget = {
		name = L["TargetTarget"],
		type = 'group',
		order = 4,
		childGroups = "tab",
		hidden = GLOBAL_DISABLEDFUNC,
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
			buffs = GetOptionsTable_Auras("Buffs", "targettarget"),
			debuffs = GetOptionsTable_Auras("Debuffs", "targettarget"),
			absorb = GetOptionsTable_Absorption("targettarget"),
			barHealth = GetOptionsTable_HealthBar("targettarget"),
			barPower = GetOptionsTable_PowerBar("targettarget"),
			castbar = GetOptionsTable_CastBar("targettarget"),
			threat = GetOptionsTable_ThreatBar("targettarget"),
			unitAlternatePower = GetOptionsTable_UnitAlternatePower("targettarget"),
		},
		
	}

	CD.Options.args.unitframe.args.focus = {
		name = L["Focus"],
		type = 'group',
		order = 5,
		childGroups = "tab",
		hidden = GLOBAL_DISABLEDFUNC,
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
			buffs = GetOptionsTable_Auras("Buffs", "focus"),
			debuffs = GetOptionsTable_Auras("Debuffs", "focus"),
			absorb = GetOptionsTable_Absorption("focus"),
			barHealth = GetOptionsTable_HealthBar("focus"),
			barPower = GetOptionsTable_PowerBar("focus"),
			castbar = GetOptionsTable_CastBar("focus"),
			threat = GetOptionsTable_ThreatBar("focus"),
			unitAlternatePower = GetOptionsTable_UnitAlternatePower("focus"),
		},
		
	}

	CD.Options.args.unitframe.args.focustarget = {
		name = L["FocusTarget"],
		type = 'group',
		order = 6,
		childGroups = "tab",
		hidden = GLOBAL_DISABLEDFUNC,
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
			buffs = GetOptionsTable_Auras("Buffs", "focustarget"),
			debuffs = GetOptionsTable_Auras("Debuffs", "focustarget"),
			absorb = GetOptionsTable_Absorption("focustarget"),
			barHealth = GetOptionsTable_HealthBar("focustarget"),
			barPower = GetOptionsTable_PowerBar("focustarget"),
			castbar = GetOptionsTable_CastBar("focustarget"),
			threat = GetOptionsTable_ThreatBar("focustarget"),
			unitAlternatePower = GetOptionsTable_UnitAlternatePower("focustarget"),
		},
		
	}

	CD.Options.args.unitframe.args.arena = {
		name = L["Arena"],
		type = 'group',
		order = 7,
		childGroups = "tab",
		hidden = GLOBAL_DISABLEDFUNC,
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
			buffs = GetOptionsTable_Auras("Buffs", "arena"),
			debuffs = GetOptionsTable_Auras("Debuffs", "arena"),
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
		hidden = GLOBAL_DISABLEDFUNC,
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
			buffs = GetOptionsTable_Auras("Buffs", "party"),
			debuffs = GetOptionsTable_Auras("Debuffs", "party"),
			absorb = GetOptionsTable_Absorption("party"),
			barHealth = GetOptionsTable_HealthBar("party"),
			barPower = GetOptionsTable_PowerBar("party"),
			castbar = GetOptionsTable_CastBar("party"),
			unitAlternatePower = GetOptionsTable_UnitAlternatePower("party"),
		},
		
	}

	CD.Options.args.unitframe.args.raid = {
		name = L["Raid"],
		type = 'group',
		order = 9,
		childGroups = "tab",
		hidden = GLOBAL_DISABLEDFUNC,
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
			buffs = GetOptionsTable_Auras("Buffs", "raid"),
			debuffs = GetOptionsTable_Auras("Debuffs", "raid"),
			absorb = GetOptionsTable_Absorption("raid"),
			barHealth = GetOptionsTable_HealthBar("raid"),
			barPower = GetOptionsTable_PowerBar("raid"),
			-- castbar = GetOptionsTable_CastBar("raid"),
			unitAlternatePower = GetOptionsTable_UnitAlternatePower("raid"),
		},
	}

	CD.Options.args.unitframe.args.raid40 = {
		name = L["Raid40"],
		type = 'group',
		order = 10,
		childGroups = "tab",
		hidden = GLOBAL_DISABLEDFUNC,
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
			buffs = GetOptionsTable_Auras("Buffs", "raid40"),
			debuffs = GetOptionsTable_Auras("Debuffs", "raid40"),
			absorb = GetOptionsTable_Absorption("raid40"),
			barHealth = GetOptionsTable_HealthBar("raid40"),
			barPower = GetOptionsTable_PowerBar("raid40"),
			-- castbar = GetOptionsTable_CastBar("raid40"),
			unitAlternatePower = GetOptionsTable_UnitAlternatePower("raid40"),
		},
	}

	CD.Options.args.unitframe.args.boss = {
		name = L["Boss"],
		type = 'group',
		order = 11,
		childGroups = "tab",
		hidden = GLOBAL_DISABLEDFUNC,
		args = {
			generalGroup =  GetOptionsTable_General("boss"),
			name = GetOptionsTable_Text("boss", "name"),
			health = GetOptionsTable_Text("boss", "health"),
			power = GetOptionsTable_Text("boss", "power"),
			level = GetOptionsTable_Text("boss", "level"),
			portrait = GetOptionsTable_Portrait("boss"),
			targetIcon = GetOptionsTable_TargetIcon("boss"),
			buffs = GetOptionsTable_Auras("Buffs", "boss"),
			debuffs = GetOptionsTable_Auras("Debuffs", "boss"),
			absorb = GetOptionsTable_Absorption("boss"),
			barHealth = GetOptionsTable_HealthBar("boss"),
			barPower = GetOptionsTable_PowerBar("boss"),
			castbar = GetOptionsTable_CastBar("boss"),
			threat = GetOptionsTable_ThreatBar("boss"),
		},
		
	}	
	
	CD.Options.args.unitframe.args.maintank = {
		name = L["Maintank"],
		type = 'group',
		order = 12,
		childGroups = "tab",
		hidden = GLOBAL_DISABLEDFUNC,
		args = {
			generalGroup = GetOptionsTable_General("maintank"),
			name = GetOptionsTable_Text("maintank", "name"),
			health = GetOptionsTable_Text("maintank", "health"),
			power = GetOptionsTable_Text("maintank", "power"),
			level = GetOptionsTable_Text("maintank", "level"),
			portrait = GetOptionsTable_Portrait("maintank"),
			readycheckicon = GetOptionsTable_ReadyCheck("maintank"),
			summonIcon = GetOptionsTable_SummonIndicator("maintank"),
			resIndicator = GetOptionsTable_ResIndicator("maintank"),
			roleIcon = GetOptionsTable_RoleIcon("maintank"),
			targetIcon = GetOptionsTable_TargetIcon("maintank"),
			leaderIcon = GetOptionsTable_Leader("maintank"),
			buffs = GetOptionsTable_Auras("Buffs", "maintank"),
			debuffs = GetOptionsTable_Auras("Debuffs", "maintank"),
			absorb = GetOptionsTable_Absorption("maintank"),
			barHealth = GetOptionsTable_HealthBar("maintank"),
			barPower = GetOptionsTable_PowerBar("maintank"),
			castbar = GetOptionsTable_CastBar("maintank"),
			unitAlternatePower = GetOptionsTable_UnitAlternatePower("maintank"),
		},
		
	}	
	
	-- Disabled Unit handling
	for groupName, tbl in pairs(CD.Options.args.unitframe.args) do
		if groupName ~= 'all' and tbl.args then
			for moduleName, module in pairs(tbl.args) do
				if moduleName ~= "generalGroup" then
					module.disabled = function() 
						local Disabled = IsGroupDisabled(groupName)
						module.name = GetLabel(module.name, Disabled)
						
						return Disabled
					end
				end
			end
		end
	end
	
	-- Add Unit Selection for "ALL" Font config	
	local target = CD.Options.args.unitframe.args.all.args.fontGroup.args.units.args
	for unit, _ in ipairs(UF.Frames) do
		OverrideFonts_EnabledUnits[unit] = true
		
		target[unit] = {
			type = "toggle",
			order = CD.Options.args.unitframe.args[unit].order,
			name = DB_UNITS_TO_LOCALIZED[unit],
			width = 0.6,
			get = function() return OverrideFonts_EnabledUnits[unit] end,
			set = function(info, value) OverrideFonts_EnabledUnits[unit] = value end,
		}
	end
end

CD:RegisterConfigModule(Module, 'Advanced')