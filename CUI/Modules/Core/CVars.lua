---@class E
local E = unpack(select(2, ...)) -- Engine, Locale
local CO = E:LoadModules("Config")

--[[-------------------------------------------------
	
	This small lib is being used to mass load CVars
	at a specific point in the code.
	
	This prevents directly setting CVars and
	makes everything more convenient, since
	CUI modifies several CVars.
	
-------------------------------------------------]]--

---------------------------------------------------
local pairs 					= pairs
---------------------------------------------------

E.CVars = {}
local EngineEvent = CreateFrame("Frame", "CUI_EngineEventFrame")
local CameraCVars = {"cameraPitchMoveSpeed", "cameraYawMoveSpeed", "cameraPitchSmoothSpeed", "cameraYawSmoothSpeed"}
local ActioncamCVars = {"test_cameraDynamicPitch", "test_cameraDynamicPitchBaseFovPad", "test_cameraDynamicPitchBaseFovPadFlying", "test_cameraTargetFocusEnemyEnable",
"test_cameraTargetFocusEnemyStrengthPitch", "test_cameraTargetFocusEnemyStrengthYaw", "test_cameraTargetFocusInteractEnable", "test_cameraTargetFocusInteractStrengthPitch",
"test_cameraTargetFocusInteractStrengthYaw", "test_cameraOverShoulder", "test_cameraHeadMovementStrength"}

local Defaults = {}
local PreventReset = {}

local function SaveDefault(name, value)
	if PreventReset[name] then return end
	
	if Defaults[name] == nil then
		Defaults[name] = value
	end
end

function E:GetBlizzCVar(CVar, isBool)
	if isBool then
		return GetCVarBool(CVar)
	else
		return GetCVar(CVar)
	end
end

function E:UpdateCVars()
	
	for _, name in pairs(CameraCVars) do
		self:RegisterCVar(name, CO.db.profile.CVars[name])
	end
	
	if CO.db.profile.engine.enableActioncam then
		for _, name in pairs(ActioncamCVars) do
			self:RegisterCVar(name, CO.db.profile.CVars[name])
		end
	end
	
	if CO.db.char.CVars.overrideSpellQueueWindow then
		self:RegisterCVar("SpellQueueWindow", CO.db.char.CVars.spellQueueWindow or 400)
	end
	
	self:LoadRegisteredCVars()
end

-- Adds a CVar to the register
function E:RegisterCVar(CVar, value, forceSet, preventReset)
	
	-- If no value was provided, load from DB
	if value == nil then
		if CO.db.profile.CVars[CVar] ~= nil then
			value = CO.db.profile.CVars[CVar]
		elseif CO.db.char.CVars[CVar] ~= nil then
			value = CO.db.char.CVars[CVar]
		end
	end

	self.CVars[CVar] = value
	PreventReset[CVar] = preventReset
	
	if forceSet then
		SaveDefault(CVar, value)
		SetCVar(CVar, value)
	end
end

-- Load a CVar with a provided value
function E:LoadRegisteredCVars()
	for name, value in pairs(self.CVars) do
		SaveDefault(name, value)
		SetCVar(name, value)
	end
end

-- Reverts all altered CVars back to their previous value (defaults)
-- This is to make sure that changes strictly stay in when CUI is enabled.
-- We made it an option to disable this behaviour, as it could cause problems with other AddOns that alter the exact same ones
function E:DisableCVars()
	if not CO.db.global.revertCVarsOnDisable then return end
	
	for name, value in pairs(Defaults) do
		SetCVar(name, value)
	end
end

hooksecurefunc(E, "OnInitialize", function()
	EngineEvent:RegisterEvent("PLAYER_ENTERING_WORLD")
	
	EngineEvent:SetScript("OnEvent", function(self)
		E:UpdateCVars()
	end)

	-- Hide and then hook to hide the next one that probably shows up - This thing is annoying. Cannot do anything about the sound sadly
	if CO.db.profile.engine.enableActioncam and CO.db.profile.engine.hideActioncamNotification then
		UIParent:UnregisterEvent("EXPERIMENTAL_CVAR_CONFIRMATION_NEEDED")
		--StaticPopup_Hide("EXPERIMENTAL_CVAR_WARNING")
		hooksecurefunc("StaticPopup_Show", function(...) StaticPopup_Hide("EXPERIMENTAL_CVAR_WARNING") end)
	end
end)