local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, L, B = E:LoadModules("Config", "Locale", "Blizzard")

local _
local HiddenFrame = CreateFrame("Frame")
local AddonLoader = CreateFrame("Frame")

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
local PlayerPowerBarAlt 		= PlayerPowerBarAlt
local UnitPowerBarAlt_TearDown 	= UnitPowerBarAlt_TearDown
local UnitPowerBarAlt_SetUp 	= UnitPowerBarAlt_SetUp
local SlashCmdList 				= SlashCmdList
local SLASH_TEST_ALERTS1 		= SLASH_TEST_ALERTS1
local IsAddOnLoaded 			= IsAddOnLoaded


B.BlizzardFrames = {
	PlayerFrame,
	TargetFrame,
	FocusFrame,
	PartyFrame,
	PartyMemberBackground,
	CompactPartyFrame,
	OrderHallCommandBar,
	PetCastingBarFrame,
	CastingBarFrame,
	MainMenuBar,
	--Actionbars,
	--Micromenu,
	BuffFrame,
	--MinimapCluster,
	--ObjectiveTrackerFrame,
	--CastingBarFrame,
	CompactRaidFrame,
	CompactRaidFrameManager,
}
B.MovableFrames = { "AddonList","AudioOptionsFrame","BankFrame","BonusRollFrame","BonusRollLootWonFrame","BonusRollMoneyWonFrame","CharacterFrame","ChatConfigFrame","DressUpFrame","FriendsFrame","FriendsFriendsFrame","GameMenuFrame",
	"GossipFrame","GuildInviteFrame","GuildRegistrarFrame","HelpFrame","InterfaceOptionsFrame","ItemTextFrame","LFDRoleCheckPopup","LFGDungeonReadyDialog","LFGDungeonReadyStatus","LootFrame","MailFrame","MerchantFrame",
	"OpenMailFrame","PVEFrame","PetStableFrame","PetitionFrame","PVPReadyDialog","QuestFrame","QuestLogPopupDetailFrame","RaidBrowserFrame","RaidInfoFrame","RaidParentFrame","ReadyCheckFrame",
	"ReportCheatingDialog","RolePollPopup","ScrollOfResurrectionSelectionFrame","SpellBookFrame","SplashFrame","StackSplitFrame","StaticPopup1","StaticPopup2","StaticPopup3","StaticPopup4","TabardFrame",
	"TaxiFrame","TimeManagerFrame","TradeFrame","TutorialFrame","VideoOptionsFrame","WorldMapFrame", "CollectionsJournal"
}

B.MovableAddonFrames = {
	["Blizzard_AchievementUI"] = { "AchievementFrame" },
	["Blizzard_ArchaeologyUI"] = { "ArchaeologyFrame" },
	["Blizzard_ArtifactUI"] = { "ArtifactRelicForgeFrame" },
	["Blizzard_AuctionUI"] = { "AuctionFrame" },
	["Blizzard_BarberShopUI"] = { "BarberShopFrame" },
	["Blizzard_BindingUI"] = { "KeyBindingFrame" },
	["Blizzard_BlackMarketUI"] = { "BlackMarketFrame" },
	["Blizzard_Calendar"] = { "CalendarCreateEventFrame", "CalendarFrame", "CalendarViewEventFrame", "CalendarViewHolidayFrame" },
	["Blizzard_ChallengesUI"] = { "ChallengesKeystoneFrame" },
	["Blizzard_Collections"] = { "CollectionsJournal" },
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

function B:RemoveBlizzard()
	for _, Frame in pairs(self.BlizzardFrames) do
		E:Remove(Frame)
	end
	
	self:RemoveFrameCluster("PartyMemberFrame%s", 4) -- Remove Blizz party frames
	self:RemoveFrameCluster("Boss%sTargetFrame", 5) -- Remove Blizz boss frames
	self:RemoveFrameCluster("ArenaEnemyFrame%s", 5) -- Remove Blizz arena frames
end

local function OnDragStart(self)
    self:StartMoving()
    self.isMoving = true
end

local function OnDragStop(self)
	self:StopMovingOrSizing()
	self.isMoving = false
end

function B:AddMovableFunc(F)
	F:EnableMouse(true)
	F:SetMovable(true)
	F:SetClampedToScreen(true)
	F:RegisterForDrag("LeftButton")

	F:SetScript("OnDragStart", OnDragStart)
	F:SetScript("OnDragStop", OnDragStop)
end

function B:MakeMovable()
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

-- Initial register if some addons are already loaded
-- Somehow those addons were already loaded and the method below would not work
-- This, for some reason, happens with ArkInventory. It's probably a taint issue
function B:TryToRegisterAllMovers()
	for addon, frames in pairs(self.MovableAddonFrames) do
		if IsAddOnLoaded(addon) then
			for _, v in pairs(frames) do
				self:AddMovableFunc(_G[v])
			end
		end
	end
end
-- /dump CUI:GetModule("Blizzard"):TryToRegisterAllMovers()
function B:RegisterAddonMover()
	AddonLoader:RegisterEvent("ADDON_LOADED")
	
	AddonLoader:SetScript("OnEvent", function(self, event, AddOn)
		if B.MovableAddonFrames[AddOn] then
			if IsAddOnLoaded(AddOn) then
				for _, v in pairs(B.MovableAddonFrames[AddOn]) do
					if _G[v] then
						B:AddMovableFunc(_G[v])
					end
				end
			end
		end
		
		return
	end)
end

function B:ToggleZoneAbility(state)
	-- We have to register/unregister a bunch of events here, since the frame otherwise would hide after a spellcast
	--has been made and the button normally would NOT exist!
	local self = ZoneAbilityFrame
	
	-- Prevent accidental hiding
	if not HasZoneAbility() then
		if state == true then
			self:UnregisterEvent("UNIT_AURA")
			self:UnregisterEvent("SPELL_UPDATE_COOLDOWN")
			self:UnregisterEvent("SPELL_UPDATE_USABLE")
			self:UnregisterEvent("SPELL_UPDATE_CHARGES")
			self:UnregisterEvent("SPELLS_CHANGED")
			self:UnregisterEvent("ACTIONBAR_SLOT_CHANGED")
			
			self:Show()
		else
			self:RegisterUnitEvent("UNIT_AURA", "player")
			self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
			self:RegisterEvent("SPELL_UPDATE_USABLE")
			self:RegisterEvent("SPELL_UPDATE_CHARGES")
			self:RegisterEvent("SPELLS_CHANGED")
			self:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
			
			self:Hide()
		end
	end
end

function B:RemoveFrameCluster(name, maxIndex)
	for i=1,maxIndex do
		local f = _G[format(name, i)]
		if f then			
			f:UnregisterAllEvents()
			f:Hide()
			
			f:SetParent(HiddenFrame)
		end
	end
end

function B:AddGameMenuButton()
	local width, height = _G["GameMenuButtonHelp"]:GetWidth(), _G["GameMenuButtonHelp"]:GetHeight()


	local button = CreateFrame("Button", "CUI_GameMenuConfigButton", _G["GameMenuButtonAddons"], "GameMenuButtonTemplate")
		button:SetWidth(width)
		button:SetHeight(height)
		button:SetScript("OnClick", function()
			CO:OpenConfig()
			ToggleGameMenu()
		end)
		button:SetText(format("|cff7394ceCUI %s|r", CHAT_CONFIGURATION))

	_G["GameMenuFrame"]:HookScript("OnShow", function()
			if not IsAddOnLoadOnDemand("CUI_Config") then
				button:Disable()
			else
				button:Enable()
			end
			_G["GameMenuButtonLogout"]:ClearAllPoints()
			_G["GameMenuFrame"]:SetHeight(_G["GameMenuFrame"]:GetHeight() + 17 + (height * 1))
			button:SetPoint("BOTTOM", _G["GameMenuButtonAddons"], "CENTER", 0, -33)
		
		_G["GameMenuButtonLogout"]:SetPoint("BOTTOM", button, "CENTER", 0, -49)
	end)
end

function B:MoveAlerts()
	AlertFrame:ClearAllPoints()
	AlertFrame:SetPoint("TOP", AlertFrameHolder, "BOTTOM")
end

-- Set hidden state for all Blizzard Actionbuttons so they never receive any Blizz updates
function B:HideActionButtons()
	
	MultiBarBottomLeft:SetParent(HiddenFrame)
	MultiBarBottomRight:SetParent(HiddenFrame)
	--MultiBarLeft:SetParent(HiddenFrame)
	MultiBarRight:SetParent(HiddenFrame)
	
	for i=1,12 do
		_G["ActionButton" .. i]:Hide()
		_G["ActionButton" .. i]:UnregisterAllEvents()
		_G["ActionButton" .. i]:SetAttribute("statehidden", true)

		_G["MultiBarBottomLeftButton" .. i]:Hide()
		_G["MultiBarBottomLeftButton" .. i]:UnregisterAllEvents()
		_G["MultiBarBottomLeftButton" .. i]:SetAttribute("statehidden", true)

		_G["MultiBarBottomRightButton" .. i]:Hide()
		_G["MultiBarBottomRightButton" .. i]:UnregisterAllEvents()
		_G["MultiBarBottomRightButton" .. i]:SetAttribute("statehidden", true)

		_G["MultiBarRightButton" .. i]:Hide()
		_G["MultiBarRightButton" .. i]:UnregisterAllEvents()
		_G["MultiBarRightButton" .. i]:SetAttribute("statehidden", true)

		_G["MultiBarLeftButton" .. i]:Hide()
		_G["MultiBarLeftButton" .. i]:UnregisterAllEvents()
		_G["MultiBarLeftButton" .. i]:SetAttribute("statehidden", true)

		if _G["VehicleMenuBarActionButton" .. i] then
			_G["VehicleMenuBarActionButton" .. i]:Hide()
			_G["VehicleMenuBarActionButton" .. i]:UnregisterAllEvents()
			_G["VehicleMenuBarActionButton" .. i]:SetAttribute("statehidden", true)
		end

		if _G['OverrideActionBarButton'..i] then
			_G['OverrideActionBarButton'..i]:Hide()
			_G['OverrideActionBarButton'..i]:UnregisterAllEvents()
			_G['OverrideActionBarButton'..i]:SetAttribute("statehidden", true)
		end

		_G['MultiCastActionButton'..i]:Hide()
		_G['MultiCastActionButton'..i]:UnregisterAllEvents()
		_G['MultiCastActionButton'..i]:SetAttribute("statehidden", true)
	end
	
	UIPARENT_MANAGED_FRAME_POSITIONS["MainMenuBar"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["StanceBarFrame"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["PossessBarFrame"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["PETACTIONBAR_YPOS"] = nil
	
	ActionBarController:UnregisterAllEvents()
	ActionBarController:RegisterEvent('UPDATE_EXTRA_ACTIONBAR')
	
	MainMenuBar:EnableMouse(false)
	MainMenuBar:SetAlpha(0)
	MainMenuBar:SetScale(0.00001)
	MainMenuBar:SetFrameStrata('BACKGROUND')
	MainMenuBar:SetFrameLevel(0)

	MainMenuBarArtFrame:UnregisterAllEvents()
	MainMenuBarArtFrame:Hide()
	MainMenuBarArtFrame:SetParent(HiddenFrame)

	StatusTrackingBarManager:EnableMouse(false)
	StatusTrackingBarManager:UnregisterAllEvents()
	StatusTrackingBarManager:Hide()

	-- StanceBarFrame:UnregisterAllEvents()
	-- StanceBarFrame:Hide()
	-- StanceBarFrame:SetParent(HiddenFrame)

	OverrideActionBar:UnregisterAllEvents()
	OverrideActionBar:Hide()
	OverrideActionBar:SetParent(HiddenFrame)

	PossessBarFrame:UnregisterAllEvents()
	PossessBarFrame:Hide()
	PossessBarFrame:SetParent(HiddenFrame)

	-- PetActionBarFrame:UnregisterAllEvents()
	-- PetActionBarFrame:Hide()
	-- PetActionBarFrame:SetParent(HiddenFrame)

	MultiCastActionBarFrame:UnregisterAllEvents()
	MultiCastActionBarFrame:Hide()
	MultiCastActionBarFrame:SetParent(HiddenFrame)
end

function B:Init()
	CO = E:GetModule("Config")
	HiddenFrame:Hide()
	
	self:MakeMovable() -- Make blizz frames movable
	self:RegisterAddonMover()
	self:TryToRegisterAllMovers()
	
	E:CreateMover(BNToastFrame, "BattleNet Notification")
	-- E:CreateMover(UIErrorsFrame, "UI-Errors / Quest Progress")
	
	E:CreateMover(PlayerPowerBarAlt, "Alternate Boss Energy", nil, 256, 64) -- 64 is be biggest it will ever get (according to sourcecode)
		
	E:CreateMover(DurabilityFrame, "Durability Frame")
	E:CreateMover(VehicleSeatIndicator, L["vehicleSeatFrame"])
	E:CreateMover(UIWidgetTopCenterContainerFrame, "Info Frame", "CENTER", 128, 50, "Stuff like Azerite on Island Expeditions etc.")
	-- E:CreateMover(TimerTracker, "Timer Bar", "CENTER", 128, 16)
		
	E:CreateMover(AlertFrameHolder, "Alertframe Anchor", nil, nil, nil, "Holds information like 'Mission completed' or 'Loot won' etc.")
	E:SecureHook(AlertFrame, "UpdateAnchors", self.MoveAlerts)
	-- @TODO: Create a mover for alert frames (loot, orderhall and garrison notifications a.e.)
	
		local LeaveVehicle = CreateFrame("Frame", "CUI_LeaveVehicleButton", E.Parent, "SecureHandlerStateTemplate")
		LeaveVehicle:SetParent(E.Parent)
		LeaveVehicle:SetSize(32, 32)
		RegisterStateDriver(LeaveVehicle, "visible", "[canexitvehicle] 1; 0")
		E:SetVisibilityHandler(LeaveVehicle)
		
		MainMenuBarVehicleLeaveButton:ClearAllPoints()
		MainMenuBarVehicleLeaveButton:SetParent(LeaveVehicle)
		MainMenuBarVehicleLeaveButton:SetAllPoints(LeaveVehicle)
		MainMenuBarVehicleLeaveButton.ignoreFramePositionManager = true
		
		MainMenuBarVehicleLeaveButton:SetScript("OnEvent", function(self, event, ...)
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
	E:CreateMover(LeaveVehicle, "Vehicle Leave Button")
	--LeaveVehicle:Hide() -- Initially hide because the state driver seems to do nothing at this point
	
	ActionBarController:UnregisterAllEvents()
	ActionBarController:RegisterEvent('UPDATE_EXTRA_ACTIONBAR')
	self:HideActionButtons()
	
	self:AddGameMenuButton()
	
	ObjectiveTrackerFrame:SetHeight(ObjectiveTrackerFrame:GetHeight()) -- If we don't set this, there's basically just the header
	E:CreateMover(ObjectiveTrackerFrame, "Objective Tracker", "TOPRIGHT", ObjectiveTrackerFrame:GetWidth() + 25, 250)

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

E:AddModule("Blizzard", B)