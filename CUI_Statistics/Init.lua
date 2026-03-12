local E, L = unpack(CUI) -- Engine
local Module = select(2, ...)
local CO, TT = E:LoadModules("Config", "Tooltip")

local GetAddOnMetadata 	= GetAddOnMetadata or C_AddOns.GetAddOnMetadata
local IsAddOnLoaded 	= IsAddOnLoaded or C_AddOns.IsAddOnLoaded

Module.Autoload = true

local AddOnName = "CUI_Statistics"
Module.Revision							=			GetAddOnMetadata(AddOnName, 'X-Revision') 	-- Revision Number - used to check for updates
Module.Version							=			GetAddOnMetadata(AddOnName, 'Version')		-- Actual Version Number
Module.VersionDate						=			GetAddOnMetadata(AddOnName, 'X-Timestamp')	-- A timestamp of when this version was last updated

function Module:DBConversion()
	local Played = CO.db.global.timePlayed
	if Played and Played.characters then
		for k,v in pairs(Played.characters) do
			if not CO.db.global.accountData.characters[k] then
				CO.db.global.accountData.characters[k] = {}
			end
			if not CO.db.global.accountData.characters[k].timePlayed then
				CO.db.global.accountData.characters[k].timePlayed = {}
			end
			
			CO.db.global.accountData.characters[k].timePlayed = E:TableDeepCopy(v)
			
			if v.timePlayed and v.timePlayed.class then
				CO.db.global.accountData.characters[k].class = v.timePlayed.class
				v.timePlayed.class = nil
			end
			if v.timePlayed and v.timePlayed.level then
				CO.db.global.accountData.characters[k].level = v.timePlayed.level
				v.timePlayed.level = nil
			end
			
			if not self.db.global.characters then
				self.db.global.characters = {}
			end
			
			-- Copy to new DB Object
			self.db.global.characters[k] = E:TableDeepCopy(CO.db.global.accountData.characters[k])
		end
		
		-- Obliterate it
		CO.db.global.timePlayed = nil
		CO.db.global.accountData = nil
	end
end

function Module:Startup()
	self.db	= LibStub('AceDB-3.0'):New('CUISTATSDB', self.ConfigDefaults)
	
	-- self.db.RegisterCallback(self, 'OnProfileChanged', 'ProfileUpdate')
	-- self.db.RegisterCallback(self, 'OnProfileCopied', 'ProfileUpdate')
	-- self.db.RegisterCallback(self, 'OnProfileReset', 'ProfileUpdate')
	-- self.db.RegisterCallback(self, 'OnDatabaseShutdown', 'OnDatabaseShutdown')
	
	self:DBConversion()
	self:InitCurrentCharacter()
	
	for _, SubModule in pairs(self) do
		if SubModule and type(SubModule) == 'table' and SubModule.Init then
			SubModule:Init()
		end
	end
end

function Module:Init()
	self.db = CO.db.global.accountData
	
	if not IsAddOnLoaded("CUI") then
		self:RegisterEvent("ADDON_LOADED")
	else
		self:Startup()
		
		return
	end
	
	-- Just a failsafe
	-- Only do this, when CUI wasn't immediately found
	
	self:SetScript("OnEvent", function(self, event, addon)
		if addon == 'CUI' then
			self:UnregisterEvent('ADDON_LOADED')
			self:SetScript('OnEvent', nil)
			
			self:Startup()
		end
	end)
end

E:AddModule("Statistics", Module)