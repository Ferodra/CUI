local E = unpack(select(2, ...)) -- Engine
local CO, CODE = E:LoadModules('Config', 'CustomCode')
CODE.Autoload = false

--[[----------------------------------------------------

	CUI Callback API
	This API provides an easy way to handle callbacks
	
	Author: Ferodra / Arenima
	
----------------------------------------------------]]--

-- Instead of providing the entire AddOn Scope, which could lead to some horrible results when importing from other people
local coreFuncs = {
	['print']		= function(_, ...) E:print(...) end,
	['debugprint']	= function(_, ...) E:debugprint(...) end,
}

local functionEnv = setmetatable({}, { __index =
  function(t, k)
    if k == "_G" then
      return t
    elseif k == "CUI" then
		return coreFuncs
	else
      return _G[k]
    end
  end
})

----------------------------------------------------

local TestStrFunc = [[function() CUI:print("HELLO WORLD!\nThis is custom code - generated from a string!") end]]

-- Validates if the required return argument exists. Adds it if necessary
local ReturnString = 'return '
function CODE:Validate(str)
	if string.sub(str, 1, 7) ~= ReturnString then
		str = ReturnString .. str
	end
	
	return str
end

function CODE:LoadFunction(str)
	str = self:Validate(str)
	local Func, ErrorStr = loadstring(str)
	
	if not ErrorStr then
		setfenv(Func, functionEnv)
		local Success, ParsedFunction = pcall(assert(Func))
		if Success then
			return ParsedFunction
		end
	else
		E:debugprint("ERROR")
	end
end

function CODE:Test()
	self:LoadFunction(CO.db.profile.code.testFunc or TestStrFunc)()
end

function CODE:Init()
	
end

E:AddModule("CustomCode", CODE)