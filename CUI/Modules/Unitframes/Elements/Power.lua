local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF = E:LoadModules("Config", "Unitframes")

--[[--------------------
	Unitframe Extension	
--------------------]]--

local _
local tinsert 				= table.insert
local UnitIsDeadOrGhost 	= UnitIsDeadOrGhost
local UnitPower 			= UnitPower
local UnitPowerMax 			= UnitPowerMax
local UnitPowerMissing 		= UnitPowerMissing
local Module = {}

-----------------------------------------

Module.Frames = {}

local function UpdateVisibility(Element, Value)
	
	--if Element.MaxValue and not (Element.MaxValue > 0) then
	--	Element:Hide()
	--	Element.Visible = false		
	--	
	--	return
	--end
	
	if not Element.HideWhenEmpty then
		if not Element.Visible then
			Element:Show()
			Element.Visible = true
		end
		
		return
	end
	
	if not issecretvalue(Value) then
		if Value > 0 then
			if not Element.Visible then
				Element:Show()
				Element.Visible = true
			end
		else
			if Element.Visible then
				Element:Hide()
				Element.Visible = false
			end
		end
	else
		Element:Show()
		Element.Visible = true
	end
end

local function UpdateElement(Element, Event, Unit)
	if Element.Disabled or Unit ~= Element.Owner.unit then return end
	
	if Event == "UNIT_DISPLAYPOWER" or Event == "ForceUpdate" then
		UF:UpdateBarColor(Element, E:GetUnitPowerColor(Unit))
	end
	
	if Event == "UNIT_MAXPOWER" or Event == "UNIT_DISPLAYPOWER" or Event == "UNIT_POWER_BAR_SHOW" or Event == "UNIT_POWER_BAR_HIDE"
	or Event == "ForceUpdate" then
		Element.MaxValue = UnitPowerMax(Unit)
		
		--if Element.MaxValue > 0 then
			Element:SetMinMaxValues(0, Element.MaxValue)
		--else
			--UpdateVisibility(Element)
		--end
	end
	
	if not UnitIsDeadOrGhost(Unit) then
		local Value = UnitPower(Unit)
		Element:SetValue(Value)
		--UpdateVisibility(Element, Value)
	else
		Element:SetValue(0)
		--UpdateVisibility(Element, 0)
		
		return
	end
end

local function ForceUpdate(Element)
	UpdateElement(Element, "ForceUpdate", Element.Owner.unit)
end

local function OnEvent(Element, event, unit)
	if(not unit or Element.Owner.unit ~= unit) then return end
	UpdateElement(Element, event, unit)
end

local function UpdateAutoSettings(F)
	Module:LoadSizeConfig(F)
end

local function UpdateUnit(Element)
	Element:UnregisterAllEvents()
	
	Element:RegisterUnitEvent("UNIT_POWER_UPDATE", Element.Owner.unit)
	
	if Element.fastUpdate then
		Element:RegisterUnitEvent("UNIT_POWER_FREQUENT", Element.Owner.unit)
	else
		Element:UnregisterEvent("UNIT_POWER_FREQUENT")
	end
		
	Element:RegisterUnitEvent("UNIT_MAXPOWER", Element.Owner.unit)
	Element:RegisterUnitEvent("UNIT_DISPLAYPOWER", Element.Owner.unit)
	Element:RegisterUnitEvent("UNIT_POWER_BAR_SHOW", Element.Owner.unit)
	Element:RegisterUnitEvent("UNIT_POWER_BAR_HIDE", Element.Owner.unit)
	
	Element:ForceUpdate()
end

----------

function Module:LoadSizeConfig(F)
	local Config = self.db.units[F.ConfigKey].power
	local Element = F.Power
	
	local Width, Height
	
	if not Element then return end
	
	if Config.autoWidth then
		Width = self.db.units[F.ConfigKey].health.width + Config.adjustAutoWidth
	else
		Width = Config.barWidth
	end
	if Config.autoHeight then
		Height = self.db.units[F.ConfigKey].health.height + Config.adjustAutoHeight
	else
		Height = Config.barHeight
	end
	
	Element:SetSize(Width, Height)
end

function Module:LoadConfig(limit)
	local Config, Element
	
	for _, F in pairs(Module.Frames) do
		F = limit or F
		
		Config = self.db.units[F.ConfigKey].power
		Element = F.Power
		
		if Config.enable then
			Element.Disabled = false
			
			UpdateAutoSettings(F)
			Element:SetReverseFill(Config.barInverseFill)
			Element:SetOrientation(Config.barOrientation)
			if Config.barSmooth then
				E.Libs.LibSmooth:SmoothBar(Element)
			else
				E.Libs.LibSmooth:ResetBar(Element)
			end

			Element:ClearAllPoints()
			Element:SetParent(F.Overlay)
			Element:SetPoint(E:InversePosition(Config.barPosition), F.Health, Config.barPosition, Config.barXOffset, Config.barYOffset)
			Element:SetFrameLevel(F.Overlay:GetFrameLevel() + 5)
			
			-- Texture
			if Config.overrideBarTexture then
				Element:SetAttribute("ReceivesGlobalTexture", false)
				Element:SetStatusBarTexture(E.Media:Fetch("statusbar", Config.barTexture or self.db.units.all.barTexture))
			else
				Element:SetAttribute("ReceivesGlobalTexture", true)
				Element:SetStatusBarTexture(E.Media:Fetch("statusbar", self.db.units.all.barTexture))
			end
			
			-- Power Border and Background
			Element.Background:SetColorTexture(unpack(Config.barBackgroundColor))
			E:SetFrameBorder(Element.Border, Config.barBorderSize, unpack(Config.barBorderColor))
			
			Element.HideWhenEmpty = Config.hideWhenEmpty
			Element:Show()
			
			--local Player_UnitFix = F.unit == 'party1' and 'player' or F.unit
			
			Element.fastUpdate = Config.fastUpdate
			
			if not F.Eventless then
				Element:UpdateUnit()
			end
			
			Element:SetScript("OnEvent", OnEvent)
			Element:ForceUpdate()
		else
			Element.Disabled = true
			
			Element:SetScript("OnEvent", nil)
			Element:Hide()
			Element.Visible = nil
		end
		
		if limit then break end
	end
end

function Module:Create(F)
	local Element 	= UF:CreateUFBar()	
	Element.Border 		= E:CreateBorder(Element)
	Element.Background 	= E:CreateBackground(Element)
	Element.Owner = F
	Element.ForceUpdate = ForceUpdate
	Element.UpdateUnit = UpdateUnit
	
	Element.Visible = false
	Element:Hide()
	
	hooksecurefunc(F, "SetSize", UpdateAutoSettings)
	
	F.Power = Element
	tinsert(Module.Frames, F)
end

---------- Add Module
UF:RegisterModule('Power', Module)