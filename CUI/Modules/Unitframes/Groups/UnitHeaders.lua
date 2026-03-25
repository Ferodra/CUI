local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF = E:LoadModules("Config", "Unitframes")


local type 				= type
local select 			= select
local lower 			= string.lower
local sub 				= string.sub
local tinsert 			= table.insert
local tonumber 			= tonumber
local InCombatLockdown	= InCombatLockdown

--[[
List of the various configuration attributes
======================================================
showRaid = [BOOLEAN] -- true if the header should be shown while in a raid
showParty = [BOOLEAN] -- true if the header should be shown while in a party and not in a raid
showPlayer = [BOOLEAN] -- true if the header should show the player when not in a raid
showSolo = [BOOLEAN] -- true if the header should be shown while not in a group (implies showPlayer)
nameList = [STRING] -- a comma separated list of player names (not used if 'groupFilter' is set)
groupFilter = [1-8, STRING] -- a comma seperated list of raid group numbers and/or uppercase class names and/or uppercase roles
roleFilter = [STRING] -- a comma seperated list of MT/MA/Tank/Healer/DPS role strings
strictFiltering = [BOOLEAN] 
-- if true, then 
---- if only groupFilter is specified then characters must match both a group and a class from the groupFilter list
---- if only roleFilter is specified then characters must match at least one of the specified roles
---- if both groupFilter and roleFilters are specified then characters must match a group and a class from the groupFilter list and a role from the roleFilter list
point = [STRING] -- a valid XML anchoring point (Default: "TOP")
xOffset = [NUMBER] -- the x-Offset to use when anchoring the unit buttons (Default: 0)
yOffset = [NUMBER] -- the y-Offset to use when anchoring the unit buttons (Default: 0)
sortMethod = ["INDEX", "NAME", "NAMELIST"] -- defines how the group is sorted (Default: "INDEX")
sortDir = ["ASC", "DESC"] -- defines the sort order (Default: "ASC")
template = [STRING] -- the XML template to use for the unit buttons
templateType = [STRING] - specifies the frame type of the managed subframes (Default: "Button")
groupBy = [nil, "GROUP", "CLASS", "ROLE", "ASSIGNEDROLE"] - specifies a "grouping" type to apply before regular sorting (Default: nil)
groupingOrder = [STRING] - specifies the order of the groupings (ie. "1,2,3,4,5,6,7,8")
maxColumns = [NUMBER] - maximum number of columns the header will create (Default: 1)
unitsPerColumn = [NUMBER or nil] - maximum units that will be displayed in a singe column, nil is infinite (Default: nil)
startingIndex = [NUMBER] - the index in the final sorted unit list at which to start displaying units (Default: 1)
columnSpacing = [NUMBER] - the amount of space between the rows/columns (Default: 0)
columnAnchorPoint = [STRING] - the anchor point of each new column (ie. use LEFT for the columns to grow to the right)
--]]

UF.Headers = {}

-- local configEX = {
	-- point 			= "TOP",
	-- groupFilter 		= "1,2,3,4,5,6,7,8",
	-- xOffset 			= 0,
	-- yOffset 			= 0,
	-- sortMethod 		= "INDEX",
	-- strictFiltering 	= false,
	-- groupBy 			= "GROUP",
	-- groupingOrder 	= "1,2,3,4,5,6,7,8",
	-- maxColumns 		= 5,
	-- unitsPerColumn 	= 5,
	-- columnSpacing 	= 4,
	-- columnAnchorPoint= "LEFT",
	-- showParty 		= false,
	-- showRaid 		= true,
	-- showPlayer 		= true,
	-- showSolo 		= false, -- Setting this to true somehow results in a effed up header
-- }

local InitializeChild, OnAttributeChanged

local function OnSizeChanged(self, forceUpdate)
	if InCombatLockdown() then return end
	
	-- Forces minimum dimensions
	if self.DBWidth then
		if self:GetWidth() < self.DBWidth or forceUpdate then
			self:SetWidth(self.DBWidth)
		end
	end
	if self.DBHeight then
		if self:GetHeight() < self.DBHeight or forceUpdate then
			self:SetHeight(self.DBHeight)
		end
	end
end

local DIRECTION_TO_ATTRIBUTES = {
	--DOWN = {Anchor = "TOP", Relative = "BOTTOM", UFPoint = "TOP"}, -- Done
	DOWN_RIGHT = {Anchor = "TOPLEFT", Relative = "TOPRIGHT", UFPoint = "TOP"}, -- Done
	DOWN_LEFT = {Anchor = "TOPRIGHT", Relative = "TOPLEFT", UFPoint = "TOP"}, -- Done
	RIGHT_DOWN = {Anchor = "TOPLEFT", Relative = "BOTTOMLEFT", UFPoint = "LEFT"}, -- Done
	RIGHT_UP = {Anchor = "BOTTOMLEFT", Relative = "TOPLEFT", UFPoint = "LEFT"}, -- Done
	LEFT_DOWN = {Anchor = "TOPRIGHT", Relative = "BOTTOMRIGHT", UFPoint = "RIGHT"}, -- Done
	LEFT_UP = {Anchor = "BOTTOMRIGHT", Relative = "TOPRIGHT", UFPoint = "RIGHT"}, -- Done
	--UP = {Anchor = "BOTTOM", Relative = "TOP", UFPoint = "BOTTOM"}, -- Done
	UP_RIGHT = {Anchor = "BOTTOMLEFT", Relative = "BOTTOMRIGHT", UFPoint = "BOTTOM"}, -- Done
	UP_LEFT = {Anchor = "BOTTOMRIGHT", Relative = "BOTTOMLEFT", UFPoint = "BOTTOM"}, -- Done
}

function UF.Headers:LoadAll()
	if not UF.RegisteredHeaderClusters then return end
	
	for _, Data in pairs(UF.RegisteredHeaderClusters) do
		self:LoadConfig(Data)
	end
end
function UF.Headers:LoadConfig(Data)
	
	if not CO.db.char.unitframe.enable then return end
	
	if type(Data) == "string" then
		Data = UF.RegisteredHeaderClusters[Data]
	end
	
	if not Data then return end
	
	local UFConfig = CO.db.profile.unitframe.units[Data.ConfigKey]
	local Config = UFConfig.headers
	
	local DirectionAttributes = DIRECTION_TO_ATTRIBUTES[Config.growthDirection]
	
	local Parent, ChildNum = nil, 0
	for i=1, Data.GroupSize do
		local Header = Data.Frames[i]
		local PrevHeader = Data.Frames[i-1]
		
		if not Header then break end
		
		
		Parent = PrevHeader or Parent or Header.Parent
		Header:SetParent(Parent)
		
		Header.DBWidth = UFConfig.health.width
		Header.DBHeight = UFConfig.health.height
		
		Header.db = Config
		
		--[[
			The startingIndex is our best friend and worst enemy at the same time.
			By setting it to -4 and then forceshowing the header, we force the API to create all unit buttons.
			
			Here's the quirk:
				When we change the startingIndex WHILE the frames are populated, they get messed up.
				So we just want to do this as little as possible.
				
				It's handy to set it to -4 when we want to show unit dummys for testing or UI configuration. Just don't
				set it repeatedly and we should be good.
		--]]
		if not Header.initialized then
			Header:SetAttribute("startingIndex", -4)
			Header:Show()
			
			Header:SetAttribute('startingIndex', 1)
			
			OnSizeChanged(Header, true)
			
			Header.initialized = true
		end
		
		
		
		Header:SetAttribute("yOffset", Config.attr_YOffset)
		Header:ClearAllPoints()
		Header:SetAttribute("columnAnchorPoint", Config.attr_ColumnAnchorPoint)
		
		for i=1, Header:GetNumChildren() do
			local child = select(i, Header:GetChildren())
			child:ClearAllPoints()
			
			ChildNum = ChildNum + 1
		end
		Header:SetAttribute("point", DirectionAttributes["UFPoint"])
		
		Header:SetAttribute("maxColumns", Config.attr_MaxColumns)
		Header:SetAttribute("unitsPerColumn", Config.attr_UnitsPerColumn)
		Header:SetAttribute("columnSpacing", Config.attr_ColumnSpacing)
		Header:SetAttribute("sortDir", Config.attr_SortDir)
		Header:SetAttribute("showPlayer", Config.attr_ShowPlayer == nil and true or Config.attr_ShowPlayer)
		
		-- The rest is taken care of by sorting functions
		UF.headerGroupBy[Config.groupBy](Header)
		
		--groupingOrder 	= "TANK,HEALER,DAMAGER,NONE",
		--groupBy 		= "ASSIGNEDROLE",
		
		----------
		---- Only issue at this point are incorrect width and height values for different scenarios. 
		---- So let's fix those
		----------
			
		local Width, Height = Header.DBWidth, Header.DBHeight
		local GapX, GapY = Config.gapX, Config.gapY
		
		if DirectionAttributes["UFPoint"] == "LEFT" or DirectionAttributes["UFPoint"] == "RIGHT" then
			Width = (Width + GapX) * 5 - GapX
			
			-- UF Offsets
			Header:SetAttribute("xOffset", DirectionAttributes["UFPoint"] == "RIGHT" and -GapX or GapX)
			Header:SetAttribute("yOffset", 0)
		elseif DirectionAttributes["UFPoint"] == "TOP" or DirectionAttributes["UFPoint"] == "BOTTOM" then
			Height = (Height + GapY) * 5 - GapY
			
			-- UF Offsets
			Header:SetAttribute("xOffset", 0)
			Header:SetAttribute("yOffset", DirectionAttributes["UFPoint"] == "TOP" and -GapY or GapY)
		end
		--
		
		
		--Header:SetPoint(DirectionAttributes["Anchor"], Parent, i < 2 and DirectionAttributes["Anchor"] or DirectionAttributes["Relative"], i > 1 and Config.xOffset or 0, i > 1 and Config.yOffset or 0)
		Header:SetSize(Width, Height)
	end
	
	--local Explode = E:FullSplit(Config.growthDirection, "_")
	
	-- Behold, the mighty (Just do it) function!
	local ColumnsFirst = DirectionAttributes["UFPoint"] == "TOP" or DirectionAttributes["UFPoint"] == "BOTTOM"
	local FullWidth, FullHeight = E:SortFrames(Data.Frames, Data.Frames[1].Parent, nil, nil, 1, Config.perRow, Config.growthDirection:find("LEFT"), Config.growthDirection:find("DOWN"), Config.groupGapX, Config.groupGapY, true, ColumnsFirst)	
	
	Data.Holder:SetSize(FullWidth, FullHeight)
	E:UpdateMoverDimensions(Data.Holder)
end

function UF.Headers:ForceToggle(state, limit)
	if InCombatLockdown() then return end
	for k, HeaderGroup in pairs(UF.RegisteredHeaderClusters) do
		if (limit and k == limit) or not limit then
			if limit then
				UF:OverrideSingleHolderVisibility(limit, state, true)
			end
			
			for _, Header in pairs(HeaderGroup.Frames) do
				
				if Header and Header.SetAttribute and Header.Parent.ForceMoverEnabled ~= false then
					Header:SetAttribute("startingIndex", state and -4 or 1)
					
					local showRaid, showParty, showSolo
					if state then
						showRaid, showParty, showSolo = false, false, false
					else
						showRaid, showParty, showSolo = Header.Attributes.showRaid, Header.Attributes.showParty, Header.Attributes.showSolo
					end
					Header:SetAttribute("showRaid", showRaid)
					Header:SetAttribute("showParty", showParty)
					Header:SetAttribute("showSolo", showSolo)
					Header:Show()
					
					-- /dump CUI_party_1_HeaderUnitButton1:IsVisible()
					-- /dump CUI_party_1_HeaderUnitButton1:SetScript('OnHide', function(self) error("PATH") end)
					
					for _, child in pairs({Header:GetChildren()}) do
						if state then
							--print("PREV UNIT", child.unit, child.Fonts)
							-- if not child.BackupUnit then
								-- child.BackupUnit = child.unit or child.unit or child:GetAttribute("unit") or "player"
							-- end
							
							if not child.isForcedShown then
								OnAttributeChanged(child, "unit", "player")
								
								child.isForcedShown = true
							end
							
							UnregisterUnitWatch(child)
							RegisterUnitWatch(child, true) -- Do not handle visibility, thanks
							
							child:Show()						
							child:EnableMouse(false)
						else
							if child.isForcedShown then
								OnAttributeChanged(child, "unit", child.BackupUnit)
								
								child:EnableMouse(true)
								child.isForcedShown = nil
							end
							
							UnregisterUnitWatch(child)
							RegisterUnitWatch(child)
						end
					end
				end
			end
		end
	end
end

local function UpdateUnit(self, value)
	local Changed = self.unit ~= value
	local realUnit, modUnit = SecureButton_GetUnit(self), SecureButton_GetModifiedUnit(self)
	
	if(realUnit == 'playerpet') then
		realUnit = 'pet'
	elseif(realUnit == 'playertarget') then
		realUnit = 'target'
	end

	if(modUnit == 'pet' and realUnit ~= 'pet') then
		modUnit = 'vehicle'
	end
	
	self.unit = realUnit
	self.unit = realUnit
	
	if self.Fonts then
		self.Fonts.Frames.Level.unit = realUnit	
		self.Fonts.Frames.Name.unit = realUnit
		self.Fonts.Frames.Health.unit = realUnit
		self.Fonts.Frames.Power.unit = realUnit
	end
	
	if self.Castbar then
		UF.Modules["Castbar"]:LoadSingleBar(self)
	end
	
	
	UF:UpdateModuleUnits(self)
	
	return Changed
end

-- Returns the unit type and concatentates this result with the provided index
local function GuessUnit(name, index)
	name = lower(name)
	if name:find("party") then
		return "party" .. index
	elseif name:find("raid") then
		return "raid" .. index
	elseif name:find("maintank") then
		return "maintank" .. index
	elseif name:find("arena") then
		return "arena" .. index
	end
	
	return "player"
end

local function OnEvent(self, event, unit)
	if unit ~= self.unit then return end
	
	OnAttributeChanged(self, 'unit', self.unit)
end

local function Force_OnEvent(self, event, unit)
	if event == 'PLAYER_ENTERING_WORLD' or event == 'GROUP_ROSTER_UPDATE' then 
		unit = self.unit
	end
	
	OnEvent(self, event, unit)
end

local function UpdateAllChildModules(self, forceUpdate)
	local Level = UnitLevel(self.unit)
	if (not Level or Level == 0) and not forceUpdate then
		-- We don't have any data for this unit yet, so pushing an update won't yield any results
		-- If we were to continue, we would be stuck with false initial data
		return false
	end

	if not InCombatLockdown() then
		self:RegisterForClicks('AnyUp')
	end
	
	UF:LoadAllUnitframeModules(self)
	UF:LoadConfig(self, true)
	
	return true
end

local Updater = CreateFrame('Frame', 'CUI_UnitHeadersUpdaterFrame')
Updater.Queue = {}
UpdateDelay = 0.05 -- Let's just keep this fairly low, so we're not stuck for long with the default look or frames

-- Staggered update for header unitframes to alleviate client freezes when joining raids
local function UpdaterTick(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	
	if self.elapsed >= UpdateDelay then
		-- Push update
		-- If our update fails, move entry to the back of the table and try again later
		if not self.Queue[1]:Update() and UnitGUID(self.Queue[1].unit) then
			self.Queue[#self.Queue+1] = self.Queue[1]
			E:debugprint("No data for", self.Queue[1].unit, "-> Pushing back")
		else
			self.Queue[1]:Update()
			E:debugprint(self.Queue[1].unit, " successfully updated")
		end
		
		-- Remove from queue
		table.remove(self.Queue, 1)
			
		-- Reset timer
		self.elapsed = 0
	end
	
	if #self.Queue < 1 then
		self:SetScript("OnUpdate", nil)
	end
end

local function ScheduleDelayedUpdate(self)
	-- Prevent double queues
	if not E:TableContainsValue(Updater.Queue, self) then
		table.insert(Updater.Queue, self)
		E:debugprint("Update scheduled for", self.unit)
	end
	
	if not Updater:GetScript('OnUpdate') then
		Updater:SetScript('OnUpdate', UpdaterTick)
	end
end

InitializeChild = function(self)
	if self.Initialized then return true end
	
	self.Parent = self:GetParent()
	self.ConfigKey = self.Parent.ConfigKey
	local Name = self:GetName()
	if not self.ConfigKey or not Name:find("UnitButton") then return false end
	
	-- Additional data we can identify the exact frame with
	self.GroupNum = self.Parent:GetID()
	self.IndexInGroup = tonumber(sub(self:GetName(), -1))
	self.RealIndex = ((self.GroupNum * 5) - 5) + self.IndexInGroup
	self.RealUnit = GuessUnit(Name, self.RealIndex)
	self.HasHeader = true
	
	UF.Frames[self.ConfigKey][self.RealIndex] = self
	
	self.BackupUnit = self:GetAttribute("unit") or self.unit	
	
	UF:CreateOverlayFrames(self)
	
	-- Add modules
	UF:AddModulesToUnitframe(self)
	
	--self:RegisterEvent("UNIT_FLAGS")
	
	-- Those probably always have been irrelevant and only caused additional update calls
	-------------------------------------------------------
	-- Events to update when unit data becomes available
	--self:RegisterEvent("UNIT_CONNECTION")
	--self:RegisterEvent("UNIT_FACTION")
	--self:RegisterEvent("UNIT_NAME_UPDATE")
	--self:RegisterEvent("PLAYER_ENTERING_WORLD")
	--self:RegisterEvent("GROUP_ROSTER_UPDATE")
	--self:HookScript('OnEvent', Force_OnEvent)
	-------------------------------------------------------
	
	UF:SetHoverScript(self, true)
	
	--UF:CreateFonts(self)
	--self.Fonts:UpdateConfig()
	UF:RegisterUpdateFunction(self)
	UF:RegisterForClique(self)
	
	if self.Fonts.Frames.Index then
		self.Fonts.Frames.Index:Update(self.RealIndex)
	end
	
	-- Update Methods
	self.ScheduleDelayedUpdate = ScheduleDelayedUpdate
	self.Update = UpdateAllChildModules
	
	if not InCombatLockdown() or not self:IsProtected() then
		self:RegisterForClicks('AnyUp')
		self:SetSize(UF.db.units[self.ConfigKey].health.width, UF.db.units[self.ConfigKey].health.height)
	end
	
	
	------------------------
	self.Initialized = true
	return true
end

OnAttributeChanged = function(self, attr, value)
	if attr == 'unit' and value then
		
		UpdateUnit(self, value)
		if not InitializeChild(self) then return end
		
		local Status = UnitIsConnected(self.unit)
		local GUID = UnitGUID(self.unit)
		-- Prevent unecessary updates, which cause us to slow down dramatically when people are joining raids
		if not GUID or (self.LastGUID == GUID and self.LastStatus == Status) then return end
		
		self.LastGUID = GUID
		
		-- Update immediately, so we won't get messed up frames
		--self:Update()
		-- If no data is available, schedule update
		--if UnitExists(self.unit) and UnitLevel(self.unit) == 0 then
			-- Stagger updates and prevent client freezes
			self:ScheduleDelayedUpdate()
		--end
		
		self.LastStatus = Status
		
		-- Schedule update for next frame, as some data sometimes somehow is not available immediately
	end
end

local function SetupChild(child)
	assert(child, "No child to initialize!")
	if not child.Setup then
		
		child:HookScript("OnAttributeChanged", OnAttributeChanged)
		
		-------------------------
		child.Setup = true
	end
end

local initialConfigFunction = [[
		local header = self:GetParent()
		local frames = table.new()
		table.insert(frames, self)
		self:GetChildList(frames)
		for i = 1, #frames do
			local frame = frames[i]
			local unit
			-- There's no need to do anything on frames with onlyProcessChildren
			if(not frame:GetAttribute('oUF-onlyProcessChildren')) then
				RegisterUnitWatch(frame)
				frame:SetWidth(%d)
				frame:SetHeight(%d)

				-- Attempt to guess what the header is set to spawn.
				local groupFilter = header:GetAttribute('groupFilter')

				if(type(groupFilter) == 'string' and groupFilter:match('MAIN[AT]')) then
					local role = groupFilter:match('MAIN([AT])')
					if(role == 'T') then
						unit = 'maintank'
					else
						unit = 'mainassist'
					end
				elseif(header:GetAttribute('showRaid')) then
					unit = 'raid'
				elseif(header:GetAttribute('showParty')) then
					unit = 'party'
				end

				local headerType = header:GetAttribute('oUF-headerType')
				local suffix = frame:GetAttribute('unitsuffix')
				if(unit and suffix) then
					if(headerType == 'pet' and suffix == 'target') then
						unit = unit .. headerType .. suffix
					else
						unit = unit .. suffix
					end
				elseif(unit and headerType == 'pet') then
					unit = unit .. headerType
				end
				
				frame:SetAttribute('*type1', 'target')
				frame:SetAttribute('*type2', 'togglemenu')
				frame:SetAttribute('shift-type1', 'focus')
				
				frame:SetAttribute('CUI-Unit', unit)
			end
			
			header:CallMethod("InitializeFrame")
			
			local clique = header:GetFrameRef('clickcast_header')
			if(clique) then
				clique:SetAttribute('clickcast_button', self)
				clique:RunAttribute('clickcast_register')
			end
		end
		
		
	]]

local function InitializeFrame(self, ...)
	SetupChild(self[#self])
end


local configEX = {
	point 			= "TOP",
	groupFilter 	= "1,2,3,4,5,6,7,8",
	xOffset 		= 0,
	yOffset 		= 0,
	sortMethod 		= "INDEX",
	strictFiltering = false,
	groupBy 		= "GROUP",
	groupingOrder 	= "1,2,3,4,5,6,7,8",
	maxColumns 		= 8,
	unitsPerColumn 	= 5,
	startingIndex 	= 1, -- This forces the Blizz API to create all 5 unit buttons at once, instead of just when they're needed
	columnSpacing 	= 4,
	columnAnchorPoint = "LEFT",
	showParty 		= false,
	showRaid 		= true,
	showPlayer 		= false,
	showSolo 		= false, -- Setting this to true somehow results in a effed up header
}
function UF.Headers:Create(name, configKey, index, parentContainer, unit, attributes)

	local width = (CO.db.profile.unitframe.units[configKey].health.width) or 200
	local height = (CO.db.profile.unitframe.units[configKey].health.height) or 60
	
	attributes = attributes or configEX
	
	-- Group Header Template
	local header = CreateFrame("Frame", ("CUI_%s_Header"):format(name), E.Parent, "SecureGroupHeaderTemplate")
	-- Template for each button
	header:SetAttribute('template', 'SecureUnitButtonTemplate, SecureHandlerStateTemplate, SecureHandlerEnterLeaveTemplate')
	
	-- Fill missing properties
	for k, v in pairs(configEX) do
		if attributes[k] == nil then
			attributes[k] = v
		end
	end
	
	for k, v in pairs(attributes) do
		header:SetAttribute(k, v)
	end
	
	header.Attributes = attributes
	header.Parent = parentContainer
	header:SetID(index)
	header.ConfigKey = configKey
	header.BaseUnit = unit
	
	if not UF.Frames[configKey] then
		UF.Frames[configKey] = {}
	end
	
	header.InitializeFrame = InitializeFrame
	
	-- Function that is called for every new child unitframe
	-- We HAVE to keep this up to date with DB data, otherwise we won't be able to update correctly on the fly!
	header:SetAttribute("initialConfigFunction", (initialConfigFunction):format(width, height))
	if(Clique) then
		SecureHandlerSetFrameRef(header, 'clickcast_header', Clique.header)
	end
	
	-- Without this, the header dimensions are incorrect on first show
	header:HookScript('OnSizeChanged', OnSizeChanged)
	
	header:Show()

	return header
end