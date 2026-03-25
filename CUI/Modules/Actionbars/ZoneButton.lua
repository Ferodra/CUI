local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, AB = E:LoadModules("Config", "Actionbars")


local LibKeyBound = LibStub('LibKeyBound-1.0-CUI')
local ZoneActionButtonHolder

local function ZoneAbility_GetHotkey(self)
	local name = "CLICK " .. self.config.keyBoundTarget .. ":LeftButton"
	local key = GetBindingKey(name)
	
	if key then
		local ShortKey = AB:GetShortHotkey(key)
		
		return ShortKey
	end
end

local function UpdateHotkey()
	local Button = ZoneAbilityFrame.SpellButton or ZoneAbilityFrame.SpellButtonContainer
	Button.HotKey:SetText(ZoneAbility_GetHotkey(Button))
end

function AB:InitZoneActionButton()
	
	if InCombatLockdown() then return end
	if not self.ZoneButtonInitialized then		
		
		local Button = ZoneAbilityFrame.SpellButton or ZoneAbilityFrame.SpellButtonContainer
		ZoneAbilityFrame.ignoreInLayout = true
		
		-- Since 9.0, the cooldown, spellbutton and text objects only are created on first show
		
		local function SetupButton(self, template)
			for spellButton in ZoneAbilityFrame.SpellButtonContainer:EnumerateActive() do
				if not spellButton.CUIModded then
					--spellButton:HookScript("OnEnter", function(self)
					--	LibKeyBound:Set(self)
					--end)
					
					spellButton.Overlay = CreateFrame("Frame", "CUI_ZoneButtonOverlayFrame", spellButton)
					spellButton.Overlay:SetAllPoints(Button)
					
					spellButton.cooldown = spellButton.Cooldown
					spellButton.cooldown.Parent = spellButton
					
					spellButton.Cooldown:SetHideCountdownNumbers(true)
					
					AB:CreateCooldownText(spellButton)
					--hooksecurefunc(spellButton.cooldown, 'SetCooldown', AB.OnSetCooldown)
					
					if spellButton.HotKey then
						E:RegisterAutoFont(spellButton.HotKey, "db.profile.actionbar.zonebar.hotkey")
					end
					E:RegisterAutoFont(spellButton.Count, "db.profile.actionbar.zonebar.count")
					E:RegisterAutoFont(spellButton.cooldown.cooldownText, "db.profile.actionbar.zonebar.cooldown")
					
					spellButton.CUIModded = true
				end
			end
				
			if template ~= "ZoneAbilityFrameSpellButtonTemplate" then return end
			if not Button.cooldown then
				Button.Overlay = CreateFrame("Frame", "CUI_ZoneButtonOverlayFrame", Button)
				Button.Overlay:SetAllPoints(Button)
				
				Button.cooldown = Button.Cooldown
				Button.cooldown.Parent = Button
				
				AB:CreateCooldownText(Button)
				--hooksecurefunc(Button.cooldown, 'SetCooldown', AB.OnSetCooldown)
				
				E:RegisterAutoFont(Button.HotKey, "db.profile.actionbar.zonebar.hotkey")
				E:RegisterAutoFont(Button.Count, "db.profile.actionbar.zonebar.count")
				E:RegisterAutoFont(Button.cooldown.cooldownText, "db.profile.actionbar.zonebar.cooldown")
			end
		end
		
		if E.IsRetail then
			--hooksecurefunc(Button, "SetTemplate", function(self, template)
			hooksecurefunc(ZoneAbilityFrame, "UpdateDisplayedZoneAbilities", function(self)
				SetupButton(self)
			end)
		else
			SetupButton(Button, "ZoneAbilityFrameSpellButtonTemplate")
		end
		
		self.ZoneButtonInitialized = true
	end
	
	AB:UpdateZoneActionButton()
end

function AB:UpdateZoneActionButtonBinding()
	--UpdateHotkey()
end

function AB:UpdateZoneActionButton()
	if InCombatLockdown() then return end
	local db = CO.db.profile.actionbar["zonebar"]
	
	--E:LoadMoverPositions(ZoneActionButtonHolder)
	
	ZoneAbilityFrame:SetScale(db.buttonSizeMultiplier)
	
	local Button = ZoneAbilityFrame.SpellButton or ZoneAbilityFrame.SpellButtonContainer
	Button.cooldownFormat = db.cooldownFormat
end