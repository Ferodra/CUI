local E, L = unpack(select(2, ...)) -- Engine, Locale
local L, CO, MF = E:LoadModules("Locale", "Config", "Misc_Features")
MF.Autoload = true

---------------------------------------------------
local _
local format				= string.format
local MerchantFrame			= MerchantFrame
local GetItemInfo			= GetItemInfo
local GetContainerItemLink	= GetContainerItemLink
local GetContainerNumSlots	= GetContainerNumSlots
local UseContainerItem		= UseContainerItem
---------------------------------------------------

function MF:ReportSellGreys()
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

function MF:SellGreys_OnUpdate(elapsed)
	self.Ticker = (self.Ticker or 0) + elapsed
	if self.Ticker >= 0.25 then
		if not MerchantFrame:IsVisible() or #self.Items == 0 then self:SetScript("OnUpdate", nil); MF:ReportSellGreys(); return end
			for k, v in pairs(self.Items) do
				if self.Count < 1 then
					-- Check again if the item really is a gray
					local link = GetContainerItemLink(v.bag, v.slot)
					local rarity
					if link then
						_, _, rarity = GetItemInfo(link)
						
						if rarity == 0 then
							self.Report[#self.Report + 1] = {["link"] = link, ["value"] = v.value, ["count"] = v.count}
							self.Reported = false
							
							UseContainerItem(v.bag, v.slot) -- Sell it
							table.remove(self.Items, k)
						end
					end
					
					self.Count = self.Count + 1
				else
					self.Count = 0
				end
			end
		
		self.Ticker = 0
	end
end

function MF:SellGreys(event)
	
	if event == "MERCHANT_SHOW" then
		if not MerchantFrame:IsVisible() then return end
		local rarity, itemType, stackPrice, stackCount
		for bag = 0,4 do
			for slot=0,GetContainerNumSlots(bag) do
				local link = GetContainerItemLink(bag, slot)
				if link then
					_, _, rarity, _, _, itemType, _, _, _, _, price = GetItemInfo(link)
					stackPrice = 0
					stackCount = 1
					if price then
						stackCount = select(2, GetContainerItemInfo(bag, slot)) or 1
						stackPrice = price * stackCount
					end
					if rarity == 0 and (itemType and itemType ~= "Quest") then
						table.insert(self.Items, {["bag"] = bag, ["slot"] = slot, ["value"] = stackPrice, ["count"] = stackCount})
					end
				end
			end
		end
		
		self.Reported = true -- Do not report if we didn't sell anything
		self:SetScript("OnUpdate", MF.SellGreys_OnUpdate)
	elseif event == "MERCHANT_CLOSED" then
		MF:ReportSellGreys()
		self:SetScript("OnUpdate", nil)
	end
end

function MF:LoadProfile()
	if self.db.autoSellGreys then
		if not self.SellGreysFrame:IsEventRegistered("MERCHANT_SHOW") then
			self.SellGreysFrame:RegisterEvent("MERCHANT_SHOW")
			self.SellGreysFrame:RegisterEvent("MERCHANT_CLOSED")
		end
	else
		self.SellGreysFrame:UnregisterEvent("MERCHANT_SHOW")
		self.SellGreysFrame:UnregisterEvent("MERCHANT_CLOSED")
	end
end

function MF:Construct()
	-- Autosell Greys
	self.SellGreysFrame = CreateFrame("Frame")
	self.SellGreysFrame.Items = {}
	self.SellGreysFrame.Report = {}
	self.SellGreysFrame.Reported = false
	self.SellGreysFrame.Count = 0
	self.SellGreysFrame:SetScript("OnEvent", MF.SellGreys)
end

function MF:Init()
	self.db = CO.db.profile.utility
	
	self:Construct()
	self:LoadProfile()
end

E:AddModule("Misc_Features", MF)