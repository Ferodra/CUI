local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF = E:LoadModules("Config", "Unitframes")

--[[--------------------
	Unitframe Extension	
--------------------]]--

local pairs			= pairs
local tinsert		= table.insert
local Module = {}

-----------------------------------------

local EventHandler = CreateFrame("Frame")
local Events = {}

local function UpdateElement(Element)
	
end

do
	-- Handles all event updates for this module
	for k, v in pairs(Events) do
		EventHandler:RegisterEvent(v)
	end
	EventHandler.Handles = {}
	EventHandler:SetScript("OnEvent", function(self, event, ...)
		for _, F in pairs(self.Handles) do
			UpdateElement(F.Element)
		end
	end)
end

----------

-- Gets called automatically when the unitframes first are initialized and on config update
function Module:LoadProfile()
	local Config
	
	for _, self in pairs(EventHandler.Handles) do
		Config = CO.db.profile.unitframe.units[self.ProfileUnit]
		
		
	end
end

function Module:Create(F)
	
	-- @TODO: Auto-determine if this module should be added to a unitframe.
	--			This would open the possibility for easy plugin support
	
	F.Element.ForceUpdate = UpdateElement
	
	tinsert(EventHandler.Handles, F)
end

---------- Add Module
UF.Modules["CustomModule"] = Module