local E, L = unpack(CUI) -- Engine
local CO, CD, L = E:LoadModules("Config", "Config_Dialog", "Locale")

local _

local Index = 99999
CD:InitializeOptionsCategory("auras", L["Buffs and Debuffs"], Index)

local function GetOptionsTable_PlayerAuras(displayName, type, index)
	
	local config = {
		order = index,
		type = 'group',
		name = L[displayName],
		childGroups = "tab",
		get = function(info) return CO.db.profile.unitframe[type][ info[#info] ] end,
		set = function(info, value) CO.db.profile.unitframe[type][ info[#info] ] = value; E:GetModule("Auras"):LoadProfile() end,
		args = {
			buttonGroup = {
				order = 1,
				type = 'group',
				name = L["Auras"],
				args = {
					size = {
						order = 1,
						name = L["Scale"],
						type = "range",
						min = 16, max = 60, step = 2,
					},
					sortHeader = {
						order = 10,
						name = "Sorting",
						type = "header",
					},
					sortMethod = {
						order = 11,
						name = "Sort By",
						type = "select",
						values = CD.AuraSortMethods,
					},
					sortDirection = {
						order = 12,
						name = "Sort Direction",
						type = "select",
						values = CD.AuraSortDirections,
					},
					growthHeader = {
						order = 20,
						name = "Growth",
						type = "header",
					},
					growthDirectionX = {
						order = 21,
						name = "Horizontal",
						type = "select",
						values = CD.AuraGrowthDirections.X,
					},
					growthDirectionY = {
						order = 22,
						name = "Vertical",
						type = "select",
						values = CD.AuraGrowthDirections.Y,
					},
					spacingHeader = {
						order = 30,
						name = "Spacing",
						type = "header",
					},
					maxPerRow = {
						order = 31,
						name = "Max Per Row",
						type = "range",
						min = 1, max = 50, step = 1,
					},
					maxWraps = {
						order = 32,
						name = "Max Wraps",
						type = "range",
						min = 1, max = 50, step = 1,
					},
					gapX = {
						order = 33,
						name = "Horizontal Gap",
						type = "range",
						min = 0, max = 50, step = 1,
					},
					gapY = {
						order = 34,
						name = "Vertical Gap",
						type = "range",
						min = 0, max = 50, step = 1,
					},
					
					borderColorHeader = {
						type = "header",
						order = 40,
						name = L["BorderColor"],
						hidden = (type == "debuffs"),
					},
					borderUseClassColor = {
						type = "toggle",
						order = 41,
						name = L["UseClassColor"],
						desc = L["UseClassColorDesc"],
						get = function() return CO.db.profile.unitframe[type].borderUseClassColor.useClassColor end,
						set = function(info, value) CO.db.profile.unitframe[type].borderUseClassColor.useClassColor = value; E:GetModule("Auras"):LoadProfile(); end,
						hidden = (type == "debuffs"),
					},
					borderColor = {
						name = L["BorderColor"],
						type = "color",
						hasAlpha = true,
						order = 42,
						get = function(info)
							local c = E:ParseDBColor(CO.db.profile.unitframe[type].borderUseClassColor)
							return c[1], c[2], c[3], c[4] or 1
						end,
						set = function(info, r, g, b, a)
							local c = E:ParseDBColor(CO.db.profile.unitframe[type].borderUseClassColor)
							c[1], c[2], c[3], c[4] = r, g, b, a or 1
							
							E:GetModule("Auras"):LoadProfile();
						end,
						disabled = function() return CO.db.profile.unitframe[type].borderUseClassColor.useClassColor end,
						hidden = (type == "debuffs"),
					},
					masqueHeader = {
						name = "Masque",
						type = "header",
						order = 50,
					},
					useMasque = {
						type = "toggle",
						order = 51,
						name = L["UseMasque"],
						desc = L["UseMasqueDesc"],
						get = function() return CO.db.profile.unitframe[type].useMasque end,
						set = function(info, value) CO.db.profile.unitframe[type].useMasque = value; CD:ShowNotification("RELOAD_NOTIFICATION") end,
					},
				},
			},
			moverGroup = {
				order = 1,
				type = 'group',
				name = L["Position"],
				args = {
					
				}
			},
		}
	}
	
	for k,v in pairs(CD:GetMoverOptions(("CUIPlayer%sMover"):format(displayName), 50, true)) do
		config.args.moverGroup.args[k] = v
	end
	
	local Fonts = {{Path = "CO.db.profile.unitframe.".. type ..".time", Order = 100, GroupName = L["Time"]}, {Path = "CO.db.profile.unitframe.".. type ..".count", Order = 200, GroupName = L["Count"]}}
	for k,v in pairs(CD:GetFontOptions(Fonts)) do
		config.args[k] = v
	end
	
	return config
end

CD.Options.args.auras = {
	name = L["Buffs and Debuffs"],
	type = 'group',
	order = Index,
	disabled = false,
	childGroups = "tab",
	args = {
		buffs = GetOptionsTable_PlayerAuras("Buffs", "buffs", 1),
		debuffs = GetOptionsTable_PlayerAuras("Debuffs", "debuffs", 2),
	},
}