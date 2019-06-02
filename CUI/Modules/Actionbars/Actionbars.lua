local E, L = unpack(select(2, ...)) -- Engine, Locale
local AB, CO, L, TT = E:LoadModules("Actionbars", "Config", "Locale", "Tooltip")

local _


local pairs						= pairs
local format					= string.format
local CreateFrame				= CreateFrame
local SetOverrideBindingClick	= SetOverrideBindingClick
local ClearOverrideBindings		= ClearOverrideBindings
local SetBinding				= SetBinding
local GetBindingKey				= GetBindingKey
local hooksecurefunc			= hooksecurefunc
local InCombatLockdown			= InCombatLockdown


local LAB10 = LibStub("CUI_LibActionButton-1.0")
local LibKeyBound = LibStub('LibKeyBound-1.0')

AB.ActionBars				= {}
AB.ActionButtons 			= {}

AB.ACTIONBUTTON_SIZE 						= 40 -- X and Y size
AB.ACTIONBUTTON_GAP 						= 5 -- X gap
AB.ACTIONBAR_NUM							= 10 -- Everything above bar 7 is already reserved by shapeshift buttons. Use with caution
AB.ACTIONBAR_NUM_BUTTONS					= 12

AB.ACTIONBUTTON_TEXTURE_BACKDROP			= [[Interface\AddOns\CUI\Textures\buttons\ActionButton1Backdrop]]
AB.ACTIONBUTTON_TEXTURE_HIGHLIGHT			= [[Interface\AddOns\CUI\Textures\buttons\ActionButton1Highlight]]
AB.ACTIONBUTTON_TEXTURE_PUSHED				= [[Interface\AddOns\CUI\Textures\buttons\ActionButton1Pushed]]
AB.ACTIONBUTTON_TEXTURE_BORDER				= [[Interface\AddOns\CUI\Textures\buttons\ActionButton1Border]]


E:RegisterEvents(AB, "PET_BATTLE_OPENING_DONE", "PET_BATTLE_CLOSE", "PLAYER_SPECIALIZATION_CHANGED", "UPDATE_BINDINGS", "CVAR_UPDATE","TRADE_SKILL_CLOSE", "ACTIONBAR_UPDATE_USABLE", "PLAYER_MOUNT_DISPLAY_CHANGED", "UPDATE_BONUS_ACTIONBAR", "UPDATE_VEHICLE_ACTIONBAR", "UPDATE_OVERRIDE_ACTIONBAR", "ACTIONBAR_PAGE_CHANGED", "UPDATE_MACROS", "ADDON_LOADED", "PLAYER_TARGET_CHANGED", "PLAYER_ENTERING_WORLD", "ACTIONBAR_SLOT_CHANGED", "UPDATE_SHAPESHIFT_FORM", "ACTIONBAR_UPDATE_COOLDOWN", "SPELL_UPDATE_COOLDOWN", "LOSS_OF_CONTROL_ADDED", "LOSS_OF_CONTROL_UPDATE")

AB.Bindings = {
	[1] = {
		["binding"] = "ACTIONBUTTON",
		["page"] = 1,
	},
	[2] = {
		["binding"] = "MULTIACTIONBAR2BUTTON",
		["page"] = 5,
	},
	[3] = {
		["binding"] = "MULTIACTIONBAR1BUTTON",
		["page"] = 6,
	},
	[4] = {
		["binding"] = "MULTIACTIONBAR4BUTTON",
		["page"] = 4,
	},
	[5] = {
		["binding"] = "MULTIACTIONBAR3BUTTON",
		["page"] = 3,
	},
	[6] = {
		["binding"] = "EXTRABAR6BUTTON",
		["page"] = 2,
	},
	[7] = {
		["binding"] = "EXTRABAR7BUTTON",
		["page"] = 8,
	},
	[8] = {
		["binding"] = "EXTRABAR8BUTTON",
		["page"] = 7,
	},
	[9] = {
		["binding"] = "EXTRABAR9BUTTON",
		["page"] = 9,
	},
	[10] = {
		["binding"] = "EXTRABAR10BUTTON",
		["page"] = 10,
	},
}

function AB:UpdateArtFill()
	self.db = CO.db.profile.actionbar
	self.dbFill = nil
	
	for k, v in pairs(self.ActionBars) do
		if v.ProfileName then
			self.dbFill = self.db[v.ProfileName].artFill
			if self.dbFill.enable then
				if not v.artFill then
					self:CreateArtFill(v)
				end
				
				-----------------------
				v.artFill:ClearAllPoints()
				v.artFill:SetPoint("TOPLEFT", v, "TOPLEFT", self.dbFill.paddingX * (-1), self.dbFill.paddingY)
				v.artFill:SetPoint("BOTTOMRIGHT", v, "BOTTOMRIGHT", self.dbFill.paddingX, self.dbFill.paddingY * (-1))
				
				v.artFill.Border.SetBorderSize(self.dbFill.borderSize)
				v.artFill.Border:SetBackdropBorderColor(self.dbFill.borderColor[1], self.dbFill.borderColor[2], self.dbFill.borderColor[3], self.dbFill.borderColor[4] or 1)
				v.artFill.Background:SetColorTexture(self.dbFill.backgroundColor[1], self.dbFill.backgroundColor[2], self.dbFill.backgroundColor[3], self.dbFill.backgroundColor[4] or 1)
				
				v.artFill:SetFrameStrata("BACKGROUND")
				v.artFill:SetFrameLevel(1)
				
				-----------------------
				v.artFill:Show()
			else
				if v.artFill then v.artFill:Hide() end
			end
		end
	end
end

function AB:CreateArtFill(frame)
	frame.artFill = CreateFrame("Frame", nil, frame)
	
	frame.artFill:SetFrameStrata("BACKGROUND")
	frame.artFill:SetFrameLevel(0)
	
	frame.artFill.Border = E:CreateBorder(frame.artFill, nil, 1)
	frame.artFill.Background = E:CreateBackground(frame.artFill)
end

function AB:UpdateMasque()
	if CO.db.profile.actionbar.useMasque and self.Masque then
		if not self.MasqueGroup then
			self.MasqueGroup = self.Masque:Group("CUI", L["Actionbars"])
		end
		self.MasqueGroup:Enable()
	elseif not CO.db.profile.actionbar.useMasque and self.MasqueGroup then	
		self.MasqueGroup:Disable()
	end
	
	for k, v in pairs(self.ActionButtons) do
		self:ActionButton_AddMasque(v)
	end
end

function AB:LoadProfile()
	for i=1,12 do self:UpdateActionbar(i) end
	self:UpdateActionbar("stancebar")
	self:UpdateActionbar("petbar")
	self:UpdateZoneActionButton()
	self:UpdateExtraActionButton()
	self:UpdateMicroMenu()
	
	self:UpdateMasque()
	
	self:UpdateActionButtonStyle()
	self:UpdateArtFill()
end

-- /dump CUI:GetModule("Actionbars"):UpdateActionButtonStyle()
function AB:UpdateActionButtonStyle(Button)
	local Update, db
	local HighlightTexture, NormalTexture, PushedTexture, CheckedTexture, ButtonName, _
	local ClassColor = E:GetUnitClassColor("player")
	
	db = CO.db.profile.actionbar["global"]
	
	Update = function(Button)
		
		HighlightTexture = Button:GetHighlightTexture()
		NormalTexture = Button:GetNormalTexture()
		PushedTexture = Button:GetPushedTexture()
		CheckedTexture = Button:GetCheckedTexture()
		ButtonName = E:GetFullFrameName(Button)
		
		Button.Border:Show()
		NormalTexture:Show()
		
		if Button.__MSQ_NormalTexture then
			Button.__MSQ_NormalTexture:Hide()
		end
	
		-- Button border is included within the icons themselves (WHY, BLIZZARD?!)
		Button.icon:SetTexCoord(0.06,0.94,0.06,0.94)
		Button:SetNormalTexture(AB.ACTIONBUTTON_TEXTURE_BACKDROP)
		Button:SetHighlightTexture(AB.ACTIONBUTTON_TEXTURE_HIGHLIGHT)
		Button:SetPushedTexture(AB.ACTIONBUTTON_TEXTURE_PUSHED)
		Button:SetCheckedTexture(AB.ACTIONBUTTON_TEXTURE_PUSHED)
		Button.Border:SetTexture(AB.ACTIONBUTTON_TEXTURE_BORDER)
		Button.Border:SetTexCoord(0,1,0,1)
		HighlightTexture:SetTexCoord(0,1,0,1)
		PushedTexture:SetTexCoord(0,1,0,1)
		CheckedTexture:SetTexCoord(0,1,0,1)
		
		if E:DoesStringPartExist(ButtonName, "Stance") then
			NormalTexture:SetTexCoord(1,2,1,2) -- Alternate Tex Coord for smaller buttons
		else
			NormalTexture:SetTexCoord(0,1,0,1)
		end
		
		Button.icon:SetDrawLayer("ARTWORK", 0)
		
		PushedTexture:SetDrawLayer("BACKGROUND", 0)
		Button.Border:ClearAllPoints()
		Button.Border:SetPoint("CENTER", Button, "CENTER", 0, 0)
		Button.Border:SetDrawLayer("ARTWORK", 1)
		
		NormalTexture:ClearAllPoints()
		NormalTexture:SetPoint("CENTER", Button, "CENTER", 0, 0)
		NormalTexture:SetDrawLayer("BACKGROUND", 0)
		
		PushedTexture:SetDrawLayer("OVERLAY", 0)
		
		Button.Border:SetSize(Button:GetWidth()+6,Button:GetHeight()+6)
		NormalTexture:SetSize(Button:GetWidth()+6,Button:GetHeight()+6)
		HighlightTexture:SetSize(Button:GetWidth()+6,Button:GetHeight()+6)
		PushedTexture:SetSize(Button:GetWidth()+6,Button:GetHeight()+6)
		CheckedTexture:SetSize(Button:GetWidth()+6,Button:GetHeight()+6)
		
		NormalTexture:SetBlendMode(db["normalTextureBlendMode"]) -- DISABLE for fully opaque background. ADD for transparent but a little too light background
		Button.Border:SetBlendMode(db["borderTextureBlendMode"])
		HighlightTexture:SetBlendMode(db["highlightTextureBlendMode"])
		PushedTexture:SetBlendMode(db["pushedTextureBlendMode"])
		CheckedTexture:SetBlendMode(db["pushedTextureBlendMode"])
		
		NormalTexture:SetVertexColor(db["normalTextureColor"].r, db["normalTextureColor"].g, db["normalTextureColor"].b, db["normalTextureColor"].a)
		Button.Border:SetVertexColor(db["borderTextureColor"].r, db["borderTextureColor"].g, db["borderTextureColor"].b, db["borderTextureColor"].a)
		HighlightTexture:SetVertexColor(db["highlightTextureColor"].r, db["highlightTextureColor"].g, db["highlightTextureColor"].b, db["highlightTextureColor"].a)
		PushedTexture:SetVertexColor(db["pushedTextureColor"].r, db["pushedTextureColor"].g, db["pushedTextureColor"].b, db["pushedTextureColor"].a)
		CheckedTexture:SetVertexColor(db["pushedTextureColor"].r, db["pushedTextureColor"].g, db["pushedTextureColor"].b, db["pushedTextureColor"].a)
		
		Button.BorderColor = db["borderTextureColor"]
		--Button.Border:SetVertexColor(ClassColor[1], ClassColor[2], ClassColor[3], 0.75)
		--NormalTexture:SetVertexColor(ClassColor[1], ClassColor[2], ClassColor[3], 0.75)
		--HighlightTexture:SetVertexColor(ClassColor[1], ClassColor[2], ClassColor[3], 1)
		
		--NormalTexture:RemoveMaskTexture()
		
	end
	
	if not (CO.db.profile.actionbar.useMasque == true and self.Masque) then
		if Button then
				Update(Button)
		else
			for _, Button in pairs(AB.ActionButtons) do
				Update(Button)
			end
		end
	end
end

function AB:ReassignBindings()
	if InCombatLockdown() then return end
	
	for _, Bar in pairs(self.ActionBars) do
		self:UpdateConfig(Bar)
	end
end

-- Mouseover functionality
function AB:BarMouseOver_Fade(self, state)
	
	if not self.showOnMouseOver or (InCombatLockdown() and self.CombatFade == "fadeIn") then return end
	
		if state == "enter" then
			E:UIFrameFadeIn(self, self.fadeInSpeed, self:GetAlpha(), self.alphaActive)
		else
			if InCombatLockdown() then
				E:UIFrameFadeOut(self, self.fadeOutSpeed, self:GetAlpha(), self.alphaInactive)
			else
				if (self.CombatFade ~= "fadeOut") then
					E:UIFrameFadeOut(self, self.fadeOutSpeed, self:GetAlpha(), self.alphaInactive)
				end
			end
		end
end

function AB:BarMOver_OnEnter()
	if not self:GetAttribute("IsShown") then return end
	
	AB:BarMouseOver_Fade(self, "enter")
end
function AB:BarMOver_OnLeave()
	if not self:GetAttribute("IsShown") then return end
	
	AB:BarMouseOver_Fade(self, "leave")
end

function AB:BarMOverButton_OnEnter()
	if not self.Parent:GetAttribute("IsShown") then return end
	
	AB:BarMouseOver_Fade(self.Parent, "enter")
end
function AB:BarMOverButton_OnLeave()
	if not self.Parent:GetAttribute("IsShown") then return end
	
	AB:BarMouseOver_Fade(self.Parent, "leave")
end

function AB:InitCombatFader()
	self.CombatFader = CreateFrame("Frame")
	
	self.CombatFader:RegisterEvent("PLAYER_REGEN_ENABLED")
	self.CombatFader:RegisterEvent("PLAYER_REGEN_DISABLED")
	
	self.CombatFader:SetScript("OnEvent", function(self, event, ...)
		for k, v in pairs(AB.ActionBars) do
			if v:GetAttribute("IsShown") then
				if v.ProfileName then
					local profileData = CO.db.profile.actionbar[v.ProfileName]
					if profileData.fadeInCombat ~= "none" then
					
						if event == "PLAYER_REGEN_DISABLED" then
							if profileData.fadeInCombat == "fadeOut" then
								-- Fade bar out
								E:UIFrameFadeOut(v, profileData.fadeOutSpeed, v:GetAlpha(), profileData.alphaInactive)
							elseif profileData.fadeInCombat == "fadeIn" then
								-- Fade bar in
								E:UIFrameFadeIn(v, profileData.fadeInSpeed, v:GetAlpha(), profileData.alphaActive)
							end
						else
							if profileData.fadeInCombat == "fadeOut" then
								-- Fade bar in
								E:UIFrameFadeIn(v, profileData.fadeInSpeed, v:GetAlpha(), profileData.alphaActive)
							elseif profileData.fadeInCombat == "fadeIn" then
								-- Fade bar out
								E:UIFrameFadeOut(v, profileData.fadeOutSpeed, v:GetAlpha(), profileData.alphaInactive)
							end
						end
					end
				end
			end
		end
		
	end)
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
function AB:UpdateActionbar(bar)
	local index, self, name, moverName, profileName, kids, size, currentRow, currentColumn, profileData, profileMoverData, addSubtract, numDisabled, maxRow, maxColumn
	
	-- Support for StanceBar
	if bar ~= "stancebar" and bar ~= "petbar" then
		name = "CUI_ActionBar" .. bar
		profileName = "bar" .. bar
		
		moverName = name .. "Mover"
		
		self = AB.ActionBars[name]
	elseif bar == "stancebar" then
		name = "CUI_StanceBar"
		profileName = "stancebar"
		
		moverName = name .. "Mover"
		
		self = AB.ActionBars["CUI_StanceBar"] -- Direct use of Blizzard Stancebar
	elseif bar == "petbar" then
		profileName = "petbar"
		
		moverName = "CUI_PetActionbarMover"
		
		self = AB.ActionBars["CUI_PetActionbar"]
	end
	
	if not self or not CO.db.profile.actionbar[profileName] then return end
	-- At this point, the settings for this bar definetely exist	
	profileData = CO.db.profile.actionbar[profileName]
	profileMoverData = CO.db.profile.movers[moverName]
	size = AB.ACTIONBUTTON_SIZE * profileData["buttonSizeMultiplier"]
	
	if not profileData["enable"] then
		self.ForceMoverEnabled = false
	else
		self.ForceMoverEnabled = nil
	end
	-- Hide when disabled. Show when enabled and visibility condition is met
	if not profileData["enable"] then
		self:Hide();
		return
	else
		if SecureCmdOptionParse(profileData.visibilityCondition) == "1" then
			self:Show()
		end
	end
	
	self:SetIgnoreParentAlpha(true)
	
	UnregisterStateDriver(self, "visible")
	UnregisterStateDriver(self, "page")
	
	RegisterStateDriver(self, "visible", profileData.visibilityCondition)
	
	self.CombatFade = profileData.fadeInCombat
	if self.CanBeFaded then
		self.showOnMouseOver = profileData.showOnMouseOver
		self.alphaActive = profileData.alphaActive
		self.alphaInactive = profileData.alphaInactive
		self.fadeInSpeed = profileData.fadeInSpeed
		self.fadeOutSpeed = profileData.fadeOutSpeed
		
		if self:GetAttribute("IsShown") then
			if not self.showOnMouseOver and profileData.fadeInCombat == "none" then
				E:UIFrameFadeIn(self, self.fadeInSpeed, self:GetAlpha(), self.alphaActive)
			else
				E:UIFrameFadeOut(self, self.fadeOutSpeed, self:GetAlpha(), self.alphaInactive)
			end
		end
		
		if profileData.fadeInCombat ~= "none" then			
			if self:GetAttribute("IsShown") then
				if profileData.fadeInCombat == "fadeOut" then
					-- Fade bar out
					E:UIFrameFadeIn(self, profileData.fadeInSpeed, self:GetAlpha(), profileData.alphaActive)
				elseif profileData.fadeInCombat == "fadeIn" then
					-- Fade bar in
					E:UIFrameFadeOut(self, profileData.fadeOutSpeed, self:GetAlpha(), profileData.alphaInactive)
				end
			end
		end
	end
	
	if tonumber(bar) then
		if bar > 1 then
			RegisterStateDriver(self, "page", AB.Bindings[bar].page)
		else
			RegisterStateDriver(self, "page", "[possessbar] 12; [overridebar] 14; [shapeshift] 13; [form, noform] 0; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6; [bonusbar:1, nostealth] 7; [bonusbar:1,stealth] 7; [bonusbar:3] 9; [bonusbar:4] 10; 1")
		end
		
		self:SetAttribute("page", AB.Bindings[bar].page)
		
		AB:UpdateConfig(self)
	end
	
	numDisabled = 0
	currentRow = 0
	maxRow = 0
	currentColumn = 0
	maxColumn = 0
	
	kids = { self:GetChildren() };
	
	index = 1
	for _,child in pairs(kids) do
		--------------------------------------------------------------------
		
		if E:GetFullFrameName(child) and string.match(E:GetFullFrameName(child), "Button") then
			if GetNumShapeshiftForms() > 0 and profileName == "stancebar" then
				
				numDisabled = 12 - GetNumShapeshiftForms()
				
			elseif profileName ~= "stancebar" and profileName ~= "petbar" then
			
				if index > profileData["buttonNum"] then
					child:Hide(); child:SetAttribute("enable", false)
					numDisabled = numDisabled + 1
				else
					child:Show()
					child:SetAttribute("enable", true)
				end
			end
			
			if bar == "stancebar" and child.Border then
				child.Border:SetSize(AB.ACTIONBUTTON_SIZE + 5, AB.ACTIONBUTTON_SIZE + 5)
			end
			
			if bar == "petbar" and child.Flash then
				
				-- That frame is such a Murloc
				child.Flash:SetScale(0.55)
			end
			
			child:SetSize(AB.ACTIONBUTTON_SIZE, AB.ACTIONBUTTON_SIZE)
			child:SetScale(profileData["buttonSizeMultiplier"])
			
			child:ClearAllPoints()
			
			if profileData["buttonsPerRow"] < 0 then
				addSubtract = -1
				child:SetPoint("TOPLEFT", self, "TOPLEFT")
			else
				addSubtract = 1
				child:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT")
			end
			
			-- We have to use the previous column and row values to make it work properly
			local xOffset = ((size * currentColumn) + (profileData["buttonGap"] * currentColumn)) / profileData["buttonSizeMultiplier"]
			local yOffset = (((size * currentRow) + (profileData["buttonGap"] * currentRow)) * addSubtract)  / profileData["buttonSizeMultiplier"]
			
			if numDisabled == 0 or profileName == "stancebar" then
				if currentRow > maxRow then maxRow = currentRow end
				if currentColumn > maxColumn then maxColumn = currentColumn end
			end
			
			-- If the current button should be in next row
			if index % profileData["buttonsPerRow"] == 0 then
				currentRow = currentRow + 1
				currentColumn = 0
			else
				currentColumn = currentColumn + 1
			end
			
			E:MoveFrame(child, xOffset, yOffset)
			
			--------------------------------------------------------------------
			index = index + 1
		end
	end
	
	self:SetWidth((size + profileData["buttonGap"]) * (maxColumn + 1) - profileData["buttonGap"])
	self:SetHeight((size + profileData["buttonGap"]) * (maxRow + 1) - profileData["buttonGap"])
	
	if E:GetMover(self) then
		if profileMoverData then
			-- E:GetMover(self):SetScale(profileData["buttonSizeMultiplier"])
			E:RepositionMover(E:GetMover(self), profileMoverData["point"], profileMoverData["relativePoint"], profileMoverData["xOffset"], profileMoverData["yOffset"])
			E:UpdateMoverDimensions(self)
		else
			assert("No mover data found for " .. moverName)
		end
	end
end

function AB:CreateActionBars()

	local barName, actionBar, buttonName, actionButton
	

	for b=1, self.ACTIONBAR_NUM do
		
		barName = "CUI_ActionBar" .. b
		
		actionBar = CreateFrame("Frame", barName, E.Parent, 'SecureHandlerStateTemplate')
		actionBar:SetFrameRef("MainMenuBarArtFrame", MainMenuBarArtFrame)
		actionBar:SetSize((self.ACTIONBUTTON_SIZE + self.ACTIONBUTTON_GAP)*(12) - 24, self.ACTIONBUTTON_SIZE)
		
		actionBar.ProfileName = "bar" .. b
		
	-- Init Button Container
		actionBar.buttons = {}
	-- Set bindings base to bar
		actionBar.bindButtons = self.Bindings[b].binding
	-- Register actionbar
		self.ActionBars[barName] = actionBar

	-- Set visibility driver (This is user controlled through the config dialog)
	-- StateDriver is registered in the config
		E:SetVisibilityHandler(actionBar)
		actionBar:SetAttribute("_onstate-page", [[
			self:SetAttribute("state", newstate)
			control:ChildUpdate("state", newstate)
		]])
		
		E:CreateMover(actionBar, L["actionbarFrame"] .. " " .. b)
		
		actionBar:SetScript("OnEnter", AB.BarMOver_OnEnter)
		actionBar:SetScript("OnLeave", AB.BarMOver_OnLeave)

		actionBar.CanBeFaded = true
	
		-- Create AB.ACTIONBAR_NUM_BUTTONS (12) buttons per bar
		for i=1, self.ACTIONBAR_NUM_BUTTONS do
			
		-- Button Name
			buttonName = format("CUI_ActionBar%sButton%s", b, i)
			
		-- Create new Button object through LibAB
			actionButton = LAB10:CreateButton(i, buttonName, actionBar)
		-- Register created button
			self.ActionButtons[buttonName] = actionButton
			
		-- Cache parent because we will have to reference to it pretty often
			actionButton.Parent = actionBar
		
			for k = 1,14 do
				actionButton:SetState(k, "action", (k - 1) * 12 + i)
			end
			actionButton:SetState(0, "action", i)
			actionButton:SetAttribute("buttonlock", GetCVarBool('lockActionBars'))
			
			actionButton.index = i
			
			actionButton.overlay = CreateFrame("Frame", nil, actionButton.cooldown)
			actionButton.overlay:SetAllPoints(actionButton.cooldown)
			self:CreateCooldownText(actionButton)
			hooksecurefunc(actionButton.cooldown, "SetCooldown", self.OnSetCooldown)
			actionButton.cooldown:SetHideCountdownNumbers(true)
			
			actionButton.cooldown:Hide()
			
			-- N.E.V.E.R use ActionButton_GetOverlayGlow, as it WILL Taint something on Blizzards end and then throw errors
			--actionButton.Glow = ActionButton_GetOverlayGlow(actionButton)
			
			-- Register Fonts with corresponding database path to automate updates
			E:RegisterPathFont(actionButton.HotKey, "db.profile.actionbar.bar" .. b .. ".hotkey")
			E:RegisterPathFont(actionButton.cooldown.cooldownText, "db.profile.actionbar.bar" .. b .. ".cooldown")
			E:RegisterPathFont(actionButton.Count, "db.profile.actionbar.bar" .. b .. ".count")
			E:RegisterPathFont(actionButton.Name, "db.profile.actionbar.bar" .. b .. ".macro")
			
		-- Add LibAB methods
			actionButton.SetKey 		= self.ActionButton_SetKey
			actionButton.ClearBindings 	= self.ActionButton_ClearBindings
			actionButton.GetBindings 	= self.ActionButton_GetBindings
			
		-- Workaround for tooltips of macros, pets and toys
			actionButton:HookScript("OnEnter", self.ActionButton_OnEnter)
			actionButton:HookScript("OnLeave", self.ActionButton_OnLeave)
			
			actionButton:HookScript("OnEnter", AB.BarMOverButton_OnEnter)
			actionButton:HookScript("OnLeave", AB.BarMOverButton_OnLeave)
			
			
			actionBar.buttons[i] = actionButton
		end
		
		self:UpdateConfig(actionBar)
	end
end

function AB:ActionButton_AddMasque(actionButton)
	if CO.db.profile.actionbar.useMasque == true and self.Masque and not actionButton.HasMasque then
		
		local buttonData = {
			Icon = actionButton.icon,
			Cooldown = actionButton.cooldown,
			Normal = actionButton:GetNormalTexture(),
			Pushed  = actionButton:GetPushedTexture(),
			Border = actionButton.Border
		}
		
		actionButton.HasMasque = true
	
		self.MasqueGroup:AddButton(actionButton, buttonData)
	else
		actionButton.HasMasque = nil
		
		if self.MasqueGroup then
			--self.MasqueGroup:RemoveButton(actionButton)
		end
	end
end

function AB:ActionButton_GetBindings()
	local BindButton = self:GetParent().bindButtons
	local ButtonIndex = self.index
	
	local keys = ""
	
	for i = 1, select("#", GetBindingKey(BindButton .. ButtonIndex)) do
		
		local hotKey = select(i, GetBindingKey(BindButton .. ButtonIndex))
		if keys ~= "" then
			keys = keys .. ", "
		end
		keys = keys .. GetBindingText(hotKey, "KEY_")
	end
	
	return keys
end

function AB:ActionButton_SetKey(key)
	local BindButton = self:GetParent().bindButtons
	local ButtonIndex = self.index
	
	SetBinding(key, BindButton .. ButtonIndex)
	
	AB:ReassignBindings()
end

function AB:ActionButton_ClearBindings()	
	SetBinding(GetBindingKey(format("%s%s", self:GetParent().bindButtons, self.index)), nil)
	
	AB:ReassignBindings()
end

function AB:ActionButton_OnEnter()
	E.TooltipOwnedByActionButton = true
	TT:UpdateStyle(true)
end

function AB:ActionButton_OnLeave()
	E.TooltipOwnedByActionButton = nil
end

function AB:ClearBindings()
	if InCombatLockdown() then return end

	for _, Bar in pairs(self.ActionBars) do
		if Bar then
			ClearOverrideBindings(Bar)
		end
	end
end

function AB:UpdateConfig(Bar)
	local Button, Binding, ButtonBinding, BarNum, BarProfile
	
	if self.keyRebind then return end
	
	if Bar.buttons then
		
		_, BarNum = E:ExtractDigits(Bar:GetName())
		BarProfile = CO.db.profile.actionbar[format("bar%s", BarNum)]
		
		if not Bar.buttonConfig then Bar.buttonConfig = {} end
		
		Bar.buttonConfig.outOfRangeColoring = "button"
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
			ButtonBinding = format("%s%s", Bar.bindButtons, i)
			Binding = GetBindingKey(ButtonBinding)
			
			if Binding then
				SetOverrideBindingClick(Bar, false, Binding, Button:GetName())
			end
			
			Bar.buttonConfig.keyBoundTarget = Binding
			
			Button:UpdateConfig(Bar.buttonConfig)
		end
	end
end

function AB:OnSetCooldown(start, duration)
	if start > 0 and duration > 0.5 then
		-- self:Show()
		self:SetScript("OnUpdate", AB.ActionButton_UpdateCooldownText)
	else
		-- self:Hide()
		self:SetScript("OnUpdate", nil)
	end
end

function AB:OnClearCooldown()
	self.cooldownText:SetText("")
end

local CDTextUpdate = 0.075
function AB:ActionButton_UpdateCooldownText(elapsed)
	
	self.update = self.update + elapsed
	if self.update >= CDTextUpdate then
		self.durationRemaining = self.duration + (self.start - GetTime())
		
		if self.durationRemaining <= 0 then
			self.cooldownText:SetText("")
			
			return
		end
		if self.duration > 1.5 then
			self.timeRemaining = 0
			if self.durationRemaining > 10 then
				if self.durationRemaining > 60 then
					if self.durationRemaining > 300 then
						if self.durationRemaining > 3600 then
							if self.durationRemaining > (3600 * 24) then
								self.timeRemaining = format("%dd", (self.durationRemaining / (3600 * 24)))
							else
								self.timeRemaining = format("%dh", (self.durationRemaining / 3600))
							end
						else
							self.timeRemaining = format("%dm", (self.durationRemaining / 60))
						end
					else
						self.timeRemaining = format("%d:%02d", self.durationRemaining / 60, self.durationRemaining % 60)
					end
				else
					self.timeRemaining = E:FormatTime(self.durationRemaining)
				end
			else
				self.timeRemaining = E:FormatTime(self.durationRemaining, 1)
			end
			self.cooldownText:SetText(self.timeRemaining)
		else
			self.cooldownText:SetText("")
		end
		
		self.update = 0
	end
end

function AB:CreateCooldownText(self)	
	if not self.cooldown.cooldownText then
		self.cooldown.cooldownText = self.overlay:CreateFontString(nil, "OVERLAY")
		E:InitializeFontFrame(self.cooldown.cooldownText, "OVERLAY", "FRIZQT__.TTF", 12, {0.933, 0.886, 0.125}, 1, {0,0}, "", 100, 20, self.cooldown, "CENTER", {1,1})
		E:SetFontInfo(self.cooldown.cooldownText, nil, "THICKOUTLINE", nil, nil)
		E:UpdateFont(self.cooldown.cooldownText)
		
		-- SetAllPoints sometimes causes the text to be cutoff
		self.cooldown.cooldownText:SetPoint("CENTER", self.overlay, "CENTER")
		self.cooldown.cooldownText:SetJustifyH("CENTER")
		self.cooldown.cooldownText:SetDrawLayer("ARTWORK", 5) -- Above Border
		
		self.cooldown.update = 0
	end
end

local function InitActionBarChange()
	--[[
		Here, it is ESSENTIAL to do the THREE following things withing the attribute function:
			- self:SetAttribute("state", PAGENUM)
			- self:ChildUpdate("state", PAGENUM)
			- self:GetFrameRef("MainMenuBarArtFrame"):SetAttribute("actionpage", PAGENUM)
			
		If we are missing just ONE of those things, the bar will NOT respond to the change (correctly)
		TL;DR: This was a pain in the beep to find out
	]]
	
	AB.ActionBars["CUI_ActionBar1"]:SetAttribute("_onstate-overrideBar", [[
		local changeTo = GetActionBarPage()
		
		-- print("newstate:", newstate)
		if newstate == 12 or newstate == 13 then
				changeTo = 12
		elseif newstate == 14 then
			if HasOverrideActionBar() then
				changeTo = GetOverrideBarIndex()
			end
		else
			if (newstate == "noform" or newstate == "shapeshift") then
				if HasTempShapeshiftActionBar() then
					changeTo = GetTempShapeshiftBarIndex()
				elseif HasOverrideActionBar() then
					changeTo = GetOverrideBarIndex()
				else
					changeTo = GetActionBarPage()
				end
            else
				if HasBonusActionBar() then
					changeTo = GetBonusBarIndex()
				else
					changeTo = GetActionBarPage()
				end
			end
		end
		
		-- print("changeTo:", changeTo)
		self:SetAttribute("state", changeTo)
		self:ChildUpdate("state", changeTo)
		self:GetFrameRef("MainMenuBarArtFrame"):SetAttribute("actionpage", changeTo)
	]]);
	
	
	-- /dump HasTempShapeshiftActionBar(), GetTempShapeshiftBarIndex(), HasOverrideActionBar(), GetOverrideBarIndex()
	-- local condition = "[form:0] noform; [form:0] noform; [form:1] 1; [form:2] 2; [form:4] 4; noform"
	-- SecureCmdOptionParse(condition)
	-- /run print(SecureCmdOptionParse("[form:0] noform; [form:0] noform; [form:1] 1; [form:2] 2; [form:4] 4; noform"))
	-- /dump SecureCmdOptionParse("[overridebar] 14;[vehicleui] 12;[possessbar] 12;[form:1] 1; [form:2] 2; [form:4] 4; noform;")
	-- /dump SecureCmdOptionParse("[shapeshift] shape; noform;")
	-- /dump SecureCmdOptionParse("[bonusbar:1] 1;[bonusbar:2] 2; [bonusbar:3] 3; [bonusbar:4] 4; [bonusbar:5] 5; [bonusbar:6] 6; noform;")
	-- /dump CUI:GetModule("Actionbars").ActionBars["CUI_ActionBar1"]:GetAttribute("state")
	-- /dump MainMenuBarArtFrame:GetAttribute("actionpage")
end

function AB:GetHotkey()
	local name = "CLICK "..self:GetName()..":LeftButton"
	local key
	
	if name then
		key = GetBindingKey(name, 1)
	end
	if key then
		key = gsub(key, 'SHIFT%-', "S-");
		key = gsub(key, 'ALT%-', "A-");
		key = gsub(key, 'CTRL%-', "C-");
		key = gsub(key, 'BUTTON', "MB");
		key = gsub(key, 'MOUSEWHEELUP', "MWU");
		key = gsub(key, 'MOUSEWHEELDOWN', "MWD");
		key = gsub(key, 'NUMPAD', "NP");
		key = gsub(key, 'PAGEUP', "PgUp");
		--key = gsub(key, 'PAGEDOWN', L["KEY_PAGEDOWN"]);
		--key = gsub(key, 'SPACE', L["KEY_SPACE"]);
		--key = gsub(key, 'INSERT', L["KEY_INSERT"]);
		--key = gsub(key, 'HOME', L["KEY_HOME"]);
		--key = gsub(key, 'DELETE', L["KEY_DELETE"]);
		key = gsub(key, 'NMULTIPLY', "*");
		key = gsub(key, 'NMINUS', "N-");
		key = gsub(key, 'NPLUS', "N+");
		key = gsub(key, 'NEQUALS', "N=");

		return LibKeyBound:ToShortKey(key) or key
	end
end

function AB:SetKeybinder(state)
	if state == true then
		AB:RegisterEvent("REGEN_DISABLED")
		AB:SetScript("OnEvent", function(self) AB:SetKeybinder(false) end)
		
		self.keyRebind = true
		CO:ShowNotification("KEYREBIND_ACTIVE")
		
		for _, button in pairs(AB.ActionButtons) do
			button:HookScript("OnEnter", function(self) AB:BindUpdate(self); end);
		end
	else
		AB:UnregisterEvent("REGEN_DISABLED")
		self.keyRebind = false
	end
end

function AB:UpdateExtraBar()
	if not InCombatLockdown() then
		UnregisterStateDriver(AB.ActionBars["CUI_ActionBar1"], "overrideBar")
		RegisterStateDriver(AB.ActionBars["CUI_ActionBar1"], "overrideBar", "[overridebar] 14;[vehicleui] 12;[possessbar] 12;[form:1] 1; [form:2] 2; [form:3] 3; [form:4] 4;[shapeshift] shapeshift; noform;")
	end
end

function AB:SetupActionbars()
	self:CreateActionBars()
	self:CreatePetActionBar()
	InitActionBarChange()
	self:UpdateExtraBar()
	self:InitStanceBar()
	self:InitExtraActionButton()
	self:InitZoneActionButton()
	self:InitMicroMenu()
	
	self:InitCombatFader()
	
	self:LoadProfile()
end

function AB:Init()
	CO = E:LoadModules("Config")
	
	self.Masque = E.Masque
	self:UpdateMasque()
	
	self:SetupActionbars()
	
	self.PageWarningShown = nil
	
	self:SetScript("OnEvent", function(self, event, ...)
		if event == "UPDATE_BONUS_ACTIONBAR" 
			or event == "UPDATE_VEHICLE_ACTIONBAR" 
			or event == "UPDATE_OVERRIDE_ACTIONBAR"
			or event == "ACTIONBAR_PAGE_CHANGED" then
				if event == "ACTIONBAR_PAGE_CHANGED" and not AB.PageWarningShown then
					E:print("Warning: You changed the actionbar page. If this was not intentional, it is advised to remove the binding for this action.")
					AB.PageWarningShown = true
				end
			AB:UpdateExtraBar()
		end
		-- Fix for some random bug that appeared first in 8.0.1.
		if event == "PLAYER_SPECIALIZATION_CHANGED" then
			AB:InitStanceBar()
			AB:UpdateExtraBar()
		end
		if event == "UPDATE_BINDINGS" then
			AB:ReassignBindings()
		end
		if event == "CVAR_UPDATE" and select(1, ...) == "LOCK_ACTIONBAR_TEXT" then
			local val = GetCVarBool('lockActionBars')
			for _, button in pairs(AB.ActionButtons) do
				button:SetAttribute("buttonlock", val)
			end
		end
		if event == "PET_BATTLE_OPENING_DONE" then
			AB:ClearBindings()
		end
		if event == "PET_BATTLE_CLOSE" then
			AB:ReassignBindings()
		end
	end)
	
	-- Prevent micromenu from being repositioned in petbattles
	PetBattleFrame.BottomFrame.MicroButtonFrame:SetScript("OnShow", nil)
	
	hooksecurefunc("MicroButtonAlert_OnShow", function(...) AB:MainMenuMicroButton_RepositionAlerts() end)
	
end

E:AddModule("Actionbars", AB)