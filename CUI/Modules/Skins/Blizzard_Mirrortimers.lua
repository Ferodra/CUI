local E, L = unpack(select(2, ...)) -- Engine, Locale
local L, CO, BM = E:LoadModules("Locale", "Config", "Blizzard_Mirrortimers")
BM.Autoload = true

function BM:Init()

	local MirrorTimer_Holder = CreateFrame("Frame", "MirrorTimerHolder", E.Parent)
	MirrorTimer_Holder:SetSize(250, 20)
	
	local function UpdateBarTimer(self)
		self.Value = self:GetValue()
		local m, s = self.Value / 60, self.Value % 60
		self.Time:SetText(string.format("%d:%02d", m, s)) -- Formats the time to an 00:00 format
	end
	
	for i = 1, MIRRORTIMER_NUMTIMERS do
		local Timer = _G["MirrorTimer" .. i]
		local Bar 	= _G["MirrorTimer" .. i .. "StatusBar"]
		local Text	= _G["MirrorTimer" .. i .. "Text"]
		
		Timer:SetParent(MirrorTimer_Holder)
		Timer:ClearAllPoints()
		Timer:SetAllPoints(MirrorTimer_Holder)
		
		Timer:SetSize(250, 20)
		Bar:SetSize(250, 20)
		
		E:RegisterStatusBar(Bar)
			Bar:SetStatusBarTexture(E.Media:Fetch("statusbar", CO.db.profile.unitframe.units.all.barTexture))
		
		Bar.Background = E:CreateBackground(Bar)
		Bar.Border = E:CreateBorder(Bar, nil, 1)
		
		for i = 1, Timer:GetNumRegions() do
			local region = select(i, Timer:GetRegions())
			if region and region:IsObjectType("Texture") then
				region:SetTexture(nil)
			end
		end
		
		Text:ClearAllPoints()
		Text:SetPoint("LEFT", Bar, "LEFT", 10, 0)
		
		Bar.Time = Bar:CreateFontString(nil)
			E:InitializeFontFrame(Bar.Time, "OVERLAY", "FRIZQT__.TTF", 11, {1, 1, 1}, 1, {-10, 0}, "", 0, 0, Bar, "RIGHT", {1,1})
		
		Bar:SetScript("OnValueChanged", UpdateBarTimer)
				
	end
	
	E:CreateMover(MirrorTimer_Holder, "Mirror Timers", nil, nil, nil, "A frame that holds timers like Breath, Fatigue and Feign Death.")
end
E:AddModule("Blizzard_Mirrortimers", BM)