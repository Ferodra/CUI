local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, L, PO = E:LoadModules("Config", "Locale", "PerformanceOptimizer")

local _

PO.Autoload = true

PO.E = CreateFrame("Frame")
PO.RangeTimer = 0
local CurrentValue
local LastAverageValue = 0
local AverageValue = 0 -- Current average framerate
local AverageTickCount = 0
local AverageTicks = {} -- Store ticks to compute the average over UPDATE_FREQUENCY seconds
local AverageTimer = 0
local TARGET_FRAMERATE, FRAMERATE_TOLERANCE, CURRENT_FRAMERATE_AVERAGE, GFX_SETTINGS, AVERAGE_UPDATE_FREQUENCY, UPDATE_FREQUENCY, AVERAGE_IMPROVEMENT_THRESHOLD

	AVERAGE_IMPROVEMENT_THRESHOLD = 5 -- Average should improve by a minimum of X before setting everything higher
	TARGET_FRAMERATE = 60
	FRAMERATE_TOLERANCE = 7.5
	GFX_SETTINGS = {[1] = "graphicsViewDistance", [2] = "graphicsShadowQuality", [3] = "graphicsLiquidDetail", [4] = "graphicsSSAO"}
	
	AVERAGE_UPDATE_FREQUENCY = 0.1 -- How often the average framerate should be updated (in seconds)
	UPDATE_FREQUENCY = 4 -- How often the analysis should be performed (in seconds)

	-- hooksecurefunc("SetCVar", print) -- To find out what CVars there are
	
function PO:Optimize()
	
	AverageTickCount = 0
	
	-- Process average data first
	for k,v in pairs(AverageTicks) do
		AverageValue = AverageValue + v -- Add tick value to total
		AverageTickCount = AverageTickCount + 1
	end
	
	-- Results finally in an average framerate over the course of UPDATE_FREQUENCY seconds. Each check was made in AVERAGE_UPDATE_FREQUENCY intervals.
	AverageValue = AverageValue / AverageTickCount
	
	CurrentValue = 1
	-- If our tolerance of stuttering is over
	if (AverageValue < TARGET_FRAMERATE - FRAMERATE_TOLERANCE) then
		-- Only update if average improved by 
		if AverageValue > LastAverageValue then
			-- @TODO:
			-- Create a priority table of most affecting settings
			-- We HAVE to rely on an average framerate over a timespan of X seconds to get proper results.
			-- Also, this system has to be somewhat intelligent and lower settings that do not affect the visual quality that much
			-- print("Down")
			for k,v in pairs(GFX_SETTINGS) do
				CurrentValue = GetCVar(v)
				if tonumber(CurrentValue) > 1 then
					SetCVar(v, CurrentValue - 1)
				end
			end
		end
	else
		if AverageValue + AVERAGE_IMPROVEMENT_THRESHOLD > LastAverageValue and AverageValue >= TARGET_FRAMERATE then
			-- print("Up")
			for k,v in pairs(GFX_SETTINGS) do
				CurrentValue = GetCVar(v)
				if tonumber(CurrentValue) < 10 then
					SetCVar(v, CurrentValue + 1)
				end
			end
		end
	end
	
	LastAverageValue = AverageValue
end

function PO:ComputeAveragePerformance(elapsed)
	-- Check elapsed for any value less than UPDATE_FREQUENCY
	-- Compute average
	-- Reset average data otherwise
	
	local Timer = AverageTimer;
	if ( Timer ) then
		Timer = Timer - elapsed;

		if ( Timer <= 0 ) then
			table.insert(AverageTicks, GetFramerate())
			
			Timer = AVERAGE_UPDATE_FREQUENCY;
		end

		AverageTimer = Timer;
	end
end

function PO:Init()
	
	-- self.db = CO.db.profile.optimizer
	
	PO.E:SetScript("OnUpdate", function(self, elapsed)
		
		PO:ComputeAveragePerformance(elapsed) -- Fill data each frame
		
		if ( self.RangeTimer >= UPDATE_FREQUENCY ) then
			PO:Optimize()
			
			wipe(AverageTicks)
			
			RangeTimer = 0;
		end

	end)
end

-- E:AddModule("PerformanceOptimizer", PO) -- Uncomment to enable