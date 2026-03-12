--[[========================================================================================
	
	
	Author: Ferodra [Arenima - Alleria EU]
		Email: ferodra@gmx.de

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the 'Software'), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense copies of the 
	Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	THE SOFTWARE.
    ========================================================================================]]

--[[
	This Addon provides a big, dynamic library of methods to instantly create unitframes for every need.

	'local *' and 'E.*' explaination:
		'local' defines the private scope in LUA
		'E' is our 'class' name in this case and lets us access everything defined within.
	
	Since we want to access some variables across our AddOn, we have to throw them into this private(/public) scope (local(/E)).
	
	Important Lua-Garbage note:
		Setting the value of any table via {} creates a NEW table and will contribute to generating garbage!
		To properly do this, empty a table with 'wipe(t)' and set values with: 'table.val = newvalue'
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
local GetAddOnMetadata = C_AddOns.GetAddOnMetadata


local AddOnName, E							= ... -- AddOn-Name, Engine
local AceAddon = _G.LibStub('AceAddon-3.0')
local AddOn = AceAddon:NewAddon(AddOnName, 'AceHook-3.0')
AddOn.AddOnName = AddOnName

E[1] = AddOn
E[2] = {}

-- Expansions
AddOn.IsTBC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC -- not used
AddOn.IsCata = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC
AddOn.IsWrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC
AddOn.IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
AddOn.IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC

-- Add optional AddOns in the TOC section 'OptionalDeps'
AddOn.Libs = {
	['AceAddon'] 	= AceAddon,
	['AceLocale'] 	= LibStub("AceLocale-3.0"),
	['Callbacks'] 	= LibStub('CallbackHandler-1.0'):New(E),
	['LibSmooth'] 	= LibStub('LibSmoothStatusBar-1.0'),
	['Masque'] 		= LibStub('Masque', true)
}

-- Callback table
AddOn.Callbacks = {}

-- CUI Global to access the API everywhere
_G['CUI'] = E
--[[===========================
			CUI Parent
=============================]]
AddOn.Parent = CreateFrame('Frame', 'CUIParent', UIParent)
do
	AddOn.Parent:SetFrameLevel(UIParent:GetFrameLevel())
	AddOn.Parent:SetPoint('BOTTOMLEFT', UIParent, 'BOTTOMLEFT')
	AddOn.Parent:SetPoint('TOPRIGHT', UIParent, 'TOPRIGHT')
	
	AddOn.ClientVersion, AddOn.ClientBuild, AddOn.ClientBuildDate, AddOn.ClientBuildRevision = GetBuildInfo()
end

_G.BINDING_HEADER_CUI = AddOnName
_G["BINDING_NAME_CLICK CUIZONEABILITYBUTTON:LeftButton"] = "Zone Ability"
_G["BINDING_NAME_CLICK ExtraActionButton1:LeftButton"] = "Extra Ability"

--[[===========================
			Core
=============================]]

-- VARIOUS RUNTIME VARIABLES BEGIN
	AddOn.Debug								=			nil -- Controlled by Config, when set to nil. Set to true or false to override. Requires hard set to apply for missing locales
	AddOn.Revision							=			GetAddOnMetadata('CUI', 'X-Revision') 	-- Revision Number - used to check for updates
	AddOn.Version							=			GetAddOnMetadata('CUI', 'Version')		-- Actual Version Number
	AddOn.VersionDate						=			GetAddOnMetadata('CUI', 'X-Timestamp')	-- A timestamp of when this version was last updated

	AddOn.UNIT_MAXLEVEL = GetMaxPlayerLevel()

-- Mass event registering
	function AddOn:RegisterEvents(obj, ...)
		for i=1,select('#', ...) do
			obj:RegisterEvent(select(i, ...))
		end
	end


--[[===========================
		Handlers
=============================]]

function AddOn:ResizeEParent(state)
	if state == 'original' then
		self.Parent:SetPoint('TOPRIGHT', UIParent, 'TOPRIGHT', 0, 0)
	else
		self.Parent:SetPoint('TOPRIGHT', UIParent, 'TOPRIGHT', 0, -OrderHallCommandBar:GetHeight())
	end
end

function AddOn:HandleCommandBar()
	OrderHallCommandBar:HookScript('OnShow', function() AddOn:ResizeEParent('new') end)
	OrderHallCommandBar:HookScript('OnHide', function() AddOn:ResizeEParent('original') end)
end

function AddOn:SafeLoadMovers()
	-- Safe call since user may have created a parenting loop that would prevent further execution
	xpcall(self.LoadMoverPositions, geterrorhandler())
end

do
	if OrderHallCommandBar then
		AddOn:HandleCommandBar()
	else
		local f = CreateFrame('Frame')
		f:RegisterEvent('ADDON_LOADED')
		f:SetScript('OnEvent', function(self, event, addon)
			if event == 'ADDON_LOADED' and addon == 'Blizzard_OrderHallUI' then
				if InCombatLockdown() then
					self:RegisterEvent('PLAYER_REGEN_ENABLED')
				else
					AddOn:HandleCommandBar()
				end
				self:UnregisterEvent(event)
			elseif event == 'PLAYER_REGEN_ENABLED' then
				AddOn:HandleCommandBar()
				self:UnregisterEvent(event)
			end
		end)
	end
end

--[[===========================
		Main Disable
=============================]]

function AddOn:Disable()
	-- Call 'Disable' Method on all compatible modules (mostly due to CVars)
	-- This is to ensure we're cleaning up necessary stuff before DB shutdown
	-- It's not really required to do any of it, as DB stuff is handled automatically
	-- by AceDB already, but we're keeping the option around
	for k, v in pairs(self.Modules) do
		if v.Disable then
			v:Disable()
		end
	end
	
	self:DisableCVars()
end

--[[===========================
		Main Init
=============================]]

-- Init core modules here
-- This is because we need the config before everything else.
-- OnInit is the earliest point where we can do stuff with the profiles
-- ArtLib is dependent on this, since we change the 3D world font. This has to happen as soon as possible.
function AddOn:OnInitialize()	
	self:InitializeModule('Config', 'Core', 'ArtLib')
	
	if self.Debug == nil then
		local CO = AddOn:LoadModules("Config")
		self.Debug =  CO.db.global.debugMode
	end
end

function AddOn:OnEnable()
	
	self:InitCallbacks()
	self:UpdateCVars()
	
	_, self.PlayerClassName, self.PlayerClass = UnitClass("player")	
	
	-- Overlay Parent to make everything show up above the layout textures
	self.OverlayParent = CreateFrame('Frame', "CUI_OverlayParentFrame", self.Parent)
	self.OverlayParent:SetAllPoints(self.Parent)
	self.PetBattleParent = CreateFrame('Frame', "CUI_PetBattleStateHandler", self.OverlayParent, 'SecureHandlerStateTemplate')
	self.PetBattleParent:SetAllPoints(self.OverlayParent)
	self:HandleFrameInPetBattles(self.PetBattleParent, true)
	
	-- Prepare Format Cache
	self:RebuildNumberFormatCache()
	
	-- Core functionality modules. Those need to have a specific load-order, that's why we cannot autoload them!
	--self:InitializeModule('Minimap', 'Worldmap', 'Chat', 'Filters', 'Tooltip', 'Unitframes', 'Auras', 'Bar_Auras', 'Bar_Experience', 'Castbar', 'Bar_Reputation', 'Bar_Honor', 'Layout', 'Actionbars')
	self:InitializeModule('Minimap', 'Worldmap', 'Chat', 'Filters', 'Tooltip', 'Unitframes', 'Auras', 'Bar_Auras', 'Bar_Experience', 'Bar_Reputation', 'Bar_Honor', 'Layout', 'Actionbars')
	local B	 = self:LoadModule('Blizzard', true)
	-- PO	 = self:LoadModule('Performance_Optimizer', true)
	
	
	--[[ This is responsible for loading all kinds of plug-ins. We can add plug-ins to the queue via:
	-- Module.Autoload = true
		
	]]--
	self:LoadModuleAutoloadQueue()
	
	-- Remove Blizz Frames after every module has been initialized, since they may be dependent on them more or less
	B:RemoveBlizzard()
	
	-- Load Path Font config
	self:UpdateAllFonts()
	
	------------------------------------------------------------------------
	-- User defined toggle of Lua-Errors
	------------------------------------------------------------------------
	
	local CO = self:LoadModule("Config")
	ScriptErrorsFrame:HookScript('OnShow', function(self, ...)
		if not CO.db.profile.LUAErrors then
			self:Hide()
			AddOn:print('Lua-Error received!')
		end
	end)
		
	-- print('\124Hmylinktype:myfunc\124h\124T'..'Click to show'..':16\124t\124h') 
	------------------------------------------------------------------------
	
	-- Safe call since user may have created a parenting loop that would prevent further execution
	self:SafeLoadMovers()
	
	self.InitComplete = true
end