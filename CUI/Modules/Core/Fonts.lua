local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO = E:LoadModules("Config")

--[[----------------------------------------------------

	This CUI Library provides a powerful toolset
	that is designed to update registered fonts
	through a database path.
	
	You may use this Code in your own projects,
	as long as there is at least any credit given.
	
	Author: Ferodra / Arenima
	
----------------------------------------------------]]--

---------------------------------------------------
local pairs 					= pairs
local tinsert					= table.insert
local wipe						= wipe
---------------------------------------------------

E.PathFonts = {}

-- Exclusion Format:
-- {type = funcRef or boolean}
function E:RegisterPathFont(Object, Path, Exclusions)
	if not self.PathFonts[Path] then
		self.PathFonts[Path] = {}
	end
	if not Object.Exclusions then
		Object.Exclusions = {}
	end
	if Exclusions then
		for k,v in pairs(Exclusions) do
			Object.Exclusions[k] = v
		end
	end
	
	tinsert(self.PathFonts[Path], Object)
end

function E:UnregisterPathFont(Path)
	if self.PathFonts[Path] then
		wipe(self.PathFonts[Path])
	end
end

-- Path[String] targets a specific font
function E:UpdatePathFont(Path)
	
	local DBTarget =  self:GetTablePath(Path, CO)
	
	if not DBTarget then
		DBTarget = E:TableDeepCopy(CO.Template_Font)
	end
	
	if not DBTarget then error("Database Font Path does not exist\nPath: CO." .. Path); return; end
	
	if not self.PathFonts[Path] then return end
	for k, font in pairs(self.PathFonts[Path]) do
		if not DBTarget.enable then if not font.Exclusions["enable"] then font:Hide() end	else
		
		-- Font Shadow
			if DBTarget.fontShadowColor and not font.Exclusions["fontShadowColor"] then
				font:SetShadowColor(DBTarget.fontShadowColor[1], DBTarget.fontShadowColor[2], DBTarget.fontShadowColor[3], DBTarget.fontShadowColor[4] or 1)
				font:SetShadowOffset(DBTarget.xFontShadowOffset, DBTarget.yFontShadowOffset)
			end
		-- Alignment
			if DBTarget.horizontalAlign and not font.Exclusions["fontShadowColor"] then
				font:SetJustifyH(DBTarget.horizontalAlign)
			end
			
		-- Repositioning
			if not font.Exclusions["position"] then
				font:ClearAllPoints()
				
				if DBTarget.positionOuter then
					font:SetPoint(E:InversePosition(DBTarget.position), font:GetParent() or E.Parent, DBTarget.position, DBTarget.xOffset, DBTarget.yOffset)
				else
					font:SetPoint(DBTarget.position, font:GetParent() or E.Parent, DBTarget.position, DBTarget.xOffset, DBTarget.yOffset)
				end
				--font:SetPoint(DBTarget.position)
				--self:MoveFrame(font, DBTarget.xOffset, DBTarget.yOffset)
			end
		
		-- Level hide
			if DBTarget.doNotShowOnMaxLevel then
				font.ShowAtMax = DBTarget.doNotShowOnMaxLevel
			end
		-- Font Color
			if DBTarget.fontColor and not font.Exclusions["fontColor"] then
				font:SetTextColor(DBTarget.fontColor[1], DBTarget.fontColor[2], DBTarget.fontColor[3], DBTarget.fontColor[4] or 1)
			end
		-- Width
			if DBTarget.width and not font.Exclusions["width"] then
				font:SetWidth(DBTarget.width)
			end
		
		-- Flags
			if not font.Exclusions["general"] then
				if DBTarget.fontFlags == "None" then font.Flags = self.TBL.EMPTY else font.Flags = DBTarget.fontFlags end
				
			-- General
				-- (Frame, fontName, fontFlags, fontHeight, fontColor)
				self:SetFontInfo(font, E.Media:Fetch("font", DBTarget.fontType), font.Flags, DBTarget.fontHeight, nil)
				self:UpdateFont(font)
				font:SetDrawLayer("OVERLAY")
			end
			
			if not font.Exclusions["enable"] then
				if font:GetText() == RANGE_INDICATOR then font:Hide() else font:Show() end
			end
		end
		
		--if #font.Exclusions > 0 then
		--E:print_r(font.Exclusions)
		--end
		--print(GetTime())
		
		--E:print_r(font.Exclusions)
		
		-- Call overridden functions
		if font.Exclusions then
			for k, v in pairs(font.Exclusions) do
				if type(v) == "function" then
					v()
				end
			end
		end
	end
end

function E:UpdateAllFonts()
	for path, group in pairs(self.PathFonts) do
		self:UpdatePathFont(path)
	end
end