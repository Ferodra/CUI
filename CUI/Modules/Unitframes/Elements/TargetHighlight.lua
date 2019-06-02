local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF = E:LoadModules("Config", "Unitframes")

--[[--------------------
	Unitframe Extension	
--------------------]]--

local _
local pairs 			= pairs
local unpack 			= unpack
local UnitIsUnit 		= UnitIsUnit
local UIFrameFadeIn 	= UIFrameFadeIn
local tinsert 			= table.insert
local Module = {}
Module.Handles = {}
Module.EventHandler = CreateFrame("Frame")

-----------------------------------------

local function UpdateElement(self, event)
	if self and self.Disabled then return end
	
	Module:HighlightUnit("target")
end

local function ForceUpdate(self)
	UpdateElement(self)
end

----------

function Module:HighlightUnit(Unit)
	for _, self in pairs(Module.Handles) do
		if UnitIsUnit(Unit, self.Unit) and self.Unit ~= "target" then
			UIFrameFadeIn(self.TargetHighlight, Module.FadeTime, self.TargetHighlight:GetAlpha(), 1)
		else
			UIFrameFadeOut(self.TargetHighlight, Module.FadeTime, self.TargetHighlight:GetAlpha(), 0)
		end
	end
end

local ProfileTarget
function Module:LoadProfile()
	ProfileTarget = CO.db.profile.unitframe.units.all
	
	if ProfileTarget.targetHighlight then
		if not ProfileTarget.targetHighlight.enable then
			Module.EventHandler:UnregisterAllEvents()
			Module.EventHandler:SetScript("OnUpdate", nil)
			
			for _, self in pairs(Module.Handles) do
				self.TargetHighlight:Hide()
			end
			
			Module.EventHandler.Disabled = true;
		else
			Module.EventHandler:RegisterEvent("PLAYER_TARGET_CHANGED")
			
			for _, self in pairs(Module.Handles) do
				self.TargetHighlight:SetBackdropBorderColor(unpack(ProfileTarget.targetHighlight.color))
				self.TargetHighlight.SetBorderSize(ProfileTarget.targetHighlight.borderSize)
			end
			Module.FadeTime = ProfileTarget.targetHighlight.fadeTime
			
			Module.EventHandler.Disabled = false;
			UpdateElement()
		end
	end
end

function Module:Create(F)
	F.TargetHighlight = E:CreateBorder(F.Overlay, nil, 1)
	F.TargetHighlight:Hide()
	
	F.TargetHighlight.ForceUpdate = ForceUpdate
	
	tinsert(self.Handles, F)
end

do
	Module.EventHandler:SetScript("OnEvent", UpdateElement)
end

---------- Add Module
UF.Modules["TargetHighlight"] = Module