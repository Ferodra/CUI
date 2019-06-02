local E, L = unpack(CUI) -- Engine
local CO, CD, L = E:LoadModules("Config", "Config_Dialog", "Locale")

CD.Autoload = true
CD.OptionsOpen = false

CD.AC										=			LibStub("AceConfig-3.0")
CD.ACD										=			LibStub("AceConfigDialog-3.0-CUI")
CD.KB 										= 			LibStub("LibKeyBound-1.0")

local _
CD.DEFAULT_WIDTH, CD.DEFAULT_HEIGHT			= 			890, 650

CD.FrameChooser								=			CreateFrame("Frame", nil, E.Parent)
CD.FrameChooser.State						=			false

-- Method to create a new category. This also should be used by plugins!
-- You can directly begin to do the args table then
function CD:InitializeOptionsCategory(TablePath, DisplayName, Order)
	self.Options.args[TablePath] = {
		type = "group",
		name = DisplayName,
		order = Order,
		args = {},
	}
end

function CD:InitializeSettings()
	
	E:InitSettingsModules()
	
	-- Define Options table with valid root value --------------------
	self.Options = {type = "group", args = {}}
	
	-------------------------------------------------------------
	self.AC:RegisterOptionsTable("CUI", self.Options)
	-------------------------------------------------------------
end

local CombatWatcher = CreateFrame("Frame", nil, E.Parent)
function CD:OpenOptions()
	if not InCombatLockdown() then
		self.ACD:SetDefaultSize("CUI", CD.DEFAULT_WIDTH, CD.DEFAULT_HEIGHT)
		self.ACD:Open("CUI")
		--CombatWatcher:UnregisterEvent("PLAYER_REGEN_DISABLED")
		
		self.OptionsOpen = true
	else
		self:CloseOptions()
	end
end

function CD:CloseOptions()
	self.ACD:Close("CUI")
	self.OptionsOpen = false
end

function CD:Init()
	
	CombatWatcher:RegisterEvent("PLAYER_REGEN_DISABLED")
	CombatWatcher:SetScript("OnEvent", function(self, event)
		
		--@TODO: Needs a workaround for hiding movers for secure frames (they currently throw blocked actions around in combat when trying to hide)
		CD:ToggleMoveGrid(false, true)
		E:ToggleMover(false, true)
		
		CD:HideNotification("HANDLE_MOVE_NOTIFICATION")
		CD:CloseOptions()
	end)
	
	self:InitializeSettings()
end

E:AddModule("Config_Dialog", CD)