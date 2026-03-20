----------------------------------------------------
local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF = E:LoadModules("Config", "Unitframes")

local Module = CreateFrame("Frame", "RaidRoleFrame", E.Parent, "SecureHandlerStateTemplate")
Module.Autoload = true -- This will cause CUI to automatically load this module. No external init needed.
----------------------------------------------------

local format					= string.format
local unpack					= unpack
local pairs						= pairs
local select					= select
local type						= type
local UnitExists				= UnitExists
local IsInRaid					= IsInRaid
local IsInGroup					= IsInGroup
local UnitGroupRolesAssigned	= UnitGroupRolesAssigned
local RegisterStateDriver		= RegisterStateDriver

local Types = {[1] = {"TANK", "LEFT"}, [2] = {"HEALER", "CENTER"}, [3] = {"DAMAGER", "RIGHT"}}
local SpecInfo = E:GetAllSpecInfo()

function Module:LoadConfig()
	self.db = CO.db.profile.dataframes.raidroledata
	
	UnregisterStateDriver(self, "visible")
	
	if self.db.enable then
		
		self:SetScale(self.db.scale)
		self.Background:SetColorTexture(unpack(self.db.backgroundColor))
		self.Border:SetBackdropBorderColor(unpack(self.db.borderColor))
		
		for k, v in pairs(Types) do
			self.Roles[v[1]]:EnableMouse(not self.db.clickThrough)
		end
		
		RegisterStateDriver(self, "visible", (self.State and "[group:raid] 1; [group:party] 1; 0") or "1")
		
		self.ForceMoverEnabled = nil
	else
		RegisterStateDriver(self, "visible", "0")
		self.ForceMoverEnabled = false
	end
end

function Module:Toggle()
	if not self.State then
		self.State = true
	else
		self.State = false
	end
	
	self:LoadConfig()
end

local function InsertUnitData(Data, Unit)
	Data.Count = (Data.Count or 0) + 1

	Data[Data.Count] = {}
	Data[Data.Count].Unit = Unit
	Data[Data.Count].Name = UnitName(Unit)
	Data[Data.Count].ClassColor = E:GetUnitClassColor(Unit)
	
end

-- GetGroupMemberCounts essentially does the same thing, but we also want the corresponding player names
-- UnitGroupRolesAssigned(F.unit)
-- @TODO: Clean this mess of a function up
function Module:GetNumRoles(type)
	local Data = {}
	
	Data.Count = 0
	if not IsInRaid() then
		if IsInGroup() then
			-- 1 to 5, because you never know
			for i=1,5 do
				if UnitExists(format("party%s", i)) and UnitGroupRolesAssigned(format("party%s", i)) == type then
					InsertUnitData(Data, format("party%s", i))
				end
			end
			
			if UnitGroupRolesAssigned("player") == type or select(1, E:GetPlayerSpecInfo()) == type then
				InsertUnitData(Data, "player")
			end
		end
	else
		for i=1,40 do
			if UnitExists(format("raid%s", i)) and UnitGroupRolesAssigned(format("raid%s", i)) == type then
				InsertUnitData(Data, format("raid%s", i))
			end
		end
	end
	
	return Data
end

-- /dump CUI[1]:LoadModule("RaidRoleData"):GetNumRoles("TANK")

local function Update(self, event, ...)
	for k, v in pairs(Types) do
		self.Roles[v[1]].Num = self:GetNumRoles(v[1])
		self.Roles[v[1]].Font:SetText(self.Roles[v[1]].Num.Count)
	end
end

function Module:InitUpdate()
	self:RegisterEvent("PLAYER_ROLES_ASSIGNED")
	self:RegisterEvent("ROLE_CHANGED_INFORM")
	self:RegisterEvent("GROUP_ROSTER_UPDATE")
	self:RegisterEvent("UPDATE_INSTANCE_INFO")
	
	self:SetScript("OnEvent", Update)
end

function Module:Construct()
	self:SetSize(210, 45)
	
	self.Background = E:CreateBackground(self)
	self.Border 	= E:CreateBorder(self)
	
	self.Roles = {}
	local Tab
	for k, v in pairs(Types) do
		Tab = CreateFrame("Frame", string.format("RaidRoleFrame%s", v[1]), self)
		self.Roles[v[1]] = Tab
		
		Tab:SetSize(70, 40)
		Tab:SetPoint(v[2], self, v[2], 8, -3)
		
		Tab:EnableMouse(true)
		Tab:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
			
			if self.Num then
				for k,v in pairs(self.Num) do
					if type(v) == "table" then
						GameTooltip:AddLine(v.Name, unpack(v.ClassColor, 1, 3))
					end
				end
			end
			
			GameTooltip:Show()
		end)
		Tab:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)
		
		Tab.Icon = E:CreateTextureFrame({"CENTER", Tab, "CENTER", 8, 8}, Tab, 16, 16, "OVERLAY")
		Tab.Icon:ClearAllPoints()
		Tab.Icon:SetPoint("LEFT", Tab, "LEFT")
		Tab.Icon.T:SetTexture(UF.RoleTexture[v[1]])
		
		Tab.Font = Tab:CreateFontString(nil)
			E:InitializeFontFrame(Tab.Font, "OVERLAY", "FRIZQT__.TTF", 11, {0.933, 0.886, 0.125}, 1, {-20,0}, "", 0, 0, Tab, "RIGHT", {1,1})
		Tab.Font:SetText(0)
	end
	
	self:InitUpdate()
	
	E:SetVisibilityHandler(self)
	RegisterStateDriver(self, "visible", "[group:raid] 1; [group:party] 1; 0")
	
	E:CreateMover(self, L["raidRoleFrame"], nil, nil, nil, "A frame that provides you with a quick summary of what roles are filled in your group.", "misc")
end

-- Prototype method. Called automatically when profile was changed in some way
function Module:UpdateDB()
	self.db = CO.db.profile.dataframes.raidroledata
end

function Module:Init()
	self:UpdateDB()

	E:HandleFrameInPetBattles(self)

	self:Construct()
	self:LoadConfig()
end

E:AddModule("RaidRoleData", Module)