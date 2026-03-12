local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO = E:LoadModules('Config')

--[[-------------------------------------------------
	
	This part of the CUI API is responsible
	to handle Item Tooltip Scanning and making
	it much easier.
	
	
	The only method you're required to use actively is
	"GetData".
	
	Usage:
	E.ScanningTooltip:GetData(...)
	
-------------------------------------------------]]--
local _G 							= _G
local GameTooltip_SetDefaultAnchor 	= GameTooltip_SetDefaultAnchor
---------------------------------------------------

local TooltipName = "CUI_ItemScanningTooltip"
E.ScanTipName = TooltipName

E.ScanningTooltip = CreateFrame("GameTooltip", TooltipName, nil, "GameTooltipTemplate")
local Prototype = E.ScanningTooltip

-- Sets up the Tooltip object
function Prototype:Prepare(Clear, Hide)	
	GameTooltip_SetDefaultAnchor(self, E.Parent)
	self:SetOwner(E.Parent, "ANCHOR_NONE")
	
	self:Release(Clear, Hide)
end

-- Wrapper Function to clean and hide the Tooltip for later use
function Prototype:Release(Clear, Hide)
	-- Force both when no value is given
	if not Clear and not Hide then Clear = true; Hide = true; end
	
	if Clear then self:Clear(self) end
	if Hide then self:Hide() end
end

-- Actually clears the Tooltip
function Prototype:Clear()
	self:ClearLines()
	for i = 1, 10 do
		_G[TooltipName..'Texture'..i]:SetTexture(nil)
	end
end

---------------
--	Core function of this API
--	
--	By using a search pattern, or searching for simple strings
--	it iterates through the lines to find the desired result.

--	@ItemLink[Str]: 	An ItemLink to fill the Tooltip with. Can also be another type that is accepted by SetHyperlink
-- 	@Search[Str]:		What string/pattern to look out for
-- 	@Match[Str]:		(Optional) A String/Pattern we want to match against
-- 	@ForceStart[Int]:	(Optional) Starting Line for Scanning
-- 	@ForceEnd[Int]:		(Optional) End Line for Scanning

---------------
function Prototype:GetData(ItemLink, Search, Match, ForceStart, ForceEnd)
	
	local Result, Current
	Match = Match or Search
	
	self:SetOwner(E.Parent, "ANCHOR_NONE")
	self:SetHyperlink(ItemLink)
	
	for i = (ForceStart or 1), (ForceEnd or self:NumLines()) do
		Current = _G[TooltipName .. "TextLeft" .. i]
		if not Current then break end
		
		Current = Current:GetText()
	  
		if Current:find(Search) then
			Result = (Current):match(Match)
			break
		end
	end
	
	self:Release()
	return Result
end

---------------
--	Second core function of this API
--	
--	Scans the specified [Bag] [Slot] Item for an Search String
--	Useful for checking for soulbound items, uncollected transmog, etc.

--	@Bag[Int]: 			Bag Index
-- 	@Slot[Int]:			Bag Slot
-- 	@SearchStr[Str]:	What EXACT string to look out for (No patterns!)
-- 	@ForceStart[Int]:	(Optional) Starting Line for Scanning
-- 	@ForceEnd[Int]:		(Optional) End Line for Scanning

---------------
-- Bag Items are a bit special. We have to use the SetBagitem method to retrieve real data.
-- Scanning Hyperlinks for an Soulbound or Transmog check generally returns false negatives,
--  as those data of course only exist for bag or equipped items
function Prototype:ScanBagItem(Bag, Slot, SearchStr, ForceStart, ForceEnd)
    self:SetOwner(E.Parent, "ANCHOR_NONE")
    self:SetBagItem(Bag, Slot)
    self:Show()
	
	local Result, Current
    for i = (ForceStart or 1), (ForceEnd or self:NumLines()) do
		Current = _G[TooltipName .. "TextLeft" .. i]
		if not Current then break end
		
        if Current:GetText() == SearchStr then
            Result = true
			break
        end
    end
    
	self:Release()
    return Result
end

function Prototype:GetAllInventoryItemLines(SlotID)
    self:SetOwner(E.Parent, "ANCHOR_NONE")
    self:SetInventoryItem("player", SlotID)
    self:Show()
	
	local Lines = ""
	local Current
    for i = 1, (ForceEnd or self:NumLines()) do
		Current = _G[TooltipName .. "TextLeft" .. i]
		
		if Current and Current:GetText() then
			Lines = Lines .. Current:GetText() .. "\n"
		else
			break
		end
    end
    
	self:Release()
    return Lines
end

do
	Prototype:Prepare()
end