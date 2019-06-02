local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF, TT, BE = E:LoadModules("Config", "Unitframes", "Tooltip", "Bar_Experience")

local _

local XPMax, XPCurrent, MaxLevel, PlayerLevel, BarX, BarY, BarPoint, BarParent, BarStrata, XPRestedString

local XPBAR_TEXTURE = [[Interface\AddOns\CUI\Textures\layout\modern\XPBar]]
local Texture = [[Interface\AddOns\CUI\Textures\statusbar\layoutBarBottom]]
local TextureFlipped = [[Interface\AddOns\CUI\Textures\statusbar\layoutBarBottomFlipped]]
local TextureReversed = [[Interface\AddOns\CUI\Textures\statusbar\layoutBarBottomReversed]]
local TextureReversedFlipped = [[Interface\AddOns\CUI\Textures\statusbar\layoutBarBottomReversedFlipped]]

--------------------------------------------------------
function BE:LoadProfile()
	self = BE -- Set for external calls
	
	self.db = CO.db.profile.layout.barExperience
	
	if self.db.enable then
		
		self.Bar.Overlay:SetReverseFill(false)
		self.Bar.Overlay:SetOrientation("HORIZONTAL")
		self.Bar.Rested:SetReverseFill(false)
		self.Bar.Rested:SetOrientation("HORIZONTAL")
		
		self.Bar.Border:Hide()
		
		self.Bar.Overlay:SetAttribute("ReceivesGlobalTexture", false)
		self.Bar.Rested:SetAttribute("ReceivesGlobalTexture", false)
		
		if self.db.style ~= "normal" then
			self.Bar:SetBackgroundColor(unpack(self.db.backgroundColor))
		end
		if self.db.style == "integrated" then
			self.Bar.Overlay:SetStatusBarTexture(TextureReversed)
			self.Bar.Rested:SetStatusBarTexture(TextureReversed)
			self.Bar.Background.Tex:SetTexture(TextureReversed)
		elseif self.db.style == "integratedReversed" then
			self.Bar.Overlay:SetStatusBarTexture(Texture)
			self.Bar.Rested:SetStatusBarTexture(Texture)
			self.Bar.Background.Tex:SetTexture(Texture)
		elseif self.db.style == "integratedReversedFlipped" then
			self.Bar.Overlay:SetStatusBarTexture(TextureFlipped)
			self.Bar.Rested:SetStatusBarTexture(TextureFlipped)
			self.Bar.Background.Tex:SetTexture(TextureFlipped)
		elseif self.db.style == "integratedFlipped" then
			self.Bar.Overlay:SetStatusBarTexture(TextureReversedFlipped)
			self.Bar.Rested:SetStatusBarTexture(TextureReversedFlipped)
			self.Bar.Background.Tex:SetTexture(TextureReversedFlipped)
		else
			
			self.Bar.Overlay:SetAttribute("ReceivesGlobalTexture", true)
			self.Bar.Rested:SetAttribute("ReceivesGlobalTexture", true)
			self.Bar.Overlay:SetStatusBarTexture(E.Media:Fetch("statusbar", CO.db.profile.unitframe.units["all"]['barTexture']))
			self.Bar.Rested:SetStatusBarTexture(E.Media:Fetch("statusbar", CO.db.profile.unitframe.units["all"]['barTexture']))
			self.Bar.Background.Tex:SetTexture(nil)
			
			self.Bar.Overlay:SetReverseFill(self.db.reverseFill)
			self.Bar.Overlay:SetOrientation(self.db.fillOrientation)
			self.Bar.Rested:SetReverseFill(self.db.reverseFill)
			self.Bar.Rested:SetOrientation(self.db.fillOrientation)
			
			self.Bar.Border:Show()
			
			self.Bar:SetBackgroundColor(unpack(self.db.backgroundColor))
			self.Bar:SetBorderColor(unpack(self.db.borderColor))
			self.Bar:SetBorderSize(self.db.borderSize)
		end
		
		self.Bar:ClearAllPoints()
		self.Bar:SetPoint(self.db.position, E.Parent, self.db.position, self.db.offsetX, self.db.offsetY)
		
		self.Bar:SetSize(self.db.width, self.db.height)
		self.Bar.Rested:SetSize(self.db.width, self.db.height)
		
		self.Bar.Overlay:GetStatusBarTexture():SetVertexColor(unpack(E:ParseDBColor(CO.db.profile.colors.layoutBars["barExperienceNormal"])))
		self.Bar.Rested:GetStatusBarTexture():SetVertexColor(unpack(E:ParseDBColor(CO.db.profile.colors.layoutBars["barExperienceRested"])))
		
		self:RegisterEvent("PLAYER_XP_UPDATE")
		self:RegisterEvent("UPDATE_EXHAUSTION")
		
		-- Instead of a straight "Show", first validate if it is supposed to!
		self:Update() -- Update if shown (again) to prevent dirty values
	else
		self.Bar:Hide()
	end
end
--------------------------------------------------------
	
function BE:SetValue(value)
	
	local XPRested = GetXPExhaustion()
	
	if XPRested then
		XPRestedString = string.format(" %s: %s", TUTORIAL_TITLE26, E:readableNumber(XPRested, 2))
		self.Bar.Rested:SetValue(value + XPRested)
		
		return
	else
		self.Bar.Rested:SetValue(0)
	end
	
	XPRestedString = ""
end

function BE:Update()
	local PlayerLevel = UnitLevel("player")
	
	if E.UNIT_MAXLEVEL ~= PlayerLevel then
		local XPMax = UnitXPMax("player")
		local XPCurrent = UnitXP("player")
		
		self.Bar:SetMinMaxValues(0, XPMax)
		self.Bar:SetValue(XPCurrent)
		--self.Bar.Overlay:SetAnimatedValues(XPCurrent, 0, XPMax, PlayerLevel)
		
		self.Bar.Rested:SetMinMaxValues(0, XPMax)
		self:SetValue(XPCurrent)
		self.Bar.Overlay.Font:SetText(string.format("%s / %s (%s%%) %s", E:readableNumber(XPCurrent, 2), E:readableNumber(XPMax, 2), E:Round((XPCurrent/XPMax)*100,2), XPRestedString))
		self.Bar:Show()
	else
		self.Bar:Hide()
	end
end

function BE:Create()
	BarStrata, BarX, BarY, BarPoint, BarParent = "MEDIUM", 750, 14, {"BOTTOM", E.Parent, "BOTTOM"}, E.Parent
	
	self.Bar = E:CreateBar("Bar_Experience", BarStrata, BarX, BarY, BarPoint, BarParent, nil, nil, nil)
	
	self.Bar.Rested = E:NewFrame("Statusbar", "Bar_Experience_Rested", "MEDIUM", BarX, BarY, BarPoint, self.Bar.Background)
	self.Bar.Rested:SetStatusBarTexture(XPBAR_TEXTURE)
	self.Bar.Rested:ClearAllPoints()
	self.Bar.Rested:SetAllPoints(self.Bar)
	
	E:RegisterStatusBar(self.Bar.Rested)
	
	self.Bar.Overlay:SetStatusBarTexture(XPBAR_TEXTURE)
	
	self.Bar.Overlay:SetAttribute("ReceivesGlobalTexture", false)
	self.Bar.Rested:SetAttribute("ReceivesGlobalTexture", false)
	
	
	E.Libs.LibSmooth:ResetBar(self.Bar.Overlay)
	E.Libs.LibSmooth:SmoothBar(self.Bar.Rested)
	
	self.Bar.Overlay.Font = self.Bar.Overlay:CreateFontString(nil, "ARTWORK")
	E:InitializeFontFrame(self.Bar.Overlay.Font, "ARTWORK", nil, 11, {0.8,0.8,0.8}, 1, {0,0}, "101010", 300, 20, self.Bar.Overlay, "CENTER", {1,1})
	
	E:RegisterPathFont(self.Bar.Overlay.Font, "db.profile.layout.barExperience.font")
	
	self.Button = CreateFrame("Frame", "CUI_XPBarButton", self.Bar.Overlay)
	self.Button:SetAllPoints(self.Bar.Overlay)
	self.Button:EnableMouse(true)
	self.Button:SetScript("OnEnter", function() ExhaustionTickMixin:ExhaustionToolTipText(); TT:UpdateStyle(nil) end)
	self.Button:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

function BE:Init()	
	self.db = CO.db.profile.layout.barExperience
	
	self:Create()
	self:Update()
	
	self:SetScript("OnEvent", self.Update)
	
	self:LoadProfile()
end

E:AddModule("Bar_Experience", BE)