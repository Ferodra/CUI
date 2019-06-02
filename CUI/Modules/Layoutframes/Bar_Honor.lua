local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF, TT, BH = E:LoadModules("Config", "Unitframes", "Tooltip", "Bar_Honor")

---------------------------------------------------------
local _
local format					= string.format
local IsWatchingHonorAsXP		= IsWatchingHonorAsXP
local UnitHonor					= UnitHonor
local UnitHonorMax				= UnitHonorMax
---------------------------------------------------------

local Texture = [[Interface\AddOns\CUI\Textures\statusbar\layoutBarBottom]]
local TextureFlipped = [[Interface\AddOns\CUI\Textures\statusbar\layoutBarBottomFlipped]]
local TextureReversed = [[Interface\AddOns\CUI\Textures\statusbar\layoutBarBottomReversed]]
local TextureReversedFlipped = [[Interface\AddOns\CUI\Textures\statusbar\layoutBarBottomReversedFlipped]]

BH.E = CreateFrame("Frame")
BH.UpdateData = {}

function BH:LoadProfile()	
	if not self.db.enable then self.Bar:Hide(); return else
	
		self.Bar.Overlay:SetAttribute("ReceivesGlobalTexture", false)
		self.Bar.Border:Hide()
		
		self.Bar.Overlay:SetReverseFill(false)
		self.Bar.Overlay:SetOrientation("HORIZONTAL")
			
		if self.db.style ~= "normal" then
			self.Bar.Background.Tex:SetVertexColor(unpack(self.db.backgroundColor))
			self.Bar:SetOverlayColor(1, 0.4, 0.4, 1)
		end
		if self.db.style == "integrated" then
			self.Bar.Overlay:SetStatusBarTexture(TextureReversed)
			self.Bar.Background.Tex:SetTexture(TextureReversed)
		elseif self.db.style == "integratedReversed" then
			self.Bar.Overlay:SetStatusBarTexture(Texture)
			self.Bar.Background.Tex:SetTexture(Texture)
		elseif self.db.style == "integratedReversedFlipped" then
			self.Bar.Overlay:SetStatusBarTexture(TextureFlipped)
			self.Bar.Background.Tex:SetTexture(TextureFlipped)
		elseif self.db.style == "integratedFlipped" then
			self.Bar.Overlay:SetStatusBarTexture(TextureReversedFlipped)
			self.Bar.Background.Tex:SetTexture(TextureReversedFlipped)
		else
			-- Normal bar
			self.Bar.Overlay:SetAttribute("ReceivesGlobalTexture", true)
			self.Bar.Overlay:SetStatusBarTexture(E.Media:Fetch("statusbar", CO.db.profile.unitframe.units["all"]['barTexture']))
			self.Bar.Background.Tex:SetTexture(nil)
			
			self.Bar:SetBackgroundColor(unpack(self.db.backgroundColor))
			self.Bar.Overlay:SetReverseFill(self.db.reverseFill)
			self.Bar.Overlay:SetOrientation(self.db.fillOrientation)
			
			self.Bar:SetBorderColor(unpack(self.db.borderColor))
			self.Bar:SetBorderSize(self.db.borderSize)
			self.Bar.Border:Show()
		end
		
		self.Bar:SetSize(self.db.width, self.db.height)
		
		self.Bar:SetOverlayColor(unpack(self.db.overlayColor))
		
		self.Bar:ClearAllPoints()
		self.Bar:SetPoint(self.db.position, E.Parent, self.db.position, self.db.offsetX, self.db.offsetY)
		
		self.Bar:Show()
	end
end

function BH:UpdateHonorData()
	self.UpdateData.CurrentHonor 	= UnitHonor("player")
	self.UpdateData.MaxHonor 		= UnitHonorMax("player")
end

function BH:UpdateValue()
	self.Bar:SetMinMaxValues(0, self.UpdateData.MaxHonor)
	self.Bar:SetValue(self.UpdateData.CurrentHonor)
	
	self.Bar.Font:SetText(string.format("%s / %s - %s %%", E:readableNumber(self.UpdateData.CurrentHonor, 2), E:readableNumber(self.UpdateData.MaxHonor, 2), E:Round(self.UpdateData.CurrentHonor / self.UpdateData.MaxHonor, 2) * 100))
end

function BH:Update()
	self:UpdateHonorData()
	self:UpdateValue()
end

function BH:__Construct()
	self.Bar = E:CreateBar("CUI_HonorBar", "MEDIUM", 256, 32, nil, nil, true, false, false)
	self.Bar:SetParent(E.Parent)
	
	self.Bar.Button = CreateFrame("Button", "CUI_HonorBarButton", self.Bar.Overlay)
	self.Bar.Button:SetAllPoints(self.Bar.Overlay)
	
	self.Bar.Button:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
		
		GameTooltip:AddLine(HONOR)
		GameTooltip:AddLine(format("%s / %s", BH.UpdateData.CurrentHonor, BH.UpdateData.MaxHonor))
		
		TT:UpdateStyle(nil)
		
		GameTooltip:Show()
	end)
	self.Bar.Button:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	
	-------------------------------------------------
		self.Bar.Font = self.Bar:CreateFontString(nil)
			E:InitializeFontFrame(self.Bar.Font, "OVERLAY", "FRIZQT__.TTF", 12, {0.933, 0.886, 0.125}, 0.9, {0,0}, "", 0, 0, self.Bar.Button, "CENTER", {1,1})
		self.Bar.Font:SetParent(self.Bar.Button)
			
		E:RegisterPathFont(self.Bar.Font, "db.profile.layout.barHonor.font") -- Enable just through local loader
	-------------------------------------------------
	
	self.E:RegisterEvent("PLAYER_ENTERING_WORLD")
	self.E:RegisterEvent("HONOR_XP_UPDATE")
	self.E:SetScript("OnEvent", function(self, event, ...)		
		BH:Update()
	end)
end

-- Those get called automatically by the module system
function BH:UpdateDB()
	self.db = E.db.layout.barHonor
end
function BH:Init()
	self:__Construct()
	
	self:LoadProfile()
end

E:AddModule("Bar_Honor", BH)