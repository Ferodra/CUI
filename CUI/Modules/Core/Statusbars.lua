local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, L = E:LoadModules("Config", "Locale")

---------------------------------------------------
local pairs 					= pairs
---------------------------------------------------

E.StatusBars = {}

function E:RegisterStatusBar(Bar)
	-- Expects Bar.Unit and Bar.Type to already be present
	tinsert(self.StatusBars, Bar)
	self:UpdateStatusBarTexture(Bar)
end

function E:UpdateStatusBarTexture(Bar)
	if Bar:GetAttribute("ReceivesGlobalTexture") ~= false then
		Bar:SetStatusBarTexture(E.Media:Fetch("statusbar", CO.db.profile.unitframe.units.all.barTexture))
	end
end

function E:UpdateAllBarTextures()
	for k, v in pairs(self.StatusBars) do
		if v:GetAttribute("ReceivesGlobalTexture") ~= false then
			v:SetStatusBarTexture(E.Media:Fetch("statusbar", CO.db.profile.unitframe.units.all.barTexture))
		end
	end
end