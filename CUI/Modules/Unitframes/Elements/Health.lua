local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF = E:LoadModules("Config", "Unitframes")

--[[--------------------
	Unitframe Extension	
--------------------]]--

local _
local UnitPlayerControlled 	= UnitPlayerControlled
local UnitIsTapDenied 		= UnitIsTapDenied
local UnitHealth 			= UnitHealth
local UnitHealthMax 		= UnitHealthMax
local UnitIsDeadOrGhost 	= UnitIsDeadOrGhost
local Module = {}

-----------------------------------------

Module.Frames = {}

local function PostUpdate(Element, Event, Unit)
	if Element.Disabled then return end
	
	if not UnitPlayerControlled(Unit) and UnitIsTapDenied(Unit) then
		Element:SetStatusBarColor(0.5, 0.5, 0.5)
	else
		
		local Color = E:GetUnitReactionColor(Unit)
		
		if Element.ColorByValue then
			-- Element:GetValue somehow returns the default value at first
			Element:SetStatusBarColor(E:ColorGradient((Element.Value / Element.MaxValue), 1, 0, 0, 1, 1, 0, Color.r or Color.RGBA[1], Color.g or Color.RGBA[2], Color.b or Color.RGBA[3]))
		else
			Element:SetStatusBarColor(Color.r or Color.RGBA[1], Color.g or Color.RGBA[2], Color.b or Color.RGBA[3])
		end
	end
end

local function UpdateElement(Element, Event, Unit)
	if Element.Disabled then return end
	
	local Health = UnitHealth(Unit)
	
	if Event == "UNIT_MAXHEALTH" or Event == "ForceUpdate" or not Element.MaxValue then
		Element.MaxValue = UnitHealthMax(Unit)
		Element:SetMinMaxValues(0, Element.MaxValue)
	end

	if not UnitIsDeadOrGhost(Unit) then
		Element.Value = Health
	else
		Element.Value = 0
	end
	Element:SetValue(Element.Value)
	
	PostUpdate(Element, Event, Unit)
end

local function ForceUpdate(Element)
	UpdateElement(Element, "ForceUpdate", Element.Unit)
end

local function ForcePostUpdate(Element)
	PostUpdate(Element, "ForceUpdate", Element.Unit)
end

local function OnEvent(self, event, unit)
	if(not unit or self.Unit ~= unit) then return end
	
	UpdateElement(self, event, unit)
end

----------

function Module:LoadProfile()
	local ProfileTarget, Element
	local Profile_ALL = CO.db.profile.unitframe.units.all
	
	UF = E:GetModule("Unitframes")
	
	for _, self in pairs(Module.Frames) do
			
		ProfileTarget = CO.db.profile.unitframe.units[self.ProfileUnit]
		Element = self.Health
		
		self:SetSize(ProfileTarget.health.width, ProfileTarget.health.height)
		Element:SetReverseFill(ProfileTarget.health.barInverseFill)
		Element:SetOrientation(ProfileTarget.health.barOrientation)
		if ProfileTarget.health.barSmooth then
			E.Libs.LibSmooth:SmoothBar(Element)
		else
			E.Libs.LibSmooth:ResetBar(Element)
		end
		
		Element.Background:SetColorTexture(ProfileTarget.health.barBackgroundColor[1], ProfileTarget.health.barBackgroundColor[2], ProfileTarget.health.barBackgroundColor[3], ProfileTarget.health.barBackgroundColor[4])
		E:SetFrameBorder(Element.Border, ProfileTarget.health.barBorderSize, ProfileTarget.health.barBorderColor[1], ProfileTarget.health.barBorderColor[2], ProfileTarget.health.barBorderColor[3], ProfileTarget.health.barBorderColor[4])
		
		-- Texture
		if ProfileTarget.health.overrideBarTexture then
			Element:SetAttribute("ReceivesGlobalTexture", false)
			Element:SetStatusBarTexture(E.Media:Fetch("statusbar", ProfileTarget.health.barTexture or Profile_ALL.barTexture))
		else
			Element:SetAttribute("ReceivesGlobalTexture", true)
			Element:SetStatusBarTexture(E.Media:Fetch("statusbar", Profile_ALL.barTexture))
		end
		
		-- Portrait Cutoff
		if self.Portrait then
			Element.Background:ClearAllPoints()
			
			if ProfileTarget.portrait.cutOff and self.Portrait and not self.Portrait.Disabled then
				if not ProfileTarget.health.barInverseFill then
					Element.Background:SetPoint("BOTTOMLEFT", Element:GetStatusBarTexture(), ProfileTarget.health.barOrientation == "HORIZONTAL" and "BOTTOMRIGHT" or "TOPLEFT")
					Element.Background:SetPoint("TOPRIGHT", Element)
				else
					Element.Background:SetPoint("TOPRIGHT", Element:GetStatusBarTexture(), ProfileTarget.health.barOrientation == "HORIZONTAL" and "TOPLEFT" or "BOTTOMRIGHT")
					Element.Background:SetPoint("BOTTOMLEFT", Element)
				end
				
				Element.Background:SetParent(self.Portrait.CutOffParent)
			else
				Element.Background:SetAllPoints(Element)
				Element.Background:SetParent(Element)
			end
		end
		
		-- Color by Value
		Element.ColorByValue = Profile_ALL.health.colorByValue
		
		if not self.Eventless then
			
			Element:UnregisterAllEvents()
			
			if ProfileTarget.health.fastUpdate or (self.Unit == "player" or self.Unit == "target") then
				Element:RegisterEvent("UNIT_HEALTH_FREQUENT")
			else
				Element:RegisterEvent("UNIT_HEALTH")
			end
			
			Element:RegisterEvent("UNIT_MAXHEALTH")
		end
		
		Element.Disabled = false
	end
end

function Module:Create(F)
	F.Health = UF:CreateUFBar(F)
	local Element = F.Health
	
	Element.Border 		= E:CreateBorder(Element); Element.Border:SetFrameLevel(Element:GetFrameLevel() + 5)
	Element.Background 	= E:CreateBackground(Element)
	
	Element:SetScript("OnEvent", OnEvent)
	Element.Unit = F.Unit
	Element.ForceUpdate = ForceUpdate
	Element.PostUpdate = ForcePostUpdate
	
	table.insert(Module.Frames, F)
end

---------- Add Module
UF.Modules["BarHealth"] = Module