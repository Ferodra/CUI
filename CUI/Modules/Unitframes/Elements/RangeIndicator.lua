local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF = E:LoadModules("Config", "Unitframes")

local RangeCheck = LibStub("LibRangeCheck-3.0")

----------------------------------------------
local _
local CreateFrame		= CreateFrame
local IsSpellInRange	= C_Spell and C_Spell.IsSpellInRange or IsSpellInRange

local Ticker = CreateFrame("Frame", "CUI_RangeIndicatorTick")
Ticker.Frames = {}
----------------------------------------------

Ticker.Elapsed = 0

local function CheckRange(unit)
	local minRange, maxRange = RangeCheck:GetRange(unit, true, true)
	return (not minRange) or maxRange
end

local function FriendlyIsInRange(Unit)
	-- When in other phase
	if UnitIsPlayer(Unit) and UnitPhaseReason(Unit) then
		return false
	end
	
	local inRange, checkedRange = UnitInRange(Unit)
	return inRange

	
	--return CheckRange(Unit)
end

local function EnemyIsInRange(Unit)	
	return CheckRange(Unit)
end

local function PetIsInRange(Unit)
	return CheckRange(Unit)
end

-- Gets called OnUpdate by every Unitframe with some timer limit (Make that an option)
local function UpdateRange(F)
	F = F.Parent
	if not F:IsVisible() then return end
	
	F.IsInRange = false
	
	if not UnitCanAttack("player", F.unit) then
		if not F.unit:find('pet') then
			F.IsInRange = UnitIsConnected(F.unit) and FriendlyIsInRange(F.unit)
		else
			F.IsInRange = PetIsInRange(F.unit)
		end
	else
		F.IsInRange = EnemyIsInRange(F.unit)
	end
	--end
	
	F:SetAlphaFromBoolean(F.IsInRange, CO.db.profile.unitframe.units.all.outOfRangeAlpha, 1)
	
	-- For now, leave that disabled, since it seems to trigger some random issues with parties and raids
	-- Prevent rapid unnecessary updates
	--if F.LastRangeState ~= F.IsInRange then
	
	--if not F.IsInRange then
		--F:SetAlpha(CO.db.profile.unitframe.units.all.outOfRangeAlpha)
		--E:UIFrameFadeOut(F, 0.2, F:GetAlpha(), CO.db.profile.unitframe.units.all.outOfRangeAlpha)
	--else
		--F:SetAlpha(1)
		--E:UIFrameFadeIn(F, 0.2, F:GetAlpha(), 1)
	--end
		
		--F.LastRangeState = F.IsInRange
	--end
end

function UF:AddRangeIndicator(F)
	if F.unit == "player" then return end
	
	for k,v in pairs(Ticker.Frames) do
		if v == F then
			F.RangeIndicator.Disabled = false
			return
		end
	end
	
	table.insert(Ticker.Frames, F)
	F.RangeIndicator = {}
	F.RangeIndicator.Parent = F
	F.RangeIndicator.Disabled = false
	F.RangeIndicator.ForceUpdate = UpdateRange
end

function UF:RemoveRangeIndicator(F)
	if true or F.unit == "player" then return end
	
	if F.RangeIndicator and not F.RangeIndicator.Disabled then
		for k,v in pairs(Ticker.Frames) do
			if v == F then
				table.remove(Ticker.Frames, k)
				break
			end
		end
		F.RangeIndicator.Disabled = true
		F:SetAlpha(1)
	end
end

-----

-- This is pretty CPU heavy, due to lots of checking and stuff. Maybe there's a more efficient way at some point
Ticker:SetScript("OnUpdate", function(self, elapsed)
	Ticker.Elapsed = Ticker.Elapsed + elapsed
	
	if Ticker.Elapsed >= 0.25 then
		--------------------
			
			for _, F in pairs(self.Frames) do
				if F.RangeIndicator and not F.RangeIndicator.Disabled then
					UpdateRange(F.RangeIndicator)
				end
			end
			
		--------------------
		Ticker.Elapsed = 0
	end
end)