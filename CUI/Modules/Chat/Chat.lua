local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO = E:LoadModules("Config")

local _
local _G = _G
local ChatFrame_ReplyTell		= ChatFrame_ReplyTell
local ChatEdit_UpdateHeader		= ChatEdit_UpdateHeader
local ChatMenu_SetChatType		= ChatMenu_SetChatType
local ChatEdit_ExtractChannel	= ChatEdit_ExtractChannel
local Module = {}
Module.Parent = CreateFrame("Frame", "ChatParent", E.Parent)
Module.Parent:SetSize(400, 120)
Module.E = CreateFrame("Frame")

local ICONS = {
	["DAMAGER"] = "|TInterface\\AddOns\\CUI\\Textures\\icons\\DAMAGER:0|t",
	["HEALER"] = "|TInterface\\AddOns\\CUI\\Textures\\icons\\HEALER:0|t",
	["TANK"] = "|TInterface\\AddOns\\CUI\\Textures\\icons\\TANK:0|t",
}
local ROLE_STR_BASE = "%s %s"

function Module:LoadConfig()
	self.db = CO.db.profile.chat
	
	--for _, FName in pairs(_G.CHAT_FRAMES) do
	--	local Frame = _G[FName]
	--	
	--	Frame:SetFont(E.Media:Fetch("font", self.db.fontType), select(2, Frame:GetFont()))
	--end
	
	self:InitMessageFilters()
end

local FilterEvents = {
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_BN_WHISPER",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_RAID_WARNING",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_INSTANCE_CHAT",
	"CHAT_MSG_INSTANCE_CHAT_LEADER",
	"CHAT_MSG_SAY",
	"CHAT_MSG_YELL",
}

function Module:InitMessageFilters()
	if not CO.db.profile.chat.showRoles or self.FiltersInitialized then return end
	
	for _, event in pairs(FilterEvents) do
		ChatFrame_AddMessageEventFilter(event, self.ApplyMessageFilter)
	end
	
	self.FiltersInitialized = true
end

local UnitFormat = '%s-%s'
local function IsUnitMessageAuthor(Author, Unit)
	local Name, Realm = UnitFullName(Unit)
	
	if Name and not Realm or (Realm and Realm == '') then
		Realm = GetRealmName()
	end
	-- @TODO: Add exception for players on same realmpool
	if not Name or not Realm then return false end
	if (UnitFormat):format(Name, Realm) == Author then
		return true
	end
	return false
end

function Module:SetRoleIcon(msg, author)
	if not CO.db.profile.chat.showRoles then return msg end
	
	local Role
	
	if (IsInRaid() or IsInGroup() or IsPartyLFG()) then
		local Unit = "raid"
		
		if IsInGroup() or IsPartyLFG() then
			Unit = "party"
		end
		
		if IsUnitMessageAuthor(author, "player") then
			Role = UnitGroupRolesAssigned("player")
		elseif UnitExists(Unit .. 1) then
			for i=1, 40 do				
				if IsUnitMessageAuthor(author, Unit .. i) then
					Role = UnitGroupRolesAssigned(Unit .. i)
					break
				end
			end
		end
	end
	
	if Role and Role ~= "NONE" and ICONS[Role] then
		msg = ICONS[Role] .. " " .. msg
	end
	
	return msg
end

function Module:PrintURL(Url)
	return "|cFFFFFFFF[|Hurl:"..Url.."|h"..Url.."|h]|r "
end

-- Return values:
--		bDiscardMessage, Message, Author, ...
function Module:ApplyMessageFilter(event, msg, author, ...)
	msg = Module:SetRoleIcon(msg, author)
	
	-- http://example.com
	local newMsg, found = gsub(msg, "(%a+)://(%S+)%s?", Module:PrintURL("%1://%2"))
	if found > 0 then return false, newMsg, author, ... end
	
	return false, msg, author, ...
end

local function Editbox_UpdateHeader(self)
	local chatType = self:GetAttribute("chatType")
	if not chatType then return end

	local ChatTypeInfo 	= _G.ChatTypeInfo
	
	if not self.CustomBackdrop then
		if E.IsRetail then
			self.CustomBackdrop = E:CreateBackdropFrame("Frame", nil, self)
			self.CustomBackdrop:SetAllPoints(self)
		else
			self.CustomBackdrop = self
		end
	end
	
	self.CustomBackdrop:SetBackdrop({ edgeFile = [[Interface/AddOns/CUI/Textures/borders/WHITE8X8]], edgeSize = 1, tile = true})
	E:SetFrameBorder(self.CustomBackdrop, 1)
	
	local header = _G[self:GetName().."Header"]
	self.CustomBackdrop:SetBackdropBorderColor(header:GetTextColor())
	--self.CustomBackdrop:SetBackdropBorderColor(info.r, info.g, info.b)
end
hooksecurefunc("ChatEdit_UpdateHeader", Editbox_UpdateHeader)

local function SetChatType(self, type, target)
	if type ~= "REPLY" then
		self:SetAttribute("channelTarget", target)
		self:SetAttribute("chatType", type)
	else
		ChatFrame_ReplyTell(self:GetParent().chatFrame)
	end
	
	ChatEdit_UpdateHeader(self)
	Editbox_UpdateHeader(self)
end

local function Editbox_OnKeyDown(self, key)
	if key == "TAB" then
		-- General Channels can be retrieved with GetChannelList()
		-- self:SetText() can be used to replace the input content
		local Channel
		
		Module:UpdateChannelList()
		
		-- Get current channel from chat API
		local CurrentChannelType = self:GetAttribute("chatType")
		local CurrentChannelTarget = self:GetAttribute("channelTarget")
		
		for k,v in pairs(Module.channelList) do
			if v.channelType == CurrentChannelType then
				if v.channelTarget == CurrentChannelTarget then
					self.currentChannel = k
				end
			end
		end
		
		-- Increment/Decrement to next channel for next call
		if IsShiftKeyDown() then
			-- We need some more logic here
			if self.currentChannel - 1 < 1 then
				self.currentChannel = #Module.channelList
			else
				self.currentChannel = self.currentChannel - 1
			end
		else
			self.currentChannel = self.currentChannel + 1
		end
		
		if self.currentChannel > #Module.channelList then
			self.currentChannel = 0
		end
		
		Channel = Module.channelList[self.currentChannel]
		if not Channel then
			-- If we reached the end, start over
			self.currentChannel = 1
			Channel = Module.channelList[1]
		end
		
		SetChatType(self, Channel.channelType, Channel.channelTarget)
		
		if Module.channelList[self.currentChannel + 1] and Module.channelList[self.currentChannel + 1].isHidden == true then
			-- Failsafe if every channel is disabled - to prevent game crash/freeze
			if E:TableContainsValue(Module.channelList, false, "boolean") then
				-- Call again
				Editbox_OnKeyDown(self, key)
			end
		end
	end
end

function Module:UpdateHeader()
	local editbox, header, headerSuffix, focus, text
	
	for _, frameName in pairs(CHAT_FRAMES) do
		editbox = _G[frameName..'EditBox']
		header = _G[frameName..'EditBoxHeader']
		headerSuffix = _G[frameName..'EditBoxHeaderSuffix']
		focus = _G[frameName..'EditBoxFocusLeft']
		
		if header then
			text = header:GetText()
			if text and not text:find('%[') then
				header:SetText(("[%s]: "):format(((text:gsub('%s', '')):gsub(':', ''))))
				
				editbox:SetTextInsets(15 + header:GetWidth() + (headerSuffix:IsShown() and headerSuffix:GetWidth() or 0), 13, 0, 0);
				header:SetJustifyH("LEFT")
				
				headerSuffix:Hide()
			end
		end
	end
end

function Module:UpdateEditbox(editbox)
	
	if not editbox then return end
	
	local chatFrame = editbox.chatParent
	
	-- @TODO: Config
	editbox:SetAltArrowKeyMode(false)
	editbox:ClearAllPoints()
	editbox:SetPoint("TOP", chatFrame, "BOTTOM", 0, -10)
	editbox:SetSize(chatFrame:GetWidth(), 20)
	
	if not editbox.styled then
		local a, b, c = select(6, editbox:GetRegions())
		a:SetTexture(nil); b:SetTexture(nil); c:SetTexture(nil)
		_G[format(editbox:GetName().."Left", id)]:SetTexture(nil)
		_G[format(editbox:GetName().."Mid", id)]:SetTexture(nil)
		_G[format(editbox:GetName().."Right", id)]:SetTexture(nil)
		
		editbox.Background = editbox:CreateTexture(nil, "BACKGROUND")
		editbox.Background:SetAllPoints(editbox)
		editbox.Background:SetTexture(130937) -- Interface\\ChatFrame\\ChatFrameBackground - it didn't like the path. Rip
		editbox.Background:SetVertexColor(0,0,0, 0.65)
		
		--E:SetFrameBorder(editbox.CustomBackdrop, 1)
		
		--------------------------------------------------------------------------------------------------------------
		--	TAB Channel iterator 
		--------------------------------------------------------------------------------------------------------------
		editbox.currentChannel = 1
		
		editbox:SetScript("OnKeyDown", Editbox_OnKeyDown)
		
		editbox.styled = true
	end
end

-- Wrapper to update all editboxes at once
function Module:UpdateEditboxes()
	for _, frameName in pairs(CHAT_FRAMES) do
		self:UpdateEditbox(_G[frameName..'EditBox'])
	end
end

function Module:SetupChat()
	self = Module
	
	local id, width, height
	self.channelList = {}
		
	for _, frameName in pairs(CHAT_FRAMES) do
		local frame = _G[frameName]
		local editbox = _G[frameName..'EditBox']
		id = frame:GetID();
		width, height = frame:GetSize()
		
		-- We have to re-parent every chat tab to position them unfortunately. Thanks blizz :c
		if id < 2 and not (id > NUM_CHAT_WINDOWS) then
			--frame:ClearAllPoints()
			--frame:SetPoint("BOTTOMLEFT", self.Parent, "BOTTOMLEFT")
			
			-- Just call when we have a valid position that won't cause errors
			--if frame:GetLeft() then
			--	FCF_SavePositionAndDimensions(frame)
			--end
		end
		--frame:SetParent(self.Parent)
		
		if not frame.SizeHooked then
			frame:HookScript("OnSizeChanged", function(_, width, height)
				self.Parent:SetSize(width, height)
			end)
			frame.SizeHooked = true
		end
		
		
		-- When frame is not docked, let the api control its position
		if frame:IsMovable() then
			frame:SetUserPlaced(true)
		end
		
		editbox.chatParent = frame
		self:UpdateEditbox(editbox)
		
		frame:SetClampedToScreen(false)
	end
	
	self.Parent:SetSize(width, height)
	
	if not self.TempHook then
		hooksecurefunc('FCF_OpenTemporaryWindow', self.SetupChat)
		self.TempHook = true
	end
	
	if not self.Initialized then
		--E:CreateMover(self.Parent, L["chatFrame"], nil, nil, nil, nil, "misc")
		
		self.Initialized = true
	end
end

function Module:UpdateFont(frame, size)
	if not frame then
		frame = FCF_GetCurrentChatFrame()
	end
	if not size then
		size = self.value
	end
	
	-- Set all the other frames to the same size.
	frame:SetFont(E.Media:Fetch("font", Module.db.fontType), size, "")
end

function Module:AddToChannelList(type, target, isHidden)
	self.channelList[#self.channelList + 1] = {
		["channelType"] = type,
		["channelTarget"] = target,
		["isHidden"] = isHidden or false
	}
end


function Module:UpdateChannelList()
	wipe(self.channelList)
	--self.channelList = {GetChannelList()}
	
	self:AddToChannelList("SAY")
	-- Module:AddToChannelList("y", "Yell")
	
	if ChatEdit_GetLastTellTarget() then
		self:AddToChannelList("REPLY")
	end
	if IsInGuild() then
		self:AddToChannelList("GUILD")
	end
	if UnitInParty("player") then
		self:AddToChannelList("PARTY")
	end
	if IsInInstance() then
		self:AddToChannelList("INSTANCE_CHAT")
	end
	if UnitInRaid("player") then
		self:AddToChannelList("RAID")
		
		if UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
			self:AddToChannelList("RAID_WARNING")
		end
	end
	
	-- Build a usable channel table
	local RawChannelList = {GetChannelList()}
	local ChannelList = {}
	for index, v in pairs(RawChannelList) do
		if index % 3 == 1 then
			ChannelList[v] = {
				["name"] = RawChannelList[index+1],
				["isHidden"] = RawChannelList[index+2]
			}
		end
	end
	
	for k, info in pairs(ChannelList) do
		if not info.isHidden then
			self:AddToChannelList("CHANNEL", k)
		end
	end
end

function Module:SetupLinkFrame()
	
	local FrameName, InputName, ButtonName = 'CUI_ChatLinkCopyFrame', 'CUI_ChatLinkCopyInput', 'CUI_ChatLinkCopyClose'
	
	local Frame = CreateFrame('Frame', FrameName, E.Parent, 'UIPanelDialogTemplate')
	self.URLFrame = Frame
	
	Frame.Label = E:NewFont(nil, nil, Frame)
	Frame.Description = E:NewFont(nil, nil, Frame)
	Frame.Input = CreateFrame('EditBox', InputName, Frame, 'InputBoxTemplate')
	Frame.Close = CreateFrame('Button', ButtonName, Frame, 'UIPanelButtonTemplate')
	
	Frame:SetPoint('TOP', E.Parent, 'TOP', 0, -120)
	Frame:SetSize(450, 128)
	
	Frame.Label:ClearAllPoints()
	Frame.Label:SetPoint('TOP', Frame, 'TOP', 0, -7)
	
	Frame.Description:ClearAllPoints()
	Frame.Description:SetPoint('TOPLEFT', Frame, 'TOPLEFT', 20, -40)
	
	Frame:EnableMouse(true)
	Frame:SetMovable(true)
	Frame:SetUserPlaced(true)
	Frame:RegisterForDrag("LeftButton")
	Frame:SetScript("OnDragStart", Frame.StartMoving)
	Frame:SetScript("OnDragStop", Frame.StopMovingOrSizing)
	Frame:SetScript("OnHide", Frame.StopMovingOrSizing)
	
	--Frame:SetScript
	
	E:SetFontInfo(Frame.Label, nil, nil, 12, {255, 215, 0})
	E:SetFontInfo(Frame.Description, nil, nil, 11, {0, 191, 255})
	E:UpdateFont(Frame.Label, Frame.Description)
	
	Frame.Input:SetPoint('BOTTOM', Frame, 'BOTTOM', 0, 45)
	Frame.Input:SetSize(400, 20)
	Frame.Input:SetAutoFocus(false)
	Frame.Input:SetScript('OnCursorChanged', function(self)
		self:HighlightText()
	end)
	Frame.Input:SetScript('OnTextChanged', function(self)
		self:SetText(self.CachedText)
		self:HighlightText()
	end)
	Frame.Input:SetScript('OnKeyDown', function(self, key)
		if key == 'ESCAPE' or key == 'ESC' then
			Frame:Hide()
		end
		
		local CtrlDown = IsControlKeyDown()
		if not CtrlDown then
			self:ClearFocus()
		end
		
		self:SetPropagateKeyboardInput(not CtrlDown)
	end)
	
	Frame.Close.Text = _G[ButtonName .. "Text"]
	Frame.Close:SetPoint('BOTTOM', Frame, 'BOTTOM', 0, 10)
	Frame.Close:SetSize(256, 20)
	Frame.Close:SetScript('OnClick', function()
		Frame:Hide()
	end)
	
	-- TEXTS
	Frame.Close.Text:SetText(CLOSE)
	Frame.Label:SetText('Copy Link')
	Frame.Description:SetText('To copy the Link, press CTRL+C')
end

function Module:ShowLink(url)
	if not self.URLFrame then
		self:SetupLinkFrame()
	end
	
	self.URLFrame.Input.CachedText = url
	self.URLFrame.Input:SetText(url)
	self.URLFrame.Input:SetFocus()
	self.URLFrame.Input:HighlightText()
	
	self.URLFrame:Show()
end

--Module:ShowLink("aa")

local function HyperLinkedURL(data)
	if strsub(data, 1, 3) == "url" then
		local currentLink = strsub(data, 5)
		if currentLink and currentLink ~= "" then
			Module:ShowLink(currentLink)
		end
	end
end

local SetHyperlink = _G.ItemRefTooltip.SetHyperlink
function _G.ItemRefTooltip:SetHyperlink(data, ...)
	if strsub(data, 1, 3) == "url" then
		HyperLinkedURL(data)
	else
		SetHyperlink(self, data, ...)
	end
end

function Module:Init()
	
	self.db = CO.db.profile.chat
	
	Module.E:RegisterEvent('UPDATE_CHAT_WINDOWS', 'SetupChat')
	Module.E:RegisterEvent('UPDATE_FLOATING_CHAT_WINDOWS', 'SetupChat')
	hooksecurefunc('FCF_SetChatWindowFontSize', Module.UpdateFont)
	
	if _G.WIM then
		_G.WIM.RegisterWidgetTrigger("chat_display", "whisper,chat,w2w,demo", "OnHyperlinkClick", function(frame) Module.clickedframe = frame end);
		_G.WIM.RegisterItemRefHandler('url', HyperLinkedURL)
	end
	
	self:SetupChat()
	self:LoadConfig()
end

E:AddModule("Chat", Module)