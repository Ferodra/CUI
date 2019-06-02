local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO = E:LoadModules("Config")

local ReloadUI = ReloadUI

-- For debugging purposes
SLASH_CUI_DEVTEST1 = '/cuitest'

-- Reload shortcut
SLASH_CUI_RELOAD1 = "/rl"
SLASH_CUI_RELOAD2 = "/reloadui"

SLASH_CUI_CONFIG1 = "/cui"

-------------------------------------

SlashCmdList.CUI_RELOAD = ReloadUI

SlashCmdList.CUI_CONFIG = CO.OpenConfig