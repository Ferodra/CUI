local E, L = unpack(CUI) -- Engine
local CO = E:LoadModules("Config")
local ST = select(2, ...)

local PT = CreateFrame("Frame")
ST.PlayTime = PT

local ipairs	= ipairs
local pairs		= pairs
local format	= string.format
local tsort		= table.sort

-- PT.SortMethod = {[1] = "class", [2] = "time"}

function PT:GetCharacterList()
	self = PT
	self.db = ST.db.global
	local List = ""
	
	local chars = {}
	local index = 1
	local class, level
	for k, v in pairs(self.db.characters) do
		class = v.class or "PRIEST"
		level = v.level or "?"
		if v.timePlayed then
			chars[index] = {
				["timePlayed"] = v.timePlayed and v.timePlayed.time or 0,
				["name"] = k,
				["level"] = level,
				["class"] = class
			}
			index = index + 1
		end
	end
	
	local sort_func = function( a,b )
		if (a.class < b.class) then
           return true
        elseif (a.class > b.class) then
            return false
        else
              return a.timePlayed > b.timePlayed
        end
	end
	tsort( chars, sort_func )
	
	for k, v in ipairs(chars) do
		self.characterColor  	= E:GetClassColorByClassName(v.class)
		self.characterColor.r, self.characterColor.g, self.characterColor.b = self.characterColor[1], self.characterColor[2], self.characterColor[3]
		self.characterColorHex 	= E:RgbToHex({self.characterColor.r, self.characterColor.g, self.characterColor.b}, true)
		
		List = format("%s\n|c%s%s [%s]|r: %s", List, self.characterColorHex, v.name, v.level, E:FormatPlaytime(v.timePlayed) .. format(" [%d %s]", v.timePlayed / 3600, HOURS))
	end
	
	return List
end

function PT:GetTotalPlaytime()
	self = PT
	self.db = ST.db.global.timePlayed
	
	return "\n" .. E:FormatPlaytime(self.db.total) .. format(" [%d %s]", self.db.total / 3600, HOURS)
end

function PT:GetAllCharacters()
	local Chars = {}
	for k, v in pairs(ST.db.global.characters) do
		if v.timePlayed then
			Chars[k] = k
		end
	end
	return Chars
end

function PT:RemoveCharacter(key)
	ST.db.global.characters[key].timePlayed = nil
	
	if self.CharList then
		self:UpdateTotal()
		self:UpdateAllWidgets()
	end
	
	if key then
		E:print(key .. L["PlaytimeCharacterRemoved"])
	end
end

-----------------------------------------------
local realmKey = GetRealmName()
local characterKey = UnitName("player") .. " - " .. realmKey

function PT:Update()
	self = PT
	self.db = ST.db.global
	
	-- Create new key if needed
		if not self.db.characters[characterKey] then self.db.characters[characterKey] = {} end
		if not self.db.characters[characterKey].timePlayed then self.db.characters[characterKey].timePlayed = {} end
	-- Set character playtime
		local Data = self.db.characters[characterKey].timePlayed
		Data.time = self.updateValue
	
	-- Update total
		self:UpdateTotal()
	
	if PT.CharList then
		PT:UpdateAllWidgets(false)
		
		if PT.UpdateBtn:GetUserData("Text") == ". . ." then
			PT.UpdateBtn:SetText("Update")
			PT.UpdateBtn:SetUserData("Text", "Update")
			PT.UpdateBtn:SetDisabled(false)
		end
	end
end

function PT:UpdateTotal()
	local TimePlayed = ST.db.global.timePlayed
	
	TimePlayed.total = 0
	for k, v in pairs(ST.db.global.characters) do
		if v.timePlayed and v.timePlayed.time then
			TimePlayed.total = TimePlayed.total + v.timePlayed.time
		end
	end
end

function PT:OnEvent(event, ...)
	if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_LOGOUT" then
		
		self:PerformRequest()
	elseif event == "TIME_PLAYED_MSG" then
		self.updateValue = ...
		self:Update()
	end
end

function PT:SetEventHandler()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_LOGOUT")
	self:RegisterEvent("TIME_PLAYED_MSG")
	
	self:SetScript("OnEvent", self.OnEvent)
end

-- Can be called externally
function PT:PerformRequest()
	PT.TimeRequesting = true
		
	RequestTimePlayed() -- Try to update on login or logout
end

function PT:HandleSystemMessage()
	if self.isPlayedMessageHandled then return end
	
	-- We have to trick out the entire /played system here, since the CUI OnEvent request somehow returns 2 sets of playtime data
	
	-- Cache function because we'll still need it
	local o = ChatFrame_DisplayTimePlayed
	ChatFrame_DisplayTimePlayed = function(...)
		
		if PT.TimeRequesting then
			return false
		end
		return o(...)
	end
	
	-- Add a custom slash command to do the thing for us
	SlashCmdList['PLAYTIME_OVERRIDE'] = function(msg)
		PT.TimeRequesting = false
		RequestTimePlayed()
	end
	
	SLASH_PLAYTIME_OVERRIDE1 = '/played'
	
	-- If this would work, we wouldn't need the stuff above, sadly
	-- ChatFrame_AddMessageEventFilter("TIME_PLAYED_MSG", Func)
	
	self.isPlayedMessageHandled = true
end

function PT:LoadConfig()
	self:UpdateState()
end

function PT:UpdateState()	
	self:UnregisterAllEvents()
	if ST.db.global.timePlayed.enable then
		self:SetEventHandler()
		self:HandleSystemMessage()
	end
end

function PT:Construct()
	self:HandleSystemMessage()
	self:SetEventHandler()
end

function PT:Init()
	self.db = ST.db.global.timePlayed
	ST:RegisterCharacterDataKey("timePlayed")
	
	if self.db.enable then
		self:Construct()
	end
end