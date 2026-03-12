--[[-----------------------------------------------------------------------------
CharacterGroup Container
Advanced container with an clickable header to store character information in
-------------------------------------------------------------------------------]]
local Type, Version = "CharacterGroup", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local pairs = pairs

-- WoW APIs
local CreateFrame, UIParent = CreateFrame, UIParent

local RaceBaseStr = "Interface/CHARACTERFRAME/TemporaryPortrait-%s-%s"
local function GetRaceTexture(race, sex)
	return RaceBaseStr:format(sex, race)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self)
		self:SetWidth(300)
		self:SetHeight(100)
		--self:SetHeight(100)
		--self:SetTitle("")
	end,

	-- ["OnRelease"] = nil,

	["SetTitle"] = function(self,title)
		self.titletext:SetText(title)
	end,
	
	["LayoutFinished"] = function(self, width, height)
		if self.noAutoHeight then return end
		
		if not self.hasContent then
			self:SetHeight((height or 0) + 30)
		else
			self:SetHeight((height or 0) + 45)
		end
	end,

	["OnWidthSet"] = function(self, width)
		local content = self.content
		local contentwidth = width - 20
		if contentwidth < 0 then
			contentwidth = 0
		end
		content:SetWidth(contentwidth)
		content.width = contentwidth
	end,

	["OnHeightSet"] = function(self, height)
		local content = self.content
		local contentheight = height - 20
		if contentheight < 0 then
			contentheight = 0
		end
		content:SetHeight(contentheight)
		content.height = contentheight
	end,
	
	["OnRelease"] = function(self)
		self.hasContent = nil
	end,
	
	["SetClassIcon"] = function(self, className)
		if className and className ~= "" then
			className = className or "PRIEST"
			self.class:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
			self.class:SetTexCoord(unpack(CLASS_ICON_TCOORDS[strupper(className)]))
		else
			SetPortraitToTexture(self.class, 134400)
		end
	end,
	
	["SetSpecIcon"] = function(self, icon)
		SetPortraitToTexture(self.spec, icon)
	end,
	
	["SetBGColor"] = function(self, r, g, b, a)
		self.bg:SetColorTexture(r/1.1, g/1.1, b/1.1, a or 1)
		self.bg2:SetColorTexture(r/1.1, g/1.1, b/1.1, a or 1)
	end,
	
	["SetOverallItemlevel"] = function(self, value)
		self.ilvl:SetText(value)
	end,
	
	["SetFaction"] = function(self, value)
		if value == "Alliance" then
			SetPortraitToTexture(self.faction, 2175463)
		elseif value == "Horde" then
			SetPortraitToTexture(self.faction, 2175464)
		else
			SetPortraitToTexture(self.faction, 134400)
		end
	end,
	
	["SetRace"] = function(self, value, sex)
		sex = (sex == 3) and "Female" or "Male"
		if value then
			SetPortraitToTexture(self.race, GetRaceTexture(value, sex) or 134400)
			self.race:Show()
		else
			self.race:Hide()
		end
	end,
	
	["SetHeaderClickHandler"] = function(self, func, data)
		if not self.header.userdata then
			self.header.userdata = {}
		else
			wipe(self.header.userdata)
		end
		
		for k,v in pairs(data) do
			self.header.userdata[k] = v
		end
		self.header:SetScript("OnClick", func)
	end,
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local function NewIcon(Parent)
	local Icon = Parent:CreateTexture("OVERLAY", nil)
	Icon:SetDrawLayer("OVERLAY", 5)
	Icon:SetSize(20, 20)
	-- Cut away those ugly borders
	Icon:SetTexCoord(0.06,0.94,0.06,0.94)
	
	return Icon
end

local function Header_OnEnter(self)
	self.Tex1:Show()
	self.Tex2:Show()
end

local function Header_OnLeave(self)
	self.Tex1:Hide()
	self.Tex2:Hide()
end

local function Constructor()
	
	local TextureAlpha = 0.75
	
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetFrameStrata("FULLSCREEN_DIALOG")
	
	local Class, Spec, Faction, Race, BG, BG2, Overlay, Header, HighlightTex, HighlightTex2
	
	BG = frame:CreateTexture("BACKGROUND", nil)
	--BG:SetGradientAlpha("HORIZONTAL", 1,1,1, 0, 1,1,1, TextureAlpha)
	BG:SetGradient("HORIZONTAL", CreateColor(1,1,1, 1), CreateColor(1,1,1, 0.3))
	BG:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, -30)
	BG:SetPoint("BOTTOMRIGHT", frame, "TOP", 0, -30)
	BG:SetHeight(30)
	
	BG2 = frame:CreateTexture("BACKGROUND", nil)
	BG2:SetGradient("HORIZONTAL", CreateColor(1,1,1, 0.3), CreateColor(1,1,1, 1))
	--BG2:SetGradientAlpha("HORIZONTAL", 1,1,1, TextureAlpha, 1,1,1, 0)
	BG2:SetPoint("BOTTOMLEFT", frame, "TOP", 0, -30)
	BG2:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, -30)
	BG2:SetHeight(30)
	
	Header = CreateFrame("Button", nil, frame)
	Header:SetPoint("TOPLEFT", BG, "TOPLEFT", 0, 0)
	Header:SetPoint("BOTTOMRIGHT", BG2, "BOTTOMRIGHT", 0, 0)
	Header:SetScript("OnEnter", Header_OnEnter)
	Header:SetScript("OnLeave", Header_OnLeave)
	Header.Owner = frame
	Header:SetHeight(30)
	
	HighlightTex = frame:CreateTexture("OVERLAY", nil)
	--HighlightTex:SetGradientAlpha("HORIZONTAL", 1,1,1, 0, 1,1,1, TextureAlpha)
	HighlightTex:SetColorTexture(1,1,1)
	HighlightTex:SetPoint("TOPLEFT", BG, "TOPLEFT", 0, 0)
	HighlightTex:SetPoint("BOTTOMRIGHT", BG, "BOTTOMRIGHT", 0, 0)
	HighlightTex:Hide()
	Header.Tex1 = HighlightTex
	
	HighlightTex2 = frame:CreateTexture("OVERLAY", nil)
	--HighlightTex2:SetGradientAlpha("HORIZONTAL", 1,1,1, TextureAlpha, 1,1,1, 0)
	HighlightTex2:SetColorTexture(1,1,1)
	HighlightTex2:SetPoint("TOPLEFT", BG2, "TOPLEFT", 0, 0)
	HighlightTex2:SetPoint("BOTTOMRIGHT", BG2, "BOTTOMRIGHT", 0, 0)
	HighlightTex2:Hide()
	Header.Tex2 = HighlightTex2
	
	Overlay = CreateFrame("Frame", nil, frame)
	Overlay:SetAllPoints(true)
	Overlay:SetFrameLevel(frame:GetFrameLevel()+15)
	
	Class = NewIcon(Overlay)
	Class:SetPoint("BOTTOMRIGHT", Overlay, "TOPRIGHT", -40, -25)
	
	Spec = NewIcon(frame)
	Spec:SetPoint("BOTTOMRIGHT", Overlay, "TOPRIGHT", -10, -25)
	
	Faction = NewIcon(frame)
	Faction:SetPoint("BOTTOMLEFT", Overlay, "TOPLEFT", 10, -25)
	
	Race = NewIcon(frame)
	Race:SetPoint("BOTTOMLEFT", Overlay, "TOPLEFT", 40, -25)
	
	local titletext = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	titletext:SetPoint("TOPLEFT", 14, -7)
	titletext:SetPoint("TOPRIGHT", -14, -7)
	titletext:SetJustifyH("CENTER")
	titletext:SetFont(select(1, titletext:GetFont()), 18, "OUTLINE")
	titletext:SetHeight(18)
	
	local ilvl = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	ilvl:SetPoint("TOPLEFT", 14, -7)
	ilvl:SetPoint("TOPRIGHT", -65, -7)
	ilvl:SetJustifyH("RIGHT")
	ilvl:SetFont(select(1, ilvl:GetFont()), 15, "OUTLINE")
	ilvl:SetHeight(18)

	local border = CreateFrame("Frame", nil, frame)
	border:SetPoint("TOPLEFT", 0, -25)
	border:SetPoint("BOTTOMRIGHT", -1, 0)

	--Container Support
	local content = CreateFrame("Frame", nil, border)
	content:SetPoint("TOPLEFT", 10, -10)
	content:SetPoint("BOTTOMRIGHT", -10, 0)

	local widget = {
		frame     	= frame,
		class   	= Class,
		spec   		= Spec,
		faction   	= Faction,
		race   		= Race,
		bg   		= BG,
		bg2   		= BG2,
		header   	= Header,
		content   	= content,
		ilvl 		= ilvl,
		titletext 	= titletext,
		type      	= Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
