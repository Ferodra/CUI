local E, L = unpack(CUI) -- Engine
local CD = E:LoadModules("Config_Dialog")

local _
local StartIndex = 100
local IndexStep = 50
local Indexes = {}

function CD:SortCategories()
	wipe(Indexes)
	
	for _, option in pairs(self.Options.args) do
		-- We use order 99999 for auto sort
		if option.name ~= "" and option.type == "group" and option.order == CD:GetAutoSortIndex() then
			table.insert(Indexes, option.name)
		end
	end

	sort(Indexes, function (a, b)
		if a < b then
			return true
		elseif b > a then
			return false
		end
	end)

	for i = 1, #Indexes do
		for _, option in pairs(self.Options.args) do
			if option.name == Indexes[i] then
				option.order = StartIndex + (IndexStep * i)
			end
		end
	end
end