local E, L = unpack(select(2, ...)) -- Engine, Locale
local L, CO, AB = E:LoadModules("Locale", "Config", "Actionbars")


local LibKeyBound = LibStub('LibKeyBound-1.0')

local StanceBarReady		= false


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

-- /run CUI:GetModule("Actionbars"):UpdateStanceBar()
function AB:InitStanceBar()
	local Button
	local NumForms = GetNumShapeshiftForms()
	
	if NumForms > 0 then
		if self.ActionBars["CUI_StanceBar"] then
			if not InCombatLockdown() then
				self.ActionBars["CUI_StanceBar"]:Show()
			end
			
			return
		end
		
		local Bar = CreateFrame("Frame", "CUI_StanceBar", E.Parent)
		Bar:SetPoint("CENTER", E.Parent, "CENTER")
		Bar:SetSize(200, 200)
		self.ActionBars["CUI_StanceBar"] = Bar
		
		Bar.CanBeFaded = true
		Bar:SetAttribute("IsShown", true)
		Bar:SetScript("OnEnter", AB.BarMOver_OnEnter)
		Bar:SetScript("OnLeave", AB.BarMOver_OnLeave)
		
		for i=1, NumForms do
			Button = _G["StanceButton" .. i]
			
			if Button then
				Button:ClearAllPoints()
				Button:SetParent(Bar)
				Button:SetPoint("LEFT", Bar, "LEFT", (32 + 5) * (i - 1), 0)
				
				function Button:SetKey(key)
					local BindButton = string.format("SHAPESHIFTBUTTON%d", self:GetID())
					SetBinding(key, BindButton)
					
					self.HotKey:SetText(key)
				end
				function Button:ClearBindings()
					local BindButton = string.format("SHAPESHIFTBUTTON%d", self:GetID())
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
				
				E:RegisterPathFont(Button.HotKey, "db.profile.actionbar.stancebar.hotkey")
				E:RegisterPathFont(Button.Count, "db.profile.actionbar.stancebar.count")
				self:ActionButton_AddMasque(Button)
				
				Button:Show()
			end
		end
		
		--StanceBarFrame:UnregisterAllEvents()
		StanceBarFrame:Hide()
		
		E:CreateMover(Bar, L["stanceBarFrame"])
		
		StanceBarReady = true
		self:UpdateStanceBar()
		self:UpdateActionbar("stancebar")
		
		Bar.ProfileName = "stancebar"
		
	else
		if self.ActionBars["CUI_StanceBar"] then
			self.ActionBars["CUI_StanceBar"]:Hide()
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
	end
end