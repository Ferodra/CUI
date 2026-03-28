local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF = E:LoadModules("Config", "Unitframes")

--[[--------------------
	Unitframe Extension	
--------------------]]--

local _
local pairs			= pairs
local tinsert		= table.insert
local Module = {}
Module.IncludeUnits = {'player', 'target', 'party', 'raid', 'raid40'}

local IncomingSummonStatus		= C_IncomingSummon.IncomingSummonStatus
local HasIncomingSummon			= C_IncomingSummon.HasIncomingSummon

local SUMMON_STATUS_NONE = Enum.SummonStatus.None or 0
local SUMMON_STATUS_PENDING = Enum.SummonStatus.Pending or 1
local SUMMON_STATUS_ACCEPTED = Enum.SummonStatus.Accepted or 2
local SUMMON_STATUS_DECLINED = Enum.SummonStatus.Declined or 3

-----------------------------------------

local EventHandler = CreateFrame("Frame")
local Events = {"INCOMING_SUMMON_CHANGED"}

local function UpdateElement(self, unit)
	if self.Disabled then return end
	
	if HasIncomingSummon(self.Owner.unit) then
		local SummonStatus = IncomingSummonStatus(self.Owner.unit)
		
		if(SummonStatus == SUMMON_STATUS_PENDING) then
			self.T:SetAtlas('RaidFrame-Icon-SummonPending')
		elseif(SummonStatus == SUMMON_STATUS_ACCEPTED) then
			self.T:SetAtlas('RaidFrame-Icon-SummonAccepted')
		elseif(SummonStatus == SUMMON_STATUS_DECLINED) then
			self.T:SetAtlas('RaidFrame-Icon-SummonDeclined')
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
	EventHandler:SetScript("OnEvent", function(self, event, unit)
		for _, F in pairs(self.Handles) do
			if F.unit == unit then
				UpdateElement(F.SummonIndicator, unit)
			end
		end
	end)
end

----------

-- Gets called automatically when the unitframes first are initialized and on config update
function Module:LoadConfig()
	local Config
	
	for _, self in pairs(EventHandler.Handles) do
		Config = CO.db.profile.unitframe.units[self.ConfigKey]
		
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
	local Element = E:CreateTextureFrame(nil, F.Overlay, 20, 20, "ARTWORK")
	Element:SetFrameLevel(10)
	Element.ForceUpdate = UpdateElement
	Element.Owner = F
	
	F.SummonIndicator = Element
	tinsert(EventHandler.Handles, F)
end

---------- Add Module
UF.Modules["SummonIndicator"] = Module