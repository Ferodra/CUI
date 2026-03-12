local E = unpack(select(2, ...)) -- Engine, Locale
local CO, Module = E:LoadModules("Config", "Blizzard_TalkingHeadUI")
Module.Autoload = true

local ipairs			= ipairs
local tremove			= tremove
local C_AddOns_IsAddOnLoaded				= C_AddOns.IsAddOnLoaded
-- /dump C_AddOns.IsAddOnLoaded("Blizzard_TalkingHeadUI")

function Module:LoadConfig()
	local TalkingHeadFrame = _G.TalkingHeadFrame
	self.db = CO.db.profile.blizzard.talkingHead
	
	TalkingHeadFrame:SetScale(self.db.scale)
	
	--Reset Model Camera
	local model = TalkingHeadFrame.MainFrame.Model
	if model.uiCameraID then
		model:RefreshCamera()
		_G.Model_ApplyUICamera(model, model.uiCameraID)
	end
end

function Module:Construct()
	local TalkingHeadFrame = _G.TalkingHeadFrame
	
	TalkingHeadFrame.ignoreFramePositionManager = true
	--TalkingHeadFrame:ClearAllPoints()
	
	--TalkingHeadFrame:SetParent(Holder)
	--TalkingHeadFrame:SetPoint("CENTER", Holder, "CENTER")
	
	E:CreateMover(TalkingHeadFrame, "Talking Head Frame", nil, nil, nil, "Holds the occasional Talking Head Dialog", "misc")
	TalkingHeadFrame.Mover = E:GetMover(TalkingHeadFrame)
	TalkingHeadFrame.Mover.HandleMovementByChild = true
	
	-- External OnHide Handler to force stop moving. Horrible things would happen otherwise
	TalkingHeadFrame:HookScript("OnHide", function(self)
		self.Mover.Handle:GetScript('OnDragStop')(self.Mover.Handle)
	end)
	-- Just brute-force this frame onto our holder at this point
	TalkingHeadFrame:HookScript("OnShow", function(self)
		self:ClearAllPoints()
		self:SetPoint("CENTER", self.Mover, "CENTER")
	end)
	
	--Iterate through all alert subsystems in order to find the one created for TalkingHeadFrame, and then remove it.
	--We do this to prevent alerts from anchoring to this frame when it is shown.
	for index, alertFrameSubSystem in ipairs(_G.AlertFrame.alertFrameSubSystems) do
		if alertFrameSubSystem.anchorFrame and alertFrameSubSystem.anchorFrame == TalkingHeadFrame then
			tremove(_G.AlertFrame.alertFrameSubSystems, index)
		end
	end
	
	self:LoadConfig()
end

function Module:Init()	
	if not _G.TalkingHeadFrame then
		E:FireOnAddOnLoaded(self, "Construct", "Blizzard_TalkingHeadUI")
	else
		self:Construct()
	end
end

E:AddModule("Blizzard_TalkingHeadUI", Module)