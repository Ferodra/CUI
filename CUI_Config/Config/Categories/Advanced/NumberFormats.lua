local E, L = unpack(CUI) -- Engine
local CO, CD = E:LoadModules("Config", "Config_Dialog")

local _
local tinsert 		= table.insert
local tremove 		= table.remove
local pairs 		= pairs
local ipairs 		= ipairs
local unpack 		= unpack
local tonumber 		= tonumber

local Index = CD:GetAutoSortIndex()

local Module = {}
local OptionStartIndex 	= 25 -- Controls the start index for dynamic options
local MaxDynamicEntries = 5 -- Controls how many Thresholds can be added
local CurrentEntryNum = 0
local Entry_Selected, CurrentEntry
local CustomMax = "30"
local Options = {}
local Defaults = {
	['Threshold'] 	= 0,
	['Decimals'] 	= 0,
	['ColorRGB'] 	= {1, 1, 1},
}

local UpdateOptionEntries

local function Entry_AddDefaults(Entry)
	Entry = E:TableDeepCopy(Defaults)
end

local function AddThresholdEntry()
	-- Add new db structure when current db index not exists
	if CurrentEntry then
		local NewEntry = {}
		Entry_AddDefaults(NewEntry)
		
		tinsert(CurrentEntry, NewEntry)
	end
	
	E:CacheNumberFormat(Entry_Selected)
end

local function Entry_Add(info, Identifier)
	
	Entry_Selected = Identifier
	CurrentEntry = CO.db.profile.numberFormats[Identifier]
	
	if not CO.db.profile.numberFormats[Identifier] then
	
		-- UPDATE
		CO.db.profile.numberFormats[Identifier] = {}
		CurrentEntry = CO.db.profile.numberFormats[Identifier]
		
		AddThresholdEntry()
		---------
	else
		E:print("Format " .. Identifier .. " already exists!")
	end
end

local function GetNumCurrentVisible()
	return #CurrentEntry
end

local function GetLastThresholdValue()
	local Num = #CO.db.profile.numberFormats[Entry_Selected]
	local Ret = 30
	
	if Num > 0 then
		Ret = CO.db.profile.numberFormats[Entry_Selected][Num].Threshold
		
		-- FAULTY TABLE
		if Num > 1 and Ret == 0 then
			-- FIX IT
			CO.db.profile.numberFormats[Entry_Selected][Num].Threshold = CO.db.profile.numberFormats[Entry_Selected][Num-1].Threshold + 1
			Ret = CO.db.profile.numberFormats[Entry_Selected][Num].Threshold
		end
	end
	
	return Ret
end

local function SetNewMaxValue(value)
	value = tonumber(value)
	if not value then return end
	if value <= GetNumCurrentVisible() then value = 30 end
	
	if GetLastThresholdValue() > value then
		E:print("ERROR: Cannot set max value below a min value! Please lower Thresholds first!")
		return
	end
	
	CustomMax = value
		
	local Base, Entry = "Threshold_%d"
	for i=1,MaxDynamicEntries do
		Entry = CD.Options.args.numberFormats.args.formats.args[Base:format(i)]
		
		if Entry then
			Entry.max = tonumber(CustomMax) - (GetNumCurrentVisible() - (i))
		end
	end
	
	CD.Options.args.numberFormats.args.formats.args.AddThreshold.disabled()
end

local function GetCurrentMinValue(index)
	local CurrentEntry = CO.db.profile.numberFormats[Entry_Selected]
	
	if index > 1 then
		if CurrentEntry[index-1].Threshold < 1 then
			return 1
		else
			return CurrentEntry[index-1].Threshold + 1
		end
	else
		return 0
	end
end

local function UpdateMinValues()
	local Base, Entry = "Threshold_%d"
	for i=1,MaxDynamicEntries do
		Entry = CD.Options.args.numberFormats.args.formats.args[Base:format(i)]		
		if Entry then	
			Entry.min = GetCurrentMinValue(i)
		end
	end
end

local function UpdateValues(UpdateMin)
	local CurrentEntry = CO.db.profile.numberFormats[Entry_Selected]
	
	local Threshold, PrevThreshold = 0, 0
	for i=1, #CurrentEntry do
		Threshold 		= CurrentEntry[i].Threshold
		if i > 1 then
			PrevThreshold 	= CurrentEntry[i-1].Threshold
			if Threshold <= PrevThreshold then
				CurrentEntry[i].Threshold = PrevThreshold + 1
			end
		-- Always set first Threshold to 0
		else
			CurrentEntry[i].Threshold = 0
		end
	end
	
	if UpdateMin then
		UpdateMinValues()
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

UpdateOptionEntries = function(event)
	-- Remove previous option entries
	for k,v in pairs(CD.Options.args.numberFormats.args.formats.args) do
		if v and v.order and v.order > 25 then
			CD.Options.args.numberFormats.args.formats.args[k] = nil
		end
	end
	
	if not CurrentEntry then return end
	
	local Config, Max, LastIndex = {}, GetLastThresholdValue(), 0
	local Min
	
	for i=1, #CurrentEntry do
		if i > MaxDynamicEntries then break end
		
		LastIndex = i
		
		local DBEntry = CurrentEntry[i]
		
		Min = GetCurrentMinValue(i)
					
		if Min > Max then
			Min = Max
		end
		
		tinsert(Config, {
			[('Threshold_%d'):format(i)] = {
				name = 'Threshold',
				desc = 'The Threshold of when this should be active. If a number gets passed into a Text and matches this Threshold, it will be used.',
				type = 'range',
				min = Min, max = Max - (GetNumCurrentVisible() - (i+1)), step = 1,
				order = (i+OptionStartIndex)*100+1,
				hidden = function() return not Entry_Selected end,
				get = function()
					return DBEntry.Threshold end,
				set = function(info, value) DBEntry.Threshold = value; E:CacheNumberFormat(Entry_Selected); UpdateValues(); end,
				disabled = function()
					if i == 1 then
						DBEntry.Threshold = 0
						return true
					end
				end
			},
			[('Decimals_%d'):format(i)] = {
				name = 'Decimals',
				desc = 'How many decimal places this Format should show.',
				type = 'range',
				order = (i+OptionStartIndex)*100+2,
				hidden = function() return not Entry_Selected end,
				min = 0, max = 3, step = 1,
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
				disabled = function() return i == 1 end,
				func = function() DeleteDBEntryIndex(i); UpdateOptionEntries("RemoveThreshold"); end,
			},
			[('Spacer_%d'):format(i)] = {type="description", name="", order=(i+OptionStartIndex)*100+5},
		})
		
	end
	
	-- Update ADD Button State and Counter Text
	CD.Options.args.numberFormats.args.formats.args.AddThreshold.disabled = function()
		if LastIndex == 0 then return false else
			return GetLastThresholdValue() >= GetMaxValue() or (LastIndex >= MaxDynamicEntries)
		end
	end
	CD.Options.args.numberFormats.args.formats.args.limitText.name = ("  Count: %d/%d"):format(LastIndex, MaxDynamicEntries)
	
	for k,v in pairs(Config) do
		for key, option in pairs(v) do
			CD.Options.args.numberFormats.args.formats.args[key] = option
		end
	end
	
	UpdateValues()
	
	local Last = GetLastThresholdValue()
	
	-- @TODO: Heck, why doesn't this work?
	-- On Removing Threshold(s!), which are at max, we cause this to error out somehow
	if Max ~= 0 then
		SetNewMaxValue(Max)
	elseif event ~= 'AddThreshold' and event ~= 'RemoveThreshold' and Last >= Min then
		SetNewMaxValue(Last)
	else
		SetNewMaxValue(30)
	end
	
	CurrentEntryNum = LastIndex
	UpdateMinValues()
	
	-- Apply options
	E:CacheNumberFormat(Entry_Selected)
	CD:RefreshConfigGUI("numberFormats")
end

function Module:Disable()
	CD.Options.args.numberFormats = nil
end

function Module:Enable()
	CD.Options.args.numberFormats = {
		name =  L["NumberFormatting"],
		type = 'group',
		order = Index,
		childGroups = "tab",
		disabled = false,
		args = {
			formats = {
				type = 'group',
				order = 1,
				name = 'Formats',
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
						get = function() return tostring(CustomMax) end,
						set = function(info, value) SetNewMaxValue(value); UpdateValues(); end,
						hidden = function() return not Entry_Selected or CurrentEntryNum == 0 end,
					},
					limitText = {
						type = "description",
						name = "",
						order = 22,
						width = "half",
						hidden = function() return not Entry_Selected or CurrentEntryNum == 0 end,
					},
					formatType = {
						type = "select",
						name = "Format Type",
						desc = "The Format Type to be used for this Number Format.\nEach of them will behave in a different way to make the most sense out of every number passed into it.\n\nThe Actionbar Cooldown provides a special formatting between 1 and 5 minutes (M:SS)\n\nThe regular Time Formatting will simply format the number straight to a number of decimal places and colorize it",
						order = 23,
						values = E.FormatTypesList,
						get = function()
							return CurrentEntry.formatType
						end,
						set = function(info, value)
							CurrentEntry.formatType = value
							
							E:CacheNumberFormat(Entry_Selected)
						end,
						hidden = function() return not Entry_Selected end,
					},
					-- isTime = {
						-- type = "toggle",
						-- name = "Is Time",
						-- order = 23,
						-- hidden = function() return not Entry_Selected or CurrentEntry.isActionbarCooldown end,
						-- get = function() return CurrentEntry.isTime end,
						-- set = function(info, value) CurrentEntry.isTime = value; E:CacheNumberFormat(Entry_Selected); end,
					-- },
					-- isActionbarCooldown = {
						-- type = "toggle",
						-- name = "Actionbar Cooldown",
						-- order = 24,
						-- hidden = function() return not Entry_Selected or CurrentEntry.isTime end,
						-- get = function() return CurrentEntry.isActionbarCooldown end,
						-- set = function(info, value) CurrentEntry.isActionbarCooldown = value; E:CacheNumberFormat(Entry_Selected); end,
					-- },
					
					newLine4 = {type="description", name="", order=25},
					
					AddThreshold = {
						type = "execute",
						name = "Add Threshold",
						order = -1,
						width = "full",
						func = function() AddThresholdEntry(); UpdateOptionEntries("AddThreshold"); UpdateValues(); end,
						hidden = function() return not Entry_Selected end,
					},
				},
			},
			unitframeTexts = {
				type = 'group',
				order = 2,
				name = 'Unitframe Text',
				args = {
					desc = {
						type = "description",
						order = 1,
						name = "This section allows you to modify the behaviour of certain unitframe text formats",
						fontSize = "small",
					},
					newLine = {type="description", name="", order=5},
					powerGroup = {
						type = 'group',
						name = 'Power',
						guiInline = true,
						args = {
							allowSmallPowers = {
								type = 'toggle',
								order = 1,
								name = 'Allow Small Power Percentages',
								desc = 'Wether or not to allow "power-pct" to display a percentage value for powers other than mana',
								get = function() return CO.db.global.tagFontRules.allowPercentageForSmallValues end,
								set = function(info, value) CO.db.global.tagFontRules.allowPercentageForSmallValues = value; E:UpdateAllTagFonts() end,
							},
							newLine = {type="description", name="", order=5},
							useThreshold = {
								type = 'toggle',
								order = 10,
								name = 'Use Threshold Value',
								desc = 'Wether or not to use a threshold value to control when a percentage value should be displayed',
								get = function() return CO.db.global.tagFontRules.usePercentageThreshold end,
								set = function(info, value) CO.db.global.tagFontRules.usePercentageThreshold = value; E:UpdateAllTagFonts() end,
							},
							thresholdForPercentage = {
								type = 'input',
								order = 11,
								name = 'Threshold for Percentage',
								get = function() return tostring(CO.db.global.tagFontRules.percentageThreshold) end,
								set = function(info, value)
									if not tonumber(value) then return end
									CO.db.global.tagFontRules.percentageThreshold = tonumber(value)
									E:UpdateAllTagFonts()
								end,
								hidden = function() return not CO.db.global.tagFontRules.usePercentageThreshold end,
							},
						},
					},
					
				},
			},
		},
		
	}
end

CD:RegisterConfigModule(Module, 'Advanced')