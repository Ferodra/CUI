local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, L, WM = E:LoadModules("Config", "Locale", "Worldmap")

----------------------------------------------------------------------
local format		= string.format
----------------------------------------------------------------------
----------------------------------------------------------------------
	local Coords = CreateFrame("Frame")

	local XRaw, YRaw, LastUpdate = 0, 0, 0
	function WM:UpdateCoords(elapsed)
		LastUpdate = LastUpdate + elapsed
		
		if LastUpdate >= 0.05 then
			XRaw, YRaw = WorldMapFrame:GetNormalizedCursorPosition() -- Eats memory unfortunately
			
			Coords.Font:SetText(format("Mouse: %s / %s", E:Round(XRaw * 100, 1), E:Round(YRaw * 100, 1)))
			
			LastUpdate = 0
		end
	end

	function WM:StartCoords(self)
		if CO.db.profile.worldmap.coords.enable then
			Coords:SetScript("OnUpdate", WM.UpdateCoords)
			Coords:Show()
		end
	end

	function WM:StopCoords(self)
		Coords:SetScript("OnUpdate", nil)
		Coords:Hide()
	end

	function WM:ConstructMapCoords()
		
		Coords:SetSize(250, 20)
		Coords:SetPoint("BOTTOM", WorldMapFrame.ScrollContainer, "BOTTOM")
		Coords:SetParent(WorldMapFrame.ScrollContainer)
		
		Coords.Font = Coords:CreateFontString(nil)
			E:InitializeFontFrame(Coords.Font, "OVERLAY", "FRIZQT__.TTF", 12, {0.933, 0.886, 0.125}, 0.9, {0,0}, "", 0, 0, Coords, "LEFT", {1,1})
		Coords.Font:SetJustifyH("LEFT")
		
		E:RegisterPathFont(Coords.Font, "db.profile.worldmap.coords")
					
		WorldMapFrame.ScrollContainer:HookScript("OnEnter", WM.StartCoords)
		WorldMapFrame.ScrollContainer:HookScript("OnLeave", WM.StopCoords)
	end
----------------------------------------------------------------------

function WM:Init()
	self:ConstructMapCoords()
end

E:AddModule("Worldmap", WM)