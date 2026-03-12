local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, Module = E:LoadModules("Config", "Blizzard_QueueStatusFrame")
Module.Autoload = true


-----------------------------------------------------------------------------
local _
local QueueStatusButtonHolder = CreateFrame("Frame", "CUI_QueueStatusButtonHolder", E.Parent)
QueueStatusButtonHolder:SetSize(50, 50)
-----------------------------------------------------------------------------

function Module:LoadConfig()
	
end

local function UpdatePosition(self)
	self:SetParent(QueueStatusButtonHolder)
	self:ClearAllPoints()
	self:SetAllPoints(QueueStatusButtonHolder)
end

function Module:Construct()
	local Button = _G["QueueStatusButton"]
	
	hooksecurefunc(Button, "UpdatePosition", UpdatePosition)
	UpdatePosition(Button)
	
	E:CreateMover(QueueStatusButtonHolder, "Queue Status Button", nil, nil, nil, "Shows your current queue status", "misc")
	E:UpdateMoverDimensions(QueueStatusButtonHolder)
end

function Module:Init()
	E:FireOnAddOnLoaded(self, "Construct", "Blizzard_QueueStatusFrame")
end

E:AddModule("Blizzard_QueueStatusFrame", Module)