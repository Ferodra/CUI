local E, L = unpack(CUI) -- Engine
local CD, L = E:LoadModules("Config_Dialog", "Locale")

local FAQ = {
	type = "group",
	name = "|cff1784d1FAQ|r",
	order = 100,
	args = {
		WorldFonts = {
			type = "description",
			name = "I've changed one of the World-Fonts, but it does not seem to apply.\n|cff1784d1This feature requires you to at least perform a relog, to make any changes.\nNote that not every font will work for this, as the AddOn load-order is really important for that one. Check the 'ArtLib.lua' in the CUI Core files for more information on how to get it working.|r",
			order = 1,
		},
		FocusSet = {
			type = "description",
			name = "How do i set a focus directly without right-clicking it first?\n|cff1784d1You can always Shift-Leftclick a unitframe to mark it as your focus target. Shift-Leftclick the focus unitframe to remove it again.|r",
			order = 2,
		},
		BugReport = {
			type = "description",
			name = "I've found this weird bug and don't know what to do!\n|cff1784d1If you encounter a strange issue with CUI, it often is resolved by a relog or '/reload'.\nIf you want to, you can also report this bug in the Curse project-page along with information about that exactly you did as it occured. It helps further development of CUI.|r",
			order = 3,
		},
		DisableUnitframes = {
			type = "description",
			name = "I want to disable a unitframe and can't seem to find any option for that!\n|cff1784d1As of 0.8.0r, there indeed is no option to disable normal unitframes directly. Instead you can modify the visibility of clustered unitframes (Arena, Party, Raid, Raid40, Boss) to '0' (without the quotes), so it will never appear. Click the 'Default Visibility' Button below this option to restore the default.|r",
			order = 4,
		},
		Installation = {
			type = "description",
			name = "What about this 'Install' button?\n|cff1784d1This is a feature that has yet to come. Chanches are high that it will be released along 1.0.0r, as it will be a lot of work and would be too much to implement newer features into the system then.|r",
			order = 5,
		},
		Default = {
			type = "description",
			name = "I want to get back the original Micromenu/Minimap/Bags/... !\n|cff1784d1There currently is no way of simply disabling the skin of the modified frames. That has yet to come. It also is already planned to modify the look of frames like the Game-Menu, Quest-Frames, etc. but i want to tackle that topic as good as possible and that will take a lot of further research to do.|r",
			order = 6,
		},
	},
}

local Global = {
	type = "group",
	name = "|cff1784d1Global|r",
	order = 200,
	args = {
		PersonalNameplate = {
			type = "header",
			name = "Personal Nameplate",
			order = 1,
		},
		PersonalNameplateDesc = {
			type = "description",
			name = "|cff1784d1By enabling this option, you are being shown the Blizzard default player nameplate just below your character!|r",
			image = [[Interface\AddOns\CUI_Config\Textures\Documentation\PersonalNameplate]],
			imageWidth = 256,
			imageHeight = 128,
			order = 2,
		},
		WorldFonts = {
			type = "header",
			name = "World Fonts",
			order = 10,
		},
		Welcome = {
			type = "description",
			name = "|cff1784d1Please note that the AddOn load-order plays a significant role for this feature, as CUI has to load the selected font as soon as possible!\nTo get any fonts working that are not, check out the 'ArtLib.lua' in the CUI Core files and follow the instructions to add your desired font.|r",
			fontSize = "small",
			order = 11,
		},
		WorldFontsDesc = {
			type = "description",
			name = "|cff1784d1|r",
			image = [[Interface\AddOns\CUI_Config\Textures\Documentation\WorldFonts]],
			imageWidth = 512,
			imageHeight = 256,
			order = 12,
		},
	},
}

CD.Options.args.help = {
	type = "group",
	name = "|cff1784d1Help|r",
	order = -1,
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
		Welcome = {
			type = "description",
			name = "|cff1784d1Welcome to the CUI options documentation!\nHow can i help you?|r",
			fontSize = "large",
			order = 2,
		},
		
		FAQGroup	= FAQ,
		GlobalGroup = Global,
	},
}