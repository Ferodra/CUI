---@class E, L
local E, L = unpack(select(2, ...)) -- Engine, Locale

-- Those are the main resources for each class and spec.
-- If there is no alternate power available, use the regular one.
-- false if the power should not be displayed on the classbar

-- Key: Class ID
-- [ClassID]: {[SpecID] = PowerID}
E.ClassPowers = {
	[1] = {[1] = false,[2] = false,[3] = false},
	[2] = {[1] = 9,[2] = 9,[3] = 9},
	[3] = {[1] = false,[2] = false,[3] = false},
	[4] = {[1] = 4,[2] = 4,[3] = 4},
	[5] = {[1] = false,[2] = false,[3] = 0},
	[6] = {[1] = 5,[2] = 5,[3] = 5},
	[7] = {[1] = false,[2] = false,[3] = false},
	--[8] = {[1] = 16,[2] = false,[3] = 33}, -- Frost[3] has special handling through Classbar logic
	[8] = {[1] = 16,[2] = false,[3] = false}, -- Frost[3] disabled until we can properly read buffs again..
	[9] = {[1] = 7,[2] = 7,[3] = 7},
	--[10] = {[1] = 30,[2] = 0,[3] = 12},
	[10] = {[1] = false,[2] = 0,[3] = 12}, -- Stagger (1) disabled until we can do calcs with health again..
	[11] = {[1] = 8,[2] = 4,[3] = 1, [4] = 0},
	[12] = {[1] = false,[2] = false},
	[13] = {[1] = 19,[2] = 19,[3] = 19},
}