local E, L = unpack(CUI) -- Engine
local CD = E:LoadModules("Config_Dialog")

local Grid
-- Base by Akeru [http://www.wowinterface.com/downloads/info6153-Align.html]
function CD:ToggleMoveGrid(state, fast)
	if not Grid and not state then return end
	if Grid and not state then
		if not fast then
			E:UIFrameFadeOut(Grid, 0.2, 1, 0)
		else
			Grid:Hide()
		end
		--Grid = nil
		
		return
	else
		if Grid then
			if not fast then
				E:UIFrameFadeIn(Grid, 0.2, 0, 1)
			else
				Grid:Show()
			end
			
			return
		end
		Grid = CreateFrame('Frame', nil, E.Parent) 
		Grid:SetAllPoints(E.Parent)
		local w = GetScreenWidth() / 128
		local h = GetScreenHeight() / 72
		for i = 0, 128 do
			local tex = Grid:CreateTexture(nil, 'BACKGROUND')
			if i == 64 then
				tex:SetColorTexture(1, 1, 0, 0.5)
			else
				tex:SetColorTexture(1, 1, 1, 0.15)
			end
			tex:SetPoint('TOPLEFT', Grid, 'TOPLEFT', i * w - 1, 0)
			tex:SetPoint('BOTTOMRIGHT', Grid, 'BOTTOMLEFT', i * w + 1, 0)
		end
		for i = 0, 72 do
			local tex = Grid:CreateTexture(nil, 'BACKGROUND')
			if i == 36 then
				tex:SetColorTexture(1, 1, 0, 0.5)
			else
				tex:SetColorTexture(1, 1, 1, 0.15)
			end
			tex:SetPoint('TOPLEFT', Grid, 'TOPLEFT', 0, -i * h + 1)
			tex:SetPoint('BOTTOMRIGHT', Grid, 'TOPRIGHT', 0, -i * h - 1)
		end	
		
		-- Background to blend out the WorldFrame a bit
		local tex = Grid:CreateTexture(nil, 'BACKGROUND')
		tex:SetAllPoints(Grid)
		tex:SetColorTexture(0, 0, 0, 0.4)
	end
end