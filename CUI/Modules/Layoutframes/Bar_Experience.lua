local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF, TT, Module = E:LoadModules("Config", "Unitframes", "Tooltip", "Bar_Experience")

local _

local XPMax, XPCurrent, MaxLevel, PlayerLevel, BarX, BarY, BarPoint, BarParent, BarStrata, XPRestedString

local TexturePath = [[Interface\AddOns\CUI\Textures\]]
local Textures = {
	['integrated'] = TexturePath .. [[statusbar\layoutBarBottomReversed]],
	['integratedReversed'] = TexturePath .. [[statusbar\layoutBarBottom]],
	['integratedReversedFlipped'] = TexturePath .. [[statusbar\layoutBarBottomFlipped]],
	['integratedFlipped'] = TexturePath .. [[statusbar\layoutBarBottomReversedFlipped]],
	['XPBarTexture'] =  TexturePath .. [[layout\modern\XPBar]]
}

--------------------------------------------------------
function Module:LoadConfig()
	self = Module -- Set for external calls
	
	self.db = CO.db.profile.layout.barExperience
	
	if self.db.enable then
		
		self.Bar.Overlay:SetReverseFill(false)
		self.Bar.Overlay:SetOrientation("HORIZONTAL")
		self.Bar.Rested:SetReverseFill(false)
		self.Bar.Rested:SetOrientation("HORIZONTAL")
		
		self.Bar.Border:Hide()
		
		self.Bar.Overlay:SetAttribute("ReceivesGlobalTexture", false)
		self.Bar.Rested:SetAttribute("ReceivesGlobalTexture", false)
		
		if self.db.style ~= "normal" then
			self.Bar.Background.Tex:SetVertexColor(unpack(self.db.backgroundColor))
		end
		local Texture = Textures[self.db.style]

		if Texture then
			self.Bar.Overlay:SetStatusBarTexture(Texture)
			self.Bar.Rested:SetStatusBarTexture(Texture)
			self.Bar.Background.Tex:SetTexture(Texture)
		else			
			self.Bar.Overlay:SetAttribute("ReceivesGlobalTexture", true)
			self.Bar.Rested:SetAttribute("ReceivesGlobalTexture", true)
			self.Bar.Overlay:SetStatusBarTexture(E.Media:Fetch("statusbar", CO.db.profile.unitframe.units["all"]['barTexture']))
			self.Bar.Rested:SetStatusBarTexture(E.Media:Fetch("statusbar", CO.db.profile.unitframe.units["all"]['barTexture']))
			self.Bar.Background.Tex:SetTexture(nil)
			
			self.Bar.Overlay:SetReverseFill(self.db.reverseFill)
			self.Bar.Overlay:SetOrientation(self.db.fillOrientation)
			self.Bar.Rested:SetReverseFill(self.db.reverseFill)
			self.Bar.Rested:SetOrientation(self.db.fillOrientation)
			
			self.Bar.Border:Show()
			
			self.Bar:SetBorderSize(self.db.borderSize)
			self.Bar:SetBackgroundColor(unpack(self.db.backgroundColor))
			self.Bar:SetBorderColor(unpack(self.db.borderColor))
		end
		
		self.Bar:ClearAllPoints()
		self.Bar:SetPoint(self.db.position, E.Parent, self.db.position, self.db.offsetX, self.db.offsetY)
		
		self.Bar:SetSize(self.db.width, self.db.height)
		self.Bar.Rested:SetSize(self.db.width, self.db.height)
		
		local nrmCol, restedCol = E:ParseDBColor(CO.db.profile.colors.layoutBars["barExperienceNormal"]), E:ParseDBColor(CO.db.profile.colors.layoutBars["barExperienceRested"])
		self.Bar.Overlay:GetStatusBarTexture():SetVertexColor(nrmCol[1], nrmCol[2], nrmCol[3], nrmCol[4])
		self.Bar.Rested:GetStatusBarTexture():SetVertexColor(restedCol[1], restedCol[2], restedCol[3], restedCol[4])
		
		self:RegisterEvent("PLAYER_ENTERING_WORLD")
		self:RegisterEvent("PLAYER_XP_UPDATE")
		self:RegisterEvent("UPDATE_EXHAUSTION")
		self.Bar.Overlay:SetScript('OnValueChanged', self.UpdateText)
		
		-- Instead of a straight "Show", first validate if it is supposed to!
		self:Update() -- Update if shown (again) to prevent dirty values
	else
		self.Bar:Hide()
	end
end
--------------------------------------------------------

function Module:UpdateText(value)
	self.Font:SetText(string.format("%s / %s (%s%%) %s", E:readableNumber(value, 2), E:readableNumber(self.Max, 2), E:Round((value/self.Max)*100,2), XPRestedString))
end

function Module:SetValue(value)
	local XPRested = GetXPExhaustion()
	
	--self.Bar:SetValue(value, 0, self.Bar.Overlay.Max, UnitLevel("player"))
	--self.UpdateText(self.Bar.Overlay, value)
	
	if XPRested then
		XPRestedString = string.format(" %s: %s", TUTORIAL_TITLE26, E:readableNumber(XPRested, 2))
		self.Bar.Rested:SetValue(value + XPRested)
		
		return
	else
		self.Bar.Rested:SetValue(0)
	end
	
	XPRestedString = ""
end

function Module:Update(SkipAnimation)
	local PlayerLevel = UnitLevel("player")
	
	if E.UNIT_MAXLEVEL ~= PlayerLevel then
		local XPMax = UnitXPMax("player")
		local XPCurrent = UnitXP("player")
		
		self.Bar.Overlay.Max = XPMax
		
		if not SkipAnimation then
			self.Bar.Overlay:SetAnimatedValues(XPCurrent, 0, XPMax, PlayerLevel)
		else
			self.Bar.Overlay:SetMinMaxValues(0, XPMax)
			self.Bar.Overlay:SetValue(XPCurrent)
		end
		
		self.Bar.Rested:SetMinMaxValues(0, XPMax)
		self:SetValue(XPCurrent)
		self.UpdateText(self.Bar.Overlay, XPCurrent)
		
		self.Bar:Show()
	else
		self.Bar:Hide()
	end
end

function Module:SetBarSmoothFactor(factor)
	self.Bar.Overlay:SetSmoothFactor(factor)
	self.Bar.Rested:SetSmoothFactor(factor)
end

local function IsCapped(self)
	if GameLimitedMode_IsBankedXPActive() then
		local restrictedLevel = GameLimitedMode_GetLevelLimit();
		return UnitLevel("player") >= restrictedLevel;
	end

	return false;
end

local function GetLevelData(self)
	local currXP = IsCapped(self) and UnitTrialXP("player") or UnitXP("player");
	local nextXP = UnitXPMax("player");
	local level = UnitLevel("player");
	local bankedLevels = UnitTrialBankedLevels("player");

	return currXP, nextXP, level, bankedLevels;
end

local function BarTooltip(self)
	local exhaustionStateID, exhaustionStateName, exhaustionStateMultiplier = GetRestState();
	if(not exhaustionStateID) then
		return;
	end

	local currXP, nextXP = GetLevelData(self);
	local percentXP = math.ceil(currXP/nextXP*100);

	local tooltip = GetAppropriateTooltip();
	GameTooltip_SetDefaultAnchor(tooltip, UIParent);
	GameTooltip_SetTitle(tooltip, XP_TEXT:format(BreakUpLargeNumbers(currXP), BreakUpLargeNumbers(nextXP), percentXP));
	GameTooltip_AddHighlightLine(tooltip, EXHAUST_TOOLTIP1:format(exhaustionStateName, exhaustionStateMultiplier * 100));

	if not IsResting() and (exhaustionStateID == 4 or exhaustionStateID == 5) then
		GameTooltip_AddHighlightLine(tooltip, EXHAUST_TOOLTIP2);
	end

	if GameLimitedMode_IsBankedXPActive() then
		local bankedLevels = UnitTrialBankedLevels("player");
		local bankedXP = UnitTrialXP("player");

		if bankedLevels > 0 or bankedXP > 0 then
			GameTooltip_AddBlankLineToTooltip(tooltip);
			GameTooltip_AddNormalLine(tooltip, XP_TEXT_BANKED_XP_HEADER);
		end

		if bankedLevels > 0 then
			GameTooltip_AddHighlightLine(tooltip, TRIAL_CAP_BANKED_LEVELS_TOOLTIP:format(bankedLevels));
		elseif bankedXP > 0 then
			GameTooltip_AddHighlightLine(tooltip, TRIAL_CAP_BANKED_XP_TOOLTIP);
		end
	end

	GameTooltip:Show();
end

function Module:Create()
	BarStrata, BarX, BarY, BarPoint, BarParent = "MEDIUM", 750, 14, {"BOTTOM", E.Parent, "BOTTOM"}, E.Parent
	
	self.Bar = E:CreateAnimatedBar("Bar_Experience", BarStrata, BarX, BarY, BarPoint, self.Holder or E.Parent)
	
	E:HandleFrameInPetBattles(self.Bar)
	
	self.Bar.Rested = E:NewFrame("Statusbar", "Bar_Experience_Rested", "MEDIUM", BarX, BarY, BarPoint, self.Bar.Background)
	self.Bar.Rested:SetStatusBarTexture(Textures.XPBarTexture)
	self.Bar.Rested:ClearAllPoints()
	self.Bar.Rested:SetAllPoints(self.Bar)
	self.Bar.Rested:SetParent(self.Bar)
	
	E:RegisterStatusBar(self.Bar.Rested)
	
	self.Bar.Overlay:SetStatusBarTexture(Textures.XPBarTexture)
	
	self.Bar.Overlay:SetAttribute("ReceivesGlobalTexture", false)
	self.Bar.Rested:SetAttribute("ReceivesGlobalTexture", false)
	
	E.Libs.LibSmooth:SmoothBar(self.Bar.Rested)
	self:SetBarSmoothFactor(25)
	E.Libs.LibSmooth:ResetBar(self.Bar.Rested)
	E.Libs.LibSmooth:ResetBar(self.Bar.Overlay)
	
	self.Bar.Overlay.Font = self.Bar.Overlay:CreateFontString(nil, "ARTWORK")
	E:InitializeFontFrame(self.Bar.Overlay.Font, "ARTWORK", nil, 11, {0.8,0.8,0.8}, 1, {0,0}, "101010", 300, 20, self.Bar.Overlay, "CENTER", {1,1})
	
	self.Text = self.Bar.Overlay.Font
	
	E:RegisterAutoFont(self.Bar.Overlay.Font, "db.profile.layout.barExperience.font")
	
	self.Button = CreateFrame("Frame", "CUI_XPBarButton", self.Bar.Overlay)
	self.Button:SetAllPoints(self.Bar.Overlay)
	self.Button:EnableMouse(true)
	self.Button:SetScript("OnEnter", BarTooltip)
	self.Button:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

function Module:UpdateDB()
	self.db = CO.db.profile.layout.barExperience
end
function Module:Init()
	self:UpdateDB()
	
	self:Create()
	self:Update(true)
	
	self:SetScript("OnEvent", function(self, event)
		if event == 'PLAYER_ENTERING_WORLD' then
			E.Libs.LibSmooth:SmoothBar(self.Bar.Overlay)
			E.Libs.LibSmooth:SmoothBar(self.Bar.Rested)
		end
		
		self:Update(event == 'PLAYER_ENTERING_WORLD')
	end)
	
	self:LoadConfig()
end

E:AddModule("Bar_Experience", Module)