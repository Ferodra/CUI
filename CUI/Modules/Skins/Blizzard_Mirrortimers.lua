local E = unpack(select(2, ...)) -- Engine, Locale
local CO, Module = E:LoadModules("Config", "Blizzard_Mirrortimers")
Module.Autoload = true

local tinsert		= table.insert

local MirrorTimer_Holder = CreateFrame("Frame", "MirrorTimerHolder", E.Parent)
MirrorTimer_Holder:SetSize(250, 20)

Module.Bars = {}

function Module:LoadConfig()
	local Config = self.db
	local Config_ALL = CO:GetConfigTable('UNITFRAMES_ALL', 3)
	
	-- Handling the possibility of multiple bars. Just in case
	for Timer, Bar in pairs(self.Bars) do
		Bar:SetSize(Config.barWidth, Config.barHeight)
		
		-- Texture
		if Config.overrideBarTexture then
			--Bar:SetAttribute("ReceivesGlobalTexture", false)
			--Bar:SetStatusBarTexture(E.Media:Fetch("statusbar", Config.barTexture or Config_ALL.barTexture))
		else
			--Bar:SetAttribute("ReceivesGlobalTexture", true)
			--Bar:SetStatusBarTexture(E.Media:Fetch("statusbar", Config_ALL.barTexture))
		end
	end
end


function Module:UpdateBarPosition()
	local MoverFrames = 1
	local GrowthDirection = Module.db.growthDirection == 'UP'
	
	for _, Bar in pairs(Module.Bars) do
		if Bar:IsVisible() then
			Bar:ClearAllPoints()
			Bar:SetPoint(GrowthDirection and "TOP" or "BOTTOM", MirrorTimer_Holder, GrowthDirection and "BOTTOM" or "TOP", 0, (MoverFrames * Bar:GetHeight()) * (GrowthDirection and 1 or -1))
			Bar.Text:Show()
			Bar.Time:Show()
			
			MoverFrames = MoverFrames + 1
		else
			Bar.Text:Hide()
			Bar.Time:Hide()
		end
	end
end


function Module:SetupMover(Bar)
	Bar:SetParent(MirrorTimer_Holder)
end

local function UpdateBarTimer(self)
	local value = self:GetValue()
	local m, s = value / 60, value % 60
	
	self.Time:SetText(string.format("%d:%02d", m, s)) -- Formats the time to an 00:00 format
end

local function UpdateBarStyle(self)
	self:SetStatusBarTexture(MirrorTimerAtlas[self.TimerType])
end

local function Bar_OnShow(self)
	UpdateBarStyle(self)
	Module:UpdateBarPosition()
end

local function SetupTimer(Container, Timer)
	local Bar = Container:GetAvailableTimer(Timer)
	if not Bar then return end
	
	Module:SetupMover(Bar)
	
	if not Module.db.enableSkin or Module.Bars[Timer] then return end
	
	local Statusbar = Bar.StatusBar
	
	--Bar.TextBorder:SetTexture(nil)
	Statusbar.TimerType = Timer
	
	Bar.Time = E:NewFontObject(nil, "OVERLAY", Bar, 10)
	
	Statusbar.Time = Bar.Time
	
	Statusbar:SetScript("OnValueChanged", UpdateBarTimer)
	Statusbar:SetScript("OnShow", Bar_OnShow)
	
	-- Let our font API handle font configs
	E:RegisterAutoFont(Bar.Text, "db.profile.blizzard.mirrortimer.text")
	E:RegisterAutoFont(Bar.Time, "db.profile.blizzard.mirrortimer.time")
	
	UpdateBarStyle(Statusbar)
	
	Module.Bars[Timer] = Bar
	
	Module:UpdateBarPosition()
end

function Module:Init()
	self.db = CO.db.profile.blizzard.mirrortimer
	
	if not self.db.enable then return end
	
	hooksecurefunc(_G.MirrorTimerContainer, 'SetupTimer', SetupTimer)
	hooksecurefunc(_G.MirrorTimerContainer, 'Layout', Module.UpdateBarPosition)
	E:CreateMover(MirrorTimer_Holder, "Mirror Timers", nil, nil, nil, "A frame that holds timers like Breath, Fatigue and Feign Death.", "misc")
	
	_G.MirrorTimerContainer:SetParent(MirrorTimer_Holder)
	_G.MirrorTimerContainer:ClearAllPoints()
	_G.MirrorTimerContainer:SetAllPoints(MirrorTimer_Holder)
	
	self:LoadConfig()
end

E:AddModule("Blizzard_Mirrortimers", Module)