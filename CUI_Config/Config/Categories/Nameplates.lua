local E, L = unpack(CUI) -- Engine
local CO, CD, L = E:LoadModules("Config", "Config_Dialog", "Locale")

CD.Options.args.nameplates = {
	name = L["Nameplates"],
	type = 'group',
	order = 99999,
	childGroups = "tab",
	args = {
		main = {
			order = 1,
			type = 'group',
			name = L["General"],
			get = function(info) return CO.db.profile.nameplates[ info[#info] ] end,
			set = function(info, value) CO.db.profile.nameplates[ info[#info] ] = value; E:GetModule("Nameplates"):LoadProfile() end,
			args = {
				showPlayerNameplate = {
					type = "toggle",
					order = 1,
					name = L["Personal Nameplate"],
					desc = L["Enable/Disable the Blizzard default personal nameplate in the center of the screen"],
					get = function() return CO.db.profile.CVars.nameplateShowSelf end,
					set = function(info, value) CO.db.profile.CVars.nameplateShowSelf = value; SetCVar("nameplateShowSelf", value) end,
				},
				
				--newLine = {type="description", name="", order=10},
				Module = {type="header",name="Nameplate Module",order=10},
				
				enableOverride = {
					type = "toggle",
					order = 11,
					name = "Enable Module",
					desc = "When enabled, CUI will handle most of the nameplate functionality",
					get = function() return CO.db.profile.nameplates.enable end,
					set = function(info, value) CO.db.profile.nameplates.enable = value; CD:ShowNotification("RELOAD_NOTIFICATION") end,
				},
				newLine = {type="description", name="", order=15},
				barWidth = {
					type = "range",
					order = 16,
					name = "Bar Width",
					desc = "The Width of the Nameplate Healthbar",
					min = 5, max = 500, step = 1,
					disabled = function() return not CO.db.profile.nameplates.enable end,
				},
				barHeight = {
					type = "range",
					order = 17,
					name = "Bar Height",
					desc = "The Height of the Nameplate Healthbar",
					min = 5, max = 500, step = 1,
					disabled = function() return not CO.db.profile.nameplates.enable end,
				},
				
				newLine2 = {type="description", name="", order=20},
				
				clickableWidth = {
					type = "range",
					order = 21,
					name = "Clickable Width",
					desc = "Controls, what area of the nameplate you are able to click",
					min = 5, max = 500, step = 1,
					disabled = function() return not CO.db.profile.nameplates.enable end,
				},
				clickableHeight = {
					type = "range",
					order = 22,
					name = "Clickable Height",
					desc = "Controls, what area of the nameplate you are able to click",
					min = 5, max = 500, step = 1,
					disabled = function() return not CO.db.profile.nameplates.enable end,
				},
				
			},
		},
	},
	
}

local Fonts = {{Path = "db.profile.nameplates.name", Order = 100, GroupName = L["Name"]}}
for k,v in pairs(CD:GetFontOptions(Fonts)) do
	CD.Options.args.nameplates.args[k] = v
end
Fonts = {{Path = "db.profile.nameplates.health", Order = 200, GroupName = L["Health"]}}
for k,v in pairs(CD:GetFontOptions(Fonts)) do
	CD.Options.args.nameplates.args[k] = v
end
Fonts = {{Path = "db.profile.nameplates.level", Order = 300, GroupName = L["Level"]}}
for k,v in pairs(CD:GetFontOptions(Fonts)) do
	CD.Options.args.nameplates.args[k] = v
end

CD.Options.args.nameplates.args[L["Name"]].args.fontColor.hidden = true
CD.Options.args.nameplates.args[L["Level"]].args.fontColor.hidden = true

CD.Options.args.nameplates.args[L["Name"]].disabled = function() return not CO.db.profile.nameplates.enable end
CD.Options.args.nameplates.args[L["Health"]].disabled = function() return not CO.db.profile.nameplates.enable end
CD.Options.args.nameplates.args[L["Level"]].disabled = function() return not CO.db.profile.nameplates.enable end