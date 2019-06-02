local E, L = unpack(CUI) -- Engine
local CD, L = E:LoadModules("Config_Dialog", "Locale")

local Content085 = [[|cff1784d1• Completed Dungeon Entrance Data
• Unitframe clusters now correctly react to profile copy/creation and such
• Actionbar Fading now also works when attached to another Fading bar
• Pet Actionbar flash for repeatable actions (such as Melee) now always has the correct size
• Actionbar Cooldown text now always is above the button border
• Corrected the text format option tooltip and improved readability
• Adjusted step size for combat indicator animation timings to 0.01
• Improved Visibility in Mover Mode
• Portrait Cutoff now works correctly (as long as the Healthbar Background is fully opaque)
• Tons of Backend Changes to prepare for 0.9.0
• Improved responsivity of Classpower to different Specs (Mostly on Druid)
• Added skinned nameplates
• Added skinned mirror timers (Breath, Fatigue, Feign Death)
• Added a new system that logs your playtime! Found in Global > Statistics. Make sure to log-in once with every character! 
• Added Absorb Texture options
• Added background to the pet actionbar
• Added actionbar combat fade option
• Added updated German Locale back again
• Added Sticky Mover functionality
• Added option to override the Bar Texture for Health and Power Bars
• Added option to override general default UI Fonts
• Added option to modify the maximum number of aura bars
• Added functionality to automatically sell grey items and report the results
• Added summon indicator to unitframes
• Added heal prediction to healthbars
• Added option to color healthbars based on the current health value
• The armory item info now should be correct all the time, as long as the item was fully loaded
• Added color options for light, medium and heavy stagger
• Added tracking option for Worldmap Markers - directly in the Worldmap Tracking Menu!
• Added a more dynamic unitframe highlight system. Settings can be found under Unitframes -> All -> Misc
• Added an indicator to see what unit currently is targeted
• Added missing Lunar Power color option
• Added enchant name to custom armory
• Added gem display to custom armory
• Added options to toggle custom armory enchants, gems and itemlevel
• Added option to choose between all armory class backgrounds
• Changed the way Aura Tooltip Source and ID are being shown
• Improved Unitframes performance
• Improved Cluster-Unitframe sort method, which also allows for specific sort rules
• Fixed screen-freeze at Uu'Nat when the whole raid becomes hostile/friendly
• All Unitframe Modules are now completely modular. This is more of a backend change but still worth mentioning
• Added armory functionality to the inspect frame
• Profile switching now is seamless
• Added Masque support for all auras

Bugfixes

• Fixed some issues with 8.2 as of April 20th 2019
• Fixed an issue that caused the tooltip healthbar to stay visible sometimes
• Fixed an issue that caused channeled spells to always be displayed as non-interruptible
• Fixed chunky Absorb Texture
• Fixed an issue that caused castbars to not being updated when the active unit changes (boss unit added/removed, Party member joined/left etc.)
• Fixed an issue that caused castbars to stay visible when no cast success or fail event fires (A.e: You are too far away or hearthstoned from your party members while they are casting something)
• Fixed an issue that caused unit power update speeds to be inversed (normal = fast and fast = normal)
• Fixed an issue that caused pull timers that were performed via the raid control panel, to not be sent to DBM Users
• Fixed an issue that caused the Classpower bar profile to not load
• The Classpower bar now will now only be visible when it is supposed to
• Fixed Aura Tooltip Source being displayed in next line
• Fixed Unit Target Unitframes not updating
• Fixed weird behaviour of the Classpower bar which constantly filled up again for no apparent reason in some situations
• Un-toggling Aura Bars via the options now results in the bars returning back to their correct state
• The Aura system now does not filter out pet auras on non-pet units
• Castbars will now update correctly whenever a cast becomes kickable/unkickable
• Spec based profiles now should always work correctly
• When in a petbattle, unitframes now are no longer visible
• When in a petbattle, hotkeys now work as intended
• The Azerite Bar now does work correctly when first obtaining the Heart of Azeroth
|r]]

local Content080 = [[|cff1784d1This update resets nearly all of your font settings due to a new font generation system!

• Optimized a lot of modules
• Lua-Errors are now enabled as a default setting
• Overhauled Classpower bar and settings
• Changed behaviour of the vehicle leave button. It now also acts as a "Interrupt flight" button
• Unit dummy mode improvements
• Re-organized some options to make more sense
• Unit Names in tooltips now are correctly colored in their class colors
• Separated Config module (optional AddOn)
• Added optional descriptive behaviour to mover hovering in config mode
• Added click functionality to worldmap markers that will now open the encounter journal of the clicked instance
• Added detailed options for layout frames
• Added functionality to attach CUI elements to basically anything
• Added mover options to a lot of modules
• Added class color options
• Added range check to unitframes (found in general)
• Added absorb indicator to healthbars
• Added spec based profiles (Still have to reload the UI. The core will soon be ready so it is not required anymore!)
• Added a ton of castbar options
• Added first iteration of the armory enhancement
• Added aura source to aura tooltips
• Added player aura options
• Added advanced options for nearly every CUI font
• Added raid control panel
• Cursor coordinates on worldmap
• Splitted config module from the core and made it an optional AddOn
• Bag bar and mover
• Unitframes text format option
• Added aura test to unit dummy mode
• Added stancebar to masque group
• XP, Honor, Reputation and Azerite Bar options
• Font options for most CUI elements (Zone, Coordinates, FPS, Latency, Actionbar Cooldown etc.)
• More aura options
• An optional fill-background for actionbars and the class power bar
• Target icon enable/disable option
• Readycheck icon options
• Group Lead/Assist icon options
• Role icon options
• Combat indicator options
• An optional fill-background for actionbars and the class power bar
• Stylized micromenu
• Added actionbar options for "Click on Down", "Flyout Direction" and "Tooltip Show Condition"
• Changed the zone mouseover tooltip to properly display zone information
• Added reset button(s) to color options
• Added first iteration of an option documentation
• Added minimap (vanilla) zone, worldmap and mail-button toggle options
• Added custom Minimap mail-icon
• Fixed actionbar scaling
• Fixed a mover problem that was caused by frame scaling
• Applied band-aid fix for stancebar border scaling
• Added resurrect indicator options
• Fixed an issue that caused the tooltip cursor anchor to not work properly
• Fixed an issue that caused the border of unit tooltips to not have the right color rightaway
• Fixed an issue that caused the Classpower bars width to be miscalculated by the gap value
• Fixed an issue that caused an unexpected error whenever a unit had too many auras on it
• Fixed an issue that caused the frame cluster config to not be loaded properly on login
• Fixed an issue that caused the actioncam notification to be shown on login
• Fixed an issue that caused bank and guild-bank item tooltips to be overblown sometimes
• Fixed an issue that caused the vehicle exit button to only be visible on flight-paths
• Fixed an issue that caused channeled spells to result in a class-colored castbar
• Fixed an issue that caused the shapeshift bar (Bar 1) to not update when the player switched into a form (automatically) via spec-change
• Fixed some issues related to petbattles (not all unfortunately)
|r]] 

local Content072 = [[|cff1784d1• Fixed an issue that caused the worldmap markers tooltip to not be displayed
|r]]
local Content071 = [[|cff1784d1• Fixed GameTooltip anchoring
• Every single tooltip now should be stylized
• Fixed an issue that caused Lua-Errors when changing keybinds
• Fixed an issue that caused the azerite bar to throw an error after a UI load for some players
|r]]
local Content070 = [[|cff1784d1• Added castbar spark
• Fixed laggy castbar progress
• Added cast-delay functionality to castbars
• Improved Unit Dummy mode
• Added vehicle exit button
• Fixed memory issues when opening the worldmap with the CUI marker plugin enabled
• Fixed memory issues with retrieving coordinates and bumped up the update frequency again
• Readycheck indicators
• Resurrect indicators
• Added some entrance markers
• Added duration animation to auras
• Fixed some issues regarding the castbar
• Added power coloring options
• Added background for the Classpower bar
• Added azerite bar (static for now just as the xp bar)
• Fixed an issue that caused item tooltips to have a white background
|r]]
local Content060 = [[|cff1784d1• Added new aura system and several initial options
• Added mover for the general info frame
• Added reputation bar (Hides when no faction is watched. Options to come)
• Added honor bar (Set Visibility: H -> Right-Click the honor icon on the right hand side -> Set as XP-bar)
• Added key-rebinder to stancebar and extra actionbutton
• Changed the tooltip style system so it allows full flexibility in how each tooltip type is styled. There will be options to configure each style soon
• Fixed spell-flash for macros

[Cosmetic changes]
• Styled minimap tracking icon and moved instance difficulty to the left
• Styled minimap clock
• Added combat indicator for player
• Changed XP-bar to behave just like the vanilla one
• Changed unitframe tooltips to behave like the vanilla ones
|r]]
local Content052 = [[|cff1784d1• Fixed castbar interruptor display
|r]]
local Content051 = [[|cff1784d1• Fixed an issue with mover repositioning
• Fixed some Lua-Errors
|r]]
local Content050 = [[|cff1784d1• Changed entire file structure and splitted up functionality of several modules
• Updated defaults to make the vehicle seat frame fit. Also fixed Objective Tracker position
• Added option to reset all anchors to their default position
• Added totem bar! [Options to come. It's movable tho, okay?]
• Full transition to the BfA API changes
• Added aura and castbar-icon borders (color driven by the player class. For castbars, color is determined by wether the spell is interruptible)
• Added tooltip borders for units, spells, auras and items (macros and pets still missing)
• Decreased coordinates update frequency to compensate a memory leak issue in the new BfA map API. It is still present, but should generate 70% less memory now
• Added mouseover highlight for auras
• Fixed castbar spellname offset
• Changed Unit maxlevel to 120. BfA is coming, baby!
|r]]
local Content042 = [[|cff1784d1• Changed actionbutton behaviour to react to the locked actionbar setting
|r]]
local Content040 = [[|cff1784d1• Added option so sort unitframe clusters and change the X and Y gap between each frame
• Added tooltip information for units to display its current target and who in your raid has this unit as a target
• Added a metric heck-ton of options for the unitframes and moved some of them to a better place!
• Changed a lot of the settings descriptions to make clear what they do
• Changed maximum value of the Head Tracking Strength to the appropiate maximum possible
|r]]
local Content030 = [[|cff1784d1• Tons of bugs have been fixed!
• New default minimap style and scaling option.
• Overhauled the screen textures and replaced them with some sleak and simple ones!
• Added aura bars!
• Changed the look of the chat input box and added a basic channel switch functionality via tab-key!
• Added several new movers for default blizzard frames
• Added option to toggle unitframe portraits
• Added new 'engine' settings to fiddle around with the camera speed and the actioncam
• Added a unit-dummy mode (accessible via Unitframes > Dummy Mode) for later re-ordering of unitframe groups!
• Added options to move the unitframe powerbar
• Added options to scale individual unitframes and their powerbars
• Completely rewritten unitframes module for later possible unitframe creation on the fly
• Added the interruptor name to the castbar interrupt text
• Added pet actionbar
• Fixed vanilla party and bossframe sometimes showing up
• Added AddOn compability for both, Legion AND BfA. The system will now correctly respond to the API changes automatically!
• Added visibility condition option for actionbars
• The UI now reacts to petbattles and hides certain frames when neccessary
• Added tooltip and aurabar options
• Changed default frame positions a bit
• Fixed actionbars once and for all
• Fixed mover issues with the Classpower bar
• Fixed castbar not working correctly for channel casts
• Added state driver for the Classpower bar. It now will automatically hide if it does not contain your primary resource!
• Added temporary fix for deathknight runes. Still needs better solution, since this one eats too much CPU time
• Overhauled the actionbar system again. It now reacts to binding/hotkey updates
• Added 3 optional actionbars [With a little warning text in the options. That problem caused me headaches in the past, as i set up ElvUI with extra bars]
• Added Hot-Key reassign mode!
• Stylized player tooltips
• Applied various optimizations to the AddOn engine and its modules
• Added role overview for party and raid
|r]]
local Content020 = [[|cff1784d1• Added custom castbars for the main units (player, target and focus)
• Fixed Aura display
• Fixed option for personal nameplate to take effect on profile creation (and first login)
• Fixed micromenu icons\n• Added player aura movers
• Added questtracker mover
• Added chat mover\n• Fixed default profile issues due to missing mover data
• Added a color based status for FPS and Latency
• Added a new Stat-icon layout and initial values for the character-frame (will be optional soon)
• Updated default profile and added 3 new internal statusbar textures!
|r]]
local Content011 = [[|cff1784d1• Added new frame mover system. This now allows you to reposition unitframes!
• Added locale system and english+german as initially supported languages! (We need translators :3)
• Added XP-bar tooltip
• Added missing casttime to castbar
• Added mouseover highlight for unitframes!
|r]]
local Content010 = [[|cff1784d1• Overhauled internal variables to use a different approach in OOP
• Added visual anchor grid
• Added various functionality
• Fixed Warlock Soul Shard bar
• Fixed occuring LUA-Errors for MainBarFrame
• Fixed tons of taint issues (there are basically none left now)
• Fixed display of location coordinates (Blizzard likes to change API things lately)
• Added internal option to toggle the personal resource bar (The thing below your character in the middle of the screen)
• Added rested bar to XP bar
• Added Masque support!
• Fixed an issue that caused the stancebar to be displayed on classes that don't have any shapeshifting
• Added credits and changelog to the options panel
|r]]

CD.Options.args.changelog = {
	type = "group",
	name = "Changelog",
	order = -4,
	args = {
		Header_085 = {
			order = 5971,
			type = "header",
			name = "Major • 0.8.5 Test • Rev. 8513 [May 25th 2019]",
		},
		Content_085 = {
			order = 5972,
			type = "description",
			name = Content085,
			fontSize = "medium",
		},
		Header_080 = {
			order = 5973,
			type = "header",
			name = "Major • 0.8.0 Release • Rev. 8000 [December 12th 2018]",
		},
		Content_080 = {
			order = 5974,
			type = "description",
			name = Content080,
			fontSize = "medium",
		},
		Header_072 = {
			order = 5975,
			type = "header",
			name = "Minor • 0.7.2 Release [August 23rd 2018]",
		},
		Content_072 = {
			order = 5976,
			type = "description",
			name = Content072,
			fontSize = "medium",
		},
		Header_071 = {
			order = 5977,
			type = "header",
			name = "Minor • 0.7.1 Release [August 20th 2018]",
		},
		Content_071 = {
			order = 5978,
			type = "description",
			name = Content071,
			fontSize = "medium",
		},
		Header_070 = {
			order = 5979,
			type = "header",
			name = "Major • 0.7.0 Release [August 18th 2018]",
		},
		Content_070 = {
			order = 5980,
			type = "description",
			name = Content070,
			fontSize = "medium",
		},
		Header_060 = {
			order = 5981,
			type = "header",
			name = "Major • 0.6.0 Release [July 23rd 2018]",
		},
		Content_060 = {
			order = 5982,
			type = "description",
			name = Content060,
			fontSize = "medium",
		},
		Header_052 = {
			order = 5983,
			type = "header",
			name = "Minor • 0.5.2 Release [July 19th 2018]",
		},
		Content_052 = {
			order = 5984,
			type = "description",
			name = Content052,
			fontSize = "medium",
		},
		Header_051 = {
			order = 5985,
			type = "header",
			name = "Minor • 0.5.1 Release [July 18th 2018]",
		},
		Content_051 = {
			order = 5986,
			type = "description",
			name = Content051,
			fontSize = "medium",
		},
		Header_050 = {
			order = 5987,
			type = "header",
			name = "Major • 0.5.0 Release [July 18th 2018]",
		},
		Content_050 = {
			order = 5988,
			type = "description",
			name = Content050,
			fontSize = "medium",
		},
		Header_042 = {
			order = 5989,
			type = "header",
			name = "Minor • 0.4.2 Release [July 4th 2018]",
		},
		Content_042 = {
			order = 5990,
			type = "description",
			name = Content042,
			fontSize = "medium",
		},
		Header_040 = {
			order = 5991,
			type = "header",
			name = "Major • 0.4.0 Release [July 2st 2018]",
		},
		Content_040 = {
			order = 5992,
			type = "description",
			name = Content040,
			fontSize = "medium",
		},
		Header_030 = {
			order = 5993,
			type = "header",
			name = "Major • 0.3.0 Release [June 20th 2018]",
		},
		Content_030 = {
			order = 5994,
			type = "description",
			name = Content030,
			fontSize = "medium",
		},
		Header_020 = {
			order = 5995,
			type = "header",
			name = "Major • 0.2.0 B [May 12th 2018]",
		},
		Content_020 = {
			order = 5996,
			type = "description",
			name = Content020,
			fontSize = "medium",
		},
		Header_011 = {
			order = 5997,
			type = "header",
			name = "Minor • 0.1.1 B [May 10th 2018]",
		},
		Content_011 = {
			order = 5998,
			type = "description",
			name = Content011,
			fontSize = "medium",
		},
		Header_010 = {
			order = 5999,
			type = "header",
			name = "Major • 0.1.0 B [May 9th 2018]",
		},
		Content_010 = {
			order = 6000,
			type = "description",
			name = Content010,
			fontSize = "medium",
		},
	},
}