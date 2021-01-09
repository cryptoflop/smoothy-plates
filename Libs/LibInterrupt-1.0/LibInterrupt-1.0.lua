-- A super simple and lightweight Library for Interrupt tracking
local LibInterrupt = LibStub:NewLibrary('LibInterrupt-1.0', 1)
if not LibInterrupt then
	return
end
LibInterrupt.callbacks = LibStub('CallbackHandler-1.0'):New(LibInterrupt)
LibInterrupt.events = LibStub('AceEvent-3.0', LibInterrupt)
LibInterrupt.timer = LibStub('AceTimer-3.0', LibInterrupt)

local SilenceSpells = {
	--[[ SILENCES ]] --
	-- Death Knight
	[47476] = true, -- Strangulate
	-- Demon Hunter
	[204490] = 202137, -- Sigil of Silence
	-- Druid
	[81261] = true, -- Solar Beam (No DR)
	-- Hunter
	[202933] = true, -- Spider Sting
	-- Paladin
	[31935] = true, -- Avenger's Shield
	[217824] = 31935, -- Shield of Virtue
	-- Priest
	[15487] = true, -- Silence
	[199683] = true, -- Last Word
	-- Rogue
	[1330] = 703, -- Garrote
	-- Warlock
	[196364] = true -- Unstable Affliction
}

-- [id] = seconds
local kickSpells = {
	[2139] = 6, -- Counterspell
	[19647] = 6, -- Spell Lock
	[47528] = 3, -- Mind Freeze
	[1766] = 5, -- Kick
	[93985] = 4, -- Skull Bash
	[96231] = 4, -- Rebuke
	[6552] = 4, -- Pummel
	[57994] = 3, -- Wind Shear
	[116705] = 4, -- Spear Hand Strike
	[147362] = 3, -- Counter Shot
	[183752] = 3, -- Disrupt,
	[220543] = 3, -- silence
	[97547] = 1, -- solarbeam
	[328404] = 1, -- arcance shadolands,
	[132409] = 6 -- spelllock
}

function isSilence(spellId)
	return SilenceSpells[spellId] or false
end

function isKick(spellId)
	if kickSpells[spellId] then
		return true
	else
		return false
	end
end

local COMBATLOG_FILTER_HOSTILE_UNITS, COMBATLOG_FILTER_HOSTILE_PLAYERS, COMBATLOG_FILTER_NEUTRAL_UNITS =
	COMBATLOG_FILTER_HOSTILE_UNITS,
	COMBATLOG_FILTER_HOSTILE_PLAYERS,
	COMBATLOG_FILTER_NEUTRAL_UNITS

function private_COMBAT_LOG_EVENT_UNFILTERED(event)
	local timeStamp,
		eventType,
		hideCaster,
		sourceGUID,
		sourceName,
		sourceFlags,
		sourceRaidFlags,
		destGUID,
		destName,
		destFlags,
		destRaidFlags,
		spellId,
		spellName,
		spellSchool,
		auraType = CombatLogGetCurrentEventInfo()

	if not spellId or not eventType or not destGUID or not sourceGUID then
		return
	end

	if
		CombatLog_Object_IsA(destFlags, COMBATLOG_FILTER_HOSTILE_PLAYERS) or
			CombatLog_Object_IsA(destFlags, COMBATLOG_FILTER_HOSTILE_UNITS) or
			CombatLog_Object_IsA(destFlags, COMBATLOG_FILTER_NEUTRAL_UNITS)
	 then
		if eventType == 'SPELL_INTERRUPT' then
			if isSilence(spellId) then
				-- return when interrupted with a silence
				return
			end

			local duration = kickSpells[spellId] or 3

			LibInterrupt.callbacks:Fire('ENEMY_INTERRUPT', destGUID, sourceGUID, spellId, duration)
			LibInterrupt.timer:ScheduleTimer(
				function()
					LibInterrupt.callbacks:Fire('ENEMY_INTERRUPT_FADED', destGUID, sourceGUID, spellId)
				end,
				duration
			)
		end
	end
end

LibInterrupt.events:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED', private_COMBAT_LOG_EVENT_UNFILTERED)

LibInterrupt.isSilence = isSilence
LibInterrupt.isKick = isKick
