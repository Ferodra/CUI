local E, L = unpack(CUI) -- Engine
local CO, CD = E:LoadModules("Config", "Config_Dialog")

local function CallUpdate(mover)
	xpcall(E.LoadMoverPositions, geterrorhandler(), mover)
end

-- This provides a full config table for a specified mover (name)
-- It also allows to basically disable the mover functionality and attach it to any frame
-- We unfortunately only can use this method when the mover name immediately is available
-- Needs order from start + 6
function CD:GetMoverOptions(mover, order, attach, disabledFunc)
	
	local attachHiddenFunc = function() return not attach or CO.db.profile.movers[mover]["enableAttach"] == false end
	
	local config = {
		['enableAttach_' .. order + 1] = {
			type = "toggle",
			order = order + 1,
			name = L["AttachMode"],
			desc = "By enabling this option, this element will be attached to the specified one. When attached, there will be no mover for the source element, as it is no longer needed.",
			width = "full",
			hidden = not attach,
			set = function(info, value)
				CO.db.profile.movers[mover]["enableAttach"] = value
				CallUpdate(mover)
			end,
			get = function(info) return CO.db.profile.movers[mover]["enableAttach"] end,
			disabled = disabledFunc,
		},
		['attachGroup_' .. order + 2] = {
			type = "group",
			order = order + 2,
			guiInline = true,
			name = L["AttachToFrame"],
			hidden = attachHiddenFunc,
			args = {
				['attachFrame_' .. order + 2] = {
					type = "input",
					order = order + 2,
					name = L["AttachToFrame"],
					desc = "A frame name for attaching this element to.",
					width = "double",
					set = function(info, value) CO.db.profile.movers[mover]["attachTo"][1] = value end,
					get = function(info) 
						CallUpdate(mover)
						
						if not CO.db.profile.movers[mover]["attachTo"] then CO.db.profile.movers[mover]["attachTo"] = {""} end
						return CO.db.profile.movers[mover]["attachTo"][1]
					end,
					disabled = disabledFunc,
					hidden = attachHiddenFunc,
				},
				['attachFrameSelect_' .. order + 3] = {
					type = "execute",
					order = order + 3,
					name = L["FrameChooserButton"],
					func = function()
						CD:ToggleFrameChooser(CO.db.profile.movers[mover]["attachTo"])
						GameTooltip:Hide()
					end,
					disabled = attachDisabledFunc,
					hidden = attachHiddenFunc,
				},
			},
		},
		['position_' .. order + 4] = {
			type = 'select',
			order = order + 4,
			name = L["Position"],
			desc = "Repositions this frame to a specific corner of the current attachment element. Keep in mind your offsets when wondering where they went!",
			values = E.Positions,
			get = function(info)
				return CO.db.profile.movers[mover]["point"]
			end,
			set = function(info, value)
					CO.db.profile.movers[mover]["point"] = value
					CO.db.profile.movers[mover]["relativePoint"] = value
					CallUpdate(mover)
			end,
			disabled = disabledFunc,
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
					CallUpdate(mover)
			end,
			disabled = disabledFunc,
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
					CallUpdate(mover)
			end,
			disabled = disabledFunc,
		},
	}
	
	return config
end

-- {{MoverName, Order, Path}, {MoverName, Order, Path}}
function CD:AddMoverConfigs(Data)
	for k,v in pairs(Data) do
		-- Getting a direct ref to the table is of upmost importance, as it's the only way to make this work
		local Tbl = E:GetTableByPath(v[3], CD)
		for dataKey, data in pairs(CD:GetMoverOptions(v[1], v[2])) do
			Tbl[dataKey] = data
		end 
	end
end