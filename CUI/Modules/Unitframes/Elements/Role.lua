local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF = E:LoadModules('Config', 'Unitframes')

--[[--------------------
	Unitframe Extension	
--------------------]]--

local _
local tinsert 					= table.insert
local UnitGroupRolesAssigned 	= UnitGroupRolesAssigned

local Module = {}
Module.ExcludeUnits = {'pet', 'boss'}

local RoleTextures = {
	['TANK'] 	= [[Interface\AddOns\CUI\Textures\icons\TANK]],
	['HEALER'] 	= [[Interface\AddOns\CUI\Textures\icons\HEALER]],
	['DAMAGER'] = [[Interface\AddOns\CUI\Textures\icons\DAMAGER]],
}
UF.RoleTexture = RoleTextures

-----------------------------------------

local EventHandler = CreateFrame('Frame')
local Events = {'ROLE_CHANGED_INFORM', 'GROUP_ROSTER_UPDATE', 'RAID_ROSTER_UPDATE', 'PLAYER_ROLES_ASSIGNED'}

local function UpdateElement(Element)
	if Element.Disabled then return end
	
	Element.T:SetTexture(RoleTextures[UnitGroupRolesAssigned(Element.Owner.unit)])
end

do
	-- Handles all event updates for this module
	for k, v in pairs(Events) do
		EventHandler:RegisterEvent(v)
	end
	EventHandler.Handles = {}
	EventHandler:SetScript('OnEvent', function(self, event, ...)
		for _, F in pairs(self.Handles) do
			UpdateElement(F.Role)
		end
	end)
end

----------

function Module:LoadConfig(limit)
	local Config, Element
	
	for _, self in pairs(EventHandler.Handles) do
		self = limit or self
		
		Config = CO.db.profile.unitframe.units[self.ConfigKey]
		Element = self.Role
		
		if Config.roleIcon then
			if Config.roleIcon.enable then
				Element:ClearAllPoints()
				Element:SetPoint('CENTER', self.Overlay, Config.roleIcon.position, Config.roleIcon.offsetX, Config.roleIcon.offsetY)
				Element:SetSize(Config.roleIcon.size, Config.roleIcon.size)
				Element:SetFrameLevel(self.Overlay:GetFrameLevel() + 25)
				
				Element:Show()
				Element.Disabled = false
			else
				Element:Hide()
				Element.Disabled = true
			end
		end
		
		if limit then return end
	end
end

function Module:Create(F)
	local Element = E:CreateTextureFrame(nil, F, 16, 16, 'OVERLAY')
	
	Element.Owner = F
	Element.ForceUpdate = UpdateElement
	
	F.Role = Element
	F.RoleIndicator = Element
	
	tinsert(EventHandler.Handles, F)
end

---------- Add Module
UF:RegisterModule('RoleIndicator', Module)