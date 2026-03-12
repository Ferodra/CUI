local E, L = unpack(CUI) -- Engine
local CO, CD, BA, FI, UF = E:LoadModules("Config", "Config_Dialog", "Bar_Auras", "Filters", "Unitframes")

local _
local Module = {}
local tinsert					= table.insert
local GetSpellBookItemInfo 		= C_SpellBook.GetSpellBookItemInfo or GetSpellBookItemInfo

local Index = CD:GetAutoSortIndex()

local AuraEntry_Selected 	= nil
local FilterEntry_Selected 	= nil
local IsRenaming			= nil
local CurrentAuraToAdd, HasMultiResult
local GlobalLookupTable_Auras = {}
local RecursiveLookupTable = {}

local function UpdateAllAuras()
	FI:UpdateRecursiveTable()
	
	BA:UpdateAuras("player", true)
	BA:UpdateAuras("target", true)
	
	UF.Modules["Auras"]:UpdateAll()
	--FI:ClearCache()
end

local function FilterSelection_RebuildList()
	local lookupTable = {}
	local Entry
	local i = 1
	
	for k, v in pairs(CO.db.global.filters.auras[FilterEntry_Selected].entries) do
		if E:GetSpellInfo(k) then
			lookupTable[i] = string.format("%s (%s)", select(1, E:GetSpellInfo(k)), k)
			i=i+1
		end
	end
	
	table.sort(lookupTable, function(a, b) return a < b end)
	local open, open, extracted
	for n=1, #lookupTable, 1 do						
		close = #lookupTable[n] - lookupTable[n]:reverse():find("%)") + 1
		open = #lookupTable[n] - lookupTable[n]:reverse():find("%(") + 1
		
		-- Extract the content between the second pair of parentheses
		extracted = string.sub(lookupTable[n], open + 1, close - 1)
		
		GlobalLookupTable_Auras[n] = tonumber(extracted)
		RecursiveLookupTable[tonumber(extracted)] = n
	end
	
	return lookupTable
end

local function FilterSelection_Clear()
	FilterEntry_Selected = nil
end
local function FilterSelection_Select(ID)
	FilterEntry_Selected = ID
end

local function AuraSelection_Clear()
	AuraEntry_Selected = nil
end
local function AuraSelection_Select(ID)
	AuraEntry_Selected = RecursiveLookupTable[ID]
end

local function AuraEntry_Add(info, value)
	local ID = tonumber(value)
	if (ID and (ID < 0 or ID > 999999999)) then return end
	
	-- If is name
	if not ID then
		ID = select(7, E:GetSpellInfo(value))
	end
	
	if not select(1, E:GetSpellInfo(ID)) then
		E:print("Aura does not exist! Try to enter the aura ID, if you just specified a name")
		
		return
	end
	
	if not CO.db.global.filters.auras[FilterEntry_Selected].entries[ID] then
		CO.db.global.filters.auras[FilterEntry_Selected].entries[ID] = {enabled = true}
	
		UpdateAllAuras()
	else
		E:print("Aura " .. select(1, E:GetSpellInfo(ID)) .. " already exists!")
	end
	
	FilterSelection_RebuildList()
	AuraSelection_Select(ID)
end

local function DoesFilterExist(name)
	-- Prevent Duplicate and make it active
	for ID, v in pairs(CO.db.global.filters.auras) do
		if v.name == name then			
			return ID
		end
	end
end

function CD:FilterEntry_Add(info, name)
	if InAddMode and name then
		if name == "" then
			E:print('Filter name cannot be empty!')
			
			return
		end
		
		-- Prevent Duplicate and make it active
		local FilterID = DoesFilterExist(name)
		if FilterID then
			FilterSelection_Select(FilterID)
			E:print('Filter with the name "' .. name .. '" already exists!')
			InAddMode = nil
			
			return
		end
		
		local Entry = {}
		
		Entry.name = name
		Entry.type = 2
		Entry.entries = {}
		
		tinsert(CO.db.global.filters.auras, Entry)
		FilterSelection_Select(#CO.db.global.filters.auras)
		
		InAddMode = nil
	end
end

local function FilterEntry_EnableAdd()
	InAddMode = true
end

local function AuraEntry_Delete()
	if not AuraEntry_Selected then return end
	
	local EntryID = GlobalLookupTable_Auras[AuraEntry_Selected]
	
	
	if CO.db.global.filters.auras[FilterEntry_Selected].entries[EntryID] then
		CO.db.global.filters.auras[FilterEntry_Selected].entries[EntryID] = nil
		AuraSelection_Clear()
		
		UpdateAllAuras()
	end
end

function CD:FilterEntry_Delete(IsConfirmed)
	if not IsConfirmed then
		CD:ShowNotification('DELETE_FILTER_ENTRY', true)
		
		return
	end
	

	-- Safely remove Filter
	if FI:Remove(FilterEntry_Selected) then
		FilterSelection_Clear()
		
		UpdateAllAuras()
	end
	
	InAddMode = nil
	IsRenaming = nil
	
	CD:DelayedGUIRefresh(0)
end

function CD:GetFilterEntry_Name()
	if not FilterEntry_Selected then return "" end
	
	return CO.db.global.filters.auras[FilterEntry_Selected].name
end

local function SetFilterEntry_Name(info, name)
	if not FilterEntry_Selected then return end
	
	-- Prevent Duplicate and make it active
	local FilterID = DoesFilterExist(name)
	if FilterID then
		E:print('Filter with the name "' .. name .. '" already exists!')
		
		return
	end
	
	CO.db.global.filters.auras[FilterEntry_Selected].name = name
	IsRenaming = nil
end


function Module:Disable()
	CD.Options.args.filters = nil
end

function Module:Enable()
	CD.Options.args.filters = {
		name =  ("%s"):format(L["Filters"]),
		type = 'group',
		order = Index,
		disabled = false,
		args = {
			loadSpells = CD:GetSpellLoadButton(0),
			desc = {
				type = "description",
				order = 1,
				name = "|cff1784d1" .. L['FilterMainDesc'] .. "|r",
				fontSize = "small",
			},
			addFilter = {
				type = "execute",
				name = L['AddFilter'],
				order = 2,
				func = function() FilterEntry_EnableAdd() end,
			},
			deleteFilter = {
				type = "execute",
				name = L['Delete'],
				order = 3,
				hidden = function() return not FilterEntry_Selected end,
				disabled = function() return CO.db.global.filters.auras[FilterEntry_Selected].isProtected end,
				func = function() CD:FilterEntry_Delete() end,
			},
			newLine = {type="description", name="", order=5},
			filterSelect = {
				type = "select",
				order = 6,
				name = L['Filter'],
				values = function()
					local lookupTable = {}
					
					for k, v in pairs(CO.db.global.filters.auras) do
						lookupTable[k] = v.name
					end
					
					return lookupTable
				end,
				get = function() return FilterEntry_Selected end,
				set = function(info, value) FilterSelection_Select(value) end,
				hidden = function() return IsRenaming or InAddMode end,
			},
			filterRename = {
				type = 'input',
				order = 6,
				name = L['FilterNewName'],
				get = CD.GetFilterEntry_Name,
				set = function(info, name)
					if InAddMode then
						CD:FilterEntry_Add(info, name)
					else
						SetFilterEntry_Name(info, name)
					end
					
					FI:UpdateRecursiveTable()
				end,
				hidden = function() return not IsRenaming and not InAddMode end,
			},
			filterTypeSelect = {
				type = "select",
				order = 7,
				name = L['FilterType'],
				values = function()
					local lookupTable = {}
					
					for k, v in pairs(FI.Types) do
						lookupTable[v] = k
					end
					
					return lookupTable
				end,
				get = function() return CO.db.global.filters.auras[FilterEntry_Selected].type end,
				set = function(info, value) CO.db.global.filters.auras[FilterEntry_Selected].type = value; UpdateAllAuras(); end,
				disabled = function() return CO.db.global.filters.auras[FilterEntry_Selected].isProtected end,
				hidden = function() return not FilterEntry_Selected or IsRenaming or InAddMode end,
			},
			renameFilter = {
				type = 'execute',
				order = 8,
				name = L['FilterRename'],
				func = function() IsRenaming = true end,
				hidden = function() return not FilterEntry_Selected or IsRenaming or InAddMode end,
				disabled = function() return CO.db.global.filters.auras[FilterEntry_Selected].isProtected end,
			},
			cancelFilterAction = {
				type = 'execute',
				order = 9,
				name = L['Cancel'],
				func = function() InAddMode = nil; IsRenaming = nil; end,
				hidden = function() return not IsRenaming and not InAddMode end,
			},
			newLine2 = {type="description", name="", order=15},
			add = {
				type = "input",
				order = 16,
				name = L['FilterAddAura'],
				width = "double",
				set = function(info, value)
					CurrentAuraToAdd = value
					
					if tonumber(value) or E:GetSpellInfo(value) then
						AuraEntry_Add(info, value)
						HasMultiResult = nil
					elseif CD:GetSpellFromCache(value) and CD:GetSpellMatchNumber(value) > 0 then
						HasMultiResult = true
					else
						if value ~= '' then
							local Append = not CD:IsSpellCacheInitialized() and "\nTry to load Spell Definitions first!" or ""
							E:print("Aura/Spell '" .. value .. "' could not have been found!" .. Append)
						end
						
						HasMultiResult = nil
					end
				end,
				get = function()
					return CurrentAuraToAdd
				end,
				hidden = function() return not FilterEntry_Selected or IsRenaming or InAddMode end,
			},
			multiResult = {
				type = "execute",
				order = 17,
				width = 0.65,
				name = function() return CD:GetSpellMatchHeader(CurrentAuraToAdd) end,
				desc = function() return CD:GetSpellMatchTooltip(tostring(CurrentAuraToAdd)) end,
				image = function()
					local Icon = CD:GetIcon(CurrentAuraToAdd)
					return Icon and tostring(Icon) or "", 18, 18
				end,
				hidden = function() return not FilterEntry_Selected or (IsRenaming or InAddMode) or not HasMultiResult end,
			},
			newLine5 = {type="description", name="", order=25},
			auraSelect = {
				type = "select",
				order = 26,
				name = L['Aura'],
				width = 1.5,
				values = FilterSelection_RebuildList,
				get = function() return AuraEntry_Selected end,
				set = function(info, value) AuraEntry_Selected = value; end,
				hidden = function() return not FilterEntry_Selected or IsRenaming or InAddMode end,
			},
			delete = {
				type = "execute",
				name = L['Delete'],
				order = 27,
				hidden = function() return not FilterEntry_Selected or not AuraEntry_Selected  or IsRenaming or InAddMode end,
				func = AuraEntry_Delete,
			},
			
			newLine6 = {type="description", name="", order=35},
			
			auraHeader = {
				type = "header",
				name = L['Options'],
				order = 36,
				hidden = function() return not FilterEntry_Selected or not AuraEntry_Selected or IsRenaming or InAddMode end,
			},
			auraEnable = {
				type = "toggle",
				name = L["Enable"],
				order = 37,
				hidden = function()
						return not FilterEntry_Selected or not AuraEntry_Selected or 
						not CO.db.global.filters.auras[FilterEntry_Selected].entries[GlobalLookupTable_Auras[AuraEntry_Selected]] 
						or IsRenaming or InAddMode 
				end,
				get = function() return CO.db.global.filters.auras[FilterEntry_Selected].entries[GlobalLookupTable_Auras[AuraEntry_Selected]].enabled end,
				set = function(info, value) CO.db.global.filters.auras[FilterEntry_Selected].entries[GlobalLookupTable_Auras[AuraEntry_Selected]].enabled = value; UpdateAllAuras(); end,
			},
			auraPriority = {
				type = "range",
				name = L["Priority"],
				desc = "This affects the sort order on aura bars and unit auras. The higher the priority, the lower the slot this aura is assigned to. Auras of the same priority are sorted by remaining time",
				order = 38,
				softMin = 1, softMax = 100, step = 1,
				min = 1, max = 2000,
				hidden = function()
						return not FilterEntry_Selected or not AuraEntry_Selected or 
						not CO.db.global.filters.auras[FilterEntry_Selected].entries[GlobalLookupTable_Auras[AuraEntry_Selected]] 
						or IsRenaming or InAddMode 
				end,
				disabled = function() return not CO.db.global.filters.auras[FilterEntry_Selected].entries[GlobalLookupTable_Auras[AuraEntry_Selected]].enabled end,
				get = function() return CO.db.global.filters.auras[FilterEntry_Selected].entries[GlobalLookupTable_Auras[AuraEntry_Selected]].priority or 1 end,
				set = function(info, value) CO.db.global.filters.auras[FilterEntry_Selected].entries[GlobalLookupTable_Auras[AuraEntry_Selected]].priority = value; UpdateAllAuras(); end,
			},
		}
	}
end

CD:RegisterConfigModule(Module, 'Advanced')