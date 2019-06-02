local E, L = unpack(select(2, ...)) -- Engine, Locale

-- Those are the main resources for each class and spec.
-- If there is no alternate power available, use the regular one.

-- Key: Class ID
-- [ClassID]: {[SpecID] = PowerID}
E.ClassPowers = {
	[1] = {[1] = 1,[2] = 1,[3] = 1},
	[2] = {[1] = 0,[2] = 0,[3] = 9},
	[3] = {[1] = 2,[2] = 2,[3] = 2},
	[4] = {[1] = 4,[2] = 4,[3] = 4},
	[5] = {[1] = 0,[2] = 0,[3] = 0},
	[6] = {[1] = 5,[2] = 5,[3] = 5},
	[7] = {[1] = 0,[2] = 0,[3] = 0},
	[8] = {[1] = 16,[2] = 0,[3] = 0},
	[9] = {[1] = 7,[2] = 7,[3] = 7},
	[10] = {[1] = 30,[2] = 0,[3] = 12},
	[11] = {[1] = 8,[2] = 4,[3] = 1, [4] = 0},
	[12] = {[1] = 17,[2] = 18},
}