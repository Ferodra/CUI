---@class E, L
local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF, Module = E:LoadModules("Config", "Unitframes", "Classpower")
Module.Autoload = true

----------------------------------------------------------
local select 					= select
local format 					= string.format
local pairs 					= pairs
local tinsert 					= table.insert
local UnitClass 				= UnitClass
local GetSpecialization 		= GetSpecialization
local UnitHealthMax 			= UnitHealthMax
local UnitPower 				= UnitPower
local UnitPowerMax 				= UnitPowerMax
local UnitStagger 				= UnitStagger
local UnitAura					= C_TooltipInfo.GetUnitAura
local GetAuraDataByIndex 		= C_UnitAuras and C_UnitAuras.GetAuraDataByIndex
local UnpackAuraData 			= AuraUtil and AuraUtil.UnpackAuraData
----------------------------------------------------------

--[[------------------------------------------------
	
	The new Classpower module uses a segment
	based method to display powers.
	Every time the max power changes, either
	new segments are being created, or unused
	segments are being hidden.
	No matter which of those actions was performed,
	all segments are being repositioned and resized
	to fit the required space.
	For non-separated powers, such as mana, we only use segment #1
	
	There probably is a metric ton of optimization we
	can do here.
	
------------------------------------------------]]--

local ClassPowers = {} -- Supported (separate) power types

-- Various data we need for proper updates
local Data = {
	-- Adds support for frost mage icicles
	["Mage"] = {
		["Icicles"] = {
			["ID"] = 205473, -- Icicles buff ID
			["Max"] = 5, -- Max of 5 icicles
		},
	},
	-- Monk stagger bar
	["Monk"] = {
		["Stagger"] = {
			["Percentage"] = 0.6, -- 60% of max HP as bar maximum (configurable)
		},
	},
	-- Visibility Conditions
	["CONDITIONS"] = {
		["HIDDEN"] = 				"0",
		["VISIBLE"] = 				"1",
		["NOFORM"] = 				"[noform] 1;0",
		["NOFORM_MOONKINFORM"] = 	"[noform] 1;[form:4] 1;0",
		["BEARFORM"] = 				"[form:1] 1;0",
		["CATFORM"] = 				"[form:2] 1;0",
	},
}

function Module:UpdateSeparatedPowers()
	for k,v in pairs(E.PowerTypesDisplayType) do
		if v then
			tinsert(ClassPowers, k)
		end
	end
end

local function GetAltPower_Mage_Frost()
	local i = 1
	local ID, Count
	while true do
		_,_, Count,_,_,_,_,_,_, ID = UnpackAuraData(GetAuraDataByIndex("player", i, "HELPFUL"))
		if not ID or ID == Data.Mage.Icicles.ID then break end
		
		i = i + 1
	end
	
	return Count or 0
end

local function GetAltPower_Warlock()
	local shardPower = UnitPower("player", 7, true);
	local shardModifier = UnitPowerDisplayMod(7);
	return (shardModifier ~= 0) and (shardPower / shardModifier) or 0;
end

local function GetAltPowerValue(id)
	local value
	if id == 30 then
		value = UnitStagger("player")
	elseif id == 33 then
		value = GetAltPower_Mage_Frost()
	elseif id == 7 then
		value = GetAltPower_Warlock()
	else
		value = UnitPower("player", id)
		
	end
	
	return value
end

local function GetAltPowerMax(id)
	local value
	if id == 30 then
		-- Use 1 to 100% of maximum HP for stagger (ID = 30)
		if CO.db.profile.unitframe.units.player.alternatePower.data.BREWMASTER_StaggerMax then
			value = UnitHealthMax("player") * ((CO.db.profile.unitframe.units.player.alternatePower.data.BREWMASTER_StaggerMax / 100) or 0.6)
		else
			value = UnitHealthMax("player") * 0.6
		end
	elseif id == 33 then
		value = Data.Mage.Icicles.Max
	else
		value = UnitPowerMax("player", id)
	end

	return value
end

function Module:LoadConfig()
	
	self:UpdateDB()
	
	if not self.Holder then return end

	if not self.db.enable then
		self:Disable()
		return
	else
		self:Enable()
	end
	
	self:UpdateSegments() -- To apply various changes
	self:UpdateValue() -- To apply various changes
	
	-- Apply fill direction, border and background config
	local Segment
	for i = 1, self.NumMaxSegments do
		Segment = self.CurrentPower.Bars[i]
		
		Segment.Overlay:SetReverseFill(self.db.reverseFill)
		Segment.Overlay:SetOrientation(self.db.fillOrientation)
		
		Segment:SetBorderSize(self.db.borderSize)
		Segment:SetBorderColor(unpack(self.db.borderColor))
		Segment:SetBackgroundColor(unpack(self.db.backgroundColor))
		
		Segment.Overlay:SetStatusBarTexture(E.Media:Fetch("statusbar", self.db.barTexture))
	end
	
	self:UpdateSegments()
	self:UpdateRuneColors()
	
	self.Holder:SetSize(self.db.width, self.db.height)
	E:UpdateMoverDimensions(self.Holder)
	
	-- ArtFill
	self.dbFill = self.db.artFill

	if self.dbFill.enable then
		if not self.Holder.ArtFill then
			E:CreateArtFill(self.Holder)
		end
		-----------------------
		local ArtFill = self.Holder.ArtFill
		ArtFill:ClearAllPoints()
		ArtFill:SetPoint("TOPLEFT", self.Holder, "TOPLEFT", self.dbFill.paddingX * (-1), self.dbFill.paddingY)
		ArtFill:SetPoint("BOTTOMRIGHT", self.Holder, "BOTTOMRIGHT", self.dbFill.paddingX, self.dbFill.paddingY * (-1))
		
		ArtFill:SetFrameStrata("BACKGROUND")
		ArtFill:SetFrameLevel(1)
		
		ArtFill.Border.SetBorderSize(self.dbFill.borderSize)
		ArtFill.Border:SetBackdropBorderColor(unpack(self.dbFill.borderColor))
		ArtFill.Background:SetColorTexture(unpack(self.dbFill.backgroundColor))
		
		-----------------------
		ArtFill:Show()
	else
		if self.Holder.ArtFill then self.Holder.ArtFill:Hide() end
	end
	
	--self.MonkStaggerMax = CO.db.profile.unitframe.units.player.alternatePower.data.monkStaggerMax
	
end

function Module:CreateHolder()
	local Holder = CreateFrame("Frame", "CUI_AlternatePower", E.Parent)
	Holder:SetPoint("CENTER", E.Parent, "CENTER")
	Holder:SetSize(self.db.width, self.db.height)
	
	Holder:SetFrameStrata("LOW")
	Holder:SetFrameLevel(10)
	
	self:UpdateCurrentPowerInfo()
	E:HandleFrameInPetBattles(Holder)
	
	E:SetVisibilityHandler(Holder)
	self:UpdateHolderVisibility()
	
	E:CreateMover(Holder, L["alternatePower"])
	
	self.Holder = Holder
end

function Module:UpdateHolderVisibility()
	--if not InCombatLockdown() then
	--	RegisterStateDriver(self.Holder, "visible", self.VisibilityCondition)
	--end
	
	if self.PowerId == nil then return false else return true end
end

function Module:IsPowerSeparated(PowerID)
	return E:TableContainsValue(ClassPowers, PowerID)
end

function Module:RepositionSegments()
	local Bars = self.CurrentPower.Bars
	
	-- Separated
	if self:IsPowerSeparated(self.PowerId) then
		local SizeX = ((self.Holder:GetWidth() / self.PowerMax) - self.db.gap) + (self.db.gap / self.PowerMax)
		local SizeY = self.Holder:GetHeight()
		
		for i = 1, self.PowerMax do
			Bars[i]:ClearAllPoints()
			Bars[i]:SetPoint("LEFT", self.Holder, "LEFT", SizeX * (i - 1) + ((i - 1) * (self.db.gap)), 0)
			Bars[i]:SetSize(SizeX, SizeY)
		end
	-- One bar
	else
		Bars[1]:ClearAllPoints()
		Bars[1]:SetPoint("CENTER", self.Holder, "CENTER", 0, 0)
		Bars[1]:SetSize(self.Holder:GetWidth(), self.Holder:GetHeight())
	end
end

function Module:CreateSegment(i, SizeX, SizeY)
	local Segment = E:CreateBar(format("CUI_AlternatePowerSegment%d", i), "LOW", SizeX, SizeY, {"LEFT", self.Holder, "LEFT", SizeX * (i - 1) + ((i - 1) * (5)), 0}, self.Holder, nil, nil, nil, nil)
	
	Segment:SetFrameStrata("LOW")
	Segment:SetFrameLevel(9)	
	--Segment:SetBackgroundColor(unpack(self.db.backgroundColor))
	Segment:SetBorderSize(self.db.borderSize)
	Segment:SetBorderColor(unpack(self.db.borderColor))
	Segment.Overlay:SetStatusBarTexture(E.Media:Fetch("statusbar", self.db.barTexture))
	Segment:SetMinMaxValues(0, 100) -- 100 as max value for smoothing
	
	self.CurrentPower.Bars[i] = Segment
end

function Module:CreateSegments()

	if not self.CurrentPower.Bars then self.CurrentPower.Bars = {} end
	
	-- Separated
	if E:TableContainsValue(ClassPowers, self.PowerId) then
	
		local SizeX, SizeY
		SizeX = self.Holder:GetWidth() / self.PowerMax
		SizeY = self.Holder:GetHeight()
		
		for i = 1, self.PowerMax do
			if not (self.CurrentPower.Bars[i]) then
				self:CreateSegment(i, SizeX, SizeY)	
			end
			
			if i > self.NumMaxSegments then self.NumMaxSegments = i end
		end
		
	-- One bar
	else
		if not (self.CurrentPower.Bars[1]) then
			self:CreateSegment(1, self.Holder:GetWidth(), self.Holder:GetHeight())	
		end
		
		if 1 > self.NumMaxSegments then self.NumMaxSegments = 1 end
	end
end

function Module:UpdatePowerColor()
	self.CurrentPower.Color = E:GetAltPowerColor(self.PowerId)
end

function Module:UpdateSegments()
	if not self.enabled then return end

	self.PreviousPowerId = (self.PowerId or -1)
	self:UpdateCurrentPowerInfo()
	
	local PowerID = self.PowerId
	local PowerMax = self.PowerMax
	local MaxSegments = self.NumMaxSegments
	local Color = self.CurrentPower.Color
	local VisibilityCondition = self.VisibilityCondition
	local Holder = self.Holder
	
	-- Fix for error that occurs on login but not on reload
	if not PowerID or not PowerMax then Holder:Hide(); return end
	
	if VisibilityCondition and SecureCmdOptionParse(VisibilityCondition) ~= "1" then
		Holder:Hide()
		
		return
	else
		Holder:Show()
	end
	
	--if not self:UpdateHolderVisibility() then return end
	
	-- If we need more segments
	if (E:TableContainsValue(ClassPowers, PowerID) and MaxSegments < PowerMax) or 
		not E:TableContainsValue(ClassPowers, PowerID) and MaxSegments <= 0 then
			self:CreateSegments()
	end
	if (E:TableContainsValue(ClassPowers, PowerID)) then
		self.NumCurrentSegments = GetAltPowerMax(PowerID)
	else
		self.NumCurrentSegments = 1
	end
	
	self:UpdatePowerColor()
	
	-- Hide all that are not needed currently
	local Bars = self.CurrentPower.Bars
	for i = 1, MaxSegments do
		if i <= PowerMax and i <= self.NumCurrentSegments then
			Bars[i]:Show()
			if PowerID ~= 30 then
				if PowerID == 4 then
					Bars[i]:SetBackgroundColor(E:ColorGradient((i / MaxSegments), 0.25, 0, 0, 0.25, 0.25, 0, 0, 0.25, 0))
					Bars[i]:SetOverlayColor(E:ColorGradient((i / MaxSegments), 1, 0.3, 0.3, 1, 1, 0.3, 0.3, 1, 0.3))
				else
					-- Fix for profile swaps, where the color keys would be empty
					if Color and Color[1] then
						Bars[i]:SetBackgroundColor(unpack(self.db.backgroundColor))
						Bars[i]:SetOverlayColor(Color[1], Color[2], Color[3], 1)
					end
				end
			end
		else
			Bars[i]:Hide()
		end
	end
	
	self:RepositionSegments()
		
	-- If Player is DeathKnight, or Monk in Brewmaster Spec, use OnUpdate
	if self.PlayerClass == 6 or (self.PlayerClass == 10 and self.PlayerSpec == 1) then
		
		if self.PlayerClass == 6 then
			self:UpdateRuneColors()
		end
		
		if not self.Holder:GetScript("OnUpdate") then
			self.Holder:SetScript("OnUpdate", function(elapsed)
				Module:UpdateValue()
			end)
		end
	else
		self.Holder:SetScript("OnUpdate", nil)
	end
end

-- Prevent rapid changes in min/max that lead to the bar constantly filling up again for no apparent reason
function Module:UpdateBarMinMax(Bar, Min, Max)
	if (Bar.MaxValue or -1) ~= Max then
		Bar:SetMinMaxValues(Min, Max)
		Bar.MaxValue = Max
	end
end

function Module:UpdateValue()
	if not self.CurrentPower or not self.PowerId or not self.CurrentPower.Bars then return end
	
	-- DeathKnight Runes
	-- those are updated most frequently, so let's handle them first
	if self.PowerId == 5 then
		local InverseCooldown = self.db.data.DEATHKNIGHT_InverseCooldown
		
		for i = 1, self.PowerMax do
			if self.CurrentPower.Bars[i] then
				self.CurrentRuneStart, self.CurrentRuneDuration, self.CurrentRuneReady = GetRuneCooldown(i)
				
				if self.CurrentRuneStart then
					self:UpdateBarMinMax(self.CurrentPower.Bars[i], 0, 100)
					
					if self.CurrentRuneReady then
						self.CurrentPower.Bars[i]:SetValue(100)
					else
						self.CurrentRuneRemaining = self.CurrentRuneDuration - (GetTime() - self.CurrentRuneStart)
						if self.CurrentRuneRemaining > 0 then
							if InverseCooldown then
								self.CurrentPower.Bars[i]:SetValue((100 / self.CurrentRuneDuration) * self.CurrentRuneRemaining)
							else
								self.CurrentPower.Bars[i]:SetValue((100 / self.CurrentRuneDuration) * (self.CurrentRuneDuration - self.CurrentRuneRemaining))
							end	
							
						
						end
					end
				end
			end
		end
		
	-- Soulshard Fragments
	elseif self.PowerId == 7 and self.PlayerSpec == 3 then
		self.CurrentSoulShards = GetAltPower_Warlock()
		
		for i = 1, self.PowerMax do
			
			self:UpdateBarMinMax(self.CurrentPower.Bars[i], 0, 100)
			
			if i <= self.CurrentSoulShards then
				self.CurrentPower.Bars[i]:SetValue(100)
			else
				if i - self.CurrentSoulShards > 0 and i - self.CurrentSoulShards < 1 then
					self.CurrentPower.Bars[i]:SetValue(( 1 - (i - self.CurrentSoulShards)) * 100)
				else
					self.CurrentPower.Bars[i]:SetValue(0)
				end
			end
		end
	else
		self.PowerValue = GetAltPowerValue(self.PowerId) or 3
		
		-- Separated
		if E:TableContainsValue(ClassPowers, self.PowerId) then
			for i = 1, self.PowerMax do
				if self.CurrentPower.Bars[i] then
					self:UpdateBarMinMax(self.CurrentPower.Bars[i], 0, 100)
					
					if i <= self.PowerValue then
						self.CurrentPower.Bars[i]:SetValue(100)
					else
						self.CurrentPower.Bars[i]:SetValue(0)
					end
				end
			end
		-- One bar
		else
			local Bar = self.CurrentPower.Bars[1]
			if Bar then				
				self:UpdateBarMinMax(Bar, 0, GetAltPowerMax(self.PowerId))
				Bar:SetValue(self.PowerValue)
				
				-- For Stagger, also update color based on value
				if self.PowerId == 30 then
					if self.CurrentPower.Color.light then
					--	self:UpdatePowerColor()
						Bar:SetOverlayColor(E:ColorGradient((self.PowerValue / (UnitHealthMax("player") * Data.Monk.Stagger.Percentage)),
							self.CurrentPower.Color.light[1], self.CurrentPower.Color.light[2], self.CurrentPower.Color.light[3],
							self.CurrentPower.Color.medium[1], self.CurrentPower.Color.medium[2], self.CurrentPower.Color.medium[3],
							self.CurrentPower.Color.heavy[1], self.CurrentPower.Color.heavy[2], self.CurrentPower.Color.heavy[3]))
					end
				end
			end
		end
	end
end

-- Sets all required data for Powers that need special handling when it comes to visibility
function Module:UpdateCurrentPowerInfo()
	self.PlayerClass	= select(3, UnitClass("player"))
	self.PlayerSpec 	= GetSpecialization()

	local Class = self.PlayerClass
	local Spec 	= self.PlayerSpec
	local Powers = E.ClassPowers[Class]
	local Power = Powers[Spec]
	
	if Power then
		-- DRUID
		if Class == 11 then
				-- Cat Form [Show Combo Points]
				if SecureCmdOptionParse(Data.CONDITIONS.CATFORM) == "1" then
					self.PowerId = 4
					self.PowerMax = GetAltPowerMax(self.PowerId)
					self.VisibilityCondition = Data.CONDITIONS.CATFORM
					
				-- No Form and Moonkin Form in Balance Spec [Show Mana]
				elseif Spec == 1 and SecureCmdOptionParse(Data.CONDITIONS.NOFORM_MOONKINFORM) == "1" then
					self.PowerId = 0
					self.PowerMax = GetAltPowerMax(self.PowerId)
					self.VisibilityCondition = Data.CONDITIONS.NOFORM_MOONKINFORM
				
				-- Bear Form [Show Mana]
				elseif SecureCmdOptionParse(Data.CONDITIONS.BEARFORM) == "1" then
					self.PowerId = 0
					self.PowerMax = GetAltPowerMax(self.PowerId)
					self.VisibilityCondition = Data.CONDITIONS.BEARFORM
				end

			return
		end
		
		-- PRIEST
		if Class == 5 and Spec == 3 then
				self.PowerId = Power
				self.PowerMax = GetAltPowerMax(self.PowerId)
				self.VisibilityCondition = Data.CONDITIONS.VISIBLE

				return -- We got what we wanted
		end
		
		-- SHAMAN
		if not E.IsRetail then
			if Class == 7 then
				if (self.PlayerSpec == 1 or self.PlayerSpec == 2) then
					self.PowerId = 0
					self.PowerMax = GetAltPowerMax(self.PowerId)
					self.VisibilityCondition = Data.CONDITIONS.NOFORM
				end
				
				return
			end
		end
			
		-- MONK
		if Class == 10 and Spec == 1 then
			self.PowerId = Power
			self.PowerMax = GetAltPowerMax(self.PowerId)
			self.VisibilityCondition = Data.CONDITIONS.VISIBLE
			
			return
		end
		
		-- MAGE ICICLES
		if Class == 8 then
			if Spec == 3 then
				self.PowerId = Power
				self.PowerMax = GetAltPowerMax(self.PowerId)
				self.VisibilityCondition = Data.CONDITIONS.VISIBLE
				
				if not self:IsEventRegistered('UNIT_AURA') then
					self:RegisterEvent('UNIT_AURA', 'player')
				end
				return
			else
				self:UnregisterEvent('UNIT_AURA')
			end
		end
		
		self.PowerId = Power
		self.PowerMax = GetAltPowerMax(self.PowerId)
		self.VisibilityCondition = Data.CONDITIONS.VISIBLE
		
		return
	end
	
	self.PowerId = nil
	self.PowerMax = nil
	self.VisibilityCondition = Data.CONDITIONS.HIDDEN
end

local DEATHKNIGHT_ColorBySpec = {
	[1] = {0.768, 0.121, 0.231},
	[2] = {0.121, 0.541, 0.768},
	[3] = {0.188, 0.631, 0.082}
}
function Module:UpdateRuneColors()
	if self.PowerId ~= 5 then return end
	
	local SpecColor
	if self.db.data.DEATHKNIGHT_ColorBySpec then
		local Spec = GetSpecialization()
		SpecColor = DEATHKNIGHT_ColorBySpec[Spec]
	end
	
	for i = 1, self.PowerMax do
		if self.CurrentPower.Bars[i] then
			_, _, self.RuneColorUpdateIsReady = GetRuneCooldown(i)
			
			if self.RuneColorUpdateIsReady then
				if SpecColor then
					self.CurrentPower.Bars[i]:SetOverlayColor(SpecColor[1], SpecColor[2], SpecColor[3], 1)
				else
					self.CurrentPower.Bars[i]:SetOverlayColor(self.colors.runesReady[1], self.colors.runesReady[2], self.colors.runesReady[3], 1)
				end
			else
				self.CurrentPower.Bars[i]:SetOverlayColor(self.colors.runesNotReady[1], self.colors.runesNotReady[2], self.colors.runesNotReady[3], 1)
			end
		end
	end
end

function Module:__OnEvent(event, ...)

	-- Prevent update when profile was loaded (spec profiles)
	if not self.db.gap then return end
	
	if event == 'UNIT_AURA' and select(1, ...) == 'player' then
		self:UpdateValue()
	end
	
	if self:GetPlayerClassID() ~= 6 then
		if event == "UNIT_POWER_UPDATE" or event == "UNIT_POWER_FREQUENT" or event == "RUNE_POWER_UPDATE" then self:UpdateValue(); return; end
	else
		if event == "RUNE_POWER_UPDATE" then self:UpdateRuneColors() end
	end
	
	if event == "PLAYER_ENTERING_WORLD" or event == "UNIT_DISPLAYPOWER" or event == "PLAYER_SPECIALIZATION_CHANGED" 
		or event == "SPELLS_CHANGED" or event == "UPDATE_SHAPESHIFT_FORM" or event == "PLAYER_LOSES_VEHICLE_DATA" then
		self:UpdateSegments()
		self:UpdateValue()
	end
end

function Module:Disable()
	self:UnregisterAllEvents()
	self.enabled = false

	if self.Holder then
		self.Holder:Hide()
	end
end

function Module:Enable()
	self:InitEventHandler()
	self.enabled = true
	
	if self.Holder then
		self:__OnEvent('PLAYER_ENTERING_WORLD')
	end
end

function Module:InitEventHandler()
	self:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
	self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
	self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
	self:RegisterEvent("RUNE_POWER_UPDATE")
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
	self:RegisterEvent("PLAYER_LOSES_VEHICLE_DATA")
	self:RegisterEvent("SPELLS_CHANGED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	
	self:SetScript("OnEvent", self.__OnEvent)
end

function Module:GetPlayerClassID()
	return select(3, UnitClass("player"))
end

function Module:UpdateDB()
	self.db = CO.db.profile.unitframe.units.player.alternatePower
	
	if not self.colors then self.colors = {} end
	self.colors.runesReady = E:GetAltPowerColor(31)
	self.colors.runesNotReady = E:GetAltPowerColor(32)
end
function Module:__Construct()
	
	self:UpdateDB()
	
	-- Here we store the information about the current power displayed
	self.CurrentPower = {}
	
	-- Number of segments already available/created
	self.NumMaxSegments = -1
	-- Number of segments currently shown
	self.NumCurrentSegments = 1
	
	self:UpdateSeparatedPowers()
	self:CreateHolder()
	self:UpdateSegments()
	self:InitEventHandler()
	
	self:LoadConfig()
end

function Module:Init()
	self:__Construct()
end

E:AddModule("Classpower", Module)