------------------------------------------------------------------------------------------
-- DO NOT TOUCH CONTENTS BELOW (unless you know what you're doing) !!
------------------------------------------------------------------------------------------
local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, AL = E:LoadModules("Config", "ArtLib")

local _
local AddOnDirectory = [[Interface\AddOns\CUI\]]
local FontDir = AddOnDirectory .. [[Fonts\]]
local TextureDir = AddOnDirectory .. [[Textures\]]
------------------------------------------------------------------------------------------
-- DO NOT TOUCH CONTENTS ABOVE (unless you know what you're doing) !!
------------------------------------------------------------------------------------------

-- BLPNG-Converter: http://www.wowinterface.com/downloads/info22128-BLPNGConverter.html

--[[
	-- General Lua-programming note:
		- double [ stands for a concatenation of letters/symbols/names/ etc.
		- It defines a so called "string" that will not be closed by symbols like " and also registers line breaks.
		- The .. operator is used for string concatenation. Using it like "Hello" .. "World" will result in "HelloWorld".
		
		- Below, you'll find the AL.Fonts and AL.StatusbarTextures tables.
		- A table stores various information - and - in some cases - even other tables and so on.
		- If we write ["FontName"] inside of that table, we created a so called key.
		- A key can hold the precious values we want to access (or other tables that contain values)
		- Sometimes, if we need just one "value", the key alone will do its job. The only thing that changes is the syntax.
		- It then changes to just "FontName". We simply remove the brackets.
		
	-- General Game Texture note:
		- All game textures have to have a width and height by the power of two.
		- This means, accepted width and height values are: 2,4,8,16,32,64,128,256,512,1024,2048,4096 and so on.
		- The width and height are not required to be the same!
		- For WoW, they come in the BLP or TGA format.
		- I've found BLP for me to be the way to go, since it's really powerful, high-quality and easy to create.
		- You may have noticed, that programs like photoshop do NOT support the BLP format.
		- The way i go about it is to simply create the desired texture, save it as a png (you also may use transparency)
		   and convert it to BLP via "BLPNG Converter". This is a very powerful and accurate tool when it comes to converting textures.
		- You simply drag the png texture from your explorer into "BLPNG"'s "BLP" field and the tool will do the magic.
		- You can find the link to this tool up here in the description.
		- All our statusbar textures are getting tiled, not stretched. So, in theory, a texture with the dimensions
		- 2 x 128 would work. Just mind the power of two!
		- Congrats, you just created your very own texture!
		- Now add it to the table below~
]]

---------------------------------------------------------------
-- EDITABLE AREA
---------------------------------------------------------------



-- Syntax: ["FontName"] = [[Path\To\Font]],
-- Mind the , at the end of each line and make sure you closed all [ and " !!
-- The key is the Font name listed in the dropdown menus and is being used as an identifier for the profile.
-- So try to not change anything later on!
-- Example: ["Walkway Oblique"] 	= FontDir .. [[Walkway_Oblique.ttf]],
-- FontDir represents the "Font" directory in the CUI root.
AL.Fonts = {
	-- DEFAULTS, DO NOT REMOVE
	["EncodeSans Black"] 			= FontDir .. [[EncodeSans-Black.ttf]],
	["EncodeSans Bold"] 			= FontDir .. [[EncodeSans-Bold.ttf]],
	["EncodeSans ExtraBold"] 		= FontDir .. [[EncodeSans-ExtraBold.ttf]],
	["EncodeSans ExtraLight"] 		= FontDir .. [[EncodeSans-ExtraLight.ttf]],
	["EncodeSans Light"] 			= FontDir .. [[EncodeSans-Light.ttf]],
	["EncodeSans Medium"] 			= FontDir .. [[EncodeSans-Medium.ttf]],
	["EncodeSans Regular"] 			= FontDir .. [[EncodeSans-Regular.ttf]],
	["EncodeSans SemiBold"] 		= FontDir .. [[EncodeSans-SemiBold.ttf]],
	["EncodeSans Thin"] 			= FontDir .. [[EncodeSans-Thin.ttf]],
	["Michroma"] 					= FontDir .. [[Michroma.ttf]],
	["Julius Sans One"] 			= FontDir .. [[JuliusSansOne-Regular.ttf]],
	["Walkway Oblique"] 			= FontDir .. [[Walkway_Oblique.ttf]],
	["Walkway Oblique UltraBold"] 	= FontDir .. [[Walkway_Oblique_UltraBold.ttf]],
	["Walkway Black"] 				= FontDir .. [[Walkway_Black.ttf]],
	["Walkway Oblique Black"] 		= FontDir .. [[Walkway_Oblique_Black.ttf]],
	["Raleway Bold Italic"] 		= FontDir .. [[Raleway-BoldItalic.ttf]],
	["Raleway ExtraLight"] 			= FontDir .. [[Raleway-ExtraLight.ttf]],
	["Raleway"] 					= FontDir .. [[Raleway-Regular.ttf]],
	["Raleway SemiBold"] 			= FontDir .. [[Raleway-SemiBold.ttf]],
	["Raleway SemiBold Italic"] 	= FontDir .. [[Raleway-SemiBoldItalic.ttf]],
	["Raleway Thin Italic"] 		= FontDir .. [[Raleway-ThinItalic.ttf]],
	["Raleway Thin"] 				= FontDir .. [[Raleway-Thin.ttf]],
	["Open Sans"] 					= FontDir .. [[OpenSans-Regular.ttf]],
	["PT Sans Narrow"] 				= FontDir .. [[PT_Sans_Narrow.ttf]],
	["PT Sans Narrow Regular"]		= FontDir .. [[PT_Sans_Narrow_Regular.ttf]],
	
	-- vvvv Add yours here vvvv
	
}

-- Syntax: ["TextureName"] = [[Path\\To\\Texture]],
-- Mind the , at the end of each line and make sure you closed all [ and " !!
-- The key is the Texture name listed in the dropdown menus and is being used as an identifier for the profile.
-- So try to not change anything later on!
-- Example: ["CUI Modern"] = TextureDir .. [[statusbar\modern]],
-- TextureDir represents the "Textures\" directory in the CUI root.
AL.StatusbarTextures = {
	-- DEFAULTS, DO NOT REMOVE
	["CUI Modern"] 					= TextureDir .. [[statusbar\modern]],
	["CUI Modern 2"] 				= TextureDir .. [[statusbar\modern2]],
	["CUI Modern 3"] 				= TextureDir .. [[statusbar\modern3]],
	["CUI Simple Light"] 			= TextureDir .. [[statusbar\simple]],
	["CUI Simple Medium"] 			= TextureDir .. [[statusbar\simpleMedium]],
	["CUI Simple Darker"] 			= TextureDir .. [[statusbar\simpleDarker]],
	["CUI Simple Darkest"] 			= TextureDir .. [[statusbar\simpleDarkest]],
	["CUI Absorb Stripes"] 			= TextureDir .. [[statusbar\absorbOverlay]],
	["CUI XPBar"] 					= TextureDir .. [[layout\modern\XPBar]],
	
	-- vvvv Add yours here vvvv
	
}



---------------------------------------------------------------
-- EDITABLE AREA END
---------------------------------------------------------------

------------------------------------------------------------------------------------------
-- DO NOT TOUCH CONTENTS BELOW (unless you know what you're doing) !!
------------------------------------------------------------------------------------------

local function SetFont(Object, Font, Size, Flags)
	local _, OverrideSize, OverrideFlags = Object:GetFont()
	if not Size then Size = OverrideSize end
	if not Flags then Flags = OverrideFlags end
	
	Object:SetFont(Font, Size, Flags)
end

function AL:UpdateFonts()

	local Global = CO.db.profile.global

	-- Overrides the 3D world fonts
	-- Unfortunately, we have to live with the resulting taint.
	if Global.overrideWorldNameFont then
		_G.UNIT_NAME_FONT		= E.Media:Fetch("font", Global.worldNameFont)
	end
	if Global.overrideWorldDamageFont then
		_G.DAMAGE_TEXT_FONT		= E.Media:Fetch("font", Global.worldDamageFont)
	end
	if Global.overrideWorldDefaultFont then
		_G.STANDARD_TEXT_FONT	= E.Media:Fetch("font", Global.worldDefaultFont)
	end
	
	if not Global.overrideGeneralFont then return end
	
	local NORMAL			= E.Media:Fetch("font", Global.generalFont)
	local NORMALSIZE		= Global.generalFontSize or 12
	
	-- Modify Game Fonts found in Interface\FrameXML\Fonts.xml and Interface\SharedXML\SharedFonts.xml
	
	SetFont(_G.AchievementFont_Small, 					NORMAL, NORMALSIZE)
	SetFont(_G.ChatBubbleFont, 							NORMAL, NORMALSIZE)
	SetFont(_G.CoreAbilityFont, 						NORMAL, 26)
	SetFont(_G.DestinyFontHuge, 						NORMAL, 20)
	SetFont(_G.DestinyFontLarge, 						NORMAL, 17)
	SetFont(_G.DestinyFontMed, 							NORMAL, 14)
	SetFont(_G.Fancy12Font, 							NORMAL, 12)
	SetFont(_G.Fancy14Font, 							NORMAL, 14)
	SetFont(_G.Fancy16Font, 							NORMAL, 16)
	SetFont(_G.Fancy18Font, 							NORMAL, 18)
	SetFont(_G.Fancy20Font, 							NORMAL, 20)
	SetFont(_G.Fancy22Font, 							NORMAL, 22)
	SetFont(_G.Fancy24Font, 							NORMAL, 24)
	SetFont(_G.Fancy27Font, 							NORMAL, 27)
	SetFont(_G.Fancy30Font, 							NORMAL, 30)
	SetFont(_G.Fancy32Font, 							NORMAL, 32)
	SetFont(_G.Fancy48Font, 							NORMAL, 48)
	SetFont(_G.FriendsFont_Large, 						NORMAL, NORMALSIZE)
	SetFont(_G.FriendsFont_Normal, 						NORMAL, NORMALSIZE)
	SetFont(_G.FriendsFont_Small, 						NORMAL, NORMALSIZE)
	SetFont(_G.FriendsFont_UserText, 					NORMAL, NORMALSIZE)
	SetFont(_G.Game11Font, 								NORMAL, 11)
	SetFont(_G.Game11Font_o1, 							NORMAL, 11)
	SetFont(_G.Game120Font, 							NORMAL, 120)
	SetFont(_G.Game12Font, 								NORMAL, 12)
	SetFont(_G.Game12Font_o1, 							NORMAL, 12)
	SetFont(_G.Game13Font, 								NORMAL, 13)
	SetFont(_G.Game13FontShadow, 						NORMAL, 13)
	SetFont(_G.Game13Font_o1, 							NORMAL, 13)
	SetFont(_G.Game15Font, 								NORMAL, 15)
	SetFont(_G.Game15Font_o1, 							NORMAL, 15)
	SetFont(_G.Game16Font, 								NORMAL, 16)
	SetFont(_G.Game18Font, 								NORMAL, 18)
	SetFont(_G.Game20Font, 								NORMAL, 20)
	SetFont(_G.Game24Font, 								NORMAL, 24)
	SetFont(_G.Game27Font, 								NORMAL, 27)
	SetFont(_G.Game30Font, 								NORMAL, 30)
	SetFont(_G.Game32Font, 								NORMAL, 32)
	SetFont(_G.Game36Font, 								NORMAL, 36)
	SetFont(_G.Game46Font, 								NORMAL, 46)
	SetFont(_G.Game48Font, 								NORMAL, 48)
	SetFont(_G.Game48FontShadow, 						NORMAL, 48)
	SetFont(_G.Game60Font, 								NORMAL, 60)
	SetFont(_G.Game72Font, 								NORMAL, 72)
	SetFont(_G.GameFontHighlightMedium, 				NORMAL, 15)
	SetFont(_G.GameFontNormalMed3, 						NORMAL, 15)
	SetFont(_G.GameFont_Gigantic, 						NORMAL, 32)
	SetFont(_G.GameTooltipHeader, 						NORMAL, NORMALSIZE)
	SetFont(_G.InvoiceFont_Med, 						NORMAL, 12)
	SetFont(_G.InvoiceFont_Small, 						NORMAL, NORMALSIZE)
	SetFont(_G.MailFont_Large, 							NORMAL, 14)
	SetFont(_G.NumberFont_GameNormal, 					NORMAL, NORMALSIZE)
	SetFont(_G.NumberFont_Normal_Med, 					NORMAL, NORMALSIZE)
	SetFont(_G.NumberFont_OutlineThick_Mono_Small, 		NORMAL, NORMALSIZE)
	SetFont(_G.NumberFont_Outline_Huge, 				NORMAL, 28)
	SetFont(_G.NumberFont_Outline_Large, 				NORMAL, 15)
	SetFont(_G.NumberFont_Outline_Med, 					NORMAL, NORMALSIZE)
	SetFont(_G.NumberFont_Shadow_Med, 					NORMAL, NORMALSIZE)
	SetFont(_G.NumberFont_Shadow_Small, 				NORMAL, NORMALSIZE)
	SetFont(_G.NumberFont_Shadow_Tiny, 					NORMAL, NORMALSIZE)
	SetFont(_G.QuestFont, 								NORMAL, NORMALSIZE + 2) -- Quest Dialog Body Text
	SetFont(_G.QuestFont_Enormous, 						NORMAL, 30) -- Mostly used for the "Boss X Killed" message. This is the Boss Name Font
	SetFont(_G.QuestFont_Huge, 							NORMAL, 18)
	SetFont(_G.QuestFont_Large, 						NORMAL, 14)
	SetFont(_G.QuestFont_Outline_Huge, 					NORMAL, NORMALSIZE)
	SetFont(_G.QuestFont_Shadow_Small, 					NORMAL, NORMALSIZE)
	SetFont(_G.QuestFont_Shadow_Huge, 					NORMAL, 17) -- Quest Dialog Title, Target and Reward Text
	SetFont(_G.QuestFont_Super_Huge, 					NORMAL, 24)
	SetFont(_G.QuestFont_Super_Huge_Outline, 			NORMAL, NORMALSIZE)
	SetFont(_G.ReputationDetailFont, 					NORMAL, NORMALSIZE)
	SetFont(_G.SpellFont_Small, 						NORMAL, NORMALSIZE)
	SetFont(_G.SplashHeaderFont, 						NORMAL, NORMALSIZE)
	SetFont(_G.SystemFont_Huge1, 						NORMAL, NORMALSIZE)
	SetFont(_G.SystemFont_Huge1_Outline, 				NORMAL, NORMALSIZE)
	SetFont(_G.SystemFont_Huge2, 						NORMAL, 24)
	SetFont(_G.SystemFont_InverseShadow_Small, 			NORMAL, NORMALSIZE)
	SetFont(_G.SystemFont_Large, 						NORMAL, 15)
	SetFont(_G.SystemFont_LargeNamePlate, 				NORMAL, NORMALSIZE)
	SetFont(_G.SystemFont_LargeNamePlateFixed, 			NORMAL, NORMALSIZE)
	SetFont(_G.SystemFont_Med1, 						NORMAL, NORMALSIZE)
	SetFont(_G.SystemFont_Med2, 						NORMAL, NORMALSIZE)
	SetFont(_G.SystemFont_Med3, 						NORMAL, NORMALSIZE)
	SetFont(_G.SystemFont_NamePlate, 					NORMAL, NORMALSIZE)
	SetFont(_G.SystemFont_NamePlateCastBar, 			NORMAL, NORMALSIZE)
	SetFont(_G.SystemFont_NamePlateFixed, 				NORMAL, NORMALSIZE)
	SetFont(_G.SystemFont_Outline, 						NORMAL, 13)
	SetFont(_G.SystemFont_OutlineThick_Huge2, 			NORMAL, 22)
	SetFont(_G.SystemFont_OutlineThick_Huge4, 			NORMAL, 26)
	SetFont(_G.SystemFont_OutlineThick_WTF, 			NORMAL, 32)
	SetFont(_G.SystemFont_Outline_Small, 				NORMAL, NORMALSIZE)
	SetFont(_G.SystemFont_Outline_WTF2, 				NORMAL, 36)
	SetFont(_G.SystemFont_Shadow_Huge1, 				NORMAL, 20)
	SetFont(_G.SystemFont_Shadow_Huge2, 				NORMAL, NORMALSIZE)
	SetFont(_G.SystemFont_Shadow_Huge3, 				NORMAL, 22)
	SetFont(_G.SystemFont_Shadow_Large, 				NORMAL, 15)
	SetFont(_G.SystemFont_Shadow_Large2, 				NORMAL, 15)
	SetFont(_G.SystemFont_Shadow_Large_Outline, 		NORMAL, 20)
	SetFont(_G.SystemFont_Shadow_Med1, 					NORMAL, NORMALSIZE)
	SetFont(_G.SystemFont_Shadow_Med1_Outline, 			NORMAL, NORMALSIZE)
	SetFont(_G.SystemFont_Shadow_Med2, 					NORMAL, NORMALSIZE)
	SetFont(_G.SystemFont_Shadow_Med3, 					NORMAL, NORMALSIZE)
	SetFont(_G.SystemFont_Shadow_Outline_Huge2, 		NORMAL, 20)
	SetFont(_G.SystemFont_Shadow_Outline_Huge3, 		NORMAL, NORMALSIZE)
	SetFont(_G.SystemFont_Shadow_Small, 				NORMAL, NORMALSIZE)
	SetFont(_G.SystemFont_Shadow_Small2, 				NORMAL, NORMALSIZE)
	SetFont(_G.SystemFont_Small, 						NORMAL, NORMALSIZE)
	SetFont(_G.SystemFont_Small2, 						NORMAL, NORMALSIZE)
	SetFont(_G.SystemFont_WTF2, 						NORMAL, NORMALSIZE)
	SetFont(_G.SystemFont_World, 						NORMAL, 64)
	SetFont(_G.SystemFont_World_ThickOutline, 			NORMAL, 64)
	SetFont(_G.System_IME, 								NORMAL, NORMALSIZE)
	SetFont(_G.Tooltip_Med, 							NORMAL, NORMALSIZE)
	SetFont(_G.Tooltip_Small, 							NORMAL, NORMALSIZE)
	SetFont(_G.ZoneTextString, 							NORMAL, 32)
	SetFont(_G.SubZoneTextString, 						NORMAL, 25)
	SetFont(_G.PVPInfoTextString, 						NORMAL, 22)
	SetFont(_G.PVPArenaTextString, 						NORMAL, 22)
end

function AL:Init()
	-- Add fonts and textures to AceWidget Dropdowns
	for k, v in pairs(AL.Fonts) do
		E.Media:Register("font", k, v)
	end
	for k, v in pairs(AL.StatusbarTextures) do
		E.Media:Register("statusbar", k, v)
	end
	
	_G.CHAT_FONT_HEIGHTS = {6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20}
	
	self:UpdateFonts()
end

E:AddModule("ArtLib", AL)