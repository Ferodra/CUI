---@class E, L
local E, L = unpack(select(2, ...)) -- Engine, Locale
---@class CO, L
local CO, L = E:LoadModules('Config', 'Locale')

local _
local C_AddOns_IsAddOnLoaded			= C_AddOns.IsAddOnLoaded
local C_AddOns_IsAddOnLoadOnDemand		= C_AddOns.IsAddOnLoadOnDemand
local C_AddOns_LoadAddOn				= C_AddOns.LoadAddOn

E.Media = LibStub('LibSharedMedia-3.0')
CO.AceGUIWidgetLSMlists = {
	['font'] = E.Media:HashTable('font'),
	['sound'] = E.Media:HashTable('sound'),
	['statusbar'] = E.Media:HashTable('statusbar'),
	['border'] = E.Media:HashTable('border'),
	['background'] = E.Media:HashTable('background'),
}

local DBContext = {
	[1] = 'global',
	[2] = 'char',
	[3] = 'profile',
}

function E:UpdateDatabase()
	for k, v in pairs(self.Modules) do
		if v.UpdateDB then
			v:UpdateDB()
		end
	end
end

function E:UpdateAllModules()
	-- Update all modules
	for k, v in pairs(self.Modules) do
		if v.UpdateDB then
			v:UpdateDB()
		end
		if v.LoadConfig then
			v:LoadConfig()
		end
	end
	
	E:UpdateCVars()
	E:UpdateAllFonts()
	E:LoadMoverPositions()
	E:UpdateAllBarTextures()
	
	-- Post module updates, since those require some special treatment
	E:LoadModule('Actionbars'):UpdateArtFill()
	E:LoadModule('Unitframes'):LoadAllHolderConfig()
	E:LoadModule('Unitframes').Headers:LoadAll()
end

function CO:PerformDBUpdate()
	-- Update DB tables first
	E:UpdateDatabase()
	E:UpdateAllModules()
	
	if C_AddOns_IsAddOnLoaded('CUI_Config') then
		E:LoadModule('Config_Dialog'):ReloadAllModules()
	end
	
	
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

function CO:OnDatabaseShutdown()
	if CO.db.global and CO.db.global.useGlobalCharacterDB then
		if self.db.char then
			-- Write current char db to global scope
			self.db.global.charDB = E:TableDeepCopy(self.db.char)
		end
	end

	-- Disable AddOn
	E:Disable()
end

function CO:GetConfigWindow()
	local ACD = LibStub('AceConfigDialog-3.0')
	local ConfigOpen = ACD and ACD.OpenFrames and ACD.OpenFrames['CUI']
	return ConfigOpen and ConfigOpen.frame
end

local function AddImportFunction()
	
	-- Simple shallow copy for copying defaults
	local function copyTable(src, dest)
		if type(dest) ~= "table" then dest = {} end
		if type(src) == "table" then
			for k,v in pairs(src) do
				if type(v) == "table" then
					-- try to index the key first so that the metatable creates the defaults, if set, and use that table
					v = copyTable(v, dest[k])
				end
				dest[k] = v
			end
		end
		return dest
	end
	
	CO.db.ImportProfile = function(self, tbl, silent)
		if type(tbl) ~= "table" then
			error(("Usage: AceDBObject:ImportProfile(tbl): 'tbl' - table expected, got %q."):format(type(tbl)), 2)
		end

		-- Reset the profile before copying
		self.ResetProfile(self, nil, true)

		local profile = self.profile

		copyTable(tbl, profile)

		-- populate to child namespaces
		-- if self.children then
			-- for _, db in pairs(self.children) do
				-- self.ImportProfile(db, self.keys["profile"], true)
			-- end
		-- end

		-- Callback: OnProfileChanged, database, sourceProfileKey
		self.callbacks:Fire("OnProfileChanged", self, self.keys["profile"])
	end
end

function CO:InitGlobalCharDB()
	local Defaults = self:GetCharacterDefaults()
	
	if not self.db.global.charDB then
		self.db.global.charDB = {}
	else
		-- Retrieve char db from global scope
		-- Yes, this will create a lot of uneccesary DB clutter, but is probably the best way to go about it,
		-- since disabling it again will leave the player with the last globally set config
		self.db.char = E:TableMergeAdvanced(self.db.char, self.db.global.charDB, self:GetCharacterDefaults())
	end
end

-- Write global char db to char db on init
-- Write char db to global db on shutdown when useGlobalCharacterDB is enabled.

function CO:DBConversion()
	-- Clean up some f'ups that are cluttering the users DB
	if CO.db.profile.global then
		CO.db.profile.global.timePlayed = nil
		CO.db.profile.global.filters = nil
		CO.db.profile.global.colors = nil
	end
	if CO.db.profile.media.accountData then
		CO.db.profile.media.accountData = nil
	end
	if CO.db.global.itemDB.data then
		CO.db.global.itemDB.data = nil
	end
	
	if CO.db.global and CO.db.global.useGlobalCharacterDB then
		if CO.db.char then
			self:InitGlobalCharDB()
		end
	end
end

function CO:GetConfigTable(type, context)
	if type == 'UNITFRAMES_ALL' then
		return self.db[DBContext[context]].unitframe.units.all
	end
end

function CO:FinishInit()
	if E.InitComplete then
		self.db.RegisterCallback(self, 'OnProfileChanged', 'ProfileUpdate')
		self.db.RegisterCallback(self, 'OnProfileCopied', 'ProfileUpdate')
		self.db.RegisterCallback(self, 'OnProfileReset', 'ProfileUpdate')
		self.db.RegisterCallback(self, 'OnDatabaseShutdown', 'OnDatabaseShutdown')
	end
end

function CO:InitConfig()
	self.db	= LibStub('AceDB-3.0'):New('CUIDB', E.ConfigDefaults)
	
	self:DBConversion()
	local LibDualSpec = LibStub('LibDualSpec-1.0')
	LibDualSpec:EnhanceDatabase(self.db, 'CUI')
	
	E:UpdateDatabase()
	AddImportFunction()
end

function CO:AddToDefaults(tbl)
	E:TableMerge(E.ConfigDefaults, tbl)
	self:InitConfig() -- Re-init to apply
end

function CO:OpenConfig()
	
	local ConfigName = 'CUI_Config'
	
	if C_AddOns_IsAddOnLoadOnDemand(ConfigName) then
		if not InCombatLockdown() then
			if not C_AddOns_IsAddOnLoaded(ConfigName) then
				C_AddOns_LoadAddOn(ConfigName)
			end
			if C_AddOns_IsAddOnLoaded(ConfigName) then
				E:LoadModule('Config_Dialog'):OpenOptions()
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

function CO:Debug_AddData(Data)
	if not CO.db.global.Debug then
		CO.db.global.Debug = {}
	else
		wipe(CO.db.global.Debug)
	end
	
	for k,v in pairs(Data) do
		CO.db.global.Debug[k] = v
	end
end

function CO:Init()
	
	-- Config variables
	E.StickyMovers = 1
	
	self:SetDefaults() -- Call to external file
	self:InitConfig()
	

	self.DisplayWatcher = CreateFrame("Frame", "CUI_DisplayWatcherFrame")
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