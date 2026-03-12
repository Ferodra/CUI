local E, L = unpack(select(2, ...)) -- Engine, Locale
local UF, CO = E:LoadModules("Unitframes", "Config")
local Module = CreateFrame("Frame", "CUI_AzeriteBarHolder", E.Parent)
Module.Autoload = true

local _
local C_AzeriteItem_IsAzeriteItemEnabled 	= C_AzeriteItem.IsAzeriteItemEnabled
local C_AzeriteItem_FindActiveAzeriteItem 	= C_AzeriteItem.FindActiveAzeriteItem
local C_AzeriteItem_GetAzeriteItemXPInfo 	= C_AzeriteItem.GetAzeriteItemXPInfo
local C_AzeriteItem_GetPowerLevel 			= C_AzeriteItem.GetPowerLevel
local Texture = [[Interface\AddOns\CUI\Textures\statusbar\layoutBarBottom]]
local TextureFlipped = [[Interface\AddOns\CUI\Textures\statusbar\layoutBarBottomFlipped]]
local TextureReversed = [[Interface\AddOns\CUI\Textures\statusbar\layoutBarBottomReversed]]
local TextureReversedFlipped = [[Interface\AddOns\CUI\Textures\statusbar\layoutBarBottomReversedFlipped]]

function Module:LoadConfig()
	--self = Module -- Set for external calls
	
	if self.db.enable then
		
		self.Bar.Overlay:SetReverseFill(false)
		self.Bar.Overlay:SetOrientation("HORIZONTAL")
		
		self.Bar.Border:Hide()
		
		self.Bar:SetAttribute("ReceivesGlobalTexture", false)
		
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
			self.Bar.Overlay:SetStatusBarTexture(TextureFlipped)
			self.Bar.Background.Tex:SetTexture(TextureFlipped)
		elseif self.db.style == "integratedFlipped" then
			self.Bar.Overlay:SetStatusBarTexture(TextureReversedFlipped)
			self.Bar.Background.Tex:SetTexture(TextureReversedFlipped)
		else
			
			self.Bar:SetAttribute("ReceivesGlobalTexture", true)
			self.Bar.Overlay:SetStatusBarTexture(E.Media:Fetch("statusbar", CO.db.profile.unitframe.units["all"]['barTexture']))
			self.Bar.Background.Tex:SetTexture(nil)
			
			self.Bar.Overlay:SetReverseFill(self.db.reverseFill)
			self.Bar.Overlay:SetOrientation(self.db.fillOrientation)
			
			self.Bar.Border:Show()
			
			self.Bar:SetBorderSize(self.db.borderSize)
			self.Bar:SetBackgroundColor(unpack(self.db.backgroundColor))
			self.Bar:SetBorderColor(unpack(self.db.borderColor))
		end	
		
		self:ClearAllPoints()
		self:SetPoint(self.db.position, E.Parent, self.db.position, self.db.offsetX, self.db.offsetY)
		
		self:SetSize(self.db.width, self.db.height)
		
		local OverlayColor = E:ParseDBColor(CO.db.profile.colors.layoutBars.barAzerite)
		self.Bar.Overlay:GetStatusBarTexture():SetVertexColor(OverlayColor[1], OverlayColor[2], OverlayColor[3], OverlayColor[4] or 1)
		
		self:Update()
		self:Enable()
	else
		self:Disable()
	end
end

function Module:ShouldBeVisible(AzeriteItemLocation)
	return AzeriteItemLocation and AzeriteItemLocation:IsEquipmentSlot() and C_AzeriteItem_IsAzeriteItemEnabled(AzeriteItemLocation);
end

function Module:Update(event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end
	
	local Bar = self.Bar
	local AzeriteItemLocation = C_AzeriteItem_FindActiveAzeriteItem()
	local ShouldBeVisible = self:ShouldBeVisible(AzeriteItemLocation)

	if not AzeriteItemLocation or not ShouldBeVisible then
		Bar:Hide()
	else
		Bar:Show()
		
		local CurrentXP, TotalLevelXP = C_AzeriteItem_GetAzeriteItemXPInfo(AzeriteItemLocation)
		local CurrentAzeriteLevel = C_AzeriteItem_GetPowerLevel(AzeriteItemLocation)
		local XPToNextLevel = TotalLevelXP - CurrentXP

		Bar:SetMinMaxValues(0, TotalLevelXP)
		Bar:SetValue(CurrentXP)
		
		Bar.Text:SetFormattedText(AZERITE_POWER_BAR, FormatPercentage(CurrentXP / TotalLevelXP, true))
	end
end

function Module:Disable()
	self:UnregisterAllEvents()
	
	if self.Bar then
		self.Bar:Hide()
	end
end

function Module:Enable()
	self:UnregisterAllEvents()
	
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:RegisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED")
	self:RegisterEvent("PLAYER_XP_UPDATE")
	self:RegisterEvent("CVAR_UPDATE")
end

function Module:InitEventHandler()
	self:Enable()
	
	self:SetScript("OnEvent", self.Update)
	self:SetScript("OnShow", self.Update)
end

function Module:__Construct()
	self:SetPoint("BOTTOM", E.Parent, "BOTTOM", 0, 14)
	self:SetSize(749, 9)
	self:SetParent(E.Parent)
	self:SetFrameStrata("MEDIUM")
	
	self.Bar = E:CreateBar("CUI_AzeriteBar", "MEDIUM", 1, 1, {"CENTER", self, "CENTER", 0, 0}, self, true, false, false)
	self.Bar:SetAllPoints(self)
	
	E:HandleFrameInPetBattles(self.Bar)
	self.Bar.Overlay:SetSmoothFactor(40)

	self.Bar:SetBackgroundColor(0, 0, 0, 0.9)
	
	self.Bar.OverlayFrame = CreateFrame("Frame", "CUI_AzeriteOverlayFrame", self.Bar.Overlay)
	self.Bar.OverlayFrame:SetAllPoints(self.Bar.Overlay)
	self.Bar.Text = E:CreateFont(self.Bar.OverlayFrame, "db.profile.layout.barAzerite.font")
	
	self.Bar:SetScript("OnEnter", function(self)
		local AzeriteItemLocation = C_AzeriteItem_FindActiveAzeriteItem();
		if AzeriteItemLocation then
			local AzeriteItem = Item:CreateFromItemLocation(AzeriteItemLocation); 
			
			self.itemDataLoadedCancelFunc = AzeriteItem:ContinueWithCancelOnItemLoad(function()
				local azeriteItemName = AzeriteItem:GetItemName();
				local CurrentXP, TotalLevelXP = C_AzeriteItem_GetAzeriteItemXPInfo(AzeriteItemLocation)
				local CurrentAzeriteLevel = C_AzeriteItem_GetPowerLevel(AzeriteItemLocation)
				local XPToNextLevel = TotalLevelXP - CurrentXP
				
				GameTooltip_SetDefaultAnchor(GameTooltip, UIParent);
				GameTooltip:SetText(AZERITE_POWER_TOOLTIP_TITLE:format(CurrentAzeriteLevel, XPToNextLevel), HIGHLIGHT_FONT_COLOR:GetRGB());
				GameTooltip:AddLine(AZERITE_POWER_TOOLTIP_BODY:format(azeriteItemName));
				GameTooltip:Show();
			end);
		end
	end)
	self.Bar:SetScript("OnLeave", function(self)
		if self.itemDataLoadedCancelFunc then
			self.itemDataLoadedCancelFunc();
			self.itemDataLoadedCancelFunc = nil;
		end
		GameTooltip:Hide()
	end)
	
	--E:CreateMover(self, "Azerite Bar")
end

-- Those get called automatically by the module system
function Module:UpdateDB()
	self.db = CO.db.profile.layout.barAzerite
end
function Module:Init()	
	self:__Construct()
	
	self:InitEventHandler()
	
	-------------------------
	self:LoadConfig()
end

E:AddModule("Bar_Azerite", Module)