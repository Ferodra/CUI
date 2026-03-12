local E, L = unpack(select(2, ...)) -- Engine, Locale
local A, Module, CO = E:LoadModules("Armory", "Inspect", "Config")
Module.Autoload = true

local InspectFrame, InspectModelFrame, InspectFrameInset, InspectMainHandSlot, InspectModelFrameControlFrame


function Module:LoadConfig()
	
	
end

function Module:UpdatePanel()
	if not Module.ModuleReady or not CO.db.global.customArmory.enabled or not InspectModelFrame then return end
	
	if InspectModelFrame:IsShown() then
		-- Those values are used to RESIZE the panel
		InspectFrame:SetWidth(400)
		InspectFrameInset:SetPoint("BOTTOMRIGHT", InspectFrame, "BOTTOMLEFT", 395, 5)
		
		InspectMainHandSlot:ClearAllPoints()
		InspectMainHandSlot:SetPoint('BOTTOM', InspectFrameInset, 'BOTTOM', -(InspectMainHandSlot:GetWidth() / 2), 10)

		InspectModelFrame:ClearAllPoints()
		InspectModelFrame:SetPoint('TOPLEFT', InspectFrameInset, "TOPLEFT", 32, -5)
		InspectModelFrame:SetPoint('BOTTOMRIGHT', InspectFrameInset, "BOTTOMRIGHT", -32, 28)
		
		InspectModelFrameControlFrame:SetPoint('TOP', InspectModelFrame, "TOP", 0, -12)
		
		A:CreateSlotInfo("Inspect")
		A:UpdateData(InspectFrame.unit, "Inspect")
		A:UpdateOverallItemlevelText("Inspect", InspectFrame.unit)
	else
		-- Those values are used to RESET the panel
		InspectFrame:SetWidth(338) -- Default: 338
		InspectFrameInset:SetPoint("BOTTOMRIGHT", InspectFrame, "BOTTOMLEFT", 333, 4) -- Default: 333, 4
	end
	
	if UnitExists(InspectFrame.unit) then
		Module:UpdateInspectBackground()
	end
end

function Module:UpdateInspectBackground()
	A:OverridePanelBackground(InspectModelFrame, CO.db.global.customArmory.overrideBackground, CO.db.global.customArmory.useCustomBackground, CO.db.global.customArmory.customBackgroundPath, select(2, UnitClass(InspectFrame.unit)))
end

function Module:__Construct()
	if not CO.db.global.customArmory.enabled then return end
	
	-- Disable auto-hide when unit was lost
	-- InspectFrame:UnregisterEvent("PLAYER_TARGET_CHANGED")
	InspectFrame, InspectModelFrame, InspectFrameInset, InspectMainHandSlot, InspectModelFrameControlFrame = _G["InspectFrame"], _G["InspectModelFrame"],  _G["InspectFrameInset"],  _G["InspectMainHandSlot"], _G["InspectModelFrameControlFrame"]
	
	--InspectFrame:HookScript("OnShow", Module.UpdatePanel)
	--InspectModelFrame:HookScript("OnShow", Module.UpdatePanel)
	--InspectModelFrame:HookScript("OnHide", Module.UpdatePanel)
	
	self:RegisterEvent("INSPECT_READY")
	self:SetScript("OnEvent", function(self, event, ...)
		if event == "INSPECT_READY" then
			Module:UpdatePanel()
		end
	end)
	
	self.ModuleReady = true
end

function Module:Init()
	E:FireOnAddOnLoaded(self, "__Construct", "Blizzard_InspectUI")
end

E:AddModule("Inspect", Module)