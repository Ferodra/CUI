--[[========================================================================================
	
	
	Author: Ferodra [Arenima - Alleria EU]
		Email: ferodra@gmx.de

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the 'Software'), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense copies of the 
	Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	THE SOFTWARE.
    ========================================================================================]]

---@class E, L
local E, L = unpack(select(2, ...)) -- Engine, Locale


--[[-----------
	DEFINITIONS
	
	
	E:GetSpellInfo(spellID)
		Returns: SpellName, nil, IconID, CastTime, MinRange, MaxRange, SpellID, OriginalIconID
		
		Retrieves vararg formatted spell info based on spellID parameter
		
	
	E:GetSpellbookSpellInfoByName(SpellName)
		Returns: (Table) [id] = {SpellType, IsPassive}
		
		Returns a corresponding player spellbook spell info based on spellName parameter
		
		
	E:FireOnAddOnLoaded(Object, Func, AddOn, ...)
		Returns: nil
		Args: Object(object or nil), Func(string or function), ...(additional args for function)
		
		Queue function call for when the required AddOn is loaded. Or do it rightaway if it already is loaded
		... is used for additional func args

-----------]]--

local select							= select
local unpack							= unpack
local tinsert							= table.insert
local tremove							= table.remove
local C_AddOns_IsAddOnLoaded			= C_AddOns.IsAddOnLoaded
local GetSpellInfo 						= GetSpellInfo
local C_Spell_GetSpellInfo 				= C_Spell and C_Spell.GetSpellInfo
local C_GetSpellBookSkillLineInfo		= C_SpellBook and C_SpellBook.GetSpellBookSkillLineInfo or GetSpellBookSkillLineInfo
local C_GetSpellBookItemInfo 			= C_SpellBook and C_SpellBook.GetSpellBookItemInfo or GetSpellBookItemInfo
local C_GetAuraDataBySpellName			= C_UnitAuras and C_UnitAuras.GetAuraDataBySpellName
local GetMouseFocus 					= GetMouseFocus
local GetMouseFoci 						= GetMouseFoci
local UnitGroupRolesAssigned			= UnitGroupRolesAssigned


--[[===========================
			Console
=============================]]

local AddOnName			= select(1, ...)
local bracketColor		= '|cffFF4500'	-- Tangerine
local prefixColor 		=  '|cffffcc00'	-- Yellow
local messageColor 		= '|cff00ccff'	-- Sky Blue
local PrintPrefix 		= ('%s<|r%s%s|r%s>|r'):format(bracketColor, prefixColor, AddOnName, bracketColor)

-- Prints AddOn messages to console/chat
function E:print(msg)
	print(format('%s %s%s|r', PrintPrefix, messageColor, msg))
end

-- Prints AddOn debug-messages to console/chat. But without any concatentation to prevent errors caused by nil
-- Messages can be turned off by simply setting E.Debug to false
function E:debugprint(...)
	if self.Debug == true then
		print(PrintPrefix, ...)
	end
end

--[[===========================
			Spells
=============================]]

function E:GetSpellInfo(spellID)
	if not spellID then return end
	
	if GetSpellInfo then
		return GetSpellInfo(spellID)
	else
		local info = C_Spell_GetSpellInfo(spellID)
		
		if info then
			return info.name, nil, info.iconID, info.castTime, info.minRange, info.maxRange, info.spellID, info.originalIconID
		end
	end
end

local SpellbookSpells = {}
for i = 1, C_SpellBook.GetNumSpellBookSkillLines() do
	local skillLineInfo = C_GetSpellBookSkillLineInfo(i)
	local offset, numSlots = skillLineInfo.itemIndexOffset, skillLineInfo.numSpellBookItems
	for j = offset+1, offset+numSlots do
		local spellBookItemInfo = C_GetSpellBookItemInfo(j, Enum.SpellBookSpellBank.Player)
		local spellType, id, isPassive, iconID = spellBookItemInfo.itemType, spellBookItemInfo.actionID, spellBookItemInfo.isPassive, spellBookItemInfo.iconID
		
		--[[if id == 20271 then
			local Data = C_GetSpellBookItemInfo(j, Enum.SpellBookSpellBank.Player)
			for k,v in pairs(Data) do
				print(k, v)
			end
		end]]--
		
		local spellName
		if spellType == Enum.SpellBookItemType.Spell then
			spellName = C_Spell.GetSpellName(id)
			spellType = "Spell"
		elseif spellType == Enum.SpellBookItemType.FutureSpell then
			spellName = C_Spell.GetSpellName(id)
			spellType = "Future Spell"
		elseif spellType == Enum.SpellBookItemType.Flyout then
			spellName = GetFlyoutInfo(id)
			spellType = "Flyout"
		end
		
		if not SpellbookSpells[spellName] then
			SpellbookSpells[spellName] = {}
		end
		SpellbookSpells[spellName][id] = {spellType, isPassive, iconID}
	end
end

function E:GetSpellbookSpellInfoByName(name)
	return SpellbookSpells[name]
end

--[[===========================
			AddOn Loader
=============================]]

local AddOnLoadedFrame = CreateFrame('Frame', "CUI_AddonLoadWatcherFrame")
AddOnLoadedFrame.Data = {}

local function RunFunction(object, func, ...)
	if not object and type(func) == "function" then
		func(...)
	elseif object and type(func) == "string" then
		-- Call object function in object scope
		object[func](object, ...)
	end
end

-- Queue function call for when the required AddOn is loaded. Or do it rightaway if it already is
-- vararg used for additional func args
-- Args: Object(object or nil), Func(string or function), ...(additional args for function)
function E:FireOnAddOnLoaded(Object, Func, AddOn, ...)
	if C_AddOns_IsAddOnLoaded(AddOn) then
		RunFunction(Object, Func, ...)
	else
		if not AddOnLoadedFrame.Data[AddOn] then
			AddOnLoadedFrame.Data[AddOn] = {}
		end
		
		local Index = (#AddOnLoadedFrame.Data[AddOn] or 0) + 1
		
		AddOnLoadedFrame.Data[AddOn][Index] = {
			['object'] = Object,
			['func'] = Func,
			['args'] = {},
			['toRemove'] = false
		}
		
		for i = 1, select('#',...) do
			tinsert(AddOnLoadedFrame.Data[AddOn][Index].args, i, select(i,...))
		end
	end
end

AddOnLoadedFrame.Check = function(self, name)
	for index, Data in pairs(self.Data[name]) do
		RunFunction(Data.object, Data.func, unpack(Data.args))
		
		Data.toRemove = true
	end
end

AddOnLoadedFrame.Cleanup = function(self, name)
	for i = #self.Data[name], 2, -1 do
		if self.Data[name][i] and self.Data[name][i].toRemove then
			tremove(self.Data[name], i)
		end
	end
end

AddOnLoadedFrame:SetScript('OnEvent', function(self, event, name)
	if event == 'ADDON_LOADED' then
		-- Failsafe because you never know
		if not C_AddOns_IsAddOnLoaded(name) then return end
		
		if self.Data[name] then
			self:Check(name)
			self:Cleanup(name)
		end
	else
		-- Just iterate all queued for stuff that could happen during loading screens
		for cachedName, v in pairs(self.Data) do
			if C_AddOns_IsAddOnLoaded(cachedName) then
				self:Check(cachedName)
				self:Cleanup(cachedName)
			end
		end
	end
end)
AddOnLoadedFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
AddOnLoadedFrame:RegisterEvent('ADDON_LOADED')

--[[-----------
	UNITS
-----------]]--

-- Cache active spec. We need this to update E.IsPlayerTankingUnit constantly in combat, so might as well reduce load a teeny tiny bit
local SpecTracker = CreateFrame("Frame")
local SpecEvents = {'PLAYER_ENTERING_WORLD', 'ACTIVE_PLAYER_SPECIALIZATION_CHANGED'}
function SpecTracker:Update()
	self.Index = GetSpecialization()
	self.Role = GetSpecializationRole(self.Index)
end
do
	for k, v in pairs(SpecEvents) do
		SpecTracker:RegisterEvent(v)
	end
	SpecTracker:SetScript('OnEvent', function(self, event, ...)
		self:Update()
	end)
end

function E:GetPlayerSpecInfo()
	return SpecTracker.Role, SpecTracker.Index
end

function E:IsPlayerTankingUnit(unit)
	local IsTanking = UnitDetailedThreatSituation('player', unit)
	local ShouldTank = false
		
	if IsTanking ~= nil then
		local Role = UnitGroupRolesAssigned("player")
		
		if Role == "TANK" or (Role == "NONE" and SpecTracker.Role == "TANK") then
			-- Also check if unit target is a tank
			if UnitExists(format("%starget", unit)) then
				if UnitGroupRolesAssigned(format("%starget", unit)) ~= "TANK" then
					ShouldTank = true
				end
			else
				IsTanking = nil
				ShouldTank = false
			end
		end
	end
	
	return IsTanking, ShouldTank
end


--[[-----------
	MISC
-----------]]--

function E:GetMouseFocus()
	if GetMouseFoci then
		local frames = GetMouseFoci()
		return frames and frames[1]
	else
		return GetMouseFocus()
	end
end

