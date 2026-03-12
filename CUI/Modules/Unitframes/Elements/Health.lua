local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF = E:LoadModules("Config", "Unitframes")

--[[--------------------
	Unitframe Extension	
--------------------]]--

local _
local tinsert				= table.insert
local UnitPlayerControlled 	= UnitPlayerControlled
local UnitIsTapDenied 		= UnitIsTapDenied
local UnitHealth 			= UnitHealth
local UnitHealthMax 		= UnitHealthMax
local UnitIsDeadOrGhost 	= UnitIsDeadOrGhost
local Module = {}

-----------------------------------------

Module.Frames = {}

-------------------------


local function GetBarColor(Element, Unit)
	if Element.UseStaticColor then
		return Element.StaticColor
	else
		return E:GetUnitReactionColor(Unit, false)
	end
end

local function PostUpdate(Element, Event, Unit)
	if Element.Disabled then return end
	
	local IsPlayer = UnitPlayerControlled(Unit)
	if (not IsPlayer and UnitIsTapDenied(Unit)) or not UnitIsConnected(Unit) then
		Element:SetStatusBarColor(0.5, 0.5, 0.5)
	else	
		local Color = GetBarColor(Element, Unit)
		local HealthMissing = UnitHealthMissing(Unit)
		
		if not issecretvalue(HealthMissing) and Element.ColorByValue then
			-- Element:GetValue somehow returns the default value at first
			
			local r, g, b = E:ColorGradient((HealthMissing), 1, 0, 0, 1, 1, 0, Color.r or Color[1], Color.g or Color[2], Color.b or Color[3])
			Element:SetStatusBarColor(r, g, b, Color.a or Color[4] or 1)
		else			
			Element:SetStatusBarColor(Color.r or Color[1], Color.g or Color[2], Color.b or Color[3], Color.a or Color[4] or 1)
		end
	end
end

local function UpdateElement(Element, Event, Unit)
	if Element.Disabled or Unit ~= Element.Owner.unit then return end
	
	if Event == "UNIT_MAXHEALTH" or Event == "ForceUpdate" or not Element.MaxValue then
		Element.MaxValue = UnitHealthMax(Unit)
		Element:SetMinMaxValues(0, Element.MaxValue)
	end
	
	-- Fix for bug that first appeared on 9.0 PTR
	--if Element.MaxValue == 0 then Element.MaxValue = 1 end

	if not UnitIsDeadOrGhost(Unit) then
		Element.Value = UnitHealth(Unit)
	else
		Element.Value = 0
	end
	
	--Element:SetValue(5000000)
	Element:SetValue(Element.Value)
	PostUpdate(Element, Event, Unit)
end

local function ForceUpdate(Element)
	UpdateElement(Element, "ForceUpdate", Element.Owner.unit)
end

local function ForcePostUpdate(Element)
	PostUpdate(Element, "ForceUpdate", Element.Owner.unit)
end

local function OnEvent(self, event, unit)
	if(not unit or self.Owner.unit ~= unit) then return end
	
	UpdateElement(self, event, unit)
end

local function UpdateUnit(Element)
	Element:RegisterUnitEvent("UNIT_HEALTH", Element.Owner.unit)
	Element:RegisterUnitEvent("UNIT_MAXHEALTH", Element.Owner.unit)
end

----------

function Module:LoadConfig(limit)
	local Config, Element
	local Config_ALL = self.db.units.all
	
	UF = E:LoadModule("Unitframes")
	
	for _, F in pairs(Module.Frames) do
		F = limit or F
		
		Config = self.db.units[F.ConfigKey]
		Element = F.Health
		
		if not InCombatLockdown() or not F:IsProtected() then
			F:SetSize(Config.health.width, Config.health.height)
		end
		Element:SetReverseFill(Config.health.barInverseFill)
		Element:SetOrientation(Config.health.barOrientation)
		if Config.health.barSmooth then
			E.Libs.LibSmooth:SmoothBar(Element)
		else
			E.Libs.LibSmooth:ResetBar(Element)
		end
		
		Element.Background:SetColorTexture(unpack(Config.health.barBackgroundColor))
		E:SetFrameBorder(Element.Border, Config.health.barBorderSize, unpack(Config.health.barBorderColor))
		
		-- Texture
		if Config.health.overrideBarTexture then
			Element:SetAttribute("ReceivesGlobalTexture", false)
			Element:SetStatusBarTexture(E.Media:Fetch("statusbar", Config.health.barTexture or Config_ALL.barTexture))
		else
			Element:SetAttribute("ReceivesGlobalTexture", true)
			Element:SetStatusBarTexture(E.Media:Fetch("statusbar", Config_ALL.barTexture))
		end
		
		-- Portrait Cutoff
		if F.Portrait then
			Element.Background:ClearAllPoints()
			
			if Config.portrait.cutOff and F.Portrait and not F.Portrait.Disabled then
				if not Config.health.barInverseFill then
					local Point = Config.health.barOrientation == "HORIZONTAL" and "BOTTOMRIGHT" or "TOPLEFT"
					Element.Background:SetPoint("BOTTOMLEFT", Element:GetStatusBarTexture(), Point)
					Element.Background:SetPoint("TOPRIGHT", Element)
				else
					local Point = Config.health.barOrientation == "HORIZONTAL" and "TOPLEFT" or "BOTTOMRIGHT"
					Element.Background:SetPoint("TOPRIGHT", Element:GetStatusBarTexture(), Point)
					Element.Background:SetPoint("BOTTOMLEFT", Element)
				end
				
				Element.Background:SetParent(F.Portrait.CutOffParent)
			else
				Element.Background:SetAllPoints(Element)
				Element.Background:SetParent(Element)
			end
		end
		
		-- Color by Value
		Element.ColorByValue = Config_ALL.health.colorByValue
		Element.UseStaticColor = Config.health.useStaticColor
		Element.StaticColor = Config.health.staticColor
		
		Element:UnregisterAllEvents()
		
		if not F.Eventless then			
			-- Absolutely refrain from using RegisterUnitEvent here, as unit can and will shift around for header unitframes!
			-- So when that happens and we don't push a config update, things get messed up badly. Ask how i know
			
			if not E.IsRetail and (Config.health.fastUpdate or (F.unit == "player" or F.unit == "target")) then
				Element:RegisterEvent("UNIT_HEALTH_FREQUENT")
			end
			
			-- Always use UNIT_HEALTH, as it will also fire on various occasions
			Element:UpdateUnit()
		end
		
		Element.Disabled = false
		Element:ForceUpdate()
		
		if limit then break end
	end
end

function Module:Create(F)
	F.Health = UF:CreateUFBar(F, nil, true)
	local Element = F.Health
	
	Element.Border 		= E:CreateBorder(Element); Element.Border:SetFrameLevel(Element:GetFrameLevel() + 5)
	Element.Background 	= E:CreateBackground(Element);
	
	Element:SetScript("OnEvent", OnEvent)
	Element.Owner		= F
	Element.ForceUpdate = ForceUpdate
	Element.PostUpdate 	= ForcePostUpdate
	Element.UpdateUnit 	= UpdateUnit
	
	tinsert(Module.Frames, F)
end

---------- Add Module
UF:RegisterModule('Health', Module)