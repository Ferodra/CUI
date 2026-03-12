local E, L = unpack(CUI) -- Engine
local CO, CD = E:LoadModules("Config", "Config_Dialog")

local _
local Module = {}

function Module:Disable()
	CD.Options.args.nameplates = nil
end

function Module:Enable()
	
	local QI_DisabledFunc = function() return not CO.db.profile.nameplates.questIcon.enable end
	
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
				set = function(info, value) CO.db.profile.nameplates[ info[#info] ] = value; E:LoadModule("Nameplates"):LoadConfig() end,
				args = {
					showPlayerNameplate = {
						type = "toggle",
						order = 1,
						name = DISPLAY_PERSONAL_RESOURCE,
						desc = L["Personal Nameplate Desc"] .. " " .. L["CVarsDesc"],
						get = function() return E:GetBlizzCVar("nameplateShowSelf", true) end,
						set = function(info, value) CO.db.profile.CVars.nameplateShowSelf = value; SetCVar("nameplateShowSelf", value, DISPLAY_PERSONAL_RESOURCE) end,
					},
					nameplateShowAll = {
						type = "toggle",
						order = 2,
						name = UNIT_NAMEPLATES_AUTOMODE,
						desc = L["ShowAllNameplatesDesc"] .. " " .. L["CVarsDesc"],
						get = function() return E:GetBlizzCVar("nameplateShowAll", true) end,
						set = function(info, value) CO.db.profile.CVars.nameplateShowAll = value; SetCVar("nameplateShowAll", value, "UNIT_NAMEPLATES_AUTOMODE") end,
					},
					
					--newLine = {type="description", name="", order=10},
					Module = {type="header",name="Nameplate Module",order=10},
					
					enableOverride = {
						type = "toggle",
						order = 11,
						name = L["EnableModule"],
						desc = "When enabled, CUI will handle most of the nameplate functionality",
						get = function() return CO.db.char.nameplates.enable end,
						set = function(info, value) CO.db.char.nameplates.enable = value; CD:ShowNotification("CHARACTERSETTING_NOTIFICATION") end,
					},
					newLine = {type="description", name="", order=15},
					barWidth = {
						type = "range",
						order = 16,
						name = "Bar Width",
						desc = "The Width of the Nameplate Healthbar",
						min = 5, max = 500, step = 1,
						hidden = function() return not CO.db.char.nameplates.enable end,
					},
					barHeight = {
						type = "range",
						order = 17,
						name = "Bar Height",
						desc = "The Height of the Nameplate Healthbar",
						min = 5, max = 500, step = 1,
						hidden = function() return not CO.db.char.nameplates.enable end,
					},
					
					newLine2 = {type="description", name="", order=20},
					
					clickableWidth = {
						type = "range",
						order = 21,
						name = "Clickable Width",
						desc = "Controls, what area of the nameplate you are able to click",
						min = 5, max = 500, step = 1,
						hidden = function() return not CO.db.char.nameplates.enable end,
					},
					clickableHeight = {
						type = "range",
						order = 22,
						name = "Clickable Height",
						desc = "Controls, what area of the nameplate you are able to click",
						min = 5, max = 500, step = 1,
						hidden = function() return not CO.db.char.nameplates.enable end,
					},
					
				},
			},
			
			questIcon = {
				order = 400,
				type = 'group',
				name = "Quest Icon",
				get = function(info) return CO.db.profile.nameplates.questIcon[ info[#info] ] end,
				set = function(info, value) CO.db.profile.nameplates.questIcon[ info[#info] ] = value; E:LoadModule("Nameplates"):LoadConfig() end,
				args = {
					enable = {
						type = "toggle",
						order = 1,
						name = L["Enable"],
					},
					onlyShowQuests = {
						type = "toggle",
						order = 1.2,
						name = "Only Show Quests",
						desc = "When enabled, the icon only will be shown for actual quests. Disable to also show for Worldquests and Bonus Areas\n\nNOTE: This function is currently slightly bugged. When first turning it off, while Worldquest targets are visible, the icon wouldn't show up immediately. This is fixed by turning the camera away once. This doesn't happen the other way around.",
					},
					newLine = {type="description", name="", order=1.5},
					scale = {
						order = 2,
						type = 'range',
						name = L["Scale"],
						min = 0.1, max = 5, step = 0.01,
						disabled = QI_DisabledFunc,
					},
					positionHeader = {
						type = "header",
						order = 5,
						name = L["Positioning"],
					},
					position = {
						type = 'select',
						order = 6,
						name = L["Position"],
						desc = "Repositions this frame to a specific corner of the current attachment element. Keep in mind your offsets when wondering where they went!",
						values = E.Positions,
						disabled = QI_DisabledFunc,
					},
					xOffset = {
						order = 7,
						type = 'range',
						name = L["XOffset"],
						desc = "Moves this frame along the X axis [horizontal]\n\nSupports hard values from -5000 to 5000",
						softMin = -500, softMax = 500, step = 1,
						min = -5000, max = 5000, step = 1,
						disabled = QI_DisabledFunc,
					},
					yOffset = {
						order = 8,
						type = 'range',
						name = L["YOffset"],
						desc = "Moves this frame along the Y axis [vertical]\n\nSupports hard values from -5000 to 5000",
						softMin = -500, softMax = 500, step = 1,
						min = -5000, max = 5000, step = 1,
						disabled = QI_DisabledFunc,
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

	CD.Options.args.nameplates.args[L["Name"]].disabled = function() return not CO.db.char.nameplates.enable end
	CD.Options.args.nameplates.args[L["Health"]].disabled = function() return not CO.db.char.nameplates.enable end
	CD.Options.args.nameplates.args[L["Level"]].disabled = function() return not CO.db.char.nameplates.enable end
end

CD:RegisterConfigModule(Module, 'Advanced')