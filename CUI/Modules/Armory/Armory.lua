local E, L = unpack(select(2, ...)) -- Engine, Locale
local Module, CO = E:LoadModules("Armory", "Config")
Module.Autoload = true

local _G = _G
local ModelFrame, CharacterFrame, CharacterFrameInset, CharacterMainHandSlot, CharacterStatsPane, TitleManagerPane, EquipmentManagerPane

Module.Modules = {}
Module.SlotInfo = {}
Module.SlotInfoFrames = {}
Module.SlotInfoFontData = {
	["Head"] 		= {1, "RIGHT"},
	["Neck"] 		= {2, "RIGHT"},
	["Shoulder"] 	= {3, "RIGHT"},
	["Back"] 		= {15, "RIGHT"},
	["Chest"] 		= {5, "RIGHT"},
	["Shirt"] 		= {4, "RIGHT"},
	["Tabard"] 		= {19, "RIGHT"},
	["Wrist"] 		= {9, "RIGHT"},
	["Hands"] 		= {10, "LEFT"},
	["Waist"] 		= {6, "LEFT"},
	["Legs"] 		= {7, "LEFT"},
	["Feet"] 		= {8, "LEFT"},
	["Finger0"] 	= {11, "LEFT"},
	["Finger1"] 	= {12, "LEFT"},
	["Trinket0"] 	= {13, "LEFT"},
	["Trinket1"] 	= {14, "LEFT"},
	["MainHand"] 	= {16, "LEFT"},
	["SecondaryHand"] = {17, "RIGHT"},
}
-- Possible Inventory Types
-- This basically maps the Inventory Types to Slots
-- Type => Slot
Module.ItemInvTypeToSlot = {
	["INVTYPE_HEAD"] = {1},
	["INVTYPE_NECK"] = {2},
	["INVTYPE_SHOULDER"] = {3},
	["INVTYPE_BODY"] = {4},
	["INVTYPE_CHEST"] = {5},
	["INVTYPE_ROBE"] = {5},
	["INVTYPE_WAIST"] = {6},
	["INVTYPE_LEGS"] = {7},
	["INVTYPE_FEET"] = {8},
	["INVTYPE_WRIST"] = {9},
	["INVTYPE_HAND"] = {10},
	["INVTYPE_FINGER"] = {11, 12},
	["INVTYPE_TRINKET"] = {13, 14},
	["INVTYPE_CLOAK"] = {15},
	["INVTYPE_WEAPON"] = {16, 17},
	["INVTYPE_SHIELD"] = {17},
	["INVTYPE_2HWEAPON"] = {16},
	["INVTYPE_WEAPONMAINHAND"] = {16},
	["INVTYPE_WEAPONOFFHAND"] = {17},
	["INVTYPE_HOLDABLE"] = {17},
	["INVTYPE_RANGED"] = {18},
	["INVTYPE_THROWN"] = {18},
	["INVTYPE_RANGEDRIGHT"] = {18},
	["INVTYPE_RELIC"] = {18},
	["INVTYPE_TABARD"] = {19},
}


function Module:UpdateOverallItemlevelText(Type, Unit)
	if not CO.db.global.customArmory.showItemlevel then
		return
	end
	
	local TargetFrame
	-- Temporary until the blizz code is consistent here
	if not Type then
		TargetFrame = _G["CharacterModelScene"]
	elseif Type == "Inspect" then
		TargetFrame = _G["InspectModelFrame"]
	end
	
	if TargetFrame then
		if not TargetFrame.OverallItemlevel then
			local OverallIlvl = CreateFrame("Frame", "CUI_OverallItemlevelFrame", TargetFrame)
			OverallIlvl:SetSize(200, 15)
			OverallIlvl:ClearAllPoints()
			OverallIlvl:SetPoint('TOP', TargetFrame, 'TOP', 0, -2)
			
			local Font = E:NewFontObject(nil, "ARTWORK", OverallIlvl, 10)
			Font:SetJustifyH('CENTER')
			Font:SetAllPoints(OverallIlvl)
			
			TargetFrame.OverallItemlevel = OverallIlvl
			TargetFrame.OverallItemlevel.Text = Font
		end
		
		if UnitExists(Unit) then
			TargetFrame.OverallItemlevel.Text:SetTextColor(unpack(E:GetUnitClassColor(Unit)))
			TargetFrame.OverallItemlevel.Text:SetText(select(2, Module.Modules["OverallItemlevel"]:GetInfo(Unit)))
			--print("Setting Text", TargetFrame.OverallItemlevel, TargetFrame.OverallItemlevel.Text, TargetFrame.OverallItemlevel:IsVisible(), TargetFrame.OverallItemlevel.Text:IsVisible())
		else
			TargetFrame.OverallItemlevel.Text:SetText('')
		end
	end
end

-- Needed: Ilvl, Enchant
function Module:CreateSlotInfo(Type)
	Type = Type or "Character"
	
	local Slot, SlotInfoName
	
	for name, data in pairs(self.SlotInfoFontData) do
		Slot = _G[string.format("%s%sSlot", Type, name)]
		SlotInfoName = Type .. name
		
		-- If Slot exists
		if Slot and not self.SlotInfo[SlotInfoName] then
			self.SlotInfo[SlotInfoName] = CreateFrame("Frame", nil, Slot)
			self.SlotInfo[SlotInfoName]:SetSize(64, 40)
			self.SlotInfo[SlotInfoName]:SetPoint(E:InversePosition(data[2]), Slot, data[2], (data[2] == "RIGHT") and 3 or -3, 0)
			
			self.SlotInfo[SlotInfoName].Name = SlotInfoName
			self.SlotInfo[SlotInfoName].Slot = data[1]
			self.SlotInfo[SlotInfoName].Align = data[2]
			
			self:CreateSlotInfoFonts(self.SlotInfo[SlotInfoName])
			self:CreateBackground(self.SlotInfo[SlotInfoName])
		end
	end
end

local function CreateGemSlots(InfoFrame, CurrentName)
	
	Module.SlotInfoFrames[CurrentName].Gems = {}
	Module.SlotInfoFrames[CurrentName].Gems.Parent = InfoFrame
	
	local GemParent = CreateFrame("Frame", nil, InfoFrame)
	GemParent:SetAllPoints(InfoFrame)
	Module.SlotInfo[CurrentName]["gems"] = GemParent
	
	for Index=1, MAX_NUM_SOCKETS do
		local GemSlot = CreateFrame("Button", ("CUI_SlotGemInfo%s_%s"):format(CurrentName, Index), GemParent)
		Module.SlotInfoFrames[CurrentName].Gems[Index] = GemSlot
		
		GemSlot:EnableMouse(true)
		GemSlot:SetScript("OnEnter", Module.Modules["Gems"].Slot_OnEnter)
		GemSlot:SetScript("OnLeave", Module.Modules["Gems"].Slot_OnLeave)
		GemSlot:SetScript("OnClick", Module.Modules["Gems"].Slot_OnClick)
		
		GemSlot.Parent = InfoFrame
		GemSlot.VisibilityParent = GemParent
		GemSlot:SetSize(12, 12)
		GemSlot.Background = E:CreateBackground(GemSlot)
		GemSlot.Border = E:CreateBorder(GemSlot)
		
		local Position = "BOTTOM" .. E:InversePosition(InfoFrame.Align)
		local Prefix = (InfoFrame.Align == "RIGHT") and 1 or -1
		GemSlot:SetPoint(Position, InfoFrame, Position, ((12 * Index) + (2 * (Index - 1))) * Prefix, 2)
		
		GemSlot.Tex = GemSlot:CreateTexture(nil, "OVERLAY")
		GemSlot.Tex:SetAllPoints(GemSlot)
		
		GemSlot:Hide()
	end
end

local ArmoryFonts = {"ilvl", "enchant"}
function Module:CreateSlotInfoFonts(InfoFrame)
	
	local CurrentName = InfoFrame.Name
	local FontSize = 10
	local CurrentOffset = 0
	local Font
	
	if not Module.SlotInfoFrames[CurrentName] then Module.SlotInfoFrames[CurrentName] = {} end
	
	for index, name in pairs(ArmoryFonts) do
		if (name == "enchant") or (name == "ilvl") then
			if name == "ilvl" then
				CurrentOffset = FontSize
			else
				CurrentOffset = 0
			end
			
			Font = InfoFrame:CreateFontString(nil, "ARTWORK")
			Module.SlotInfoFrames[CurrentName][name] = Font
			InfoFrame[name] = Font
			
			-- We're using this method to directly set offsets and alignments in one go
			E:InitializeFontFrame(Font, "ARTWORK", nil, FontSize, {0.8,0.8,0.8}, 1, {(InfoFrame.Align == "RIGHT") and 12 or -12, CurrentOffset}, "", 0, 0, InfoFrame, E:InversePosition(InfoFrame.Align), {0,0}, "OUTLINE")
			Font:SetJustifyH(E:InversePosition(InfoFrame.Align))
			Font:SetSize(80, 15)
			
			Font.Parent = InfoFrame
		end
	end
	
	if CO.db.global.customArmory.showGems then		
		-- Gems
		CreateGemSlots(InfoFrame, CurrentName)
	end
end

function Module:CreateBackground(F)
	E:CreateTextureObject(F, "Background", "BACKGROUND")
	F.Background:SetTexture([[Interface/AddOns/CUI/Textures/layout/InspectInfoBackground]])
	
	F.Background:SetAlpha(0.45)
	--F.Background:SetVertexColor(0.09, 0.51, 0.81)
	F.Background:SetVertexColor(0.450, 0.580, 0.807)
	
	if F.Align == "LEFT" then
		F.Background:SetTexCoord(1, 0, 0, 1)
	else
		F.Background:SetTexCoord(0, 1, 0, 1)
	end
end

function Module:UpdateBackground(Background, State)
	if Background.IsStateLocked then return end
	
	if State then
		Background:Show()
	else
		Background:Hide()
	end
end

local function GetGemQualityColor(Quality)
	local ColorR, ColorG, ColorB = GetItemQualityColor(Quality)
	return ColorR, ColorG, ColorB
end

function Module:UpdateData(Unit, Type)
	
	if not CO.db.global.customArmory.enabled then return end
	
	Type = Type or "Character"
	
	-- Contains: SlotID, Alignment
	local Slot, ItemLink, ItemLevel, ItemRarity, Enchant, RarityColor, RarityColorHex,
	AllFontsEmpty, LastFont
	
	for slotInfoName, fonts in pairs(Module.SlotInfoFrames) do
		if (slotInfoName):find(Type) then
			AllFontsEmpty = true
			
			for name, frame in pairs(fonts) do
				Slot = frame.Parent.Slot
				ItemLink = GetInventoryItemLink(Unit or "player", Slot)
				
				if name ~= "Gems" then
					-- Post-set shadow color, since it's just a pain
					frame:SetShadowColor(0, 0, 0)
					
					if ItemLink ~= nil and ItemLink ~= "" then
						AllFontsEmpty = false
					end
					if frame.ItemLink ~= ItemLink then
						frame.ItemLink = ItemLink
						
						if name == "ilvl" then
							local Text, Color = Module.Modules["Itemlevel"]:GetInfo(ItemLink)
							
							if Text ~= "" then AllFontsEmpty = false end
							frame.HasData = Text ~= "";
							frame:SetText(Text)
						elseif name == "enchant" then
							local Text, IsEnchanted = Module.Modules["Enchant"]:GetInfo(ItemLink)
							
							if Text ~= "" then AllFontsEmpty = false end
							frame.HasData = Text ~= "";
							frame:SetText(Text)
						end
					end
					
					-- To access the parent
					LastFont = frame
				else
					local Holder = frame[1].VisibilityParent
					Holder.HasData = false
					
					if ItemLink then
						local Gems = Module.Modules["Gems"]:GetInfo(ItemLink)
						local GemSlot, GemSlotFrame
						
						-- GEMS
						for i = 1, MAX_NUM_SOCKETS do
							GemData = Gems[i]
							GemSlotFrame = frame[i]
							
							if GemData.isEmpty ~= nil then
								-- GEM SLOT EXISTS
								GemSlotFrame.Tex:SetTexture(GemData.Texture)
								GemSlotFrame.GemLink 	= GemData.GemLink
								GemSlotFrame.GemQuality = GemData.GemQuality
								
								if GemSlotFrame.GemQuality then
									GemSlotFrame.Border:SetBackdropBorderColor(GetGemQualityColor(GemSlotFrame.GemQuality))
									GemSlotFrame.Border:Show()
								else
									GemSlotFrame.Border:Hide()
								end
								
								GemSlotFrame:Show()
								Holder.HasData = true
							else
								GemSlotFrame.GemLink = nil
								
								GemSlotFrame:Hide()
							end
						end
					else
						for i = 1, MAX_NUM_SOCKETS do
							frame[i]:Hide()
						end
					end
				end
			end
			
		end
		
		if LastFont then
			if AllFontsEmpty then
				Module:UpdateBackground(LastFont.Parent.Background, false)
			else
				Module:UpdateBackground(LastFont.Parent.Background, true)
			end
		end
	end
end

function Module:UpdateCamera()		
	if not Module.AlteredModelFrame then
		
		local function OnMouseWheel(self, delta, maxZoom, minZoom)				
			maxZoom = maxZoom or self.maxZoom;
			minZoom = minZoom or self.minZoom;
			local zoomLevel = self.zoomLevel or minZoom;
			zoomLevel = zoomLevel + delta * MODELFRAME_ZOOM_STEP;
			zoomLevel = min(zoomLevel, maxZoom);
			zoomLevel = max(zoomLevel, minZoom);
			
			if not self.interpolateZoom then
				self:SetPortraitZoom(zoomLevel);
				self.zoomLevel = zoomLevel
			else
				self.zoomElapsed = 0
				self.startZoomLevel = self.zoomLevel
				self.targetZoomLevel = zoomLevel
				self.zoomFinished = nil
			end
			
		end
		
		local InterpolationTargetTime = 0.125 -- 0.1 Second animation
		local function OnUpdate(self, elapsed)				
			-- Interpolate Zoom
			if self.interpolateZoom then
				if self.zoomFinished then return end
				
				self.zoomElapsed = (self.zoomElapsed or 0) + elapsed
				local NewZoom = self.startZoomLevel + ((self.targetZoomLevel - self.startZoomLevel) / (InterpolationTargetTime)) * (self.zoomElapsed)
				
				if NewZoom > 0 and NewZoom < 1 and (abs(NewZoom - self.targetZoomLevel) > 0) then
					self.zoomLevel = NewZoom
					self:SetPortraitZoom(NewZoom)
				end
				
				if self.zoomElapsed >= InterpolationTargetTime then
					self.zoomElapsed = 0
					self.zoomFinished = true
				end
				
			end
		end
		
		ModelFrame.interpolateZoom = true
		
		ModelFrame.OnMouseWheel = OnMouseWheel
		ModelFrame:SetScript('OnMouseWheel', OnMouseWheel)
		ModelFrame.OnUpdate = OnUpdate
		ModelFrame:HookScript('OnUpdate', OnUpdate)
		
		Module.AlteredModelFrame = true
	end
	
	ModelFrame:SetPortraitZoom(0)
	ModelFrame.zoomElapsed = 0
	ModelFrame.zoomLevel = 0
	ModelFrame.startZoomLevel = ModelFrame.zoomLevel
	ModelFrame.targetZoomLevel = ModelFrame.zoomLevel
end

local types = {"ilvl", "enchant", "gems"}
local function ToggleInfo_Single(type, state)
	local Object
	
	for k, info in pairs(Module.SlotInfo) do
		Object = info[type]
		
		if Object then			
			if state then
				Object:Show()
			else
				Object:Hide()
			end
		end		
	end
end

function Module:ToggleInfo_UpdateBackground()
	local AllEmpty, Object
	
	for k, info in pairs(Module.SlotInfo) do
		AllEmpty = true
		
		for _, typeName in pairs(types) do
			Object = info[typeName]
			
			if Object then
				if Object:IsVisible() and Object.HasData then
					AllEmpty = false
				end
			end
		end
		
		if AllEmpty then
			info.Background.IsStateLocked = true
			info.Background:Hide()
		else
			info.Background.IsStateLocked = false
			info.Background:Show()
		end
	end
end

function Module:ToggleInfo(type, state)
	type = type or "all"
	if type == "all" then
		for _, name in pairs(types) do
			ToggleInfo_Single(name, state)
		end
	else
		ToggleInfo_Single(type, state)
	end
	
	self:ToggleInfo_UpdateBackground()
end

function Module:CacheVariables()
	-- Globals
	ModelFrame, CharacterFrame, CharacterFrameInset, CharacterMainHandSlot, CharacterStatsPane, TitleManagerPane, EquipmentManagerPane = _G["CharacterModelScene"],_G["CharacterFrame"],_G["CharacterFrameInset"],_G["CharacterMainHandSlot"],_G["CharacterStatsPane"],_G["TitleManagerPane"],_G["EquipmentManagerPane"]
end

function Module:CacheOriginalState()
	if self.HasValidStateCache then return end
	
	-- Measurements
	CharacterFrame.OriginalWidth = CharacterFrame:GetWidth()
	
	-- Points
	local _, _, _, OffsetX = CharacterFrameInset:GetPoint(2)
	CharacterFrameInset.OriginalOffset = OffsetX
	
	self.HasValidStateCache = true
end

function Module:UpdatePanel()
	--if not CO.db.global.customArmory.enabled then return end
	
	if ModelFrame:IsVisible() then
		Module:CacheOriginalState()
		
		if CO.db.global.customArmory.enabled then
			-- Those values are used to RESIZE the panel when 
			CharacterFrame:SetWidth(610)
			CharacterFrameInset:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMLEFT", 400, 4)
			
			Module:CreateInfo()
			Module:UpdateData()
			Module:UpdateInfoStates()
		else
			CharacterFrame:SetWidth(CharacterFrame.OriginalWidth)
			CharacterFrameInset:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMLEFT", CharacterFrameInset.OriginalOffset, 4)
			
			Module:ToggleInfo("all", false)
		end

		-- Idk why this is shown when we open the panel
		if CharacterModelScene and CharacterModelScene:IsVisible() and CharacterModelScene.ControlFrame then
			CharacterModelScene.ControlFrame:Hide()
		end
	end
	
	-- We don't have to handle size change due to changing to another tab, as blizz already takes care of that
end

-- self = PaperDollFrame
function Module:CreateInfo()	
	CharacterMainHandSlot:ClearAllPoints()
	CharacterMainHandSlot:SetPoint('BOTTOM', CharacterFrameInset, 'BOTTOM', -(CharacterMainHandSlot:GetWidth() / 2), 10)

	ModelFrame:ClearAllPoints()
	ModelFrame:SetPoint('TOPLEFT', CharacterFrameInset, "TOPLEFT", 32, -5)
	ModelFrame:SetPoint('BOTTOMRIGHT', CharacterFrameInset, "BOTTOMRIGHT", -32, 28)
	
	Module:CreateSlotInfo()
	
	--Module:OverridePanelBackground(ModelFrame, Config.overrideBackground, Config.useCustomBackground, Config.customBackgroundPath, Config.classBackground)
end

local BackgroundRegions = {"BackgroundTopLeft", "BackgroundTopRight", "BackgroundBotLeft", "BackgroundBotRight", "BackgroundOverlay"}
function Module:OverridePanelBackground(Frame, State, CustomTexture, CustomTexturePath, TextureUseClass)
	if not Frame then return end
	
	-- This overrides the default armory background based on player character class
	if State then
		for _, name in pairs(BackgroundRegions) do
			Frame[name]:Hide()
		end
		
		if not Frame.ModelBackground then
			Frame.ModelBackground = Frame:CreateTexture("ModelBackground", "BACKGROUND")
			Frame.ModelBackground:SetAllPoints(Frame)
		else
			Frame.ModelBackground:Show()
		end
		
		if CustomTexture then
			Frame.ModelBackground:SetTexture(CustomTexturePath)
		else
			if TextureUseClass == "PLAYER_CLASS" then
				TextureUseClass = E.PlayerClassName
			end
			
			Frame.ModelBackground:SetAtlas("dressingroom-background-" .. E:stringToLower(TextureUseClass))
		end
	else
		if Frame.ModelBackground then
			Frame.ModelBackground:Hide()
		end
		
		CharacterModelFrameBackgroundTopLeft:Show()
		CharacterModelFrameBackgroundTopLeft:ClearAllPoints()
		CharacterModelFrameBackgroundOverlay:ClearAllPoints()
		CharacterModelFrameBackgroundTopLeft:SetAllPoints(Frame)
		CharacterModelFrameBackgroundOverlay:SetAllPoints(Frame)
		CharacterModelFrameBackgroundBotLeft:Hide()
		CharacterModelFrameBackgroundBotRight:Hide()
	end
end

function Module:UpdateInfoStates()
	self:ToggleInfo("ilvl", CO.db.global.customArmory.enabled and CO.db.global.customArmory.showItemlevel)
	self:ToggleInfo("gems", CO.db.global.customArmory.enabled and CO.db.global.customArmory.showGems)
	self:ToggleInfo("enchant", CO.db.global.customArmory.enabled and CO.db.global.customArmory.showEnchants)
end

function Module:LoadConfig()
	
	self:SetScript("OnEvent", nil)
	
	if CO.db.global.customArmory.enabled then
		self:SetScript("OnEvent", self.UpdatePanel)
	end
	
	self:UpdatePanel()
	self:UpdateInfoStates()
	self:OverridePanelBackground(ModelFrame, CO.db.global.customArmory.enabled and CO.db.global.customArmory.overrideBackground, CO.db.global.customArmory.useCustomBackground, CO.db.global.customArmory.customBackgroundPath, CO.db.global.customArmory.classBackground)
end

function Module:__Construct()
	Module:CacheVariables()
	
	local EventFrames = {
		["CharacterFrame"] = {CharacterFrame, "OnShow", Module.UpdatePanel, "OnHide", Module.UpdatePanel},
		["CharacterStatsPane"] = {CharacterStatsPane, "OnShow", Module.CreateInfo, "OnHide", Module.UpdatePanel},
		["TitleManagerPane"] = {PaperDollFrame.TitleManagerPane, "OnShow", Module.UpdatePanel, "OnHide", Module.UpdatePanel},
		["EquipmentManagerPane"] = {PaperDollFrame.EquipmentManagerPane, "OnShow", Module.UpdatePanel, "OnHide", Module.UpdatePanel},	
	}
	
	--for k, v in pairs(EventFrames) do
	--	v[1]:HookScript(v[2], v[3])
	--	v[1]:HookScript(v[4], v[5])
	--end
	
	hooksecurefunc(CharacterFrame, "UpdateSize", Module.UpdatePanel)
	
	self:RegisterEvent("SOCKET_INFO_SUCCESS")
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:RegisterUnitEvent("UNIT_INVENTORY_CHANGED", "player")
	self:RegisterEvent("TRANSMOGRIFY_SUCCESS")
	self:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
	
	self:LoadConfig()
end

function Module:Init()
	self:__Construct()
end

E:AddModule("Armory", Module)