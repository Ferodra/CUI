--[[
	
	This documentation is about how to create plug-ins for the Interface modification "CUI".
	
	This is the base construct to load the necessary modules into your files:
		Line 1: local E, L = unpack(CUI) -- Engine, Locale
		Line 2: local CO, CD = E:LoadModules("Config", "Config_Dialog")
	
	----------------------------------------------------------------------
	To add a custom module, do the following:
		local CustomObject = E:LoadModules("MyCustomPluginName")
		
	At the bottom of your script, add this:
		E:AddModule("MyCustomPluginName", CustomObject)
	CUI will then create the missing module by itself.
	All modules are frames, so you can add event handlers and such
	
	----------------------------------------------------------------------
	This will be called when the module is being loaded:
		function CustomObject:Init()
			
		end
	
	----------------------------------------------------------------------
	To add an options category:
		CD.Options.args[... Path ...]
	
	Consult https://www.wowace.com/projects/ace3/pages/ace-config-3-0-options-tables for info on how to add stuff to it
	
	----------------------------------------------------------------------
	To extend the CUI localization, use this snippet:
		local L_enUS = E.Libs.AceLocale:NewLocale('CUI', 'enUS')
	
	You can choose freely between all available game languages, of course.
	After this, you can easily add or override localized strings like this:
		L_enUS['Hello World'] = 'Hello World!'
	----------------------------------------------------------------------
	You can access every CUI module as you wish to!
]]--