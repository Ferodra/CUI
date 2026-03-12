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


-- ANIMATED HEALTH LOSS

local AnimatedHealthLoss = {}

function AnimatedHealthLoss:OnUpdate(elapsed)
	local currValue = UnitHealth(self.Owner.unit)

	if ( currValue ~= self.currValue ) then
		self:UpdateHealth(currValue, self.currValue)
		self.currValue = currValue
	end
	
	self:UpdateLossAnimation(currValue);
end

function AnimatedHealthLoss:OnLoad()
	self:SetStatusBarColor(1, 0, 0, 1);
	self:SetDuration(0.25);
	self:SetStartDelay(0.1);
	self:SetPauseDelay(.05);
	self:SetPostponeDelay(.05);
	
	self:UpdateHealthMinMax()
	
	self.currValue = UnitHealth(self.Owner.unit)
	self:SetValue(0)
	
	self:SetScript('OnUpdate', self.OnUpdate)
end

function AnimatedHealthLoss:SetDuration(duration)
	self.animationDuration = duration or 0;
end

function AnimatedHealthLoss:SetStartDelay(delay)
	self.animationStartDelay = delay or 0;
end

function AnimatedHealthLoss:SetPauseDelay(delay)
	self.animationPauseDelay = delay or 0;
end

function AnimatedHealthLoss:SetPostponeDelay(delay)
	self.animationPostponeDelay = delay or 0;
end

function AnimatedHealthLoss:UpdateHealthMinMax()
	self.MaxValue = UnitHealthMax(self.Owner.unit)
	self:SetMinMaxValues(0, self.MaxValue)
end

function AnimatedHealthLoss:GetHealthLossAnimationData(currentHealth, previousHealth)
	if self.animationStartTime then
		local totalElapsedTime = GetTime() - self.animationStartTime;
		if totalElapsedTime > 0 then
			local animCompletePercent = totalElapsedTime / self.animationDuration;
			if animCompletePercent < 1 and previousHealth > currentHealth then
				local healthDelta = previousHealth - currentHealth;
				local animatedLossAmount = previousHealth - (animCompletePercent * healthDelta);
				return animatedLossAmount, animCompletePercent;
			end
		else
			return previousHealth, 0;
		end
	end
	return 0, 1; -- Animated loss amount is 0, and the animation is fully complete.
end

function AnimatedHealthLoss:CancelAnimation()
	self:Hide();
	self.animationStartTime = nil;
	self.animationCompletePercent = nil;
end

function AnimatedHealthLoss:BeginAnimation(value)
	--print("START")
	self.animationStartValue = value;
	self.animationStartTime = GetTime() + self.animationStartDelay;
	self.animationCompletePercent = 0;
	self:Show();
	self:SetValue(self.animationStartValue);
end

function AnimatedHealthLoss:PostponeStartTime()
	self.animationStartTime = self.animationStartTime + self.animationPostponeDelay;
end

function AnimatedHealthLoss:UpdateHealth(currentHealth, previousHealth)
	local delta = currentHealth - previousHealth;
	local hasLoss = delta < 0;
	local hasBegun = self.animationStartTime ~= nil;
	local isAnimating = hasBegun and self.animationCompletePercent > 0;
	
	--print(hasLoss, hasBegun)
	if hasLoss and not hasBegun then
		self:BeginAnimation(previousHealth);
	elseif hasLoss and hasBegun and not isAnimating then
		self:PostponeStartTime();
	elseif hasLoss and isAnimating then
		-- Reset the starting value of the health to what the animated loss bar was when the new incoming damage happened
		-- and pause briefly when new damage occurs.
		self.animationStartValue = self:GetHealthLossAnimationData(previousHealth, self.animationStartValue);
		self.animationStartTime = GetTime() + self.animationPauseDelay;
	elseif not hasLoss and hasBegun and currentHealth >= self.animationStartValue then
		self:CancelAnimation();
	end
end

function AnimatedHealthLoss:UpdateLossAnimation(currentHealth)
	local totalAbsorb = UnitGetTotalAbsorbs(self.Owner.unit) or 0;
	if totalAbsorb > 0 then
		self:CancelAnimation();
	end

	if self.animationStartTime then
		local animationValue, animationCompletePercent = self:GetHealthLossAnimationData(currentHealth, self.animationStartValue);
		--print(animationValue)
		self.animationCompletePercent = animationCompletePercent;
		if animationCompletePercent >= 1 then
			self:CancelAnimation();
		else
			self:SetValue(animationValue);
		end
	end
end

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
		
		if Element.ColorByValue then
			-- Element:GetValue somehow returns the default value at first
			local r, g, b = E:ColorGradient((Element.Value / Element.MaxValue), 1, 0, 0, 1, 1, 0, Color.r or Color[1], Color.g or Color[2], Color.b or Color[3])
			Element:SetStatusBarColor(r, g, b, Color.a or Color[4] or 1)
		else			
			Element:SetStatusBarColor(Color.r or Color[1], Color.g or Color[2], Color.b or Color[3], Color.a or Color[4] or 1)
		end
	end
	
	-- if Element.HealthLoss then
		-- Element.HealthLoss:UpdateHealth(Element.Value, Element.HealthLoss.PrevHealth or UnitHealth(Unit))
		-- Element.HealthLoss.PrevHealth = UnitHealth(Unit)
	-- end
end

local function UpdateElement(Element, Event, Unit)
	if Element.Disabled or Unit ~= Element.Owner.unit then return end
	
	if Event == "UNIT_MAXHEALTH" or Event == "ForceUpdate" or not Element.MaxValue then
		Element.MaxValue = UnitHealthMax(Unit)
		Element:SetMinMaxValues(0, Element.MaxValue)
	end
	
	-- Fix for bug that first appeared on 9.0 PTR
	if Element.MaxValue == 0 then Element.MaxValue = 1 end

	--if not UnitIsDeadOrGhost(Unit) then
		Element.Value = UnitHealth(Unit)
	--else
	--	Element.Value = 0
	--end
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

----------

function Module:LoadConfig(limit)
	local Config, Element
	local Config_ALL = self.db.units.all
	
	UF = E:LoadModule("Unitframes")
	
	for _, F in pairs(Module.Frames) do
		if limit then F = limit end
		
			
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
		
		if not F.Eventless then
			
			Element:UnregisterAllEvents()
			
			if not E.IsRetail and (Config.health.fastUpdate or (F.unit == "player" or F.unit == "target")) then
				Element:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", F.unit)
			end
			
			-- Always use UNIT_HEALTH, as it will also fire on various occasions
			Element:RegisterUnitEvent("UNIT_HEALTH", F.unit)
			Element:RegisterUnitEvent("UNIT_MAXHEALTH", F.unit)
		end
		
		Element.Disabled = false
		Element:ForceUpdate()
		
		if limit then return end
	end
end

function Module:Create(F)
	F.Health = UF:CreateUFBar(F, nil, true)
	local Element = F.Health
	
	Element.Border 		= E:CreateBorder(Element); Element.Border:SetFrameLevel(Element:GetFrameLevel() + 5)
	Element.Background 	= E:CreateBackground(Element);
	
	-- if F.unit == 'player' then
		-- Element.HealthLoss	= CreateFrame("Statusbar", "$parentHealthLoss", Element)
		-- --Element.HealthLoss:SetPoint("CENTER", E.Parent, "CENTER")
		-- --Element.HealthLoss:SetSize(200,50)
		
		-- Element.HealthLoss:SetPoint("TOPLEFT", Element.Background, "TOPLEFT")
		-- Element.HealthLoss:SetPoint("BOTTOMRIGHT", Element.Background, "BOTTOMRIGHT")
		-- Element.HealthLoss:SetFrameLevel(Element.Background:GetFrameLevel()+10)
		
		-- Element.HealthLoss.Owner = F
		-- for k,v in pairs(AnimatedHealthLoss) do
			-- if not Element.HealthLoss[k] then
				-- Element.HealthLoss[k] = v
			-- end
		-- end
		-- --Element.HealthLoss:SetMinMaxValues(0,100)
		-- --Element.HealthLoss:SetValue(100)
		-- Element.HealthLoss:OnLoad()
		-- Element.HealthLoss:SetStatusBarTexture(E.Media:Fetch("statusbar", self.db.units.all))
	-- end
	
	Element:SetScript("OnEvent", OnEvent)
	Element.Owner		= F
	Element.ForceUpdate = ForceUpdate
	Element.PostUpdate 	= ForcePostUpdate
	
	tinsert(Module.Frames, F)
end

---------- Add Module
UF:RegisterModule('Health', Module)