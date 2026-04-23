local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, UF = E:LoadModules("Config", "Unitframes")

--[[--------------------
	Unitframe Extension	
--------------------]]--

local Module = {}
local _
local tinsert       = table.insert

-----------------------------------------

Module.Frames = {}

Module.FontsToCreate = {"Health", "Power", "Level", "Name"}


local function NameFont_PostUpdate(self)
    self:SetTextColor(unpack(E:GetUnitReactionColor(self.Owner.unit, false)))
end

local function HealthFont_PostUpdate(self)
    if not UnitIsDeadOrGhost(self.Owner.unit) then
        if not UnitIsConnected(self.Owner.unit) then
            self:SetText(FRIENDS_LIST_OFFLINE)
        end
    else
        self:SetText(DEAD)
    end
end

local function PowerFont_OnEvent(self, event, unit)
    if not event or (event and event == "UNIT_DISPLAYPOWER") then
        --print(unit, self.Owner.unit, unpack(E:GetUnitPowerColor((self.Owner.unit or unit))))
        self:SetTextColor(unpack(E:GetUnitPowerColor((self.Owner.unit or unit))))
    end
end

local function PowerFont_PostUpdate(self)
    --if not (UnitPowerMax(self.Owner.unit) > 0) then
    --	self:SetText("")
    --end
    
    self:SetTextColor(unpack(E:GetUnitPowerColor((self.Owner.unit or unit))))
    --print(unpack(E:GetUnitPowerColor((self.Owner.unit or unit))))
end

local function LevelFont_PostUpdate(self)
    self.Level = UnitLevel(self.Owner.unit)
    
    if self.ShowAtMax == true and self.Level == E.UNIT_MAXLEVEL then
        self:SetText(E.STR.EMPTY)
    else
        if self.Level <= -1 then
            --self:SetText(E:ParseString(self.Format or "[level]", self.unit))
            self:SetText(E.STR.Boss)
        end
    end
end

local function Fonts_UpdateUnit(self)
    for _, font in pairs(self.Frames) do
        if font.UpdateUnit then
            font:UpdateUnit(modUnit)
        end
    end
end

local function Fonts_Update(self, full)
    -- Fix for Bug that appeared first on 8.2 PTR
    if not UF:UnitExists(self.Owner.unit) then return end
    
    if full then
        Module:RefreshFontTags(self.Owner)
    end
    for k, font in pairs(self.Frames) do
        if font.ForceUpdate then
            font:ForceUpdate()
        end
    end
end

local PostUpdate = {
    ["Name"] = NameFont_PostUpdate,
    ["Health"] = HealthFont_PostUpdate,
    ["Power"] = PowerFont_PostUpdate,
    ["Level"] = LevelFont_PostUpdate,
}

Module.FontProperties = {
    ["Name"] = {
        ['Exclusions'] = {},
        ['Inclusions'] = {["textFormat"] = true},
    },
    ["Health"] = {
        ['Exclusions'] = {},
        ['Inclusions'] = {["textFormat"] = true},
    },
    ["Power"] = {
        ['Exclusions'] = {["fontColor"] = true},
        ['Inclusions'] = {["textFormat"] = true},
    },
    ["Level"] = {
        ['Exclusions'] = {},
        ['Inclusions'] = {["textFormat"] = true},
    },
}

function Module:RefreshFontTags_All(DBPath)
    if not DBPath then
        for _, unitframe in pairs(self.Frames) do
            self:RefreshFontTags(unitframe)
        end
    else
        if E.AutoFonts[DBPath] then
            -- We want to limit the updated frames
            for k, font in pairs(E.AutoFonts[DBPath]) do
                if font.Owner and font.Format then
                    self:RefreshFontTags(font.Owner)
                end
            end
        end
    end
end

function Module:RefreshFontTags(Unitframe)
    if not Unitframe.Fonts then return end
    
    for k, font in pairs(Unitframe.Fonts.Frames) do
        -- "Format" property is automatically updated via AutoFont
        if font.Format then
            E:RegisterTagFont(font, font.Format, Unitframe.unit)
        end
    end
end

local function RefreshFontTagsSingle(self)
    Module:RefreshFontTags(self.Owner)
end

local function ApplyFontConfig(self, Config)
    for _, font in pairs(self.Frames) do
        E:UpdateAutoFont(E:GetAutoFontPathForObject(font))
    end
    
    self:RefreshFontTagStrings()
    self:ForceUpdate()
end

function Module:LoadConfig(limit)
	local Config, Element
end

function Module:Create(F)
    if F.Fonts then return end

    local Element = {['Frames'] = {}}
    
    for name, info in pairs(self.FontProperties) do
        local Font = E:NewFontObject(format("%s%sFont", F:GetName(), name), "OVERLAY", F.TextOverlay, 10)
        Font.Owner = F

        Element.Frames[name] = Font
        E:RegisterAutoFont(Font, "db.profile.unitframe.units." .. F.ConfigKey .. ".fonts." .. E:stringToLower(name), info.Exclusions, info.Inclusions)
        E:RegisterTagFontPostUpdate(Font, PostUpdate[name])
    end

    -- We're adding those directly to the unitframe, since we want our Fonts table clean from anything else
    Element.Owner                   = F
    Element.ForceUpdate             = Fonts_Update
    Element.RefreshFontTagStrings   = RefreshFontTagsSingle
    Element.UpdateConfig 	        = ApplyFontConfig
    Element.UpdateUnit              = Fonts_UpdateUnit

    F.Fonts = Element
    tinsert(Module.Frames, F)
end

---------- Add Module
UF:RegisterModule('Fonts', Module)