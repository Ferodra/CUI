local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, Module = E:LoadModules("Config", "PlayTime")
Module.Autoload = true
-----------------------------------------------

local ipairs	= ipairs
local pairs		= pairs
local format	= string.format
local tsort		= table.sort

function Module:GetCharacterList()
	self = Module
	self.db = CO.db.global.timePlayed
	local List = ""
	
	local chars = {}
	local index = 1
	for k, v in pairs(self.db.characters) do
		chars[index] = v
		v.name = k
		
		index = index + 1
	end
	
	local sort_func = function( a,b )
		if (a.class < b.class) then
           return true
        elseif (a.class > b.class) then
            return false
        else
              return a.time > b.time
        end
	end
	tsort( chars, sort_func )
	
	for k, v in ipairs(chars) do
		self.characterColor  	= CO.db.profile.colors.classes[v.class]
		self.characterColor.r, self.characterColor.g, self.characterColor.b = self.characterColor[1], self.characterColor[2], self.characterColor[3]
		self.characterColorHex 	= E:RgbToHex({self.characterColor.r, self.characterColor.g, self.characterColor.b}, true)
		
		List = format("%s\n|c%s%s [%s]|r: %s", List, self.characterColorHex, v.name, v.level, E:FormatPlaytime(v.time) .. format(" [%d %s]", v.time / 3600, HOURS))
	end
	
	return List
end

function Module:GetTotalPlaytime()
	self = Module
	self.db = CO.db.global.timePlayed
	
	return "\n" .. E:FormatPlaytime(self.db.total) .. format(" [%d %s]", self.db.total / 3600, HOURS)
end

function Module:GetAllCharacters()
	local Chars = {}
	for k, v in pairs(CO.db.global.timePlayed.characters) do
		Chars[k] = k
	end
	return Chars
end

function Module:RemoveCharacter(key)
	CO.db.global.timePlayed.characters[key] = nil
	
	local CD = E:LoadModule("Config_Dialog")
	
	if CD then
		Module:UpdateTotal()
		CD.Options.args.global.args.statisticsGroup.args.characterList.name = Module:GetCharacterList()
		CD.Options.args.global.args.statisticsGroup.args.totalTime.name = Module:GetTotalPlaytime()
	end
	
	if key then
		E:print(key .. L["PlaytimeCharacterRemoved"])
	end
end

-----------------------------------------------
local realmKey = GetRealmName()
local characterKey = UnitName("player") .. " - " .. realmKey
local classKey = select(2, UnitClass("player"))
local levelKey = UnitLevel("player")

function Module:Update()
	self = Module
	self.db = CO.db.global.timePlayed
	
	-- Create new key if needed
		if not self.db.characters[characterKey] then self.db.characters[characterKey] = {} end
	-- Set character playtime
		self.db.characters[characterKey]["time"] = self.updateValue
		self.db.characters[characterKey]["class"] = classKey
		self.db.characters[characterKey]["level"] = levelKey
	
	-- Update total
		self:UpdateTotal()
		
	local CD = E:LoadModule("Config_Dialog")
	
	if CD and CD.Options then
		CD.Options.args.global.args.statisticsGroup.args.characterList.name = self:GetCharacterList()
		CD.Options.args.global.args.statisticsGroup.args.totalTime.name = self:GetTotalPlaytime()
		
		if CD.Options.args.global.args.statisticsGroup.args.update.name == ". . ." then
			CD.Options.args.global.args.statisticsGroup.args.update.name = "Update"
		
			-- Change selected options	
			CD.ACD:SelectGroup("CUI", "global", "generalGroup")
			CD.ACD:SelectGroup("CUI", "global", "statisticsGroup")
		end
	end
end

function Module:UpdateTotal()
	Module.db.total = 0
	for k, v in pairs(Module.db.characters) do
		Module.db.total = Module.db.total + v.time
	end
end

function Module:OnEvent(event, ...)
	if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_LOGOUT" then
		
		self:PerformRequest()
	elseif event == "TIME_PLAYED_MSG" then
		self.updateValue = ...
		self:Update()
	end
end

function Module:SetEventHandler()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_LOGOUT")
	self:RegisterEvent("TIME_PLAYED_MSG")
	
	self:SetScript("OnEvent", self.OnEvent)
end

-- Can be called externally
function Module:PerformRequest()
	Module.TimeRequesting = true
		
	RequestTimePlayed() -- Try to update on login or logout
end

function Module:HandleSystemMessage()
	
	-- We have to trick out the entire /played system here, since the CUI OnEvent request somehow returns 2 sets of playtime data
	
	-- Cache function because we'll still need it
	local o = ChatFrame_DisplayTimePlayed
	ChatFrame_DisplayTimePlayed = function(...)
		
		if Module.TimeRequesting then
			return false
		end
		return o(...)
	end
	
	-- Add a custom slash command to do the thing for us
	SlashCmdList['PLAYTIME_OVERRIDE'] = function(msg)
		Module.TimeRequesting = false
		RequestTimePlayed()
	end
	
	SLASH_PLAYTIME_OVERRIDE1 = '/played'
	
	-- If this would work, we wouldn't need the stuff above, sadly
	-- ChatFrame_AddMessageEventFilter("TIME_PLAYED_MSG", Func)
end

function Module:Construct()
	self:HandleSystemMessage()
	self:SetEventHandler()
end

function Module:Init()
	self.db = CO.db.global.timePlayed
	
	if self.db.enable then
		self:Construct()
	end
end

E:AddModule("PlayTime", Module)	