local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF = E:LoadModules("Config", "Unitframes")

--[[--------------------
	Unitframe Extension	
--------------------]]--

local _
local UnitIsUnit = UnitIsUnit
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

local function Highlight_OnFadeFinished(self)
	self.IsFading = false
	print("FINISHED")
end

local function Highlight_OnModAlpha(self, state)
	if issecretvalue(state) then return end
	self.IsFading = true
	print(state)
	if state ~= self.LastState then
		print(state, self.LastState)
		if state then
			self:SetAlpha(0)
			E:UIFrameFadeIn(self, 0.5, self:GetAlpha(), 1, Highlight_OnFadeFinished, self)
			self.LastState = state
		else
			self:SetAlpha(1)
			E:UIFrameFadeOut(self, 0.5, self:GetAlpha(), 0, Highlight_OnFadeFinished, self)
			self.LastState = state
		end
	else
		print("None")
	end
	
end

----------

function Module:HighlightUnit(Unit)
	for _, self in pairs(Module.Handles) do
		if self:IsVisible() then
			if E.IsRetail then
				--if not self.Highlight.Tex.IsFading then
					self.Highlight.Tex:SetAlphaFromBoolean(UnitIsUnit(Unit, self.unit), 1, 0)
					self.Highlight.Tex:Show()
				--end
			else
				if UnitIsUnit(Unit, self.unit) then
					if self.Highlight.Tex:GetAlpha() < 1 then
						E:UIFrameFadeIn(self.Highlight.Tex, Module.FadeTime, self.Highlight.Tex:GetAlpha(), 1)
						UIFrameFadeIn(self.Highlight.Tex, Module.FadeTime, self.Highlight.Tex:GetAlpha(), 1)
					end
					self.Highlight.Tex:SetAlpha(1)
				else
					if self.Highlight.Tex:GetAlpha() > 0 then
						E:UIFrameFadeOut(self.Highlight.Tex, Module.FadeTime, self.Highlight.Tex:GetAlpha(), 0)
						UIFrameFadeOut(self.Highlight.Tex, Module.FadeTime, self.Highlight.Tex:GetAlpha(), 0)
					end
					self.Highlight.Tex:SetAlpha(0)
				end
			end
		end
	end
end

local ProfileTarget
function Module:LoadConfig(limit)
	ProfileTarget = CO.db.profile.unitframe.units.all
	
	if ProfileTarget.highlight then
		if not ProfileTarget.highlight.enable then
			Module.EventHandler:UnregisterAllEvents()
			Module.EventHandler:SetScript("OnUpdate", nil)
			
			for _, self in pairs(Module.Handles) do
				self = limit or self
				
				self.Highlight.Tex:Hide()
				
				if limit then break end
			end
			
			Module.EventHandler.Disabled = true;
		else
			Module.EventHandler:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
			Module.EventHandler:SetScript("OnUpdate", CheckMouseover)
			
			Module.FadeTime = ProfileTarget.highlight.fadeTime
			for _, self in pairs(Module.Handles) do
				self = limit or self
				
				self.Highlight.Tex:SetColorTexture(unpack(ProfileTarget.highlight.color)) -- Make this an option
				self.Highlight.Tex:SetBlendMode(ProfileTarget.highlight.blendMode)
				if limit then break end
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
	--hooksecurefunc(F.Highlight.Tex, "SetAlphaFromBoolean", Highlight_OnModAlpha)
	
	F.Highlight.ForceUpdate = ForceUpdate
	
	table.insert(self.Handles, F)
end

do
	Module.EventHandler:SetScript("OnEvent", UpdateElement)
end

---------- Add Module
UF.Modules["Highlight"] = Module