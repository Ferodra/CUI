local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF = E:LoadModules("Config", "Unitframes")

--[[--------------------
	Unitframe Extension	
--------------------]]--

local _
local pairs			= pairs
local tinsert		= table.insert
local Module = {}
Module.ExcludeUnits = {'pet', 'boss'}

-----------------------------------------

local EventHandler = CreateFrame("Frame")
local Events = {"INCOMING_RESURRECT_CHANGED"}

local function UpdateElement(self, unit)
	if self.Disabled or (unit and unit ~= self.Owner.unit) then return end
	
	if UnitHasIncomingResurrection(self.Owner.unit) then
		self:Show()
	else
		self:Hide()
	end
end

do
	-- Handles all event updates for this module
	for k, v in pairs(Events) do
		EventHandler:RegisterEvent(v)
	end
	EventHandler.Handles = {}
	EventHandler:SetScript("OnEvent", function(self, event, unit)
		for _, F in pairs(self.Handles) do
			UpdateElement(F.ResurrectIndicator, unit)
		end
	end)
end

----------

-- Gets called automatically when the unitframes first are initialized and on config update
function Module:LoadConfig()
	local Config, Element
	
	for _, self in pairs(EventHandler.Handles) do
		Config = CO.db.profile.unitframe.units[self.ConfigKey]
		
		if Config.resIndicator then
			Element = self.ResurrectIndicator
			
			if not Config.resIndicator.enable then Element:Hide(); Element.T:SetTexture(nil) Element.Disabled = true; else
				Element.T:SetTexture([[Interface\RaidFrame\Raid-Icon-Rez]])
				Element:ClearAllPoints()
				Element:SetPoint("CENTER", self.Overlay, Config.resIndicator.position, Config.resIndicator.offsetX, Config.resIndicator.offsetY)
				Element:SetSize(Config.resIndicator.size, Config.resIndicator.size)
				Element:SetFrameLevel(self.Overlay:GetFrameLevel() + 25)
				
				Element.Disabled = false
			end
		end
	end
end

function Module:Create(F)
	local Element = E:CreateTextureFrame(nil, F, 20, 20, "ARTWORK")
	Element.ForceUpdate = UpdateElement
	Element.Owner = F
	
	Element:Hide()
	
	F.ResurrectIndicator = Element
	tinsert(EventHandler.Handles, F)
end

---------- Add Module
UF.Modules["ResurrectIndicator"] = Module