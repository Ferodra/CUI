---@class E, L
local E, L = unpack(select(2, ...)) -- Engine, Locale

-- Those are the main resources for each class and spec.
-- If there is no alternate power available, use the regular one.
-- false if the power should not be displayed on the classbar

-- Key: Class ID
-- [ClassID]: {[SpecID] = PowerID}
local Colors = {
	['none']    = { ['r'] = 0.80, ['g'] = 0, ['b'] = 0 },
    ["Magic"]   = { ['r'] = 0.20, ['g'] = 0.60, ['b'] = 1.00 },
    ["Curse"]   = { ['r'] = 0.60, ['g'] = 0.00, ['b'] = 1.00 },
    ["Disease"] = { ['r'] = 0.60, ['g'] = 0.40, ['b'] = 0 },
    ["Poison"]  = { ['r'] = 0.00, ['g'] = 0.60, ['b'] = 0 }
}

E.DebuffTypeColor = {}

-- Convert to color object
do
    for name, entry in pairs(Colors) do
        E.DebuffTypeColor[name] = CreateColor(entry.r, entry.g, entry.b)
    end
end