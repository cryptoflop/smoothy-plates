local SP = SmoothyPlates
local Utils = SP.Utils

SP.db = nil

SP.hookOnInit(
	function()
		local db = LibStub('AceDB-3.0'):New('SPDB')

		if not db.char.options then
			SP.db = SP.getDefaultConfig()
			db.char.options = SP.db

			local frameP = SP.Ace.GUI:Create('Frame')
			frameP:EnableResize(false)
			frameP:SetTitle('SmoothyPlates')
			frameP:SetCallback(
				'OnClose',
				function(widget)
					SP.Ace.GUI:Release(widget)
				end
			)
			frameP:SetLayout('Flow')
			frameP:SetWidth(260)
			frameP:SetHeight(140)
			local labelP = SP.Ace.GUI:Create('Label')
			labelP:SetText(
				[[This is the first time this AddOn is loaded. If you notice that your nameplates are not in the right shape, activate the [Bigger Nameplates]-Option in the Interface-Options. Type /smp to configure.]]
			)
			labelP:SetWidth(220)
			frameP:AddChild(labelP)
		else
			-- force default db
			-- db.char.options = SP.getDefaultConfig()

			local versions = Utils.split(db.char.options.version, '.', true)
			local major = tonumber(versions[1])
			if major < 6 then
				Utils.print(
					'Major update from version ' ..
						db.char.options.version .. ' to ' .. SP.Vars.currVersion .. '. All settings discarded.'
				)
				-- 6 was a major rework, reset db
				db.char.options = SP.getDefaultConfig()
				db.char.options.version = SP.Vars.currVersion
			end

			if not (db.char.options.version == SP.Vars.currVersion) then
				-- when db has another version merge current db version options
				-- into current one
				db.char.options = Utils.mergeTable(SP.getDefaultConfig(), db.char.options)
				Utils.print('Updated DB from: ' .. db.char.options.version .. ' to: ' .. SP.Vars.currVersion)
				db.char.options.version = SP.Vars.currVersion
			end

			SP.db = db.char.options
		end

		SP.setCharOptions = function(options)
			SP.db = options
			db.char.options = options
		end
	end
)
