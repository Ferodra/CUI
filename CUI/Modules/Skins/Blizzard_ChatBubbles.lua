local E, L = unpack(select(2, ...)) -- Engine, Locale
local Module, CO = E:LoadModules("Blizzard_ChatBubbles", "Config")
Module.Autoload = true

local _
local tinsert 							= table.insert
local Ambiguate 						= Ambiguate
local GetPlayerInfoByGUID 				= GetPlayerInfoByGUID
local C_ChatBubbles_GetAllChatBubbles 	= C_ChatBubbles.GetAllChatBubbles

local MessageToSender 	= {}
local MessageToGUID 	= {}
Module.Frames = {}

Module.BackdropTemplate = {
	  bgFile = [[Interface\AddOns\CUI\Textures\borders\WHITE8X8]],
	  edgeFile = [[Interface\AddOns\CUI\Textures\borders\WHITE8X8]],
	  tile = true,
	  edgeSize = 1,
	  insets = { left = 0, right = 0, top = 0, bottom = 0 }
}

local NameStrBase = "|c%s %s |r"

function Module:LoadConfig()
	local Config = CO.db.profile.blizzard.chatBubbles
	
	self.BackdropTemplate.edgeSize = Config.borderSize
	self.BackdropColor = Config.backgroundColor -- For later and direct use
	self.BackdropBorderColor = Config.borderColor -- For later and direct use
	
	for _, Frame in pairs(self.Frames) do
		if Frame.BackdropFrame then
			-- We have to reset the backdrop to nil before changing anything, because it otherwise doesn't apply
			local BorderColor = {Frame.BackdropFrame:GetBackdropBorderColor()}
			Frame.BackdropFrame:SetBackdrop(nil)
			
			Frame.BackdropFrame:SetBackdrop(self.BackdropTemplate)
			Frame.BackdropFrame:SetBackdropColor(unpack(Config.backgroundColor))
			Frame.BackdropFrame:SetBackdropBorderColor(unpack(BorderColor))
		end
	end
end

-- Skinning function in AddOn Scope for easy override
function Module:SkinBubble(Frame, Holder)
	-- Skin on first call for this frame or when forced (Config Update)
	if not Frame.IsCUISkinned then
		
		local Holder = Frame:GetChildren()
		if not Holder or Holder:IsForbidden() then return end
		
		-- Setting up requires variables
		for _, region in pairs({Frame:GetRegions()}) do
			if region:IsObjectType('Texture') then
				region:SetTexture(nil)
			end
		end
		
		Holder:DisableDrawLayer('BORDER')
		
		Frame.BackdropFrame = E:CreateBackdropFrame("Frame", nil, Frame)
		Frame.BackdropFrame:SetAllPoints(Frame)
		Frame.BackdropFrame:SetBackdrop(self.BackdropTemplate)
		
		if not Frame.BackdropFrame then return end
		
		local Text = Holder.String or Frame.Text or Frame.BackdropFrame.String
		
		if not Text then return end
		
		Frame.Text = Text
		Frame.OverlayFrame = CreateFrame("Frame", "CUI_ChatBubblesOverlayFrame", Frame.BackdropFrame)
		Frame.OverlayFrame:SetAllPoints(true)
		
		-- Font that displays the sender's name
		Frame.Name = E:NewFontObject(nil, nil, Frame.OverlayFrame, 10)
		E:RegisterAutoFont(Frame.Name, "db.profile.blizzard.chatBubbles.name")
		E:RegisterAutoFont(Text, "db.profile.blizzard.chatBubbles.text")
		
		Frame.Holder = Holder
		
		Frame.IsCUISkinned = true
	end
	
	--[[-------------------
	--	UPDATING
	-------------------]]--
	
	Frame.BackdropFrame:SetBackdropColor(unpack(self.BackdropColor))
	local r,g,b = Frame.Holder.String:GetTextColor()
	Frame.BackdropFrame:SetBackdropBorderColor(r,g,b)
	
	local Msg = Frame.Holder.String:GetText()
	local Sender = MessageToSender[Msg]
	local GUID = MessageToGUID[Msg] -- This is nil for most or all NPC lines
	
	-- COLORING
	local Color
	if GUID and GUID ~= "" then
		local _, ClassName = GetPlayerInfoByGUID(GUID)
		if ClassName then
			Color = E:GetClassColorByClassName(ClassName)
		end
	end
	
	if Color then
		--Frame.Name:SetTextColor(unpack(Color))
		Frame.Color = E:RgbToHex(Color, true)
	else
		--Frame.Name:SetTextColor(1,1,1,1)
		Frame.Color = ""
	end
	
	Sender = Sender or "???"
	
	if Frame.Color ~= "" then
		Frame.Name:SetText(NameStrBase:format(Frame.Color, Sender))
	else
		Frame.Name:SetText(Sender)
	end
end

function Module:OnEvent(event, ...)
	self = self or Module
	
	for _, Frame in pairs(C_ChatBubbles_GetAllChatBubbles()) do
		if not E:TableContainsValue(self.Frames, Frame) then
			tinsert(self.Frames, Frame)
		end
		
		self:SkinBubble(Frame)
	end
end

-- Used for delaying the skinning function to the next frame[s].
local function OnUpdate(self, elapsed)
	self:OnEvent()
	
	-- Let it run for 0.25 seconds, just to be absolutely sure
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed >= 0.25 then
		self:SetScript("OnUpdate", nil)
		self.elapsed = 0
	end
end

-- Event Wrapper
local function OnEvent(self, event, Msg, Sender, _, _, _, _, _, _, _, _, _, GUID)
	if InCombatLockdown() or issecretvalue(Msg) or issecretvalue(Sender) or issecretvalue(GUID) then return end
	
	if Msg then
		if Sender then
			MessageToSender[Msg] = Ambiguate(Sender, "none")
		end
		MessageToGUID[Msg] = GUID
	end
	
	-------------------------
	
	-- Call on next frame, as the bubbles aren't available on the same frame as the event occured
	self:SetScript("OnUpdate", OnUpdate)
end

function Module:Construct()
	E:RegisterEvents(self, "PLAYER_ENTERING_WORLD", "CHAT_MSG_MONSTER_SAY", "CHAT_MSG_MONSTER_YELL", "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_MONSTER_PARTY", "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER")
	self:SetScript("OnEvent", OnEvent)
end

function Module:Init()
	self.db = CO.db.char.blizzard.chatBubbles
	E:RegisterFontExclusions("db.profile.blizzard.chatBubbles.text", {["position"] = true, ["width"] = true, ["height"] = true})
	
	if not self.db.enable then return end
	self:LoadConfig()
	self:Construct()
end

E:AddModule("Blizzard_ChatBubbles", Module)