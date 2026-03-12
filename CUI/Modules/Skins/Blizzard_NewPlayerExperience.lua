local E = unpack(select(2, ...)) -- Engine, Locale
local CO, Module = E:LoadModules("Config", "Blizzard_NewPlayerExperience")
Module.Autoload = true

--[[-------------------------

	As there arose some issues with the new NPE system, we try to fix/handle them here
	1. When using custom actionbars

-------------------------]]--

local _
local _G			= _G
local select		= select
local C_AddOns_IsAddOnLoaded				= C_AddOns.IsAddOnLoaded

local function Pointer_OnShow(self)
	if self.AnchoredToSpellbook then
		self:Hide()
	end
end

function Module:HandleSpellbookPointer()
	-- Iterate all pointers and assign the OnShow hook
	local i=1
	local Frame, Anchor
	while true do
		Frame = _G['NPE_PointerFrame_' .. i]
		Anchor = nil
		if not Frame then break end
		
		if not Frame.CustomShowHooked then
			Frame:HookScript('OnShow', Pointer_OnShow)
			Frame.CustomShowHooked = true
		end
		
		Anchor = select(2, Frame:GetPoint())
		if Anchor == _G.SpellbookMicroButton then
			Frame.AnchoredToSpellbook = true
			Frame:Hide()
			--break
		else
			Anchor = nil
			Frame.AnchoredToSpellbook = nil
		end
		------------
		i=i+1
	end
	
	return Frame or false
end

function Module:HandlePointer(content, direction, anchorFrame, ofsX, ofsY, relativePoint, backupDirection, showMovieName, loopMovie, resolution)
	--print(self, content, direction, anchorFrame, ofsX, ofsY, relativePoint, backupDirection, showMovieName, loopMovie, resolution)
end

function Module:Construct()	
	Module:HandleSpellbookPointer()	
	hooksecurefunc(Class_AddSpellToActionBar, 'ShowScreenTutorial', Module.HandleSpellbookPointer)
end

function Module:Init()
	E:FireOnAddOnLoaded(self, "Construct", "Blizzard_NewPlayerExperience")

	--[[if C_AddOns_IsAddOnLoaded("Blizzard_NewPlayerExperience") then
		self:Construct()
	else
		self:RegisterEvent("PLAYER_ENTERING_WORLD")
		self:RegisterEvent("ADDON_LOADED")
		self:SetScript("OnEvent", function(self, event)
			if C_AddOns_IsAddOnLoaded("Blizzard_NewPlayerExperience") then
				self:UnregisterAllEvents()
				self:Construct()
			end
		end)
	end]]--
end

E:AddModule("Blizzard_NewPlayerExperience", Module)