---@class E, L
local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, B = E:LoadModules("Config", "Blizzard")

--[[----------------------------------------------------

	This CUI Library provides a powerful toolset
	that is designed to create frame movers
	on the fly.
	
	You may use this Code in your own projects,
	as long as there is at least any credit given.
	
	Author: Ferodra / Arenima
	
----------------------------------------------------]]--

---------------------------------------------------
local _
local _G 						= _G
local pairs 					= pairs
local type 						= type
local tinsert 					= table.insert
local HasExtraActionBar 		= HasExtraActionBar

local LibSticky					= LibStub("LibSimpleSticky-1.0")
---------------------------------------------------

E.Movers = {}
E.Stickys = {}

-- Add X and Y Centered Sticky Points
do
	local X = CreateFrame("Frame", nil, E.Parent)
	X:SetPoint("LEFT", E.Parent, "LEFT")
	X:SetPoint("RIGHT", E.Parent, "RIGHT")
	X:SetHeight(1)
	
	local Y = CreateFrame("Frame", nil, E.Parent)
	Y:SetPoint("TOP", E.Parent, "TOP")
	Y:SetPoint("BOTTOM", E.Parent, "BOTTOM")
	Y:SetWidth(1)
	
	tinsert(E.Stickys, X)
	tinsert(E.Stickys, Y)
end

local MoverPanel_DescBase = '%s\n\n' .. L['MoverPanel_Description']

local function HideMoverPanel()
	E:UIFrameFadeOut(E.MoverPanel, 0.2, E.MoverPanel:IsVisible() and E.MoverPanel:GetAlpha() or 0, 0)
	E.MoverPanel:EnableMouse(false)
end

local function MoverPanel_OnEnter(self)
	if E.HideTimer then
		E.HideTimer:Cancel()
	end
	
	E:SetMoverPanelState(true)
end

local function MoverPanel_OnLeave(self)
	if E.HideTimer then
		E.HideTimer:Cancel()
	end
	if E.MoverPanel:IsVisible() then
		E.HideTimer = C_Timer.NewTimer(0.25, HideMoverPanel)
	end
	
	E:SetMoverPanelState(false)
end

local function PushMover(Mover, direction)
	if not Mover then return end
	
	local Config = E:GetMoverConfig(Mover)
	local AxisX, AxisY
	
	if direction == 'UP' then
		AxisY = 1
	elseif direction == 'DOWN' then
		AxisY = -1
	elseif direction == 'LEFT' then
		AxisX = -1
	elseif direction == 'RIGHT' then
		AxisX = 1
	end
	
	if not AxisX and not AxisY then return end
	
	if AxisX then
		Config.xOffset = Config.xOffset + AxisX
	elseif AxisY then
		Config.yOffset = Config.yOffset + AxisY
	end
	
	E:ApplyMoverConfig(Mover, Config)
end

local function PropagateNonMoveKeys(self, key)
	if key == 'UP' or key == 'DOWN' or key == 'LEFT' or key == 'RIGHT' then
		self:SetPropagateKeyboardInput(false)
		
		return true
	else
		self:SetPropagateKeyboardInput(true)
	end
end

local function Panel_OnKeyDown(self, key)
	-- If a target key was pressed, continue execution
	-- If not, propagate input and continue normal execution for this key
	if PropagateNonMoveKeys(self, key) then
		E:MoverPanel_Move(key)
	end
end

local function Panel_OnEnter(self)	
	MoverPanel_OnEnter(self)
end

local function Panel_OnLeave(self)
	MoverPanel_OnLeave(self)
end

function E:SetMoverPanelState(state)
	if E.MoverPanel then
		if state then
			E.MoverPanel:EnableKeyboard(true)
			E.MoverPanel:SetScript('OnKeyDown', Panel_OnKeyDown)
		else
			E.MoverPanel:EnableKeyboard(false)
			E.MoverPanel:SetScript('OnKeyDown', nil)
		end
	end
end

local SmartPositions = {
	["TOP"] = "BOTTOM",
	["BOTTOM"] = "TOP",
	["LEFT"] = "RIGHT",	
	["RIGHT"] = "LEFT",
	["TOPLEFT"] = "BOTTOMLEFT",
	["TOPRIGHT"] = "BOTTOMRIGHT",
	["BOTTOMLEFT"] = "TOPLEFT",
	["BOTTOMRIGHT"] = "TOPRIGHT",
	["CENTER"] = "CENTER",
}
function E:InversePosition(point)
	return SmartPositions[point]
end

function E:GetMoverPoints(Mover)
	local screenWidth, screenHeight, screenCenter = E.Parent:GetRight(), E.Parent:GetTop(), E.Parent:GetCenter()
	local x, y = Mover:GetCenter()
	
	local LEFT = screenWidth / 3
	local RIGHT = screenWidth * 2 / 3
	local TOP = screenHeight / 2
	local point, nudgePoint, nudgeInversePoint

	if y >= TOP then
		point = "TOP"
		nudgePoint = "TOP"
		y = -(screenHeight - Mover:GetTop())
	else
		point = "BOTTOM"
		nudgePoint = "BOTTOM"
		y = Mover:GetBottom()
	end

	if x >= RIGHT then
		point = point..'RIGHT'
		nudgePoint = "RIGHT"
		x = Mover:GetRight() - screenWidth
	elseif x <= LEFT then
		point = point..'LEFT'
		nudgePoint = "LEFT"
		x = Mover:GetLeft()
	else
		x = x - screenCenter
	end
	
	return x, y, point, point
end

local CategoryNameTranslate = {
	["All"] = "all",
	["Actionbars"] = "actionbars",
	["Unitframes"] = "unitframes",
	["Misc"] = "misc",
}

function E:FilterShownMovers()
	local Filter = self.CurrentMoverFilter and CategoryNameTranslate[self.CurrentMoverFilter] or "all"
	
	for k,v in pairs(self.Movers) do
		if v.HandleIsActive then
			if Filter ~= "all" then
				if v.Category ~= Filter then
					v.Handle:Disable()
				else
					v.Handle:Enable()
				end
			else
				v.Handle:Enable()
			end
		end
	end
end

-- Toggle mover overlays and drag functionality
-- We can NOT simply show the whole thing, since we still have to hide them afterwards
-- this results in EVERY frame disappearing
function E:ToggleMover(state, noFade)
	-- Here we toggle special blizzard frames
	if state == true then
		-- Extra Button
		--if not HasExtraActionBar() then
		--	ExtraActionBarFrame:Show()
		--	ExtraActionBarFrame:SetAlpha(1)
		--	ExtraActionButton1:Show()
		--end
		
		--VehicleSeatIndicator:Show()
	else
		-- Extra Button
		-- Prevent the button from being hidden when it actually is supposed to be active
		--if not HasExtraActionBar() then
		--	ExtraActionBarFrame:Hide()
		--	ExtraActionBarFrame:SetAlpha(0)
		--	ExtraActionButton1:Hide()
		--end
		
		--VehicleSeatIndicator:Hide()
		
		if self.MoverPanel then
			self.MoverPanel:Hide()
			-- Force disabling keyboard functionality, as this somehow stays active
			self.MoverPanel:GetScript('OnLeave')(self.MoverPanel)
		end
	end
	
	
	-- We can assign "MoverChild.ForceMoverEnabled = true" to - force show it or false to force hide
	-- Assign nil to disable this functionality
	for k,v in pairs(self.Movers) do
		--if (state == true and v.Category == Filter) or not state then
			if state == true and (v.Frame.ForceMoverEnabled == true or (not v.Frame.ForceMoverEnabled and v.Frame.MoverEnabled)) then
				if v.Frame.ForceMoverEnabled == true or v.Frame.ForceMoverEnabled == false then
					if v.Frame.ForceMoverEnabled == true then
						v.HandleIsActive = true
						v.Handle:Enable(noFade)
					else
						v.Handle:Disable(noFade)
						v.HandleIsActive = nil
					end
				else
					if v.Frame.MoverEnabled then
						v.HandleIsActive = true
						v.Handle:Enable(noFade)
					end
				end
			else
				v.HandleIsActive = nil
				v.Handle:Disable(noFade)
			end
		--end
	end
	
	self:FilterShownMovers()
end

function E:ApplyMoverConfig(Mover, Data)
	
	local Config = CO.db.profile.movers[Mover:GetName()]
	
	for k,v in pairs(Data) do
		if Config[k] and v then
			Config[k] = v
		end
	end
	
	self:LoadMoverPositions(Mover)
end

function E:GetMoverConfig(Mover)
	return CO.db.profile.movers[Mover:GetName()]
end

-- Returns a registered mover from child object or name-string
function E:GetMover(C)
	if not C then return end
	
	if type(C) == "string" then
		return self.Movers[C .. "Mover"]
	else
		if not C:GetName():find("Mover") then
			return self.Movers[self:GetFullFrameName(C) .. "Mover"]
		else
			return C
		end
	end
end

function E:RegisterMover(M, MName)
	self.Movers[MName] = M
end

function E:IsMoverConfigAttached(Config)
	if Config.enableAttach and Config.attachTo and Config.attachTo[1] ~= "" then
		-- Attachment Target exists
		if _G[Config.attachTo[1]] then
			return true
		end
	end
	
	return false
end

local function SetHandleMovementByChild(mover)
	local child = mover.Frame
	
	if not mover.IsAttached then
		if child.HandleMovementByChild or mover.HandleMovementByChild then
			E:SetMoverMovableByChild(child, true)
			
			return
		end
	end
	
	E:SetMoverMovableByChild(child, false)
end

function E:LoadMoverPosition_Single(mover)
	if mover then
		local Conf = CO.db.profile.movers
		local ConfData = {}
	
		ConfData = Conf[mover:GetName()]
		local SmartPosition = ConfData["point"]
		
		if not ConfData then return false end
		if E:IsMoverConfigAttached(ConfData) then
			mover:SetParent(_G[ConfData["attachTo"][1]])
			mover.IsAttached = true
			_G[ConfData["attachTo"][1]].Parent = mover
			mover.Frame.MoverEnabled = false
			
			SmartPosition = E:InversePosition(ConfData["point"])
		else
			mover.IsAttached = nil
			if not mover.IsPetBattleHandled then
				mover:SetParent(self.Parent)
			end
			E:SetMoverMovableByChild(limit, false)
			mover.Frame.MoverEnabled = true
			
			if ConfData["attachTo"] and ConfData["attachTo"][1] and _G[ConfData["attachTo"][1]] then
				_G[ConfData["attachTo"][1]].Parent = self.Parent					
			end
		end
		
		SetHandleMovementByChild(mover)
		
		E:RepositionMover(mover, SmartPosition, ConfData["relativePoint"] or ConfData["point"], ConfData["xOffset"], ConfData["yOffset"])
		
		return true
	end
end

function E:LoadMoverPositions(limit)
	self = E
	
	if limit then		
		self:LoadMoverPosition_Single(self:GetMover(limit))
		return
	end
	
	-- k: Mover Name - v: Mover Object
	for k,v in pairs(self.Movers) do		
		if v then
			self:LoadMoverPosition_Single(v)
		else
			self:print("WARNING: Corrupt mover data found!")
		end
	end
	
	self.MoversInitialized = true
end

local function Child_OnDragStart(self)
	local Mover = E:GetMover(self)
	
	Mover.Handle:GetScript('OnDragStart')(Mover.Handle)
end

local function Child_OnDragStop(self)
	local Mover = E:GetMover(self)
	
	Mover.Handle:GetScript('OnDragStop')(Mover.Handle)
end

local function MoverHandle_OnDragStart(self)
	local Mover = self:GetParent()
	
	Mover:SetMovable(true)
	self:SetClampedToScreen(false)
	Mover:SetClampedToScreen(false)
	
	if E.StickyMovers then
		LibSticky:StartMoving(Mover, E.Stickys, E.StickyRange or 1, E.StickyRange or 1, E.StickyRange or 1, E.StickyRange or 1)
	else
		Mover:StartMoving()
	end
end

local function MoverHandle_OnDragStop(self)
	local point, relativePoint, xOfs, yOfs
	local parent = self:GetParent()
	local title = self.Title
	
	parent:SetMovable(false)
	if E.StickyMovers then
		LibSticky:StopMoving(parent)
	else
		parent:StopMovingOrSizing()
	end
	
	-- Fix for movers without any default values
	if not CO.db.profile.movers[title] then
		CO.db.profile.movers[title] = {}
	end
	local conf = CO.db.profile.movers[title]
	
	
	xOfs, yOfs, point, relativePoint = E:GetMoverPoints(parent)
	
	conf["point"] 			= point
	conf["relativePoint"] 	= relativePoint
	conf["xOffset"] 		= xOfs
	conf["yOffset"] 		= yOfs
end

local function Mover_SetSize(child)
	E:UpdateMoverDimensions(child)
end

local function Mover_SetScale(child, scale)
	E:UpdateMoverDimensions(child)
end

function E:GetMoverChildState(Mover)
	return Mover.MovableByChildState
end

function E:SetMoverMovableByChild(child, state)
	local Mover = self:GetMover(child)
	if not Mover then return end
	
	local IsAttached = self:IsMoverConfigAttached(self:GetMoverConfig(Mover))
	
	if child.DefaultMovable == nil then
		child.DefaultMovable = child:IsMouseEnabled()
		child.Script_DragStart = child:GetScript("OnDragStart")
		child.Script_DragStop = child:GetScript("OnDragStop")
	end
	
	if state ~= false and not Mover.MovableByChildState and not IsAttached then
		child:EnableMouse(true)
		child:SetMovable(true)
		child:RegisterForDrag("LeftButton")
		
		child:SetScript("OnDragStart", Child_OnDragStart)
		child:SetScript("OnDragStop", Child_OnDragStop)
	elseif not state then
		child:EnableMouse(child.DefaultMovable)
		child:SetMovable(child.DefaultMovable)
		
		child:SetScript("OnDragStart", child.Script_DragStart)
		child:SetScript("OnDragStop", child.Script_DragStop)
	end
	
	Mover.MovableByChildState = state
end

local function Mover_OnKeyDown(self, key)
	if PropagateNonMoveKeys(self.Handle, key) then
		PushMover(self, key)
	end
end

local function Mover_SetKeyMove(self, state)
	self:EnableKeyboard(state)
	self:SetScript('OnKeyDown', state and Mover_OnKeyDown or nil)
end

-- @PARAM1: Child target [Named frame(IMPORTANT), so we can store that config properly]
-- @PARAM2: Localized mover name for user display
-- @PARAM3: Alignment/Point
-- @PARAM4: Width
-- @PARAM5: Height
-- @PARAM6: Tooltip text for mover mode
-- @PARAM7: Config identifier override to use for this mover
-- @PARAM8: Config path to wherever a click on this mover should open the config to
function E:CreateMover(C, LT, A, X, Y, TT, Category, ConfigKeyOverride, ConfigPath)
	local MNameRaw = self:GetFullFrameName(C)
	local MName = MNameRaw .. "Mover"
	MName = ConfigKeyOverride or MName
	
	if not A then A = "CENTER" end
	if not (X and Y) then X, Y = C:GetWidth(), C:GetHeight() if X <= 0 and Y <= 0 then X, Y = 50, 50 end end
	local M = self:NewFrame("Frame", MName, "LOW", X,Y, {"CENTER", self.Parent, "CENTER", 0, 0}, self.Parent)	
	
	-- Position update function
	-- This is probably the only existing way to deal with constantly moving blizzard frames and also work for everything else ofc
	local function Mover_SetPosition(_, _, parent)
		if parent ~= M then
			C:ClearAllPoints()
			--C:SetParent(M)
			C:SetPoint(A, M, A, 0, 0)
		end
	end
	
	hooksecurefunc(C, "SetPoint", Mover_SetPosition)
	hooksecurefunc(C, "SetScale", Mover_SetScale)
	hooksecurefunc(C, "SetSize", Mover_SetSize)
	
	C:SetPoint("CENTER", self.Parent, "CENTER") -- Execute hook initially to force an update
	
	M.SetKeyMove = Mover_SetKeyMove
	
	-- Create Mover handle to interact with
	M.Handle = self:CreateMoverHandle(C, LT, A, X, Y, TT, ConfigPath)
	M.Handle:SetParent(M)
	M.Handle:SetFrameLevel(99)
	M.Handle:SetFrameStrata("HIGH")
	
	-- Store reference to child frame
	C.MoverEnabled = true
	M.Frame = C
	M.Category = Category
	
	-- E:GetMover(FrameObjectOrNameAsString).Handle:Show() -- We can use this to access the handle at any time!
	
	M.Handle.Title = MName
	M.Handle:SetScript("OnDragStart", MoverHandle_OnDragStart)
	M.Handle:SetScript("OnDragStop", MoverHandle_OnDragStop)
	
	M.HandleMovementByChild = C.HandleMovementByChild
	
	-- Internal register
	-- MoverObject, MoverName
	self:RegisterMover(M, MName)
	
	if self.MoversInitialized then
		self:LoadMoverPositions(M)
	end
	
	tinsert(E.Stickys, M)
	
	return M
end

function E:RepositionMover(M, Point, RelativePoint, OffsetX, OffsetY)
	self:RepositionFrame(M, Point, RelativePoint, OffsetX, OffsetY)
end

local function MoverHandle_Enable(self, noFade)
	self:EnableMouse(true)
	
	if not noFade then
		E:UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1)
	else
		self:Show()
		self:SetAlpha(1)
	end
end
local function MoverHandle_Disable(self, noFade)
	self:EnableMouse(false)
	
	if not noFade then
		E:UIFrameFadeOut(self, 0.2, self:GetAlpha(), 0)
	else
		self:Hide()
		self:SetAlpha(0)
	end
end

-- Since we move frames via movers, which are basically frames, the frames we want to move with are parented to the mover
-- By later "copying" the translations made to the overlay to the base parent, we can move the whole thing
function E:CreateMoverHandle(C, LT, A, X, Y, TT, P)
	local MH = self:NewFrame("Button", "Handle", "HIGH", X,Y, {A, C, A, 0, 0}, C, nil, nil, nil, BackdropTemplateMixin and "BackdropTemplate")
	local RGB = self:GetUnitClassColor("player")
	MH:EnableMouse(true)
	MH:SetMovable(true)
	MH:RegisterForDrag("LeftButton")
	MH:RegisterForClicks("AnyUp")
	
	MH:SetBackdrop({
		bgFile 		= [[Interface\AddOns\CUI\Textures\borders\WHITE8X8]],
		edgeFile 	= [[Interface\AddOns\CUI\Textures\borders\WHITE8X8]],
		edgeSize 	= 1,
		tile 		= true, tileSize = 16
	})
	MH:SetBackdropColor(0.05, 0.05, 0.05, 0.6)
	MH:SetBackdropBorderColor(RGB[1], RGB[2], RGB[3], 0.8)
	
	-- Init font overlay
	MH.Name = MH:CreateFontString(nil, "ARTWORK")
	self:InitializeFontFrame(MH.Name, "ARTWORK", "FRIZQT__.TTF", 14, {1,1,1}, 1, {0,0}, "", 250, Y, MH, "CENTER", {1,1})
	MH.Name:SetFont(E.Media:Fetch("font", CO.db.profile.media.generalFont), 14)
	MH.Name:ClearAllPoints()
	MH.Name:SetPoint("CENTER", MH, 'CENTER', 0, 0)
	
	MH.Name:SetText(LT) -- Set provided name
	
	MH:SetAlpha(0) -- For toggle fading
	MH:Hide()
	
	-- Save original dimensions for fallback
	MH.OriginalWidth 	= X
	MH.OriginalHeight 	= Y
	
	-- Vars for tooltip functionality
	MH.LT = LT
	MH.TT = TT
	
	-- Making our lives easier
	MH.Enable = MoverHandle_Enable
	MH.Disable = MoverHandle_Disable
	
	-- Store path to config dialog
	if P then
		local Path = {}
		for word in string.gmatch(P, '([^.]+)') do
			table.insert(Path, word)
		end
		MH.ConfigPath = Path
	end
	
	-- Add tooltip functionality to describe this mover in config mode
	MH:SetScript("OnEnter", self.Mover_OnEnter)
	MH:SetScript("OnLeave", self.Mover_OnLeave)
	MH:SetScript("OnClick", self.Mover_OnClick)
	
	return MH
end

-- Update Mover dimensions based on child frame
-- Falls back to initialized dimension(s) when below min
local MinDimension = 20
function E:UpdateMoverDimensions(C, W, H)
	local M = self:GetMover(C)
	
	if not M then return false end
	
	if W and H then
		C:SetSize(W, H)
	end
	
	local EffWidth, EffHeight = C:GetWidth() * C:GetScale(), C:GetHeight() * C:GetScale()
	
	-- Fallback when it's too small
	if EffWidth <= MinDimension then
		EffWidth = M.Handle.OriginalWidth or 10
	end
	if EffHeight <= MinDimension then
		EffHeight = M.Handle.OriginalHeight or 10
	end
	
	if not InCombatLockdown() or not M:IsProtected() then
		M:SetSize(EffWidth, EffHeight)
		M.DirtyMoverDimensions = nil
	else
		M.DirtyMoverDimensions = true
	end
	M.Handle:SetSize(EffWidth, EffHeight)
end

function E:Mover_OnEnter()
	
	if E.ShowMoverDialog then
		Panel_OnEnter(self)
		MoverPanel_OnEnter()
		E:UpdateMoverPanel(self:GetParent())
	else
		self:GetParent():SetKeyMove(true)
	end
	
	-- Set Tooltip
	E:Mover_GameTooltipOnEnter(self)
end

function E:Mover_OnLeave()
	
	if E.ShowMoverDialog then
		Panel_OnEnter(self)
		MoverPanel_OnLeave(self)
	else
		self:GetParent():SetKeyMove(false)
	end
	
	-- Set Normal State
	E:Mover_GameTooltipOnLeave(self)
end

function E:Mover_OnClick(button)
	if button == 'RightButton' then	
		E:print(("Temporarily hiding the '%s' Mover"):format(self.LT))
		-- Hide Mover
		self:Hide()
		-- Also hide mover panel
		if E.ShowMoverDialog then
			E.MoverPanel:Hide()
		end
	elseif button == 'MiddleButton' then
		if self.ConfigPath then
			local CD = E:LoadModules("Config_Dialog")
			CD:OpenPath(self.ConfigPath)
		end
	end
end

-- TOOLTIP METHODS
	function E:Mover_GameTooltipOnEnter(self)
		-- If user actually wants tooltips
		if E.ShowMoverTooltips then
			GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
			GameTooltip:AddLine(self.LT)
			if self.TT then
				GameTooltip:AddLine(self.TT)
			end
			GameTooltip:Show()
			
			-- Absolutely make sure it's on the very top!
			GameTooltip:SetFrameLevel(9999)
		end
		
		-- Highlight border to indicate the hovered frame
		self:SetBackdropBorderColor(0.7, 0.7, 0.7, 1)
	end

	function E:Mover_GameTooltipOnLeave(self)
		GameTooltip:Hide()
		local RGB = E:GetUnitClassColor("player")
		self:SetBackdropBorderColor(RGB[1], RGB[2], RGB[3], 0.8)
	end
-- TOOLTIP METHODS END

function E:ResetMoverPositions()
	CO.db.profile.movers = self:TableDeepCopy(self.MoverDefaults)
	
	self:LoadMoverPositions()
end

local function MoverPanel_Button_MoveUp()
	E:MoverPanel_Move('UP')
end

local function MoverPanel_Button_MoveDown()
	E:MoverPanel_Move('DOWN')
end

local function MoverPanel_Button_MoveLeft()
	E:MoverPanel_Move('LEFT')
end

local function MoverPanel_Button_MoveRight()
	E:MoverPanel_Move('RIGHT')
end

function E:MoverPanel_Move(direction)
	if not self.MoverPanel.Mover then return end
	
	PushMover(self.MoverPanel.Mover, direction)
end

-- Repositions the Mover panel to an handle
function E:UpdateMoverPanel(Mover)
	
	-- Load mover panel only if we actually need it
	self:SetupMoverPanel()
	
	self.MoverPanel:ClearAllPoints()
	
	local PosX, PosY
	
	if Mover:GetLeft() > (GetScreenWidth() / 2) then
		PosX = 'LEFT'
	else
		PosX = 'RIGHT'
	end
	if Mover:GetTop() > (GetScreenHeight() / 2) then
		PosY = 'TOP'
	else
		PosY = 'BOTTOM'
	end
	
	local Pos = PosY .. PosX
	
	self.MoverPanel:SetPoint(Pos, Mover, self:InversePosition(Pos))
	
	E:UIFrameFadeIn(self.MoverPanel, 0.2, self.MoverPanel:GetAlpha(), 1)
	E.MoverPanel:EnableMouse(true)
	
	self.MoverPanel.Font.Text:SetText((MoverPanel_DescBase):format(Mover.Handle.LT or ''))
	-- Text
	
	-- Set Reference
	self.MoverPanel.Mover = Mover
end

function E:SetupMoverPanel()
	if not self.MoverPanel then
		self.MoverPanel = CreateFrame("Frame", "CUI_MoverPanel", self.Parent, 'InsetFrameTemplate')
		local Panel = self.MoverPanel
		
		Panel:SetSize(150, 200)
		Panel:SetFrameStrata("TOOLTIP")
		Panel:EnableMouse(true)
		Panel:SetClampedToScreen(true)
		--Panel.Background = self:CreateBackground(Panel)
		--Panel.Border = self:CreateBorder(Panel)
		Panel:Hide()
		
		Panel:SetScript('OnEnter', Panel_OnEnter)
		Panel:SetScript('OnLeave', Panel_OnLeave)
		
		--------------------------------
		
		Panel.Font = CreateFrame('Frame', nil, Panel)
		Panel.Font:SetPoint('TOPLEFT', Panel, 'TOPLEFT', 5, 0)
		Panel.Font:SetPoint('TOPRIGHT', Panel, 'TOPRIGHT', -5, 0)
		Panel.Font:SetHeight(125)
		
		Panel.Font.Text = E:CreateFont(Panel.Font)
		Panel.Font.Text:SetAllPoints(Panel.Font)
		
		--------------------------------
		
		local Buttons = {
			['Up'] = MoverPanel_Button_MoveUp,
			['Down'] = MoverPanel_Button_MoveDown,
			['Left'] = MoverPanel_Button_MoveLeft,
			['Right'] = MoverPanel_Button_MoveRight,
		}
		local NameBase, ChildBase = 'CUI_MoverPanel_Move%s', 'Button_%s'
		
		for Name, Func in pairs(Buttons) do
			local Button = CreateFrame('Button', (NameBase):format(Name), Panel, 'UIPanelSquareButton')
			Panel[(ChildBase):format(Name)] = Button
			
			Button:RegisterForClicks("AnyUp")
			Button:SetSize(25, 25)
			SquareButton_SetIcon(Button, string.upper(Name))
			Button:SetScript('OnClick', Func)
			Button:SetScript('OnEnter', Panel_OnEnter)
			Button:SetScript('OnLeave', Panel_OnLeave)
		end
		
		local Up, Down, Left, Right = Panel.Button_Up, Panel.Button_Down, Panel.Button_Left, Panel.Button_Right
		local ButtonOffsetY = -60
		
		Up:SetPoint('CENTER', Panel, 'CENTER', 0, ButtonOffsetY + (25))
		Down:SetPoint('CENTER', Panel, 'CENTER', 0, ButtonOffsetY + (-25))
		Left:SetPoint('CENTER', Panel, 'CENTER', -25, ButtonOffsetY + (0))
		Right:SetPoint('CENTER', Panel, 'CENTER', 25, ButtonOffsetY + (0))
	end
end