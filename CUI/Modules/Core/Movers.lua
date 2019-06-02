local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, L, B = E:LoadModules("Config", "Locale", "Blizzard")

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
local HasExtraActionBar 		= HasExtraActionBar

local LibSticky					= LibStub("LibSimpleSticky-1.0")
---------------------------------------------------

E.Movers = {}
E.Stickys = {}

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
	
	return x, y, point, nudgePoint
end

-- Toggle mover overlays and drag functionality
-- We can NOT simply show the whole thing, since we still have to hide them afterwards
-- this results in EVERY frame disappearing
function E:ToggleMover(state, noFade)
	
	-- Here we toggle special blizzard frames
	if state == true then
		-- Extra Button
		if not HasExtraActionBar() then
			ExtraActionBarFrame:Show()
			ExtraActionBarFrame:SetAlpha(1) -- W.h.y
			ExtraActionButton1:Show()
		end
		
		VehicleSeatIndicator:Show()
	else
		-- Extra Button
		-- Prevent the button from being hidden when it actually is supposed to be active
		if not HasExtraActionBar() then
			ExtraActionBarFrame:Hide()
			ExtraActionBarFrame:SetAlpha(0) -- W.h.y
			ExtraActionButton1:Hide()
		end
		
		VehicleSeatIndicator:Hide()
	end
	
	B:ToggleZoneAbility(state)
	
	-- We can assign "MoverChild.ForceMoverEnabled = true" to - force show it or false to force hide
	-- Assign nil to disable this functionality
	for k,v in pairs(self.Movers) do
		if state == true and (v.Frame.ForceMoverEnabled == true or (not v.Frame.ForceMoverEnabled and v.Frame.MoverEnabled)) then
			if v.Frame.ForceMoverEnabled == true or v.Frame.ForceMoverEnabled == false then
				if v.Frame.ForceMoverEnabled == true then
					v.Handle:EnableMouse(true)
					if not noFade then
						E:UIFrameFadeIn(v.Handle, 0.2, v.Handle:GetAlpha(), 1)
					else
						v.Handle:Show()
						v.Handle:SetAlpha(1)
					end
				else
					v.Handle:Hide()
					v.Handle:SetAlpha(0)
				end
			else
				if v.Frame.MoverEnabled then
					v.Handle:EnableMouse(true)
					if not noFade then
						E:UIFrameFadeIn(v.Handle, 0.2, v.Handle:GetAlpha(), 1)
					else
						v.Handle:Show()
						v.Handle:SetAlpha(1)
					end
				end
			end
		else
			v.Handle:EnableMouse(false)
			if not noFade then
				E:UIFrameFadeOut(v.Handle, 0.2, v.Handle:GetAlpha(), 0)
			else
				v.Handle:Hide()
				v.Handle:SetAlpha(0)
			end
		end
	end
end

-- Returns a registered mover from child object or name-string
function E:GetMover(C)
	if type(C) == "string" then
		return self.Movers[C .. "Mover"]
	else
		return self.Movers[self:GetFullFrameName(C) .. "Mover"]
	end
end

function E:RegisterMover(M, MName)
	self.Movers[MName] = M
end

function E:LoadMoverPositions(limit)
	self = E
	
	local Conf = CO.db.profile.movers
	local ConfData = {}
	
	local SmartPosition
	
	if limit then
		local mover = self:GetMover(limit)
		
		if mover then
			ConfData = Conf[mover:GetName()]
			SmartPosition = ConfData["point"]
			
			if ConfData["enableAttach"] and ConfData["attachTo"] and ConfData["attachTo"][1] ~= "" then
				-- Attachment Target exists
				if _G[ConfData["attachTo"][1]] then
					mover:SetParent(_G[ConfData["attachTo"][1]])
					_G[ConfData["attachTo"][1]].Parent = mover
					mover.Frame.MoverEnabled = false
					
					SmartPosition = E:InversePosition(ConfData["point"])
				end
			else
				mover:SetParent(self.Parent)
				mover.Frame.MoverEnabled = true
				
				if ConfData["attachTo"] and ConfData["attachTo"][1] and _G[ConfData["attachTo"][1]] then
					_G[ConfData["attachTo"][1]].Parent = self.Parent					
				end
			end
			
			self:RepositionMover(mover, SmartPosition, ConfData["point"], ConfData["xOffset"] / mover:GetScale(), ConfData["yOffset"] / mover:GetScale())
			
			return
		end
	end
	
	-- k: Mover Name - v: Mover Object
	for k,v in pairs(self.Movers) do
		ConfData = Conf[k]
		
		if ConfData then
			if v then
				
				SmartPosition = ConfData["point"]
				
				if ConfData["enableAttach"] and ConfData["attachTo"] and ConfData["attachTo"][1] ~= "" then
					-- Attachment Target exists
					if _G[ConfData["attachTo"][1]] then
						v:SetParent(_G[ConfData["attachTo"][1]])
						_G[ConfData["attachTo"][1]].Parent = v
						v.Frame.MoverEnabled = false
						
						SmartPosition = E:InversePosition(ConfData["point"])
					end
				else
					v:SetParent(self.Parent)
					v.Frame.MoverEnabled = true
					
					if ConfData["attachTo"] and ConfData["attachTo"][1] and _G[ConfData["attachTo"][1]] then
						_G[ConfData["attachTo"][1]].Parent = self.Parent
					end
				end
				
				self:RepositionMover(v, SmartPosition, ConfData["point"], ConfData["xOffset"] / v:GetScale(), ConfData["yOffset"] / v:GetScale())
			else
				self:print("WARNING: Corrupt mover data found!")
			end
		end
	end
end

-- @PARAM1: Child target
-- @PARAM2: Localized mover name for user display
function E:CreateMover(C, LT, A, X, Y, TT)
	local MNameRaw = self:GetFullFrameName(C)
	local MName = MNameRaw .. "Mover"
	
	if not A then A = "CENTER" end
	if not (X and Y) then X, Y = C:GetWidth(), C:GetHeight() if X <= 0 and Y <= 0 then X, Y = 50, 50 end end
	local M = self:NewFrame("Frame", MName, "LOW", X,Y, {"CENTER", self.Parent, "CENTER", 0, 0}, self.Parent)	
	
	-- Position update function
	-- This is probably the only existing way to deal with constantly moving blizzard frames and also work for everything else ofc
	local function Mover_SetPosition(_, _, parent)
		if parent ~= M then
			C:ClearAllPoints()
			C:SetParent(M)
			C:SetPoint(A, M, A, 0, 0)
		end
	end
	hooksecurefunc(C, "SetPoint", Mover_SetPosition)
	C:SetPoint("CENTER") -- Execute hook initially to force an update
	
	-- Create Mover handle to interact with
	M.Handle = self:CreateMoverHandle(C, LT, A, X, Y, TT)
	M.Handle:SetParent(M)
	M.Handle:SetFrameLevel(99)
	M.Handle:SetFrameStrata("HIGH")	
	
	-- Store reference to child frame
	C.MoverEnabled = true
	M.Frame = C
	
	-- E:GetMover(FrameObjectOrNameAsString).Handle:Show() -- We can use this to access the handle at any time!
	
	M.Handle:SetScript("OnDragStart", function(self)
		local parent = M
		parent:SetMovable(true)
		self:SetClampedToScreen(false)
		parent:SetClampedToScreen(false)
		if E.StickyMovers then
			LibSticky:StartMoving(parent, E.Stickys, E.StickyRange or 1, E.StickyRange or 1, E.StickyRange or 1, E.StickyRange or 1)
		else
			parent:StartMoving()
		end
	end)
	M.Handle:SetScript("OnDragStop", function(self)
		local point, relativePoint, xOfs, yOfs
		local parent = M
		local title = MName
		
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
		
		
		if E.StickyMovers then
			xOfs, yOfs, point, relativePoint = E:GetMoverPoints(parent)
		else
			point, _, relativePoint, xOfs, yOfs = parent:GetPoint(parent:GetNumPoints())
		end
		
		conf["point"] 			= point
		conf["relativePoint"] 	= relativePoint
		conf["xOffset"] 		= xOfs
		conf["yOffset"] 		= yOfs
	end)
	
	-- Internal register
	-- MoverObject, MoverName
	self:RegisterMover(M, MName)
	
	return M
end

function E:RepositionMover(M, Point, RelativePoint, OffsetX, OffsetY)
	self:RepositionFrame(M, Point, RelativePoint, OffsetX, OffsetY)
end

-- Since we move frames via movers, which are basically frames, the frames we want to move with are parented to the mover
-- By later "copying" the translations made to the overlay to the base parent, we can move the whole thing
function E:CreateMoverHandle(C, LT, A, X, Y, TT)
	local MH = self:NewFrame("Frame", "Handle", "HIGH", X,Y, {A, C, A, 0, 0}, C)
	local RGB = self:GetUnitClassColor("player")
	MH:EnableMouse(true)
	MH:SetMovable(true)
	MH:RegisterForDrag("LeftButton")
	
	MH:SetBackdrop({
		bgFile 		= [[Interface\Buttons\WHITE8X8]],
		edgeFile 	= [[Interface\Buttons\WHITE8X8]],
		edgeSize 	= 1,
		tile 		= true, tileSize = 16
	})
	MH:SetBackdropColor(0.05, 0.05, 0.05, 0.6)
	MH:SetBackdropBorderColor(RGB[1], RGB[2], RGB[3], 0.8)
	
	-- Init font overlay
	MH.Name = MH:CreateFontString(nil, "ARTWORK")
	self:InitializeFontFrame(MH.Name, "ARTWORK", "FRIZQT__.TTF", 14, {1,1,1}, 1, {0,0}, "", 250, Y, MH, "CENTER", {1,1})
	MH.Name:SetFont(E.Media:Fetch("font", CO.db.profile.global.generalFont), 14)
	MH.Name:ClearAllPoints()
	MH.Name:SetPoint("CENTER", MH, 'CENTER', 0, 0)
	
	MH.Name:SetText(LT) -- Set provided name
	
	MH:SetAlpha(0) -- For toggle fading
	MH:Hide()
	
	-- Vars for tooltip functionality
	MH.LT = LT
	MH.TT = TT
	
	-- Add tooltip functionality to describe this mover in config mode
	MH:SetScript("OnEnter", self.Mover_GameTooltipOnEnter)
	MH:SetScript("OnLeave", self.Mover_GameTooltipOnLeave)
	
	table.insert(E.Stickys, MH)
	
	return MH
end

-- Update Mover dimensions based on child frame
function E:UpdateMoverDimensions(C)
	local M = self:GetMover(C)
	
	if not M then return false end
	
	M:SetSize(C:GetWidth(), C:GetHeight())
	M.Handle:SetSize(C:GetWidth(), C:GetHeight())
end

-- TOOLTIP METHODS
	function E:Mover_GameTooltipOnEnter()
		-- If user actually wants tooltips
		if E.ShowMoverTooltips then
			GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
			GameTooltip:AddLine(self.LT)
			if self.TT then
				GameTooltip:AddLine(self.TT)
			end
			GameTooltip:Show()
			
			-- Absolutely make sure it's on the very top!
			GameTooltip:SetFrameLevel(99999)
		end
		
		-- Highlight border to indicate the hovered frame
		self:SetBackdropBorderColor(0.7, 0.7, 0.7, 1)
	end

	function E:Mover_GameTooltipOnLeave()
		GameTooltip:Hide()
		local RGB = E:GetUnitClassColor("player")
		self:SetBackdropBorderColor(RGB[1], RGB[2], RGB[3], 0.8)
	end
-- TOOLTIP METHODS END

function E:ResetMoverPositions()
	CO.db.profile.movers = self:TableDeepCopy(self.MoverDefaults)
	
	self:LoadMoverPositions()
end










