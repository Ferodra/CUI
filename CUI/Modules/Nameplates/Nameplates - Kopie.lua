local E = unpack(select(2, ...)) -- Engine, Locale
local CO, Module = E:LoadModules("Config", "Nameplates")
Module.Autoload = true;

----------------------------------------
local _
local format		= string.format
local match			= string.match
----------------------------------------

--[[-------------------------------------------------

	This module modifies Blizzard nameplates
	
	The actual styling is done in the StylePlate method.
	The way nameplates work is that once a plate was created,
	it actually keeps its modifications.
	A modification of the styling preferences is possible at any point.

-------------------------------------------------]]--
-- Nameplate keys: Plate.UnitFrame, Plate.UnitFrame.healthBar, Plate.UnitFrame.healthBar.border,
--				   Plate.UnitFrame.castBar, Plate.UnitFrame.BuffFrame, Plate.UnitFrame.selectionHighlight
--				   Plate.UnitFrame.aggroHighlight, Plate.UnitFrame.LoseAggroAnim, Plate.UnitFrame.name
--				   Plate.UnitFrame.ClassificationFrame

-- Nameplate API: C_NamePlate.GetNamePlateForUnit, C_NamePlate.GetNamePlates, C_NamePlate.SetNamePlateEnemyClickThrough,
--				  C_NamePlate.SetNamePlateEnemySize, C_NamePlate.SetNamePlateFriendlyClickThrough, 
--				  C_NamePlate.SetNamePlateFriendlySize, C_NamePlate.SetNamePlateSelfClickThrough, 
--				  C_NamePlate.SetNamePlateSelfSize
local C_NamePlate_GetNamePlateForUnit 		= C_NamePlate.GetNamePlateForUnit
local C_NamePlate_SetNamePlateSelfSize 		= C_NamePlate.SetNamePlateSelfSize
local C_NamePlate_SetNamePlateEnemySize 	= C_NamePlate.SetNamePlateEnemySize
local C_NamePlate_SetNamePlateFriendlySize 	= C_NamePlate.SetNamePlateFriendlySize
local C_QuestLog_GetNumQuestLogEntries		= C_QuestLog.GetNumQuestLogEntries and C_QuestLog.GetNumQuestLogEntries or GetNumQuestLogEntries
--local C_QuestLog_GetTitleForLogIndex		= C_QuestLog.GetTitleForLogIndex and C_QuestLog.GetTitleForLogIndex or GetQuestLogTitle
local C_QuestLog_GetInfo 					= C_QuestLog.GetInfo
local C_QuestLog_IsComplete 				= C_QuestLog.IsComplete
local UnitIsTapDenied 	= UnitIsTapDenied
local UNKNOWN			= UNKNOWN

local NameFont_Exclusions = {["fontColor"] = true}
local LevelFont_Exclusions = {["fontColor"] = true}

local TappedColor = {0.5, 0.5, 0.5}
local ScanningTooltip = CreateFrame("GameTooltip", "CUI_NameplateScanningTooltip", nil, "GameTooltipTemplate")
local QuestListener = CreateFrame("Frame", "CUI_NameplateQuestListenerFrame")
local Quests_Update

-- Kickable cast, Dispellable Auras, Configurable HP Text, Power Bar (If possible), Time to cast finish, Unit Name, Unit Level Text

-- Stores available nameplate unitIDs
Module.Plates = {}

--------------------------------------------------------
--	Functionality to actually access nameplates
--------------------------------------------------------
	
	-- Only gets called by the profile handler and config dialog
	function Module:LoadConfig()
		
		local Config = self.db
		local Unitframe
		
		if not CO.db.char.nameplates.enable then return end
		
		for Name, _ in pairs(self.Plates) do
			
			Unitframe = self:GetPlateUnitframe(Name)
			
			if Unitframe and Unitframe.Mod then
				Unitframe.HPBar:SetSize(Config.barWidth, Config.barHeight)
				Unitframe.HPBar:SetStatusBarTexture(E.Media:Fetch("statusbar", Config.barTexture))
				
				if Config.questIcon.enable then
					if not Unitframe.QuestIcon then
						Module:InitQuestIcon(Unitframe)
					end
					
					if Unitframe.QuestIcon then
						Unitframe.QuestIcon:SetScale(Config.questIcon.scale)
						
						Unitframe.QuestIcon:ClearAllPoints()
						Unitframe.QuestIcon:SetPoint(E:InversePosition(Config.questIcon.position), Unitframe.HPBar, Config.questIcon.position, Module.db.questIcon.xOffset, Config.questIcon.yOffset)
						
						Unitframe.QuestIcon:ForceUpdate()
					end
				else
					if Unitframe.QuestIcon then
						Unitframe.QuestIcon:Hide()
					end
				end
				
				Unitframe:ForceUpdate()
			end
		end
		
		Quests_Update()
		
		C_NamePlate_SetNamePlateSelfSize(Config.clickableWidth, Config.clickableHeight)
		C_NamePlate_SetNamePlateEnemySize(Config.clickableWidth, Config.clickableHeight)
		C_NamePlate_SetNamePlateFriendlySize(Config.clickableWidth, Config.clickableHeight)
		
		-- CVar stuff
		E:RegisterCVar("nameplateShowSelf", nil, nil, true)
		E:RegisterCVar("nameplateShowAll", nil, nil, true)
	end
	
	function Module:GetPlateUnitframe(Unit)
		self.CurrentPlate = C_NamePlate_GetNamePlateForUnit(Unit)
		if self.CurrentPlate then
			return self.CurrentPlate.UnitFrame
		end
		
		return false
	end

	function Module:AddPlate(Nameplate, Unit)
		-- Do not alter player plate(s)
		local Unit = Nameplate.unit or Unit
		
		if UnitIsUnit("player", Unit) then return end
		
		local Unitframe = self:GetPlateUnitframe(Unit)
		
		Nameplate.blizzPlate = Unitframe
		Nameplate.widgetsOnly = UnitNameplateShowsWidgetsOnly(Unit)
		Unitframe.widgetsOnly = Nameplate.widgetsOnly

		self.Plates[Unit] = true
		self:UpdatePlate(Unitframe)
	end

	function Module:RemovePlate(Unit)
		self.Plates[Unit] = nil
	end

	local function OnEvent(nameplate, event, ...)	
		-- Add to table
		if event == "NAME_PLATE_UNIT_ADDED" then
			Module:AddPlate(nameplate, ...)
		-- Remove from table
		elseif event == "NAME_PLATE_UNIT_REMOVED" then
			--Module:RemovePlate(...)
		elseif event == "PLAYER_TARGET_CHANGED" then
			Module:UpdateTargeted()
		
		-- This should fix Names not being updated properly
		elseif event == "UNIT_FACTION" or event == "UNIT_NAME_UPDATE" then
			Module:UpdateGeneral(nameplate, ...)
		end
	end

--------------------------------------------------------
--	Nameplate styling
--------------------------------------------------------
	local OnlyShowQuests
	Quests_Update = function(event, questID)
		-- Module.QuestList = {
		-- 		[QuestName] = {[QuestID], [IsComplete]}
		-- }
		-- Start over fresh, just to be sure
		if not event or (event and event ~= 'QUEST_LOG_UPDATE') then
			Module.QuestList = Module.QuestList and wipe(Module.QuestList) or {}
		end
		
		local Title, IsHeader, IsCollapsedHeader, IsComplete, QuestID, IsTask
		OnlyShowQuests = Module.db.questIcon.onlyShowQuests
		local Info
		
		for i=1, C_QuestLog_GetNumQuestLogEntries() do
			Info = C_QuestLog_GetInfo(i)
			
			if Info then
				Title, IsHeader, IsCollapsedHeader, QuestID, IsTask = Info.title, Info.isHeader, Info.isCollapsed, Info.questID, Info.isTask
				
				if not IsHeader and (not (OnlyShowQuests and IsTask) or not OnlyShowQuests) then
					if QuestID then
						IsComplete = C_QuestLog_IsComplete(i)
					end
					Module.QuestList[Title] = Module.QuestList[Title] or {}
					
					Module.QuestList[Title].QuestID 	= QuestID
					Module.QuestList[Title].IsComplete 	= IsComplete
				end
			end
		end
		
		Module:UpdateAllQuestIcons()
	end
	
	local function Quests_OnEvent(self, event, ...)
		-- HANDLE QUEST EVENTS HERE
		Quests_Update(event, ...)
	end
	
	local function GetUnitColor(Unit)
		if not UnitIsTapDenied(Unit) then
			return E:GetUnitReactionColor(Unit, false)
		else
			return TappedColor
		end
	end
	
	local function Update_NameColor(self, newColor)
		if self.Mod and self.Name then
			
			newColor = newColor or GetUnitColor(self.unit)
		
			self.name:Hide()
			self.Name:SetTextColor(unpack(newColor))
		end
	end
	
	local function Update_PlateColor(self)
		if not self.Mod then return end
		
		local Color = self.OverrideColor or GetUnitColor(self.unit)
		
		self.HPBar:SetStatusBarColor(unpack(Color))
		Update_NameColor(self, Color)
	end
	
	local function Update_Health(self, event, ...)
		if not self.owner.unit then return end
		local Max, Value = UnitHealthMax(self.owner.unit), UnitHealth(self.owner.unit)
		
		self:SetMinMaxValues(0, Max)
		self:SetValue(Value)
		if Max == 0 and Value == 0 then
			self.Font:SetText("Error")
		else
			self.Font:SetText(format("%.1f%%", (Value / Max) * 100))
		end
	end
	
	local function NameUpdate_Cancel(self)
		self:SetScript('OnUpdate', nil)
	end
	local function NameUpdate_OnUpdate(self, elapsed)
		-- Tick every 0.2 seconds
		self.Elapsed = (self.Elapsed or 0) + elapsed
		if self.Elapsed < 0.2 then return end
		self.Elapsed = 0
		
		-- Cancel scheduler when unit does not exist
		if not UnitExists(self.Owner.unit) then
			print("Cancel update of", self.Owner.unit)
			NameUpdate_Cancel(self)
			return
		end
		
		self.NameCache = UnitName(self.Owner.unit)
		--print(self.Owner.unit, " has name ", self.NameCache)
		
		-- If the name was found, update Text and Color
			self.Name:SetText(self.NameCache)
		if self.NameCache and self.NameCache ~= UNKNOWN then
			Update_PlateColor(self.Owner)
			
			-- Exit Scheduler
			NameUpdate_Cancel(self)
			return
		end
	end
	local function Schedule_NameUpdate(self)
		if not self:GetScript('OnUpdate') then			
			self:SetScript('OnUpdate', NameUpdate_OnUpdate)
		end
	end
	
	local function Update_NameFont(self)
		if self.Mod and self.Name then
			local Name = UnitName(self.unit)
			self.Name:SetText(Name)
			
			if Name == UNKNOWN then
				Schedule_NameUpdate(self.FontContainer)
			end
		end
	end
	
	local function Update_LevelFont(self)
		local Level = UnitLevel(self.unit)
		
		if self.Level.ShowAtMax == true and Level == E.UNIT_MAXLEVEL then
			self.Level:SetText(E.STR.EMPTY)
		else
			if Level ~= -1 then
				self.Level:SetText(Level)
				
				self.Level:SetTextColor(E:GetRGB(GetQuestDifficultyColor(Level)))
			else
				self.Level:SetText(E.STR.Boss)
				self.Level:SetTextColor(1, 0.2, 0.2)
			end
		end
	end
	
	local QuestIcon_ForceUpdate
	local function Construct_QuestIcon(self)
		self.QuestIcon = CreateFrame('Frame', 'CUI_NameplateQuestIcon', self.HPBar)
		self.QuestIcon:SetSize(12, 18)
		self.QuestIcon:SetScale(Module.db.questIcon.scale)
		self.QuestIcon:SetPoint(E:InversePosition(Module.db.questIcon.position), self.HPBar, Module.db.questIcon.position, Module.db.questIcon.xOffset, Module.db.questIcon.yOffset)
		self.QuestIcon.Tex = self.QuestIcon:CreateTexture(nil, 'OVERLAY')
		self.QuestIcon.Tex:SetAllPoints(self.QuestIcon)
		self.QuestIcon.Tex:SetTexture([[Interface\QUESTFRAME\AutoQuest-Parts]])
		self.QuestIcon.Tex:SetTexCoord(0.13476563 ,0.171875 ,0.015625 ,0.53125)
		
		self.QuestIcon.Owner = self
		self.QuestIcon.ForceUpdate = QuestIcon_ForceUpdate
	end
	
	local function Update_QuestMob(self)
		if not Module.db.questIcon.enable or not UnitExists(self.unit) then
			if self.QuestIcon then
				self.QuestIcon:Hide()
			end
			return
		end
		
		ScanningTooltip:SetOwner(UIParent, 'ANCHOR_NONE')
		ScanningTooltip:SetUnit(self.unit)
		ScanningTooltip:Show()
		
		self.QuestInfo = self.QuestInfo and wipe(self.QuestInfo) or {}
		
		local CurStr, IsMyQuest, Progress, QuestInfo
		for i=2,ScanningTooltip:NumLines() do			
			CurStr = _G['CUI_NameplateScanningTooltipTextLeft' .. i]
			CurStr = CurStr and CurStr:GetText()
			
			if not CurStr then break end
			if not QuestInfo then
				QuestInfo = Module.QuestList[CurStr]
			end
			
			-- /dump CUI[1]:LoadModule('Nameplates').QuestList
			
			if UnitIsPlayer(CurStr) and (IsInGroup() or IsInRaid()) then
				IsMyQuest = CurStr == E.PlayerName
			elseif QuestInfo then
				self.QuestInfo.ObjectiveCount 				= self.QuestInfo.ObjectiveCount or {}
				
				local Current, Goal = match(CurStr, '(%d+)/(%d+)')
				if Current and Goal then
					self.QuestInfo.ObjectiveCount.Current 	= Current
					self.QuestInfo.ObjectiveCount.Goal 		= Goal
					self.QuestInfo.ObjectiveCount.Finished 	= Current == Goal
				else
					self.QuestInfo.ObjectiveCount.Finished	= QuestInfo.IsComplete
				end
				
				self.QuestInfo.IsComplete 					= QuestInfo.IsComplete
				self.QuestInfo.QuestID 						= QuestInfo.QuestID
			end
		end
		
		ScanningTooltip:Hide()
		
		if self.QuestInfo and self.QuestInfo.QuestID and not self.QuestInfo.IsComplete and not self.QuestInfo.ObjectiveCount.Finished then
			if not self.QuestIcon then
				Construct_QuestIcon(self)
			end
			
			self.QuestIcon:Show()
		else
			if self.QuestIcon then
				self.QuestIcon:Hide()
			end
		end
	end
	
	local Unit_Player = "player"
	local function OnEvent_Threat(self, event, unit)
		-- Irrelevant update
		if self.Owner.unit ~= unit then return end
		
		if (UnitInParty(Unit_Player) or UnitInRaid(Unit_Player)) then
			-- When IsTanking is nil, unit is not in combat
			local IsTanking, ShouldTank = E:IsPlayerTankingUnit(unit)
			--print(string.format("Is Tanking? %s Should Tank? %s", IsTanking, ShouldTank))
			
			if IsTanking ~= nil then			
				if (not ShouldTank and IsTanking) or (ShouldTank and not IsTanking) then
					self.Border:Show()
					return
				end
			end
		end
		
		self.Border:Hide()
	end
	
	local function Update_Threat(self)
		OnEvent_Threat(self.CUI_ThreatIndicatorFrame, nil, self.unit)
	end
	
	local Texture_Glow = [[Interface/AddOns/CUI/Textures/borders/glow]]
	local function Construct_Threat(self)
		--"UNIT_THREAT_SITUATION_UPDATE", "UNIT_THREAT_LIST_UPDATE"
		
		local Frame = CreateFrame('Frame', 'CUI_NameplateThreatIndicator', self.HPBar)
		Frame:SetAllPoints(self.HPBar)
		
		Frame.Border = E:CreateBorder(Frame, Texture_Glow, 7)
		Frame.Border:SetFrameLevel(1)
		Frame.Border:ClearAllPoints()
		Frame.Border:SetPoint("CENTER", Frame, "CENTER")
		
		local GlowSize = 16
		Frame.Border:SetBackdropBorderColor(1,0,0)
		Frame.Border:SetSize(self.HPBar:GetWidth() + (GlowSize * 2), self.HPBar:GetHeight() + (GlowSize * 2))
		Frame.Border.SetBorderSize(GlowSize)
		
		Frame.Owner = self
		self.CUI_ThreatIndicatorFrame = Frame
		
		Frame:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
		Frame:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
		Frame:SetScript("OnEvent", OnEvent_Threat)
		
		OnEvent_Threat(Frame, nil, self.unit)
	end
	
	local function Nameplate_OnShow(self)
		Module:UpdatePlate(self)
	end
	
	local function ForceUpdate(self)
		Module:UpdatePlate(self)
	end
	
	QuestIcon_ForceUpdate = function(self)
		Update_QuestMob(self.Owner)
	end
	
	function Module:InitQuestIcon(Unitframe)
		Update_QuestMob(Unitframe)
	end
	
	function Module:UpdatePlate(Unitframe)
		
		if Unitframe.widgetsOnly then return end
		
		--Unitframe.unit = Unitframe.unit
		
		if not Unitframe.Mod then
			self:StylePlate(Unitframe, Unitframe.unit)
			Unitframe.ForceUpdate = ForceUpdate
		else
			Module:UpdateUnit(Unitframe)
		end
		
		Update_Health(Unitframe.HPBar)
		
		Update_NameFont(Unitframe)
		Update_LevelFont(Unitframe)
		
		Update_QuestMob(Unitframe)
		Update_Threat(Unitframe)
		
		-- Update color last, so we can make changes to it
		Update_PlateColor(Unitframe)
		self:UpdateTargeted()
	end
	
	function Module:UpdateAllQuestIcons()
		local Unitframe
		for Name, _ in pairs(self.Plates) do
			Unitframe = self:GetPlateUnitframe(Name)
			
			if Unitframe and Unitframe.QuestIcon and Unitframe:IsVisible() then
				Unitframe.QuestIcon:ForceUpdate()
			end
		end
	end
	
	function Module:UpdateUnit(Unitframe)
		Unitframe.HPBar:UnregisterEvent("UNIT_HEALTH")
		Unitframe.HPBar:RegisterUnitEvent("UNIT_HEALTH", Unitframe.unit)
		
		Unitframe.CUI_ThreatIndicatorFrame:RegisterUnitEvent("UNIT_THREAT_SITUATION_UPDATE", Unitframe.unit)
		Unitframe.CUI_ThreatIndicatorFrame:RegisterUnitEvent("UNIT_THREAT_LIST_UPDATE", Unitframe.unit)
	end
	
	local function Construct_Font(Unitframe, Data)
		local FontContainer = Unitframe.FontContainer
		local Font = FontContainer:CreateFontString(nil)
		E:InitializeFontFrame(Font, "OVERLAY", "FRIZQT__.TTF", 9, {0.9, 0.9, 0.9}, 0.9, {0, -4}, "", 0, 0, FontContainer, "CENTER", {1,1})
		
		Unitframe[Data.key], FontContainer[Data.key] = Font, Font
		
		if Data.exclusions then
			E:RegisterFontExclusions(Data.autofontPath, Data.exclusions)
		end
		E:RegisterAutoFont(Font, Data.autofontPath, Data.exclusions)
		E:UpdateAutoFont(Data.autofontPath)
	end
	local Fonts = {
		{
			["key"] = "Name",
			["exclusions"] = NameFont_Exclusions,
			["autofontPath"] = "db.profile.nameplates.name",
		},
		{
			["key"] = "Level",
			["exclusions"] = LevelFont_Exclusions,
			["autofontPath"] = "db.profile.nameplates.level",
		},
		{
			["key"] = "Health",
			["autofontPath"] = "db.profile.nameplates.health",
		}
	}
	local function Construct_Fonts(Unitframe)
		local FontContainer = CreateFrame("Frame", nil, Unitframe.HPBar)
		FontContainer:SetAllPoints(true)
		FontContainer:SetScript("OnEvent", Fonts_OnEvent)
		FontContainer.Owner = Unitframe
		Unitframe.FontContainer = FontContainer
		
		for _, Data in pairs(Fonts) do
			Construct_Font(Unitframe, Data)
		end
		
		FontContainer:RegisterEvent("UNIT_NAME_UPDATE")
		FontContainer:RegisterEvent("UNIT_LEVEL")
	end
	
	function Module:StylePlate(Unitframe, Unit)
		-- Only mod each Plate once
		if not Unit then return end
		
		if not Unitframe.Mod and not Unitframe.widgetsOnly then
			---------------------------
			-- Healthbar
				-- Bar smoothing
					
				-- This actually is a completely new bar so we never have to mess with the Blizz ones [Taint 'n stuff]
				
				local Healthbar = CreateFrame("statusbar", "NamePlate_HealthBar" .. Unit, Unitframe)
				Healthbar:SetScript("OnEvent", Update_Health)
				Healthbar:RegisterUnitEvent("UNIT_HEALTH", Unit)
				if not E.IsRetail then
					Healthbar:RegisterEvent("UNIT_HEALTH_FREQUENT")
				end
				
				Unitframe.HPBar = Healthbar
				Healthbar.owner = Unitframe
				
				Healthbar.Background = E:CreateBackground(Healthbar)
				Healthbar.Border = E:CreateBorder(Healthbar)
				
				E.Libs.LibSmooth:SmoothBar(Healthbar)
				
			-- Bar texture
				E:RegisterStatusBar(Healthbar)
				Healthbar:SetStatusBarTexture(E.Media:Fetch("statusbar", self.db.barTexture))
				
				Healthbar:SetSize(self.db.barWidth, self.db.barHeight)
				Healthbar:SetPoint("CENTER", Unitframe, "CENTER", 0, 0)
				
				-- Keep old bar hidden
				Unitframe.healthBar:HookScript('OnShow', function(self) self:Hide() end)
				Unitframe.healthBar:Hide()
			
			
			---------------------------
			-- Fonts
					
				Construct_Fonts(Unitframe)
				
			---------------------------
			-- Various stuff to make our lives easier
			
				Unitframe.HealthFont	 	= Unitframe.Health
				Healthbar.Font 				= Unitframe.Health
				hooksecurefunc("CompactUnitFrame_UpdateHealthColor", Update_PlateColor)
				hooksecurefunc("CompactUnitFrame_UpdateName", Update_NameColor)
				
			-- Selection texture
				Unitframe.selectionHighlight:ClearAllPoints()
				Unitframe.selectionHighlight:SetTexture(nil)
				Unitframe.HealthBarsContainer:Hide()
				Unitframe.HealthBarsContainer:SetAlpha(0)
			
			-- Custom selection indicator
				Unitframe.SelectionBorder = E:CreateBorder(Healthbar, nil, 1)
				Unitframe.SelectionBorder:SetBackdropBorderColor(1, 1, 1, 1)
				Unitframe.SelectionBorder:Hide()
				
			-- Classification Icon
				Unitframe.ClassificationFrame:ClearAllPoints()
				Unitframe.ClassificationFrame:SetPoint("BOTTOMRIGHT", Healthbar, "TOPLEFT")
				
			-- Threat
				Construct_Threat(Unitframe)
				
			-- Force update when it shows up
			-- This is to prevent a bug with spawned units whose name cannot be resolved
				Unitframe:SetScript("OnShow", Nameplate_OnShow)
			
			
			---------------------------
			Unitframe.Mod = true
			
			return
		elseif Unitframe.widgetsOnly then
		
			if Unitframe.Mod then
				Unitframe.HPBar:Hide()
				
				for k,v in pairs(Fonts) do
					if k == "key" then
						Unitframe.FontContainer[v]:Hide()
					end
				end
			end
			
			return
		end
		
		if Unitframe.widgetsOnly and Unitframe.Mod then
			for k,v in pairs(Fonts) do
				if k == "key" then
					Unitframe.FontContainer[v]:Show()
				end
			end
		end
	end
	
	function Module:UpdateTargeted()
		for unit, _ in pairs(self.Plates) do
			
			self.TargetPlate = Module:GetPlateUnitframe(unit)
			
			if type(self.TargetPlate) == "table" then
				if self.TargetPlate.SelectionBorder then
					if UnitExists("target") and UnitIsUnit(self.TargetPlate.unit, "target") then
						self.TargetPlate.SelectionBorder:Show()
					else
						self.TargetPlate.SelectionBorder:Hide()
					end
				end
			end
		end
	end
	
	-- This seems to get called whenever we have to perform a critical update (Name etc)
	function Module:UpdateGeneral(Nameplate, Unit)
		local Plate = self:GetPlateUnitframe(Unit)
		if Plate then
			Module:UpdatePlate(Plate)
		end
	end



--------------------------------
function Module:UpdateDB()
	self.db = CO.db.profile.nameplates
end
function Module:Init()
	self:UpdateDB()
	
	if not CO.db.char.nameplates.enable then return end
	
	E:RegisterEvents(QuestListener, 'QUEST_ACCEPTED', 'QUEST_REMOVED', 'QUEST_LOG_UPDATE', 'QUEST_FINISHED', 'PLAYER_ENTERING_WORLD')
	QuestListener:SetScript('OnEvent', Quests_OnEvent)
	
	self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("UNIT_FACTION")
	
	self:SetScript("OnEvent", OnEvent)
	self:LoadConfig()
end
E:AddModule("Nameplates", Module)