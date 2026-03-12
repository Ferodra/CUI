local E, L = unpack(CUI) -- Engine
local CD = E:LoadModules("Config_Dialog")

function CD:EnableEditmode(isCalledByMainMenu)
	CD.ShowConfigOnEditClose = not isCalledByMainMenu
	
	E:ToggleMover(true)
	CD:ToggleMoveGrid(true)
	CD:CloseOptions()
	GameTooltip:Hide()
	
	CD:ShowNotification("HANDLE_MOVE_NOTIFICATION")
end

function CD:DisableEditmode()
	if CD.ShowConfigOnEditClose then
		CD:OpenOptions()
	end
	
	CD:ToggleMoveGrid(false)
	E:ToggleMover(false)
end