local E, L = unpack(select(2, ...)) -- Engine, Locale
local L, CO, UF = E:LoadModules("Locale", "Config", "Unitframes")
local AP = CreateFrame("Frame")
AP.Autoload = true

AP.E = CreateFrame("Frame")

----------------------------------------------------------
	local select 					= select
	local format 					= string.format
	local pairs 					= pairs
	local UnitClass 				= UnitClass
	local GetSpecialization 		= GetSpecialization
	local UnitHealthMax 			= UnitHealthMax
	local UnitPower 				= UnitPower
	local UnitPowerMax 				= UnitPowerMax
	local UnitStagger 				= UnitStagger
	local WarlockPowerBar_UnitPower = WarlockPowerBar_UnitPower
----------------------------------------------------------

--[[------------------------------------------------
	
	The new AlternatePower module uses an segment
	based method to display powers.
	Every time the max power changes, either
	new segments are being created, or unused
	segments are being hidden.
	No matter which of those cases was done,
	all segments are being repositioned and resized
	to fit the needed space.
	For high powers such as mana, we only use segment #1
	
------------------------------------------------]]--

local AlternatePowers = {4,5,7,9,12,16} -- Supported (separate) power types




local function GetAltPowerValue(id)
	local value
	if id == 30 then
		value = UnitStagger("player")
	elseif id == 7 then
		value = WarlockPowerBar_UnitPower("player")
	else
		value = UnitPower("player", id)
		
	end
	
	return value
end

local function GetAltPowerMax(id)
	local value
	if id == 30 then
		-- Use 1 to 100% of maximum HP for stagger (ID = 30)
		if CO.db.profile.unitframe.units.player.alternatePower.data.monkStaggerMax then
			value = UnitHealthMax("player") * ((CO.db.profile.unitframe.units.player.alternatePower.data.monkStaggerMax / 100) or 0.6)
		else
			value = UnitHealthMax("player") * 0.6
		end
	else
		value = UnitPowerMax("player", id)
	end

	return value
end

function AP:LoadProfile()
	
	self.db = CO.db.profile.unitframe.units.player.alternatePower
	
	if not self.Holder then return end
	self:UpdateSegments() -- To apply various changes
	self:UpdateValue() -- To apply various changes
	
	-- Apply fill direction, border and background config
	local Segment
	for i = 1, self.NumMaxSegments do
		Segment = self.CurrentPower.Bars[i]
		
		Segment.Overlay:SetReverseFill(self.db.reverseFill)
		Segment.Overlay:SetOrientation(self.db.fillOrientation)
		
		Segment:SetBackgroundColor(unpack(self.db.backgroundColor))
		Segment:SetBorderSize(self.db.borderSize)
		Segment:SetBorderColor(self.db.borderColor[1], self.db.borderColor[2], self.db.borderColor[3], self.db.borderColor[4])
		
		Segment.Overlay:SetStatusBarTexture(E.Media:Fetch("statusbar", self.db.barTexture))
	end
	
	self:UpdateRuneColors()
	
	self.Holder:SetSize(self.db.width, self.db.height)
	E:UpdateMoverDimensions(self.Holder)
	
	-- ArtFill
	self.dbFill = self.db.artFill

	if self.dbFill.enable then
		if not self.Holder.artFill then
			E:CreateArtFill(self.Holder)
		end
		-----------------------
		local ArtFill = self.Holder.artFill
		ArtFill:ClearAllPoints()
		ArtFill:SetPoint("TOPLEFT", self.Holder, "TOPLEFT", self.dbFill.paddingX * (-1), self.dbFill.paddingY)
		ArtFill:SetPoint("BOTTOMRIGHT", self.Holder, "BOTTOMRIGHT", self.dbFill.paddingX, self.dbFill.paddingY * (-1))
		
		ArtFill:SetFrameStrata("BACKGROUND")
		ArtFill:SetFrameLevel(1)
		
		ArtFill.Border.SetBorderSize(self.dbFill.borderSize)
		ArtFill.Border:SetBackdropBorderColor(self.dbFill.borderColor[1], self.dbFill.borderColor[2], self.dbFill.borderColor[3], self.dbFill.borderColor[4] or 1)
		ArtFill.Background:SetColorTexture(self.dbFill.backgroundColor[1], self.dbFill.backgroundColor[2], self.dbFill.backgroundColor[3], self.dbFill.backgroundColor[4] or 1)
		
		-----------------------
		ArtFill:Show()
	else
		if self.Holder.artFill then self.Holder.artFill:Hide() end
	end
	
	--self.MonkStaggerMax = CO.db.profile.unitframe.units.player.alternatePower.data.monkStaggerMax
	
end

function AP:CreateHolder()
	--self.Holder = CreateFrame("Frame", "CUI_AlternatePower", E.Parent, "SecureHandlerStateTemplate")
	self.Holder = CreateFrame("Frame", "CUI_AlternatePower", E.Parent)
	self.Holder:SetPoint("CENTER", E.Parent, "CENTER")
	self.Holder:SetSize(self.db.width, self.db.height)
	
	self.Holder:SetFrameStrata("LOW")
	self.Holder:SetFrameLevel(10)
	
	self:UpdateCurrentPowerInfo()
	
	E:SetVisibilityHandler(self.Holder)
	self:UpdateHolderVisibility()
	
	E:CreateMover(self.Holder, L["alternatePower"])
end

function AP:UpdateHolderVisibility()
	--if not InCombatLockdown() then
	--	RegisterStateDriver(self.Holder, "visible", self.VisibilityCondition)
	--end
	
	if self.PowerId == nil then return false else return true end
end

function AP:RepositionSegments()	
	-- Separated
	if E:tableContainsValue(AlternatePowers, self.PowerId) then
		
		local SizeX = ((self.Holder:GetWidth() / self.PowerMax) - self.db.gap) + (self.db.gap / self.PowerMax)
		local SizeY = self.Holder:GetHeight()
		
		for i = 1, self.PowerMax do
			self.CurrentPower.Bars[i]:ClearAllPoints()
			self.CurrentPower.Bars[i]:SetPoint("LEFT", self.Holder, "LEFT", SizeX * (i - 1) + ((i - 1) * (self.db.gap)), 0)
			self.CurrentPower.Bars[i]:SetSize(SizeX, SizeY)
		end
	-- One bar
	else
		self.CurrentPower.Bars[1]:ClearAllPoints()
		self.CurrentPower.Bars[1]:SetPoint("CENTER", self.Holder, "CENTER", 0, 0)
		self.CurrentPower.Bars[1]:SetSize(self.Holder:GetWidth(), self.Holder:GetHeight())
	end
end

function AP:CreateSegment(i, SizeX, SizeY)
	local Segment = E:CreateBar(format("CUI_AlternatePowerSegment%d", i), "LOW", SizeX, SizeY, {"LEFT", self.Holder, "LEFT", SizeX * (i - 1) + ((i - 1) * (5)), 0}, self.Holder, nil, nil, nil, nil)
	self.CurrentPower.Bars[i] = Segment
	
	Segment:SetFrameStrata("LOW")
	Segment:SetFrameLevel(9)
	Segment:SetBackgroundColor(unpack(self.db.backgroundColor))
	Segment:SetBorderSize(self.db.borderSize)
	Segment:SetBorderColor(self.db.borderColor[1], self.db.borderColor[2], self.db.borderColor[3], self.db.borderColor[4])
	Segment.Overlay:SetStatusBarTexture(E.Media:Fetch("statusbar", self.db.barTexture))
	Segment:SetMinMaxValues(0, 100)
end

function AP:CreateSegments()

	if not self.CurrentPower.Bars then self.CurrentPower.Bars = {} end
	
	-- Separated
	if E:tableContainsValue(AlternatePowers, self.PowerId) then
	
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

function AP:UpdateSegments()
	
	self.PreviousPowerId = (self.PowerId or -1)
	self:UpdateCurrentPowerInfo()
	
	-- Fix for error that occurs on login but not on reload
	if not self.PowerId or not self.PowerMax then self.Holder:Hide(); return end
	
	if self.VisibilityCondition and SecureCmdOptionParse(self.VisibilityCondition) ~= "1" then
		self.Holder:Hide()
		
		return
	else
		self.Holder:Show()
	end
	
	--if not self:UpdateHolderVisibility() then return end
	
	if (E:tableContainsValue(AlternatePowers, self.PowerId) and self.NumMaxSegments < self.PowerMax) or 
		not E:tableContainsValue(AlternatePowers, self.PowerId) and self.NumMaxSegments <= 0 then
			self:CreateSegments()
	end
	if (E:tableContainsValue(AlternatePowers, self.PowerId)) then
		self.NumCurrentSegments = GetAltPowerMax(self.PowerId)
	else
		self.NumCurrentSegments = 1
	end
	
	self.CurrentPower.Color = E:GetAltPowerColor(self.PowerId)
	
	-- Hide all that are not needed currently
	for i = 1, self.NumMaxSegments do
		if i <= self.PowerMax and i <= self.NumCurrentSegments then
			self.CurrentPower.Bars[i]:Show()
			if self.PowerId ~= 30 then
				self.CurrentPower.Bars[i]:SetOverlayColor(self.CurrentPower.Color[1], self.CurrentPower.Color[2], self.CurrentPower.Color[3], 1)
			end
		else
			self.CurrentPower.Bars[i]:Hide()
		end
	end
	
	self:RepositionSegments()
		
	-- If Player is DeathKnight or Monk in Brewmaster Spec, use OnUpdate
	if self.PlayerClass == 6 or (self.PlayerClass == 10 and self.PlayerSpec == 1) then
		
		if self.PlayerClass == 6 then
			self:UpdateRuneColors()
		end
		
		if not self.Holder:GetScript("OnUpdate") then
			self.Holder:SetScript("OnUpdate", function(elapsed)
				AP:UpdateValue()
			end)
		end
	else
		self.Holder:SetScript("OnUpdate", nil)
	end
end

-- Prevent rapid changes in min/max that lead to the bar constantly filling up again for no reason
function AP:UpdateBarMinMax(Bar, Min, Max)
	if (Bar.MaxValue or -1) ~= Max then
		Bar:SetMinMaxValues(Min, Max)
		Bar.MaxValue = Max
	end
end

function AP:UpdateValue()
	if not self.CurrentPower or not self.PowerId or not self.CurrentPower.Bars then return end
	
	-- DeathKnight Runes
	if self.PowerId == 5 then
		for i = 1, self.PowerMax do
			if self.CurrentPower.Bars[i] then
				self.CurrentRuneStart, self.CurrentRuneDuration, self.CurrentRuneReady = GetRuneCooldown(i)
				
				self:UpdateBarMinMax(self.CurrentPower.Bars[i], 0, 100)
				
				if self.CurrentRuneReady then
					self.CurrentPower.Bars[i]:SetValue(100)
				else
					self.CurrentRuneRemaining = self.CurrentRuneDuration - (GetTime() - self.CurrentRuneStart)
					if self.CurrentRuneRemaining > 0 then
						self.CurrentPower.Bars[i]:SetValue((100 / self.CurrentRuneDuration) * self.CurrentRuneRemaining)
					end
				end
			end
		end
		
	-- Soulshard Fragments
	elseif self.PowerId == 7 and self.PlayerSpec == 3 then
		self.CurrentSoulShards = WarlockPowerBar_UnitPower("player")
		
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
		self.PowerValue = GetAltPowerValue(self.PowerId) or 0
		
		-- Separated
		if E:tableContainsValue(AlternatePowers, self.PowerId) then
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
				
				-- For Stagger, also update color
				if self.PowerId == 30 then
					Bar.SetOverlayColor(E:ColorGradient((self.PowerValue / (UnitHealthMax("player") * 0.6)),
						self.CurrentPower.Color.light[1], self.CurrentPower.Color.light[2], self.CurrentPower.Color.light[3],
						self.CurrentPower.Color.medium[1], self.CurrentPower.Color.medium[2], self.CurrentPower.Color.medium[3],
						self.CurrentPower.Color.heavy[1], self.CurrentPower.Color.heavy[2], self.CurrentPower.Color.heavy[3]))
				end
			end
		end
	end
end

-- Sets all required data for Powers that need special handling when it comes to visibility
function AP:UpdateCurrentPowerInfo()
	self.PlayerClass	= select(3, UnitClass("player"))
	self.PlayerSpec 	= GetSpecialization()
	
	for k,v in pairs(E.ClassPowers) do
		if k == self.PlayerClass then
		
			-- DRUID
			if k == 11 then
					-- Cat Form [Show Combo Points]
					if SecureCmdOptionParse("[form:2] 1;0") == "1" then
						self.PowerId = 4
						self.PowerMax = GetAltPowerMax(self.PowerId)
						self.VisibilityCondition = "[form:2] 1;0"
						
					-- No Form and Moonkin Form in Balance Spec [Show Mana]
					elseif self.PlayerSpec == 1 and SecureCmdOptionParse("[noform] 1;[form:4] 1;0") == "1" then
						self.PowerId = 0
						self.PowerMax = GetAltPowerMax(self.PowerId)
						self.VisibilityCondition = "[noform] 1;[form:4] 1;0"
					
					-- Bear Form [Show Mana]
					elseif SecureCmdOptionParse("[form:1] 1;0") == "1" then
						self.PowerId = 0
						self.PowerMax = GetAltPowerMax(self.PowerId)
						self.VisibilityCondition = "[form:1] 1;0"
					end

				break
			end
			
			-- PRIEST
			if v[self.PlayerSpec] then
				if E:tableContainsValue(AlternatePowers, v[self.PlayerSpec]) or
					(self.PlayerClass == 5 and (self.PlayerSpec == 3)) then
					
						self.PowerId = v[self.PlayerSpec]
						self.PowerMax = GetAltPowerMax(self.PowerId)
						self.VisibilityCondition = "1"

						break -- We got what we wanted
				end
			end
			
			-- SHAMAN
			if (k == 7 and (self.PlayerSpec == 1 or self.PlayerSpec == 2)) then
				self.PowerId = 0
				self.PowerMax = GetAltPowerMax(self.PowerId)
				self.VisibilityCondition = "[noform] 1;0"
				
				break
			end
				
			-- MONK
			if k == 10 and self.PlayerSpec == 1 then
				self.PowerId = v[self.PlayerSpec]
				self.PowerMax = GetAltPowerMax(self.PowerId)
				self.VisibilityCondition = "1"
				
				break
			end
			
			self.PowerId = nil
			self.PowerMax = nil
			self.VisibilityCondition = "0"
		end
	end
end

function AP:UpdateRuneColors()
	if self.PowerId ~= 5 then return end
	
	for i = 1, self.PowerMax do
		if self.CurrentPower.Bars[i] then
			_, _, self.RuneColorUpdateIsReady = GetRuneCooldown(i)
			
			if self.RuneColorUpdateIsReady then
				self.CurrentPower.Bars[i].SetOverlayColor(self.colors.runesReady[1], self.colors.runesReady[2], self.colors.runesReady[3], 1)
			else
				self.CurrentPower.Bars[i].SetOverlayColor(self.colors.runesNotReady[1], self.colors.runesNotReady[2], self.colors.runesNotReady[3], 1)
			end
		end
	end
end

function AP:__OnEvent(event, ...)
	if select(3, UnitClass("player")) ~= 6 then
		if event == "UNIT_POWER_UPDATE" or event == "UNIT_POWER_FREQUENT" or event == "RUNE_POWER_UPDATE" then self:UpdateValue() end
	else
		if event == "RUNE_POWER_UPDATE" then self:UpdateRuneColors() end
	end
	
	if event == "PLAYER_ENTERING_WORLD" or event == "UNIT_DISPLAYPOWER" or event == "PLAYER_SPECIALIZATION_CHANGED" 
		or event == "SPELLS_CHANGED" or event == "UPDATE_SHAPESHIFT_FORM" or event == "PLAYER_LOSES_VEHICLE_DATA" then
		self:UpdateSegments()
		self:UpdateValue()
	end
end

function AP:InitEventHandler()
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

function AP:__Construct()
	self.db = CO.db.profile.unitframe.units.player.alternatePower
	self.colors = {}
	self.colors.runesReady = E:GetAltPowerColor(31)
	self.colors.runesNotReady = E:GetAltPowerColor(32)
	
	-- Here we store the information about the current power displayed
	self.CurrentPower = {}
	
	self.NumMaxSegments = -1
	self.NumCurrentSegments = 1
	
	self:CreateHolder()
	self:UpdateSegments()
	self:InitEventHandler()
	
	self:LoadProfile()
end

function AP:Init()
	self:__Construct()
end

E:AddModule("Alternate_Power", AP)