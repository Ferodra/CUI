local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF = E:LoadModules('Config', 'Unitframes')

--[[--------------------
	Unitframe Extension	
--------------------]]--

local _
local tinsert = table.insert
local Module = {}
Module.IncludeUnits = {'player', 'party', 'raid', 'raid40', 'arena'}
UF.ReadyCheckStates = {
	['ready'] = [[Interface\AddOns\CUI\Textures\icons\Readycheck_Ready]],
	['notready'] = [[Interface\AddOns\CUI\Textures\icons\Readycheck_NotReady]],
	['waiting'] = [[Interface\AddOns\CUI\Textures\icons\Readycheck_Waiting]],
}

-----------------------------------------

local EventHandler = CreateFrame('Frame')
local Events = {'READY_CHECK', 'READY_CHECK_CONFIRM', 'READY_CHECK_FINISHED'}

local function UpdateTexture(self, type)
	if not (type == 'waiting' or type == 'ready' or type == 'notready') then return end
	
	self.T:SetTexture(UF.ReadyCheckStates[type])
	self.T:SetVertexColor(unpack(CO.db.profile.colors.readycheck[type]))
end

local function UpdateElement(self, event)
	if self.Disabled then return end
	
	local Status 	= GetReadyCheckStatus(self.Owner.unit)
	
	if event == 'READY_CHECK_FINISHED' then
		-- Timeout
		if self.Status == 'waiting' then
			UpdateTexture(self, 'notready')
		end
		
		self.Animation:Play()
	end
	
	if UnitExists(self.Owner.unit) and Status then
		if Status == 'ready' or Status == 'notready' then
			UpdateTexture(self, Status)
		else
			UpdateTexture(self, 'waiting')
		end
		
		self:Show()
		self.Status = Status
		
		return;
	end
end

do
	-- Handles all event updates for this module
	for k, v in pairs(Events) do
		EventHandler:RegisterEvent(v)
	end
	EventHandler.Handles = {}
	EventHandler:SetScript('OnEvent', function(self, event, ...)
		for _, F in pairs(self.Handles) do
			UpdateElement(F.ReadyCheckIndicator, event)
		end
	end)
end

local function Animation_OnFinished(self)
	self:GetParent():Hide();
	self:GetParent().T:SetTexture(nil)
end

----------

function Module:LoadConfig(limit)
	local ProfileTarget, Element
	
	for _, self in pairs(EventHandler.Handles) do
		self = limit or self
		
		ProfileTarget = CO.db.profile.unitframe.units[self.ConfigKey]
		
		if ProfileTarget.readyCheckIndicator then
			
			Element = self.ReadyCheckIndicator
			
			if not ProfileTarget.readyCheckIndicator.enable then Element:Hide(); Element.T:SetTexture(nil) Element.Disabled = true; else
				Element:ClearAllPoints()
				Element:SetPoint('CENTER', self.Overlay, ProfileTarget.readyCheckIndicator.position, ProfileTarget.readyCheckIndicator.offsetX, ProfileTarget.readyCheckIndicator.offsetY)
				Element:SetSize(ProfileTarget.readyCheckIndicator.size, ProfileTarget.readyCheckIndicator.size)
				
				Element:Show()
				Element.Disabled = false
			end
		end
		
		if limit then break end
	end
end

function Module:Create(F)
	local Element = E:CreateTextureFrame({'CENTER', F, 'TOP', 0, 0}, F, 20, 20, 'ARTWORK')
	Element:SetFrameLevel(F.Overlay:GetFrameLevel() + 25)
	
	local AnimationGroup = Element:CreateAnimationGroup()
	AnimationGroup:SetScript('OnFinished', Animation_OnFinished)

	local Animation = AnimationGroup:CreateAnimation('Alpha')
	Animation:SetFromAlpha(1)
	Animation:SetToAlpha(0)
	Animation:SetStartDelay(8)
	Animation:SetDuration(2)
		Element.Animation = AnimationGroup
	
	Element:Hide()
	
	F.ReadyCheckIndicator = Element
	Element.Owner = F
	Element.ForceUpdate = UpdateElement
	
	tinsert(EventHandler.Handles, F)
end

---------- Add Module
UF:RegisterModule('ReadyCheckIndicator', Module)