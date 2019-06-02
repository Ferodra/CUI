local E, L = unpack(select(2, ...)) -- Engine, Locale
local A, I, CO = E:LoadModules("Armory", "Inspect", "Config")
I.Autoload = true



function I:LoadProfile()
	
	
end

function I:UpdatePanel()
	if not I.ModuleReady or not CO.db.profile.customArmory or not _G["InspectModelFrame"] then return end
	
	if _G["InspectModelFrame"]:IsVisible() then
		-- Those values are used to RESIZE the panel
		_G["InspectFrame"]:SetWidth(400)
		_G["InspectFrameInset"]:SetPoint("BOTTOMRIGHT", InspectFrame, "BOTTOMLEFT", 395, 5)
		
		_G["InspectMainHandSlot"]:ClearAllPoints()
		_G["InspectMainHandSlot"]:SetPoint('BOTTOM', _G["InspectFrameInset"], 'BOTTOM', -(_G["InspectMainHandSlot"]:GetWidth() / 2), 10)

		_G["InspectModelFrame"]:ClearAllPoints()
		_G["InspectModelFrame"]:SetPoint('TOPLEFT', _G["InspectFrameInset"], "TOPLEFT", 32, -5)
		_G["InspectModelFrame"]:SetPoint('BOTTOMRIGHT', _G["InspectFrameInset"], "BOTTOMRIGHT", -32, 28)
		
		A:CreateSlotInfo("Inspect")
		A:UpdateData(InspectFrame.unit, "Inspect")
	else
		-- Those values are used to RESET the panel
		_G["InspectFrame"]:SetWidth(338) -- Default: 338
		_G["InspectFrameInset"]:SetPoint("BOTTOMRIGHT", InspectFrame, "BOTTOMLEFT", 333, 4) -- Default: 333, 4
	end
	
	if UnitExists(InspectFrame.unit) then
		I:UpdateInspectBackground()
	end
end

function I:UpdateInspectBackground()
	A:OverridePanelBackground(_G["InspectModelFrame"], CO.db.profile.customArmoryBackground, CO.db.profile.customArmoryBackgroundTexture, CO.db.profile.customArmoryBackgroundTexturePath, select(2, UnitClass(InspectFrame.unit)))
end

function I:__Construct()
	if not CO.db.profile.customArmory then return end
	
	InspectFrame:HookScript("OnShow", I.UpdatePanel)
	_G["InspectModelFrame"]:HookScript("OnShow", I.UpdatePanel)
	_G["InspectModelFrame"]:HookScript("OnHide", I.UpdatePanel)
	
	self.ModuleReady = true
end

function I:Init()
	
	self:RegisterEvent("ADDON_LOADED")
	self:RegisterEvent("INSPECT_READY")
	self:SetScript("OnEvent", function(self, event, ...)
		if event == "ADDON_LOADED" and ... == "Blizzard_InspectUI" then
			I:__Construct()
		elseif event == "INSPECT_READY" then
			I:UpdatePanel()
		end
	end)
end

E:AddModule("Inspect", I)