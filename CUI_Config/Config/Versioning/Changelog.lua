local E, L = unpack(CUI) -- Engine
local CD = E:LoadModules("Config_Dialog")

local Content0930_90300 = [[|cff1784d1Features

• Updated for Midnight (12.0)
• Added option to handle character settings globally
• Added some options to disable certain modules

|r]]

local Content0922_90212 = [[|cff1784d1Features

• Updated for The War Within (10.0)

|r]]

local Content0921_90211 = [[|cff1784d1Bugfixes

• Fixed errors when changing the spec from one with stances to one without (a.E.: Shadow Priest to Holy)
• Fixed errors when disabling the unitframes module and then reloading. This issue also prevented re-enabling of the module
|r]]

local Content0921_90210 = [[|cff1784d1Features

• Added options to show or hide the player unit in group and maintank unitframes [Unitframes->Party/Maintank]

Bugfixes

• Removed Temp Enchant Cooldown Animation
• Actionbar fading now respects the set visibility condition and won't make the bar show up on its own anymore
• Another fix to prevent group unitframes from displaying false data
• Fixed actioncam dynamic pitch not being disabled when the option was unchecked
• The player castbar now also respects the player vehicle status and will display vehicle casts
• Fixed heal prediction being displayed for dead units. Stay dead ffs
|r]]

local Content092_9029 = [[|cff1784d1Bugfixes

• Fixed incorrect Chat Bubble Name positioning
• Fixed Chat Bubble border size not taking any effect immediately
• Fixed issues that occured when the Heart of Azeroth was put in the bank. The Azerite Bar now only shows up when the HoA is actually equipped
• Fixed absorb options incorrectly disabling each other
|r]]

local Content092_9028 = [[|cff1784d1Features

• Improved Unitframe Auras performance by about 2x. This results in better overall performance when in raids
• Added option for Unitframe Auras to configure a minimum duration auras should have to actually be displayed
• Added classbar options for Deathknights. You now can configure how the bar displays the rune cooldown - as well as toggle rune colors based on your current spec
• Added Heal Absorption to unitframes health, as well as options for them. This bar is positioned within the empty portion of the healthbar but still attached to the moving bar itself
• Added Alpha option for unitframes health absorption

Bugfixes

• Classbar no longer shows up for shamans (Rip Maelstrom)
• Removed Blizzard frame for temporary auras
• Fixed broken aura frames for temporary weapon enchants/poisons and such
• Fixed lots of Blizzard frame taint issues - this should fix errors when opening things like the mount journal in combat
• Fixed aura filters not taking effect immediately, when you changed the filter type
• Fixed chatbubbles not being skinned
|r]]

local Content092_9027 = [[|cff1784d1Bugfixes

• Performance fixes
• Autoselling now works again
• Experimental fix for false unitframe font texts when first joining a group
• Fixed broken range indicator
• Fixed nameplate quest icons not showing up when the quest section was collapsed
|r]]

local Content092_9026 = [[|cff1784d1Features

• Added option to automatically hide the unitframe power bar when the power is at 0

Bugfixes

• The Height and Vertical Align options for Unitframe fonts now work again
• Reduced the displayed icons of "CUI Worldmap Markers" to entrances, as Blizzard finally added nearly all dungeon/raid entrances on their own
• Castbars no longer are movable in mover mode when they are attached to something
• Fixed castbars not working properly for grouped unitframes
• Fixed player castbar being yeeted into the center of the screen when you are part of a group while the UI is loading
• Fixed Blizzard nameplate healthbar showing up when the CUI nameplate module is enabled
• Fixed extra actionbutton and zone button not being affected by their movers. This required to change how they are positioned overall due to some changes Blizzard made. You now can only position them both at once through the "Extra Ability" options in the actionbars section
• Fixed an issue where the alternate power module would throw errors like candy
• Fixed grouped Unitframes not properly updating when the unit changes online status
• Experimental fix for static popup errors when opening mover mode
|r]]

local Content092_9025 = [[|cff1784d1Features

• Added Clique support to unitframes
• Offset Options for Unitframe Icons now range from -300 to 300
• Unitframe Power bars now grow correctly based on their attachment position
• Removed Zone Ability Hotkey, as it no longer is possible to click this button through code (Don't ask me why)
• Aura Filter Spell search no longer is case sensitive
• Power bars now are attached to the outside of the unitframe

Bugfixes

• Fixed Font options for grouped unitframes
• Fixed Color options not immediately taking effect
|r]]

local Content092_9024 = [[|cff1784d1Bugfixes

• Fixed Unitframe Font options not taking any effect
|r]]

local Content092_9023 = [[|cff1784d1Features

• Healthbars now are discolored when the unit is an offline player

Bugfixes

• Fixed group unitframes toggle functionality
• Fixed group unitframes aura functionality
• Fixed group unitframes sub-module toggles (Raid Target, Summon Indicator etc.)
• Fixed group unitframes not updating on profile change
• Fixed faulty arena unitframes default visibility - causing it to show up when in parties
• Fixed Readycheck Indicator showing up again after the group/raid changed members
• Fixed errors with the stancebar frame
• Resolved issues with the default profile
• Moved arena frames back to the old group system to make it actually work (You'll just have some other options you can achieve the same as in the new system with)
|r]]

local Content092 = [[|cff1784d1Features

• Runs on 8.3.7 and 9.0 (Shadowlands)!
• Lots of improvements to the default profile
• Frost Mage icicles are now displayed on the Classbar (Thanks to Velanri for this idea!)
• Raid Unitframes now also show empty slots and are properly ordered by group!
• Added Maintank Unitframes!
• Nearly all fonts now have an option for automatic player class colors
• Autosell Thresholds updated for Shadowlands in advance, as the Pre-Patch will already lower itemlevels and such
• The autosell feature no longer sells tabards, shirts and bags
• Improved Fonts Section in the Unitframe "All" options
• Updated possible enchants for gear checking in armory module
• Moved Mirror Bar Position config to new Blizzard category
• Zhe Zoom function for the character window model now is smoothed out. Not as good as in the Dress Up Window, but it's something.
• The Chat input box now has a colored border
• The Raid Control Panel now only is visible when you actually are allowed to perform group commands (Leader/Assist)
• Totem Bar Icons now have an actual border (Configurable between class color and specific color)
• Repositioned Main Menu Button tooltip to the button itself
• Minimap AddOn Icons now have a styled border to match the theme
• The Minimap clock now has a border and an background - as well as an option for automatic class coloring for the text, border and background
• Some option cleanup and visual improvements for easier readability across the board
• Changed castbar flash behaviour to an animation with configurable fade timings to improve the feeling of casts [Unitframes -> All -> Castbar]
• Added system that tracks all of your item counts and currencies across all characters! Counts are shown in item tooltips!
Gold also is tracked, so you don't need a bag AddOn for this - simply mouseover the money text in your vanilla bags!
• Added option to disable the entire actionbar module
• Added option to disable the entire unitframe module
• Added option to disable unitframe power bars
• Added option to fully customize the actionbar fading through macro conditionals [Actionbars -> Bar -> Fading -> Behaviour -> Custom]
• Added options to configure the power text percentage behaviour [Number Formats -> Unitframe Texts]
• Added options to change the targeting sounds [Unitframes -> Misc -> Targeting Sounds]
• Added new statusbar texture - which now is the new default
• Added option to disable specific unitframes
• Added separate statistics module. Can be found in the ESC Game Menu!
• Added Armory Data to Statistics. You now can view your gear of every char everywhere. Anytime!
• Added binding options for the Zone Ability and Extra Actionbutton. Located in: [Game Menu -> Keybinds -> Actionbars -> (Scroll to bottom)]
• The Zone Ability and Extra Actionbutton can now be keybound within the CUI Keybind-Mode
• Added 2D and floating mode for Portraits. Also some positioning and scaling options for it
• Added skinned Chat Bubbles. [Blizzard -> Chat Bubbles]
• Added option to also show Nameplate Quest Icons on Worldquest targets. [Nameplates -> Quest Icon -> Only Show Quests]
• Added option to show the target of a cast on the castbar. Located in: [Unitframes -> All -> Castbar -> Show Target Name] and in the individual castbar config of each unitframe
• Added animated actionbar flash with configurable timings to improve the feeling of pressing buttons. Affected bars: Bar 1 to 10, Stancebar, Pet Bar [Actionbars -> Bar -> Flash]
• Added option to use static colors for healthbars, instead of class or reaction colored ones. Still works with Color by Value
• Added Titan Residuum and Echoes of Ny'alotha Reward Amount to the Mythic Plus Frame. On Mouseover, you're also shown the amount of rewarded currency for up to level 25. This feature depends on data from the community and most likely will take some time to be fully up to date in the future, if there's currency being rewarded.
• Added Tooltip Background Color option (Instead of just an Alpha Slider)
• Added Option to disable the Tooltip Module completely. This option does NOT require an reload!
• Added Option to change the "SpellQueueWindow" CVar. This allows you to change the time of how long WoW does queue clicked/used spells to chain them together. By adjusting this value, players can change how combat feels overall and allows for more control in some instances. Option located in Actionbars->All
• Added Option (Default: Enabled) that automatically reverts all CVar changes, CUI has made during it's runtime, when the AddOn is being unloaded by the Game Client [Global -> Revert CVars on Shutdown]
• Added X and Y (and therefore also center) axis snap points for mover mode
• Added Talking Head Frame Mover and Size Config
• Added Position Config for Info Frame and UI Widget
• Added Mover for the Archeology Progress Bar
• Added Autosell option [Default: Disabled] to sell old gems - With an configurable Itemlevel Threshold
• Added Autosell option [Default: Disabled] for old equipment - With an configurable Itemlevel Threshold
• Added Autosell option [Default: Disabled] to never autosell BoE Items
• Mouseovering a spell in your spellbook now highlights it on the actionbars (Except for Pet and Shapeshift Bars. Also doesn't work for Druid Swipe, for some reason)
• [Devs Only] Added API for easy Item Tooltip Scanning. See Modules/Core/TooltipScanning.lua

Bugfixes

• Resolved an Extra Actionbutton tainting issue, which led to it not showing up
• Experimental Fix for Error when opening the Mover/Anchor mode. Will have to monitor this change, as it potentially could cause taint issues
• The Talking Head and Battlerez Frames now snap to other frames when moved outside of mover mode
• Item Ref Tooltips (From Chats) no longer should snap to the tooltip anchor point
• Fixed Tooltip background randomly being in an blue-ish color
• Fixed Tooltip border rapidly changing color on the first few frames after it shows up
• Fixed an issue that would cause power bars to not being updated properly on death or revival
• Additionally to the fix above, incorrect power bar values now also SHOULD be fixed. Will have to monitor this.
• Fixed Classpower Segment Background Color option not having any effect
• Fixed Mover positioning issues due to scaling
• Fixed Totem Bar Timer behaviour when the time goes below 0
• Fixed Actionbar Cooldown Text still being shown when the cooldown already finished
• Fixed Autoseller for situations where lots of items are vendored at once. Before, there would occur an error, that interferes with the selling process.
• Fixed global DB data being written to each individual profile. Cleanup does happen automatically and will reduce the SavedVariables file size quite a bit
• Fixed actionbar cooldown being displayed twice when the Blizzard Option for Button Countdowns is enabled
• Fixed visual actionbar issues when not using Masque
• Fixed actionbar Hotkey Texts being misaligned on login
• Fixed an interference with the AddOn "BetterWardrobe", which caused the helmet toggle to stop working correctly
• Fixed an issue with Masque, where CUI couldn't reposition the actionbar hotkeys anymore
• Fixed stancebar not updating properly when the number of displayed stances changed
|r]]

local Content0912 = [[|cff1784d1Bugfixes

• Layout Bars now should respond correctly to switching between profiles
• Minimap Icons now are repositioned automatically when changing the minimap scale
• Fixed an unhandled exception for Aura Bars, that would cause errors when an aura does not have a specific expiration time
|r]]

local Content0911 = [[|cff1784d1Features

Revision 9011
• CUI will now use brute-force while trying to display Unit Names on Nameplates. This should cause them to always show up a few frames after it says "Unknown"
• Added Alternate Power Bar for most units
• The Number Format System now is a bit more usable! You now can use it for Actionbar Cooldown Texts!
• Added Quest Icon to Nameplates. It's shown when you need that specific mob for one of your current Quests
• Added options for Unit Aura Clickthrough and display alpha
• Added "Show Helmet" Button to the set collections. Finally a preview without Helmets!
• Added button (For Filters and Aura Colors) to load all game spell definitions. This enables you to search for auras/spells (That your character doesn't have in its Spellbook!) by name. When results were found, you can mouseover the "N Matches" icon to show the corresponding spell descriptions to make your life a bit easier!
• Updated Raid Debuffs Whitelist for Ny'alotha
• Colorized and sorted unitframes options by category
• Improved Link Copy Frame behaviour to keystrokes
• Moved Nameplate Classification Icon (no options yet)
• Unitframes now change their state when a vehicle was entered/exited and show the new unit (the vehicle) accordingly
• Major Unitframes Core improvements for future updates

Bugfixes

Revision 9011
• Nameplates now correctly show when a unit is already tapped by a player of the opposite faction
• Unit Auras now behave correctly when attached
• Disabled Dataframes now are also hidden in mover mode
• Fixed Fonts not being up-to-date with the config when they're first created
• Fixed Readycheck Indicator and Target Highlight Frame Level
• Fixed actionbar fading (again). It now behaves correctly on a mouseover between the bar and buttons
• Fixed actionbuttons border staying green/visible after an item was dragged off of them
• Fixed a case of actionbars teleporting to random positions when configuring them
• Fixed player auras flickering when Masque is being used
• Fixed coordinates not showing up on login
• Fixed Battlerez Frame behaviour when attached to a frame. It now is not movable when attached to anything. When not attached, you can freely move it around, even outside of mover mode
]]

local Content091 = [[|cff1784d1Features

Revision 9010
• Updated for 8.3.0!
• Worldmap Markers can now be toggled via the default 'Dungeon Entrances' option in the Worldmap Tracking Menu
• All new Role and Combat Indicator Icons
• Added Threat Bar Config (Finally)
• Added Import/Export Feature for Profiles. It can be found under Profiles->Import/Export
• Completed Aura Filter System. You now can create your own filters and use them for Unit Buffs and Debuffs!
Also added default aura filter whitelist for Raid Debuffs!
• Added Unit Coloring System, that enables you to specify colors for unit names. A.e.: M+ Bombs or important Adds, which require immediate attention.
This can be found under Colors->Units
• Added total Itemlevel Text for inspected Units to the custom Armory Mode
• Added Casting Bar flash for the end of a cast. Also added size config under Unitframes->All->Castbar
• Added "Show All Nameplates" option to the nameplates section. This is a convenience change to quickly find the option, as it already exists in the Blizzard Config
• Added Options to change all Unitframes Absorption config. Unitframes->All->Absorption
• Added Reputation Bar Color option. Colors->Layout Bars
• Improved BattleRez frame behaviour
• You now can enable/disable the mover helper frame in mover mode. You still are able to use your arrow keys to move things
• Reduced Class Specific Class Power options to what options are actually available, instead of listing every single spec
• Updated lots of locale strings

Bugfixes

Revision 9010
• Resolved an issue with Tag Fonts, that basically munched away memory when changing font options
• Fixed Unitframes Level Font not correctly responding to a change of the "Not at Maxlevel" setting
• Fixed an issue with the Classpower Bar that caused Lua-Errors when changing the active profile
• Fixed an issue that caused Lua-Errors when changing the Azerite Bar color
• Fixed Inspect Background override
• Fixed an issue with Unit Buffs, which could not show up properly in some extremely rare cases
• The Armory Mode no longer highlights missing enchants on Off-Hand only Items such as Books etc.
• The Casting Bars now should behave correctly all the time
• The Casting Bars now properly update when the UI was hidden and shown again during a cast
• When changing Nameplate options via the Blizz config, CUI will now get the correct new values
]]
local Content090 = [[|cff1784d1Features

Revision 9000
Note: As of this version (Client Patch 8.2.5), there is a major bug with the Actioncam functionality, which is caused by the game client itself. More info in the Camera>Actioncam section of the config!

• Introduced a simplified version of the config module! You can switch to it via the dropdown in the config header (For now, this option exists, but the other config mode has no functionality)
• Added an aura filter system, which allows you to specify a white-/blacklist for your Aurabars. Make sure to select the appropiate Filter in your Aurabar config! Unitframes->Player/Target->Aura Bars->Filter Type
• Added an additional config section for character related settings (Masque, at the moment)
• Split Layout and (Experience, Azerite, Honor and Reputation)-Bar settings into separate sections
• The Number Format method (English, Metric, German etc.) now can be changed seamlessly without any reload required!
• You now can right-click a mover to temporarily hide it in anchor mode
• The Actioncam now can specifically be enabled/disabled by a single checkbox
• Various micro optimizations across the board (May result in major performance gains in heavy situations (Raids))
• Experience-, Azerite-, Honor- and Reputation Bar Animations now are much slower/smoother
• More translated strings!

Bugfixes

Revision 9000
• The Bags Masque setting now truly is character wide, instead of a normal profile value
• Armory settings now are global settings, as intended
• Readycheck indicator icon colors now should be correct
• The target highlight now will actually be disabled when it is supposed to
• World Font Overrides now work again! 
• Resetting all anchors now works as intended (multiple times)
• When using Masque, Aura borders now are displayed correctly again
• Unitframe clusters, Raid Control and Role Overview now are being hidden in pet battles
• Fixed Tooltip in Config not being hidden properly, when entering Anchor- or Keybind-Mode
• Actionbar fading now behaves as expected
• Fixed an issue where actionbar fading could produce Lua-Errors
• Fixed situations where the Aurabars module could throw Lua-Errors when the profile was changed
• Fixed Classbar module for some mysterious 8.2.5 changes

|r]]

local Content086 = [[|cff1784d1Bugfixes

Revision 8516
• Fixed an issue that would cause CUI fail to initialize

Revision 8517
• Reverted 8.2 PTR fix that corrected Micromenu, Zone- and Extra-Actionbutton scaling, as this was changed again in the 8.2 Release Version.

Revision 8518
• Fixed various situations where the Zone- and Extra Actionbuttons would not show up
• Unitframes now are being hidden correctly in pet battles
|r]]
local Content085 = [[|cff1784d1• Updated for 8.2
• Completed Dungeon Entrance Data
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
• Added resting indicator to player unitframe
• Added heal prediction to healthbars
• Added option to color healthbars based on the current health value
• Added color options for light, medium and heavy stagger
• Added tracking option for Worldmap Markers - directly in the Worldmap Tracking Menu!
• Added a more dynamic unitframe highlight system. Settings can be found under Unitframes -> All -> Misc
• Added an indicator to see what unit currently is targeted
• Added missing Lunar Power color option
• Added enchant name to custom armory
• Added gem display to custom armory
• Added options to toggle custom armory enchants, gems and itemlevel
• Added option to choose between all armory class backgrounds
• Added Masque support for all auras
• Added armory functionality to the inspect frame
• Added functionality to override some font options for every unitframe at once. Such as: Font Type, Size, Flags. Option can be found in Unitframes -> All -> Font
• Added a mover panel (in anchor mode), which allows for more precise positioning on the fly. Use either buttons or your arrow keys to move stuff!
• The armory item info now should be correct all the time, as long as the item was fully loaded
• Changed the way Aura Tooltip Source and ID are being shown
• Improved Unitframes performance
• Improved Cluster-Unitframe sort method, which also allows for specific sort rules
• Fixed screen-freeze at Uu'Nat when the whole raid becomes hostile/friendly
• All Unitframe Modules are now completely modular. This is more of a backend change but still worth mentioning
• All Masque settings now are a character setting and no longer affect the profile. This is to make spec-based profiles more seamless.
• Profile switching now is seamless

Bugfixes

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
• The "Autosell Greys" feature now does not report anything when the merchant is not a vendor (A.e.: A Repair Hammer and such)
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
	name = '|cff1784d1' .. L["Changelog"] .. '|r',
	order = -4,
	args = {
		Header_0930_90300 = {
			order = 5936,
			type = "header",
			name = "Minor • 0.9.3.0 Release • Rev. 90300 [Mar 24th 2026]",
		},
		Content_0930_90300 = {
			order = 5936,
			type = "description",
			name = Content0930_90300,
			fontSize = "medium",
		},
		Header_0922_90212 = {
			order = 5937,
			type = "header",
			name = "Minor • 0.9.2.2 Release • Rev. 90212 [Aug 18th 2021]",
		},
		Content_0922_90212 = {
			order = 5938,
			type = "description",
			name = Content0922_90212,
			fontSize = "medium",
		},
		Header_0921_90211 = {
			order = 5939,
			type = "header",
			name = "Minor • 0.9.2.1 Release • Rev. 90211 [Jan 18th 2021]",
		},
		Content_0921_90211 = {
			order = 5940,
			type = "description",
			name = Content0921_90211,
			fontSize = "medium",
		},
		Header_0921_90210 = {
			order = 5941,
			type = "header",
			name = "Minor • 0.9.2.1 Release • Rev. 90210 [Dec 11th 2020]",
		},
		Content_0921_90210 = {
			order = 5942,
			type = "description",
			name = Content0921_90210,
			fontSize = "medium",
		},
		Header_092_9029 = {
			order = 5943,
			type = "header",
			name = "Minor • 0.9.2 Release • Rev. 9029 [Nov 26th 2020]",
		},
		Content_092_9029 = {
			order = 5944,
			type = "description",
			name = Content092_9029,
			fontSize = "medium",
		},
		Header_092_9028 = {
			order = 5945,
			type = "header",
			name = "Minor • 0.9.2 Release • Rev. 9028 [Nov 23rd 2020]",
		},
		Content_092_9028 = {
			order = 5946,
			type = "description",
			name = Content092_9028,
			fontSize = "medium",
		},
		Header_092_9027 = {
			order = 5947,
			type = "header",
			name = "Minor • 0.9.2 Release • Rev. 9027 [Oct 20th 2020]",
		},
		Content_092_9027 = {
			order = 5948,
			type = "description",
			name = Content092_9027,
			fontSize = "medium",
		},
		Header_092_9026 = {
			order = 5949,
			type = "header",
			name = "Minor • 0.9.2 Release • Rev. 9026 [Oct 18th 2020]",
		},
		Content_092_9026 = {
			order = 5950,
			type = "description",
			name = Content092_9026,
			fontSize = "medium",
		},
		Header_092_9025 = {
			order = 5951,
			type = "header",
			name = "Minor • 0.9.2 Release • Rev. 9025 [Oct 14th 2020]",
		},
		Content_092_9025 = {
			order = 5952,
			type = "description",
			name = Content092_9025,
			fontSize = "medium",
		},
		Header_092_9024 = {
			order = 5953,
			type = "header",
			name = "Minor • 0.9.2 Release • Rev. 9024 [Oct 13th 2020]",
		},
		Content_092_9024 = {
			order = 5954,
			type = "description",
			name = Content092_9024,
			fontSize = "medium",
		},
		Header_092_9023 = {
			order = 5955,
			type = "header",
			name = "Minor • 0.9.2 Release • Rev. 9023 [Oct 13th 2020]",
		},
		Content_092_9023 = {
			order = 5956,
			type = "description",
			name = Content092_9023,
			fontSize = "medium",
		},
		Header_092 = {
			order = 5957,
			type = "header",
			name = "Major • 0.9.2 Release • Rev. 9022 [Oct 12th 2020]",
		},
		Content_092 = {
			order = 5958,
			type = "description",
			name = Content092,
			fontSize = "medium",
		},
		Header_0912 = {
			order = 5959,
			type = "header",
			name = "Minor • 0.9.1.2 Release • Rev. 9012 [March 3rd 2020]",
		},
		Content_0912 = {
			order = 5960,
			type = "description",
			name = Content0912,
			fontSize = "medium",
		},
		Header_0911 = {
			order = 5961,
			type = "header",
			name = "Minor • 0.9.1.1 Release • Rev. 9011 [February 24th 2020]",
		},
		Content_0911 = {
			order = 5962,
			type = "description",
			name = Content0911,
			fontSize = "medium",
		},
		Header_091 = {
			order = 5963,
			type = "header",
			name = "Major • 0.9.1 Release • Rev. 9010 [January 13th 2020]",
		},
		Content_091 = {
			order = 5964,
			type = "description",
			name = Content091,
			fontSize = "medium",
		},
		Header_090 = {
			order = 5965,
			type = "header",
			name = "Major • 0.9.0 Release • Rev. 9000 [October 3rd 2019]",
		},
		Content_090 = {
			order = 5966,
			type = "description",
			name = Content090,
			fontSize = "medium",
		},
		Header_086 = {
			order = 5969,
			type = "header",
			name = "Minor • 0.8.6 Release • Rev. 8518 [July 4th 2019]",
		},
		Content_086 = {
			order = 5970,
			type = "description",
			name = Content086,
			fontSize = "medium",
		},
		Header_085 = {
			order = 5971,
			type = "header",
			name = "Major • 0.8.5 Release • Rev. 8515 [June 21st 2019]",
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