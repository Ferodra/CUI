local E, L = unpack(select(2, ...)) -- Engine, Locale
local A, CO = E:LoadModules("Armory", "Config")

--[[--------------------
	Armory Extension	
--------------------]]--

local _
local Module = {}

local ScanTipTexturePath = E.ScanningTooltip:GetName() .. "Texture"
local EmptySocketString = "UI--EmptySocket"

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
	
	for i=1, MAX_NUM_SOCKETS do
		local GemTex = GetGemTexture(i)
		GemID = nil
		
		GemData[i] = {}
		
		if (type(GemTex) == "string" and GemTex:find(EmptySocketString)) then
			GemData[i].isEmpty = true
		elseif type(GemTex) == "number" then
			GemData[i].isEmpty = false
			GemID = GemTex
		else
			GemData[i].isEmpty = nil
		end
		
		GemData[i].Texture		= GemTex
		GemData[i].GemLink 		= select(2, GetItemGem(ItemLink, i))
		if GemData[i].GemLink then
			GemData[i].GemQuality 	= select(3, GetItemInfo(GemData[i].GemLink))
		end
	end
	
	E.ScanningTooltip:Release()
	
	return GemData
end

---------- Add Module
A.Modules["Gems"] = Module