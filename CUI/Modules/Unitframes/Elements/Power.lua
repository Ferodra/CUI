local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF = E:LoadModules("Config", "Unitframes")

--[[--------------------
	Unitframe Extension	
--------------------]]--

local _
local tinsert 			= table.insert
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitPower 		= UnitPower
local UnitPowerMax 		= UnitPowerMax
local Module = {}

-----------------------------------------

Module.Frames = {}

local function UpdateElement(Element, Event, Unit)
	if Element.Disabled then return end
	if not Unit then Unit = Element.Unit end -- Required for ForceUpdate
	
	if Event == "UNIT_DISPLAYPOWER" or Event == "ForceUpdate" then
		UF:UpdateBarColor(Element, E:GetUnitPowerColor(Unit))
	end
	
	if Event == "UNIT_MAXPOWER" or Event == "UNIT_DISPLAYPOWER" or Event == "ForceUpdate" then
		Element.MaxValue = UnitPowerMax(Unit)
		
		if Element.MaxValue == 0 then
			if Element:IsVisible() then
				Element:Hide()
			end
			
			return
		else
			if not Element:IsVisible() then
				Element:Show()
			end
			
			Element:SetMinMaxValues(0, Element.MaxValue)
		end
	end
	
	if not UnitIsDeadOrGhost(Unit) then
		Element:SetValue(UnitPower(Unit))
	else
		Element:SetValue(0)
	end
end

local function ForceUpdate(Element)
	UpdateElement(Element, "ForceUpdate", Element.Unit)
end

local function OnEvent(Element, event, unit)
	if(not unit or Element.Unit ~= unit) then return end
	UpdateElement(Element, event, unit)
end

----------

function Module:LoadProfile()
	local Config, Element
	
	for _, self in pairs(Module.Frames) do
		Config = CO.db.profile.unitframe.units[self.ProfileUnit]
		Element = self.Power
		
		Element:SetSize(Config.power.barWidth, Config.power.barHeight)
		Element:SetReverseFill(Config.power.barInverseFill)
		Element:SetOrientation(Config.power.barOrientation)
		if Config.power.barSmooth then
			E.Libs.LibSmooth:SmoothBar(Element)
		else
			E.Libs.LibSmooth:ResetBar(Element)
		end

		Element:ClearAllPoints()
		Element:SetParent(self.Overlay)
		Element:SetPoint(Config.power.barPosition, self.Health, Config.power.barPosition, Config.power.barXOffset, Config.power.barYOffset)
		
		-- Texture
		if Config.power.overrideBarTexture then
			Element:SetAttribute("ReceivesGlobalTexture", false)
			Element:SetStatusBarTexture(E.Media:Fetch("statusbar", Config.power.barTexture or CO.db.profile.unitframe.units.all.barTexture))
		else
			Element:SetAttribute("ReceivesGlobalTexture", true)
			Element:SetStatusBarTexture(E.Media:Fetch("statusbar", CO.db.profile.unitframe.units.all.barTexture))
		end
		
		-- Power Border and Background
		Element.Background:SetColorTexture(unpack(Config.power.barBackgroundColor))
		E:SetFrameBorder(Element.Border, Config.power.barBorderSize, unpack(Config.power.barBorderColor))
		
		if not self.Eventless then
			if Config.power.fastUpdate then
				Element:UnregisterEvent("UNIT_POWER_UPDATE")
				Element:RegisterEvent("UNIT_POWER_FREQUENT")
			else
				Element:UnregisterEvent("UNIT_POWER_FREQUENT")
				Element:RegisterEvent("UNIT_POWER_UPDATE")
			end
			
			if not Element:IsEventRegistered("UNIT_MAXPOWER") then
				Element:RegisterEvent("UNIT_MAXPOWER")
				Element:RegisterEvent("UNIT_DISPLAYPOWER")
			end
		end
		
		Element.Disabled = false
	end
end

function Module:Create(F)
	F.Power 		= UF:CreateUFBar()
	local Element 	= F.Power
	
	Element.Border 		= E:CreateBorder(Element)
	Element.Background 	= E:CreateBackground(Element)
	
	Element.Unit = F.Unit
	Element:SetScript("OnEvent", OnEvent)
	Element.ForceUpdate = ForceUpdate
	
	tinsert(Module.Frames, F)
end

---------- Add Module
UF.Modules["BarPower"] = Module