local E, L = unpack(select(2, ...)) -- Engine, Locale
local CO = E:LoadModules("Config")

---------------------------------------------------
local pairs 					= pairs
local tinsert 					= table.insert
---------------------------------------------------

--[[
	This Module handles all Textures used in CUI.
	It enables users to easily override every registered Texture.
]]--

-- Format:
-- [Identifier] = {
--		['Frames'] = {},
--		['Texture'] = "",
--		['OverrideTexture'] = "",
--		['EnableOverride'] = false,
--	}
E.Textures = {}

-- This has to initialize the Texture Pool for the given Identifier first
-- Also can be used to update values
function E:RegisterTexturePool(Identifier, Texture, OverrideTexture, EnableOverride)
	if not Identifier then return end
	
	if not self.Textures[Identifier] then self.Textures[Identifier] = {} end
	local Pool = self.Textures[Identifier]
	
	if not Pool.Frames then Pool.Frames = {} end
	Pool['Texture'] = Texture
	Pool['OverrideTexture'] = OverrideTexture
	Pool['EnableOverride'] = EnableOverride
	
	self:UpdateTexturePool(Identifier)
end

-- Assigns a Texture Frame to the pool
function E:RegisterTexture(Identifier, Frame)
	if not Identifier or not Frame then return end
	
	if not self.Textures[Identifier] then
		error("Texture Pool for Identifier " .. Identifier .. " was not initialized before registering a Texture Frame!")
	end
	
	if Frame and not self:TableContainsValue(self.Textures[Identifier].Frames, Frame) then
		tinsert(self.Textures, Frame)
	end
	
	self:UpdateTexture(Identifier)
end

function E:UpdateTexture(Identifier)
	local Pool = self.Textures[Identifier]
	if not Pool then return end
	
	for _, Frame in pairs(Pool.Frames) do
		Frame:SetTexture(Pool.EnableOverride and Pool.OverrideTexture or Pool.Texture)
	end
end

function E:UpdateTexturePool(Limit)
	for Identifier, _ in pairs(self.Textures) do
		if not Limit or (Limit and Identifier == Limit) then
			self:UpdateTexture(Identifier)
		end
	end
end