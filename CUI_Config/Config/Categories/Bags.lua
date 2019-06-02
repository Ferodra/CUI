local E, L = unpack(CUI) -- Engine
local CO, CD, L = E:LoadModules("Config", "Config_Dialog", "Locale")

CD.Options.args.bags = {
	name = L["Bags"],
	type = 'group',
	order = 99999,
	childGroups = "tab",
	args = {
		main = {
			order = 1,
			type = 'group',
			name = L["General"],
			get = function(info) return CO.db.profile.bags[ info[#info] ] end,
			set = function(info, value) CO.db.profile.bags[ info[#info] ] = value; E:GetModule("Bags"):LoadProfile() end,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					width = "full",
				},
				positionHeader = {
					type = "header",
					order = 10,
					name = L["Positioning"],
				},
				styleHeader = {
					type = "header",
					order = 20,
					name = L["Styling"],
				},
				buttonsPerRow = {
					order = 21,
					type = 'range',
					name = L["ButtonsPerRow"],
					desc = L["ButtonsPerRowDesc"],
					min = -5, max = 5, step = 1,
					disabled = function() return not CO.db.profile.bags.enable end,
				},
				buttonSizeMultiplier = {
					order = 22,
					type = 'range',
					name = L["ButtonSize"],
					desc = L["ButtonSizeDesc"],
					min = 0.1, max = 5, step = 0.05,
					disabled = function() return not CO.db.profile.bags.enable end,
				},
				buttonGap = {
					order = 23,
					type = 'range',
					name = L["ButtonGap"],
					desc = L["ButtonGapDesc"],
					min = -50, max = 50, step = 1,
					disabled = function() return not CO.db.profile.bags.enable end,
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
					get = function() return CO.db.profile.bags.useMasque end,
					set = function(info, value) CO.db.profile.bags.useMasque = value; CD:ShowNotification("RELOAD_NOTIFICATION") end,
				},
			},
		},
		utility = {
			order = 10,
			type = 'group',
			name = L["Utility"],
			args = {
				sellGreys = {
					type = "toggle",
					order = 1,
					name = L["Autosell Greys"],
					desc = L["When enabled, grey items from your bag will automatically be sold"],
					get = function() return CO.db.profile.utility.autoSellGreys end,
					set = function(info, value) CO.db.profile.utility.autoSellGreys = value; E:GetModule("Misc_Features"):LoadProfile(); end,
				},
				sellGreysReport = {
					type = "toggle",
					order = 2,
					name = L["Autosell Greys Report"],
					desc = L["Reports what has been sold and how much revenue you earned"],
					get = function() return CO.db.profile.utility.autoSellGreysReport end,
					set = function(info, value) CO.db.profile.utility.autoSellGreysReport = value; end,
					disabled = function() return not CO.db.profile.utility.autoSellGreys end,
				},
			},
		},
	},
	
}

for k,v in pairs(CD:GetMoverOptions("CUI_BagBarHolderMover", 11, true)) do
	CD.Options.args.bags.args.main.args[k] = v
end