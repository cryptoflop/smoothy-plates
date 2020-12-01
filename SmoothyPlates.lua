-- Author: Max David aka Vènomstrikè
-- 2016 - 2020
local SP = SmoothyPlates
local Utils = SP.Utils
local Addon = LibStub("AceAddon-3.0"):NewAddon("SmoothyPlates")
SP.Addon = Addon

function Addon:OnInitialize()
	-- init --
	for _, func in pairs(SP.initFunctions) do
		func()
	end 

	-- Modules --
	for name, module in pairs(SP.db.modules.options) do
		if module.value then
			self:EnableModule(name)
		else
			self:DisableModule(name)
		end
	end

	-- Utils.Print("Version: " .. SP.Vars.currVersion .. " loaded.")
end
