local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, L, COMM = E:LoadModules("Config", "Locale", "Communication")

local RC = CreateFrame("Frame", "RaidControlFrame", E.Parent)
RC.Autoload = true
--------------------------------------------------------------------------------------------

local NeededButtons = {{"Readycheck", "Readycheck", "PerformReadyCheck"}, {"PullTimer", "Pull Timer", "PerformPullTimer"}, {"StopPull", "Stop Pull", "StopPull"}}

function RC:PerformReadyCheck()
	DoReadyCheck()
end

function RC:StopPull()
	local InGroup, InRaid = IsInGroup(), IsInRaid()
	RC:SendPullTimer(0, InGroup, InRaid)
end

function RC:PerformPullTimer()
	local Time = RC:GetPullTime()
	if Time ~= "" then
		Time = tonumber(Time)
		if Time > 0 then
			local InGroup, InRaid = IsInGroup(), IsInRaid()
			
			if InGroup or InRaid then
				RC:SendPullTimer(Time, InGroup, InRaid)
			else
				if Time < 15 then
					E:print(("A %d second Pulltimer now would have been sent to your group members."):format(Time))
				else
					if Time < 35 then
						E:print(("Really? Your want to send a %d second Pulltimer to your group? You really must hate them."):format(Time))
					else
						E:print(("A %d second Pulltimer officially makes you look like a sadist :c"):format(Time))
					end
				end
			end
		else
			E:print(L["Pull Time must be above 0 seconds!"])
		end
	end
end

function RC:SendPullTimer(Time, InGroup, InRaid)
	local Type, PlayerName = nil, UnitName("player")
	
	-- Check permission
	if InGroup or InRaid then
		local isAssist, isLeader
			isLeader = (UnitInParty("player") or UnitInRaid("player")) and UnitIsGroupLeader("player")
			isAssist = UnitInRaid("player") and UnitIsGroupAssistant("player") and not UnitIsGroupLeader("player")
		if not isLeader and not isAssist then
			if Time > 0 then
				E:print("Pull timer was not sent, since you are not authorized! (No Leader or Assist)")
			else
				E:print("Pull timer was not cancelled, since you are not authorized! (No Leader or Assist)")
			end
			
			return
		end
	end
	
	Type = COMM:GetGroupChannelType()
	
	local mapID = select(8, GetInstanceInfo())
	
	C_ChatInfo.SendAddonMessage("BigWigs", ("P^Pull^%d"):format(Time), Type, PlayerName)
	C_ChatInfo.SendAddonMessage("D4", ("PT\t%d\t%d"):format(Time, tonumber(mapID) or -1), Type, PlayerName)
	RC.Buttons["PullTimer"].EditBox:ClearFocus()
	
	if Time > 0 then
		E:print(L["Sending Pulltimer to BigWigs and DBM Users"] .. (" -- Duration: %d"):format(Time))
	else
		E:print("Pulltimer cancelled")
	end
end

function RC:TogglePanel()
	if not self.State then
		self.State = true
		self:Show()
	else
		self.State = false
		self:OnEvent()
	end
end

function RC:LoadProfile()
	self.db = CO.db.profile.dataframes.raidControl
	
	if self.db.enable then
		
		self:SetScale(self.db.scale)
		
		self:RegisterEvent("GROUP_ROSTER_UPDATE", self.OnEvent)
		
		if not self.State then
			self:OnEvent() -- Force update
		end
	else
		self:UnregisterAllEvents()
		self:Hide()
	end
end

function RC:StyleButton(Button, Width, Height, GenerateFont, StripTextures, OverrideNormal, OverrideHighlight, OverridePushed)

	Button:SetWidth(Width or 125)
	Button:SetHeight(Height or 20)
	
	if GenerateFont and not Button.Font then
		Button.Font = Button:CreateFontString(nil)
		E:InitializeFontFrame(Button.Font, "OVERLAY", "FRIZQT__.TTF", 11, {0.933, 0.886, 0.125}, 1, {0,0}, "", 0, 0, Button, "CENTER", {1,1})
	end
	
	-- if not Button.Border then
		-- Button.Border = E:CreateBorder(Button)
		-- Button.Border:SetBackdropBorderColor(0, 0, 0, 1)
		
		-- Button:SetScript('OnEnter', function(self) self.Border:SetBackdropBorderColor(0.35, 0.35, 0.35, 1) end)
		-- Button:SetScript('OnLeave', function(self) self.Border:SetBackdropBorderColor(0, 0, 0, 1) end)
	-- end
	if StripTextures then
		Button.TopLeft:SetAlpha(0)
		Button.TopRight:SetAlpha(0)
		Button.BottomLeft:SetAlpha(0)
		Button.BottomRight:SetAlpha(0)
		Button.TopMiddle:SetAlpha(0)
		Button.BottomMiddle:SetAlpha(0)
		Button.MiddleLeft:SetAlpha(0)
		Button.MiddleMiddle:SetAlpha(0)
		Button.MiddleRight:SetAlpha(0)
		
		Button:SetHighlightTexture("")
		Button:SetDisabledTexture("")
	end
	
	if OverrideNormal then
		Button:SetNormalTexture([[Interface\Buttons\WHITE8X8]])
		Button:GetNormalTexture():SetVertexColor(0.15, 0.15, 0.15, 0.6)
	end
	
	if OverrideHighlight then
		Button:SetHighlightTexture([[Interface\Buttons\WHITE8X8]])
		Button:GetHighlightTexture():SetVertexColor(0.16, 0.16, 0.16, 0.65)
	end
	
	if OverridePushed then
		Button:SetPushedTexture([[Interface\Buttons\WHITE8X8]])
		Button:GetPushedTexture():SetVertexColor(0.07, 0.07, 0.07, 0.75)
	end
end

function RC:AddClosedButton()
	self.Buttons["Open"] = CreateFrame("Button", nil, self.ClosedPanel, "UIPanelButtonTemplate")
	self.Buttons["Open"]:SetPoint("BOTTOM", self.ClosedPanel, "BOTTOM", 0, -16)
	self.Buttons["Open"]:SetParent(self.ClosedPanel)
	--self.Buttons["Open"]:SetFrameRef("Panel", self.Panel)
	
	
	self:StyleButton(self.Buttons["Open"], 125, 25, true)
	self.Buttons["Open"].Font:SetText("Show")
	
	self.Buttons["Open"]:SetScript("OnClick", function(self)
		RC.Panel:Show()
		self:GetParent():Hide()
	end)
	
	--self.Buttons["Open"]:GetNormalTexture():SetVertexColor(0.15, 0.15, 0.15, 1)
	--self.Buttons["Open"]:GetHighlightTexture():SetVertexColor(0.16, 0.16, 0.16, 1)
	--self.Buttons["Open"]:GetPushedTexture():SetVertexColor(0.07, 0.07, 0.07, 1)
end

function RC:AddPanelCloseButton()
	self.Buttons["CloseOpen"] = CreateFrame("Button", nil, self.Panel, "UIPanelButtonTemplate")
	self.Buttons["CloseOpen"]:SetPoint("BOTTOM", self.Panel, "BOTTOM", 0, -16)
	self.Buttons["CloseOpen"]:SetParent(self.Panel)
	--self.Buttons["CloseOpen"]:SetFrameRef("Panel", self.ClosedPanel)
	
	
	self:StyleButton(self.Buttons["CloseOpen"], 125, 25, true)
	self.Buttons["CloseOpen"].Font:SetText("Hide")
	
	self.Buttons["CloseOpen"]:SetScript("OnClick", function(self)
		RC.ClosedPanel:Show()
		self:GetParent():Hide()
	end)
	
	--self.Buttons["CloseOpen"]:GetNormalTexture():SetVertexColor(0.15, 0.15, 0.15, 1)
	--self.Buttons["CloseOpen"]:GetHighlightTexture():SetVertexColor(0.16, 0.16, 0.16, 1)
	--self.Buttons["CloseOpen"]:GetPushedTexture():SetVertexColor(0.07, 0.07, 0.07, 1)
end

function RC:AddButtons()	
	local index = 1
	local prevButton = self.Panel
	
	for _, data in pairs(NeededButtons) do
		self.Buttons[data[1]] = CreateFrame("Button", nil, self.Panel, "UIPanelButtonTemplate")
		self.Buttons[data[1]]:SetPoint("TOP", prevButton, "TOP", 0, ((20 * (index - 1) + 7) * (-1)))
		self.Buttons[data[1]]:SetParent(self.Panel)
		
		self.Buttons[data[1]]:SetScript("OnClick", RC[data[3]])
		
		self:StyleButton(self.Buttons[data[1]], 125, 20, true)
		self.Buttons[data[1]].Font:SetText(data[2])
		
		----------------------------------------
		index = index + 1
		prevButton = self.Buttons[data[1]]
	end
	
	local MarkerBtn = CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton
	
	MarkerBtn:ClearAllPoints()
	MarkerBtn:SetPoint("BOTTOM", self.Panel, "BOTTOM", 0, 15)
	MarkerBtn:SetParent(self.Panel)
	
	self:StyleButton(MarkerBtn, 100, 20, true)
	MarkerBtn.Icon:ClearAllPoints()
	MarkerBtn.Icon:SetPoint("CENTER", MarkerBtn, "CENTER")
	MarkerBtn.Icon:SetSize(15, 15)
	--MarkerBtn.CUIIcon:SetTexture("Interface\\RaidFrame\\Raid-WorldPing")

	-------
	-- Reposition Pull Button
		self.Buttons["PullTimer"]:SetWidth(100)
		E:PushFrame(self.Buttons["PullTimer"], 12, 0)

		-- Add time input
		self.Buttons["PullTimer"].EditBox = CreateFrame("EditBox", nil, self.Buttons["PullTimer"], "InputBoxTemplate")
		self.Buttons["PullTimer"].EditBox:SetSize(21, 20)
		self.Buttons["PullTimer"].EditBox:SetPoint("RIGHT", self.Buttons["PullTimer"], "LEFT", -2, 0)
		self.Buttons["PullTimer"].EditBox:SetAutoFocus(false)
		self.Buttons["PullTimer"].EditBox:SetText(CO.db.profile.utility.pullTimer)
		self.Buttons["PullTimer"].EditBox:SetScript("OnChar", function(self, input)
			local Text = tonumber(self:GetText()) or 10
			if Text > 60 then Text = 60 end
			
			CO.db.profile.utility.pullTimer = Text
			self:SetText(Text)
		end)
		self.Buttons["PullTimer"].EditBox:SetScript("OnKeyDown", function(self, key)
			if key == "ENTER" then
				-- Cancel input and remove focus
				self:ClearFocus()
				
				if RC.db.pullOnEnter then
					RC:PerformPullTimer()
				end
			end
		end)
		
		E:MoveFrame(self.Buttons.StopPull, -12, -25)

		--self.Buttons["PullTimer"].EditBox.Left:SetAlpha(0)
		--self.Buttons["PullTimer"].EditBox.Middle:SetAlpha(0)
		--self.Buttons["PullTimer"].EditBox.Right:SetAlpha(0)
		
		--self.Buttons["PullTimer"].EditBox.Background = E:CreateBackground(self.Buttons["PullTimer"].EditBox)
		--self.Buttons["PullTimer"].EditBox.Border = E:CreateBorder(self.Buttons["PullTimer"].EditBox)
		
		--self.Buttons["PullTimer"].EditBox:SetBackdrop(nil)
		
end

function RC:GetPullTime()
	return self.Buttons["PullTimer"].EditBox:GetText()
end

function RC:OnEvent(event, ...)
	if IsInGroup() or IsInRaid() then
		self:Show()
	else
		self:Hide()
	end
end

function RC:Construct()
	
	
	-- Catch BigWigs and DBM Messages with this
	-- local Frame = CreateFrame("Frame")
	-- Frame:RegisterEvent("CHAT_MSG_ADDON")
	-- Frame:SetScript("OnEvent", print)
	
	self.Buttons = {}
	
	self:SetSize(175, 135)
	self:SetPoint("CENTER", E.Parent, "CENTER")
	self:SetFrameStrata("MEDIUM")
	
	self.ClosedPanel = CreateFrame("Frame", "RaidControlFramePanelClosed", self, "InsetFrameTemplate")
	--self.ClosedPanel:SetSize(175, 50)
	self.ClosedPanel:SetHeight(25)
	self.ClosedPanel:SetPoint("TOPLEFT", self, "TOPLEFT")
	self.ClosedPanel:SetPoint("TOPRIGHT", self, "TOPRIGHT")
	
	--self.ClosedPanel.Background = E:CreateBackground(self.ClosedPanel)
	--self.ClosedPanel.Border 	= E:CreateBorder(self.ClosedPanel)
	
	-------------------------------------------------------
	
	self.Panel = CreateFrame("Frame", "RaidControlFramePanel", self, "InsetFrameTemplate")
	self.Panel:SetAllPoints(self)
	
	--self.Panel.Background 		= E:CreateBackground(self.Panel)
	--self.Panel.Border 			= E:CreateBorder(self.Panel)
	
	self.Panel:Hide()
	
	self:AddButtons()
	self:AddClosedButton()
	self:AddPanelCloseButton()
	
	self:SetScript("OnEvent", self.OnEvent)
	self:OnEvent()
	
	E:CreateMover(self, "RaidControl", nil, nil, nil, "A panel that holds various functionality to administrate a raid.")
	
	-- Make movable without config mode
	--E:SetMoverDraggable(self, true)
end


function RC:Init()
	self:Construct()
	
	self:LoadProfile()
end
-- CUI:GetModule("RaidControl"):Hide()
E:AddModule("RaidControl", RC)