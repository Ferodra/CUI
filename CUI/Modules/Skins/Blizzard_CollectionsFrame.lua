local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, Module = E:LoadModules("Config", "Blizzard_CollectionsFrame")
Module.Autoload = true

local SHOW_HELM = SHOW_HELM
local SOUNDKIT	= SOUNDKIT
local C_AddOns_IsAddOnLoaded				= C_AddOns.IsAddOnLoaded
-----------------------------
local DressUpFrame
local EventListener = CreateFrame("Frame", "CUI_CollectionsFrameEventHandler")
local HeadSlot = 1
local AnimationID = 2 		-- Idle
local AnimationID_Click = 9 -- Hit
local UpdateDelay = 0

local function OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed >= UpdateDelay then
		Module:HideHeadArmor()
		
		self.elapsed = 0
	end
end

local Timer
local function ResetAnimation()
	DressUpFrame:SetAnimation(AnimationID)
	if Timer then
		Timer:Cancel()
		Timer = nil
	end
end

local function SetDelayedUpdate(state)
	if state then
		if not EventListener:GetScript('OnUpdate') then
			EventListener:SetScript('OnUpdate', OnUpdate)
		end
		-- Delay animation start by one frame, as AddOns like BetterWardrobe seem to already override the animation OnShow
		C_Timer.After(0, ResetAnimation)
	else
		EventListener:SetScript('OnUpdate', nil)
	end
end

function Module:HideHeadArmor()
	if Module:GetHelmetConfig() then return end
	DressUpFrame:UndressSlot(HeadSlot)
end

local function UpdateCheckboxPosition()
	local Box = Module.CheckButton
	local Parent = Box.Parent
	local Dropdown = WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame.VariantSetsDropdown
	
	if not Dropdown:IsVisible() then
		Box:SetPoint("TOPRIGHT", Parent, "TOPRIGHT", -5, -5)
	else
		Box:SetPoint("TOPRIGHT", Parent, "TOPRIGHT", -130, -5)
	end
end

local function UpdateDisplayedSet()
	UpdateCheckboxPosition()
end

local function UpdateTickerState()
	
	if not Module:GetHelmetConfig() and WardrobeCollectionFrame.SetsCollectionFrame:IsVisible() then
		SetDelayedUpdate(true)
		DressUpFrame:SetAnimation(AnimationID)
		--print("UPDATE TRUE")
	else
		SetDelayedUpdate(false)
		--print("UPDATE FALSE")
	end
end


local function InitModelHook()	
	--hooksecurefunc(DressUpFrame, "TryOn", Module.HideHeadArmor)
	--hooksecurefunc(DressUpFrame, "SetUnit", Module.HideHeadArmor)
	--hooksecurefunc(DressUpFrame, "RefreshUnit", Module.HideHeadArmor)
	--hooksecurefunc(DressUpFrame, "SetDisplayInfo", Module.HideHeadArmor)
	hooksecurefunc(WardrobeCollectionFrame.SetsCollectionFrame, "DisplaySet", UpdateDisplayedSet)
	hooksecurefunc(WardrobeCollectionFrame.SetsCollectionFrame, "SelectSet", UpdateDisplayedSet)
	
	-- The hooks do not work 100% of the time, although they cover every spot where the API loads something into the slot
	-- It possibly has something to do with how WoW loads armor models to DressUpFrames. So we have to set an asynchronous OnUpdate ticker to make it fully work all the time
	-- We have to hook into a parented frame of the SetsCollection, as some AddOns override the OnShow and OnHide Scripts
	-- Which then renders the hook useless
	EventListener:SetParent(WardrobeCollectionFrame.SetsCollectionFrame)
	EventListener:SetScript("OnShow", UpdateTickerState)
	EventListener:SetScript("OnHide", UpdateTickerState)
	
	DressUpFrame:HookScript('OnMouseDown', function(self, button)
		if button == 'MiddleButton' then
			DressUpFrame:SetAnimation(AnimationID_Click)
			
			if Timer then
				Timer:Cancel()
				Timer = nil
			end
			
			Timer = C_Timer.NewTimer(0.55, ResetAnimation)
		end
	end)
end

local function UpdateCheckboxTitle(self, OverrideTitle)
	self.CheckButton.Text:SetText(SHOW_HELM)
end

function Module:GetHelmetConfig()
	return CO.db.global.misc.collectionsShowHelmet
end

function Module:UpdateHelmet()
	if not WardrobeCollectionFrame then return end
	
	local Config = Module:GetHelmetConfig()
	
	if Config then
		WardrobeCollectionFrame.SetsCollectionFrame:Refresh()
	else
		Module:HideHeadArmor()
	end
end

function Module:AddCheckbox()
	local Parent = WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame
	--local Parent = WardrobeSetsCollectionVariantSetsButton
	local Box = CreateFrame("CheckButton", "CUI_ToggleHeadArmorButton", Parent, "UICheckButtonTemplate")
	local Text = _G[Box:GetName() .. 'Text']
	self.CheckButton = Box
	self.CheckButton.Text = Text
	self.CheckButton.Parent = Parent
	
	UpdateCheckboxTitle(self)
	
	Box:SetSize(25, 25)
	Box:SetPoint("TOPRIGHT", Parent, "TOPRIGHT", -115, -5)
	
	Box:SetHitRectInsets(-80, 0, 0, 0)
	
	Text:ClearAllPoints()
	Text:SetPoint("RIGHT", Box, "LEFT", -2, 0)

	Box:SetScript('OnClick', function(self)
		CO.db.global.misc.collectionsShowHelmet = self:GetChecked()
		Module:UpdateHelmet()
		UpdateTickerState()
		
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	end)
	
	Box:SetChecked(CO.db.global.misc.collectionsShowHelmet)
end

function Module:LoadCollections()
	if WardrobeCollectionFrame and WardrobeCollectionFrame.SetsCollectionFrame and WardrobeCollectionFrame.SetsCollectionFrame.Model then
		DressUpFrame = WardrobeCollectionFrame.SetsCollectionFrame.Model
		InitModelHook()
		self:AddCheckbox()
	end
end

function Module:LoadConfig()
	Module:UpdateHelmet()
end

function Module:Init()
	E:FireOnAddOnLoaded(self, "LoadCollections", "Blizzard_Collections")
	
	--[[if not WardrobeCollectionFrame then
		EventListener:SetScript("OnEvent", function(self, event, AddOn)
			if C_AddOns_IsAddOnLoaded(AddOn) then
				if AddOn == 'Blizzard_Collections' then
					Module:LoadCollections()
				end
			end
		end)
		EventListener:RegisterEvent("ADDON_LOADED")
	else
		self:LoadCollections()
	end]]--
	
end

E:AddModule("Blizzard_CollectionsFrame", Module)