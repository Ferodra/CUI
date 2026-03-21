---@class E, L
local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO = E:LoadModules("Config")

local pairs 	= pairs
local match 	= string.match
local gsub 		= string.gsub
local sub 		= string.sub
local len 		= string.len
local gmatch 	= string.gmatch
local rep 		= string.rep
local lower		= string.lower
local upper		= string.upper
local format	= string.format
local floor 	= math.floor
local fmod 		= math.fmod
local tinsert	= table.insert
local GetNumSpecializationsForClassID = C_SpecializationInfo.GetNumSpecializationsForClassID

function E:GetRandomTableKey(t)
	local keys, i = {}, 1
	for k,_ in pairs(t) do
	 keys[i] = k
	 i = i+1
	end

	local m
	m = math.random(1,#keys)
	return keys[m]
end

function E:GetRandomTableEntry(t)
	local Key = self:GetRandomTableKey(t)
	return t[Key]
end

function E:tableContainsKey(tbl, item)
    for key, value in pairs(tbl) do
        if key == item then return value end
    end
    return false
end

function E:GetTableLength(t)
    local c = 0
    for k,v in pairs(t) do
		if v then
         c = c + 1
		 end
    end
    return c
end

local TablePathCache = {}
function E:GetTableByPath(Path, Source)
	if TablePathCache[Source] and TablePathCache[Source][Path] then return TablePathCache[Source][Path] end

	local Separator = "."
    local Parts = {};
    local i = 1;
    for PathPart in Path:gmatch("([^"..Separator.."]+)") do
        Parts[i] = PathPart;
        i = i + 1;
    end
	
	local Target

    for _, key in pairs(Parts) do
        Target = (Target and Target[key]) or Source[key]
    end

	if not TablePathCache[Source] then TablePathCache[Source] = {} end
	TablePathCache[Source][Path] = Target
    return Target
end

function E:TableContainsValue(tbl, item, itemType)
    for key, value in pairs(tbl) do
		if itemType then
			if value == item and type(item) == itemType then return key end
		else
			if value == item then return key end
		end
    end
    return false
end

function E:TableContainsValueAtN(tbl, item, position)
    for key, value in pairs(tbl) do
        if value[position] == item then return key end
    end
    return false
end

function E:IsStringPartInTableValues(tbl, str)
    for key, value in pairs(tbl) do
        if match(str, value) then return match(str, value) end
    end
    return false
end

function E:IsStringPartInTableKeys(tbl, str)
    for key, value in pairs(tbl) do
        if match(str, key) then return match(str, key) end
    end
    return false
end

function E:DoesStringPartExist(str, find)
	return match(str, find)
end

function E:RemoveFromString(str, find)
	return gsub(str, find, "")
end

function E:GetFullFrameName(object)
	return object:GetName()
end

-- Returns d, h, m, s
function E:TimeBreakDown(totalTime)
	return ChatFrame_TimeBreakDown(totalTime)
end

function E:FormatPlaytime(totalTime)
	local d, h, m, s = self:TimeBreakDown(totalTime)
	--return format(TIME_DAYHOURMINUTESECOND, d, h, m, s)
	return format("%d %s, %d %s, %d %s", d, DAYS, h, HOURS, m, MINUTES)
end

function E:RgbToHex(rgb, SmallValue)
	
	local hexadecimal = 'FF'

	for key, value in pairs(rgb) do
		if SmallValue then value = value * 255 end
		local hex = ''

		while(value > 0)do
			local index = fmod(value, 16) + 1
			value = floor(value / 16)
			hex = sub('0123456789ABCDEF', index, index) .. hex			
		end
		
		if(len(hex) == 0)then
			hex = '00'

		elseif(len(hex) == 1)then
			hex = '0' .. hex
		end

		hexadecimal = hexadecimal .. hex
	end

	return hexadecimal
end

local HexToRGBReturn = {}
function E:HexToRgb(hex)
    hex = hex:gsub("#","")
	HexToRGBReturn.r = tonumber("0x"..hex:sub(1,2))
	HexToRGBReturn.g = tonumber("0x"..hex:sub(3,4))
	HexToRGBReturn.b = tonumber("0x"..hex:sub(5,6))
	
    return HexToRGBReturn
end

-- Split str after every space
function E:Split(str)
	t = {}
	for word in str:gmatch("%w+") do tinsert(t, word) end
	
	return t
end

function E:SplitAt(str, delimiter)
	delimiter = delimiter or '%s' -- Default to spaces
	
	local t = {}
	for word in str:gmatch('([^'..delimiter..']+)') do tinsert(t, '['..word) end
	
	return t
end

function E:FullSplit(inputstr, sep)
	local i = 1
	local t = {}
	if sep == nil then
			sep = "%s"
	end
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			t[i] = str
			i = i + 1
	end
	return t
end

function E:GetNPartOfName(str, n)
	if not str then return end
	
	local data = {}
	data = E:Split(str)
	
	return data[n]
end

function E:print_r(t)
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..rep(" ",len(pos)+8))
                        print(indent..rep(" ",len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end

function E:makePositive(num)
	if num < 0 then num = num * (-1) end
	return num
end

function E:removeDigits(str)
	return gsub(str, '%d+', '')
end

function E:ExtractDigits(str)
	local num = ""
	if match(str, "%d+") then
		num = match(str, "%d+")
	end
	local str = E:removeDigits(str)
	return str, num
end

function E:getDigits(str)
	return match(str, "%d+") or ""
end

function E:getFromGlobal()
	for n in pairs(_G) do 
		if match(tostring(n), "TRACKING") ~= nil then
			print(n)
		end
	end
end

function E:printChildren(parentFrame)
	local kids = { parentFrame:GetChildren() };

	for _, child in ipairs(kids) do
	  print(E:GetFrameName(child))
	end
end

function E:firstToUpper(str)
    return (str:gsub("^%l", upper))
end

function E:stringToUpper(str)
	return upper(str)
end

function E:stringToLower(str)
	return lower(str)
end

function E:StringReplace(str, searchStr, replaceStr)
	if not searchStr or not replaceStr then return end
	print(searchStr, type(searchStr), replaceStr, type(replaceStr), issecretvalue(replaceStr))
	
	if not issecretvalue(replaceStr) then
		return string.gsub(str, searchStr, replaceStr)
	else
		--/dump C_StringUtil.WrapString("b", "a", "c")
		local Buffer = string.gsub(str, searchStr, '%%s')
		return string.format(Buffer, replaceStr)
	end
end

function E:getHighestFrameLevelChild(parentFrame)
local kids = { parentFrame:GetChildren() };
	local highestChild = nil
	local lastLevel = 0

	for _, child in ipairs(kids) do
		if child:GetFrameLevel() > lastLevel then
			lastLevel = child:GetFrameLevel()
			highestChild = child
		end
	end
	
	return highestChild
end

function E:GetBiggestChildrenInfo(parentFrame)
	local kids = { parentFrame:GetChildren() };
	local biggestChild = nil
	local lastX = 1
	local lastY = 1

	for _, child in ipairs(kids) do
		if child:GetWidth() > lastX or child:GetHeight() > lastY then
			if child:GetWidth() > lastX and lastX then
				lastX = child:GetWidth()
			end
			if child:GetHeight() > lastY and lastY then
				lastY = child:GetHeight()
			end
			
			biggestChild = E:GetFullFrameName(child)
		end
	end
	
	return biggestChild, lastX, lastY
end

-- Micro optimizations
local NUMBERFORMAT_BASE 			= '%s%s'
local NUMBERFORMAT_LOWNUMBER_BASE	= "%.0f"

local Suffix_Met_T, Suffix_Met_G, Suffix_Met_M, Suffix_Met_K = ' T', ' G', ' M', ' K'
function E:FormatNumber_Metric(placeValue, num)
	if num >= 1e12 then
		return format(NUMBERFORMAT_BASE, placeValue:format(num / 1e12), Suffix_Met_T)
    elseif num >= 1e9 then
		return format(NUMBERFORMAT_BASE, placeValue:format(num / 1e9), Suffix_Met_G)
    elseif num >= 1e6 then
		return format(NUMBERFORMAT_BASE, placeValue:format(num / 1e6), Suffix_Met_M)
    elseif num >= 1e3 then
		return format(NUMBERFORMAT_BASE, placeValue:format(num / 1e3), Suffix_Met_K)
    end
	
	return NUMBERFORMAT_LOWNUMBER_BASE:format(num)
end

local Suffix_Ger_Bio, Suffix_Ger_Mrd, Suffix_Ger_Mio, Suffix_Ger_Tsd = ' Bio', ' Mrd', ' Mio', ' Tsd'
function E:FormatNumber_German(placeValue, num)
	if num >= 1e12 then
		return format(NUMBERFORMAT_BASE, placeValue:format(num / 1e12), Suffix_Ger_Bio)
    elseif num >= 1e9 then
		return format(NUMBERFORMAT_BASE, placeValue:format(num / 1e9), Suffix_Ger_Mrd)
    elseif num >= 1e6 then
		return format(NUMBERFORMAT_BASE, placeValue:format(num / 1e6), Suffix_Ger_Mio)
    elseif num >= 1e3 then
		return format(NUMBERFORMAT_BASE, placeValue:format(num / 1e3), Suffix_Ger_Tsd)
    end
	
	return NUMBERFORMAT_LOWNUMBER_BASE:format(num)
end

local Suffix_Kor_8, Suffix_Kor_4, Suffix_Kor_3 = '억', '만', '천'
function E:FormatNumber_Korean(placeValue, num)
	if num >= 1e8 then
		return format(NUMBERFORMAT_BASE, placeValue:format(num / 1e8), Suffix_Kor_8)
	elseif num >= 1e4 then
		return format(NUMBERFORMAT_BASE, placeValue:format(num / 1e4), Suffix_Kor_4)
	elseif num >= 1e3 then
		return format(NUMBERFORMAT_BASE, placeValue:format(num / 1e3), Suffix_Kor_3)
	end
	
	return NUMBERFORMAT_LOWNUMBER_BASE:format(num)
end

local Suffix_Eng_T, Suffix_Eng_B, Suffix_Eng_M, Suffix_Eng_K = ' T', ' B', ' M', ' K'
function E:FormatNumber_English(placeValue, num)
	if num >= 1e12 then
		return format(NUMBERFORMAT_BASE, placeValue:format(num / 1e12), Suffix_Eng_T)
    elseif num >= 1e9 then
		return format(NUMBERFORMAT_BASE, placeValue:format(num / 1e9), Suffix_Eng_B)
    elseif num >= 1e6 then
		return format(NUMBERFORMAT_BASE, placeValue:format(num / 1e6), Suffix_Eng_M)
    elseif num >= 1e3 then
		return format(NUMBERFORMAT_BASE, placeValue:format(num / 1e3), Suffix_Eng_K)
    end
	
	return NUMBERFORMAT_LOWNUMBER_BASE:format(num)
end

local Suffix_Chi_8, Suffix_Chi_4 = 'Y', 'W'
function E:FormatNumber_Chinese(placeValue, num)
	if num >= 1e8 then
		return format(NUMBERFORMAT_BASE, placeValue:format(num / 1e8), Suffix_Chi_8)
	elseif num >= 1e4 then
		return format(NUMBERFORMAT_BASE, placeValue:format(num / 1e4), Suffix_Chi_4)
	end
	
	return NUMBERFORMAT_LOWNUMBER_BASE:format(num)
end











----------------------------------------------------------------------------


E.Abbreviate = {}
E.ShortPrefixValues = {}
E.ShortPrefixStyles = {
	CHINESE = {{1e12,'兆'}, {1e8,'亿'}, {1e4,'万'}},
	TCHINESE = {{1e12,'兆'}, {1e8,'億'}, {1e4,'萬'}},
	KOREAN = {{1e12,'조'}, {1e8,'억'}, {1e4,'만'}},
	ENGLISH = {{1e12,'T'}, {1e9,'B'}, {1e6,'M'}, {1e3,'K'}},
	GERMAN = {{1e12,'Bio'}, {1e9,'Mrd'}, {1e6,'Mio'}, {1e3,'Tsd'}},
	METRIC = {{1e12,'T'}, {1e9,'G'}, {1e6,'M'}, {1e3,'k'}}
}

E.GetFormattedTextStyles = {
	CURRENT = '%s',
	CURRENT_MAX = '%s - %s',
	CURRENT_PERCENT = '%s - %.1f%%',
	CURRENT_MAX_PERCENT = '%s - %s | %.1f%%',
	PERCENT = '%.1f%%',
	DEFICIT = '-%s',
}


	local asianUnits = {
		CHINESE = E.ShortPrefixStyles.CHINESE,
		TCHINESE = E.ShortPrefixStyles.TCHINESE,
		KOREAN = E.ShortPrefixStyles.KOREAN,
	}

	local westernUnits = {
		ENGLISH = E.ShortPrefixStyles.ENGLISH,
		GERMAN = E.ShortPrefixStyles.GERMAN,
		METRIC = E.ShortPrefixStyles.METRIC
	}

	local westernDivisors = {
		[0] = {1e12, 1e9, 1e6, 1e3},
		{1e11, 1e8, 1e5, 1e2},
		{1e10, 1e7, 1e4, 1e1},
		{1e9, 1e6, 1e3, 1e0},
	}

	local asianDivisors = {
		1e11, 1e7, 1e3
	}

	local short = { breakpoints = {} }
	local long = { long = true }

	E.Abbreviate.short = short
	E.Abbreviate.long = long

	local function BuildAbbreviateConfigs()

		local style = 'METRIC'
		local asian = asianUnits[style]
		local units = asian or westernUnits[style or 'ENGLISH']

		long.isAsian = asian
		short.isAsian = asian

		local decimal = 1
		if decimal > 3 then decimal = 3 end

		local signi = (asian and asianDivisors) or westernDivisors[decimal]
		local factor = (asian and 10) or (10 ^ decimal)

		for i = 1, (asian and 3) or 4 do
			local unit = units[i]

			short.breakpoints[i] = {
				breakpoint = unit[1],
				abbreviation = unit[2],
				significandDivisor = signi[i],
				fractionDivisor = factor,
				abbreviationIsGlobal = false
			}
		end

		if CreateAbbreviateConfig then
			short.config = CreateAbbreviateConfig(short.breakpoints)

			wipe(short.breakpoints)
		end
    end

BuildAbbreviateConfigs()





----------------------------------------------------------------------------













function E:readableNumber(num, places)
    local ret, placeValue
    placeValue = ("%%.%df"):format(places or 1)
	
    if not num then
        return 0
	else
		--ret = E:NumberFormatFunc(placeValue, num)
		ret = AbbreviateNumbers(num, short)
	end
    
	-- To correctly format to target delimiter
	if ret ~= nil then
		return ret
	end
end

function E:FormatMoney(copper, breakupNumbers)
	--return (("%dg %ds %dc"):format(copper / 100 / 100, (copper / 100) % 100, copper % 100))
	-- BreakUpLargeNumbers
	return GetMoneyString(copper, breakupNumbers)
end

local timeYears, timeMonths, timeDays, timeHours, timeMinutes = 3600*24*356, 3600*24*31, 3600*24, 3600, 60

function E:GetFormattedCooldownTime(time, places)
	if time > 0 then
		if time > timeMinutes then
			if time > 300 then
				if time > timeHours then
					if time > timeDays then
						time = format('%sd', E:GetFloat(time / timeDays, places))
					else
						time = format('%sh', E:GetFloat(time / timeHours, places))
					end
				else
					time = format('%sm', E:GetFloat(time / timeMinutes, places))
				end
			else
				time = format('%d:%02d', time / timeMinutes, time % timeMinutes)
				places = 0
			end
		else
			time = E:GetFloat(time, places)
		end
	else
		time = ''
		places = 0
	end
	
	return time, places
end

-- Optimization through pre-calculating the timings
local TimeStr
function E:FormatTime(s, places)
	if not places then places = 0 end
	
	if s >= timeYears then
		TimeStr = E:Round(s / timeYears, places) .. "Y"
	elseif s >= timeMonths then
		TimeStr = E:Round(s / timeMonths, places) .. "M"
	elseif s >= timeDays then
		TimeStr = E:Round(s / timeDays, places) .. "d"
	elseif s >= timeHours then
		TimeStr = E:Round(s / timeHours, places) .. "h"
	elseif s >= timeMinutes then
		TimeStr = E:Round(s / timeMinutes, places) .. "m"
	elseif s >= 0 then
		if s / 60 > 1 then
			TimeStr = E:Round(s / 60,places) .. "m"
		else
			TimeStr = E:Round(s,places)
		end
	end
	
	return TimeStr, places
end

function E:FormatTimeSimple(seconds)
	return date('%H:%M:%S', seconds)
end

function E:FormatDate(timeStr)
	return date('%B %d, %Y', timeStr)
end

local units = {"player", "pet", "target", "targettarget", "focus", "focustarget", "party", "raid", "boss"}
function E:ExtractUnit(unit)
	local unit, unitNum = E:ExtractDigits(unit)
	
	for k,v in pairs(units) do
		if match(lower(unit), v) then
			return v .. unitNum
		end
	end
end

local RoundMultiplier = 0
function E:Round(num, numDecimalPlaces)
	RoundMultiplier = 10^(numDecimalPlaces or 0)
	return floor(num * RoundMultiplier + 0.5) / RoundMultiplier
end

function E:RoundToNearest(num)
	return tonumber(string.format("%.0f", num))
end

local function Remove(self)
	if self.UnregisterAllEvents then
		self:UnregisterAllEvents()
	else
		self.Show = self.Hide
	end

	self:SetScript("OnShow", function(self) self:Hide() end)
	self:Hide()
end

-- We use this to basically copy the separate default tables into the massive combined one.
-- This is a fix we need to properly access the original values at any given time.
-- NOTE: This WILL cause a stack-overflow with big tables
function E:TableDeepCopy(t) -- deep-copy a table
    if type(t) ~= "table" then return t end
    local meta = getmetatable(t)
    local target = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            target[k] = self:TableDeepCopy(v)
        else
            target[k] = v
        end
    end
    setmetatable(target, meta)
    return target
end

function E:TableMove(t, old, new)
    local value = t[old]
    if new < old then
       table.move(t, new, old - 1, new + 1)
    else    
       table.move(t, old + 1, new, old) 
    end
    t[new] = value
end

function E:TableMerge(target, source)
    for k,v in pairs(source) do
        if type(v) == "table" then
            if type(target[k] or false) == "table" then
                self:TableMerge(target[k] or {}, source[k] or {})
            else
                target[k] = v
            end
        else
            target[k] = v
        end
    end
    return target
end

-- Provides an easy way to retrieve color information from a table
function E:GetRGB(Data)
	return Data.r or Data[1], Data.g or Data[2], Data.b or Data[3], Data.a or Data[4]
end

function E:GetFloat(Number, Decimals)
	return format(('%%.%df'):format(Decimals), Number), Decimals
end

function E:GetItemLinkInfo(ItemLink)
	local LinkInfo = {}
	LinkInfo.itemName, LinkInfo.itemLink, LinkInfo.itemRarity, LinkInfo.itemLevel, LinkInfo.itemMinLevel, LinkInfo.itemType,
	LinkInfo.itemSubType, LinkInfo.itemStackCount, LinkInfo.itemEquipLoc, LinkInfo.itemTexture, LinkInfo.itemSellPrice =
		GetItemInfo(ItemLink)
	
	return LinkInfo
end

function E:GetAllSpecInfo()
	if not E.SpecInfo then
		E.SpecInfo = {}
		
		for i=1, GetNumClasses() do
			if not E.SpecInfo[i] then
				E.SpecInfo[i] = {}
			end
			
			for a=1, GetNumSpecializationsForClassID(i) do
				E.SpecInfo[i][a] = {}
				E.SpecInfo[i][a].SpecID, E.SpecInfo[i][a].SpecName, _, E.SpecInfo[i][a].IconID = GetSpecializationInfoForClassID(i, a)
			end
		end
	end
	
	return E.SpecInfo
end


local function AddAPI(object)
	local metatable = getmetatable(object).__index
	if not object.Remove then metatable.Remove = Remove end
end

local frame = CreateFrame("Frame")
AddAPI(frame)