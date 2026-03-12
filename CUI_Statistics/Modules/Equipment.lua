local E, L = unpack(CUI) -- Engine
local CO = E:LoadModules("Config")
local ST = select(2, ...)

local EQ = CreateFrame("Frame")
ST.Equipment = EQ

local ipairs	= ipairs
local pairs		= pairs
local format	= string.format
local tsort		= table.sort

function EQ:RemoveCharacter(key)
	CO.db.global.accountData.characters[key].armory = nil
	
	if self.CharList then
		--self:UpdateTotal()
		--self:UpdateAllWidgets()
	end
	
	if key then
		E:print(key .. L["PlaytimeCharacterRemoved"])
	end
end

-----------------------------------------------
local realmKey = GetRealmName()
local characterKey = UnitName("player") .. " - " .. realmKey

function EQ:Update()
	local Data = ST:PrepareCharacterData(characterKey).armory
	
	-- Write all slots to DB
	-- @TODO Maybe make it an option to save detailed info (Azerite, Gems, Enchants etc.) by saving the entire tooltip. This may completely wreck the database size, so don't do it for now!
	for i=1, 19 do
		Data[i] = GetInventoryItemLink("player", i)
	end
	Data['overallMaxItemlevel'], Data['overallItemlevel'] = GetAverageItemLevel()
	
	if not Data.talents then
		Data.talents = {}
	else
		wipe(Data.talents)
	end

	for tier = 1, 7 do
		for column = 1, 3 do
			local talentID, name, iconTexture, selected, available = GetTalentInfo(tier, column, GetActiveSpecGroup())
			if selected then
				if not Data.talents[tier] then
					Data.talents[tier] = {}
				end
				
				Data.talents[tier].column = column
				Data.talents[tier].id = talentID
				Data.talents[tier].texture = iconTexture
			end
		end
	end
end

function EQ:OnEvent(event, ...)
	self:Update()
end

function EQ:SetEventHandler()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	self:RegisterEvent("PLAYER_TALENT_UPDATE")
	
	self:SetScript("OnEvent", self.OnEvent)
end

function EQ:LoadConfig()
	self:UpdateState()
end

function EQ:UpdateState()	
	self:UnregisterAllEvents()
	if ST.db.global.armory.enable then
		self:SetEventHandler()
	end
end

function EQ:Construct()
	self:SetEventHandler()
end

function EQ:Init()	
	self.db = ST.db.global.armory
	ST:RegisterCharacterDataKey("armory")
	
	if self.db and self.db.enable then
		self:Construct()
	end
end