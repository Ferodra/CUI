local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF = E:LoadModules("Config", "Unitframes")

--[[--------------------
	Unitframe Extension	
--------------------]]--

local _
local pairs			= pairs
local tinsert		= table.insert
local Module = {}

-----------------------------------------

local EventHandler = CreateFrame("Frame")
local Events = {"INCOMING_RESURRECT_CHANGED"}

local function UpdateElement(self)
	if self.Disabled then return end
		self.Unit = self:GetParent().Unit
		if unit and self.Unit ~= unit then return end
	
	if UnitHasIncomingResurrection(self.Unit) then
		self:Show()
	else
		self:Hide()
	end
end

do
	-- Handles all event updates for this module
	for k, v in pairs(Events) do
		EventHandler:RegisterEvent(v)
	end
	EventHandler.Handles = {}
	EventHandler:SetScript("OnEvent", function(self, event, ...)
		for _, F in pairs(self.Handles) do
			UpdateElement(F.ResurrectIndicator)
		end
	end)
end

----------

-- Gets called automatically when the unitframes first are initialized and on config update
function Module:LoadProfile()
	local Config
	
	for _, self in pairs(EventHandler.Handles) do
		Config = CO.db.profile.unitframe.units[self.ProfileUnit]
		
		if Config.resIndicator then
			if not Config.resIndicator.enable then self.ResurrectIndicator:Hide(); self.ResurrectIndicator.T:SetTexture(nil) self.ResurrectIndicator.Disabled = true; else
				self.ResurrectIndicator.T:SetTexture([[Interface\RaidFrame\Raid-Icon-Rez]])
				self.ResurrectIndicator:ClearAllPoints()
				self.ResurrectIndicator:SetPoint("CENTER", self.Overlay, Config.resIndicator.position, Config.resIndicator.offsetX, Config.resIndicator.offsetY)
				self.ResurrectIndicator:SetSize(Config.resIndicator.size, Config.resIndicator.size)
				self.ResurrectIndicator:SetFrameLevel(self.Overlay:GetFrameLevel() + 25)
				
				self.ResurrectIndicator.Disabled = false
			end
		end
	end
end

function Module:Create(F)
	F.ResurrectIndicator = E:CreateTextureFrame(nil, F, 20, 20, "ARTWORK")
	
	F.ResurrectIndicator.ForceUpdate = UpdateElement
	
	tinsert(EventHandler.Handles, F)
end

---------- Add Module
UF.Modules["ResurrectIndicator"] = Module