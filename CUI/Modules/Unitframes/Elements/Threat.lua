local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF, TT, BT = E:LoadModules("Config", "Unitframes", "Tooltip", "Bar_Threat")
BT.Autoload = true

-----------------------------------------
local _
local UnitCanAttack					= UnitCanAttack
local UnitDetailedThreatSituation	= UnitDetailedThreatSituation
-----------------------------------------

local UpdateInterval = 0.2 -- 5 times per second

local lastUpdate, threatpct = 0, 0
function BT:__Update(elapsed)
	
	lastUpdate = (lastUpdate or 0) + elapsed
	if lastUpdate > UpdateInterval then
		_, _, threatpct, _, _ = UnitDetailedThreatSituation("player", "target")
		self:SetValue(threatpct or 0)
		
		lastUpdate = 0
	end
end

function BT:__OnEvent()
	if UnitCanAttack("target", "player") then
		self:Show()
	else
		self:Hide()
	end
end

function BT:__LoadConfig()
	self.db = CO.db.profile.unitframe.units.target.threatBar
	
	self.Bar:ClearAllPoints()
	self.Bar:SetPoint(self.db.position, UF.Frames.target, self.db.relativePosition, self.db.offsetX, self.db.offsetY)
end

function BT:__Construct()
	self.Bar = E:CreateBar("CUI_ThreatBar", "LOW", 5, 68, {"LEFT", UF.Frames.target, "RIGHT"}, UF.Frames["target"], 0, 0, 0)
	self.Bar:SetMinMaxValues(0, 100)
	self.Bar:SetValue(0)
	
	self.Bar.Overlay:SetOrientation("VERTICAL")
	self.Bar.Overlay:GetStatusBarTexture():SetVertexColor(1, 0.8, 0.17) -- Yellow
	
	-- self.Bar.Border:SetBackdropBorderColor
	
	-- @TODO: Options for the threat-bar!
	
	self.Bar:RegisterEvent("PLAYER_TARGET_CHANGED")
	self.Bar:RegisterUnitEvent("UNIT_FACTION", "target")
	
	self.Bar:SetScript("OnUpdate", self.__Update)
	self.Bar:SetScript("OnEvent", self.__OnEvent)
end

function BT:Init()
	self.db = CO.db.profile.unitframe.units.target.threatBar
	
	self:__Construct()
end

E:AddModule("Bar_Threat", BT)