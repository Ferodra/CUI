local E, L = unpack(CUI) -- Engine
local CD, L = E:LoadModules("Config_Dialog", "Locale")


-- Static tables for various settings
-----------------------------------[[--

	CD.FontFlags = {
		[""] = L["None"],
		["OUTLINE"] = "Outline",
		["THICKOUTLINE"] = "Thick Outline",
		["MONOCHROME"] = "Monochrome",
		["MONOCHROMEOUTLINE"] = "Monochrome Outline",
	}
	CD.FontHorizontalAlign = {
		["LEFT"] = L["Left"],
		["CENTER"] = L["Center"],
		["RIGHT"] = L["Right"],
	}
	CD.FontVerticalAlign = {
		["TOP"] = L["Top"],
		["MIDDLE"] = L["Center"],
		["BOTTOM"] = L["Bottom"],
	}
	CD.SortBarOrientation = {
		["HORIZONTAL"]  = L["Left"] .. " -> " .. L["Right"],
		["VERTICAL"]  = L["Bottom"] .. " -> " .. L["Top"],
	}

-----------------------------------]]--