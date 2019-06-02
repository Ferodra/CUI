local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF = E:LoadModules("Config", "Unitframes")

--[[--------------------
	Unitframe Extension	
--------------------]]--

local _
local Module = {}
UF.ROLE_TANK_TEXTURE 	= [[Interface\AddOns\CUI\Textures\icons\TANK]]
UF.ROLE_HEAL_TEXTURE 	= [[Interface\AddOns\CUI\Textures\icons\HEALER]]
UF.ROLE_DPS_TEXTURE 	= [[Interface\AddOns\CUI\Textures\icons\DAMAGER]]

UF.RoleTexture = {
	["TANK"] 	= UF.ROLE_TANK_TEXTURE,
	["HEALER"] 	= UF.ROLE_HEAL_TEXTURE,
	["DAMAGER"] = UF.ROLE_DPS_TEXTURE,
}

-----------------------------------------

local EventHandler = CreateFrame("Frame")
local Events = {"ROLE_CHANGED_INFORM", "GROUP_ROSTER_UPDATE", "RAID_ROSTER_UPDATE"}

local function UpdateElement(Role)
	if Role.Disabled then return end
	
	Role.T:SetTexture(UF.RoleTexture[UnitGroupRolesAssigned(Role:GetParent().Unit)])
end

do
	-- Handles all event updates for this module
	for k, v in pairs(Events) do
		EventHandler:RegisterEvent(v)
	end
	EventHandler.Handles = {}
	EventHandler:SetScript("OnEvent", function(self, event, ...)
		for _, F in pairs(self.Handles) do
			UpdateElement(F.Role)
		end
	end)
end

----------

local ProfileTarget
function Module:LoadProfile()
	for _, self in pairs(EventHandler.Handles) do
		ProfileTarget = CO.db.profile.unitframe.units[self.ProfileUnit]
		
		if ProfileTarget.roleIcon then
			if not ProfileTarget.roleIcon.enable then self.Role:Hide(); self.Role.Disabled = true; else
				self.Role:ClearAllPoints()
				self.Role:SetPoint("CENTER", self.Overlay, ProfileTarget.roleIcon.position, ProfileTarget.roleIcon.offsetX, ProfileTarget.roleIcon.offsetY)
				self.Role:SetSize(ProfileTarget.roleIcon.size, ProfileTarget.roleIcon.size)
				self.Role:SetFrameLevel(self.Overlay:GetFrameLevel() + 25)
				
				self.Role:Show()
				self.Role.Disabled = false
			end
		end
	end
end

function Module:Create(F)
	F.Role = E:CreateTextureFrame(nil, F, 16, 16, "OVERLAY")
	
	F.Role.ForceUpdate = UpdateElement
	
	table.insert(EventHandler.Handles, F)
end

---------- Add Module
UF.Modules["RoleIndicator"] = Module