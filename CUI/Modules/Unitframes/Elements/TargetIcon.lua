local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF = E:LoadModules("Config", "Unitframes")

--[[--------------------
	Unitframe Extension	
--------------------]]--

local _
local pairs			= pairs
local tinsert		= table.insert
local GetRaidTargetIndex 				= GetRaidTargetIndex
local SetRaidTargetIconTexture 			= SetRaidTargetIconTexture
local Module = {}

-----------------------------------------

local EventHandler = CreateFrame("Frame")
local Events = {"RAID_TARGET_UPDATE"}

local function UpdateElement(self)
	if self.Disabled then return end
		self.Unit = self:GetParent().Unit
		if unit and self.Unit ~= unit then return end
	
	local index = GetRaidTargetIndex(self.Unit)
	if index then
		if not self.T:GetTexture() then
			self.T:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
		end

		SetRaidTargetIconTexture(self.T, index)
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
			UpdateElement(F.TargetIcon)
		end
	end)
end

----------

-- Gets called automatically when the unitframes first are initialized and on config update
function Module:LoadProfile()
	local Config
	
	for _, self in pairs(EventHandler.Handles) do
		Config = CO.db.profile.unitframe.units[self.ProfileUnit]
		
		if Config.targetIcon then
			if not Config.targetIcon.enable then self.TargetIcon:Hide(); self.TargetIcon.T:SetTexture(nil) self.TargetIcon.Disabled = true; else
				self.TargetIcon:ClearAllPoints()
				self.TargetIcon:SetPoint("CENTER", self.Overlay, Config.targetIcon.position, Config.targetIcon.offsetX, Config.targetIcon.offsetY)
				self.TargetIcon:SetSize(Config.targetIcon.size, Config.targetIcon.size)
				self.TargetIcon:SetFrameLevel(self.Overlay:GetFrameLevel() + 25)
				
				self.TargetIcon.Disabled = false
			end
		end
	end
end

function Module:Create(F)
	F.TargetIcon = E:CreateTextureFrame(nil, F, 20, 20, "ARTWORK")
	
	F.TargetIcon.ForceUpdate = UpdateElement
	
	tinsert(EventHandler.Handles, F)
end

---------- Add Module
UF.Modules["TargetIcon"] = Module