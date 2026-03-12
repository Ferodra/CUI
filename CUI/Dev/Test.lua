local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO, CODE = E:LoadModules('Config', 'CustomCode')
-- General testing file for snippets etc

local Base = [[Interface\TALENTFRAME\]]

local function Test_ClassBG()
	local Tex = Base .. [[bg-druid-cat]]

	local Frame = CreateFrame('Frame', nil, E.Parent)
	Frame:SetFrameStrata('TOOLTIP')
	Frame:SetSize(420, 420)
	Frame:SetPoint('CENTER', E.Parent, 'CENTER')
	
	Frame.Tex = Frame:CreateTexture(nil)
	Frame.Tex:SetAllPoints(Frame)
	Frame.Tex:SetTexture(Tex)
	Frame.Tex:SetBlendMode('ADD')
	
	Frame.Mask = Frame:CreateMaskTexture()
	Frame.Mask:SetTexture("Interface\\AddOns\\CUI\\Textures\\Mask_Smooth-Left-Bottom", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
	--Frame.Mask:SetSize(420, 420)
	Frame.Mask:SetAllPoints(Frame)
	
	Frame.Tex:AddMaskTexture(Frame.Mask)
	--Frame.Tex:SetVertexColor(0.40, 0.23, 0.14) -- Correct color to better overlay with BG
	--Frame.Tex:SetVertexColor(0.341, 0.250, 0.196) -- Correct color to better overlay with BG
	Frame.Tex:SetVertexColor(0.537, 0.4, 0.321) -- Correct color to better overlay with BG
	
	Frame:SetMovable(true)
	Frame:EnableMouse(true)
	Frame:RegisterForDrag("LeftButton")
	Frame:SetScript("OnDragStart", Frame.StartMoving)
	Frame:SetScript("OnDragStop", Frame.StopMovingOrSizing)
end

local function Test_SpecNamesWithIcons()
	local IconSet = E:GetAllSpecInfo()
	
	for ClassID = 1, #IconSet do
		for SpecID = 1, #IconSet[ClassID] do
			print('|T' .. (IconSet[ClassID][SpecID].IconID or 'error') .. ':0|t ' .. E:GetClassColorizedText(IconSet[ClassID][SpecID].SpecName, ClassID))
		end
	end
end










local function SortFrames(Frames, Parent, Width, Height, SizeMult, PerRow, InverseStartX, InverseStartY, GapX, GapY, PrioritizeColumns)
	local currentRow, currentColumn, xOffset, yOffset, prefixX, prefixY = 0, 0, 0, 0, 0, 0
	local endRow, endColumn, index = 1, 1, 1
	local pointH, pointV, point, iterator
	
	SizeMult = SizeMult or 1
	if PerRow == 0 then PerRow = 1 end
	if PerRow < 0 then prefixX = -1; prefixY = -1; else prefixX = 1; prefixY = 1; end
	
	-- Perform Direction transform
	prefixX = prefixX * (InverseStartX and -1 or 1)
	prefixY = prefixY * (InverseStartY and -1 or 1)
	
	if prefixX < 0 then pointH = "RIGHT" else pointH = "LEFT" end
	if prefixY < 0 then pointV = "TOP" else pointV = "BOTTOM" end
	point = pointV .. pointH
	
	for _, child in pairs(Frames) do
	--------------------------------------------------------------------
		if not child.IgnoreSort then
			
			-- We have to use the previous column and row values to make it work properly
			xOffset = ((((Width * SizeMult) * currentColumn) + (GapX * currentColumn)) * prefixX) / SizeMult
			yOffset = ((((Height * SizeMult) * currentRow) + (GapY * currentRow)) * prefixY)  / SizeMult
			
			-- If the current button should start the next row
			if index % PerRow == 0 then
				if PrioritizeColumns then
					currentColumn = currentColumn + 1
					endColumn = endColumn + 1
					
					currentRow = 0
				else
					currentRow = currentRow + 1
				
					currentColumn = 0
				end
			else
				if PrioritizeColumns then
					currentRow = currentRow + 1
				else
					currentColumn = currentColumn + 1
				end
			end
			
			--E:MoveFrame(child, xOffset, yOffset)
			
			--------------------------------------------------------------------
			index = index + 1
		end
	end
	
	-- Post-iterate index correction, since we increment after each loop
	index = index - 1
	if PrioritizeColumns then
		endRow = math.abs(PerRow)
		endColumn = math.abs(endColumn) - 1
	else
		endColumn = math.abs(PerRow)
		endRow = math.abs(currentRow)
	end
	
	-- Start new row when needed to prevent false return values
	if index - (endColumn * endRow) > 0 then
		endRow = endRow + 1
	end
	-- Clamp EndWidth so we dont get overflow
	if endColumn > index then
		endColumn = index
	end
	
	if endColumn == 0 then
		endColumn = 1
	end
	
	--Width = Width or 0
	--Height = Height or 0
	
	local EndWidth = ((Width * SizeMult) + GapX) * (endColumn) - GapX
	local EndHeight = ((Height * SizeMult) + GapY) * (endRow) - GapY
	return EndWidth, EndHeight
end






local abs = math.abs
local function SortFramesOptimized(Frames, Parent, Width, Height, SizeMult, PerRow, InverseStartX, InverseStartY, GapX, GapY, PrioritizeColumns)
    local currentRow, currentColumn = 0, 0
    local endRow, endColumn, index = 1, 1, 1
    local prefixX, prefixY = 1, 1
    local pointH, pointV, point

    -- Use local variables for calculations that are constant across iterations
    local scaledWidth = Width * SizeMult
    local scaledHeight = Height * SizeMult
    local xMultiplier = scaledWidth + GapX
    local yMultiplier = scaledHeight + GapY

    -- Determine direction transforms once
    if PerRow < 0 then
        prefixX, prefixY = -1, -1
    end
    prefixX = prefixX * (InverseStartX and -1 or 1)
    prefixY = prefixY * (InverseStartY and -1 or 1)

    pointH = prefixX < 0 and "RIGHT" or "LEFT"
    pointV = prefixY < 0 and "TOP" or "BOTTOM"
    point = pointV .. pointH

    -- Loop through frames once
    for _, child in pairs(Frames) do
        if not child.IgnoreSort then
            -- Calculate x and y offsets only once
            local xOffset = (xMultiplier * currentColumn) * prefixX / SizeMult
            local yOffset = (yMultiplier * currentRow) * prefixY / SizeMult

            -- Move to next row/column if necessary
            if index % PerRow == 0 then
                if PrioritizeColumns then
                    currentColumn = currentColumn + 1
                    endColumn = endColumn + 1
                    currentRow = 0
                else
                    currentRow = currentRow + 1
                    currentColumn = 0
                end
            else
                if PrioritizeColumns then
                    currentRow = currentRow + 1
                else
                    currentColumn = currentColumn + 1
                end
            end

            index = index + 1
        end
    end

    -- Final adjustments after the loop
    index = index - 1
    if PrioritizeColumns then
        endRow = abs(PerRow)
        endColumn = abs(endColumn) - 1
    else
        endColumn = abs(PerRow)
        endRow = abs(currentRow)
    end

    if index - (endColumn * endRow) > 0 then
        endRow = endRow + 1
    end
    if endColumn > index then
        endColumn = index
    end
    if endColumn == 0 then
        endColumn = 1
    end

    -- Calculate final width and height
    local EndWidth = xMultiplier * endColumn - GapX
    local EndHeight = yMultiplier * endRow - GapY
    return EndWidth, EndHeight
end








-- Function to create 100 frames for testing
local function CreateTestFrames()
    local Frames = {}
    for i = 1, 100 do
        Frames[i] = { IgnoreSort = false }
    end
    return Frames
end

-- Timer function
local function TimeFunction(func, ...)
	debugprofilestart()
    --local startTime = (GetTime() - GetTickTime())  -- Get the current time before the function starts
	for i=1, 2000 do
		func(...) -- Call the function with provided arguments
	end	
    --local endTime = (GetTime() - GetTickTime())    -- Get the time after the function finishes
    return debugprofilestop()    -- Return the time taken in ms
end

-- Create test frames
local Frames = CreateTestFrames()
local Parent = {}  -- Dummy parent (you can leave it empty)
local Width = 100
local Height = 100
local SizeMult = 1
local PerRow = 10
local InverseStartX = false
local InverseStartY = false
local GapX = 10
local GapY = 10
local PrioritizeColumns = false



local EventCounter = {}
local TestState = false
local EventFrame = CreateFrame("Frame")
local function CheckAllEvents()
	E:debugprint("<STARTING EVENT COUNTER>")
	EventFrame:RegisterAllEvents()
	EventFrame:SetScript("OnEvent", function(self, event, ...)
		EventCounter[event] = (EventCounter[event] or 0) + 1
		
		--E:debugprint("Count for ", event, "is:", EventCounter[event])
	end)
end



local function Test()
	-- Test the original function
	--local originalTime = TimeFunction(SortFrames, Frames, Parent, Width, Height, SizeMult, PerRow, InverseStartX, InverseStartY, GapX, GapY, PrioritizeColumns)
	--print("Original SortFrames time:", originalTime)

	-- Test the optimized function
	--local optimizedTime = TimeFunction(SortFramesOptimized, Frames, Parent, Width, Height, SizeMult, PerRow, InverseStartX, InverseStartY, GapX, GapY, PrioritizeColumns)
	--print("Optimized SortFrames time:", optimizedTime)
	
	if not TestState then
		TestState = true
		
		CheckAllEvents()
	else
		TestState = false
		
		EventFrame:SetScript("OnEvent", nil)
		E:debugprint("<EVENT SUMMARY>")
		
		for k,v in pairs(EventCounter) do
			E:debugprint("Count for ", k, "is:", v)
		end
		
		CO:Debug_AddData(EventCounter)
		
		wipe(EventCounter)
	end
end

local function Debug()
	if E.Debug then
		Test()
	else
		E:print("Debug mode is disabled!")
	end
end

SlashCmdList.CUI_DEVTEST = Debug