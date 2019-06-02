local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO,MM = E:LoadModules("Config", "Minimap")


MM.E = CreateFrame("Frame") -- Event

local _
local _G 					= _G
local pairs 				= pairs
local Minimap_ZoomIn 		= Minimap_ZoomIn
local Minimap_ZoomOut 		= Minimap_ZoomOut


local MinimapHolder = CreateFrame("Frame", "CUI_MinimapHolder", E.Parent)
local CUI_MinimapBorder, CUI_MinimapBackground
local FramesToHide = {MinimapBorder, MinimapBorderTop, MinimapZoomIn, MinimapZoomOut}
local QuetMode = false
local MINIMAP_MASK_TEXTURE, MINIMAP_BORDER_TEXTURE, MINIMAP_BACKGROUND_TEXTURE, MINIMAP_PLAYERICON_TEXTURE

	MINIMAP_MASK_TEXTURE = [[Interface\AddOns\CUI\Textures\minimap\maskModern]]
	MINIMAP_BORDER_TEXTURE = [[Interface\AddOns\CUI\Textures\minimap\borderModern]]
	MINIMAP_BACKGROUND_TEXTURE = [[Interface\AddOns\CUI\Textures\minimap\background]]
	MINIMAP_PLAYERICON_TEXTURE = [[Interface\AddOns\CUI\Textures\minimap\playerIcon]]
	
--local GetMinimapShape = GetMinimapShape

	
do
	--if select(3, UnitClass("player")) == 11 then 
	if UnitName("player") == "Arenima" then
		-- QuetMode = true
	end
end

function MM:LoadProfile()
	
	-- Update db reference
	self.db = CO.db.profile.minimap
	
	Minimap:SetSize(self.Width * self.db.scale, self.Height * self.db.scale)
	MinimapHolder:SetSize(self.Width * self.db.scale, self.Height * self.db.scale)
	
	E:UpdateMoverDimensions(MinimapHolder)
	
	self:HandleZoneButton(self.db.zoneText.enable)
	self:HandleWorldMapButton(self.db.worldMapButton.enable)
	self:HandleMailIcon(self.db.mailIcon.enable)
	
	self.Mail:UnregisterAllEvents()
	if not self.db.customMailIcon.enable then
		self.Mail:Hide()
	else
		self.Mail:RegisterEvent("UPDATE_PENDING_MAIL")
		self.Mail:GetScript("OnEvent")(self.Mail)
	end
	
	Minimap.CUIClockFrame:SetScale(self.db.scale)
	
	if GameTimeFrame then
		GameTimeFrame:ClearAllPoints()
		GameTimeFrame:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT")
		GameTimeFrame:SetScale(1)
	end
	
	if GarrisonLandingPageMinimapButton then
		GarrisonLandingPageMinimapButton:ClearAllPoints()
		GarrisonLandingPageMinimapButton:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT")
		GarrisonLandingPageMinimapButton:SetScale(1)
		if GarrisonLandingPageTutorialBox then
			--GarrisonLandingPageTutorialBox:SetScale(1 / self.db.scale)
			GarrisonLandingPageTutorialBox:SetClampedToScreen(true)
		end
	end
	
	if QueueStatusMinimapButton then
		QueueStatusMinimapButton:ClearAllPoints()
		QueueStatusMinimapButton:SetPoint("TOPRIGHT", Minimap, "BOTTOMLEFT")
		QueueStatusMinimapButton:SetScale(1)
		QueueStatusFrame:SetScale(1)
	end
end

function MM:LoadMinimapStyle()
	local Update = function(Object, Size, Texture, TextureCoord)
		Object = Minimap:CreateTexture(nil)
		
		Object:SetAllPoints(Minimap)
		--Object:SetPoint("CENTER", Minimap, "CENTER", 0, 0)
		--Object:SetSize(Size, Size)
		Object:SetTexture(Texture)
		Object:SetTexCoord(TextureCoord[1],TextureCoord[2],TextureCoord[3],TextureCoord[4])
	end
	local Frames = {
		["CUI_MinimapBorder"] 		= {140, MINIMAP_BORDER_TEXTURE, {0,1,0,1}},
		-- ["CUI_MinimapBackground"] 	= {140, MINIMAP_BACKGROUND_TEXTURE, {0,1,0,1}},
	}
	for k,v in pairs(Frames) do
		Update(k, v[1],v[2],v[3])
	end
	
	self.Width = Minimap:GetWidth()
	self.Height = Minimap:GetHeight()
	
	MinimapHolder:SetSize(self.Width, self.Height)
	Minimap:ClearAllPoints()
	--Minimap:SetAllPoints(MinimapHolder)
	Minimap:SetPoint("TOPRIGHT", MinimapHolder, "TOPRIGHT")
	MinimapBackdrop:ClearAllPoints()
	MinimapBackdrop:SetAllPoints(Minimap)
	self.Mover = E:CreateMover(MinimapHolder, "Minimap")
	
	Minimap:SetQuestBlobRingAlpha(0)
	Minimap:SetArchBlobRingAlpha(0)
	Minimap:SetMaskTexture(MINIMAP_MASK_TEXTURE)
	
	self:EnableMouseZoom()
	self:HideBlizzard()
	
	if QuetMode == true then Minimap:SetPlayerTexture(MINIMAP_PLAYERICON_TEXTURE) end
end

function MM:HideBlizzard()
	for k,v in pairs(FramesToHide) do
		v:Hide()
	end
	
	MinimapCluster:EnableMouse(false)
end

function MM:EnableMouseZoom()
	Minimap:EnableMouseWheel(true)
	Minimap:SetScript('OnMouseWheel', function(self, delta)
		if delta > 0 then
			Minimap_ZoomIn()
		else
			Minimap_ZoomOut() 
		end
	end)
end

function MM:StyleButtons()
	local TrackingButtonName = "MiniMapTracking"
	
	--_G[TrackingButtonName .. "Background"]:Hide()
	_G[TrackingButtonName .. "ButtonBorder"]:Hide()
	
	_G[TrackingButtonName]:ClearAllPoints()
	_G[TrackingButtonName]:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 1, 2)
	
	_G[TrackingButtonName .. "Background"]:SetTexture([[Interface\AddOns\CUI\Textures\icons\minimap\IconBackground]])
	_G[TrackingButtonName .. "Background"]:SetVertexColor(0.5, 0.5, 0.5, 1)
	
	_G[TrackingButtonName .. "Button"]:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self)
		GameTooltip:AddLine("|cff1784d1" .. TRACKING .. "|r")
		GameTooltip:AddLine(MINIMAP_TRACKING_TOOLTIP_NONE)
		
		GameTooltip:Show()
	end)
	
	self:HandleClock()
	self:HandleDifficulty()
	
	self:AddMailIcon()
end

-- @TODO: Add a top/bottom/side-panel to display some information
function MM:AddInfoPanel()
	
end

function MM:AddMailIcon()
	self.Mail = E:CreateTextureFrame({"BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", -6, 0}, Minimap, 20, 25, "ARTWORK")
	self.Mail.T:SetTexture([[Interface\AddOns\CUI\Textures\icons\minimap\mailIcon]])
	self.Mail:EnableMouse(true)
	
	self.Mail:SetScript("OnEvent", function(self, event, ...)
		if ( HasNewMail() ) then
			self:Show();
			if( GameTooltip:IsOwned(self) ) then
				MinimapMailFrameUpdate();
			end
		else
			self:Hide();
		end
	end)
	self.Mail:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT");
		if( GameTooltip:IsOwned(self) ) then
			MinimapMailFrameUpdate();
		end
	end)
	self.Mail:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
end

function MM:HandleMailIcon(state)
	local Button = "MiniMapMailFrame"
	
	local ButtonObj = _G[Button]
	if ButtonObj then
		if state == false then
			ButtonObj:SetScript("OnShow", function(self) self:Hide() end)
			ButtonObj:Hide()
		else
			ButtonObj:SetScript("OnShow", nil)
			if HasNewMail() then
				ButtonObj:Show()
			end
		end
	end
end

function MM:HandleDifficulty()
	local Diff = "MiniMapInstanceDifficulty"
	
	_G[Diff]:ClearAllPoints()
	_G[Diff]:SetPoint("LEFT", Minimap, "LEFT", -(_G[Diff]:GetWidth() / 2), 0)
end

function MM:HandleZoneButton(state)
	local Button = "MinimapZoneTextButton"
	
	local ButtonObj = _G[Button]
	if ButtonObj then
		if state == false then
			ButtonObj:SetScript("OnShow", function(self) self:Hide() end)
			ButtonObj:Hide()
		else
			ButtonObj:SetScript("OnShow", nil)
			ButtonObj:Show()
		end
	end
end

function MM:HandleWorldMapButton(state)
	local Button = "MiniMapWorldMapButton"
	
	local ButtonObj = _G[Button]
	if ButtonObj then
		if state == false then
			ButtonObj:SetScript("OnShow", function(self) self:Hide() end)
			ButtonObj:Hide()
		else
			ButtonObj:SetScript("OnShow", nil)
			ButtonObj:Show()
		end
	end
end

function MM:HandleClock()
	-- We simply cannot access the border texture. Damn.
	local Clock = "TimeManagerClockButton"
	_G[Clock]:SetScript("OnShow", function(self) self:Hide() end)
	_G[Clock]:Hide()
	
	local ClockFrame = CreateFrame("Button", "CUI_ClockFrame", Minimap)
	ClockFrame:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, 5)
	ClockFrame:SetSize(50, 10)
	
	ClockFrame:EnableMouse(true)
	ClockFrame:RegisterForClicks("AnyUp")
	
	ClockFrame:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self)
		TimeManagerClockButton_UpdateTooltip()
	end)
	ClockFrame:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
	ClockFrame:SetScript("OnClick", _G[Clock]:GetScript("OnClick"))
	
	ClockFrame.Time = ClockFrame:CreateFontString(nil)
	E:InitializeFontFrame(ClockFrame.Time, "OVERLAY", "FRIZQT__.TTF", 10, {1,1,1}, 1, {0,0}, "", 0, 0, ClockFrame, "CENTER", {1,1})
	
	ClockFrame.updateTimer = 0
	ClockFrame:SetScript("OnUpdate", function(self, elapsed)
		self.updateTimer = self.updateTimer + elapsed
		
		if self.updateTimer >= 0.85 then
			self.Time:SetText(GameTime_GetTime(GetCVar("timeMgrUseMilitaryTime")))
			
			self.updateTimer = 0
		end
	end)
	
	Minimap.CUIClockFrame = ClockFrame
end

-- Causes the minimap buttons to correctly follow the new shape
-- We simply override the function global c:
--GetMinimapShape = function() return "CORNER-BOTTOMLEFT" end
GetMinimapShape = function() return "SQUARE" end
-- Fix for when the minimap is not on its default position or scaled up high.
--MinimapCluster.GetBottom = function() return 9999 end

function MM:Init()
	self.db = CO.db.profile.minimap
	self:LoadMinimapStyle()
	
	Minimap:SetArchBlobRingScalar(0)
	Minimap:SetQuestBlobRingScalar(0)
	
	self:StyleButtons()
	
	self.E:RegisterEvent("ADDON_LOADED")
	self.E:SetScript("OnEvent", function(self, event, ...)
		
	end)
	
	self:LoadProfile()
end

E:AddModule("Minimap", MM)