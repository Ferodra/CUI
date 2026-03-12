local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF = E:LoadModules("Config", "Unitframes")

--[[--------------------
	Unitframe Extension	
--------------------]]--

local _
local tinsert				= table.insert
local UnitHealth			= UnitHealth
local UnitHealthMax			= UnitHealthMax
local UnitHealthMissing		= UnitHealthMissing
local UnitGetIncomingHeals	= UnitGetIncomingHeals

local Module = {}
Module.Handles = {}
Module.Dependencies = {'Health'}

local BarTexture = [[Interface\AddOns\CUI\Textures\borders\WHITE8X8]]

-----------------------------------------

local function UpdateElement(self, event, unit)
	if self.Disabled or unit ~= self.Owner.unit then return end
	
	self:SetMinMaxValues(0, UnitHealthMissing(unit))
	self:SetValue(UnitGetIncomingHeals(unit) or 0)
end

local function ForceUpdate(self)
	UpdateElement(self, nil, self.Owner.unit)
end

----------

function Module:LoadConfig()
	local Config, Element
	
	for _, self in pairs(Module.Handles) do
		Config = CO.db.profile.unitframe.units[self.ConfigKey]
		Element = self.HealPrediction
		
		if Config.healPrediction then
			Element:UnregisterAllEvents()
			
			if not Config.healPrediction.enable then
				Element:Hide()
				Element.Disabled = true
			else				
				Element:SetParent(self.Health)
				self.Health:SetSubBar(Element, false, Config.health.barInverseFill, Config.health.barOrientation)
				
				Element:RegisterUnitEvent("UNIT_HEAL_PREDICTION", Element.Owner.unit)
				Element:RegisterUnitEvent("UNIT_HEALTH", Element.Owner.unit)
				if not E.IsRetail and Config.health.fastUpdate then
					Element:RegisterEvent("UNIT_HEALTH_FREQUENT")
				end
				
				Element:Show()
				Element.Disabled = false
			end
		end
	end
end

function Module:Create(F)
	local Element = UF:CreateUFBar()
	
	Element:SetStatusBarTexture(BarTexture)
	Element:SetStatusBarColor(0.1, 0.6, 0.9, 0.5)
	Element:SetValue(0)
	
	Element.Owner = F
	Element:SetScript("OnEvent", UpdateElement)
	Element.ForceUpdate = ForceUpdate
	
	F.HealPrediction = Element
	tinsert(Module.Handles, F)
end

---------- Add Module
UF.Modules["HealPrediction"] = Module