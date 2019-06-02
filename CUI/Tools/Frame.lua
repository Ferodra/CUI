local E, L = unpack(select(2, ...)) -- Engine, Locale
local L, CO = E:LoadModules("Locale", "Config")

local _
local HiddenFrame = CreateFrame("Frame", nil, E.Parent)

E.FrameFadeTime = 1
E.Frames = {}
E.Fonts = {}

E.FrameStratas = {
	[1] = "BACKGROUND",
	[2] = "LOW",
	[3] = "MEDIUM",
	[4] = "HIGH",
	[5] = "DIALOG",
	[6] = "FULLSCREEN",
	[7] = "FULLSCREEN_DIALOG",
	[8] = "TOOLTIP",
}

E.BlendModes = {
	["BLEND"] = "BLEND",
	["ADD"] = "ADD",
	["MOD"] = "MOD",
	["DISABLE"] = "DISABLE",
}

E.Positions = {
	["TOPLEFT"] 		= L["TOPLEFT"],
	["LEFT"]		 	= L["LEFT"],
	["BOTTOMLEFT"] 		= L["BOTTOMLEFT"],
	["TOP"] 			= L["TOP"],
	["CENTER"] 			= L["CENTER"],
	["BOTTOM"] 			= L["BOTTOM"],
	["TOPRIGHT"] 		= L["TOPRIGHT"],
	["RIGHT"] 			= L["RIGHT"],
	["BOTTOMRIGHT"] 	= L["BOTTOMRIGHT"],
}

do
	HiddenFrame:Hide()
end

-- type, name, strata, sizeX, sizeY, {point, relativeFrame, relativePoint, offsetX, offsetY}, parent, enablemouse, enablemousewheel, enablekeyboard
function E:NewFrame(type, name, strata, sizeX, sizeY, point, parent, enablemouse, enablemousewheel, enablekeyboard, template)
	
	local Frame
	
	if not type then type = "Frame" end
	if not parent then parent = E.Parent end
	if not point then point = {"CENTER", parent, "CENTER", 0, 0} end
	if not enablemouse then enablemouse = false end
	if not enablemousewheel then enablemousewheel = false end
	if not enablekeyboard then enablekeyboard = false end
	if not sizeX then sizeX = parent:GetWidth() end
	if not sizeY then sizeY = parent:GetHeight() end
	
	Frame = CreateFrame(type, name, parent, template or nil)
	
	if name then
		E.Frames[name] = Frame
	end
	
	if point then Frame:SetPoint(point[1], point[2], point[3], point[4], point[5]) end
	if strata then Frame:SetFrameStrata(strata) end
	if sizeY then Frame:SetWidth(sizeX) end
	if sizeY then Frame:SetHeight(sizeY) end
	if parent then Frame:SetParent(parent) end
	
	Frame:EnableMouse(enablemouse)
	Frame:EnableMouseWheel(enablemousewheel)
	Frame:EnableKeyboard(enablekeyboard)
	
	return Frame
end

local InitFontOffset, InitShadowOffset, InitFontColor = {0, 0}, {1, 1}, {0.9, 0.9, 0.9}
InitShadowColor = {0,0,0,1}
function E:InitializeFontFrame(Frame, DrawLayer, Font, FontSize, FontColor, FontAlpha, Offset, DefaultText, Width, Height, Parent, Anchor, ShadowOffset, FontFlags, ShadowColor)

	if not FontColor then FontColor = InitFontColor end
	if not ShadowOffset then ShadowOffset = InitShadowOffset end
	if not Font then Font = "FRIZQT__.TTF" end
	if not FontSize then FontSize = 16 end
	if not Offset then Offset = InitFontOffset end
	if not DrawLayer then DrawLayer = "OVERLAY" end
	if not Parent then Parent = self.Parent end
	if not Anchor then Anchor = "CENTER" end
	if not Width then Width = Parent:GetWidth() end
	if not Height then Height = Parent:GetHeight() end
	if not ShadowColor then ShadowColor = InitShadowColor end
	
	Frame:ClearAllPoints()
	Frame:SetShadowColor(ShadowColor[1], ShadowColor[2], ShadowColor[3])
	Frame:SetTextColor(FontColor[1], FontColor[2], FontColor[3], FontAlpha)
	Frame:SetShadowOffset(ShadowOffset[1], ShadowOffset[2])
	Frame:SetFont("Fonts\\" .. Font, FontSize, FontFlags or "")
	Frame:SetPoint(Anchor, Parent, Anchor, Offset[1], Offset[2])
	Frame:SetText(DefaultText)
	Frame:SetDrawLayer(DrawLayer)
	Frame:SetWidth(Width)
	Frame:SetHeight(Height)
	
	self:SetFontInfo(Frame, Font, nil, FontSize, FontColor)
end

-- The return value and E.Fonts[Name] allows access to typical Frame and Font methods
function E:NewFont(Name, Layer, Parent)
	local Frame 	= E:NewFrame("Frame", Name, _, _, _, _, Parent)
	
	-- Override the frame object to basically extend it
	Frame			=	Frame:CreateFontString(Name, Layer)
	E:InitializeFontFrame(Frame, Layer, _, _, _, _, {0, 0}, "Hello world", _, _, Parent)
	E.Fonts[Name] = Frame
	
	return Frame
end

-- Reposition Frame entirely
function E:RepositionFrame(Frame, Point, RelativePoint, OffsetX, OffsetY, Parent)
	
	local _
	
	if not Parent then
		Parent = Frame:GetParent()
	end
	Frame:ClearAllPoints()
	Frame:SetPoint(Point, Parent, RelativePoint, OffsetX, OffsetY)
end

-- Move frame relative to its parent
function E:MoveFrame(Frame, OffsetX, OffsetY)
	local Point, RelativeTo, RelativePoint = Frame:GetPoint(Frame:GetNumPoints())
	Frame:SetPoint(Point, RelativeTo, RelativePoint, OffsetX, OffsetY)
end

-- Push frame relative from its current location
function E:PushFrame(Frame, PushX, PushY)
	local Point, RelativeTo, RelativePoint, OffsetX, OffsetY = Frame:GetPoint(Frame:GetNumPoints())
	if not OffsetX then OffsetX = 0 end
	if not OffsetY then OffsetY = 0 end
	Frame:SetPoint(Point, RelativeTo, RelativePoint, OffsetX + PushX, OffsetY + PushY)
end

function E:SetFramePoint(Frame, Point)
	local _, RelativeTo = Frame:GetPoint(Frame:GetNumPoints())
	
	Frame:SetPoint(Point, RelativeTo, Point)
end

------------------------
-- To correctly update a font, we have to set the font info with this method first.
-- When ready to update, it is followed by E:UpdateFont(FrameName)
-- If no or less than the maximum amount of arguments are passed, all info will be retrieved automatically
-- This is potentially extremely CPU-intensive, since we are probably iterating through every single font (About 200 frames)
----- @PARAM
--------	Frame(object):		Font object to to update
--------	fontName(str):		Font type. It is spcified by a full path (such as )
--------	fontFlags(str):		Additional info such as "OUTLINE, MONOCHROME"
--------	fontHeight(num):	The Font Height in px
--------	fontColor(table):	A table to represent the r,g,b colors and alpha values in that order. Values range from 0 to 1
----- @RETURN
--------	NONE
------------------------

function E:SetFontInfo(Frame, fontName, fontFlags, fontHeight, fontColor)
	
	if not Frame then return end
	
	local FontInfo = {}
	
	-- Get current values from font if not specified. This is to allow a more dynamic flow
	if not fontName or not fontFlags or not fontHeight or not fontColor then FontInfo = E:GetFontInfo(Frame) end
	
	if not fontName then fontName 		= FontInfo["fontName"] end
	if not fontFlags then fontFlags 	= FontInfo["fontFlags"] end
	if not fontHeight then fontHeight 	= FontInfo["fontHeight"] end
	if not fontColor then fontColor 	= {FontInfo["r"],FontInfo["g"],FontInfo["b"],FontInfo["a"]} end
	
	Frame["fontName"]	=	fontName
	Frame["fontFlags"]	=	fontFlags
	Frame["fontHeight"]	=	fontHeight
	Frame["r"]			=	fontColor[1]
	Frame["g"]			=	fontColor[2]
	Frame["b"]			=	fontColor[3]
	Frame["a"]			=	fontColor[4]
end

function E:GetFontInfo(Frame)
	
	local Data = {}
	local fontName, fontHeight, fontFlags = Frame:GetFont()
	local r, g, b, a = Frame:GetTextColor()
	
	Data["fontName"] 	= fontName
	Data["fontHeight"] 	= fontHeight
	Data["fontFlags"]	= fontFlags
	Data["r"] 			= r
	Data["g"] 			= g
	Data["b"] 			= b
	Data["a"] 			= a
	
	return Data
end

-- Update Font with values stored within
function E:UpdateFont(Frame)
	
	if Frame ~= nil then				
		Frame:SetFont(Frame["fontName"], Frame["fontHeight"], Frame["fontFlags"])
		
		if Frame["r"] and Frame["g"] and Frame["b"] and Frame["a"] then
			Frame:SetTextColor(Frame["r"], Frame["g"], Frame["b"], Frame["a"])
		end
	else
		return
	end
end

-- Move a font container frame properly
function E:SetFontFramePoint(Frame, Point)
	Frame:ClearAllPoints()
	Frame:SetPoint(Point, Frame:GetParent())
	Frame:SetJustifyH(Point)
end

-- Parent Frame 
function E:MergeFrames(Source, Target)
	Source:SetParent(Target)
	Source:SetAllPoints(Target)
	--E:debugprint(E:GetFrameName(Target) .. " is now a parent of " .. E:GetFrameName(Source))
end

function E:GetFrameName(Frame)
	return Frame:GetName()
end

function E:GetFramePosition(Frame)
	local _,_,_,offsetX,offsetY = Frame:GetPoint()
	return offsetX,offsetY
end

function E:UpdateBlendmode(Frame, Blendmode)
	Frame:GetStatusBarTexture():SetBlendMode(Blendmode)
end

function E:GetFrameLevel(Frame)
	if not Frame then Frame = E.Frames[Frame] end
	if Frame:GetFrameType() then
		return Frame:GetFrameLevel()
	else
		return 1
	end
end

function E:SetModelInfo(Frame, Info, Value)
	
	if Info == "SetPortraitZoom" then
		Frame:SetPortraitZoom(Value)
	elseif Info == "SetCamDistanceScale" then
		Frame:SetCamDistanceScale(Value)
	elseif Info == "SetRotation" then
		Frame:SetRotation(Value)
	elseif Info == "SetDisplayInfo" then
		Frame:SetDisplayInfo(Value)
	elseif Info == "SetUnit" and UnitExists(Value) then -- When Unit REALLY exists!
		Frame:SetUnit(Value)
	elseif Info == "ClearUnit" then
		Frame:ClearModel()
	end
end

function E:ToggleFrame(Frame, State, Fade)
	Fade = Fade or false

	if State == false then
		if Frame:GetAlpha() ~= 0 and Fade == true then
			UIFrameFadeOut(Frame, E.FrameFadeTime, Frame:GetAlpha(), 0) -- To make sure we never constantly repeat the fade from 1 to 0, fade from current alpha
		end
		if Frame:GetAlpha() == 0 or Fade == false then
			Frame:Hide()
			Frame:SetAlpha(0)
		end
	end
	if State == true then
		if Frame:GetAlpha() ~= 1 and Fade == true then
			UIFrameFadeOut(Frame, E.FrameFadeTime, Frame:GetAlpha(), 1) -- To make sure we never constantly repeat the fade from 1 to 0, fade from current alpha
		end
		if Frame:GetAlpha() == 1 or Fade == false then
			Frame:Show()
			Frame:SetAlpha(1)
		end
	end
end

function E:Remove(Frame)
	if Frame.UnregisterAllEvents then
		Frame:UnregisterAllEvents()
		Frame:SetParent(HiddenFrame)
	else
		Frame.Show = Frame.Hide
	end
	
	Frame:Hide()
	--Frame:SetScript("OnShow", function(self) self:Hide() end)
end

function E:SetFrameBorder(F, S, R, G, B, A)
	if S then
		F:SetBackdrop({ edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = S, tile = true})
	end
	if R and G and B and A then
		F:SetBackdropBorderColor(R, G, B, A)
	end
end

function E:SetVisibilityHandler(object)
	object:SetAttribute("_onstate-visible", [[
		if newstate == 1 then
			self:Show();
			self:SetAttribute("IsShown", true)
		else
			self:Hide();
			self:SetAttribute("IsShown", false)
		end
		-- print(newstate, self:GetName())
	]]);
end

local ButtonTex
function E:SkinButtonIcon(B, BC)
	if not B then return end
	
	if not B.Border then
	
		ButtonTex = B.Tex or B.Icon or B.icon
		
		B.Border = CreateFrame("Frame", nil)
		B.Border:SetAllPoints(B)
		B.Border:SetParent(B)
		
		B.Border:SetFrameLevel(B:GetFrameLevel() + 2)
		
		B.Border:SetBackdrop({bgFile = "", 
			edgeFile = [[Interface\Buttons\WHITE8X8]], 
			edgeSize = 1, 
			tile = true, tileSize = 16});
			
		B.Highlight = self:CreateHighlight(B)
		B.Highlight:SetColorTexture(1,1,0, 0.15)
		B.Highlight:SetBlendMode("ADD")
		
		if ButtonTex and ButtonTex.SetTexCoord then
			ButtonTex:SetTexCoord(0.06,0.94,0.06,0.94)
		end
	end
	if BC then
		if not BC.r then
			B.Border:SetBackdropBorderColor(BC[1], BC[2], BC[3], BC[4] or 1)
		else
			B.Border:SetBackdropBorderColor(BC.r, BC.g, BC.b, BC.a or 1)
		end
	end
end

function E:ColorizeButton(Button, Color)
	E:ColorizeAuraButton(Button, nil, nil, nil, nil, nil, nil, Color)
end

function E:ColorizeAuraButton(Slot, DType, Unit, UnitAuraClass, AuraName, SpellID, DefaultColor, OverrideColor)
	local NormalTexture = Slot.__MSQ_NormalTexture
	
	if NormalTexture then
		local Color = OverrideColor or self:GetAuraColor(DType, Unit, UnitAuraClass, AuraName, SpellID, DefaultColor)
		
		if Color then
			if not Color.r then
				NormalTexture:SetVertexColor(Color[1], Color[2], Color[3], Color[4] or 1)
			else
				NormalTexture:SetVertexColor(Color.r, Color.g, Color.b, Color.a or 1)
			end
		end
	else
		E:SkinButtonIcon(Slot, OverrideColor or self:GetAuraColor(DType, Unit, UnitAuraClass, AuraName, SpellID, DefaultColor))
	end
end

-- Adds an hover highlight to the specified frame
function E:CreateHighlight(F)
	local H = F:CreateTexture("HighlightTex")
	H:SetDrawLayer("HIGHLIGHT", 1)
	H:SetParent(F)
	H:SetAllPoints(true)

	H:SetColorTexture(1, 1, 0, 0.1)
	H:SetBlendMode("ADD")

	return H
end

-- Adds an black border to the specified frame
function E:CreateBorder(F, BorderFile, BorderSize)
	local B = CreateFrame("Frame", nil, F)
	B:SetAllPoints(true)
	
	B.File = BorderFile
	
	B.SetBorderSize = function(size)
		local Color = {B:GetBackdropBorderColor()}
		
		B:SetBackdrop({
			edgeFile = B.File or [[Interface\Buttons\WHITE8X8]],
			edgeSize = size,
			tile = true
		})
		
		-- Try to keep color
		B:SetBackdropBorderColor(Color[1] or 0, Color[2] or 0, Color[3] or 0, Color[4] or 1)
	end
	B.SetBorderSize(BorderSize or 1)

	return B
end

-- Adds an near-black background to the specified frame
function E:CreateBackground(F)
	local B = F:CreateTexture(nil, "BACKGROUND")
	B:SetAllPoints(F)

	B:SetColorTexture(0.1, 0.1, 0.1, 1)

	return B
end

function E:CreateTextureObject(Frame, SubObject, DrawLayer)
	Frame[SubObject] = Frame:CreateTexture(nil, DrawLayer or "OVERLAY")
	Frame[SubObject]:SetAllPoints(Frame)
	
	return Frame.T
end

-- Creates a new child frame of the specified parent and adds an texture slot to it
local DefaultCTFPoint = {"CENTER", E.Parent, "CENTER", 0, 0}
function E:CreateTextureFrame(Point, Parent, SizeX, SizeY, DrawLayer)
	
	if not Point then Point = DefaultCTFPoint end

	local TF = CreateFrame("Frame", nil)
	TF:SetPoint(Point[1], Point[2], Point[3], Point[4], Point[5])
	TF:SetParent(Parent or E.Parent)
	TF:SetSize(SizeX, SizeY)

	E:CreateTextureObject(TF, "T", DrawLayer)

	return TF
end

function E:SortFrames(Frames, Parent, Width, Height, SizeMult, PerRow, InverseStartX, InverseStartY, GapX, GapY, Ordered)
	local currentRow, currentColumn, xOffset, yOffset, prefixX, prefixY = 0, 0, 0, 0, 0, 0
	local pointH, pointV, point
	local endRow, endColumn, index = 1, 1, 1
	
	SizeMult = SizeMult or 1
	if PerRow == 0 then PerRow = 1 end
	if PerRow < 0 then prefixX = -1; prefixY = -1; else prefixX = 1; prefixY = 1; end
	
	-- Perform Direction transform
	prefixX = prefixX * (InverseStartX and -1 or 1)
	prefixY = prefixY * (InverseStartY and -1 or 1)
	
	if prefixX < 0 then pointH = "RIGHT" else pointH = "LEFT" end
	if prefixY < 0 then pointV = "TOP" else pointV = "BOTTOM" end
	point = pointV .. pointH
	
	for _, child in (Ordered and ipairs or pairs)(Frames) do
	--------------------------------------------------------------------
		
		if Width then child:SetWidth(Width) else Width = child:GetWidth() end
		if Height then child:SetHeight(Height) else Height = child:GetHeight() end
		child:SetScale(SizeMult)
		
		child:ClearAllPoints()
		child:SetPoint(point, Parent, point)
		child:SetParent(Parent)
		
		-- We have to use the previous column and row values to make it work properly
		xOffset = ((((Width * SizeMult) * currentColumn) + (GapX * currentColumn)) * prefixX) / SizeMult
		yOffset = ((((Height * SizeMult) * currentRow) + (GapY * currentRow)) * prefixY)  / SizeMult
		
		-- If the current button should start the next row
		if index % PerRow == 0 then
			currentRow = currentRow + 1
			
			currentColumn = 0
		else
			currentColumn = currentColumn + 1
		end
		
		E:MoveFrame(child, xOffset, yOffset)
		
		--------------------------------------------------------------------
		index = index + 1
	end
	
	index = index - 1
	endColumn = E:makePositive(PerRow) -- This always will be correct
	endRow = currentRow
	
	-- Start new row when needed to prevent false return values
	if index - (endColumn * endRow) > 0 then
		endRow = endRow + 1
	end
	-- Clamp EndWidth so we dont get overflow
	if endColumn > index then
		endColumn = index
	end
	
	local EndWidth = ((Width * SizeMult) + GapX) * (endColumn) - GapX
	local EndHeight = ((Height * SizeMult) + GapY) * (endRow) - GapY
	return EndWidth, EndHeight
end

function E:CreateArtFill(frame)
	frame.artFill = CreateFrame("Frame", nil, frame)
	
	frame.artFill:SetFrameStrata("BACKGROUND")
	frame.artFill:SetFrameLevel(1)
	
	frame.artFill.Border = self:CreateBorder(frame.artFill, nil, 1)
	frame.artFill.Background = self:CreateBackground(frame.artFill)
end

-- Description: This method allows for easy sub-bar creation, as it automatically sets the correct points for the sub-bar
--------------	to be on any position inside of the other bar
-- @PARAM 0: (self) The Sub-Bar parent
-- @PARAM 1: (StatusBar) The Sub-Bar
-- @PARAM 2: (boolean) Wether or not the Param 1 frame should be on the target statusbar texture
-- @PARAM 3: (boolean) If the Param 1 bar should be reversed
-- @PARAM 4: (string) The bar orientation for the Param 1 bar
local function SetSubBar(self, Target, OnTexture, Reverse, Orientation)
	
	Target:ClearAllPoints()
	
	-- If Bar acutally is a bar
	if Target.SetReverseFill then
		Target:SetReverseFill(Reverse)
		Target:SetOrientation(Orientation)
	end
	
	if not OnTexture then
		if not Reverse then
			Target:SetPoint("BOTTOMLEFT", self:GetStatusBarTexture(), Orientation == "HORIZONTAL" and "BOTTOMRIGHT" or "TOPLEFT")
			Target:SetPoint("TOPRIGHT", self)
		else
			Target:SetPoint("TOPRIGHT", self:GetStatusBarTexture(), Orientation == "HORIZONTAL" and "TOPLEFT" or "BOTTOMRIGHT")
			Target:SetPoint("BOTTOMLEFT", self)
		end
	else
		Target:SetAllPoints(self:GetStatusBarTexture())
	end
end

-- Final solution taken from: https://wowwiki.fandom.com/wiki/USERAPI_ColorGradient
function E:ColorGradient(perc, ...)
	if perc >= 1 then
		local r, g, b = select(select('#', ...) - 2, ...)
		return r, g, b
	elseif perc <= 0 then
		local r, g, b = ...
		return r, g, b
	end
	
	local num = select('#', ...) / 3

	local segment, relperc = math.modf(perc*(num-1))
	local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...)

	return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc
end

function E:CreateFont(Parent, PathString)
	local Font = Parent:CreateFontString(nil, "ARTWORK")
	self:InitializeFontFrame(Font, "ARTWORK", nil, 11, {0.8,0.8,0.8}, 1, {0,0}, "", 300, 20, Parent, "CENTER", {1,1})
	
	if PathString then
		self:RegisterPathFont(Font, PathString)
	end
	
	return Font
end

---------------------------------------
--	Bar API
---------------------------------------
local function Bar_SetOverlayColor(self, r, g, b, a, RGBA) if not RGBA then self.Overlay:SetStatusBarColor(r, g, b, a) else self.Overlay:SetStatusBarColor(RGBA[1], RGBA[2], RGBA[3], RGBA[4] or a or 1) end end
local function Bar_Border_SetSize(self, size) local Color = {self:GetBackdropBorderColor()}; self:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]],edgeSize = size,}) self:SetBorderColor(unpack(Color)) end
local function Bar_Border_SetColor(self, r, g, b, a) self:SetBackdropBorderColor(r, g, b, a) end
local function Bar_SetBorderSize(self, size) self.Border:SetBorderSize(size) end
local function Bar_SetBorderColor(self, r, g, b, a) self.Border:SetBorderColor(r, g, b, a) end
local function Bar_SetBackgroundColor(self, r, g, b, a) self.Background.Tex:SetColorTexture(r or 0.1, g or 0.1, b or 0.1, a) end
local function Bar_GetValue(self) return self.Overlay:GetValue() end
local function Bar_SetValue(self, value) self.Overlay:SetValue(value) end
local function Bar_GetMinMaxValues(self) return self.Overlay:GetMinMaxValues() end
local function Bar_SetMinMaxValues(self, min, max) self.Overlay:SetMinMaxValues(min or 0, max) end

function E:CreateBar(name, strata, sizeX, sizeY, point, parent, enablemouse, enablemousewheel, enablekeyboard, template)
	local MainFrame = E:NewFrame('Statusbar', name, strata, sizeX, sizeY, point, parent, enablemouse, enablemousewheel, enablekeyboard)
	
	local BackgroundName, OverlayName, BorderName
	if name then
		BackgroundName 	= name .. 'Background'
		OverlayName 	= name .. 'Overlay'
		BorderName 		= name .. 'Border'
	end
	
	-- BACKGROUND
		local Background = E:NewFrame('Frame', BackgroundName, strata, sizeX, sizeY, point, MainFrame)
			Background:SetAllPoints(MainFrame)
			Background.Tex = Background:CreateTexture(nil)
			Background.Tex:SetAllPoints(Background)
			
			MainFrame.SetBackgroundColor = Bar_SetBackgroundColor
			
	-- Add Background
		MainFrame.Background = Background
		
	-- OVERLAY
		local Overlay = E:NewFrame('Statusbar', OverlayName, strata, sizeX, sizeY, point, Background, nil, nil, nil, template)
			E:RegisterStatusBar(Overlay)

			E.Libs.LibSmooth:SmoothBar(Overlay)
			
			Overlay:SetAllPoints(Background)
			
			-- Convenience functions
			MainFrame.GetValue = Bar_GetValue
			MainFrame.SetValue = Bar_SetValue
			MainFrame.GetMinMaxValues = Bar_GetMinMaxValues
			MainFrame.SetMinMaxValues = Bar_SetMinMaxValues
			MainFrame.SetOverlayColor = Bar_SetOverlayColor
			
	-- Add Overlay
		MainFrame.Overlay = Overlay
	
	-- BORDER
		local Border = E:NewFrame('Frame', BorderName, strata, sizeX, sizeY, point, Overlay)
			Border:SetAllPoints(Overlay)
			Border.SetBorderColor = Bar_Border_SetColor
			Border.SetBorderSize = Bar_Border_SetSize
			
			-- Convenience functions
			MainFrame.SetBorderColor = Bar_SetBorderColor
			MainFrame.SetBorderSize = Bar_SetBorderSize
	
	-- Add Border
		MainFrame.Border = Border	
		
	-- Some init stuff
	MainFrame:SetBackgroundColor(0.1, 0.1, 0.1, 0.85)
	MainFrame:SetBorderSize(1)
	MainFrame:SetBorderColor(0.15, 0.15, 0.15, 1)
	

	return MainFrame
end



local function AddAPI(object)
	local metatable = getmetatable(object).__index
	if not object.CreateBackground then metatable.CreateBackground = E.CreateBackground end
	if not object.CreateBorder then metatable.CreateBorder = E.CreateBorder end
end

local function AddBarAPI(object)
	local metatable = getmetatable(object).__index
	if not object.SetSubBar then metatable.SetSubBar = SetSubBar end
end

local Frame = CreateFrame("Frame")
AddAPI(Frame)

local Bar = CreateFrame("StatusBar")
AddAPI(Bar)
AddBarAPI(Bar)



