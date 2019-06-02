local E, L = unpack(select(2, ...)) -- Engine, Locale
local L, CO, AB = E:LoadModules("Locale", "Config", "Actionbars")


local LibKeyBound = LibStub('LibKeyBound-1.0')


function AB:InitZoneActionButton()
	E:CreateMover(ZoneAbilityFrame, "Zone Button")
	ZoneAbilityFrame.ignoreFramePositionManager = true
	
	ZoneAbilityFrame.SpellButton:HookScript("OnEnter", function(self)
		LibKeyBound:Set(self)
	end)
	ZoneAbilityFrame.SpellButton.GetHotkey = AB.GetHotkey
	
	E:RegisterPathFont(ZoneAbilityFrame.SpellButton.Count, "db.profile.actionbar.zonebar.count")
	
	AB:UpdateZoneActionButton()
end

function AB:UpdateZoneActionButton()
	local db = CO.db.profile.actionbar["zonebar"]
	
	E:LoadMoverPositions(ZoneAbilityFrame)
	ZoneAbilityFrame:SetScale(db.buttonSizeMultiplier)
end