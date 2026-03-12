local E, L = unpack(select(2, ...)) -- Engine, Locale
local FI = E:LoadModules("Filters")

--[[
	This database makes it easier for us to resolve auras to spellbook spells
	
	As auras nowadays often have different ID's from the spellbook spell,
	it causes a lot of trouble when the player adds filters based on the spellbook ID's.
	By linking the spellbook ID with other variations of the spell/aura here, we can
	resolve all of this - as long as we keep it updated . . .
--]]

-- [SpellbookID] => {... Additional Spell ID's ...}
local AdditionalSpellIDs = {
	[106832] = {106830, 77758}, -- Thrash
	[190784] = {363608}, -- Divine Steed
	[20271] = {197277}, -- Divine Judgement
}


do
	FI.AdditionalSpellIDs = AdditionalSpellIDs
end