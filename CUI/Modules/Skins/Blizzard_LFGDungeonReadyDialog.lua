local E = unpack(select(2, ...)) -- Engine, Locale
local CO, Module, UF = E:LoadModules("Config", "Blizzard_LFGDungeonReadyDialog", "Unitframes")
Module.Autoload = true

local LFGDungeonReadyDialog = _G.LFGDungeonReadyDialog
local ConfirmationTime = 40
local BigWigsTimer

local BigWigsFunc = function(event, frame, name)
	if frame and name == "QueueTimer" then BigWigsTimer = frame; frame:Hide() end
end

function Module:LoadConfig()
	if not self.db.enable then
		if self.Timer then
			self.Timer:Hide()
			self:SetScript('OnEvent', nil)
		end
	else	
		self:SetScript('OnEvent', self.OnEvent)
		self:OnEvent()
	end
	
	
	-- As BigWigs has an internal function to display a bar like this, but no option at all to disable it, we have to react-handle
	if BigWigsLoader then
		if self.db.hideBigWigs then
			if not BigWigsTimer then
				BigWigsLoader.RegisterMessage(E, "BigWigs_FrameCreated", BigWigsFunc)
			else
				BigWigsTimer:Hide()
			end
		else
			BigWigsLoader.UnregisterMessage(E, "BigWigs_FrameCreated")
			if BigWigsTimer then BigWigsTimer:Show() end
		end
	end
end

local function Timer_OnUpdate(self, elapsed)	
	local TimeLeft = (Module.showTime or (GetTime() + ConfirmationTime)) - GetTime()
	
	self:SetValue(TimeLeft)
	self:SetStatusBarColor(E:ColorGradient((TimeLeft / ConfirmationTime), 0.85, 0.05, 0.05, 0.95, 0.9, 0, 0.1, 0.9, 0.1))
	self.Text:SetText(E:Round(TimeLeft, 1))
end

local function Show()
	if not Module.Timer then return end
	
	Module.Timer.CloseIn = ConfirmationTime
	Module.Timer:SetScript('OnUpdate', Timer_OnUpdate)
	Module.Timer:Show()
end

local function Hide()
	if not Module.Timer then return end
	
	Module.Timer:SetScript('OnUpdate', nil)
	Module.Timer:Hide()
end

function Module:OnEvent(event)
	if event == "LFG_PROPOSAL_SHOW" then
		self.showTime = GetTime() + ConfirmationTime
	end
		
	if LFGDungeonReadyDialog:IsVisible() then
		self:Construct()
		Show()
	else
		Hide()
	end
end

function Module:Construct()	
	--if not self.db.enable or self.Timer then return end
		
	local Timer = UF:CreateUFBar()
	
	Timer:SetSize(250, 15)
	
	Timer.Border 		= E:CreateBorder(Timer); Timer.Border:SetFrameLevel(Timer:GetFrameLevel() + 5)
	Timer.Background 	= E:CreateBackground(Timer)
	Timer.Text 			= E:NewFontObject(nil, "ARTWORK", Timer, 10, 5)
	Timer.Text:ClearAllPoints()
	Timer.Text:SetPoint("CENTER", Timer, "CENTER")
	
	local Media = CO.db.profile.media
	local Defaults = E.ConfigDefaults.profile.media
	E:SetFontInfo(Timer.Text,  E.Media:Fetch("font", Media.generalFont or Defaults.generalFont), "OUTLINE", (Media.generalFontSize or Defaults.generalFontSize or 12), nil, true)
	
	Timer:ClearAllPoints()
	Timer:SetPoint("TOP", LFGDungeonReadyDialog, "BOTTOM", 0 , -5)
	Timer:SetParent(LFGDungeonReadyDialog)
	
	Timer:SetMinMaxValues(0, ConfirmationTime)
	
	self.Timer = Timer
end

function Module:UpdateDB()
	self.db = CO.db.profile.blizzard.dungeonReadyDialog
end

function Module:Init()
	self:UpdateDB()
	
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("LFG_PROPOSAL_SHOW")
	
	self:LoadConfig()
end

E:AddModule("Blizzard_LFGDungeonReadyDialog", Module)