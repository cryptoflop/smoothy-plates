-- Author: Max David aka Vènomstrikè
-- 2016 - 2021

local SP = SmoothyPlates
-- local Utils = SP.Utils
local Addon = LibStub('AceAddon-3.0'):NewAddon('SmoothyPlates')
SP.Addon = Addon

function Addon:OnInitialize()
	-- init --
	for _, func in pairs(SP.initFunctions) do
		func()
	end

	SP.Ace.Event.RegisterEvent(
		self,
		'PLAYER_ENTERING_WORLD',
		function()
			-- clean up
			for _, func in pairs(SP.cleanFunctions) do
				func()
			end
		end
	)

	-- Modules --
	for name in pairs(SP.getOptionsStructure()[2].options) do
		local moduleRef = self:GetModule(name, true)
		local active = SP.db.modules[name].active
		if moduleRef then
			if active then
				moduleRef:Enable()
			else
				moduleRef:Disable()
			end
		end
	end

	-- Utils.print('|cff00ff00' .. SP.Vars.currVersion .. '|r')
end
