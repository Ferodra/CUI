local E, L = unpack(CUI) -- Engine
local CO, CD, L = E:LoadModules("Config", "Config_Dialog", "Locale")

local _

local Index = 99999 -- 99999 -> Auto-Sort

-- Template table to use for option creation
local OptionStartIndex 	= 50
local OptionOrderOffset = 5
local CurrentEntries = 1
local Entry_Selected, CurrentEntry, UpdateOptionEntries, NewDBEntry, SetNewMaxValue
local Visible = 0
local CustomMax = "360"
local Required = 0
local Entries = {}
local Prototype = {
	['Threshold_%d'] = {
		name = 'Threshold',
		desc = 'When to use this sub-format',
		type = 'range',
		min = 0, max = 5000, step = 1,
		order = '%d',
	},
	['Decimals_%d'] = {
		name = 'Decimals',
		desc = 'How many decimal places this sub-format should show',
		type = 'range',
		order = '%d+1',
		min = 0, max = 5, step = 1,
	},
	['Color_%d'] = {
		name = 'Text Color',
		desc = 'Text color of this sub-format',
		type = 'color',
		width = 'half',
		order = '%d+2',
	},
	['Threshold_Remove_%d'] = {
		name = 'Remove',
		desc = 'Text this Threshold',
		type = 'execute',
		order = '%d+3',
	},
	['Spacer_%d'] = {type="description", name="", order='%d+4'},
}
local Option_Types = {'Threshold', 'Decimals', 'Color', 'Threshold_Remove', 'Spacer'}
local Defaults = {
	['Threshold'] 	= 0,
	['Decimals'] 	= 0,
	['ColorRGB'] 	= {1, 1, 1},
}

local function Entry_AddDefaults(Entry)
	Entry = E:TableDeepCopy(Defaults)
end

local function Entry_Add(info, Identifier)
	
	if not CO.db.profile.numberFormats[Identifier] then
	
		-- UPDATE
		CO.db.profile.numberFormats[Identifier] = {}
		---------
	else
		E:print("Format " .. Identifier .. " already exists!")
	end
	
	Entry_Selected = Identifier
	CurrentEntry = CO.db.profile.numberFormats[Identifier]
end

local function Entry_Delete()
	if not Entry_Selected then return end
	
	if CurrentEntry then
		CO.db.profile.numberFormats[Entry_Selected] = nil
		CurrentEntry = nil
		Entry_Selected = nil
	end
end

local function DeleteIndex(Index)
	CO.db.profile.numberFormats[Entry_Selected][Index] = nil
	table.remove(CurrentEntry, Index)
	
	UpdateOptionEntries()
end

local function UpdateFunctions(Entry, Type)
	
	local Index = tonumber(select(2, E:ExtractDigits(Type)))
	
	if not CO.db.profile.numberFormats[Entry_Selected] then
		Entry.get = nil
		Entry.set = nil
	else
		for _, PType in pairs(Option_Types) do
			if E:DoesStringPartExist(Type, PType) then
				if PType == 'Threshold' or PType == 'Decimals' then
					Entry.get = function(info) return CurrentEntry[Index][PType] end
					Entry.set = function(info, value) CurrentEntry[Index][PType] = value; E:CacheNumberFormat(Entry_Selected); end
				end
			end
		end
		if E:DoesStringPartExist(Type, "Color") then
			Entry.get = function()
				return unpack(CurrentEntry[Index].ColorRGB or Defaults.ColorRGB)
			end
			Entry.set = function(info, r, g, b)
				local Color = CurrentEntry[Index].ColorRGB
				if Color then
					Color[1], Color[2], Color[3] = r, g, b;
					
					E:CacheNumberFormat(Entry_Selected);
				end
			end
		elseif E:DoesStringPartExist(Type, "Threshold_Remove") then
			Entry.func = function() DeleteIndex(Index); E:CacheNumberFormat(Entry_Selected); end
		elseif E:DoesStringPartExist(Type, "Spacer") then
			
		end
		
		Entry.hidden = function(info)
			if CurrentEntry then
				--print("Table Length: ", E:GetTableLength(CO.db.profile.numberFormats[Entry_Selected]), "Index:", Index, "Hidden:", (Index > #CurrentEntry), "Name:", Type)
				return (Index > #CurrentEntry) and true or false
			end
			--print("PASSED HIDDEN")
			return true
		end
	end
end

NewDBEntry = function()
	-- Add new db structure when current db index not exists
	
	--print("Attempting to create index", CurrentEntries, "Current Table Size:", #CurrentEntry, "Current Entries:", CurrentEntries)
	if (CurrentEntry and not CurrentEntry[CurrentEntries]) and #CurrentEntry < CurrentEntries then
		local NewEntry = {}
		Entry_AddDefaults(NewEntry)
		
		table.insert(CurrentEntry, NewEntry)
	end
end

local function NewOptionEntry()
	
	local CurrentKey
	
	for k, v in pairs(Prototype) do
		if not Entry_Selected then return end
		
		local Option = E:TableDeepCopy(v)
		CurrentKey = (k):format(CurrentEntries)
		CD.Options.args.numberFormats.args[CurrentKey] = Option
		
		Option.order = loadstring("return " .. ((v.order):format(OptionStartIndex)))()	
		UpdateFunctions(Option, CurrentKey)
		
		local EntryCache = {Option, CurrentKey}
		table.insert(Entries, EntryCache)
	end
	
	CurrentEntries = CurrentEntries + 1
	
	OptionStartIndex = OptionStartIndex + OptionOrderOffset
end

UpdateOptionEntries = function()
	-- Determine how many entries we actually need
	
	if CurrentEntry then
		Required = #CurrentEntry
	
		--print("Required:", Required, "Current:", CurrentEntries)
		
		if CurrentEntries < Required then
			for i = CurrentEntries, Required do
				NewOptionEntry()
			end
			
			CurrentEntries = CurrentEntries - 2
		else
			for k,v in pairs(Entries) do
				UpdateFunctions(v[1], v[2])
			end
		end
		
		--print("POST - Required:", Required, "Current:", CurrentEntries)
	end
	
	SetNewMaxValue()
end

SetNewMaxValue = function()
	for k,v in pairs(Entries) do
		if E:DoesStringPartExist(v[2], "Threshold") then
			v[1].max = tonumber(CustomMax)
		end
	end
end

CD.Options.args.numberFormats = {
	name = "Number Formats",
	type = 'group',
	order = Index,
	childGroups = "tab",
	disabled = false,
	args = {
		desc = {
			type = "description",
			order = 1,
			name = "Here, you can define specific number formats you can then choose to use in compatible modules",
			fontSize = "small",
		},
		newLine = {type="description", name="", order=5},
		add = {
			type = "input",
			order = 7,
			name = "New Format Name",
			width = "double",
			set = Entry_Add,
		},
		newLine2 = {type="description", name="", order=10},
		selection = {
			type = "select",
			order = 11,
			name = "Format",
			values = function()
				local lookupTable = {}
				
				for k, v in pairs(CO.db.profile.numberFormats) do
					lookupTable[k] = k
				end
				
				return lookupTable
			end,
			get = function() return Entry_Selected end,
			set = function(info, value) Entry_Selected = value; CurrentEntry = CO.db.profile.numberFormats[Entry_Selected]; UpdateOptionEntries() end,
		},
		delete = {
			type = "execute",
			name = "Delete",
			order = 12,
			hidden = function() return not Entry_Selected end,
			func = Entry_Delete,
		},
		
		newLine3 = {type="description", name="", order=15},
		
		formatHeader = {
			type = "header",
			name = "Options",
			order = 20,
			hidden = function() return not Entry_Selected end,
		},
		
		customMaxValue = {
			name = 'Max Threshold',
			desc = 'Max value to use for the threshold sliders',
			type = 'input',
			order = 21,
			get = function() return CustomMax end,
			set = function(info, value) CustomMax = value; SetNewMaxValue() end,
			hidden = function() return not Entry_Selected end,
		},
		
		newLine4 = {type="description", name="", order=25},
		
		AddThreshold = {
			type = "execute",
			name = "Add Threshold",
			order = -1,
			width = "full",
			func = function() NewDBEntry(); NewOptionEntry(); E:CacheNumberFormat(Entry_Selected); end,
			hidden = function() return not Entry_Selected end,
		},
	},
	
}