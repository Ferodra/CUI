local E, L = unpack(CUI) -- Engine
local CO, CD, L = E:LoadModules("Config", "Config_Dialog", "Locale")

local Index = 99999

CD:InitializeOptionsCategory("dataframes", "Infoframes", Index)

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
			set = function(info, value) CO.db.profile.dataframes["raidroledata"][ info[#info] ] = value; E:GetModule("RaidRoleData"):LoadProfile() end,
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
					func = function() E:GetModule("RaidRoleData"):Toggle() end,
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
				},
				clickThrough = {
					order = 22,
					type = "toggle",
					name = L["ClickThrough"],
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
						E:GetModule("RaidRoleData"):LoadProfile();
					end,
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
						E:GetModule("RaidRoleData"):LoadProfile();
					end,
				},
			}
		},
		raidControl = {
			order = 2,
			type = 'group',
			name = L["RaidControl"],
			get = function(info) return CO.db.profile.dataframes["raidControl"][ info[#info] ] end,
			set = function(info, value) CO.db.profile.dataframes["raidControl"][ info[#info] ] = value; E:GetModule("RaidControl"):LoadProfile() end,
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
					func = function() E:GetModule("RaidControl"):TogglePanel(); end,
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
				},
				pullOnEnter = {
					type = "toggle",
					order = 22,
					name = "Start Pull on Enter",
					desc = "If enabled, the pull timer will be started when you press the Enter key while typing in the pull time input field"
				},
			}
		},
		mirrorTimer = {
			order = 3,
			type = 'group',
			name = L["MirrorTimer"],
			get = function(info) return CO.db.profile.dataframes.mirrorTimer[ info[#info] ] end,
			set = function(info, value) CO.db.profile.dataframes.mirrorTimer[ info[#info] ] = value; end,
			args = {
				positionHeader = {
					type = "header",
					order = 1,
					name = L["Positioning"],
				},
			}
		},
	},
	
}

for k,v in pairs(CD:GetMoverOptions("RaidRoleFrameMover", 11, true)) do
	CD.Options.args.dataframes.args.raidroledata.args[k] = v
end

for k,v in pairs(CD:GetMoverOptions("RaidControlFrameMover", 11, true)) do
	CD.Options.args.dataframes.args.raidControl.args[k] = v
end

for k,v in pairs(CD:GetMoverOptions("MirrorTimerHolderMover", 11, true)) do
	CD.Options.args.dataframes.args.mirrorTimer.args[k] = v
end