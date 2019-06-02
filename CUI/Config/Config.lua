local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, L = E:LoadModules('Config', 'Locale')

local _

E.Media = LibStub('LibSharedMedia-3.0')
CO.AceGUIWidgetLSMlists = {
	['font'] = E.Media:HashTable('font'),
	['sound'] = E.Media:HashTable('sound'),
	['statusbar'] = E.Media:HashTable('statusbar'),
	['border'] = E.Media:HashTable('border'),
	['background'] = E.Media:HashTable('background'),
}

function E:UpdateDatabase()
	E.db = CO.db.profile
	E.db.global = CO.db.global
	
	for k, v in pairs(E.Modules) do
		if v.UpdateDB then
			v:UpdateDB()
		end
	end
end

function E:UpdateAllModules()
	-- Update all modules
	for k, v in pairs(E.Modules) do
		if v.LoadProfile then
			v:LoadProfile()
		end
	end
	
	E:UpdateCVars()
	E:UpdateAllFonts()
	E:LoadMoverPositions()
	E:UpdateAllBarTextures()
	
	-- Post module updates, since those require some special treatment
	E:GetModule('Actionbars'):UpdateArtFill()
	E:GetModule('Unitframes'):LoadAllHolderConfig()
end

function CO:PerformDBUpdate()
	-- Update DB tables first
	E:UpdateDatabase()
	E:UpdateAllModules()
	
	E.isDBUpdating = nil
end

-- We have to keep this here, since we use spec based profiles that don't need the Config Dialog
function CO:ProfileUpdate(event)
	-- Prevent multiple updates
	if not E.isDBUpdating then
		-- Delay update by a bit, since we will get errors all over the place otherwise
		C_Timer.After(0.02, self.PerformDBUpdate)
		E.isDBUpdating = true
	end
end

function CO:InitializeSettings()
	self.db	= LibStub('AceDB-3.0'):New('CUIDB', E.ConfigDefaults)
	--self.db:RegisterDefaults(E.ConfigDefaults)
	
	self.db.RegisterCallback(self, 'OnProfileChanged', 'ProfileUpdate');
	self.db.RegisterCallback(self, 'OnProfileCopied', 'ProfileUpdate');
	self.db.RegisterCallback(self, 'OnProfileReset', 'ProfileUpdate');
	
	local LibDualSpec = LibStub('LibDualSpec-1.0')
	LibDualSpec:EnhanceDatabase(self.db, 'CUI')
	
	E:UpdateDatabase()
end

function CO:AddToDefaults(tbl)
	E:TableMerge(E.ConfigDefaults, tbl)
	self:InitializeSettings() -- Re-init to apply
end

function CO:OpenConfig()
	
	local ConfigName = 'CUI_Config'
	
	if IsAddOnLoadOnDemand(ConfigName) then
		if not InCombatLockdown() then
			if not IsAddOnLoaded(ConfigName) then
				LoadAddOn(ConfigName)
			end
			if IsAddOnLoaded(ConfigName) then
				E:GetModule('Config_Dialog'):OpenOptions()
			else
				E:print("Config module is disabled!")
			end
		else
			E:print("You cannot open the settings while in combat!")
		end
	else
		E:print("Config module is missing!")
	end
end

function CO:Init()
	self:SetDefaults() -- Call to external file
	self:InitializeSettings()
	

	self.DisplayWatcher = CreateFrame("Frame")
	self.DisplayWatcher:RegisterEvent("PLAYER_ENTERING_WORLD")
	
	self.DisplayWatcher:SetScript("OnEvent", function(self, event)
		if event == "PLAYER_ENTERING_WORLD" then
			self:RegisterEvent("UI_SCALE_CHANGED")
			self:RegisterEvent("DISPLAY_SIZE_CHANGED")
		elseif GetTime() - 5 > (self.LastNotificationTime or 0) then
			E:print("Resolution change detected! You may have to reload the UI for changes to take effect!")
			
			E:LoadMoverPositions()
			
			self.LastNotificationTime = GetTime()
		end
	end)
	
end

E:AddModule('Config', CO)