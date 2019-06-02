local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF = E:LoadModules("Config", "Unitframes")

local SpellRange = LibStub("SpellRange-1.0")

----------------------------------------------
local _
local CreateFrame		= CreateFrame

local Ticker = CreateFrame("Frame", nil)
Ticker.Frames = {}
----------------------------------------------

Ticker.Elapsed = 0


local function FriendlyIsInRange(Unit)
	
	if UnitIsWarModePhased(Unit) then
		return false
	end
	
	local inRange, checkedRange = UnitInRange(Unit)
	if checkedRange and not inRange then
		return false
	end
	
	if E.RangeSpells[E.PlayerClass] then
		if UnitIsDeadOrGhost(Unit) then
			for _, spellID in pairs(E.RangeSpells[E.PlayerClass].resurrect) do
				if SpellRange.IsSpellInRange(spellID, Unit) == 1 then
					return true
				end
			end
			
			return false
		end
		
		for a, spellID in pairs(E.RangeSpells[E.PlayerClass].friendly) do
			if SpellRange.IsSpellInRange(spellID, Unit) == 1 then
				return true
			end
		end
	end
	
	if CheckInteractDistance(Unit, 1) then
		return true
	end
	
	return false
end

local function EnemyIsInRange(Unit)
	
	if CheckInteractDistance(Unit, 2) then
		return true
	end
	
	if E.RangeSpells[E.PlayerClass] then
		for _, spellID in pairs(E.RangeSpells[E.PlayerClass].enemy) do
			if SpellRange.IsSpellInRange(spellID, Unit) == 1 then
				return true
			end
		end
	end
	
	return false
end

local function PetIsInRange()
	
	if CheckInteractDistance("pet", 2) then
		return true
	end
	
	if E.RangeSpells[E.PlayerClass] then
		for _, spellID in pairs(E.RangeSpells[E.PlayerClass].pet) do
			if SpellRange.IsSpellInRange(spellID, "pet") == 1 then
				return true
			end
		end
		
		for _, spellID in pairs(E.RangeSpells[E.PlayerClass].friendly) do
			if SpellRange.IsSpellInRange(spellID, "pet") == 1 then
				return true
			end
		end
	end
	
	return false
end

-- Gets called OnUpdate by every Unitframe with some timer limit (Make that an option)
local function UpdateRange(F)
	F = F.Parent
	F.IsInRange = false
	
	if UnitInPhase(F.Unit) then
		if not UnitCanAttack("player", F.Unit) then
			if not UnitIsUnit("pet", F.Unit) then
				F.IsInRange = UnitIsConnected(F.Unit) and FriendlyIsInRange(F.Unit)
			else
				F.IsInRange = PetIsInRange()
			end
		else
			F.IsInRange = EnemyIsInRange(F.Unit)
		end
	end
	
	-- For now, leave that disabled, since it seems to trigger some random issues with parties and raids
	-- Prevent rapid unnecessary updates
	--if F.LastRangeState ~= F.IsInRange then
		if not F.IsInRange then
			F:SetAlpha(CO.db.profile.unitframe.units.all.outOfRangeAlpha)
		else
			F:SetAlpha(1)
		end
		
		--F.LastRangeState = F.IsInRange
	--end
end

function UF:AddRangeIndicator(F)
	if F.Unit == "player" then return end
	
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
	if F.Unit == "player" then return end
	
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