local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF = E:LoadModules("Config", "Unitframes")

--[[--------------------
	Unitframe Extension	
--------------------]]--

local _
local Module = {}
UF.ReadyCheckStates = {
	["ready"] = [[Interface\AddOns\CUI\Textures\icons\Readycheck_Ready]],
	["notready"] = [[Interface\AddOns\CUI\Textures\icons\Readycheck_NotReady]],
	["waiting"] = [[Interface\AddOns\CUI\Textures\icons\Readycheck_Waiting]],
}

-----------------------------------------

local EventHandler = CreateFrame("Frame")
local Events = {"READY_CHECK", "READY_CHECK_CONFIRM", "READY_CHECK_FINISHED"}

local function UpdateElement(self, event)
	if self.Disabled then return end
	
	self.Unit 		= self:GetParent().Unit
	self.IsReady 	= GetReadyCheckStatus(self.Unit)
	
	if event == "READY_CHECK_FINISHED" then
		-- Timeout
		if self.Status == "waiting" then
			self.T:SetTexture(UF.ReadyCheckStates["notready"])
		end
		
		self.Animation:Play()
	end
	
	if UnitExists(self.Unit) and self.IsReady then
		
		self.CurrentIconColor = CO.db.profile.colors.readycheck[self.IsReady]
		
		if self.IsReady == "ready" then
			self.T:SetTexture(UF.ReadyCheckStates["ready"])
		elseif self.IsReady == "notready" then
			self.T:SetTexture(UF.ReadyCheckStates["notready"])
		else
			self.T:SetTexture(UF.ReadyCheckStates["waiting"])
		end
		
		if self.CurrentIconColor then
			-- Set user defined color for icons
			self.T:SetVertexColor(self.CurrentIconColor[1], self.CurrentIconColor[2], self.CurrentIconColor[3])
		else
			E:print("Warning: No icon color for ready state " .. self.IsReady .. " found. Please tell the developer!")
		end
		
		self:Show()
		self.Status = self.IsReady
		
		return;
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
			UpdateElement(F.ReadyCheckIndicator, event)
		end
	end)
end

local function Animation_OnFinished(self)
	self:GetParent():Hide();
end

----------

local ProfileTarget
function Module:LoadProfile()
	for _, self in pairs(EventHandler.Handles) do
		ProfileTarget = CO.db.profile.unitframe.units[self.ProfileUnit]
		
		if ProfileTarget.readyCheckIndicator then
			if not ProfileTarget.readyCheckIndicator.enable then self.ReadyCheckIndicator:Hide(); self.ReadyCheckIndicator.T:SetTexture(nil) self.ReadyCheckIndicator.Disabled = true; else
				self.ReadyCheckIndicator:ClearAllPoints()
				self.ReadyCheckIndicator:SetPoint("CENTER", self.Overlay, ProfileTarget.readyCheckIndicator.position, ProfileTarget.readyCheckIndicator.offsetX, ProfileTarget.readyCheckIndicator.offsetY)
				self.ReadyCheckIndicator:SetSize(ProfileTarget.readyCheckIndicator.size, ProfileTarget.readyCheckIndicator.size)
				
				self.ReadyCheckIndicator:Show()
				self.ReadyCheckIndicator.Disabled = false
			end
		end
	end
end

function Module:Create(F)
	F.ReadyCheckIndicator = E:CreateTextureFrame({"CENTER", F, "TOP", 0, 0}, F, 20, 20, "ARTWORK")
			
	local AnimationGroup = F.ReadyCheckIndicator:CreateAnimationGroup()
	AnimationGroup:SetScript('OnFinished', Animation_OnFinished)

	local Animation = AnimationGroup:CreateAnimation('Alpha')
	Animation:SetFromAlpha(1)
	Animation:SetToAlpha(0)
	Animation:SetStartDelay(8)
	Animation:SetDuration(2)
		F.ReadyCheckIndicator.Animation = AnimationGroup
	
	F.ReadyCheckIndicator.ForceUpdate = UpdateElement
	
	table.insert(EventHandler.Handles, F)
end

---------- Add Module
UF.Modules["ReadyCheckIndicator"] = Module