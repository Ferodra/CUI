local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF = E:LoadModules("Config", "Unitframes")

--[[--------------------
	Unitframe Extension	
--------------------]]--

local _
local unpack			= unpack
local pairs				= pairs
local tinsert			= table.insert
local Module = {}
Module.Frames = {}
Module.IncludeUnits = {'player'}

-----------------------------------------

local Texture_Glow = [[Interface/AddOns/CUI/Textures/borders/glow]]
local Texture_Icon = [[Interface/AddOns/CUI/Textures/icons/Combat]]

local function UpdateElement(self, event, ...)
	if self.Disabled then self:Hide() return end
	
	if not event or event == "PLAYER_REGEN_ENABLED" then
		if self.enableGlow then E:UIFrameFadeOut(self.Border, self.glowFadeOut, self.Border:GetAlpha(), 0) end
		if self.enableIcon then E:UIFrameFadeOut(self.Icon, self.iconFadeOut, self.Icon:GetAlpha(), 0) end	
	else
		if self.enableGlow then E:UIFrameFadeIn(self.Border, self.glowFadeIn, self.Border:GetAlpha(), 1) end
		if self.enableIcon then E:UIFrameFadeIn(self.Icon, self.iconFadeIn, self.Icon:GetAlpha(), 1) end	
	end
end

local function ForceUpdate(self)
	UpdateElement(self)
end

----------

-- Gets called automatically when the unitframes first are initialized and on config update
function Module:LoadConfig()
	local Config, Element, ElementConfig
	
	for _, self in pairs(self.Frames) do
		Config = CO.db.profile.unitframe.units[self.ConfigKey]
		Element = self.CombatIndicator
		ElementConfig = Config.combatIndicator
		
		if ElementConfig then
			if not ElementConfig.enableGlow and not ElementConfig.enableIcon then Element:Hide(); Element:UnregisterAllEvents(); Element.Disabled = true; else
			
				Element.enableGlow = ElementConfig.enableGlow
				Element.enableIcon = ElementConfig.enableIcon
				
				if not Element.enableGlow then Element.Border:Hide(); end
				if not Element.enableIcon then Element.Icon:Hide(); end
				Element:Show()
				
				Element.glowFadeIn = ElementConfig.glowFadeIn
				Element.glowFadeOut = ElementConfig.glowFadeOut
				Element.iconFadeIn = ElementConfig.iconFadeIn
				Element.iconFadeOut = ElementConfig.iconFadeOut
				
				Element.Icon:ClearAllPoints()
				Element.Icon:SetPoint("CENTER", Element, ElementConfig.iconPosition, ElementConfig.iconOffsetX, ElementConfig.iconOffsetY)
				Element.Icon:SetSize(ElementConfig.iconSize, ElementConfig.iconSize)
									
				Element.Border:SetBackdropBorderColor(unpack(ElementConfig.glowColor))
				Element.Border:SetSize(Element:GetWidth() + (ElementConfig.glowSize * 2), Element:GetHeight() + (ElementConfig.glowSize * 2))
				Element.Border.SetBorderSize(ElementConfig.glowSize)
				
				if not Element:IsEventRegistered("PLAYER_REGEN_DISABLED") then
					Element:RegisterEvent("PLAYER_REGEN_ENABLED")
					Element:RegisterEvent("PLAYER_REGEN_DISABLED")
				end
				
				Element.Disabled = false
			end
		else
			Element:UnregisterAllEvents()
			Element.Disabled = true
		end
	end
end

function Module:Create(F)
	local Element = CreateFrame("Frame", format("CUI_CombatIndicator_%s", F.unit), F)
	Element:SetAllPoints(F)
	
	Element:SetFrameLevel(F:GetFrameLevel() + 10)
			
	Element.Border = E:CreateBorder(Element, Texture_Glow, 7)
		Element.Border:SetFrameLevel(1)
		Element.Border:ClearAllPoints()
		Element.Border:SetPoint("CENTER", Element, "CENTER")
		
	Element.Icon = CreateFrame("Frame", Element:GetName() .. "Icon")
		Element.Icon:SetParent(Element)

		Element.Icon.T = Element.Icon:CreateTexture(nil, "OVERLAY")
		Element.Icon.T:SetAllPoints(Element.Icon)
		Element.Icon.T:SetTexture(Texture_Icon)
	
	Element.Icon:SetAlpha(0); Element.Border:SetAlpha(0)
	Element.Icon:Hide(); Element.Border:Hide()
	
	Element:SetScript("OnEvent", UpdateElement)
	-- We have to update from config when the Unitframe changed size, since the glow uses hard size values and cannot be made dynamic, really
	if F.Health then
		hooksecurefunc(F, "SetSize", function() Module:LoadConfig() end)
	end
	
	F.CombatIndicator = Element
	F.CombatIndicator.ForceUpdate = ForceUpdate
	
	tinsert(self.Frames, F)
end

---------- Add Module
UF.Modules["CombatIndicator"] = Module