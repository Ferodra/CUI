local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF = E:LoadModules("Config", "Unitframes")

--[[--------------------
	Unitframe Extension	
--------------------]]--

local _
local pairs			= pairs
local tinsert		= table.insert
local Module = {}

local GetUnitSummonStatus		= C_IncomingSummon.IncomingSummonStatus

local SUMMON_STATUS_NONE = Enum.SummonStatus.None or 0
local SUMMON_STATUS_PENDING = Enum.SummonStatus.Pending or 1
local SUMMON_STATUS_ACCEPTED = Enum.SummonStatus.Accepted or 2
local SUMMON_STATUS_DECLINED = Enum.SummonStatus.Declined or 3

-----------------------------------------

local EventHandler = CreateFrame("Frame")
local Events = {"INCOMING_SUMMON_CHANGED"}

local function UpdateElement(self, event, unit)
	if self.Disabled then return end
		self.Unit = self:GetParent().Unit
		if unit and self.Unit ~= unit then return end
	
	self.SummonStatus 	= GetUnitSummonStatus(self.Unit)
	
	if(self.SummonStatus ~= SUMMON_STATUS_NONE) then
		if(self.SummonStatus == SUMMON_STATUS_PENDING) then
			self.T:SetAtlas('Raid-Icon-SummonPending')
		elseif(self.SummonStatus == SUMMON_STATUS_ACCEPTED) then
			self.T:SetAtlas('Raid-Icon-SummonAccepted')
		elseif(self.SummonStatus == SUMMON_STATUS_DECLINED) then
			self.T:SetAtlas('Raid-Icon-SummonDeclined')
		end

		self:Show()
	else
		self:Hide()
	end
end

do
	-- Handles all event updates for this module
	for k, v in pairs(Events) do
		EventHandler:RegisterEvent(v)
	end
	EventHandler.Handles = {}
	EventHandler:SetScript("OnEvent", function(self, event, ...)
		for _, F in pairs(self.Handles) do
			UpdateElement(F.SummonIndicator, event, ...)
		end
	end)
end

----------

-- Gets called automatically when the unitframes first are initialized and on config update
function Module:LoadProfile()
	local Config
	
	for _, self in pairs(EventHandler.Handles) do
		Config = CO.db.profile.unitframe.units[self.ProfileUnit]
		
		if Config.summonIndicator then
			if not Config.summonIndicator.enable then self.SummonIndicator:Hide(); self.SummonIndicator.T:SetTexture(nil) self.SummonIndicator.Disabled = true; else
				self.SummonIndicator:ClearAllPoints()
				self.SummonIndicator:SetPoint("CENTER", self.Overlay, Config.summonIndicator.position, Config.summonIndicator.offsetX, Config.summonIndicator.offsetY)
				self.SummonIndicator:SetSize(Config.summonIndicator.size, Config.summonIndicator.size)
				self.SummonIndicator:SetFrameLevel(self.Overlay:GetFrameLevel() + 25)
				
				self.SummonIndicator.Disabled = false
			end
		end
	end
end

function Module:Create(F)
	F.SummonIndicator = E:CreateTextureFrame(nil, F, 20, 20, "ARTWORK")
	
	F.SummonIndicator.ForceUpdate = UpdateElement
	
	tinsert(EventHandler.Handles, F)
end

---------- Add Module
UF.Modules["SummonIndicator"] = Module