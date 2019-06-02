local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF = E:LoadModules("Config", "Unitframes")

--[[--------------------
	Unitframe Extension	
--------------------]]--

local _
local Module = {}

-----------------------------------------

Module.Frames = {}
local Events = {"UNIT_PORTRAIT_UPDATE"}

local function UpdateElement(Element, Unit)
	if Element.Disabled or not UnitExists(Element.Unit) or not UnitIsUnit(Unit, Element.Unit) then return end
	
	E:SetModelInfo(Element, "SetUnit", Element.Unit)
end

local function ForceUpdate(Element)
	UpdateElement(Element, Element.Unit)
end

local function OnEvent(Element, event, ...)
	UpdateElement(Element, ...)
end

----------

local ProfileTarget
function Module:LoadProfile()
	for _, self in pairs(Module.Frames) do
		
		ProfileTarget = CO.db.profile.unitframe.units[self.ProfileUnit]
		
		if not ProfileTarget.portrait.enable then
			self.Portrait:Hide()
			self.Portrait.Disabled = true
			
			E:SetModelInfo(self.Portrait, "ClearModel")
		else	
			self.Portrait:Show()
			self.Portrait.Disabled = false
			
			self.Portrait:SetAlpha(ProfileTarget.portrait.alpha)
			E:SetModelInfo(self.Portrait, "SetPortraitZoom", ProfileTarget.portrait.zoom)
			E:SetModelInfo(self.Portrait, "SetCamDistanceScale", ProfileTarget.portrait.camDistanceScale)
			E:SetModelInfo(self.Portrait, "SetRotation", ProfileTarget.portrait.rotation)
		end
	end
end

function Module:Create(F)
	F.Portrait = CreateFrame("PlayerModel", nil)
	F.Portrait:SetParent(F)
	F.Portrait:SetAllPoints(F)
	F.Portrait.Unit = F.Unit
	
	F.Portrait:RegisterUnitEvent(Events[1], F.Unit)
	F.Portrait:SetScript("OnEvent", OnEvent)
	
	F.Portrait.CutOffParent = CreateFrame("Frame", nil, F)
	F.Portrait.CutOffParent:SetFrameLevel(F.Health:GetFrameLevel() + 1) -- This way it always is above the Bar
	
	F.Portrait.ForceUpdate = ForceUpdate
	table.insert(Module.Frames, F)
end

---------- Add Module
UF.Modules["Portrait"] = Module