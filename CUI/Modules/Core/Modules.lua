local AddOn = unpack(select(2, ...)) -- Engine

--[[===========================
		Module System
=============================]]

-- Provide full modularity by separating every Addon module into its own thing.
-- This also allows plugins that can be embedded in the users config (custom code etc)
-- Note: Every Module is a Frame
AddOn.ModuleLoadQueue = {}
local function QueueModuleAutoload(name)
	tinsert(AddOn.ModuleLoadQueue, name)
end

function AddOn:LoadModuleAutoloadQueue()
	for k, v in pairs(AddOn.ModuleLoadQueue) do
		AddOn:InitializeModule(v)
	end
end

AddOn.Modules = {}
function AddOn:AddModule(name, object)
	-- Store in Engine
	if self.Modules[name] then
		-- Add additional data to already existing table
		-- That way, the modules never will have to be reloaded!
		for k,v in pairs(object) do
			self.Modules[name][k] = v
		end
	else
		self.Modules[name] = object
	end
	
	self.Modules[name].initialized = false
	if self.Modules[name].Autoload then
		if self.InitComplete then
			self:InitializeModule(name)
		else
			QueueModuleAutoload(name)
		end
	end
	
	return
end

local function ValidateModule(name)
	assert(type(name) == 'string', 'Module name has to be a string. Usage: [string] name')
	
	if not AddOn.Modules[name] then
		AddOn.Modules[name] = CreateFrame('Frame', "CUI_Module_" .. name)
		AddOn.Modules[name].SecureHook = AddOn.SecureHook
	end
	
	return AddOn.Modules[name]
end

-- Enables mass-initialization by providing module names
-- args: (string) Name of the module(s) to load ['Core', 'Config', ...]
function AddOn:InitializeModule(...)
	
	local name
	
	for i=1, select('#', ...) do
		name = select(i, ...)
		if name then
			ValidateModule(name)
			
			if self.Modules[name] and not self.Modules[name].initialized then
				assert(self.Modules[name].Init, ('Module %s has no Init method'):format(name))
				
				if self.Modules[name].UpdateDB then
					self.Modules[name]:UpdateDB()
				end
				self.Modules[name]:Init()
				self.Modules[name].initialized = true
			end
		end
	end
end

-- Loads module reference on demand and initialize if @param2 is true and module wasnt initialized yet
function AddOn:LoadModule(name, init)
	ValidateModule(name)
	
	if init then
		self:InitializeModule(name)
	end
	
	return self.Modules[name]
end

-- Batch-loading of modules
-- Args: (string) Names of Modules to load ['Config', 'Locale', ...]
function AddOn:LoadModules(...)
	local CurrentModule
	local Modules = {}
	for i=1, select('#', ...) do
		CurrentModule = self:LoadModule(select(i, ...), false)
		if CurrentModule then
			Modules[i] = CurrentModule
		end
	end
	
	return unpack(Modules)
end

AddOn.InitSettings = {}
function AddOn:AddSettingsModule(object)
	tinsert(self.InitSettings, object)
end

function AddOn:InitSettingsModules()
	for k,v in pairs(self.InitSettings) do
		assert(v.Init, 'Settings module requires an Init method')
		v:Init()
	end
end