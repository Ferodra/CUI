local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, AB = E:LoadModules("Config", "Actionbars")

local LibKeyBound = LibStub('LibKeyBound-1.0-CUI')
local ExtraActionBarHolder

function AB:InitExtraActionButton()
	if InCombatLockdown() then return end
	
	-- ExtraActionBarHolder = CreateFrame('Frame', 'ExtraActionBarFrameHolder', E.Parent)
	-- ExtraActionBarHolder:SetPoint('BOTTOM', E.Parent, 'BOTTOM', 0, 150)
	-- ExtraActionBarHolder:SetSize(ExtraActionBarFrame:GetSize())
	
	-- ExtraActionBarFrame:SetParent(ExtraActionBarHolder)
	-- ExtraActionBarFrame:ClearAllPoints()
	-- ExtraActionBarFrame:SetAllPoints(ExtraActionBarHolder)
	-- ExtraActionBarFrame.ignoreFramePositionManager  = true
	
	-- E:CreateMover(ExtraActionBarHolder, "Extra Button", nil, nil, nil, nil, "actionbars")
	if not self.ExtraButtonInitialized then
		local Button = _G["ExtraActionButton1"]
		local Cooldown = Button.Cooldown or Button.cooldown
		
		-- Doing this does taint the cooldown and thus the button, as lowercase cooldown already exists and would be overwritten
		-- This seems to be a special case, for some reason, as every other button has it named "Cooldown".
		-- Button.cooldown = Cooldown
		--Button.Cooldown = Cooldown
		Cooldown.Parent = Button
		Button.Overlay = CreateFrame("Frame", "CUI_ExtraButtonOverlayFrame", Button)
		Button.Overlay:SetAllPoints(Button)
		
		self:CreateCooldownText(Button)
		--hooksecurefunc(Cooldown, 'SetCooldown', self.OnSetCooldown)
		
		Button:HookScript("OnEnter", function(self)
			LibKeyBound:Set(self)
		end)
		Button.GetHotkey = AB.GetHotkey
		
		E:RegisterAutoFont(Button.HotKey, "db.profile.actionbar.extrabar.hotkey")
		E:RegisterAutoFont(Button.Count, "db.profile.actionbar.extrabar.count")
		E:RegisterAutoFont(Cooldown.cooldownText, "db.profile.actionbar.extrabar.cooldown")

		-- Disable mouse for area around button
		_G['ExtraActionBarFrame']:EnableMouse(false)
		
		self.ExtraButtonInitialized = true
	end
	
	AB:UpdateExtraActionButton()
end

function AB:UpdateExtraActionButton()
	if InCombatLockdown() then return end
	local db = CO.db.profile.actionbar.extrabar
	
	--E:LoadMoverPositions(ExtraActionBarHolder)
	
	ExtraActionBarFrame:SetScale(db.buttonSizeMultiplier)
	
	local Button = _G["ExtraActionButton1"]
	Button.cooldownFormat = db.cooldownFormat
end