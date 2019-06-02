local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF = E:LoadModules("Config", "Unitframes")

--[[--------------------
	Unitframe Extension	
--------------------]]--

local _
local pairs			= pairs
local tinsert		= table.insert
local Module = {}

-----------------------------------------

local EventHandler = CreateFrame("Frame")
local Events = {"PARTY_LEADER_CHANGED", "GROUP_ROSTER_UPDATE"}

local function UpdateElement(self)
	if self.Disabled then return end
		self.Unit = self:GetParent().Unit
		if unit and self.Unit ~= unit then return end
	
	local isAssist, isLeader
	isLeader = (UnitInParty(self.Unit) or UnitInRaid(self.Unit)) and UnitIsGroupLeader(self.Unit)

	if isLeader then
		self.T:SetTexture([[Interface\GroupFrame\UI-Group-LeaderIcon]])
		self:Show()
		
		return
	else
		isAssist = UnitInRaid(self.Unit) and UnitIsGroupAssistant(self.Unit) and not UnitIsGroupLeader(self.Unit)

		if isAssist then
			self.T:SetTexture([[Interface\GroupFrame\UI-Group-AssistantIcon]])
			self:Show()
			
			return
		end
	end

	self:Hide()
end

do
	-- Handles all event updates for this module
	for k, v in pairs(Events) do
		EventHandler:RegisterEvent(v)
	end
	EventHandler.Handles = {}
	EventHandler:SetScript("OnEvent", function(self, event, ...)
		for _, F in pairs(self.Handles) do
			UpdateElement(F.LeaderIcon)
		end
	end)
end

----------

-- Gets called automatically when the unitframes first are initialized and on config update
function Module:LoadProfile()
	local Config
	
	for _, self in pairs(EventHandler.Handles) do
		Config = CO.db.profile.unitframe.units[self.ProfileUnit]
		
		if Config.leaderIcon then
			if not Config.leaderIcon.enable then self.LeaderIcon:Hide(); self.LeaderIcon.T:SetTexture(nil) self.LeaderIcon.Disabled = true; else
				self.LeaderIcon:ClearAllPoints()
				self.LeaderIcon:SetPoint("CENTER", self.Overlay, Config.leaderIcon.position, Config.leaderIcon.offsetX, Config.leaderIcon.offsetY)
				self.LeaderIcon:SetSize(Config.leaderIcon.size, Config.leaderIcon.size)
				self.LeaderIcon:SetFrameLevel(self.Overlay:GetFrameLevel() + 25)
				
				self.LeaderIcon.Disabled = false
			end
		end
	end
end

function Module:Create(F)
	F.LeaderIcon = E:CreateTextureFrame(nil, F, 20, 20, "ARTWORK")
	
	F.LeaderIcon.ForceUpdate = UpdateElement
	
	tinsert(EventHandler.Handles, F)
end

---------- Add Module
UF.Modules["LeaderIcon"] = Module