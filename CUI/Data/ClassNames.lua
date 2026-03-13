---@class E, L
local E, L = unpack(select(2, ...)) -- Engine, Locale

-- Those are the main resources for each class and spec.
-- If there is no alternate power available, use the regular one.
-- false if the power should not be displayed on the classbar

-- Key: Class Identifier
-- [ClassID]: <Localized gendered class name>


--[[-----------
	CLASS NAMES
-----------]]--

E.ClassNames = {}

for k,v in pairs((UnitSex("player") == 2) and LOCALIZED_CLASS_NAMES_MALE or LOCALIZED_CLASS_NAMES_FEMALE) do
	E.ClassNames[k] = v
end