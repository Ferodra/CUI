local E, L = unpack(CUI) -- Engine
local CO, CD, L = E:LoadModules("Config", "Config_Dialog", "Locale")

-- This provides a full config table for a specified mover (name)
-- It also allows to basically disable the mover functionality and attach it to any frame
-- We unfortunately only can use this method when the mover name immediately is available
-- Needs order from start + 6
function CD:GetMoverOptions(mover, order, attach)
	local config = {
		['enableAttach_' .. order + 1] = {
			type = "toggle",
			order = order + 1,
			name = L["AttachMode"],
			desc = "By enabling this option, this element will be attached to the specified one. When attached, there will be no mover for the source element, as it is no longer needed.",
			width = "full",
			hidden = not attach,
			set = function(info, value) CO.db.profile.movers[mover]["enableAttach"] = value end,
			get = function(info) return CO.db.profile.movers[mover]["enableAttach"] end,
		},
		['attachFrame_' .. order + 2] = {
			type = "input",
			order = order + 2,
			name = L["AttachToFrame"],
			desc = "A frame name for attaching this element to.",
			width = "double",
			hidden = not attach,
			set = function(info, value) CO.db.profile.movers[mover]["attachTo"][1] = value end,
			get = function(info) 
				xpcall(E.LoadMoverPositions, geterrorhandler(), mover)
				
				if not CO.db.profile.movers[mover]["attachTo"] then CO.db.profile.movers[mover]["attachTo"] = {""} end
				return CO.db.profile.movers[mover]["attachTo"][1]
			end,
			disabled = function() return CO.db.profile.movers[mover]["enableAttach"] == false end,
		},
		['attachFrameSelect_' .. order + 3] = {
			type = "execute",
			order = order + 3,
			name = L["FrameChooserButton"],
			hidden = not attach,
			func = function()
				CD:ToggleFrameChooser(CO.db.profile.movers[mover]["attachTo"])
				GameTooltip:Hide()
			end,
			disabled = function() return CO.db.profile.movers[mover]["enableAttach"] == false end,
		},
		['position_' .. order + 4] = {
			type = 'select',
			order = order + 4,
			name = "Position",
			desc = "Repositions this frame to a specific corner of the current attachment element. Keep in mind your offsets when wondering where they went!",
			values = E.Positions,
			get = function(info)
				return CO.db.profile.movers[mover]["point"]
			end,
			set = function(info, value)
					CO.db.profile.movers[mover]["point"] = value
					CO.db.profile.movers[mover]["relativePoint"] = value
					xpcall(E.LoadMoverPositions, geterrorhandler(), mover)
			end,
		},
		['xOffset_' .. order + 5] = {
			order = order + 5,
			type = 'range',
			name = L["XOffset"],
			desc = "Moves this frame along the X axis [horizontal]\n\nSupports hard values from -5000 to 5000",
			softMin = -500, softMax = 500, step = 1,
			min = -5000, max = 5000, step = 1,
			get = function(info)
				return CO.db.profile.movers[mover]["xOffset"]
			end,
			set = function(info, value)
					CO.db.profile.movers[mover]["xOffset"] = value
					xpcall(E.LoadMoverPositions, geterrorhandler(), mover)
			end,
		},
		['yOffset_' .. order + 6] = {
			order = order + 6,
			type = 'range',
			name = L["YOffset"],
			desc = "Moves this frame along the Y axis [vertical]\n\nSupports hard values from -5000 to 5000",
			softMin = -500, softMax = 500, step = 1,
			min = -5000, max = 5000, step = 1,
			get = function(info)
				return CO.db.profile.movers[mover]["yOffset"]
			end,
			set = function(info, value)
					CO.db.profile.movers[mover]["yOffset"] = value
					xpcall(E.LoadMoverPositions, geterrorhandler(), mover)
			end,
		},
	}
	
	return config
end