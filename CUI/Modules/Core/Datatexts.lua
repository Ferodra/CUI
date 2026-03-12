local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, Module = E:LoadModules("Config", "Datatexts")
Module.Autoload = true
--------------------------------------------------------

local _
local tinsert	= table.insert

--[[
	[Name] = {
		[Events] = {},
		[OnUpdate] = Func,
		[OnEvent] = Func,
		[AdditionalData] = {},
		[DBUpdate] = Func,
		[PostUpdate] = Func,
		[OnDisable] = Func,
	}
	
	-- Functions also are injected into the datatext object
	-- For DB Settings, maybe avoid single use entries and instead make one for each Datatext
	-- Additionally, this system allows for user-generated datatexts
]]

local Pool = {}
local ColorizedPing = {[0] = "FF2ded4d", [75] = "FFe3b034", [150] = "FFea2020"}
local Data = {
	['FPS'] = {
		-- OnUpdate is throttled automatically by the UpdateInterval property, which has to be a number.
		-- We update UpdateInterval through DBUpdate, if necessary.
		-- Datatexts with matching UpdateInterval's are consolidated into a single update call
		['OnUpdate'] = function(self, elapsed)
			local Value = GetFramerate()
			local ColorizedText
			for k,v in pairs(self.AdditionalData()['ColorizedFPS']) do
				if k <= Value then
					ColorizedText = format("|c%s%s|r", v, E:Round(Value, 1))
				end
			end
			
			self:SetText(ColorizedText)
		end,
		-- Optional
		['OnEvent'] = nil,
		-- Required in conjuction with OnEvent (obviously)
		['Events'] = nil,
		-- Optional for hover handling
		['OnEnter'] = nil,
		-- Optional for hover handling
		['OnLeave'] = nil,
		-- Additional data to pass into the object
		['AdditionalData'] = function() return {["ColorizedFPS"] = {[0] = "FFea2020", [25] = "FFe3b034", [45] = "FF2ded4d"}} end,
		-- Optional DBUpdate method
		['DBUpdate'] = function(self, CO)
			self.UpdateInterval = CO.db.profile.layout.stateControl.layoutUpdateFrequency
		end,
		-- Only required for datatexts with OnUpdate method
		['UpdateInterval'] = 0,
		-- Optional
		['PostUpdate'] = nil,
		-- Optional
		['OnDisable'] = nil,
		-- This is required
		['Configure'] = function(self) E:RegisterAutoFont(self, 'db.profile.layout.fps') end,
	},
}
-- Expose data to module
Module.Data = Data
Module.Pool = Pool

function Module:DisableDatatext(Object)
	Object:SetScript('OnUpdate', nil)
	Object:SetScript('OnEvent', nil)
	
	Object:OnDisable()
end

function Module:EnableDatatext(Object)
	local Meta = Data[Object.Type]
	
	if Meta.OnUpdate then
		Object:SetScript('OnUpdate', Object.OnUpdate)
	end
	if Meta.OnEvent then
		Object:SetScript('OnEvent', Object.OnEvent)
	end
	
	Object:DBUpdate(CO)
end

-- Enables AddOn Devs to manually add new types
function Module:AddNewDatatextType(Type, Tbl)	
	if not Data[Type] then
		Data[Type] = {}
	end
	
	for k,v in pairs(Tbl) do
		Data[Type][k] = v
	end
end

function Module:ConfigureDatatext(Object)
	if (Object.OnEnter and type(Object.OnEnter) == 'function') or (Object.OnLeave and type(Object.OnLeave) == 'function') then
		Object:EnableMouse(true)
	end
	if Object.Events and type(Object.Events) == 'table' then
		for _, event in pairs(Object.Events) do
			-- Consolidate this into a main event pool
			Object:RegisterEvent(event)
		end
		
	end
end

function Module:RegisterDatatext(Type, Tbl)
	if Tbl and not Data[Type] then
		self:AddNewDatatextType(Type, Tbl)
	end
	
	local Object = E:NewFontObject(nil, nil, self, 12)
	local Meta = Data[Type]
	
	Object.Type = Type
	
	-- Add Everything
	for k,v in pairs(Meta) do
		Object[k] = v
	end
	
	for _, event in pairs(Meta.Events) do
		Object:RegisterEvent(event)
	end
	
	self:ConfigureDatatext(Object)
	
	if Object.DBUpdate then
		Object:DBUpdate()
	end
	assert(Object.Configure, "Datatext requires a 'Configure' method")
	Object:Configure()
	
	if not Pool[Type] then Pool[Type] = {} end
	tinsert(Pool[Type], Object)
	
	return Object
end

--------------------------------------------------------
function Module:UpdateDB()
	for _, Object in pairs(Pool) do
		if Object.DBUpdate then
			Object:DBUpdate(CO)
		end
	end
end
function Module:Init()
	
end
--E:AddModule("Datatexts", Module)