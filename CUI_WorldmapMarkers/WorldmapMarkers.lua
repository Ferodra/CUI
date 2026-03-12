local E, L = unpack(CUI) -- Engine
local WMM = select(2, ...)
local CO, TT = E:LoadModules("Config", "Tooltip")

WMM.Autoload = true

local DDM = LibStub("DropDownModify-1.0")
local SkipRaids = E.ClientBuildRevision >= 80300

WMM.CurrentContinent, WMM.CurrentZone, WMM.MapInfo = nil, nil, nil
WMM.Buttons = {}
WMM.ButtonSize = 32
WMM.TexturePath = [[Interface\AddOns\CUI_WorldmapMarkers\Textures\worldmap\]]

-- We use this to check if the zone has been changed.
-- Our update event is a hook of the WorldMapFrame:OnMapChanged method
WMM.LastZone = -1
WMM.Canvas = nil

function WMM:UpdateCurrentZone()
	self.CurrentZone	= WorldMapFrame:GetMapID()
end

function WMM:SetEntranceTexture(object, instanceType, markerType)
	if type(markerType) ~= "string" then
		if instanceType == true then
			object:SetTexture(self.TexturePath .. "raid")
		else
			object:SetTexture(self.TexturePath .. "dungeon")
		end
	else
		if markerType == "floorUp" then
			object:SetTexture(self.TexturePath .. "door_up")
		elseif markerType == "floorDown" then
			object:SetTexture(self.TexturePath .. "door_down")
		elseif markerType == "floorLeft" then
			object:SetTexture(self.TexturePath .. "door_left")
		elseif markerType == "floorRight" then
			object:SetTexture(self.TexturePath .. "door_right")
		else
			object:SetTexture(self.TexturePath .. "door")
		end
	end
end

function WMM:GetMapScale()
	return WorldMapFrame:GetCanvasScale()
end

function WMM:GetMapZoom()
	return WorldMapFrame:GetCanvasZoomPercent()
end

function WMM:OverridePinScale()
	local CanvasSize = self:GetMapScale()
	
	local parentScaleFactor = 1.0 / CanvasSize
	local Scale = (parentScaleFactor * Lerp(0.8, 1, Saturate(1 * self:GetMapZoom()))) or 1
	
	for k, v in pairs(self.Buttons) do
		for _, f in pairs(v) do
			WMM:SetPinScaleFactor(f, Scale)			
		end
	end
end

function WMM:SetPinScaleFactor(Pin, Scale)
	Pin:SetScale(Scale)
	
	local Canvas = WorldMapFrame:GetCanvas()
	Pin:SetPoint("CENTER", Canvas, "TOPLEFT", (Canvas:GetWidth() * Pin.NormalizedCoordX) / Scale, -(Canvas:GetHeight() * Pin.NormalizedCoordY) / Scale);
end

local function Button_OnEnter(self)
	WorldMapFrame:TriggerEvent("SetAreaLabel", MAP_AREA_LABEL_TYPE.POI, self.instanceName, self.description)
end
local function Button_OnLeave(self)
	WorldMapFrame:TriggerEvent("ClearAreaLabel", MAP_AREA_LABEL_TYPE.POI)
end
local function Pin_OnClick(self)
	EncounterJournal_LoadUI()
	EncounterJournal_OpenJournal(nil, self.InstanceID)
end
local function Navigate_OnClick(self)
	WorldMapFrame:SetMapID(self.NavigationTarget)
end

function WMM:CreateButton(InstanceName, InstancePosX, InstancePosY, InstanceNameOverride, NavigationTarget, IstanceID, isRaid)
	if not self.Canvas then return end
	
	Button = CreateFrame("Button", nil, self.Canvas)
	Button.BaseSize = self.ButtonSize
	
	
	Button.CoordX, Button.CoordY = InstancePosX, InstancePosY
	Button.NormalizedCoordX, Button.NormalizedCoordY = InstancePosX / 100, InstancePosY / 100
	Button:SetSize(self.ButtonSize, self.ButtonSize)
	Button:SetPoint("CENTER", self.Canvas, "TOPLEFT", ((InstancePosX / 100) * self.mapWidth) - (self.ButtonSize / 2), -(((InstancePosY / 100) * self.mapHeight) - (self.ButtonSize / 2)))
	Button:SetFrameStrata("HIGH")
	Button:RegisterForClicks('AnyUp')
	
	if not InstanceNameOverride then
		Button.instanceName = InstanceName
	else
		Button.instanceName = string.format("%s: %s", InstanceName, InstanceNameOverride)
	end
	Button.isRaid = isRaid
	Button.InstanceID = IstanceID
	
	if Button.isRaid == true then
		Button.description = RAID
	elseif Button.isRaid == false then
		Button.description = CALENDAR_TYPE_DUNGEON
	else
		Button.description = ""
	end
	
	-- Use Area label system
	Button:SetScript("OnEnter", Button_OnEnter)
	Button:SetScript("OnLeave", Button_OnLeave)
	
	
	-- NAVIGATION TO OTHER AREA
	Button.NavigationTarget = NavigationTarget
	-- ONCLICK HANDLERS
	Button:SetScript("OnClick", NavigationTarget and Navigate_OnClick or Pin_OnClick)
	
	
	Button.Icon = Button:CreateTexture(Button, "BACKGROUND")
	Button.Icon:SetPoint("CENTER", Button, "CENTER")
	Button.Icon:SetScale(1.1)
	
	Button.Icon:SetParent(Button)
	
		self:SetEntranceTexture(Button.Icon, isRaid, IstanceID)
	
	Button.Icon:SetTexCoord(0, 1, 0, 1)
	
	Button:SetHighlightTexture("Interface/WorldMap/UI-QuestPoi-NumberIcons");
	Button:GetHighlightTexture():SetTexCoord(0.625, 0.750, 0.875, 1);
	
	return Button
end

function WMM:__Update(self, event, ...)
	
	if not self.EnableTracking then return end
	
	self:UpdateCurrentZone()
	
	if not self.CurrentZone then return end
	if self.LastZone == self.CurrentZone then return end
	
	self.mapWidth 	= WorldMapFrame.ScrollContainer.Child:GetWidth()
	self.mapHeight 	= WorldMapFrame.ScrollContainer.Child:GetHeight()
	self.Canvas 	= WorldMapFrame:GetCanvas()
	
	E:debugprint("Zone: " .. self.CurrentZone)
	
	self:HideAll()
	
	if self.Markers.Instances[self.CurrentZone] then
		for k, instance in pairs(self.Markers.Instances[self.CurrentZone]) do
			if type(instance) == "table" then
				local InstanceInfo
				local CurrentType = type(instance[1])
				
				if CurrentType ~= "string" then
					InstanceInfo = { EJ_GetInstanceInfo(instance[1]) }
				end
				
				
				if CurrentType == 'string' then
				--if (SkipRaids and (CurrentType == 'string' or not instance[2])) or not SkipRaids then
					--if (InstanceInfo and InstanceInfo[1]) or CurrentType) == "string" then
						
						local InstanceName, InstancePosX, InstancePosY, InstanceNameOverride, NavigationTarget, IstanceID, isRaid
						
						if CurrentType ~= "string" then
							InstanceName 			= InstanceInfo[1]
							-- self.currentInstanceDesc 	= self.currentInstanceInfo[2]
							InstancePosX			= instance[3]
							InstancePosY 			= instance[4]
							InstanceNameOverride	= instance[5]
							NavigationTarget 		= nil
						else
							InstanceName 			= instance[2]
							-- self.currentInstanceDesc 	= self.currentInstanceInfo[2]
							InstancePosX 			= instance[3]
							InstancePosY 			= instance[4]
							InstanceNameOverride	= nil
							NavigationTarget		= instance[5]
						end
						
						isRaid = instance[2]
						InstanceID = instance[1]
						
						if not self.Buttons[self.CurrentZone] then self.Buttons[self.CurrentZone] = {} end
						
						local Button = self.Buttons[self.CurrentZone][k]
						
						if Button then
							Button:Show()
						else
							self.Buttons[self.CurrentZone][k] = self:CreateButton(InstanceName, InstancePosX, InstancePosY, InstanceNameOverride, NavigationTarget, InstanceID, isRaid)
						end
					--end
				end
			end
		end
	end
	
	self.LastZone = self.CurrentZone
end

function WMM:HideAll()
	for k, v in pairs(self.Buttons) do
		for _, f in pairs(v) do
			f:Hide()
		end
	end
end

function WMM:UpdateState(name, forceUpdate)
	if forceUpdate then
		name = 'showDungeonEntrancesOnMap'
	end
	if name ~= 'showDungeonEntrancesOnMap' then return end
	
	self.EnableTracking = GetCVarBool(name)
	
	-- Actually update state
	if not self.EnableTracking then
		WMM:HideAll()
	else
		WMM.LastZone = -1
		WMM:__Update(WMM)
	end
end

function WMM:InitMarkers()
	
	WMM:UpdateState(nil, true)
	
	hooksecurefunc(WorldMapFrame, "OnMapChanged", function() 
		WMM:__Update(WMM)
	end)
	
	hooksecurefunc(WorldMapFrame, "OnCanvasScaleChanged", function()		
		WMM:OverridePinScale()
	end)
	
	hooksecurefunc("SetCVar", function(name)
		WMM:UpdateState(name)
	end)
	
	
	-- -- Manipulating the tracking dropdown
	-- self.TrackingMenu = nil
	
	-- for k,v in pairs(WorldMapFrame.overlayFrames) do
		-- -- Since it's the only overlayFrame with a dropdown, this is simple
		-- if v.DropDown then
			-- self.TrackingMenu = v
		-- end
	-- end
	
	-- WMM.DropdownMod = DDM:RegisterMod(self.TrackingMenu.DropDown, function()
	
		-- UIDropDownMenu_AddSeparator();

		-- local info = UIDropDownMenu_CreateInfo();
		
		-- info.isTitle = true;
		-- info.notCheckable = true;
		-- info.text = "|cff00ccffCUI|r";
		-- UIDropDownMenu_AddButton(info);

		-- info.isTitle = nil;
		-- info.disabled = nil;
		-- info.notCheckable = nil;
		-- info.isNotRadio = true;
		-- info.keepShownOnClick = true;
		-- info.func = OnSelection;
		
		-- info.isTitle = nil;
		-- info.disabled = nil;
		-- info.notCheckable = nil;
		-- info.isNotRadio = true;
		-- info.keepShownOnClick = true;
		-- info.text = "Worldmap Markers";
		-- info.value = "CUIShowWorldmapMarkers";
		-- info.checked = CO.db.global.worldmapMarkersDungeonsEnableTracking
		-- info.func = WMM.OnDropdownSelection;
		-- UIDropDownMenu_AddButton(info);
	-- end, 1)
end

function WMM:OnEvent(event, ...)
	if event == "ADDON_LOADED" then
		if ... == "CUI" then
			self:InitMarkers()
		end
	
		return
	end
	self:__Update(self, event, ...)
end

function WMM:Init()
	self.db = CO.db.profile.worldmap
	
	-- We have to use this in BfA to retrieve the current map id
	-- /dump WorldMapFrame:GetMapID()
	
	-- local Defaults = {
		-- ["global"] = {
			-- ["worldmapMarkersDungeonsEnableTracking"] = true,
		-- },
	-- }
	
	-- CO:AddToDefaults(Defaults)
	
	if not IsAddOnLoaded("CUI") then
		self:RegisterEvent("ADDON_LOADED")
	else
		self:InitMarkers()
		
		return
	end
	self:SetScript("OnEvent", self.OnEvent)
end

E:AddModule("WorldmapMarkers", WMM)