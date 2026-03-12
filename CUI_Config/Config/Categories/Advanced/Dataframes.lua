local E, L = unpack(CUI) -- Engine
local CO, CD = E:LoadModules("Config", "Config_Dialog")

local Module = {}
local Index = CD:GetAutoSortIndex()

function Module:Disable()
	CD.Options.args.dataframes = nil
end

local RRD_DisabledFunc 			= function() return not CO.db.profile.dataframes["raidroledata"].enable end
local RaidControl_DisabledFunc 	= function() return not CO.db.profile.dataframes["raidControl"].enable end
local RezCharges_DisabledFunc 	= function() return not CO.db.profile.dataframes["battlerezCharges"].enable end

function Module:Enable()
	CD.Options.args.dataframes = {
	name = L["Infoframes"],
	type = 'group',
	order = Index,
	childGroups = "tab",
	args = {
		raidroledata = {
			order = 1,
			type = 'group',
			name = L["RaidRoles"],
			get = function(info) return CO.db.profile.dataframes["raidroledata"][ info[#info] ] end,
			set = function(info, value) CO.db.profile.dataframes["raidroledata"][ info[#info] ] = value; E:LoadModule("RaidRoleData"):LoadConfig() end,
			args = {
				enable = {
					type = "toggle",
					order = 1,
					name = L["Enable"],
				},
				toggle = {
					order = 2,
					type = "execute",
					name = L["Toggle"],
					func = function() E:LoadModule("RaidRoleData"):Toggle() end,
					disabled = RRD_DisabledFunc,
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
				scale = {
					order = 21,
					type = 'range',
					name = L["Scale"],
					min = 0.1, max = 5, step = 0.01,
					disabled = RRD_DisabledFunc,
				},
				clickThrough = {
					order = 22,
					type = "toggle",
					name = L["ClickThrough"],
					disabled = RRD_DisabledFunc,
				},
				newLine = {type="description", name="", order=30},
				backgroundColor = {
					name = L["BackgroundColor"],
					type = "color",
					hasAlpha = true,
					order = 31,
					get = function(info)
						local c = CO.db.profile.dataframes.raidroledata.backgroundColor
						return c[1], c[2], c[3], c[4]
					end,
					set = function(info, r, g, b, a)
						local c = CO.db.profile.dataframes.raidroledata.backgroundColor
						c[1], c[2], c[3], c[4] = r, g, b, a
						E:LoadModule("RaidRoleData"):LoadConfig();
					end,
					disabled = RRD_DisabledFunc,
				},
				borderColor = {
					name = L["BorderColor"],
					type = "color",
					hasAlpha = true,
					order = 31,
					get = function(info)
						local c = CO.db.profile.dataframes.raidroledata.borderColor
						return c[1], c[2], c[3], c[4]
					end,
					set = function(info, r, g, b, a)
						local c = CO.db.profile.dataframes.raidroledata.borderColor
						c[1], c[2], c[3], c[4] = r, g, b, a
						E:LoadModule("RaidRoleData"):LoadConfig();
					end,
					disabled = RRD_DisabledFunc,
				},
			}
		},
		raidControl = {
			order = 2,
			type = 'group',
			name = L["RaidControl"],
			get = function(info) return CO.db.profile.dataframes["raidControl"][ info[#info] ] end,
			set = function(info, value) CO.db.profile.dataframes["raidControl"][ info[#info] ] = value; E:LoadModule("RaidControl"):LoadConfig() end,
			args = {
				enable = {
					type = "toggle",
					order = 1,
					name = L["Enable"],
				},
				toggle = {
					order = 2,
					type = "execute",
					name = L["Toggle"],
					func = function() E:LoadModule("RaidControl"):TogglePanel(); end,
					disabled = RaidControl_DisabledFunc,
				},
				positionHeader = {
					type = "header",
					order = 10,
					name = L["Positioning"],
				},
				miscHeader = {
					type = "header",
					order = 20,
					name = "Misc",
				},
				scale = {
					order = 21,
					type = 'range',
					name = L["Scale"],
					min = 0.1, max = 5, step = 0.01,
					disabled = RaidControl_DisabledFunc,
				},
				pullOnEnter = {
					type = "toggle",
					order = 22,
					name = "Start Pull on Enter",
					desc = "If enabled, the pull timer will be started when you press the Enter key while typing in the pull time input field",
					disabled = RaidControl_DisabledFunc,
				},
			}
		},
		rezCharges = {
			order = 2,
			type = 'group',
			name = L["BattlerezCharges"],
			childGroups = 'tab',
			get = function(info) return CO.db.profile.dataframes["battlerezCharges"][ info[#info] ] end,
			set = function(info, value) CO.db.profile.dataframes["battlerezCharges"][ info[#info] ] = value; E:LoadModule("BattlerezCharges"):LoadConfig() end,
			args = {
				enable = {
					type = "toggle",
					order = 1,
					name = L["Enable"],
				},
				toggle = {
					order = 1.5,
					type = "execute",
					name = L["Toggle"],
					func = function() E:LoadModule("BattlerezCharges"):Toggle(); end,
					disabled = RezCharges_DisabledFunc,
				},
				Icon = {
					order = 2,
					type = 'group',
					name = L['Icon'],
					disabled = RezCharges_DisabledFunc,
					args = {
						positionHeader = {
							type = "header",
							order = 10,
							name = L["Positioning"],
						},
						-- miscHeader = {
							-- type = "header",
							-- order = 20,
							-- name = "Misc",
						-- },
						size = {
							order = 21,
							type = 'range',
							name = L["Size"],
							min = 8, max = 128, step = 1,
						},
						-- pullOnEnter = {
							-- type = "toggle",
							-- order = 22,
							-- name = "Start Pull on Enter",
							-- desc = "If enabled, the pull timer will be started when you press the Enter key while typing in the pull time input field"
						-- },
						},
				},
			}
		},
	},
	
	}

	for k,v in pairs(CD:GetMoverOptions("RaidRoleFrameMover", 11, true, RRD_DisabledFunc)) do
		CD.Options.args.dataframes.args.raidroledata.args[k] = v
	end

	for k,v in pairs(CD:GetMoverOptions("RaidControlFrameMover", 11, true, RaidControl_DisabledFunc)) do
		CD.Options.args.dataframes.args.raidControl.args[k] = v
	end
	
	for k,v in pairs(CD:GetMoverOptions("CUI_BattlerezChargesMover", 11, true)) do
		CD.Options.args.dataframes.args.rezCharges.args.Icon.args[k] = v
	end
	
	local Fonts = {{Path = "db.profile.dataframes.battlerezCharges.time", Order = 100, GroupName = L["Time"]}, {Path = "db.profile.dataframes.battlerezCharges.charges", Order = 200, GroupName = L["Charges"]}}
	for k,v in pairs(CD:GetFontOptions(Fonts, RezCharges_DisabledFunc)) do
		CD.Options.args.dataframes.args.rezCharges.args[k] = v
	end
	
end

CD:RegisterConfigModule(Module, 'Advanced')