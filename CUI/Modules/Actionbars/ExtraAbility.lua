local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, AB = E:LoadModules("Config", "Actionbars")


local LibKeyBound = LibStub('LibKeyBound-1.0-CUI')

function AB:InitExtraAbility()
	--print("INIT EA")
	--print(ExtraAbilityContainer)
	if not self.ExtraAbilityInitialized then
		ExtraAbilityHolder = CreateFrame('Frame', 'ExtraAbilityFrameHolder', E.Parent)
		ExtraAbilityHolder:SetPoint('BOTTOM', E.Parent, 'BOTTOM', 0, 215)
		ExtraAbilityHolder:SetSize(ZoneAbilityFrame:GetSize())
		
		ExtraAbilityContainer:SetParent(ExtraAbilityHolder)
		ExtraAbilityContainer:ClearAllPoints()
		ExtraAbilityContainer:SetAllPoints(ExtraAbilityHolder)
		
		ExtraAbilityContainer:SetScript('OnShow', nil)
		--ExtraAbilityContainer:SetScript('OnUpdate', nil)
		--ExtraAbilityContainer.OnUpdate = nil -- remove BaseLayoutMixin.OnUpdate
		ExtraAbilityContainer.IsLayoutFrame = nil -- dont let it get readded
		
		ExtraAbilityContainer.ignoreFramePositionManager = true
		E:CreateMover(ExtraAbilityHolder, "Extra Buttons", nil, nil, nil, nil, "actionbars")
		
		self.ExtraAbilityInitialized = true
	end
	
	AB:UpdateZoneActionButton()
end

function AB:UpdateZoneActionButtonBinding()
	--UpdateHotkey()
end

function AB:UpdateExtraAbilty()
	--local db = CO.db.profile.actionbar["extrabar"]
	
	E:LoadMoverPositions(ExtraAbilityHolder)
	--ExtraAbilityHolder:SetScale(db.buttonSizeMultiplier)
end