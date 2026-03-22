local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF = E:LoadModules('Config', 'Unitframes')

--[[--------------------
	Unitframe Extension	
--------------------]]--

local _
local UpdateInterval = 0.25
local ForceInterval = UpdateInterval + 1
local Module = {}
Module.IncludeUnits = {'target', 'targettarget', 'focus', 'focustarget'}
Module.Dependencies = {'Health'}

-----------------------------------------
local _
local select						= select
local tinsert						= table.insert
local UnitCanAttack					= UnitCanAttack
local UnitDetailedThreatSituation	= UnitDetailedThreatSituation
-----------------------------------------

Module.Frames = {}

local function UpdateElement(Element, elapsed)
	if Element.Disabled or not UnitExists(Element.Owner.unit) then return end
	
	Element.lastUpdate = (Element.lastUpdate or 0) + elapsed
	if Element.lastUpdate > UpdateInterval then
		
		local Value = select(3, UnitDetailedThreatSituation('player', Element.Owner.unit)) or 0
		
		Element:SetValue(Value)
		if not issecretvalue(Value) then
			Element:SetOverlayColor(E:ColorGradient((Value / 100), 0.11, 0.98, 0.38, 0.37, 0.76, 1, 0.91,0.27,0.36))
		else
			Element:SetOverlayColor(E:ColorGradient((1), 0.11, 0.98, 0.38, 0.37, 0.76, 1, 0.91,0.27,0.36))
		end
		
		Element.lastUpdate = 0
	end
end

local function OnEvent(Element, event, ...)
	if Element.Disabled or not UnitExists(Element.Owner.unit) or Element.Owner.unit ~= ... then return end
	
	if UnitCanAttack('player', Element.Owner.unit) then
		Element:Show()
	else
		Element:Hide()
	end
	
	if event and event ~= 'ForceUpdate' then
		UpdateElement(Element, ForceInterval)
	end
end

local function ForceUpdate(Element)
	OnEvent(Element, 'ForceUpdate', Element.Owner.unit)
	UpdateElement(Element, ForceInterval)
end

local function UpdateAutoSettings(F)
	Module:LoadSizeConfig(F)
end

----------

function Module:LoadSizeConfig(F)
	local Config = self.db.units[F.ConfigKey].threat
	
	if not F.Threat then return end
	
	local Element = F.Threat
	
	if Config.autoWidth then
		Width = self.db.units[F.ConfigKey].health.width
	else
		Width = Config.width
	end
	if Config.autoHeight then
		Height = self.db.units[F.ConfigKey].health.height
	else
		Height = Config.height
	end
	
	Element:SetSize(Width, Height)
end

function Module:LoadConfig(limit)
	local Config, Element
	
	for _, F in pairs(self.Frames) do
		F = limit or F
		
		Config = self.db.units[F.ConfigKey].threat
		
		Element = F.Threat
		Element:UnregisterAllEvents()
		
		if not Config.enable then
			Element.Disabled = true
			Element:Hide()
		else	
			Element.Disabled = false
			
			Element:RegisterEvent('UNIT_FACTION')
			
			self:LoadSizeConfig(F)
			Element:ClearAllPoints()
			Element:SetPoint(E:InversePosition(Config.position), F, Config.position, Config.xOffset, Config.yOffset)
			
			Element.Overlay:SetReverseFill(Config.barInverseFill)
			Element.Overlay:SetOrientation(Config.barOrientation)
			
			if Config.barSmooth then
				E.Libs.LibSmooth:SmoothBar(Element.Overlay)
			else
				E.Libs.LibSmooth:ResetBar(Element.Overlay)
			end
			
			-- Texture
			if Config.overrideBarTexture then
				Element.Overlay:SetAttribute("ReceivesGlobalTexture", false)
				Element.Overlay:SetStatusBarTexture(E.Media:Fetch("statusbar", Config.barTexture or self.db.units.all.barTexture))
			else
				Element.Overlay:SetAttribute("ReceivesGlobalTexture", true)
				Element.Overlay:SetStatusBarTexture(E.Media:Fetch("statusbar", self.db.units.all.barTexture))
			end
			
			-- Power Border and Background
			Element:SetBackgroundColor(unpack(Config.barBackgroundColor))
			Element:SetBorderColor(unpack(Config.barBorderColor))
			Element:SetBorderSize(Config.barBorderSize)
		end
		
		Element:ForceUpdate()
		
		if limit then break end
	end
end

function Module:Create(F)
	local Element = E:CreateBar('CUI_ThreatBar', 'LOW', 5, 68, {'LEFT', F, 'RIGHT'}, F, 0, 0, 0)
	Element:EnableMouse(false)
	
	Element:SetMinMaxValues(0, 100)
	Element:SetValue(0)
	
	Element.Owner = F
	
	hooksecurefunc(F, "SetSize", UpdateAutoSettings)
	
	Element:SetScript('OnUpdate', UpdateElement)
	Element:SetScript('OnEvent', OnEvent)
	
	Element.ForceUpdate = ForceUpdate
	
	F.Threat = Element
	tinsert(self.Frames, F)
end

---------- Add Module
UF:RegisterModule('Threat', Module)