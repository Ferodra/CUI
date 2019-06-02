local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO,L,UF,TT = E:LoadModules("Config", "Locale", "Unitframes", "Tooltip")

--[[-------------------------------------------------------------------------

	Caching globals for faster access times

-------------------------------------------------------------------------]]--

local _
local format 							= string.format
local tsort								= table.sort
local tinsert							= table.insert
local unpack 							= unpack
local select 							= select
local pairs 							= pairs
local tonumber 							= tonumber
local type 								= type
local CreateFrame 						= CreateFrame
local RegisterUnitWatch 				= RegisterUnitWatch
local UnitExists 						= UnitExists
local UnitClass 						= UnitClass
local UnitName 							= UnitName
local UnitLevel 						= UnitLevel
local UnitIsConnected 					= UnitIsConnected
local UnitHealth 						= UnitHealth
local UnitHealthMax 					= UnitHealthMax
local UnitPower 						= UnitPower
local UnitPowerMax						= UnitPowerMax
local UnitStagger						= UnitStagger
local UnitInParty 						= UnitInParty
local UnitInRaid 						= UnitInRaid
local UnitIsGroupLeader 				= UnitIsGroupLeader
local UnitIsGroupAssistant 				= UnitIsGroupAssistant
local UnitGroupRolesAssigned 			= UnitGroupRolesAssigned
local WarlockPowerBar_UnitPower			= WarlockPowerBar_UnitPower
local GetRuneCooldown					= GetRuneCooldown
local GetSpecialization 				= GetSpecialization
local GetSpecializationInfoForClassID 	= GetSpecializationInfoForClassID
local UnregisterStateDriver 			= UnregisterStateDriver
local RegisterStateDriver 				= RegisterStateDriver
local InCombatLockdown 					= InCombatLockdown
local UIFrameFadeOut 					= UIFrameFadeOut
local UIFrameFadeIn 					= UIFrameFadeIn
local DEAD 								= DEAD
local FRIENDS_LIST_OFFLINE 				= FRIENDS_LIST_OFFLINE
-----------------------------------------------------------------------------

UF.Modules = {}

UF.UNITFRAMES_RANGE_UPDATE 					= 0.5 -- Range update frequency in seconds


-- Affected = Source
local Targets = {
	targettarget = {"target"},
	focustarget = {"focus"},
}
local PeriodicUnitUpdate = CreateFrame("Frame")

UF.HolderVisibilityOverride = false

UF.ToCreate = {["arena"] = 5,["party"] = 5,["boss"] = 5,["raid"] = 20,["raid40"] = 40}

function UF:GetUnitSpecs(Unit)
	local classID, specID, name, description, iconID, role, isRecommended, isAllowed
	classID 	= select(3,UnitClass(Unit))
	local data 	= {}

	for i=1,GetNumSpecializationsForClassID(classID) do
		specID, name, description, iconID, role, isRecommended, isAllowed = GetSpecializationInfoForClassID(classID, i)
		data[i] = {specID, name, description, iconID, role, isRecommended, isAllowed}
	end

	return data
end

function UF:UpdateBarColor(Bar, RGBA, r, g, b, a)
	if not RGBA and not r and not g and not b and not a then return end
	local BarTexture = Bar:GetStatusBarTexture()
	
	if RGBA then
		BarTexture:SetVertexColor(RGBA[1], RGBA[2], RGBA[3], RGBA[4] or select(4, BarTexture:GetVertexColor()) or 1)
		Bar.RGBA = RGBA
	else
		BarTexture:SetVertexColor(r, g, b, a or select(4, BarTexture:GetVertexColor()) or 1)
		Bar.r = r; Bar.g = g; Bar.b = b; Bar.a = a or select(4, BarTexture:GetVertexColor()) or 1
	end
end

function UF:SetHoverScript(Frame, State)
	-- For blizz functionality (Blizz does not use unit with an capital U)
	Frame.unit = Frame.Unit
	Frame.hideStatusOnTooltip = nil
	
	if State == true then
		Frame:SetScript('OnEnter', UnitFrame_OnEnter)
		Frame:SetScript('OnLeave', UnitFrame_OnLeave)
		Frame:EnableMouse(true)
	else
		Frame:SetScript('OnEnter', nil)
		Frame:SetScript('OnLeave', nil)
		Frame:EnableMouse(false)
	end
end

-------------------------------------------------------------------------------------------------------------------------------------
-- Refactor prototype
-------------------------------------------------------------------------------------------------------------------------------------

	----------------------------------------------------------
	-- Profile handler
	----------------------------------------------------------
	local function ApplyFontsProfile(self, ProfileTarget)
		local CurrentFont, CurrentFontProfile
		for k,v in pairs(self.Fonts) do
			CurrentFontProfile = ProfileTarget.fonts[E:stringToLower(k)]
			if CurrentFontProfile then
				v.Enable = CurrentFontProfile.enable
				
				if v.Enable == false then
					v:Hide()
				else
					v:Show()
					
					-- Font Shadow
						if CurrentFontProfile.fontShadowColor then
							v:SetShadowColor(CurrentFontProfile.fontShadowColor[1], CurrentFontProfile.fontShadowColor[2], CurrentFontProfile.fontShadowColor[3], CurrentFontProfile.fontShadowColor[4] or 1)
							v:SetShadowOffset(CurrentFontProfile.xFontShadowOffset, CurrentFontProfile.yFontShadowOffset)
						end
					-- Alignment
						if CurrentFontProfile.horizontalAlign then
							v:SetJustifyH(CurrentFontProfile.horizontalAlign)
						end
					-- Repositioning
						v:ClearAllPoints()
						v:SetPoint(CurrentFontProfile.position)
						E:MoveFrame(v, CurrentFontProfile.xOffset, CurrentFontProfile.yOffset)
					
					-- Level hide
						if CurrentFontProfile.doNotShowOnMaxLevel then
							v.ShowAtMax = CurrentFontProfile.doNotShowOnMaxLevel
						end
					-- Font Color
						if CurrentFontProfile.fontColor then
							v:SetTextColor(CurrentFontProfile.fontColor[1], CurrentFontProfile.fontColor[2], CurrentFontProfile.fontColor[3], CurrentFontProfile.fontColor[4] or 1)
						end
					-- Width
						if CurrentFontProfile.width then
							v:SetWidth(CurrentFontProfile.width)
						end
						
					
					-- Flags
						if CurrentFontProfile.fontFlags == "None" then v.Flags = E.TBL.EMPTY else v.Flags = CurrentFontProfile.fontFlags end
						
					-- 
						-- (Frame, fontName, fontFlags, fontHeight, fontColor)
						E:SetFontInfo(v, E.Media:Fetch("font", CurrentFontProfile.fontType), v.Flags, CurrentFontProfile.fontHeight, nil)
						E:UpdateFont(v)
						
					-- Text Format
						if CurrentFontProfile.textFormat then
							v.Format = CurrentFontProfile.textFormat
							--E:RegisterString(v.Format)
							
							E:RegisterTagFont(v, v.Format, self.Unit)
						end
				end
			end
		end
	
		self:UpdateFonts()
	end
	
	local ProfileTarget
	local function ApplyUFProfile(self, limit)
		ProfileTarget = UF.db.units[self.ProfileUnit]
		
		limit = limit or "all"
		
		if limit == "fonts" or limit == "all" then
			ApplyFontsProfile(self, ProfileTarget)
			
			-- Limit update to this module
			if limit == "fonts" then return end
		end

		-- Absorb
			if self.Health.Absorb then
				if ProfileTarget.health.enableAbsorb then
					-- As absorb is basically a statusbar, we can actually handle it like the healthbar					
					self.Health:SetSubBar(self.Health.Absorb, true, not ProfileTarget.health.barInverseFill, ProfileTarget.health.barOrientation)
					
					-- Let user toggle between stripes or full cover
					if ProfileTarget.health.absorbUseStripes then
						self.Health.Absorb.Border.Background:SetTexture(E.Media:Fetch("statusbar", "CUI Absorb Stripes"), "REPEAT", "REPEAT")
					else
						self.Health.Absorb.Border.Background:SetTexture([[Interface\Buttons\WHITE8X8]])
					end
					self.Health.Absorb.Border:SetBackdropBorderColor(ProfileTarget.health.absorbBorderColor[1], ProfileTarget.health.absorbBorderColor[2], ProfileTarget.health.absorbBorderColor[3], ProfileTarget.health.absorbBorderColor[4])
					self.Health.Absorb.Border.Background:SetVertexColor(ProfileTarget.health.absorbTextureColor[1], ProfileTarget.health.absorbTextureColor[2], ProfileTarget.health.absorbTextureColor[3], ProfileTarget.health.absorbTextureColor[4])
					
					self.Health.Absorb.TextureSizeMultiplier = ProfileTarget.health.absorbTextureSizeMultiplier or 7
					
					UF:InitAbsorbEvents(self.Health.Absorb)
					self.Health.Absorb:Update()
				else
					UF:RemoveAbsorbEvents(self.Health.Absorb)
					self.Health.Absorb:Hide()
				end
			end
			
			if self.Unit == "player" or self.Unit == "target" then
				ProfileTarget.power.fastUpdate = true
			end
		
		-- Player specific
			if self.ProfileUnit == "player" then
				E:GetModule("Alternate_Power"):LoadProfile()
				
				-- Combat indicator
				if self.CombatIndicator then
					self.CombatIndicator.enableGlow = ProfileTarget.combatIndicator.enableGlow
					self.CombatIndicator.enableIcon = ProfileTarget.combatIndicator.enableIcon
					
					if not self.CombatIndicator.enableGlow then self.CombatIndicator.Border:Hide(); end
					if not self.CombatIndicator.enableIcon then self.CombatIndicator.Icon:Hide(); end
					
					self.CombatIndicator.glowFadeIn = ProfileTarget.combatIndicator.glowFadeIn
					self.CombatIndicator.glowFadeOut = ProfileTarget.combatIndicator.glowFadeOut
					self.CombatIndicator.iconFadeIn = ProfileTarget.combatIndicator.iconFadeIn
					self.CombatIndicator.iconFadeOut = ProfileTarget.combatIndicator.iconFadeOut
					
					self.CombatIndicator.Icon:ClearAllPoints()
					self.CombatIndicator.Icon:SetPoint("CENTER", self.CombatIndicator, ProfileTarget.combatIndicator.iconPosition, ProfileTarget.combatIndicator.iconOffsetX, ProfileTarget.combatIndicator.iconOffsetY)
					self.CombatIndicator.Icon:SetSize(ProfileTarget.combatIndicator.iconSize, ProfileTarget.combatIndicator.iconSize)
										
					self.CombatIndicator.Border:SetBackdropBorderColor(ProfileTarget.combatIndicator.glowColor[1],ProfileTarget.combatIndicator.glowColor[2],ProfileTarget.combatIndicator.glowColor[3],ProfileTarget.combatIndicator.glowColor[4])
					self.CombatIndicator.Border:SetSize(self.CombatIndicator:GetWidth() + (ProfileTarget.combatIndicator.glowSize * 2), self.CombatIndicator:GetHeight() + (ProfileTarget.combatIndicator.glowSize * 2))
					self.CombatIndicator.Border.SetBorderSize(ProfileTarget.combatIndicator.glowSize)
				end
			end
		
		-- Override range update frequency
			self.RangeUpdateFrequency = 0.25
			
			self.enableRangeIndicator = ProfileTarget.rangeIndicator
			
		-- Override range indicator
			if not ProfileTarget.rangeIndicator then
				UF:RemoveRangeIndicator(self)
			else
				UF:AddRangeIndicator(self)
			end
		
		-- Update Mover
			E:UpdateMoverDimensions(self)
	end

	function UF:LoadProfile(limit)
		-- Load individual unitframe settings
		for _, Module in pairs(self.Modules) do
			if Module.LoadProfile then
				Module:LoadProfile()
			end
		end
		for _, frame in pairs(UF.Frames) do
			frame.Update(limit)
		end
	end

	function UF:GetUFMover(type)
		if type == "raid" or type == "raid40" or type == "party" or type == "boss" or type == "arena" then
			return E:GetMover(self:GetHolder(type))
		else
			return E:GetMover(self.Frames[type])
		end
	end
	
	function UF:GetUnitframe(Unit)
		return self.Frames[Unit]
	end
	
	-- To iterate a function over every unitframe of a specified unit type
	function UF:PerformForUnits(Unit, Function)
		if self.ToCreate[Unit] then
			for i = 1, self.ToCreate[Unit] do
				Function(Unit .. i)
			end
		else
			Function(Unit)
		end
	end
	
	function UF:LoadProfileForUnits(Unit, Limit)
		if self.ToCreate[Unit] then
			for i = 1, self.ToCreate[Unit] do
				UF.Frames[Unit .. i].Update(Limit)
			end
		else
			UF.Frames[Unit].Update(Limit)
		end
	end
	
	----------------------------------------------------------
	-- Update handlers
	----------------------------------------------------------
		
		local function NameFont_PostUpdate(self)
			self:SetTextColor(unpack(E:GetUnitReactionColor(self.Unit, false)))
		end
		
		local function HealthFont_PostUpdate(self)
			if not UnitIsDeadOrGhost(self.Unit) then
				if not UnitIsConnected(self.Unit) then
					self:SetText(FRIENDS_LIST_OFFLINE)
				end
			else
				self:SetText(DEAD)
			end
		end
		
		local function PowerFont_OnEvent(self, event, unit)
			if not event or (event and event == "UNIT_DISPLAYPOWER") then
				(self.Parent or self):SetTextColor(unpack(E:GetUnitPowerColor((self.Parent or self).Unit or unit)))
			end
		end
		
		local function PowerFont_PostUpdate(self)
			if not (UnitPowerMax(self.Unit) > 0) then
				self:SetText("")
			end
		end
		
		local function LevelFont_PostUpdate(self)
			self.Level = UnitLevel(self.Unit)
			
			if self.ShowAtMax == true and self.Level == E.UNIT_MAXLEVEL then
				self:SetText(E.STR.EMPTY)
			else
				if self.Level <= -1 then
					--self:SetText(E:ParseString(self.Format or "[level]", self.Unit))
					self:SetText(E.STR.Boss)
				end
			end
		end

		local function Fonts_Update(F)
			-- Fix for Bug that appeared first on 8.2 PTR
			if UnitName(F.Unit) then
				for k,v in pairs(F.Fonts) do
					if v.ForceUpdate then
						v:ForceUpdate()
					elseif v.Update then
						v:Update()
					end
					if v.OnEvent then
						v:OnEvent()
					end
				end
			end
		end

		-- This gets called by the OnEvent handler, which basically fires whenever a frame shows up and is missing data.
		-- The OnUpdate handler handles the periodic update calls for units we do not receive any events for. (targettarget, focustarget etc.)
		-- Every other update is performed by the individual modules
		local function UF_Update(self, event, unit, ...)
			-- Instead of "UnitExists". Bug#1: No Chambers displayed at Mother (Uldir)
			if not UnitName(self.Unit) then return end
				
				-- Base modules that definetely exist
				self.Health:ForceUpdate()
				self.Health.HealPrediction:ForceUpdate()
				self.Power:ForceUpdate()
				Fonts_Update(self)
				
				-- Modules we dont want to include in the OnUpdate ticks, as the internal events work just fine for them
				if not event or (event and (event ~= "OnUpdate" and event ~= "UNIT_FACTION")) then
					if self.Portrait then
						self.Portrait:ForceUpdate()
					end
					if self.Auras then
						self.Auras:ForceUpdate()
					end
					if self.RangeIndicator then
						self.RangeIndicator:ForceUpdate()
					end
					if self.LeaderIcon then
						self.LeaderIcon:ForceUpdate()
					end
					if self.Role then
						self.Role:ForceUpdate()
					end
					if self.TargetIcon then
						self.TargetIcon:ForceUpdate()
					end
					if self.TargetHighlight then
						self.TargetHighlight:ForceUpdate()
					end
					
					-- Optional modules that probably exist
					if self.ResurrectIndicator then
						self.ResurrectIndicator:ForceUpdate()
					end
					if self.SummonIndicator then
						self.SummonIndicator:ForceUpdate()
					end
				end
				
				-- @TODO: Pack into UF module
					self.Health.Absorb:Update()
				
				if UnitIsConnected(self.Unit) then
					UF:AddRangeIndicator(self)
				else
					UF:RemoveRangeIndicator(self)
					self:SetAlpha(0.5)
					UF:UpdateBarColor(self.Health, nil, 0.5, 0.5, 0.5)
				end
		end

		function UF:UpdateAllUF()
			for k, frame in pairs(self.Frames) do
				frame:ForceUpdate()
			end
			
			E:GetModule("Alternate_Power"):LoadProfile()
		end
		
		function UF:UpdateGroup(group)
			for k, frame in pairs(self.Frames) do
				if frame.ProfileUnit == group then
					frame:ForceUpdate()
				end
			end
		end

	----------------------------------------------------------
	-- OnEvent handler
	----------------------------------------------------------
		
		local function UnitFrame_ForceUpdate(self)
			UF_Update(self, "ForceUpdate")
		end
		
		local function UnitFrame_OnEvent(self, event, ...)
			UF_Update(self, event, ...)
		end
		
		local function UnitFrame_OnShow(self)
			if self.RangeIndicator and self.enableRangeIndicator then
				UF:AddRangeIndicator(self)
			end
			UF_Update(self)
		end
		local function UnitFrame_OnHide(self)
			if self.RangeIndicator then
				UF:RemoveRangeIndicator(self)
			end
		end

	----------------------------------------------------------
	-- Methods to create UF modules
	----------------------------------------------------------
		function UF:CreateUFBar(F, Name)
			local B = CreateFrame("Statusbar", Name or nil)
			if F then
				B:SetAllPoints(F)
				B:SetParent(F)
			end

			B:SetMinMaxValues(0, 100)
			B:SetValue(100)
			B:SetStatusBarTexture(E.Media:Fetch("statusbar", self.db.units.all.barTexture))

			E:RegisterStatusBar(B)

			return B
		end

		function UF:CreateFonts(F)

			local Fonts, FontName
			Fonts = {"Health", "Power", "Level", "Name", "Index"}

			for k,v in pairs(Fonts) do
				-- We have to define this here, since Lua only uses table referencing
				local Font = {}
				FontName = format("%s%sFont", F.Unit, v)

				--Font = E:NewFont(FontName, "OVERLAY", F.Overlay)
				Font = F.Overlay:CreateFontString(nil)
					E:InitializeFontFrame(Font, "OVERLAY", "FRIZQT__.TTF", 17, {0.933, 0.886, 0.125}, 0.9, {0,0}, "", 0, 0, F.Overlay, "CENTER", {1,1})
					Font.Unit = F.Unit
				Font.E = CreateFrame("Frame")
				Font.E.Parent = Font

				F.Fonts[v] = Font

				if v == "Health" then
					E:RegisterTagFontPostUpdate(Font, HealthFont_PostUpdate)
				end
				if v == "Power" then
					--Font.E:RegisterUnitEvent("UNIT_POWER_UPDATE", F.Unit)
					--Font.E:RegisterUnitEvent("UNIT_POWER_FREQUENT", F.Unit)
					Font.E:RegisterUnitEvent("UNIT_DISPLAYPOWER", F.Unit)
					
					Font.OnEvent = PowerFont_OnEvent
					E:RegisterTagFontPostUpdate(Font, PowerFont_PostUpdate)
				end
				if v == "Level" then
					E:RegisterTagFontPostUpdate(Font, LevelFont_PostUpdate)
				end
				if v == "Name" then
					E:RegisterTagFontPostUpdate(Font, NameFont_PostUpdate)
				end
				if v == "Index" then
					Font.Parent = CreateFrame("Frame", nil)
					Font.Parent:SetAllPoints(F)
					Font.Parent:SetFrameLevel(999)
					
					Font:SetText(select(2, E:ExtractDigits(F.Unit)))
					Font:SetPoint("CENTER", Font.Parent, "CENTER")
					Font:SetParent(Font.Parent)
					Font.Update = function() end

					Font:Hide()
				end

				Font.E:SetScript("OnEvent", Font.OnEvent)
				if Font.OnEvent then Font:OnEvent() end
			end
		end

		function UF:CreateTargetIcon(F)
			--local I = CreateFrame("Frame", nil)
			return E:CreateTextureFrame(nil, F, 8, 8, "OVERLAY")
		end
		
		function UF:CreateCombatIndicator(F)
			local CI = CreateFrame("Frame", nil)
				CI:SetParent(F)
				CI:SetAllPoints(F)
			
			CI.Border = E:CreateBorder(CI, [[Interface\AddOns\CUI\Textures\borders\glow]], 7)
				CI.Border:SetBackdropBorderColor(0.9, 0, 0, 0.9)
				CI.Border:SetFrameLevel(1)
				CI.Border:ClearAllPoints()
				CI.Border:SetPoint("CENTER", CI, "CENTER")
				
			CI.Icon = CreateFrame("Frame", nil)
				CI.Icon:SetPoint("CENTER", CI, "CENTER", 0,20)
				CI.Icon:SetParent(CI)
				CI.Icon:SetSize(32,32)

				CI.Icon.T = CI.Icon:CreateTexture(nil, "OVERLAY")
				CI.Icon.T:SetAllPoints(CI.Icon)
				CI.Icon.T:SetTexture([[Interface\AddOns\CUI\Textures\icons\Combat]])
			
			CI.Icon:Hide()
			CI.Border:Hide()
			
			CI:RegisterEvent("PLAYER_REGEN_ENABLED")
			CI:RegisterEvent("PLAYER_REGEN_DISABLED")
			CI:SetScript("OnEvent", function(self, event)
				if event == "PLAYER_REGEN_ENABLED" then
					if self.enableGlow then UIFrameFadeOut(self.Border, self.glowFadeOut, 1, 0) end
					if self.enableIcon then UIFrameFadeOut(self.Icon, self.iconFadeOut, 1, 0) end		
				else
					if self.enableGlow then UIFrameFadeIn(self.Border, self.glowFadeIn, 0, 1) end
					if self.enableIcon then UIFrameFadeIn(self.Icon, self.iconFadeIn, 0, 1) end	
				end
			end)
			
			return CI
		end
		
		function UF:RegisterModule(Name, Module)
			self.Modules[Name] = Module
			Module.db = self.db
		end
		
		function UF:AddModule(Object, Module)
			if not self.Modules[Module] then error(("Module %s does not exist!"):format(Module)); return; end
			self.Modules[Module]:Create(Object)
		end

	----------------------------------------------------------
	-- Method to create a UnitFrame
	----------------------------------------------------------
	UF.Frames = {}
	function UF:CreateUF(Unit, Index, Header, UnitButton)
		local RawUnit, UnitNum = E:ExtractDigits(Unit)
		local Config = self.db.units[RawUnit]
		local FrameName = format("CUI_%s", Unit)
		local OverlayFrameName
		local F = CreateFrame("Frame", FrameName, UnitButton or E.Parent)
		F.Fonts = {}

		-- Add Unitframe to register
		if Index then
			self.Frames[RawUnit .. Index .. UnitNum] = F
				F.ProfileUnit = RawUnit .. Index
				OverlayFrameName = RawUnit .. Index .. "_" .. UnitNum
		else
			self.Frames[Unit] = F
			F.ProfileUnit = RawUnit
			OverlayFrameName = Unit
		end
	
		if not Header then
		-- UF Overlay to interact with, since the highlight does not work on the Base frame
			F.Overlay = CreateFrame("Button", format("CUI_UF_%s", E:firstToUpper(OverlayFrameName)), F, "SecureUnitButtonTemplate")
			F.Overlay:SetAllPoints(F)
			F.Overlay:SetParent(F)
			F.Overlay:EnableMouse(true)
			F:SetIgnoreParentAlpha(true)
		else
			if not UnitButton then
				F.Overlay = CreateFrame("Frame", format("CUI_UF_%s", E:firstToUpper(OverlayFrameName)), Header)
				F.Overlay:SetAllPoints(Header)
				F.Overlay:SetParent(Header)
			else
				F.Overlay = UnitButton
			end
		end
		
		-- For 'unittarget' units, we have to use an onupdate handler, since we don't get any events for them
		if Unit:match('%w+target') then
			F.Eventless = true
			tinsert(PeriodicUnitUpdate, F)
		end
		
		F.Overlay:SetFrameLevel(10)

		-- Set unit
			F.Unit = Unit
			F.RawUnit = RawUnit
			F.Overlay.Unit = Unit
			F.BackupUnit = Unit -- In case the dummy mode is enabled, we have to use this one

		-- Add UF Modules
			
			self:AddModule(F, "BarHealth")			-- F.Health
			self:AddModule(F, "HealPrediction")		-- F.Health.HealPrediction
			self:AddModule(F, "BarPower")			-- F.Power
			self:AddModule(F, "Portrait")			-- F.Portrait
			self:AddModule(F, "Auras")				-- F.Auras
			self:AddModule(F, "RoleIndicator")		-- F.Role
			self:AddModule(F, "Highlight")			-- F.Highlight
			self:AddModule(F, "TargetHighlight")	-- F.TargetHighlight
			self:AddModule(F, "ResurrectIndicator")	-- F.ResurrectIndicator
			self:AddModule(F, "LeaderIcon")			-- F.LeaderIcon
			self:AddModule(F, "TargetIcon")			-- F.TargetIcon
			
			self:AddHealthAbsorb(F.Health)
			
			if Unit == "player" then
				F.CombatIndicator = self:CreateCombatIndicator(F.Overlay)
			end
			if RawUnit == "arena" or RawUnit == "party" or RawUnit == "raid" or RawUnit == "player" or RawUnit == "target" then
				if RawUnit ~= "target" then
					-- F.ReadyCheckIndicator
					self:AddModule(F, "ReadyCheckIndicator")
					F.ReadyCheckIndicator:SetFrameLevel(10)
				end
				if RawUnit ~= "arena" then
					-- F.SummonIndicator
					self:AddModule(F, "SummonIndicator")
					F.SummonIndicator:SetFrameLevel(10)
				end
			end
			
		-- Add UF Fonts
			self:CreateFonts(F)

		-- Set Required attributes
			F:SetAttribute("unit", Unit)
			if not Header then
				F.Overlay:SetAttribute("unit", Unit)
			end

		-- Set hover script
			self:SetHoverScript(F.Overlay, true)

		-- Set interaction attributes
			if not Header or UnitButton then
				F.Overlay:RegisterForClicks("AnyUp")
			end
			if not Header then
				F.Overlay:SetAttribute("type1", "target")
				F.Overlay:SetAttribute("*type2", "togglemenu")
				F.Overlay:SetAttribute("shift-type1", "focus")
					if Unit == "focus" then F.Overlay:SetAttribute("shift-type1", "macro"); F.Overlay:SetAttribute("macrotext", "/focus none"); end
			end

			-- Register Frame to the engine so it will take care of its visibility
				RegisterUnitWatch(F)

			-- Register a bunch of events to handle target changing etc.
			-- Since we register just the neccessary event(s) to each frame, we do not have to care
			-- about which event fired in the OnEvent handler.
			-- Wohoo!

					-- When the unit turns hostile/friendly or whatever
					F:RegisterUnitEvent("UNIT_FACTION", Unit)
				
				-- Events that handle situations in which we have to update the unitframe
				if Unit == "target" or Unit == "targettarget" then
					F:RegisterEvent("PLAYER_TARGET_CHANGED")
				elseif Unit == "focus" or Unit == "focustarget" then
					F:RegisterEvent("PLAYER_FOCUS_CHANGED")
				elseif Unit == "pet" then
					F:RegisterEvent("UNIT_PET")
				elseif RawUnit == "party" or RawUnit == "raid" then
					F:RegisterEvent("GROUP_ROSTER_UPDATE")
					F:RegisterEvent("UPDATE_INSTANCE_INFO")
				elseif RawUnit == "boss" then
					F:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
				end
				if Unit ~= "player" then
					F:RegisterUnitEvent("UNIT_CONNECTION", Unit)
					F:RegisterUnitEvent("UNIT_NAME_UPDATE", Unit) -- Probably the only reliable way to update when every dataset is ready
				else
					--RegisterAttributeDriver(F, "unit", "[vehicleui] vehicle; player")
					--F:SetScript("OnAttributeChanged", function(self)
					--	self.Unit = self:GetAttribute("unit")
					--	UF_Update(self)
					--end)
				end
				
				-- We previously scanned for every unit target call
				-- But with this method, we have total control over what happens
				if Targets[Unit] then
					for _, source in pairs(Targets[Unit]) do
						if source then
							F:RegisterUnitEvent("UNIT_TARGET", source)
						end
					end
				end
			-- When a frame event fires, update modules
				F:SetScript("OnEvent", UnitFrame_OnEvent)
				-- To make the update instantaneous when the frame shows up
					F:SetScript("OnShow", UnitFrame_OnShow)
					F:SetScript("OnHide", UnitFrame_OnHide)

		-- Initial Update
			UnitFrame_ForceUpdate(F)
		-- Setup profile methods
			F.ForceUpdate = UnitFrame_ForceUpdate
			F.UpdateFonts = Fonts_Update
			F.Update = function(limit) ApplyUFProfile(F, limit) end

		-- Prevent creation of movers for clustered unitframes
		-- We'll do it for those when the holder is being created
		if not Header then
			if RawUnit ~= "arena" and RawUnit ~= "party" and RawUnit ~= "boss" and RawUnit ~= "raid" then
				E:CreateMover(F, L[Unit .. "Frame"], nil, nil, nil, format("The %s Unitframe", E:firstToUpper(RawUnit)))
			end
		end

		return F
	end

	UF.Holders = {}
	UF.Holders.SortMethod = {
		["arena"] 	= {"TOPLEFT", 0, 15, "+", "-"},
		["party"] 	= {"TOPLEFT", 0, 15, "+", "-"},
		["raid"] 	= {"TOPRIGHT", 2, 2, "-", "-"},
		["raid40"] 	= {"TOPRIGHT", 2, 2, "-", "-"},
		["boss"] 	= {"TOPLEFT", 0, 15, "+", "-"},
	}

	function UF:CreateUFHolder(Type, SX, SY)
		local Holder = CreateFrame("Frame", format("%sHolder", Type), E.Parent, "SecureHandlerStateTemplate")
		if SX and SY then Holder:SetSize(SX, SY) end
		Holder:SetPoint("CENTER", E.Parent, "CENTER")
		Holder.Type = Type
		Holder.Unitframes = {}

		self.Holders[Type] = Holder

		E:SetVisibilityHandler(Holder)

		E:CreateMover(Holder, L[format("%sFrame", Type)], nil, nil, nil, format("The %s Unitframe Cluster", E:firstToUpper(Type)))

		return Holder
	end

	function UF:GetHolder(Unit)
		return self.Holders[Unit]
	end

	function UF:OverrideHolderVisibility(state)
		self.HolderVisibilityOverride = state
		
		for k,v in pairs(self.Holders) do
			if k ~= "SortMethod" then
				if state == true then
					UnregisterStateDriver(self:GetHolder(k), "visible")
					RegisterStateDriver(self:GetHolder(k), "visible", "1")
				else
					self:LoadHolderConfig(k)
				end
			end
		end
	end
	
	function UF:LoadAllHolderConfig()
		for k,v in pairs(self.Holders) do
			if k ~= "SortMethod" then
				self:LoadHolderConfig(k)
			end
		end
	end
	
	function UF:GetClusterConfig(Name)
		return self.db.clusters[Name]
	end

	function UF:LoadHolderConfig(Unit)
		local startSortFrom = ""
		local Holder = self:GetHolder(Unit)
		
		if not Holder then return end
		
		local HolderSortMethod = self.Holders.SortMethod[Unit]
		local Config = self.db.units[Unit]
		
		local ClusterConfig = UF:GetClusterConfig(Config.UFInfo.cluster.clusterName)
			
		-- Override sort config
		HolderSortMethod[1] = ClusterConfig.perRow
		HolderSortMethod[2] = not ClusterConfig.inverseStartX
		HolderSortMethod[3] = not ClusterConfig.inverseStartY
		HolderSortMethod[4] = ClusterConfig.gapX
		HolderSortMethod[5] = ClusterConfig.gapY

		-- Check if the user currently wants the holders to stay visible
		if self.HolderVisibilityOverride == false then
			UnregisterStateDriver(Holder, "visible")
			RegisterStateDriver(Holder, "visible", ClusterConfig.visibilityCondition)
		end

		-- Apply changes
		self:SortUFHolderContents(Holder)
	end

	function UF:SortUFHolderContents(Holder)

		local PerRow, InverseStartX, InverseStartY, GapX, GapY = unpack(self.Holders.SortMethod[Holder.Type])
		-- Frames, Parent, Width, Height, SizeMult, PerRow, InverseStartX, InverseStartY, GapX, GapY, Ordered
		local totalWidth, totalHeight = E:SortFrames(Holder.Unitframes, Holder, nil, nil, nil, PerRow, InverseStartX, InverseStartY, GapX, GapY, true)

		Holder:SetSize(totalWidth, totalHeight)
		E:UpdateMoverDimensions(Holder)
	end

	function UF:AssignUFHolder(Holder, F)
		F:ClearAllPoints()
		F:SetPoint("CENTER", Holder, "CENTER")
		F:SetParent(Holder)

		tinsert(Holder.Unitframes, F)
	end
	
	local function SortByClass(a, b)
		if (a and b) and (a.SortValue_Class and b.SortValue_Class) then
			if a.SortValue_Class < b.SortValue_Class then
				return true
			elseif a.SortValue_Class > b.SortValue_Class then
				return false
			end
		end
	end
	
	-- @TODO: A new sort method to easily define new positions
	function UF:SortRaidHolder()
		
		local Map = {}
		
		-- Write required data to holder frames
		for k, v in pairs(UF.Holders["raid40"]) do
			if type(v) == "table" then
				if UnitExists(v.Unit) then
					v.SortValue_Class = select(3, UnitClass(v.Unit))
				end
			end
		end
		
		tsort(UF.Holders["raid40"], SortByClass)
	end
	

-------------------------------------------------------------------------------------------------------------------------------------
-- Refactor end
-------------------------------------------------------------------------------------------------------------------------------------
function UF:UpdateDB()
	self.db = E.db.unitframe
	
	for _, Module in pairs(self.Modules) do
		Module.db = self.db
	end
end
function UF:Init()
	
	self:UpdateDB()
	E.PlayerClass = select(2, UnitClass("player"))

	self:CreateUF("player")
	self:CreateUF("target")
	self:CreateUF("targettarget")
	self:CreateUF("focus")
	self:CreateUF("focustarget")
	self:CreateUF("pet")

	-- @TODO: Create a new type of UF Holder that dynamically can create unitframes on the fly when needed
	--local HolderSortHandler = CreateFrame("Frame")
	--HolderSortHandler:RegisterEvent("GROUP_ROSTER_UPDATE")
	--HolderSortHandler:SetScript("OnEvent", UF.SortRaidHolder)
	
	local ArenaHolder 		= self:CreateUFHolder("arena")
	local PartyHolder 		= self:CreateUFHolder("party")
	local BossHolder 		= self:CreateUFHolder("boss")
	local RaidHolder 		= self:CreateUFHolder("raid")
	local RaidFullHolder 	= self:CreateUFHolder("raid40")

	for i=1,5 do
		self:AssignUFHolder(ArenaHolder, self:CreateUF("arena" .. i))
		self:AssignUFHolder(PartyHolder, self:CreateUF("party" .. i))
		self:AssignUFHolder(BossHolder, self:CreateUF("boss" .. i))
	end
	for i=1,20 do
		self:AssignUFHolder(RaidHolder, self:CreateUF("raid" .. i))
	end
	for i=1,40 do
		self:AssignUFHolder(RaidFullHolder, self:CreateUF("raid" .. i, "40"))
	end
	
	-- Experimental
	-- self.Headers:Create("raid")

	self:LoadProfile()
	self:LoadAllHolderConfig()
	
	PeriodicUnitUpdate:SetScript('OnUpdate', function(self, elapsed)
		self.elapsed = (self.elapsed or 0) + elapsed
		
		if self.elapsed > 0.5 then
			-------------------------
				for _, frame in pairs(self) do
					if type(frame) == 'table' then
						if frame.ForceUpdate then
							UF_Update(frame, "OnUpdate")
						end
					end
				end
			-------------------------
			
			self.elapsed = 0
		end
	end)
end

E:AddModule("Unitframes", UF)
