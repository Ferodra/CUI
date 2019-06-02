local E, L = unpack(CUI) -- Engine
local CO, CD, L = E:LoadModules("Config", "Config_Dialog", "Locale")

-- {{PATH, ORDER, GROUPNAME}}
function CD:GetFontOptions(Data)
	local config = {}
	local CurrentGroup
	for _, group in pairs(Data) do
		if type(group) == "table" then
			-- Create new group
			if group.GroupName then
				CurrentGroup = self:AddFontGroup(group)
				
				config[group.GroupName] = CurrentGroup
			end
		end
	end
	
	return config
end

function CD:AddFontGroup(Data)
	local config = {
		type = "group",
		order = Data.Order,
		name = Data.GroupName,
	}
	
	self:AddMethods(config, Data.Path)
	config.args = self:AddFontOptions(Data.Path)
	
	return config
end

function CD:AddMethods(config, DBPath)
	
	config.set = function(info, value) E:GetTablePath(DBPath, CO)[ info[#info] ] = value; E:UpdatePathFont(DBPath) end
	config.get = function(info) return E:GetTablePath(DBPath, CO)[ info[#info] ] end
	
	return config
end

function CD:AddFontOptions(DBPath, Order)
	local config = {
		enable = {
			type = "toggle",
			order = (Order or 1) + 1,
			name = L["Enable"],
			width = "full",
		},
		width = {
			order = (Order or 2) + 2,
			type = 'range',
			name = L["Width"],
			desc = L["WidthFontDesc"],
			min = 0, max = 500, step = 1,
			disabled = function() return not E:GetTablePath(DBPath, CO).enable end,
		},
		positionHeader = {
			order = (Order or 10) + 10,
			type = "header",
			name = L["Positioning"],
		},
		position = {
			type = 'select',
			order = (Order or 11) + 11,
			name = L["Position"],
			values = E.Positions,
			disabled = function() return not E:GetTablePath(DBPath, CO).enable end,
		},
		xOffset = {
			order = (Order or 12) + 12,
			type = 'range',
			name = L["XOffset"],
			min = -5000, max = 5000,
			softMin = -300, softMax = 300, step = 1,
			disabled = function() return not E:GetTablePath(DBPath, CO).enable end,
		},
		yOffset = {
			order = (Order or 13) + 13,
			type = 'range',
			name = L["YOffset"],
			min = -5000, max = 5000,
			softMin = -300, softMax = 300, step = 1,
			disabled = function() return not E:GetTablePath(DBPath, CO).enable end,
		},
		horizontalAlign = {
			name = L["HorizontalAlign"],
			type = "select",
			desc = L["HAlignFontDesc"],
			order = (Order or 14) + 14,
			-- style = "dropdown",
			values = CD.FontHorizontalAlign,
			disabled = function() return not E:GetTablePath(DBPath, CO).enable end,
		},
		styleHeader = {
			order = (Order or 20) + 20,
			type = "header",
			name = L["FontStyle"],
		},
		fontHeight = {
			order = (Order or 21) + 21,
			type = 'range',
			name = L["FontHeight"],
			min = 3, max = 90, step = 1,
			disabled = function() return not E:GetTablePath(DBPath, CO).enable end,
		},
		fontType = {
		  name = L["FontType"],
		  dialogControl = "LSM30_Font",
		  type = "select",
		  order = (Order or 22) + 22,
		  values = CO.AceGUIWidgetLSMlists["font"],
		  disabled = function() return not E:GetTablePath(DBPath, CO).enable end,
		},
		fontFlags = {
		  name = L["FontFlags"],
		  type = "select",
		  order = (Order or 23) + 23,
		  values = CD.FontFlags,
		  disabled = function() return not E:GetTablePath(DBPath, CO).enable end,
		},
		fontColor = {
			name = L["FontColor"],
			type = "color",
			hasAlpha = true,
			order = (Order or 24) + 24,
			get = function(info)
					local c = E:GetTablePath(DBPath, CO).fontColor
					return c[1], c[2], c[3], c[4]
			end,
			set = function(info, r, g, b, a)
					local color = E:GetTablePath(DBPath, CO).fontColor
					color[1], color[2], color[3], color[4] = r, g, b, a
					E:UpdatePathFont(DBPath)
			end,
			disabled = function() return not E:GetTablePath(DBPath, CO).enable end,
		},
		shadowHeader = {
			order = (Order or 30) + 30,
			type = "header",
			name = L["TextShadow"],
		},
		fontShadowColor = {
		  name = L["TextShadowColor"],
		  type = "color",
		  hasAlpha = true,
		  order = (Order or 31) + 31,
		  get = function(info)
				local c = E:GetTablePath(DBPath, CO).fontShadowColor
					return c[1], c[2], c[3], c[4]
		  end,
		  set = function(info, r, g, b, a)
				local color = E:GetTablePath(DBPath, CO).fontShadowColor
				color[1], color[2], color[3], color[4] = r, g, b, a
				E:UpdatePathFont(DBPath)
		  end,
		  disabled = function() return not E:GetTablePath(DBPath, CO).enable end,
		},
		xFontShadowOffset = {
			order = (Order or 32) + 32,
			type = 'range',
			name = L["XOffset"],
			min = -10, max = 10, step = 1,
			disabled = function() return not E:GetTablePath(DBPath, CO).enable end,
		},
		yFontShadowOffset = {
			order = (Order or 33) + 33,
			type = 'range',
			name = L["YOffset"],
			min = -10, max = 10, step = 1,
			disabled = function() return not E:GetTablePath(DBPath, CO).enable end,
		},
	}
	
	return config
end