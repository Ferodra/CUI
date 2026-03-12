--[[-----------------------------------------------------------------------------
ItemButton Widget
-------------------------------------------------------------------------------]]
local Type, Version = "ItemButton", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local select, pairs = select, pairs

-- WoW APIs
local PlaySound = PlaySound
local CreateFrame, UIParent = CreateFrame, UIParent

-- Global vars/functions that we don't upvalue since they might get hooked, or upgraded
-- List them here for Mikk's FindGlobals script

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function Control_OnEnter(frame)
	frame.obj:Fire("OnEnter")
end

local function Control_OnLeave(frame)
	frame.obj:Fire("OnLeave")
end

local function ItemButton_OnEnter(self)
	--print("Enter")
	--print(self.text)
	if self.text and type(self.text) ~= "function" then
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		if not self.textIsLink then
			GameTooltip:SetText(self.text)
		else
			GameTooltip:SetHyperlink(self.text)
		end
		GameTooltip:Show()
	elseif type(self.text) == "function" then
		self.text()
	end
end

local function ItemButton_OnLeave(self)
	if self.text then
		GameTooltip:Hide()
	end
end

local function ItemButton_OnClick(self, Button)
	if self.text and type(self.text) ~= "function" and self.textIsLink and Button == "LeftButton" and (IsShiftKeyDown() or IsControlKeyDown()) then
		--HandleModifiedItemClick(self.text)
		ChatEdit_InsertLink(self.text)
	end
	
	AceGUI:ClearFocus()
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self)
		-- height is calculated from the width and required space for the description
		local size = 32
		self.frame:SetSize(size + 3, size + 5)
		self.button:SetSize(size, size)
		
		self:SetTextSize(12)
	end,
	
	["OnRelease"] = function(self)
		self.frame:Hide()
	end,
	
	["EnableButton"] = function(self)
		self.button:EnableMouse(true)
	end,
	
	["DisableButton"] = function(self)
		self.button:EnableMouse(false)
	end,
	
	["SetLabel"] = function(self, label)
		self.text:SetText(label)
	end,

	["SetDescription"] = function(self, desc, isLink)
		self.button.text = desc
		self.button.textIsLink = isLink
	end,

	["SetBorder"] = function(self, size, r, g, b, a)
		local Color = {self.border:GetBackdropBorderColor()}
		
		self.border:SetBackdrop({
			edgeFile = [[Interface\Buttons\WHITE8X8]],
			edgeSize = size,
			tile = true
		})
		
		-- Try to either set or keep color
		--print(r or Color[1] or 0, g or Color[2] or 0, b or Color[3] or 0, a or Color[4] or 1)
		self.border:SetBackdropBorderColor(r or Color[1] or 0, g or Color[2] or 0, b or Color[3] or 0, a or Color[4] or 1)
	end,
	
	["SetTexture"] = function(self, texture)
		self.texture:SetTexture(texture)
	end,
	
	["SetText"] = function(self, value)
		self.text:SetText(value)
	end,
	
	["SetTextPoint"] = function(self, ...)
		self.text:ClearAllPoints()
		self.text:SetPoint(...)
	end,
	
	["SetTextColor"] = function(self, ...)
		self.text:SetTextColor(...)
	end,
	
	["SetTextSize"] = function(self, value)
		local Font = self.text:GetFont()
		self.text:SetFont(Font, value, "OUTLINE")
	end,
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:Hide()
	
	local button = CreateFrame("Button", nil, frame)
	button:SetPoint("LEFT", frame, "LEFT")
	
	button:EnableMouse(true)
	button:SetScript("OnEnter", ItemButton_OnEnter)
	button:SetScript("OnLeave", ItemButton_OnLeave)
	button:SetScript("OnClick", ItemButton_OnClick)

	local texture = button:CreateTexture("OVERLAY", nil)
	texture:SetAllPoints(button)
	texture:SetTexCoord(0.06,0.94,0.06,0.94)
	
	local border = CreateFrame("Frame", nil, button, BackdropTemplateMixin and "BackdropTemplate")
	border:SetFrameLevel(button:GetFrameLevel() + 2)
	border:SetAllPoints(true)
	
	if not border.SetBackdrop then
		_G.Mixin(border, _G.BackdropTemplateMixin)
		border:HookScript('OnSizeChanged', border.OnBackdropSizeChanged)
	end
	
	local text = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	text:SetJustifyH("CENTER")
	text:SetPoint("BOTTOM", button, "BOTTOM", 0, 1)
	

	local widget = {
		frame     	= frame,
		button		= button,
		texture		= texture,
		border		= border,
		text		= text,
		type      	= Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
