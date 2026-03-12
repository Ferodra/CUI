local E, L = unpack(CUI) -- Engine
local CO, CD, TT = E:LoadModules("Config", "Config_Dialog", "Tooltip")

local _
local Module = {}

function Module:Disable()
	CD.Options.args.tooltip = nil
end

function Module:Enable()
		
	local DisabledFunc = function() return not CO.db.profile.tooltip["enable"] end
		
	CD.Options.args.tooltip = {
		name = "Tooltip",
		type = 'group',
		order = CD:GetAutoSortIndex(),
		disabled = false,
		args = {
			enable = {
				order = 1,
				type = "toggle",
				name = L["Enable"],
				desc = "Enables/Disables the Tooltip Module. When disabled, the Tooltip Mover won't be visible and CUI will not touch the Tooltip in any other way.",
				width = "full",
				get = function(info) return CO.db.profile.tooltip["enable"] end,
				set = function(info, value) CO.db.profile.tooltip["enable"] = value; GameTooltip:Hide() TT:LoadConfig(); end,
			},
			headerFontType = {
				name = "Header Font Type",
				dialogControl = "LSM30_Font",
				type = "select",
				desc = L["FontType"],
				order = 2,
				values = CO.AceGUIWidgetLSMlists["font"],
				get = function(info) return CO.db.profile.tooltip.header["fontType"] end,
				set = function(info, value) CO.db.profile.tooltip.header["fontType"] = value; TT:UpdateFonts(); end,
				disabled = DisabledFunc,
			},
			bodyFontType = {
				name = "Body Font Type",
				dialogControl = "LSM30_Font",
				type = "select",
				desc = L["FontType"],
				order = 3,
				values = CO.AceGUIWidgetLSMlists["font"],
				get = function(info) return CO.db.profile.tooltip.body["fontType"] end,
				set = function(info, value) CO.db.profile.tooltip.body["fontType"] = value; TT:UpdateFonts(); end,
				disabled = DisabledFunc,
			},
			statusbarFontType = {
				name = "Health Font Type",
				dialogControl = "LSM30_Font",
				type = "select",
				desc = L["FontType"],
				order = 4,
				values = CO.AceGUIWidgetLSMlists["font"],
				get = function(info) return CO.db.profile.tooltip.statusbar["fontType"] end,
				set = function(info, value) CO.db.profile.tooltip.statusbar["fontType"] = value; TT:UpdateFonts(); end,
				disabled = DisabledFunc,
			},
			headerFontSize = {
				order = 10,
				type = 'range',
				name = "Header Font height",
				desc = "Font height of the first Tooltip line",
				softMin = 3, softMax = 50, step = 1,
				min = 3, max = 90,
				get = function(info) return CO.db.profile.tooltip.header["fontSize"] end,
				set = function(info, value) CO.db.profile.tooltip.header["fontSize"] = value; TT:UpdateFonts(); end,
				disabled = DisabledFunc,
			},
			bodyFontSize = {
				order = 11,
				type = 'range',
				name = "Body Font height",
				desc = "Font height of everything below the first Tooltip line",
				softMin = 3, softMax = 50, step = 1,
				min = 3, max = 90,
				get = function(info) return CO.db.profile.tooltip.body["fontSize"] end,
				set = function(info, value) CO.db.profile.tooltip.body["fontSize"] = value; TT:UpdateFonts(); end,
				disabled = DisabledFunc,
			},
			statusbarFontSize = {
				order = 12,
				type = 'range',
				name = "Health Font height",
				desc = "Font height of everything below the first Tooltip line",
				softMin = 3, softMax = 50, step = 1,
				min = 3, max = 90,
				get = function(info) return CO.db.profile.tooltip.statusbar["fontSize"] end,
				set = function(info, value) CO.db.profile.tooltip.statusbar["fontSize"] = value; TT:UpdateFonts(); end,
				disabled = DisabledFunc,
			},
			headerFontFlags = {
				name = "Header Font Flags",
				type = "select",
				order = 13,
				values = CD.FontFlags,
				get = function(info) return CO.db.profile.tooltip.header["fontFlags"] end,
				set = function(info, value) CO.db.profile.tooltip.header["fontFlags"] = value; TT:UpdateFonts(); end,
				disabled = DisabledFunc,
			},
			bodyFontFlags = {
				name = "Body Font Flags",
				type = "select",
				order = 14,
				values = CD.FontFlags,
				get = function(info) return CO.db.profile.tooltip.body["fontFlags"] end,
				set = function(info, value) CO.db.profile.tooltip.body["fontFlags"] = value; TT:UpdateFonts(); end,
				disabled = DisabledFunc,
			},
			statusbarFontFlags = {
				name = "Health Font Flags",
				type = "select",
				order = 15,
				values = CD.FontFlags,
				get = function(info) return CO.db.profile.tooltip.statusbar["fontFlags"] end,
				set = function(info, value) CO.db.profile.tooltip.statusbar["fontFlags"] = value; TT:UpdateFonts(); end,
				disabled = DisabledFunc,
			},

			bgHeader = {
				order = 21,
				type = "header",
				name = L["General"],
			},
			rgba = {
				order = 22,
				type = 'color',
				name = "Background Color",
				desc = "Background Color",
				hasAlpha = true,
				get = function() return unpack(CO.db.profile.tooltip.background.rgba) end,
				set = function(info, r, g, b, a)
					local Config = CO.db.profile.tooltip.background.rgba
					Config[1] = r
					Config[2] = g
					Config[3] = b
					Config[4] = a
				end,
				disabled = DisabledFunc,
			},
			itemHeader = {
				order = 30,
				type = "header",
				name = "Items",
			},
			showItemCounts_Ark = {
				type = "toggle",
				order = 31,
				width = "double",
				name = "[ArkInventory] Show Item Counts",
				desc = "Controls the state of the ArkInventory Item Counts in the Tooltip",
				get = function() return ArkInventory and ArkInventory.db.option.tooltip.itemcount.enable end,
				set = function(info, value) 
					if not ArkInventory then return end
					ArkInventory.db.option.tooltip.itemcount.enable = value
				end,
				hidden = function() return not ArkInventory end,
			},
			showItemCounts_Bagnon = {
				type = "toggle",
				order = 32,
				width = "double",
				name = "[Bagnon] Show Item Counts",
				desc = "Controls the state of the Bagnon Item Counts in the Tooltip",
				get = function() return Bagnon and Bagnon.sets.tipCount end,
				set = function(info, value) 
					if not Bagnon then return end
					Bagnon.sets.tipCount = value
				end,
				hidden = function() return not Bagnon end,
			},
			newLine = CD:GetNewLine(35),
			showItemCounts = {
				type = "toggle",
				order = 36,
				width = "double",
				name = "Show Item Account Counts",
				desc = "When enabled, you're shown item counts of all your characters for the shown item in the tooltip - under the condition of the same realmpool and faction.\n\nIs not active when ArkInventory, or Bagnon have this feature enabled on their own!\n\nTo update the database this functionality pulls its data from, 'Log Character Items' in the global section has to be enabled!",
				get = function() return CO.db.profile.tooltip.showItemCounts end,
				set = function(info, value) CO.db.profile.tooltip.showItemCounts = value end,
				disabled = function()
					return (ArkInventory and ArkInventory.db.option.tooltip.itemcount.enable) or (Bagnon and Bagnon.sets.tipCount)
				end,
			},
		},
		
	}
end

CD:RegisterConfigModule(Module, 'Advanced')