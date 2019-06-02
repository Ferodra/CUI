local E, L = unpack(select(2, ...)) -- Engine, Locale
local UF = E:LoadModules("Unitframes")

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

local function InitChild(child)
	assert(child, "No child to initialize!")
	if not child.Initialized then
		
		child.UF = UF:CreateUF(child:GetAttribute('unit'), nil, child:GetParent(), child)
		
		--child.unit = child:GetAttribute('unit')
		--child.Unit = child.unit
		
		-- MODULES
			--UF:AddModule(child, "BarHealth")
			--UF:CreateFonts(child)
		--
		--UF:SetHoverScript(child, true)
		
		--child:RegisterForClicks("AnyUp")
		
		-------------------------
		child.Initialized = true
	end
end

function UF.Headers:InitializeChilds(header)
	local i = 1
	while true do
		if not header[i] then break end
		-------------------------------------
			
			InitChild(header[i])
			
		-------------------------------------
		i = i + 1
	end
	
	UF:LoadProfile()
end

function UF.Headers:Load(event, ...)
	UF.Headers:InitializeChilds(self)
end

local configEX = {
	point 			= "LEFT",
	groupFilter 	= "1, 2",
	templateType 	= "Button",
	xOffset 		= 0,
	yOffset 		= -5,
	sortMethod 		= "INDEX",
	strictFiltering = false,
	groupBy 		= "GROUP",
	groupingOrder 	= "1,2,3,4,5,6,7,8",
	maxColumns 		= 8,
	unitsPerColumn 	= 5,
	columnSpacing 	= 4,
	columnAnchorPoint = "LEFT",
	showParty 		= false,
	showRaid 		= true,
	showPlayer 		= true,
	showSolo 		= false,
}
function UF.Headers:Create(name, config, attributes)

	local width = 200
	local height = 50
	
	attributes = attributes or configEX
	
	local header = CreateFrame("Frame", name, UIParent, "SecureGroupHeaderTemplate")
	
	for k, v in pairs(attributes) do
		header:SetAttribute(k, v)
	end
	
	header.attributes = attributes
	
	header:SetAttribute("initialConfigFunction", ([[
		local Header = self:GetParent()
		
		self:SetWidth(%d)
		self:SetHeight(%d)
		
		RegisterUnitWatch(self)
		
		self:SetAttribute('type1', 'target')
		self:SetAttribute('*type2', 'togglemenu')
		self:SetAttribute('shift-type1', 'focus')
	]]):format(width, height))

	header:SetPoint("CENTER", E.Parent, "CENTER")
	header:SetSize(width, height)
	
	header:SetAttribute('template', 'SecureUnitButtonTemplate')

	header:RegisterEvent("PLAYER_ENTERING_WORLD")
	header:RegisterEvent("RAID_ROSTER_UPDATE")
	header:RegisterEvent("GROUP_ROSTER_UPDATE")

	header:SetScript("OnEvent", self.Load)
	self:InitializeChilds(header)
	
	header:Show()

	return header
end