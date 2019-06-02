local E, L = unpack(CUI) -- Engine
local CD, L = E:LoadModules("Config_Dialog", "Locale")

function CD:ToggleFrameChooser(Path)
	
	if not self.FrameChooser.Initialized then
		
		self.FrameChooser.UpdateTimer = 0
		
		self.FrameChooser.Selection = CreateFrame("Frame", nil, self.FrameChooser)
		self.FrameChooser.Selection:SetFrameStrata("TOOLTIP")
		self.FrameChooser.Selection:SetBackdrop({
		  edgeFile = [[Interface\Buttons\WHITE8X8]],
		  edgeSize = 1.25,
		  insets = {left = 0, right = 0, top = 0, bottom = 0}
		})
		self.FrameChooser.Selection:SetBackdropBorderColor(0.35, 0.35, 1)
		self.FrameChooser.Selection:Hide()
		
		self.FrameChooser.InfoText = self.FrameChooser:CreateFontString(nil)
		E:InitializeFontFrame(self.FrameChooser.InfoText, "OVERLAY", "FRIZQT__.TTF", 13, {0.933, 0.886, 0.125}, 0.9, {0,0}, "", 0, 0, E.Parent, "CENTER", {1,1})
		
		self.FrameChooser.InfoText:SetText(CD:GetClickIcon("|cFF00FFFF" .. L["FrameChooser1"] .. "|r\n\n{Atlas|NPE_LeftClick:25} " .. L["FrameChooser2"] .. "\n{Atlas|NPE_RightClick:25} " .. L["FrameChooser3"]))
		
		self.FrameChooser.Initialized = true
	end
	
	if not self.FrameChooser.State then
		if not Path then return end
		
		self.FrameChooser.State = true
		
		self.FrameChooser:Show()
		self:CloseOptions()
		
		self.FrameChooser:SetScript("OnUpdate", function(self, elapsed)
			
			if(IsMouseButtonDown("RightButton")) then
				CD:ToggleFrameChooser()
			elseif(IsMouseButtonDown("LeftButton") and self.CurrentValidFocus) then
				Path[1] = self.CurrentValidFocus
				CD:ToggleFrameChooser()
			else
			
				self.UpdateTimer = self.UpdateTimer + elapsed
				if self.UpdateTimer >= 0.1 then
					self.CurrentFocus = GetMouseFocus()
					if self.CurrentFocus then
						self.CurrentFocusName = self.CurrentFocus:GetName()
						
						if self.CurrentFocusName and self.CurrentFocusName ~= "WorldFrame" then
						
							self.Selection:ClearAllPoints()
							self.Selection:SetAllPoints(self.CurrentFocus)
							self.Selection:SetScale(1.25)
							
							self.CurrentValidFocus = self.CurrentFocusName
						
							self.Selection:Show()
							
							return
						end
					end
					
					self.Selection:Hide()
					self.CurrentValidFocus = nil
				end
			end
		end)
	else
		self.FrameChooser.State = false
		
		self.FrameChooser:Hide()
		CD:OpenOptions()
		
		self.FrameChooser:SetScript("OnUpdate", nil)
	end
end

-- Taken directly from the Blizz UI Source Code
function CD:GetClickIcon(str)
	-- Atlas icons e.g. {Atlas|NPE_RightClick:16}
	str = string.gsub(str, "{Atlas|([%w_]+):?(%d*)}", function(atlasName, size)
				size = tonumber(size) or 0;

				local filename, width, height, txLeft, txRight, txTop, txBottom = GetAtlasInfo(atlasName);

				if (not filename) then return; end

				local atlasWidth = width / (txRight - txLeft);
				local atlasHeight = height / (txBottom - txTop);

				local pxLeft	= atlasWidth	* txLeft;
				local pxRight	= atlasWidth	* txRight;
				local pxTop		= atlasHeight	* txTop;
				local pxBottom	= atlasHeight	* txBottom;

				return string.format("|T%s:%d:%d:0:0:%d:%d:%d:%d:%d:%d|t", filename, size, size, atlasWidth, atlasHeight, pxLeft, pxRight, pxTop, pxBottom);
			end);

	return str;
end