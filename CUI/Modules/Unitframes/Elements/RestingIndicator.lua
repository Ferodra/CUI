local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF = E:LoadModules("Config", "Unitframes")

--[[--------------------
	Unitframe Extension	
--------------------]]--

local _
local unpack		= unpack
local pairs			= pairs
local tinsert		= table.insert
local IsResting		= IsResting
local Module = {}
Module.IncludeUnits = {'player'}

-----------------------------------------

local EventHandler = CreateFrame("Frame")
local FramePool = {}
local Events = {"PLAYER_ENTERING_WORLD", "PLAYER_UPDATE_RESTING"}

local Texture = [[Interface\CharacterFrame\UI-StateIcon]]
local TexCoord = {0, 0.5, 0, 0.421875}

local function SetElementVisibility(self, state)
	if state then
		self:Show()
		if self.RestLoopAnim then
			self.RestLoopAnim:Play()
		end
	else
		self:Hide()
		if self.RestLoopAnim then
			self.RestLoopAnim:Stop()
		end
	end
end

local function UpdateElement(self)
	SetElementVisibility(self, not self.Disabled and IsResting())
end

do
	-- Handles all event updates for this module
	for k, v in pairs(Events) do
		EventHandler:RegisterEvent(v)
	end
	EventHandler.Handles = {}
	EventHandler:SetScript("OnEvent", function(self, event, ...)
		for _, F in pairs(self.Handles) do
			UpdateElement(F.RestingIndicator)
		end
	end)
end

----------

local function UpdateMode(self)
	local Config = CO.db.profile.unitframe.units[self.ConfigKey]
	
	if self.RestingIndicator then
		SetElementVisibility(self.RestingIndicator, false)
	end
	
	if not Config.restingIndicator or not FramePool[self.unit] then return else
		self.RestingIndicator = Config.restingIndicator.animMode == false and FramePool[self.unit].Tex or FramePool[self.unit].Anim
		self.RestingIndicator.ForceUpdate = UpdateElement
	end
end

-- Gets called automatically when the unitframes first are initialized and on config update
function Module:LoadConfig(limit)
	local Config
	
	for _, self in pairs(EventHandler.Handles) do
		self = limit or self
		
		Config = CO.db.profile.unitframe.units[self.ConfigKey]
		
		UpdateMode(self)
		
		if Config.restingIndicator then
			if not Config.restingIndicator.enable then self.RestingIndicator:Hide(); self.RestingIndicator.Disabled = true; else
				self.RestingIndicator:ClearAllPoints()
				self.RestingIndicator:SetPoint("CENTER", self.Overlay, Config.restingIndicator.position, Config.restingIndicator.offsetX, Config.restingIndicator.offsetY)
				self.RestingIndicator:SetSize(Config.restingIndicator.size, Config.restingIndicator.size)
				self.RestingIndicator:SetFrameLevel(self.Overlay:GetFrameLevel() + 25)
				
				self.RestingIndicator.Disabled = false
			end
		else
			self.RestingIndicator.Disabled = true
		end
		
		self.RestingIndicator:ForceUpdate()
		
		if limit then break end
	end
end

function Module:Create(F)
	local AnimFrame = CreateFrame("Frame", nil, F.Overlay, "RestLoopTemplate_CUI")
	AnimFrame:Hide()
	AnimFrame.RestLoopAnim:Stop()
	local TexFrame = E:CreateTextureFrame(nil, F.Overlay, 20, 20, "ARTWORK")
	TexFrame.T:SetTexture(Texture)
	TexFrame.T:SetTexCoord(unpack(TexCoord))
	TexFrame:Hide()
	
	-- Just do it this way, since we only have one indicator per UF (if we'd do it for more than just player for some reason)
	FramePool[F.unit] = {
		['Anim'] = AnimFrame,
		['Tex'] = TexFrame,
	}
	
	UpdateMode(F)
	tinsert(EventHandler.Handles, F)
end

---------- Add Module
UF.Modules["RestingIndicator"] = Module