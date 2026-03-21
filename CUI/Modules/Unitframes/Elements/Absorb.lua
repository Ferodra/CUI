local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF = E:LoadModules("Config", "Unitframes")

----------------------------------------------------------
	local UnitGetTotalAbsorbs 		= UnitGetTotalAbsorbs
	local UnitGetTotalHealAbsorbs 	= UnitGetTotalHealAbsorbs
----------------------------------------------------------

local AbsorbTypes = {"damage", "healing"}
local Module = {}

-----------------------------------------

Module.Frames = {}

--[[------------------------------------------------
	
	This is the CUI library to display absorb
	on a units healthbar.
	
	The profile loader is being handled
	in the Unitframes module.
	
	This is simply an extension.
	
------------------------------------------------]]--

function Module:LoadConfig(limit)
	local Config, HealthConfig, Element, ElementConfig
	local AllDisabled
	
	for _, F in pairs(self.Frames) do
		F = limit or F
		
		Config = CO.db.profile.unitframe.units[F.ConfigKey]
		HealthConfig = Config.health
		
		AllDisabled = true
		
		for _, Type in pairs(AbsorbTypes) do
			Element = F.Health.Absorb[Type]
			ElementConfig = HealthConfig.absorbs[Type]
			
			if ElementConfig.enable then
				AllDisabled = false
				
				-- As absorb is basically a statusbar, we can actually handle it like the healthbar					
				-- Update: We shouldn't do this, since it does prevent showing the remaining absorb when HP are below that value.
				-- 			Just lay it over the healthbar, but don't restrict it.
				--F.Health:SetSubBar(Element, true, not HealthConfig.barInverseFill, HealthConfig.barOrientation, not ElementConfig.onHealthbar)
				Element:SetFrameLevel(F.Overlay:GetFrameLevel())
				
				
				Element:SetReverseFill(HealthConfig.barInverseFill)
				Element:SetOrientation(HealthConfig.barOrientation)
				
				Element:SetAlpha(ElementConfig.alpha)
				
				-- Let user toggle between stripes or full cover
				if ElementConfig.useStripes then
					Element.Border.Background:SetTexture(E.Media:Fetch("statusbar", "CUI Absorb Stripes"), "REPEAT", "REPEAT")
				else
					Element.Border.Background:SetTexture("Interface/AddOns/CUI/Textures/borders/WHITE8X8")
				end
				Element.Border:SetBackdropBorderColor(ElementConfig.borderColor[1], ElementConfig.borderColor[2], ElementConfig.borderColor[3], ElementConfig.borderColor[4])
				Element.Border.Background:SetVertexColor(ElementConfig.textureColor[1], ElementConfig.textureColor[2], ElementConfig.textureColor[3], ElementConfig.textureColor[4])
				
				Element.TextureSizeMultiplier = ElementConfig.textureSizeMultiplier or 7
				
				Element.Disabled = false
			else
				Element.Disabled = true
				Element:Hide()
			end
		end
		
		if not AllDisabled then
			self:InitEvents(F.Health.Absorb)
			self:Update(F.Health.Absorb)
		else
			self:RemoveEvents(F.Health.Absorb)
		end
		
		if limit then break end
	end
end

function Module:InitEvents(AbsorbFrame)
	self:RemoveEvents(AbsorbFrame)
	
	if not E.IsRetail then
		AbsorbFrame:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", AbsorbFrame.Owner.unit)
	end
	AbsorbFrame:RegisterUnitEvent("UNIT_MAXHEALTH", AbsorbFrame.Owner.unit)
	AbsorbFrame:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", AbsorbFrame.Owner.unit)
	AbsorbFrame:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", AbsorbFrame.Owner.unit)
	
	AbsorbFrame:SetScript("OnEvent", self.BarFrame_OnEvent)
end
function Module:RemoveEvents(AbsorbFrame)
	AbsorbFrame:UnregisterAllEvents()
	AbsorbFrame:SetScript("OnEvent", nil)
end
-- /dump UnitGetTotalAbsorbs("player")
function Module:ForceUpdate()
	 Module.BarFrame_OnEvent(self, 'ForceUpdate')
end

function Module:BarFrame_OnEvent(event, ...)
	Module:Update(self)
end

local function UpdateTexCoord(Element, Value, Unit)
	--local Coord  = (Element.TextureSizeMultiplier or 7) * (Value / UnitHealthMax(Unit))
	local Coord  = (Element.TextureSizeMultiplier or 7) * 0.5
				
	-- Clamp to 0 and 50 to avoid "out of range"
	if Coord < 0 then Coord = 0; elseif Coord > 50 then Coord = 50; end 
	
	Element.Border.Background:SetTexCoord(0, Coord, 0, Coord)
end

function Module:Update(BarFrame)
	local Unit = BarFrame.Owner.unit
	local Value, Element
	
	for Index, Type in pairs(AbsorbTypes) do
		Element = BarFrame[Type]
		
		if not Element.Disabled then
			if Index == 1 then
				Value = UnitGetTotalAbsorbs(Unit) or 0				
			else
				Value = UnitGetTotalHealAbsorbs(Unit) or 0
			end
			
			-- Testing
			--Value = 9000000
			
			-- Filter cases with a value of 1, because Buffs like Blessing of the Kings cause the unit to always have 1 absorb somehow
			--if Value > 1 then
				Element:SetMinMaxValues(0, UnitHealthMax(Unit))
				Element:SetValue(Value)
				--print(UnitHealthMax(Unit), Value, Unit)
				
				Element:Show()
				Element:SetAlpha(Value)
				UpdateTexCoord(Element, Value, Unit)
			--else
			--	Element:Hide()
			--end
		end
	end
end

local function UpdateUnit(self)
	Module:InitEvents(self)
end

function Module:InitBar(Bar)
	local Owner = Bar.Owner.Owner
	
	Bar:Hide()
	Bar:ClearAllPoints()
	Bar:SetParent(Owner.Overlay)
	Bar:SetPoint("TOPLEFT", Owner.Health, "TOPLEFT")
	Bar:SetPoint("BOTTOMRIGHT", Owner.Health, "BOTTOMRIGHT")
	
	Bar:SetStatusBarTexture(E.Media:Fetch("statusbar", "CUI Absorb Stripes"))
	Bar:GetStatusBarTexture():SetVertexColor(0, 0, 0, 0) -- Make texture invisible, since we don't need it anyways
	Bar:SetAlpha(0.5)
	Bar:SetValue(0)
	
	-- We anchor this border element to the statusbar, so it automatically occupies the correct amount of space
	local Border = E:CreateBackdropFrame("Frame", nil, Bar)
	Bar.Border = Border
	
	-- Basically scale every corner X pixels inwards to make some space for the healthbar border
	--Border:SetPoint("TOPLEFT", Bar:GetStatusBarTexture(), "TOPLEFT", 1, -1)
	Border:SetPoint("TOPLEFT", Bar.Owner, "TOPLEFT", 1, -1)
	--Border:SetPoint("BOTTOMRIGHT", Bar:GetStatusBarTexture(), "BOTTOMRIGHT", -1, 1)
	Border:SetPoint("BOTTOMRIGHT", Bar.Owner, "BOTTOMRIGHT", -1, 1)
	
	-- The actual element that's gonna be shown instead of 
	Border:SetBackdrop({
        bgFile = [[Interface/AddOns/CUI/Textures/borders/WHITE8X8]], 
        edgeFile = [[Interface/AddOns/CUI/Textures/borders/WHITE8X8]], 
        edgeSize = 3,
    })
	Border.Background = Border:CreateTexture(nil, "OVERLAY")
	Border.Background:SetAllPoints(Bar.Border)
	
    Border.Background:SetTexCoord(0,3,0,3)
	Border:SetBackdropColor(0, 0, 0, 0.3)
	
	E.Libs.LibSmooth:SmoothBar(Bar)
end

function Module:Create(F)
	if true then return end
	local Bar = F.Health
	if not Bar then return end
	
	-- Handles Events for this Frame
	local Element = CreateFrame("Frame", "CUI_AbsorbFrame", Bar)
	Element:SetAllPoints(Bar)
	Element.Owner = F
	Element.ForceUpdate = self.ForceUpdate
	Element.UpdateUnit = UpdateUnit
	
	for _, Type in pairs(AbsorbTypes) do
		Element[Type] = E:CreateBackdropFrame("Statusbar", nil, Bar)
		Element[Type].Owner = Element
		self:InitBar(Element[Type])
	end
	
	-- For better compatibility
	F.HealthAbsorb = Element
	F.Health.Absorb = Element
	
	tinsert(self.Frames, F)
end

---------- Add Module
UF:RegisterModule('HealthAbsorb', Module)