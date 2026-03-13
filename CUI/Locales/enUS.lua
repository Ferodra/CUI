local E = unpack(select(2, ...)) -- Engine, Locale

---@class L
local L = E.Libs.AceLocale:NewLocale('CUI', 'enUS', true, not E.Debug)

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------- UNITS -------
L["player"] 		= "Player"
L["target"] 		= "Target"
L["pet"] 			= "Pet"
L["targettarget"] 	= "Target of Target"
L["boss"] 			= "Boss"
L["raid"] 			= "Raid"
L["party"] 			= "Party"
L["focus"] 			= "Focus"
L["focustarget"] 	= "Focustarget"
L["unit"] 			= "Unit"
L["Units"] 			= "Units"

------- MOVER HANDLES -------
-- Defines the frame names on mover handles (anchor mode)
L["frame"] 				= "frame"
L["Frame"] 				= "Frame"
L["playerFrame"] 		= "Player Frame"
L["petFrame"] 			= "Pet Frame"
L["targetFrame"] 		= "Target Frame"
L["targettargetFrame"] 	= "Target of Target Frame"
L["focusFrame"] 		= "Focus Frame"
L["focustargetFrame"] 	= "Focus Target Frame"
L["arenaFrame"] 		= "Arena Frame"
L["partyFrame"] 		= "Party Frame"
L["bossFrame"] 			= "Boss Frame"
L["raidFrame"] 			= "Raid Frame"
L["raid40Frame"] 		= "40 Raid Frame"
L["chatFrame"]			= "Chat"
L["stanceBarFrame"]		= "Stancebar"
L["actionbarFrame"]		= "Actionbar"
L["tooltipAnchor"]		= "Tooltip Anchor"
L["alternatePower"]		= "Classpower"
L["buffs"]				= "Buffs"
L["debuffs"]			= "Debuffs"
L["micromenu"]			= "Micromenu"
L["raidRoleFrame"]		= "Role Overview"
L["vehicleSeatFrame"]	= "Vehicle-Seats"
L["battlerezCharges"]	= "Battle Res"

L["MoverPanel_Description"] = 'To move this frame click the buttons below or hover your mouse over this panel or frame and use the arrow keys on your keyboard.'

------- MISC -------
L["Misc"] 		= "Misc"
L["None"] 		= "None"
L["Reset"] 		= "Reset"
L["castbar"] 	= "Castbar"
L["Health"]		= "Health"
L["Power"]		= "Power"
L["AuraBars"]	= "Aura-Bars"

L["Top"]		= "Top"
L["Bottom"]		= "Bottom"
L["Left"]		= "Left"
L["Right"]		= "Right"
L["Center"]		= "Center"
L["Up"]			= "Up"
L["Down"]		= "Down"

L["TOPLEFT"] 		= "Top Left"
L["LEFT"]		 	= "Left"
L["BOTTOMLEFT"] 	= "Bottom Left"
L["TOP"] 			= "Top"
L["CENTER"] 		= "Center"
L["BOTTOM"] 		= "Bottom"
L["TOPRIGHT"] 		= "Top Right"
L["RIGHT"] 			= "Right"
L["BOTTOMRIGHT"] 	= "Bottom Right"

L["of"]			= "of"

L["BarFillInverse"]		= "Bar Inverse Fill"
L["BarFillDirection"]	= "Fill Direction"
L["SmoothBar"]			= "Smooth Bar"

L["CharacterSetting"]	= "[Character]"

-- ABSORB
L["UseStripes"]			= "Use Stripes"
L["TextureSizeMultiplier"]= "Texture Size Multiplier"

-- POWERS
L["Modifies the color of"] = "Modifies the color of the resource"
L["MANA"]			= _G["MANA"]
L["RAGE"]			= _G["RAGE"]
L["FOCUS"]			= _G["FOCUS"]
L["ENERGY"]			= _G["ENERGY"]
L["COMBO_POINTS"]	= _G["COMBO_POINTS"]
L["RUNES"]			= _G["RUNES"]
L["RUNIC_POWER"]	= _G["RUNIC_POWER"]
L["SOUL_SHARDS"]	= _G["SOUL_SHARDS"]
L["LUNAR_POWER"]	= _G["LUNAR_POWER"]
L["HOLY_POWER"]		= _G["HOLY_POWER"]
L["MAELSTROM"]		= _G["MAELSTROM"]
L["CHI"]			= _G["CHI"]
L["INSANITY"]		= _G["INSANITY"]
L["ARCANE_CHARGES"]	= _G["ARCANE_CHARGES"]
L["FURY"]			= _G["FURY"]
L["PAIN"]			= _G["PAIN"]
L["STAGGER"]		= _G["STAGGER"]
L["MAGE_ICICLES"]	= "Mage Icicles"
L["ALTERNATE_POWER"]= "Alternate Power"
L["RUNE_READY"]		= "Rune Ready"
L["RUNE_NOT_READY"]	= "Rune Cooldown"
L["PowerHeader"]	= "Power/Resource Colors"
L["PowerColorDesc"]	= "Those settings allow you to override the default resource/power colors"

-- READYCHECK
L["ReadycheckDesc"]		= "Those settings allow you to change the readycheck icon colors"
L["Readycheck"]			= "Readycheck"
L["ReadycheckIcons"]	= "Readycheck Icons"
L["ready"]				= "Ready"
L["notready"]			= "Not Ready"
L["waiting"]			= "Pending"
L["Modifies the Readycheck color for state"] = "Modifies the Readycheck color for state"
L["This will apply the next time a readycheck was performed"] = "Changes will apply the next time a readycheck was performed"

-- COLORS
L["ColorPickerPlus"]			= "For this section, it is recommended to use the AddOn \"Color Picker Plus\", as it provides a better colorpicker UI!"
L["ClassColors"]				= "Class Colors"

-- ZONE COLORS
L["ZoneColors"]		= "Zone Colors"
L["ZoneColorsDesc"]	= "Those settings allow you to change the zone text colors"
L["Modifies the zone color"]	= "Modifies the color of a zone PvP indication"
L["arena"] 			= "Arena"
L["friendly"] 		= "Friendly"
L["contested"] 		= "Contested"
L["hostile"] 		= "Hostile"
L["sanctuary"] 		= "Sanctuary"
L["combat"] 		= "Combat"
L["default"] 		= "Default"

-- CLASS COLORS
L["Modifies the color of the class"] = "Modifies the color of the class"
L["ClassColorDesc"] 			= "Those settings allow you to override the default class colors"

-- REACTION COLORS
L["ReactionColor"] 				= "Reaction Colors"
L["ReactionColorDesc"]			= "Those settings allow you to change the unit reaction colors"
L["Modifies the reaction color"]= "Modifies the color of a unit reaction towards you"
L["neutral"] 					= "Neutral"
L["unfriendly"] 				= "Unfriendly"

-- CASTBAR COLORS
L["CastbarColorDesc"]	= "Those settings allow you to change the castbar state colors"
L["CastbarColors"]		= "Castbar Colors"
L["Modifies the Castbar color for state"]	= "Modifies the Castbar color for state"
L["success"]			= "Success"
L["failed"]				= "Failed"
L["interruptible"]		= "Interruptible"
L["notInterruptible"]	= "Not Interruptible"

-- LAYOUT COLORS
L["LayoutColorDesc"]	= "Those settings allow you to change the layout bar colors"
L["Modifies layout bar color"] 	= "Modifies the color of a layout bar"
L["XPBar"]				= "XP Bar"
L["XPBarNormal"] 		= "XP Bar Normal"
L["XPBarRested"] 		= "XP Bar Rested"
L["ReputationBarOverlay"]= "Reputation Bar Texture"
L["AzeriteBarOverlay"] 	= "Azerite Bar Texture"
L["UseNormalClassColor"]= "Use Normal Class Color"
L["UseNormalClassColorDesc"]= "Use your class color for the normal state"
L["ReputationBar"]		= "Reputation Bar"
L["AzeriteBar"]			= "Azerite Bar"

------- STATS -------
L["agility"] = "Agility"
L["mastery"] = "Mastery"
L["leech"] = "Leech"
L["versatility"] = "Versatility"
L["haste"] = "Haste"
L["crit"] = "Critical Strike"

------- CONFIG HEADERS -------

-- Main
L["Global"] 	= "Global"
L["Unitframes"] = "Unitframes"
L["Actionbars"] = "Actionbars"
L["Bags"] 		= "Bags"
L["Camera"] 	= "Camera"
L["System"] 	= "System"
L["Colors"] 	= "Colors"
L["Color"] 		= "Color"
L["Maps"] 		= "Maps"
L["Infoframes"] = "Infoframes"
L["Tooltip"] 	= "Tooltip"
L["Changelog"] 	= "Changelog"
L["Bugtracker"] = "Bugtracker"
L["Credits"] 	= "Credits"
L["Help"] 		= "Help"
L["NumberFormatting"] = "Number Formatting"
L["Filters"] 	= "Filters"

-- Actionbars
L["Actionbar"] = "Actionbar"
L["Stancebar"] = "Stancebar"
L["Extra Button"] = "Extra Button"
L["Zone Button"] = "Zone Button"
L["Micromenu"] = "Micromenu"
L["Pet Bar"] = "Pet Bar"
L["Totem Bar"] = "Totem Bar"
L["Bar"] = "Bar"

-- Buffs and Debuffs
L["Buffs and Debuffs"] = "Buffs & Debuffs"

-- Unitframes 
L["All"] = "All"
L["Pet"] = "Pet"
L["Player"] = "Player"
L["Target"] = "Target"
L["TargetTarget"] = "Target target"
L["Focus"] = "Focus"
L["FocusTarget"] = "Focus target"
L["Arena"] = "Arenaframes"
L["Party"] = "Partyframes"
L["Raid"] = "Raidframes"
L["Raid40"] = "Raidframes 40"
L["Boss"] = "Bossframes"
L["Maintank"] = "Maintank"

-- Help
L["HelpWelcome"] = "Welcome to the CUI options documentation!\nHow can i help you?"

------- CONFIG BODY -------
-- MISC
L["New"] 				= "New"
L["Enable"] 			= "Enable"
L["Toggle"] 			= "Toggle"
L["Font"] 				= "Font"
L["Scale"] 				= "Scale"
L["Width"] 				= "Width"
L["Height"] 			= "Height"
L["WidthFontDesc"]		= "Maximum Width of the font container. Used for horizontal alignment. Leave at 0 if unsure. Can be combined with the Height setting to limit the amount of text displayed."
L["HeightFontDesc"]		= "Maximum Height of the font container. Used for vertical alignment. Leave at 0 if unsure. Can be combined with the Width setting to limit the amount of text displayed."
L["Visibility"]			= "Visibility"
L["DefVisibility"]		= "Default Visibility"
L["DefVisibilityDesc"]	= "In case you want to reset the visiblity string to default"
L["Position"]			= "Position"
L["Positioning"]		= "Positioning"
L["XOffset"]			= "X Offset"
L["YOffset"]			= "Y Offset"
L["HAlignFontDesc"]		= "Sets the horizontal growth direction of this font. Left sets the growth to right. Right sets it to left. Just like in any text-processing program. To reposition the font, use the position dropdown. Is being affected by the font container width"
L["VAlignFontDesc"]		= "Sets the vertical growth direction of this font. Top sets the growth to Bottom. Bottom sets it to Top. Just like in any text-processing program. To reposition the font, use the position dropdown. Is being affected by the font container height"
L["FontStyle"]			= "Font Style"
L["FontHeight"]			= "Font Height"
L["FontType"]			= "Font Type"
L["FontFlags"]			= "Font Flags"
L["Fonts"]				= "Fonts"
L["FontColor"]			= "Font Color"
L["TextShadow"]			= "Text Shadow"
L["TextShadowColor"]	= "Text Shadow Color"
L["Style"]				= "Style"
L["Texture"]			= "Texture"
L["OverrideTexture"]	= "Override Texture"
L["BarTexture"]			= "Bar Texture"
L["OverrideBarTexture"]	= "Override Bar Texture"
L["BarStyle"]			= "Bar Style"
L["Styling"]			= "Styling"
L["Size"]				= "Size"
L["Bars"]				= "Bars"
L["HorizontalAlign"]	= "Horizontal Align"
L["VerticalAlign"]		= "Vertical Align"
L["ClassSpecific"]		= "Class Specific"
L["RangeIndicator"]		= "Range Indicator"
L["BorderSize"]			= "Border Size"
L["BorderColor"]		= "Border Color"
L["Fading"]				= "Fading"
L["Background"]			= "Background"
L["BackgroundColor"]	= "Background Color"
L["PaddingH"]			= "Horizontal Padding"
L["PaddingHDesc"]		= "Controls the amount of horizontal 'overflow' for the fill frame"
L["PaddingV"]			= "Vertical Padding"
L["PaddingVDesc"]		= "Controls the amount of vertical 'overflow' for the fill frame"
L["Enabled"]			= "Enabled"
L["Disabled"]			= "Disabled"
L["Hide in Combat"]		= "Hide in Combat"
L["UseClassColor"]		= "Use Class Color"
L["UseClassColorDesc"]	= "Use your class color instead of a specified one"
L["UseUnitClassColor"]	= "Use Unit Class Color"
L["UseUnitClassColorDesc"]= "Use the units class color instead of a specified one"
L["SortDirection"]		= "Sort Direction"
L["SortMethod"]			= "Sort Method"
L["GrowthDirection"]	= "Growth Direction"
L["BlendMode"]			= "Blend Mode"
L["EnableModule"]		= "Enable Module"
L["ApplyChanges"]		= "Apply Changes"
L["Ascending"]			= "Ascending"
L["Descending"]			= "Descending"
L["Conditions"]			= "Conditions"

L["DOWN_RIGHT"]			= "Down and then Right"
L["DOWN_LEFT"]			= "Down and then Left"
L["RIGHT_DOWN"]			= "Right and then Down"
L["RIGHT_UP"]			= "Right and then Up"
L["LEFT_DOWN"]			= "Left and then Down"
L["LEFT_UP"]			= "Left and then Right"
L["UP_RIGHT"]			= "Up and then Right"
L["UP_LEFT"]			= "Up and then Left"

L["UnitConfig"]			= "Unit Configuration"
L["GroupConfig"]		= "Group Configuration"
L["GroupsPerColumn"]	= "Groups per Column"
L["GroupsPerRow"]		= "Groups per Row"
L["GroupGap"]			= "Group Gap"

-- Statistics
L["Statistics"]			= "Statistics"
L["EnableLogging"]		= "Enable Logging"
L["RemoveCharacter"]	= "Remove Character"
L["YourPlaytime"]		= "Your Total Playtime (So far)"
L["CharacterPlaytime"]	= "Your Character Playtime"
L["PlaytimeCharacterRemoved"] = " was removed from the list."

-- Frame Chooser
L["FrameChooserButton"]	= "Select Frame"
L["AttachMode"]			= "Attach Mode"
L["AttachToFrame"]		= "Attach to"
L["FrameChooser1"]		= "Frame selection enabled"
L["FrameChooser2"]		= "Left-Click to select a frame"
L["FrameChooser3"]		= "Right-Click to cancel the selection"

-- Headers [The 4 BIG Buttons]
L["Lua-Errors"] 				= "Lua-Errors"
L["Lua-ErrorsDesc"] 			= "Show/Hide Lua-Errors. It currently is recommended to hide them!"
L["SetKeybinds"] 				= "Set Keybinds"
L["SetKeybindsDesc"] 			= "Allows you to change actionbutton keybinds simply via mouseover!"
L["Install"] 					= "Install"
L["InstallDesc"] 				= "Install everything"
L["Toggle Anchors"] 			= "Toggle Anchors"
L["Toggle AnchorsDesc"] 		= "Unlock various elements of the UI to reposition them."
L["Reset Anchors"] 				= "Reset Anchors"
L["Reset AnchorsDesc"] 			= "Reset all frames to their original positions."

-- Global
L["CheckVersion"] 				= "Check Version"
L["NumberFormat"] 				= "Number Format"
L["Nameplates"] 				= "Nameplates"
L["Personal Nameplate"] 		= "Personal Nameplate"
L["Personal Nameplate Desc"] 	= "Enable/Disable the Blizzard default personal nameplate in the center of the screen."
L["ShowAllNameplatesDesc"]		= "When disabled, only nameplates of units which are currently in combat with you will be displayed."

-- Media
L["Media"]						= "Media"
L["WorldSettings"]				= "World Settings"
L["OverrideGlobalFont"]			= "Override Global Font"
L["OverrideGlobalFontDesc"]		= "Replaces the global font that is used by most parts of the User Interface"
L["OverrideWorldNameFont"]		= "Override Names"
L["OverrideWorldDamageFont"]	= "Override Damage"
L["OverrideWorldDefaultFont"]	= "Override Default"
L["WorldNameFont"]				= "Name Font"
L["WorldNameFontDesc"]			= "Changes the name font that is being rendered in the WorldFrame [Text above units]\nThis requires a relog, since reloading the UI is not enough for this.\nAlso please note, that not every font will work, as this functionality is heavily dependent on the load order. Just fiddle around a bit"
L["WorldDamageFont"]			= "Damage Font"
L["WorldDamageFontDesc"]		= "Changes the damage font that is being rendered in the WorldFrame\nThis requires a relog, since reloading the UI is not enough for this.\nAlso please note, that not every font will work, as this functionality is heavily dependent on the load order. Just fiddle around a bit"
L["WorldDefaultFont"]			= "Default Font"
L["WorldDefaultFontDesc"]		= "Changes the default font that is being rendered in the WorldFrame. This includes texts like honor gain etc\nThis requires a relog, since reloading the UI is not enough for this.\nAlso please note, that not every font will work, as this functionality is heavily dependent on the load order. Just fiddle around a bit"

-- Actionbars
L["Values"]				= "Values"
L["ShowGrid"] 			= "Show Empty"
L["ClickOnDown"]		= "Click On Down"
L["ABTooltip"]			= "Tooltip"
L["AllWarning"]			= "WARNING: Those settings override every single one of your actionbar font settings! Use with caution!\nIf you are expriencing issues with the positioning section, try to set the position to Bottomright"
L["BarReservedWarning"]	= "WARNING: This bar is already reserved for Druid Shapeshifting!\nBar 8 also for the Rogue Stealth!\nIf you change/remove any spells from this bar, this will also affect your main bar!\nIt is advised to leave this bar untouched and disabled when playing a Druid or a Rogue!"
L["VisibilityDesc"]		= "A string of macro conditionals to determine, whether this frame should be displayed.\nSome possible values:"
L["VisibilityDescSec"]	= "Find more at"
L["ButtonConfig"]		= "Button Config"
L["FlyoutDirection"]	= "Flyout Direction"
L["FlyoutDirectionDesc"]= "The direction that is used when opening consolidated spells. E.g. Mage Portals/Teleports"
L["ButtonsPerRow"]		= "Buttons Per Row"
L["ButtonsPerRowDesc"]	= "Buttons per row. Set to negative value to invert the direction"
L["ButtonCount"]		= "Number of Buttons"
L["ButtonCountDesc"]	= "The number of buttons this bar should contain"
L["ButtonSize"]			= "Button Size"
L["ButtonSizeDesc"]		= "The Button size multiplier that is used to calculate the final size."
L["Gap"]				= "Gap"
L["ButtonGap"]			= "Button Gap"
L["ButtonGapDesc"]		= "The gap that is between the individual bar-buttons (x and y axis)"
L["Custom"]				= "Custom"
L["Behaviour"]			= "Behaviour"
L["InCombatBarFadeDesc"] = "Determines how the actionbar should react when entering combat\n\nOn 'In Combat: Fade In', the Inactive Alpha will be used outside of combat.\nOn 'In Combat: Fade Out', the Active Alpha will be used outside of combat.\nSet to 'Custom' to specify your own conditional\n\nTo only use Mouseover, set this to 'Do Nothing'."
L["CombatFadeIn"]		= "In Combat: Fade In"
L["CombatFadeOut"]		= "In Combat: Fade Out"
L["DoNothing"]			= "Do Nothing"
L["Mouseover"]			= "Mouseover"
L["MouseoverDesc"]		= "By enabling this option, the actionbar will always fade in on mouseover"
L["ActionbarFadeConditionDesc"]	= "This option allows you to specify custom situations and reactions for this actionbar via macro conditionals.\n\nExample:\n[combat] 1; 0\n\nThe 1 indicates the use of the active alpha and the 0 for inactive. You also may use complex chains based on multiple conditions.\n\nMore Examples and explainations on:"
L["AlphaActive"]		= "Active Alpha"
L["AlphaActiveDesc"]	= "The alpha when the bar is mouseovered"
L["AlphaInactive"]		= "Inactive Alpha"
L["AlphaInactiveDesc"]	= "The alpha when the bar is NOT mouseovered"
L["FadeInTime"]			= "Fade In Time"
L["FadeInTimeDesc"]		= "The time in seconds it takes the bar to fade in"
L["FadeOutTime"]		= "Fade Out Time"
L["FadeOutTimeDesc"]	= "The time in seconds it takes the bar to fade out"
L["ButtonBorderTexture"]= "Button Border Texture"
L["NormalColor"]		= "Normal Color"
L["ButtonNormalTexture"]= "Button Normal Texture"
L["HighlightColor"]		= "Highlight Color"
L["ButtonHTexture"]		= "Button Highlight Texture"
L["PushedColor"]		= "Pushed Color"
L["ButtonPTexture"]		= "Button Pushed Texture"
L["AdditionalAddOns"]	= "Additional AddOns"
L["UseMasque"]			= "[Character] Use Masque"
L["UseMasqueDesc"]		= "Leave styling the buttons to masque (if installed). This setting will only be saved in your character profile and leaves the current profile unaffected."
L["CVars"]				= "Console Variables (CVars)"
L["CVarsDesc"]			= 'This option controls the state of a so called "Console Variable". They are NOT being saved in CUI Profiles but on the Servers themselves. So it\'s basically a character wide setting.'
L["GlobalFunctions"]	= "Global Functions"
L["ClearAllSlots"]		= "Clear all Slots"
L["ClearAllSlotsDesc"]	= "This action literally clears ALL your actionbars. Use with caution and just if you really want to do this, as it cannot be reversed!"
L["Hotkey"]				= "Hotkey"
L["Cooldown"]			= "Cooldown"
L["Count"]				= "Count"
L["Macro"]				= "Macro"

-- Bags
L["Bags"]				= "Bags"
L["General"]			= "General"
L["Utility"]			= "Utility"
L["Autosell Greys"]				= "Autosell Greys"
L["When enabled, grey items from your bag will automatically be sold"] = "When enabled, grey items from your bag will automatically be sold"
L["Autosell Greys Report"]		= "Autosell Report"
L["Reports what has been sold and how much revenue you earned"] = "Reports what has been sold and how much revenue you earned"
L["Sold: %s for %s"]			= "Sold: %s for %s"
L["Total Revenue: %s"]			= "Total Revenue: %s"

-- Dataframes
L["RaidRoles"]			= "Raid Roles"
L["RaidControl"]		= "Raid Control"
L["MirrorTimer"]		= "Mirror Bar"
L["ClickThrough"]		= "Click Through"
L["Sending Pulltimer to BigWigs and DBM Users"] = "Sending Pulltimer to BigWigs and DBM Users"
L["Pull Time must be above 0 seconds!"]	= "Pull Time must be above 0 seconds!"
L["BattlerezCharges"]	= "Battle Res"
L["Charges"]			= "Charges"

-- Aura Bars
L["Number of Bars"]		= "Number of Bars"

-- Maps
L["Map"] 				= "Map"
L["Worldmap"] 			= "Worldmap"
L["Minimap"] 			= "Minimap"
L["Coordinates"] 		= "Coordinates"

-- Engine
L["Camera"]			= "Camera"
L["CameraDesc"]		= "Those settings are intended for high-DPI displays or high resolutions in general, since the default camera settings do not do a good job on them. Feel free to experiment for what suits your feeling or set one or both settings to 0 to use the engines default value"
L["CameraDescSec"]	= "after a required reload (just for a value of 0 !)"
L["YawSpeed"]		= "Yaw Speed Override"
L["YawSpeedDesc"]	= "Adjust the camera yaw speed (Left/Right)\nSet to 0 and use /reload to use the engine default"
L["PitchSpeed"]		= "Pitch Speed Override"
L["PitchSpeedDesc"]	= "Adjust the camera pitch speed (Up/Down)\nSet to 0 and use /reload to use the engine default"
L["Presets"]		= "Presets"
L["PresetFullHD"]	= "1080p (Full HD)"
L["Preset4K"]		= "4K (Ultra HD)"
L["Actioncam"]		= "Actioncam"
L["ActioncamDesc"]	= "Those settings provide basic functionality of the new (Legion) actioncam. If you want further options, it is advised to disable this module and using 'DynamicCam' for it!"
L["ActioncamDescWarning"]	= "WARNING: As of Patch 8.2, there is a major bug regarding the Actioncam, where after a reload or relog, it completely loses its functionality, except for the Head-Tracking! This is NOT an AddOn issue, nor can it be fixed by AddOn authors - you'll have to wait until Blizzard fixes it!"
L["HideNotification"]		= "Hide Notification"
L["HideNotificationDesc"]	= "Hide/Show the blizzard actioncam notification on login"
L["HeadTracking"]			= "Head Tracking Strength"
L["HeadTrackingDesc"]		= "Adjusts how much the camera is affected by head movement"
L["ShoulderOffset"]			= "Camera Shoulder Offset"
L["ShoulderOffsetDesc"]		= "Adjusts how far the camera should be offset to the left/right"
L["DynamicPitch"]			= "Dynamic Camera Pitch"
L["DynamicPitchDesc"]		= "Use the new actioncam to control the camera pitch"
L["BaseFoVPad"]			= "Base FoV Pad"
L["BaseFoVPadDesc"]		= "Adjusts how far the camera is turned up/down"
L["FlyingFoVPad"]		= "Flying FoV Pad"
L["FlyingFoVPadDesc"]	= "Adjusts how far the camera is turned up/down when flying"
L["EnemyFocus"]			= "Focus Enemy"
L["EnemyFocusDesc"]		= "Make the camera pan/tilt to follow enemy targets (attackable)"
L["FriendlyFocus"]		= "Focus Friendly"
L["FriendlyFocusDesc"]	= "Make the camera pan/tilt to follow friendly targets (while dialog is open)"
L["FocusPitch"]			= "Focus Pitch Strength"
L["FocusPitchDesc"]		= "Adjusts how much the cameras pitch (up/down) is being influenced by the focus"
L["FocusYaw"]			= "Focus Yaw Strength"
L["FocusYawDesc"]		= "Adjusts how much the cameras yaw (left/right) is being influenced by the focus"

-- Unitframes
L["Health"]				= "Health"
L["Power"]				= "Power"
L["Health Bar"]			= "Health Bar"
L["Power Bar"]			= "Power Bar"
L["Threat Bar"]			= "Threat Bar"
L["Level"]				= "Level"
L["Name"]				= "Name"
L["Time"]				= "Time"
L["Castbar"]			= "Castbar"
L["Combat Indicator"]	= "Combat Indicator"
L["RestingIndicator"]	= "Resting Indicator"
L["Alternate Power"]	= "Classpower"
L["Absorption"]			= "Absorption"
L["Res Indicator"]		= "Res Indicator"
L["Summon Icon"]		= "Summon icon"
L["Ready Check"]		= "Ready Check"
L["Role Icon"]			= "Role Icon"
L["Leader Icon"]		= "Leader Icon"
L["Target Icon"]		= "Target Icon"
L["Aura Bars"]			= "Aura Bars"
L["Buffs"]				= "Buffs"
L["Debuffs"]			= "Debuffs"
L["Portrait"]			= "Portrait"
L["Icon"]				= "Icon"
L["Auras"]				= "Auras"
L["NotOnMaxlevel"]		= "Not at Maxlevel"
L["Color By Value"]		= "Color By Value"
L["DesaturateOtherDebuffs"] = "Desaturate Debuffs from Other Players"
L["DesaturateOtherDebuffsDesc"] = "When enabled, debuffs on hostile targets will be desaturated/ displayed in black and white, when you didn't apply them."

-- Armory
L["ArmoryEnableDesc"]				= "When enabled, CUI will add various information next to each gear slot in the armory frame. This controls the inspect frame as well as your own character panel"
L["ArmoryItemlevel"]				= "Show Itemlevel"
L["ArmoryItemlevelDesc"]			= "When enabled, you will be shown the Itemlevel of each equipped piece of gear."
L["ArmoryEnchant"]					= "Show Enchants"
L["ArmoryEnchantDesc"]				= "When enabled, you will be shown the Enchant of each equipped piece of gear. If an essential enchant is missing, thios will also be highlighted"
L["ArmoryGem"]						= "Show Gems"
L["ArmoryGemDesc"]					= "When enabled, you will be shown the Gem Slots of each equipped piece of gear. If a gem is missing, you'll be shown an empty socket slot"
L["ArmoryOverrideBackground"]		= "Replace Background"
L["ArmoryOverrideBackgroundDesc"]	= "When enabled, the default background will be replaced with the specified one"
L["CustomTexture"]					= "Custom Texture"
L["CustomTextureDesc"]				= "Allows you to use your completely own texture as a background, as long as it meets the Texture-Requirements (Resolution of 16x16, 32x32,64x64 etc.)."
L["TexturePath"]					= "Texture Path"
L["ArmoryBackgroundOfClass"]		= "Use Class Background"
L["ArmoryBackgroundOfClassDesc"]	= "Choose which class background you want to use in your own armory"
L["YourCurrentClass"]				= "Your Class"
L["Automatic"]						= "Automatic"
L["Equipped"]						= "Equipped"

-- Bars
L["Experience"]				= "Experience"
L["Azerite"]				= "Azerite"
L["Honor"]					= "Honor"
L["Reputation"]				= "Reputation"

-- Layout
L["AdvancedOptions"]		= "Advanced Options"
L["LayoutTextures"]			= "Textures"
L["LayoutFonts"]			= "Fonts"
L["TopBar"]					= "Top Bar"
L["BottomBar"]				= "Bottom Bar"
L["BottomLeftCorner"]		= "Bottom Left Corner"
L["BottomRightCorner"]		= "Bottom Right Corner"
L["SystemUpdateFrequency"]	= "System Update Rate"
L["CoordinatesUpdateFrequency"]	= "Coordinates Update Rate"
L["FPS"]					= "FPS"
L["Latency"]				= "Latency"
L["Zone"]					= "Zone"
L["CoordinatesX"]			= "Coordinates X"
L["CoordinatesY"]			= "Coordinates Y"

-- Filters
L['AddFilter']				= 'Add Filter'
L['DeleteFilter']			= 'Delete Filter'
L['Filter']					= 'Filter'
L['FilterNewName']			= 'New Name'
L['FilterType']				= 'Filter Type'
L['FilterRename']			= 'Rename'
L['FilterAddAura']			= 'Add Aura by Name or Spell ID'
L['Aura']					= 'Aura'
L['Delete']					= 'Delete'
L['Options']				= 'Options'
L['Cancel']					= 'Cancel'

-- Notifications
L["Reload"] 				= "Reload"
L["Later"] 					= "Later"
L["Nofification_Reload"] 	= "The modifications you made may not fully apply until the Interface has been reloaded!"
L["Nofification_Charactersetting"] = "The modification you made only affects this character and is not being saved in the current profile!\nThis modification requires you to reload your UI to make it fully apply."
L["Nofification_Relog"] 	= "The modification you made requires a relog to fully apply!"
L['Nofification_FilterDelete'] = 'Are you sure you want to delete this filter entry?'
L["NewVersion"]				= "A new Version is available! ['%s' from %s, Revision: %s]"

-- Descriptions
L["GlobalAbsorb_Desc"]		= [[This section allows you to configure the absorption module for ALL Unitframes at ONCE.
To make a change, a setting has to be changed at least once to take effect when you click the apply button!]]
L['FilterMainDesc']			= [[Here, you can specify aura filters for various modules.
A 'Whitelist' blocks everything except the specified entries.
A Blacklist lets pass everything except the specified entries.

NOTE: Those Filters are GLOBAL, so they are available across all your characters!]]
L["CharacterWideNote"]		= [[Those settings allow you to centrally control Character wide options.
You also (still) can enable those in the corresponding module settings so you don't have to come back here just for that. Those settings only exist as a central hub.]]

-- Config Types
L["ConfigType"]				= "Config Style"
L["ConfigTypeDesc"]			= "Controls what options are available, to tailor your configuration experience."
L["ConfigType-Recommended"]	= "Recommended"
L["ConfigType-Simple"]		= "Simple (WiP)"
L["ConfigType-Advanced"]	= "Advanced"

-- Credits
L["CREDITS_DEVELOPEDBY"]	= "Developed by Ferodra - Arenima @ Alleria EU"
L["CREDITS_CUIDESC"]		= "CUI is a highly Customizable User Interface replacement, designed to be yours in every possible way. [At some point in the future]"
L["CREDITS_THANKSTO"]		= "A very special thanks to:\n-Skaltryos @ Alleria EU\n-Tiray/Myralin/Velanri @ Alleria EU\n\nYou guys are amazing!"