local E, L = unpack(CUI) -- Engine
local CO, CD = E:LoadModules("Config", "Config_Dialog")

local C_Timer_After = C_Timer.After

CD.Autoload = true
CD.OptionsOpen = false

CD.AC										=			LibStub("AceConfig-3.0")
CD.ACD										=			LibStub("AceConfigDialog-3.0")
CD.ACR										=			LibStub("AceConfigRegistry-3.0")
CD.KB 										= 			LibStub("LibKeyBound-1.0-CUI")

local _
CD.DEFAULT_WIDTH, CD.DEFAULT_HEIGHT			= 			890, 655
CD.AUTOSORTINDEX							=			99999

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

function CD:GetNewLine(index)
	return {type="description", name="", order=index}
end

function CD:GetAutoSortIndex()
	return self.AUTOSORTINDEX
end

local NewFeatureStr = "%s |cff42f572(" .. L["New"] .. ")|r"
function CD:GetNewFeatureString(str)
	return (NewFeatureStr):format(str)
end

function CD:InitializeSettings()
	
	E:InitSettingsModules()
	
	-- Define Options table with valid root value --------------------
	self.Options = {type = "group", args = {}}
	
	-------------------------------------------------------------
	self.AC:RegisterOptionsTable("CUI", self.Options)
	-------------------------------------------------------------
end

function CD:DelayedGUIRefresh(delay)
	delay = delay or 0.01
	
	C_Timer_After(delay, function()
		CD:RefreshConfigGUI()
	end)
end

function CD:DelayedOpenOptions(delay)
	delay = delay or 0.01
	
	C_Timer.After(delay, function()
		CD:OpenOptions()
	end)
end

function CD:InitExtraFrames()
	if self.FramesInitialized then return end
	
	local Frame = CO:GetConfigWindow()
	if not Frame then return end
	
	-------------------------------------------
	
	
	
	-------------------------------------------	
	
	self.FramesInitialized = true
end

local CombatWatcher = CreateFrame("Frame", nil, E.Parent)
function CD:OpenOptions()
	if not InCombatLockdown() then
		self.ACD:SetDefaultSize("CUI", CD.DEFAULT_WIDTH, CD.DEFAULT_HEIGHT)
		self.ACD:Open("CUI")
		
		self:SetConfigType()
		self:InitExtraFrames()
		--CombatWatcher:UnregisterEvent("PLAYER_REGEN_DISABLED")
		
		self.OptionsOpen = true
	else
		self:CloseOptions()
	end
end

function CD:CloseOptions()
	self.ACD:Close('CUI')
	self.OptionsOpen = false
end

function CD:OpenPath(path)
	self:OpenOptions()
	self.ACD:SelectGroup('CUI', unpack(path))
end

function CD:RefreshConfigGUI(...)
	if select(1, ...) == nil then
		self.ACR:NotifyChange('CUI')
	else
		self.ACD:SelectGroup("CUI", ...)
	end
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