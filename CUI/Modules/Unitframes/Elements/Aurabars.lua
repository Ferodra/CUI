local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF, BA, TT, FI = E:LoadModules("Config", "Unitframes", "Bar_Auras", "Tooltip", "Filters")

--[[-------------------------------------------------------------------------

	We are caching globals, since making those functions local,
	results in a slight performance boost and therefore
	in less CPU time. Exactly what we are aiming for.

-------------------------------------------------------------------------]]--
local _
local format 					= string.format
local wipe						= wipe
local tremove 					= table.remove
local tsort 					= table.sort
local CreateFrame 				= CreateFrame
local DebuffTypeColor 			= DebuffTypeColor
local UnitExists 				= UnitExists
local UnitCanAttack 			= UnitCanAttack
local UnitAura					= C_TooltipInfo.GetUnitAura
local GetAuraDataByIndex 		= C_UnitAuras and C_UnitAuras.GetAuraDataByIndex
local UnpackAuraData 			= AuraUtil and AuraUtil.UnpackAuraData
-----------------------------------------------------------------------------

BA.Containers = {}
BA.Auras = {}


local BAR_NUM, BAR_GAP_X, BAR_GAP_Y, BAR_SIZE_X, BAR_SIZE_Y = 10, 0, 2, 295, 18
local Masque = E.Libs.Masque
local MasqueGroup = Masque and Masque:Group("CUI", L["Aura Bars"])


BA.BAR_NUM = BAR_NUM

local function SortBars(a,b)
	if a and b then
		if a[8] > b[8] then
			return true
		elseif a[8] < b[8] then
			return false
		else
			return a[6] < b[6]
		end
	end
end

local function AuraButton_OnEnter(self)
	self.IsHovered = true
end
local function AuraButton_OnLeave(self)
	self.IsHovered = nil
	GameTooltip:Hide()
end

function BA:LoadConfig()
	self.db = CO.db.profile.auras
	
	for Unit, Header in pairs(self.Containers) do
		local profileData = CO.db.profile.auras.units[Unit].aurabars
		
		Header.BarNum = profileData.barNum
		if not profileData.enable then
			self:UnregisterAllEvents()
			Header:Hide()
		else
			Header.NumberFormat = profileData.cooldownIdentifier
			Header.filterType	= profileData.filterType or -1
			
			E:RegisterNumberFormatDBPath("db.profile.auras.units." .. Unit .. ".aurabars.cooldownIdentifier")
			E:CacheNumberFormat(Header.NumberFormat)
			
			-- Create new bars when needed
			self:CreateBar(Header)
			
			for i = 1, Header.BarNumMax do
				if i > Header.BarNum then
					Header[i]:Hide()
					Header[i].Visible = false
				else
					Header[i]:SetSize(profileData.width, profileData.height)
					Header[i].Bar:SetSize(profileData.width, profileData.height)
					
					Header[i].autoColorBarBorder = profileData.autoColorBarBorder
					Header[i].autoColorIconBorder = profileData.autoColorIconBorder
					
					if not profileData.autoColorBarBorder then
						Header[i].Bar.Border:SetBackdropBorderColor(profileData.barBorderColor.r, profileData.barBorderColor.g, profileData.barBorderColor.b, profileData.barBorderColor.a)
					end
					if not profileData.autoColorIconBorder then
						--E:SkinButtonIcon(Header[i].Icon.Tex, profileData.iconBorderColor)
						E:ColorizeAuraButton(Header[i].Icon, nil, nil, nil, nil, nil, profileData.iconBorderColor)
					end
					
					Header[i].Bar.Background.Tex:SetColorTexture(profileData.backgroundColor[1], profileData.backgroundColor[2], profileData.backgroundColor[3], profileData.backgroundColor[4])
					
					Header[i]:ClearAllPoints()
					if profileData.invertGrowth then
						Header[i]:SetPoint("TOPLEFT", Header, "TOPLEFT")
						E:MoveFrame(Header[i], 0, (((profileData.height + profileData.gapY) * (i - 1)) * (-1)) - profileData.gapY)
					else
						Header[i]:SetPoint("BOTTOMLEFT", Header, "BOTTOMLEFT")
						E:MoveFrame(Header[i], 0, ((profileData.height + profileData.gapY) * (i - 1)) - profileData.gapY)
					end
					
					Header[i].Icon:SetSize(profileData.iconSize, profileData.iconSize)
					
					Header[i]:Show()
					Header[i].Visible = true
				end
			end

			self:RegisterUnitEvent("UNIT_AURA", "player", "target")
			self:RegisterEvent("PLAYER_TARGET_CHANGED")
			
			self:UpdateHeader(Header)
			self:UpdateAuraCache(Unit)
			self:UpdateAuras(Unit)
			
			Header:Show()
		end
	end
end

function BA:UpdateHeader(Header)
	local SizeX, SizeY = 0, 0
	
	for i=1, Header.BarNumMax do
		if Header[i].Visible then
			SizeX = Header[i]:GetWidth() + CO.db.profile.auras.units[Header.unit].aurabars.iconSize
			SizeY = SizeY + Header[i]:GetHeight() + CO.db.profile.auras.units[Header.unit].aurabars.gapY
		end
	end
	
	Header:SetSize(SizeX, SizeY)
	E:UpdateMoverDimensions(Header)
end

function BA:ToggleBars(Unit)
	if self.Containers[Unit].ForceShow then
		self.Containers[Unit].ForceShow = nil
		self:UpdateAuras(Unit) -- Push update to show correct stuff again
	else
		self.Containers[Unit].ForceShow = true
	end
end
------------------------------------------------------------------------------------------------------------------------------
function BA:UpdateName(Object, Aura)
	if Aura[3] and Aura[3] > 1 then
		Object:SetText(format("%s [%s]", Aura[1], Aura[3]))
	else
		if Object:GetText() ~= Aura[1] then
			Object:SetText(Aura[1])
		end
	end
end

function BA:UpdateTime(Object, TimeLeft, Format)
	if TimeLeft > 0 then
		E:WriteNumberFormat(Object, Format, TimeLeft)
		--Object:SetText(E:GetFloat(TimeLeft, 1))
	else
		Object:SetText("")
	end
end

function BA:UpdateBarValues(Object, TimeLeft, Duration)
	
	if not (TimeLeft == 0 and Duration == 0) then
		Object:SetValue(TimeLeft)
		if Object.CurrentDuration ~= Duration then
			Object:SetMinMaxValues(0, Duration)
			Object.CurrentDuration = Duration
		end
	else
		Object:SetValue(1)
		Object:SetMinMaxValues(0, 1)
		Object.CurrentDuration = 0
	end
end

-- In this method, we make heavy use of control variables, since those have the least impact on memory
function BA:UpdateBarColor(Object, DType, Unit, UnitAuraClass, AuraName, SpellID, DefaultColor, OverrideColor)
	
	local Color = E:GetAuraColor(DType, Unit, AuraType, AuraName, SpellID, DefaultColor, OverrideColor)
	
	Object.Bar.Overlay:GetStatusBarTexture():SetVertexColor(Color.r, Color.g, Color.b, 1)
	if Object.autoColorBarBorder then
		Object.Bar.Border:SetBackdropBorderColor(Color.r, Color.g, Color.b, 1)
	end
	
	-- Always force custom color - when defined
	if Object.autoColorIconBorder or E:GetCustomAuraColor(SpellID) then
		E:ColorizeAuraButton(Object.Icon, DType, Unit, UnitAuraClass, AuraName, SpellID, DefaultColor, OverrideColor)
	end
end
------------------------------------------------------------------------------------------------------------------------------

local TooltipUnit, TooltipRealIndex, TooltipParent
function BA:BuildTooltip(self)
	TooltipParent = self:GetParent()
	TooltipUnit = TooltipParent:GetParent().unit
	if not BA.Auras[TooltipUnit] or not BA.Auras[TooltipUnit][TooltipParent.Index] then return end
	
	-- We have to retrieve the real aura index, since we do remove and sort auras from the table
	for k, v in pairs(BA.Auras[TooltipUnit]) do
		-- Because of the way how we assign the tables, we can do a direct comparison
		if v == BA.Auras[TooltipUnit][TooltipParent.Index] then
			TooltipRealIndex = v.RealIndex
			--print(TooltipRealIndex, v[1])
		end
	end	
	
	if TooltipRealIndex then
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:SetUnitAura(TooltipUnit, TooltipRealIndex, BA.Auras[TooltipUnit].AuraType)
		
		GameTooltip:Show()
	end
end

local HideAllFrame
function BA:HideAll(Unit)
	HideAllFrame = self.Containers[Unit]
		for i=1, HideAllFrame.BarNumMax do
			if not HideAllFrame[i].IsHidden then
				HideAllFrame[i]:Hide()
				HideAllFrame[i].IsHidden = true
			end
		end
		
	HideAllFrame.AllHidden = true
end

function BA:Bar_OnUpdate(elapsed)
	if self.ForceShow then
		for i=1, self.BarNum do
			self[i]:Show()
			self[i].Icon.Tex:SetTexture(134400)
			self[i].Bar.Overlay.name:SetText(format("Placeholder Aura %s", i))
			BA:UpdateTime(self[i].Bar.Overlay.time, (i / self.BarNum) * self.BarNum, self.NumberFormat)
			BA:UpdateBarValues(self[i].Bar.Overlay, i, self.BarNum)
		end
		
		return
	end

	if not (BA.Auras[self.unit] and BA.Auras[self.unit][1]) and not self.AllHidden then BA:HideAll(self.unit); return end

	-- Execute post-sort when needed
	if not self.UpdateInProgress and self.QueueAuraSort then
		tsort(BA.Auras[self.unit], SortBars)
		
		self.QueueAuraSort = nil
	end

	local CurrentBar, CurrentAura
	for i=1, self.BarNum do
		-- If we don't have any auras of the unit, return
		if UnitExists(self.unit) and BA.Auras[self.unit] and BA.Auras[self.unit][i] and BA.Auras[self.unit][i][5] and BA.Auras[self.unit][i][5] > 0 then
			
			CurrentBar = self[i]
			CurrentAura = BA.Auras[self.unit][i]
			
			if CurrentAura then
				CurrentBar.duration = CurrentAura[5]
				
				-- Fix for some random auras without duration that somehow pass until this point
				if CurrentAura[6] then
					CurrentBar.timeLeft = CurrentAura[6] - GetTime()
				
					if CurrentBar.timeLeft < 0 then CurrentAura[i] = nil else
						
						BA:UpdateBarValues(BA.Containers[self.unit][i].Bar.Overlay, CurrentBar.timeLeft, CurrentBar.duration)
						BA:UpdateTime(CurrentBar.Bar.Overlay.time, CurrentBar.timeLeft, self.NumberFormat)
					end
				else
					BA:UpdateBarValues(BA.Containers[self.unit][i].Bar.Overlay, 0, 0)
					BA:UpdateTime(CurrentBar.Bar.Overlay.time, 0, self.NumberFormat)
				end
				
				if CurrentBar.Icon.IsHovered then
					BA:BuildTooltip(CurrentBar.Icon)
				end
			end
			if not CurrentBar:IsVisible() then CurrentBar:Show(); CurrentBar.IsHidden = nil; self.AllHidden = nil end
		else
			if self[i]:IsVisible() then self[i]:Hide() end
		end
	end
end

function BA:CreateBar(Container)
	local CreatedNew = false
	local Unit = Container.unit
	local BarColor
	
	local Frame
	
	for i = 1, Container.BarNum do
		if not Container[i] then
			Frame = CreateFrame("Frame", format("AuraBar%s%s", Unit, i)) -- Acts as a parent
			Container[i] = Frame
			
			Frame:SetPoint(E.STR.BOTTOMLEFT, Container, E.STR.BOTTOMLEFT, BAR_GAP_X, (CO.db.profile.auras.units[Unit].aurabars.gapY + BAR_SIZE_Y) * (i - 1))
			Frame:SetSize(BAR_SIZE_X, BAR_SIZE_Y)
			Frame:SetParent(Container)
			
			self:CreateIcon(Frame, format("AuraBar%s%sIcon", Unit, i))
			Frame.Icon:SetScript("OnEnter", AuraButton_OnEnter)
			Frame.Icon:SetScript("OnLeave", AuraButton_OnLeave)
			
			Frame.Bar = E:CreateBar(format("AuraBar%s%sOverlay", Unit, i), "LOW", BAR_SIZE_X - BAR_SIZE_Y, BAR_SIZE_Y, {"LEFT", Frame.Icon, "RIGHT", 0, 0}, Frame.Icon, false, false, false)
			Frame.Bar:SetParent(Frame.Icon)
			
			-- We don't need this here
			E.Libs.LibSmooth:ResetBar(Frame.Bar.Overlay)
			
			BarColor = E:GetUnitReactionColor(Unit)
			Frame.Bar.Overlay:GetStatusBarTexture():SetVertexColor(BarColor.r, BarColor.g, BarColor.b, 1)
			
			self:InitFonts(Frame.Bar.Overlay, Unit)
			
			local ButtonData = {
				FloatingBG = nil,
				Icon = Frame.Icon.Tex,
				Cooldown = false,
				Flash = nil,
				Pushed = nil,
				Normal = nil,
				Disabled = nil,
				Checked = nil,
				Border = nil,
				AutoCastable = nil,
				Highlight = Frame.Highlight,
				HotKey = nil,
				Count = false,
				Name = nil,
				Duration = false,
				AutoCast = nil,
			}
			
			if MasqueGroup and CO.db.char.auras.generalAurabars.useMasque then
				MasqueGroup:AddButton(Frame.Icon, ButtonData)
				
				-- Not needed anymore, but let's keep this
				if Frame.Icon.__MSQ_BaseFrame then
					Frame.Icon.__MSQ_BaseFrame:SetFrameLevel(2) --Lower the framelevel to fix issue with buttons created during combat
				end
			end
			
			Frame.Index = i
			Frame:Hide()
			
			CreatedNew = true
		end
	end
	
	if CreatedNew then
		E:UpdateAutoFont("db.profile.auras.units." .. Unit .. ".aurabars.time")
		E:UpdateAutoFont("db.profile.auras.units." .. Unit .. ".aurabars.name")
	end
	
	if Container.BarNum > (Container.BarNumMax or 0) then
		Container.BarNumMax = Container.BarNum
	end
end

-- Creates a bar container for a given unit 
function BA:CreateBarContainer(Unit)
	
	local Container = self.Containers[Unit]
	
	if not Container then
		Container = CreateFrame("Frame", format("AuraBarContainer%s", Unit), E.Parent)
		self.Containers[Unit] = Container
		
		Container:SetPoint(E.STR.CENTER, E.Parent, E.STR.CENTER)
		Container:SetSize(BAR_SIZE_X, BAR_SIZE_Y * BAR_NUM)		
		
		Container.unit = Unit
		Container.BarNum = BAR_NUM
		
		Container:SetHideInPetBattles(true)
		E:HandleFrameInPetBattles(Container)
		E:CreateMover(Container, format("%s %s", L[Unit], L["AuraBars"]), E.STR.BOTTOMLEFT, nil, nil, nil, "unitframes")
	end
	
	self:CreateBar(Container)
	
	-- Post script to prevent issues
	if not Container:GetScript("OnUpdate") then
		Container:SetScript("OnUpdate", BA.Bar_OnUpdate)
	end
	
	self:UpdateAuraCache(Unit)
end

function BA:CreateIcon(F, Name)
	F.Icon = CreateFrame("Button", Name)
	F.Icon:SetPoint(E.STR.LEFT, F, E.STR.LEFT)
	F.Icon:SetSize(BAR_SIZE_Y, BAR_SIZE_Y)
	F.Icon:SetParent(F)
	
	F.Icon:EnableMouse(true)
	
	F.Icon.Tex = F.Icon:CreateTexture(nil, "OVERLAY")
	F.Icon.Tex:SetAllPoints(F.Icon)
	
	F.Icon.Highlight = E:CreateHighlight(F.Icon)
end

function BA:InitFonts(F, Unit)
	local FontType = "FRIZQT__.TTF"
	local Fonts = {["time"] = {"RIGHT", 100, 18, -5}, ["name"] = {"LEFT", 150, 18, 5}} -- Alignment, Width, Height, XOffset
	
	for n,v in pairs(Fonts) do
		F[n] = F:CreateFontString(nil, "ARTWORK")
		E:InitializeFontFrame(F[n], "ARTWORK", font, 11, {1,0.96,0.41}, 1, {0,0}, "", v[2], v[3], F, v[1], {1,1})
		F[n]:ClearAllPoints()
		F[n]:SetParent(F)
		F[n]:SetJustifyH(v[1])
		F[n]:SetPoint(v[1], F, v[1], v[4], 0)
		
		E:RegisterAutoFont(F[n], "db.profile.auras.units." .. Unit .. ".aurabars." .. n)
	end
end

local function IsAuraFiltered(Unit, SpellID, AuraDuration)
	return (FI:IsFiltered(BA.Containers[Unit].filterType, SpellID) or (AuraDuration and (AuraDuration == 0 or AuraDuration >= (BA.db.units[Unit].aurabars.maxThreshold or 0))))
end

function BA:AddAuraToCache(Unit, Index, AuraData)
	if not AuraData then return false end
	
	if not IsAuraFiltered(Unit, AuraData.spellId, AuraData.duration) then
		local Data = {
			[1] = AuraData.name,
			[2] = AuraData.icon,
			[3] = AuraData.applications,
			[4] = AuraData.dispelName,
			[5] = AuraData.duration,
			[6] = AuraData.expirationTime,
			[7] = AuraData.spellId,
			[8] = FI:GetAuraPriority(self.Containers[Unit].filterType, AuraData.spellId)
		}
		
		local Index = #self.Auras[Unit]+1
		self.Auras[Unit][Index] = {}
		tinsert(self.Auras[Unit][Index], Data)
	end
	
	-- UnpackAuraData
	-- return auraData.name,
		-- auraData.icon,
		-- auraData.applications,
		-- auraData.dispelName,
		-- auraData.duration,
		-- auraData.expirationTime,
		-- auraData.sourceUnit,
		-- auraData.isStealable,
		-- auraData.nameplateShowPersonal,
		-- auraData.spellId,
		-- auraData.canApplyAura,
		-- auraData.isBossAura,
		-- auraData.isFromPlayerOrPlayerPet,
		-- auraData.nameplateShowAll,
		-- auraData.timeMod,
		-- unpack(auraData.points);
end

-- If return false then we should run a full update instead
function BA:ProcessEventInfo(Unit, EventInfo)
	if not EventInfo then return false end
	
	if EventInfo.removedAuraInstanceIDs then
		for k,v in pairs(EventInfo.removedAuraInstanceIDs) do
			--print(k,v)
		end
	end
	if EventInfo.addedAuras then
		for k,v in pairs(EventInfo.addedAuras) do
			--self:AddAuraToCache(v)
		end
	end
	--self.Auras[Unit]
	
	-- @TODO: Change this to true after this method is fully implemented
	return false
end

local AuraName, AuraTexture, AuraCount, AuraDType, AuraDuration, AuraExpirationTime, UnitAuraClass, SpellID, CurrentAuraIndex, Index
function BA:UpdateAuraCache(Unit, EventInfo)
	if not UnitExists(Unit) or not self.Containers[Unit] then return end
	if InCombatLockdown() then return end -- Skip aurabars in combat until blizz releases a filtering fix..
	
	-- We use this to gain more control over the sort process, since it sometimes seems to run when we update the aura cache
	self.UpdateInProgress = true
	
	if not BA:ProcessEventInfo(Unit, EventInfo) then
		CurrentAuraIndex = 1
		Index = 1
	
		-- Start with a clean table
		if self.Auras[Unit] then wipe(self.Auras[Unit]) end
		if not self.Auras[Unit] then self.Auras[Unit] = {} end
	
		if UnitCanAttack(Unit, E.STR.player) then UnitAuraClass = E.STR.HARMFUL; else UnitAuraClass = E.STR.HELPFUL; end
	
		-- Iterate until we reach the last auraID of the unit
		while true do
			
			AuraName, AuraTexture, AuraCount, AuraDType, AuraDuration, AuraExpirationTime, _, _, _, SpellID = UnpackAuraData(GetAuraDataByIndex(Unit, CurrentAuraIndex, UnitAuraClass .. "|PLAYER"))
			
			if not AuraName then			
				break
			end
			
			-- If this aura should actually be displayed
			--if not (FI:IsFiltered(self.Containers[Unit].filterType, SpellID) or (AuraDuration and (AuraDuration == 0 or AuraDuration >= (self.db.units[Unit].aurabars.maxThreshold or 0)))) then
			if not IsAuraFiltered(Unit, SpellID, AuraDuration) then
				--print(UnpackAuraData(GetAuraDataByIndex(Unit, CurrentAuraIndex, UnitAuraClass .. "|PLAYER")))
				
				if not self.Auras[Unit][Index] then self.Auras[Unit][Index] = {} end
				
				
				-- Used for tooltips
				self.Auras[Unit][Index].RealIndex = CurrentAuraIndex
				
				-- Numerical indexing for better sort results (results at all)
				self.Auras[Unit][Index][1] = AuraName
				self.Auras[Unit][Index][2] = AuraTexture
				self.Auras[Unit][Index][3] = AuraCount
				self.Auras[Unit][Index][4] = AuraDType
				self.Auras[Unit][Index][5] = AuraDuration
				self.Auras[Unit][Index][6] = AuraExpirationTime
				self.Auras[Unit][Index][7] = SpellID
				self.Auras[Unit][Index][8] = FI:GetAuraPriority(self.Containers[Unit].filterType, SpellID)
				
				-- Also cache the aura type [Harmful or Helpful]
				self.Auras[Unit].AuraType = UnitAuraClass
				
				Index = Index + 1
			end
			
			CurrentAuraIndex = CurrentAuraIndex + 1
		end
	end
	
	self.UpdateInProgress = nil
	
	-- NOTE: As of 16-0-2025, we moved this into the loop above to remove excess overhead. No functionality should be lost through this.
	-- Remove uneccessary entries. Start from the end. Otherwise the loop would cancel after removing the first entry
	--for i=#self.Auras[Unit],1,-1 do
		-- Remove auras with a duration higher than 5 minutes or no duration at all
		-- @TODO: Make this highly customizable and migrate this method to an external file inside the AUR namespace
		-- So we can use it for more than just the aurabars
		--if FI:IsFiltered(self.Containers[Unit].filterType, self.Auras[Unit][i][7]) or (self.Auras[Unit][i] and (self.Auras[Unit][i][5] == 0 or self.Auras[Unit][i][5] >= (self.db.units[Unit].aurabars.maxThreshold or 0))) then
		--	tremove(self.Auras[Unit], i)
		--end
	--end
	
	-- Sort by expiration time
	if self.Auras[Unit] and not self.UpdateInProgress then
		tsort(self.Auras[Unit], SortBars)
	elseif self.UpdateInProgress then
		self.QueueAuraSort = true
	end
	
	-- This updates textures, name and bar color ONCE
	-- So we don't have to check for updates within the OnUpdate handler!
	self:UpdateAuras(Unit)
end

function BA:UpdateAuras(Unit, ForceUpdateCache)

	if ForceUpdateCache then self:UpdateAuraCache(Unit) end
	
	local AuraCache 	= BA.Auras[Unit]
	local BarCluster 	= self.Containers[Unit]
	local Bar, Aura
	
	for i=1, BarCluster.BarNum do
		-- If we don't have any auras of the unit, return
		if UnitExists(BarCluster.unit) and AuraCache and AuraCache[i] then
			
			Bar = BarCluster[i]
			Aura = AuraCache[i]
			
			if Aura then
				Bar.duration = Aura[5]
				Bar.timeLeft = Aura[6] - GetTime()
				
				if Bar.timeLeft < 0 then Aura[i] = nil else
					
					-- Perform updates
					BA:UpdateBarColor(Bar, Aura[4], Unit, AuraCache.AuraType, Aura[1], Aura[7])
					BA:UpdateBarValues(Bar.Bar.Overlay, Bar.timeLeft, Bar.duration)
					Bar.Icon.Tex:SetTexture(Aura[2])
					
					BA:UpdateName(Bar.Bar.Overlay.name, Aura)
					BA:UpdateTime(Bar.Bar.Overlay.time, Bar.timeLeft, BarCluster.NumberFormat)
				end
			end
			if not Bar:IsVisible() then Bar:Show(); Bar.IsHidden = nil; BarCluster.AllHidden = nil end
		else
			if BarCluster[i]:IsVisible() then BarCluster[i]:Hide() end
		end
	end
end

function BA:Init()
	if not CO.db.char.unitframe.enable then return end
	self.db = CO.db.profile.auras
	
	self:SetScript("OnEvent", function(self, event, ...)
		if event == "UNIT_AURA" then
			self:UpdateAuraCache(...)
		else
			self:UpdateAuraCache("target")
		end
	end)
	
	self:CreateBarContainer("player")
	self:CreateBarContainer("target")
	
	self:LoadConfig()
end

E:AddModule("Bar_Auras", BA)