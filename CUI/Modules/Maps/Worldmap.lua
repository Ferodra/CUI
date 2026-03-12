local E = unpack(select(2, ...)) -- Engine, Locale
local CO, Module = E:LoadModules("Config", "Worldmap")

----------------------------------------------------------------------
local format		= string.format
----------------------------------------------------------------------
----------------------------------------------------------------------
	local Coords = CreateFrame("Frame", "CUI_WorldmapFrame")

	local XRaw, YRaw, LastUpdate = 0, 0, 0
	function Module:UpdateCoords(elapsed)
		LastUpdate = LastUpdate + elapsed
		
		if LastUpdate >= 0.05 then
			XRaw, YRaw = WorldMapFrame:GetNormalizedCursorPosition() -- Eats memory unfortunately
			
			Coords.Font:SetText(format("Mouse: %s / %s", E:Round(XRaw * 100, 1), E:Round(YRaw * 100, 1)))
			
			LastUpdate = 0
		end
	end

	local function OnEnter(self)
		if CO.db.profile.worldmap.coords.enable then
			Coords:SetScript("OnUpdate", Module.UpdateCoords)
			Coords:Show()
		end
	end

	local function OnLeave(self)
		Coords:SetScript("OnUpdate", nil)
		Coords:Hide()
	end

	function Module:ConstructMapCoords()
		
		Coords:SetSize(250, 20)
		Coords:SetPoint("BOTTOM", WorldMapFrame.ScrollContainer, "BOTTOM")
		Coords:SetParent(WorldMapFrame.ScrollContainer)
		
		Coords.Font = E:NewFontObject(nil, "OVERLAY", Coords, 12)
		--Coords.Font = Coords:CreateFontString(nil)
		--E:InitializeFontFrame(Coords.Font, "OVERLAY", "FRIZQT__.TTF", 12, {0.933, 0.886, 0.125}, 0.9, {0,0}, "", 0, 0, Coords, "LEFT", {1,1})
		Coords.Font:SetJustifyH("LEFT")
		E:RegisterAutoFont(Coords.Font, "db.profile.worldmap.coords")
					
		WorldMapFrame.ScrollContainer:HookScript("OnEnter", OnEnter)
		WorldMapFrame.ScrollContainer:HookScript("OnLeave", OnLeave)
	end
----------------------------------------------------------------------

function Module:Init()
	self:ConstructMapCoords()
end

E:AddModule("Worldmap", Module)