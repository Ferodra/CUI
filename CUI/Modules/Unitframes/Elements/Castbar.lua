local E, L = unpack(select(2, ...)) -- Engine, Locale
local BC,L,UF,TT = E:LoadModules("Bar_Cast", "Locale", "Unitframes", "Tooltip")

local _
	BC.Bars = {}
	BC.DBColors = {}
	
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

function BC:LoadProfile()
	local ProfileTarget
	
	self.DBColors.Success = self.db.colors.castbar.success
	self.DBColors.Failed = self.db.colors.castbar.failed
	self.DBColors.Interruptible = self.db.colors.castbar.interruptible
	self.DBColors.NotInterruptible = self.db.colors.castbar.notInterruptible
	
	for Name, Bar in pairs(BC.Bars) do
		ProfileTarget = BC.db.unitframe.units[E:removeDigits(Bar.Unit)].castbar
		
		if not ProfileTarget.enable then
			Bar:Hide()
			Bar.MoverEnabled = false
			Bar.ForceMoverEnabled = nil
			BC:RemoveEventHandler(Bar)
		else			
			Bar.MoverEnabled = true
			BC:AddEventHandler(Bar)
			
			if Bar.ForceToggle == true then
				Bar:Show()
			end
		
		-- Bar
			Bar:SetSize(ProfileTarget.width, ProfileTarget.height)
			Bar.LagBar:SetSize(ProfileTarget.width, ProfileTarget.height) -- Set both as we just override one of them			
			
			if ProfileTarget.attachToUnitframe then
				local BarSmartPosition = E:InversePosition(ProfileTarget.barPosition)
				
				Bar:ClearAllPoints()
				Bar:SetParent(UF:GetUnitframe(Bar.Unit))
				Bar:SetPoint(BarSmartPosition, UF:GetUnitframe(Bar.Unit), ProfileTarget.barPosition, ProfileTarget.barOffsetX, ProfileTarget.barOffsetY)
			end
			
			Bar.Overlay:SetReverseFill(ProfileTarget.barInverseFill)
			Bar.Overlay:SetOrientation(ProfileTarget.barOrientation)
			
			Bar.Reverse = ProfileTarget.barInverseFill
			Bar.Vertical = (ProfileTarget.barOrientation == "VERTICAL")
			
			Bar.LagBar:ClearAllPoints()
			Bar.Spark:ClearAllPoints()
			
			local NewPosition
			
			if Bar.Vertical then
				
				Bar.LagBar:SetHeight(3)
				
				if Bar.Reverse then NewPosition = "BOTTOM" else NewPosition = "TOP" end
				
				Bar.Spark:SetRotation(1.5708)
				Bar.Spark:SetSize(ProfileTarget.sparkHeight, ProfileTarget.sparkWidth) -- Also rotates the axis due to SetRotation
			else
				
				Bar.LagBar:SetWidth(3)
				
				if Bar.Reverse then NewPosition = "LEFT" else NewPosition = "RIGHT" end
				
				Bar.Spark:SetRotation(0)
				Bar.Spark:SetSize(ProfileTarget.sparkWidth, ProfileTarget.sparkHeight) -- Also rotates the axis due to SetRotation
			end
			
			Bar.LagBar:SetPoint(NewPosition, Bar.Overlay, NewPosition)
			Bar.Spark:SetPoint("CENTER", Bar.Overlay:GetStatusBarTexture(), NewPosition, 0, 0)
			
			Bar:SetBorderColor(unpack(ProfileTarget.barBorderColor))
			Bar:SetBorderSize(ProfileTarget.barBorderSize)
		
		-- Texture
			if not ProfileTarget.enableIcon then
				Bar.Icon:Hide()
			else
				Bar.Icon:SetSize(ProfileTarget.iconSize, ProfileTarget.iconSize)
				
				local SmartPosition = E:InversePosition(ProfileTarget.iconPosition)
				Bar.Icon:ClearAllPoints()
				Bar.Icon:SetPoint(SmartPosition, Bar, ProfileTarget.iconPosition, ProfileTarget.iconOffsetX, ProfileTarget.iconOffsetY)
				
				Bar.Icon:Show()
			end
			
		-- Fonts
			-- Those are being handled by the PathFonts system now
			
			
			E:UpdateMoverDimensions(Bar)
		end
	end
end

function BC:Toggle(Unit)
	
	if type(self) == "string" then Unit = self end
	
	if not BC.Bars[Unit] then return end
	
	if BC.Bars[Unit]:IsVisible() then
		BC.Bars[Unit].ForceMoverEnabled = nil
		
		BC.Bars[Unit]:Hide()
		BC.Bars[Unit].ForceToggle = false
	else
		BC.Bars[Unit].ForceMoverEnabled = true
		BC.Bars[Unit].Icon.Tex:SetTexture(136235)
		BC.Bars[Unit]:SetMinMaxValues(0, 100)
		BC.Bars[Unit]:SetValue(50)
		BC.Bars[Unit].Name:SetText("Long Spell Name")
		BC.Bars[Unit].Time:SetText("3.4")
		
		BC.Bars[Unit]:Show()
		BC.Bars[Unit]:SetAlpha(1)
		BC.Bars[Unit].ForceToggle = true
	end
end

function BC:Get(BName)
	return self.Bars[BName]
end

function BC:GetIndex(unit)
	local i = 1
	for k, v in pairs(self.Bars) do
		if v.unit == unit then
			i = i + 1
		end
	end
	
	return i
end

function BC:AddText(b, n, a, x, y)
	b[n] = b.Overlay:CreateFontString(nil, "ARTWORK")
	local f = b[n]
	
	E:InitializeFontFrame(b[n], "ARTWORK", E.Media:Fetch("font", "FRIZQT__.TTF"), 11, {0.8,0.8,0.8}, 1, {0,0}, "", 0, 0, b.Overlay, "RIGHT", {1,1})
	f:SetFont(E.Media:Fetch("font", "FRIZQT__.TTF"), 11, "")
	f:ClearAllPoints()
	f:SetPoint(a, b, a)
	f:SetJustifyH(a)
	f:SetJustifyV("MIDDLE")
	
	if x and y then E:PushFrame(f, x, y) end
	
	return f
end

function BC:ToggleMovers(s)
	for k, v in pairs(self.Bars) do
		self.Bars[k].ForceMoverEnabled = s
		
		if s == true then
			self.Bars[k]:Show()
			self.Bars[k]:SetAlpha(1)
		else
			self.Bars[k]:Hide()
		end
	end
end

function BC:AddLagBar(o)
	o.LagBar = CreateFrame("Frame", nil, o.Overlay)
	o.LagBar:SetSize(o.Overlay:GetWidth(), o.Overlay:GetHeight()) -- Set both as we just override one of them
	o.LagBar:SetPoint("RIGHT", o.Overlay, "RIGHT")
	o.LagBarTex = o.LagBar:CreateTexture(nil)
	o.LagBarTex:SetAllPoints(o.LagBar)
	o.LagBarTex:SetColorTexture(0.65, 0, 0, 0.5)
	
	self:UpdateLagBar(o, false)
end

function BC:UpdateLagBar(o, s)
	if s == false then
		o.LagBar:Hide()
		return
	else
		o.LagBar:Show()
	end
	
	local min, max = o:GetMinMaxValues()
	-- We always assume the min max values are timings
	-- We use the delta value to determine the required dimension of the LagBar
	local delta = max - min
	
	local timePerPixel = (o.Vertical and o.Overlay:GetHeight() or o.Overlay:GetWidth()) / delta
	local lagBarSize = (select(4, GetNetStats()) / 1000) * timePerPixel
	
	if not o.Vertical then
		o.LagBar:SetWidth(lagBarSize)
	else
		o.LagBar:SetHeight(lagBarSize)
	end
end

function BC:AddSpark(o)
	o.Spark = o.Overlay:CreateTexture(nil, "OVERLAY")
	o.Spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
	o.Spark:SetBlendMode("ADD")
end

function BC:SetSparkPosition(o, isChanneling)
	if not o.Vertical then
		if isChanneling then
			o.sparkPositionX = ((o.value / o.maxValue) * o.Overlay:GetWidth()) + 1
		else
			o.sparkPositionX = ((o.currentTime / o.endTime) * o.Overlay:GetWidth()) - 1
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
			o.sparkPositionY = ((o.currentTime / o.endTime) * o.Overlay:GetHeight()) - 1
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

function BC:SetInterruptible(bar, notInterruptible)
	if bar.casting or bar.channeling then
		if notInterruptible then
			bar:SetOverlayColor(unpack(BC.DBColors.NotInterruptible))
			E:SkinButtonIcon(bar.Icon, BC.DBColors.NotInterruptible)
		else
			bar:SetOverlayColor(unpack(BC.DBColors.Interruptible))
			E:SkinButtonIcon(bar.Icon, BC.DBColors.Interruptible)
		end
	end
end

function BC:RemoveEventHandler(bar)
	if bar.active then
		bar:UnregisterAllEvents()
		bar:SetScript("OnEvent", nil)
		bar:SetScript("OnUpdate", nil)
	end
	
	bar.active = nil
end

function BC:AddEventHandler(bar)
	
	if bar.active then return end
	
	bar.casting = nil
	bar.channeling = nil
	bar.fadeOut = false
	bar.holdTime = 0
	
	-- Register a bunch (all) of spellcast events (all we need)
	bar:RegisterUnitEvent("UNIT_SPELLCAST_START", bar.Unit)
	bar:RegisterUnitEvent("UNIT_SPELLCAST_STOP", bar.Unit)
	bar:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", bar.Unit)
	bar:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", bar.Unit)
	bar:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", bar.Unit)
	bar:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", bar.Unit)
	bar:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", bar.Unit)
	bar:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", bar.Unit)
	bar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", bar.Unit)
	bar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", bar.Unit)
	bar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", bar.Unit)
	bar:RegisterEvent("UNIT_TARGET")
	if bar.Unit == "target" or bar.Unit == "targettarget" then
		bar:RegisterEvent("PLAYER_TARGET_CHANGED")
		if bar.Unit == "targettarget" then
			bar:RegisterUnitEvent("UNIT_TARGET", "target")
		end
	elseif bar.Unit == "focus" or bar.Unit == "focustarget" then
		bar:RegisterEvent("PLAYER_FOCUS_CHANGED")
		if bar.Unit == "focustarget" then
			bar:RegisterUnitEvent("UNIT_TARGET", "focus")
		end
	end
	
	-- Interruptor
	bar:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	
	bar:SetScript("OnEvent", function(self, event, ...)
		-- Interruptor handler START
		----------------------------
		if self:IsVisible() and event == "COMBAT_LOG_EVENT_UNFILTERED" then
			-- Probably the most efficient way we can go
			
			_, self.combatLogInfoType, _, _, self.combatLogInfoName, _, _, self.combatLogInfoGUID = CombatLogGetCurrentEventInfo()
			
			if self.combatLogInfoType == "SPELL_INTERRUPT" and self.combatLogInfoGUID == UnitGUID(self.Unit) then
				self.Interruptor = self.combatLogInfoName
				
				-- Check if the interruptor name is valid. Environmental effects like quaking leave this at nil, a.e.
				if self.Interruptor then
					self.Name:SetText(format("%s [%s]", INTERRUPTED, self.Interruptor))
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
		if not UnitExists(self.Unit) then self:Hide(); return; end
		if self.eventUnit ~= self.Unit and not event == "PLAYER_TARGET_CHANGED" then return end
		
		if (event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_FOCUS_CHANGED") and not (UnitCastingInfo(self.Unit) or UnitChannelInfo(self.Unit)) then
			self.casting = nil
			self.channeling = nil
			self.fadeOut = true
			self.holdTime = 0
			
			self:Hide()
		end
		
		if event == "UNIT_SPELLCAST_START" or ((event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_FOCUS_CHANGED") and UnitCastingInfo(self.Unit)) then
			self.SpellName, _, self.SpellTexture, self.startTime, self.endTime, self.SpellIsTradeSkill, self.SpellCastID, self.notInterruptible  = UnitCastingInfo(self.Unit)
			if self.SpellName then
				CastingBarFrame_ApplyAlpha(self, 1.0)
				self.holdTime = 0
				self.casting = true
				self.channeling = nil
				self.fadeOut = nil
				
				self.endTime = (self.endTime - self.startTime) / 1000
				self.currentTime = (GetTime() - (self.startTime / 1000))
				self:SetMinMaxValues(0, self.endTime)
				self:SetValue(self.currentTime)
				
				if ( self.Spark ) then
					self.Spark:Show()
				end
				self.Name:SetText(self.SpellName)
				self.Icon.Tex:SetTexture(self.SpellTexture)
				
				
				BC:SetInterruptible(self, self.notInterruptible)
				
				-- Keep lagbar enabled for non-player units, when the cast is interruptible to help with interrupting it on high latency
				if self.Unit ~= "player" and self.notInterruptible then BC:UpdateLagBar(self, false) else BC:UpdateLagBar(self, true) end
				
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
			
		
			
		elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
			if self.Name:GetText() == INTERRUPTED or self.channeling then return end
			
			-- If still casting [Fix for passive auras that also trigger this event]
			if UnitCastingInfo(self.Unit) then return end
			
			self.casting = nil
			self.channeling = nil
			self.fadeOut = true
			self.holdTime = CASTING_BAR_HOLD_TIME
			
			if ( self.Spark ) then
				self.Spark:Hide()
			end
			self:SetValue(select(2, self.Overlay:GetMinMaxValues()))
			self.Time:SetText("")
			
			self:SetOverlayColor(BC.DBColors.Success[1], BC.DBColors.Success[2], BC.DBColors.Success[3], 0.95)
			--local name, rank, displayName, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(bar.Unit)
			--if not name then
								
			--end

		elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then
			-- If still casting [Fix for passive auras that also trigger this event]
			if not self.channeling or UnitChannelInfo(self.Unit) then return end
			
			self.casting = nil
			self.channeling = nil
			self.fadeOut = true
			self.holdTime = CASTING_BAR_HOLD_TIME
			
			if ( self.Spark ) then
				self.Spark:Hide()
			end
			self:SetValue(select(2, self.Overlay:GetMinMaxValues()))
			self.Time:SetText("")
			
			self:SetOverlayColor(BC.DBColors.Failed[1], BC.DBColors.Failed[2], BC.DBColors.Failed[3], 0.95)
		elseif event == "UNIT_SPELLCAST_FAILED" then
			if UnitCastingInfo(self.Unit) then return end
			
			if not self.casting then return end
				self.casting = nil
				self.channeling = nil
				self.fadeOut = true
				self.holdTime = 0
				
				self:Hide()
			
		elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
			if not self.casting then return end
			-- If still casting [Fix for passive auras that also trigger this event]
			--if UnitCastingInfo(bar.Unit) then return end
			
			if ( self.Spark ) then
				self.Spark:Hide()
			end
			self:SetValue(select(2, self.Overlay:GetMinMaxValues()))
			self.Time:SetText("")
			
			-- We set the interruptor name in the COMBAT_LOG_EVENT_UNFILTERED handler
			self.Name:SetText(INTERRUPTED)
			
			self:SetOverlayColor(BC.DBColors.Failed[1], BC.DBColors.Failed[2], BC.DBColors.Failed[3], 0.95)
		
			self.casting = nil
			self.channeling = nil
			self.fadeOut = true
			self.holdTime = GetTime() + CASTING_BAR_HOLD_TIME
		elseif event == "UNIT_SPELLCAST_INTERRUPTIBLE" or event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" then
			BC:SetInterruptible(self, event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
		elseif event == "UNIT_SPELLCAST_DELAYED" then
			if ( self:IsShown() ) then
				self.SpellName, _, _, self.startTime, self.endTime, _, _, _  = UnitCastingInfo(self.Unit)
				if not self.SpellName then
					-- if there is no name, there is no bar
					self:Hide();
					return;
				end
				
				self.endTime = (self.endTime - self.startTime) / 1000
				self.currentTime = (GetTime() - (self.startTime / 1000))
				self:SetMinMaxValues(0, self.endTime)
			end
			
		-- Immediate interruption (Spellcast failed through movement or such)
		elseif event == "UNIT_SPELLCAST_STOP" then
			if not self.casting then return end
			
			self.casting = nil
			self.channeling = nil
			self.fadeOut = true
			self.holdTime = 0
			
			self:Hide()
		
		elseif event == "UNIT_SPELLCAST_CHANNEL_START" or ((event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_FOCUS_CHANGED") and UnitChannelInfo(self.Unit)) then
			self.SpellName, _, self.SpellTexture, self.startTime, self.endTime, self.SpellIsTradeSkill, self.notInterruptible = UnitChannelInfo(self.Unit)
			
			if not self.SpellName then
				-- if there is no name, there is no bar
				self:Hide()
				return
			end
				
			self:Show()
			self:SetAlpha(1)

			self.Name:SetText(self.SpellName)
			self.Icon.Tex:SetTexture(self.SpellTexture)
			self.maxValue = (self.endTime - self.startTime) / 1000
			self.value = (self.endTime / 1000) - GetTime()
			self.minValue = 0
			self:SetMinMaxValues(0, self.maxValue)
			self:SetValue(self.value)
			self.casting = nil
			self.channeling = true
			
			
			BC:SetInterruptible(self, self.notInterruptible)
			
			if ( self.Spark ) then
				self.Spark:Show()
			end
			
			BC:UpdateLagBar(self, false)
			
			self.holdTime = GetTime() + CASTING_BAR_HOLD_TIME
			
		-- Channel delay
		elseif event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
			if ( self:IsShown() ) then
				self.SpellName, _, self.SpellTexture, self.startTime, self.endTime, self.SpellIsTradeSkill, _, _ = UnitChannelInfo(self.Unit)
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
	end)
	
	bar.OnUpdate = self.OnUpdate
	bar:SetScript("OnUpdate", bar.OnUpdate)
	
	bar.active = true
end

function BC:OnUpdate(elapsed)
	if self.ForceMoverEnabled then return end
	
	if ( self.casting ) then
		
		self.currentTime = self.currentTime + elapsed;
		if ( self.currentTime >= self.endTime ) then
			self:SetValue(self.endTime);
			self.casting = nil;
			self.fadeOut = true;
			return;
		end
		self:SetValue(self.currentTime)
		self.Time:SetText(E:Round(self.endTime - self.currentTime, 1))
		if ( self.Flash ) then
			self.Flash:Hide();
		end
		if ( self.Spark ) then
			--BC:SetSparkPosition(self, false)
		end
		
	elseif ( self.channeling ) then
		self.value = self.value - elapsed;
		if ( self.value <= self.minValue ) then
			-- CastingBarFrame_FinishSpell(self, self.Spark, self.Flash);
			self.channeling = nil;
			self.fadeOut = true;
			return;
		end
		
		self:SetValue(self.value);
		self.Time:SetText(E:Round(self.value, 1))
		if ( self.Flash ) then
			self.Flash:Hide();
		end
		if ( self.Spark ) then
			--BC:SetSparkPosition(self, true)
		end
	elseif ( GetTime() < self.holdTime ) then
		return;
	elseif ( self.flash ) then
		local alpha = 0;
		if ( self.Flash ) then
			alpha = self.Flash:GetAlpha() + CASTING_BAR_FLASH_STEP;
		end
		if ( alpha < 1 ) then
			if ( self.Flash ) then
				self.Flash:SetAlpha(alpha);
			end
		else
			if ( self.Flash ) then
				self.Flash:SetAlpha(1.0);
			end
			self.flash = nil;
		end
	elseif ( self.fadeOut ) then
		local alpha = self:GetAlpha() - 0.015;
		if ( alpha > 0 ) then
			-- CastingBarFrame_ApplyAlpha(self, alpha);
			self:SetAlpha(alpha)
		else
			self.fadeOut = nil;
			self:Hide();
		end
	end
end

function BC:Create(unit)
	local i = self:GetIndex(unit) -- Get index
	local name = format("CUI_%sCastbar%s", unit, i)
	
	local Bar = E:CreateBar(name, "LOW", 235, 25, {"CENTER", E.Parent, "CENTER"}, E.Parent)
	E.Libs.LibSmooth:ResetBar(Bar.Overlay) -- Leaving the smooth anim on somehow causes the bar to not go at a 100%. This results in the LagBar simply being useless and just looks weird
	Bar:SetBackgroundColor(nil, nil, nil, 0.95)
	
	Bar.Unit = unit
	Bar.RawUnit, Bar.UnitNum = E:ExtractDigits(unit)
	
	Bar.Icon = CreateFrame("Frame", "CUI_CastbarIconHolder", Bar)
	Bar.Icon:SetSize(IconSize, IconSize)
	Bar.Icon:SetPoint("LEFT", Bar, "LEFT", -IconSize, 0)
	
	Bar.Icon.Tex = Bar.Icon:CreateTexture(nil, "OVERLAY")
	Bar.Icon.Tex:SetTexCoord(0.06, 0.94, 0.06, 0.94)
	Bar.Icon.Tex:SetParent(Bar.Icon)
	Bar.Icon.Tex:SetAllPoints(Bar.Icon)
	
	
	
	
	E:RegisterPathFont(self:AddText(Bar, "Time", "RIGHT", -10, 0), "db.profile.unitframe.units." .. Bar.RawUnit .. ".castbar.fonts.time")
	E:RegisterPathFont(self:AddText(Bar, "Name", "LEFT", 5, 0), "db.profile.unitframe.units." .. Bar.RawUnit .. ".castbar.fonts.name")
	
	-- Lag Bar
	self:AddLagBar(Bar)
	-- Spark
	self:AddSpark(Bar)
	-- Functionality
	self:AddEventHandler(Bar)
	-- Initial Hide
	Bar:Hide()
	-- Add mover
		-- No mover for clustered units !
	if Bar.UnitNum == "" then
		E:CreateMover(Bar, format("%s - %s", L[Bar.RawUnit], L["castbar"]))
	end
	-- Register castbar to engine
	self.Bars[unit] = Bar
	
	return Bar
end

function BC:UpdateDB()
	self.db = E.db
	self.moverdb = E.db.movers
end
function BC:Init()
	self:Create("player")
	self:Create("target")
	self:Create("targettarget")
	self:Create("focus")
	self:Create("focustarget")
	self:Create("pet")
	self:Create("boss1")
	self:Create("boss2")
	self:Create("boss3")
	self:Create("boss4")
	self:Create("boss5")
	
	self:Create("party1")
	self:Create("party2")
	self:Create("party3")
	self:Create("party4")
	self:Create("party5")
	
	self:Create("arena1")
	self:Create("arena2")
	self:Create("arena3")
	self:Create("arena4")
	self:Create("arena5")
	
	-- Load castbars
	self:LoadProfile()
end

E:AddModule("Bar_Cast", BC)