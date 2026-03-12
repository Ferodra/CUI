local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF = E:LoadModules('Config', 'Unitframes')

--[[--------------------
	Unitframe Extension	
--------------------]]--

local _
local tinsert		= table.insert
local Module = {}
Module.Frames = {}
Module.IncludeUnits = {'player', 'target', 'targettarget', 'focus', 'focustarget', 'party', 'raid', 'raid40'}
Module.Dependencies = {'Health', 'Power'}

-----------------------------------------

local ALTERNATE_POWER_INDEX = ALTERNATE_POWER_INDEX

local function UpdateElement(Element, Unit)
	if Element.Disabled or not UnitExists(Element.Owner.unit) then return end
	
	local BarType, Min, PowerName, PowerTooltip
	
	if UnitAlternatePowerInfo then
		BarType, Min, _, _, _, _, _, _, _, _, PowerName, PowerTooltip = UnitAlternatePowerInfo(Element.Owner.unit)
	else
		BarType = GetUnitPowerBarInfo(Element.Owner.unit)
		PowerName, PowerTooltip = GetUnitPowerBarStrings(Element.Owner.unit)
	end
	
	Element.PowerName 	 = PowerName
	Element.PowerTooltip = PowerTooltip
	Element.ValueCurrent = UnitPower(Element.Owner.unit, ALTERNATE_POWER_INDEX)
	Element.ValueMax 	 = UnitPowerMax(Element.Owner.unit, ALTERNATE_POWER_INDEX)
	
	if BarType then
		Element:SetMinMaxValues(0, Element.ValueMax)
		Element:SetValue(Element.ValueCurrent)
	end
end

local function UpdateState(Element)
	
	local BarType
	if UnitAlternatePowerInfo then
		BarType = UnitAlternatePowerInfo(Element.Owner.unit)
	else
		BarType = GetUnitPowerBarInfo(Element.Owner.unit)
	end
	
	if BarType then
		Element:Show()
		Element:RegisterEvent('UNIT_MAXPOWER')
		Element:RegisterEvent('UNIT_POWER_UPDATE')
		
		return true
	else
		Element:Hide()
		Element:UnregisterEvent('UNIT_MAXPOWER')
		Element:UnregisterEvent('UNIT_POWER_UPDATE')
	end
end

local function OnEvent(Element, event, unit)
	if (not UnitExists(unit) or not UnitIsUnit(Element.Owner.unit, unit)) or Element.Disabled then return end
	
	if event == 'UNIT_POWER_BAR_SHOW' or event == 'UNIT_POWER_BAR_HIDE' or event == 'ForceUpdate' then		
		if not UpdateState(Element) or event == 'UNIT_POWER_BAR_HIDE' then
			return
		end
	end	
	
	UpdateElement(Element, unit)
end

local function ForceUpdate(Element)
	OnEvent(Element, 'ForceUpdate', Element.Owner.unit)
end

local function OnEnter(self)
	if not self.PowerName or not self.PowerTooltip then return end
	
	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
	GameTooltip:AddDoubleLine(self.PowerName, ("%s / %s"):format(self.ValueCurrent, self.ValueMax), 1, 1, 1, 1, 1, 1)
	GameTooltip:AddLine(self.PowerTooltip, nil, nil, nil, 1)
	GameTooltip:Show()
end

local function OnLeave(self)
	GameTooltip:Hide()
end

local function UpdateAutoSettings(F)
	Module:LoadSizeConfig(F)
end

----------

function Module:LoadSizeConfig(F)
	local Config = self.db.units[F.ConfigKey].altPower
	local Element = F.AltPower
	
	if not Element then return end
	
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

function Module:LoadConfig()
	local Config, Element
	for _, F in pairs(Module.Frames) do
		
		Config = self.db.units[F.ConfigKey].altPower
		Element = F.AltPower
		
		Element:UnregisterEvent('UNIT_POWER_BAR_SHOW')
		Element:UnregisterEvent('UNIT_POWER_BAR_HIDE')
		
		if not Config.enable then
			Element.Disabled = true
			
			Element:Hide()			
		else	
			Element.Disabled = false
			UpdateState(Element)
			--------------------
			
			Element:SetOverlayColor(unpack(E:GetAltPowerColor(ALTERNATE_POWER_INDEX)))
			UpdateAutoSettings(F)
			Element:ClearAllPoints()
			Element:SetPoint(E:InversePosition(Config.position), F, Config.position, Config.offsetX, Config.offsetY)
			
			Element.Overlay:SetReverseFill(Config.barInverseFill)
			Element.Overlay:SetOrientation(Config.barOrientation)
			
			-- Power Border and Background
			Element:SetBackgroundColor(unpack(Config.barBackgroundColor))
			Element:SetBorderColor(unpack(Config.barBorderColor))
			Element:SetBorderSize(Config.barBorderSize)
			
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
			
			Element:RegisterEvent('UNIT_POWER_BAR_SHOW')
			Element:RegisterEvent('UNIT_POWER_BAR_HIDE')
		end
	end
end

function Module:Create(F)
	F.AltPower = E:CreateBar('CUI_UnitAltPowerBar', 'LOW', 5, 68, {'LEFT', F, 'RIGHT'}, F, 0, nil, nil, BackdropTemplateMixin and "BackdropTemplate")
	local Element = F.AltPower
	
	Element:SetParent(F.Overlay)
	Element.Owner = F
	
	Element:SetValue(50)
	Element:SetMinMaxValues(0, 100)
	
	Element:SetScript('OnEvent', OnEvent)
	
	Element:SetScript('OnEnter', OnEnter)
	Element:SetScript('OnLeave', OnLeave)
	
	E:SecureHook(F, "SetSize", UpdateAutoSettings)
	
	Element.ForceUpdate = ForceUpdate
	tinsert(Module.Frames, F)
end

---------- Add Module
UF:RegisterModule('AltPower', Module)
