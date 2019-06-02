local E, L = unpack(select(2, ...)) -- Engine, Locale
local A, CO = E:LoadModules("Armory", "Config")
A.Autoload = true

A.Modules = {}
A.SlotInfo = {}
A.SlotInfoFrames = {}
A.SlotInfoFontData = {
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
A.ItemInvTypeToSlot = {
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

-- Needed: Ilvl, Enchant
function A:CreateSlotInfo(Type)
	Type = Type or "Character"
	
	local Slot, SlotInfoName
	
	for name, data in pairs(self.SlotInfoFontData) do
		Slot = _G[string.format(Type .. "%sSlot", name)]
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

local NeededFonts = {"ilvl", "enchant"}
function A:CreateSlotInfoFonts(InfoFrame)
	
	local CurrentName = InfoFrame.Name
	local FontSize = 10
	local CurrentOffset = 0
	local Font
	
	if not A.SlotInfoFrames[CurrentName] then A.SlotInfoFrames[CurrentName] = {} end
	
	for index, name in pairs(NeededFonts) do
		if (name == "enchant" and CO.db.profile.customArmoryShowEnchants) or (name == "ilvl" and CO.db.profile.customArmoryShowItemlevel) then
			if name == "ilvl" then
				CurrentOffset = FontSize
			else
				CurrentOffset = 0
			end
			
			Font = InfoFrame:CreateFontString(nil, "ARTWORK")
			A.SlotInfoFrames[CurrentName][name] = Font
			
			E:InitializeFontFrame(Font, "ARTWORK", nil, FontSize, {0.8,0.8,0.8}, 1, {(InfoFrame.Align == "RIGHT") and 12 or -12, CurrentOffset}, "", 0, 0, InfoFrame, E:InversePosition(InfoFrame.Align), {0,0}, "OUTLINE")
			Font:SetJustifyH(E:InversePosition(InfoFrame.Align))
			Font:SetSize(80, 15)
			
			Font.Parent = InfoFrame
		end
	end
	
	if CO.db.profile.customArmoryShowGems then
		A.SlotInfoFrames[CurrentName].Gems = {}
		A.SlotInfoFrames[CurrentName].Gems.Parent = InfoFrame
		
		
		-- Gems
		for i=1, MAX_NUM_SOCKETS do
			local GemSlot = CreateFrame("Frame", ("CUI_SlotGemInfo%s_%s"):format(CurrentName, i), InfoFrame)
			A.SlotInfoFrames[CurrentName].Gems[i] = GemSlot
			
			GemSlot.Parent = InfoFrame
			GemSlot:SetSize(12, 12)
			E:CreateBackground(GemSlot)
			
			local Position = "BOTTOM" .. E:InversePosition(InfoFrame.Align)
			local Prefix = (InfoFrame.Align == "RIGHT") and 1 or -1
			GemSlot:SetPoint(Position, InfoFrame, Position, ((12 * i) + (2 * (i - 1))) * Prefix, 2)
			
			GemSlot.Tex = GemSlot:CreateTexture(nil, "OVERLAY")
			GemSlot.Tex:SetAllPoints(GemSlot)
			
			GemSlot:Hide()
		end
	end
end

function A:CreateBackground(F)
	E:CreateTextureObject(F, "Background", "BACKGROUND")
	F.Background:SetTexture([[Interface\AddOns\CUI\Textures\layout\InspectInfoBackground]])
	
	F.Background:SetAlpha(0.45)
	--F.Background:SetVertexColor(0.09, 0.51, 0.81)
	F.Background:SetVertexColor(0.450, 0.580, 0.807)
	
	if F.Align == "LEFT" then
		F.Background:SetTexCoord(1, 0, 0, 1)
	else
		F.Background:SetTexCoord(0, 1, 0, 1)
	end
end

function A:UpdateBackground(Background, State)
	if State then
		Background:Show()
	else
		Background:Hide()
	end
end

function A:PrepareScanTooltip(Clear, Hide)
	self.ScanTip = self.ScanTip or CreateFrame("GameTooltip", "CUI_ArmoryScanningTooltip", nil, "GameTooltipTemplate")
	
	GameTooltip_SetDefaultAnchor(self.ScanTip, E.Parent)
	self.ScanTip:SetOwner(E.Parent, "ANCHOR_NONE")
	
	self:ReleaseScanTooltip(Clear, Hide)
end

function A:ReleaseScanTooltip(Clear, Hide)
	-- Force both when no value is given
	if not Clear and not Hide then Clear = true; Hide = true; end
	
	if Clear then self:ClearTooltip(self.ScanTip) end
	if Hide then self.ScanTip:Hide() end
end

function A:GetTooltipData(ItemLink, Search, Match)
	
	local Result
	
	self.ScanTip:SetOwner(E.Parent, "ANCHOR_NONE")
	self.ScanTip:SetHyperlink(ItemLink)
	
	for i=1, self.ScanTip:NumLines() do
	  local textLeft =  _G["CUI_ArmoryScanningTooltipTextLeft"..i]:GetText()
	  
	  if textLeft:find(Search) then
		Result = (textLeft):match(Match)
		
		break
	  end
	end
	
	self:ReleaseScanTooltip()
	return Result
end

-- Function to clean tooltip to get actual data instead of recursive ones
function A:ClearTooltip(Tooltip)
	local TooltipName = Tooltip:GetName()
	
	Tooltip:ClearLines()
	for i = 1, 10 do
		_G[TooltipName..'Texture'..i]:SetTexture(nil)
	end
end

function A:UpdateData(Unit, Type)
	
	if not CO.db.profile.customArmory then return end
	
	Type = Type or "Character"
	
	-- Contains: SlotID, Alignment
	local Slot, ItemLink, ItemLevel, ItemRarity, Enchant, RarityColor, RarityColorHex,
	AllFontsEmpty, LastFont
	
	for slotInfoName, fonts in pairs(A.SlotInfoFrames) do
		
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
							local Text, Color = A.Modules["Itemlevel"]:GetInfo(ItemLink)
							
							if Text ~= "" then AllFontsEmpty = false end
							frame:SetText(Text)
						elseif name == "enchant" then
							local Text, IsEnchanted = A.Modules["Enchant"]:GetInfo(ItemLink)
							
							if Text ~= "" then AllFontsEmpty = false end
							frame:SetText(Text)
						end
						
					end
					
					-- To access the parent
					LastFont = frame
				else
					if ItemLink then
						local Gems = A.Modules["Gems"]:GetInfo(ItemLink)
						
						-- GEMS
						for i = 1, MAX_NUM_SOCKETS do
							--print(Slot, ItemLink)
							--print(Gems[i].Texture)
							if Gems[i].isEmpty ~= nil then
								-- GEM SLOT EXISTS
								frame[i].Tex:SetTexture(Gems[i].Texture)
								frame[i]:Show()
							else
								frame[i]:Hide()
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
				A:UpdateBackground(LastFont.Parent.Background, false)
			else
				A:UpdateBackground(LastFont.Parent.Background, true)
			end
		end
	end
	
	
end

function A:UpdateInfo()
	if not CO.db.profile.customArmory then return end
	
	if _G["CharacterModelFrame"]:IsVisible() then
		-- Those values are used to RESIZE the panel
		_G["CharacterFrame"]:SetWidth(610)
		_G["CharacterFrameInset"]:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMLEFT", 400, 5)
		
		A:UpdateData()
	else
		-- Those values are used to RESET the panel
		_G["CharacterFrame"]:SetWidth(338) -- Default: 338
		_G["CharacterFrameInset"]:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMLEFT", 333, 4) -- Default: 333, 4
	end
end

-- self = PaperDollFrame
function A:CreateInfo()	
	
	if CO.db.profile.customArmory then
		
		_G["CharacterMainHandSlot"]:ClearAllPoints()
		_G["CharacterMainHandSlot"]:SetPoint('BOTTOM', _G["CharacterFrameInset"], 'BOTTOM', -(_G["CharacterMainHandSlot"]:GetWidth() / 2), 10)

		_G["CharacterModelFrame"]:ClearAllPoints()
		_G["CharacterModelFrame"]:SetPoint('TOPLEFT', _G["CharacterFrameInset"], "TOPLEFT", 32, -5)
		_G["CharacterModelFrame"]:SetPoint('BOTTOMRIGHT', _G["CharacterFrameInset"], "BOTTOMRIGHT", -32, 28)
		
		A:CreateSlotInfo()
		A:UpdateInfo()
	end
	
	A:OverridePanelBackground(_G["CharacterModelFrame"], CO.db.profile.customArmoryBackground, CO.db.profile.customArmoryBackgroundTexture, CO.db.profile.customArmoryBackgroundTexturePath, CO.db.profile.customArmoryBackgroundUseClass)
end

function A:OverridePanelBackground(Frame, State, CustomTexture, CustomTexturePath, TextureUseClass)
	-- This overrides the default armory background based on player character class
	if State then
		Frame.BackgroundTopLeft:Hide()
		Frame.BackgroundTopRight:Hide()
		Frame.BackgroundBotLeft:Hide()
		Frame.BackgroundBotRight:Hide()
		Frame.BackgroundOverlay:Hide()
		
		if not Frame.ModelBackground then
			Frame.ModelBackground = Frame:CreateTexture("ModelBackground", "BACKGROUND")
			Frame.ModelBackground:SetAllPoints(Frame)
		end
		
		if CustomTexture then
			Frame.ModelBackground:SetTexture(CustomTexturePath)
		else
			if TextureUseClass == "PLAYER_CLASS" then
				TextureUseClass = E.PlayerClass
			end
			
			Frame.ModelBackground:SetAtlas("dressingroom-background-" .. E:stringToLower(TextureUseClass))
		end
	end
end

function A:LoadProfile()
	
	self:SetScript("OnEvent", nil)
	
	if CO.db.profile.customArmory then
		self:SetScript("OnEvent", self.UpdateInfo)
	end
	
	for k,v in pairs(self.SlotInfo) do
		if CO.db.profile.customArmory then
			v:Show()
		else
			v:Hide()
		end
	end
	
	A:OverridePanelBackground(_G["CharacterModelFrame"], CO.db.profile.customArmoryBackground, CO.db.profile.customArmoryBackgroundTexture, CO.db.profile.customArmoryBackgroundTexturePath, CO.db.profile.customArmoryBackgroundUseClass)
end

function A:__Construct()
	--self.EquipmentSlots = { PaperDollItemsFrame:GetChildren() }
	local EventFrames = {
		["CharacterFrame"] = {"OnShow", A.UpdateInfo, "OnHide", A.UpdateInfo},
		["CharacterStatsPane"] = {"OnShow", A.CreateInfo, "OnHide", A.UpdateInfo},
		["PaperDollTitlesPane"] = {"OnShow", A.UpdateInfo, "OnHide", A.UpdateInfo},
		["PaperDollEquipmentManagerPane"] = {"OnShow", A.UpdateInfo, "OnHide", A.UpdateInfo},	
	}
	
	for k, v in pairs(EventFrames) do
		_G[k]:HookScript(v[1], v[2])
		_G[k]:HookScript(v[3], v[4])
	end
	
	hooksecurefunc("CharacterFrameTab_OnClick", A.UpdateInfo)
	
	self:RegisterEvent("SOCKET_INFO_SUCCESS")
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:RegisterEvent("UNIT_INVENTORY_CHANGED")
	self:RegisterEvent("ITEM_UPGRADE_MASTER_UPDATE")
	self:RegisterEvent("TRANSMOGRIFY_SUCCESS")
	self:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
	self:RegisterEvent("LOADING_SCREEN_DISABLED")
	
	self:LoadProfile()
	
	self:PrepareScanTooltip()
	self:ReleaseScanTooltip()
end

function A:Init()
	self:__Construct()
end

E:AddModule("Armory", A)