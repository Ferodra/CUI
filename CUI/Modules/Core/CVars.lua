local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, L = E:LoadModules("Config", "Locale")

--[[-------------------------------------------------
	
	This small lib is being used to mass load CVars
	at a specific point in the code.
	
	This prevents directly setting CVars and
	makes everything more convenient, since
	CUI modifies several CVars.
	
-------------------------------------------------]]--

---------------------------------------------------
local pairs 					= pairs
local SetCVar 					= SetCVar
---------------------------------------------------

E.CVars = {}
local EngineEvent = CreateFrame("Frame")
local CVars = {"cameraPitchMoveSpeed", "cameraYawMoveSpeed", "cameraPitchSmoothSpeed", "cameraYawSmoothSpeed", "test_cameraDynamicPitch", "test_cameraDynamicPitchBaseFovPad", 
"test_cameraDynamicPitchBaseFovPadFlying", "test_cameraTargetFocusEnemyEnable", "test_cameraTargetFocusEnemyStrengthPitch", "test_cameraTargetFocusEnemyStrengthYaw", 
"test_cameraTargetFocusInteractEnable", "test_cameraTargetFocusInteractStrengthPitch", "test_cameraTargetFocusInteractStrengthYaw", "test_cameraOverShoulder", "test_cameraHeadMovementStrength"}

function E:UpdateCVars()
	for _, name in pairs(CVars) do
		self:RegisterCVar(name, CO.db.profile.CVars[name])
	end
	
	self:LoadRegisteredCVars()
end

-- Adds a CVar to the register
function E:RegisterCVar(CVar, value)
	self.CVars[CVar] = value
end

-- Load a CVar with a provided value
function E:LoadRegisteredCVars()
	for k,v in pairs(self.CVars) do
		SetCVar(k, v)
	end
end

hooksecurefunc(E, "OnInitialize", function()
	EngineEvent:RegisterEvent("ADDON_LOADED")
	EngineEvent:RegisterEvent("PLAYER_ENTERING_WORLD")
	
	EngineEvent:SetScript("OnEvent", function(self)
		E:UpdateCVars()
	end)

	-- Hide and then hook to hide the next one that probably shows up - This thing is annoying. Cannot do anything about the sound sadly
	if CO.db.profile.engine.hideActioncamNotification then
		UIParent:UnregisterEvent("EXPERIMENTAL_CVAR_CONFIRMATION_NEEDED")
		--StaticPopup_Hide("EXPERIMENTAL_CVAR_WARNING")
		hooksecurefunc("StaticPopup_Show", function(...) StaticPopup_Hide("EXPERIMENTAL_CVAR_WARNING") end)
	end
end)