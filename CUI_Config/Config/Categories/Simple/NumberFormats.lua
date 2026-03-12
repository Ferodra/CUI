local E, L = unpack(CUI) -- Engine
local CO, CD = E:LoadModules("Config", "Config_Dialog")

local _
local tinsert 		= table.insert
local tremove 		= table.remove
local pairs 		= pairs
local ipairs 		= ipairs
local unpack 		= unpack
local tonumber 		= tonumber

local Index = CD:GetAutoSortIndex() -- 99999 -> Auto-Sort

local Module = {}
local OptionStartIndex 	= 25 -- Controls the start index for dynamic options
local MaxDynamicEntries = 5 -- Controls how many Thresholds can be added
local Entry_Selected, CurrentEntry
local CustomMax = "30"
local Options = {}
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

local function SetNewMaxValue()
	for k,v in pairs(CD.Options.args.numberFormats.args) do
		if v.order and v.order > OptionStartIndex then
			if v.max and E:DoesStringPartExist(v.name, "Threshold") then
				v.max = tonumber(CustomMax)
			end
		end
	end
end

local function GetMaxValue()
	return tonumber(CustomMax)
end

local function DeleteDBEntry()
	if not Entry_Selected then return end
	
	if CurrentEntry then
		CO.db.profile.numberFormats[Entry_Selected] = nil
		CurrentEntry = nil
		Entry_Selected = nil
	end
end

local function DeleteDBEntryIndex(Index)
	tremove(CurrentEntry, Index)
end

local function NewDBEntry()
	-- Add new db structure when current db index not exists
	if (CurrentEntry and not CurrentEntry[CurrentEntries]) then
		local NewEntry = {}
		Entry_AddDefaults(NewEntry)
		
		tinsert(CurrentEntry, NewEntry)
	end
	
	E:CacheNumberFormat(Entry_Selected)
end

local function UpdateOptionEntries()	
	-- Remove previous option entries
	for k,v in pairs(CD.Options.args.numberFormats.args) do
		if v and v.order and v.order > 25 then
			CD.Options.args.numberFormats.args[k] = nil
		end
	end
	
	if not CurrentEntry then return end
	
	local Config, Max, LastIndex = {}, GetMaxValue(), 0
	for i=1, #CurrentEntry do
		if i > MaxDynamicEntries then break end
		
		LastIndex = i
		
		local DBEntry = CurrentEntry[i]
		
		tinsert(Config, {
			[('Threshold_%d'):format(i)] = {
				name = 'Threshold',
				desc = 'The Threshold of when this should be active. If a number gets passed into a Text and matches this Threshold, it will be used.',
				type = 'range',
				min = 0, max = Max, step = 1,
				order = (i+OptionStartIndex)*100+1,
				hidden = function() return not Entry_Selected end,
				get = function() return DBEntry.Threshold end,
				set = function(info, value) DBEntry.Threshold = value; E:CacheNumberFormat(Entry_Selected); end,
			},
			[('Decimals_%d'):format(i)] = {
				name = 'Decimals',
				desc = 'How many decimal places this Format should show.',
				type = 'range',
				order = (i+OptionStartIndex)*100+2,
				hidden = function() return not Entry_Selected end,
				min = 0, max = 5, step = 1,
				get = function() return DBEntry.Decimals end,
				set = function(info, value) DBEntry.Decimals = value; E:CacheNumberFormat(Entry_Selected); end,
			},
			[('Color_%d'):format(i)] = {
				name = 'Text Color',
				desc = 'Text color of this sub-format',
				type = 'color',
				width = 'half',
				order = (i+OptionStartIndex)*100+3,
				hidden = function() return not Entry_Selected end,
				get = function() return unpack(DBEntry.ColorRGB) end,
				set = function(info, r, g, b)
					DBEntry.ColorRGB[1] = r
					DBEntry.ColorRGB[2] = g
					DBEntry.ColorRGB[3] = b
					
					E:CacheNumberFormat(Entry_Selected);
				end,
			},
			[('Threshold_Remove_%d'):format(i)] = {
				name = 'Remove',
				type = 'execute',
				order = (i+OptionStartIndex)*100+4,
				hidden = function() return not Entry_Selected end,
				func = function() DeleteDBEntryIndex(i); UpdateOptionEntries(); end,
			},
			[('Spacer_%d'):format(i)] = {type="description", name="", order=(i+OptionStartIndex)*100+5},
		})
		
	end
	
	-- Update ADD Button State and Counter Text
	CD.Options.args.numberFormats.args.AddThreshold.disabled = LastIndex >= MaxDynamicEntries
	CD.Options.args.numberFormats.args.limitText.name = ("  Count: %d/%d"):format(LastIndex, MaxDynamicEntries)
	
	for k,v in pairs(Config) do
		for key, option in pairs(v) do
			CD.Options.args.numberFormats.args[key] = option
		end
	end
	
	-- Apply options
	E:CacheNumberFormat(Entry_Selected)
	CD:RefreshConfigGUI()
end

function Module:Disable()
	CD.Options.args.numberFormats = nil
end

function Module:Enable()
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
				name = "Here, you can define specific number formats you can then choose to use in compatible modules.\n|cffFF0000This module currently is under heavy construction, so just some tweaks are possible at the moment.|r",
				fontSize = "small",
			},
			newLine = {type="description", name="", order=5},
			add = {
				type = "input",
				order = 7,
				name = "New Format Name",
				width = "double",
				set = function(info, value) Entry_Add(info, value); UpdateOptionEntries(); end,
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
				disabled = function() return CurrentEntry.isProtected end,
				func = DeleteDBEntry,
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
				desc = 'Max value to use for the Threshold sliders',
				type = 'input',
				order = 21,
				get = function() return CustomMax end,
				set = function(info, value) CustomMax = value; SetNewMaxValue() end,
				hidden = function() return not Entry_Selected end,
			},
			limitText = {
				type = "description",
				name = "",
				order = 22,
				width = "half",
				hidden = function() return not Entry_Selected end,
			},
			
			newLine4 = {type="description", name="", order=25},
			
			AddThreshold = {
				type = "execute",
				name = "Add Threshold",
				order = -1,
				width = "full",
				func = function() NewDBEntry(); UpdateOptionEntries(); end,
				hidden = function() return not Entry_Selected end,
			},
		},
		
	}
end

CD:RegisterConfigModule(Module, 'Simple')