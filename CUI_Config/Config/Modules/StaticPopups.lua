local E, L = unpack(CUI) -- Engine
local CD, L, TT = E:LoadModules("Config_Dialog", "Locale", "Tooltip")

local CurrentShownNotification

function CD:ShowNotification(type)
	-- Prevent this notification from being shown more than once
	if CurrentShownNotification ~= type then
		StaticPopup_Show(type)
		CurrentShownNotification = type
	end
end

function CD:HideNotification(type)
	if CurrentShownNotification == type then
		StaticPopup_Hide(type)
		CurrentShownNotification = nil
	end
end
	
	-- General Note: By using "\n" in the Popup text, we can control the height!

	StaticPopupDialogs["FONT_TYPE_NOTIFICATION"] = {
	  text = "The modifications you made, may not apply to every font type or just after the tooltip has been shown a few times!",
	  button1 = "OK",
	  OnAccept = function() CurrentShownNotification = nil end,
	  OnCancel = function() CurrentShownNotification = nil end,
	  timeout = 0,
	  whileDead = true,
	  hideOnEscape = true,
	  preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
	}
	StaticPopupDialogs["RELOAD_NOTIFICATION"] = {
	  text = L["Nofification_Reload"],
	  button1 = L["Reload"],
	  button2 = L["Later"],
	  OnAccept = function() ReloadUI(); CurrentShownNotification = nil end,
	  OnCancel = function() CurrentShownNotification = nil end,
	  timeout = 0,
	  whileDead = true,
	  hideOnEscape = true,
	  preferredIndex = 3,
	}
	StaticPopupDialogs["HANDLE_MOVE_NOTIFICATION"] = {
	  text = "The frames are now movable. To lock them, click the button below.\n\n\n\n\n\n",
	  button1 = "Lock",
	  OnAccept = function() CD:OpenOptions(); CD:ToggleMoveGrid(false); E:ToggleMover(false); CurrentShownNotification = type end,
	  OnShow = function(self)
		if not self.Tooltips then
			self.Tooltips = CreateFrame("CheckButton", "MoverTooltips", self, "OptionsCheckButtonTemplate")
			_G[self.Tooltips:GetName() .. 'Text']:SetText("Mover Tooltips")
			
			self.Tooltips:SetSize(32, 32)
			self.Tooltips:SetPoint("TOPLEFT", self, "TOPLEFT", 10, -50)
			
			E.ShowMoverTooltips = 1

			self.Tooltips:SetScript('OnClick', function(self)
				E.ShowMoverTooltips = self:GetChecked()
			end)
			
			self.Tooltips:SetChecked(E.ShowMoverTooltips)
		end
		if not self.StickyMovers then
			self.StickyMovers = CreateFrame("CheckButton", "StickyMovers", self, "OptionsCheckButtonTemplate")
			_G[self.StickyMovers:GetName() .. 'Text']:SetText("Sticky Movers")
			
			self.StickyMovers:SetSize(32, 32)
			self.StickyMovers:SetPoint("LEFT", self.Tooltips, "RIGHT", 135, 0)
			
			E.StickyMovers = 1

			self.StickyMovers:SetScript('OnClick', function(self)
				E.StickyMovers = self:GetChecked()
			end)
			
			self.StickyMovers:SetChecked(E.StickyMovers)
		end
		if not self.StickyRange then
			self.StickyRange = CreateFrame("EditBox", nil, self, "InputBoxTemplate")
			self.StickyRange:SetSize(30, 20)
			self.StickyRange:SetPoint("TOP", self, "TOP", 115, -90)
			self.StickyRange:SetAutoFocus(false)
			self.StickyRange:SetText(1)
			self.StickyRange:SetScript("OnChar", function(self)
				local Text = tonumber(self:GetText()) or 1
				if Text > 100 then Text = 1 end
				
				E.StickyRange = Text
				self:SetText(Text)
			end)
			
			self.StickyRange.Text = self.StickyRange:CreateFontString(nil)
				E:InitializeFontFrame(self.StickyRange.Text, "OVERLAY", "FRIZQT__.TTF", 11, {0.933, 0.886, 0.125}, 1, {0,0}, "", 0, 0, self.StickyRange, "CENTER", {1,1})
			self.StickyRange.Text:SetText("Sticky Range")
			self.StickyRange.Text:ClearAllPoints()
			self.StickyRange.Text:SetPoint("RIGHT", self.StickyRange, "LEFT", -10, 0)
			
			self.StickyRange:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_LEFT", -15, 15)
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine("The range in px that is used for the sticky attachment.\nCan be negative to set it to the outer instead of inner of the frames.\n\nDefault: 1")
				GameTooltip:Show()
				
				TT:UpdateStyle(nil, nil, true)
			end)
			self.StickyRange:SetScript("OnLeave", function(self)
				GameTooltip:Hide()
			end)
			
			E.StickyRange = tonumber(self.StickyRange:GetText()) or 1
		end
		
		self.Tooltips:Show()
		self.StickyMovers:Show()
		self.StickyRange:Show()
		self.StickyRange.Text:Show()
	  end,
	  OnHide = function(self)
		self.Tooltips:Hide()
		self.StickyMovers:Hide()
		self.StickyRange:Hide()
		self.StickyRange.Text:Hide()
	  end,
	  timeout = 0,
	  whileDead = true,
	  hideOnEscape = false,
	  preferredIndex = 10,
	}
	StaticPopupDialogs["CLEAR_ACTIONBARS_NOTIFICATION"] = {
	  text = "You are about to empty ALL your actionbars ENTIRELY. Are you absolutely sure, you want to perform this action?",
	  button1 = "Yes",
	  button2 = "Cancel",
	  OnAccept = function() CurrentShownNotification = nil CD:ShowNotification("CLEAR_ACTIONBARS_NOTIFICATION2"); end,
	  OnCancel = function() CurrentShownNotification = nil end,
	  timeout = 15,
	  whileDead = true,
	  hideOnEscape = true,
	  preferredIndex = 3,
	}
	StaticPopupDialogs["CLEAR_ACTIONBARS_NOTIFICATION2"] = {
	  text = "This action cannot be reversed. Are you sure?",
	  button1 = "Clear all Bars",
	  button2 = "Cancel",
	  OnAccept = function() for i = 1,120 do PickupAction(i) ClearCursor() end; CurrentShownNotification = nil end,
	  OnCancel = function() CurrentShownNotification = nil end,
	  timeout = 5,
	  whileDead = true,
	  hideOnEscape = true,
	  preferredIndex = 3,
	}
	StaticPopupDialogs["KEYREBIND_ACTIVE"] = {
	  text = "Key rebind enabled. You can now hover actionslots and press desired keys to assign. Press ESC to remove the current bind from the slot.",
	  button1 = "Lock",
	  OnAccept = function() E:GetModule("Actionbars"):SetKeybinder(false); ACD:Open("CUI"); CurrentShownNotification = nil end,
	  timeout = 0,
	  whileDead = true,
	  hideOnEscape = false,
	  preferredIndex = 10,
	}
	StaticPopupDialogs["RESET_ANCHORS"] = {
	  text = "Are you sure you want to reset all anchors to their default position?",
	  button1 = "Reset Anchors",
	  button2 = "Cancel",
	  OnAccept = function() E:ResetMoverPositions(); CurrentShownNotification = nil; end,
	  OnCancel = function() CurrentShownNotification = nil end,
	  timeout = 0,
	  whileDead = true,
	  hideOnEscape = true,
	  preferredIndex = 10,
	}