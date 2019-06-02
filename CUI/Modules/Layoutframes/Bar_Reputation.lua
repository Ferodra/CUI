local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF, TT, BR = E:LoadModules("Config", "Unitframes", "Tooltip", "Bar_Reputation")

local _
local format		= string.format

local Texture = [[Interface\AddOns\CUI\Textures\statusbar\layoutBarBottom]]
local TextureFlipped = [[Interface\AddOns\CUI\Textures\statusbar\layoutBarBottomFlipped]]
local TextureReversed = [[Interface\AddOns\CUI\Textures\statusbar\layoutBarBottomReversed]]
local TextureReversedFlipped = [[Interface\AddOns\CUI\Textures\statusbar\layoutBarBottomReversedFlipped]]

BR.UpdateData = {}

function BR:LoadProfile()
	self = BR
	if not self.db.enable then self.Bar:Hide(); self:UnregisterEvent("PLAYER_ENTERING_WORLD"); self:UnregisterEvent("UPDATE_FACTION") return else
	
		self.Bar.Overlay:SetAttribute("ReceivesGlobalTexture", false)
		self.Bar.Border:Hide()
		
		self.Bar.Overlay:SetReverseFill(false)
		self.Bar.Overlay:SetOrientation("HORIZONTAL")
		
		if self.db.style ~= "normal" then
			self.Bar.Background.Tex:SetVertexColor(unpack(self.db.backgroundColor))
		end
		if self.db.style == "integrated" then
			self.Bar.Overlay:SetStatusBarTexture(TextureReversed)
			self.Bar.Background.Tex:SetTexture(TextureReversed)
		elseif self.db.style == "integratedReversed" then
			self.Bar.Overlay:SetStatusBarTexture(Texture)
			self.Bar.Background.Tex:SetTexture(Texture)
		elseif self.db.style == "integratedReversedFlipped" then
			self.Bar.Overlay:SetStatusBarTexture(TextureReversed)
			self.Bar.Background.Tex:SetTexture(TextureReversed)
		elseif self.db.style == "integratedFlipped" then
			self.Bar.Overlay:SetStatusBarTexture(TextureReversedFlipped)
			self.Bar.Background.Tex:SetTexture(TextureReversedFlipped)
		else
			-- Normal bar
			self.Bar.Overlay:SetAttribute("ReceivesGlobalTexture", true)
			self.Bar.Overlay:SetStatusBarTexture(E.Media:Fetch("statusbar", CO.db.profile.unitframe.units["all"]['barTexture']))
			self.Bar.Background.Tex:SetTexture(nil)
			
			self.Bar.Overlay:SetReverseFill(self.db.reverseFill)
			self.Bar.Overlay:SetOrientation(self.db.fillOrientation)
			
			self.Bar:SetBackgroundColor(unpack(self.db.backgroundColor))
			self.Bar:SetBorderColor(unpack(self.db.borderColor))
			self.Bar:SetBorderSize(self.db.borderSize)
			self.Bar.Border:Show()
		end
		
		self.Bar:SetSize(self.db.width, self.db.height)
		
		self.Bar:ClearAllPoints()
		self.Bar:SetPoint(self.db.position, E.Parent, self.db.position, self.db.offsetX, self.db.offsetY)
		
		self:RegisterEvent("PLAYER_ENTERING_WORLD")
		self:RegisterEvent("UPDATE_FACTION")
		self.Bar:Show()
	end
end

function BR:UpdateFactionData()

	self.UpdateData.Name, _, self.UpdateData.MinValue, self.UpdateData.MaxValue, self.UpdateData.CurrentValue, _ = GetWatchedFactionInfo()

	if self.UpdateData.Name then
		if self.UpdateData.CurrentValue >= 0 then
			self.UpdateData.CurrentValue = self.UpdateData.CurrentValue - self.UpdateData.MinValue
			self.UpdateData.MaxValue = self.UpdateData.MaxValue - self.UpdateData.MinValue
			self.UpdateData.MinValue = 0
			
			self.UpdateData.IsHostile = false
		else
			self.UpdateData.CurrentValue = self.UpdateData.CurrentValue * (-1)
			self.UpdateData.MaxValue = self.UpdateData.MaxValue * (-1)
			self.UpdateData.MinValue = self.UpdateData.MinValue * (-1)
			
			self.UpdateData.CurrentValue = (self.UpdateData.MinValue - (self.UpdateData.CurrentValue - self.UpdateData.MaxValue)) - self.UpdateData.MaxValue
			self.UpdateData.MaxValue = self.UpdateData.MinValue - self.UpdateData.MaxValue
			self.UpdateData.MinValue = 0
			
			self.UpdateData.IsHostile = true
		end
		
		if self.UpdateData.CurrentValue == 0 and self.UpdateData.MaxValue == 0 then
			self.UpdateData.CurrentValue = 21000
			self.UpdateData.MaxValue = 21000
		end
	end
end

function BR:UpdateValue()
	if self.UpdateData.Name then
		
		self.Bar:SetMinMaxValues(self.UpdateData.MinValue, self.UpdateData.MaxValue)
		self.Bar:SetValue(self.UpdateData.CurrentValue)
		
		self.Bar.Font:SetText(string.format("%s / %s - %s %%", E:readableNumber(self.UpdateData.CurrentValue, 2), E:readableNumber(self.UpdateData.MaxValue, 2), (E:Round(self.UpdateData.CurrentValue / self.UpdateData.MaxValue, 2) * 100)))
		
		self.Bar:Show()
	else
		self.Bar:Hide()
	end
end

function BR:UpdateColor()
	if self.UpdateData.IsHostile then
		self.Bar:SetOverlayColor(0.7, 0.15, 0.15, 1)
		--self.Bar.Border.UpdateBorderColor(0.6, 0.1, 0.1, 0.5)
	else
		self.Bar:SetOverlayColor(0.7, 0.7, 0.7, 1)
		--self.Bar.Border.UpdateBorderColor(0.1, 0.1, 0.1, 0.9)
	end
end

function BR:__Construct()
	self.Bar = E:CreateBar("CUI_ReputationBar", "MEDIUM", 256, 32, nil, nil, true, false, false)
	self.Bar:SetParent(E.Parent)

	self.Bar.Button = CreateFrame("Button", "CUI_ReputationBarButton", self.Bar.Overlay)
	self.Bar.Button:SetAllPoints(self.Bar.Overlay)
	
	self.Bar.Button:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
		
		GameTooltip:AddLine(BR.UpdateData.Name)
		GameTooltip:AddLine(format("%s / %s", BR.UpdateData.CurrentValue, BR.UpdateData.MaxValue))
		
		TT:UpdateStyle(nil)
		
		GameTooltip:Show()
	end)
	self.Bar.Button:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	
	-------------------------------------------------
		self.Bar.Font = self.Bar:CreateFontString(nil)
			E:InitializeFontFrame(self.Bar.Font, "OVERLAY", "FRIZQT__.TTF", 12, {0.933, 0.886, 0.125}, 0.9, {0,0}, "", 0, 0, self.Bar.Overlay, "CENTER", {1,1})
		self.Bar.Font:SetParent(self.Bar.Button)
			
		E:RegisterPathFont(self.Bar.Font, "db.profile.layout.barReputation.font") -- Enable just through local loader
		--E:RegisterPathFont(self.Bar.Font, "db.profile.layout.barReputation.font", {["enable"] = function() BR:LoadProfile() end}) -- Enable just through local loader
	-------------------------------------------------
	
	self:SetScript("OnEvent", function(self, event, ...)
		self:UpdateFactionData()
		self:UpdateColor()
		self:UpdateValue()
	end)
end

function BR:UpdateDB()
	self.db = E.db.layout.barReputation
end
function BR:Init()
	self:__Construct()
	
	self:LoadProfile()
end

E:AddModule("Bar_Reputation", BR)