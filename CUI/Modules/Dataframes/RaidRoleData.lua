----------------------------------------------------
local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, L = E:LoadModules("Config", "Locale")
local UF

local RRD = CreateFrame("Frame", "RaidRoleFrame", E.Parent, "SecureHandlerStateTemplate")
RRD.Autoload = true -- This will cause CUI to automatically load this module. No external init needed.
----------------------------------------------------

local format					= string.format
local pairs						= pairs
local select					= select
local type						= type
local UnitExists				= UnitExists
local IsInRaid					= IsInRaid
local IsInGroup					= IsInGroup
local UnitGroupRolesAssigned	= UnitGroupRolesAssigned
local RegisterStateDriver		= RegisterStateDriver

local Types = {[1] = {"TANK", "LEFT"}, [2] = {"HEALER", "CENTER"}, [3] = {"DAMAGER", "RIGHT"}}


function RRD:LoadProfile()
	self.db = CO.db.profile.dataframes.raidroledata
	
	UnregisterStateDriver(self, "visible")
	
	if self.db.enable then
		
		self:SetScale(self.db.scale)
		self.Background:SetColorTexture(self.db.backgroundColor[1],self.db.backgroundColor[2],self.db.backgroundColor[3],self.db.backgroundColor[4])
		self.Border:SetBackdropBorderColor(self.db.borderColor[1],self.db.borderColor[2],self.db.borderColor[3],self.db.borderColor[4])
		
		for k, v in pairs(Types) do
			self.Roles[v[1]]:EnableMouse(not self.db.clickThrough)
		end
		
		if not self.State then
			RegisterStateDriver(self, "visible", "[group:raid] 1; [group:party] 1; 0")
		else
			RegisterStateDriver(self, "visible", "1")
		end
	else
		RegisterStateDriver(self, "visible", "0")
	end
	
	E:GetMover(self):SetScale(self.db.scale)
end

function RRD:Toggle()
	if not self.State then
		self.State = true
	else
		self.State = false
	end
	
	self:LoadProfile()
end

function RRD:NumAddUnit(i, unit)
	self.NumRoles[i] = {}
	self.NumRoles[i].Count = self.NumRoles.Count + 1
	self.NumRoles[i].Unit = unit
	
	self.NumRoles.Count = self.NumRoles.Count + 1
end

-- GetGroupMemberCounts essentially does the same thing, but we also want the corresponding player names
-- UnitGroupRolesAssigned(F.Unit)
-- @TODO: Clean this mess of a function up
function RRD:GetNumRoles(type)
	self.NumRoles = {}
	self.NumRoles.Count = 0
	if not IsInRaid() then
		if IsInGroup() then
			for i=1,4 do
				if UnitExists(format("party%s", i)) and UnitGroupRolesAssigned(format("party%s", i)) == type then
					self.NumRoles[i] = {}
					self.NumRoles[i].Count = self.NumRoles.Count + 1
					self.NumRoles[i].Unit = format("party%s", i)
					
					self.NumRoles.Count = self.NumRoles.Count + 1
				end
			end
			
			if UnitGroupRolesAssigned("player") == type then
				self.NumRoles[self.NumRoles.Count + 1] = {}
				self.NumRoles[self.NumRoles.Count + 1].Count = self.NumRoles.Count + 1
				self.NumRoles[self.NumRoles.Count + 1].Unit = "player"
				
				self.NumRoles.Count = self.NumRoles.Count + 1
			end
		end
	else
		for i=1,40 do
			if UnitExists(format("raid%s", i)) and UnitGroupRolesAssigned(format("raid%s", i)) == type then
				self.NumRoles[i] = {}
				self.NumRoles[i].Count = self.NumRoles.Count + 1
				self.NumRoles[i].Unit = format("raid%s", i)
				
				self.NumRoles.Count = self.NumRoles.Count + 1
			end
		end
	end
	
	return self.NumRoles
end

-- /dump CUI:GetModule("RaidRoleData"):GetNumRoles("TANK")

local function Update(self, event, ...)
	self.Roles.TANK.Num 	= self:GetNumRoles("TANK")
	self.Roles.HEALER.Num 	= self:GetNumRoles("HEALER")
	self.Roles.DAMAGER.Num 	= self:GetNumRoles("DAMAGER")
	
	self.Roles.TANK.Font:SetText(self.Roles.TANK.Num.Count)
	self.Roles.HEALER.Font:SetText(self.Roles.HEALER.Num.Count)
	self.Roles.DAMAGER.Font:SetText(self.Roles.DAMAGER.Num.Count)
end

function RRD:InitUpdate()
	self:RegisterEvent("PLAYER_ROLES_ASSIGNED")
	self:RegisterEvent("ROLE_CHANGED_INFORM")
	self:RegisterEvent("GROUP_ROSTER_UPDATE")
	self:RegisterEvent("UPDATE_INSTANCE_INFO")
	
	self:SetScript("OnEvent", Update)
end

function RRD:Construct()
	self:SetSize(210, 45)
	
	self.Background = E:CreateBackground(self)
	self.Border 	= E:CreateBorder(self)
	
	self.Roles = {}
	for k, v in pairs(Types) do
		self.Roles[v[1]] = CreateFrame("Frame", string.format("RaidRoleFrame%s", v[1]), self)
		self.Roles[v[1]]:SetSize(70, 40)
		self.Roles[v[1]]:SetPoint(v[2], self, v[2], 8, -3)
		
		self.Roles[v[1]]:EnableMouse(true)
		self.Roles[v[1]]:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
			
			if self.Num then
				for k,v in pairs(self.Num) do
					if type(v) == "table" then
						GameTooltip:AddLine(UnitName(v.Unit))
					end
				end
			end
			
			GameTooltip:Show()
		end)
		self.Roles[v[1]]:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)
		
		self.Roles[v[1]].Icon = E:CreateTextureFrame({"CENTER", self.Roles[v[1]], "CENTER", 8, 8}, self.Roles[v[1]], 16, 16, "OVERLAY")
		self.Roles[v[1]].Icon:ClearAllPoints()
		self.Roles[v[1]].Icon:SetPoint("LEFT", self.Roles[v[1]], "LEFT")
		self.Roles[v[1]].Icon.T:SetTexture(UF.RoleTexture[v[1]])
		
		self.Roles[v[1]].Font = self.Roles[v[1]]:CreateFontString(nil)
			E:InitializeFontFrame(self.Roles[v[1]].Font, "OVERLAY", "FRIZQT__.TTF", 11, {0.933, 0.886, 0.125}, 1, {-20,0}, "", 0, 0, self.Roles[v[1]], "RIGHT", {1,1})
		self.Roles[v[1]].Font:SetText(0)
	end
	
	self:InitUpdate()
	
	E:SetVisibilityHandler(self)
	RegisterStateDriver(self, "visible", "[group:raid] 1; [group:party] 1; 0")
	
	E:CreateMover(self, L["raidRoleFrame"], nil, nil, nil, "A frame that provides you with a quick summary of what roles are filled in your group.")
end

function RRD:Init()
	self.db = CO.db.profile.dataframes.raidroledata
	
	UF = E:GetModule("Unitframes")

	self:Construct()
	self:LoadProfile()
end

E:AddModule("RaidRoleData", RRD)