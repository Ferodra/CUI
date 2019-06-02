local E, L = unpack(select(2, ...)) -- Engine, Locale
local A, CO = E:LoadModules("Armory", "Config")

--[[--------------------
	Armory Extension	
--------------------]]--

local _
local Module = {}

local ScanTipTexturePath = "CUI_ArmoryScanningTooltipTexture"
local EmptySocketString = "UI--EmptySocket"

-----------------------------------------

function Module:GetInfo(ItemLink)
	
	A:PrepareScanTooltip(true, true)
	A.ScanTip:SetHyperlink(ItemLink)
	
	local GemData = {}
	
	for i=1, MAX_NUM_SOCKETS do
		local GemTex = _G[ScanTipTexturePath .. i]:GetTexture()
		
		GemData[i] = {}
		
		if (type(GemTex) == "string" and GemTex:find(EmptySocketString)) then
			GemData[i].isEmpty = true
		elseif type(GemTex) == "number" then
			GemData[i].isEmpty = false
		else
			GemData[i].isEmpty = nil
		end
		
		GemData[i].Texture = GemTex
	end
	
	A:ReleaseScanTooltip()
	
	return GemData
end

---------- Add Module
A.Modules["Gems"] = Module