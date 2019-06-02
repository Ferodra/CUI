local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, L, LT, TT = E:LoadModules("Config", "Locale", "Layout", "Tooltip")
local HBD = LibStub("HereBeDragons-2.0") -- Using HereBeDragons to handle the coords

local _
local CreateFrame		= CreateFrame
local format			= string.format

LT.F = CreateFrame("Frame", "LT", E.Parent, "SecureHandlerStateTemplate")
LT.F.Overlay = CreateFrame("Frame", nil, LT.F)
local Location = CreateFrame("Frame", "Location", LT.F)
local EdgeBottom = CreateFrame("Frame", "EdgeBottom", LT.F)
local Fps = CreateFrame("Frame", "Fps", LT.F)
local Ping = CreateFrame("Frame", "Ping", LT.F)
local LocationInit, LocationFonts, FontInit, DataFonts
local ClassColor, LastPlayerCoordinates
local EDGETILE_BOTTOM_TEXTURE, STATICON_TEXTURE, EDGETILE_BOTTOM_TEXTURE_MODERN, LOCATIONPANEL_EDGE_TEXTURE, BAR_TEXTURE, BAR_SMALL_TEXTURE

	STATICON_TEXTURE					= [[Interface\AddOns\CUI\Textures\layout\StatIconOuter]]
	
	LOCATIONPANEL_EDGE_TEXTURE				= [[Interface\AddOns\CUI\Textures\layout\modern\LayoutBarEdge]]
	BAR_TEXTURE								= [[Interface\AddOns\CUI\Textures\layout\modern\LayoutBar]]
	BAR_SMALL_TEXTURE						= [[Interface\AddOns\CUI\Textures\layout\modern\LayoutBarSmall]]
	EDGETILE_BOTTOM_TEXTURE					= [[Interface\AddOns\CUI\Textures\layout\modern\LayoutBottomBarEdge]]
	
	LT.F.RangeTimer = 0
	LT.F.CoordsTimer = 0
	LastPlayerCoordinates = {["x"] = 0, ["y"] = 0}
	DataFonts = {
		["CoordX"] 		= {"Location", "", 13, "LEFT", {80,-2}},
		["CoordY"] 		= {"Location", "", 13, "RIGHT", {-80,-2}},
		["Zone"] 		= {"Location", "", 14, "CENTER", {0,-2}},
		["Fps"] 		= {"EdgeBottom", "Left", 14, "BOTTOMLEFT", {10,10}},
		["Ping"] 		= {"EdgeBottom", "Right", 14, "BOTTOMRIGHT", {-10,10}},
	}

do
	E:SetVisibilityHandler(LT.F)
	
	RegisterStateDriver(LT.F, "visible", "[petbattle] 0;1")
end

function LT:LoadProfile()
	
	self.db = CO.db.profile.layout
	self.sysdb = CO.db.profile.system
	ClassColor = E:GetUnitClassColor("player")
	
	local disabled = {}
	
	for k, v in pairs(self.Frames) do
		for _, frame in pairs(v) do
			if self.sysdb[k] then
				frame:Show()
			else
				frame:Hide()
				disabled[k] = true
			end
		end
	end
	
	self.EdgeBottom.Center:ClearAllPoints()
	
	-- Both
		if disabled["enableBottomLeft"] and disabled["enableBottomRight"] then
			self.EdgeBottom.Center:SetWidth(GetScreenWidth())
			self.EdgeBottom.Center:SetPoint("BOTTOM", self.F, "BOTTOM")
		elseif disabled["enableBottomLeft"] then
			self.EdgeBottom.Center:SetWidth(GetScreenWidth() - 140)
			self.EdgeBottom.Center:SetPoint("BOTTOMLEFT", self.F, "BOTTOMLEFT")
		elseif disabled["enableBottomRight"] then
			self.EdgeBottom.Center:SetWidth(GetScreenWidth() - 140)
			self.EdgeBottom.Center:SetPoint("BOTTOMRIGHT", self.F, "BOTTOMRIGHT")
	-- None
		else
			self.EdgeBottom.Center:SetWidth(GetScreenWidth() - (140 * 2))
			self.EdgeBottom.Center:SetPoint("BOTTOM", self.F, "BOTTOM")
		end
	
	-- Disable OnUpdate
	if not self.db.fps.enable and
		not self.db.ping.enable and
		not self.db.zone.enable and
		not self.db.coordx.enable and
		not self.db.coordy.enable then
			print("Disable")
			self.F:SetScript("OnUpdate", nil)
	else
			self.F:SetScript("OnUpdate", self.FontFrames_OnUpdate)
	end
end

function LT:SetZoneTooltipData()

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

function LT:FontFrames_OnUpdate(elapsed)
	if ( self.RangeTimer ) then
		self.RangeTimer = self.RangeTimer + elapsed;
		if ( self.RangeTimer >= CO.db.profile.system.layoutUpdateFrequency ) then
			LT:UpdateSystemValues()
			
			self.RangeTimer = 0
		end
	end
	if ( self.CoordsTimer ) then
		self.CoordsTimer = self.CoordsTimer + elapsed;

		if ( self.CoordsTimer >= CO.db.profile.system.coordsUpdateFrequency ) then
			LT:UpdateLocationCoords()
			
			self.CoordsTimer = 0
		end
	end
end
	
function LT:InitDataPanels()
	
	Location:ClearAllPoints()
	Location:SetPoint("CENTER", self.F, "CENTER")
	
	-- Path, Appendix, CreationFrame, SizeX, SizeY, Position, Parent, RelativePosition, OffsetX, OffsetY, Texture, TexCoord1, TexCoord2, TexCoord3, TexCoord4
	-- @TODO: Heck, re-do this monstrosity
	local Textures = {
		[1] = {"Tex", "", Location, 750, 30, "TOP", self.F, "TOP", 0, 0, BAR_TEXTURE, 0, 1, 0, 1},
		[2] = {"Tex", "Left", Location, 60, 60, "TOPLEFT", "Location.Tex", "TOPLEFT", -60, 0, LOCATIONPANEL_EDGE_TEXTURE, 0, 1, 0, 1},
		[3] = {"Tex", "Right", Location, 60, 60, "TOPRIGHT", "Location.Tex", "TOPRIGHT", 60, 0, LOCATIONPANEL_EDGE_TEXTURE, 1, 0, 0, 1},
		
		[4] = {"", "Center", EdgeBottom, GetScreenWidth() - (140 * 2), 15, "BOTTOM", self.F, "BOTTOM", 0, 0, BAR_SMALL_TEXTURE, 0, 1, 0, 1},
		[5] = {"", "Left", EdgeBottom, 140, 200, "BOTTOMLEFT", self.F, "BOTTOMLEFT", 0, -1, EDGETILE_BOTTOM_TEXTURE, 0, 1, 0, 1},
		[6] = {"", "Right", EdgeBottom, 140, 200, "BOTTOMRIGHT", self.F, "BOTTOMRIGHT", 0, -1, EDGETILE_BOTTOM_TEXTURE, 1, 0, 0, 1},
	}
	
	
	for k, v in ipairs(Textures) do
		local Path
		local Next = ""
		
		if v[1] ~= "" then
			if v[2] ~= "" then
				Path = v[3][v[1]]
				Next = v[2]
			else
				Path = v[3]
				Next = v[1]
			end
		else
			if v[2] ~= "" then
				Path = v[3]
				Next = v[2]
			else
				Path = v[3]
			end
		end
		
		if Next ~= "" then
			Path[Next] = v[3]:CreateTexture(nil, "BACKGROUND")
			Path = Path[Next]
		else
			Path = v[3]:CreateTexture(nil, "BACKGROUND")
		end
		
		if type(v[7]) == "string" then
			local Parts
			for _, part in ipairs(E:FullSplit(v[7], ".")) do
				if not Parts then
					Parts = _G[part]
				else
					Parts = Parts[part]
				end
			end
			
			v[7] = Parts
		end
		
		Path:SetTexture(v[11])
		Path:SetSize(v[4], v[5])
		Path:SetPoint(v[6], v[7], v[8], v[9], v[10])
		Path:SetTexCoord(v[12], v[13], v[14], v[15])
		Path:SetVertexColor(0.8, 0.8, 0.8)
		Path:SetBlendMode("Blend")
		Path:SetAlpha(1)
	end
	
	self.EdgeBottom = EdgeBottom
	self.Location = Location
	
	FontInit = function(Object, Parent, SubParent, FontSize, Point, Offset)
		local Instance = LT[Parent]
		if SubParent ~= "" then
			Instance = LT[Parent][SubParent]
		end
		
		Instance[Object] = LT.F.Overlay:CreateFontString(nil, "ARTWORK")
		E:InitializeFontFrame(Instance[Object], "ARTWORK", nil, FontSize, {0.8,0.8,0.8}, 1, {0,0}, "", 0, 0, LT.F.Overlay, Point, {1,1})
		Instance[Object]:ClearAllPoints()
		if Parent == "Location" then
			Instance[Object]:SetPoint(Point, LT.F.Overlay, Point, Offset[1], Offset[2])
		elseif Parent == "EdgeBottom" then
			Instance[Object]:SetPoint(Point, LT.F.Overlay, Point, Offset[1], Offset[2])
			if SubParent == "Left" then
				Instance[Object]:SetJustifyH("LEFT")
			else
				Instance[Object]:SetJustifyH("RIGHT")
			end
		end
		
		if Object == "Zone" then
			E:RegisterPathFont(Instance[Object], "db.profile.layout." .. string.lower(Object), {["fontColor"] = true})
		else
			E:RegisterPathFont(Instance[Object], "db.profile.layout." .. string.lower(Object))
		end
	end
	for k,v in pairs(DataFonts) do
		FontInit(k, v[1],v[2],v[3],v[4],v[5])
	end
	
	Location:RegisterEvent("ZONE_CHANGED")
	Location:RegisterEvent("ZONE_CHANGED_INDOORS")
	Location:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	Location:SetScript("OnEvent", function(self, event, ...)
		LT:UpdateLocationZone()
	end)
	self.F:SetScript("OnUpdate", self.FontFrames_OnUpdate)
	
	self.Location.Zone.Button = CreateFrame("Button")
	self.Location.Zone.Button:SetAllPoints(self.Location.Zone)
	self.Location.Zone.Button:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
		
		LT:SetZoneTooltipData()
		
		GameTooltip:Show()
		
		TT:UpdateStyle()
	end)
	self.Location.Zone.Button:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	
	
	self:UpdateLocationZone()
end

local ColorizedReturn = 0
local ColorizedPing = {[0] = "FF2ded4d", [75] = "FFe3b034", [150] = "FFea2020"}
local ColorizedFPS = {[0] = "FFea2020", [25] = "FFe3b034", [45] = "FF2ded4d"}
function LT:GetColorized(type, value)
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

function LT:UpdateSystemValues()
	if self.db.fps.enable then
		self.EdgeBottom.Left.Fps:SetText("FPS: " .. self:GetColorized("fps", GetFramerate()))
	end
	
	if self.db.ping.enable then
		self.EdgeBottom.Right.Ping:SetText("Ping: " .. self:GetColorized("ping", select(3, GetNetStats())))
	end
end

local LocationCoordPosX, LocationCoordPosY
function LT:UpdateLocationCoords()
	if not self.db.coordx.enable and not self.db.coordy.enable then return end
	
	LocationCoordPosX, LocationCoordPosY = HBD:GetPlayerZonePosition()
	
	if LocationCoordPosX and LocationCoordPosY then
		
		if (LocationCoordPosX and LocationCoordPosY) and LocationCoordPosX ~= LastPlayerCoordinates["x"] or LocationCoordPosY ~= LastPlayerCoordinates["y"] then
		
			self.Location.CoordX:SetText(format("%.2f",	LocationCoordPosX * 100))
			self.Location.CoordY:SetText(format("%.2f",	LocationCoordPosY * 100))
			
			LastPlayerCoordinates["x"] = LocationCoordPosX
			LastPlayerCoordinates["y"] = LocationCoordPosY
		end
	else
		self.Location.CoordX:SetText("")
		self.Location.CoordY:SetText("")
	end
end

function LT:UpdateLocationZone()
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
	
	self.Location.Zone:SetTextColor(unpack(Color))
	
	if self.CurrentZone == self.CurrentSubZone or self.CurrentSubZone == "" then
		self.Location.Zone:SetText(format("%s",self.CurrentZone))
	else
		self.Location.Zone:SetText(format("%s, %s",self.CurrentZone, self.CurrentSubZone))
	end
end

function LT:UpdateDB()
	self.db = E.db.layout
	self.sysdb = E.db.system
end
function LT:Init()
	
	self:UpdateDB()
	ClassColor = E:GetUnitClassColor("player")
	
	
	self.F:SetAllPoints(E.Parent)
	self.F.Overlay:SetAllPoints(self.F)
	
	self:InitDataPanels()
	
	self.Frames = {
		["enableTop"] = {
			Location,
		},
		["enableBottom"] = {
			self.EdgeBottom.Center,
		},
		["enableBottomLeft"] = {
			self.EdgeBottom.Left,
		},
		["enableBottomRight"] = {
			self.EdgeBottom.Right,
		},
	}
	
	self:LoadProfile()
end

E:AddModule("Layout", LT)