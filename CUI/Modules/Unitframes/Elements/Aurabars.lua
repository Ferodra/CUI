local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO,L,UF,BA,TT = E:LoadModules("Config", "Locale", "Unitframes", "Bar_Auras", "Tooltip")
local UAUR = UF.Modules["Auras"]

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
local UnitAura 					= UnitAura
-----------------------------------------------------------------------------

BA.E = CreateFrame("Frame")
BA.Bars = {}
BA.Auras = {}


local BAR_NUM, BAR_GAP_X, BAR_GAP_Y, BAR_SIZE_X, BAR_SIZE_Y = 10, 0, 2, 295, 18
local Masque = E.Libs.Masque
local MasqueGroup = Masque and Masque:Group("CUI", L["Aura Bars"])


BA.BAR_NUM = BAR_NUM

local function SortByExpiration(a,b)
	if a and b then
		if a[6] < b[6] then
			return true
		elseif a[6] > b[6] then
			return false
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

function BA:LoadProfile()
	for Unit, Header in pairs(self.Bars) do
		local profileData = CO.db.profile.auras.units[Unit].aurabars
		
		Header.BarNum = profileData.barNum
		if profileData.enable == false then
			Header:Hide()
		else
			
			Header.NumberFormat = profileData.cooldownIdentifier
			
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
			
			BA:UpdateHeader(Header)
			BA:UpdateAuras(Unit)
			
			Header:Show()
		end
	end
end

function BA:UpdateHeader(Header)
	local SizeX, SizeY = 0, 0
	
	for i=1, Header.BarNumMax do
		if Header[i].Visible then
			SizeX = Header[i]:GetWidth() + CO.db.profile.auras.units[Header.Unit].aurabars.iconSize
			SizeY = SizeY + Header[i]:GetHeight() + CO.db.profile.auras.units[Header.Unit].aurabars.gapY
		end
	end
	
	Header:SetSize(SizeX, SizeY)
	E:UpdateMoverDimensions(Header)
end

function BA:ToggleBars(Unit)
	if self.Bars[Unit].ForceShow then
		self.Bars[Unit].ForceShow = nil
		self:UpdateAuras(Unit) -- Push update to show correct stuff again
	else
		self.Bars[Unit].ForceShow = true
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
	E:WriteNumberFormat(Object, Format, TimeLeft)
end

function BA:UpdateBarValues(Object, TimeLeft, Duration)
	Object:SetValue(TimeLeft)
	if Object.CurrentDuration ~= Duration then
		Object:SetMinMaxValues(0, Duration)
		Object.CurrentDuration = Duration
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
	TooltipUnit = TooltipParent:GetParent().Unit
	if not BA.Auras[TooltipUnit] or not BA.Auras[TooltipUnit][TooltipParent.Index] then return end
	
	-- We have to retrieve the real aura index, since we do remove and sort auras from the table
	for k, v in pairs(BA.Auras[TooltipUnit]) do
		-- Because of the way how we assign the tables, we can do a direct comparison
		if v == BA.Auras[TooltipUnit][TooltipParent.Index] then
			TooltipRealIndex = v.RealIndex
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
	HideAllFrame = self.Bars[Unit]
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

	if not (BA.Auras[self.Unit] and BA.Auras[self.Unit][1]) and not self.AllHidden then BA:HideAll(self.Unit); return end

	-- Execute post-sort when needed
	if not self.UpdateInProgress and self.QueueAuraSort then
		tsort(BA.Auras[self.Unit], SortByExpiration)
		
		self.QueueAuraSort = nil
	end


	for i=1, self.BarNum do
		-- If we don't have any auras of the unit, return
		if UnitExists(self.Unit) and BA.Auras[self.Unit] and BA.Auras[self.Unit][i] and BA.Auras[self.Unit][i][5] and BA.Auras[self.Unit][i][5] > 0 then
			
			self.CurrentBar = self[i]
			self.CurrentAura = BA.Auras[self.Unit][i]
			
			if self.CurrentAura then
				self.CurrentBar.duration = self.CurrentAura[5]
				self.CurrentBar.timeLeft = self.CurrentAura[6] - GetTime()
				
				if self.CurrentBar.timeLeft < 0 then self.CurrentAura[i] = nil else
					
					BA:UpdateBarValues(BA.Bars[self.Unit][i].Bar.Overlay, self.CurrentBar.timeLeft, self.CurrentBar.duration)
					BA:UpdateTime(self.CurrentBar.Bar.Overlay.time, self.CurrentBar.timeLeft, self.NumberFormat)
				end
				
				if self.CurrentBar.Icon.IsHovered then
					BA:BuildTooltip(self.CurrentBar.Icon)
				end
			end
			if not self.CurrentBar:IsVisible() then self.CurrentBar:Show(); self.CurrentBar.IsHidden = nil; self.AllHidden = nil end
		else
			if self[i]:IsVisible() then self[i]:Hide() end
		end
	end
end

function BA:CreateBar(Holder)
	local CreatedNew = false
	local Unit = Holder.Unit
	local BarColor
	
	local Frame
	
	for i = 1, Holder.BarNum do
		if not Holder[i] then
			Frame = CreateFrame("Frame", format("AuraBar%s%s", Unit, i)) -- Acts as a parent
			Holder[i] = Frame
			
			Frame:SetPoint(E.STR.BOTTOMLEFT, Holder, E.STR.BOTTOMLEFT, BAR_GAP_X, (CO.db.profile.auras.units[Unit].aurabars.gapY + BAR_SIZE_Y) * (i - 1))
			Frame:SetSize(BAR_SIZE_X, BAR_SIZE_Y)
			Frame:SetParent(Holder)
			
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
			
			if MasqueGroup and CO.db.profile.auras.generalAurabars.useMasque then
				MasqueGroup:AddButton(Frame.Icon, ButtonData)
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
		E:UpdatePathFont("db.profile.auras.units." .. Unit .. ".aurabars.time")
		E:UpdatePathFont("db.profile.auras.units." .. Unit .. ".aurabars.name")
	end
	
	if Holder.BarNum > (Holder.BarNumMax or 0) then
		Holder.BarNumMax = Holder.BarNum
	end
end

function BA:CreateBars(Unit)
	
	if not self.Bars[Unit] then
		self.Bars[Unit] = CreateFrame("Frame", format("AuraBarContainer%s", Unit))
		self.Bars[Unit]:SetPoint(E.STR.CENTER, E.Parent, E.STR.CENTER)
		self.Bars[Unit]:SetSize(BAR_SIZE_X, BAR_SIZE_Y * BAR_NUM)
		
		self.Bars[Unit].Unit = Unit
		self.Bars[Unit].BarNum = BAR_NUM
		
		E:CreateMover(self.Bars[Unit], format("%s %s", L[Unit], L["AuraBars"]), E.STR.BOTTOMLEFT)
	end
	
	self:CreateBar(self.Bars[Unit])
	
	-- Post script to prevent issues
	if not self.Bars[Unit]:GetScript("OnUpdate") then
		self.Bars[Unit]:SetScript("OnUpdate", BA.Bar_OnUpdate)
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
		
		E:RegisterPathFont(F[n], "db.profile.auras.units." .. Unit .. ".aurabars." .. n)
	end
end

local AuraName, AuraTexture, AuraCount, AuraDType, AuraDuration, AuraExpirationTime, UnitAuraClass, CurrentAuraIndex, SpellID
function BA:UpdateAuraCache(Unit)
	if not UnitExists(Unit) or not self.Bars[Unit] then return end
	
	-- We use this to gain more control over the sort process, since it sometimes seems to run when we update the aura cache
	self.UpdateInProgress = true
	CurrentAuraIndex = 1
	
	-- Start with a clean table
	if self.Auras[Unit] then wipe(self.Auras[Unit]) end
	if not self.Auras[Unit] then self.Auras[Unit] = {} end
	
	if UnitCanAttack(Unit, E.STR.player) then UnitAuraClass = E.STR.HARMFUL; else UnitAuraClass = E.STR.HELPFUL; end
	
	-- Iterate until we reach the last auraID of the unit
	while true do
		
		AuraName, AuraTexture, AuraCount, AuraDType, AuraDuration, AuraExpirationTime, _, _, _, SpellID = UnitAura(Unit, CurrentAuraIndex, UnitAuraClass .. "|PLAYER")
		if not AuraName then
			if self.Auras[Unit] and self.Auras[Unit][CurrentAuraIndex] then
				self.Auras[Unit][CurrentAuraIndex] = nil
			end
			
			-- If aura would have been the first one. R.I.P
			if CurrentAuraIndex == 1 then
				wipe(self.Auras[Unit])
			end
			
				break
		end
		
		if not self.Auras[Unit][CurrentAuraIndex] then self.Auras[Unit][CurrentAuraIndex] = {} end
		
		
		-- Used for tooltips
		self.Auras[Unit][CurrentAuraIndex].RealIndex = CurrentAuraIndex
		
		-- Numerical indexing for better sort results (results at all)
		self.Auras[Unit][CurrentAuraIndex][1] = AuraName
		self.Auras[Unit][CurrentAuraIndex][2] = AuraTexture
		self.Auras[Unit][CurrentAuraIndex][3] = AuraCount
		self.Auras[Unit][CurrentAuraIndex][4] = AuraDType
		self.Auras[Unit][CurrentAuraIndex][5] = AuraDuration
		self.Auras[Unit][CurrentAuraIndex][6] = AuraExpirationTime
		self.Auras[Unit][CurrentAuraIndex][7] = SpellID
		
		-- Also cache the aura type [Harmful or Helpful]
		self.Auras[Unit].AuraType = UnitAuraClass
		
		CurrentAuraIndex = CurrentAuraIndex + 1
	end
	
	self.UpdateInProgress = nil
	
	-- Remove uneccessary entries. Start from the end. Otherwise the loop would cancel after removing the first entry
	for i=#self.Auras[Unit],1,-1 do
		-- Remove auras with a duration higher than 5 minutes or no duration at all
		-- @TODO: Make this highly customizable and migrate this method to an external file inside the AUR namespace
		-- So we can use it for more than just the aurabars
		if self.Auras[Unit][i] and (self.Auras[Unit][i][5] == 0 or self.Auras[Unit][i][5] >= 300) then
			tremove(self.Auras[Unit], i)
		end
	end
	
	-- Sort by expiration time
	if self.Auras[Unit] and not self.UpdateInProgress then
		tsort(self.Auras[Unit], SortByExpiration)
	elseif self.UpdateInProgress then
		self.QueueAuraSort = true
	end
	
	-- This updates textures, name and bar color ONCE
	-- So we don't have to check for updates within the OnUpdate handler!
	self:UpdateAuras(Unit)
end

function BA:UpdateAuras(Unit)
	
	self.CurrentUpdate = self.Bars[Unit]
	
	for i=1, self.CurrentUpdate.BarNum do
		-- If we don't have any auras of the unit, return
		if UnitExists(self.CurrentUpdate.Unit) and BA.Auras[Unit] and BA.Auras[Unit][i] and BA.Auras[Unit][i][5] > 0 then
			
			self.CurrentUpdate.CurrentBar = self.CurrentUpdate[i]
			self.CurrentUpdate.CurrentAura = BA.Auras[Unit][i]
			
			if self.CurrentUpdate.CurrentAura then
				self.CurrentUpdate.CurrentBar.duration = self.CurrentUpdate.CurrentAura[5]
				self.CurrentUpdate.CurrentBar.timeLeft = self.CurrentUpdate.CurrentAura[6] - GetTime()
				
				if self.CurrentUpdate.CurrentBar.timeLeft < 0 then self.CurrentUpdate.CurrentAura[i] = nil else
					
					-- Perform updates
					BA:UpdateBarColor(self.CurrentUpdate.CurrentBar, self.CurrentUpdate.CurrentAura[4], Unit, BA.Auras[Unit].AuraType, self.CurrentUpdate.CurrentAura[1], self.CurrentUpdate.CurrentAura[7])
					BA:UpdateBarValues(self.CurrentUpdate.CurrentBar.Bar.Overlay, self.CurrentUpdate.CurrentBar.timeLeft, self.CurrentUpdate.CurrentBar.duration)
					self.CurrentUpdate.CurrentBar.Icon.Tex:SetTexture(self.CurrentUpdate.CurrentAura[2])
					
					BA:UpdateName(self.CurrentUpdate.CurrentBar.Bar.Overlay.name, self.CurrentUpdate.CurrentAura)
					BA:UpdateTime(self.CurrentUpdate.CurrentBar.Bar.Overlay.time, self.CurrentUpdate.CurrentBar.timeLeft, self.CurrentUpdate.NumberFormat)
				end
			end
			if not self.CurrentUpdate.CurrentBar:IsVisible() then self.CurrentUpdate.CurrentBar:Show(); self.CurrentUpdate.CurrentBar.IsHidden = nil; self.CurrentUpdate.AllHidden = nil end
		else
			if self.CurrentUpdate[i]:IsVisible() then self.CurrentUpdate[i]:Hide() end
		end
	end
end

function BA:Init()
	self.db = CO.db.profile.auras
	
	self.E:RegisterEvent("UNIT_AURA", "player", "target")
	self.E:RegisterEvent("PLAYER_TARGET_CHANGED")
	self.E:SetScript("OnEvent", function(selfE, event, ...)
		if event == "PLAYER_TARGET_CHANGED" then self:UpdateAuraCache("target") else
			self:UpdateAuraCache(...)
		end
	end)
	
	self:CreateBars("player")
	self:CreateBars("target")
	
	self:LoadProfile()
end

E:AddModule("Bar_Auras", BA)