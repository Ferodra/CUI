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

function E:GetRandomTableKey(t)
	local keys, i = {}, 1
	for k,_ in pairs(t) do
	 keys[i] = k
	 i = i+1
	end
	-- then

	local m
	m = math.random(1,#keys)
	return keys[m]
end

function E:GetRandomTableEntry(t)
	local keys, i = {}, 1
	for k,_ in pairs(t) do
	 keys[i] = k
	 i = i+1
	end
	-- then

	local m
	m = math.random(1,#keys)
	return t[ keys[m] ]
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

function E:GetTablePath(Path, Source)
	local Separator = "."
    local Parts = {};
    local i = 1;
    for PathPart in string.gmatch(Path, "([^"..Separator.."]+)") do
        Parts[i] = PathPart;
        i = i + 1;
    end
	
	local Target

    for _, key in pairs(Parts) do
        Target = (Target and Target[key]) or Source[key]
    end
    return Target
end

function E:tableContainsValue(tbl, item, itemType)
    for key, value in pairs(tbl) do
		if itemType then
			if value == item and type(item) == itemType then return key end
		else
			if value == item then return key end
		end
    end
    return false
end

function E:tableContainsValueAtN(tbl, item, position)
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

function E:StringReplace(str, searchStrStr, replaceStr)
	return string.gsub(str, searchStrStr, replaceStr)
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

function E:FormatNumber_Metric(placeValue, num)
	if num >= 1e12 then
        return placeValue:format(num / 1e12) .. " T" -- trillion
    elseif num >= 1e9 then
        return placeValue:format(num / 1e9) .. " G" -- billion
    elseif num >= 1e6 then
        return placeValue:format(num / 1e6) .. " M" -- million
    elseif num >= 1e3 then
        return placeValue:format(num / 1e3) .. " K" -- thousand
    end
	
	return format("%.0f", num)
end

function E:FormatNumber_German(placeValue, num)
	if num >= 1e12 then
        return placeValue:format(num / 1e12) .. " Bio" -- trillion
    elseif num >= 1e9 then
        return placeValue:format(num / 1e9) .. " Mrd" -- billion
    elseif num >= 1e6 then
        return placeValue:format(num / 1e6) .. " Mio" -- million
    elseif num >= 1e3 then
        return placeValue:format(num / 1e3) .. " Tsd" -- thousand
    end
	
	return format("%.0f", num)
end

function E:FormatNumber_Korean(placeValue, num)
	if num >= 1e8 then
		return placeValue:format(num / 1e8) .."억"
	elseif num >= 1e4 then
		return placeValue:format(num / 1e4) .."만"
	elseif num >= 1e3 then
		return placeValue:format(num / 1e3) .."천"
	end
	
	return format("%.0f", num)
end

function E:FormatNumber_English(placeValue, num)
	if num >= 1e12 then
        return placeValue:format(num / 1e12) .. " T" -- trillion
    elseif num >= 1e9 then
        return placeValue:format(num / 1e9) .. " B" -- billion
    elseif num >= 1e6 then
        return placeValue:format(num / 1e6) .. " M" -- million
    elseif num >= 1e3 then
        return placeValue:format(num / 1e3) .. " K" -- thousand
    end
	
	return format("%.0f", num)
end

function E:FormatNumber_Chinese(placeValue, num)
	if num >= 1e8 then
		return placeValue:format(num / 1e8) .."Y"
	elseif num >= 1e4 then
		return placeValue:format(num / 1e4) .."W"
	end
	
	return format("%.0f", num)
end

function E:readableNumber(num, places)
    local ret, placeValue
    placeValue = ("%%.%df"):format(places or 1)
	
    if not num then
        return 0
	else
		ret = E:NumberFormatFunc(placeValue, num)
	end
    
	-- To correctly format to target delimiter
	if ret ~= nil then
		return ret
	end
end

function E:FormatMoney(copper, texture)
	--return (("%dg %ds %dc"):format(copper / 100 / 100, (copper / 100) % 100, copper % 100))
	return texture and GetCoinTextureString(copper) or GetCoinText(copper)
end

-- Optimization through pre-calculating the timings
local TimeStr
local timeYears, timeMonths, timeDays, timeHours, timeMinutes = 3600*24*356, 3600*24*31, 3600*24, 3600, 60
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
	
	return TimeStr
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

local function Remove(o)
	if o.UnregisterAllEvents then
		o:UnregisterAllEvents()
	else
		o.Show = o.Hide
	end

	o:SetScript("OnShow", function(self) self:Hide() end)
	o:Hide()
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

function E:TableMerge(t1, t2)
    for k,v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[k] or false) == "table" then
                E:TableMerge(t1[k] or {}, t2[k] or {})
            else
                t1[k] = v
            end
        else
            t1[k] = v
        end
    end
    return t1
end

-- Provides an easy way to retrieve color information from a table
function E:GetRGB(Data)
	return Data.r or Data[1], Data.g or Data[2], Data.b or Data[3], Data.a or Data[4]
end

function E:GetFloat(Number, Decimals)
	return format(('%%.%df'):format(Decimals), Number)
end

local LinkInfo = {}
function E:GetItemLinkInfo(l)
	LinkInfo.itemName, LinkInfo.itemLink, LinkInfo.itemRarity, LinkInfo.itemLevel, LinkInfo.itemMinLevel, LinkInfo.itemType,
	LinkInfo.itemSubType, LinkInfo.itemStackCount, LinkInfo.itemEquipLoc, LinkInfo.itemTexture, LinkInfo.itemSellPrice =
		GetItemInfo(l)
	
	return LinkInfo
end


local function AddAPI(object)
	local metatable = getmetatable(object).__index
	if not object.Remove then metatable.Remove = Remove end
end

local frame = CreateFrame("Frame")
AddAPI(frame)