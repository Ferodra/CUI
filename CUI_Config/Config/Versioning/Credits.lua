local E, L = unpack(CUI) -- Engine
local CD = E:LoadModules("Config_Dialog")

CD.Options.args.credits = {
	type = "group",
	name = '|cff1784d1' .. 'Credits' .. '|r',
	order = -2,
	args = {
		Banner = {
			type = "description",
			name = "",
			image = [[Interface\AddOns\CUI\Textures\CUILogo]],
			imageWidth = 128,
			imageHeight = 128,
			width = "full",
			order = 1,
		},
		Description = {
			type = "description",
			name = "|cff1784d1" .. L["CREDITS_CUIDESC"] .. "|r",
			fontSize = "medium",
			order = 2,
		},
		Icon = {
			type = "description",
			name = "|cff1784d1" .. L["CREDITS_DEVELOPEDBY"] .. "|r",
			order = 3,
		},
		ThanksTo = {
			type = "description",
			name = "|cff1784d1\n\n" .. L["CREDITS_THANKSTO"] .. "|r",
			fontSize = "small",
			order = 4,
		},
		Discord = {
			type = "execute",
			name = "|cff1784d1We not got an official Discord Server!\nClick the Logo to show the invite Link!\n\nThe Discord Logo is courtesy of Discord inc.|r",
			width = 1.2,
			func = function()
				E:LoadModule('Chat'):ShowLink("https://discord.gg/6RN8Qt7|r")
			end,
			image = function()
				return [[Interface\AddOns\CUI\Textures\Discord]], 200, 50
			end,
			--fontSize = "small",
			order = 5,
		},
	},
}