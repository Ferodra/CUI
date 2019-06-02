local E = unpack(select(2, ...)) -- Engine, Locale
local CO, L, B = E:LoadModules("Config", "Locale", "Bags")
B.Autoload = true

-----------------------------------------------------------------------------
B.Bags = {}
local _
local BagSize = 50
local BagHolder = CreateFrame("Frame", "CUI_BagBarHolder", E.Parent)
local MainBag = _G["MainMenuBarBackpackButton"]
local SecondaryBags = "CharacterBag%dSlot"
local Color_EmptyBag = {0.1, 0.1, 0.1}

local Masque = E.Libs.Masque
local MasqueGroup = Masque and Masque:Group("CUI", L['Bags'])
-----------------------------------------------------------------------------

function B:GetBagColor(ID)
	
	local Link, Color
	
	if ID > 0 then
		ID = ContainerIDToInventoryID(ID)
		
		Link = GetInventoryItemLink("player", ID)
		
		if Link then
			Color = ITEM_QUALITY_COLORS[select(3, GetItemInfo(Link))]
		else
			Color = Color_EmptyBag
		end
	else
		Color = ITEM_QUALITY_COLORS[1]
	end
	
	return Color
end

function B:ApplyBorderColor(event)
	local ID, Color
	for k, bag in pairs(self.Bags) do
		ID = bag:GetBagID()
		
		Color = B:GetBagColor(ID) or Color_EmptyBag
		E:ColorizeButton(bag, Color)
	end
end

function B:LoadMasque()
	
	if not MasqueGroup then return end
	
	for k, bag in pairs(self.Bags) do
		local buttonData = {
			Icon 		= bag.icon,
			Normal 		= bag:GetNormalTexture(),
			Pushed  	= bag:GetPushedTexture(),
			Highlight 	= bag:GetHighlightTexture(),
			Border  	= bag.IconBorder,
			Count		= bag.Count
		}
		
		MasqueGroup:AddButton(bag, buttonData)
	end
end

function B:LoadProfile()
	self.db = CO.db.profile.bags
	
	if self.db.enable then		
		local totalWidth, totalHeight = E:SortFrames(self.Bags, BagHolder, BagSize, BagSize, self.db.buttonSizeMultiplier, self.db.buttonsPerRow, false, false, self.db.buttonGap, self.db.buttonGap, true)
		
		BagHolder:SetSize(totalWidth, totalHeight)
		
		if E:GetMover(BagHolder) then
			local profileMoverData = CO.db.profile.movers["CUI_BagBarHolderMover"]
			E:RepositionMover(E:GetMover(BagHolder), profileMoverData["point"], profileMoverData["relativePoint"], profileMoverData["xOffset"], profileMoverData["yOffset"])
			E:UpdateMoverDimensions(BagHolder)
		end
		
		if MasqueGroup and self.db.useMasque then
			MasqueGroup:ReSkin()
		end
		
		BagHolder:Show()
	else
		BagHolder:Hide()
	end
end

function B:Construct()
	BagHolder:SetSize(250, BagSize)
	
	MainBag:ClearAllPoints()
	MainBag:SetPoint("TOPRIGHT", BagHolder, "TOPRIGHT")
	MainBag:SetParent(BagHolder)
	MainBag:SetSize(BagSize, BagSize)
	_G["MainMenuBarBackpackButtonNormalTexture"]:SetAlpha(0)
	table.insert(self.Bags, MainBag)	
	
	MainBag.IconBorder:Hide()
	MainBag.IconBorder:SetAlpha(0)
	
	local CurrentBag
	for i = 0, NUM_BAG_FRAMES - 1 do
		CurrentBag = _G[string.format(SecondaryBags, i)]
		if CurrentBag then
			CurrentBag:ClearAllPoints()
			CurrentBag:SetPoint("BOTTOMRIGHT", BagHolder, "BOTTOMLEFT", 0, 0)
			CurrentBag:SetParent(BagHolder)
			CurrentBag:SetSize(BagSize, BagSize)
			CurrentBag.IconBorder:SetSize(BagSize, BagSize)
			_G[string.format(SecondaryBags, i) .. "NormalTexture"]:SetAlpha(0)
			
			table.insert(self.Bags, CurrentBag)
			
			CurrentBag.IconBorder:Hide()
			CurrentBag.IconBorder:SetAlpha(0)
		end
	end
	
	if CO.db.profile.bags.useMasque then
		self:LoadMasque()
	end
	
	E:CreateMover(BagHolder, "Bag-Bar", nil, nil, nil, "Holds your bags!")
	
	self:RegisterEvent("BAG_UPDATE")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:SetScript("OnEvent", self.ApplyBorderColor)
end

function B:Init()
	self:Construct()
	
	self:LoadProfile()
end

E:AddModule("Bags", B)