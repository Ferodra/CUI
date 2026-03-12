local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, Module = E:LoadModules("Config", "ItemDB")
Module.Autoload = true

-----------------------------------------------------------------------------
local _
local pairs									= pairs
local select								= select
local tsort									= table.sort
local match									= string.match
local GetItemInfo							= GetItemInfo
local GetItemCount							= GetItemCount
local GetContainerItemLink  				= C_Container.GetContainerItemLink or GetContainerItemLink
local ContainerIDToInventoryID 				= C_Container.ContainerIDToInventoryID or ContainerIDToInventoryID
local GetContainerNumFreeSlots 				= C_Container.GetContainerNumFreeSlots or GetContainerNumFreeSlots
local GetInventoryItemLink 					= C_Container.GetInventoryItemLink or GetInventoryItemLink
local GetContainerNumSlots  				= C_Container.GetContainerNumSlots or GetContainerNumSlots
local GetItemInfoInstant					= GetItemInfoInstant
local C_CurrencyInfo_GetCurrencyInfo		= C_CurrencyInfo.GetCurrencyInfo or GetCurrencyInfo
local C_CurrencyInfo_GetCurrencyListInfo	= C_CurrencyInfo.GetCurrencyListInfo or GetCurrencyListInfo
local C_CurrencyInfo_ExpandCurrencyList		= C_CurrencyInfo.ExpandCurrencyList or ExpandCurrencyList
local C_CurrencyInfo_GetCurrencyListLink	= C_CurrencyInfo.GetCurrencyListLink or GetCurrencyListLink
local C_Bank_FetchDepositedMoney			= C_Bank.FetchDepositedMoney

-- Enum.BankType.Account

-- Yo Blizz, why are those locals?
-- local VOID_STORAGE_PAGES = 2
-- local VOID_STORAGE_MAX = 80
local BANK_NUM_BAGS = 6
local BANK_NUM_SLOTS = 28
local NUM_BAG_SLOTS = 4
local BANK_CONTAINER = -2
local REAGENTBANK_CONTAINER = 5

local WARBANK_TABS = {12,13,14,15,16}
local BANK_TABS = Enum.BagIndex

local NameToDBIndex = {
	['bags'] 	  	= 1,
	['bank'] 	  	= 2,
	['void'] 	  	= 3,
	['equipment'] 	= 4,
	['reagentbank'] = 5,
}

local TEMP_ACC_CURRENCY = {}

-----------------------------------------------------------------------------

--[[
['itemDB'] = {		
	['data'] = {
		['characters'] = {
			[CharKey] = {
				[ItemID] = {NumInBags, NumInBank, NumInVoid, Equipped, ReagentBank},
				[currency] = {
					[ItemID] = amount,
				}
			},
		},
		['WARBANK'] = {
			[ItemID] = {NumInWarbank},
			[currency] = {
				[ItemID] = amount,
			}
		},
	},
}
--]]


-- Also use realm in key, so we never hit any duplicate chars
local RealmKey = GetRealmName()
local CharKey = UnitName("player") .. " - " .. RealmKey
-- Used for return data limiting
local CurrentFaction = UnitFactionGroup("player")
-- The second value in a players GUID is the Realm ID, which is shared between realms in the same realmpool.
-- We can use that to limit return data to the same pool!
local CurrentRealmID = select(2, strsplit("-", UnitGUID("player") or ""))

function Module:AddItemToCurrentChar(ItemID, IsEquipped)
	if not ItemID then return end -- You're not supposed to be here
	
	if not self.currentCharDB.items[ItemID] then
		self.currentCharDB.items[ItemID] = {}
	end
	
	if not IsEquipped then
		local TotalNum_All = GetItemCount(ItemID, true, false, true)
		local TotalNum_Bank = GetItemCount(ItemID, true)
		if TotalNum_All <= 0 then 
			self.currentCharDB.items[ItemID] = nil
			
			return
		end 
		
		local InBags = GetItemCount(ItemID)
		local InBank = TotalNum_Bank - InBags
		local InReagentBank = TotalNum_All - InBank - InBags
		local Equipped = (self.currentCharDB.items[ItemID][4] or 0)
		
		-- Subtract equipped num from the ItemCount, as it appears to already count equipped gear.
		-- This would falsify our real count
		self.currentCharDB.items[ItemID][1] = (InBags - Equipped) > 0 and (InBags - Equipped) or nil
		self.currentCharDB.items[ItemID][2] = InBank > 0 and InBank or nil
		self.currentCharDB.items[ItemID][5] = InReagentBank > 0 and InReagentBank or nil
	else
		self.currentCharDB.items[ItemID][4] = (self.currentCharDB.items[ItemID][4] or 0) + 1
	end
end

function Module:AddItemToWarbank(ItemID)
	if not ItemID then return end
	
	local TotalNum = GetItemCount(ItemID, false, false, false, true)
	if TotalNum <= 0 then 
		self.warbankDB.items[ItemID] = nil
		
		return
	end 
	
	local InBags = GetItemCount(ItemID)
	local InBank = TotalNum - InBags
	
	self.warbankDB.items[ItemID] = InBank
end

function Module:UpdateWarbankMoney()
	local Money = C_Bank_FetchDepositedMoney(Enum.BankType.Account)
	
	self.warbankDB.currency.Money = Money
end

-- Without this, we're just adding to the db, but never remove anything
function Module:ResetForCurrentChar(StorageType)
	local DBIndex = NameToDBIndex[StorageType]
	local Target = self.currentCharDB.items
	
	for k, itemData in pairs(Target) do
		itemData[DBIndex] = nil
	end
end

function Module:ResetWarbankData(forItems, forCurrencies)
	if forItems then
		wipe(self.warbankDB.items)
	end
	if forCurrencies then
		wipe(self.warbankDB.currency)
	end
end

function Module:IsBankInitialized()
	return self.currentCharDB.isBankInitialized
end
function Module:SetBankInitialized()
	self.currentCharDB.isBankInitialized = true
end

function Module:ScanBag(BagID)
	local IsWarbank = E:TableContainsValue(WARBANK_TABS, BagID)
	
	local ItemID
	for slot=0, GetContainerNumSlots(BagID) do
		local Link = GetContainerItemLink(BagID, slot)
		
		if Link then
			ItemID = GetItemInfoInstant(Link)
			
			if not IsWarbank then
				self:AddItemToCurrentChar(ItemID)
			else
				self:AddItemToWarbank(ItemID)
			end
		end
	end
end
-- function Module:ScanVoidStorage()
	
	
	-- local ItemID
	-- for tab=1, VOID_STORAGE_PAGES do
		-- for slot=1, VOID_STORAGE_MAX do
			-- ItemID = GetVoidItemInfo(tab, slot)
			
			-- self:AddItemToCurrentChar(ItemID, true)
		-- end
	-- end
-- end
function Module:ScanEquipment()
	self:ResetForCurrentChar('equipment')
	
	local Link, ItemID
	for i=1, 19 do
		Link = GetInventoryItemLink('player', i)
		if Link then
			ItemID = GetItemInfoInstant(Link)
			
			self:AddItemToCurrentChar(ItemID, false, true)
		end
	end
end
--[[
	CURRENCY:
	We can use C_CurrencyInfo_GetCurrencyListInfo(index) to retrieve data about all currencies.
	When a header is collapsed, we can call ExpandCurrencyList(id, expanded[0 or 1]) to actually get the currency data
	Update event: CURRENCY_DISPLAY_UPDATE
	GetCurrencyListSize()
--]]

function Module:UpdateCurrency()
	
	wipe(self.currentCharDB.currency)
	
	local name, isHeader, isExpanded, count, currencyID, link, data
	local index = 1
	
	while true do
		if not C_CurrencyInfo.GetCurrencyListInfo then
			name, isHeader, isExpanded, _, _, count = C_CurrencyInfo_GetCurrencyListInfo(index)
		else
			data = C_CurrencyInfo_GetCurrencyListInfo(index)
			if not data then break end
			
			name, isHeader, isExpanded, count = data.name, data.isHeader, data.isHeaderExpanded, data.quantity
		end
		if not name then break end
		
		if isHeader and not isExpanded then
			C_CurrencyInfo_ExpandCurrencyList(index, 1)
		elseif not isHeader then
			link = C_CurrencyInfo_GetCurrencyListLink(index)
			
			if link then
				currencyID = tonumber(match(C_CurrencyInfo_GetCurrencyListLink(index),"currency:(%d+)"))
				if currencyID then
					self.currentCharDB.currency[currencyID] = count
				end
			end
		end
		
		index = index + 1
	end
	
	-- Money
	self:UpdateCharMoney()
	self:UpdateWarbankMoney()
end

function Module:UpdateCharMoney()
	self.currentCharDB.currency['Money'] = GetMoney()
end

function Module:UpdateAccountCurrency(currencyID)
	if not self.IsAccountCurrencyDataReady then return end
	
	local Data = C_CurrencyInfo.FetchCurrencyDataFromAccountCharacters(currencyID)
	local DBData, DBName, DBRealm, DBFound
	
	-- Reset currency for characters first
	for k, v in pairs(self.db.global.data.characters) do
		if v.currency[currencyID] then
			v.currency[currencyID] = nil
		end
	end
	
	for k,v in pairs(Data) do
		DBFound = true
		-- Figure out which character it could be based on our data
		if not string.find(v.fullCharacterName, "-") then
			--print("Cannot find realm for", v.fullCharacterName, "for currency", currencyID)
			DBFound = false
			
			for name, _ in pairs(self.db.global.data.characters) do
				DBData = E:Split(name)
				DBName, DBRealm = DBData[1], DBData[2]
				
				if DBName == v.fullCharacterName then
					-- Just write it into the table
					v.fullCharacterName = string.format("%s-%s", DBName, DBRealm)
					DBFound = true
					break
				end
			end
		end
		
		-- If we have a DB entry for this char
		if DBFound then
			v.fullCharacterName = string.gsub(v.fullCharacterName, "-", " - ")
			--print("Determined full name as:", v.fullCharacterName)
			
			if self.db.global.data.characters[v.fullCharacterName] then
				-- Update count for this char
				self.db.global.data.characters[v.fullCharacterName].currency[currencyID] = v.quantity
				-- if tonumber(currencyID) == 1166 then
					-- print("Updated currency", currencyID, "for", v.fullCharacterName, "quantity:", v.quantity)
				-- end
			end
		else
			-- If we don't yet have data for this char, store it anyway for tooltip usage
			if not TEMP_ACC_CURRENCY[v.fullCharacterName] then
				TEMP_ACC_CURRENCY[v.fullCharacterName] = {}
			end
			
			TEMP_ACC_CURRENCY[v.fullCharacterName][currencyID] = v.quantity
		end
	end
	
	-- Update current char currencies, since they aren't included in the FetchCurrencyDataFromAccountCharacters payload
	self:UpdateCurrency()
end

function Module:RequestAccountCurrencyData()
	C_CurrencyInfo.RequestCurrencyDataForAccountCharacters()
	self:InitAccountCurrencyUpdater()
end

function Module:HandleAccountCurrencyData()
	local name, isHeader, isExpanded, count, currencyID, link, data
	local index = 1
	
	while true do
		if not C_CurrencyInfo.GetCurrencyListInfo then
			name, isHeader, isExpanded, _, _, count = C_CurrencyInfo_GetCurrencyListInfo(index)
		else
			data = C_CurrencyInfo_GetCurrencyListInfo(index)
			if not data then break end
			
			name, isHeader, isExpanded, count = data.name, data.isHeader, data.isHeaderExpanded, data.quantity
		end
		if not name then break end
		
		--if data.currencyID == 1166 then
		--print(data.name, data.currencyID, data.isAccountTransferable)
		--end
		
		if isHeader and not isExpanded then
			C_CurrencyInfo_ExpandCurrencyList(index, 1)
		elseif not isHeader then
			link = C_CurrencyInfo_GetCurrencyListLink(index)
			
			if link then
				currencyID = tonumber(match(C_CurrencyInfo_GetCurrencyListLink(index),"currency:(%d+)"))
				if currencyID then
					--self.currentCharDB.currency[currencyID] = count
					if data.isAccountTransferable then
						self:UpdateAccountCurrency(currencyID)
					end
				end
			end
		end
		
		index = index + 1
	end	
end

local function CheckAccountCurrencyState(self, elapsed)
	if ((self.elapsed or 0) + elapsed) >= 0.5 then
		--print("Received currency data?", C_CurrencyInfo.IsAccountCharacterCurrencyDataReady())
		if C_CurrencyInfo.IsAccountCharacterCurrencyDataReady() then
			Module.IsAccountCurrencyDataReady = true
			Module:HandleAccountCurrencyData()
			
			self:SetScript('OnUpdate', nil)
		end
		self.elapsed = 0
	end
	self.elapsed = (self.elapsed or 0) + (elapsed)
end

function Module:InitAccountCurrencyUpdater()
	local Updater = CreateFrame('Frame', 'CUI_ItemDBAccountCurrencyUpdater')
	Updater:SetScript('OnUpdate', CheckAccountCurrencyState)
end

function Module:ScheduleAccountCurrencyUpdate()
	if _G.TokenFrame:IsVisible() then
		self:RequestAccountCurrencyData()
	else
		self.ScheduledAccountCurrencyUpdate = true
		
		if not self.TokenFrameHooked then
			_G.TokenFrame:HookScript("OnShow", function()
				Module:RequestAccountCurrencyData()
				Module.ScheduledAccountCurrencyUpdate = false
			end)
		end
		
		self.TokenFrameHooked = true
	end
end

function Module:OnEvent(event, arg1, ...)
	if event == 'PLAYER_ENTERING_WORLD' or event == 'CURRENCY_DISPLAY_UPDATE' or event == 'ACCOUNT_STORE_CURRENCY_AVAILABLE_UPDATED' then
		if event == 'PLAYER_ENTERING_WORLD' then
			-- Update once on login
			Module:RequestAccountCurrencyData()
		end
		
		-- Still schedule update of account currencies on currency frame shown
		-- This is to prevent unnecessary updates during gameplay
		self:ScheduleAccountCurrencyUpdate()
	end
	
	if event == 'PLAYER_ENTERING_WORLD' or event == 'BAG_UPDATE' or event == 'PLAYER_EQUIPMENT_CHANGED' or event == 'CURRENCY_DISPLAY_UPDATE' or event == 'LoadBank' then
		self:UpdateCurrency()
		
		if event == 'CURRENCY_DISPLAY_UPDATE' then return end
		
		self:ScanEquipment()
		-- We scanned equipment, let's leave
		if event == 'PLAYER_EQUIPMENT_CHANGED' then	return end
		
		
		if event ~= 'LoadBank' then
			self:ResetForCurrentChar('bags')
			for bag = 0,4 do
				self:ScanBag(bag)
			end
			-- Reagent bag
			self:ScanBag(5)
		end
		
		if self.IsBankOpen then
			self:ResetForCurrentChar('bank')
			self:ResetForCurrentChar('reagentbank')
			
			for bag = NUM_BAG_SLOTS+1, NUM_BAG_SLOTS+BANK_NUM_BAGS do
				self:ScanBag(bag)
			end
			self:ScanBag(BANK_CONTAINER)
			self:ScanBag(REAGENTBANK_CONTAINER)
			
			-- Rebuild warbank
			self:ResetWarbankData(true, false)
			for _, index in pairs(WARBANK_TABS) do
				self:ScanBag(index)
			end
		end
	elseif event == 'BANKFRAME_OPENED' or event == 'BANKFRAME_CLOSED' then
		self.IsBankOpen = event == 'BANKFRAME_OPENED'
		
		if self.IsBankOpen then
			self:OnEvent('LoadBank')
		end
	elseif event == 'VOID_TRANSFER_DONE' then
		--self:ScanVoidStorage()
	elseif event == 'PLAYER_MONEY' then
		self:UpdateCharMoney()
	end
end

-- We use this to actually retrieve the DB information in a convenient way
function Module:GetItemInfo(ItemID)
	local Data = self.charDB
	if not Data then return end
	
	local Info = {}
		Info.Chars = {}
	local Total = 0
	local CharTotal
	
	-- Scans all entries
	for CharName, v in pairs(Data) do
		-- Limit returned data to current realmpool AND faction
		if v.RealmID == CurrentRealmID and v.Faction == CurrentFaction then
			CharTotal = 0
			
			if v.items[ItemID] then
				for _, num in pairs(v.items[ItemID]) do
					CharTotal = CharTotal + num
				end
				if CharTotal > 0 then
					Info.Chars[CharName] = {
						['bags'] = v.items[ItemID][1] or 0,
						['bank'] = v.items[ItemID][2] or 0,
						--['void'] = v.items[ItemID][3] or 0,
						['equipped'] = v.items[ItemID][4] or 0,
						['reagentbank'] = v.items[ItemID][5] or 0,
						['Class'] = v.Class,
					}
					
					Total = Total + CharTotal
				else
					self.charDB[CharName].items[ItemID] = nil
				end
			end
		end
	end
	
	-- Scan warbank data
	local WarbankData = self.warbankDB.items[ItemID]
	Info.WARBANK = WarbankData or 0
	Total = Total + (WarbankData or 0)
	
	Info.Total = Total
	
	return Info
end

local function CurrencySortByAmount(a, b)
	return a.amount > b.amount
end

local function CurrencySortByName(a, b)
	return a.name > b.name
end

local function CurrencySortByClass(a, b)
	return a.class > b.class
end

-- Use this for testing
-- /dump CUI[1]:LoadModule("ItemDB"):GetCurrencyInfo("Money")
function Module:GetCurrencyInfo(ItemID, SortBy)
	assert(not SortBy or (SortBy == 'amount' or SortBy == 'class' or SortBy == 'name'), "Currency must be sorted by amount, class or name [string]!")
	
	local Data = self.charDB
	
	if ItemID ~= "Money" then
		local CurrencyInfo = C_CurrencyInfo_GetCurrencyInfo(ItemID)
		local IsAccountCurrency, IsAccountWideCurrency
		
		if CurrencyInfo then
			IsAccountCurrency = CurrencyInfo.isAccountTransferable
			IsAccountWideCurrency = CurrencyInfo.isAccountWide
		end
		
		if IsAccountWideCurrency then
			return nil
		end
	end
	
	local Info = {}
		Info.Chars = {}
	local Total = 0
	local CharTotal
	
	
	
	-- Scans all entries
	local i = 1
	for CharName, v in pairs(Data) do
		-- Limit returned data to current realmpool AND faction
		if (ItemID ~= "Money" and (v.RealmID == CurrentRealmID and v.Faction == CurrentFaction)) or ItemID == "Money" then
			if v.currency[ItemID] then
			
				CharTotal = 0
				
				Info.Chars[i] = {
					['amount'] = v.currency[ItemID] or 0,
					['class'] = v.Class,
					['name'] = CharName,
				}
				
				CharTotal = (v.currency[ItemID] or 0)
				if CharTotal < 1 then
					self.charDB[CharName].currency[ItemID] = nil
				else
					Total = Total + CharTotal
				end
				
				i = i+1
			end
		end
	end
	
	local WarbankAmount = self.warbankDB.currency[ItemID]
	if WarbankAmount then
		Info.WARBANK = WarbankAmount
		Total = Total + WarbankAmount
	end
	
	Info.Total = Total
	
	if not SortBy or (SortBy and SortBy == 'amount') then
		tsort(Info.Chars, CurrencySortByAmount)
	elseif SortBy == 'class' then
		tsort(Info.Chars, CurrencySortByClass)
	elseif SortBy == 'name' then
		tsort(Info.Chars, CurrencySortByName)
	end
	
	
	return Info
end

-- Use this for testing
-- /dump CUI[1]:LoadModule("ItemDB"):GetItemInfo(172191)
function Module:LoadConfig()	
	self.CUIDB		= CO.db.global.itemDB
	
	if self.CUIDB then
		self:SetScript("OnEvent", self.OnEvent)
	else
		self:SetScript("OnEvent", nil)
	end
end

function Module:Construct()	
	-- Prepare Char Table
	if not self.charDB[CharKey] then	
		self.charDB[CharKey] = {}
		self.charDB[CharKey].items = {}
		self.charDB[CharKey].currency = {}
		-- Just another place where we store character data.. Gotta find another permanent place for that
		self.charDB[CharKey].Class = select(2, UnitClass("player"))
		self.charDB[CharKey].RealmID = CurrentRealmID
		self.charDB[CharKey].Faction = CurrentFaction
	end
	
	self.currentCharDB 	= self.db.global.data.characters[CharKey]
	
	self:RegisterEvent("BAG_UPDATE")
	self:RegisterEvent("BANKFRAME_OPENED")
	self:RegisterEvent("BANKFRAME_CLOSED")
	--self:RegisterEvent("VOID_TRANSFER_DONE")
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_MONEY")
	self:RegisterEvent("ACCOUNT_CHARACTER_CURRENCY_DATA_RECEIVED")
	self:RegisterEvent("ACCOUNT_STORE_CURRENCY_AVAILABLE_UPDATED")
	
	-- Void storage is deprecated as of 11.2
	self:ResetForCurrentChar('void')
end

function Module:Init()
	self:SetDefaults()
	self.db	= LibStub('AceDB-3.0'):New('CUIITEMDB', self.Defaults)
	
	--self.db = CO.db.global.itemDB
	self.allDB 			= self.db.global.data
	self.charDB 		= self.db.global.data.characters
	self.warbankDB 		= self.db.global.data.WARBANK
		
	self:Construct()
	self:LoadConfig()
end

E:AddModule("ItemDB", Module)