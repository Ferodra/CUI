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
local AtlasTexture						= [[Interface\TargetingFrame\UI-RaidTargetingIcons]]
local Module = {}

-----------------------------------------

local EventHandler = CreateFrame("Frame")
local Events = {"RAID_TARGET_UPDATE"}

local function UpdateElement(Element)
	if Element.Disabled then return end
	
	local index = GetRaidTargetIndex(Element.Owner.unit)
	if index then
		if not Element.T:GetTexture() then
			Element.T:SetTexture(AtlasTexture)
		end

		SetRaidTargetIconTexture(Element.T, index)
		Element:Show()
	else
		Element:Hide()
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

local function UpdateUnit(self)
	UpdateElement(self)
end

----------

-- Gets called automatically when the unitframes first are initialized and on config update
function Module:LoadConfig(limit)
	local Config
	
	for _, self in pairs(EventHandler.Handles) do
		self = limit or self
		
		Config = CO.db.profile.unitframe.units[self.ConfigKey]
		
		if Config.targetIcon then
			if not Config.targetIcon.enable then self.TargetIcon:Hide(); self.TargetIcon.T:SetTexture(nil) self.TargetIcon.Disabled = true; else
				self.TargetIcon:ClearAllPoints()
				self.TargetIcon:SetPoint("CENTER", self.Overlay, Config.targetIcon.position, Config.targetIcon.offsetX, Config.targetIcon.offsetY)
				self.TargetIcon:SetSize(Config.targetIcon.size, Config.targetIcon.size)
				self.TargetIcon:SetFrameLevel(self.Overlay:GetFrameLevel() + 25)
				
				self.TargetIcon.Disabled = false
			end
		end
		
		if limit then break end
	end
end

function Module:Create(F)
	local Element = E:CreateTextureFrame(nil, F, 20, 20, "ARTWORK")
	Element.ForceUpdate = UpdateElement
	Element.UpdateUnit = UpdateUnit
	Element.Owner = F
	
	Element:Hide()
	
	F.TargetIcon = Element	
	
	tinsert(EventHandler.Handles, F)
end

---------- Add Module
UF.Modules["TargetIcon"] = Module