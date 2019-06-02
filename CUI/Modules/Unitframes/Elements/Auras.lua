local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO,L,UF,AUR = E:LoadModules("Config", "Locale", "Unitframes", "Auras")

local _
AUR.E = CreateFrame("Frame")

------------------------------------
local format		= string.format
local GetTime		= GetTime
------------------------------------


-- AurasNamespace = AUR

AUR.AURA_SIZE 				= 32 -- X and Y size
AUR.AURA_MARGIN 			= 5 -- Margin between auras in px
AUR.BUFF_PER_ROW 			= 8
AUR.BUFF_NUM_PLAYER 		= 32
AUR.DEBUFF_NUM_PLAYER 		= 16
AUR.AURA_TYPES 				= {"Buff", "Debuff"}
local HarmfulColor			= {0.85, 0, 0}
local Masque = E.Libs.Masque
local MasqueGroup_Buffs = Masque and Masque:Group("CUI", format("%s %s", L["player"],  L["Buffs"]))
local MasqueGroup_Debuffs = Masque and Masque:Group("CUI", format("%s %s", L["player"],  L["Debuffs"]))

function AUR:LoadProfile()
	
	self.db = CO.db.profile.unitframe
	
	local Profile
	for k, header in pairs(self.Headers) do
		if header:GetName() == "CUIPlayerBuffs" then Profile = self.db.buffs else Profile = self.db.debuffs end
		
		header.SortMethod = Profile.sortMethod
		header.SortDirection = Profile.sortDirection
		header.MaxWraps = Profile.maxWraps
		header.MaxPerRow = Profile.maxPerRow
		header.GrowthDirectionX = Profile.growthDirectionX
		header.GrowthDirectionY = Profile.growthDirectionY
		header.Size = Profile.size
		header.GapX = Profile.gapX
		header.GapY = Profile.gapY
		
		header.Point = ""
		
		header.WrapY = header.Size + header.GapY
		if header.GrowthDirectionY == "DOWN" then
			header.WrapY = header.WrapY * (-1) -- Reverse
			header.Point = "TOP"
		else
			header.Point = "BOTTOM"
		end
		
		header.xOffset = header.Size + header.GapX
		if header.GrowthDirectionX == "LEFT" then
			header.xOffset = header.xOffset * (-1) -- Reverse
			header.Point = header.Point .. "RIGHT"
		else
			header.Point = header.Point .. "LEFT"
		end
		
		header.useClassColor = Profile.borderUseClassColor or false
		
		header.Width = ((header.Size + header.GapX) * header.MaxPerRow)
		header.Height = ((header.Size + header.GapY) * header.MaxWraps)
		
		header:SetAttribute("headerWidth", header.Width)
		header:SetAttribute("headerHeight", header.Height)
		header:SetSize(header.Width, header.Height)
		E:UpdateMoverDimensions(header)
		
		self:UpdateHeader(header)
	end
end

function AUR:ColorizeAll()
	for k, header in pairs(self.Headers) do
		for k, button in pairs({ header:GetChildren() }) do
			if button.filter == "HARMFUL" then
				E:ColorizeAuraButton(button, button.AuraDType, button.unit, button.filter, button.AuraName, button.AuraSpellID, nil, button.debuffColor)
			else
				E:ColorizeAuraButton(button, button.AuraDType, button.unit, button.filter, button.AuraName, button.AuraSpellID, header.useClassColor)
			end
		end
	end
end

local function AuraAttributeChanged(button, attribute, index)
	if attribute == "target-slot" then E:debugprint(attribute) end
	if attribute == "index" then
		
		-- Refresh those values all the time, since it seems to cause problems when we don't
		if not button.header then
			button.header = button:GetParent()
		end
		
		button.index = index
		button.unit = button.header:GetAttribute("unit")
		button.filter = button.header:GetAttribute("filter")
		button.AuraName, button.AuraTexture, button.AuraCount, button.AuraDType, button.AuraDuration, button.AuraExpirationTime, _, _, _, button.AuraSpellID = UnitAura(button.unit, index, button.filter)
		if button.AuraName then
			if button.filter == "HARMFUL" then
				if button.AuraDType then
					button.debuffColor = DebuffTypeColor[button.AuraDType]
				else
					button.debuffColor = DebuffTypeColor["none"]
				end
				
				E:ColorizeAuraButton(button, button.AuraDType, button.unit, button.filter, button.AuraName, button.AuraSpellID, nil, button.debuffColor)
			else
				E:ColorizeAuraButton(button, button.AuraDType, button.unit, button.filter, button.AuraName, button.AuraSpellID, button.header.useClassColor)
				--Module:ColorizeAura(Slot, DType, Unit, UnitAuraClass, AuraName, SpellID)
				--E:SkinButtonIcon(button.texture, E:ParseDBColor(button.header.useClassColor))
			end
			
			if button.AuraCount and button.AuraCount > 1 then
				button.count:SetText(button.AuraCount)
			else
				button.count:SetText(E.STR.EMPTY)
			end
			
			button.Tex:SetTexture(button.AuraTexture)
			
			if button.AuraDuration <= 0 then
				button.time:SetText(E.STR.EMPTY)
				
				button:SetScript("OnUpdate", nil)
				button.Cooldown:Hide()
			else
				button:SetScript("OnUpdate", AUR.Button_OnUpdate)
				button.Cooldown:Show()
				
				button.Cooldown:SetCooldown(button.AuraExpirationTime - button.AuraDuration, button.AuraDuration)
			end
		end
	end
end

local function AuraButton_OnEnter(self)
	self.IsHovered = true
end
local function AuraButton_OnLeave(self)
	self.IsHovered = nil
	GameTooltip:Hide()
end

function AUR:SetupCooldown(Button)
	Button.Cooldown = CreateFrame("Cooldown", nil, Button, "CooldownFrameTemplate")
	Button.Cooldown:SetParent(Button)
	Button.Cooldown:SetAllPoints(Button)
	Button.Cooldown:SetReverse(true)
	Button.Cooldown:Show()
end

local CreateIconFont = "FRIZQT__.TTF"
function AUR:CreateIcon(button)

	-- This method gets called when a new button was created automatically by the "SecureAuraHeaderTemplate" attribute "template".
	-- The template is simply an XML construct with several initial data for the frame.
	-- Right here, we can do all sort of "post-processing" for that frame(s).
	-- @TODO
	-- 		Make the method more dynamic and allow aura bars to be created through it.
	--		Maybe a simple bool?
	
	button.Tex = button:CreateTexture(nil, "BORDER")
	button.Tex:SetTexCoord(0,1,0,1)
	--E:SkinButtonIcon(button.texture, E:GetUnitClassColor("player"))	
	
	button.Tex:SetAllPoints(button)
	button.border:Hide()
	
	AUR:SetupCooldown(button)
	
	button.FontHolder = CreateFrame("Frame", nil, button)
	button.FontHolder:SetAllPoints(button.Cooldown)
	
	button.Cooldown:SetHideCountdownNumbers(true)

	button.count = button.FontHolder:CreateFontString(nil, "ARTWORK")
	E:InitializeFontFrame(button.count, "ARTWORK", CreateIconFont, 14, {1,1,1}, 1, {0,0}, "", 0, 0, button.FontHolder, "CENTER", {1,1})
	button.count:ClearAllPoints()
	button.count:SetParent(button.FontHolder)

	button.time = button.FontHolder:CreateFontString(nil, "ARTWORK")
	E:InitializeFontFrame(button.time, "ARTWORK", CreateIconFont, 11, {1,0.96,0.41}, 1, {0,0}, "", 0, 0, button.FontHolder, "CENTER", {1,1})
	button.time:SetParent(button.FontHolder)
	
	if button:GetParent():GetAttribute("filter") == "HARMFUL" then
		E:RegisterPathFont(button.count, "CO.db.profile.unitframe.debuffs.count")
		E:RegisterPathFont(button.time, "CO.db.profile.unitframe.debuffs.time")
		
		E:UpdatePathFont("CO.db.profile.unitframe.debuffs.count")
		E:UpdatePathFont("CO.db.profile.unitframe.debuffs.time")
	else
		E:RegisterPathFont(button.count, "CO.db.profile.unitframe.buffs.count")
		E:RegisterPathFont(button.time, "CO.db.profile.unitframe.buffs.time")
		
		E:UpdatePathFont("CO.db.profile.unitframe.buffs.count")
		E:UpdatePathFont("CO.db.profile.unitframe.buffs.time")
	end
		
	button.rangeTimer = 0
	button:HookScript("OnEnter", AuraButton_OnEnter)
	button:HookScript("OnLeave", AuraButton_OnLeave)

	-- This Script gets called every time a aura changed/was added or removed.
	-- We can use this to update the whole thing and its children.
	button:SetScript("OnAttributeChanged", AuraAttributeChanged)
	
	if not MasqueGroup_Buffs or not MasqueGroup_Debuffs then return end
	
	button.Highlight = E:CreateHighlight(button)
	button.Highlight:SetColorTexture(1,1,0, 0.15)
	
	local ButtonData = {
		FloatingBG = nil,
		Icon = button.Tex,
		Cooldown = button.Cooldown,
		Flash = nil,
		Pushed = nil,
		Normal = nil,
		Disabled = nil,
		Checked = nil,
		Border = nil,
		AutoCastable = nil,
		Highlight = button.Highlight,
		HotKey = nil,
		Count = false,
		Name = nil,
		Duration = false,
		AutoCast = nil,
	}
	
	local Target
	if CO.db.profile.unitframe.buffs.useMasque and button:GetParent():GetAttribute("filter") == "HELPFUL" then
		Target = MasqueGroup_Buffs
	elseif CO.db.profile.unitframe.debuffs.useMasque and button:GetParent():GetAttribute("filter") == "HARMFUL" then
		Target = MasqueGroup_Debuffs
	end
	if Target then
		Target:AddButton(button, ButtonData)
		Target:ReSkin()
		
		if button.__MSQ_BaseFrame then
			button.__MSQ_BaseFrame:SetFrameLevel(2) --Lower the framelevel to fix issue with buttons created during combat
		end
	end
end

function AUR:Button_OnUpdate(elapsed)
	self.rangeTimer = self.rangeTimer - elapsed;

	if ( self.rangeTimer <= 0 ) then
		--------------------------------------------------------------
		-- OnUpdate Code BEGIN
		
		--if self.AuraDuration ~= 0 and self.AuraExpirationTime ~= nil then
			self.timeLeftBase = E:makePositive(E:Round(GetTime() - self.AuraExpirationTime, 2))
			
			if self.timeLeftBase > 10 then self.timeLeft = E:FormatTime(self.timeLeftBase, 0); else self.timeLeft = E:FormatTime(self.timeLeftBase, 1); end
			self.time:SetText(self.timeLeft)
		--end
		
		if self.IsHovered then
			if not GameTooltip:IsOwned(self) then
				GameTooltip:SetOwner(self)
			end
			GameTooltip:SetUnitAura(self.unit, self.index, self.filter)
			
			GameTooltip:Show()
		end
		

		-- OnUpdate Code END
		--------------------------------------------------------------
		self.rangeTimer = 0.07;
	end
end

function AUR:UpdateHeader(header)
	-- By setting the template, everything starts.
	-- The buttons are being created by the secure aura header
	-- To be exact, it reads the set filter and calculates the number of total auras to display.
	-- Based on that, AUR:CreateIcon() gets called by the OnLoad handler of the template.
	-- This way, we can modify the auras however we want to.
	-- We simply need different headers for multiple aura bars.
	-- That said, a frame with the "SecureAuraHeaderTemplate" simply needs to be created. Followed by the SetAttribute("template") or SetAttribute("weaponTemplate")
	-- Maybe XML proves to be not that bad.	
	
	header:SetAttribute("consolidateTo", 0)
	header:SetAttribute('weaponTemplate', ("CUIAuraTemplate%d"):format(header.Size))
	
	header:SetAttribute("separateOwn", 0)
	header:SetAttribute("sortMethod", header.SortMethod)
	header:SetAttribute("sortDirection", header.SortDirection)
	
	header:SetAttribute("maxWraps", header.MaxWraps)
	header:SetAttribute("wrapAfter", header.MaxPerRow)

	header:SetAttribute("point", header.Point)
	
		header:SetAttribute("minWidth", header:GetAttribute("headerWidth"))
		header:SetAttribute("minHeight", header:GetAttribute("headerHeight"))
		header:SetAttribute("xOffset", header.xOffset)
		header:SetAttribute("yOffset", 0)
		header:SetAttribute("wrapXOffset", 0)
		header:SetAttribute("wrapYOffset", header.WrapY)

	header:SetAttribute("template", ("CUIAuraTemplate%d"):format(header.Size))
	
	-- Post-fix of values we have to update manually
	local index = 1
	for k, child in pairs({ header:GetChildren() }) do
		-- Set new size
		child:SetSize(header.Size, header.Size)
		
		if (index > (header.MaxWraps * header.MaxPerRow)) and child:IsShown() then
			child:Hide()
		end
		
		index = index + 1
	end
	
	-- To actually apply the size
	if MasqueGroup_Buffs and CO.db.profile.unitframe.buffs.useMasque then
		MasqueGroup_Buffs:ReSkin()
	elseif MasqueGroup_Debuffs and CO.db.profile.unitframe.debuffs.useMasque then
		MasqueGroup_Debuffs:ReSkin()
	end
	
	self:ColorizeAll()
end

local function CreatePlayerAuraHeader(filter)
	local name = "CUIPlayerDebuffs"
	if filter == "HELPFUL" then name = "CUIPlayerBuffs" end
	
	local header = CreateFrame("Frame", name, E.Parent, "SecureAuraHeaderTemplate")
	header:SetClampedToScreen(true)
	header:SetAttribute("unit", "player")
	header:SetAttribute("filter", filter)
	
	RegisterStateDriver(header, "visibility", "[petbattle] hide; show")
	RegisterAttributeDriver(header, "unit", "[vehicleui] vehicle; player")

	if filter == "HELPFUL" then
		header:SetAttribute('consolidateDuration', nil)
		header:SetAttribute("includeWeapons", 1)
	end
	
	header:SetAttribute("headerWidth", 300)
	header:SetAttribute("headerHeight", 90)
	
	header:SetSize(300, 90)
	header:Show()

	return header
end

function AUR:InitializeAuras()
	self.BuffFrame = CreatePlayerAuraHeader("HELPFUL")
	E:CreateMover(self.BuffFrame, L["buffs"], "TOPRIGHT")

	self.DebuffFrame = CreatePlayerAuraHeader("HARMFUL")	
	E:CreateMover(self.DebuffFrame, L["debuffs"], "BOTTOMRIGHT")
	
	self.Headers = {self.BuffFrame, self.DebuffFrame}
end

function AUR:Init()	
	self.db = CO.db.profile.unitframe.auras
	
	self:InitializeAuras()
	self:LoadProfile()
end

E:AddModule("Auras", AUR)