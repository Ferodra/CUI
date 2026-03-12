local E, L = unpack(CUI) -- Engine
local CO, CD = E:LoadModules("Config", "Config_Dialog")

local _
local LibDualSpec 	= LibStub('LibDualSpec-1.0')
local Serializer 	= LibStub("AceSerializer-3.0")
local LibDeflate 	= LibStub("LibDeflate")

local configForDeflate = {level = 9} -- the biggest bottleneck by far is in transmission and printing; so use maximal compression

local function serializeProfile()
	local tbl = CO.db.profile
	local serialized = Serializer:Serialize(tbl)
	local compressed = LibDeflate:CompressDeflate(serialized, configForDeflate)
	local encoded = LibDeflate:EncodeForPrint(compressed)
	--encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)
	
	return encoded
end

local AceDBTable = LibStub("AceDBOptions-3.0"):GetOptionsTable(CO.db)

local Mode = ''
local ImportCache = ''

local function PerformImport()
	local target = CO.db.profile
	local source = ImportCache
	
	local decoded 		= LibDeflate:DecodeForPrint(source)
	local uncompressed 	= LibDeflate:DecompressDeflate(decoded)
	local success, new 	= Serializer:Deserialize(uncompressed)
	
	if success and type(new) == 'table' then
		CO.db:ImportProfile(new)
	else
		E:print('The profile you were trying to import is not valid!')
	end
end

local function CancelImport()
	Mode = ''
	ImportCache = ''
end

CD.Options.args.profile = {
	type = 'group',
	name = '|cff1784d1' .. AceDBTable.name .. '|r',
	desc = AceDBTable.desc,
	childGroups = 'tab',
	order = -5,
	args = {
		profileGroup = {
			type = 'group',
			name = L['General'],
			order = 1,
			args = AceDBTable.args,
			handler = AceDBTable.handler
		},
		importExportGroup = {
			type = 'group',
			name = L['Import/Export'],
			order = 1,
			args = {
				Import = {
					type = 'execute',
					order = 1,
					name = 'Import',
					func = function() Mode = 'Import' end,
					disabled = function() return Mode ~= '' end,
				},
				Export = {
					type = 'execute',
					order = 2,
					name = 'Export',
					func = function() Mode = 'Export' end,
					disabled = function() return Mode ~= '' end,
				},
				currentProfile = {
					order = 3,
					type = "description",
					name = function() return NORMAL_FONT_COLOR_CODE .. "Current Profile:\n|cff1784d1" .. CO.db:GetCurrentProfile() .. FONT_COLOR_CODE_CLOSE end,
					width = "default", 
				},
				newLine = {type='description',name='',order=5},
				importNote = {type='description',order=5,
					hidden = function() return Mode ~= 'Import' end,
					name='|cffd93232This mode allows you to import other peoples profiles into your current one!\nSo, before importing, make sure that the right profile is selected!|r',
				},
				exportNote = {type='description',order=5,
					hidden = function() return Mode ~= 'Export' end,
					name='|cffd93232This mode allows you to export your current profile to give it to other players, or create simple backups of it!|r',
				},
				targetContainer = {
					type = 'input',
					multiline = 15,
					name = function()
						if Mode == 'Import' then
							return L['Input']
						elseif Mode == 'Export' then
							return L['Output']
						end
					end,
					order = 10,
					width = 'full',
					hidden = function() return Mode == '' end,
					set = function(info, value)
						if Mode ~= 'Import' then return end
						
						ImportCache = value
					end,
					get = function()
						if Mode == 'Import' then
							return ImportCache or ''
						elseif Mode == 'Export' then
							return serializeProfile()
						end
					end,
				},
				newLine = {type='description',name='',order=15},
				accept = {
					type = 'execute',
					order = 25,
					name = function() if Mode == 'Export' then return L['Done'] else return L['Import'] end end,
					func = function() if Mode == 'Import' then PerformImport() end CancelImport() end,
					hidden = function() return Mode == '' end,
					disabled = function() return Mode == 'Import' and ImportCache == '' end,
				},
				cancel = {
					type = 'execute',
					order = 30,
					name = L['Cancel'],
					func = function() CancelImport() end,
					hidden = function() return Mode ~= 'Import' end,
				},
			},
		},
	}
}

LibDualSpec:EnhanceOptions(CD.Options.args.profile.args.profileGroup, CO.db)

