local E, L = unpack(select(2, ...)) -- Engine, Locale
local L, CO, NP = E:LoadModules("Locale", "Config", "Nameplates")
NP.Autoload = true;

----------------------------------------
local _
local format		= string.format
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

-- Nameplate API: C_NamePlate.GetNamePlateForUnit, C_NamePlate.GetNamePlates, C_NamePlate.SetNamePlateEnemyClickThrough,
--				  C_NamePlate.SetNamePlateEnemySize, C_NamePlate.SetNamePlateFriendlyClickThrough, 
--				  C_NamePlate.SetNamePlateFriendlySize, C_NamePlate.SetNamePlateSelfClickThrough, 
--				  C_NamePlate.SetNamePlateSelfSize
local C_NamePlate_GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit
local C_NamePlate_SetNamePlateSelfSize = C_NamePlate.SetNamePlateSelfSize
local C_NamePlate_SetNamePlateEnemySize = C_NamePlate.SetNamePlateEnemySize
local C_NamePlate_SetNamePlateFriendlySize = C_NamePlate.SetNamePlateFriendlySize

local NameFont_Exclusions = {["fontColor"] = true}
local LevelFont_Exclusions = {["fontColor"] = true}

-- Kickable cast, Dispellable Auras, Configurable HP Text, Power Bar (If possible), Time to cast finish, Unit Name, Unit Level Text

-- Stores available nameplate unitIDs
NP.Plates = {}

--------------------------------------------------------
--	Functionality to actually access nameplates
--------------------------------------------------------
	
	-- Only gets called by the profile handler and config dialog
	function NP:LoadProfile()
		
		local Config = self.db
		local Plate
		
		for Name, _ in pairs(self.Plates) do
			
			Plate = self:GetPlateUnitframe(Name)
			
			if Plate and Plate.HPBar then
				Plate.HPBar:SetSize(Config.barWidth, Config.barHeight)
				Plate.HPBar:SetStatusBarTexture(E.Media:Fetch("statusbar", Config.barTexture))
			end
		end
		
		C_NamePlate_SetNamePlateSelfSize(Config.clickableWidth, Config.clickableHeight)
		C_NamePlate_SetNamePlateEnemySize(Config.clickableWidth, Config.clickableHeight)
		C_NamePlate_SetNamePlateFriendlySize(Config.clickableWidth, Config.clickableHeight)
	end
	
	function NP:GetPlateUnitframe(Unit)
		self.CurrentPlate = C_NamePlate_GetNamePlateForUnit(Unit)
		if self.CurrentPlate then
			return self.CurrentPlate.UnitFrame
		end
		
		return false
	end

	function NP:AddPlate(Unit)
		-- Do not alter player plate(s)
		if UnitIsUnit("player", Unit) then return end
		
		local Unitframe = self:GetPlateUnitframe(Unit)
		
		self.Plates[Unit] = true
		
		self:UpdatePlate(Unitframe)
	end

	function NP:RemovePlate(Unit)
		self.Plates[Unit] = nil
	end

	function NP:OnEvent(event, ...)	
		-- Add to table
		if event == "NAME_PLATE_UNIT_ADDED" then
			self:AddPlate(...)
		-- Remove from table
		elseif event == "NAME_PLATE_UNIT_REMOVED" then
			--self:RemovePlate(...)
		elseif event == "PLAYER_TARGET_CHANGED" then
			self:UpdateTargeted()
		
		-- This should fix Names not being updated properly
		elseif event == "UNIT_FACTION" or event == "UNIT_NAME_UPDATE" then
			self:UpdateGeneral(...)
		end
	end

--------------------------------------------------------
--	Nameplate styling
--------------------------------------------------------
	
	local function Update_Health(self, event, ...)
		if not self:GetParent().displayedUnit then return end
		local Max, Value = UnitHealthMax(self:GetParent().displayedUnit), UnitHealth(self:GetParent().displayedUnit)
		
		self:SetMinMaxValues(0, Max)
		self:SetValue(Value)
		if Max == 0 and Value == 0 then
			self.Font:SetText("Error")
		else
			self.Font:SetText(format("%.1f%%", (Value / Max) * 100))
		end
	end
	
	local function Update_NameFont(self)
		if self.Mod and self.Name then
			self.Name:SetText(UnitName(self.displayedUnit))
		end
	end
	
	local function Update_NameColor(self)
		if self.Mod and self.Name then
			self.name:Hide()
			self.Name:SetTextColor(unpack(E:GetUnitReactionColor(self.displayedUnit, false)))
		end
	end
	
	local function Update_PlateColor(self)
		if not self.Mod then return end
		
		self.HPBar:SetStatusBarColor(self.healthBar:GetStatusBarColor())
		Update_NameColor(self)
	end
	
	local function Update_LevelFont(self)
		local Level = UnitLevel(self.displayedUnit)
		
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
	
	local function Nameplate_OnShow(self)
		NP:UpdatePlate(self)
	end
	
	function NP:UpdatePlate(Unitframe)
		
		Unitframe.Unit = Unitframe.displayedUnit
		
		if not Unitframe.Mod then
			self:StylePlate(Unitframe, Unitframe.displayedUnit)
		end
		
		Unitframe.healthBar:Hide()
		Update_PlateColor(Unitframe)
		Update_Health(Unitframe.HPBar)
		
		Update_NameFont(Unitframe)
		Update_LevelFont(Unitframe)
		
		self:UpdateTargeted()
	end
	
	function NP:StylePlate(Unitframe, Unit)
		-- Only mod each Plate once
		if not Unitframe.Mod then
			---------------------------
			-- Healthbar
				-- Bar smoothing
					
					-- This actually is a completely new bar so we never have to mess with the Blizz ones [Taint 'n stuff]
					
					local Healthbar = CreateFrame("statusbar", "NamePlate_HealthBar" .. Unit, Unitframe)
					Healthbar:SetScript("OnEvent", Update_Health)
					Healthbar:RegisterEvent("UNIT_HEALTH")
					Healthbar:RegisterEvent("UNIT_HEALTH_FREQUENT")
					Unitframe.HPBar = Healthbar
					
					Healthbar.Background = E:CreateBackground(Healthbar)
					Healthbar.Border = E:CreateBorder(Healthbar)
					
					E.Libs.LibSmooth:SmoothBar(Healthbar)
					
				-- Bar texture
					E:RegisterStatusBar(Healthbar)
					Healthbar:SetStatusBarTexture(E.Media:Fetch("statusbar", self.db.barTexture))
					
					Healthbar:SetSize(self.db.barWidth, self.db.barHeight)
					Healthbar:SetPoint("CENTER", Unitframe, "CENTER", 0, 0)
			
			
			---------------------------
			-- @TODO: We actually can register those fonts via PathFont.
			-- 		  Also, pack the fonts into a compact and simple table
			-- Fonts
			
				local FontContainer = CreateFrame("Frame", nil, Healthbar)
				FontContainer:SetAllPoints(true)
				FontContainer:SetScript("OnEvent", Fonts_OnEvent)
			
				-- Name
					
					local Name = FontContainer:CreateFontString(nil)
						E:InitializeFontFrame(Name, "OVERLAY", "FRIZQT__.TTF", 9, {0.9, 0.9, 0.9}, 0.9, {0, -4}, "", 0, 0, FontContainer, "CENTER", {1,1})
					FontContainer:RegisterEvent("UNIT_NAME_UPDATE")
					Unitframe.Name = Name
				
				-- Level
					
					local Level = FontContainer:CreateFontString(nil)
						E:InitializeFontFrame(Level, "OVERLAY", "FRIZQT__.TTF", 9, {0.9, 0.9, 0.9}, 0.9, {0, -4}, "", 0, 0, FontContainer, "LEFT", {1,1})
					FontContainer:RegisterEvent("UNIT_LEVEL")
					Unitframe.Level = Level
					
				-- Health
					
					local Health = FontContainer:CreateFontString(nil)
						E:InitializeFontFrame(Health, "OVERLAY", "FRIZQT__.TTF", 8, {0.9, 0.9, 0.3}, 0.9, {-3, 0}, "", 0, 0, FontContainer, "RIGHT", {1,1})						
					Unitframe.Health = Health
						
					E:RegisterPathFont(Health, "db.profile.nameplates.health")
					E:UpdatePathFont("db.profile.nameplates.health")
					
					E:RegisterPathFont(Level, "db.profile.nameplates.level", LevelFont_Exclusions)
					E:UpdatePathFont("db.profile.nameplates.level")	
					
					E:RegisterPathFont(Name, "db.profile.nameplates.name", NameFont_Exclusions)
					E:UpdatePathFont("db.profile.nameplates.name")
					
				
			---------------------------
			-- Various stuff to make our lives easier
			
				Unitframe.HealthFont	 	= Health
				Healthbar.Font 				= Health
				hooksecurefunc("CompactUnitFrame_UpdateHealthColor", Update_PlateColor)
				hooksecurefunc("CompactUnitFrame_UpdateName", Update_NameColor)
				
			-- Selection texture
				Unitframe.selectionHighlight:ClearAllPoints()
				Unitframe.selectionHighlight:SetTexture(nil)
				Unitframe.healthBar.border:Hide()
			
			-- Custom selection indicator
				Unitframe.SelectionBorder = E:CreateBorder(Healthbar, nil, 1)
				Unitframe.SelectionBorder:SetBackdropBorderColor(1, 1, 1, 1)
				Unitframe.SelectionBorder:Hide()
				
			-- Force update when it shows up
			-- This is to prevent a bug with spawned units whose name cannot be resolved
				Unitframe:SetScript("OnShow", Nameplate_OnShow)
			
			
			---------------------------
			Unitframe.Mod = true
		end
	end
	
	function NP:UpdateTargeted()
		for unit, _ in pairs(self.Plates) do
			
			self.TargetPlate = NP:GetPlateUnitframe(unit)
			
			if type(self.TargetPlate) == "table" then
				if self.TargetPlate.SelectionBorder then
					if UnitExists("target") and UnitIsUnit(self.TargetPlate.Unit, "target") then
						self.TargetPlate.SelectionBorder:Show()
					else
						self.TargetPlate.SelectionBorder:Hide()
					end
				end
			end
		end
	end
	
	-- This seems to get called whenever we have to perform a critical update (Name etc)
	function NP:UpdateGeneral(Unit)
		local Plate = self:GetPlateUnitframe(Unit)
		if Plate then
			NP:UpdatePlate(Plate)
		end
	end



--------------------------------
function NP:UpdateDB()
	self.db = E.db.nameplates
end
function NP:Init()
	
	self:UpdateDB()
	
	if not self.db.enable then return end
	
	self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("UNIT_FACTION")
	
	self:SetScript("OnEvent", NP.OnEvent)
	self:LoadProfile()
end
E:AddModule("Nameplates", NP)