local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF = E:LoadModules("Config", "Unitframes")

--[[--------------------
	Unitframe Extension	
--------------------]]--

local _
local MouseoverUnit = "mouseover"
local UpdateDelay = 0.1
local Module = {}
Module.Handles = {}
Module.EventHandler = CreateFrame("Frame")

-----------------------------------------

local function CheckMouseover(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	
	if self.elapsed > UpdateDelay then
		
		Module:HighlightUnit(MouseoverUnit)
		
		self.elapsed = 0
	end
end

local function UpdateElement(self, event)
	if self.Disabled then return end
	
	Module:HighlightUnit(MouseoverUnit)
end

local function ForceUpdate(self)
	UpdateElement(self)
end

----------

function Module:HighlightUnit(Unit)
	for _, self in pairs(Module.Handles) do
		if self:IsVisible() then
			if UnitIsUnit(Unit, self.Unit) then
				E:UIFrameFadeIn(self.Highlight.Tex, Module.FadeTime, self.Highlight.Tex:GetAlpha(), 1)
			else
				E:UIFrameFadeOut(self.Highlight.Tex, Module.FadeTime, self.Highlight.Tex:GetAlpha(), 0)
			end
		end
	end
end

local ProfileTarget
function Module:LoadProfile()
	ProfileTarget = CO.db.profile.unitframe.units.all
	
	if ProfileTarget.highlight then
		if not ProfileTarget.highlight.enable then
			Module.EventHandler:UnregisterAllEvents()
			Module.EventHandler:SetScript("OnUpdate", nil)
			
			for _, self in pairs(Module.Handles) do
				self.Highlight.Tex:Hide()
			end
			
			Module.EventHandler.Disabled = true;
		else
			Module.EventHandler:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
			Module.EventHandler:SetScript("OnUpdate", CheckMouseover)
			
			Module.FadeTime = ProfileTarget.highlight.fadeTime
			for _, self in pairs(Module.Handles) do
				self.Highlight.Tex:SetColorTexture(unpack(ProfileTarget.highlight.color)) -- Make this an option
				self.Highlight.Tex:SetBlendMode(ProfileTarget.highlight.blendMode)
			end
			
			Module.EventHandler.Disabled = false;
		end
	end
end

function Module:Create(F)
	F.Highlight = CreateFrame("Frame", nil, F)
	F.Highlight:SetAllPoints(true)
	F.Highlight.Tex = F.Highlight:CreateTexture(nil, "OVERLAY")
	F.Highlight.Tex:SetAllPoints(true)
	F.Highlight.Tex:Hide()
	
	F.Highlight.ForceUpdate = ForceUpdate
	
	table.insert(self.Handles, F)
end

do
	Module.EventHandler:SetScript("OnEvent", UpdateElement)
end

---------- Add Module
UF.Modules["Highlight"] = Module