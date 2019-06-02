local E, L = unpack(CUI) -- Engine
local CO, CD, L = E:LoadModules("Config", "Config_Dialog", "Locale")

local _

CD.Options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(CO.db)
CD.Options.args.profile.order = -5

local LibDualSpec = LibStub('LibDualSpec-1.0')
LibDualSpec:EnhanceOptions(CD.Options.args.profile, CO.db)