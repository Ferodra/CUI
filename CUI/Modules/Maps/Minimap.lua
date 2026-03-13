local E = unpack(select(2, ...)) -- Engine, Locale
local CO, Module = E:LoadModules("Config", "Minimap")


Module.E = CreateFrame("Frame", "CUI_MinimapEventFrame") -- Event

local _
local _G 					= _G
local pairs 				= pairs
local Minimap_ZoomIn 		= Minimap_ZoomIn
local Minimap_ZoomOut 		= Minimap_ZoomOut

local LibDBIcon 			= LibStub('LibDBIcon-1.0', true)


local MinimapHolder = CreateFrame("Frame", "CUI_MinimapHolder", E.Parent)
local CUI_MinimapBorder, CUI_MinimapBackground
local FramesToHide = {MinimapBorder, MinimapBorderTop, MinimapZoomIn, MinimapZoomOut}
local QuetMode = false
local MINIMAP_MASK_TEXTURE, MINIMAP_BORDER_TEXTURE, MINIMAP_BACKGROUND_TEXTURE, MINIMAP_PLAYERICON_TEXTURE

	MINIMAP_MASK_TEXTURE = [[Interface\AddOns\CUI\Textures\minimap\maskModern]]
	MINIMAP_BORDER_TEXTURE = [[Interface\AddOns\CUI\Textures\minimap\borderModern]]
	MINIMAP_BACKGROUND_TEXTURE = [[Interface\AddOns\CUI\Textures\minimap\background]]
	MINIMAP_PLAYERICON_TEXTURE = [[Interface\AddOns\CUI\Textures\minimap\playerIcon]]

-- FrameName = {Function to post-hook our position update to}
local BlizzButtons = {
	["ExpansionLandingPageMinimapButton"] = {"SetLandingPageIconOffset"},
}

	
do
	--if select(3, UnitClass("player")) == 11 then 
	if UnitName("player") == "Arenima" then
		-- QuetMode = true
	end
end

function Module:LoadConfig()
	
	-- Update db reference
	self.db = CO.db.profile.minimap
	if not CO.db.char.minimap.enable then return end
	
	Minimap:SetSize(self.Width * self.db.scale, self.Height * self.db.scale)
	MinimapHolder:SetSize(self.Width * self.db.scale, self.Height * self.db.scale)
	
	--print(self.Width * self.db.scale, self.Height * self.db.scale)
	
	E:UpdateMoverDimensions(MinimapHolder)
	
	self:HandleZoneButton(self.db.zoneText.enable)
	self:HandleWorldMapButton(self.db.worldMapButton.enable)
	self:LoadMinimapTextures()
	self:StyleDBIcons()
	
	self.Mail:UnregisterAllEvents()
	if not self.db.customMailIcon.enable then
		self.Mail:Hide()
	else
		self.Mail:RegisterEvent("UPDATE_PENDING_MAIL")
		self.Mail:GetScript("OnEvent")(self.Mail)
		self.Mail:ClearAllPoints()
		self.Mail:SetPoint(self.db.customMailIcon.position, Minimap, self.db.customMailIcon.position, self.db.customMailIcon.xOffset, self.db.customMailIcon.yOffset)
		self.Mail:SetScale(self.db.customMailIcon.scale)
		
		local MailColor = E:ParseDBColor(CO.db.profile.minimap.customMailIcon.rgba, "player")
		self.Mail.T:SetVertexColor(MailColor[1], MailColor[2], MailColor[3], MailColor[4])
	end
	
	if LibDBIcon then
		if LibDBIcon.objects then
			for name,_ in pairs(LibDBIcon.objects) do
				LibDBIcon:Refresh(name)
			end
		end
	end
	
	Minimap.CUIClockFrame:ClearAllPoints()
	Minimap.CUIClockFrame:SetPoint(self.db.clock.position, Minimap, self.db.clock.position, self.db.clock.xOffset, self.db.clock.yOffset)
	Minimap.CUIClockFrame:SetScale(self.db.scale)
	Minimap.CUIClockFrame:SetSize(self.db.clock.width, self.db.clock.height)
	
	-- local Col = E:ParseDBColor(CO.db.profile.minimap.clock.backgroundColor, "player")
	-- local r,g,b,a = Col[1],Col[2],Col[3],Col[4]
	-- print("ALPHA",a)
	local BGCol = E:ParseDBColor(CO.db.profile.minimap.clock.backgroundColor, "player")
	local r,g,b,a = BGCol[1],BGCol[2],BGCol[3],BGCol[4]
	local BorderBrightnessMult = 0.4
	local BackgroundBrightnessMult = 0.325
	Minimap.CUIClockFrame.Background:SetColorTexture(r*BackgroundBrightnessMult,g*BackgroundBrightnessMult,b*BackgroundBrightnessMult, a)
	
	local BorderCol = E:ParseDBColor(CO.db.profile.minimap.clock.borderColor, "player")
	r,g,b,a = BorderCol[1],BorderCol[2],BorderCol[3],BorderCol[4]
	Minimap.CUIClockFrame.Border:SetBackdropBorderColor(r*BorderBrightnessMult,g*BorderBrightnessMult,b*BorderBrightnessMult, a)
	-- ['backgroundColor'] = {useClassColor = true, {1,1,1, 1}},
	-- ['borderColor'] = {useClassColor = true, {1,1,1, 1}},
	
	if GameTimeFrame then
		GameTimeFrame:ClearAllPoints()
		GameTimeFrame:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT")
		GameTimeFrame:SetScale(1)
	end
	
	if GarrisonLandingPageMinimapButton and not GarrisonLandingPageMinimapButton.Styled then
		GarrisonLandingPageMinimapButton:ClearAllPoints()
		GarrisonLandingPageMinimapButton:SetPoint("BOTTOMLEFT", MinimapHolder, "BOTTOMLEFT")
		
		hooksecurefunc(GarrisonLandingPageMinimapButton, "SetPoint", function(self)
			if self.Abort then return end
			self.Abort = true
			
			self:ClearAllPoints()
			self:SetPoint("BOTTOMLEFT", MinimapHolder, "BOTTOMLEFT")
			
			self.Abort = nil
		end)
		
		GarrisonLandingPageMinimapButton:SetScale(1)
		if GarrisonLandingPageTutorialBox then
			--GarrisonLandingPageTutorialBox:SetScale(1 / self.db.scale)
			GarrisonLandingPageTutorialBox:SetClampedToScreen(true)
		end
		
		GarrisonLandingPageMinimapButton.Styled = true
	end
	
	if QueueStatusMinimapButton then
		QueueStatusMinimapButton:ClearAllPoints()
		QueueStatusMinimapButton:SetPoint("TOPRIGHT", Minimap, "BOTTOMLEFT")
		QueueStatusMinimapButton:SetScale(1)
		QueueStatusFrame:SetScale(1)
	end
end

function Module:StyleDBIconBorder(button)
	local Col = E:ParseDBColor(CO.db.profile.minimap.dbIconRgb, "player")
	button.border:SetVertexColor(Col[1], Col[2], Col[3], Col[4])
end

function Module:StyleDBIcons()
	if not LibDBIcon then return end
	
	local Icons = LibDBIcon.objects
	if not Icons then return end
	
	for name, button in pairs(Icons) do
		for i = 1, button:GetNumRegions() do
			if not button.border then
				local Region = select(i, button:GetRegions())
				
				if Region:GetObjectType() == 'Texture' then
					local Texture = Region:GetTexture()
					
					if Texture and strfind(Texture, 'Border') then
						Region:SetTexture([[Interface\AddOns\CUI\Textures\buttons\minimapbuttons_border]])
						Region:SetSize(25, 25)
						Region:ClearAllPoints()
						Region:SetPoint("CENTER")
						
						if not button.border then
							button.border = Region
						end
					end
				end
			end
			
			if button.border then
				self:StyleDBIconBorder(button)
			end
		end
	end
end

Module.TextureFrames = {
	["CUI_MinimapBorder"] 		= {140, MINIMAP_BORDER_TEXTURE, {0,1,0,1}},
	-- ["CUI_MinimapBackground"] 	= {140, MINIMAP_BACKGROUND_TEXTURE, {0,1,0,1}},
}

function Module:LoadMinimapTextures()
	for k,v in pairs(self.TextureFrames) do		
		local Texture = Minimap[k] or Minimap:CreateTexture(nil)
		
		Texture:SetAllPoints(Minimap)
		--Object:SetPoint("CENTER", Minimap, "CENTER", 0, 0)
		--Object:SetSize(Size, Size)
		Texture:SetTexture(v[2])
		Texture:SetTexCoord(v[3][1],v[3][2],v[3][3],v[3][4])
		
		if k == "CUI_MinimapBorder" then
			local Col = E:ParseDBColor(CO.db.profile.minimap.borderColor, "player")
			Texture:SetVertexColor(Col[1], Col[2], Col[3], Col[4])
		end
		
		Minimap[k] = Texture
	end
end

function Module:LoadMinimapStyle()
	
	self:LoadMinimapTextures()
	
	self.Width = Minimap:GetWidth()
	self.Height = Minimap:GetHeight()
	
	MinimapHolder:SetSize(self.Width, self.Height)
	Minimap:ClearAllPoints()
	--Minimap:SetAllPoints(MinimapHolder)
	Minimap:SetPoint("TOPRIGHT", MinimapHolder, "TOPRIGHT")
	MinimapBackdrop:ClearAllPoints()
	MinimapBackdrop:SetAllPoints(Minimap)
	MinimapBackdrop:Hide()
	self.Mover = E:CreateMover(MinimapHolder, "Minimap", nil, nil, nil, nil, "misc")
	
	Minimap:SetQuestBlobRingAlpha(0)
	Minimap:SetArchBlobRingAlpha(0)
	Minimap:SetMaskTexture(MINIMAP_MASK_TEXTURE)
	
	self:EnableMouseZoom()
	self:HideBlizzard()
	
	if QuetMode == true then Minimap:SetPlayerTexture(MINIMAP_PLAYERICON_TEXTURE) end
end

function Module:HideBlizzard()
	for k,v in pairs(FramesToHide) do
		v:Hide()
	end
	
	MinimapCluster:EnableMouse(false)
end

function Module:EnableMouseZoom()
	Minimap:EnableMouseWheel(true)
	Minimap:SetScript('OnMouseWheel', function(self, delta)
		if delta > 0 then
			Minimap_ZoomIn()
		else
			Minimap_ZoomOut() 
		end
	end)
end

function Module:StyleButtons()
	local TrackingButtonName = "MiniMapTracking"
	
	--_G[TrackingButtonName .. "Background"]:Hide()
	if _G[TrackingButtonName .. "ButtonBorder"] then
		_G[TrackingButtonName .. "ButtonBorder"]:Hide()
		
		_G[TrackingButtonName]:ClearAllPoints()
		_G[TrackingButtonName]:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 1, 2)
		
		_G[TrackingButtonName .. "Background"]:SetTexture([[Interface\AddOns\CUI\Textures\icons\minimap\IconBackground]])
		_G[TrackingButtonName .. "Background"]:SetVertexColor(0.5, 0.5, 0.5, 1)
	end
	
	if _G[TrackingButtonName .. "Button"] then
		_G[TrackingButtonName .. "Button"]:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self)
			GameTooltip:AddLine("|cff1784d1" .. TRACKING .. "|r")
			GameTooltip:AddLine(MINIMAP_TRACKING_TOOLTIP_NONE)
			
			GameTooltip:Show()
		end)
	end
	
	self:HandleClock()
	self:HandleDifficulty()
	
	self:AddMailIcon()
end

-- @TODO: Add a top/bottom/side-panel to display some information
function Module:AddInfoPanel()
	
end

function Module:AddMailIcon()
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

function Module:HandleMailIcon()	
	local ButtonObj = _G["MinimapCluster"].IndicatorFrame.MailFrame
	if ButtonObj then
		ButtonObj:UnregisterAllEvents()
		ButtonObj:Hide()
		--[[if state == false then
			ButtonObj:SetScript("OnShow", function(self) self:Hide() end)
			ButtonObj:Hide()
		else
			ButtonObj:SetScript("OnShow", nil)
			if HasNewMail() then
				ButtonObj:Show()
			end
		end]]--
	end
end

function Module:HandleDifficulty()
	local Diff = "MiniMapInstanceDifficulty"
	
	if not _G[Diff] then return end
	
	_G[Diff]:ClearAllPoints()
	_G[Diff]:SetPoint("LEFT", Minimap, "LEFT", -(_G[Diff]:GetWidth() / 2), 0)
	
	local GuildDiff = "GuildInstanceDifficulty"
	
	_G[GuildDiff]:ClearAllPoints()
	_G[GuildDiff]:SetPoint("LEFT", Minimap, "LEFT", -(_G[GuildDiff]:GetWidth() / 2), (_G[GuildDiff]:GetHeight()))
end

function Module:HandleZoneButton(state)
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

function Module:HandleWorldMapButton(state)
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

function Module:HandleClock()
	-- We simply cannot access the border texture. Damn.
	local Clock = "TimeManagerClockButton"
	
	_G[Clock]:SetScript("OnShow", function(self) self:Hide() end)
	_G[Clock]:Hide()
	
	local ClockFrame = CreateFrame("Button", "CUI_ClockFrame", Minimap, BackdropTemplateMixin and "BackdropTemplate")
	ClockFrame:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, 5)
	ClockFrame:SetSize(40, 20)
	
	ClockFrame.Background = E:CreateBackground(ClockFrame)
	ClockFrame.Border = E:CreateBorder(ClockFrame, nil, 1)
	
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
	E:RegisterAutoFont(ClockFrame.Time, "db.profile.minimap.clock.text")
	
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

local function ApplyPositioning(self)
	self:ClearAllPoints()
	self:SetPoint("CENTER", MinimapHolder, "BOTTOMLEFT", 0, 0)
end

function Module:HandleBlizzButtons()
	local Frame
	
	for name, info in pairs(BlizzButtons) do
		Frame = _G[name]
		if Frame then
			Frame:SetParent(MinimapHolder)
			Frame.ApplyPositioning = ApplyPositioning
			hooksecurefunc(Frame, info[1], Frame.ApplyPositioning)
			
			Frame:ApplyPositioning()
		end
	end
end

-- Causes the minimap buttons to correctly follow the new shape
-- We simply override the function global c:
--GetMinimapShape = function() return "CORNER-BOTTOMLEFT" end
-- Fix for when the minimap is not on its default position or scaled up high.
--MinimapCluster.GetBottom = function() return 9999 end

function Module:Init()
	self.db = CO.db.profile.minimap
	
	if not CO.db.char.minimap.enable then return end
	
	self:LoadMinimapStyle()
	GetMinimapShape = function() return "SQUARE" end
	
	Minimap:SetArchBlobRingScalar(0)
	Minimap:SetQuestBlobRingScalar(0)
	
	self:StyleButtons()
	self:HandleMailIcon()
	self:HandleBlizzButtons()
	
	if LibDBIcon then
		hooksecurefunc(LibDBIcon, "Register", function()
			self:StyleDBIcons()
		end)
		-- Initial Update
		self:StyleDBIcons()
	end
	
	self:LoadConfig()
end

E:AddModule("Minimap", Module)