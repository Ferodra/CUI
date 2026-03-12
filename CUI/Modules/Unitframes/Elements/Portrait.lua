local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF = E:LoadModules("Config", "Unitframes")

--[[--------------------
	Unitframe Extension	
--------------------]]--

local _
local pairs			= pairs
local tinsert		= table.insert
local UnitExists	= UnitExists
local UnitIsUnit	= UnitIsUnit
local SetPortraitTexture	= SetPortraitTexture
local Module = {}

-----------------------------------------

Module.Frames = {}

local function UpdateElement(Element, Unit)
	if Element.Disabled or not UnitExists(Element.Owner.unit) or (Unit and not UnitIsUnit(Unit, Element.Owner.unit)) then return end
	
	if Element.Mode == "3D" then
		E:SetModelInfo(Element.Model, "SetUnit", Element.Owner.unit)
		Element.Model:SetModelAlpha(Element.DBALpha or 1)
	else
		SetPortraitTexture(Element.Texture.Tex, Element.Owner.unit)
	end
end

local function ForceUpdate(Element)
	UpdateElement(Element, Element.Owner.unit)
end

local function OnEvent(Element, event, ...)
	UpdateElement(Element, ...)
end

local function AlphaFix(self)
	local Element = self.Portrait
	Element.Model:SetModelAlpha(Element.DBALpha or 1)
end

----------

-- Handles frame portrait creation on demand
local function Initialize(self)
	local Config = Module.db.units[self.ConfigKey].portrait
	
	self.Portrait.Mode = Config.style
	
	if Config.style == "3D" then
		if not self.Portrait.Model then
			self.Portrait.Model = CreateFrame("PlayerModel", nil)
			self.Portrait.Model:SetParent(self.Portrait)
			self.Portrait.Model:SetAllPoints(self.Portrait)
			self.Portrait.Model.Owner = self
		end
		
		self.Portrait.Model:Show()
		if self.Portrait.Texture then
			self.Portrait.Texture:Hide()
		end
	else
		if not self.Portrait.Texture then
			self.Portrait.Texture = CreateFrame("Frame", nil)
			self.Portrait.Texture:SetParent(self.Portrait)
			self.Portrait.Texture:SetAllPoints(self.Portrait)
			self.Portrait.Texture.Owner = self
			
			self.Portrait.Texture.Tex = self.Portrait.Texture:CreateTexture(nil, "OVERLAY")
			self.Portrait.Texture.Tex:SetParent(self.Portrait.Texture)
			self.Portrait.Texture.Tex:SetAllPoints(self.Portrait.Texture)
			
			-- Scale up by 18% to fill quadratic shape, as SetPortraitTexture outputs a circular texture
			self.Portrait.Texture.Tex:SetTexCoord(.18, .82, .18, .82)
		end
		self.Portrait.Texture:Show()
		if self.Portrait.Model then
			self.Portrait.Model:Hide()
		end
	end
	
	UpdateElement(self.Portrait, self.unit)
end

function Module:LoadConfig(limit)
	local Config
	for _, F in pairs(Module.Frames) do
		if limit then F = limit end
		
		Config = self.db.units[F.ConfigKey]
		
		if not Config.portrait.enable then
			F.Portrait:Hide()
			F.Portrait.Disabled = true
			
			if F.Portrait.Model then
				E:SetModelInfo(F.Portrait.Model, "ClearModel")
			elseif F.Portrait.Texture then
				F.Portrait.Texture.Tex:SetTexture(nil)
			end
		else	
			F.Portrait:Show()
			F.Portrait.Disabled = false
			
			F.Portrait.DBALpha = Config.portrait.alpha
			F.Portrait:SetAlpha(Config.portrait.alpha)
			
			Initialize(F)
			
			F.Portrait:ClearAllPoints()
			if Config.portrait.overlay then
				-- The Portrait somehow stretches across the UF border by 1px
				F.Portrait:SetPoint('TOPLEFT', F, 'TOPLEFT')
				F.Portrait:SetPoint('BOTTOMRIGHT', F, 'BOTTOMRIGHT', -1, 1)
			else
				F.Portrait:SetPoint(E:InversePosition(Config.portrait.position), F, Config.portrait.position, Config.portrait.offsetX, Config.portrait.offsetY)
				F.Portrait:SetSize(Config.portrait.width, Config.portrait.height)
			end
			
			if Config.portrait.style == "3D" then
				E:SetModelInfo(F.Portrait.Model, "SetPortraitZoom", Config.portrait.zoom)
				E:SetModelInfo(F.Portrait.Model, "SetCamDistanceScale", Config.portrait.camDistanceScale)
				E:SetModelInfo(F.Portrait.Model, "SetRotation", Config.portrait.rotation)
				
				hooksecurefunc(F, "SetAlpha", AlphaFix)
			end
		end
		
		if limit then return end
	end
end

function Module:Create(F)
	F.Portrait = CreateFrame("Frame", nil)
	F.Portrait:SetParent(F)
	F.Portrait:SetAllPoints(F)
	F.Portrait.Owner = F
	
	F.Portrait:SetIgnoreParentAlpha(true)
	
	
	Initialize(F)
	
	F.Portrait:RegisterUnitEvent("UNIT_PORTRAIT_UPDATE", F.unit)
	F.Portrait:RegisterEvent("PORTRAITS_UPDATED")
	F.Portrait:SetScript("OnEvent", OnEvent)
	
	F.Portrait.CutOffParent = CreateFrame("Frame", nil, F)
	F.Portrait.CutOffParent:SetFrameLevel(F.Health:GetFrameLevel() + 5) -- This way it always is above the Bar
	
	F.Portrait.ForceUpdate = ForceUpdate
	tinsert(Module.Frames, F)
end

---------- Add Module
UF:RegisterModule('Portrait', Module)