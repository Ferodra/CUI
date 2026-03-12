local E, L = unpack(CUI) -- Engine
local CO = E:LoadModules("Config")
local ST = select(2, ...)

-------------------------------------------
local tinsert = table.insert
-------------------------------------------

local gui = CreateFrame("Frame")
ST.GUI = gui

local AceGUI = LibStub("AceGUI-3.0")

local EscHandler
local mainTree
local mainTreeCallbacks = {}
local mainTreeTbl = {}
local mainTreeStatusTbl = {}
gui.Modules = {}

function ST.GUI:RegisterStatModule(name, object)
	object.Name = name
	tinsert(self.Modules, object)
	
	-- We already initialized the main module
	if self.initialized then
		self:LoadStatModules()
	end
end

function ST.GUI:LoadStatModules(forceLoad)
	for name, object in pairs(self.Modules) do
		if not object.initialized or forceLoad then
			if object.Init then
				object:Init()
				object.initialized = true
			end
		end
	end
end

-- Removes from tree based on set value
function ST.GUI:RemoveFromTree(removeValue, preventUpdate)
	for i=1, #mainTreeTbl do
		if mainTreeTbl[i] then
			for key, value in pairs(mainTreeTbl[i]) do
				if key == "value" and value == removeValue then
					table.remove(mainTreeTbl, i)
					i=i-1
				end
			end
		end
	end
	
	if mainTreeCallbacks[removeValue] then
		mainTreeCallbacks[removeValue] = nil
	end
	
	if not preventUpdate then
		mainTree:SetTree(mainTreeTbl)
	end
end

function ST.GUI:AddToTree(appendText, appendValue, appendEnabled, callback)
	self:RemoveFromTree(appendValue, true)
	
	local Append = {
		text = appendText,
		value = appendValue,
		enabled = appendEnabled
	}
	
	mainTreeCallbacks[appendValue] = callback
	
	tinsert(mainTreeTbl, Append)
	mainTree:SetTree(mainTreeTbl)
end

local CurrentSelection = "equipment"

function gui:Show()
	local frame = AceGUI:Create("Frame")
	
	frame:SetLayout("Flow") --Fill will make the first child fill the whole content area
	frame:SetTitle("CUI Statistics")
	frame:SetWidth(900)
	frame:SetHeight(655)
	
	gui.isShown = true
	
	frame:SetCallback("OnClose", function(widget)
		gui.isShown = nil
		AceGUI:Release(widget)
		wipe(mainTreeStatusTbl)
	end)
	
	local versionHeader = AceGUI:Create("Heading")
	versionHeader:SetText(("|cff1784d1Version: %s [Revision %s] - Updated: %s|r"):format(ST.Version, ST.Revision, E:FormatDate(ST.VersionDate)))
	versionHeader:SetFullWidth(false)
	versionHeader:SetFullHeight(false)
	versionHeader:SetRelativeWidth(1.0)
	versionHeader:SetHeight(50)
	frame:AddChild(versionHeader)
	
	-- local introduction = AceGUI:Create("Label")
	-- introduction:SetText("Welcome! Here, all (kind of) important account statistics are recorded!")
	-- introduction:SetFontObject(GameFontHighlight)
	-- introduction:SetRelativeWidth(1)
	-- introduction:SetHeight(30)
	-- frame:AddChild(introduction)

	mainTree = AceGUI:Create("TreeGroup")
	
	mainTree:SetFullWidth(true)
	mainTree:SetFullHeight(true)
	mainTree:SetTree(mainTreeTbl)
	mainTree:SetStatusTable(mainTreeStatusTbl)
	
	mainTree:SetLayout("Fill")
	mainTree:SetCallback("OnGroupSelected", function(widget, event, value)
		widget:ReleaseChildren()
		
		local outerContainer = AceGUI:Create("SimpleGroup")
		outerContainer:PauseLayout() -- Stop drawing (improves performance) until we've added everything
		outerContainer:SetLayout("Fill")
		outerContainer:SetFullWidth(true)
		widget:AddChild(outerContainer)
		
		local scroll = AceGUI:Create("ScrollFrame")
		scroll:SetLayout("Flow")
		scroll:SetFullWidth(true)
		scroll:SetFullHeight(true)
		scroll:SetUserData("parent", outerContainer)

		outerContainer:AddChild(scroll)

		
		local Func = mainTreeCallbacks[value]
		if Func then
			Func(scroll, event, value)
		end
		
		-- for k, v in pairs(mainTreeCallbacks) do
			-- if type(v) == "function" then
				-- v(scroll, event, value)
			-- end
		-- end
		
		widget:RefreshTree()
		
		CurrentSelection = value
		mainTreeStatusTbl.groups[value] = true
		
		outerContainer:ResumeLayout()
		outerContainer:PerformLayout()
	end)

	frame:AddChild(mainTree)
	
	self:LoadStatModules(true)
	
	if CurrentSelection then
		mainTree:SelectByValue(CurrentSelection)
	end
	
	frame:Show()
		
		--------------------------------------------------------------------------------
	if not self.initialized then	
		-- @TODO: Figuring out a better solution for ESC close, as exclusive windows still will show up in front/behind our frame
		EscHandler = CreateFrame("Frame", nil, UIParent)
		EscHandler:SetAllPoints(UIParent)
		EscHandler:EnableKeyboard(true)
		
		self.initialized = true
	end
	
	EscHandler:SetScript("OnKeyDown", function(self, key)
		if key ~= 'ESCAPE' or key == 'ESC' then
			self:SetPropagateKeyboardInput(true)
		else
			self:SetPropagateKeyboardInput(false)
			self:SetScript("OnKeyDown", nil)
			frame:Hide()
		end
	end)
end