local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO = E:LoadModules("Config")

local Module = CreateFrame("Frame", "CUI_BattlerezCharges", E.Parent)
Module.Autoload = true -- This will cause CUI to automatically load this module. No external init needed.
----------------------------------------------------

local _
local format					= string.format
local pairs						= pairs
local select					= select
local type						= type
local IsInRaid					= IsInRaid
local IsInGroup					= IsInGroup
local GetSpellCharges			= C_Spell.GetSpellCharges
local GetSpellTexture			= C_Spell.GetSpellTexture

local BorderColor = {0, 0, 0, 1}
local SourceSpellID = 20484 -- Druid Rebirth
-- /dump C_Spell.GetSpellCharges(20484)

function Module:LoadConfig()
	self.db = CO.db.profile.dataframes.battlerezCharges
	
	self:SetSize(self.db.size, self.db.size)
	self.Mover.HandleMovementByChild = true
	
	if not self.db.enable then
		self:UnregisterAllEvents(); self:Hide();
		self.ForceMoverEnabled = false
	else
		self.ForceMoverEnabled = nil
	end
end

local function Enable(self)
	self:Show()
end

local function Disable(self)
	self:Hide()
end


local function OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	
	if self.elapsed >= 0.15 then
		
		local Info = GetSpellCharges(SourceSpellID)
		if not Info then
			Disable(self)
			
			return
		end
		local Charges, StartTime, ChargeDuration = Info.currentCharges, Info.cooldownStartTime, Info.cooldownDuration
		
		if not Charges or not StartTime then
			Disable(self)
			
			return
		end
		self.Button:Show()
		
		local TimeRemaining = ChargeDuration - (GetTime() - StartTime)
		
		self.Time:SetFormattedText("%d:%02d", floor(TimeRemaining/60), TimeRemaining%60)
		self.Charges:SetText(Charges)
		self.Cooldown:SetCooldown(StartTime, ChargeDuration)
		
		self.elapsed = 0
	end
end

local function OnEvent(self, event)
	-- We enable the OnUpdate handler via OnEvent (this), so there's one less ticking around uneccessarily
	if not IsInRaid() and not IsInGroup() then
		Disable(self)
		
		return
	end
	
	local Charges = GetSpellCharges(SourceSpellID)
	if not Charges then
		Disable(self)
	else
		Enable(self)
	end
end

function Module:Toggle()
	self.state = not self.state
	if self.state then
		self:SetScript('OnUpdate', nil)
		Enable(self)
		self.Button:Show()
	else
		self.Button:Hide()
		self:SetScript('OnUpdate', OnUpdate)
		OnEvent(self)
	end
end

function Module:Construct()
	
	self.Button = CreateFrame('Frame', 'CUI_BattlerezChargeFrame', self)
	self.Button:SetAllPoints(self)
	
	self.Button.Icon = self.Button:CreateTexture(nil, 'BACKGROUND')
	self.Button.Icon:SetAllPoints(self.Button)
	self.Button.Icon:SetParent(self.Button)
	self.Icon = self.Button.Icon
	
	self.Button.Icon:SetTexture(GetSpellTexture(SourceSpellID))
	E:SkinButtonIcon(self.Button, BorderColor, false, true)
	
	self.Cooldown = CreateFrame('Cooldown', nil, self.Button, 'CooldownFrameTemplate')
	self.Cooldown:SetAllPoints(self.Button)
	self.Cooldown:SetHideCountdownNumbers(true)
	
	self.Overlay = CreateFrame('Frame', nil, self.Button)
	self.Overlay:SetAllPoints(self.Button)
	
	self.Time 		= E:NewFontObject('Time', 'ARTWORK', self.Overlay)
	self.Charges 	= E:NewFontObject('Charges', 'ARTWORK', self.Overlay)
	
	E:RegisterAutoFont(self.Time, 'db.profile.dataframes.battlerezCharges.time')
	E:RegisterAutoFont(self.Charges, 'db.profile.dataframes.battlerezCharges.charges')
	
	self.Time:SetText(10)
	self.Charges:SetText(2)
	
	self:SetScript('OnUpdate', OnUpdate)
	self:SetScript('OnEvent', OnEvent)
	
	-- Handle state via events, so we don't have to check the charges OnUpdate
	self:RegisterEvent('PLAYER_REGEN_DISABLED')
	self:RegisterEvent('PLAYER_REGEN_ENABLED')
	self:RegisterEvent('INSTANCE_ENCOUNTER_ENGAGE_UNIT')
	self:RegisterEvent('GROUP_ROSTER_UPDATE')
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
    self:RegisterEvent('CHALLENGE_MODE_START')
	self:RegisterEvent('CHALLENGE_MODE_COMPLETED')
    self:RegisterEvent('CHALLENGE_MODE_RESET')
	self:RegisterEvent('WORLD_STATE_TIMER_START')
	
	E:CreateMover(self, L["battlerezCharges"], nil, nil, nil, "A frame that shows you, how many Combat Resurrects are left in your group/raid", "misc")
	self.Mover = E:GetMover(self)
end

function Module:Init()
	self.db = CO.db.profile.dataframes.battlerezCharges

	E:HandleFrameInPetBattles(self)

	self:Construct()
	self:LoadConfig()
end

E:AddModule("BattlerezCharges", Module)