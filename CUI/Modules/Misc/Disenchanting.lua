local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, Module = E:LoadModules("Config", "Disenchanting")
Module.Autoload = true

local GetItemInfo			= GetItemInfo
local GetContainerItemLink	= C_Container and C_Container.GetContainerItemLink or GetContainerItemLink
local GetContainerItemInfo	= C_Container and C_Container.GetContainerItemInfo or GetContainerItemInfo
local GetContainerNumSlots	= C_Container and C_Container.GetContainerNumSlots or GetContainerNumSlots
local UseContainerItem		= C_Container and C_Container.UseContainerItem or UseContainerItem

function Module:GetDisenchantItems()
	local Items = {}
	
	
	
	local Link
	for bag = 0,4 do
		for slot = 0, GetContainerNumSlots(bag) do
			Link = GetContainerItemLink(bag, slot)
			if Link then
				--_, _, rarity, _, _, itemType, _, _, itemEquipLoc, _, price, _, _, bindType = GetItemInfo(Link)
				print(GetItemInfo(Link))
				if true then return end
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
	
	return Items
end

local function OnEvent(self, event, ...)
	print(...)
end
function Module:Construct()
	local Frame = CreateFrame("Frame", "CUI_DisenchantingFrame", E.Parent)
	--Frame:RegisterEvent("CURRENT_SPELL_CAST_CHANGED")
	--Frame:SetScript("OnEvent", OnEvent)
	
	self.Frame = Frame
	self:GetDisenchantItems()
end

function Module:Init()
	-- Not working on this module until we find a good way to get an
	-- items' disenchantable state
	
	--self:Construct()
	--self:LoadConfig()
end

E:AddModule("Disenchanting", Module)