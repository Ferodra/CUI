local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF = E:LoadModules('Config', 'Unitframes')

--[[--------------------
	Unitframe Extension	
--------------------]]--

local pairs			= pairs
local tinsert		= table.insert
local Module = {}

-----------------------------------------
-- Only one of them can be used at a time
-- Use regular table values like {'player','target', ...}
-----
-- Module.IncludeUnits = {}
-- Module.ExcludeUnits = {}
-----------------------------------------
-----------------------------------------

local EventHandler = CreateFrame('Frame')
local Events = {}

local function UpdateElement(Element)
	-- Do stuff
end

do
	-- Handles all event updates for this module
	-- This can alternatively be replaced by an OnEvent function, while the Element itself listens to specific events
	for k, v in pairs(Events) do
		EventHandler:RegisterEvent(v)
	end
	EventHandler.Handles = {}
	EventHandler:SetScript('OnEvent', function(self, event, ...)
		for _, F in pairs(self.Handles) do
			UpdateElement(F.Element)
		end
	end)
end

----------

-- Gets called automatically when the unitframes first are initialized and on config update
function Module:LoadConfig()
	local Config
	
	for _, self in pairs(EventHandler.Handles) do
		Config = CO.db.profile.unitframe.units[self.ConfigKey]
		
		-- Load stuff from config variable
	end
end

function Module:Create(F)
	
	-- @TODO: Auto-determine if this module should be added to a unitframe.
	--			This would open the possibility for easy plugin support
	local Element = CreateFrame("Frame")
	
	Element.Owner = F
	Element.ForceUpdate = UpdateElement
	Element.UpdateUnit = UpdateUnit
	
	F.CustomModule = Element
	
	tinsert(EventHandler.Handles, F)
end

---------- Add Module
UF:RegisterModule('CustomModule', Module)