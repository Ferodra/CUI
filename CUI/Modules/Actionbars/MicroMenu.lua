local E, L = unpack(select(2, ...)) -- Engine, Locale
local L, CO, AB, UF = E:LoadModules("Locale", "Config", "Actionbars", "Unitframes")


local _G			= _G
local ipairs		= ipairs


local alerts = {"StoreMicroButtonAlert","EJMicroButtonAlert","LFDMicroButtonAlert","CollectionsMicroButtonAlert","TalentMicroButtonAlert"}
local MicroButtons = {"CharacterMicroButton", "SpellbookMicroButton", "TalentMicroButton", "AchievementMicroButton", "QuestLogMicroButton", "GuildMicroButton", "LFDMicroButton", "CollectionsMicroButton", "EJMicroButton", "StoreMicroButton", "MainMenuMicroButton"}


function AB:InitMicroMenu()
	local mover = CreateFrame("Frame", "MicroMenu", E.Parent)
	self.MicroMenu = mover
	mover:SetSize(308, 36)
	local index = 0
	
	for _, v in pairs(MicroButtons) do
		_G[v]:ClearAllPoints()
		_G[v]:SetParent(mover)
		_G[v]:SetPoint("BOTTOMLEFT", mover, "BOTTOMLEFT", _G[v]:GetWidth() * index, 0)
		
		local normal = _G[v]:GetNormalTexture()
		local pushed = _G[v]:GetPushedTexture()
		local disabled = _G[v]:GetDisabledTexture()
		local highlight = _G[v]:GetHighlightTexture()
		
		normal:SetTexCoord(0.22, 0.81, 0.21, 0.82)
		pushed:SetTexCoord(0.22, 0.81, 0.21, 0.82)
		highlight:SetTexCoord(0.22, 0.81, 0.21, 0.82)
		if disabled then
			disabled:SetTexCoord(0.22, 0.81, 0.21, 0.82)
		end
		
		_G[v].Hover = _G[v]:CreateTexture(nil, "HIGHLIGHT")
		_G[v].Hover:SetColorTexture(1, 1, 1, 0.45)
		
		index = index + 1
	end
	
	MicroButtonPortrait:ClearAllPoints()
	MicroButtonPortrait:SetAllPoints(_G["CharacterMicroButton"])
	
	GuildMicroButtonTabard:ClearAllPoints()
	GuildMicroButtonTabard:SetAllPoints(_G["GuildMicroButton"])
	
	MainMenuBarPerformanceBar:Hide()
	
	mover.Border = E:CreateBorder(mover, nil, -1)
	
	E:CreateMover(mover, L["micromenu"])
	self:UpdateMicroMenu()
end

function AB:UpdateMicroMenu()
	local db = CO.db.profile.actionbar["micromenu"]
	
	if db.enable ~= true then self.MicroMenu:Hide() return end
	if not self.MicroMenu:IsVisible() then self.MicroMenu:Show() end
	
	self:MainMenuMicroButton_RepositionAlerts()
	E:LoadMoverPositions("MicroMenu")
	E:GetMover(self.MicroMenu):SetScale(db.buttonSizeMultiplier)
	
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