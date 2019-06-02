local E = unpack(select(2, ...)) -- Engine
local L, B, AUR, UF = E:LoadModules('Locale', 'Bags', 'Auras', 'Unitframes')

--[[----------------------------------------------------

	Masque Callback Handler
	
----------------------------------------------------]]--

local ModuleName = "Masque"

local format	= string.format

-- Stop if this callback already has been loaded/registered
if E.Callbacks[ModuleName] then return end

--[[------------------------------
	BODY
--]]------------------------------
	
	local BagName = L['Bags']
	local PlayerAurasNameBuffs, PlayerAurasNameDebuffs = format("%s %s", L["player"],  L["Buffs"]), format("%s %s", L["player"],  L["Debuffs"])
	local UnitAurasNameBuffs, UnitAurasNameDebuffs = format("%s %s", L["unit"],  L["Buffs"]), format("%s %s", L["unit"],  L["Debuffs"])
	
	local function Callback(AddOn, SkinName)		
		if AddOn ~= E.AddOnName then return end
		
		if SkinName == BagName then
			B:ApplyBorderColor()			
		elseif SkinName == PlayerAurasNameBuffs or SkinName == PlayerAurasNameDebuffs then
			AUR:ColorizeAll()
		elseif SkinName == UnitAurasNameBuffs or SkinName == UnitAurasNameDebuffs then
			UF.Modules['Auras']:UpdateAll()
		end
	end

	local function Init()
		local Module = E[ModuleName] or E.Libs[ModuleName]
		
		if E[ModuleName] or E.Libs[ModuleName] then
			Module:Register(E.AddOnName, E.Callbacks[ModuleName], E)
		end
	end

---------------------------------------------------------------------------

-- Those will get called automatically by the API.
-- You usually don't have to touch the stuff below

--[[------------------------------
	HEAD
--]]------------------------------
E.Callbacks[ModuleName] = function(...) if E.InitComplete then Callback(...) end end
--[[------------------------------
	INIT
--]]------------------------------
E.Callbacks[E:Callbacks_GetInitName(ModuleName)] = function() Init() end
--[[------------------------------
	REGISTER CALLBACK
--]]------------------------------
E:RegisterCallback(ModuleName)