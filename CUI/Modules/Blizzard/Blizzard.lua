local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, Module = E:LoadModules("Config", "Blizzard")

local _
local HiddenFrame = CreateFrame("Frame", "CUI_BlizzardHandler", E.Parent)

local AlertFrameHolder = CreateFrame("Frame", "AlertFrameHolder", E.Parent)
do
	AlertFrameHolder:SetSize(64,64)
	AlertFrameHolder:SetPoint("CENTER", E.Parent, "CENTER")
end

local _G 						= _G
local pairs 					= pairs
local select 					= select
local format					= string.format
local SlashCmdList 				= SlashCmdList
local StoreEnabled 				= C_StorePublic.IsEnabled
local C_AddOns_IsAddOnLoaded 	= C_AddOns.IsAddOnLoaded
local LoadAddOn					= C_AddOns.LoadAddOn
local IsAddOnLoadOnDemand		= C_AddOns.IsAddOnLoadOnDemand

-- Blizz frames to remove
Module.BlizzardFrames = {
	OrderHallCommandBar,
	MainStatusTrackingBarContainer,
	SecondaryStatusTrackingBarContainer,
	MicroMenuContainer,
	MicroButtonAndBagsBar,
	BagsBar,
}
Module.Unitframes = {
	PlayerFrame,
	TargetFrame,
	FocusFrame,
	PartyFrame,
	PartyMemberBackground,
	CompactPartyFrame,
	PetCastingBarFrame,
	PlayerCastingBarFrame,
	CastingBarFrame,
	CompactRaidFrameContainer,
	CompactArenaFrame,
	--CompactRaidFrameManager
}
Module.AuraFrames = {
	BuffFrame,
	DebuffFrame,
	TemporaryEnchantFrame,
}
Module.MovableFrames = { "AddonList","AudioOptionsFrame","BankFrame","BonusRollFrame","BonusRollLootWonFrame","BonusRollMoneyWonFrame","CharacterFrame","ChatConfigFrame","DressUpFrame","FriendsFrame","FriendsFriendsFrame","GameMenuFrame",
	"GossipFrame","GuildInviteFrame","GuildRegistrarFrame","HelpFrame","InterfaceOptionsFrame","ItemTextFrame","LFDRoleCheckPopup","LFGDungeonReadyDialog","LFGDungeonReadyStatus","LootFrame","MailFrame","MerchantFrame",
	"OpenMailFrame","PVEFrame","PetStableFrame","PetitionFrame","PVPReadyDialog","QuestFrame","QuestLogPopupDetailFrame","RaidBrowserFrame","RaidInfoFrame","RaidParentFrame","ReadyCheckFrame",
	"ReportCheatingDialog","RolePollPopup","ScrollOfResurrectionSelectionFrame","SpellBookFrame","SplashFrame","StackSplitFrame","StaticPopup1","StaticPopup2","StaticPopup3","StaticPopup4","TabardFrame",
	"TaxiFrame","TimeManagerFrame","TradeFrame","TutorialFrame","VideoOptionsFrame","WorldMapFrame", "CollectionsJournal"
}

Module.MovableAddonFrames = {
	["Blizzard_AchievementUI"] = { "AchievementFrame" },
	["Blizzard_ArchaeologyUI"] = { "ArchaeologyFrame" },
	["Blizzard_ArtifactUI"] = { "ArtifactRelicForgeFrame" },
	["Blizzard_AuctionHouseUI"] = { "AuctionHouseFrame" },
	["Blizzard_AzeriteUI"] = { "AzeriteEmpoweredItemUI" },
	["Blizzard_AzeriteEssenceUI"] = { "AzeriteEssenceUI" },
	["Blizzard_BarberShopUI"] = { "BarberShopFrame" },
	["Blizzard_BindingUI"] = { "KeyBindingFrame" },
	["Blizzard_BlackMarketUI"] = { "BlackMarketFrame" },
	["Blizzard_Calendar"] = { "CalendarCreateEventFrame", "CalendarFrame", "CalendarViewEventFrame", "CalendarViewHolidayFrame" },
	["Blizzard_ChallengesUI"] = { "ChallengesKeystoneFrame" },
	["Blizzard_Collections"] = { "CollectionsJournal" },
	["Blizzard_Communities"] = { "CommunitiesFrame", "CommunitiesGuildLogFrame" },
	["Blizzard_EncounterJournal"] = { "EncounterJournal" },
	["Blizzard_GarrisonUI"] = { "GarrisonLandingPage", "GarrisonMissionFrame", "GarrisonCapacitiveDisplayFrame", "GarrisonBuildingFrame", "GarrisonRecruiterFrame", "GarrisonRecruitSelectFrame", "GarrisonShipyardFrame" },
	["Blizzard_GMChatUI"] = { "GMChatStatusFrame" },
	["Blizzard_GMSurveyUI"] = { "GMSurveyFrame" },
	["Blizzard_GuildBankUI"] = { "GuildBankFrame" },
	["Blizzard_GuildControlUI"] = { "GuildControlUI" },
	["Blizzard_GuildUI"] = { "GuildFrame", "GuildLogFrame" },
	["Blizzard_InspectUI"] = { "InspectFrame" },
	["Blizzard_ItemAlterationUI"] = { "TransmogrifyFrame" },
	["Blizzard_ItemSocketingUI"] = { "ItemSocketingFrame" },
	["Blizzard_ItemUpgradeUI"] = { "ItemUpgradeFrame" },
	["Blizzard_ItemInteractionUI"] = { "ItemInteractionFrame" },
	["Blizzard_LookingForGuildUI"] = { "LookingForGuildFrame" },
	["Blizzard_MacroUI"] = { "MacroFrame" },
	["Blizzard_OrderHallUI"] = { "OrderHallTalentFrame" },
	["Blizzard_QuestChoice"] = { "QuestChoiceFrame" },
	["Blizzard_TalentUI"] = { "PlayerTalentFrame" },
	["Blizzard_TalkingHeadUI"] = { "TalkingHeadFrame" },
	["Blizzard_TradeSkillUI"] = { "TradeSkillFrame" },
	["Blizzard_TrainerUI"] = { "ClassTrainerFrame" },
	["Blizzard_VoidStorageUI"] = { "VoidStorageFrame" }
}

Module.MoversOnBlizzLoad = {
	["Blizzard_CooldownViewer"] = { {"EssentialCooldownViewer", "Cooldown Viewer", "misc"}, {"BuffIconCooldownViewer", "Buff Icon Viewer", "misc"}, {"UtilityCooldownViewer", "Utility Cooldown Viewer", "misc"}, {"BuffBarCooldownViewer", "Buff Bar Cooldown Viewer", "misc"} },
}

local FramesToHide = {
	MultiBar5 = true,
	MultiBar6 = true,
	MultiBar7 = true,
	MultiBarLeft = true,
	MultiBarRight = true,
	MultiBarBottomLeft = true,
	MultiBarBottomRight = true,
	OverrideActionBar = true,
	MainMenuBar = true,
	MainActionBar = true,
}

local KeepEventHandlerForButtons = {
	['ActionButton1'] = true,
	['ActionButton2'] = true,
	['ActionButton3'] = true,
	['ActionButton4'] = true,
	['ActionButton5'] = true,
	['ActionButton6'] = true,
	['ActionButton7'] = true,
	['ActionButton8'] = true,
	['ActionButton9'] = true,
	['ActionButton10'] = true,
	['ActionButton11'] = true,
	['ActionButton12'] = true,
	['ExtraActionButton1'] = true
}

local function OnDragStart(self)
	if InCombatLockdown() then return end
	
    self:StartMoving()
    self.isMoving = true
end

local function OnDragStop(self)
	self:StopMovingOrSizing()
	self.isMoving = false
end

function Module:QueueFrameForMovable(F)
	tinsert(self.MovableQueue, F)
	self:RegisterEvent('PLAYER_REGEN_ENABLED')
end

function Module:LoadMovableQueue(event)
	if InCombatLockdown() then return end
	
	for _, F in pairs(self.MovableQueue) do
		self:AddMovableFunc(F)
	end
	
	wipe(self.MovableQueue)
	
	self:UnregisterEvent('PLAYER_REGEN_ENABLED')
end

function Module:AddMovableFunc(F)
	
	if not F then return end
	if (F and F:IsProtected() and InCombatLockdown()) then
		Module:QueueFrameForMovable(F)
		return
	end
	
	F:EnableMouse(true)
	F:SetMovable(true)
	F:SetClampedToScreen(true)
	F:RegisterForDrag("LeftButton")

	F:SetScript("OnDragStart", OnDragStart)
	F:SetScript("OnDragStop", OnDragStop)
end

function Module:MakeMovable()
	local Frame
	for _,f in pairs(self.MovableFrames) do
		-- f:HookScript("OnShow", function(self)
			Frame = _G[f]
			if Frame then
				self:AddMovableFunc(Frame)
			end
		-- end)
	end
end

function Module:AddMovableFuncForMultiple(Frames)
	for _, frame in pairs(Frames) do
		self:AddMovableFunc(_G[frame])
	end
end

function Module:RegisterAddonMover()
	for event, frames in pairs(Module.MovableAddonFrames) do
		E:FireOnAddOnLoaded(Module, "AddMovableFuncForMultiple", event, frames)
	end
end

function Module:RegisterAddonMover()
	for event, frames in pairs(Module.MovableAddonFrames) do
		E:FireOnAddOnLoaded(Module, "AddMovableFuncForMultiple", event, frames)
	end
end

function Module:AddBlizzMover(Data)
	if _G[Data[1]] then
		E:CreateMover(_G[Data[1]], Data[2], nil, nil, nil, nil, Data[3])
	end
end

local function CreateBlizzAddonMovers()
	for addon, values in pairs(Module.MoversOnBlizzLoad) do
		for _, data in pairs(values) do
			E:FireOnAddOnLoaded(Module, "AddBlizzMover", addon, data)
		end
	end
end

function Module:RegisterBlizzAddonMovers()
	if not CO.db.char.blizzard.useGameplayFeatureMovers then return end
	
	if GetCVar("cooldownViewerEnabled") == "0" then
		hooksecurefunc("SetCVar", function(name, value)
			if name == "cooldownViewerEnabled" and (value == "1" or value) then
				CreateBlizzAddonMovers()
			end
		end)
	else
		CreateBlizzAddonMovers()
	end
end

-- lock Boss, Party, and Arena
local function LockParent(frame, parent)
	if parent ~= HiddenFrame then
		frame:SetParent(HiddenFrame)
	end
end

function Module:HideFrame(frame, doNotReparent)
	if not frame then return end

	local lockParent = doNotReparent == 1
	if lockParent or not doNotReparent then
		frame:SetParent(HiddenFrame)

		if lockParent then
			hooksecurefunc(frame, 'SetParent', LockParent)
		end
	end
end

function Module:RemoveFrameCluster(name, maxIndex, doNotReparent)
	for i=1,maxIndex do
		local f = _G[format(name, i)]
		if f then			
			f:UnregisterAllEvents()
			f:Hide()
			
			if not doNotReparent then
				f:SetParent(HiddenFrame)
			else
				self:HideFrame(f, 1)
			end
		end
	end
end

local function EditModeButtonOverride(self, button, down)
	if down then return end
	if button == 'LeftButton' then
		self:OrigFunc()
	elseif button == 'RightButton' then
		_G.GameMenuFrame.CUI:Click()
		E:LoadModules("Config_Dialog"):EnableEditmode(true)
	end
end

local gameMenuLastButtons = {
	[_G.GAMEMENU_OPTIONS] = 1,
	[_G.BLIZZARD_STORE] = 2
}
-- Dirty, but gets the job done
local button, statsButton
local totalGameMenuOffset = 0
function Module:AddGameMenuButtons()
	
	local function CreateConfigButton()
		if configButton then configButton:Show(); return end
		if IsAddOnLoadOnDemand("CUI_Config") then	
			configButton = CreateFrame("Button", "CUI_GameMenuConfigButton", GameMenuFrame, "MainMenuFrameButtonTemplate")
			configButton:SetWidth(200)
			configButton:SetHeight(35)
			configButton:SetScript("OnClick", function()
				CO:OpenConfig()
				if not InCombatLockdown() then
					HideUIPanel(GameMenuFrame)
				end
			end)
			configButton:SetText(format("|cff7394ceCUI %s|r", CHAT_CONFIGURATION))
			totalGameMenuOffset = totalGameMenuOffset + 35
		end
	end
	
	local function CreateStatsButton()
		if statsButton then statsButton:Show() return end
		if C_AddOns_IsAddOnLoaded("CUI_Statistics") then
			statsButton = CreateFrame("Button", "CUI_GameMenuStatsButton", GameMenuFrame, "MainMenuFrameButtonTemplate")
			statsButton:SetWidth(200)
			statsButton:SetHeight(35)
			statsButton:SetScript("OnClick", function()
				
				local AddOnName = 'CUI_Statistics'
				if not C_AddOns_IsAddOnLoaded(AddOnName) then
					LoadAddOn(AddOnName)
				end
				if C_AddOns_IsAddOnLoaded(AddOnName) then
					E:LoadModule('Statistics').GUI:Show()
					if not InCombatLockdown() then
						HideUIPanel(GameMenuFrame)
					end
				else
					E:print("Statistics module is disabled!")
				end
			end)
			statsButton:SetText(format("|cff7394ceCUI %s|r", STATISTICS))
			totalGameMenuOffset = totalGameMenuOffset + 35
		end
	end
	
	
	GameMenuFrame.MenuButtons = {}
	local function PositionMainMenuButtons()
		if not C_AddOns_IsAddOnLoaded("CUI_Statistics") then
			if statsButton then statsButton:Hide() end
		else
			CreateStatsButton()
			GameMenuFrame.CUIStats = statsButton
		end
		
		if not IsAddOnLoadOnDemand("CUI_Config") then
			if configButton then configButton:Hide() end
		else
			CreateConfigButton()
			GameMenuFrame.CUI = configButton
		end
			
		-- Credit to ElvUI for the base of this.
		local anchorIndex = (StoreEnabled and StoreEnabled() and 2) or 1
		for button in GameMenuFrame.buttonPool:EnumerateActive() do
			local text = button:GetText()

			GameMenuFrame.MenuButtons[text] = button -- export these

			local lastIndex = gameMenuLastButtons[text]
			if lastIndex == anchorIndex and GameMenuFrame.CUI then
				GameMenuFrame.CUI:ClearAllPoints()
				GameMenuFrame.CUI:SetPoint('TOPLEFT', button, 'BOTTOMLEFT', 0, -10)
				
				if GameMenuFrame.CUIStats then
					GameMenuFrame.CUIStats:ClearAllPoints()
					GameMenuFrame.CUIStats:SetPoint('TOPLEFT', button, 'BOTTOMLEFT', 0, (-10)-35)
				end				
			elseif not lastIndex then
				local point, anchor, point2, x, y = button:GetPoint()
				button:SetPoint(point, anchor, point2, x, y - totalGameMenuOffset)
			end
		end

		_G["GameMenuFrame"]:SetHeight(_G["GameMenuFrame"]:GetHeight() + totalGameMenuOffset)
		
		-- Change editmode click
		for button in GameMenuFrame.buttonPool:EnumerateActive() do
			if button:GetText() == HUD_EDIT_MODE_MENU then
				Module.EditmodeButton = button
				button.OrigFunc = button:GetScript("OnClick")
				
				button:RegisterForClicks('AnyUp')
				button:SetScript("OnClick", EditModeButtonOverride)
			end
		end
	end
	
	-- RESIZE
	hooksecurefunc(GameMenuFrame, 'Layout', PositionMainMenuButtons)
end

function Module:MoveAlerts()
	AlertFrame:ClearAllPoints()
	AlertFrame:SetPoint("TOP", AlertFrameHolder, "BOTTOM")
end

-- Set hidden state for all Blizzard Actionbuttons so they never receive any Blizz updates
function Module:HideActionButtons()
	
	for name in next, FramesToHide do
		local frame = _G[name]
		if frame then
			frame:SetParent(HiddenFrame)
			frame:UnregisterAllEvents()
		end
	end
	
	-- shut down some events for things we dont use
	_G.ActionBarController:UnregisterAllEvents()
	_G.ActionBarActionEventsFrame:UnregisterAllEvents()

	-- used for ExtraActionButton and TotemBar (on wrath)
	_G.ActionBarButtonEventsFrame:RegisterEvent('ACTIONBAR_SLOT_CHANGED') -- needed to let the ExtraActionButton show and Totems to swap
	_G.ActionBarButtonEventsFrame:RegisterEvent('ACTIONBAR_UPDATE_COOLDOWN') -- needed for cooldowns of them both
	
	--_G.StatusTrackingBarManager:Kill()
	_G.ActionBarController:RegisterEvent('SETTINGS_LOADED') -- this is needed for page controller to spawn properly
	_G.ActionBarController:RegisterEvent('UPDATE_EXTRA_ACTIONBAR') -- this is needed to let the ExtraActionBar show
	
	local settingsHider = CreateFrame("Frame")
	settingsHider:SetScript("OnEvent", function(self)
		self:UnregisterAllEvents()
		_G.SettingsPanel.TransitionBackOpeningPanel()
	end)
	
	-- dont reopen game menu and fix settings panel not being able to close during combat
	_G.SettingsPanel.TransitionBackOpeningPanel = function(frame)
		if InCombatLockdown() then
			settingsHider:RegisterEvent('PLAYER_REGEN_ENABLED')
			frame:SetScale(0.00001)
		else
			HideUIPanel(frame)
		end
	end
	
	-- change the text of the remove paging
	hooksecurefunc(_G.SettingsPanel.Container.SettingsList.ScrollBox, 'Update', function(frame)
		for _, child in next, { frame.ScrollTarget:GetChildren() } do
			local option = child.data and child.data.setting
			local variable = option and option.variable
			if variable and strsub(variable, 0, -3) == 'PROXY_SHOW_ACTIONBAR' then
				local num = tonumber(strsub(variable, 22))
				if num and num <= 5 then -- NUM_ACTIONBAR_PAGES - 1
					--child.Text:SetFormattedText(L["Remove Bar %d Action Page"], num)
				else
					child.Checkbox:SetEnabled(false)
					child:DisplayEnabled(false)
				end
			end
		end
	end)
end

local AutoHider
function Module:InitTrackerAutoHide()
	local tracker = _G.ObjectiveTrackerFrame
	if not tracker then return end

	AutoHider = CreateFrame('Frame', "CUI_TrackerAutoHideFrame", E.Parent, 'SecureHandlerStateTemplate')
	AutoHider:SetParent(E:GetMover(ObjectiveTrackerFrame))
	_G.ObjectiveTrackerFrame:SetParent(AutoHider)
	
	self:UpdateTrackerAutoHide()
end

function Module:UpdateTrackerAutoHide()
	local Config 	= CO.db.profile.blizzard.objectiveTracker
	local Defaults 	= E.ConfigDefaults.profile.blizzard.objectiveTracker
	
	UnregisterStateDriver(AutoHider, "visible")
	
	if Config.autoHideGeneral then
		local Condition = Config.useCustomCondition and Config.customHideCondition or Defaults.customHideCondition
		
		RegisterStateDriver(AutoHider, "visible", Condition)
		E:SetVisibilityHandler(AutoHider, Condition)
	else
		AutoHider:Show()
	end
end

function Module:HandleVehicleButton(state)
	local Button = MainMenuBarVehicleLeaveButton

	if not state then
		Button:SetParent(UIParent)
		return
	end

	local LeaveVehicle = CreateFrame("Frame", "CUI_LeaveVehicleButton", E.Parent, "SecureHandlerStateTemplate")
	LeaveVehicle:SetParent(E.Parent)
	LeaveVehicle:SetSize(32, 32)
	RegisterStateDriver(LeaveVehicle, "visible", "[canexitvehicle] 1; 0")
	E:SetVisibilityHandler(LeaveVehicle)
	
	
	Button:ClearAllPoints()
	Button:SetParent(UIParent)
	Button:SetPoint('CENTER', LeaveVehicle, 'CENTER')
	Button.ignoreFramePositionManager = true
	--Button.system = nil
	--print(Button.system)

	-- @TODO: Critical issue with editmode managed frames: Moving them in any way will result in their config being effed, because they will save
	-- 	their relative frame. There is no fallback to a default frame on blizzard's side for those cases.
	-- We'd have to somehow remove the frame from being managed before doing anything to them.
	-- OR we just don't create movers for any editmode managed frames at all.
	
	Button:SetScript("OnEvent", function(self, event, ...)
		--if ( CanExitVehicle() and ActionBarController_GetCurrentActionBarState() == LE_ACTIONBAR_STATE_MAIN ) then
		if ( CanExitVehicle() ) then
			self:Show()
			self:Enable()
		else
			self:SetHighlightTexture([[Interface\Buttons\ButtonHilight-Square]], "ADD");
			self:UnlockHighlight()
			self:Hide()
		end
	end)
	
	hooksecurefunc(Button, 'SetPoint', function(_, _, parent)
		if parent ~= LeaveVehicle then
			Button:ClearAllPoints()
			Button:SetParent(UIParent)
			Button:SetPoint('CENTER', LeaveVehicle, 'CENTER')
		end
	end)
	
	-- Vehicle Leave Button
		E:CreateMover(LeaveVehicle, "Vehicle Leave Button", nil, nil, nil, nil, "actionbars")
end


function Module:CreateBlizzMovers()

		self:HandleVehicleButton(false)
	-- Battlenet Notifications
		E:CreateMover(BNToastFrame, "BattleNet Notification", nil, nil, nil, nil, "misc")
	-- Alternate Boss Energy
		E:CreateMover(PlayerPowerBarAlt, "Alternate Boss Energy", nil, 256, 64, nil, "misc") -- 256x64 is be biggest it will ever get (according to sourcecode)	
	-- Durability Frame
		--E:CreateMover(DurabilityFrame, "Durability Frame", nil, nil, nil, nil, "misc")
	-- Vehicle Seats
		--E:CreateMover(VehicleSeatIndicator, L["vehicleSeatFrame"], nil, nil, nil, nil, "misc")
	-- Widgets
		E:CreateMover(UIWidgetTopCenterContainerFrame, "Info Frame", "CENTER", 128, 50, "Stuff like Azerite on Island Expeditions etc.", "misc")
		E:CreateMover(UIWidgetPowerBarContainerFrame, "Power Bar Widget", "CENTER", 300, 70, "Advanced flying power etc.", "misc")
	-- Alerts
		E:CreateMover(AlertFrameHolder, "Alertframe Anchor", nil, nil, nil, "Holds information like 'Mission completed' or 'Loot won' etc.", "misc")
		E:SecureHook(AlertFrame, "UpdateAnchors", self.MoveAlerts)
	-- Quest Tracker
		--jectiveTrackerFrame:SetHeight(ObjectiveTrackerFrame:GetHeight()) -- If we don't set this, there's basically just the header
		--jectiveTrackerFrame.isManagedFrame = false
		--E:CreateMover(ObjectiveTrackerFrame, "Objective Tracker", "TOPRIGHT", ObjectiveTrackerFrame:GetWidth() + 25, 250, nil, "misc")
	-- Azshara Widget etc.
		E:CreateMover(UIWidgetBelowMinimapContainerFrame, "UI Widget Container", nil, 100, 100, "Holds things like the Azshara Encounter Widget", "misc")
		
	--LoadAddOn("Blizzard_ArchaeologyUI")
		
	-- Archeology Bar
		if ArcheologyDigsiteProgressBar then
			E:CreateMover(ArcheologyDigsiteProgressBar, "Archeology Bar", nil, 240, 25, "Holds the Archeology Progress Bar", "misc")
		end
end

function Module:RemoveBlizzard()
	for _, Frame in pairs(self.BlizzardFrames) do
		E:Remove(Frame)
	end
end
function Module:RemoveActionbars()
	ActionBarController:UnregisterAllEvents()
	-- We still need this one to push updates for actionpage handling
	ActionBarController:RegisterEvent('UPDATE_EXTRA_ACTIONBAR')
	self:HideActionButtons()
	
	-- Get rid of the unused actionbutton event calls
	-- This potentially frees up a few milliseconds.
	-- Leave buttons with paging intact, as those are still
	-- needed for proper updating
	for k,v in pairs(ActionBarButtonEventsFrame.frames) do
		local Name = v:GetName()
		
		if not KeepEventHandlerForButtons[Name] then
			ActionBarButtonEventsFrame.frames[k] = nil
		end
	end
	
	E:Remove(MainMenuBar)
end
function Module:RemoveUnitframes()
	for _, Frame in pairs(self.Unitframes) do
		E:Remove(Frame)
	end
	
	self:RemoveFrameCluster("PartyMemberFrame%s", 4) -- Remove Blizz party frames
	self:RemoveFrameCluster("Boss%sTargetFrame", 5, true) -- Remove Blizz boss frames
	self:RemoveFrameCluster("ArenaEnemyFrame%s", 5, true) -- Remove Blizz arena frames
	
	self:HideFrame(_G.BossTargetFrameContainer, 1)
	self:HideFrame(_G.CompactArenaFrame, 1)
	self:HideFrame(_G.PartyFrame, 1)
	
	CompactRaidFrameManager_SetSetting('IsShown', '0')
	_G.UIParent:UnregisterEvent('GROUP_ROSTER_UPDATE')
	_G.CompactRaidFrameManager:UnregisterAllEvents()
	_G.CompactRaidFrameManager:SetParent(HiddenFrame)
end
function Module:RemovePlayerAuras()
	for _, Frame in pairs(self.AuraFrames) do
		E:Remove(Frame)
	end
end

function Module:Init()
	CO = E:LoadModule("Config")
	HiddenFrame:Hide()
	HiddenFrame:SetPoint("TOPLEFT", E.Parent, "TOPLEFT")
	HiddenFrame:SetPoint("BOTTOMRIGHT", E.Parent, "BOTTOMRIGHT")
	
	self.MovableQueue = {}
	self:SetScript('OnEvent', self.LoadMovableQueue)
	
	self:MakeMovable() -- Make blizz frames movable
	self:RegisterAddonMover()
	self:CreateBlizzMovers()
	self:RegisterBlizzAddonMovers()
	self:AddGameMenuButtons()
	
	--self:InitTrackerAutoHide()
	
	
	-- Widget type table
	--Enum.UIWidgetVisualizationType

	--[[ Code you can use for alert testing
			--Queued Alerts:
			/run AchievementAlertSystem:AddAlert(5192)
			/run CriteriaAlertSystem:AddAlert(9023, "Doing great!")
			/run LootAlertSystem:AddAlert("\124cffa335ee\124Hitem:18832::::::::::\124h[Brutality Blade]\124h\124r", 1, 1, 1, 1, false, false, 0, false, false)
			/run LootUpgradeAlertSystem:AddAlert("\124cffa335ee\124Hitem:18832::::::::::\124h[Brutality Blade]\124h\124r", 1, 1, 1, nil, nil, false)
			/run MoneyWonAlertSystem:AddAlert(815)
			/run NewRecipeLearnedAlertSystem:AddAlert(204)

			--Simple Alerts
			/run GuildChallengeAlertSystem:AddAlert(3, 2, 5)
			/run InvasionAlertSystem:AddAlert(1)
			/run WorldQuestCompleteAlertSystem:AddAlert(112)
			/run GarrisonBuildingAlertSystem:AddAlert("Barracks")
			/run GarrisonFollowerAlertSystem:AddAlert(204, "Ben Stone", 90, 3, false)
			/run GarrisonMissionAlertSystem:AddAlert(681) (Requires a mission ID that is in your mission list.)
			/run GarrisonShipFollowerAlertSystem:AddAlert(592, "Test", "Transport", "GarrBuilding_Barracks_1_H", 3, 2, 1)
			/run LegendaryItemAlertSystem:AddAlert("\124cffa335ee\124Hitem:18832::::::::::\124h[Brutality Blade]\124h\124r")
			/run StorePurchaseAlertSystem:AddAlert("\124cffa335ee\124Hitem:180545::::::::::\124h[Mystic Runesaber]\124h\124r", "", "", 214)
			/run DigsiteCompleteAlertSystem:AddAlert(1)

			--Bonus Rolls
			/run BonusRollFrame_StartBonusRoll(242969,1,179,1273,14)
		]]




	-- This adds an entry to every friendly player popup-menu
	--[[
		UnitPopupButtons["GUILD_INVITE"] = { text = "Invite to Guild", dist = 0 };

	-- Add it to the FRIEND and PLAYER menus as the 2nd to last option (before Cancel)
	table.insert(UnitPopupMenus["FRIEND"], #UnitPopupMenus["FRIEND"]-1, "GUILD_INVITE");
	table.insert(UnitPopupMenus["PLAYER"], #UnitPopupMenus["FRIEND"]-1, "GUILD_INVITE");
	]]--
end

E:AddModule("Blizzard", Module)