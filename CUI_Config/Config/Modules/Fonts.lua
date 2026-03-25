local E, L = unpack(CUI) -- Engine
local CO, CD, UF = E:LoadModules("Config", "Config_Dialog", "Unitframes")

-- {{PATH, ORDER, GROUPNAME}}
function CD:GetFontOptions(Data, DisabledFunc, TableOnly)
	local config = {}
	local CurrentGroup
	for _, group in pairs(Data) do
		if type(group) == "table" then
			-- Create new group
			if group.GroupName then
				CurrentGroup = self:AddFontGroup(group, DisabledFunc)
				
				if not TableOnly then
					config[group.GroupName] = CurrentGroup
				else
					config = CurrentGroup
				end
			end
		end
	end
	
	return config
end

function CD:AddFontGroup(Data, DisabledFunc)
	local config = {
		type = "group",
		order = Data.Order,
		name = Data.GroupName,
		disabled = DisabledFunc,
	}
	
	self:AddMethods(config, Data.Path)
	config.args = self:AddFontOptions(Data.Path)
	
	return config
end

function CD:AddMethods(config, DBPath)
	config.get = function(info) return E:GetTableByPath(DBPath, CO)[ info[#info] ] end
	config.set = function(info, value) E:GetTableByPath(DBPath, CO)[ info[#info] ] = value; E:UpdateAutoFont(DBPath); UF.Modules["Fonts"]:RefreshFontTags_All(DBPath) end
	
	return config
end

function CD:AddFontOptions(DBPath, Order)
	--if not DBPath then error('AddFontOptions requires a valid DBPath!') return end

	local config = {}
	local Exclusions = E:GetFontExclusions(DBPath)
	local Inclusions = E:GetFontInclusions(DBPath)
	
	-- This config scheme enables full control over what happens, simply by setting up an Exclusions table for one of the registered font objects
	
	if Inclusions.textFormat then
		config.textFormat = {
			type = 'input',
			order = (Order or 25) + 25,
			name = "Text-Format",
			desc = "A string of various format types for this font.\nPossible values:\n[health], [health-formatted], [health-max], [health-max-formatted], [health-pct], [health-missing], [health-missing-formatted], [health-missing-pct]\n\n[power], [power-formatted], [power-max], [power-max-formatted], [power-pct]\n\n[name], [level], [level-max], [level-except-max]\n\n[class], [raidgroup], [guild-name], [guild-rank-name]\n\n[newline]",
			width = "full",
			disabled = DBPath and function() return not E:GetTableByPath(DBPath, CO).enable end,
		}
	end

	if not Exclusions.enable then
		config.enable = {
			type = "toggle",
			order = (Order or 1) + 1,
			name = L["Enable"],
			width = "full",
		}
	end
	if not Exclusions.width then
		config.width = {
			order = (Order or 2) + 2,
			type = 'range',
			name = L["Width"],
			desc = L["WidthFontDesc"],
			min = 0, max = 500, step = 1,
			disabled = DBPath and function() return not E:GetTableByPath(DBPath, CO).enable end,
		}
	end
	if not Exclusions.height then
		config.height = {
			order = (Order or 3) + 3,
			type = 'range',
			name = L["Height"],
			desc = L["HeightFontDesc"],
			min = 0, max = 500, step = 1,
			disabled = DBPath and function() return not E:GetTableByPath(DBPath, CO).enable end,
		}
	end
	if not Exclusions.position or not Exclusions.xOffset or not Exclusions.yOffset or not Exclusions.horizontalAlign or not Exclusions.verticalAlign then
		config.positionHeader = {
			order = (Order or 10) + 10,
			type = "header",
			name = L["Positioning"],
		}
		
		if not Exclusions.position then
			config.position = {
				type = 'select',
				order = (Order or 11) + 11,
				name = L["Position"],
				values = E.Positions,
				disabled = DBPath and function() return not E:GetTableByPath(DBPath, CO).enable end,
			}
		end
		if not Exclusions.xOffset then
			config.xOffset = {
				order = (Order or 12) + 12,
				type = 'range',
				name = L["XOffset"],
				min = -5000, max = 5000,
				softMin = -300, softMax = 300, step = 1,
				disabled = DBPath and function() return not E:GetTableByPath(DBPath, CO).enable end,
			}
		end
		if not Exclusions.yOffset then
			config.yOffset = {
				order = (Order or 13) + 13,
				type = 'range',
				name = L["YOffset"],
				min = -5000, max = 5000,
				softMin = -300, softMax = 300, step = 1,
				disabled = DBPath and function() return not E:GetTableByPath(DBPath, CO).enable end,
			}
		end
		if not Exclusions.horizontalAlign then
			config.horizontalAlign = {
				name = L["HorizontalAlign"],
				type = "select",
				desc = L["HAlignFontDesc"],
				order = (Order or 14) + 14,
				-- style = "dropdown",
				values = CD.FontHorizontalAlign,
				disabled = DBPath and function() return not E:GetTableByPath(DBPath, CO).enable end,
			}
		end
		if not Exclusions.verticalAlign then
			config.verticalAlign = {
				name = L["VerticalAlign"],
				type = "select",
				desc = L["VAlignFontDesc"],
				order = (Order or 14) + 14,
				-- style = "dropdown",
				values = CD.FontVerticalAlign,
				disabled = DBPath and function() return not E:GetTableByPath(DBPath, CO).enable end,
			}
		end
	end
	if not Exclusions.fontHeight or not Exclusions.fontType or not Exclusions.fontFlags or not Exclusions.fontColor then
		config.styleHeader = {
			order = (Order or 20) + 20,
			type = "header",
			name = L["FontStyle"],
		}
		if not Exclusions.fontHeight then
			config.fontHeight = {
				order = (Order or 21) + 21,
				type = 'range',
				name = L["FontHeight"],
				min = 3, max = 90, step = 1,
				disabled = DBPath and function() return not E:GetTableByPath(DBPath, CO).enable end,
			}
		end
		if not Exclusions.fontType then
			config.fontType = {
			  name = L["FontType"],
			  dialogControl = "LSM30_Font",
			  type = "select",
			  order = (Order or 22) + 22,
			  values = CO.AceGUIWidgetLSMlists["font"],
			  disabled = DBPath and function() return not E:GetTableByPath(DBPath, CO).enable end,
			}
		end
			if not Exclusions.fontFlags then
			config.fontFlags = {
			  name = L["FontFlags"],
			  type = "select",
			  order = (Order or 23) + 23,
			  values = CD.FontFlags,
			  disabled = DBPath and function() return not E:GetTableByPath(DBPath, CO).enable end,
			}
		end
		if not Exclusions.fontColor then
			config.fontColorUseClass = {
				type = "toggle",
				order = (Order or 24) + 24,
				name = L["UseClassColor"],
				desc = L["UseClassColorDesc"],
				get = function() return E:GetTableByPath(DBPath, CO).fontColor.useClassColor end,
				set = function(info, value) E:GetTableByPath(DBPath, CO).fontColor.useClassColor = value; E:UpdateAutoFont(DBPath) end,
				hidden = DBPath and function() return not E:GetTableByPath(DBPath, CO).fontColor end,
			}
			config.fontColorRgba = {
				name = L["Color"],
				type = "color",
				hasAlpha = true,
				order = (Order or 25) + 25,
				get = DBPath and function(info)
					local c = E:ParseDBColor(E:GetTableByPath(DBPath, CO).fontColor)
					return c[1], c[2], c[3], c[4] or 1
				end,
				set = DBPath and function(info, r, g, b, a)
					local c = E:ParseDBColor(E:GetTableByPath(DBPath, CO).fontColor)
					c[1], c[2], c[3], c[4] = r, g, b, a or 1
					
					E:UpdateAutoFont(DBPath)
				end,
				disabled = DBPath and function() return not E:GetTableByPath(DBPath, CO).enable or E:GetTableByPath(DBPath, CO).fontColor.useClassColor end,
				hidden = DBPath and function() return not E:GetTableByPath(DBPath, CO).fontColor end, -- Only display when there actually are fontColor configs for this
			}
		end
	end
	if not Exclusions.fontShadowColor or not Exclusions.xFontShadowOffset or not Exclusions.yFontShadowOffset then
		config.shadowHeader = {
			order = (Order or 30) + 30,
			type = "header",
			name = L["TextShadow"],
		}
		if not Exclusions.fontShadowColor then
			config.fontShadowColor = {
			  name = L["TextShadowColor"],
			  type = "color",
			  hasAlpha = true,
			  order = (Order or 31) + 31,
			  get = DBPath and function(info)
					local c = E:GetTableByPath(DBPath, CO).fontShadowColor
						return c[1], c[2], c[3], c[4]
			  end,
			  set = DBPath and function(info, r, g, b, a)
					local color = E:GetTableByPath(DBPath, CO).fontShadowColor
					color[1], color[2], color[3], color[4] = r, g, b, a
					E:UpdateAutoFont(DBPath)
			  end,
			  disabled = DBPath and function() return not E:GetTableByPath(DBPath, CO).enable end,
			}
		end
		if not Exclusions.xFontShadowOffset then
			config.xFontShadowOffset = {
				order = (Order or 32) + 32,
				type = 'range',
				name = L["XOffset"],
				min = -10, max = 10, step = 1,
				disabled = DBPath and function() return not E:GetTableByPath(DBPath, CO).enable end,
			}
		end
		if not Exclusions.yFontShadowOffset then
			config.yFontShadowOffset = {
				order = (Order or 33) + 33,
				type = 'range',
				name = L["YOffset"],
				min = -10, max = 10, step = 1,
				disabled = DBPath and function() return not E:GetTableByPath(DBPath, CO).enable end,
			}
		end
	end
	
	return config
end

function CD:AddIndexFont(Frame)
	if Frame.Fonts.Frames.Index then return end
	
	local Font = E:NewFontObject(nil, "OVERLAY", Frame.Overlay, 15)
	Font:SetText(Frame.IndexInGroup or select(2, E:ExtractDigits(Frame.unit)))
	Font.Update = function(self, text) self:SetText(text) end
	
	Font:SetPoint("CENTER", Frame.Overlay, "CENTER")
	Font:SetTextColor(1, 1, 0)
	Font:SetShadowColor(0,0,0,1)
	Font:SetShadowOffset(1, 1)
	
	Frame.Fonts.Frames.Index = Font
end






