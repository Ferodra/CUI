local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, Module = E:LoadModules("Config", "Misc_Features")
Module.Autoload = true

---------------------------------------------------
local _
local pairs					= pairs
local tremove				= table.remove
local tinsert				= table.insert
local format				= string.format
local UIErrorsFrame 		= UIErrorsFrame -- To handle 'not a vendor'
local ERR_VENDOR_DOESNT_BUY = ERR_VENDOR_DOESNT_BUY
local ERR_OBJECT_IS_BUSY	= ERR_OBJECT_IS_BUSY -- Happens when we're selling too fast
local MerchantFrame			= MerchantFrame
local GetItemInfo			= GetItemInfo
local GetContainerItemLink	= C_Container and C_Container.GetContainerItemLink or GetContainerItemLink
local GetContainerItemInfo	= C_Container and C_Container.GetContainerItemInfo or GetContainerItemInfo
local GetContainerNumSlots	= C_Container and C_Container.GetContainerNumSlots or GetContainerNumSlots
local UseContainerItem		= C_Container and C_Container.UseContainerItem or UseContainerItem

-- CREDIT TO Terciob [Dev of AutoSeller]
local ExcludeList = {
	[44731] = true, 	-- Bouquet of Ebon Roses
	[38506] = true, 	-- Don Carlos' Famous Hat
	[86579] = true, 	-- Bottled Tornado
	[25653] = true, 	-- Riding Crop
	[19970] = true, 	-- Arcanite Fishing Pole
	[118372] = true, 	-- Orgrimmar Tabard
	[63207] = true, 	-- Wrap of Unity
	[63353] = true, 	-- Shroud of Cooperation
	[116913] = true, 	-- Peon's Mining Pick
	[116916] = true, 	-- Gorepetal's Gentle Grasp
	[33820] = true, 	-- Weather-Beaten Fishing Hat
	[84661] = true, 	-- Dragon Fishing Pole
	[63206] = true, 	-- Wrap of Unity
	[103678] = true, 	-- Time-Lost Artifact
	[65274] = true, 	-- Cloak of Coordination
	[2901] = true, 		-- Mining Pick
	[86566] = true, 	-- Forager's Gloves
	[162690] = true, 	-- Waist of Time
	[52252] = true, 	-- Tabard of the Lighbringer
	[154172] = true, 	-- Aman'thul Pantheon Trinket
	[154173] = true, 	-- Aggramar Pantheon Trinket
	[154174] = true, 	-- Golganneth Pantheon Trinket
	[154175] = true, 	-- Eonar Pantheon Trinket
	[154176] = true, 	-- Khaz'goroth Pantheon Trinket
	[154177] = true, 	-- Norgannon Pantheon Trinket
	[33292] = true, 	-- Gruselhelm
	[180136] = true, 	-- Die Mittlerangel
	[21525] = true, 	-- Green Winter Hat
	[241007] = true, 	-- Cosmetic Mace
	[241019] = true, 	-- Cosmetic Sword
}

local IncludeList = {
	
}

-- DO NOT SELL THOSE
local EquipLocBlacklist = {
	['INVTYPE_TABARD'] = true,
	['INVTYPE_BODY'] = true,
	['INVTYPE_BAG'] = true,
}

-- We need those to check for Item Types
local ARMOR 	= ARMOR
local WEAPON 	= WEAPON
local AUCTION_CATEGORY_GEMS	= AUCTION_CATEGORY_GEMS -- Basically the most accurate thing we could go for
local GEM		= AUCTION_CATEGORY_GEMS:sub(1, -3)

local GemIlvlString 			= SOCKETING_ITEM_MIN_LEVEL_I
local UncollectedTransmogString = TRANSMOGRIFY_STYLE_UNCOLLECTED
local ITEM_SOULBOUND			= ITEM_SOULBOUND

local TICKER_TIME = 0.2 -- Seconds between each sell, to make sure everything goes right
---------------------------------------------------

local function IsItemSoulbound(Bag, Slot)
	return E.ScanningTooltip:ScanBagItem(Bag, Slot, ITEM_SOULBOUND, nil, 6)
end

local function IsItemUncollectedTransmog(Bag, Slot)
	return E.ScanningTooltip:ScanBagItem(Bag, Slot, UncollectedTransmogString)
end

local function IsGemEligibleForSell(ItemID)
	local ItemName, _, _, ItemLevel = GetItemInfo(ItemID)
	
	if ItemLevel then 
		ItemLevel = tonumber(ItemLevel)
		
		if ItemLevel < Module.db.autoSellOldGemsBelowIlvl then
			return true
		end
	end
end

local function ShouldAutoSellItem(Rarity, ItemLevel, ItemType, ItemEquipLoc, BindType, ItemID, ItemLink, Bag, Slot, Value)
	if not ItemID or not ItemType or (not Value or (Value and Value <= 0)) then return end
	if not ItemLink then
		ItemLink = GetItemInfo(ItemID)
	end
	
	if Module.db.autoSellOldGems and ItemType:find(GEM) then
		return IsGemEligibleForSell(ItemID)
	end

	-- Prevent Whites and Legendaries from being sold
	if Rarity and (Rarity == 1 or Rarity > 4) or not Rarity or (Module.db.autoSellNoBoE and BindType > 1 and Rarity > 0 and not IsItemSoulbound(Bag, Slot)) or (ExcludeList[ItemID]) then return nil end
	
	if Module.db.autoSellGreys and Rarity == 0 then
		return true
	end
	
	if (ItemType == ARMOR or ItemType == WEAPON) and ItemLevel then
		--print(ItemLink, ItemLevel < Module.db.autoSellBelowIlvl, ItemLevel, Module.db.autoSellBelowIlvl)
		if Module.db.autoSellBelowIlvlEnable and ItemLevel < Module.db.autoSellBelowIlvl 
		and ((Module.db.autoSellBelowIlvlEnableAtMaxlevel and UnitLevel("player") == E.UNIT_MAXLEVEL) or not Module.db.autoSellBelowIlvlEnableAtMaxlevel) 
		and not EquipLocBlacklist[ItemEquipLoc] then
			if not Module.db.autoSellNoBoE and (BindType == 2 or BindType == 3) then
				-- Do not sell uncollected Transmog
				if Module.db.autoSellNoUncollectedTransmog then
					return not IsItemUncollectedTransmog(Bag, Slot)
				end
			end
			
			return true
		end
	end
end

function Module:ReportSellGreys()
	if self.SellGreysFrame.Reported or not self.db.autoSellGreysReport then wipe(self.SellGreysFrame.Report); return end
	self.SellGreysFrame.Reported = true
	
	local Value = 0
	
	for k, data in ipairs(self.SellGreysFrame.Report) do
		if data.count and data.count > 1 then
			E:print(format(L["Sold: %s for %s"], format("%sx%s", data.count, data.link), E:FormatMoney(data.value, true)))
		else
			E:print(format(L["Sold: %s for %s"], data.link, E:FormatMoney(data.value, true)))
		end
		
		Value = Value + data.value
	end
	
	E:print("------")
	E:print(format(L["Total Revenue: %s"], E:FormatMoney(Value, true)))
	
	wipe(self.SellGreysFrame.Report)
end

function Module:SellGreys_OnUpdate(elapsed)
	if not self.IsVendor then wipe(self.Items); return end
	
	self.Ticker = (self.Ticker or 0) + elapsed
	if self.Ticker >= TICKER_TIME then
		if not MerchantFrame:IsVisible() or #self.Items == 0 then self:SetScript("OnUpdate", nil); Module:ReportSellGreys(); return end			
			local Item = tremove(self.Items)
			
			local Link = GetContainerItemLink(Item.bag, Item.slot)
			if Link then
				local _, _, rarity, _, _, itemType,_,_, itemEquipLoc,_,_,_,_, bindType = GetItemInfo(Link)
				local effectiveILvl = GetDetailedItemLevelInfo(Link)
				
				local itemID = GetItemInfoInstant(Link)
				
				if itemType and ShouldAutoSellItem(rarity, effectiveILvl, itemType, itemEquipLoc, bindType, itemID, Link, Item.bag, Item.slot, Item.value) then
					self.Report[#self.Report + 1] = {["link"] = Link, ["value"] = Item.value, ["count"] = Item.count}
					self.Reported = false
					
					UseContainerItem(Item.bag, Item.slot) -- Sell it
					if _G.StaticPopup1 and _G.StaticPopup1Button1 then
						StaticPopup1Button1:Click()
					end
				end
			end
		
		self.Ticker = 0
	end
end

function Module:SellGreys(event)
	
	if event == "MERCHANT_SHOW" or event == "PLAYER_INTERACTION_MANAGER_FRAME_SHOW" then
		self.IsVendor = true
		
		if not MerchantFrame:IsVisible() then return end
		
		local rarity, ilvl, itemType, price, stackPrice, stackCount, bindType, itemID
		for bag = 0,4 do
			for slot=0, GetContainerNumSlots(bag) do
				local Link = GetContainerItemLink(bag, slot)
				if Link then
					_, _, rarity, _, _, itemType, _, _, itemEquipLoc, _, price, _, _, bindType = GetItemInfo(Link)
					ilvl = GetDetailedItemLevelInfo(Link)
					itemID = GetItemInfoInstant(Link)
					
					stackPrice = 0
					stackCount = 1
					if price then
						stackCount = select(2, GetContainerItemInfo(bag, slot)) or 1
						stackPrice = price * stackCount
					end
					if ShouldAutoSellItem(rarity, ilvl, itemType, itemEquipLoc, bindType, itemID, Link, bag, slot, stackPrice) and (itemType and itemType ~= "Quest") then
						tinsert(self.Items, {["bag"] = bag, ["slot"] = slot, ["value"] = stackPrice, ["count"] = stackCount})
					end
				end
			end
		end
		
		self.Reported = true -- Do not report if we didn't sell anything
		self:SetScript("OnUpdate", Module.SellGreys_OnUpdate)
	elseif event == "MERCHANT_CLOSED" then
		if self.IsVendor then
			Module:ReportSellGreys()
		end
		self:SetScript("OnUpdate", nil)
	end
end

function Module:SellGreys_VendorError(msg)
	if not MerchantFrame:IsVisible() then return end
	if msg and msg == ERR_VENDOR_DOESNT_BUY then
		-- Terminate
		
		if Module.SellGreysFrame.IsVendor then
			E:print("No greys sold, as this merchant is not a vendor!")
		end
		
		-- Clean to avoid duplicates
		wipe(Module.SellGreysFrame.Report)
		Module.SellGreysFrame.IsVendor = nil
		Module.SellGreysFrame:SetScript("OnUpdate", nil)
	end
	if msg and msg == ERR_OBJECT_IS_BUSY then
		-- @TODO: Restart selling without reporting
	end
end

function Module:LoadConfig()
	if self.db.autoSellGreys or self.db.autoSellBelowIlvlEnable or self.db.autoSellOldGems then
		if not self.SellGreysFrame:IsEventRegistered("MERCHANT_SHOW") then
			self.SellGreysFrame:RegisterEvent("MERCHANT_SHOW")
			self.SellGreysFrame:RegisterEvent("MERCHANT_CLOSED")
			self.SellGreysFrame:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW")
			hooksecurefunc(UIErrorsFrame, 'AddMessage', self.SellGreys_VendorError)
		end
	else
		self.SellGreysFrame:UnregisterEvent("MERCHANT_SHOW")
		self.SellGreysFrame:UnregisterEvent("MERCHANT_CLOSED")
		self.SellGreysFrame:UnregisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW")
	end
end

function Module:Construct()
	-- Autosell Greys
	self.SellGreysFrame = CreateFrame("Frame", "CUI_SellGreysHandlerFrame")
	self.SellGreysFrame.Items = {}
	self.SellGreysFrame.Report = {}
	self.SellGreysFrame.Reported = false
	self.SellGreysFrame.Count = 0
	self.SellGreysFrame:SetScript("OnEvent", Module.SellGreys)
end

function Module:Init()
	self.db = CO.db.profile.utility
	
	self:Construct()
	self:LoadConfig()
end

E:AddModule("Misc_Features", Module)