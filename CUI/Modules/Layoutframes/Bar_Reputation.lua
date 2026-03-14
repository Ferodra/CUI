local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF, TT, Module = E:LoadModules("Config", "Unitframes", "Tooltip", "Bar_Reputation")

local _
local LEVEL						= LEVEL
local format					= string.format
local GetWatchedFactionData		= C_Reputation.GetWatchedFactionData
local GetFriendshipReputation	= C_GossipInfo.GetFriendshipReputation
local IsFactionParagon			= C_Reputation.IsFactionParagon
local IsMajorFaction			= C_Reputation.IsMajorFaction
local GetFactionParagonInfo		= C_Reputation.GetFactionParagonInfo
local GetMajorFactionData		= C_MajorFactions.GetMajorFactionData

-- C_Reputation.IsFactionParagon(2699)

local Texture = [[Interface\AddOns\CUI\Textures\statusbar\layoutBarBottom]]
local TextureFlipped = [[Interface\AddOns\CUI\Textures\statusbar\layoutBarBottomFlipped]]
local TextureReversed = [[Interface\AddOns\CUI\Textures\statusbar\layoutBarBottomReversed]]
local TextureReversedFlipped = [[Interface\AddOns\CUI\Textures\statusbar\layoutBarBottomReversedFlipped]]

Module.UpdateData = {}

function Module:LoadConfig()
	self = Module
	if not self.db.enable then self.Bar:Hide(); self:UnregisterEvent("PLAYER_ENTERING_WORLD"); self:UnregisterEvent("UPDATE_FACTION") return else
	
		self.Bar.Overlay:SetAttribute("ReceivesGlobalTexture", false)
		self.Bar.Border:Hide()
		
		self.Bar.Overlay:SetReverseFill(false)
		self.Bar.Overlay:SetOrientation("HORIZONTAL")
		
		if self.db.style ~= "normal" then
			self.Bar.Background.Tex:SetVertexColor(unpack(self.db.backgroundColor))
		end
		if self.db.style == "integrated" then
			self.Bar.Overlay:SetStatusBarTexture(TextureReversed)
			self.Bar.Background.Tex:SetTexture(TextureReversed)
		elseif self.db.style == "integratedReversed" then
			self.Bar.Overlay:SetStatusBarTexture(Texture)
			self.Bar.Background.Tex:SetTexture(Texture)
		elseif self.db.style == "integratedReversedFlipped" then
			self.Bar.Overlay:SetStatusBarTexture(TextureReversed)
			self.Bar.Background.Tex:SetTexture(TextureReversed)
		elseif self.db.style == "integratedFlipped" then
			self.Bar.Overlay:SetStatusBarTexture(TextureReversedFlipped)
			self.Bar.Background.Tex:SetTexture(TextureReversedFlipped)
		else
			-- Normal bar
			self.Bar.Overlay:SetAttribute("ReceivesGlobalTexture", true)
			self.Bar.Overlay:SetStatusBarTexture(E.Media:Fetch("statusbar", CO.db.profile.unitframe.units["all"]['barTexture']))
			self.Bar.Background.Tex:SetTexture(nil)
			
			self.Bar.Overlay:SetReverseFill(self.db.reverseFill)
			self.Bar.Overlay:SetOrientation(self.db.fillOrientation)
			
			self.Bar:SetBorderSize(self.db.borderSize)
			self.Bar:SetBackgroundColor(unpack(self.db.backgroundColor))
			self.Bar:SetBorderColor(unpack(self.db.borderColor))
			self.Bar.Border:Show()
		end
		
		self.Bar:SetSize(self.db.width, self.db.height)
		
		self.Bar:ClearAllPoints()
		self.Bar:SetPoint(self.db.position, E.Parent, self.db.position, self.db.offsetX, self.db.offsetY)
		
		self:RegisterEvent("PLAYER_ENTERING_WORLD")
		self:RegisterEvent("UPDATE_FACTION")
		
		-- Validate if the bar should be shown
		self:ForceUpdate()
	end
end

local UpdateData
function Module:UpdateFactionData()

	UpdateData = GetWatchedFactionData()
	if not UpdateData or UpdateData.factionID == 0 then 
		self.isFactionWatched = false
		self.Bar:Hide()
		
		return
	end
	
	local name, reaction, currentReactionThreshold, nextReactionThreshold, currentStanding, factionID = UpdateData.name, UpdateData.reaction, UpdateData.currentReactionThreshold, UpdateData.nextReactionThreshold, UpdateData.currentStanding, UpdateData.factionID
	
	self.isFactionWatched = true
	
	if reaction == 0 then
		reaction = 1
	end
	
	local friendshipInfo = GetFriendshipReputation(factionID)
	local friendshipFactionID
	if friendshipInfo then
		standing, currentReactionThreshold, nextReactionThreshold, currentStanding = friendshipInfo.reaction, friendshipInfo.reactionThreshold or 0, friendshipInfo.nextThreshold or math.huge, friendshipInfo.standing or 1
		friendshipFactionID = friendshipInfo.friendshipFactionID
	end
	
	local IsParagon, IsMajor = IsFactionParagon(factionID), IsMajorFaction(factionID)
	
	local level
	local minBar, maxBar, value = UpdateData.currentReactionThreshold, UpdateData.nextReactionThreshold, UpdateData.currentStanding;
	if IsMajor then
		local majorFactionData = GetMajorFactionData(factionID);
		minBar, maxBar = 0, majorFactionData.renownLevelThreshold;
		level = majorFactionData.renownLevel;
	elseif IsParagon then
		local currentValue, threshold, _, hasRewardPending = GetFactionParagonInfo(factionID);
		minBar, maxBar  = 0, threshold;
		value = currentValue % threshold;
		level = maxLevel;
		if hasRewardPending then
			value = value + threshold;
		end
	elseif friendshipInfo and friendshipFactionID > 0 then
		local repRankInfo = C_GossipInfo.GetFriendshipReputationRanks(factionID);
		level = repRankInfo.currentLevel;
		if friendshipInfo.nextThreshold then
			minBar, maxBar, value = friendshipInfo.reactionThreshold, friendshipInfo.nextThreshold, friendshipInfo.standing;
		else
			-- max rank, make it look like a full bar
			minBar, maxBar, value = 0, 1, 1;
		end
	else
		level = UpdateData.reaction
	end
	
	-- Normalize values
	maxBar = maxBar - minBar;
	value = value - minBar;
	if isCapped and maxBar == 0 then
		maxBar = 1;
		value = 1;
	end
	minBar = 0;
	
	self.UpdateData.Name 			= name
	self.UpdateData.MinValue 		= minBar
	self.UpdateData.MaxValue 		= maxBar
	self.UpdateData.CurrentValue 	= value
	self.UpdateData.Level 			= level
	
	self:UpdateColor()
	self:UpdateValue()
end

function Module:UpdateValue()
	if not self.isFactionWatched then return end
	
	if self.UpdateData.Name then
		
		self.Bar:SetMinMaxValues(self.UpdateData.MinValue, self.UpdateData.MaxValue)
		self.Bar:SetValue(self.UpdateData.CurrentValue)
		
		self.Bar.Font:SetText(string.format("%s: %s / %s (%s %%)", self.UpdateData.Name, E:readableNumber(self.UpdateData.CurrentValue, 2), E:readableNumber(self.UpdateData.MaxValue, 2), (E:Round(self.UpdateData.CurrentValue / self.UpdateData.MaxValue, 2) * 100)))
		
		self.Bar:Show()
	else
		self.Bar:Hide()
	end
end

function Module:UpdateColor()
	if not self.isFactionWatched then return end
	
	if self.UpdateData.IsHostile then
		self.Bar:SetOverlayColor(unpack(CO.db.profile.colors.reactions.hostile))
		--self.Bar.Border.UpdateBorderColor(0.6, 0.1, 0.1, 0.5)
	else
		local Col = E:ParseDBColor(CO.db.profile.colors.layoutBars.barReputation)
		self.Bar:SetOverlayColor(Col[1], Col[2], Col[3], Col[4])
		--self.Bar:SetOverlayColor(0.7, 0.7, 0.7, 1)
		--self.Bar.Border.UpdateBorderColor(0.1, 0.1, 0.1, 0.9)
	end
end

function Module:ForceUpdate()
	self:OnEvent()
end

function Module:OnEvent(event, ...)
	self:UpdateFactionData()
end

function Module:__Construct()
	self.Bar = E:CreateBar("CUI_ReputationBar", "MEDIUM", 256, 32, nil, nil, true, false, false)
	E:HandleFrameInPetBattles(self.Bar)

	self.Bar.Button = CreateFrame("Button", "CUI_ReputationBarButton", self.Bar.Overlay)
	self.Bar.Button:SetAllPoints(self.Bar.Overlay)
	
	self.Bar.Button:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
		
		GameTooltip:AddLine(Module.UpdateData.Name)
		GameTooltip:AddLine(format("%s: %s", LEVEL, Module.UpdateData.Level))
		GameTooltip:AddLine(format("%s / %s", Module.UpdateData.CurrentValue, Module.UpdateData.MaxValue))
		
		TT:UpdateStyle(nil)
		
		GameTooltip:Show()
	end)
	self.Bar.Button:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	
	-------------------------------------------------
		self.Bar.Font = self.Bar:CreateFontString(nil)
			E:InitializeFontFrame(self.Bar.Font, "OVERLAY", "FRIZQT__.TTF", 12, {0.933, 0.886, 0.125}, 0.9, {0,0}, "", 0, 0, self.Bar.Overlay, "CENTER", {1,1})
		self.Bar.Font:SetParent(self.Bar.Button)
			
		E:RegisterAutoFont(self.Bar.Font, "db.profile.layout.barReputation.font") -- Enable just through local loader
		--E:RegisterAutoFont(self.Bar.Font, "db.profile.layout.barReputation.font", {["enable"] = function() Module:LoadConfig() end}) -- Enable just through local loader
	-------------------------------------------------
	
	self:SetScript("OnEvent", self.OnEvent)
end

function Module:UpdateDB()
	self.db = CO.db.profile.layout.barReputation
end
function Module:Init()
	self:__Construct()
	
	self:LoadConfig()
end

E:AddModule("Bar_Reputation", Module)