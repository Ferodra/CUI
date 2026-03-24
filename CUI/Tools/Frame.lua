---@class E, L
local E, L = unpack(select(2, ...)) -- Engine
local CO = E:LoadModules("Config")

local _
local abs = math.abs

local HiddenFrame = CreateFrame("Frame", "CUI_HiddenFrame", E.Parent)
E.HiddenFrame = HiddenFrame

local DefaultColor = {0, 0, 0, 1}
local DefaultWhiteTexture = "Interface/AddOns/CUI/Textures/borders/WHITE8X8"

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
	if not sizeX then sizeX = parent:GetWidth() end
	if not sizeY then sizeY = parent:GetHeight() end
	
	Frame = CreateFrame(type, name, parent, template)
	
	if name then
		E.Frames[name] = Frame
	end
	
	if point then Frame:SetPoint(point[1], point[2], point[3], point[4], point[5]) end
	if strata then Frame:SetFrameStrata(strata) end
	if sizeX then Frame:SetWidth(sizeX) end
	if sizeY then Frame:SetHeight(sizeY) end
	if parent then Frame:SetParent(parent) end
	
	Frame:EnableMouse(enablemouse or false)
	Frame:EnableMouseWheel(enablemousewheel or false)
	Frame:EnableKeyboard(enablekeyboard or false)
	
	return Frame
end

function E:InitializeFontMinimal(Frame, DrawLayer, DrawLayerIndex, FontSize)	
	Frame:SetDrawLayer(DrawLayer, DrawLayerIndex)
	Frame:SetFont("Fonts/FRIZQT__.TTF", FontSize or 10)
end

local InitFontOffset, InitShadowOffset, InitFontColor = {0, 0}, {1, 1}, {0.9, 0.9, 0.9}
InitShadowColor = {0,0,0,1}
local BlizzFonts = {"FRIZQT__.TTF", "ARIALN.TTF", "SKURRI.TTF", "MORPHEUS.TTF"}
function E:InitializeFontFrame(Frame, DrawLayer, Font, FontSize, FontColor, FontAlpha, Offset, DefaultText, Width, Height, Parent, Anchor, ShadowOffset, FontFlags, ShadowColor)

	if type(DrawLayer) == "table" and not Parent then
		Parent = DrawLayer
	end
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
	Frame:SetShadowColor(unpack(ShadowColor))
	Frame:SetTextColor(FontColor[1], FontColor[2], FontColor[3], FontAlpha)
	Frame:SetShadowOffset(unpack(ShadowOffset))
	
	local IsBlizzFont
	for k,v in pairs(BlizzFonts) do
		if v == Font:upper() then IsBlizzFont = true; break; end
	end
	
	if IsBlizzFont then
		Frame:SetFont("Fonts\\" .. Font, FontSize, FontFlags or "")
	else
		Frame:SetFont(Font, FontSize, FontFlags or "")
	end
	
	Frame:SetPoint(Anchor, Parent, Anchor, unpack(Offset))
	Frame:SetText(DefaultText)
	Frame:SetDrawLayer(DrawLayer)
	Frame:SetWidth(Width)
	Frame:SetHeight(Height)
	self:SetFontInfo(Frame, Font, nil, FontSize, FontColor)
end

function E:NewFontObject(Name, Layer, Parent, FontSize, LayerIndex)
	LayerIndex = LayerIndex or 1
	assert(type(LayerIndex) == "number", "LayerIndex (arg5) must be a number!")
	
	Layer = Layer or 'ARTWORK'
	
	local Font = Parent:CreateFontString(Name, Layer)
	--self:InitializeFontFrame(Font, Layer, _, FontSize, _, _, {0, 0}, "Hello world", _, _, Parent)
	self:InitializeFontMinimal(Font, Layer, LayerIndex, FontSize)
	
	return Font
end

-- The return value and E.Fonts[Name] allows access to typical Frame and Font methods
local NewFontDefaultOffset = {0, 0}
function E:NewFont(Name, Layer, Parent)
	local Frame 	= E:NewFrame("Frame", Name, _, _, _, _, Parent)
	
	Layer = Layer or 'ARTWORK'
	
	-- Override the frame object to basically extend it
	Frame			=	Frame:CreateFontString(Name, Layer)
	self:InitializeFontFrame(Frame, Layer, _, _, _, _, NewFontDefaultOffset, "Hello world", _, _, Parent)
	if Name then
		E.Fonts[Name] = Frame
	else
		table.insert(E.Fonts, Frame)
	end
	
	return Frame
end

-- Wrapper function for new 9.0 creation of frames with a Backdrop
function E:CreateBackdropFrame(frameType, frameName, parentFrame, template)
	if BackdropTemplateMixin then
		if not template then template = "" end
		if template == "" then
			template = "BackdropTemplate"
		else
			template = template .. ", BackdropTemplate"
		end
	end
	
	return CreateFrame(frameType, frameName, parentFrame, template)
end

-- Reposition Frame entirely
function E:RepositionFrame(Frame, Point, RelativePoint, OffsetX, OffsetY, Parent)	
	if not Parent then
		Parent = Frame:GetParent()
	end
	Frame:ClearAllPoints()
	Frame:SetPoint(Point, Parent, RelativePoint, OffsetX, OffsetY)
end

-- Move frame relative to its parent
function E:MoveFrame(Frame, OffsetX, OffsetY)
	local Point, RelativeTo, RelativePoint = Frame:GetPoint(Frame:GetNumPoints())
	--print(Frame:GetName(), Frame, Point, RelativeTo, RelativePoint, OffsetX, OffsetY)
	Frame:SetPoint(Point or 'CENTER', RelativeTo or E.Parent, RelativePoint or 'CENTER', OffsetX, OffsetY)
end

-- Push frame relative from its current location
function E:PushFrame(Frame, PushX, PushY)
	local Point, RelativeTo, RelativePoint, OffsetX, OffsetY = Frame:GetPoint(Frame:GetNumPoints())
	if not OffsetX then OffsetX = 0 end
	if not OffsetY then OffsetY = 0 end
	Frame:SetPoint(Point or 'CENTER', RelativeTo or E.Parent, RelativePoint or 'CENTER', OffsetX + PushX, OffsetY + PushY)
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

function E:SetFontInfo(Frame, fontName, fontFlags, fontHeight, fontColor, pushUpdate)
	
	if not Frame then return end
	
	local FontInfo = {}
	
	-- Get current values from font if not specified. This is to allow a more dynamic flow
	if not fontName or not fontFlags or not fontHeight or not fontColor then FontInfo = E:GetFontInfo(Frame) end
	
	if not fontName then 						fontName 	= FontInfo["fontName"] end
	if not fontFlags then 						fontFlags 	= FontInfo["fontFlags"] end
	if not fontHeight then 						fontHeight 	= FontInfo["fontHeight"] end
	if not fontColor and FontInfo["r"] then 	fontColor 	= {FontInfo["r"],FontInfo["g"],FontInfo["b"],FontInfo["a"]} end
	
	Frame["fontName"]	=	fontName
	Frame["fontFlags"]	=	fontFlags
	Frame["fontHeight"]	=	fontHeight
	
	local Div = 1
	
	-- Wow
	if not issecretvalue(fontColor[1]) then
		if fontColor and (fontColor[1] > 1 or fontColor[2] > 1 or fontColor[3] > 1) then Div = 255 end
		Frame["r"]			=	fontColor and (fontColor[1] / Div)
		Frame["g"]			=	fontColor and (fontColor[2] / Div)
		Frame["b"]			=	fontColor and (fontColor[3] / Div)
		Frame["a"]			=	fontColor and fontColor[4] or 1
	else
		-- Pull from db
		if Frame.DBColor then		
			Frame.r = Frame.DBColor.r
			Frame.g = Frame.DBColor.g
			Frame.b = Frame.DBColor.b
			Frame.a = Frame.DBColor.a
		else
			Frame.r = 1
			Frame.g = 1
			Frame.b = 1
			Frame.a = 1
		end
	end
	
	if pushUpdate then
		self:UpdateFont(Frame)
	end
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

-- Update Fonts with values stored within
function E:UpdateFont(Font)

	if not Font then return false end
	
	Font:SetFont(Font["fontName"], Font["fontHeight"], Font["fontFlags"])
	if Font["r"] and Font["g"] and Font["b"] and Font["a"] then
		Font:SetTextColor(Font["r"], Font["g"], Font["b"], Font["a"])
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
			E:UIFrameFadeOut(Frame, E.FrameFadeTime, Frame:GetAlpha(), 0) -- To make sure we never constantly repeat the fade from 1 to 0, fade from current alpha
		end
		if Frame:GetAlpha() == 0 or Fade == false then
			Frame:Hide()
			Frame:SetAlpha(0)
		end
	elseif State == true then
		if Frame:GetAlpha() ~= 1 and Fade == true then
			E:UIFrameFadeOut(Frame, E.FrameFadeTime, Frame:GetAlpha(), 1) -- To make sure we never constantly repeat the fade from 1 to 0, fade from current alpha
		end
		if Frame:GetAlpha() == 1 or Fade == false then
			Frame:Show()
			Frame:SetAlpha(1)
		end
	end
end

function E:Remove(Frame, KeepEvents)
	if not Frame then return end
	
	if not KeepEvents and Frame.UnregisterAllEvents then
		Frame:UnregisterAllEvents()
	end
	
	Frame:SetParent(HiddenFrame)
end

function E:SetFrameBorder(F, S, R, G, B, A)
	if (F and not F.SetBackdrop) or not F then return end
	
	if S then
		-- No longer supported by WoW...
		if S < 0 then S = 1 end
		F:SetBackdrop({ edgeFile = DefaultWhiteTexture, edgeSize = S, tile = true})
	end
	if R and G and B and A then
		F:SetBackdropBorderColor(R, G, B, A)
	end
end

function E:SetVisibilityHandler(object, condition)
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
	
	if condition then
		if SecureCmdOptionParse(condition) == "0" then
			object:Hide()
		else
			object:Show()
		end
	end
end

function E:ValidateColorTable(Color)
	if Color then
		if not Color.GetRGB then
			if not Color.r and not Color.g and not Color.b then
				Color[1] = Color[1] or 1
				Color[2] = Color[2] or 1
				Color[3] = Color[3] or 1
				Color[4] = Color[4] or 1
			else
				Color.r = Color.r or 1
				Color.g = Color.g or 1
				Color.b = Color.b or 1
				Color.a = Color.a or 1
			end
		else
			Color.r, Color.g, Color.b, Color.a = Color:GetRGBA()
		end
		
		return Color
	else
		return {1,1,1,1}
	end
end

local ButtonTex
function E:SkinButtonIcon(Button, Color, NoBorder, NoHighlight)
	if not Button then return end
	
	if not Button.Border then
	
		ButtonTex = Button.Tex or Button.Icon or Button.icon
		
		if not NoBorder then
			local Border = E:CreateBackdropFrame("Frame", nil)
			
			Border:SetAllPoints(Button)
			Border:SetParent(Button)
			Border:SetFrameLevel(Button:GetFrameLevel() + 2)
			
			-- Yes, this *has* to be a new table every time
			-- If we were to use a variable for this, the backdrop edge would go haywire and stop working
			Border:SetBackdrop({bgFile = "", 
				edgeFile = DefaultWhiteTexture, 
				edgeSize = 1, 
				tile = true, tileSize = 16});
				
			Button.Border = Border
		end
		
		if not NoHighlight then
			local Highlight = self:CreateHighlight(Button)
			Highlight:SetColorTexture(1,1,0, 0.15)
			Highlight:SetBlendMode("ADD")
			
			Button.Highlight = Highlight
		end
		
		if ButtonTex and ButtonTex.SetTexCoord then
			ButtonTex:SetTexCoord(0.06,0.94,0.06,0.94)
		end
	end
	
	if NoBorder then return end
	
	if Color then
		Color = E:ValidateColorTable(Color)
		
		if not Color.r then
			Button.Border:SetBackdropBorderColor(Color[1], Color[2], Color[3], Color[4])
		else
			Button.Border:SetBackdropBorderColor(Color.r, Color.g, Color.b, Color.a )
		end
	end
end

function E:ColorizeButton(Button, Color)
	E:ColorizeAuraButton(Button, nil, nil, nil, nil, nil, nil, Color)
end

function E:ColorizeAuraButton(Slot, DType, Unit, UnitAuraClass, AuraName, SpellID, DefaultColor, OverrideColor)
	local NormalTexture = Slot.__MSQ_Normal
	
	if NormalTexture then
		local Color = OverrideColor or self:GetAuraColor(DType, Unit, UnitAuraClass, AuraName, SpellID, DefaultColor)
		
		if Color then
			if not Color.GetRGB then
				if not Color.r then
					NormalTexture:SetVertexColor(Color[1], Color[2], Color[3], Color[4] or 1)
				else
					NormalTexture:SetVertexColor(Color.r, Color.g, Color.b, Color.a or 1)
				end
			else
				NormalTexture:SetVertexColor(Color:GetRGBA())
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
	local B = self:CreateBackdropFrame("Frame", nil, F)
	B:SetAllPoints(true)
	
	B.File = BorderFile
	
	B.SetBorderSize = function(size)
		if size < 0 then size = 1 end
		local Color = {B:GetBackdropBorderColor()}
		
		B:SetBackdrop({
			edgeFile = B.File or DefaultWhiteTexture,
			edgeSize = size,
			tile = false,
			tileEdge = false,
		})
		
		-- Try to keep color
		B:SetBackdropBorderColor(Color[1] or 0, Color[2] or 0, Color[3] or 0, Color[4] or 1)
	end
	B.SetBorderSize(BorderSize or 1)

	return B
end

-- Adds an near-black background to the specified frame
function E:CreateBackground(F, WithFrame)
	local BGFrame
	if WithFrame then
		BGFrame = CreateFrame("Frame", nil, F)
		BGFrame:SetFrameLevel(F:GetFrameLevel()-2)
		BGFrame:SetAllPoints(F)
	end
	
	local Texture = self:CreateTextureObject(BGFrame or F, "Background", "BACKGROUND")

	Texture:SetColorTexture(0.1, 0.1, 0.1, 1)
	
	if BGFrame then
		BGFrame.Tex = Texture
		BGFrame.SetColorTexture = function(self, r,g,b,a)
			self.Tex:SetColorTexture(r,g,b,a)
		end
	end

	return BGFrame or Texture
end

function E:CreateTextureObject(Frame, SubObjectName, DrawLayer)
	Frame[SubObjectName] = Frame:CreateTexture(nil, DrawLayer or "OVERLAY")
	Frame[SubObjectName]:SetAllPoints(Frame)
	
	return Frame[SubObjectName]
end

local function SetHideInPetBattles(self, state)
	if state ~= false then
		if not self.BackupParent then
			self.BackupParent = self:GetParent()
		end
		E:HandleFrameInPetBattles(self)
	else
		if self.BackupParent then
			self:SetParent(self.BackupParent)
		else
			self:SetParent(E.Parent)
		end
	end
end

local PetbattleVisiblityCondition = '[petbattle] 0; 1'
function E:HandleFrameInPetBattles(Frame, UseStateHandler)
	if not UseStateHandler then
		Frame:SetParent(self.PetBattleParent)
		Frame.IsPetBattleHandled = true
	else
		self:SetVisibilityHandler(Frame, PetbattleVisiblityCondition)
		RegisterStateDriver(Frame, 'visible', PetbattleVisiblityCondition)
	end
end

-- Creates a new child frame of the specified parent and adds a texture slot to it
local DefaultCTFPoint = {"CENTER", E.Parent, "CENTER", 0, 0}
function E:CreateTextureFrame(Point, Parent, SizeX, SizeY, DrawLayer)
	local TF = CreateFrame("Frame", nil)
	TF:SetPoint(unpack(Point or DefaultCTFPoint))
	TF:SetParent(Parent or E.Parent)
	TF:SetSize(SizeX, SizeY)

	E:CreateTextureObject(TF, "T", DrawLayer)

	return TF
end

--[[
	-- SortFrames
	Sorts frames by all given params and returns the new resulting parent width and height
	Child frames with the "IgnoreSort" property are excluded from the sorting process
	
	@PARAM1 [table]:				A table containing all frames to sort
	@PARAM2 [frame]:				The Parent that should contain all the sorted frames
	@PARAM3 [int]: 		(Optional) 	Override the Child width
	@PARAM4 [int]: 		(Optional) 	Override the Child height
	@PARAM5 [int]: 		(Optional) 	Override the Child size
	@PARAM6 [int]: 					Number of frames in a single row
	@PARAM7 [bool]: 	(Optional) 	Inverse the X starting direction
	@PARAM8 [bool]: 	(Optional) 	Inverse the Y starting direction
	@PARAM9 [int]:		(Optional) 	X Gap between child frames
	@PARAM10 [int]: 	(Optional) 	Y Gap between child frames
	@PARAM11 [bool]: 	(Optional) 	Sort frames by their index
	@PARAM12 [bool]: 	(Optional) 	Creates columns first, when true
--]]
function E:SortFrames(Frames, Parent, Width, Height, SizeMult, PerRow, InverseStartX, InverseStartY, GapX, GapY, Ordered, PrioritizeColumns)
	local currentRow, currentColumn, xOffset, yOffset, prefixX, prefixY = 0, 0, 0, 0, 0, 0
	local endRow, endColumn, index = 1, 1, 1
	local pointH, pointV, point, iterator
	
	if Ordered then
		iterator = ipairs
	else
		iterator = pairs
	end
	
	SizeMult = SizeMult or 1
	if PerRow == 0 then PerRow = 1 end
	if PerRow < 0 then prefixX = -1; prefixY = -1; else prefixX = 1; prefixY = 1; end
	
	-- Perform Direction transform
	prefixX = prefixX * (InverseStartX and -1 or 1)
	prefixY = prefixY * (InverseStartY and -1 or 1)
	
	if prefixX < 0 then pointH = "RIGHT" else pointH = "LEFT" end
	if prefixY < 0 then pointV = "TOP" else pointV = "BOTTOM" end
	point = pointV .. pointH
	
	for _, child in iterator(Frames) do
	--------------------------------------------------------------------
		if not child.IgnoreSort then
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
				if PrioritizeColumns then
					currentColumn = currentColumn + 1
					endColumn = endColumn + 1
					
					currentRow = 0
				else
					currentRow = currentRow + 1
				
					currentColumn = 0
				end
			else
				if PrioritizeColumns then
					currentRow = currentRow + 1
				else
					currentColumn = currentColumn + 1
				end
			end
			
			E:MoveFrame(child, xOffset, yOffset)
			
			--------------------------------------------------------------------
			index = index + 1
		end
	end
	
	-- Post-iterate index correction, since we increment after each loop
	index = index - 1
	if PrioritizeColumns then
		endRow = abs(PerRow)
		endColumn = abs(endColumn) - 1
	else
		endColumn = abs(PerRow)
		endRow = abs(currentRow)
	end
	
	-- Start new row when needed to prevent false return values
	if index - (endColumn * endRow) > 0 then
		endRow = endRow + 1
	end
	-- Clamp EndWidth so we dont get overflow
	if endColumn > index then
		endColumn = index
	end
	
	if endColumn == 0 then
		endColumn = 1
	end
	
	local EndWidth = ((Width * SizeMult) + GapX) * (endColumn) - GapX
	local EndHeight = ((Height * SizeMult) + GapY) * (endRow) - GapY
	return EndWidth, EndHeight
end

function E:CreateArtFill(frame)
	local ArtFill = CreateFrame("Frame", nil, frame)
	
	ArtFill:SetFrameStrata("BACKGROUND")
	ArtFill:SetFrameLevel(1)
	
	ArtFill.Border = self:CreateBorder(ArtFill, nil, 1)
	ArtFill.Background = self:CreateBackground(ArtFill)
	
	frame.ArtFill = ArtFill
end

-- Description: This method allows for easy sub-bar creation, as it automatically sets the correct points for the sub-bar
--------------	to be on any position inside of the other bar
-- @PARAM 0: (self) The Sub-Bar parent
-- @PARAM 1: (StatusBar) The Sub-Bar
-- @PARAM 2: (boolean) Wether or not the Param 1 frame should be on the target statusbar texture
-- @PARAM 3: (boolean) If the Param 1 bar should be reversed
-- @PARAM 4: (string) The bar orientation for the Param 1 bar
local function SetSubBar(self, Target, OnTexture, Reverse, Orientation, FlipGrowth)
	
	Target:ClearAllPoints()
	
	-- If Bar acutally is a bar
	if Target.SetReverseFill then
		if FlipGrowth then
			Target:SetReverseFill(FlipGrowth and not Reverse)
		else
			Target:SetReverseFill(Reverse)
		end
		Target:SetOrientation(Orientation)
	end
	
	Target:SetFrameLevel(self:GetFrameLevel() + 5)
	
	local Point, RelativePoint, EndPoint
	
	if not OnTexture then
		if not Reverse then
			Point = "BOTTOMLEFT"
			RelativePoint = Orientation == "HORIZONTAL" and "BOTTOMRIGHT" or "TOPLEFT"
			EndPoint = "TOPRIGHT"
		else
			Point = "TOPRIGHT"
			RelativePoint = Orientation == "HORIZONTAL" and "TOPLEFT" or "BOTTOMRIGHT"
			EndPoint = "BOTTOMLEFT"
		end
	else
		if not FlipGrowth then
			Target:SetAllPoints(self:GetStatusBarTexture())
		else
			if not Reverse then
				Point = Orientation == "HORIZONTAL" and "BOTTOMRIGHT" 			or "TOPLEFT"
				RelativePoint = Orientation == "HORIZONTAL" and "BOTTOMLEFT" 	or "BOTTOMLEFT"
				EndPoint = Orientation == "HORIZONTAL" and "TOPLEFT" 			or "BOTTOMRIGHT"
			else
				Point = Orientation == "HORIZONTAL" and "TOPLEFT" 				or "BOTTOMLEFT"
				RelativePoint = Orientation == "HORIZONTAL" and "TOPRIGHT" 		or "TOPLEFT"
				EndPoint = Orientation == "HORIZONTAL" and "BOTTOMRIGHT" 		or "TOPRIGHT"
			end
		end
	end
	
	if not (OnTexture and not FlipGrowth) then
		Target:SetPoint(Point, self:GetStatusBarTexture(), RelativePoint)
		Target:SetPoint(EndPoint, self)
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
		self:RegisterAutoFont(Font, PathString)
	end
	
	return Font
end

---------------------------------------
--	Bar API
---------------------------------------
local function Bar_SetOverlayColor(self, r, g, b, a, RGBA) if not RGBA then self.Overlay:SetStatusBarColor(r, g, b, a) else self.Overlay:SetStatusBarColor(RGBA[1], RGBA[2], RGBA[3], RGBA[4] or a or 1) end end
local function Bar_Border_SetSize(self, size) if size < 0 then size = 1 end; self:SetBackdrop({edgeFile = DefaultWhiteTexture, edgeSize = size}) self:SetBorderColor(self:GetBackdropBorderColor()) end
local function Bar_Border_SetColor(self, r, g, b, a) self:SetBackdropBorderColor(r, g, b, a) end
local function Bar_SetBorderSize(self, size) if size < 0 then size = 1 end; self.Border:SetBorderSize(size); local Color = self.Border.LastColor or DefaultColor; self.Border:SetBorderColor(unpack(Color)) end
local function Bar_SetBorderColor(self, r, g, b, a) self.Border:SetBorderColor(r, g, b, a); self.Border.LastColor = {r, g, b, a} end
local function Bar_SetBackgroundColor(self, r, g, b, a) self.Background.Tex:SetColorTexture(r or 0.1, g or 0.1, b or 0.1, a) end
local function Bar_GetValue(self) return self.Overlay:GetValue() end
local function Bar_SetValue(self, value) self.Overlay:SetValue(value) end
local function Bar_Animated_SetValue(self, value, min, max, level) self.Overlay:SetAnimatedValues(value, min, max, level) end
local function Bar_GetMinMaxValues(self) return self.Overlay:GetMinMaxValues() end
local function Bar_SetMinMaxValues(self, min, max) self.Overlay:SetMinMaxValues(min or 0, max) end

function E:CreateAnimatedBar(Name, Strata, Width, Height, Point, Parent, EnableMouse, EnableMousewheel, EnableKeyboard, Template)
	return self:CreateBar(Name, Strata, Width, Height, Point, Parent, EnableMouse, EnableMousewheel, EnableKeyboard, 'AnimatedStatusBarTemplate')
	--return self:CreateBar(Name, Strata, Width, Height, Point, Parent, EnableMouse, EnableMousewheel, EnableKeyboard, 'StatusTrackingBarManagerTemplate')
end

function E:CreateBar(Name, Strata, Width, Height, Point, Parent, EnableMouse, EnableMousewheel, EnableKeyboard, Template)
	local Bar = E:NewFrame('Frame', Name, Strata, Width, Height, Point, Parent, EnableMouse, EnableMousewheel, EnableKeyboard)
	
	local BackgroundName, OverlayName, BorderName
	if Name then
		BackgroundName 	= Name .. 'Background'
		OverlayName 	= Name .. 'Overlay'
		BorderName 		= Name .. 'Border'
	end
	
	-- BACKGROUND
		local Background = E:NewFrame('Frame', BackgroundName, Strata, nil, nil, nil, Bar)
			Background:SetAllPoints(Bar)
			Background.Tex = Background:CreateTexture(nil)
			Background.Tex:SetAllPoints(Background)
			
			Bar.SetBackgroundColor = Bar_SetBackgroundColor
			
	-- Add Background
		Bar.Background = Background
		
	-- OVERLAY
		local Overlay = E:NewFrame('Statusbar', OverlayName, Strata, nil, nil, nil, Background, nil, nil, nil, Template)
			E:RegisterStatusBar(Overlay)

			E.Libs.LibSmooth:SmoothBar(Overlay)
			Overlay:SetAllPoints(Background)
			
			-- Convenience functions
			Bar.GetValue = Bar_GetValue
			if Template ~= 'AnimatedStatusBarTemplate' then
				Bar.SetValue = Bar_SetValue
			else
				Bar.SetValue = Bar_Animated_SetValue
			end
			Bar.GetMinMaxValues = Bar_GetMinMaxValues
			Bar.SetMinMaxValues = Bar_SetMinMaxValues
			Bar.SetOverlayColor = Bar_SetOverlayColor
			
	-- Add Overlay
		Bar.Overlay = Overlay
	
	-- BORDER
		local Border = E:NewFrame('Frame', BorderName, Strata, nil, nil, nil, Overlay, nil, nil, nil, BackdropTemplateMixin and "BackdropTemplate")
			Border:SetAllPoints(Overlay)
			Border.SetBorderColor = Bar_Border_SetColor
			Border.SetBorderSize = Bar_Border_SetSize
			
			-- Convenience functions
			Bar.SetBorderColor = Bar_SetBorderColor
			Bar.SetBorderSize = Bar_SetBorderSize
	
	-- Add Border
		Bar.Border = Border	
		
	-- Some init stuff
	Bar:SetBackgroundColor(0.1, 0.1, 0.1, 0.85)
	Bar:SetBorderColor(0.15, 0.15, 0.15, 1)
	Bar:SetBorderSize(1)
	
	return Bar
end

-- By modifying the metatable of a frame, we basically can make every other frame of this type inherit those methods below

local function AddAPI(object)
	local metatable = getmetatable(object).__index
	if not object.CreateBackground then metatable.CreateBackground = E.CreateBackground end
	if not object.CreateBorder then metatable.CreateBorder = E.CreateBorder end
	if not object.SetHideInPetBattles then metatable.SetHideInPetBattles = SetHideInPetBattles end
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



