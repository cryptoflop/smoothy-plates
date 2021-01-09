std = 'lua51'

max_line_length = 180

exclude_files = {
	'Libs/',
	'.luacheckrc'
}

ignore = {}

globals = {
	-- own globals
	'SmoothyPlates',
	-- lib globals
	'LibStub',
	-- misc lua
	'format',
	'strrep',
	-- wow api
	'GetSpellTexture',
	'GetTime',
	'C_NamePlate',
	'UnitIsUnit',
	'UnitAura',
	'CreateFrame',
	'GetSpellInfo',
	'GetPhysicalScreenSize',
	'SetCVar',
	'hooksecurefunc',
	'UnitIsPlayer',
	'UnitPlayerControlled',
	'UnitCreatureType',
	'UnitName',
	'UnitNameplateShowsWidgetsOnly',
	'ReloadUI',
	'UIParent',
	'SetRaidTargetIconTexture',
	'UnitGUID',
	'UnitHealthMax',
	'UnitHealth',
	'UnitClass',
	'UnitIsPlayer',
	'UnitSelectionColor',
	'RAID_CLASS_COLORS',
	'PowerBarColor',
	'GetUnitName',
	'UnitPowerType',
	'UnitPower',
	'UnitPowerMax',
	'UnitIsTapDenied',
	'GetRaidTargetIndex',
	'UnitGetIncomingHeals',
	'UnitGetTotalHealAbsorbs',
	'UnitGetTotalAbsorbs',
	'UnitCastingInfo',
	'UnitChannelInfo',
	'AuraUtil',
	'BackdropTemplateMixin',
	'CombatLogGetCurrentEventInfo',
	'CombatLog_Object_IsA',
	'COMBATLOG_FILTER_HOSTILE_PLAYERS',
	'IsInInstance'
}

allow_defined_top = true
self = false
