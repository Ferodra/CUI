local E, L = unpack(CUI) -- Engine
local CO = E:LoadModules("Config")
local ST = select(2, ...)

local _
local _G						= _G
local pairs						= pairs
local unpack					= unpack
local select					= select
local tsort						= table.sort
local GetItemInfo				= GetItemInfo
local GetInventorySlotInfo		= GetInventorySlotInfo
local GetItemQualityColor		= GetItemQualityColor
local RAID_CLASS_COLORS			= RAID_CLASS_COLORS

local AceGUI 	= LibStub("AceGUI-3.0")
local EQ 		= ST.Equipment
local Module 	= CreateFrame("Frame")
local gui 		= ST.GUI

----------------------------------------------------

local DefaultRarityColor = {0.1, 0.1, 0.1}
local IDToSlotName = {
	[1] 	= "HEADSLOT",
	[2] 	= "NECKSLOT",
	[3] 	= "SHOULDERSLOT",
	[4] 	= "SHIRTSLOT",
	[5] 	= "CHESTSLOT",
	[6] 	= "WAISTSLOT",
	[7] 	= "LEGSSLOT",
	[8] 	= "FEETSLOT",
	[9] 	= "WRISTSLOT",
	[10] 	= "HANDSSLOT",
	[11] 	= "FINGER0SLOT",
	[12] 	= "FINGER1SLOT",
	[13] 	= "TRINKET0SLOT",
	[14] 	= "TRINKET1SLOT",
	[15] 	= "BACKSLOT",
	[16] 	= "MAINHANDSLOT",
	[17] 	= "SECONDARYHANDSLOT",
	--[18] 	= "RANGEDSLOT",
	[19] 	= "TABARDSLOT",
}
	--/dump GetInventorySlotInfo("INVTYPE_HEAD")

local CharsToRemove = {}
local function SetCharKeyToRemove(key)
	if not CharsToRemove[key] then
		-- Add on first call for this key
		CharsToRemove[key] = true
	else
		-- Remove when called again for this key
		CharsToRemove[key] = nil
	end
end

local function GetCharsToRemoveNum()
	local Count = 0
	for k,v in pairs(CharsToRemove) do
		if v then
			Count = Count + 1
		end
	end
	
	return Count
end

local function LoadCharacterOnClick(self)
	PlaySound(852) -- SOUNDKIT.IG_MAINMENU_OPTION
	local data = ST.db.global.characters[self.userdata.charKey]
	if not data then
		E:print("No Armory Data found for this character!")
		
		return
	end
	local charGroup = self.userdata.group
	local widget = self.userdata.widget
	
	if charGroup.userdata.hasChildren then
		charGroup.userdata.hasChildren = nil
		charGroup.hasContent = nil
		charGroup:ReleaseChildren()
		
		charGroup:DoLayout()
		widget:DoLayout()
		
		return
	end

	
	for i=1, 19 do
		if IDToSlotName[i] then
			local Button = AceGUI:Create("ItemButton")
			
			Texture, Rarity, RarityColor, ItemLevel, Desc, IsLink = nil, nil, nil, nil, nil, nil
			local Link = data.armory[i]
			
			if Link then
				_, _, Rarity, ItemLevel, _, _, _, _, _, Texture = GetItemInfo(Link)
				
				-- It CAN happen that we have a link but GetItemInfo doesn't return the proper data immediately.
				-- In that case, do another request a few frames later
				if not Texture then
					-- Really dirty way to go
					-- But we have to delay the request for the missing data, otherwise we will get the same result
					C_Timer.After(0.1, function()
						_, _, Rarity, ItemLevel, _, _, _, _, _, Texture = GetItemInfo(data.armory[i])
						if Texture then
							Button:SetTexture(Texture)
						end
						if Rarity then
							RarityColor = {GetItemQualityColor(Rarity)}
							Button:SetBorder(2, RarityColor[1], RarityColor[2], RarityColor[3])
							Button:SetTextColor(RarityColor[1], RarityColor[2], RarityColor[3])
						end
						if ItemLevel then
							Button:SetText(ItemLevel or "")
						end
					end)
				end
				
				if Rarity then
					RarityColor = {GetItemQualityColor(Rarity)}
				end
				IsLink = true
				Desc = Link
			else
				Desc = _G[IDToSlotName[i]]
			end
			
			if not Texture then
				Texture = select(2, GetInventorySlotInfo(IDToSlotName[i]))
			end
			if not Rarity then
				RarityColor = DefaultRarityColor
			end
			
			
			Button:SetTexture(Texture)
			Button:SetDescription(Desc, IsLink)
			Button:SetBorder(2, RarityColor[1], RarityColor[2], RarityColor[3])
			Button:SetTextColor(RarityColor[1], RarityColor[2], RarityColor[3])
			Button:SetText(ItemLevel or "")
			
			charGroup:AddChild(Button)
		end
	end
	
	if data.armory.talents then
		local spacer = AceGUI:Create("Heading")
		spacer:SetText(TALENTS)
		spacer:SetFullWidth(true)
		charGroup:AddChild(spacer)
		
		-- ["id"] = 22291,
		-- ["column"] = 1,
		-- ["texture"] = 132176,
	
		local ID, Texture
		for i=1, 7 do
			local Talent = AceGUI:Create("ItemButton")
			
			if data.armory.talents[i] then
				ID = data.armory.talents[i].id
				Texture = data.armory.talents[i].texture
			else
				ID = nil
				Texture = 134400
			end
			
			Talent:SetBorder(2, RAID_CLASS_COLORS[data.class]:GetRGB())
			Talent:SetTexture(Texture)
			Talent:SetText("")
			
			if Texture == 134400 then
				Talent:DisableButton()
			else
				Talent:EnableButton()
			end
			
			if ID then
				Talent:SetDescription(function()
					GameTooltip:SetOwner(Talent.frame, "ANCHOR_RIGHT")
					GameTooltip:SetTalent(data.armory.talents[i].id)
					
					_G["GameTooltipTextLeft" .. GameTooltip:NumLines()]:SetText("")
					GameTooltip:SetHeight(GameTooltip:GetHeight() - 25)
				end)
			end
			
			charGroup:AddChild(Talent)
		end
	end
	
	charGroup.userdata.hasChildren = true
	charGroup.hasContent = true
	charGroup:DoLayout()
	widget:DoLayout()
	
	-- Clear so we only do this once
	--self:SetScript("OnClick", nil)
end

local function SortChars( a,b )
	if (a.class < b.class) then
	   return true
	elseif (a.class > b.class) then
		return false
	else
		return a.overallItemlevel > b.overallItemlevel
	end
end
	

local function Callback(widget, event, value)
	local played
	local Class, Texture, Rarity, RarityColor, ItemLevel, Desc, IsLink
	
	-- Let's do some sorting
	local CharList = {}
	local Index = 1
	for name, v in pairs(ST.db.global.characters) do
		if v.class then
			CharList[Index] = {
				['key'] = name,
				['class'] = v.class,
				['overallItemlevel'] = v.armory and v.armory.overallItemlevel or 0,
			}
			
			Index = Index + 1
		end
	end
	
	tsort( CharList, SortChars )
	
	for index, v in ipairs(CharList) do
		local Data = ST.db.global.characters[v.key]
		if Data.armory then
			local charGroup = AceGUI:Create("CharacterGroup")
			charGroup:SetTitle(("[%s]  %s"):format(Data.level, v.key))
			charGroup:SetLayout("Flow")
			charGroup:SetFullWidth(true)
			widget:AddChild(charGroup)
			
			Class = Data.class or "PRIEST"
			
			local IlvlStr
			
			if Data.armory.overallItemlevel then
				IlvlStr = E:Round(Data.armory.overallItemlevel, 2) or ""
				
				if Data.armory.overallMaxItemlevel then
					IlvlStr = ("%s (%s)"):format(IlvlStr, E:Round(Data.armory.overallMaxItemlevel, 2)) or ""
				end
			end

			charGroup:SetOverallItemlevel(IlvlStr or "")
			charGroup:SetClassIcon(Data.class)
			charGroup:SetSpecIcon(Data.specID and (select(4, GetSpecializationInfoByID(Data.specID))) or 134400)
			charGroup:SetFaction(Data.faction)
			charGroup:SetRace(Data.race, Data.sex)
			
			--charGroup:SetBGColor(RAID_CLASS_COLORS[Class]:GetRGB())
			charGroup:SetBGColor(unpack(E:GetClassColorByClassName(v.class)))
			
			charGroup:SetHeaderClickHandler(LoadCharacterOnClick, {["charKey"] = v.key, ["group"] = charGroup, ["widget"] = widget})
		end
	end
end

function Module:Init()
	gui:AddToTree("Equipment", "equipment", true, Callback)
end

gui:RegisterStatModule("equipment", Module)