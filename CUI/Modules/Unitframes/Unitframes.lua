local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF, TT = E:LoadModules("Config", "Unitframes", "Tooltip")

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
local DEAD 								= DEAD
local FRIENDS_LIST_OFFLINE 				= FRIENDS_LIST_OFFLINE
-----------------------------------------------------------------------------

UF.Modules = {}

UF.UNITFRAMES_RANGE_UPDATE 					= 0.5 -- Range update frequency in seconds
local UseNewGroupSystem = true
UF.UseNewGroupSystem = UseNewGroupSystem


-- Affected = Source
local Targets = {
	targettarget = {"target"},
	focustarget = {"focus"},
}
local PeriodicUnitUpdate = CreateFrame("Frame", "CUI_PeriodicUnitframeUpdater")

UF.HolderVisibilityOverride = false

UF.ToCreate = {["arena"] = 5,["party"] = 5,["boss"] = 5,["raid"] = 20,["raid40"] = 40, ["maintank"] = 5}

function UF:UnitExists(unit)
	return unit and (UnitExists(unit) or ShowBossFrameWhenUninteractable(unit))
end

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
	Frame.hideStatusOnTooltip = nil
	
	if State == true then
		Frame:SetScript('OnEnter', UnitFrame_OnEnter)
		Frame:SetScript('OnLeave', UnitFrame_OnLeave)
		
		if not InCombatLockdown() or not Frame:IsProtected() then
			Frame:EnableMouse(true)
		end
	else
		Frame:SetScript('OnEnter', nil)
		Frame:SetScript('OnLeave', nil)
		
		if not InCombatLockdown() or not Frame:IsProtected() then
			Frame:EnableMouse(false)
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------
-- Refactor prototype
-------------------------------------------------------------------------------------------------------------------------------------

	----------------------------------------------------------
	-- Profile handler
	----------------------------------------------------------	
	local function ApplyUFConfig(self, limit, arg2)
		-- Needed when tthis is called through PerformForUnits
		if arg2 then limit = arg2 end
		
		if not self then return end
		local Config = UF.db.units[self.ConfigKey]
		
		limit = limit or "all"
		if limit == "fonts" or limit == "all" then
			self.Fonts:UpdateConfig(Config)
			-- Limit update to this module
			if limit == "fonts" then return end
		end
		
		if not Config.enable then
			-- @TODO: If is NOT clustered
			if not UF.ToCreate[self.ConfigKey] then
				self.ForceMoverEnabled = false
			end
		
			if not InCombatLockdown() then
				UnregisterUnitWatch(self)
				self:Hide()
			end
			
			return
		else
			if not UF.ToCreate[self.ConfigKey] then
				self.ForceMoverEnabled = nil
			end
			
			-- All we had to do to fully fix grouped toggles was to check for forceShow here...
			if not InCombatLockdown() and not self.isForcedShown then
				RegisterUnitWatch(self)
			end
		end
			
			if self.unit == "player" or self.unit == "target" then
				Config.power.fastUpdate = true
			end
		
		-- Player specific
			if self.ConfigKey == "player" then
				E:LoadModule("Classpower"):LoadConfig()
			end
		
		-- Override range update frequency
			self.RangeUpdateFrequency = 0.25
			
			self.enableRangeIndicator = Config.rangeIndicator
			
		-- Override range indicator
			if not Config.rangeIndicator then
				UF:RemoveRangeIndicator(self)
			else
				UF:AddRangeIndicator(self)
			end
		
		-- Update Mover
			E:UpdateMoverDimensions(self)
	end
	UF.ApplyUFConfig = ApplyUFConfig

	-- Loads config for all existing unitframes, except when limit is specified
	-- 
	function UF:LoadConfig(limit, onlyInitialize)
		if not CO.db.char.unitframe.enable then return end
	
		local WriteLoaded
		if limit and type(limit) == 'table' and not limit.LoadedConfigs then
			limit.LoadedConfigs = {}
			WriteLoaded = true
		end
		
		-- Load individual unitframe settings
		if not limit then
			for ModuleName, Module in pairs(self.Modules) do
				if ModuleName ~= "Auras" and Module.LoadConfig and (((limit and onlyInitialize and not limit.LoadedConfigs[ModuleName]) or not onlyInitialize) or limit) then
					Module:LoadConfig()
					
					if type(limit) == 'table' then
						limit.LoadedConfigs[ModuleName] = true
					end
				end
			end
		elseif type(limit) == 'table' then
			for ModuleName, Module in pairs(self:GetRegisteredModulesForUnitframe(limit)) do
				if self.Modules[ModuleName] then
					self.Modules[ModuleName]:LoadConfig(limit)
				end
			end
		end
		for _, frames in pairs(UF.Frames) do
			for _, frame in pairs(frames) do
				if frame.UpdateConfig then
					-- Somehow, this passes frames that are nil??
					frame:UpdateConfig(limit)
				end
			end
		end
		
		if (limit and (onlyInitialize and not limit.LoadedConfigs['Auras']) or not onlyInitialize) or not limit then
			self.Modules['Auras']:LoadConfig(limit)
		end
		
		PeriodicUnitUpdate.UpdateFrequency = self.db.periodicUnitUpdateFrequency
	end

	function UF:HasFrameKeyHeader(Key)
		if self.RegisteredHeaderClusters[Key] then
			return true
		end
	end
	function UF:GetUFMover(type)
		if type == "raid" or type == "raid40" or type == "party" or type == "boss" or type == "arena" or type == "maintank" then
			return E:GetMover(self:GetHolder(type))
		else
			if self.Frames[type] then
				return E:GetMover(self.Frames[type][1])
			else
				return false
			end
		end
	end
	
	function UF:IsUnitGrouped(Unit)
		if not Unit then return end
		
		for Compare, _ in pairs(UF.ToCreate) do
			if Unit:find(Compare) then
				return true
			end
		end
	end
	
	function UF:GetUnitframe(Unit)
		if self.Frames[Unit] then
			return self.Frames[Unit][Index or 1]
		end
		
		-- Scan frame metatable for this unit
		for ConfigKey, Frames in pairs(self.Frames) do
			for Index, Frame in pairs(Frames) do
				if (ConfigKey .. Index) == Unit then
					return Frame
				end
			end
		end
	end
	
	-- To iterate a function over every unitframe of a specified unit type
	function UF:PerformForUnits(Unit, Function, ...)
		if self.Frames[Unit] then
			local NumFrames = #self.Frames[Unit]
			for Index, Frame in pairs(self.Frames[Unit]) do
				Function(Unit .. (NumFrames > 1 and Index or ""), Frame, ...)
			end
		else
			Function(Unit, self:GetUnitframe(Unit), ...)
		end
	end
	
	local function LoadConfigForSingle(Unit, ...)
		local Frame = UF:GetUnitframe(Unit)
		if not Frame then return end
		
		if Frame.UpdateConfig then
			Frame.UpdateConfig(...)
		end
	end
	function UF:LoadProfileForUnits(Unit, Limit)
		self:PerformForUnits(Unit, LoadConfigForSingle, Limit)
	end
	
	----------------------------------------------------------
	-- Update handlers
	----------------------------------------------------------

		-- This gets called by the OnEvent handler, which basically fires whenever a frame shows up and is missing data.
		-- The OnUpdate handler handles the periodic update calls for units we do not receive any events for. (targettarget, focustarget etc.)
		-- Every other update is performed by the individual modules
		local function UF_Update(self, event, unit, ...)
			--print("Updating for ", self.unit, self:GetName())
			-- Instead of "UnitExists". Bugfix for "No Chambers displayed at Mother (Uldir)"
			if not UF:UnitExists(self.unit) then return end
				
				-- Base modules that definetely exist
				if self.Health then
					self.Health:ForceUpdate()
					if self.Health.Absorb then
						self.Health.Absorb:ForceUpdate()
					end
				end
				if self.HealPrediction then
					self.HealPrediction:ForceUpdate()
				end
				if self.Power then
					self.Power:ForceUpdate()
				end
				if self.AltPower then
					self.AltPower:ForceUpdate()
				end
				if self.Fonts then
					self.Fonts:ForceUpdate()
				end
				
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
					if self.Threat then
						self.Threat:ForceUpdate()
					end
				end
				
				if UnitIsConnected(self.unit) then
					UF:AddRangeIndicator(self)
				else
					UF:RemoveRangeIndicator(self)
					self:SetAlpha(0.5)
					UF:UpdateBarColor(self.Health, nil, 0.5, 0.5, 0.5)
				end
		end

		function UF:UpdateAllUF()
			for k, frames in pairs(self.Frames) do
				for _, frame in pairs(frames) do
					-- Header Unitframes don't have this
					if frame.ForceUpdate then
						frame:ForceUpdate()
					end
				end
			end
			
			UF.Modules['AltPower']:LoadConfig()
			E:LoadModule("Classpower"):LoadConfig()
		end
		
		function UF:UpdateGroup(group)
			for k, frame in pairs(self.Frames) do
				if frame.ConfigKey == group then
					frame:ForceUpdate()
				end
			end
		end
		
		-- Initializes unit events and generally sets everything up
		function UF:InitializeUnitEvents(F)
			if F.Eventless then return end
			
			local Unit = F.unit
			local RawUnit, UnitNum = F.RawUnit, F.UnitNum
			
			-- When the unit turns hostile/friendly or whatever
				F:RegisterUnitEvent("UNIT_FACTION", Unit)
				F:RegisterUnitEvent("UNIT_FLAGS", Unit)
				
			-- Events that handle situations in which we have to update the unitframe
				if Unit == "target" or Unit == "targettarget" then
					F:RegisterEvent("PLAYER_TARGET_CHANGED")
				elseif Unit == "focus" or Unit == "focustarget" then
					F:RegisterEvent("PLAYER_FOCUS_CHANGED")
				elseif RawUnit == "party" or RawUnit == "raid" then
					F:RegisterEvent("GROUP_ROSTER_UPDATE")
					F:RegisterEvent("UPDATE_INSTANCE_INFO")
				elseif RawUnit == "boss" then
					F:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
				end
			
				if Unit ~= "player" then
					F:RegisterUnitEvent("UNIT_CONNECTION", Unit)
					F:RegisterUnitEvent("UNIT_PET", Unit)
				end
				
				if not Unit:match('%w+target') then
					F:RegisterUnitEvent('UNIT_ENTERED_VEHICLE', Unit)
					F:RegisterUnitEvent('UNIT_EXITED_VEHICLE', Unit)
					
					if Unit ~= "player" and Unit ~= "pet" then
						F:RegisterUnitEvent('UNIT_PET', Unit)
					end
					
					F:RegisterUnitEvent("UNIT_NAME_UPDATE", Unit) -- Probably the only reliable way to update when every dataset is ready
					
					F.UnitButton:SetAttribute('toggleForVehicle', true) -- Doesn't work for some reason?
					F.UnitButton:HookScript("OnAttributeChanged", function(self, attrName, value)		
						if attrName == 'unit' then
							--print("Attr changed:", self:GetName(), attrName, value)
							UpdateUnit(self.Owner, value)
							self.Owner:ForceUpdate()
						end
					end)
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
		end
		
		-- We need to use this to update modules reliant on unit events whenever the active unit changes
		function UF:UpdateModuleUnits(Unitframe)
			for ModuleName, Module in pairs(self:GetRegisteredModulesForUnitframe(Unitframe)) do
				if Module.UpdateUnit then
					Module:UpdateUnit()
				end
			end
		end
		
		local function UpdateUnit(self)
			local realUnit, modUnit = SecureButton_GetUnit(self.UnitButton), SecureButton_GetModifiedUnit(self.UnitButton)
			
			--print("Pre", modUnit, realUnit)
			
			if(realUnit == 'playerpet') then
				realUnit = 'pet'
			elseif(realUnit == 'playertarget') then
				realUnit = 'target'
			end

			if(modUnit == 'pet' and realUnit ~= 'pet') then
				modUnit = 'vehicle'
			end
			
			--print("Post", modUnit, realUnit)
			
			--print("ModUnit for Frame", self:GetName(), ": ", modUnit, " Unit:", unit)
			
			if(not UF:UnitExists(modUnit)) then return end
			
			
			
			self.UnitButton.unit 	= modUnit
			self.UnitButton.unit 	= modUnit
			self.unit				= modUnit
			
			--print("New unit for", self:GetName(), "is", modUnit)
			
			--if self.Castbar then
				--if unit == 'player' then
					--UF.Modules.Castbar:UpdateBarUnit(self.Castbar, modUnit)
				--end
			--end
			
			UF:UpdateModuleUnits(self)
			
			return true
		end

	----------------------------------------------------------
	-- OnEvent handler
	----------------------------------------------------------
		
		local function UnitFrame_ForceUpdate(self)
			UpdateUnit(self)
			UF_Update(self, "ForceUpdate")
		end
		
		local function UnitFrame_OnPetStateChanged(self, unit)
			unit = unit or self.unit
			
			local petUnit
			if(unit == 'target') then
				return
			elseif(unit == 'player') then
				petUnit = 'pet'
			else
				-- Convert raid26 -> raidpet26
				petUnit = unit:gsub('^(%a+)(%d+)', '%1pet%2')
			end

			if(self.unit ~= petUnit) then return end
			
			if UpdateUnit(self) then
				return true
			end
		end
		
		local function UnitFrame_OnEvent(self, event, unit, ...)
			-- We cannot check the event unit like this, as UnitIsUnit returns false for (player, vehicle) when exiting a vehicle (obviously)
			--if unit and not UnitIsUnit(unit, self.unit) then return end
			if (event == 'UNIT_ENTERED_VEHICLE' or event == 'UNIT_EXITED_VEHICLE') then
				--print(event, unit, self.unit, unit and unit ~= self.unit, self:GetName())
			end
			
			-- This prevents us from changing back to the original unit when coming from vehicle(s)
			--if unit and unit ~= self.unit then return end
			
			if event == 'UNIT_PET' then
				if not UnitFrame_OnPetStateChanged(self, unit) then
					return
				end
			end
			
			if (event == 'UNIT_ENTERED_VEHICLE' or event == 'UNIT_EXITED_VEHICLE') then
				UpdateUnit(self)
			end
			
			--print("Firing update for", self:GetName(), "Unit: ", unit)
			UF_Update(self, event, unit, ...)
		end
		
		local function UnitFrame_OnShow(self)
			if self.RangeIndicator and self.enableRangeIndicator then
				UF:AddRangeIndicator(self)
			end
			UnitFrame_ForceUpdate(self)
		end
		local function UnitFrame_OnHide(self)
			if self.RangeIndicator then
				UF:RemoveRangeIndicator(self)
			end
		end

	----------------------------------------------------------
	-- Methods to create UF modules
	----------------------------------------------------------
		function UF:CreateUFBar(F, Name, HasBorder)
			local B
			if not HasBorder then
				B = CreateFrame("Statusbar", Name or nil)
			else
				B = E:CreateBackdropFrame("Statusbar", Name or nil)
			end
			if F then
				B:SetAllPoints(F)
			else
				B:SetSize(150, 15)
			end
			
			B:SetParent(F or E.Parent)

			B:SetMinMaxValues(0, 100)
			B:SetValue(50)
			B:SetStatusBarTexture(E.Media:Fetch("statusbar", self.db.units.all.barTexture))

			E:RegisterStatusBar(B)

			return B
		end
		
		local function Font_OnEvent(self, event, ...)
			if self.Parent.OnEvent then
				self.Parent:OnEvent(event, ...)
			end
		end
		
		function UF:CreateOverlayFrames(Unitframe, OverlayName, TextOverlayName)
			Unitframe.Overlay = CreateFrame("Frame", OverlayName or "CUI_UnitOverlay", Unitframe)
			Unitframe.Overlay:SetFrameLevel(Unitframe.Overlay:GetFrameLevel() + 1)
			Unitframe.Overlay:SetAllPoints(Unitframe)
			
			Unitframe.TextOverlay = CreateFrame("Frame", TextOverlayName or "CUI_UnitTextOverlay", Unitframe.Overlay)
			Unitframe.TextOverlay:SetFrameLevel(Unitframe.TextOverlay:GetFrameLevel() + 10)
			Unitframe.TextOverlay:SetAllPoints(Unitframe.Overlay)
		end
		
		function UF:UpdateRangeIndicatorState(Unitframe)
			if UnitIsConnected(Unitframe.unit) then
				self:AddRangeIndicator(Unitframe)
			else
				self:RemoveRangeIndicator(Unitframe)
				Unitframe:SetAlpha(0.5)
				self:UpdateBarColor(Unitframe.Health, nil, 0.5, 0.5, 0.5)
			end
		end
		
		function UF:LoadAllUnitframeModules(Unitframe)
			if not Unitframe.Health then return end
			
			-- Update existing modules with ForceUpdate method
			for _, module in pairs(self:GetRegisteredModulesForUnitframe(Unitframe)) do
				if module.ForceUpdate then
					module:ForceUpdate(true)
				end
			end
			
			self:UpdateRangeIndicatorState(Unitframe)
			--Unitframe:RefreshFontStrings()
			--Unitframe:UpdateFonts()
		end
		
		function UF:HasUnitframeModule(Unitframe, ModuleName)
			if not Unitframe.LoadedModules then Unitframe.LoadedModules = {} return false end
			return E:TableContainsValue(Unitframe.LoadedModules, ModuleName)
		end
		
		function UF:RegisterModule(Name, Module, PreventAddingToUnitframe)
			-- assert((Module.IncludeUnits and type(Module.IncludeUnits) ~= 'table') or (Module.ExcludeUnits and type(Module.ExcludeUnits) ~= 'table')),
				-- format("Module '%s': 'IncludeUnits' or 'ExcludeUnits' of the wrong data type. It MUST be a table!", Name)
			-- )
			-- assert(Module.IncludeUnits and Module.ExcludeUnits,
				-- format("Module '%s': Has a List of compatible units AND an exclusion list. Only one of them is allowed!", Name)
			-- )
			
			if (Module.IncludeUnits and type(Module.IncludeUnits) ~= 'table') or (Module.ExcludeUnits and type(Module.ExcludeUnits) ~= 'table') then
				error(("Module %s has a variable 'IncludeUnits' or 'ExcludeUnits' of the wrong data type. It MUST be a table!"):format(Name))
				return
			end
			if (Module.IncludeUnits and Module.ExcludeUnits) then
				error(("Module %s has a List of compatible units AND an exclusion list. Only one of them is allowed!"):format(Name))
				return
			end
			
			-- Only for edge cases, but why not
			Module.PreventAddingToUnitframe = PreventAddingToUnitframe
			Module.Name = Name

			-- Add AceEvent to module
			Module.RegisterEvent = E.RegisterEvent
			Module.UnregisterEvent = E.UnregisterEvent
			
			self.Modules[Name] = Module
			Module.db = self.db
		end
		
		function UF:IsKeyEligibleForModule(ConfigKey, ModuleName)
			local Module = self.Modules[ModuleName]
			
			assert(Module, format("Module '%s' does not exist!", ModuleName))
			assert(not Module.PreventAddingToUnitframe, format("Module '%s' cannot be added to unitframes!", ModuleName))
			
			local IsAllowed = false
			
			-------------------------
			
			-- Only allow specific units to own this module
			-- tables 'IncludeUnits' and 'ExcludeUnits' consist of config key values like 'player' or 'raid40' without any individual suffix
			-- If not specified every unit is allowed
			
			if Module.IncludeUnits then
				if E:TableContainsValue(Module.IncludeUnits, ConfigKey) then
					IsAllowed = true
				end
			elseif Module.ExcludeUnits then
				if not E:TableContainsValue(Module.ExcludeUnits, ConfigKey) then
					IsAllowed = true
				end
			end
			if not Module.IncludeUnits and not Module.ExcludeUnits then
				IsAllowed = true
			end
			
			
			return IsAllowed
		end
		
		function UF:AddModule(Object, ModuleName)
			local Module = self.Modules[ModuleName]
			
			assert(Module, format("Module '%s' does not exist!", ModuleName))
			assert(not Module.PreventAddingToUnitframe, format("Module '%s' cannot be added to unitframes!", ModuleName))
			
			if not Object.LoadedModules then Object.LoadedModules = {} end
			
			local IsAllowed = self:IsKeyEligibleForModule(Object.ConfigKey, ModuleName)
			
			-------------------------
			
			-- Check if this module requires any dependencies
			
			if Module.Dependencies then
				for _, Dependency in pairs(Module.Dependencies) do
					if not self:HasUnitframeModule(Object, Dependency) then
						error(("ERROR: Unitframe Module '%s' could not have been added to %s, as it's missing the dependency module '%s'!"):format(ModuleName, Object.unit, Dependency))
						IsAllowed = false
					end
				end
			end
			
			-------------------------
			
			if IsAllowed then
				Module:Create(Object)
				tinsert(Object.LoadedModules, ModuleName)
			end
		end
		
		function UF:GetRegisteredModulesForUnitframe(Object)
			local Ret = {}
			
			if Object.LoadedModules then
				for _, ModuleName in pairs(Object.LoadedModules) do
					if Object[ModuleName] then
						Ret[ModuleName] = Object[ModuleName]
					end
				end
			end
			
			return Ret
		end
		
		-- Return the actual DB key for the specified unit
		function UF:GetConfigKey(Unit, RawUnit, Index)
			RawUnit = RawUnit or E:ExtractDigits(Unit)

			-- Add Unitframe to register
			if Index then
				return RawUnit .. Index
			else
				return RawUnit
			end
		end
		
		-- Returns the unitframe module attachment frame/module and checks if there are any issues
		function UF:GetModuleAttachmentFrame(Module)
			assert(Module.Owner, format("Module '%s' has no specified element owner (.Owner)!", Module:GetName()))
			
			local OtherModule
			if Module.AttachTo then
				-- Attached module exists within the unitframe
				OtherModule = Module.Owner[Module.AttachTo]
				if OtherModule then
					if not OtherModule.AttachTo or (OtherModule.AttachTo and OtherModule.AttachTo ~= Module.AttachTo) then
						return OtherModule
					elseif OtherModule.AttachTo and OtherModule.AttachTo ~= Module.AttachTo then
						E:print("The attachment point of " .. Module:GetName() .. " is creating a parenting loop with " .. OtherModule:GetName() .. "!")
					end
				end
			end
			
			return Module.Owner
		end
		
		function UF:RegisterUpdateFunction(Frame)
			Frame.UpdateConfig = ApplyUFConfig
		end
		
		function UF:RegisterForClique(Frame)
			if not Frame.RegisterForClicks then return end
			if not _G.ClickCastFrames then
				_G.ClickCastFrames = ClickCastFrames or {}
			end
			
			ClickCastFrames[Frame] = true
		end
		
		UF.ModulesAddOrder = {
			[1] = 'Health',
			[2] = 'HealthAbsorb',
			[3] = 'HealPrediction',
			[4] = 'Power',
			[5] = 'Portrait',
			[6] = 'Auras',
			[7] = 'RoleIndicator',
			[8] = 'Highlight',
			[9] = 'TargetHighlight',
			[10] = 'ResurrectIndicator',
			[11] = 'LeaderIcon',
			[12] = 'TargetIcon',
			[13] = 'Threat',
			[14] = 'SummonIndicator',
			[15] = 'ReadyCheckIndicator',
			[16] = 'AltPower',
			[17] = 'RestingIndicator',
			[18] = 'CombatIndicator',
			[19] = 'Castbar',
			[20] = 'Fonts',
		}
		
		function UF:AddModulesToUnitframe(Unitframe)
			-- Add modules
			for _, Name in ipairs(self.ModulesAddOrder) do
				self:AddModule(Unitframe, Name)
			end
		end

	----------------------------------------------------------
	-- Method to create a UnitFrame
	----------------------------------------------------------
	UF.Frames = {}
	-- @PARAM
	--	Unit: The actual unit of the unitframe. This will also be used as the config key
	function UF:Create(Unit)
		local RawUnit, UnitNum = E:ExtractDigits(Unit)
		local FrameName = format("CUI_%s", Unit)
		local F = CreateFrame("Frame", FrameName, E.Parent)
		
		-- The table key we use to work with this frame's configs
		
			F.ConfigKey = self:GetConfigKey(nil, RawUnit)

		-- Add Unitframe to registered pool
		
			if not self.Frames[F.ConfigKey] then
				self.Frames[F.ConfigKey] = {}
			end
			tinsert(self.Frames[F.ConfigKey], F)		
		
		-- Overlay we add stuff like fonts to, so they're showing up above the bars
			
			self:CreateOverlayFrames(F)
	
		-- Unit button to interact with, since this requires a secure frame. 
		
			F.UnitButton = CreateFrame("Button", format("CUI_UF_%s", E:firstToUpper(Unit)), F.Overlay, "SecureUnitButtonTemplate")
			F.UnitButton:SetAllPoints(F.Overlay)
			F.UnitButton:EnableMouse(true)
			F:SetIgnoreParentAlpha(true)
			
		-- Auto-hide in petbattles. This only parents the base frame to a secure state handlers.
		
			E:HandleFrameInPetBattles(F)
		
		-- For '*target' units, we have to use an onupdate handler, since we don't get any events for them
			if Unit:match('%w+target') then
				F.Eventless = true
				tinsert(PeriodicUnitUpdate, F)
			end
			
		-- Make sure frames are properly ordered
		
			F.UnitButton:SetFrameLevel(10)
			F.Overlay:SetFrameLevel(10)

		-- Set unit
			F.unit 				= Unit
			F.unit 				= Unit
			F.RawUnit 			= RawUnit
			F.UnitNum 			= tonumber(UnitNum)
			F.UnitButton.unit 	= Unit
			F.UnitButton.Owner 	= F
			F.Overlay.unit 		= Unit
			F.BackupUnit 		= Unit -- In case the dummy mode is enabled, we have to use this one

		-- Add UF Modules
			
			self:AddModulesToUnitframe(F)

		-- Set Required attributes
		
			F:SetAttribute("unit", Unit)
			F.UnitButton:SetAttribute("unit", Unit)

		-- Set hover script
		
			self:SetHoverScript(F.UnitButton, true)

		-- Set interaction attributes
		
			F.UnitButton:RegisterForClicks("AnyUp")
			F.UnitButton:SetAttribute("type1", "target")
			F.UnitButton:SetAttribute("*type2", "togglemenu")
			
			-- Ability to shift-click a unitframe to set it as focus
			F.UnitButton:SetAttribute("shift-type1", "focus")
			
			-- Shift-clicking the focus unitframe removes focus
			if Unit == "focus" then
				F.UnitButton:SetAttribute("shift-type1", "macro")
				F.UnitButton:SetAttribute("macrotext", "/focus none")
			end

		-- Register Frame to the engine so it will take care of its visibility
			
			RegisterUnitWatch(F)

		-- Register necessary events

			self:InitializeUnitEvents(F)
			
		-- Event Handlers
		
			F:SetScript("OnEvent", UnitFrame_OnEvent)
			
			-- To make the update instantaneous when the frame shows up
			F:SetScript("OnShow", UnitFrame_OnShow)
			F:SetScript("OnHide", UnitFrame_OnHide)

		-- Initial Update
		
			UnitFrame_ForceUpdate(F)
			
		-- Setup profile methods
		
			F.ForceUpdate = UnitFrame_ForceUpdate
			UF:RegisterUpdateFunction(F)
			UF:RegisterForClique(F.UnitButton)

		-- Prevent creation of movers for clustered unitframes
		-- We'll do it for those when the holder is being created
		
			if RawUnit ~= "arena" and RawUnit ~= "party" and RawUnit ~= "boss" and RawUnit ~= "raid" then
				E:CreateMover(F, L[Unit .. "Frame"], nil, nil, nil, format("The %s Unitframe", E:firstToUpper(RawUnit)), "unitframes", nil, format("unitframe.%s", F.ConfigKey))
				E:HandleFrameInPetBattles(E:GetMover(F))
			end

		return F
	end

	UF.Holders = {}
	UF.Holders.SortMethod = {
		["boss"] 	= {"TOPLEFT", 0, 15, "+", "-"},
		["arena"] 	= {"TOPLEFT", 0, 15, "+", "-"},
	}

	function UF:CreateUFHolder(Type, SX, SY)
		local Holder = CreateFrame("Frame", format("%sHolder", Type), E.Parent, "SecureHandlerStateTemplate")
		if SX and SY then Holder:SetSize(SX, SY) end
		Holder:SetPoint("CENTER", E.Parent, "CENTER")
		Holder.Type = Type
		Holder.Unitframes = {}

		self.Holders[Type] = Holder

		E:SetVisibilityHandler(Holder)
		E:HandleFrameInPetBattles(Holder)

		E:CreateMover(Holder, L[format("%sFrame", Type)], nil, nil, nil, format("The %s Unitframe Cluster", E:firstToUpper(Type)), "unitframes")
		E:HandleFrameInPetBattles(E:GetMover(Holder))

		return Holder
	end

	function UF:GetHolder(Unit)
		return self.Holders[Unit]
	end
	
	function UF:IsHolderVisible(Holder)
		return SecureCmdOptionParse(Holder.visibilityCondition) == "1"
	end
	
	-- @ ForceNormalize: (bool)	- Wether or not to force normal visiblity on force unshow, no matter what the dummy mode is currently set to
	function UF:OverrideSingleHolderVisibility(Holder, state, forceNormalize)
		
		local Holder = type(Holder) == 'string' and self:GetHolder(Holder) or Holder
		
		--if state == true and Holder.ForceMoverEnabled ~= false then
		if state == true then
			UnregisterStateDriver(Holder, "visible")
			RegisterStateDriver(Holder, "visible", "1")
			Holder.ForceShow = true
		else
			Holder.ForceShow = nil
			self:LoadHolderConfig(Holder.Type, forceNormalize)
		end
	end
	function UF:OverrideHolderVisibility(state, limit)
		self.HolderVisibilityOverride = state
		
		for k,v in pairs(self.Holders) do
			if limit then v = limit; k = 'Force' end
			
			if k ~= "SortMethod" and not v.HasHeader then
				self:OverrideSingleHolderVisibility(v, state)
			end
			
			if limit then break end
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

	function UF:LoadHolderConfig(Unit, ForceNormalizeVisibility)
		local Holder = self:GetHolder(Unit)
		
		if not Holder then return end
		
		local HolderSortMethod = self.Holders.SortMethod[Unit]
		local Config = self.db.units[Unit]
		
		if not Config.enable then
			-- Straight up disables the mover
			Holder.ForceMoverEnabled = false
			UnregisterStateDriver(Holder, "visible")
			RegisterStateDriver(Holder, "visible", "0")
			
			return
		else
			Holder.ForceMoverEnabled = nil
		end
		
		local ClusterConfig = Config.UFInfo.cluster
		
		-- Check if the user currently wants the holders to stay visible
		Holder.visibilityCondition = ClusterConfig.visibilityCondition
		if (self.HolderVisibilityOverride == false or ForceNormalizeVisibility) and not Holder.ForceShow then
			UnregisterStateDriver(Holder, "visible")
			RegisterStateDriver(Holder, "visible", ClusterConfig.visibilityCondition)
		end
		
		if Unit ~= "boss" and Unit ~= "arena" then return end
		
		-- Override sort config
		HolderSortMethod[1] = ClusterConfig.perRow
		HolderSortMethod[2] = not ClusterConfig.inverseStartX
		HolderSortMethod[3] = not ClusterConfig.inverseStartY
		HolderSortMethod[4] = ClusterConfig.gapX
		HolderSortMethod[5] = ClusterConfig.gapY
		
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
	
	local function SortByGroup(a, b)
		if ( IsInRaid() ) then			
			if ( not a or not b ) then
				return false
			end
			
			-- local subgroup1 = a.SortValue_Subgroup
			-- local subgroup2 = b.SortValue_Subgroup
			
			-- if ( subgroup1 and subgroup2 and subgroup1 ~= subgroup2 ) then
				-- return subgroup1 < subgroup2;
			-- end
			
			if (a.SortValue_Subgroup < b.SortValue_Subgroup) then
			   return true
			elseif (a.SortValue_Subgroup > b.SortValue_Subgroup) then
				return false
			else
				  return a.SortValue_Rank > b.SortValue_Rank
			end
			
			
		end
		
		--Fallthrough: Sort by order in Raid window.
		return a.UnitNum < b.UnitNum
	end
	
	local function SortByDefault(a, b)
		return a.UnitNum < b.UnitNum
	end
	

UF.headerGroupBy = {
	CLASS = function(header)
		--local groupingOrder = header.db and strjoin(',', header.db.CLASS1, header.db.CLASS2, header.db.CLASS3, header.db.CLASS4, header.db.CLASS5, header.db.CLASS6, header.db.CLASS7, header.db.CLASS8, header.db.CLASS9)
		--if E.Retail and groupingOrder then
		--	groupingOrder = groupingOrder..strjoin(',', header.db.CLASS10, header.db.CLASS11, header.db.CLASS12, header.db.CLASS13)
		--end

		local sortMethod = header.db and header.db.attr_SortMethod
		header:SetAttribute('groupingOrder', groupingOrder or 'DEATHKNIGHT,DEMONHUNTER,DRUID,EVOKER,HUNTER,MAGE,PALADIN,PRIEST,ROGUE,SHAMAN,WARLOCK,WARRIOR,MONK')
		header:SetAttribute('sortMethod', sortMethod or 'NAME')
		header:SetAttribute('groupBy', 'CLASS')
		header:SetAttribute('filterOnPet', nil)
	end,
	ROLE = function(header)
		--local groupingOrder = header.db and strjoin(',', header.db.ROLE1, header.db.ROLE2, header.db.ROLE3, 'NONE')
		local sortMethod = header.db and header.db.attr_SortMethod
		header:SetAttribute('groupingOrder', groupingOrder or 'TANK,HEALER,DAMAGER,NONE')
		header:SetAttribute('sortMethod', sortMethod or 'NAME')
		header:SetAttribute('groupBy', 'ASSIGNEDROLE')
		header:SetAttribute('filterOnPet', nil)
	end,
	NAME = function(header)
		header:SetAttribute('groupingOrder', '1,2,3,4,5,6,7,8')
		header:SetAttribute('sortMethod', 'NAME')
		header:SetAttribute('groupBy', nil)
		header:SetAttribute('filterOnPet', nil)
	end,
	GROUP = function(header)
		local sortMethod = header.db and header.db.attr_SortMethod
		header:SetAttribute('groupingOrder', '1,2,3,4,5,6,7,8')
		header:SetAttribute('sortMethod', sortMethod or 'INDEX')
		header:SetAttribute('groupBy', 'GROUP')
		header:SetAttribute('filterOnPet', nil)
	end,
	PETNAME = function(header)
		header:SetAttribute('groupingOrder', '1,2,3,4,5,6,7,8')
		header:SetAttribute('sortMethod', 'NAME')
		header:SetAttribute('groupBy', nil)
		header:SetAttribute('filterOnPet', true) --This is the line that matters. Without this, it sorts based on the owners name
	end,
	INDEX = function(header)
		header:SetAttribute('groupingOrder', '1,2,3,4,5,6,7,8')
		header:SetAttribute('sortMethod', 'INDEX')
		header:SetAttribute('groupBy', nil)
		header:SetAttribute('filterOnPet', nil)
	end,
}

function UF:CreateHeaders()
	local ArenaHolder, PartyHolder, BossHolder, RaidHolder, RaidFullHolder, MaintankHolder
	BossHolder 		= self:CreateUFHolder("boss")
	ArenaHolder 	= self:CreateUFHolder("arena")
	PartyHolder 	= self:CreateUFHolder("party")
	RaidHolder 		= self:CreateUFHolder("raid")
	RaidFullHolder 	= self:CreateUFHolder("raid40")
	MaintankHolder 	= self:CreateUFHolder("maintank")
	
	for i=1,5 do
		self:AssignUFHolder(BossHolder, self:Create("boss" .. i))
		self:AssignUFHolder(ArenaHolder, self:Create("arena" .. i))
	end
	
	self.RegisteredHeaderClusters = {
		-- Arena doesn't work with that
		-- ['arena'] = {
			-- ['Holder'] = ArenaHolder,
			-- ['GroupSize'] = 1,
			-- ['LiteralName'] = "arena",
			-- ['Unit'] = "arena",
			-- ['ConfigKey'] = "arena",
			-- ['Attributes'] = {
				-- showParty 		= true,
				-- showRaid 		= false,
				-- showPlayer 		= true,
				-- showSolo 		= false, -- Setting this to true results in a f*ed up header
			-- }
		-- },
		['party'] = {
			['Holder'] = PartyHolder,
			['GroupSize'] = 1,
			['LiteralName'] = "party",
			['Unit'] = "party",
			['ConfigKey'] = "party",
			['Attributes'] = {
				showParty 		= true,
				showRaid 		= false,
				showPlayer 		= false,
				showSolo 		= false, -- Setting this to true results in a f*ed up header
				groupingOrder 	= "TANK,HEALER,DAMAGER,NONE",
				groupBy 		= "ASSIGNEDROLE",
			}
		},
		['raid'] = {
			['Holder'] = RaidHolder,
			['GroupSize'] = 4,
			['LiteralName'] = "raid",
			['Unit'] = "raid",
			['ConfigKey'] = "raid",
			['Attributes'] = {
				showParty 		= false,
				showRaid 		= true,
				showPlayer 		= true,
				showSolo 		= false, -- Setting this to true results in a f*ed up header
			}
		},
		['raid40'] = {
			['Holder'] = RaidFullHolder,
			['GroupSize'] = 8,
			['LiteralName'] = "raid40",
			['Unit'] = "raid",
			['ConfigKey'] = "raid40",
			['Attributes'] = {
				showParty 		= false,
				showRaid 		= true,
				showPlayer 		= true,
				showSolo 		= false, -- Setting this to true results in a f*ed up header
			}
		},
		
		-- Special Frames
		['maintank'] = {
			['Holder'] = MaintankHolder,
			['GroupSize'] = 1,
			['LiteralName'] = "MainTanks",
			['Unit'] = "",
			['ConfigKey'] = "maintank",
			['Attributes'] = {
				showParty 		= false,
				showRaid 		= true,
				showPlayer 		= true,
				showSolo 		= false, -- Setting this to true results in a f*ed up header
				groupFilter		= "MAINTANK",
			}
		},
	}
	local Headers = self.RegisteredHeaderClusters
	
	-- Creates all headers
	for k,v in pairs(Headers) do
		if not v.Frames then
			v.Frames = {}
		end
		local WriteFilter
		for i=1, v.GroupSize do
			
			if not v.Attributes.groupFilter then
				WriteFilter = true
			end
			if WriteFilter then
				v.Attributes.groupFilter = tostring(i)
			end
			v.Attributes.groupingOrder = tostring(i)
			
			v.Frames[i] = self.Headers:Create(v.LiteralName .. "_" .. i, v.ConfigKey, i, v.Holder, v.unit, v.Attributes)
		end
		
		v.Holder.HasHeader = true
		self.Headers:LoadConfig(v)
	end
end

	

-------------------------------------------------------------------------------------------------------------------------------------
-- Refactor end
-------------------------------------------------------------------------------------------------------------------------------------
function UF:UpdateDB()
	self.db = CO.db.profile.unitframe
	
	for _, Module in pairs(self.Modules) do
		if Module.UpdateDB then
			Module:UpdateDB()
		else
			Module.db = self.db
		end
	end
end
function UF:Init()
	self:UpdateDB()
	
	if not CO.db.char.unitframe.enable then return end
	

	self:Create("player")
	self:Create("target")
	self:Create("targettarget")
	self:Create("focus")
	self:Create("focustarget")
	self:Create("pet")
	
	self:CreateHeaders()	

	self:LoadConfig()
	self:LoadAllHolderConfig()
	
	-- Handler for eventless units
	PeriodicUnitUpdate:SetScript('OnUpdate', function(self, elapsed)
		self.elapsed = (self.elapsed or 0) + elapsed
		
		if self.elapsed > self.UpdateFrequency or 1 then
			-------------------------
				for _, frame in pairs(self) do
					if type(frame) == 'table' then
						if frame.ForceUpdate and frame:IsVisible() then
							UF_Update(frame, "OnUpdate")
						end
					end
				end
			-------------------------
			
			self.elapsed = 0
		end
	end)
	
	local Blizzard = E:LoadModule('Blizzard')
	Blizzard:RemoveUnitframes()
end

E:AddModule("Unitframes", UF)
