local E, L = unpack(select(2, ...)) -- Engine, Locale
local L, CO = E:LoadModules("Locale", "Config")

local _
local C = {}
C.Parent = CreateFrame("Frame", "ChatParent")
C.E = CreateFrame("Frame")

local ICONS = {
	["DAMAGER"] = "|TInterface\\AddOns\\CUI\\Textures\\icons\\DAMAGER:0|t",
	["HEALER"] = "|TInterface\\AddOns\\CUI\\Textures\\icons\\HEALER:0|t",
	["TANK"] = "|TInterface\\AddOns\\CUI\\Textures\\icons\\TANK:0|t",
}
local ROLE_STR_BASE = "%s %s"

function C:LoadProfile()
	self.db = CO.db.profile.chat
	
	for _, FName in pairs(_G.CHAT_FRAMES) do
		local Frame = _G[FName]
		
		Frame:SetFont(E.Media:Fetch("font", self.db.fontType), select(2, Frame:GetFont()))
	end
	
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
	"CHAT_MSG_INSTANCE_CHAT",
	"CHAT_MSG_INSTANCE_CHAT_LEADER",
	"CHAT_MSG_SAY",
	"CHAT_MSG_YELL",
}

function C:InitMessageFilters()
	
	if not CO.db.profile.chat.showRoles then return end
	if self.FiltersInitialized then return end
	
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
	
	if not Name or not Realm then return false end
	if (UnitFormat):format(Name, Realm) == Author then
		return true
	end
	return false
end

function C:SetRoleIcon(msg, author)
	if not CO.db.profile.chat.showRoles then return msg end
	
	local Role = UnitGroupRolesAssigned(author)
	
	if (not Role or (Role and Role == "NONE")) and (IsInRaid() or IsInGroup() or IsPartyLFG()) then
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

-- Return values:
--		bDiscardMessage, Message, Author, ...
function C:ApplyMessageFilter(event, msg, author, ...)
	
	msg = C:SetRoleIcon(msg, author)
	
	return false, msg, author, ...
end

local function Editbox_OnKeyDown(self, key)
	if key == "TAB" then
		-- General Channels can be retrieved with GetChannelList()
		-- self:SetText() can be used to replace the input content
		
		C:UpdateChannelList()
		
		self.channelID = C.channelList[self.currentChannel]
		if not self.channelID then
			-- If we reached the end, start over
			self.currentChannel = 1
			self.channelID = C.channelList[1]
		end
		
		if self.channelID and C.channelList[self.currentChannel + 2] == false then
			self:SetText("/" .. self.channelID .. " " .. self:GetText())
		end
			
		self.currentChannel = self.currentChannel + 3
			
		if C.channelList[self.currentChannel + 2] == true then
			-- Failsafe if every channel is disabled - to prevent game crash/freeze
			if E:tableContainsValue(C.channelList, false, "boolean") then
				-- Call again
				Editbox_OnKeyDown(self, key)
			end
		end
	end
end

function C:UpdateHeader()
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

function C:SetupChat()
	local frame, editbox, id
	self.channelList = {}
		
	for _, frameName in pairs(CHAT_FRAMES) do
		frame = _G[frameName]
		editbox = _G[frameName..'EditBox']
		id = frame:GetID();
	
		C.Parent:SetSize(frame:GetSize())
		frame:SetParent(C.Parent)
		
		-- We have to re-parent every chat tab to position them unfortunately. Thanks blizz :c
		frame:ClearAllPoints()
		frame:SetAllPoints(C.Parent)
		
		editbox:SetAltArrowKeyMode(false)
		local a, b, c = select(6, editbox:GetRegions())
		a:SetTexture(nil); b:SetTexture(nil); c:SetTexture(nil)
		_G[format(editbox:GetName().."Left", id)]:SetTexture(nil)
		_G[format(editbox:GetName().."Mid", id)]:SetTexture(nil)
		_G[format(editbox:GetName().."Right", id)]:SetTexture(nil)
		
		editbox:ClearAllPoints()
		editbox:SetPoint("TOP", frame, "BOTTOM", 0, -10)
		editbox:SetSize(frame:GetWidth(), 20)
		
		editbox.Background = editbox:CreateTexture(nil, "BACKGROUND")
		editbox.Background:SetAllPoints(editbox)
		editbox.Background:SetTexture(130937) -- Interface\\ChatFrame\\ChatFrameBackground - it didn't like the path. Rip
		editbox.Background:SetVertexColor(0,0,0, 0.65)
		
		--------------------------------------------------------------------------------------------------------------
		--	TAB Channel iterator 
		--------------------------------------------------------------------------------------------------------------
		editbox.currentChannel = 1
		editbox.channelID = "s"
		
		editbox:SetScript("OnKeyDown", Editbox_OnKeyDown)
		--hooksecurefunc("ChatEdit_UpdateHeader", C.UpdateHeader) -- Post show
		
		frame:SetClampedToScreen(false)
	end
	
	E:CreateMover(self.Parent, L["chatFrame"])
end

function C:UpdateFont(frame, size)
	if not frame then
		frame = FCF_GetCurrentChatFrame()
	end
	if not size then
		size = self.value
	end
	
	-- Set all the other frames to the same size.
	frame:SetFont(E.Media:Fetch("font", C.db.fontType), size)
end

function C:AddToChannelList(str, name)
	self.channelList[#self.channelList + 1] = str
	self.channelList[#self.channelList + 1] = name
	self.channelList[#self.channelList + 1] = false
end


function C:UpdateChannelList()
	wipe(self.channelList)
	--self.channelList = {GetChannelList()}
	for k,v in pairs({GetChannelList()}) do
		self.channelList[#self.channelList + 1] = v
	end
	
	C:AddToChannelList("s", "SAY")
	-- C:AddToChannelList("y", "Yell")
	
	if ChatEdit_GetLastTellTarget() then
		C:AddToChannelList("r", "REPLY")
	end
	if IsInGuild() then
		C:AddToChannelList("g", "GUILD")
	end
	if UnitInParty("player") then
		C:AddToChannelList("p", "PARTY")
	end
	if IsInInstance() then
		C:AddToChannelList("i", "INSTANCE_CHAT")
	end
	if UnitInRaid("player") then
		C:AddToChannelList("ra", "RAID")
		
		if UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
			C:AddToChannelList("rw", "RAID_WARNING")
		end
	end
	--table.insert(self.channelList, {GetChannelList()})
end

function C:Init()
	
	self.db = CO.db.profile.chat
	
	C.E:RegisterEvent('UPDATE_CHAT_WINDOWS', 'SetupChat')
	C.E:RegisterEvent('UPDATE_FLOATING_CHAT_WINDOWS', 'SetupChat')
	hooksecurefunc('FCF_SetChatWindowFontSize', C.UpdateFont)
	
	self:SetupChat()
	self:LoadProfile()
end

E:AddModule("Chat", C)