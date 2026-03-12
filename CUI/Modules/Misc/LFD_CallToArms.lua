-- Use this to get the "DungeonID" of the currently selected Type
-- /dump LFDQueueFrame.type

--[[

local dungeonID = LFDQueueFrame.type;
	LFG_SetRoleIconIncentive(LFDQueueFrameRoleButtonTank, nil);
	LFG_SetRoleIconIncentive(LFDQueueFrameRoleButtonHealer, nil);
	LFG_SetRoleIconIncentive(LFDQueueFrameRoleButtonDPS, nil);

	local tankLocked, healerLocked, dpsLocked;
	local restrictedRoles = {[1]={count=0, alert=false}, -- tank
							 [2]={count=0, alert=false}, -- healer
							 [3]={count=0, alert=false}} -- dps
	if ( type(dungeonID) == "number" ) then
		tankLocked, healerLocked, dpsLocked = GetLFDRoleRestrictions(dungeonID);
		if ( not IsInGroup(LE_PARTY_CATEGORY_HOME) ) then
			for i=1, LFG_ROLE_NUM_SHORTAGE_TYPES do
				local eligible, forTank, forHealer, forDamage, itemCount, money, xp = GetLFGRoleShortageRewards(dungeonID, i);
				if ( eligible and (itemCount ~= 0 or money ~= 0 or xp ~= 0) ) then	--Only show the icon if there is actually a reward.
					if ( forTank ) then
						LFG_SetRoleIconIncentive(LFDQueueFrameRoleButtonTank, i);
					end
					if ( forHealer ) then
						LFG_SetRoleIconIncentive(LFDQueueFrameRoleButtonHealer, i);
					end
					if ( forDamage ) then
						LFG_SetRoleIconIncentive(LFDQueueFrameRoleButtonDPS, i);
					end
				end
			end
		end

]]

    -- local canTank, canHealer, canDamage = C_LFGList.GetAvailableRoles() 
    -- function updateShortageInfo(dID) 
        -- for j = 1, LFG_ROLE_NUM_SHORTAGE_TYPES do
            -- local eligible, tank, healer, damage, itemCount, money, xp = GetLFGRoleShortageRewards(dID, j)
            -- local tankLocked, healerLocked, damageLocked = GetLFDRoleRestrictions(dID)
            -- tank = tank and canTank and not tankLocked
            -- healer = healer and canHealer and not healerLocked
            -- damage = damage and canDamage and not damageLocked
            -- if(eligible and itemCount > 0 and (tank or healer or damage)) then
                
                
                -- local rewardName, rewardIcon = GetLFGDungeonShortageRewardInfo(dID, j, 1)
                -- data[dID] = {dID=dID, name=GetLFGDungeonInfo(dID), rewardName=rewardName, rewardIcon=rewardIcon, tank=tank, healer=healer, damage=damage}
                -- r = true
            -- end
        -- end
    -- end
    
    -- for i = 1, GetNumRandomDungeons() do
        -- local dID = GetLFGRandomDungeonInfo(i)
        -- updateShortageInfo(dID)
    -- end
    
    -- for i = 1,GetNumRFDungeons() do
        -- local dID = GetRFDungeonInfo(i)
        -- updateShortageInfo(dID)
    -- end
	
-- function CTA:Init()
	-- canTank, canHealer, canDamage = C_LFGList.GetAvailableRoles() 
-- end
-- E:AddModule("CallToArms", CTA)