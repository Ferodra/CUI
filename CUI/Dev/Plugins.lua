--[[
	
	This documentation is about how to create plug-ins for the Interface modification "CUI".
	
	This is the base construct to load the necessary modules into your files:
		Line 1: local E = CUI
		Line 2: local L, CO = E:LoadModules("Locale", "Config")
	
	----------------------------------------------------------------------
	To add a custom module, do the following:
		local CustomObject = E:LoadModules("MyCustomPluginName")
		
		E:AddModule("MyCustomPluginName", CustomObject)
	CUI will then create the missing module by itself.
	
	----------------------------------------------------------------------
	If the module should be based on a frame, do the following:
		local CustomObject = CreateFrame("Frame", "MyFrameName" or nil)
		
		E:AddModule("MyCustomPluginName", CustomObject)
	
	----------------------------------------------------------------------
	This will be called when all modules are being loaded:
		function CustomObject:Init()
			
		end
	
	----------------------------------------------------------------------
	To add an options category:
		CO:InitializeOptionsCategory("MyCustomSettings", CustomSettingsName, Order)
	
	----------------------------------------------------------------------
	To add localized strings:
		local L = E:LoadModules("LOC_enUS")
			L["MyCustomString"]	= "Hello World"		
	
	----------------------------------------------------------------------
	You can access every CUI module as you wish to!
]]--