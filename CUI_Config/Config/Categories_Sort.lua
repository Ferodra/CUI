local E, L = unpack(CUI) -- Engine
local CD, L = E:LoadModules("Config_Dialog", "Locale")

local _
local StartIndex = 100
local IndexStep = 50
local Indexes = {}

for _, option in pairs(CD.Options.args) do
	-- We use order 99999 for auto sort
	if option.name ~= "" and option.type == "group" and option.order == 99999 then
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
	for _, option in pairs(CD.Options.args) do
		if option.name == Indexes[i] then
			option.order = StartIndex + (IndexStep * i)
		end
	end
end