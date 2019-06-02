local E, L = unpack(select(2, ...)) -- Engine, Locale
local TT = E:LoadModules("Tooltip")

--[[--------------------------------
	
	A collection of different
	tooltip styles.
	
	Those are the default values
	used for the style system.
	
	We later can provide options
	for each single type

--------------------------------]]--

TT.TooltipStyles = {
	["Default"] = {
		["BorderR"] 	= 0.4,
		["BorderG"] 	= 0.4,
		["BorderB"] 	= 0.4,
		["BorderA"] 	= 1,
		["OverrideBorder"] 	= true, -- If the border color should be changed
		["BorderSize"] 	= 1, -- Can also be negative
		
		["BackgroundR"] = 0.15,
		["BackgroundG"] = 0.15,
		["BackgroundB"] = 0.15,
		["BackgroundA"] = 0.6,
	},
	["Aura"] = {
		["BorderR"] 	= 0.9,
		["BorderG"] 	= 0.9,
		["BorderB"] 	= 0.9,
		["BorderA"] 	= 1,
		["OverrideBorder"] 	= true,
		
		["BackgroundR"] = 0.15,
		["BackgroundG"] = 0.15,
		["BackgroundB"] = 0.15,
		["BackgroundA"] = 0.35,
		["BorderSize"] 	= 1,
	},
	["Item"] = {
		["BorderR"] 	= 1,
		["BorderG"] 	= 1,
		["BorderB"] 	= 1,
		["BorderA"] 	= 0.35,
		["BorderSize"] 	= 1,
		["OverrideBorder"] 	= true,
		
		["BackgroundR"] = 0.1,
		["BackgroundG"] = 0.1,
		["BackgroundB"] = 0.1,
		["BackgroundA"] = 1,
	},
	["Spell"] = {
		["BorderR"] 	= 1,
		["BorderG"] 	= 1,
		["BorderB"] 	= 1,
		["BorderA"] 	= 1,
		["BorderSize"] 	= 1,
		["OverrideBorder"] 	= true,
		
		["BackgroundR"] = nil,
		["BackgroundG"] = nil,
		["BackgroundB"] = nil,
		["BackgroundA"] = 1,
	},
	["Unit"] = {
		["BorderR"] 	= 1,
		["BorderG"] 	= 1,
		["BorderB"] 	= 1,
		["BorderA"] 	= 1,
		["BorderSize"] 	= 1,
		["OverrideBorder"] 	= true,
		
		["BackgroundR"] = nil,
		["BackgroundG"] = nil,
		["BackgroundB"] = nil,
		["BackgroundA"] = 0.35,
	}
}
TT.CurrentTooltipStyle = {
	["Default"]	= {},
	["Aura"]	= {},
	["Item"] 	= {},
	["Spell"] 	= {},
	["Unit"] 	= {},
}