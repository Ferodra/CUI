local E, L = unpack(select(2, ...)) -- Engine, Locale
local L, CO, UF = E:LoadModules("Locale", "Config", "Unitframes")

----------------------------------------------------------
	local UnitGetTotalAbsorbs 		= UnitGetTotalAbsorbs
----------------------------------------------------------

--[[------------------------------------------------
	
	This is the CUI library to display absorb
	on a units healthbar.
	
	The profile loader is being handled
	in the Unitframes module.
	
	This is simply an extension.
	
------------------------------------------------]]--

function UF:InitAbsorbEvents(Absorb)
	self:RemoveAbsorbEvents(Absorb)
	
	Absorb:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", Absorb:GetParent().Unit)
	Absorb:RegisterUnitEvent("UNIT_MAXHEALTH", Absorb:GetParent().Unit)
	Absorb:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", Absorb:GetParent().Unit)
	Absorb:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", Absorb:GetParent().Unit)
	
	Absorb.Update = self.__UpdateAbsorb
	Absorb:SetScript("OnEvent", self.BarAbsorb_OnEvent)
end
function UF:RemoveAbsorbEvents(Absorb)
	Absorb:UnregisterAllEvents()
	
	Absorb.Update = function() end
	Absorb:SetScript("OnEvent", nil)
end
-- /dump UnitGetTotalAbsorbs("player")
function UF:__UpdateAbsorb()
	UF:SetAbsorbValue(self, UnitGetTotalAbsorbs(self:GetParent().Unit), self:GetParent().Unit)
end

function UF:BarAbsorb_OnEvent(event, ...)
	self:Update()
end

function UF:SetAbsorbValue(Absorb, Value, Unit)
	
	-- Just less than 1, because Buffs like Blessing of the Kings cause the unit to always have 1 absorb somehow
	if Value <= 1 then
		Absorb:Hide()
	else
		Absorb:SetMinMaxValues(0, UnitHealth(Unit))
		Absorb:SetValue(Value)
		
		Absorb:Show()
		Absorb.Coord = (Absorb.TextureSizeMultiplier or 7) * (Value / UnitHealthMax(Unit))
		
		-- Clamp to 0 and 50 to avoid "out of range"
		if Absorb.Coord < 0 then Absorb.Coord = 0; elseif Absorb.Coord > 50 then Absorb.Coord = 50; end 
		
		Absorb.Border.Background:SetTexCoord(0, Absorb.Coord, 0, Absorb.Coord)
	end
	
	
end

function UF:StyleAbsorb(Absorb)
	Absorb:Hide()
	
	Absorb:SetStatusBarTexture(E.Media:Fetch("statusbar", "CUI Absorb Stripes"))
	Absorb:GetStatusBarTexture():SetVertexColor(0, 0, 0, 0) -- Make texture invisible, since we don't need it anyways
	Absorb:SetValue(0)
	
	Absorb:SetAlpha(0.5)
	
	Absorb.Border = CreateFrame("Frame", nil, Absorb)
	
	-- Basically scale every corner X pixels inwards to make some space for the healthbar border
	Absorb.Border:SetPoint("TOPLEFT", Absorb:GetStatusBarTexture(), "TOPLEFT", 1, -1)
	Absorb.Border:SetPoint("BOTTOMRIGHT", Absorb:GetStatusBarTexture(), "BOTTOMRIGHT", -1, 1)
	
	Absorb.Border:SetBackdrop({
        bgFile = [[Interface\Buttons\WHITE8X8]], 
        edgeFile = [[Interface\Buttons\WHITE8X8]], 
        edgeSize = 3,
    })
	Absorb.Border.Background = Absorb.Border:CreateTexture(nil, "OVERLAY")
	Absorb.Border.Background:SetAllPoints(Absorb.Border)
	-- Absorb.Border.Background:SetVertexColor(0, 0.5, 0.5, 1)
    Absorb.Border.Background:SetTexCoord(0,3,0,3)
	
	Absorb.Border:SetBackdropColor(0, 0, 0, 0.3)
	
	
	Absorb:SetFrameLevel(Absorb:GetParent():GetFrameLevel() + 2)
	
	Absorb:SetReverseFill(true)
	E.Libs.LibSmooth:SmoothBar(Absorb)
end

function UF:AddHealthAbsorb(Bar)
	Bar.Absorb = CreateFrame("Statusbar", nil, Bar)
	
	self:StyleAbsorb(Bar.Absorb)
	
	self:InitAbsorbEvents(Bar.Absorb)
end