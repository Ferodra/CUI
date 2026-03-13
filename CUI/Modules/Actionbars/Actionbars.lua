local E, L = unpack(select(2, ...)) -- Engine, Locale
local Module, CO, TT = E:LoadModules('Actionbars', 'Config', 'Tooltip')

local _


local pairs						= pairs
local format					= string.format
local CreateFrame				= CreateFrame
local SetOverrideBindingClick	= SetOverrideBindingClick
local ClearOverrideBindings		= ClearOverrideBindings
local C_PetBattles_IsInBattle	= C_PetBattles.IsInBattle
local SetBinding				= SetBinding
local GetBindingKey				= GetBindingKey
local hooksecurefunc			= hooksecurefunc
local InCombatLockdown			= InCombatLockdown
local GetCVarBool 				= C_CVar.GetCVarBool


local LAB10 = LibStub('LibActionButton-1.0-CUI')
local LibKeyBound = LibStub('LibKeyBound-1.0-CUI')

Module.ActionBars				= {}
Module.ActionButtons 			= {}

Module.ACTIONBUTTON_SIZE 						= 40 -- X and Y size
Module.ACTIONBUTTON_GAP 						= 5 -- X gap
Module.ACTIONBAR_NUM							= 10 -- Everything above bar 7 is already reserved by shapeshift buttons. Use with caution
Module.ACTIONBAR_NUM_BUTTONS					= 12
local NUM_ACTIONBAR_MAXPAGES				= 18 -- Used for how many potential pages should be considered for actionbutton paging

Module.ACTIONBUTTON_TEXTURE_BACKDROP			= [[Interface/AddOns/CUI/Textures/buttons/ActionButton1Backdrop]]
Module.ACTIONBUTTON_TEXTURE_HIGHLIGHT			= [[Interface/AddOns/CUI/Textures/buttons/ActionButton1Highlight]]
Module.ACTIONBUTTON_TEXTURE_PUSHED				= [[Interface/AddOns/CUI/Textures/buttons/ActionButton1Pushed]]
Module.ACTIONBUTTON_TEXTURE_BORDER				= [[Interface/AddOns/CUI/Textures/buttons/ActionButton1Border]]


E:RegisterEvents(Module, 'PET_BATTLE_OPENING_DONE', 'PET_BATTLE_CLOSE', 'PLAYER_SPECIALIZATION_CHANGED', 'UPDATE_BINDINGS', 'CVAR_UPDATE','TRADE_SKILL_CLOSE', 'ACTIONBAR_UPDATE_USABLE', 'PLAYER_MOUNT_DISPLAY_CHANGED', 'UPDATE_BONUS_ACTIONBAR', 'UPDATE_VEHICLE_ACTIONBAR', 'UPDATE_OVERRIDE_ACTIONBAR', 'ACTIONBAR_PAGE_CHANGED', 'UPDATE_MACROS', 'ADDON_LOADED', 'PLAYER_TARGET_CHANGED', 'PLAYER_ENTERING_WORLD', 'ACTIONBAR_SLOT_CHANGED', 'UPDATE_SHAPESHIFT_FORM', 'ACTIONBAR_UPDATE_COOLDOWN', 'SPELL_UPDATE_COOLDOWN', 'LOSS_OF_CONTROL_ADDED', 'LOSS_OF_CONTROL_UPDATE')

-- /dump GetBindingKey("CUIBAR6BUTTON2")
Module.Bindings = {
	[1] = {
		['binding'] = 'ACTIONBUTTON',
		['page'] = 1,
	},
	[2] = {
		['binding'] = 'MULTIACTIONBAR2BUTTON',
		['page'] = 5,
	},
	[3] = {
		['binding'] = 'MULTIACTIONBAR1BUTTON',
		['page'] = 6,
	},
	[4] = {
		['binding'] = 'MULTIACTIONBAR4BUTTON',
		['page'] = 4,
	},
	[5] = {
		['binding'] = 'MULTIACTIONBAR3BUTTON',
		['page'] = 3,
	},
	[6] = {
		['binding'] = 'CUIBAR6BUTTON',
		['page'] = 2,
	},
	[7] = {
		['binding'] = 'CUIBAR7BUTTON',
		['page'] = 8,
	},
	[8] = {
		['binding'] = 'CUIBAR8BUTTON',
		['page'] = 7,
	},
	[9] = {
		['binding'] = 'CUIBAR9BUTTON',
		['page'] = 9,
	},
	[10] = {
		['binding'] = 'CUIBAR10BUTTON',
		['page'] = 10,
	},
}
Module.PagingDefaults = {
	['ROGUE'] = '[bonusbar:1] 7;',
	['DRUID'] = '[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 7; [bonusbar:2] 10; [bonusbar:3] 9; [bonusbar:4] 10;',
	['EVOKER'] = '[bonusbar:1] 7;',
	['PRIEST'] = '[bonusbar:1] 7;',
	['WARRIOR'] = '[bonusbar:1] 7; [bonusbar:2] 9; [bonusbar:3] 10;'
}

function Module:UpdateArtFill()
	self.db = CO.db.profile.actionbar
	self.dbFill = nil
	
	for k, v in pairs(self.ActionBars) do
		if v.ConfigKey then
			self.dbFill = self.db[v.ConfigKey].artFill
			if self.dbFill.enable then
				if not v.ArtFill then
					self:CreateArtFill(v)
				end
				
				-----------------------
				v.ArtFill:ClearAllPoints()
				v.ArtFill:SetPoint('TOPLEFT', v, 'TOPLEFT', self.dbFill.paddingX * (-1), self.dbFill.paddingY)
				v.ArtFill:SetPoint('BOTTOMRIGHT', v, 'BOTTOMRIGHT', self.dbFill.paddingX, self.dbFill.paddingY * (-1))
				v.ArtFill.Border.SetBorderSize(self.dbFill.borderSize)
				v.ArtFill.Border:SetBackdropBorderColor(self.dbFill.borderColor[1], self.dbFill.borderColor[2], self.dbFill.borderColor[3], self.dbFill.borderColor[4] or 1)
				v.ArtFill.Background:SetColorTexture(self.dbFill.backgroundColor[1], self.dbFill.backgroundColor[2], self.dbFill.backgroundColor[3], self.dbFill.backgroundColor[4] or 1)
				
				v.ArtFill:SetFrameStrata('BACKGROUND')
				v.ArtFill:SetFrameLevel(1)
				
				-----------------------
				v.ArtFill:Show()
			else
				if v.ArtFill then v.ArtFill:Hide() end
			end
		end
	end
end

function Module:CreateArtFill(frame)
	frame.ArtFill = CreateFrame('Frame', frame:GetName() .. "ArtFill", frame)
	
	frame.ArtFill:SetFrameStrata('BACKGROUND')
	frame.ArtFill:SetFrameLevel(0)
	
	frame.ArtFill.Border = E:CreateBorder(frame.ArtFill, nil, 1)
	frame.ArtFill.Background = E:CreateBackground(frame.ArtFill)
end

function Module:UpdateMasque()
	if CO.db.char.actionbar.useMasque and self.Masque then
		if not self.MasqueGroup then
			self.MasqueGroup = self.Masque:Group('CUI', L['Actionbars'])
		end
		--self.MasqueGroup:Enable()
	elseif not CO.db.char.actionbar.useMasque and self.MasqueGroup then	
		--self.MasqueGroup:Disable()
	end
	
	for k, v in pairs(self.ActionButtons) do
		self:ActionButton_AddMasque(v)
	end
end

function Module:LoadConfig()
	for i=1,12 do self:UpdateActionbar('bar' .. i) end
	self:UpdateActionbar('stancebar')
	self:UpdateActionbar('petbar')
	self:UpdateZoneActionButton()
	self:UpdateExtraActionButton()
	self:UpdateExtraAbilty()
	self:UpdateMicroMenu()
	
	self:UpdateMasque()
	
	self:UpdateActionButtonStyle() -- Apply all cosmetic configs
	self:UpdateArtFill() -- Background and border for the whole actionbar frame (not buttons)
	self:UpdateAllFlashes() -- Cosmetic button flashes
end

local function UpdateButtonTexture(Texture, Button, ButtonName, Width, Height, BlendMode, Color)
	if E:DoesStringPartExist(ButtonName, 'Stance') then
		Texture:SetTexCoord(1,2,1,2) -- Alternate Tex Coord for smaller buttons
	else
		Texture:SetTexCoord(0,1,0,1)
	end
	
	Texture:ClearAllPoints()
	Texture:SetAllPoints(Button)
	
	Texture:SetSize(Width, Height)
	Texture:SetBlendMode(BlendMode)
	Texture:SetVertexColor(unpack(Color))
end

function Module:UpdateButtonStyle(Button, Config)
		
		local HighlightTexture = Button:GetHighlightTexture()
		local NormalTexture = Button.NormalTexture or _G[Button:GetName()..'NormalTexture']
		local PushedTexture = Button:GetPushedTexture()
		local CheckedTexture = Button:GetCheckedTexture()
		local ButtonName = E:GetFullFrameName(Button)
		
		Button.Border:Show()
		
		Button.SlotBackground:Hide()
		Button.SlotArt:Hide()
		
		if Button.__MSQ_Normal then
			Button.__MSQ_Normal:Hide()
		end
	
		-- Button border is included within the icons themselves (WHY, BLIZZARD?!)
		Button.icon:SetTexCoord(0.06,0.94,0.06,0.94)
		Button.icon:ClearAllPoints()
		local Offset = 2
		Button.icon:SetPoint("TOPLEFT", Button, "TOPLEFT", Offset, -Offset)
		Button.icon:SetPoint("BOTTOMRIGHT", Button, "BOTTOMRIGHT", -Offset, Offset)
		
		Button.OverrideNormalTexture1 = Module.ACTIONBUTTON_TEXTURE_BACKDROP
		Button.OverrideNormalTexture2 = Module.ACTIONBUTTON_TEXTURE_BACKDROP
		NormalTexture:SetTexture(Module.ACTIONBUTTON_TEXTURE_BACKDROP)
		
		--Button:SetNormalTexture(Module.ACTIONBUTTON_TEXTURE_BACKDROP)
		Button:SetHighlightTexture(Module.ACTIONBUTTON_TEXTURE_HIGHLIGHT)
		Button:SetPushedTexture(Module.ACTIONBUTTON_TEXTURE_PUSHED)
		Button:SetCheckedTexture(Module.ACTIONBUTTON_TEXTURE_PUSHED)
		Button.Border:SetTexture(Module.ACTIONBUTTON_TEXTURE_BORDER)
		
		Button.icon:SetDrawLayer('BACKGROUND', 0)
		
		PushedTexture:SetDrawLayer('BACKGROUND', 0)
		Button.Border:ClearAllPoints()
		Button.Border:SetPoint('CENTER', Button, 'CENTER', 0, 0)
		Button.Border:SetDrawLayer('ARTWORK', 1)
		NormalTexture:SetDrawLayer('BACKGROUND', 0)
		PushedTexture:SetDrawLayer('OVERLAY', 0)
		
		local Padding = 6
		local Width, Height = Button:GetWidth(), Button:GetHeight()
		
		Button.Border:SetSize(Width+Padding,Height+Padding)
		Button.Border:SetBlendMode(Config['borderTextureBlendMode'])
		Button.Border:SetVertexColor(unpack(Config['borderTextureColor']))
		Button.BorderColor = Config['borderTextureColor']
		
		UpdateButtonTexture(NormalTexture, Button, ButtonName, Width, Height, Config['normalTextureBlendMode'], Config['normalTextureColor'])
		UpdateButtonTexture(PushedTexture, Button, ButtonName, Width, Height, Config['pushedTextureBlendMode'], Config['pushedTextureColor'])
		UpdateButtonTexture(CheckedTexture, Button, ButtonName, Width, Height, Config['pushedTextureBlendMode'], Config['pushedTextureColor'])
		UpdateButtonTexture(HighlightTexture, Button, ButtonName, Width, Height, Config['highlightTextureBlendMode'], Config['highlightTextureColor'])
	end

-- /dump CUI:LoadModule('Actionbars'):UpdateActionButtonStyle()
function Module:UpdateActionButtonStyle(Button)
	local db = CO.db.profile.actionbar['global']
	local Config = {}
	
	-- Cache configs in a more easily accessible way
	-- We should just migrate all r,g,b,a tables to an indexed one, so this is only a (permanent) temporary solution
	for k, v in pairs(db) do
		if type(v) == 'table' and (v.r and v.g and v.b and v.a) then
			Config[k] = {}
			Config[k][1] = v.r
			Config[k][2] = v.g
			Config[k][3] = v.b
			Config[k][4] = v.a
		else
			Config[k] = v
		end
	end
	
	if not (CO.db.char.actionbar.useMasque == true and self.Masque) then
		if Button then
				self:UpdateButtonStyle(Button, Config)
		else
			for _, Button in pairs(Module.ActionButtons) do
				self:UpdateButtonStyle(Button, Config)
			end
		end
	end
end

function Module:ClearButtonHighlight()
	for _, Button in pairs(self.Buttons) do
		
	end
end

function Module:UpdateButtonHighlight(SpellID)
	-- Called through UpdateOnBarHighlightMarksBySpell
	
	for _, Button in pairs(self.Buttons) do
		
	end
	-- Cleared by ClearOnBarHighlightMarks
end

function Module:ReassignBindings()
	if InCombatLockdown() then return end
	
	for _, Bar in pairs(self.ActionBars) do
		self:UpdateConfig(Bar)
	end
	
	self:UpdateZoneActionButtonBinding()
end

function Module:UpdateBarFade(self)
	if not self:GetAttribute("IsShown") then return end
	if self.isActive or self.isHovered then
		E:UIFrameFadeIn(self, self.fadeInSpeed, self:GetAlpha(), self.alphaActive)
	else
		E:UIFrameFadeOut(self, self.fadeOutSpeed, self:GetAlpha(), self.alphaInactive)
	end
end

function Module:UpdateCombatFaderState(self, inCombat)		
	if self.CombatFade == 'fadeOut' or self.CombatFade == 'fadeIn' then
		if inCombat then
			if self.CombatFade == 'fadeOut' then
				self.isActive = false
			elseif self.CombatFade == 'fadeIn' then
				self.isActive = true
			end
		else
			if self.CombatFade == 'fadeOut' then
				self.isActive = true
			elseif self.CombatFade == 'fadeIn' then
				self.isActive = false
			end
		end
	elseif self.CombatFade == 'custom' then
		self.isActive = inCombat
	elseif self.showOnMouseOver == true then
		self.isActive = false
	else
		self.isActive = true
	end
	
	Module:UpdateBarFade(self)
end

-- Mouseover functionality
function Module:UpdateBarFadeHoverState(self, state)
	if not self.showOnMouseOver then 
		self.isHovered = nil
	elseif state == 'enter' then
		self.isHovered = true
	elseif state == 'leave' then
		self.isHovered = nil
	end
	
	Module:UpdateBarFade(self)
end

function Module:Bar_VisibilityOnAttributeChanged(name, value)
	if name ~= 'state-fade' or not self.useCustomFadeCondition then return end
	value = tonumber(value)
	
	if not value or value == 0 then
		Module:UpdateCombatFaderState(self, false)
	else
		Module:UpdateCombatFaderState(self, true)
	end
end

function Module:BarMOver_OnEnter()
	if not self:GetAttribute('IsShown') then return end
	
	Module:UpdateBarFadeHoverState(self, 'enter')
end
function Module:BarMOver_OnLeave()
	if not self:GetAttribute('IsShown') then return end
	
	Module:UpdateBarFadeHoverState(self, 'leave')
end

function Module:BarMOverButton_OnEnter()
	if not self.Parent:GetAttribute('IsShown') then return end
	
	Module:UpdateBarFadeHoverState(self.Parent, 'enter')
end
function Module:BarMOverButton_OnLeave()
	if not self.Parent:GetAttribute('IsShown') then return end
	
	Module:UpdateBarFadeHoverState(self.Parent, 'leave')
end

function Module:InitBarFader()
	for k, Bar in pairs(self.ActionBars) do
		if not self.CombatFader then
			self.CombatFader = CreateFrame('Frame', 'CUI_CombatFaderFrame')
		end
		
		self.CombatFader:RegisterEvent('PLAYER_REGEN_ENABLED')
		self.CombatFader:RegisterEvent('PLAYER_REGEN_DISABLED')
		
		self.CombatFader:SetScript('OnEvent', function(self, event, ...)
			for k, v in pairs(Module.ActionBars) do
				if v:GetAttribute('IsShown') and not v.useCustomFadeCondition then
					Module:UpdateCombatFaderState(v, event == 'PLAYER_REGEN_DISABLED')
				end
			end
			
		end)
	end
end

local FlashDefaults = {
	enable = false,
	blendMode = "ADD",
	drawLayer = "OVERLAY",
	drawLayerSubLevel = 5,
	fadeInTime = 0.025,
	fadeOutTime = 0.25,
	rgba = {1,1,1, 1},
	forceTexture = nil, -- Path or nil
}
local function merge(target, source, default)
	for k,v in pairs(default) do
		if type(v) ~= "table" then
			if source and source[k] ~= nil then
				target[k] = source[k]
			else
				target[k] = v
			end
		else
			if type(target[k]) ~= "table" then target[k] = {} else wipe(target[k]) end
			merge(target[k], type(source) == "table" and source[k], v)
		end
	end
	return target
end
local function DoFlash(self, button, state)
	-- This portion is called when the action actually would be used
	if self.flashConfig.enable and (self:GetAttribute("type") == "action" or self.IsStanceButton or self.IsPetButton) then		
		if state == GetCVarBool('ActionButtonUseKeyDown') then
			if E:UIFrameIsFlashing(self.flashOverlay) then
				E:UIFrameFlashStop(self.flashOverlay)
			end
			
			E:UIFrameFlash(self.flashOverlay, self.flashConfig.fadeInTime, self.flashConfig.fadeOutTime, (self.flashConfig.fadeInTime + self.flashConfig.fadeOutTime), false, 0, 0)
		end
	end
end

local function Flash_OnFinished(self)
	self.Owner.flashOverlay:Hide()
end
function Module:LoadFlashAnimation()
	if not self.flashOverlay.alphaAnimation then
		local Group = self.flashOverlay:CreateAnimationGroup()
		Group.Owner = self
		Group:SetScript('OnFinished', Flash_OnFinished)
		
		local FadeIn = Group:CreateAnimation("Alpha")
		local FadeOut = Group:CreateAnimation("Alpha")
		
		FadeIn:SetFromAlpha(0)
		FadeIn:SetToAlpha(1)
		FadeIn:SetOrder(1)
		
		FadeOut:SetFromAlpha(1)
		FadeOut:SetToAlpha(0)
		FadeOut:SetOrder(2)
		
		self.flashOverlay.alphaAnimation = Group
		self.flashOverlay.FadeIn = FadeIn
		self.flashOverlay.FadeOut = FadeOut
	end
	
	self.flashOverlay.FadeIn:SetDuration(self.flashConfig.fadeInTime)
	self.flashOverlay.FadeOut:SetDuration(self.flashConfig.fadeOutTime)
end

function Module:SetupFlash()
	if not self.flashConfig then
		self.flashConfig = {}
		merge(self.flashConfig, FlashDefaults, FlashDefaults)
	end
	
	local config = self.flashConfig
	if not config.enable then return end
	
	local flash = self.flashOverlay or self:CreateTexture("FLASHOVERLAY", "OVERLAY")
	if not config.forceTexture then
		flash:SetColorTexture(config.rgba[1], config.rgba[2], config.rgba[3], config.rgba[4])
	else
		flash:SetTexture(config.forceTexture)
		flash:SetVertexColor(unpack(config.forceTextureRGBA))
	end
	
	flash:SetBlendMode(config.blendMode)
	flash:SetDrawLayer(config.drawLayer, config.drawLayerSubLevel)
	flash:SetAlpha(0)
	
	local ParentFrame = config.showAboveCooldown and self.Overlay or self
	flash:ClearAllPoints()
	flash:SetAllPoints(ParentFrame)
	flash:SetParent(ParentFrame)
	
	if not self.flashOverlay then
		self.flashOverlay = flash
		self:HookScript("OnClick", DoFlash)
		--Module.LoadFlashAnimation(self)
	end
end

local function UpdateButtonFlash(self, Config)
	if not Config then return end
	if not self.flashConfig then
		self.flashConfig = {}
	end
	
	self.flashConfig.enable 			= Config.enable
	self.flashConfig.showAboveCooldown 	= Config.showAboveCooldown
	self.flashConfig.blendMode 			= Config.blendMode
	self.flashConfig.drawLayer 			= Config.drawLayer
	self.flashConfig.drawLayerSubLevel 	= Config.drawLayerSubLevel
	self.flashConfig.fadeInTime 		= Config.fadeInTime
	self.flashConfig.fadeOutTime 		= Config.fadeOutTime
	self.flashConfig.rgba 				= E:ParseDBColor(Config.rgba, "player")
	self.flashConfig.forceTexture 		= Config.forceTexture
	
	if self.flashOverlay then
		--Module.LoadFlashAnimation(self)
	end
	
	Module.SetupFlash(self)
end

function Module:UpdateAllFlashes()
	local Config
	for _, Bar in pairs(self.ActionBars) do
		if Bar.buttons then
			Config = CO.db.profile.actionbar[Bar.ConfigKey].flash
			
			for _, Button in pairs(Bar.buttons) do
				UpdateButtonFlash(Button, Config)
			end
		end
	end
end

--[[
	Expected settings:
	
	- Enable / Disable
	- A scale multiplier (This also has to move the hotkey and macro texts)
	- Setting the actual gap
	- Initial anchor move handler
	- Buttons per row
	- Total Buttons
	
	Optional: 
	
	- Movable individual buttons
]]--
function Module:UpdateActionbar(bar)
	-- Fix for config, as we only pass the bar number from there
	if tonumber(bar) then
		bar = 'bar' .. bar
	end
	local Bar = self.ActionBars[bar]
	
	if not Bar then return end
	
	local Config = CO.db.profile.actionbar[Bar.ConfigKey]
	if not Config then return end
	
	if not Config.enable then
		Bar.ForceMoverEnabled = false
	else
		Bar.ForceMoverEnabled = nil
	end
	-- Hide when disabled. Show when enabled and visibility condition is met
	if not Config.enable then
		Bar:Hide();
		return
	else
		if SecureCmdOptionParse(Config.visibilityCondition) == '1' then
			Bar:Show()
		end
	end
	
	Bar:SetIgnoreParentAlpha(true)
	
	Bar.cooldownFormat = Config.cooldownFormat
	
	UnregisterStateDriver(Bar, 'visible')
	UnregisterStateDriver(Bar, 'page')
	
	RegisterStateDriver(Bar, 'visible', Config.visibilityCondition)
	
	Bar.CombatFade = Config.fadeInCombat
	if Bar.CanBeFaded then
		Bar.showOnMouseOver = Config.showOnMouseOver
		Bar.alphaActive = Config.alphaActive
		Bar.alphaInactive = Config.alphaInactive
		Bar.fadeInSpeed = Config.fadeInSpeed
		Bar.fadeOutSpeed = Config.fadeOutSpeed
		Bar.useCustomFadeCondition = true
		Bar.fadeCondition = Bar.CombatFade == 'custom' and Config.fadeCondition or '[combat] 1; 0'
		
		if Bar:GetAttribute('IsShown') then
			if Bar.useCustomFadeCondition then
				Module.Bar_VisibilityOnAttributeChanged(Bar, 'state-fade', SecureCmdOptionParse(Bar.fadeCondition))
			else
				Module:UpdateCombatFaderState(Bar, InCombatLockdown())
			end
		end
		
		-- Custom Fader Conditional
		if Bar.useCustomFadeCondition then
			RegisterStateDriver(Bar, 'fade', Bar.fadeCondition)
			if not Bar.AttrIsHooked then
				Bar:HookScript('OnAttributeChanged', self.Bar_VisibilityOnAttributeChanged)
				Bar.AttrIsHooked = true
			end
		end
	end
	
	if Bar.BarIndex then
		if Bar.BarIndex > 1 then
			RegisterStateDriver(Bar, 'page', Module.Bindings[Bar.BarIndex].page)
			Bar:SetAttribute('page', Module.Bindings[Bar.BarIndex].page)
		else
			local fullConditions = format('[overridebar] %d; [vehicleui][possessbar] %d;', GetOverrideBarIndex(), GetVehicleBarIndex())
			local Condition = fullConditions..format('[shapeshift] %d; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6; [bonusbar:5] 11;', GetTempShapeshiftBarIndex())
			
			if Module.PagingDefaults[E.PlayerClassName] then
				Bar.pagingCondition = Condition .. ' ' .. Module.PagingDefaults[E.PlayerClassName] .. ' 1'
			else
				Bar.pagingCondition = Condition .. ' 1'
			end
			
			RegisterStateDriver(Bar, 'page', Bar.pagingCondition)
			Bar:SetAttribute('page', Bar.pagingCondition)
		end		
		
		Module:UpdateConfig(Bar)
	end
	
	local ButtonParent = Bar
	for k, child in ipairs(Bar.buttons) do			
		child.IgnoreSort = nil
		
		if Bar.ConfigKey ~= 'stancebar' and Bar.ConfigKey ~= 'petbar' then
			if k > Config.buttonNum then
				child:Hide(); child:SetAttribute('enable', false)
				child.IgnoreSort = true
			else
				child:Show()
				child:SetAttribute('enable', true)
			end
		end
		
		if bar == 'stancebar' and child.Border then
			child.Border:SetSize(Module.ACTIONBUTTON_SIZE + 5, Module.ACTIONBUTTON_SIZE + 5)
		end
		
		if bar == 'petbar' and child.Flash then
			
			-- That frame is such a Murloc
			child.Flash:SetScale(0.55)
		end
		
		child:SetSize(child.overrideSize or Module.ACTIONBUTTON_SIZE, child.overrideSize or Module.ACTIONBUTTON_SIZE)
		child:SetScale(Config.buttonSizeMultiplier)
	end
	
	if bar == 'stancebar' then
		Module:UpdateActiveStanceButtons()

		return
	end
	local NewWidth, NewHeight = E:SortFrames(Bar.buttons, ButtonParent, nil, nil, Config.buttonSizeMultiplier, Config.buttonsPerRow, nil, nil, Config.buttonGap, Config.buttonGap, true, false)
	Bar:SetSize(NewWidth, NewHeight)
	
	E:LoadMoverPositions(Bar)
	E:UpdateMoverDimensions(Bar)
end

local function ButtonKeybind_OnEnter(self)
	if not Module.keyRebind then return end
	
	if (self.GetHotkey) then
		LibKeyBound:Set(self)
	end
end

function Module:CreateActionBars()

	local barName, actionBar, buttonName, actionButton
	

	for b=1, self.ACTIONBAR_NUM do
		
		barName = 'CUI_ActionBar' .. b
		
		actionBar = CreateFrame('Frame', barName, E.Parent, 'SecureHandlerStateTemplate')
		--actionBar:SetFrameRef('MainMenuBar', MainMenuBarArtFrame)
		--SecureHandlerSetFrameRef(actionBar, 'MainMenuBarArtFrame', _G.MainMenuBarArtFrame)
		actionBar:SetSize((self.ACTIONBUTTON_SIZE + self.ACTIONBUTTON_GAP)*(12) - 24, self.ACTIONBUTTON_SIZE)
		
		actionBar.ConfigKey = 'bar' .. b
		actionBar.BarIndex = b
		
	-- Init Button Container
		actionBar.buttons = {}
	-- Set bindings base to bar
		actionBar.bindButtons = self.Bindings[b].binding
	-- Register actionbar
		self.ActionBars["bar" .. b] = actionBar

	-- Set visibility driver (This is user controlled through the config dialog)
	-- StateDriver is registered in the config
		E:SetVisibilityHandler(actionBar)
		actionBar:SetAttribute('_onstate-page', [[
			if newstate == 'possess' or newstate == '11' then
				if HasVehicleActionBar() then
					newstate = GetVehicleBarIndex()
				elseif HasOverrideActionBar() then
					newstate = GetOverrideBarIndex()
				elseif HasTempShapeshiftActionBar() then
					newstate = GetTempShapeshiftBarIndex()
				elseif HasBonusActionBar() then
					newstate = GetBonusBarIndex()
				else
					newstate = 12
				end
			end
			
			self:SetAttribute('state', newstate)
			control:ChildUpdate('state', newstate)
		]])
		
		E:CreateMover(actionBar, L['actionbarFrame'] .. ' ' .. b, nil, nil, nil, nil, "actionbars")
		
		actionBar:SetScript('OnEnter', Module.BarMOver_OnEnter)
		actionBar:SetScript('OnLeave', Module.BarMOver_OnLeave)

		actionBar.CanBeFaded = true
		actionBar.pagingCondition = "1"
	
		-- Create Module.ACTIONBAR_NUM_BUTTONS (12) buttons per bar
		for i=1, self.ACTIONBAR_NUM_BUTTONS do
			
		-- Button Name
			buttonName = format('CUI_ActionBar%sButton%s', b, i)
			
		-- Create new Button object through LibAB
			actionButton = LAB10:CreateButton(i, buttonName, actionBar)
		-- Register created button
			self.ActionButtons[buttonName] = actionButton
			
		-- Cache parent because we will have to reference to it pretty often
			actionButton.Parent = actionBar
			actionButton.cooldown.Parent = actionBar
		
			for k = 1, NUM_ACTIONBAR_MAXPAGES do
				actionButton:SetState(k, 'action', (k - 1) * 12 + i)
			end
			actionButton:SetState(0, 'action', i)
			actionButton:SetAttribute('buttonlock', GetCVarBool('lockActionBars'))
			
			actionButton.index = i
			
			--actionButton.Overlay = CreateFrame('Frame', nil, actionButton.cooldown)
			--actionButton.Overlay:SetAllPoints(actionButton.cooldown)
			actionButton.Overlay = CreateFrame('Frame', "CUI_ActionButtonOverlayFrame", actionButton)
			actionButton.Overlay:SetAllPoints(actionButton)
			self:CreateCooldownText(actionButton)
			hooksecurefunc(actionButton.cooldown, 'SetCooldown', self.OnSetCooldown)
			actionButton.cooldown:SetHideCountdownNumbers(true)
			
			actionButton.cooldown:Hide()
			
			-- N.E.V.E.R use ActionButton_GetOverlayGlow, as it WILL Taint something on Blizzards end and then throw errors
			--actionButton.Glow = ActionButton_GetOverlayGlow(actionButton)
			
			-- Register Fonts with corresponding database path to automate updates
			actionButton.HotKey.__MSQ_Hooked = true -- Trick Masque into thinking it already has control over the text position
			E:RegisterAutoFont(actionButton.HotKey, 'db.profile.actionbar.bar' .. b .. '.hotkey')
			E:RegisterAutoFont(actionButton.cooldown.cooldownText, 'db.profile.actionbar.bar' .. b .. '.cooldown')
			E:RegisterAutoFont(actionButton.Count, 'db.profile.actionbar.bar' .. b .. '.count')
			E:RegisterAutoFont(actionButton.Name, 'db.profile.actionbar.bar' .. b .. '.macro')
			
		-- Add LibAB methods
			actionButton.GetHotkey 		= self.GetHotkey
			actionButton.SetKey 		= self.ActionButton_SetKey
			actionButton.ClearBindings 	= self.ActionButton_ClearBindings
			actionButton.GetBindings 	= self.ActionButton_GetBindings
			
		-- Workaround for tooltips of macros, pets and toys
			actionButton:HookScript('OnEnter', self.ActionButton_OnEnter)
			actionButton:HookScript('OnLeave', self.ActionButton_OnLeave)
			
			actionButton:HookScript('OnEnter', Module.BarMOverButton_OnEnter)
			actionButton:HookScript('OnLeave', Module.BarMOverButton_OnLeave)
			
			actionButton:HookScript('OnEnter', ButtonKeybind_OnEnter)
			
			
			actionBar.buttons[i] = actionButton
		end
		
		self:UpdateConfig(actionBar)
	end
end

function Module:ActionButton_AddMasque(actionButton)
	if CO.db.char.actionbar.useMasque == true and self.Masque and not actionButton.HasMasque then
		
		local buttonData = {
			Icon = actionButton.icon,
			Cooldown = actionButton.cooldown,
			Normal = actionButton:GetNormalTexture(),
			Pushed  = actionButton:GetPushedTexture(),
			Border = actionButton.Border
		}
		
		actionButton.HasMasque = true
	
		self.MasqueGroup:AddButton(actionButton, buttonData)
	elseif not CO.db.char.actionbar.useMasque == true and actionButton.HasMasque then
		actionButton.HasMasque = nil
		
		if self.MasqueGroup then
			--self.MasqueGroup:RemoveButton(actionButton)
		end
	end
end

function Module:ActionButton_GetBindings()
	local BindButton = self:GetParent().bindButtons
	local ButtonIndex = self.index
	
	local keys = ''
	
	for i = 1, select('#', GetBindingKey(BindButton .. ButtonIndex)) do
		
		local hotKey = select(i, GetBindingKey(BindButton .. ButtonIndex))
		if keys ~= '' then
			keys = keys .. ', '
		end
		keys = keys .. GetBindingText(hotKey, 'KEY_')
	end
	
	return keys
end

function Module:ActionButton_SetKey(key)
	local BindButton = self:GetParent().bindButtons
	local ButtonIndex = self.index
	
	-- /dump SetBinding("SHIFT-G", "EXTRABAR6BUTTON2")
	local Success = SetBinding(key, BindButton .. ButtonIndex)
	print(Success, BindButton, ButtonIndex, key)
	
	Module:ReassignBindings()
end

function Module:ActionButton_ClearBindings()
	local Key = GetBindingKey(format('%s%s', self:GetParent().bindButtons, self.index))
	if not Key then return end
	
	SetBinding(Key, nil)
	
	Module:ReassignBindings()
end

function Module:ActionButton_OnEnter()
	E.TooltipOwnedByActionButton = true
	TT:UpdateStyle(GameTooltip, true)
end

function Module:ActionButton_OnLeave()
	E.TooltipOwnedByActionButton = nil
end

function Module:ClearBindings()
	if InCombatLockdown() then return end

	for _, Bar in pairs(self.ActionBars) do
		if Bar then
			ClearOverrideBindings(Bar)
		end
	end
end

function Module:UpdateConfig(Bar)
	local Button, Binding, ButtonBinding, BarNum, BarProfile
	
	--if self.keyRebind then return end
	
	if Bar.buttons and not Bar.BlizzBar then
		
		_, BarNum = E:ExtractDigits(Bar:GetName())
		BarProfile = CO.db.profile.actionbar[format('bar%s', BarNum)]
		
		if not Bar.buttonConfig then Bar.buttonConfig = {} end
		
		Bar.buttonConfig.outOfRangeColoring = 'button'
		Bar.buttonConfig.tooltip = BarProfile.showTooltip
		Bar.buttonConfig.showGrid = BarProfile.showGrid
		Bar.buttonConfig.colors = { range = { 0.8, 0.1, 0.1 }, mana = { 0.5, 0.5, 1.0 } }
		Bar.buttonConfig.hideElements = { macro = false, hotkey = false, equipped = false }
		-- Bar.buttonConfig.keyBoundTarget = false
		Bar.buttonConfig.clickOnDown = BarProfile.clickOnDown
		Bar.buttonConfig.flyoutDirection = BarProfile.flyoutDirection
		
		ClearOverrideBindings(Bar)
		
		for i=1, NUM_ACTIONBAR_BUTTONS do
			Button = Bar.buttons[i]
			ButtonBinding = format('%s%s', Bar.bindButtons, i)
			Binding = GetBindingKey(ButtonBinding)
			
			if Binding then
				SetOverrideBindingClick(Bar, false, Binding, Button:GetName())
			end
			
			Bar.buttonConfig.keyBoundTarget = Binding
			
			Button:UpdateConfig(Bar.buttonConfig)
		end
	end
end

function Module:OnSetCooldown(start, duration)
	if start > 0 and duration > 0.5 then
		-- self:Show()
		self.nextUpdate = 0 -- Force Immediate Update
		
		self.start = start
		self.duration = duration
		self:SetScript('OnUpdate', Module.ActionButton_UpdateCooldownText)
	else
		-- self:Hide()
		self:SetScript('OnUpdate', nil)
	end
end

function Module:OnClearCooldown()
	self.cooldownText:SetText('')
end

function Module:ActionButton_UpdateCooldownText(elapsed)
	
	self.update = self.update + elapsed
	if self.update >= (self.nextUpdate or 0) then
		self.durationRemaining = self.duration + (self.start - GetTime())
		
		--print(self.start, self.duration, )
		
		if self.durationRemaining <= 0 then
			self.cooldownText:SetText('')
			
			return
		end
		
		self.nextUpdate = 0.5
		
		if self.duration > 1.5 then
			if not self.Parent.cooldownFormat then
				self.timeRemaining = 0
				if self.durationRemaining > 10 then
					if self.durationRemaining > 60 then
						if self.durationRemaining > 300 then
							if self.durationRemaining > 3600 then
								if self.durationRemaining > (3600 * 24) then
									self.timeRemaining = format('%dd', (self.durationRemaining / (3600 * 24)))
								else
									self.timeRemaining = format('%dh', (self.durationRemaining / 3600))
								end
							else
								self.timeRemaining = format('%dm', (self.durationRemaining / 60))
							end
						else
							self.timeRemaining = format('%d:%02d', self.durationRemaining / 60, self.durationRemaining % 60)
						end
					else
						self.timeRemaining = E:FormatTime(self.durationRemaining)
					end
				else
					self.timeRemaining, self.nextUpdate = E:FormatTime(self.durationRemaining, 1)
					self.nextUpdate = E:GetNumberFormatNextUpdate(self.nextUpdate)
				end
				self.cooldownText:SetText(self.timeRemaining)
			else
				self.nextUpdate = E:WriteNumberFormat(self.cooldownText, self.Parent.cooldownFormat, self.durationRemaining)
			end
		else
			self.cooldownText:SetText('')
		end
		
		self.update = 0
	end
end

function Module:CreateCooldownText(self)
	local Cooldown = self.Cooldown or self.cooldown
	
	if not Cooldown.cooldownText then
		Cooldown.cooldownText = E:NewFontObject(nil, "ARTWORK", Cooldown, 10, 5)
		
		Cooldown.update = 0
	end
end

function Module:GetShortHotkey(key)
	key = gsub(key, 'SHIFT%-', 'S-');
	key = gsub(key, 'ALT%-', 'A-');
	key = gsub(key, 'CTRL%-', 'C-');
	key = gsub(key, 'BUTTON', 'MB');
	key = gsub(key, 'MOUSEWHEELUP', 'MWU');
	key = gsub(key, 'MOUSEWHEELDOWN', 'MWD');
	key = gsub(key, 'NUMPAD', 'NP');
	key = gsub(key, 'PAGEUP', 'PgUp');
	key = gsub(key, 'PAGEDOWN', 'PgDown');
	key = gsub(key, 'SPACE', 'Space');
	key = gsub(key, 'INSERT', 'Ins');
	key = gsub(key, 'HOME', 'Home');
	key = gsub(key, 'DELETE', 'Del');
	key = gsub(key, 'NMULTIPLY', '*');
	key = gsub(key, 'NMINUS', 'N-');
	key = gsub(key, 'NPLUS', 'N+');
	key = gsub(key, 'NEQUALS', 'N=');

	return key or LibKeyBound:ToShortKey(key)
end

function Module:GetHotkey()	
	local name, key
	name = "CLICK "..self:GetName() or (self.config and self.config.keyBoundTarget) ..":LeftButton"
	key = GetBindingKey(self.config and self.config.keyBoundTarget or name)
	
	if not key and self.config.keyBoundTarget and name then
		key = GetBindingKey(name, 1)
		
		if not key then
			key = self.config.keyBoundTarget
		end
	end
	
	if key then
		return Module:GetShortHotkey(key)
	end
end

function Module:SetKeybinderState(state)
	self.keyRebind = state
end

-- Force update of bar 1 paging
function Module:UpdateExtraBar()
	if not InCombatLockdown() then
		local page = SecureCmdOptionParse(Module.ActionBars.bar1.pagingCondition)
		
		RegisterStateDriver(Module.ActionBars.bar1, 'page', Module.ActionBars.bar1.pagingCondition)
		Module.ActionBars.bar1:SetAttribute('page', page)
	end
end

function Module:SetupActionbars()
	self:CreateActionBars()
	self:CreatePetActionBar()
	self:UpdateExtraBar()
	self:InitStanceBar()
	self:InitExtraActionButton()
	self:InitZoneActionButton()
	self:InitExtraAbility()
	self:InitMicroMenu()
	
	self:InitBarFader()
	
	self:LoadConfig()
end

function Module:UpdateDB()
	self.db = CO.db.profile.actionbar
end

function Module:Init()
	self:UpdateDB()
	
	CO = E:LoadModules('Config')
	
	if not CO.db.char.actionbar.enable then return end
	
	self.Masque = E.Libs.Masque
	self:UpdateMasque()
	
	self:SetupActionbars()
	
	self.PageWarningShown = nil
	
	self:SetScript('OnEvent', function(self, event, ...)
		if event == 'UPDATE_BONUS_ACTIONBAR' 
			or event == 'UPDATE_VEHICLE_ACTIONBAR' 
			or event == 'UPDATE_OVERRIDE_ACTIONBAR'
			or event == 'ACTIONBAR_PAGE_CHANGED' then
				if event == 'ACTIONBAR_PAGE_CHANGED' and not Module.PageWarningShown then
					E:print('Warning: You changed the actionbar page. If this was not intentional, it is advised to remove the binding for this action.')
					Module.PageWarningShown = true
				end
			Module:UpdateExtraBar()
		end
		-- Fix for some random bug that appeared first in 8.0.1.
		-- /dump CUI[1]:LoadModule('Actionbars'):InitStanceBar()
		if event == 'PLAYER_SPECIALIZATION_CHANGED' then
			Module:InitStanceBar()
			Module:UpdateExtraBar()
		end
		if event == 'UPDATE_BINDINGS' or event == "PLAYER_ENTERING_WORLD" or event == "PET_BATTLE_CLOSE" then
			Module:ReassignBindings()
		end
		if event == 'CVAR_UPDATE' and select(1, ...) == 'LOCK_ACTIONBAR_TEXT' then
			local val = GetCVarBool('lockActionBars')
			for _, button in pairs(Module.ActionButtons) do
				button:SetAttribute('buttonlock', val)
			end
		end
		if event == 'PET_BATTLE_OPENING_DONE' then
			Module:ClearBindings()
		end
	end)
	
	if C_PetBattles_IsInBattle() then
		Module:ClearBindings()
	end
	
	-- Prevent micromenu from being repositioned in petbattles
	PetBattleFrame.BottomFrame.MicroButtonFrame:SetScript('OnShow', nil)
	
	--hooksecurefunc('MicroButtonAlert_OnShow', function(...) Module:MainMenuMicroButton_RepositionAlerts() end)
	local Blizzard = E:LoadModule('Blizzard')
	Blizzard:RemoveActionbars()
	
	--for k,v in pairs(ActionBarButtonEventsFrame.frames) do
	--	print(k, v:GetName())
	--end
end

E:AddModule('Actionbars', Module)