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
		local moduleRef = self:GetModule(name, true);
		if moduleRef then
			if module.value then
				moduleRef:Enable()
			else
				moduleRef:Disable()
			end
		else
			-- TODO: remove module from options in db
		end
	end

	-- Utils.Print("Version: " .. SP.Vars.currVersion .. " loaded.")
end
