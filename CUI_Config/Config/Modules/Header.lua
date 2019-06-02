local E, L = unpack(CUI) -- Engine
local CO, CD, L = E:LoadModules("Config", "Config_Dialog", "Locale")

CD.Options.args = {
		CUIVersion = {
			order = 0,
			type = "description",
			name = ("|cff1784d1Version: %s [Revision %s] - Updated: %s|r"):format(E.Version, E.Revision, E:FormatDate(E.VersionDate)),
			width = "full"
		},
		CUIHeader = {
			order = 1,
			type = "header",
			name = "",
			width = "full",
		},
		LUAErrors = {
			order = 2,
			type = 'toggle',
			name = L["Lua-Errors"],
			desc = L["Lua-ErrorsDesc"],
			get = function(info) return CO.db.profile.LUAErrors or false end,
			set = function(info, value) CO.db.profile.LUAErrors = value end,
		},
		KeybindSetup = {
			order = 3,
			type = 'execute',
			name = L["SetKeybinds"],
			desc = L["SetKeybindsDesc"],
			func = function() CD.KB:Toggle(); CD:CloseOptions(); GameTooltip:Hide() end,
		},
		Install = {
			order = 4,
			type = 'execute',
			name = L["Install"] .. " [TBD]",
			desc = L["InstallDesc"],
			func = function() E:print("This will trigger the installation!") end,
			disabled = true,
		},
		ToggleAnchors = {
			order = 5,
			type = "execute",
			name = L["Toggle Anchors"],
			desc = L["Toggle AnchorsDesc"],
			func = function() CD:CloseOptions(); E:ToggleMover(true); CD:ShowNotification("HANDLE_MOVE_NOTIFICATION"); CD:ToggleMoveGrid(true); GameTooltip:Hide() end,
		},
		ResetAllMovers = {
			order = 6,
			type = "execute",
			name = L["Reset Anchors"],
			desc = L["Reset AnchorsDesc"],
			func = function() CD:ShowNotification("RESET_ANCHORS") end,
		},
}