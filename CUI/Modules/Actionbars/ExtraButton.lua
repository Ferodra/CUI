local E, L = unpack(select(2, ...)) -- Engine, Locale
local L, CO, AB = E:LoadModules("Locale", "Config", "Actionbars")

local LibKeyBound = LibStub('LibKeyBound-1.0')


function AB:InitExtraActionButton()
	
	E:CreateMover(ExtraActionBarFrame, "Extra Button")
	ExtraActionBarFrame.ignoreFramePositionManager = true
	
	_G["ExtraActionButton1"]:HookScript("OnEnter", function(self)
		LibKeyBound:Set(self)
	end)
	_G["ExtraActionButton1"].GetHotkey = AB.GetHotkey
	
	E:RegisterPathFont(_G["ExtraActionButton1"].HotKey, "db.profile.actionbar.extrabar.hotkey")
	E:RegisterPathFont(_G["ExtraActionButton1"].Count, "db.profile.actionbar.extrabar.count")
	
	AB:UpdateExtraActionButton()
end

function AB:UpdateExtraActionButton()
	local db = CO.db.profile.actionbar.extrabar
	
	E:LoadMoverPositions(ExtraActionBarFrame)
	ExtraActionButton1:SetScale(db.buttonSizeMultiplier)
end