local E, L = unpack(CUI) -- Engine
local CO = E:LoadModules("Config")
local ST = select(2, ...)

local AceGUI = LibStub("AceGUI-3.0")
local PT = ST.PlayTime
local Module = CreateFrame("Frame")
local gui = ST.GUI

local CharsToRemove = {}
local function SetCharKeyToRemove(key)
	if not CharsToRemove[key] then
		-- Add on first call for this key
		CharsToRemove[key] = true
	else
		-- Remove when called again for this key
		CharsToRemove[key] = nil
	end
end

local function GetCharsToRemoveNum()
	local Count = 0
	for k,v in pairs(CharsToRemove) do
		if v then
			Count = Count + 1
		end
	end
	
	return Count
end

function PT:UpdateAllWidgets(forceUpdateButtonText)
	if not self.DeleteChar or not gui.isShown then return end
	
	if forceUpdateButtonText ~= false then
		local NewText = forceUpdateButtonText or (GetCharsToRemoveNum() > 0 and "Remove Characters" or "Update")
		self.UpdateBtn:SetText(NewText)
		self.UpdateBtn:SetUserData("Text", NewText)
	end
	
	self.DeleteChar:SetList(self:GetAllCharacters())
	self.CharList:SetText(self:GetCharacterList())
	self.Total:SetText(self:GetTotalPlaytime())
	self.UpdateBtn:SetDisabled(not ST.db.global.timePlayed.enable)
end

local function Callback(widget, event, value)
	
	local UpdateBtn, DeleteChar, Total, CharList
	wipe(CharsToRemove)
	
	local enable = AceGUI:Create("CheckBox")
	enable:SetLabel(L["EnableLogging"])
	enable:SetValue(ST.db.global.timePlayed.enable)
	enable:SetRelativeWidth(0.2)
	enable:SetCallback('OnValueChanged', function(self, event, value)
		ST.db.global.timePlayed.enable = value
		PT:LoadConfig()
		
		UpdateBtn:SetDisabled(not value)
	end)
	
	DeleteChar = AceGUI:Create("Dropdown")
	DeleteChar:SetLabel(L["RemoveCharacter"])
	DeleteChar:SetMultiselect(true)
	DeleteChar:SetCallback('OnValueChanged', function(self, event, value)
		SetCharKeyToRemove(value)
		
		if GetCharsToRemoveNum() > 0 then
			UpdateBtn:SetText("Remove Characters")
			UpdateBtn:SetUserData("Text", "Remove Characters")
			UpdateBtn:SetDisabled(false)
		else
			UpdateBtn:SetText("Update")
			UpdateBtn:SetUserData("Text", "Update")
			UpdateBtn:SetDisabled(not ST.db.global.timePlayed.enable)
		end
	end)
	
	UpdateBtn = AceGUI:Create("Button")
	UpdateBtn:SetText("Update")
	UpdateBtn:SetRelativeWidth(0.35)
	UpdateBtn:SetCallback('OnClick', function(self)
		if GetCharsToRemoveNum() > 0 then
			for key,_ in pairs(CharsToRemove) do
				PT:RemoveCharacter(key)
			end
			
			wipe(CharsToRemove)
			self:SetText("Update")
			self:SetUserData("Text", "Update")
		else
			PT:PerformRequest()
			self:SetText(". . .")
			self:SetUserData("Text", ". . .")
		end
		
		self:SetDisabled(not ST.db.global.timePlayed.enable or self:GetUserData("Text") == ". . .")
	end)
	
	local header = AceGUI:Create("Heading")
	header:SetText(L["YourPlaytime"])
	header:SetFullWidth(true)
	
	Total = AceGUI:Create("Label")
	Total:SetFontObject(GameFontHighlight)
	Total:SetRelativeWidth(0.65)
	
	
	local charHeader = AceGUI:Create("Heading")
	charHeader:SetText(L["CharacterPlaytime"])
	charHeader:SetFullWidth(true)
	
	CharList = AceGUI:Create("Label")
	CharList:SetFontObject(GameFontHighlight)
	CharList:SetFullWidth(true)
	
	PT.UpdateBtn = UpdateBtn
	PT.Total = Total
	PT.CharList = CharList
	PT.DeleteChar = DeleteChar
	
	PT:UpdateAllWidgets()
	widget:AddChildren(enable, DeleteChar, UpdateBtn, header, Total, charHeader, CharList)
end

function Module:Init()
	gui:AddToTree("Play Time", "playtime", true, Callback)
end

gui:RegisterStatModule("playtime", Module)