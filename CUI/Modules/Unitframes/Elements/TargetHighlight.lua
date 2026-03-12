local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF = E:LoadModules("Config", "Unitframes")

--[[--------------------
	Unitframe Extension
	
	For this module, we're using an 'Enabled'
	state instead of 'Disabled', as we would run
	into errors otherwise due to some frames
	running ForceUpdate OnUpdate before
	we've loaded our config here.
--------------------]]--

local _
local pairs 			= pairs
local unpack 			= unpack
local UnitIsUnit 		= UnitIsUnit
local tinsert 			= table.insert
local Module = {}
Module.Handles = {}
Module.EventHandler = CreateFrame("Frame")

-----------------------------------------

local function UpdateElement(self, event)
	if not Module.EventHandler.Enabled then return end
	
	Module:HighlightUnit("target")
end

local function ForceUpdate()
	UpdateElement()
end

----------

function Module:HighlightUnit(Unit)
	for _, self in pairs(Module.Handles) do
		if UnitIsUnit(Unit, self.unit) and self.unit ~= "target" then
			E:UIFrameFadeIn(self.TargetHighlight, Module.FadeTime, self.TargetHighlight:GetAlpha(), 1)
		else
			E:UIFrameFadeOut(self.TargetHighlight, Module.FadeTime, self.TargetHighlight:GetAlpha(), 0)
		end
	end
end

local Config
function Module:LoadConfig()
	Config = CO.db.profile.unitframe.units.all
	
	if Config.targetHighlight then
		if not Config.targetHighlight.enable then
			Module.EventHandler:UnregisterAllEvents()
			
			for _, self in pairs(Module.Handles) do
				self.TargetHighlight:Hide()
			end
			
			Module.FadeTime = 0.5
			
			Module.EventHandler.Enabled = nil;
		else
			Module.EventHandler:RegisterEvent("PLAYER_TARGET_CHANGED")
			
			for _, self in pairs(Module.Handles) do
				self.TargetHighlight:SetBackdropBorderColor(unpack(Config.targetHighlight.color))
				self.TargetHighlight.SetBorderSize(Config.targetHighlight.borderSize)
			end
			Module.FadeTime = Config.targetHighlight.fadeTime
			
			Module.EventHandler.Enabled = true;
			UpdateElement()
		end
	end
end

function Module:Create(F)
	if true then return end
	F.TargetHighlight = E:CreateBorder(F.Overlay, nil, 1)
	F.TargetHighlight:SetFrameLevel(F.Overlay:GetFrameLevel() + 25)
	F.TargetHighlight:SetAlpha(0)
	F.TargetHighlight:Hide()
	
	F.TargetHighlight.ForceUpdate = ForceUpdate
	
	tinsert(self.Handles, F)
end

do
	Module.EventHandler:SetScript("OnEvent", UpdateElement)
end

---------- Add Module
UF.Modules["TargetHighlight"] = Module