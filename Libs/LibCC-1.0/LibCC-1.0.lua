-- A super simple and lightweight Library for Stun and Silences detection
local LibCC = LibStub:NewLibrary("LibCC-1.0", 1)
if not LibCC then return end
LibCC.callbacks = LibStub("CallbackHandler-1.0"):New(LibCC)
LibCC.events = LibStub("AceEvent-3.0", LibCC)
LibCC.timer = LibStub("AceTimer-3.0", LibCC)

local CCSpells = {

	--[[ TAUNT ]]--
		-- Death Knight
		[ 56222] = true, -- Dark Command
		[ 57603] = true, -- Death Grip
		-- I have also seen this spellID used for the Death Grip debuff in MoP:
		[ 51399] = true, -- Death Grip
		-- Demon Hunter
		[185245] = true, -- Torment
		-- Druid
		[  6795] = true, -- Growl
		-- Hunter
		[ 20736] = true, -- Distracting Shot
		-- Monk
		[116189] = 115546, -- Provoke
		[118635] = 115546, -- Provoke via the Black Ox Statue -- NEED TESTING
		-- Paladin
		[ 62124] = true, -- Reckoning
		-- Warlock
		[ 17735] = true, -- Suffering (Voidwalker)
		-- Warrior
		[   355] = true, -- Taunt
		-- Shaman
		[ 36213] = true, -- Angered Earth (Earth Elemental)


	--[[ INCAPACITATES ]]--
		-- Druid
		[    99] = true, -- Incapacitating Roar (talent)
		[203126] = true, -- Maim (with blood trauma pvp talent)
		-- Hunter
		[  3355] = 187650, -- Freezing Trap
		[ 19386] = true, -- Wyvern Sting
		[209790] = true, -- Freezing Arrow
		[213691] = true, -- Scatter Shot
		-- Mage
		[   118] = true, -- Polymorph
		[ 28272] = true, -- Polymorph (pig)
		[ 28271] = true, -- Polymorph (turtle)
		[ 61305] = true, -- Polymorph (black cat)
		[ 61721] = true, -- Polymorph (rabbit)
		[ 61780] = true, -- Polymorph (turkey)
		[126819] = true, -- Polymorph (procupine)
		[161353] = true, -- Polymorph (bear cub)
		[161354] = true, -- Polymorph (monkey)
		[161355] = true, -- Polymorph (penguin)
		[161372] = true, -- Polymorph (peacock)
		[ 82691] = true, -- Ring of Frost
		-- Monk
		[115078] = true, -- Paralysis
		-- Paladin
		[ 20066] = true, -- Repentance
		-- Priest
		[605] = true, -- Dominate Mind
		[9484] = true, -- Shackle Undead
		[64044] = true, -- Psychic Horror (Horror effect)
		[200196] = true, -- Holy Word: Chastise
		-- Rogue
		[1776] = true, -- Gouge
		[6770] = true, -- Sap
		-- Shaman
		[51514] = true, -- Hex
		[211004] = true, -- Hex (spider)
		[210873] = true, -- Hex (raptor)
		[211015] = true, -- Hex (cockroach)
		[211010] = true, -- Hex (snake)
		-- Warlock
		[710] = true, -- Banish
		[6789] = true, -- Mortal Coil
		-- Pandaren
		[107079] = true, -- Quaking Palm
		-- Demon Hunter
		[217832] = true, -- Imprison
		[221527] = true, -- Improve Imprison

	--[[ DISORIENTS ]]--
		-- Death Knight
		[207167] = true, -- Blinding Sleet (talent) -- FIXME: is this the right category?
		-- Demon Hunter
		[207685] = true, -- Sigil of Misery
		-- Druid
		[33786] = true, -- Cyclone
		[209753] = true, -- Cyclone (Balance)
		-- Hunter
		[186387] = true, -- Bursting Shot
		[224729] = true, -- Bursting Shot
		-- Mage
		[31661] = true, -- Dragon's Breath
		-- Monk
		[198909] = true, -- Song of Chi-ji -- FIXME: is this the right category( tooltip specifically says disorient, so I guessed here)
		[202274] = true, -- Incendiary Brew -- FIXME: is this the right category( tooltip specifically says disorient, so I guessed here)
		-- Paladin
		[105421] = true, -- Blinding Light -- FIXME: is this the right category? Its missing from blizzard's list
		-- Priest
		[8122] = true, -- Psychic Scream
		-- Rogue
		[2094] = true, -- Blind
		-- Warlock
		[5782] = true, -- Fear -- probably unused
		[118699] = 5782, -- Fear -- new debuff ID since MoP
		[130616] = 5782, -- Fear (with Glyph of Fear)
		[5484] = true, -- Howl of Terror (talent)
		[115268] = true, -- Mesmerize (Shivarra)
		[6358] = true, -- Seduction (Succubus)
		-- Warrior
		[5246] = true, -- Intimidating Shout (main target)

	--[[ STUNS ]]--
		-- Death Knight
		-- Abomination's Might note: 207165 is the stun, but is never applied to players,
		-- so I haven't included it.
		[108194] = true, -- Asphyxiate (talent for unholy)
		[221562] = true, -- Asphyxiate (baseline for blood)
		[ 91800] = true, -- Gnaw (Ghoul)
		[ 91797] = true, -- Monstrous Blow (Dark Transformation Ghoul)
		[207171] = true, -- Winter is Coming (Remorseless winter stun)
		-- Demon Hunter
		[179057] = true, -- Chaos Nova
		[200166] = true, -- Metamorphosis
		[205630] = true, -- Illidan's Grasp, primary effect
		[208618] = true, -- Illidan's Grasp, secondary effect
		[211881] = true, -- Fel Eruption
		-- Druid
		[203123] = true, -- Maim
		[236025] = true, -- Maim (Honor talent)
		[236026] = true, -- Maim (Honor talent)
		[22570] = true, -- Maim (Honor talent)
		[5211] = true, -- Mighty Bash
		[163505] = 1822, -- Rake (Stun from Prowl)
		-- Hunter
		[117526] = 109248, -- Binding Shot
		[24394] = 19577, -- Intimidation
		-- Mage

		-- Monk
		[120086] =   true, -- Fists of Fury (with Heavy-Handed Strikes, pvp talent)
		[232055] =   true, -- Fists of Fury (new ID in 7.1)
		[119381] =   true, -- Leg Sweep
		-- Paladin
		[853] = true, -- Hammer of Justice
		-- Priest
		[200200] = true, -- Holy word: Chastise
		[226943] = true, -- Mind Bomb
		-- Rogue
		-- Shadowstrike note: 196958 is the stun, but it never applies to players,
		-- so I haven't included it.
		[1833] = true, -- Cheap Shot
		[408] = true, -- Kidney Shot
		[199804] = true, -- Between the Eyes
		-- Shaman
		[118345] = true, -- Pulverize (Primal Earth Elemental)
		[118905] = true, -- Static Charge (Capacitor Totem)
		--[204399] = true, -- Earthfury (pvp talent)
		-- Warlock
		[89766] = true, -- Axe Toss (Felguard)
		[30283] = true, -- Shadowfury
		[22703] = 1122, -- Summon Infernal
		-- Warrior
		[132168] = true, -- Shockwave
		[132169] = true, -- Storm Bolt
		[237744] = true, -- Warbringer
		-- Tauren
		[20549] = true, -- War Stomp

	--[[ ROOTS ]]--
		-- Death Knight
		[96294] = true, -- Chains of Ice (Chilblains Root)
		[204085] = true, -- Deathchill (pvp talent)
		-- Druid
		[339] = true, -- Entangling Roots
		[102359] = true, -- Mass Entanglement (talent)
		[45334] = true, -- Immobilized (wild charge, bear form)
		-- Hunter
		[ 53148] = 61685, -- Charge (Tenacity pet)
		[162480] = true, -- Steel Trap
		[190927] = true, -- Harpoon
		[200108] = true, -- Ranger's Net
		[212638] = true, -- tracker's net
		[201158] = true, -- Super Sticky Tar (Expert Trapper, Hunter talent, Tar Trap effect)
		-- Mage
		[122] = true, -- Frost Nova
		[33395] = true, -- Freeze (Water Elemental)
		-- [157997] = true, -- Ice Nova -- since 6.1, ice nova doesn't DR with anything
		[228600] = true, -- Glacial spike (talent)
		-- Monk
		[116706] = 116095, -- Disable
		-- Priest
		-- Shaman
		[ 64695] = true, -- Earthgrab Totem

	--[[ KNOCKBACK ]]--
		-- Death Knight
		[108199] = true, -- Gorefiend's Grasp
		-- Druid
		[102793] = true, -- Ursol's Vortex
		[132469] = true, -- Typhoon
		-- Hunter
		-- Shaman
		[51490] = true, -- Thunderstorm
		-- Warlock
		[6360] = true, -- Whiplash
		[115770] = true  -- Fellash
}

local SilenceSpells = {
	--[[ SILENCES ]]--
	-- Death Knight
	[47476] = true, -- Strangulate
	-- Demon Hunter
	[204490] = true, -- Sigil of Silence
	-- Druid
	-- Hunter
	[202933] = true, -- Spider Sting (pvp talent)
	-- Mage
	-- Paladin
	[31935] = true, -- Avenger's Shield
	-- Priest
	[15487] = true, -- Silence
	[199683] = true, -- Last Word (SW: Death silence)
	-- Rogue
	[1330] = true, -- Garrote
	-- Blood Elf
	[25046] = true, -- Arcane Torrent (Energy version)
	[28730] = true, -- Arcane Torrent (Priest/Mage/Lock version)
	[50613] = true, -- Arcane Torrent (Runic power version)
	[69179] = true, -- Arcane Torrent (Rage version)
	[80483] = true, -- Arcane Torrent (Focus version)
	[129597] = true, -- Arcane Torrent (Monk version)
	[155145] = true, -- Arcane Torrent (Paladin version)
	[202719] = true  -- Arcane Torrent (DH version)
}
local activeStunns = {}
local activeSilences = {}

local GetTime = GetTime

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
