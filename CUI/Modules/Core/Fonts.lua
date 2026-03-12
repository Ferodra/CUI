local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO = E:LoadModules("Config")

--[[----------------------------------------------------

	This library provides a powerful toolset
	that is designed to automatically update registered
	fonts through a database path.
	
	You may use this Code in your own projects,
	as long as there is at least any credit given.
	
	Author: Ferodra / Arenima
	
----------------------------------------------------]]--

---------------------------------------------------
local pairs 					= pairs
local tinsert					= table.insert
local wipe						= wipe
---------------------------------------------------

E.AutoFonts = {}
local GlobalExclusions = {} -- Used to automate the font config process
local EmptyExclusions = {}

local function UpdateFont(Object, Config, Path)
	Config = type(Config) == 'table' and Config or E:GetTableByPath(Object.ConfigPath or Path, CO)
	
	if not Config then
		Config = E:TableDeepCopy(CO.Template_Object)
	end
	
	local Exclusions = E:GetFontExclusions(Object.ConfigPath or Path) or Object.Exclusions
	
	if not Config.enable then if not Exclusions.enable then Object:Hide() end	else
		
		-- Font Shadow
			if Config.fontShadowColor and not Exclusions.fontShadowColor then
				Object:SetShadowColor(Config.fontShadowColor[1], Config.fontShadowColor[2], Config.fontShadowColor[3], Config.fontShadowColor[4] or 1)
				Object:SetShadowOffset(Config.xFontShadowOffset, Config.yFontShadowOffset)
			end
		-- Alignment
			if Config.horizontalAlign and not Exclusions.horizontalAlign then
				Object:SetJustifyH(Config.horizontalAlign)
			end
			if Config.verticalAlign and not Exclusions.verticalAlign then
				Object:SetJustifyV(Config.verticalAlign)
			end
			
		-- Repositioning
			if not Exclusions.position then
				Object:ClearAllPoints()
				
				if Config.positionOuter then
					Object:SetPoint(E:InversePosition(Config.position), Object:GetParent() or E.Parent, Config.position, Config.xOffset, Config.yOffset)
				else
					Object:SetPoint(Config.position, Object:GetParent() or E.Parent, Config.position, Config.xOffset, Config.yOffset)
				end
			end
		
		-- Level hide
			if Config.doNotShowOnMaxLevel then
				Object.ShowAtMax = Config.doNotShowOnMaxLevel
			end
		-- Font Color
			if Config.fontColor and not Exclusions.fontColor then
				-- Upgrade to classcolor system
				if Config.fontColor.useClassColor == nil then
					Config.fontColor.useClassColor = false
				end
				
				local Color = E:ParseDBColor(Config.fontColor, "player")
				Object.DBColor = Color
				Object:SetTextColor(Color[1], Color[2], Color[3], Color[4])
			end
		-- Width
			if Config.width and not Exclusions.width then
				Object:SetWidth(Config.width)
			end
		-- Height
			if Config.height and not Exclusions.height then
				Object:SetHeight(Config.height)
			end
		
		-- Flags
			if not Exclusions.general then
				if Config.fontFlags == "None" then Object.Flags = E.TBL.EMPTY else Object.Flags = Config.fontFlags end
				
			-- General
				-- (Frame, fontName, fontFlags, fontHeight, fontColor)
				E:SetFontInfo(Object, E.Media:Fetch("font", Config.fontType), Object.Flags, Config.fontHeight, nil)
				E:UpdateFont(Object)
				Object:SetDrawLayer("OVERLAY")
			end
			
			if not Exclusions.enable and not issecretvalue(Object:GetText()) then
				if Object:GetText() == RANGE_INDICATOR then Object:Hide() else Object:Show() end
			end
		end
	
	--if #Exclusions > 0 then
	--E:print_r(Exclusions)
	--end
	--print(GetTime())
	
	--E:print_r(Exclusions)
	
	-- Call overridden functions
	if Exclusions then
		for k, v in pairs(Exclusions) do
			if type(v) == "function" then
				v()
			end
		end
	end
end

-- Exclusion Format:
-- {type = funcRef or boolean}
function E:RegisterAutoFont(Object, Path, Exclusions)
	if not self.AutoFonts[Path] then
		self.AutoFonts[Path] = {}
	end
	
	Object.Exclusions = Object.Exclusions or Exclusions or {}
	Exclusions = Object.Exclusions
	
	self:RegisterFontExclusions(Path, Exclusions)
	
	if Exclusions then
		for k,v in pairs(Exclusions) do
			Object.Exclusions[k] = v
		end
	end
	
	Object.ConfigPath = Path
	
	tinsert(self.AutoFonts[Path], Object)
	UpdateFont(Object, nil, Path)
end

function E:UnregisterAutoFont(Path)
	if self.AutoFonts[Path] then
		wipe(self.AutoFonts[Path])
	end
end

-- Path[String] targets a specific font
function E:UpdateAutoFont(Path)
	local Config =  self:GetTableByPath(Path, CO)
	
	if not Config then
		Config = E:TableDeepCopy(CO.Template_Font)
	end
	
	if not Config then error("Database Font Path does not exist\nPath: CO." .. Path); return; end
	
	if not self.AutoFonts[Path] then return end
	for k, font in pairs(self.AutoFonts[Path]) do
		UpdateFont(font, Config, Path)
	end
end

function E:UpdateAllFonts()
	for path, group in pairs(self.AutoFonts) do
		self:UpdateAutoFont(path)
	end
end

-- /dump CUI[1]:GetFontExclusions("db.profile.blizzard.chatBubbles.name")

-- This is used to set exclusions in advance, to make sure the config will get the correct data from the get go
function E:RegisterFontExclusions(Path, Exclusions)
	if not GlobalExclusions[Path] then
		GlobalExclusions[Path] = {}
	end
	
	for k,v in pairs(Exclusions) do
		GlobalExclusions[Path][k] = v
	end
end
function E:GetFontExclusions(Path)
	return GlobalExclusions[Path] or EmptyExclusions
end