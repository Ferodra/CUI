local E, L = unpack(select(2, ...)) -- Engine, Locale
local ItemDB = E:LoadModules('ItemDB')

local Defaults = {
	["global"] = {
		["data"] = {
			["WARBANK"] = {
				['items'] = {},
				['currency'] = {},
			},
			["characters"] = {},
		},
	},
}

function ItemDB:SetDefaults()
	self.Defaults = Defaults
end