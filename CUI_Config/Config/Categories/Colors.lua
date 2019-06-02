local E, L = unpack(CUI) -- Engine
local CO, CD, L, UF, BA = E:LoadModules("Config", "Config_Dialog", "Locale", "Unitframes", "Bar_Auras")
local UAUR = UF.Modules["Auras"]

local _

local Index = 99999

CD:InitializeOptionsCategory("colors", "Colors", Index)

local function GetOptionsTable_ClassColor(class, order)
	local color = {
	  name = L[class] or "Unknown",
	  type = "color",
	  desc = string.format("%s '%s'", L["Modifies the color of the class"], L[class] or "Unknown"),
	  order = order,
	  get = function(info)
			local c = CO.db.profile.colors.classes[class]
			return c[1], c[2], c[3], c[4]
	  end,
	  set = function(info, r, g, b, a)
			local c = CO.db.profile.colors.classes[class]
			
			c[1], c[2], c[3], c[4] = r, g, b, a
			
			E:GetModule("Unitframes"):UpdateAllUF()
	  end,
	}

	return color
end

local function GetOptionsTable_PowerColor(index, order, subType)
	
	local Name = ((L[E.PowerTypes[index]]) or "Unknown")
	
	if subType then
		Name = (Name .. " (%s)"):format(subType)
	end
	
	local color = {
	  name = Name,
	  type = "color",
	  hasAlpha = false,
	  desc = string.format("%s %s", L["Modifies the color of"], L[E.PowerTypes[index]] or "Unknown"),
	  order = order,
	  get = function(info)
			local c
			if subType and CO.db.profile.colors.powers[E.PowerTypes[index]] and CO.db.profile.colors.powers[E.PowerTypes[index]][subType] then
				c = CO.db.profile.colors.powers[E.PowerTypes[index]][subType]
			else
				c = CO.db.profile.colors.powers[E.PowerTypes[index]]
			end
			
			return c[1], c[2], c[3]
	  end,
	  set = function(info, r, g, b)
			local c
			if subType and CO.db.profile.colors.powers[E.PowerTypes[index]] and CO.db.profile.colors.powers[E.PowerTypes[index]][subType] then
				c = CO.db.profile.colors.powers[E.PowerTypes[index]][subType]
			else
				c = CO.db.profile.colors.powers[E.PowerTypes[index]]
			end
			c[1], c[2], c[3] = r, g, b
			
			E:GetModule("Unitframes"):UpdateAllUF()
	  end,
	}

	return color
end

-- Does not need an update function. Setting the new value already is enough
local function GetOptionsTable_ReadyCheck(state, index)
	local color = {
	  name = L[state] or "Unknown",
	  type = "color",
	  hasAlpha = true,
	  desc = string.format("%s '%s'.\n%s", L["Modifies the Readycheck color for state"], L[state] or "Unknown", L["This will apply the next time a readycheck was performed"]),
	  order = index,
	  get = function(info)
			local c = CO.db.profile.colors.readycheck[state]
			return c[1], c[2], c[3], c[4]
	  end,
	  set = function(info, r, g, b, a)
			local c = CO.db.profile.colors.readycheck[state]
			
			c[1], c[2], c[3], c[4] = r, g, b, a
	  end,
	}

	return color
end

local function GetOptionsTable_ReactionColors(reaction, index)
	local reactionColor = {
	  name = L[reaction],
	  type = "color",
	  hasAlpha = false,
	  desc = L["Modifies the reaction color"],
	  order = index,
	  get = function(info)
			local c = CO.db.profile.colors.reactions[reaction]
			return c[1], c[2], c[3]
	  end,
	  set = function(info, r, g, b, a)
			local c = CO.db.profile.colors.reactions[reaction]
			c[1], c[2], c[3] = r, g, b
			
			E:GetModule("Unitframes"):UpdateAllUF()
	  end,
	}

	return reactionColor
end

local function GetOptionsTable_CastBar(type, index)
	local color = {
	  name = L[type] or "Unknown",
	  type = "color",
	  hasAlpha = false,
	  desc = string.format("%s '%s'.", L["Modifies the Castbar color for state"], L[type] or "Unknown"),
	  order = index,
	  get = function(info)
			local c = CO.db.profile.colors.castbar[type]
			return c[1], c[2], c[3]
	  end,
	  set = function(info, r, g, b, a)
			local c = CO.db.profile.colors.castbar[type]
			
			c[1], c[2], c[3] = r, g, b
	  end,
	}

	return color
end

local function GetOptionsTable_LayoutBars(title, type, index, updateFunc)
	local color = {
	  name = title,
	  type = "color",
	  hasAlpha = true,
	  desc = L["Modifies layout bar color"],
	  order = index,
	  get = function(info)
			local c = E:ParseDBColor(CO.db.profile.colors.layoutBars[type])
			return c[1], c[2], c[3], c[4] or 1
	  end,
	  set = function(info, r, g, b, a)
			local c = E:ParseDBColor(CO.db.profile.colors.layoutBars[type])
			c[1], c[2], c[3], c[4] = r, g, b, a or 1
			
			updateFunc()
	  end,
	}

	return color
end

local function GetOptionsTable_ZoneColor(type, order)
	local config = {
		name = L[type],
		type = "color",
		hasAlpha = true,
		desc = L["Modifies the zone color"],
		order = order,
		get = function(info)
			local c = CO.db.profile.colors.zones[type]
			return c[1], c[2], c[3], c[4]
		end,
		set = function(info, r, g, b)
			local c = CO.db.profile.colors.zones[type]
			c[1], c[2], c[3], c[4] = r, g, b, a
			
			E:GetModule("Layout"):UpdateLocationZone()
		end,
	}
	
	return config
end

local AuraEntry_Selected = nil
local function AuraEntry_Add(info, value)
	local ID = tonumber(value)
	if (ID and (ID < 0 or ID > 999999999)) then return end
	
	-- If is name
	if not ID then
		local Name = value
		ID = select(7, GetSpellInfo(Name))
	end
	
	if not select(1, GetSpellInfo(ID)) then
		E:print("Aura does not exist! Try to enter the aura ID, if you just specified a name")
		
		return
	end
	
	if not CO.db.profile.colors.auras[ID] then
		CO.db.profile.colors.auras[ID] = {enabled = true, color = {["r"] = 0.5, ["g"] = 0.5, ["b"] = 0.5}}
	
		BA:UpdateAuras("player")
		BA:UpdateAuras("target")
	else
		E:print("Aura " .. select(1, GetSpellInfo(ID)) .. " already exists!")
	end
	
	AuraEntry_Selected = ID
end

local function AuraEntry_Delete()
	if not AuraEntry_Selected then return end
	
	if CO.db.profile.colors.auras[AuraEntry_Selected] then
		CO.db.profile.colors.auras[AuraEntry_Selected] = nil
		AuraEntry_Selected = nil
		
		BA:UpdateAuras("player")
		BA:UpdateAuras("target")
	end
end

CD.Options.args.colors = {
	name = L["Colors"],
	type = 'group',
	order = Index,
	childGroups = "tab",
	disabled = false,
	args = {
		colorPickerNote = {
			type = "description",
			order = 1,
			name = L["ColorPickerPlus"],
			hidden = IsAddOnLoaded("ColorPickerPlus"),
		},
		classGroup = {
			type = "group",
			order = 10,
			name = L["ClassColors"],
			args = {
				classHeader = {
					type = "header",
					order = 20,
					name = L["ClassColors"],
				},
				classDesc = {
					type = "description",
					order = 21,
					name = L["ClassColorDesc"],
					fontSize = "small",
				},
				WARRIOR = GetOptionsTable_ClassColor("WARRIOR", 22),
				DRUID = GetOptionsTable_ClassColor("DRUID", 23),
				SHAMAN = GetOptionsTable_ClassColor("SHAMAN", 24),
				MAGE = GetOptionsTable_ClassColor("MAGE", 25),
				DEMONHUNTER = GetOptionsTable_ClassColor("DEMONHUNTER", 26),
				HUNTER = GetOptionsTable_ClassColor("HUNTER", 27),
				ROGUE = GetOptionsTable_ClassColor("ROGUE", 28),
				DEATHKNIGHT = GetOptionsTable_ClassColor("DEATHKNIGHT", 29),
				MONK = GetOptionsTable_ClassColor("MONK", 30),
				PRIEST = GetOptionsTable_ClassColor("PRIEST", 31),
				WARLOCK = GetOptionsTable_ClassColor("WARLOCK", 32),
				PALADIN = GetOptionsTable_ClassColor("PALADIN", 33),
				
				newLine = {type = "description", name = "", order = 1000},
				reset = {
					type = "execute",
					name = L["Reset"],
					order = 1001,
					func = function() for k,v in pairs(E.ConfigDefaults.profile.colors.classes) do for key, color in pairs(v) do CO.db.profile.colors.classes[k][key] = color end end; E:GetModule("Unitframes"):UpdateAllUF(); end,
				},
			},
		},
		powerGroup = {
			type = "group",
			order = 20,
			name = L["PowerHeader"],
			args = {
				powerHeader = {
					type = "header",
					order = 40,
					name = L["PowerHeader"],
				},
				powerDesc = {
					type = "description",
					order = 41,
					name = L["PowerColorDesc"],
					fontSize = "small",
				},
				Mana 			=  GetOptionsTable_PowerColor(0, 45),
				Rage 			=  GetOptionsTable_PowerColor(1, 50),
				Focus 			=  GetOptionsTable_PowerColor(2, 55),
				Energy 			=  GetOptionsTable_PowerColor(3, 60),
				Combopoints 	=  GetOptionsTable_PowerColor(4, 65),
				RunicPower 		=  GetOptionsTable_PowerColor(6, 70),
				LunarPower 		=  GetOptionsTable_PowerColor(8, 75),
				HolyPower 		=  GetOptionsTable_PowerColor(9, 80),
				Maelstrom 		=  GetOptionsTable_PowerColor(11, 85),
				Chi 			=  GetOptionsTable_PowerColor(12, 90),
				Insanity 		=  GetOptionsTable_PowerColor(13, 95),
				ArcaneCharges 	=  GetOptionsTable_PowerColor(16, 100),
				Fury 			=  GetOptionsTable_PowerColor(17, 105),
				Pain 			=  GetOptionsTable_PowerColor(18, 110),
				StaggerLight	=  GetOptionsTable_PowerColor(30, 115, "light"),
				StaggerMedium	=  GetOptionsTable_PowerColor(30, 120, "medium"),
				StaggerHeavy	=  GetOptionsTable_PowerColor(30, 125, "heavy"),
				RuneReady 		=  GetOptionsTable_PowerColor(31, 130),
				RuneNotReady 	=  GetOptionsTable_PowerColor(32, 135),
				
				newLine = {type = "description", name = "", order = 1000},
				reset = {
					type = "execute",
					name = L["Reset"],
					order = 1001,
					func = function() for k,v in pairs(E.ConfigDefaults.profile.colors.powers) do for key, color in pairs(v) do CO.db.profile.colors.powers[k][key] = color end end; E:GetModule("Unitframes"):UpdateAllUF(); end,
				},
			},
		},
		reactionGroup = {
			type = "group",
			order = 30,
			name = L["ReactionColor"],
			args = {
				powerDesc = {
					type = "description",
					order = 1,
					name = L["ReactionColorDesc"],
					fontSize = "small",
				},
				reactionHeader = {
					type = "header",
					order = 10,
					name = L["ReactionColor"],
				},
				colorFriendly = GetOptionsTable_ReactionColors("friendly", 11),
				colorNeutral = GetOptionsTable_ReactionColors("neutral", 12),
				colorUnfriendly = GetOptionsTable_ReactionColors("unfriendly", 13),
				colorHostile = GetOptionsTable_ReactionColors("hostile", 14),
				newLine = {type = "description", name = "", order = 1000},
				reset = {
					type = "execute",
					name = L["Reset"],
					order = 1001,
					func = function() for k,v in pairs(E.ConfigDefaults.profile.colors.reactions) do for key, color in pairs(v) do CO.db.profile.colors.reactions[k][key] = color end end; E:GetModule("Unitframes"):UpdateAllUF() end,
				},
			},
		},
		readycheckGroup = {
			type = "group",
			order = 40,
			name = L["Readycheck"],
			args = {
				powerDesc = {
					type = "description",
					order = 1,
					name = L["ReadycheckDesc"],
					fontSize = "small",
				},
				readycheckHeader = {
					type = "header",
					order = 80,
					name = L["ReadycheckIcons"],
				},
				ReadyCheck_Ready 		= GetOptionsTable_ReadyCheck("ready", 81),
				ReadyCheck_NotReady 	= GetOptionsTable_ReadyCheck("notready", 82),
				ReadyCheck_Waiting 		= GetOptionsTable_ReadyCheck("waiting", 83),
				newLine = {type = "description", name = "", order = 1000},
				reset = {
					type = "execute",
					name = L["Reset"],
					order = 1001,
					func = function() for k,v in pairs(E.ConfigDefaults.profile.colors.readycheck) do for key, color in pairs(v) do CO.db.profile.colors.readycheck[k][key] = color end end end,
				},
			},
		},
		castbarGroup = {
			type = "group",
			order = 50,
			name = L["Castbar"],
			args = {
				castbarDesc = {
					type = "description",
					order = 1,
					name = L["CastbarColorDesc"],
					fontSize = "small",
				},
				castbarHeader = {
					type = "header",
					order = 80,
					name = L["CastbarColors"],
				},
				Success 			= GetOptionsTable_CastBar("success", 81),
				Failed 				= GetOptionsTable_CastBar("failed", 82),
				Interruptible 		= GetOptionsTable_CastBar("interruptible", 83),
				NotInterruptible 	= GetOptionsTable_CastBar("notInterruptible", 84),
				newLine = {type = "description", name = "", order = 1000},
				reset = {
					type = "execute",
					name = L["Reset"],
					order = 1001,
					func = function() for k,v in pairs(E.ConfigDefaults.profile.colors.castbar) do for key, color in pairs(v) do CO.db.profile.colors.castbar[k][key] = color end end end,
				},
			},
		},
		layoutBarsGroup = {
			type = "group",
			order = 60,
			name = "Layout Bars",
			args = {
				desc = {
					type = "description",
					order = 1,
					name = L["LayoutColorDesc"],
					fontSize = "small",
				},
				xpHeader = {
					type = "header",
					name = L["XPBar"],
					order = 80,
				},
				xpUseClassColor = {
					type = "toggle",
					order = 81,
					name = L["UseNormalClassColor"],
					desc = L["UseNormalClassColorDesc"],
					get = function() return CO.db.profile.colors.layoutBars.barExperienceNormal.useClassColor end,
					set = function(info, value) CO.db.profile.colors.layoutBars.barExperienceNormal.useClassColor = value; E:GetModule("Bar_Experience"):LoadProfile(); end,
				},
				xpNormal 			= GetOptionsTable_LayoutBars(L["XPBarNormal"], "barExperienceNormal", 100, E:GetModule("Bar_Experience").LoadProfile),
				xpRested 			= GetOptionsTable_LayoutBars(L["XPBarRested"], "barExperienceRested", 200, E:GetModule("Bar_Experience").LoadProfile),
				newline5 = {type = "description", name = "", order = 250},
				azHeader = {
					type = "header",
					name = L["AzeriteBar"],
					order = 290,
				},
				azUseClassColor = {
					type = "toggle",
					order = 300,
					name = L["UseClassColor"],
					desc = L["UseClassColorDesc"],
					get = function() return CO.db.profile.colors.layoutBars.barAzerite.useClassColor end,
					set = function(info, value) CO.db.profile.colors.layoutBars.barAzerite.useClassColor = value; E:GetModule("Bar_Azerite"):LoadProfile(); end,
				},
				azOverlay 			= GetOptionsTable_LayoutBars(L["AzeriteBarOverlay"], "barAzerite", 350, E:GetModule("Bar_Azerite").LoadProfile),
				newLine = {type = "description", name = "", order = 1000},
				reset = {
					type = "execute",
					name = L["Reset"],
					order = 1001,
					func = function() for k,v in pairs(E.ConfigDefaults.profile.colors.layoutBars) do for key, color in pairs(v) do CO.db.profile.colors.layoutBars[k][key] = color end end; E:GetModule("Bar_Experience"):LoadProfile(); E:GetModule("Bar_Azerite"):LoadProfile(); end,
				},
			},
		},
		zoneGroup = {
			type = "group",
			order = 70,
			name = L["ZoneColors"],
			args = {
				desc = {
					type = "description",
					order = 1,
					name = L["ZoneColorsDesc"],
					fontSize = "small",
				},
				arena = GetOptionsTable_ZoneColor("arena", 10),
				friendly = GetOptionsTable_ZoneColor("friendly", 20),
				contested = GetOptionsTable_ZoneColor("contested", 30),
				hostile = GetOptionsTable_ZoneColor("hostile", 40),
				sanctuary = GetOptionsTable_ZoneColor("sanctuary", 50),
				combat = GetOptionsTable_ZoneColor("combat", 60),
				default = GetOptionsTable_ZoneColor("default", 70),
				newLine = {type = "description", name = "", order = 100},
				reset = {
					type = "execute",
					name = L["Reset"],
					order = 101,
					func = function() for k,v in pairs(E.ConfigDefaults.profile.colors.zones) do for key, color in pairs(v) do CO.db.profile.colors.zones[k][key] = color end end end,
				},
			},
		},
		aurasGroup = {
			type = "group",
			order = 80,
			name = L["Auras"],
			args = {
				desc = {
					type = "description",
					order = 1,
					name = "Here, you can define specific colors for your aura bars",
					fontSize = "small",
				},
				newLine = {type="description", name="", order=5},
				add = {
					type = "input",
					order = 7,
					name = "Add Aura by Name or Spell ID",
					width = "double",
					set = AuraEntry_Add,
				},
				newLine2 = {type="description", name="", order=10},
				selection = {
					type = "select",
					order = 11,
					name = "Aura",
					values = function()
						local lookupTable = {}
						
						for k, v in pairs(CO.db.profile.colors.auras) do
							if GetSpellInfo(k) then
								lookupTable[k] = string.format("%s (%s)", select(1, GetSpellInfo(k)), k)
							end
						end
						
						return lookupTable
					end,
					get = function() return AuraEntry_Selected end,
					set = function(info, value) AuraEntry_Selected = value end,
				},
				delete = {
					type = "execute",
					name = "Delete",
					order = 12,
					hidden = function() return not AuraEntry_Selected end,
					func = AuraEntry_Delete,
				},
				
				newLine3 = {type="description", name="", order=15},
				
				auraHeader = {
					type = "header",
					name = "Options",
					order = 20,
					hidden = function() return not AuraEntry_Selected end,
				},
				auraEnable = {
					type = "toggle",
					name = L["Enable"],
					order = 21,
					hidden = function() return not AuraEntry_Selected end,
					get = function() return CO.db.profile.colors.auras[AuraEntry_Selected].enabled end,
					set = function(info, value) CO.db.profile.colors.auras[AuraEntry_Selected].enabled = value; BA:UpdateAuras("player"); BA:UpdateAuras("target"); UAUR:UpdateAll() end,
				},
				
				newLine4 = {type="description", name="", order=25},
				
				auraColor = {
					name = "Color",
					type = "color",
					hasAlpha = false,
					order = 26,
					get = function(info)
						if not AuraEntry_Selected or not CO.db.profile.colors.auras[AuraEntry_Selected] then return end
						local c = CO.db.profile.colors.auras[AuraEntry_Selected].color
						return c.r, c.g, c.b
					end,
					set = function(info, r, g, b)
						local c = CO.db.profile.colors.auras[AuraEntry_Selected].color
						c.r, c.g, c.b = r, g, b
						
						BA:UpdateAuras("player")
						BA:UpdateAuras("target")
						UAUR:UpdateAll()
					end,
					disabled = function() return not CO.db.profile.colors.auras[AuraEntry_Selected].enabled end,
					hidden = function() return not AuraEntry_Selected end,
				},
			},
		},
		-- Used for specific unit coloring
		--[[
		unitGroup = {
			type = "group",
			order = 90,
			name = L["Unitframes"],
			args = {
				desc = {
					type = "description",
					order = 1,
					name = "Here, you can define specific colors for your aura bars",
					fontSize = "small",
				},
				newLine = {type="description", name="", order=5},
				add = {
					type = "input",
					order = 7,
					name = "Add Aura by Name or Spell ID",
					width = "double",
					set = AuraEntry_Add,
				},
				newLine2 = {type="description", name="", order=10},
				selection = {
					type = "select",
					order = 11,
					name = "Aura",
					values = function()
						local lookupTable = {}
						
						for k, v in pairs(CO.db.profile.colors.auras) do
							if GetSpellInfo(k) then
								lookupTable[k] = string.format("%s (%s)", select(1, GetSpellInfo(k)), k)
							end
						end
						
						return lookupTable
					end,
					get = function() return AuraEntry_Selected end,
					set = function(info, value) AuraEntry_Selected = value end,
				},
				delete = {
					type = "execute",
					name = "Delete",
					order = 12,
					hidden = function() return not AuraEntry_Selected end,
					func = AuraEntry_Delete,
				},
				
				newLine3 = {type="description", name="", order=15},
				
				auraHeader = {
					type = "header",
					name = "Options",
					order = 20,
					hidden = function() return not AuraEntry_Selected end,
				},
				auraEnable = {
					type = "toggle",
					name = L["Enable"],
					order = 21,
					hidden = function() return not AuraEntry_Selected end,
					get = function() return CO.db.profile.colors.auras[AuraEntry_Selected].enabled end,
					set = function(info, value) CO.db.profile.colors.auras[AuraEntry_Selected].enabled = value; BA:UpdateAuras("player"); BA:UpdateAuras("target"); UAUR:UpdateAll() end,
				},
				
				newLine4 = {type="description", name="", order=25},
				
				auraColor = {
					name = "Color",
					type = "color",
					hasAlpha = false,
					order = 26,
					get = function(info)
						if not AuraEntry_Selected or not CO.db.profile.colors.auras[AuraEntry_Selected] then return end
						local c = CO.db.profile.colors.auras[AuraEntry_Selected].color
						return c.r, c.g, c.b
					end,
					set = function(info, r, g, b)
						local c = CO.db.profile.colors.auras[AuraEntry_Selected].color
						c.r, c.g, c.b = r, g, b
						
						BA:UpdateAuras("player")
						BA:UpdateAuras("target")
						UAUR:UpdateAll()
					end,
					disabled = function() return not CO.db.profile.colors.auras[AuraEntry_Selected].enabled end,
					hidden = function() return not AuraEntry_Selected end,
				},
			},
		},]]
	},
	
}