local E, L = unpack(CUI) -- Engine
local CO, CD, TT = E:LoadModules("Config", "Config_Dialog", "Tooltip")

local CurrentShownNotification

function CD:ShowNotification(type, ignoreCurrent)
	-- Reset popup points so we won't error out
	if StaticPopup_DisplayedFrames and #StaticPopup_DisplayedFrames > 0 then
		for idx, dialog in pairs(StaticPopup_DisplayedFrames) do
			dialog:ClearAllPoints()
			StaticPopup_SetUpAnchor(dialog, idx)
		end
	end
	
	-- Prevent this notification from being shown more than once
	if (not ignoreCurrent and CurrentShownNotification ~= type) or ignoreCurrent then
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
	
	-- General Note: By using "\n" in the Popup text, we can indirectly control the height!
	StaticPopupDialogs["DELETE_FILTER_ENTRY"] = {
	  text = L['Nofification_FilterDelete'],
	  button1 = OKAY,
	  button2 = CANCEL,
	  OnAccept = function() CD:FilterEntry_Delete(true); CurrentShownNotification = nil end,
	  OnCancel = function() CurrentShownNotification = nil end,
	  timeout = 0,
	  whileDead = true,
	  hideOnEscape = true,
	  preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
	}
	StaticPopupDialogs["FONT_TYPE_NOTIFICATION"] = {
	  text = "The modifications you made, may not apply to every font type or just after the tooltip has been shown a few times!",
	  button1 = OKAY,
	  OnAccept = function() CurrentShownNotification = nil end,
	  OnCancel = function() CurrentShownNotification = nil end,
	  timeout = 0,
	  whileDead = true,
	  hideOnEscape = true,
	  preferredIndex = 3,
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
	StaticPopupDialogs["RELOG_NOTIFICATION"] = {
	  text = L["Nofification_Relog"] or 'Requires a Relog',
	  button1 = CLOSE,
	  OnAccept = function() CurrentShownNotification = nil end,
	  timeout = 0,
	  whileDead = true,
	  hideOnEscape = true,
	  preferredIndex = 3,
	}

	local CharSetting_Title

	do
		if not CO.db.global.useGlobalCharacterDB then
			CharSetting_Title = L["Nofification_Charactersetting"]
		else
			CharSetting_Title = L["Nofification_Charactersetting_Global"]
		end
	end

	StaticPopupDialogs["CHARACTERSETTING_NOTIFICATION"] = {
	  text = CharSetting_Title,
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
	  text = "The frames are now movable. To lock them, click the button below.\n\n\n\n\n\n\n\n\n\n",
	  button1 = "Lock",
	  OnAccept = function() CD:DisableEditmode(); CurrentShownNotification = type end,
	  OnShow = function(self)
	
		-- This probably is the messiest code on Earth, but it gets the job done
	
		if not self.Tooltips then
			self.Tooltips = CreateFrame("CheckButton", "MoverTooltips", self, "UICheckButtonTemplate")
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
			self.StickyMovers = CreateFrame("CheckButton", "StickyMovers", self, "UICheckButtonTemplate")
			_G[self.StickyMovers:GetName() .. 'Text']:SetText("Sticky Movers")

			self.StickyMovers:SetSize(32, 32)
			self.StickyMovers:SetPoint("LEFT", self.Tooltips, "RIGHT", 135, 0)

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
			
			
			local Font = E.Media:Fetch("font", CO.db.profile.media.generalFont)
			self.StickyRange.Text = self.StickyRange:CreateFontString(nil)
				E:InitializeFontFrame(self.StickyRange.Text, "OVERLAY", Font, 11, {0.933, 0.886, 0.125}, 1, {0,0}, "", 0, 0, self.StickyRange, "CENTER", {1,1})
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
		if not self.ShowMoverDialog then
			self.ShowMoverDialog = CreateFrame("CheckButton", "CUIOptionsShowMoverDialog", self, "UICheckButtonTemplate")
			_G[self.ShowMoverDialog:GetName() .. 'Text']:SetText("Show Helper")
			
			self.ShowMoverDialog:SetSize(32, 32)
			self.ShowMoverDialog:SetPoint("TOPLEFT", self.Tooltips, "BOTTOMLEFT", 0, 0)
			
			self.ShowMoverDialog:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_LEFT", -15, 15)
				GameTooltip:AddLine("When enabled, you will be shown a helper frame when you mouseover a mover")
				GameTooltip:Show()
				
				TT:UpdateStyle(nil, nil, true)
			end)
			self.ShowMoverDialog:SetScript("OnLeave", function(self)
				GameTooltip:Hide()
			end)
			
			self.ShowMoverDialog:SetScript('OnClick', function(self)
				E.ShowMoverDialog = self:GetChecked()
			end)
			
			self.ShowMoverDialog:SetChecked(E.ShowMoverDialog)
		end
		if not self.MoverTypeSelection then
			local MoverTypes = {
				[1] = "All",
				[2] = "Actionbars",
				[3] = "Unitframes",
				[4] = "Misc",
			}
			
			local dropDown = CreateFrame("frame", "CUI_MoverSelection", self, "UIDropDownMenuTemplate")
			dropDown:SetPoint("TOPRIGHT", self.StickyRange, "BOTTOMRIGHT", 15, -10)
			UIDropDownMenu_SetWidth(dropDown, 150)
			UIDropDownMenu_SetText(dropDown, MoverTypes[1])
			
			local function ValueChanged(self)
				E.CurrentMoverFilter = self.value
				dropDown.indexSelected = self.menuList
				UIDropDownMenu_SetText(dropDown, MoverTypes[dropDown.indexSelected])
				
				E:FilterShownMovers()
			end
			
			-- Create and bind the initialization function to the dropdown menu
			UIDropDownMenu_Initialize(dropDown, function(self, level, menuList)
				local info = UIDropDownMenu_CreateInfo()
				if (level or 1) == 1 then
					-- Display the 0-9, 10-19, ... groups
					for i=1,4 do
						info.text, info.checked = MoverTypes[i], (dropDown.indexSelected and i == dropDown.indexSelected) or (not dropDown.indexSelected and i == 1)
						info.menuList, info.hasArrow = i, false
						
						info.func = ValueChanged
						UIDropDownMenu_AddButton(info)
					end
				end
			end)
			
			-- For entire clickable width
			-- local button = _G[dropdown:GetName() .. "Button"]
			-- self.button = button
			-- button.obj = self
			-- button:SetScript("OnEnter",Control_OnEnter)
			-- button:SetScript("OnLeave",Control_OnLeave)
			-- button:SetScript("OnClick",Dropdown_TogglePullout)

			-- local button_cover = CreateFrame("BUTTON",nil,self.frame)
			-- self.button_cover = button_cover
			-- button_cover.obj = self
			-- button_cover:SetPoint("TOPLEFT",self.frame,"BOTTOMLEFT",0,25)
			-- button_cover:SetPoint("BOTTOMRIGHT",self.frame,"BOTTOMRIGHT")
			-- button_cover:SetScript("OnEnter",Control_OnEnter)
			-- button_cover:SetScript("OnLeave",Control_OnLeave)
			-- button_cover:SetScript("OnClick",Dropdown_TogglePullout)

			
			local TextFont = E.Media:Fetch("font", CO.db.profile.media.generalFont)
			local Text = dropDown:CreateFontString(nil)
				E:InitializeFontFrame(Text, "OVERLAY", TextFont, 11, {0.933, 0.886, 0.125}, 1, {0,0}, "", 0, 0, dropDown, "CENTER", {1,1})
			Text:SetText("Filter")
			Text:ClearAllPoints()
			Text:SetPoint("RIGHT", dropDown, "LEFT", -10, 0)
			dropDown.DescText = Text
			
			self.MoverTypeSelection = dropDown
		end
		
		self.Tooltips:Show()
		self.StickyMovers:Show()
		self.StickyRange:Show()
		self.StickyRange.Text:Show()
		self.ShowMoverDialog:Show()
		self.MoverTypeSelection:Show()
	  end,
	  OnHide = function(self)
		self.Tooltips:Hide()
		self.StickyMovers:Hide()
		self.StickyRange:Hide()
		self.StickyRange.Text:Hide()
		self.ShowMoverDialog:Hide()
		self.MoverTypeSelection:Hide()
	  end,
	  timeout = 0,
	  whileDead = true,
	  hideOnEscape = false,
	  preferredIndex = 3,
	}
	StaticPopupDialogs["CLEAR_ACTIONBARS_NOTIFICATION"] = {
	  text = "You are about to empty ALL your actionbars ENTIRELY. Are you absolutely sure, you want to perform this action?",
	  button1 = "Yes",
	  button2 = CANCEL,
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
	  button2 = CANCEL,
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
	  OnAccept = function() E:LoadModule("Actionbars"):SetKeybinder(false); ACD:Open("CUI"); CurrentShownNotification = nil end,
	  timeout = 0,
	  whileDead = true,
	  hideOnEscape = false,
	  preferredIndex = 3,
	}
	StaticPopupDialogs["RESET_ANCHORS"] = {
	  text = "Are you sure you want to reset all anchors to their default position?",
	  button1 = "Reset Anchors",
	  button2 = CANCEL,
	  OnAccept = function() E:ResetMoverPositions(); CurrentShownNotification = nil; end,
	  OnCancel = function() CurrentShownNotification = nil end,
	  timeout = 0,
	  whileDead = true,
	  hideOnEscape = true,
	  preferredIndex = 3,
	}
	
-- When MOVING a popup, there's a possibility that the next one will trigger a chain of errors!
-- That's the root of all problems!

-- Overload Blizz function to basically fix it
-- @TODO: Check if this causes any issues in regards to taint
-- function StaticPopup_SetUpPosition(dialog)
	-- if ( not tContains(StaticPopup_DisplayedFrames, dialog) ) then
		-- -- Fixes issues with parenting loops
		-- dialog:ClearAllPoints()
		
		-- StaticPopup_SetUpAnchor(dialog, #StaticPopup_DisplayedFrames + 1);
		-- tinsert(StaticPopup_DisplayedFrames, dialog);
	-- end
-- end