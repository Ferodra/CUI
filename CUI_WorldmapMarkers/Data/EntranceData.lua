local WMM = select(2, ...)

-- 75 -- By using instance IDs, we can get the real ID here
-- Global string list can be found on https://github.com/tekkub/wow-globalstrings/tree/master/GlobalStrings

-- Syntax:
-- [continentIndex] = {
--	[zoneIndex] = {
--		[internalNum] = {InstanceID, IsRaid, MapPosX, MapPosY, OPTIONALSubZoneText},
--	}
-- }

WMM.Markers = {
	-- Kalimdor
	--[1] = {
		-- Wastelands
		[15] = {
			[2] = {239, false, 41.85, 11.55}, -- Uldaman
		},
		-- Tirisfal
		[18] = {
			[1] = {"floor", "Scarlet Monastery", 82.31, 33.12, 19}, -- Navigation to Scarlet Monastery
		},
		-- Scarlet Monastery
		[19] = {
			[1] = {"floor", EXIT, 15.71, 77.29, 18}, -- Navigation to Tirisfal
			[2] = {316, false, 69.65, 26.44}, -- Scarlet Monastery
			[3] = {311, false, 78.04, 56.66}, -- Scarlet Halls
		},
		-- Dun Morogh
		[27] = {
			[1] = {"floorDown", DUNGEON_FLOOR_DUNMOROGH10, 30.75, 36.85, 30}, -- Navigation to Gnomeregan
		},
		-- Gnomeregan
		[30] = {
			[1] = {"floorUp", EXIT, 77.26, 83.79, 469}, -- Navigation to Dun Morogh
			[2] = {231, false, 30.23, 74.39, DUNGEON_FLOOR_GNOMEREGAN1}, -- Gnomeregan
			[3] = {231, false, 45.00, 12.75, DUNGEON_FLOOR_GNOMEREGAN1}, -- Gnomeregan
		},
		-- Gnome Starting Area
		[469] = {
			[1] = {"floorDown", DUNGEON_FLOOR_DUNMOROGH10, 32.95, 36.15, 30}, -- Navigation to Gnomeregan
		},
		-- Searing Gorge
		[32] = {
			[1] = {"floor", DUNGEON_FLOOR_SEARINGGORGE14, 34.78, 83.41, 33}, -- Navigation to Blackrock Mountains
		},
		-- Blackrock Mountains
		[33] = {
			[1] = {"floor", EXIT, 51.54, 91.60, 36}, -- Navigation to Burning Steppes
			[2] = {"floor", EXIT, 46.66, 11.72, 32}, -- Navigation to Searing Gorge
			[3] = {"floor", DUNGEON_FLOOR_SEARINGGORGE16, 45.87, 48.70, 35}, -- Navigation to Blackrock Depths
			[4] = {"floor", DUNGEON_FLOOR_SEARINGGORGE15, 66.86, 60.78, 34}, -- Navigation to Blackrock Caverns
			[5] = {"floor", DUNGEON_FLOOR_SEARINGGORGE15, 72.86, 43.07, 34}, -- Navigation to Blackrock Caverns
			[6] = {559, false, 79.03, 34.75}, -- Upper Blackrock Spire
			[7] = {229, false, 80.39, 40.91}, -- Lower Blackrock Spire
			[8] = {742, true, 64.17, 71.28}, -- Blackwing Lair
		},
		-- Blackrock Caverns
		[34] = {
			[1] = {"floor", DUNGEON_FLOOR_SEARINGGORGE14, 40.63, 80.55, 33}, -- Navigation to Blackrock Mountains
			[2] = {"floor", DUNGEON_FLOOR_SEARINGGORGE14, 58.41, 27.78, 33}, -- Navigation to Blackrock Mountains
			[3] = {66, false, 71.57, 53.39}, -- Blackrock Caverns
		},
		-- Blackrock Depths
		[35] = {
			[1] = {"floor", DUNGEON_FLOOR_SEARINGGORGE14, 57.00, 88.53, 33}, -- Navigation to Blackrock Mountains
			[2] = {228, false, 39.02, 18.15}, -- Blackrock Depths
			[3] = {741, true, 53.75, 81.38}, -- Molten Core
		},
		-- Burning Steppes
		[36] = {
			[1] = {"floor", DUNGEON_FLOOR_SEARINGGORGE14, 21.01, 38.02, 33}, -- Navigation to Blackrock Mountains
			[2] = {73, true, 24.01, 26.56}, -- Blackrock Descent
		},
		-- Deadwind Pass
		[42] = {
			[1] = {745, true, 47.04, 74.96}, -- Karazhan
			[2] = {860, false, 46.83, 70.06}, -- Return to Karazhan
		},
		-- Northern Stranglethorn Valley
		[50] = {
			[1] = {76, false, 72.00, 32.90}, -- Zul'Gurub
		},
		-- Swamp of Sorrows
		[51] = {
			[1] = {237, false, 69.67, 53.62}, -- Temple of Atal'Hakkar
		},
		-- Westfall
		[52] = {
			[1] = {"floorDown", DUNGEON_FLOOR_THEDEADMINES1, 43.04, 71.88, 55}, -- Navigation to Deadmines
		},
		-- Deadmines
		[55] = {
			[1] = {"floorUp", EXIT, 69.40, 20.63, 52}, -- Navigation to Westfall
			[2] = {63, false, 27.95, 51.45}, -- Deadmines
		},
		-- Desolace
		[66] = {
			[1] = {"floorLeft", DUNGEON_FLOOR_DESOLACE21, 29.18, 62.57, 67}, -- Navigation to Maraudon Caverns
		},
		-- Maraudon Entrance Cave
		[67] = {
			[1] = {"floorRight", EXIT, 24.10, 43.48, 66}, -- Navigation to Desolace
			[2] = {"floorDown", DUNGEON_FLOOR_DESOLACE22, 29.10, 42.76, 68}, -- Navigation to Maraudon Foulspore Cavern
			[3] = {"floorDown", DUNGEON_FLOOR_DESOLACE22, 27.37, 34.07, 68}, -- Navigation to Maraudon Foulspore Cavern
			[4] = {232, false, 78.27, 54.84, DUNGEON_FLOOR_DESOLACE22}, -- Foulspore Cavern
		},
		-- Maraudon Foulspore Cavern
		[68] = {
			[1] = {"floorUp", DUNGEON_FLOOR_DESOLACE21, 47.08, 88.26, 67}, -- Navigation to Maraudon Entrance Cave
			[2] = {"floorUp", DUNGEON_FLOOR_DESOLACE21, 48.19, 77.08, 67}, -- Navigation to Maraudon Entrance Cave
			[3] = {232, false, 44.42, 76.84, "Earth Song Falls"}, -- Earth Song Falls
			[4] = {232, false, 50.76, 24.88, DUNGEON_FLOOR_DESOLACE21}, -- Wicked Grotto
		},
		-- Dustwallow Marsh
		[70] = {
			[1] = {760, true, 52.48, 76.51}, -- Onyxias Lair
		},
		-- Ashenvale
		[63] = {
			[1] = {227, false, 14.13, 13.96}, -- Blackfathoms Deeps
		},
		-- Feralas
		[69] = {
		
			[1] = {230, false, 60.32, 30.23, DUNGEON_FLOOR_DIREMAUL2}, -- Diremaul
			[2] = {230, false, 64.84, 30.30, DUNGEON_FLOOR_DIREMAUL5}, -- Diremaul
			[3] = {230, false, 66.77, 34.84, DUNGEON_FLOOR_DIREMAUL5}, -- Diremaul
			[4] = {230, false, 62.47, 24.89, DUNGEON_FLOOR_DIREMAUL1}, -- Diremaul
		},
		-- Stormwind
		[84] = {
			[1] = {238, false, 51.45, 68.16}, -- The Stockade
		},
		-- Ghostlands
		[95] = {
			[1] = {77, false, 82.00, 64.33}, -- Zul'Aman
		},
		-- Hyjal
		[198] = {
			[1] = {78, true, 47.61, 77.89}, -- Firelands
		},
		-- Shadowmoon Valley (Outland)
		[104] = {
			[1] = {751, true, 71.02, 46.21}, -- Black Temple
		},
		-- Blades Edge Mountains
		[105] = {
			[1] = {746, true, 68.17, 24.37}, -- Gruul's Lair
		},
		-- Forests of Terrokar
		[108] = {
			[1] = {252, false, 41.99, 65.60}, -- Sethekk Halls
			[2] = {253, false, 39.63, 69.14}, -- Shadow Labyrinth
			[3] = {247, false, 37.32, 65.62}, -- Auchenai Crypts
			[4] = {250, false, 39.65, 62.25}, -- Mana Tombs
		},
		-- Borean Tundra
		[114] = {
			[1] = {756, true, 27.58, 27.63}, -- Eye of Eternity
			[2] = {282, false, 28.61, 26.57}, -- The Oculus
			[3] = {281, false, 26.49, 26.11}, -- The Nexus
		},
		-- Dragonblight
		[115] = {
			[1] = {761, true, 61.19, 52.74}, -- Ruby Sanctum
			[2] = {755, true, 60.00, 56.73}, -- Obsidian Sanctum
			[3] = {754, true, 87.35, 50.99}, -- Naxxramas
			[4] = {271, false, 28.35, 51.66}, -- Ahn'kahet: The Old Kingdom
			[5] = {272, false, 26.01, 50.83}, -- Azjol-Nerub
		},
		-- Icecrown
		[118] = {
			[1] = {758, true, 53.24, 85.22}, -- Icecrown Citadel
			[2] = {757, true, 75.17, 21.81}, -- Trial of the Crusader
			[3] = {284, false, 74.18, 20.41}, -- Trial of the Champion
			[4] = {278, false, 54.70, 91.62}, -- Pit of Saron
			[5] = {276, false, 55.13, 90.82}, -- Halls of Reflection
			[6] = {280, false, 54.71, 90.02}, -- The Forge of Souls
			[7] = {"floorRight", "Entrance to Dungeons", 52.17, 89.29, 118}, -- Nav to Icecrown
		},
		-- Isle of Quel'Danas
		[122] = {
			[1] = {752, true, 44.26, 45.51}, -- Sunwell Plateau
			[2] = {249, false, 61.03, 30.74}, -- Magisters' Terrace
		},
		-- Wintergrasp
		[123] = {
			[1] = {753, true, 50.00, 16.53}, -- Vault of Archavon
		},
		-- Northern Barrens
		[10] = {
			[1] = {240, false, 38.91, 69.37}, -- Wailing Caverns
		},
		-- Silverpine Forest
		[21] = {
			[1] = {64, false, 44.93, 67.92}, -- Shadowfang Keep
		},
		-- Western Plaguelands
		[22] = {
			[1] = {246, false, 69.74, 73.44}, -- Scholomance
		},
		-- Eastern Plaguelands
		[23] = {
			[1] = {236, false, 26.43, 11.60, DUNGEON_FLOOR_STRATHOLME1}, -- Stratholme: Main Gate
			[2] = {236, false, 43.46, 19.46, DUNGEON_FLOOR_STRATHOLME2}, -- Stratholme: Service Entrance
		},
		-- Silithus
		[81] = {
			[1] = {"floor", DUNGEON_FLOOR_RUINSOFAHNQIRAJ1, 35.89, 84.51, 327}, -- Navigation to Ahn'Qiraj
		},
		-- Orgrimmar
		[85] = {
			[1] = {"floorDown", DUNGEON_FLOOR_ORGRIMMAR1, 42, 60.07, 86} -- Navigation to Kluft der Schatten
		},
		-- Kluft der Schatten
		[86] = {
			[1] = {226, false, 67.6, 50.9} -- Ragefire Chasm
		},
		-- Ahn'Qiraj
		[327] = {
			[1] = {743, true, 58.95, 14.16}, -- Ruins of Ahn'Qiraj
			[2] = {744, true, 46.79, 7.50}, -- Temple of Ahn'Qiraj
		},
		-- Southern Barrens
		[199] = {
			[1] = {234, false, 41.02, 94.65}, -- Kral der Klingenhauer
		},
		-- Tanaris
		[71] = {
			[1] = {241, false, 39.22, 21.62}, -- Zul'Farrak
			[2] = {"floorRight", DUNGEON_FLOOR_TANARIS17, 64.53, 50.04, 74},
		},
		-- Tanaris, Timeless Tunnels
		[74] = {
			[1] = {"floorLeft", EXIT, 55.45, 28.83, 71}, -- Navigation to Tanaris
			[2] = {"floorDown", DUNGEON_FLOOR_TANARIS18, 32.76, 73.95, 75}, -- Navigation to Caverns of Time
		},
		-- Caverns of Time
		[75] = {
			[1] = {187, true, 60.82, 21.14}, -- Dragonsoul
			[2] = {186, false, 68.41, 29.53}, -- Hour of Twilight
			[4] = {750, true, 35.91, 16.03}, -- Battle for Mount Hyjal
			[5] = {251, false, 26.87, 36.16}, -- Escape from Durnholde Keep
			[6] = {185, false, 22.66, 64.27}, -- Well of Eternity
			[7] = {255, false, 36.76, 83.44}, -- Opening of the Dark Portal
			[8] = {279, false, 57.13, 82.63}, -- The Culling of Stratholme
			[9] = {184, true, 57.46, 29.51}, -- End Time
			[10] = {"floorUp", DUNGEON_FLOOR_TANARIS17, 62.53, 53.07, 74}, -- Navigation to Timeless Tunnels
		},
		-- Thousand Needles
		[64] = {
			[1] = {233, false, 46.63, 23.52}, -- Hügel der Klingenhauer
		},
		-- Tol Barad
		[244] = {
			[1] = {75, true, 46.07, 47.97}, -- Baradin Hold
		},
		-- Uldum
		[249] = {
			[1] = {74, true, 38.49, 80.56}, -- Throne of the Four Winds
			[2] = {68, false, 76.71, 84.37}, -- The Vortex Pinnacle
			[3] = {69, false, 60.51, 64.10}, -- Lost City of Tol'Vir
			[4] = {70, false, 71.88, 52.17}, -- Halls of Origination
		},
	--},
	-- Eastern Kingdoms
	--[2] = {
		-- Abyssal Deeps
		[204] = {
			[1] = {65, false, 70.85, 29.42}, -- Throne of Tides
		},
	--},
	-- Outland
	--[3] = {
		-- Hellfire Peninsula
		[100] = {
			[1] = {248, false, 47.76, 53.52}, -- Hellfire Ramparts
			[2] = {259, false, 48.21, 51.85}, -- Shattered Halls
			[3] = {256, false, 46.15, 51.67}, -- Blood Furnace
			[4] = {747, true, 46.51, 52.84}, -- Magtheridon's Lair
		},
		-- Zangarmarsh
		[102] = {
			[1] = {"floorDown", "Entrances are down the pipe", 50.02, 41.10, 102}, -- Nav to Coilfang Reservoir
			[2] = {748, true, 51.90, 33.74}, -- Coilfang Reservoir
			[3] = {260, false, 48.95, 36.04}, -- The Slave Pens
			[4] = {261, false, 50.48, 33.33}, -- The Steamvault
			[5] = {262, false, 54.14, 34.48}, -- The Underbog
		},
		-- Netherstorm
		[109] = {
			[1] = {257, false, 71.62, 55.19}, -- The Botanica
			[2] = {258, false, 70.48, 69.55}, -- The Mechanar
			[3] = {254, false, 74.30, 57.79}, -- The Arcatraz
			[4] = {749, true, 73.57, 63.73}, -- Tempest Keep
		},
	--},
	-- Northrend
	--[4] = {
		-- Grizzly Hills
		[116] = {
			[1] = {273, false, 17.54, 23.39}, -- Drak'Tharon
		},
		-- Howling Fjord
		[117] = {
			[1] = {285, false, 57.22, 46.49}, -- Utgarde Pinnacle
			[2] = {286, false, 58.01, 50.04}, -- Utgarde Keep
		},
		-- Stormpeaks
		[120] = {
			[1] = {759, true, 41.56, 17.99}, -- Ulduar
			[2] = {277, false, 39.64, 26.91}, -- Halls of Stone
			[3] = {275, false, 45.34, 21.43}, -- Halls of Lightning
		},
		-- Zul'Drak
		[121] = {
			[1] = {273, false, 28.58, 86.94}, -- Drak'Tharon
			[2] = {274, false, 76.28, 21.20}, -- Gundrak
		},
	--},
		-- Shadow Highlands
		[241] = {
			[1] = {72, true, 34.05, 77.89}, -- The Bastion of Twilight
			[2] = {71, false, 19.21, 54.11}, -- Grim Batol
		},
	-- The Maelstrom
	--[5] = {
		-- Deepholm
		[207] = {
			[1] = {67, false, 47.39, 52.06}, -- The Stonecore
		},
	--},
	-- Pandaria
	--[6] = {
		-- Everblossom
		[390] = {
			[1] = {369, true, 72.52, 44.14}, -- Siege of Orgrimmar
			[2] = {303, false, 15.85, 74.34}, -- Gate of the Setting Sun
			[3] = {321, false, 80.74, 32.86}, -- Mogu'shan Palace
		},
		-- The Jadeforest
		[371] = {
			[1] = {313, false, 56.17, 57.86}, -- Temple of the Jade Serpent
		},
		-- The Hidden Stairs
		[433] = {
			[1] = {320, true, 48.44, 61.45}, -- Terrace of Endless Spring
		},
		-- Isle of Thunder
		[504] = {
			[1] = {362, true, 63.59, 32.39}, -- Throne of Thunder
		},
		-- Kun-Lai
		[379] = {
			[1] = {312, false, 36.70, 47.43}, -- Shado-Pan Monastery
			[2] = {317, true, 59.61, 39.19}, -- Mogu'Shan Vault
		},
		-- Schreckensöde
		[422] = {
			[1] = {330, true, 38.92, 34.99}, -- Heart of Fear
		},
		-- Valley of Four Winds
		[376] = {
			[1] = {302, false, 36.06, 69.12}, -- Stormstout Brewery
		},
		-- Tonlong
		[388] = {
			[1] = {324, false, 34.67, 81.47}, -- Siege of Niuzao Zemple
		},
	--},
	-- Draenor
	--[7] = {
		-- Frostfire Ridge
		[525] = {
			[1] = {385, false, 49.86, 24.76}, -- Bloodmaul Slag Mines
		},
		-- Gorgrond
		[543] = {
			[1] = {558, false, 45.38, 13.54}, -- Iron Docks
			[2] = {457, true, 51.34, 28.52}, -- Blackrock Foundry
			[3] = {536, false, 55.24, 32.07}, -- Grimrail Depot
			[4] = {556, false, 59.59, 45.52}, -- The Everbloom
		},
		-- Nagrand
		[550] = {
			[1] = {477, true, 32.59, 38.39}, -- Highmaul
		},
		-- Shadowmoon Valley
		[539] = {
			[1] = {537, false, 31.92, 42.48}, -- Shadowmoon Burial Grounds
		},
		-- Peaks of Arak
		[542] = {
			[1] = {476, false, 35.59, 33.58}, -- Skyreach
		},
		-- Talador
		[535] = {
			[1] = {547, false, 46.30, 73.94}, -- Auchindoun
		},
		-- Tanaan Jungle
		[534] = {
			[1] = {669, true, 45.54, 53.60}, -- Hellfire Citadel
		},
	--},
	--[8] = {
		
	--},
	--[9] = {
		
	--},
	
}