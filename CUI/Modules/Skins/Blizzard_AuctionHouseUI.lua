local E = unpack(select(2, ...)) -- Engine, Locale
local ModuleName = "Blizzard_AuctionHouseUI"
local CO, Module = E:LoadModules("Config", ModuleName)
Module.Autoload = true

local Holder = CreateFrame("Frame", "CUI_AuctionHouseMultisellFrameHolder", E.Parent)

local function AnchorFrameToMover(self)
	self:ClearAllPoints()
	self:SetParent(self.Holder)
	self:SetPoint("CENTER", self.Holder, "CENTER")
end

function Module:Construct()
	local Frame = _G.AuctionHouseMultisellProgressFrame
	
	Frame.ignoreFramePositionManager = true
	Frame.HandleMovementByChild = true
	
	Frame.Holder = Holder
	Frame.Mover = E:GetMover(Holder)
	
	-- External OnHide Handler to force stop moving. Horrible things would happen otherwise
	Frame:HookScript("OnHide", function(self)
		self.Mover.Handle:GetScript('OnDragStop')(self.Mover.Handle)
	end)
	hooksecurefunc(Frame, "Start", AnchorFrameToMover)
	
	if Frame then
		AnchorFrameToMover(Frame)
	end
end

function Module:Init()
	Holder:SetSize(300, 64)
	Holder:ClearAllPoints()
	Holder:SetPoint("CENTER", E.Parent, "CENTER")
	
	E:CreateMover(Holder, "Auction House Multisell Frame", nil, nil, nil, "The multisell progress window of the auction house", "misc")
	E:UpdateMoverDimensions(Holder)
	
	E:FireOnAddOnLoaded(self, "Construct", "Blizzard_AuctionHouseUI")
end

E:AddModule(ModuleName, Module)