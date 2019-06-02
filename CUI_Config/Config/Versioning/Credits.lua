local E, L = unpack(CUI) -- Engine
local CD, L = E:LoadModules("Config_Dialog", "Locale")

CD.Options.args.credits = {
	type = "group",
	name = "Credits",
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
			type = "description",
			name = "|cff1784d1\n\n\nWe now got an official Discord Server!|r\nhttps://discord.gg/6RN8Qt7|r",
			fontSize = "small",
			order = 5,
		},
	},
}