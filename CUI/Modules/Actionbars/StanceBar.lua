local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, AB = E:LoadModules("Config", "Actionbars")

local _G 					= _G
local format 				= string.format
local tinsert 				= table.insert
local LibKeyBound 			= LibStub('LibKeyBound-1.0-CUI')

local StanceBarReady		= false
local EventListener 		= CreateFrame("Frame", "CUI_StanceBarEventFrame")

function AB:GetStancebarBindings()
	local binding = format("SHAPESHIFTBUTTON%d", self:GetID())
	local keys = ""
	
	for i = 1, select("#", GetBindingKey(binding)) do
		
		local hotKey = select(i, GetBindingKey(binding))
		if keys ~= "" then
			keys = keys .. ", "
		end
		keys = keys .. GetBindingText(hotKey, "KEY_")
	end
	
	return keys
end

function AB:UpdateActiveStanceButtons(event)
	
	if InCombatLockdown() then
		EventListener:RegisterEvent('PLAYER_REGEN_ENABLED')
		
		return
	end
	
	local Bar = self.ActionBars.stancebar
	local Config = CO.db.profile.actionbar[Bar.ConfigKey]
	
	for k, child in ipairs(Bar.buttons) do			
		if k > GetNumShapeshiftForms() then
			child.IgnoreSort = true
			child:Hide()
		else
			child:Show()
			child.IgnoreSort = nil
		end
	end
	
	if GetNumShapeshiftForms() > 0 then
		local NewWidth, NewHeight = E:SortFrames(Bar.buttons, Bar, nil, nil, Config.buttonSizeMultiplier, Config.buttonsPerRow, nil, nil, Config.buttonGap, Config.buttonGap, true, false)
		Bar:SetSize(NewWidth, NewHeight)
	else
		Bar:SetSize(32,32)
	end
	
	E:LoadMoverPositions(Bar)
	E:UpdateMoverDimensions(Bar)
	
	
end

local function EventListener_OnEvent(self, event)
	if not self.StancebarInitialized then
		AB:InitStanceBar()
	end
	AB:UpdateActiveStanceButtons(event)
	
	if event == 'PLAYER_REGEN_ENABLED' then
		EventListener:UnregisterEvent('PLAYER_REGEN_ENABLED')
	end
	if self.ScheduleConfigUpdate then
		AB:UpdateStanceBar()
		self.ScheduleConfigUpdate = nil
	end
end

-- /run CUI:LoadModule("Actionbars"):UpdateStanceBar()
function AB:InitStanceBar()
	
	if not EventListener.Initialized then
		EventListener:RegisterEvent('UPDATE_SHAPESHIFT_FORMS')
		EventListener:SetScript('OnEvent', EventListener_OnEvent)
		EventListener.Initialized = true
	end
	
	local Button
	local NumForms = GetNumShapeshiftForms()
	
	if NumForms > 0 then
		if self.ActionBars["stancebar"] then
			if not InCombatLockdown() then
				self.ActionBars["stancebar"]:Show()
			end
			
			return
		end
		
		if InCombatLockdown() then
			EventListener:RegisterEvent('PLAYER_REGEN_ENABLED')
			
			return
		end
		
		if not self.StancebarInitialized then
			local Bar = CreateFrame("Frame", "CUI_StanceBar", E.Parent)
			Bar:SetPoint("CENTER", E.Parent, "CENTER")
			Bar:SetSize(200, 200)
			self.ActionBars["stancebar"] = Bar
			Bar.buttons = {}
			Bar.BlizzBar = true
			Bar.ConfigKey = "stancebar"
			
			Bar.CanBeFaded = true
			Bar:SetAttribute("IsShown", true)
			Bar:SetScript("OnEnter", AB.BarMOver_OnEnter)
			Bar:SetScript("OnLeave", AB.BarMOver_OnLeave)
			
			for i=1, GetNumShapeshiftForms() do
				Button = _G["StanceButton" .. i]
				Button.IsStanceButton = true
				tinsert(Bar.buttons, Button)
				
				if Button then
					Button:ClearAllPoints()
					Button:SetParent(Bar)
					Button:SetPoint("LEFT", Bar, "LEFT", (50 + 5) * (i - 1), 0)
					
					function Button:SetKey(key)
						local BindButton = format("SHAPESHIFTBUTTON%d", self:GetID())
						SetBinding(key, BindButton)
						
						self.HotKey:SetText(key)
					end
					function Button:ClearBindings()
						local BindButton = format("SHAPESHIFTBUTTON%d", self:GetID())
						SetBinding(GetBindingKey(BindButton), nil)
						
						self.HotKey:SetText("")
					end
					-- /dump GetBindingKey(_G["SHAPESHIFTBUTTON1"])
					function Button:GetHotkey()
						local binding = format("SHAPESHIFTBUTTON%d", self:GetID())
						
						return LibKeyBound:ToShortKey(GetBindingKey(binding))
					end
					Button.GetBindings = AB.GetStancebarBindings
					
					
					Button:HookScript("OnEnter", function(self)
						LibKeyBound:Set(self)
					end)
					
					Button.Parent = Bar
					Button:HookScript("OnEnter", AB.BarMOverButton_OnEnter)
					Button:HookScript("OnLeave", AB.BarMOverButton_OnLeave)
					
					E:RegisterAutoFont(Button.HotKey, "db.profile.actionbar.stancebar.hotkey")
					E:RegisterAutoFont(Button.Count, "db.profile.actionbar.stancebar.count")
					self:ActionButton_AddMasque(Button)
					
					Button:Show()
				end
			end
			
			--StanceBarFrame:UnregisterAllEvents()
			StanceBar:Hide()
			
			E:CreateMover(Bar, L["stanceBarFrame"], nil, nil, nil, nil, "actionbars")
			
			StanceBarReady = true
			self:UpdateStanceBar()
			self:UpdateActionbar("stancebar")
			
			Bar.ProfileName = "stancebar"
			
			self.StancebarInitialized = true
		end
	else
		if self.ActionBars["stancebar"] then
			self.ActionBars["stancebar"]:Hide()
		end
	end
end

-- /run print(AB.ActionButtons["AB_StanceButton1"].action)

function AB:UpdateStanceBar()
	if not StanceBarReady then return end
	
	for i=1,GetNumShapeshiftForms() do
		self:UpdateActionButtonStyle(_G["StanceButton" .. i])
	end
	
	if not InCombatLockdown() then
		AB:UpdateActionbar("stancebar")
		
	else
		EventListener.ScheduleConfigUpdate = true
	end
end