local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, AB, UF = E:LoadModules("Config", "Actionbars", "Unitframes")


local _G			= _G
local ipairs		= ipairs


local alerts = {"StoreMicroButtonAlert","EJMicroButtonAlert","LFDMicroButtonAlert","CollectionsMicroButtonAlert","TalentMicroButtonAlert"}
local MicroButtons = {"CharacterMicroButton", "SpellbookMicroButton", "TalentMicroButton", "AchievementMicroButton", "QuestLogMicroButton", "GuildMicroButton", "LFDMicroButton", "CollectionsMicroButton", "EJMicroButton", "StoreMicroButton", "MainMenuMicroButton"}

local function UpdateTooltipPosition(self)
	GameTooltip:ClearAllPoints()
	
	local Pos, RelPos
	
	if self:GetTop() > GameTooltip:GetHeight() then
		Pos = "TOP"
		RelPos = "BOTTOM"
	else
		Pos = "BOTTOM"
		RelPos = "TOP"
	end
	if self:GetLeft() > GameTooltip:GetWidth() then
		Pos = Pos .. "RIGHT"
		RelPos = RelPos .. "LEFT"
	else
		Pos = Pos .. "LEFT"
		RelPos = RelPos .. "RIGHT"
	end
	
	GameTooltip:SetPoint(Pos, self, RelPos)
end

function AB:InitMicroMenu()
	local mover = CreateFrame("Frame", "MicroMenu_CUI", E.Parent)
	local index = 0
	self.MicroMenu = mover
	
	local ButtonOffset = 25
	local ButtonInvisibleOffset = 4
	for _, v in pairs(_G.MICRO_BUTTONS) do
		local Button = _G[v]
		
		if Button:IsVisible() then
			--Button:ClearAllPoints()
			Button:SetParent(_G.MicroMenu)
			Button:SetPoint("TOPLEFT", _G.MicroMenu, "TOPLEFT", (ButtonOffset * index) - ButtonInvisibleOffset, 0)
			
			--[[local normal = Button:GetNormalTexture()
			local pushed = Button:GetPushedTexture()
			local disabled = Button:GetDisabledTexture()
			local highlight = Button:GetHighlightTexture()
			
			normal:SetTexCoord(0.22, 0.81, 0.21, 0.82)
			pushed:SetTexCoord(0.22, 0.81, 0.21, 0.82)
			highlight:SetTexCoord(0.22, 0.81, 0.21, 0.82)
			if disabled then
				disabled:SetTexCoord(0.22, 0.81, 0.21, 0.82)
			end]]--
			
			Button.Hover = Button:CreateTexture(nil, "HIGHLIGHT")
			Button.Hover:SetAllPoints(Button)
			Button.Hover:SetColorTexture(1, 1, 1, 0.2)
			
			index = index + 1
		end
	end
	
	mover:SetSize(ButtonOffset*index, 36)
	
	MainMenuMicroButton.MainMenuBarPerformanceBar:Hide()
	
	hooksecurefunc("MainMenuBarPerformanceBarFrame_OnEnter", UpdateTooltipPosition)
	
	mover.Overlay = CreateFrame("Frame", "CUI_MicroMenuMoverOverlayFrame", mover)
	mover.Overlay:SetAllPoints(mover)
	mover.Border = E:CreateBorder(mover.Overlay, nil, -1)
	
	_G.MicroMenu:SetParent(mover)
	_G.MicroMenu:ClearAllPoints()
	_G.MicroMenu:SetAllPoints(mover)
	
	
	E:CreateMover(mover, L["micromenu"], nil, nil, nil, nil, "actionbars")
	self:UpdateMicroMenu()
end

function AB:UpdateMicroMenu()
	local db = CO.db.profile.actionbar["micromenu"]
	
	if db.enable ~= true then self.MicroMenu:Hide(); self.MicroMenu.ForceMoverEnabled = false; return end
	if not self.MicroMenu:IsVisible() then self.MicroMenu:Show() end
	
	self.MicroMenu.ForceMoverEnabled = nil
	
	--self:MainMenuMicroButton_RepositionAlerts()
	E:LoadMoverPositions(self.MicroMenu)
	
	self.MicroMenu:SetScale(db.buttonSizeMultiplier)
	
	local MMDBColor = E:ParseDBColor(db.borderColor)
	
	self.MicroMenu.Border.SetBorderSize(db.borderSize)
	self.MicroMenu.Border:SetBackdropBorderColor(MMDBColor[1], MMDBColor[2], MMDBColor[3], MMDBColor[4] or 1)
end

function AB:MainMenuMicroButton_PositionAlert(alert)
	
	local OffsetX, OffsetY = 0
		alert:ClearAllPoints();
		alert:SetPoint("TOP", alert.MicroButton, "BOTTOM", 0, -18);
		alert.Arrow:ClearAllPoints();
		alert.Arrow:SetPoint("BOTTOM", alert, "TOP", 0, 0);
		self:MicroMenuButton_SetAlertArrowTexCoord(alert, {0.78515625,0.99218750,0.58789063,0.54687500})
	
	if ( alert.MicroButton:GetLeft() + (alert:GetWidth() / 2) > E.Parent:GetLeft() ) then
		if alert:GetLeft() < 0 then
			E:PushFrame(alert, alert:GetLeft() * -1, 0)
			E:PushFrame(alert.Arrow, alert:GetLeft(), 0)
		end
	end
end
	
function AB:MicroMenuButton_SetAlertArrowTexCoord(alert, texcoord)
	local kids = { alert.Arrow:GetRegions() };

	for _, child in ipairs(kids) do
		child:SetTexCoord(texcoord[1],texcoord[2],texcoord[3],texcoord[4])
	end
end

function AB:MainMenuMicroButton_RepositionAlerts()
	for _, alert in pairs(alerts) do
		if _G[alert].MicroButton then
			self:MainMenuMicroButton_PositionAlert(_G[alert])
		end
	end
end