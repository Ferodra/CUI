-- DropDownModify is an API that provides easy manipulation of dropdown menus


local MAJOR, MINOR = "DropDownModify-1.0", 1
assert(LibStub, MAJOR .. " requires LibStub")

local DDM, oldversion = LibStub:NewLibrary(MAJOR, MINOR)
if not DDM then return end -- No upgrade needed

--[[--------
	CORE
--]]--------

local Listeners = {}

-- Registers any modifications to an dropdown menu
-- arg1: (frame) The DropDown frame reference
-- arg2: (function) A function containing the modifications (See https://wow.gamepedia.com/Using_UIDropDownMenu)
-- [arg3: (number) (Optional) The DropDown level that has to be visible for the function]
-- return: (number) Mod index. Required to unregister
local Usage = "(Usage: Menu, Function[, Level])"
function DDM:RegisterMod(Menu, Func, Level)
	assert(Menu and (type(Menu) == "table" or type(Menu) == "userdata"), "Not a valid DropDown Menu " .. Usage)
	assert(Func and type(Func) == "function", "Not a valid function" .. Usage)
	if Level then
		assert(tonumber(Level), "Not a valid DropDown Level " .. Usage)
	end
	
	Listeners[#Listeners + 1] = {["Menu"] = Menu, ["Func"] = Func, ["Level"] = tonumber(Level) or 1}
	
	return #Listeners
end

function DDM:UnregisterMod(Index)
	Listeners[Index] = nil
end

local function Listen(_, _, DropDown)
	for _, Data in pairs(Listeners) do
		-- If the DropDown arg is one of the registered menus AND the dropdown is visible
		if DropDown == Data.Menu and _G["DropDownList" .. Data.Level]:IsVisible() then
			
			-- From here, we can simply proceed to add stuff like we always would do to an dropdown
			-- This works, since the method Blizzard coded dropdowns uses ONE dropdown menu for EVERYTHING
			-- When it is being shown, every call to UIDropDownMenu_AddButton goes to exactly the menu that is currently active/open
			
			Data.Func()
		end
	end
end

-- Callback when an dropdown is being toggled
hooksecurefunc("ToggleDropDownMenu", Listen)