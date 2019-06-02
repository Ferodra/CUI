local E, L = unpack(select(2, ...)) -- Engine, Locale

--[[
	This Addon provides a big, dynamic library full of methods to instantly create unitframes for every need.

	"local *" and "E.*" explaination:
		"local" defines the private scope in LUA
		"E" is our 'class' name in this case and lets us access everything defined within.
	
	Since we want to access some variables across our AddOn, we have to throw them into this private(/public) scope (local(/E)).
]]-- 

-------------------------------------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

--[[
	This Core combines the API with all required modules.
	We have to define the AH instance here, since we need it ASAP to initialize the locale!
]]-- 

-------------------------------------------------------------------------------------------------------------------------------
	-------------------------------------------------  Globals  -------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

	E.RaidMarkerNames = {
		[0] = "Keine",
		[1] = "Stern",
		[2] = "Kreis",
		[3] = "Diamant",
		[4] = "Dreieck",
		[5] = "Mond",
		[6] = "Quadrat",
		[7]	= "Kreuz",
		[8] = "Totenschädel",
		
	}

	local Separator = {}
	local CurrentDropDownUnit, CurrentDropDownButton
	E.MenuFrame = CreateFrame("Frame", "EMenuFrame", UIParent, "UIDropDownMenuTemplate")
	E.MenuFrame.displayMode = "MENU"
	
	-- BASE RAIDMARKER ICON PATH
	-- "Interface\\TargetingFrame\\UI-RaidTargetingIcon_%d"
	-- UIDropDownMenu_AddSeparator(UIDropDownMenu_CreateInfo(), 2)

	E.DropDownMenuContent = {
		{ text = "Select an Option", isTitle = true, notCheckable = true},
		{ text = "Inspect", func = function() InspectUnit("target") end, notCheckable = true },
		{ text = "Option 2", func = function() print("You've chosen option 2"); end, notCheckable = true },
		{ text = "Option 2", func = function() print("You've chosen option 2"); end, notCheckable = true },
		{ text = "More Options", hasArrow = true, notCheckable = true,
			menuList = {
				{ text = "Option 3", func = function() print("You've chosen option 3"); end }
			} 
		},
		Separator,
		{ text = "Gruppe verlassen", func = function() LeaveParty() end, notCheckable = true },
	}

	
	
	
	
	
	
	
	
-------------------------------------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

-- @TODO
-- Define templates for each possible case and combine the required ones in DropDownMenuCurrent.
E.DropDownMenuCurrent = {}


function E:PrepareDropDownInfo(self, unit, button)
	CurrentDropDownUnit 	= unit
	CurrentDropDownButton 	= button
end

local info = {}

local function AddSeparator(info, level)
	Lib_UIDropDownMenu_AddSeparator(info, level)
	
	info.text = nil
	info.hasArrow = nil
	info.dist = nil
	info.isTitle = nil
	info.isUninteractable = nil
	info.notCheckable = nil
	info.iconOnly = nil
	info.icon = nil
	info.tCoordLeft = nil;
	info.tCoordRight = nil;
	info.tCoordTop = nil;
	info.tCoordBottom = nil;
	info.tSizeX = nil;
	info.tSizeY = nil;
	info.tFitDropDownSizeX = nil;
	info.iconInfo = nil
end

E.MenuFrame.initialize = function(self, level, menuList)
	
	print(CurrentDropDownUnit)
	
	if not level then return end
	if not CurrentDropDownUnit or not CurrentDropDownButton then return end
	wipe(info)
	
	local specs = E:GetUnitSpecs(CurrentDropDownUnit)
	
	
	if (level == 1) then
	
		-- Headline (Unit Name)
	
		info.text			= UnitName(CurrentDropDownUnit)
		info.isTitle		= true
		info.notCheckable	= true
		info.isNotRadio 	= true
		Lib_UIDropDownMenu_AddButton(info, level)
		
		info.isTitle		= nil
		info.disabled		= nil
		
		
		info.text			= "Zielmarkierungssymbole"
		info.menuList		= "targetmarker"
		info.func 			= function() SetRaidTarget(CurrentDropDownUnit, 0); end
		info.hasArrow		= true
		Lib_UIDropDownMenu_AddButton(info, level)
		
		if CurrentDropDownUnit == "player" then
			AddSeparator(info, level)
			
			info.text			= "Beuteoptionen"
			info.isTitle		= true
			info.notCheckable	= true
			info.isNotRadio 	= true
			Lib_UIDropDownMenu_AddButton(info, level)
			
			info.isTitle		= nil
			info.disabled		= nil
			
			info.text			= "Beutespezialisierung"
			info.menuList		= "lootspec"
			info.func 			= nil
			info.hasArrow		= true
			Lib_UIDropDownMenu_AddButton(info, level)
			
			if IsInGroup() then
				info.text			= "Gruppe verlassen"
				info.menuList		= nil
				info.func 			= function() LeaveParty() end
				info.hasArrow		= false
				Lib_UIDropDownMenu_AddButton(info, level)
			end
		else
			-- If unit is not the player but a player
			if UnitIsPlayer(CurrentDropDownUnit) then
				if CurrentDropDownUnit ~= "focus" then
					info.text			= "Fokus setzen"
					info.menuList		= nil
					info.func 			= function() E:print("To focus a unit, simply Shift-Click its Unitframe.") end
					info.hasArrow		= false
					Lib_UIDropDownMenu_AddButton(info, level)
				else
					info.text			= "Fokus löschen"
					info.menuList		= nil
					info.func 			= function() E:print("To remove your focus, simply Shift-Click the focus Unitframe.") end
					info.hasArrow		= false
					Lib_UIDropDownMenu_AddButton(info, level)
				end
			
				info.text			= "+ Kontakt"
				info.menuList		= "addcontact"
				info.func 			= nil
				info.hasArrow		= true
				Lib_UIDropDownMenu_AddButton(info, level)
			
				AddSeparator(info, level)
				
				info.text			= "Interagieren"
				info.isTitle		= true
				info.notCheckable	= true
				info.isNotRadio 	= true
				Lib_UIDropDownMenu_AddButton(info, level)
				
				info.isTitle		= nil
				info.disabled		= nil
				
				info.text			= "Einladen"
				info.func			= function() InviteUnit(UnitName(CurrentDropDownUnit)) end
				Lib_UIDropDownMenu_AddButton(info, level)
			end
		end
		if CurrentDropDownUnit == "pet" then
			info.text			= "Freigeben"
			info.menuList		= nil
			info.func 			= function() PetDismiss() end
			info.hasArrow		= false
			Lib_UIDropDownMenu_AddButton(info, level)
		end
		
	elseif level == 2 then
		if menuList == "targetmarker" then
		
			for i=0,8 do
				info.text = E.RaidMarkerNames[i]
				if i ~= 0 then
					info.icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. i
				end
				info.keepShowOnClick = false
				info.func 			 = function() SetRaidTarget(CurrentDropDownUnit, i); end
				Lib_UIDropDownMenu_AddButton(info, level)
			end

        elseif menuList == "lootspec" then
            for i=0,table.getn(specs) do
				if i == 0 then
					i = GetSpecialization()
					info.text = "Aktuelle Spezialisierung (" .. specs[GetSpecialization()][2] .. ")"
				else
					info.text = specs[i][2]
				end
				local isActive = false
				if GetLootSpecialization() == specs[i][1] then
					isActive = true
				end
				info.checked = isActive
				info.icon = specs[i][4]
				info.keepShowOnClick = false
				info.func 			 = function() SetLootSpecialization(specs[i][1]); end
				Lib_UIDropDownMenu_AddButton(info, level)
			end
        end
	end
end

-- @TODO
-- Just fires once ?
local function MenuFrame_Initialize(self, level)
	if not level then return end
	if not CurrentDropDownUnit or CurrentDropDownButton then return end
	wipe(info)
	
	local _,_,classID = UnitClass(CurrentDropDownUnit)
	local specs = E:GetUnitSpecs(Unit)
	
	
	if (level == 1) then
	
		-- Headline (Unit Name)
	
		info.text			= UnitName(CurrentDropDownUnit)
		info.isTitle		= true
		info.notCheckable	= true
		info.isNotRadio 	= true
		Lib_UIDropDownMenu_AddButton(info, level)
		
		info.isTitle		= nil
		info.disabled		= nil
		
		
		info.text			= "Zielmarkierungssymbole"
		info.menuList		= "targetmarker"
		info.func 			= function() SetRaidTarget(CurrentDropDownUnit, 0); end
		info.hasArrow		= true
		Lib_UIDropDownMenu_AddButton(info, level)
		
		info.text			= "Beutespezialisierung"
		info.menuList		= "lootspec"
		info.func 			= nil
		info.hasArrow		= true
		Lib_UIDropDownMenu_AddButton(info, level)
		
	elseif level == 2 then
		if menuList == "targetmarker" then
		
			for i=0,8 do
				info.text = E.RaidMarkerNames[i]
				info.icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. i
				info.keepShowOnClick = false
				info.func 			 = function() SetRaidTarget(CurrentDropDownUnit, i); end
				Lib_UIDropDownMenu_AddButton(info, level)
			end

        elseif menuList == "submenu2" then
            info.text = "Moo"
            Lib_UIDropDownMenu_AddButton(info, level)

            info.text = "Lar"
            Lib_UIDropDownMenu_AddButton(info, level)

        end
	end
end


function E:InitializeDropDown()
	Lib_UIDropDownMenu_Initialize(E.MenuFrame, MenuFrame_Initialize)
	-- UIDropDownMenu_SetWidth(E.MenuFrame, 400, 5) Doesn't work apparently
end
















