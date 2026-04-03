---@class E, L
local E, L = unpack(select(2, ...)) -- Engine, Locale

local CreateColorCurve = C_CurveUtil.CreateColorCurve

E.Curves = {
    ['Auras'] = false,
    ['Health'] = false,
}

do
    -- Auras
    local Auras = CreateColorCurve()
    Auras:SetType(Enum.LuaCurveType.Step)

    E.Curves.Auras = Auras
    
    for which, index in next, E.DispelTypes do
        Auras:AddPoint(index, E.DebuffTypeColor[which])
        --print(index, CreateColor(E.DebuffTypeColorRaw[which]))
    end
end