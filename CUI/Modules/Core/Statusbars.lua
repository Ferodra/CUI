local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO = E:LoadModules("Config")

---------------------------------------------------
local pairs 					= pairs
---------------------------------------------------

E.StatusBars = {}

function E:RegisterStatusBar(Bar)
	tinsert(self.StatusBars, Bar)
	self:UpdateStatusBarTexture(Bar)
end

function E:UpdateStatusBarTexture(Bar)
	if Bar:GetAttribute("ReceivesGlobalTexture") ~= false then
		Bar:SetStatusBarTexture(self.Media:Fetch("statusbar", CO.db.profile.unitframe.units.all.barTexture))
	end
end

function E:UpdateAllBarTextures()
	for k, v in pairs(self.StatusBars) do
		self:UpdateStatusBarTexture(v)
	end
end