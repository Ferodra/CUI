local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, Module = E:LoadModules("Config", "Bar_Totem")
Module.Autoload = true

local _G			= _G
local pairs			= pairs
local CreateFrame	= CreateFrame
local GetTotemInfo 	= GetTotemInfo
local MAX_TOTEMS	= MAX_TOTEMS

Module.E			= CreateFrame("Frame", "CUI_TotemBarFrame") -- Module Event
local ButtonSize	= 40

local function UpdateButtonBorder()
	local Color = E:GetAuraColor(nil, "player", nil, nil, nil, Module.db.borderColor)
	for _, Button in pairs(Module.Bar.Buttons) do
		E:SkinButtonIcon(Button.Overlay, Color)
	end
end

function Module:LoadConfig()
	if true then return end
	self.db = CO.db.profile.actionbar.totembar
	
	if not self.db.enable then self.Bar:Hide() else
		
		local totalWidth, totalHeight = E:SortFrames(self.Bar.Buttons, self.Bar, ButtonSize, ButtonSize, self.db.buttonSizeMultiplier, self.db.buttonsPerRow, false, false, self.db.buttonGap, self.db.buttonGap, true)
		UpdateButtonBorder()
		
		self.Bar:SetSize(totalWidth, totalHeight)
		E:UpdateMoverDimensions(self.Bar)
		
		self.Bar:Show()
	end
end

local Slot, Priorities, TotemExists, CDStart, CDDuration, Icon
function Module:__Update()
	for _, v in pairs(self.Bar.Buttons) do
		print("Update cd:", v.Icon.Cooldown)
		
		
		Priorities = STANDARD_TOTEM_PRIORITIES;
		if (class == "SHAMAN") then
			priorities = SHAMAN_TOTEM_PRIORITIES;
		end	
		
		Slot = Priorities[v.slot]
		print(Slot)
		if not Slot or not v.Icon.Cooldown then return end
		TotemExists, _, CDStart, CDDuration, Icon = GetTotemInfo(Slot)
		
		print("Totem exists?", TotemExists, Icon)
		if TotemExists then
			-- How to get rid of that nameless border?

			for _, child in ipairs({ v:GetChildren() }) do
				child:Hide() -- First: Hide all childs
			end
			
			 -- Second: Show Icon and Cooldown again!
			v.Icon:Show()
			v.Icon.Cooldown:Show()
			
			v.FontHolder.CDDuration = CDDuration
			v.FontHolder.CDStart = CDStart
			
			if ((CDStart + CDDuration) - GetTime()) > 0 then
				v.FontHolder:SetScript("OnUpdate", Module.SetCooldown)
				v.FontHolder.Duration:Show()
			else
				v.FontHolder:SetScript("OnUpdate", nil)
				v.FontHolder.Duration:Hide()
			end
		end
	end
end

function Module:SetCooldown()
	self.Remaining = (self.CDStart + self.CDDuration) - GetTime()
	
	self.Duration:SetText(self.Remaining > 0 and E:FormatTime(self.Remaining) or "")
end

function Module:Layout()
	local Bar = Module.BlizzBar
	Bar:SetParent(Module.Bar)
	Bar:ClearAllPoints()
	Bar:SetPoint("CENTER", Module.Bar, "CENTER")
end

function Module:__Construct()
	self.Bar = CreateFrame("Frame", "CUI_TotemBar", E.Parent)
	self.Bar:SetSize(ButtonSize * MAX_TOTEMS, ButtonSize) -- Make this controllable via config somehow. Maybe smart-sizing
	
	self.Bar.Buttons = {}
	
	self.HiddenParent = CreateFrame("Frame")
	self.HiddenParent:Hide()
	
	local Bar = _G["TotemFrame"]
	self.BlizzBar = Bar
	hooksecurefunc(Bar, 'Layout', Module.Layout)
	
	self:Layout()
	
	
	
	
	
	-- local haveTotem, name, startTime, duration, icon;
	-- local slot, button;
	-- local CurrentButton, CurrentIcon, CurrentIconTexture, CurrentIconCooldown, CurrentIconDuration
	-- Bar.totemPool:ReleaseAll(); 
	-- for i=1, MAX_TOTEMS do
		-- haveTotem, name, startTime, duration, icon = GetTotemInfo(i);
		-- button = Bar.totemPool:Acquire();
		
		-- CurrentIcon 		= button.Icon;
		-- CurrentIconTexture 	= button.Icon.Texture;
		-- CurrentIconDuration = button.Duration;
		-- CurrentIconCooldown = button.Icon.Cooldown;
		-- print(CurrentIconCooldown)
		-- print("----")
		
		-- CurrentIconDuration:SetParent(self.HiddenParent)
		-- CurrentIconDuration:Hide()
		
		-- button:SetSize(ButtonSize, ButtonSize)
		-- button:SetParent(self.Bar)
		
		-- button:ClearAllPoints()
		-- button:SetPoint("CENTER", self.Bar, "CENTER")
		
		
		-- button.Overlay = CreateFrame("Frame", nil, CurrentIcon)
		-- button.Overlay:SetAllPoints(CurrentIcon)
		-- button.Overlay:SetFrameLevel(button:GetFrameLevel()+99)
		-- button.Overlay.Tex = CurrentIconTexture
		
		-- button.FontHolder = CreateFrame("Frame", nil, button.Overlay)
		-- button.FontHolder:SetAllPoints(button.Overlay)
		
		-- button.FontHolder.Duration = button.FontHolder:CreateFontString(nil)
		-- E:InitializeFontFrame(button.FontHolder.Duration, "OVERLAY", "FRIZQT__.TTF", 12, {1,1,1}, 0.9, {0,0}, "", 0, 0, button.FontHolder, "CENTER", {1,1})
		-- button.FontHolder.Duration:SetParent(button.FontHolder)
		
		-- E:RegisterAutoFont(button.FontHolder.Duration, "db.profile.actionbar.totembar.duration")
		
		-- self.Bar.Buttons[i] = button
	-- end
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	--[[for i = 1, MAX_TOTEMS do
		CurrentButton = _G["TotemFrameTotem" .. i]
		
		if CurrentButton then
			CurrentIcon = _G["TotemFrameTotem" .. i .. "Icon"]
			CurrentIconDuration = _G["TotemFrameTotem" .. i .. "Duration"]
			CurrentIconTexture = _G["TotemFrameTotem" .. i .. "IconTexture"]
			CurrentIconCooldown = _G["TotemFrameTotem" .. i .. "IconCooldown"]
			
			CurrentButton.Icon = CurrentIcon
			CurrentButton.Icon.Texture = CurrentIconTexture
			
			CurrentButton.Cooldown = CurrentIconCooldown
			
			-- Parent the overlay frame to the icon, as the button itself somehow doesn't work
			CurrentButton.Overlay = CreateFrame("Frame", nil, CurrentIcon)
			CurrentButton.Overlay:SetAllPoints(CurrentIcon)
			CurrentButton.Overlay:SetFrameLevel(CurrentButton:GetFrameLevel()+99)
			CurrentButton.Overlay.Tex = CurrentIconTexture
			
			CurrentButton.FontHolder = CreateFrame("Frame", nil, CurrentButton.Overlay)
			CurrentButton.FontHolder:SetAllPoints(CurrentButton.Overlay)
			
			-- Getting rid of the default font object, since it's causing trouble with our system
			CurrentIconDuration:SetParent(self.HiddenParent)
			CurrentIconDuration:Hide()
			
			CurrentButton.FontHolder.Duration = CurrentButton.FontHolder:CreateFontString(nil)
			E:InitializeFontFrame(CurrentButton.FontHolder.Duration, "OVERLAY", "FRIZQT__.TTF", 12, {1,1,1}, 0.9, {0,0}, "", 0, 0, CurrentButton.FontHolder, "CENTER", {1,1})
			CurrentButton.FontHolder.Duration:SetParent(CurrentButton.FontHolder)
			
			E:RegisterAutoFont(CurrentButton.FontHolder.Duration, "db.profile.actionbar.totembar.duration")
			
			CurrentButton:SetSize(ButtonSize, ButtonSize)
			CurrentButton:SetParent(self.Bar)
			
			CurrentIcon:ClearAllPoints()
			CurrentIcon:SetAllPoints(CurrentButton)
			CurrentButton.Tex = CurrentIconTexture
			
			self.Bar.Buttons[i] = CurrentButton -- Cache button for easier access
		end
	end]]--
	
	E:CreateMover(self.Bar, "Totem-Bar", nil, nil, nil, "This Frame holds icons like Efflorescence, Consecration, Totems and some more.", "misc")
	
	--self.E:SetScript("OnEvent", function() self:__Update() end)
	self.E:RegisterEvent("PLAYER_TOTEM_UPDATE");
	self.E:RegisterEvent("PLAYER_ENTERING_WORLD");
	self.E:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
	self.E:RegisterEvent("PLAYER_TALENT_UPDATE");	
	self.E:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED"); 
	
	--self:__Update() -- Initial Update
end

function Module:Init()
	self.db = CO.db.profile.totemBar
	
	self:__Construct()
	
	self:LoadConfig()
end

E:AddModule("Bar_Totem", Module)