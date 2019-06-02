local E, L = unpack(select(2, ...)) -- Engine, Locale
local AB = E:LoadModules("Actionbars")


local _G 					=	_G
local format 				=	string.format
local NUM_PET_ACTION_SLOTS 	=	NUM_PET_ACTION_SLOTS


function AB:CreatePetActionBar()
	local Button, ButtonName
	local BarName = "CUI_PetActionbar"
	local Bar = CreateFrame("Frame", BarName, E.Parent, "SecureHandlerStateTemplate")
	Bar:SetScript("OnShow", function(self)
		if not UnitExists("pet") then
			self:Hide()
		end
	end)
	
	Bar.ProfileName = "petbar"
	AB.ActionBars[BarName] = Bar
	
	Bar:SetPoint("CENTER", E.Parent, "CENTER")
	Bar:SetSize((32 + 3) * NUM_PET_ACTION_SLOTS, 32)
	
	Bar:SetScript("OnEnter", AB.BarMOver_OnEnter)
	Bar:SetScript("OnLeave", AB.BarMOver_OnLeave)

	Bar.CanBeFaded = true
	
	for i=1, NUM_PET_ACTION_SLOTS do
		Button = _G["PetActionButton" .. i]
		Bar[format("Button%s", i)] = Button
		
		AB.ActionButtons["PetActionButton" .. i] = Button
		-------------------------------------------

		Button.isPetButton = true
		
		Button:SetSize(32, 32)
		Button:ClearAllPoints()
		Button:SetParent(Bar)
		Button:SetPoint("LEFT", Bar, "LEFT", (32 + 3) * (i - 1), 0)
		
		Button.Parent = Bar
		Button:HookScript("OnEnter", AB.BarMOverButton_OnEnter)
		Button:HookScript("OnLeave", AB.BarMOverButton_OnLeave)

		E:RegisterPathFont(Button.HotKey, "db.profile.actionbar.petbar.hotkey")
		E:RegisterPathFont(Button.Count, "db.profile.actionbar.petbar.count")
		
		--self:ActionButton_AddMasque(Button)
		
		Button:Show()
	end
	
	E:SetVisibilityHandler(Bar)
	
	E:CreateMover(Bar, "Pet Actionbar")
end