local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF, AUR, B, FI, BA = E:LoadModules("Config", "Unitframes", "Auras", "Blizzard", "Filters", "Bar_Auras")

local _
AUR.E = CreateFrame("Frame", "CUI_PlayerAurasEventHandler")

------------------------------------
local format		= string.format
local ceil			= math.ceil
local GetTime		= GetTime
local UnitAura				= C_TooltipInfo.GetUnitAura
local GetAuraDataByIndex 	= C_UnitAuras and C_UnitAuras.GetAuraDataByIndex
local UnpackAuraData 		= AuraUtil and AuraUtil.UnpackAuraData
local GetAuraDuration 		= C_UnitAuras.GetAuraDuration
local GetAuraApplicationDisplayCount = C_UnitAuras.GetAuraApplicationDisplayCount
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

function AUR:LoadConfig()
	
	self.db = CO.db.profile.unitframe
	if not CO.db.char.unitframe.enable then return end
	
	local Config
	if not self.Headers then return end
	for k, header in pairs(self.Headers) do
		if header:GetName() == "CUIPlayerBuffs" then Config = self.db.buffs else Config = self.db.debuffs end
		
		header.SortMethod 		= Config.sortMethod
		header.SortDirection 	= Config.sortDirection
		header.MaxWraps 		= Config.maxWraps
		header.MaxPerRow 		= Config.maxPerRow
		header.GrowthDirectionX = Config.growthDirectionX
		header.GrowthDirectionY = Config.growthDirectionY
		header.Size 			= Config.size
		header.GapX 			= Config.gapX
		header.GapY 			= Config.gapY
		
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
		
		header.useClassColor = Config.borderUseClassColor or false
		
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


local QualityColors = {}
do
	for i=0,7 do
		QualityColors[i] = {GetItemQualityColor(i)}
		QualityColors[i][4] = 1 -- index 4 is a hex color from GetItemQualityColor, but we need an alpha value for our skin button
	end
end

local function SetTooltip(button)
	if button:GetAttribute('index') then
		GameTooltip:SetUnitAura(button.header:GetAttribute('unit'), button:GetID(), button.filter)
	elseif button:GetAttribute('target-slot') then
		GameTooltip:SetInventoryItem('player', button:GetID())
	end
end

local function RegisterDurationText(self, filter)
	E:RegisterAutoFont(self, format("CO.db.profile.unitframe.%s.time", (filter == 'HARMFUL') and 'buffs' or 'debuffs'))
	E:UpdateAutoFont(format("CO.db.profile.unitframe.%s.time", (filter == 'HARMFUL') and 'buffs' or 'debuffs'))
end

local TimeLeftFormatter = CreateFromMixins(SecondsFormatterMixin);
TimeLeftFormatter:Init(0, SecondsFormatter.Abbreviation.OneLetter, true, true);
function TimeLeftFormatter:GetMinInterval(seconds)
	if not seconds then
		return SecondsFormatter.Interval.Days;
	elseif seconds > SECONDS_PER_DAY then
		return SecondsFormatter.Interval.Days;
	elseif seconds > SECONDS_PER_HOUR then
		return SecondsFormatter.Interval.Hours;
	elseif seconds > SECONDS_PER_MIN then
		return SecondsFormatter.Interval.Minutes;
	end

	return SecondsFormatter.Interval.Seconds;
end
function TimeLeftFormatter:FormatZero(abbreviation, toLower)
	return ''
end

--[[ TimeLeftFormatter:Init(
	SECONDS_PER_HOUR, 
	SecondsFormatter.Abbreviation.None,
	SecondsFormatterConstants.DontRoundUpLastUnit, 
	SecondsFormatterConstants.DontConvertToLower) ]]

local function Button_OnUpdate(self, elapsed)
	self.elapsed = self.elapsed - elapsed;
	self.totalElapsed = (self.totalElapsed or 0) + elapsed

	if ( self.elapsed <= 0 ) then
		--------------------------------------------------------------
		-- OnUpdate Code BEGIN
		
		if self.RunOnUpdate then
			--if self.HasTempEnchant then
			--	self.EnchantTimePassed = (self.EnchantTimePassed or 0) + self.totalElapsed
				--print(self.EnchantTimePassed, self.AuraExpirationTime - self.EnchantTimePassed)
			--	print(E:FormatTime(self.AuraExpirationTime - self.EnchantTimePassed))
				--self.time:SetText(E:FormatTime(self.AuraExpirationTime - self.EnchantTimePassed))
			--end

			--[[ local Duration = self.time.DurationObject:GetRemainingDuration()
			local IsZero = self.time.DurationObject:IsZero()

			print(TimeLeftFormatter:Format(Duration), Duration)
			self.time:SetFormattedText(TimeLeftFormatter:Format(Duration)) ]]
		end
		
		if GameTooltip:IsOwned(self) then
			SetTooltip(self)
		end
		

		-- OnUpdate Code END
		--------------------------------------------------------------
		self.elapsed = 0.25;
		self.totalElapsed = 0
	end
end

function AUR:UpdateEnchant(self, index)
	local InfoOffset = (strmatch(self:GetName(), '2$') and 6) or 2
	local duration, remaining = 600, 0
	local expiration = select(InfoOffset, GetWeaponEnchantInfo())
	local charges = select(InfoOffset+1, GetWeaponEnchantInfo())
	
	self.HasTempEnchant = true
	if not self.header then
		self.header = self:GetParent()
	end
	
	if charges and charges > 1 then
		self.count:SetText(charges)
	else
		self.count:SetText('')
	end
	
	self.Tex:SetTexture(GetInventoryItemTexture('player', index))

	if expiration then
		
		local quality = GetInventoryItemQuality('player', index)
		local color
		if quality and quality > 1 then
			color = QualityColors[quality]
			
			E:ColorizeAuraButton(self, nil, nil, nil, nil, nil, nil, color)
		else
			E:ColorizeAuraButton(self, nil, nil, nil, nil, nil, self.header.useClassColor)
		end
		 
		local remaining = (expiration * 0.001) or 0
		local duration = (remaining <= 600 and 600) or (remaining <= 1800 and 1800) or (ceil(remaining / 3600)*3600)
		local expiration = remaining + GetTime()
		
		self.AuraExpirationTime, self.AuraDuration = remaining, duration
		
		if duration <= 0.05 then
			self.Cooldown:Hide()
			self.RunOnUpdate = false
		else
			self.Cooldown:Show()
			self.Cooldown:SetCooldown(expiration - duration, duration)
			self.RunOnUpdate = true
		end
	else
		self.Cooldown:Hide()
		--self.RunOnUpdate = false
	end
end

local function UpdateAura(self, index)
	-- Refresh those values all the time, since it seems to cause problems when we don't
	if not self.header then
		self.header = self:GetParent()
	end
	
	self.HasTempEnchant = nil
	
	self.index = index
	self.filter = self.header:GetAttribute("filter")
	
	local Data = GetAuraDataByIndex("player", index, self.filter)
	if not Data then return end

	self.AuraName, self.AuraTexture, self.AuraCount, self.AuraDType, self.AuraDuration, self.AuraExpirationTime, self.AuraSpellID = Data.name, Data.icon, Data.applications, Data.dispelName, Data.duration, Data.expirationTime, Data.spellId
	
	if self.AuraName then
		if self.filter == "HARMFUL" then
			if self.AuraDType then
				self.debuffColor = E.DebuffTypeColor[self.AuraDType]
			else
				self.debuffColor = E.DebuffTypeColor["none"]
			end
			
			E:ColorizeAuraButton(self, self.AuraDType, "player", self.filter, self.AuraName, self.AuraSpellID, nil, self.debuffColor)
		else
			E:ColorizeAuraButton(self, self.AuraDType, "player", self.filter, self.AuraName, self.AuraSpellID, self.header.useClassColor)
		end

		self.count:SetText(GetAuraApplicationDisplayCount("player", Data.auraInstanceID, 2, 99))		
		self.Tex:SetTexture(self.AuraTexture)
		
		local Duration = GetAuraDuration("player", Data.auraInstanceID)
		if Duration then
			--self.RunOnUpdate = true
			self.Cooldown:SetCooldownFromDurationObject(Duration, true)
		else			
			--self.RunOnUpdate = false
			self.Cooldown:Clear()
		end
	else
		--self.RunOnUpdate = false
		self.Cooldown:Hide()
	end
end

local function AuraAttributeChanged(self, attribute, index)
	if attribute == "index" then
		--if IsShiftKeyDown() then errno() end
		if not self.throttleUpdate then
		
			UpdateAura(self, index)
			self.throttleUpdate = true
		elseif self.header.spells[self] ~= index then
		
			self.header.spells[self] = index
		end
	elseif attribute == "target-slot" then
		AUR:UpdateEnchant(self, index)
		return
	end
end

local function AuraButton_OnEnter(self)
	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMLEFT', -5, -5)
	self.elapsed = -1
end
local function AuraButton_OnLeave(self)
	GameTooltip:Hide()
end
local function AuraButton_OnShow(self)
	if self.enchantIndex then
		self.header.enchants[self.enchantIndex] = self
		self.header.elapsedEnchants = 1 -- let the enchant update next frame
	end
end
local function AuraButton_OnHide(self)
	if self.enchantIndex then
		self.header.enchants[self.enchantIndex] = nil
	else
		self.throttleUpdate = false
	end
end
local function HandleClick(self, button)
	FI:AddSpellIDToUnitAurabarsFilter(self.AuraSpellID, "player", self.AuraDuration)
end

function AUR:SetupCooldown(Button)
	Button.Cooldown = CreateFrame("Cooldown", nil, Button, "CooldownFrameTemplate")
	Button.Cooldown:SetParent(Button)
	Button.Cooldown:SetAllPoints(Button)
	Button.Cooldown:SetReverse(true)
	Button.Cooldown:Show()

	Button.time = Button.Cooldown:GetRegions()
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
	
	button.Cooldown:SetHideCountdownNumbers(false)

	button.count = button.FontHolder:CreateFontString(nil, "ARTWORK")
	E:InitializeFontFrame(button.count, "ARTWORK", CreateIconFont, 14, {1,1,1}, 1, {0,0}, "", 0, 0, button.FontHolder, "CENTER", {1,1})
	button.count:ClearAllPoints()
	button.count:SetParent(button.FontHolder)

	--button.time = button.FontHolder:CreateFontString(nil, "ARTWORK")
	--E:InitializeFontFrame(button.time, "ARTWORK", CreateIconFont, 11, {1,0.96,0.41}, 1, {0,0}, "", 0, 0, button.FontHolder, "CENTER", {1,1})
	--button.time:SetParent(button.FontHolder)
	
	local Filter = button:GetParent():GetAttribute("filter")
	
	E:RegisterAutoFont(button.count, format("CO.db.profile.unitframe.%s.count", (Filter == 'HARMFUL') and 'debuffs' or 'buffs'))
	E:RegisterAutoFont(button.time, format("CO.db.profile.unitframe.%s.time", (Filter == 'HARMFUL') and 'debuffs' or 'buffs'))
	
	E:UpdateAutoFont(format("CO.db.profile.unitframe.%s.count", (Filter == 'HARMFUL') and 'debuffs' or 'buffs'))
	E:UpdateAutoFont(format("CO.db.profile.unitframe.%s.time", (Filter == 'HARMFUL') and 'debuffs' or 'buffs'))
		
	button.elapsed = 0
	button.header = button:GetParent()
	button.throttleUpdate = false
	button.enchantIndex = tonumber(strmatch(button:GetName(), 'TempEnchant(%d)$'))
	if button.enchantIndex then
		button.header['enchant'..button.enchantIndex] = button
		button.header.enchantButtons[button.enchantIndex] = button
	else
		button.instant = true -- let update on attribute change
	end
	-- This Script gets called every time a aura changed/was added or removed.
	-- We can use this to update the whole thing and its children.
	button:SetScript("OnAttributeChanged", AuraAttributeChanged)
	button:SetScript("OnUpdate", Button_OnUpdate)
	button:SetScript("OnEnter", AuraButton_OnEnter)
	button:SetScript("OnLeave", AuraButton_OnLeave)
	button:SetScript("OnShow", AuraButton_OnShow)
	button:SetScript("OnHide", AuraButton_OnHide)
	--button:HookScript("OnClick", AuraButton_OnClick)
	button.InvokeClick = HandleClick
	
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
	
	-- Let's disable this for now, since it seems to cause taint
	--if true then return end
	
	local Target
	if CO.db.char.unitframe.buffs.useMasque and button:GetParent():GetAttribute("filter") == "HELPFUL" then
		Target = MasqueGroup_Buffs
	elseif CO.db.char.unitframe.debuffs.useMasque and button:GetParent():GetAttribute("filter") == "HARMFUL" then
		Target = MasqueGroup_Debuffs
	end
	if Target then
		Target:AddButton(button, ButtonData)
		-- Don't ReSkin here, as it will: Impact performance, due to rapid creation of buttons and cause flickering, since the whole group is being iterated
		--Target:ReSkin()
		
		-- Not needed anymore, but let's keep this
		if button.__MSQ_BaseFrame then
			button.__MSQ_BaseFrame:SetFrameLevel(2) --Lower the framelevel to fix issue with buttons created during combat
		end
	end
end

local function AuraHeader_OnEvent(self, event)
	if event == 'WEAPON_ENCHANT_CHANGED' then
		local header = self.frame
		for enchantIndex, button in next, header.enchantButtons do
			if header.enchants[enchantIndex] ~= button then
				header.enchants[enchantIndex] = button
				header.elapsedEnchants = 0 -- reset the timer so we can wait for the data to be ready
			end
		end
	end
end

local function AuraHeader_OnUpdate(self, elapsed)
	local header = self.frame
	if header.elapsedSpells and header.elapsedSpells > 0.1 then
		local button, value = next(header.spells)
		while button do
			UpdateAura(button, value)

			header.spells[button] = nil
			button, value = next(header.spells)
		end

		header.elapsedSpells = 0
	else
		header.elapsedSpells = (header.elapsedSpells or 0) + elapsed
	end

	if header.elapsedEnchants and header.elapsedEnchants > 0.5 then
		local index, enchant = next(header.enchants)
		if index then
			local _, main, _, _, _, offhand, _, _, _, ranged = GetWeaponEnchantInfo()
			while enchant do
				--AUR:UpdateEnchant(enchant, enchant:GetID())

				header.enchants[index] = nil
				index, enchant = next(header.enchants)
			end
		end

		header.elapsedEnchants = 0
	else
		header.elapsedEnchants = (header.elapsedEnchants or 0) + elapsed
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
	
	--header:SetAttribute("consolidateTo", 0)
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
	if MasqueGroup_Buffs and CO.db.char.unitframe.buffs.useMasque then
		MasqueGroup_Buffs:ReSkin()
	elseif MasqueGroup_Debuffs and CO.db.char.unitframe.debuffs.useMasque then
		MasqueGroup_Debuffs:ReSkin()
	end
	
	self:ColorizeAll()
end

local function CreatePlayerAuraHeader(filter)
	local name = "CUIPlayerDebuffs"
	if filter == "HELPFUL" then name = "CUIPlayerBuffs" end
	
	local header = CreateFrame("Frame", name, E.Parent, "SecureAuraHeaderTemplate")
	header:SetClampedToScreen(true)
	header:UnregisterEvent('UNIT_AURA')
	header:RegisterUnitEvent('UNIT_AURA', 'player', 'vehicle')
	header:SetAttribute("unit", "player")
	header:SetAttribute("filter", filter)
	header.enchantButtons = {}
	header.enchants = {}
	header.spells = {}
	
	header.visibility = CreateFrame('Frame', "CUI_AurasVisibilityHandler", UIParent, 'SecureHandlerStateTemplate')
	header.visibility:SetScript('OnUpdate', AuraHeader_OnUpdate) -- dont put this on the main frame
	header.visibility:SetScript('OnEvent', AuraHeader_OnEvent) -- dont put this on the main frame
	header.visibility.frame = header
	header.auraType = auraType
	header.filter = filter
	header.name = name
	
	header.visibility:RegisterEvent('WEAPON_ENCHANT_CHANGED')
	
	-- This line causes a bug on the Blizz side of the statedriver code, DO NOT USE
	-- The statedriver fires an update EVERY frame, since it gets caught in a loop *somehow*
	--RegisterStateDriver(header, "visibility", "[petbattle] hide; show")
	E:HandleFrameInPetBattles(header)
	RegisterAttributeDriver(header, "unit", "[vehicleui] vehicle; player")

	if filter == "HELPFUL" then
		header:SetAttribute('consolidateDuration', -1)
		header:SetAttribute("includeWeapons", 1)
	end
	
	header:Show()

	return header
end

function AUR:InitializeAuras()
	self.BuffFrame = CreatePlayerAuraHeader("HELPFUL")
	E:CreateMover(self.BuffFrame, L["buffs"], "TOPRIGHT")

	self.DebuffFrame = CreatePlayerAuraHeader("HARMFUL")	
	E:CreateMover(self.DebuffFrame, L["debuffs"], "BOTTOMRIGHT")
	
	self.Headers = {self.BuffFrame, self.DebuffFrame}
	
	B:RemovePlayerAuras()
end

function AUR:Init()	
	self.db = CO.db.profile.unitframe.auras
	
	if CO.db.char.auras.playerAuras.enable then
		self:InitializeAuras()
		self:LoadConfig()
	end
end

E:AddModule("Auras", AUR)