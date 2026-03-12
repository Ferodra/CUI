local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, Module = E:LoadModules("Config", "TimeToKill")
Module.Autoload = true

-----------------------------------------------------------------------------
local _
local max					= math.max
local floor					= math.floor
local ceil					= math.ceil
local UnitHealth 			= UnitHealth
local UnitHealthMax 		= UnitHealthMax

Module.Holder = CreateFrame("Frame", "CUI_TimeToKillHolder", E.Parent)

local AnalyzeSeconds = 10
local UpdateInterval = 0.3
local NumOfTicks = AnalyzeSeconds / UpdateInterval
-----------------------------------------------------------------------------

local function ShiftTickTable(self)
	for i=1,NumOfTicks do
		if i < NumOfTicks then
			if self.Ticks[i+1] then
				self.Ticks[i][1] = self.Ticks[i+1][1]
				self.Ticks[i][2] = self.Ticks[i+1][2]
			end
		else
			self.Ticks[i][1] = nil
			self.Ticks[i][2] = nil
		end
	end
end

local function SetCurrentTickData(self, time, health)
	self.Ticks[self.CurrentTickIndex][1] = time
	self.Ticks[self.CurrentTickIndex][2] = health
end

local function GetKillTime(self)
	self.CurrentHealth = UnitHealth("target")
	
	if not self.Ticks[self.CurrentTickIndex] then self.Ticks[self.CurrentTickIndex] = {} end
		SetCurrentTickData(self, self.elapsed, self.CurrentHealth)
	
	local DPS = (self.Ticks[1][2] - self.Ticks[self.CurrentTickIndex][2]) / ((self.Ticks[self.CurrentTickIndex][1] - self.Ticks[1][1]) == 0 and self.Ticks[self.CurrentTickIndex][1] or (self.Ticks[self.CurrentTickIndex][1] - self.Ticks[1][1]))
	self.lastElapsed = self.elapsed
	self.LastHealth = self.CurrentHealth
	local Seconds = (DPS ~= 0) and (self.CurrentHealth / DPS) or 0
	
	if self.CurrentTickIndex >= NumOfTicks then self.CurrentTickIndex = 1; ShiftTickTable(self); else self.CurrentTickIndex = self.CurrentTickIndex + 1 end
	if Seconds <= 0 or Seconds > 600 then
		return ""
	elseif Seconds >= 60 then
		return E:FormatTimeSimple(Seconds)
	else
		return E:Round(Seconds, 1)
	end
end

local function UpdateMaxHealth(self)
	self.MaxHealth = UnitHealthMax("target")
end

local function OnUpdate(self, elapsed)
	self.interval = (self.interval or 0) + elapsed
	self.elapsed = (self.elapsed or 0) + elapsed
	
	if self.interval >= UpdateInterval then
		self.Time:SetText(GetKillTime(self))
		
		self.interval = 0
	end
end

local function Reset(self)
	self.elapsed = 0
	self.lastElapsed = 0
	-- Current Tick Index also indicates the current max index we can use to analyze dps
	self.CurrentTickIndex = 1
end

local function Enable(self)
	Reset(self)
	
	if not self:GetScript("OnUpdate") then
		self:SetScript("OnUpdate", OnUpdate)
	end
end

local function Disable(self)
	self:SetScript("OnUpdate", nil)
end

local function OnEvent(self, event)
	self.elapsed = 0
	if UnitExists("target") then
		UpdateMaxHealth(self)
		Enable(self)
	else
		Disable(self)
	end
end

function Module:LoadConfig()
	-- self.db = CO.db.profile.dataframes.timeToKill
	
	-- if self.db.enable then		
		
		
		-- self.Holder:Show()
	-- else
		-- self.Holder:Hide()
	-- end
end

function Module:Construct()
	self.Holder:SetSize(100, 35)
	
	E:CreateMover(self.Holder, "Time to Kill", nil, nil, nil, "Shows you for how long your current target will still live (approximately)", "misc")
	
	self.Time = E:NewFontObject('Time', 'ARTWORK', self.Holder)
	--E:RegisterAutoFont(self.Time, 'db.profile.dataframes.battlerezCharges.time')
	
	self.Time:SetText('')
	
	self.Ticks = {}
	
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:SetScript("OnEvent", OnEvent)
end

function Module:Init()
	-- self:Construct()
	
	-- self:LoadConfig()
end

E:AddModule("TimeToKill", Module)