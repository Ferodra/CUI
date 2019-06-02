local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, TB = E:LoadModules("Config", "Bar_Totem")
TB.Autoload = true

local _G			= _G
local pairs			= pairs
local CreateFrame	= CreateFrame
local GetTotemInfo 	= GetTotemInfo
local MAX_TOTEMS	= MAX_TOTEMS

TB.E				= CreateFrame("Frame") -- TB Event
local ButtonSize	= 40

function TB:LoadProfile()
	self.db = CO.db.profile.actionbar.totembar
	
	if not self.db.enable then self.Bar:Hide() else
		
		local totalWidth, totalHeight = E:SortFrames(self.Bar.Buttons, self.Bar, ButtonSize, ButtonSize, self.db.buttonSizeMultiplier, self.db.buttonsPerRow, false, false, self.db.buttonGap, self.db.buttonGap, true)
		
		self.Bar:SetSize(totalWidth, totalHeight)
		E:UpdateMoverDimensions(self.Bar)
		
		self.Bar:Show()
	end
end

local TotemExists, CDStart, CDDuration, Icon
function TB:__Update()
	
	for _, v in pairs(self.Bar.Buttons) do
		TotemExists, _, CDStart, CDDuration, Icon = GetTotemInfo(v.slot)
		
		if TotemExists then
			-- How to get rid of that nameless border?

			for _, child in ipairs({ v:GetChildren() }) do
				child:Hide() -- First: Hide all childs
			end
			
			 -- Second: Show Icon and Cooldown again!
			v.Icon:Show()
			v.Cooldown:Show()
			
			v.FontHolder.CDDuration = CDDuration
			v.FontHolder.CDStart = CDStart
			
			if ((CDStart + CDDuration) - GetTime()) > 0 then
				v.FontHolder:SetScript("OnUpdate", TB.SetCooldown)
				v.FontHolder.Duration:Show()
			else
				v.FontHolder:SetScript("OnUpdate", nil)
				v.FontHolder.Duration:Hide()
			end
		end
	end
end

function TB:SetCooldown()	
	self.Remaining = (self.CDStart + self.CDDuration) - GetTime()
	self.Duration:SetText(E:FormatTime(self.Remaining) or "")
end

function TB:__Construct()
	self.Bar = CreateFrame("Frame", "CUI_TotemBar", E.Parent)
	self.Bar:SetSize(ButtonSize * MAX_TOTEMS, ButtonSize) -- Make this controllable via config somehow. Maybe smart-sizing
	
	self.Bar.Buttons = {}
	
	self.HiddenParent = CreateFrame("Frame")
	self.HiddenParent:Hide()
	
	
	local CurrentButton, CurrentIcon, CurrentIconTexture, CurrentIconCooldown, CurrentIconDuration
	for i = 1, MAX_TOTEMS do
		CurrentButton = _G["TotemFrameTotem" .. i]
		
		if CurrentButton then
			CurrentIcon = _G["TotemFrameTotem" .. i .. "Icon"]
			CurrentIconDuration = _G["TotemFrameTotem" .. i .. "Duration"]
			CurrentIconTexture = _G["TotemFrameTotem" .. i .. "IconTexture"]
			CurrentIconCooldown = _G["TotemFrameTotem" .. i .. "IconCooldown"]
			
			CurrentButton.Icon = CurrentIcon
			CurrentButton.Icon.Texture = CurrentIconTexture
			
			CurrentButton.Cooldown = CurrentIconCooldown
			
			CurrentButton.FontHolder = CreateFrame("Frame", nil, CurrentIconCooldown)
			CurrentButton.FontHolder:SetAllPoints(CurrentIconCooldown)
			
			
			-- Getting rid of the default font object, since it's causing trouble with our system
			CurrentIconDuration:SetParent(self.HiddenParent)
			CurrentIconDuration:Hide()
			
			CurrentButton.FontHolder.Duration = CurrentButton.FontHolder:CreateFontString(nil)
			E:InitializeFontFrame(CurrentButton.FontHolder.Duration, "OVERLAY", "FRIZQT__.TTF", 12, {1,1,1}, 0.9, {0,0}, "", 0, 0, CurrentButton.FontHolder, "CENTER", {1,1})
			CurrentButton.FontHolder.Duration:SetParent(CurrentButton.FontHolder)
			
			E:RegisterPathFont(CurrentButton.FontHolder.Duration, "db.profile.actionbar.totembar.duration")
			
			CurrentButton:SetSize(ButtonSize, ButtonSize)
			CurrentButton:SetParent(self.Bar)
			
			CurrentIcon:ClearAllPoints()
			CurrentIcon:SetAllPoints(CurrentButton)
			CurrentButton.Tex = CurrentIconTexture
			E:SkinButtonIcon(CurrentButton, E:GetUnitClassColor("player"))
			
			self.Bar.Buttons[i] = CurrentButton -- Cache button for easier access
		end
	end
	
	E:CreateMover(self.Bar, "Totem-Bar", nil, nil, nil, "This Frame holds icons like Efflorescence, Consecration, Totems and some more.")
	
	self.E:SetScript("OnEvent", function() self:__Update() end)
	self.E:RegisterEvent("PLAYER_ENTERING_WORLD")
	self.E:RegisterEvent("PLAYER_TOTEM_UPDATE")
	self:__Update() -- Initial Update
end

function TB:Init()
	-- self.db = CO.db.profile.totemBar
	
	self:__Construct()
	
	self:LoadProfile()
end

E:AddModule("Bar_Totem", TB)