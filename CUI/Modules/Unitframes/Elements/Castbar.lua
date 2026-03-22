local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF, TT = E:LoadModules("Config", "Unitframes", "Tooltip")

local _
local Module = {}
	Module.Bars = {}
	Module.DBColors = {}
	
local pairs							= pairs
local select						= select
local format						= string.format
local GetNetStats					= GetNetStats
local GetTime						= GetTime
local CastingBarFrame_ApplyAlpha	= CastingBarFrame_ApplyAlpha
local INTERRUPTED					= INTERRUPTED

-- string.format usage:
-- string.format("CUI_%sCastbar%s", unit, index)
-- %s can be used an unlimited amount of times. Also do additional args
local BarBaseName 			= "CUI_%sCastbar"
local IconSize 				= 23
local CASTING_BAR_HOLD_TIME = 0.75

Module.IncludeUnits = {'player', 'target', 'targettarget', 'focus', 'focustarget', 'party', 'pet', 'boss', 'arena', 'maintank'}

---------------------------------------



function Module:LoadSingleBar(Frame, GlobalConfig, Config)
	
	-- Automatically creates the new bar when it doesn't exist
	if not Frame.Castbar then
		-- Check if this frame's unit should have this module
		if not UF:IsKeyEligibleForModule(Frame.ConfigKey, Module.Name) then
			return
		end
		
		self:CreateBar(Frame, true)
	end
	
	local Bar = Frame.Castbar
	-- For edge cases where the bar failed to be created for some reason
	if not Bar then return end
	
	GlobalConfig, Config = GlobalConfig or Module.db.unitframe.units.all.castbar, Config or Module.db.unitframe.units[Frame.ConfigKey].castbar
	if not GlobalConfig or not Config then return end

	Bar.enable = Config.enable
	if not Config.enable then
		Bar:Hide()
		Bar.MoverEnabled = false
		Bar.ForceMoverEnabled = nil
		Module:RemoveEventHandler(Bar)
	else		
		Bar.MoverEnabled = true
		Module:AddEventHandler(Bar)
		
		if Bar.ForceToggle == true then
			Bar:Show()
		end
	
	-- Bar
	-- CUI_party_1_HeaderUnitButton1
		Bar:SetSize(Config.width, Config.height)
		Bar.LagBar:SetSize(Config.width, Config.height) -- Set both as we just override one of them			
		
		-- Auto Handling for grouped frames
		if Bar.attachToUnitframe then
			local BarSmartPosition = E:InversePosition(Config.barPosition)
			
			Bar:ClearAllPoints()
			Bar:SetParent(Bar.Owner)
			Bar:SetPoint(BarSmartPosition, Bar.Owner, Config.barPosition, Config.barOffsetX, Config.barOffsetY)
		end
		
		Bar.Overlay:SetReverseFill(Config.barInverseFill)
		Bar.Overlay:SetOrientation(Config.barOrientation)
		
		Bar.Reverse = Config.barInverseFill
		Bar.Vertical = (Config.barOrientation == "VERTICAL")
		
		Bar.ShowCastingTarget = Config.showCastingTarget
		Bar.CastingTarget = nil
		
		Bar.LagBar:ClearAllPoints()
		Bar.Spark:ClearAllPoints()
		
		local NewPosition
		
		if Bar.Vertical then
			
			Bar.LagBar:SetHeight(3)
			
			if Bar.Reverse then NewPosition = "BOTTOM" else NewPosition = "TOP" end
			
			Bar.Spark:SetRotation(1.5708)
			Bar.Spark:SetSize(Config.sparkHeight, Config.sparkWidth) -- Also rotates the axis due to SetRotation
		else
			
			Bar.LagBar:SetWidth(3)
			
			if Bar.Reverse then NewPosition = "LEFT" else NewPosition = "RIGHT" end
			
			Bar.Spark:SetRotation(0)
			Bar.Spark:SetSize(Config.sparkWidth, Config.sparkHeight) -- Also rotates the axis due to SetRotation
		end
		
		Bar.LagBar:SetPoint(NewPosition, Bar.Overlay, NewPosition)
		Bar.Spark:SetPoint("CENTER", Bar.Overlay:GetStatusBarTexture(), NewPosition, 0, 0)
		
		Bar:SetBorderColor(unpack(Config.barBorderColor))
		Bar:SetBorderSize(Config.barBorderSize)
	
	-- Texture
		if not Config.enableIcon then
			Bar.Icon:Hide()
		else
			Bar.Icon:SetSize(Config.iconSize, Config.iconSize)
			
			local SmartPosition = E:InversePosition(Config.iconPosition)
			Bar.Icon:ClearAllPoints()
			Bar.Icon:SetPoint(SmartPosition, Bar, Config.iconPosition, Config.iconOffsetX, Config.iconOffsetY)
			
			Bar.Icon:Show()
		end
		
	-- Flash
		if Bar.Flash then
			Bar.Flash:Size(GlobalConfig.flashSize)
			Bar.flashFadeInTime, Bar.flashFadeOutTime = GlobalConfig.flashFadeInTime, GlobalConfig.flashFadeOutTime
		end
		
	-- Fonts
		-- Those are being handled by the PathFonts system now
		
		
		E:UpdateMoverDimensions(Bar)
	end
end

function Module:LoadConfig()
	local GlobalConfig, Config = Module.db.unitframe.units.all.castbar
	
	self.DBColors.Success = self.db.colors.castbar.success
	self.DBColors.Failed = self.db.colors.castbar.failed
	self.DBColors.Interruptible = self.db.colors.castbar.interruptible
	self.DBColors.NotInterruptible = self.db.colors.castbar.notInterruptible
	
	for _, Bar in pairs(self.Bars) do
		self:LoadSingleBar(Bar.Owner, GlobalConfig, Module.db.unitframe.units[Bar.Owner.ConfigKey].castbar)
	end
end

function Module:Toggle(Unitframe)
	local Bar = Unitframe.Castbar
	if not Bar then return end
	
	if Bar:IsVisible() then
		if Bar.Flash then
			Bar.Flash:SetAlpha(0)
		end
		
		Bar:Hide()
		Bar.ForceToggle = false
	else
		Bar.Icon.Tex:SetTexture(136235)
		Bar:SetMinMaxValues(0, 100)
		Bar:SetValue(50)
		Bar.Name:SetText("Long Long Long Long Long Chonk Cat")
		Bar.Time:SetText("3.4")
		
		if Bar.Flash then
			Bar.Flash:SetAlpha(1)
			Bar.Flash:Show()
		end
		
		Bar:Show()
		Bar:SetAlpha(1)
		Bar.ForceToggle = true
	end
end

function Module:GetIndex(unit)
	local i = 1
	
	for _, Bar in pairs(self.Bars) do
		-- Only count created bars that are NOT part of grouped unitframes
		-- This is because we only need the exact identifier for movers, as their config relies on it
		if Bar.Owner.unit == unit and not Bar.attachToUnitframe then
			i = i + 1
		end
	end
	
	return i
end

local function Flash_SetSize(self, size)
	if not self then return false end
	
	self:SetPoint('TOPLEFT', self.BarParent, 'TOPLEFT', -size, size)
	self:SetPoint('BOTTOMRIGHT', self.BarParent, 'BOTTOMRIGHT', size, -size)
end

function Module:AddFlash(b)
	b.Flash = b:CreateTexture(nil, 'OVERLAY')
	local Flash = b.Flash
	
	Flash.Size = Flash_SetSize
	Flash.BarParent = b
	
	Flash:Size(6)
	Flash:SetTexture([[Interface\AddOns\CUI\Textures\castingbar\flash]])
	Flash:SetBlendMode('ADD')
	Flash:SetAlpha(0)
end

function Module:AddText(Bar, Name)
	local Font = E:NewFontObject(nil, "OVERLAY", Bar.Overlay, 10)
	Bar[Name] = Font
	
	return Font
end

function Module:ToggleMovers(state)
	for k, v in pairs(self.Bars) do
		self.Bars[k].ForceMoverEnabled = state
		
		if state == true then
			self.Bars[k]:Show()
			self.Bars[k]:SetAlpha(1)
		else
			self.Bars[k]:Hide()
		end
	end
end

function Module:AddLagBar(o)
	o.LagBar = CreateFrame("Frame", "CUI_CastbarLagBar", o.Overlay)
	o.LagBar:SetSize(o.Overlay:GetWidth(), o.Overlay:GetHeight()) -- Set both as we just override one of them
	o.LagBar:SetPoint("RIGHT", o.Overlay, "RIGHT")
	o.LagBarTex = o.LagBar:CreateTexture(nil)
	o.LagBarTex:SetAllPoints(o.LagBar)
	o.LagBarTex:SetColorTexture(0.65, 0, 0, 0.5)
	
	self:UpdateLagBar(o, false)
end

function Module:UpdateLagBar(o, s)
	if s == false then
		o.LagBar:Hide()
		return
	else
		o.LagBar:Show()
	end
	
	local min, max = o:GetMinMaxValues()
	-- We always assume the min max values are timings
	-- We use the delta value to determine the required dimensions of the LagBar
	local delta = max - min
	
	local timePerPixel = (o.Vertical and o.Overlay:GetHeight() or o.Overlay:GetWidth()) / delta
	local lagBarSize = (select(4, GetNetStats()) / 1000) * timePerPixel
	
	if not o.Vertical then
		o.LagBar:SetWidth(lagBarSize)
	else
		o.LagBar:SetHeight(lagBarSize)
	end
end

function Module:AddSpark(o)
	o.Spark = o.Overlay:CreateTexture(nil, "OVERLAY")
	o.Spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
	o.Spark:SetBlendMode("ADD")
	
end

function Module:SetSparkPosition(o, isChanneling)
	if not o.Vertical then
		if isChanneling then
			o.sparkPositionX = ((o.value / o.maxValue) * o.Overlay:GetWidth()) + 1
		else
			o.sparkPositionX = ((o.value / o.endTime) * o.Overlay:GetWidth()) - 1
		end
		
		if not o.Reverse then
			if select(3, o.Spark:GetPoint(3)) == "RIGHT" then
				o.Spark:ClearAllPoints()
			end
			o.Spark:SetPoint("CENTER", o, "LEFT", o.sparkPositionX, 0)
		else
			if select(3, o.Spark:GetPoint(3)) == "LEFT" then
				o.Spark:ClearAllPoints()
			end
			o.Spark:SetPoint("CENTER", o, "RIGHT", -o.sparkPositionX, 0)
		end
	else
		if isChanneling then
			o.sparkPositionY = ((o.value / o.maxValue) * o.Overlay:GetHeight()) + 1
		else
			o.sparkPositionY = ((o.value / o.endTime) * o.Overlay:GetHeight()) - 1
		end
		
		if not o.Reverse then
			if select(3, o.Spark:GetPoint(3)) == "TOP" then
				o.Spark:ClearAllPoints()
			end
			o.Spark:SetPoint("CENTER", o, "BOTTOM", 0, o.sparkPositionY)
		else
			if select(3, o.Spark:GetPoint(3)) == "BOTTOM" then
				o.Spark:ClearAllPoints()
			end
			o.Spark:SetPoint("CENTER", o, "TOP", 0, -o.sparkPositionY)
		end
	end
end

function Module:SetInterruptible(bar, notInterruptible)
	if bar.casting or bar.channeling then
		if notInterruptible then
			bar:SetOverlayColor(unpack(Module.DBColors.NotInterruptible))
			E:SkinButtonIcon(bar.Icon, Module.DBColors.NotInterruptible)
		else
			bar:SetOverlayColor(unpack(Module.DBColors.Interruptible))
			E:SkinButtonIcon(bar.Icon, Module.DBColors.Interruptible)
		end
	end
end

local function Castingbar_ResetFlash(self)
	if self.Flash then
		self.Flash:SetAlpha(0)
		self.Flash:Show()
	end
end

local function Castingbar_FinishCast(self, state, holdTime)
	
	local Color = (state == true or state == nil) and Module.DBColors.Success or Module.DBColors.Failed
	
	self.Time:SetText('')
	self:SetValue(select(2, self.Overlay:GetMinMaxValues()))
	self:SetOverlayColor(unpack(Color))
	
	Castingbar_ResetFlash(self)	
	if self.Flash then
		self.Flash:SetVertexColor(Color[1], Color[2], Color[3])
		
		if E:UIFrameIsFlashing(self.Flash) then
			E:UIFrameFlashStop(self.Flash)
		end
				
		E:UIFrameFlash(self.Flash, self.flashFadeInTime, self.flashFadeOutTime, self.flashFadeInTime + self.flashFadeOutTime, false, 0, 0)
	end
	
	if self.Spark then
		self.Spark:Hide()
	end
	
	self.flash = true
	self.fadeOut = true
	self.casting = nil
	self.channeling = nil
	self.holdTime = holdTime or 0
end

function Module:RemoveEventHandler(bar)
	if bar.active then
		bar:UnregisterAllEvents()
		bar:SetScript("OnEvent", nil)
		bar:SetScript("OnUpdate", nil)
	end
	
	bar.active = nil
end

local InterruptStr = "%s [%s]"
local function Bar_OnEvent(self, event, ...)
	if not self.Owner:IsVisible() and event ~= "ForceUpdate" then return end
	-- Probably the most efficient way we can go
	
	-- Interruptor handler START
	----------------------------
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then		
		_, self.combatLogInfoType, _, _, self.combatLogInfoName, _, _, self.combatLogInfoGUID = CombatLogGetCurrentEventInfo()
		
		if self.combatLogInfoType == "SPELL_INTERRUPT" and self.combatLogInfoGUID == UnitGUID(self.Owner.unit) then
			-- Check if the interruptor name is valid. Environmental effects like quaking leave this at nil, a.e.
			if self.combatLogInfoName then
				self.Name:SetText(InterruptStr:format(INTERRUPTED, self.combatLogInfoName))
			end
		end
		
		-- End call directly, since we do not want the script to iterate through everything else. This does get fired REALLY rapidly in combat.
		return
	end
	-- Interruptor handler END
	----------------------------
	
	-- print(event)
	
	self.eventUnit = ...
	
	-- Hide when there is no such unit
	--print(self.Owner.unit, self.eventUnit)
	if not UnitExists(self.Owner.unit) then self:Hide(); return; end
	if self.eventUnit ~= self.Owner.unit and not event == "PLAYER_TARGET_CHANGED" then return end
	
	if (event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_FOCUS_CHANGED") and not (UnitCastingInfo(self.Owner.unit) or UnitChannelInfo(self.Owner.unit)) then
		self.casting = nil
		self.channeling = nil
		self.fadeOut = true
		self.holdTime = 0
		
		self:Hide()
	end
	
	if event == "UNIT_SPELLCAST_SENT" and self.ShowCastingTarget then
		
		local target = select(2, ...)
		self.CastingTarget = (target and target ~= "") and target or nil
		self.CastingTargetGUID = select(3, ...)
		
		return
	end
	
	if event == "UNIT_SPELLCAST_START" or ((event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_FOCUS_CHANGED" or event == "ForceUpdate") and UnitCastingInfo(self.Owner.unit)) then
		self.SpellName, _, self.SpellTexture, self.startTime, self.endTime, self.SpellIsTradeSkill, self.castID, self.notInterruptible  = UnitCastingInfo(self.Owner.unit)
		if self.SpellName then
			self:ApplyAlpha(1.0)
			self.holdTime = 0
			self.casting = true
			self.channeling = nil
			self.fadeOut = nil
			
			self.endTime = (self.endTime - self.startTime) / 1000
			self.value = (GetTime() - (self.startTime / 1000))
			self:SetMinMaxValues(0, self.endTime)
			self:SetValue(self.value)
			
			if ( self.Spark ) then
				self.Spark:Show()
			end
			self.Name:SetText((self.CastingTarget and self.CastingTargetGUID == self.castID) and (self.SpellName .. " -> " .. self.CastingTarget) or self.SpellName)
			self.Icon.Tex:SetTexture(self.SpellTexture)
			
			
			Module:SetInterruptible(self, self.notInterruptible)
			
			-- Keep lagbar enabled for non-player units, when the cast is interruptible to help with interrupting it on high latency
			if self.Owner.unit ~= "player" and self.notInterruptible then Module:UpdateLagBar(self, false) else Module:UpdateLagBar(self, true) end
			
			self:Show()
			self:SetAlpha(1)
			
			-- self.holdTime = GetTime() + CASTING_BAR_HOLD_TIME
		else
			self.casting = nil
			self.channeling = nil
			self.fadeOut = true
			self.holdTime = 0
			
			self:Hide()
		end
		
	
		
	elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_EMPOWER_STOP" then
		-- If still casting [Fix for passive auras that also trigger this event]
		if not self.channeling or UnitChannelInfo(self.Owner.unit) then return end
		if not self:IsVisible() then
			self:Hide()
		end
		
		Castingbar_FinishCast(self, true)
		
	elseif event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" then
		if ( self:IsShown() and
		     (self.casting and select(2, ...) == self.castID) and not self.fadeOut ) then
			if self.Name then
				if event == "UNIT_SPELLCAST_FAILED" then
					self.Name:SetText(FAILED);
				else
					self.Name:SetText(INTERRUPTED);
				end
			end
			
			Castingbar_FinishCast(self, false, GetTime() + CASTING_BAR_HOLD_TIME)
			
		end
		
	elseif event == "UNIT_SPELLCAST_INTERRUPTIBLE" or event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" then
		Module:SetInterruptible(self, event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
	elseif event == "UNIT_SPELLCAST_DELAYED" then
		if ( self:IsShown() ) then
			self.SpellName, _, _, self.startTime, self.endTime, _, _, _  = UnitCastingInfo(self.Owner.unit)
			if not self.SpellName then
				-- if there is no name, there is no bar
				self:Hide();
				return;
			end
			
			self.flash = nil
			
			self.endTime = (self.endTime - self.startTime) / 1000
			self.value = (GetTime() - (self.startTime / 1000))
			self:SetMinMaxValues(0, self.endTime)
		end
		
	-- Cast succeeded
	elseif event == "UNIT_SPELLCAST_STOP" then
		if not self:IsVisible() then
			self:Hide()
		end
		if ( (self.casting and event == "UNIT_SPELLCAST_STOP") or
		     (self.channeling and event == "UNIT_SPELLCAST_CHANNEL_STOP") ) then
			Castingbar_FinishCast(self, true)		
		end
		
	
	elseif event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_EMPOWER_START" or ((event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_FOCUS_CHANGED") and UnitChannelInfo(self.Owner.unit)) then
		self.SpellName, _, self.SpellTexture, self.startTime, self.endTime, self.SpellIsTradeSkill, self.notInterruptible, _, _, self.SpellNumStages = UnitChannelInfo(self.Owner.unit)
		
		if not self.SpellName then
			-- if there is no name, there is no bar
			self:Hide()
			return
		end
			
		self:Show()
		self:SetAlpha(1)
		
		local isChargeSpell = self.SpellNumStages > 0;

		if isChargeSpell and not issecretvalue(self.endTime) then
			self.endTime = self.endTime + GetUnitEmpowerHoldAtMaxTime(self.Owner.unit);
		end

		self.Name:SetText(self.CastingTarget and (self.SpellName .. " -> " .. self.CastingTarget) or self.SpellName)
		self.Icon.Tex:SetTexture(self.SpellTexture)
		self.maxValue = (self.endTime - self.startTime) / 1000
		self.value = (self.endTime / 1000) - GetTime()
		self.minValue = 0
		self:SetMinMaxValues(0, self.maxValue)
		self:SetValue(self.value)
		self.casting = nil
		self.channeling = true
		
		
		Module:SetInterruptible(self, self.notInterruptible)
		
		if ( self.Spark ) then
			self.Spark:Show()
		end
		
		Module:UpdateLagBar(self, false)
		
		self.holdTime = GetTime() + CASTING_BAR_HOLD_TIME
		
	-- Channel delay
	elseif event == "UNIT_SPELLCAST_CHANNEL_UPDATE" or event == "UNIT_SPELLCAST_EMPOWER_UPDATE" then
		if ( self:IsShown() ) then
			self.SpellName, _, self.SpellTexture, self.startTime, self.endTime, self.SpellIsTradeSkill, _, _ = UnitChannelInfo(self.Owner.unit)
			if not self.SpellName then
				-- if there is no name, there is no bar
				self:Hide();
				return;
			end

			self.value = ((self.endTime / 1000) - GetTime());
			self.maxValue = (self.endTime - self.startTime) / 1000;
			self:SetMinMaxValues(0, self.maxValue);
			self:SetValue(self.value);
		end
		
	end
end

local function Bar_ForceUpdate(self)
	Module:UpdateEvents(self, true)
	Bar_OnEvent(self, "ForceUpdate")
end

local function Bar_OnShow(self)
	if self.casting then
		local _, _, _, startTime = UnitCastingInfo(self.Owner.unit);
		if startTime then
			self.value = (GetTime() - (startTime / 1000));
		end
	else
		local _, _, _, _, endTime = UnitChannelInfo(self.Owner.unit);
		if endTime then
			self.value = ((endTime / 1000) - GetTime());
		end
	end
end

function Module:UpdateBarUnit(Bar, Unit)
	Bar.unit = Unit
	Module:UpdateEvents(Bar)
end

-- For updating event units on the fly for grouped frames
-- Without doing this for them, we won't get casts for those units
function Module:UpdateEvents(Bar, SkipUpdate)
	Bar:UnregisterAllEvents()

	if not Bar.enable then return end
	
	-- Register a bunch (all) of spellcast events (all we need)
	Bar:RegisterUnitEvent("UNIT_SPELLCAST_START", Bar.Owner.unit)
	Bar:RegisterUnitEvent("UNIT_SPELLCAST_STOP", Bar.Owner.unit)
	Bar:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", Bar.Owner.unit)
	Bar:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", Bar.Owner.unit)
	Bar:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", Bar.Owner.unit)
	Bar:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", Bar.Owner.unit)
	Bar:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", Bar.Owner.unit)
	Bar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", Bar.Owner.unit)
	Bar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", Bar.Owner.unit)
	Bar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", Bar.Owner.unit)
	Bar:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_START", Bar.Owner.unit)
	Bar:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_UPDATE", Bar.Owner.unit)
	Bar:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_STOP", Bar.Owner.unit)
	--Bar:RegisterUnitEvent("UNIT_SPELLCAST_SENT", Bar.Owner.unit)
	--Bar:RegisterUnitEvent("UNIT_TARGET", Bar.Owner.unit)
	
	if Bar.Owner.unit == "target" or Bar.Owner.unit == "targettarget" then
		Bar:RegisterEvent("PLAYER_TARGET_CHANGED")
		if Bar.Owner.unit == "targettarget" then
			Bar:RegisterUnitEvent("UNIT_TARGET", "target")
		end
	elseif Bar.Owner.unit == "focus" or Bar.Owner.unit == "focustarget" then
		Bar:RegisterEvent("PLAYER_FOCUS_CHANGED")
		if Bar.Owner.unit == "focustarget" then
			Bar:RegisterUnitEvent("UNIT_TARGET", "focus")
		end
	end
	
	if Bar.ForceUpdate and not SkipUpdate then
		Bar:ForceUpdate()
	end
	-- Interruptor
	--Bar:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

local function Bar_UpdateEvents(self)
	Module:UpdateEvents(self)
end

function Module:AddEventHandler(bar)
	
	if bar.active then return end
	
	bar.casting = nil
	bar.channeling = nil
	bar.fadeOut = false
	bar.holdTime = 0
	
	Module:UpdateEvents(bar)
	
	bar:SetScript("OnShow", Bar_OnShow)
	bar:SetScript("OnEvent", Bar_OnEvent)
	
	bar.OnUpdate = self.OnUpdate
	bar:SetScript("OnUpdate", bar.OnUpdate)
	
	bar.ForceUpdate = Bar_ForceUpdate
	
	-- This is to mitigate our :IsVisible() condition in the OnEvent handler of a bar
	-- We use it, since we want to reduce the event time to an absolute minimum
	bar.Owner.Health:HookScript("OnShow", function()
		bar:ForceUpdate()
	end)
	
	bar.active = true
end


function Module:OnUpdate(elapsed)
	if self.ForceMoverEnabled then return end
	
	if ( self.casting ) then
		
		self.value = self.value + elapsed;
		if ( self.value >= self.endTime ) then
			self:SetValue(self.endTime);
			Castingbar_FinishCast(self)
			return;
		end
		self:SetValue(self.value)
		self.Time:SetText(E:Round(self.endTime - self.value, 1))
		-- if ( self.Flash ) then
			-- self.Flash:Hide();
		-- end
		
	elseif ( self.channeling ) then
		self.value = self.value - elapsed;
		if ( self.value <= self.minValue ) then
			Castingbar_FinishCast(self)
			self.channeling = nil;
			self.fadeOut = true;
			return;
		end
		
		self:SetValue(self.value);
		self.Time:SetText(E:Round(self.value, 1))
		-- if ( self.Flash ) then
			-- self.Flash:Hide();
		-- end
	elseif ( GetTime() < self.holdTime ) then
		return;
	--elseif ( self.flash ) then
		-- local alpha = 0;
		-- if ( self.Flash ) then
			-- alpha = self.Flash:GetAlpha() + 0.15;
		-- end
		-- if ( alpha < 1 ) then
			-- if ( self.Flash ) then
				-- self.Flash:SetAlpha(alpha);
			-- end
		-- else
			-- if ( self.Flash ) then
				-- self.Flash:SetAlpha(1.0);
			-- end
			-- self.flash = nil;
		-- end
	elseif ( self.fadeOut ) then
		local alpha = self:GetAlpha() - 0.015;
		if ( alpha > 0 ) then
			self:SetAlpha(alpha)
			
			-- if self.Flash then
				-- self.Flash:SetAlpha(self.Flash:GetAlpha() - 0.125)
			-- end
		else
			self.fadeOut = nil;
			self:Hide();
		end
	end
end

function Module:CreateBar(Frame, doNotLoad)
	
	if Frame.Castbar then return end
	
	local Unit = Frame.unit
	if Unit == 'vehicle' or Unit == 'player' then
		Unit = 'player'
	end
	
	local Attach = UF:IsUnitGrouped(Unit) or (Frame.RealUnit and UF:IsUnitGrouped(Frame.RealUnit))
	
	-- CUI_party1Castbar1
	local Bar = E:CreateBar(format("CUI_%sCastbar%s", Unit, Attach and "" or self:GetIndex(Unit)), "LOW", 235, 25, {"CENTER", E.Parent, "CENTER"}, E.Parent)
	E.Libs.LibSmooth:ResetBar(Bar.Overlay) -- Leaving the smooth anim on somehow causes the bar to not go at a 100%. This results in the LagBar simply being useless and just looks weird
	Bar:SetBackgroundColor(nil, nil, nil, 0.95)
	Bar.Owner = Frame
	
	Frame.Castbar = Bar
	
	Bar.unit = Unit
	Bar.attachToUnitframe = Attach
	--Bar.RealUnit = RealUnit
	
	local Icon = CreateFrame("Frame", "CUI_CastbarIconHolder", Bar)
	Bar.Icon = Icon
	Icon:SetSize(IconSize, IconSize)
	Icon:SetPoint("LEFT", Bar, "LEFT", -IconSize, 0)
	
	Icon.Tex = Icon:CreateTexture(nil, "OVERLAY")
	Icon.Tex:SetTexCoord(0.06, 0.94, 0.06, 0.94)
	Icon.Tex:SetParent(Icon)
	Icon.Tex:SetAllPoints(Icon)
	
	E:RegisterAutoFont(self:AddText(Bar, "Time", "RIGHT", -10, 0), "db.profile.unitframe.units." .. Frame.ConfigKey .. ".castbar.fonts.time")
	E:RegisterAutoFont(self:AddText(Bar, "Name", "LEFT", 5, 0), "db.profile.unitframe.units." .. Frame.ConfigKey .. ".castbar.fonts.name")
	
	
	if not Bar.ApplyAlpha then
		_G.Mixin(Bar, _G.CastingBarMixin)
	end
	
	-- Methods
	Bar.UpdateEvents = Bar_UpdateEvents
	Bar.UpdateUnit = Bar_UpdateEvents
	
	-- Lag Bar
	self:AddLagBar(Bar)
	-- Spark
	self:AddSpark(Bar)
	-- Flash
	self:AddFlash(Bar)
	-- Functionality
	self:AddEventHandler(Bar)
	-- Initial Hide
	Bar:Hide()
	-- Add mover
		-- No mover for clustered units !
	if not Bar.attachToUnitframe then
		local MoverConfigOverride
		if Frame == UF.Frames.player[1] then
			MoverConfigOverride = "CUI_playerCastbar1Mover"
		end
		
		E:CreateMover(Bar, format("%s - %s", L[Frame.ConfigKey], L["castbar"]), nil, nil, nil, nil, "unitframes", MoverConfigOverride)
	end
	-- Register castbar to lib
	tinsert(self.Bars, Bar)
	
	if not doNotLoad then
		self:LoadSingleBar(Frame)
	end
end

function Module:UpdateDB()
	self.db = CO.db.profile
	self.moverdb = CO.db.profile.movers
end
function Module:Init()
	--if not CO.db.char.unitframe.enable then return end
	
	for k,v in pairs(BarUnits) do
		self:CreateBar(UF:GetUnitframe(v))
	end
	
	-- Load castbars
	self:LoadConfig()
end

function Module:Create(F)
	if not self.DBInit then
		self:UpdateDB()
		self.DBInit = true
	end
	self:CreateBar(F)
end

UF:RegisterModule('Castbar', Module)
--UF.Modules["Castbar"] = Module