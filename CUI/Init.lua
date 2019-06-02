--[[========================================================================================
	
	
	Author: Ferodra [Arenima - Alleria EU]
		Email: ferodra@gmx.de

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	THE SOFTWARE.
    ========================================================================================]]

--[[
	This Addon provides a big, dynamic library full of methods to instantly create unitframes for every need.

	"local *" and "E.*" explaination:
		"local" defines the private scope in LUA
		"E" is our 'class' name in this case and lets us access everything defined within.
	
	Since we want to access some variables across our AddOn, we have to throw them into this private(/public) scope (local(/E)).
	
	Important Lua-Garbage note:
		Setting the value of any table via {}, creates a NEW table and will contribute to generating garbage!!!
		To properly do this, empty a table with "wipe(t)" and set values with: "table.val = newvalue"
		Not table = {val = newvalue}
]]--

	
--[[===========================
		Init and Caching
=============================]]
local _
local _G			= _G
local unpack		= unpack
local LibStub		= LibStub
local CreateFrame 	= CreateFrame
local print			= print
local select		= select
local format		= string.format
local tinsert		= table.insert


local AddOnName, E							= 			... -- AddOn-Name, Engine
local AceAddon = _G.LibStub("AceAddon-3.0")
local AddOn = AceAddon:NewAddon(AddOnName, "AceHook-3.0")
AddOn.AddOnName = AddOnName

E[1] = AddOn
E[2] = {}

-- Add optional AddOns in the TOC section 'OptionalDeps'
AddOn.Libs = {
	['AceAddon'] 	= AceAddon,
	['Callbacks'] 	= LibStub("CallbackHandler-1.0"):New(E),
	['LibSmooth'] 	= LibStub("LibSmoothStatusBar-1.0"),
	['Masque'] 		= LibStub('Masque', true),
	
}
AddOn.Masque = AddOn.Libs.Masque

-- Callback table
AddOn.Callbacks = {}

-- CUI Global to access the API everywhere
_G['CUI'] = E
--[[===========================
			CUI Parent
=============================]]
AddOn.Parent								=			CreateFrame("Frame", "CUIParent", UIParent)
do
	AddOn.Parent:SetFrameLevel(UIParent:GetFrameLevel())
	AddOn.Parent:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT")
	AddOn.Parent:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT")
	
	AddOn.ClientVersion, AddOn.ClientBuild, AddOn.ClientBuildDate, AddOn.ClientBuildRevision = GetBuildInfo()
end
--[[===========================
			Core
=============================]]

-- VARIOUS RUNTIME VARIABLES BEGIN
	AddOn.Debug									=			nil -- Controlled by Config, when set to nil. Set to true or false to override
	AddOn.Revision								=			8513 -- Revision Number - used to check for updates
	AddOn.Version								=			"0.8.5 Test"
	AddOn.VersionDate							=			1558789338 -- May 25th 2019 - 15:02

	AddOn.InitComplete							=			false

	local colorReset 						= 			"|r"
	local bracketColor						=			"|cffFF4500" -- Tangerine
	local prefixColor 						= 			"|cffffcc00" -- Yellow
	local messageColor 						= 			"|cff00ccff" -- Sky Blue
	AddOn.PrintPrefix 							= ("%s<%s%s%s%s%s>%s"):format(bracketColor, colorReset, prefixColor, AddOnName, colorReset, bracketColor, colorReset)

	AddOn.UNIT_MAXLEVEL = GetMaxPlayerLevel()

-- Mass event registering
	function AddOn:RegisterEvents(obj, ...)
		for i=1,select('#', ...) do
			obj:RegisterEvent(select(i, ...))
		end
	end


--[[===========================
			Console
=============================]]
	-- Prints AddOn messages to console/chat
	function AddOn:print(msg)
		print(format("%s %s%s%s", self.PrintPrefix, messageColor, msg, colorReset))
	end

	-- Prints AddOn debug-messages to console/chat. But without any concatentation to prevent errors caused by nil
	-- Messages can be turned off by simply setting AddOn.Debug to false
	function AddOn:debugprint(...)
		if self.Debug == true then
			print(self.PrintPrefix .. colorReset, ...)
		end
	end

--[[===========================
		Module System
=============================]]
	-- Provide full modularity by simply separating every UI module.
	-- This also allows plugins that can be embedded in the users config (custom code etc)
	-- Note: Every Module is a Frame
	AddOn.ModuleLoadQueue = {}
	local function QueueModuleAutoload(name)
		tinsert(AddOn.ModuleLoadQueue, name)
	end

	local function LoadModuleAutoloadQueue()
		for k, v in pairs(AddOn.ModuleLoadQueue) do
			AddOn:InitializeModule(v)
		end
	end
	
	--
	
	AddOn.Modules = {}
	function AddOn:AddModule(name, object)
		-- Store in Engine
		if self.Modules[name] then
			-- Add additional data to already existing table
			-- In that way, the modules never will have to be reloaded!
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
		
		assert(type(name) == "string", "Module name has to be a string. Usage: [string] name")
		
		if not AddOn.Modules[name] then
			AddOn.Modules[name] = CreateFrame("Frame", nil)
		end
		
		return AddOn.Modules[name]
	end
	
	-- Enabled mass-initializing by providing the name
	-- args: (string) Name of the module(s) to load ["Core", "Config", ...]
	function AddOn:InitializeModule(...)
		
		local name
		
		for i=1, select('#', ...) do
			name = select(i, ...)
			if name then
				ValidateModule(name)
				
				if self.Modules[name] and not self.Modules[name].initialized then
					assert(self.Modules[name].Init, ("Module %s has no Init method"):format(name))
					
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
	function AddOn:GetModule(name, init)
		ValidateModule(name)
		
		if init then
			self:InitializeModule(name)
		end
		
		return self.Modules[name]
	end

	-- Mass-loading of modules
	-- Args: (string) Names of Modules to load ["Config", "Locale", ...]
	function AddOn:LoadModules(...)
		local CurrentModule
		local Modules = {}
		for i=1, select('#', ...) do
			CurrentModule = self:GetModule(select(i, ...), false)
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
			assert(v.Init, "Settings module requires an Init method")
			v:Init()
		end
	end
-- MODULE SYSTEM END

--[[===========================
		Handlers
=============================]]

function AddOn:ResizeEParent(state)
	if state == "original" then
		self.Parent:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 0)
	else
		self.Parent:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, -OrderHallCommandBar:GetHeight())
	end
end

function AddOn:HandleCommandBar()
	OrderHallCommandBar:HookScript("OnShow", function() AddOn:ResizeEParent("new") end)
	OrderHallCommandBar:HookScript("OnHide", function() AddOn:ResizeEParent("original") end)
end

do
	if OrderHallCommandBar then
		AddOn:HandleCommandBar()
	else
		local f = CreateFrame("Frame")
		f:RegisterEvent("ADDON_LOADED")
		f:SetScript("OnEvent", function(self, event, addon)
			if event == "ADDON_LOADED" and addon == "Blizzard_OrderHallUI" then
				if InCombatLockdown() then
					self:RegisterEvent("PLAYER_REGEN_ENABLED")
				else
					AddOn:HandleCommandBar()
				end
				self:UnregisterEvent(event)
			elseif event == "PLAYER_REGEN_ENABLED" then
				AddOn:HandleCommandBar()
				self:UnregisterEvent(event)
			end
		end)
	end
end

--[[===========================
		Main Init
=============================]]

-- Init core modules here
-- This is because we need the config before everything else.
-- OnInit is the earliest point where we can do stuff with the profiles
-- ArtLib is dependent on this, since we change the 3D world font. This has to happen as soon as possible.
function AddOn:OnInitialize()
	self:InitializeModule("Config", "Core", "ArtLib")
	
	if self.Debug == nil then
		self.Debug = AddOn.db.global.debugMode
	end
end

function AddOn:OnEnable()
	
	self:InitCallbacks()
	self:UpdateCVars()
	
	-- Core functionality modules. Those need to have a specific load-order, that's why we cannot autoload them!
	self:InitializeModule("Minimap", "Worldmap", "Chat", "Tooltip", "Unitframes", "Auras", "Bar_Auras", "Bar_Experience", "Bar_Cast", "Bar_Reputation", "Bar_Honor", "Layout", "Actionbars")
	local B	 = self:GetModule("Blizzard", true)
	-- PO	 = self:GetModule("Performance_Optimizer", true)
	
	
	-- This is responsible for loading all kinds of plug-ins. We can add plug-ins to the queue via:
	-- Module.Autoload = true
	LoadModuleAutoloadQueue()
	
	-- Remove Blizz Frames after every module has been initialized, since they may be dependent on them more or less
	B:RemoveBlizzard()
	
	-- Load Path Font config
	self:UpdateAllFonts()
	
	------------------------------------------------------------------------
	-- User defined toggle of Lua-Errors
	------------------------------------------------------------------------
	
		ScriptErrorsFrame:SetScript("OnShow", function(self, ...)
			if not CO.db.profile.LUAErrors then
				self:Hide()
				AddOn:print("LUA-Error received!")
			end
		end)
	-- print("\124Hmylinktype:myfunc\124h\124T".."Click to show"..":16\124t\124h") 
	------------------------------------------------------------------------
	
	-- Safe call since user may have created a parenting loop that would prevent further execution
	xpcall(self.LoadMoverPositions, geterrorhandler())
	
	self.InitComplete = true
end