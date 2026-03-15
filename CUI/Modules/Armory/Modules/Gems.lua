local E, L = unpack(select(2, ...)) -- Engine, Locale
local A, CO = E:LoadModules("Armory", "Config")

--[[--------------------
	Armory Extension	
--------------------]]--

local _
local Module = {}
local GetItemNumSockets = C_Item and C_Item.GetItemNumSockets -- args: (itemLink)
local GetSocketGem		= C_TooltipInfo.GetSocketGem -- args: (index)
local GetItemGem		= C_Item and C_Item.GetItemGem -- args: (hyperlink, index)
local GetItemInfo		= C_Item and C_Item.GetItemInfo

local ScanTipTexturePath = E.ScanningTooltip:GetName() .. "Texture"
local EmptySocketString = "UI--EmptySocket"
local EmptySocketTexture = 'Interface/Addons/CUI/Textures/icons/UI-EmptySocket'

-----------------------------------------

local function GetGemTexture(index)
	return _G[ScanTipTexturePath .. index]:GetTexture()
end

function Module:Slot_OnEnter()
	if self.GemLink then
		GameTooltip:SetOwner(self)
		
		GameTooltip:SetHyperlink(self.GemLink)
		
		GameTooltip:Show()
	end
end

function Module:Slot_OnLeave()
	GameTooltip:Hide()
end

function Module:Slot_OnClick(Button)
	if self.GemLink then
		if Button == "LeftButton" and IsShiftKeyDown() then
			HandleModifiedItemClick(self.GemLink)
		end
	end
end

function Module:GetInfo(ItemLink)
	
	E.ScanningTooltip:Prepare(true, true)
	E.ScanningTooltip:SetHyperlink(ItemLink)
	
	local GemData = {}
	
	local NumSockets = GetItemNumSockets(ItemLink)
	local GemInfo
	for i=1, MAX_NUM_SOCKETS do
		GemInfo = nil
		if not GemData[i] then
			GemData[i] = {}
		end

		GemData[i].GemLink = select(2, GetItemGem(ItemLink, i))
		if i <= NumSockets then
			GemData[i].isEmpty = GemData[i].GemLink == true
		else
			GemData[i].isEmpty = nil
		end
		
		if GemData[i].GemLink then
			GemInfo = {GetItemInfo(GemData[i].GemLink)}
			GemData[i].GemQuality = select(3, unpack(GemInfo))
		end
		GemData[i].Texture = GemInfo and select(10, unpack(GemInfo)) or EmptySocketTexture
		print(GemInfo, GemInfo and select(10, unpack(GemInfo)), ItemLink, GemData[i].Texture)
	end
	
	E.ScanningTooltip:Release()
	
	return GemData
end

---------- Add Module
A.Modules["Gems"] = Module