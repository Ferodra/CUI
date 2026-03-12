local E, L = unpack(CUI) -- Engine
local CO, CD = E:LoadModules("Config", "Config_Dialog")

local _
local RECOMMENDED			= RECOMMENDED
local tinsert 				= table.insert

local DefaultConfigType 	= 'Advanced'
local RecommendedConfigType = 'Advanced'
local LocaleKey 			= 'ConfigType-%s'
local RecommendedKey		= '%s (%s)'
CD.CurrentConfigType 		= nil
CD.Modules 					= {['Simple'] = {}, ['Advanced'] = {}}


local function EnableModule(module)
	if module.Disabled == false then return end
	
	if module.Enable then
		module:Enable()
	end
	module.Disabled = false
end

local function DisableModule(module)
	if module.Disabled then return end
	
	if module.Disable then
		module:Disable()
	end
	module.Disabled = true
end

function CD:NewConfigType(name)
	if not self.Modules[name] then
		self.Modules[name] = {}
	end
end

function CD:SetConfigType(type, forceRefresh)

	type = type or CO.db.global.configType
	if not self.Modules[type] then
		type = DefaultConfigType
	end
	
	local Config = self.Modules[type]
	
	if not Config then error(('Requested config type (%s) does not exist.'):format(type)); return end
	if self.CurrentConfigType == type and not forceRefresh then return end -- No changes required
	
	
	if self.CurrentConfigType then
		-- Remove previously active config type, if necessary
		for _, module in pairs(self.Modules[self.CurrentConfigType]) do
			DisableModule(module)
		end
	end
	
	-- Enable new config type
	for _, module in pairs(Config) do
		EnableModule(module)
	end
	
	self.CurrentConfigType = type
	
	-- Perform new sort
	self:SortCategories()
	
	-- Refresh GUI on next frame
	-- The delay is extremely important, because changes in the option tables don't apply without it
	self:DelayedGUIRefresh(0)
end

function CD:ReloadAllModules()
	CD:SetConfigType(nil, true)
end

-- Registers a new config module of a variable type.
function CD:RegisterConfigModule(module, type)
	CD:NewConfigType(type)
	tinsert(self.Modules[type], module)
end

function CD:GetDefaultConfigType()
	return DefaultConfigType
end

function CD:GetConfigTypeList()
	
	local List = {}
	local LocalizedName
	local Recommended = L[(LocaleKey):format('Recommended')] or RECOMMENDED
	
	for Name, _ in pairs(self.Modules) do
		LocalizedName = L[(LocaleKey):format(Name)]
		
		if Name == RecommendedConfigType then
			List[Name] = '|cff1784d1' .. (RecommendedKey):format(LocalizedName or Name, Recommended) .. '|r'
		else
			List[Name] = '|cff1784d1' .. LocalizedName or Name .. '|r'
		end
	end
	
	return List
end