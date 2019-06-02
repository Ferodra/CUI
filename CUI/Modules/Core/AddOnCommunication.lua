local E, L = unpack(select(2, ...)) -- Engine, Locale
local L, CO, COMM = E:LoadModules("Locale", "Config", "Communication")
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
local Handler = CreateFrame("Frame")

local CachedUpgradeVersion = 0


--[[----------------
	Core
----------------]]--
	
	local function CompareVersion(Compare)
		
		local Revision, Version, VersionDate = unpack(E:FullSplit(Compare, "?"))
		
		Revision = tonumber(Revision)
		
		if Revision and Revision > E.Revision and Revision > CachedUpgradeVersion then
			if type(VersionDate) == "number" then
				VersionDate = E:FormatDate(VersionDate)
			end
			E:print((L["NewVersion"]):format(Version, VersionDate, Revision))
			
			CachedUpgradeVersion = Revision
		end
	end
	
	local function AnswerRequest(Type, Channel)
		if Type == "VERSIONCHECK" then
			COMM:SendMessage(("VERSIONCHECK---%s?%s?%s"):format(E.Revision, E.Version, E.VersionDate), Channel)
		end
	end
	
	local function HandleMessage(_, _, Pref, Message, Channel, Sender)
		-- Make sure the message is from a CUI user that is not the player himself
		if Pref == Prefix and Sender ~= COMM.PlayerName then
			E:debugprint("CUI Message from", Sender, ": ", Message)
			local Type, Args = unpack(E:FullSplit(Message, "---"))
			
			-- We have to be overly protective here, since literally ANYTHING could have been sent
			
			if Type == "VERSIONCHECK" then
				if Args then
					CompareVersion(Args)
				else -- Is a request
					AnswerRequest(Type, Channel)
				end
			end
		end
	end
	
	function COMM:SendMessage(message, channel)
		SendAddonMessage(Prefix, message, channel)
	end
	
	function COMM:GetGroupChannelType()
		if IsInGroup() or IsInRaid() then
			if IsActiveBattlefieldArena() then
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
		RegisterAddonMessagePrefix(Prefix)
		Handler:RegisterEvent("CHAT_MSG_ADDON")
		Handler:SetScript("OnEvent", HandleMessage)
	end

--[[----------------
	Version Check
----------------]]--
	
	-- Checks every minute for potential upgrades
	local function VersionCheck_OnUpdate(self, elapsed)
		self.UpdateDelay = (self.UpdateDelay or -60) + elapsed
		
		if self.UpdateDelay > 0 then
			COMM:PerformVersionCheck()
			
			self.UpdateDelay = -60
		end
	end
	
	local CheckVersion = CreateFrame("Frame")
	CheckVersion:RegisterEvent("PLAYER_ENTERING_WORLD")
	CheckVersion:RegisterEvent("GROUP_ROSTER_UPDATE")
	CheckVersion:RegisterEvent("UPDATE_INSTANCE_INFO")
	CheckVersion.Enabled = false
	
	function COMM:UpdateVersionCheck()
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
		COMM:SendMessage("VERSIONCHECK", Channel)
	end


function COMM:Init()
	
	self.PlayerName = UnitFullName("player")
	
	-- Auto update state
	self:UpdateVersionCheck()
end

E:AddModule("Communication", COMM)