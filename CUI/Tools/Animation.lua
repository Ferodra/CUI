local E, L = unpack(select(2, ...)) -- Engine, Locale

--[[
	
	Direct branch from the Blizzard Frame Fade implementation
	
	We have to use our own implementation of UIFrameFade, since the default one
	doesn't check wether or not the frame is protected.
	That leads to 'Addon action blocked in Combat' messages.
	A.e.: Actionbar fading

]]--

-- Frame fading and flashing --

local FADEFRAMES = {}
local frameFadeManager = CreateFrame('FRAME');

-- Generic fade function
function E:UIFrameFade(frame, fadeInfo)
	if (not frame) then
		return;
	end
	if ( not fadeInfo.mode ) then
		fadeInfo.mode = 'IN';
	end
	local alpha;
	if ( fadeInfo.mode == 'IN' ) then
		if ( not fadeInfo.startAlpha ) then
			fadeInfo.startAlpha = 0;
		end
		if ( not fadeInfo.endAlpha ) then
			fadeInfo.endAlpha = 1.0;
		end
		alpha = 0;
	elseif ( fadeInfo.mode == 'OUT' ) then
		if ( not fadeInfo.startAlpha ) then
			fadeInfo.startAlpha = 1.0;
		end
		if ( not fadeInfo.endAlpha ) then
			fadeInfo.endAlpha = 0;
		end
		alpha = 1.0;
	end
	frame:SetAlpha(fadeInfo.startAlpha);

	frame.fadeInfo = fadeInfo;
	if not frame:IsProtected() then
		frame:Show();
	end

	local index = 1;
	while FADEFRAMES[index] do
		-- If frame is already set to fade then return
		if ( FADEFRAMES[index] == frame ) then
			return;
		end
		index = index + 1;
	end
	tinsert(FADEFRAMES, frame);
	frameFadeManager:SetScript('OnUpdate', E.UIFrameFade_OnUpdate);
end

-- Convenience function to do a simple fade in
function E:UIFrameFadeIn(frame, timeToFade, startAlpha, endAlpha)
	-- Just start process if we really have to fade
	if not (startAlpha >= 1 and endAlpha >= 1) then
		local fadeInfo = {};
		fadeInfo.mode = 'IN';
		fadeInfo.timeToFade = timeToFade;
		fadeInfo.startAlpha = startAlpha;
		fadeInfo.endAlpha = endAlpha;
		self:UIFrameFade(frame, fadeInfo);
	else
		frame:Show()
		frame:SetAlpha(1)
	end
end

-- Convenience function to do a simple fade out
function E:UIFrameFadeOut(frame, timeToFade, startAlpha, endAlpha)
	-- Just start process if we really have to fade
	if not (startAlpha <= 0 and endAlpha <= 0) then
		local fadeInfo = {};
		fadeInfo.mode = 'OUT';
		fadeInfo.timeToFade = timeToFade;
		fadeInfo.startAlpha = startAlpha;
		fadeInfo.endAlpha = endAlpha;
		self:UIFrameFade(frame, fadeInfo);
	else
		frame:Hide()
		frame:SetAlpha(0)
	end
end

function E:UIFrameFadeRemoveFrame(frame)
	tDeleteItem(FADEFRAMES, frame);
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
	local index = 1;
	local frame, fadeInfo;
	while FADEFRAMES[index] do
		frame = FADEFRAMES[index];
		fadeInfo = FADEFRAMES[index].fadeInfo;
		-- Reset the timer if there isn't one, this is just an internal counter
		if ( not fadeInfo.fadeTimer ) then
			fadeInfo.fadeTimer = 0;
		end
		fadeInfo.fadeTimer = fadeInfo.fadeTimer + elapsed;

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

		index = index + 1;
	end

	if ( #FADEFRAMES == 0 ) then
		self:SetScript('OnUpdate', nil);
	end
end