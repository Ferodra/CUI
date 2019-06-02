local E = unpack(select(2, ...)) -- Engine

--[[----------------------------------------------------

	CUI Callback API
	This API provides an easy way to handle callbacks
	
	Author: Ferodra / Arenima
	
----------------------------------------------------]]--

local InitMethodBase = "%s_Init"

-- To check which callbacks still have to be initialized
E.Callbacks.Initialized = {}
E.RegisteredCallbacks = {}

function E:Callbacks_GetInitName(Name)
	return (InitMethodBase):format(Name)
end

function E:RegisterCallback(Name)
	if not E.RegisteredCallbacks[Name] then
		E.RegisteredCallbacks[Name] = true
		
		self:UpdateCallbacks()
	end
end

function E:InitCallbacks()
	
	local Func, FuncName
	
	for Name, _ in pairs(E.RegisteredCallbacks) do
		if Name then
			FuncName = self:Callbacks_GetInitName(Name)
			Func = self.Callbacks[FuncName]
			
			if Func and not self.Callbacks.Initialized[Name] then
				Func()
				
				self.Callbacks.Initialized[Name] = true
			end
		end
	end
end

-- For more convenient updating
E.UpdateCallbacks = E.InitCallbacks