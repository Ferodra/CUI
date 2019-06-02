local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF = E:LoadModules("Config", "Unitframes")

--[[--------------------
	Unitframe Extension	
--------------------]]--

local _
local Module = {}
Module.Handles = {}

-----------------------------------------

local function UpdateElement(self, event)
	if self.Disabled then return end
	
	self:SetMinMaxValues(0, (UnitHealthMax(self.Unit) - UnitHealth(self.Unit)))
	self:SetValue(UnitGetIncomingHeals(self.Unit) or 0)
end

local function ForceUpdate(self)
	UpdateElement(self, nil)
end

----------

local ProfileTarget
function Module:LoadProfile()
	for _, self in pairs(Module.Handles) do
		ProfileTarget = CO.db.profile.unitframe.units[self.ProfileUnit]
		
		if ProfileTarget.healPrediction then
			if not ProfileTarget.healPrediction.enable then
				self.Health.HealPrediction:UnregisterAllEvents()
				
				self.Health.HealPrediction:Hide()
				self.Health.HealPrediction.Disabled = true;
			else				
				self.Health.HealPrediction:SetParent(self.Health)
				
				self.Health:SetSubBar(self.Health.HealPrediction, false, ProfileTarget.health.barInverseFill, ProfileTarget.health.barOrientation)
				
				if not self.Health.HealPrediction:IsEventRegistered("UNIT_HEAL_PREDICTION") then
					self.Health.HealPrediction:RegisterUnitEvent("UNIT_HEAL_PREDICTION", self.Unit)
				end
				if ProfileTarget.health.fastUpdate then
					self.Health.HealPrediction:UnregisterEvent("UNIT_HEALTH")
					self.Health.HealPrediction:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", self.Unit)
				else
					self.Health.HealPrediction:UnregisterEvent("UNIT_HEALTH_FREQUENT")
					self.Health.HealPrediction:RegisterUnitEvent("UNIT_HEALTH", self.Unit)
				end
				
				self.Health.HealPrediction:Show()
				self.Health.HealPrediction.Disabled = false;
			end
		end
	end
end

function Module:Create(F)
	F.Health.HealPrediction = UF:CreateUFBar()
	F.Health.HealPrediction:SetStatusBarTexture([[Interface\Buttons\WHITE8X8]])
	F.Health.HealPrediction:SetStatusBarColor(0.1, 0.6, 0.9, 0.5)
	F.Health.HealPrediction:SetValue(0)
	
	F.Health.HealPrediction.Unit = F.Unit
	F.Health.HealPrediction:SetScript("OnEvent", UpdateElement)
	F.Health.HealPrediction.ForceUpdate = ForceUpdate
	
	table.insert(Module.Handles, F)
end

---------- Add Module
UF.Modules["HealPrediction"] = Module