local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, Module, TT = E:LoadModules("Config", "Layout", "Tooltip")
local HBD = LibStub("HereBeDragons-2.0") -- Using HereBeDragons to handle the coords

--[[
	This module abomination needs a complete rewrite, omg
	I didn't know any better before, okay?
]]--

local _
local CreateFrame		= CreateFrame
local format			= string.format

-------------------------------------------------------

local ClassColor

local TextureDir = "Interface/AddOns/CUI/Textures/"
local Textures = {
	--['StatIcon'] 	= [[Interface\AddOns\CUI\Textures\layout\StatIconOuter]], -- I don't even remember what this was for
	['EdgeSmall'] 	= TextureDir .. "layout/modern/LayoutBarEdge",
	['Bar'] 		= TextureDir .. "layout/modern/LayoutBar",
	['BarSmall'] 	= TextureDir .. "layout/modern/LayoutBarSmall",
	['EdgeBig'] 	= TextureDir .. "layout/modern/LayoutBottomBarEdge",
}
local Fonts = {"CoordX", "CoordY", "Zone", "Fps", "Ping"}

function Module:LoadConfig()
	
	local Config = CO.db.profile.layout
	self.db = Config
	
	ClassColor = E:GetUnitClassColor("player")
	
	local state = Config.stateControl.textures	
	if not state["enableTop"] then
		self.TopPanel:Hide()
	else
		self.TopPanel:Show()
	end
	
	if not state["enableBottom"] then
		self.BottomPanel:Hide()
	else
		self.BottomPanel:Show()
		
		self.BottomPanel.Center:ClearAllPoints()
		-- For those, we just leave the edges shown, as they're pushed off-screen anyway when we adjust the width
		-- Both
		if not state["enableBottomLeft"] and not state["enableBottomRight"] then
			self.BottomPanel.Center:SetWidth(GetScreenWidth())
			self.BottomPanel.Center:SetPoint("BOTTOM", self.F, "BOTTOM")
		elseif not state["enableBottomLeft"] then
			self.BottomPanel.Center:SetWidth(GetScreenWidth() - 140)
			self.BottomPanel.Center:SetPoint("BOTTOMLEFT", self.F, "BOTTOMLEFT")
		elseif not state["enableBottomRight"] then
			self.BottomPanel.Center:SetWidth(GetScreenWidth() - 140)
			self.BottomPanel.Center:SetPoint("BOTTOMRIGHT", self.F, "BOTTOMRIGHT")
		-- None
		else
			self.BottomPanel.Center:SetWidth(GetScreenWidth() - (140 * 2))
			self.BottomPanel.Center:SetPoint("BOTTOM", self.F, "BOTTOM")
		end
	end

	
	-- Disable OnUpdate
	if not Config.fps.enable and
		not Config.ping.enable and
		not Config.zone.enable and
		not Config.coordx.enable and
		not Config.coordy.enable then
			self.F:SetScript("OnUpdate", nil)
	else
			self.F:SetScript("OnUpdate", self.FontFrames_OnUpdate)
	end
	
	UnregisterStateDriver(Module.F, "visible")
	RegisterStateDriver(Module.F, "visible", format("[petbattle]%s 0;1", Config.stateControl.additionalHideConditions or ""))
end

function Module:SetZoneTooltipData()

	local pvpType, _, factionName = GetZonePVPInfo();
	local zoneName = GetZoneText();
	local subzoneName = GetSubZoneText();
	if ( subzoneName == zoneName ) then
		subzoneName = "";
	end
	GameTooltip:AddLine( zoneName, 1.0, 1.0, 1.0 );
	if ( pvpType == "sanctuary" ) then
		GameTooltip:AddLine( subzoneName, 0.41, 0.8, 0.94 );
		GameTooltip:AddLine(SANCTUARY_TERRITORY, 0.41, 0.8, 0.94);
	elseif ( pvpType == "arena" ) then
		GameTooltip:AddLine( subzoneName, 1.0, 0.1, 0.1 );
		GameTooltip:AddLine(FREE_FOR_ALL_TERRITORY, 1.0, 0.1, 0.1);
	elseif ( pvpType == "friendly" ) then
		if (factionName and factionName ~= "") then
			GameTooltip:AddLine( subzoneName, 0.1, 1.0, 0.1 );
			GameTooltip:AddLine(format(FACTION_CONTROLLED_TERRITORY, factionName), 0.1, 1.0, 0.1);
		end
	elseif ( pvpType == "hostile" ) then
		if (factionName and factionName ~= "") then
			GameTooltip:AddLine( subzoneName, 1.0, 0.1, 0.1 );
			GameTooltip:AddLine(format(FACTION_CONTROLLED_TERRITORY, factionName), 1.0, 0.1, 0.1);
		end
	elseif ( pvpType == "contested" ) then
		GameTooltip:AddLine( subzoneName, 1.0, 0.7, 0.0 );
		GameTooltip:AddLine(CONTESTED_TERRITORY, 1.0, 0.7, 0.0);
	elseif ( pvpType == "combat" ) then
		GameTooltip:AddLine( subzoneName, 1.0, 0.1, 0.1 );
		GameTooltip:AddLine(COMBAT_ZONE, 1.0, 0.1, 0.1);
	else
		GameTooltip:AddLine( subzoneName, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b );
	end
end

function Module:FontFrames_OnUpdate(elapsed)
	self.SystemTimer = (self.SystemTimer or 0) + elapsed;
	self.CoordsTimer = (self.CoordsTimer or 0) + elapsed;
	
	
	if ( self.SystemTimer >= CO.db.profile.layout.stateControl.layoutUpdateFrequency ) then
		Module:UpdateSystemValues()
		
		self.SystemTimer = 0
	end
	

	if ( self.CoordsTimer >= CO.db.profile.layout.stateControl.coordsUpdateFrequency ) then
		Module:UpdateLocationCoords()
		
		self.CoordsTimer = 0
	end
end

local function FontInit(Name)
	local Font = E:NewFontObject(nil, "ARTWORK", Module.F.Overlay, 10)
	
	if Name == "Zone" then
		E:RegisterAutoFont(Font, "db.profile.layout." .. string.lower(Name), {["fontColor"] = true})
	else
		E:RegisterAutoFont(Font, "db.profile.layout." .. string.lower(Name))
	end
	
	Module.Fonts[Name] = Font
end
	
function Module:InitDataPanels()
	local TopPanel = CreateFrame("Frame", "CUI_LayoutTopPanel", self.F)
	local BottomPanel = CreateFrame("Frame", "CUI_LayoutBottomPanel", self.F)
	self.TopPanel = TopPanel
	self.BottomPanel = BottomPanel
	
	-- Path, Suffix, ReferenceFrame, SizeX, SizeY, Position, Parent, RelativePosition, OffsetX, OffsetY, Texture, TexCoord1, TexCoord2, TexCoord3, TexCoord4
	local Data = {
		[1] = {"Center", TopPanel, 750, 30, "TOP", self.F, "TOP", 0, 0, Textures.Bar, 0, 1, 0, 1},
		[2] = {"Left", TopPanel, 60, 60, "TOPRIGHT", function() return TopPanel.Center end, "TOPLEFT", 0, 0, Textures.EdgeSmall, 0, 1, 0, 1},
		[3] = {"Right", TopPanel, 60, 60, "TOPLEFT", function() return TopPanel.Center end, "TOPRIGHT", 0, 0, Textures.EdgeSmall, 1, 0, 0, 1},
		--[2] = {"Tex", "Left", TopPanel, 60, 60, "TOPLEFT", "Location.Tex", "TOPLEFT", -60, 0, Textures.EdgeSmall, 0, 1, 0, 1},
		--[3] = {"Tex", "Right", TopPanel, 60, 60, "TOPRIGHT", "Location.Tex", "TOPRIGHT", 60, 0, Textures.EdgeSmall, 1, 0, 0, 1},
		
		[4] = {"Center", BottomPanel, GetScreenWidth() - (140 * 2), 15, "BOTTOM", self.F, "BOTTOM", 0, 0, Textures.BarSmall, 0, 1, 0, 1},
		[5] = {"Left", BottomPanel, 140, 200, "BOTTOMRIGHT", function() return BottomPanel.Center end, "BOTTOMLEFT", 0, -1, Textures.EdgeBig, 0, 1, 0, 1},
		[6] = {"Right", BottomPanel, 140, 200, "BOTTOMLEFT", function() return BottomPanel.Center end, "BOTTOMRIGHT", 0, -1, Textures.EdgeBig, 1, 0, 0, 1},
	}
	
	-- ipairs, since we have to reference the center frame(s) for the edges
	for k, v in ipairs(Data) do
		local Texture = v[2]:CreateTexture(nil, "BACKGROUND")
	
		Texture:SetTexture(v[10])
		Texture:SetSize(v[3], v[4])
		
		local Parent = v[6]
		if type(Parent) == 'function' then
			Parent = v[6]()
		end
		Texture:SetPoint(v[5], Parent, v[7], v[8], v[9])
		Texture:SetTexCoord(v[11], v[12], v[13], v[14])
		Texture:SetVertexColor(0.8, 0.8, 0.8)
		Texture:SetBlendMode("Blend")
		Texture:SetAlpha(1)
		
		v[2][v[1]] = Texture
	end
	
	for k,v in pairs(Fonts) do
		FontInit(v)
	end
	
	TopPanel:RegisterEvent("ZONE_CHANGED")
	TopPanel:RegisterEvent("ZONE_CHANGED_INDOORS")
	TopPanel:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	TopPanel:SetScript("OnEvent", function(self, event, ...)
		Module:UpdateLocationZone()
	end)
	self.F:SetScript("OnUpdate", self.FontFrames_OnUpdate)
	
	self.Fonts.Zone.Button = CreateFrame("Button")
	self.Fonts.Zone.Button:SetAllPoints(self.Fonts.Zone)
	self.Fonts.Zone.Button:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
		Module:SetZoneTooltipData()
		GameTooltip:Show()
		
		TT:UpdateStyle()
	end)
	self.Fonts.Zone.Button:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	
	
	self:UpdateLocationZone()
end

local ColorizedReturn = 0
local ColorizedPing = {[0] = "FF2ded4d", [75] = "FFe3b034", [150] = "FFea2020"}
local ColorizedFPS = {[0] = "FFea2020", [25] = "FFe3b034", [45] = "FF2ded4d"}
function Module:GetColorized(type, value)
	if type == "ping" then
		for k,v in pairs(ColorizedPing) do
			if k <= value then
				ColorizedReturn = format("|c%s%sms|r", v, value)
			end
		end
	elseif type == "fps" then
		for k,v in pairs(ColorizedFPS) do
			if k <= value then
				ColorizedReturn = format("|c%s%s|r", v, E:Round(value,1))
			end
		end
	end
	
	return ColorizedReturn
end

function Module:UpdateSystemValues()
	if not self.db or not self.db.fps then return end
	
	if self.db.fps.enable then
		self.Fonts.Fps:SetText("FPS: " .. self:GetColorized("fps", GetFramerate()))
	end
	
	if self.db.ping.enable then
		self.Fonts.Ping:SetText("Ping: " .. self:GetColorized("ping", select(3, GetNetStats())))
	end
end

local LocationCoordPosX, LocationCoordPosY
local LastPlayerCoordinates = {["x"] = 0, ["y"] = 0}
function Module:UpdateLocationCoords()
	if not self.db.coordx or not self.db.coordx.enable and not self.db.coordy.enable then return end
	
	LocationCoordPosX, LocationCoordPosY = HBD:GetPlayerZonePosition()
	
	if LocationCoordPosX and LocationCoordPosY then
		
		if (LocationCoordPosX and LocationCoordPosY) and LocationCoordPosX ~= LastPlayerCoordinates["x"] or LocationCoordPosY ~= LastPlayerCoordinates["y"] then
		
			self.Fonts.CoordX:SetText(format("%.2f",	LocationCoordPosX * 100))
			self.Fonts.CoordY:SetText(format("%.2f",	LocationCoordPosY * 100))
			
			LastPlayerCoordinates["x"] = LocationCoordPosX
			LastPlayerCoordinates["y"] = LocationCoordPosY
		end
	else
		self.Fonts.CoordX:SetText("")
		self.Fonts.CoordY:SetText("")
	end
end

function Module:UpdateLocationZone()
	local pvpType, isSubZonePvP, factionName = GetZonePVPInfo();
	
	self.zoneColors = CO.db.profile.colors.zones
	local Color
	
	if ( pvpType == "sanctuary" ) then
		Color = self.zoneColors.sanctuary
	elseif ( pvpType == "arena" ) then
		Color = self.zoneColors.arena
	elseif ( pvpType == "friendly" ) then
		Color = self.zoneColors.friendly
	elseif ( pvpType == "hostile" ) then
		Color = self.zoneColors.hostile
	elseif ( pvpType == "contested" ) then
		Color = self.zoneColors.contested
	elseif ( pvpType == "combat" ) then
		Color = self.zoneColors.combat
	else
		Color = self.zoneColors.default
	end
	
	self.CurrentZone 	= GetZoneText()
	self.CurrentSubZone = GetSubZoneText()
	
	local Font = self.Fonts.Zone
	Font:SetTextColor(unpack(Color))
	
	if self.CurrentZone == self.CurrentSubZone or self.CurrentSubZone == "" then
		Font:SetText(format("%s", self.CurrentZone))
	else
		Font:SetText(format("%s, %s", self.CurrentZone, self.CurrentSubZone))
	end
end

function Module:UpdateDB()
	self.db = CO.db.profile.layout
	self.statedb = self.db.stateControl
end
function Module:Init()
	self.Frames = {}
	self.Fonts = {}
	
	self:UpdateDB()
	
	self.F = CreateFrame("Frame", "CUI_LayoutStateFrame", E.Parent, "SecureHandlerStateTemplate")
	self.F.Overlay = CreateFrame("Frame", nil, self.F)
	self.VisibilityHandler = CreateFrame("Frame", "CUI_LayoutVisibilityHandlerFrame", self.F, "SecureHandlerStateTemplate")
	self.VisibilityHandler:SetAllPoints(Module.F)
	
	E:SetVisibilityHandler(self.F)
	E:SetVisibilityHandler(self.VisibilityHandler)
	RegisterStateDriver(self.F, "visible", "[petbattle] 0;1")
	
	ClassColor = E:GetUnitClassColor("player")
	
	self.F:SetAllPoints(E.Parent)
	self.F.Overlay:SetAllPoints(self.F)
	
	self:InitDataPanels()
	
	self:LoadConfig()
end

E:AddModule("Layout", Module)