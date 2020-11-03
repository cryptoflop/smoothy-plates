-- A super simple and lightweight Library for Stun and Silences detection
local LibCC = LibStub:NewLibrary("LibCC-1.0", 1)
if not LibCC then return end
LibCC.callbacks = LibStub("CallbackHandler-1.0"):New(LibCC)
LibCC.events = LibStub("AceEvent-3.0", LibCC)
LibCC.timer = LibStub("AceTimer-3.0", LibCC)

-- TODO: use DRData instead of own list
local CCSpells = {

	--[[ TAUNT ]]--
		-- Death Knight
		[ 56222] = true, -- Dark Command
		[ 57603] = true, -- Death Grip
		-- Demon Hunter
		[185245] = true, -- Torment
		-- Druid
		[  6795] = true, -- Growl
		-- Hunter
		[  2649] = true, -- Growl (Hunter Pet)
		[ 20736] = true, -- Distracting Shot
		-- Monk
		[116189] = 115546, -- Provoke
		[118635] = 115546, -- Provoke (Black Ox Statue)
		[196727] = 115546, -- Provoke (Niuzao)
		-- Paladin
		[ 62124] = true, -- Hand of Reckoning
		[204079] = true, -- Final Stand
		-- Warlock
		[ 17735] = true, -- Suffering (Voidwalker)
		-- Warrior
		[   355] = true, -- Taunt
		-- Shaman
		[ 36213] = true, -- Angered Earth (Earth Elemental)


	--[[ INCAPACITATES ]]--
		-- Demon Hunter
		[217832] = true, -- Imprison
		[221527] = true, -- Imprison (Honor Talent)
		-- Druid
		[    99] = true, -- Incapacitating Roar
		[  2637] = true, -- Hibernate
		[236025] = true, -- Maim incap
		-- Hunter
		[  3355] = 187650, -- Freezing Trap
		[203337] = 187650, -- Freezing Trap (Honor Talent)
		[209790] = true, -- Freezing Arrow
		[213691] = true, -- Scatter Shot
		-- Mage
		[   118] = true, -- Polymorph
		[ 28271] = true, -- Polymorph (Turtle)
		[ 28272] = true, -- Polymorph (Pig)
		[ 61305] = true, -- Polymorph (Black Cat)
		[ 61721] = true, -- Polymorph (Rabbit)
		[ 61780] = true, -- Polymorph (Turkey)
		[126819] = true, -- Polymorph (Procupine)
		[161353] = true, -- Polymorph (Polar Bear Cub)
		[161354] = true, -- Polymorph (Monkey)
		[161355] = true, -- Polymorph (Penguin)
		[161372] = true, -- Polymorph (Peacock)
		[277787] = true, -- Polymorph (Direhorn)
		[277792] = true, -- Polymorph (Bumblebee)
		[ 82691] = 113724, -- Ring of Frost
		-- Monk
		[115078] = true, -- Paralysis
		-- Paladin
		[ 20066] = true, -- Repentance
		-- Priest
		[   9484] = true, -- Shackle Undead
		[ 200196] = 88625, -- Holy Word: Chastise
		-- Rogue
		[  1776] = true, -- Gouge
		[  6770] = true, -- Sap
		-- Shaman
		[ 51514] = true, -- Hex
		[196942] = true, -- Hex (Voodoo Totem)
		[210873] = true, -- Hex (Raptor)
		[211004] = true, -- Hex (Spider)
		[211010] = true, -- Hex (Snake)
		[211015] = true, -- Hex (Cockroach)
		[269352] = true, -- Hex (Skeletal Hatchling)
		[277784] = true, -- Hex (Wicker Mongrel)
		[277778] = true, -- Hex (Zandalari Tendonripper)
		[309328] = true, -- Hex (Living Honey)
		[197214] = true, -- Sundering
		-- Warlock
		[   710] = true, -- Banish
		[  6789] = true, -- Mortal Coil
		-- Pandaren
		[107079] = true, -- Quaking Palm (Racial)

	--[[ DISORIENTS ]]--
		-- Death Knight
		[207167] = true, -- Blinding Sleet
		-- Demon Hunter
		[207685] = 207684, -- Sigil of Misery
		-- Druid
		[ 33786] = true, -- Cyclone
		[209753] = true, -- Cyclone (Balance Honor Talent)
		-- Mage
		[ 31661] = true, -- Dragon's Breath
		-- Monk
		[198909] = 198898, -- Song of Chi-ji
		[202274] = 115181, -- Incendiary Brew
		-- Paladin
		[105421] = 115750, -- Blinding Light
		-- Priest
		[   605] = true, -- Dominate Mind
		[  8122] = true, -- Psychic Scream
		[226943] = 205369, -- Mind Bomb
		-- Rogue
		[  2094] = true, -- Blind
		-- Warlock
		[  6358] = true, -- Seduction (Succubus)
		[118699] = 5782, -- Fear
		[261589] = 261589, -- Seduction (Grimoire of Sacrifice)
		-- Warrior
		[  5246] = true, -- Intimidating Shout

	--[[ STUNS ]]--
		-- Death Knight
		[ 91797] = 47481, -- Monstrous Blow (Mutated Ghoul)
		[ 91800] = 47481, -- Gnaw (Ghoul)
		[108194] = true, -- Asphyxiate (Unholy/Frost)
		[221562] = true, -- Asphyxiate (Blood)
		[210141] = 210128, -- Zombie Explosion
		[287254] = 196770, -- Dead of Winter
		-- Demon Hunter
		[179057] = true, -- Chaos Nova
		[205630] = true, -- Illidan's Grasp (Primary effect)
		[208618] = true, -- Illidan's Grasp (Secondary effect)
		[211881] = true, -- Fel Eruption
		-- Druid
		[  5211] = true, -- Mighty Bash
		[203123] = true, -- Maim
		[163505] = 1822, -- Rake (Prowl)
		[202244] = 202246, -- Overrun
		-- Hunter
		[ 24394] = 19577, -- Intimidation
		-- Monk
		[119381] = true, -- Leg Sweep
		[202346] = 121253, -- Double Barrel
		-- Paladin
		[   853] = true, -- Hammer of Justice
		-- Priest
		[ 64044] = true, -- Psychic Horror
		[200200] = 88625, -- Holy word: Chastise Censure
		-- Rogue
		[   408] = true, -- Kidney Shot
		[  1833] = true, -- Cheap Shot
		[199804] = true, -- Between the Eyes
		-- Shaman
		[118345] = true, -- Pulverize (Primal Earth Elemental)
		[118905] = 192058, -- Static Charge (Capacitor Totem)
		[305485] = true, -- Lightning Lasso
		-- Warlock
		[ 30283] = true, -- Shadowfury
		[ 89766] = true, -- Axe Toss (Felguard)
		[171017] = true, -- Meteor Strike (Infernal)
        [171018] = true, -- Meteor Strike (Abyssal)
		-- Warrior
		[46968] = true, -- Shockwave
		[132168] = 46968, -- Shockwave (Protection)
		[132169] = 107570, -- Storm Bolt
		[199085] = 6544, -- Warpath
		-- Tauren
		[ 20549] = true, -- War Stomp
		[255723] = true, -- Bull Rush
		-- Kul Tiran
		[287712] = true, -- Haymaker

	--[[ ROOTS ]]--
		-- Death Knight
		[204085] = 45524, -- Deathchill (Chains of Ice)
		[233395] = 196770, -- Deathchill (Remorseless Winter)
		-- Druid
		[   339] = true, -- Entangling Roots
		[170855] = 102342, -- Entangling Roots (Nature's Grasp)
		[102359] = true, -- Mass Entanglement
		[ 45334] = 16979, -- Immobilized (wild charge, bear form)
		-- Hunter
		[ 53148] = 61685, -- Charge (Tenacity Pet)
		[162480] = 162488, -- Steel Trap
		[117526] = 109248, -- Binding Shot
		[190927] = 190925, -- Harpoon
		[201158] = true, -- Super Sticky Tar
		[200108] = true, -- Ranger's Net
		[212638] = true, -- Tracker's Net
		-- Mage
		[   122] = true, -- Frost Nova
		[ 33395] = true, -- Freeze (Water Elemental)
		[198121] = true, -- Frostbite
		[220107] = true, -- Frostbite (Water Elemental)
		[228600] = 199786, -- Glacial Spike
		-- Monk
		[116706] = 116095, -- Disable
		-- Priest
		-- Warlock
		[233582] = 17962, -- Entrenched in Flame
		-- Shaman
		[ 64695] = 51485, -- Earthgrab Totem

	--[[ KNOCKBACK ]]--
		-- Death Knight
		[108199] = true, -- Gorefiend's Grasp
		-- Druid
		[102793] = true, -- Ursol's Vortex
		[132469] = true, -- Typhoon
		-- Hunter
		[186387] = true, -- Bursting Shot
		[224729] = true, -- Bursting Shot
		[238559] = true, -- Bursting Shot
		[236775] = true, -- Hi-Explosive Trap
		-- Mage
		[157981] = true, -- Blast Wave
		-- Priest
		[204263] = true, -- Shining Force
		-- Shaman
		[ 51490] = true, -- Thunderstorm
		-- Warlock
		[  6360] = true, -- Whiplash
		[115770] = true, -- Fellash
}

local SilenceSpells = {
	--[[ SILENCES ]]--
	-- Death Knight
	[ 47476] = true, -- Strangulate
	-- Demon Hunter
	[204490] = 202137, -- Sigil of Silence
	-- Druid
	--[81261] = true, -- Solar Beam (No DR)
	-- Hunter
	[202933] = 202914, -- Spider Sting
	-- Paladin
	[ 31935] = true, -- Avenger's Shield
	[217824] = 31935, -- Shield of Virtue
	-- Priest
	[ 15487] = true, -- Silence
	[199683] = true, -- Last Word
	-- Rogue
	[  1330] = 703, -- Garrote
	-- Warlock
	[196364] = true, -- Unstable Affliction
}

local activeStunns = {}
local activeSilences = {}

local COMBATLOG_FILTER_HOSTILE_UNITS, COMBATLOG_FILTER_HOSTILE_PLAYERS, COMBATLOG_FILTER_NEUTRAL_UNITS = COMBATLOG_FILTER_HOSTILE_UNITS, COMBATLOG_FILTER_HOSTILE_PLAYERS, COMBATLOG_FILTER_NEUTRAL_UNITS

function private_COMBAT_LOG_EVENT_UNFILTERED(event)
	local timeStamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, auraType = CombatLogGetCurrentEventInfo();
	if not auraType or not spellID or not eventType or not destGUID or not sourceGUID then return end

	if CombatLog_Object_IsA(destFlags, COMBATLOG_FILTER_HOSTILE_PLAYERS) or CombatLog_Object_IsA(destFlags, COMBATLOG_FILTER_HOSTILE_UNITS) or CombatLog_Object_IsA(destFlags, COMBATLOG_FILTER_NEUTRAL_UNITS) then
		if not activeSilences[destGUID] then activeSilences[destGUID] = {} end
		if not activeStunns[destGUID] then activeStunns[destGUID] = {} end

		if eventType == "SPELL_AURA_APPLIED" and auraType == "DEBUFF" then
			if LibCC:isSilence(spellID) then
				activeSilences[destGUID][spellID] = true
				LibCC.callbacks:Fire("ENEMY_SILENCE", destGUID, sourceGUID, spellID)
				return
			end
			if LibCC:isCC(spellID) then
				activeStunns[destGUID][spellID] = true
				LibCC.callbacks:Fire("ENEMY_STUN", destGUID, sourceGUID, spellID)
			end
		elseif eventType == "SPELL_AURA_REMOVED" then

			if activeSilences[destGUID][spellID] then
				activeSilences[destGUID][spellID] = nil
				LibCC.callbacks:Fire("ENEMY_SILENCE_FADED", destGUID, sourceGUID, spellID)
				return
			end

			if activeStunns[destGUID][spellID] then
				activeStunns[destGUID][spellID] = nil
				LibCC.callbacks:Fire("ENEMY_STUN_FADED", destGUID, sourceGUID, spellID)
			end

		elseif eventType == "SPELL_INTERRUPT" then
			LibCC.callbacks:Fire("ENEMY_SILENCE", destGUID, sourceGUID, -1)
			LibCC.timer:ScheduleTimer(function() LibCC.callbacks:Fire("ENEMY_SILENCE_FADED", destGUID, sourceGUID, -1) end, 2.8)
		end
	end
end

function private_PLAYER_ENTERING_WORLD()
	activeStunns = {}
	activeSilences = {}
end

LibCC.events:RegisterEvent("PLAYER_ENTERING_WORLD", private_PLAYER_ENTERING_WORLD)
LibCC.events:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", private_COMBAT_LOG_EVENT_UNFILTERED)


function LibCC:isCC( spellID )
	return CCSpells[spellID] or false
end

function LibCC:isSilence( spellID )
	return SilenceSpells[spellID] or false
end
