---@class E, L
local E, L = unpack(select(2, ...)) -- Engine, Locale

--[[
	
	Direct branch from the Blizzard Frame Fade implementation
	
	We have to use our own implementation of UIFrameFade, since the default one
	doesn't check wether or not the frame is protected.
	That leads to 'Addon action blocked in Combat' messages.
	
	ALSO
	It friggin taints lots of blizzard code if we run it in AddOns!!!!!!
	
	
	A.e.: Actionbar fading

]]--

-- Frame fading and flashing --

local FADEFRAMES = {}
local frameFadeManager = CreateFrame('FRAME', "CUI_FrameFadeManager");
frameFadeManager.delay = 0 -- Delay each update tick

-- Generic fade function
function E:UIFrameFade(frame, fadeInfo)	
	if not frame then
		return
	end
	if issecretvalue(fadeInfo.startAlpha) or issecretvalue(fadeInfo.endAlpha) then return end
	
	frame.fadeInfo = fadeInfo
	
	if not fadeInfo.mode then
		fadeInfo.mode = 'IN'
	end
	local alpha;
	if ( fadeInfo.mode == 'IN' ) then
		fadeInfo.startAlpha = fadeInfo.startAlpha or 0
		fadeInfo.endAlpha 	= fadeInfo.endAlpha or 1.0
	elseif ( fadeInfo.mode == 'OUT' ) then
		fadeInfo.startAlpha = fadeInfo.startAlpha or 1.0
		fadeInfo.endAlpha 	= fadeInfo.endAlpha or 0
	end
	
	if not (frame:IsProtected() and InCombatLockdown()) then
		frame:Show();
	end

	if not FADEFRAMES[frame] then
		FADEFRAMES[frame] = fadeInfo
		frameFadeManager:SetScript('OnUpdate', E.UIFrameFade_OnUpdate)
	else
		FADEFRAMES[frame] = fadeInfo
	end
end

-- Convenience function to do a simple fade in
function E:UIFrameFadeIn(frame, timeToFade, startAlpha, endAlpha, finishedFunc, finishedArg1)
	if not frame or frame:IsForbidden() then return end
	
	frame.FadeData = frame.FadeData or {}
	frame.FadeData.fadeTimer = nil
	
	frame.FadeData.mode = 'IN'
	frame.FadeData.timeToFade = timeToFade
	frame.FadeData.startAlpha = startAlpha
	frame.FadeData.endAlpha = endAlpha
	frame.FadeData.finishedFunc = finishedFunc
	frame.FadeData.finishedArg1 = finishedArg1
	
	self:UIFrameFade(frame, frame.FadeData)
end

-- Convenience function to do a simple fade out
function E:UIFrameFadeOut(frame, timeToFade, startAlpha, endAlpha, finishedFunc, finishedArg1)
	if not frame or frame:IsForbidden() then return end
	
	frame.FadeData = frame.FadeData or {}
	frame.FadeData.fadeTimer = nil
	
	frame.FadeData.mode = 'OUT'
	frame.FadeData.timeToFade = timeToFade
	frame.FadeData.startAlpha = startAlpha
	frame.FadeData.endAlpha = endAlpha
	frame.FadeData.finishedFunc = finishedFunc
	frame.FadeData.finishedArg1 = finishedArg1
	
	self:UIFrameFade(frame, frame.FadeData)
end

function E:UIFrameFadeRemoveFrame(frame)
	if frame and FADEFRAMES[frame] then
		if frame.FadeData then
			frame.FadeData.fadeTimer = nil
		end

		FADEFRAMES[frame] = nil
	end
end

-- Function that actually performs the alpha change
--[[
Fading frame attribute listing
============================================================
frame.timeToFade  [Num]		Time it takes to fade the frame in or out
frame.mode  ['IN', 'OUT']	Fade mode
frame.finishedFunc [func()]	Function that is called when fading is finished
frame.finishedArg1 [ANYTHING]	Argument to the finishedFunc
frame.finishedArg2 [ANYTHING]	Argument to the finishedFunc
frame.finishedArg3 [ANYTHING]	Argument to the finishedFunc
frame.finishedArg4 [ANYTHING]	Argument to the finishedFunc
frame.fadeHoldTime [Num]	Time to hold the faded state
 ]]

function E:UIFrameFade_OnUpdate(elapsed)	
	self.timer = (self.timer or 0) + elapsed

	if self.timer > self.delay then
		self.timer = 0
		
		for frame, fadeInfo in next, FADEFRAMES do
			
			if issecretvalue(fadeInfo.startAlpha) or issecretvalue(fadeInfo.endAlpha) then 
				FADEFRAMES[frame] = nil
				return
			end
			
			-- Reset the timer if there isn't one, this is just an internal counter
			if frame:IsVisible() then
				fadeInfo.fadeTimer = (fadeInfo.fadeTimer or 0) + (elapsed + self.delay)
			else
				fadeInfo.fadeTimer = fadeInfo.timeToFade + 1
			end

			-- If the fadeTimer is less then the desired fade time then set the alpha otherwise hold the fade state, call the finished function, or just finish the fade
			if ( fadeInfo.fadeTimer < fadeInfo.timeToFade ) then
				if ( fadeInfo.mode == 'IN' ) then
					frame:SetAlpha((fadeInfo.fadeTimer / fadeInfo.timeToFade) * (fadeInfo.endAlpha - fadeInfo.startAlpha) + fadeInfo.startAlpha);
				elseif ( fadeInfo.mode == 'OUT' ) then
					frame:SetAlpha(((fadeInfo.timeToFade - fadeInfo.fadeTimer) / fadeInfo.timeToFade) * (fadeInfo.startAlpha - fadeInfo.endAlpha)  + fadeInfo.endAlpha);
				end
			else
				frame:SetAlpha(fadeInfo.endAlpha);
				-- If there is a fadeHoldTime then wait until its passed to continue on
				if ( fadeInfo.fadeHoldTime and fadeInfo.fadeHoldTime > 0  ) then
					fadeInfo.fadeHoldTime = fadeInfo.fadeHoldTime - elapsed;
				else
					-- Complete the fade and call the finished function if there is one
					E:UIFrameFadeRemoveFrame(frame);
					if ( fadeInfo.finishedFunc ) then
						fadeInfo.finishedFunc(fadeInfo.finishedArg1, fadeInfo.finishedArg2, fadeInfo.finishedArg3, fadeInfo.finishedArg4);
						fadeInfo.finishedFunc = nil;
					end
				end
			end
		end
	end

	if not next(FADEFRAMES) then
		self:SetScript('OnUpdate', nil)
	end
end


-------------
-- FLASH
-----------------------------

local FLASHFRAMES = {}
local frameFlashManager = CreateFrame("FRAME", "CUI_FrameFlashManager");

local UIFrameFlashTimers = {};
local UIFrameFlashTimerRefCount = {};

-- Function to start a frame flashing
function E:UIFrameFlash(frame, fadeInTime, fadeOutTime, flashDuration, showWhenDone, flashInHoldTime, flashOutHoldTime, syncId)
	if ( frame ) then
		local index = 1;
		-- If frame is already set to flash then return
		while FLASHFRAMES[index] do
			if ( FLASHFRAMES[index] == frame ) then
				return;
			end
			index = index + 1;
		end

		if (syncId) then
			frame.syncId = syncId;
			if (UIFrameFlashTimers[syncId] == nil) then
				UIFrameFlashTimers[syncId] = 0;
				UIFrameFlashTimerRefCount[syncId] = 0;
			end
			UIFrameFlashTimerRefCount[syncId] = UIFrameFlashTimerRefCount[syncId]+1;
		else
			frame.syncId = nil;
		end

		-- Time it takes to fade in a flashing frame
		frame.fadeInTime = fadeInTime;
		-- Time it takes to fade out a flashing frame
		frame.fadeOutTime = fadeOutTime;
		-- How long to keep the frame flashing, -1 means forever
		frame.flashDuration = flashDuration;
		-- Show the flashing frame when the fadeOutTime has passed
		frame.showWhenDone = showWhenDone;
		-- Internal timer
		frame.flashTimer = 0;
		-- How long to hold the faded in state
		frame.flashInHoldTime = flashInHoldTime;
		-- How long to hold the faded out state
		frame.flashOutHoldTime = flashOutHoldTime;

		tinsert(FLASHFRAMES, frame);

		frameFlashManager:SetScript("OnUpdate", E.UIFrameFlash_OnUpdate);
	end
end

-- Called every frame to update flashing frames
function E:UIFrameFlash_OnUpdate(elapsed)
	local frame;
	local index = #FLASHFRAMES;

	-- Update timers for all synced frames
	for syncId, timer in pairs(UIFrameFlashTimers) do
		UIFrameFlashTimers[syncId] = timer + elapsed;
	end

	while FLASHFRAMES[index] do
		frame = FLASHFRAMES[index];
		frame.flashTimer = frame.flashTimer + elapsed;

		if ( (frame.flashTimer > frame.flashDuration) and frame.flashDuration ~= -1 ) then
			E:UIFrameFlashStop(frame);
		else
			local flashTime = frame.flashTimer;
			local alpha;

			if (frame.syncId) then
				flashTime = UIFrameFlashTimers[frame.syncId];
			end

			flashTime = flashTime%(frame.fadeInTime+frame.fadeOutTime+(frame.flashInHoldTime or 0)+(frame.flashOutHoldTime or 0));
			if (flashTime < frame.fadeInTime) then
				alpha = flashTime/frame.fadeInTime;
			elseif (flashTime < frame.fadeInTime+(frame.flashInHoldTime or 0)) then
				alpha = 1;
			elseif (flashTime < frame.fadeInTime+(frame.flashInHoldTime or 0)+frame.fadeOutTime) then
				alpha = 1 - ((flashTime - frame.fadeInTime - (frame.flashInHoldTime or 0))/frame.fadeOutTime);
			else
				alpha = 0;
			end

			frame:SetAlpha(alpha);
			if not frame:IsProtected() then
				frame:Show();
			end
		end

		-- Loop in reverse so that removing frames is safe
		index = index - 1;
	end

	if ( #FLASHFRAMES == 0 ) then
		self:SetScript("OnUpdate", nil);
	end
end

-- Function to see if a frame is already flashing
function E:UIFrameIsFlashing(frame)
	for index, value in pairs(FLASHFRAMES) do
		if ( value == frame ) then
			return 1;
		end
	end
	return nil;
end

-- Function to stop flashing
function E:UIFrameFlashStop(frame)
	tDeleteItem(FLASHFRAMES, frame);
	frame:SetAlpha(1.0);
	frame.flashTimer = nil;
	if (frame.syncId) then
		UIFrameFlashTimerRefCount[frame.syncId] = UIFrameFlashTimerRefCount[frame.syncId]-1;
		if (UIFrameFlashTimerRefCount[frame.syncId] == 0) then
			UIFrameFlashTimers[frame.syncId] = nil;
			UIFrameFlashTimerRefCount[frame.syncId] = nil;
		end
		frame.syncId = nil;
	end
	if not (frame:IsProtected() and InCombatLockdown()) then
		if ( frame.showWhenDone ) then
			frame:Show();
		else
			frame:Hide();
		end
	end
end