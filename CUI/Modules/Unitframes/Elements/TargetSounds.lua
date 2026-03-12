local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF = E:LoadModules('Config', 'Unitframes')

--[[--------------------
	Unitframe Extension	
--------------------]]--

local _
local IsReplacingUnit	= C_PlayerInteractionManager.IsReplacingUnit()
local AGGRO_SELECT		= SOUNDKIT.IG_CREATURE_AGGRO_SELECT
local NEUTRAL_SELECT	= SOUNDKIT.IG_CREATURE_NEUTRAL_SELECT
local NPC_SELECT		= SOUNDKIT.IG_CHARACTER_NPC_SELECT
local TARGET_LOST		= SOUNDKIT.INTERFACE_SOUND_LOST_TARGET_UNIT

local Module = {}

-----------------------------------------

local EventHandler = CreateFrame('Frame')
local Events = {'PLAYER_TARGET_CHANGED'}

local function GetSoundFromDB(Situation)
	local DB = CO.db.profile.unitframe.units.all.targetSounds.situations[Situation]
	return tonumber(DB) or DB
end

local function UpdateElement(self, event)
	if self.Disabled then return end
	
	if UnitExists('target') and not IsReplacingUnit then
		if UnitIsEnemy('player', 'target') then
			PlaySound(GetSoundFromDB('aggro') or AGGRO_SELECT)
		elseif UnitIsFriend('player', 'target') then
			PlaySound(GetSoundFromDB('npc') or NPC_SELECT)
		else
			PlaySound(GetSoundFromDB('neutral') or NEUTRAL_SELECT)
		end
	elseif not UnitExists('target') then
		PlaySound(GetSoundFromDB('lost') or TARGET_LOST)
	end
end

function Module:Disable()	
	EventHandler:UnregisterAllEvents()
	
	self.Disabled = true
end

function Module:Enable()
	self:Disable()
	
	for k, v in pairs(Events) do
		EventHandler:RegisterEvent(v)
	end
	
	self.Disabled = false
end

do
	EventHandler:SetScript('OnEvent', function()
		UpdateElement(Module)
	end)
end

----------

function Module:LoadConfig()
	local Config = CO.db.profile.unitframe.units.all
		
	if Config.targetSounds then
		if not Config.targetSounds.enable then
			self:Disable()
		else
			self:Enable()
		end
	end
end

---------- Add Module
UF:RegisterModule('TargetSounds', Module, true)