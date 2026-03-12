local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, COMM = E:LoadModules("Config", "Communication")
COMM.Autoload = true

--[[--
	Here, we handle all the cross-client communication for CUI
--]]--

local _
local unpack 						= unpack
local tonumber 						= tonumber
local type 							= type
local SendAddonMessage 				= C_ChatInfo.SendAddonMessage
local RegisterAddonMessagePrefix 	= C_ChatInfo.RegisterAddonMessagePrefix

local Prefix = "CUI"
local Handler = CreateFrame("Frame", "CUI_AddonCommFrame")

local MessageSentBase = 'Message sent to Channel: "%s" - Content: "%s"'

-- Table of functions we expose to the message handler
-- This is to prevent cases where people could mess with our COMM system
local Public = {
	['VERSIONCHECK'] = true,
}

--[[----------------
	Core
----------------]]--
	
	local function HandleMessage(_, _, Pref, Message, Channel, Sender)
		-- Make sure the message is from a CUI user that is not the player himself
		if Pref == Prefix then
			if Sender ~= COMM.PlayerName then
				--if not Message:find("---", nil, true) then return end
				E:debugprint("CUI Message from", Sender, ": ", Message)
				local Type, Args = unpack(E:FullSplit(Message, "---"))
				
				-- We have to be overly protective here, since literally ANYTHING could have been sent
				
				-- Modular Comm Handler, so we don't have to put everything in this method
				-- Method should look like this: COMM:MESSAGETYPE(Args, Channel, Sender)
				-- Also filters malformed args
				if Type and Public[Type] and COMM[Type] and ((Args and not Args:find("??", nil, true)) or (not Args and Message)) then
					COMM[Type](Args or Message, Channel, Sender)
				end
			else
				E:debugprint((MessageSentBase):format(Channel, Message))
			end
		end
	end
	
	function COMM:SendMessage(Message, Channel)
		SendAddonMessage(Prefix, Message, Channel)
	end
	
	function COMM:GetGroupChannelType()
		if IsInGroup() or IsInRaid() then
			if UnitInBattleground("player") or IsActiveBattlefieldArena() then
				return "BATTLEGROUND"
			else
				if IsPartyLFG() then
					return "INSTANCE_CHAT"
				elseif IsInRaid() then
					return "RAID"
				else
					return "PARTY"
				end
			end
		end
	end
	
	--
	
	do
		-- RegisterAddonMessagePrefix(Prefix)
		-- Handler:RegisterEvent("CHAT_MSG_ADDON")
		-- Handler:SetScript("OnEvent", HandleMessage)
	end

--[[----------------
	Version Check
----------------]]--
	
	local CachedUpgradeVersion = 0
	
	-- Checks every minute for potential upgrades
	local function VersionCheck_OnUpdate(self, elapsed)
		self.UpdateDelay = (self.UpdateDelay or -60) + elapsed
		
		if self.UpdateDelay > 0 then
			COMM:PerformVersionCheck()
			
			self.UpdateDelay = -60
		end
	end
	
	local CheckVersion = CreateFrame("Frame", "CUI_VersionCheckFrame")
	CheckVersion:RegisterEvent("PLAYER_ENTERING_WORLD")
	--CheckVersion:RegisterEvent("GROUP_ROSTER_UPDATE")
	--CheckVersion:RegisterEvent("UPDATE_INSTANCE_INFO")
	CheckVersion.Enabled = false
	
	function COMM:UpdateVersionCheckTicker()
		if CO.db.global.communication.autoCheckVersion then
			if not CheckVersion.Enabled then
				CheckVersion.Enabled = true
				
				CheckVersion:SetScript("OnEvent", COMM.PerformVersionCheck)
				CheckVersion:SetScript("OnUpdate", VersionCheck_OnUpdate)
			end
		else
			if CheckVersion.Enabled then
				CheckVersion.Enabled = false
				
				CheckVersion:SetScript("OnEvent", nil)
				CheckVersion:SetScript("OnUpdate", nil)
			end
		end
	end
	
	function COMM:VersionCheck_Stop()
		CheckVersion:SetScript("OnUpdate", nil)
	end
	
	function COMM:PerformVersionCheck(event)
		if IsInGuild() then
			COMM:SendMessage("VERSIONCHECK", "GUILD")
		end
		
		local Channel = COMM:GetGroupChannelType()
		if Channel then
			COMM:SendMessage("VERSIONCHECK", Channel)
		end
	end
	
	local function VERSIONCHECK_COMPARE(Args)
		local Revision, Version, VersionDate = unpack(E:FullSplit(Args, "?"))
		
		Revision = tonumber(Revision)
		
		if Revision and Revision > E.Revision and Revision > CachedUpgradeVersion then
			if type(VersionDate) == "number" then
				VersionDate = E:FormatDate(VersionDate)
			end
			E:print((L["NewVersion"]):format(Version, VersionDate, Revision))
			
			CachedUpgradeVersion = Revision
		end
	end
	
	local function VERSIONCHECK_ANSWER(Channel)
		COMM:SendMessage(("VERSIONCHECK---%s?%s?%s"):format(E.Revision, E.Version, E.VersionDate), Channel)
	end
	
	function COMM:VERSIONCHECK(Args, Channel, Sender)
		if Args then
			VERSIONCHECK_COMPARE(Args)
		else -- Is a request
			VERSIONCHECK_ANSWER(Channel)
		end
	end


function COMM:Init()
	
	local Name, Realm = UnitFullName("player")
	self.PlayerName = ('%s-%s'):format(Name, Realm)
	
	-- Auto update state
	--self:UpdateVersionCheckTicker()
end

-- Disabled for now - doesn't work properly
--E:AddModule("Communication", COMM)