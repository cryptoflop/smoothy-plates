local SP = SmoothyPlates
local Utils = SP.Utils
local Auras = SP.Addon:NewModule('Auras', 'AceEvent-3.0')
local libGlow = LibStub('LibButtonGlow-1.0')

local defaultSpellSets = {
	['STUNS'] = {
		--[[ INCAPACITATES ]] --
		-- Druid
		[99] = true, -- Incapacitating Roar (talent)
		[203126] = true, -- Maim (with blood trauma pvp talent)
		[236025] = true, -- Main (Honor talent)
		[236026] = true, -- Main (Honor talent)
		-- Hunter
		[3355] = 187650, -- Freezing Trap
		[19386] = true, -- Wyvern Sting
		[209790] = true, -- Freezing Arrow
		[213691] = true, -- Scatter Shot
		-- Mage
		[118] = true, -- Polymorph
		[28272] = true, -- Polymorph (pig)
		[28271] = true, -- Polymorph (turtle)
		[61305] = true, -- Polymorph (black cat)
		[61721] = true, -- Polymorph (rabbit)
		[61780] = true, -- Polymorph (turkey)
		[126819] = true, -- Polymorph (procupine)
		[161353] = true, -- Polymorph (bear cub)
		[161354] = true, -- Polymorph (monkey)
		[161355] = true, -- Polymorph (penguin)
		[161372] = true, -- Polymorph (peacock)
		[277787] = true, -- Polymorph (direhorn)
		[277792] = true, -- Polymorph (bumblebee)
		[82691] = true, -- Ring of Frost
		-- Monk
		[115078] = true, -- Paralysis
		-- Paladin
		[20066] = true, -- Repentance
		-- Priest
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
		[221527] = true, -- Improve Imprison -- Death Knight
		--
		--[[ DISORIENTS ]] [207167] = true, -- Blinding Sleet (talent) -- FIXME: is this the right category?
		-- Demon Hunter
		[207685] = true, -- Sigil of Misery
		-- Druid
		[2637] = true, -- Hibernate
		[33786] = true, -- Cyclone
		-- Hunter
		[186387] = true, -- Bursting Shot
		-- Mage
		[31661] = true, -- Dragon's Breath
		-- Monk
		[198909] = true, -- Song of Chi-ji -- FIXME: is this the right category( tooltip specifically says disorient, so I guessed here)
		[202274] = true, -- Incendiary Brew -- FIXME: is this the right category( tooltip specifically says disorient, so I guessed here)
		-- Paladin
		[105421] = true, -- Blinding Light -- FIXME: is this the right category? Its missing from blizzard's list
		-- Priest
		[8122] = true, -- Psychic Scream
		[605] = true, -- Dominate Mind
		[226943] = true, -- Mind Bomb
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
		[5246] = true, -- Intimidating Shout (main target) -- Death Knight -- Abomination's Might note: 207165 is the stun, but is never applied to players, -- so I haven't included it.
		--
		--[[ STUNS ]] [108194] = true, -- Asphyxiate (talent for unholy)
		[221562] = true, -- Asphyxiate (baseline for blood)
		[91800] = true, -- Gnaw (Ghoul)
		[91797] = true, -- Monstrous Blow (Dark Transformation Ghoul)
		[207171] = true, -- Winter is Coming (Remorseless winter stun)
		-- Demon Hunter
		[179057] = true, -- Chaos Nova
		[200166] = true, -- Metamorphosis
		[205630] = true, -- Illidan's Grasp, primary effect
		[208618] = true, -- Illidan's Grasp, secondary effect
		[211881] = true, -- Fel Eruption
		-- Druid
		[203123] = true, -- Maim
		[5211] = true, -- Mighty Bash
		[163505] = 1822, -- Rake (Stun from Prowl)
		-- Hunter
		[117526] = 109248, -- Binding Shot
		[24394] = 19577, -- Intimidation
		-- Mage

		-- Monk
		[120086] = true, -- Fists of Fury (with Heavy-Handed Strikes, pvp talent)
		[232055] = true, -- Fists of Fury (new ID in 7.1)
		[119381] = true, -- Leg Sweep
		-- Paladin
		[853] = true, -- Hammer of Justice
		-- Priest
		[200200] = true, -- Holy word: Chastise
		-- Rogue
		-- Shadowstrike note: 196958 is the stun, but it never applies to players,
		-- so I haven't included it.
		[1833] = true, -- Cheap Shot
		[408] = true, -- Kidney Shot
		[199804] = true, -- Between the Eyes
		-- Shaman
		[118345] = true, -- Pulverize (Primal Earth Elemental)
		[118905] = true, -- Static Charge (Capacitor Totem)
		[204399] = true, -- Earthfury (pvp talent)
		-- Warlock
		[89766] = true, -- Axe Toss (Felguard)
		[30283] = true, -- Shadowfury
		[22703] = 1122, -- Summon Infernal
		-- Warrior
		[132168] = true, -- Shockwave
		[132169] = true, -- Storm Bolt
		-- Tauren
		[20549] = true, -- War Stomp -- Death Knight
		--
		--[[ ROOTS ]] [96294] = true, -- Chains of Ice (Chilblains Root)
		[204085] = true, -- Deathchill (pvp talent)
		-- Druid
		[339] = true, -- Entangling Roots
		[102359] = true, -- Mass Entanglement (talent)
		[45334] = true, -- Immobilized (wild charge, bear form)
		-- Hunter
		[53148] = 61685, -- Charge (Tenacity pet)
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
		[64695] = true, -- Earthgrab Totem -- Death Knight
		--
		--[[ KNOCKBACK ]] [108199] = true, -- Gorefiend's Grasp
		-- Druid
		[102793] = true, -- Ursol's Vortex
		[132469] = true, -- Typhoon
		-- Hunter
		-- Shaman
		[51490] = true, -- Thunderstorm
		-- Warlock
		[6360] = true, -- Whiplash
		[115770] = true -- Fellash
	},
	['SILENCES'] = {
		--[[ SILENCES ]] --
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
		[202719] = true -- Arcane Torrent (DH version)
	},
	['PVPSPELLS'] = {
		-- Copied from GladiatorlosSA2

		-- GENERAL
		[34709] = 'shadowSight',
		-- Covenant Abilities
		[310143] = 'soulshape', -- Nightfae Signature
		[319217] = 'podtender', -- Nightfae Cheat Death
		[320224] = 'podtender', -- Nightfae Cheat Death
		-- Backlash (Aura Applied)
		[87204] = 'backlashFear', -- Vampiric Touch Dispel (Priest)
		[196364] = 'backlashSilence', -- Unstable Affliction Dispel (Warlock)
		-- Death Knight (Aura Applied)
		[48792] = 'iceboundFortitude',
		[55233] = 'vampiricBlood',
		[51271] = 'pillarofFrost',
		[48707] = 'antiMagicShell',
		[152279] = 'BreathOfSindragosa',
		[219809] = 'tombstone',
		[194679] = 'runetap',
		[194844] = 'bonestorm',
		--[206977] = "bloodmirror",
		--[207256] = "obliteration",
		[207319] = 'corpseShield',
		--[207171] = "remorselessWinter",
		[212332] = 'smash',
		[212337] = 'smash',
		[91800] = 'smash',
		[91797] = 'smash',
		[116888] = 'Purgatory', -- Purgatory
		[49039] = 'lichborne', -- Lichborne
		[288977] = 'transfusion',
		[315443] = 'abominationLimb',
		[311648] = 'swarmingmist', -- Venthyr
		-- Demon Hunter (Aura Applied)
		[198589] = 'blur',
		[212800] = 'blur',
		[162264] = 'metamorphosis',
		[187827] = 'metamorphosis', -- Vengeance
		[188501] = 'spectralSight',
		[196555] = 'netherwalk',
		[207810] = 'netherBond',
		-- Druid (Aura Applied)
		[102560] = 'incarnationElune',
		[102543] = 'incarnationKitty',
		[102558] = 'incarnationUrsoc',
		[33891] = 'incarnationTree',
		[61336] = 'survivalInstincts',
		[22812] = 'barkskin',
		[1850] = 'dash',
		[252216] = 'dash', -- Tiger Dash
		[106951] = 'berserk',
		[69369] = 'PredatorSwiftness',
		[112071] = 'celestialAlignment',
		[194223] = 'celestialAlignment',
		[102342] = 'ironBark',
		[102351] = 'cenarionWard',
		[155835] = 'BristlingFur',
		[29166] = 'innervate',
		--[200851] = "rageOfSleeper",
		--[203727] = "thorns", -- (Resto)
		[236696] = 'thorns', -- (Feral/Balance)
		[305497] = 'thorns', -- Resto/Feral/Balance 8.2
		[163505] = 'rakeStun',
		--[323557] = "ravenousFrenzy", -- Venthyr
		[108291] = 'heartOfTheWild', -- Heart of the Wild
		[108292] = 'heartOfTheWild', -- Heart of the Wild
		[108293] = 'heartOfTheWild', -- Heart of the Wild
		[108294] = 'heartOfTheWild', -- Heart of the Wild
		[323546] = 'ravenousfrenzy', -- Venthyr
		-- Hunter (Aura Applied)
		[19263] = 'deterrence',
		[186265] = 'deterrence', -- Aspect of the Turtle
		[53271] = 'mastersCall',
		[53480] = 'roarOfSacrifice', -- Pet Skill
		[186257] = 'cheetah',
		[212640] = 'mendingBandage',
		--[193526] = "trueShot",
		[193530] = 'trueShot', -- Aspect of the Wild
		[266779] = 'trueShot', -- Coordinated Assault
		--[186289] = "eagle",
		[3355] = 'trapped', -- Freezing Trap Success
		[202748] = 'survivalTactics', -- Survival Tactics (Honor Talent Feign Death Passive)
		[212704] = 'beastWithin', -- The Beast Within; Beastial Wrath Fear/Horror Immunity Honor Talent
		-- Mage (Aura Applied)
		[45438] = 'iceBlock',
		[12042] = 'arcanePower',
		[12472] = 'icyVeins',
		[198111] = 'temporalShield',
		[198144] = 'iceForm',
		[86949] = 'cauterize',
		[87024] = 'cauterize',
		[190319] = 'Combustion',
		[110909] = 'alterTime',
		[342246] = 'alterTime',
		[108978] = 'alterTime',
		[324220] = 'deathborne', -- Necrolord
		-- Monk (Aura Applied)
		[122278] = 'dampenHarm',
		[122783] = 'diffuseMagic',
		[115203] = 'fortifyingBrew', --Fortifying Brew (Brewmaster)
		[201318] = 'fortifyingBrew', --Fortifying Brew (Windwalker PvP Talent)
		[243435] = 'fortifyingBrew', --Fortifying Brew (Mistweaver)
		[115176] = 'zenMeditation', -- Zen Meditation (Brewmaster)
		--[201325] = "zenMoment", --Zen Moment (PvP Talent)
		[116849] = 'lifeCocoon',
		--[122470] = "touchOfKarma",
		--[125174] = "touchOfKarma", --Test
		[152173] = 'Serenity',
		--[216113] = "fistweaving", --Way of the Crane
		[197908] = 'manaTea',
		[209584] = 'zenFocusTea',
		[202335] = 'doubleBarrel', -- Double Barrel (Brewmaster Honor Talent that stuns)
		[310454] = 'weaponoforder', -- Kyrian
		-- Paladin (Aura Applied)
		[1022] = 'handOfProtection',
		[1044] = 'handOfFreedom',
		[642] = 'divineShield',
		[31884] = 'avengingWrath', -- Protection/Retribution
		--[31842] = "avengingWrath", -- Holy
		[231895] = 'crusade',
		--[224668] = "crusade", -- Crusade (Retribution Talent)
		[105809] = 'holyAvenger',
		--[204150] = "lightAegis",
		[31850] = 'ardentDefender',
		[205191] = 'eyeForAnEye',
		[184662] = 'vengeanceShield',
		[86659] = 'ancientKings', -- Guardian of Ancient Kings
		[212641] = 'ancientKings', -- Guardian of Ancient Kings (Glyph)
		[228049] = 'forgottenQueens',
		--[182496] = "unbreakableWill",
		[216331] = 'AvengingCrusader',
		[210294] = 'divineFavor',
		[498] = 'divineProtection', -- Divine Protection
		[204018] = 'Spellwarding', -- Blessing of Spellwarding
		[215652] = 'ShieldOfVirtue', -- Shield of Virtue
		-- Priest (Aura Applied)
		[33206] = 'painSuppression',
		[47585] = 'dispersion',
		[47788] = 'guardianSpirit',
		[10060] = 'powerInfusion',
		[197862] = 'archangelHealing',
		[197871] = 'archangelDamage',
		[200183] = 'apotheosis',
		[213610] = 'holyWard',
		[197268] = 'rayOfHope',
		[193223] = 'surrenderToMadness',
		[319952] = 'surrenderToMadness',
		[47536] = 'rapture',
		[109964] = 'rapture',
		[194249] = 'voidForm',
		[218413] = 'voidForm',
		[15286] = 'vampiricEmbrace',
		[213602] = 'greaterFade',
		--[196762] = "innerFocus",

		-- Rogue (Aura Applied)
		[185313] = 'shadowDance',
		[185422] = 'shadowDance',
		[2983] = 'sprint',
		[31224] = 'cloakOfShadows',
		[5277] = 'evasion',
		[51690] = 'killingSpree',
		[121471] = 'shadowBlades',
		[199754] = 'riposte',
		[31230] = 'cheatDeath',
		[45182] = 'cheatDeath',
		[343142] = 'dreadblades',
		[1833] = 'cheapShot',
		[1330] = 'garrote',
		[6770] = 'sap',
		[207736] = 'shadowyDuel',
		[1966] = 'Feint', -- Feint
		-- Shaman (Aura Applied)
		--[204288] = "earthShield",
		[79206] = 'spiritwalkersGrace',
		--[16166] = "elementalMastery",
		[114050] = 'ascendance',
		[114051] = 'ascendance',
		[114052] = 'ascendance',
		[210918] = 'etherealForm',
		[108271] = 'astralShift',
		--[204293] = "spiritLink",

		-- Warlock (Aura Applied)
		[108416] = 'darkPact',
		[104773] = 'unendingResolve',
		[196098] = 'darkSoul', -- Soul Harvest (Legion's Version)
		[113860] = 'darkSoul', -- Dark Soul: Misery (Affliction)
		[113858] = 'darkSoul', -- Dark Soul: Instability (Destruction)
		[212295] = 'netherWard',
		-- Warrior (Aura Applied)
		[184364] = 'enragedRegeneration',
		[871] = 'shieldWall',
		[18499] = 'berserkerRage',
		[46924] = 'bladestorm',
		[227847] = 'bladestorm',
		[1719] = 'battleCry', -- Recklessness (Fury)
		[262228] = 'battleCry', -- Deadly Calm (Arms)
		[118038] = 'dieByTheSword',
		[107574] = 'avatar',
		--[12292] = "bloodbath",
		[198817] = 'sharpenBlade',
		[197690] = 'defensestance',
		--[218826] = "trialByCombat",
		[23920] = 'spellReflection',
		[330279] = 'spellReflection', -- Overwatch PvP talent
		[236273] = 'duel',
		[260708] = 'sweepingStrikes', -- Sweeping Strikes
		[202147] = 'secondWind', -- Second Wind
		[12975] = 'lastStand', -- Last Stand
		[223658] = 'safeguard', -- Safeguard
		[199086] = 'warpath' -- Warpath
	}
}

local listMap = {
	blacklists = {
		ids = {},
		auraTypes = {}
	},
	whitelists = {
		ids = {},
		auraTypes = {}
	}
}

local auraFramePool = {}
local aurasForGuid = {}
local packCooldownInfo = Utils.packCooldownInfo

local tinsert = table.insert
local tremove = table.remove

local customOptions = nil
local activeAuraSets = {}

SP.hookOnClean(
	function()
		for key in pairs(auraFramePool) do
			auraFramePool[key] = {}
		end
		aurasForGuid = {}
	end
)

function Auras:OnEnable()
	customOptions = SP.db.modules.Auras.customOptions or {}

	local activeAuraSetCount = 0
	for key, set in pairs(customOptions.auraSets) do
		if set.active then
			activeAuraSets[key] = set
			local frameName = 'AURAS_' .. key
			SP.SmoothyPlate.RegisterFrame(
				'Auras - ' .. set.name,
				frameName,
				{
					['y'] = 42,
					['x'] = 0,
					['anchor'] = 'TOPLEFT',
					['size'] = 26,
					['opacity'] = 1,
					['parent'] = 'HealthBar',
					['direction'] = 'RIGHT',
					['duration'] = false,
					['glow'] = false,
					['count'] = false,
					['level'] = 1
				}
			)
			set.frameName = frameName

			auraFramePool[frameName] = {}

			local fillMaps = function(listType)
				for spellListKey, active in pairs(set[listType]) do
					if active then
						local spellList
						local isAuraType = false

						if customOptions.spellSets[spellListKey] then
							local ss = customOptions.spellSets[spellListKey]
							isAuraType = ss.isAuraType
							spellList = ss.list
						else
							spellList = defaultSpellSets[spellListKey]
						end

						if isAuraType then
							if not listMap[listType]['auraTypes'][spellListKey] then
								listMap[listType]['auraTypes'][spellListKey] = {}
							end
							listMap[listType]['auraTypes'][spellListKey][key] = set
						else
							for spellId in pairs(spellList) do
								if not listMap[listType]['ids'][spellId] then
									listMap[listType]['ids'][spellId] = {}
								end
								listMap[listType]['ids'][spellId][key] = set
							end
						end
					end
				end
			end
			fillMaps('whitelists')
			fillMaps('blacklists')
			activeAuraSetCount = activeAuraSetCount + 1
		end
	end

	SP.callbacks.RegisterCallback(self, 'AFTER_SP_CREATION', 'CreateAllAuraSets')
	SP.callbacks.RegisterCallback(self, 'AFTER_SP_UNIT_ADDED', 'UNIT_ADDED')
	SP.callbacks.RegisterCallback(self, 'BEFORE_SP_UNIT_REMOVED', 'UNIT_REMOVED')

	if activeAuraSetCount > 0 then
		self:RegisterEvent('UNIT_AURA')
	end

	-- self:customOptions()
end

function Auras:CreateAllAuraSets(_, plate)
	for _, set in pairs(activeAuraSets) do
		self:CreateElement_AurasContainer(plate, set)
	end

	if plate.SmoothyPlate.debug then
		self:AddDebugAuras(plate)
	end
end

function Auras:CreateElement_AurasContainer(plate, set)
	local sp = plate.SmoothyPlate.sp

	local h = SP.Layout.GET(set.frameName, 'size')

	local container = Utils.createSimpleFrame('$aurasContainer' .. set.frameName, sp, false)
	container:SetSize(h, h)
	container:SetPoint(SP.Layout.APXY(set.frameName, sp))

	-- container.set = set
	container.auraFrames = {}

	sp[set.frameName] = container
	plate.SmoothyPlate:hookFrame(set.frameName)
end

local GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit

function Auras:UNIT_AURA(_, unit)
	local plate = GetNamePlateForUnit(unit)
	if not plate then
		return
	end

	self:UpdateAuras(plate, plate.SmoothyPlate.guid)
end

local ForEachAura = AuraUtil.ForEachAura
local UnitIsUnit = UnitIsUnit

function addAura(auras, sets, name, icon, count, type, duration, expires, spellId, timeMod)
	if icon then
		auras[spellId] = {
			sets = sets,
			name = name,
			icon = icon,
			count = count,
			cooldown = packCooldownInfo(spellId, duration, expires, timeMod),
			spellId = spellId,
			type = type
		}
	end
end

function checkWithList(listType, auraType, action, unitCaster, spellId, showOnNameplate)
	local setsForId = listMap[listType].ids[spellId]
	local auraTypes = listMap[listType].auraTypes
	if setsForId then
		action(setsForId)
	end

	local TYPEsets = auraTypes[auraType]
	if TYPEsets then
		action(TYPEsets)
	end

	if showOnNameplate then
		local NAMEPLATEsets = auraTypes['INCLUDE_NAME_PLATE_ONLY']
		if NAMEPLATEsets then
			action(NAMEPLATEsets)
		end
	end

	if unitCaster and UnitIsUnit(unitCaster, 'PLAYER') then
		local PLAYERsets = auraTypes['PLAYER']
		if PLAYERsets then
			action(PLAYERsets)
		end
	end
end

function checkAura(auras, auraType, name, icon, count, debuffType, duration, expires, unitCaster, ...)
	local spellId = select(3, ...)
	local showOnNameplate, timeMod = select(7, ...)

	local setsForAura = {}

	checkWithList(
		'whitelists',
		auraType,
		function(sets)
			-- merge sets
			for key, set in pairs(sets) do
				setsForAura[key] = set
			end
		end,
		unitCaster,
		spellId,
		showOnNameplate
	)

	checkWithList(
		'blacklists',
		auraType,
		function(sets)
			-- remove sets
			for key in pairs(sets) do
				setsForAura[key] = nil
			end
		end,
		unitCaster,
		spellId,
		showOnNameplate
	)

	local setsCount = 0
	for _, set in pairs(setsForAura) do
		if set then
			setsCount = setsCount + 1
		end
	end
	if setsCount > 0 then
		addAura(auras, setsForAura, name, icon, count, debuffType, duration, expires, spellId, timeMod)
	end
end

function getAurasForUnit(unit)
	local auras = {}

	ForEachAura(
		unit,
		'HELPFUL',
		40,
		function(...)
			checkAura(auras, 'HELPFUL', ...)
		end
	)
	ForEachAura(
		unit,
		'HARMFUL',
		40,
		function(...)
			checkAura(auras, 'HARMFUL', ...)
		end
	)

	local aurasNum = 0
	for _, aura in pairs(auras) do
		if aura then
			aurasNum = aurasNum + 1
		end
	end
	if aurasNum > 0 then
		return auras
	end
end

function Auras:ForEachAuraSet(aura, fn, ...)
	for _, set in pairs(aura.sets) do
		fn(self, aura, set, ...)
	end
end

function Auras:UpdateAuras(plate, guid)
	if not guid or plate.SmoothyPlate.debug then
		return
	end

	local auras = getAurasForUnit(plate.SmoothyPlate.unitid)

	if auras then
		local shouldRealign = false
		local currentAuras = aurasForGuid[guid] or {}
		aurasForGuid[guid] = auras

		for spellId, aura in pairs(auras) do
			if currentAuras[spellId] then
				-- aura exists
				local currAura = currentAuras[spellId]
				if
					currAura.count ~= aura.count or currAura.cooldown.expires ~= aura.cooldown.expires or
						currAura.cooldown.duration ~= aura.cooldown.duration
				 then
					-- aura changed, update
					self:ForEachAuraSet(aura, self.UpdateAura, plate)
				end
			else
				self:ForEachAuraSet(aura, self.CreateAura, plate)
				shouldRealign = true
			end
		end

		for spellId, currAura in pairs(currentAuras) do
			if not auras[spellId] then
				self:ForEachAuraSet(currAura, self.RemoveAura, plate)
				shouldRealign = true
			end
		end

		if shouldRealign then
			self:AlignAuras(plate, auras)
		end
	else
		self:ClearAuras(plate, guid)
	end
end

local LayoutGet = SP.Layout.GET
local getCooldown = Utils.getCooldown

local createTextureFrame = Utils.createTextureFrame

function fadeOnFinished(cooldown)
	-- this handler gets triggered only when
	-- the cooldown finished before the aura was remove (lag, ping, fps...)
	-- to singal the user the aura is basically not valid anymore we fade it out
	-- fade the auraFrame
	cooldown:GetParent():GetParent():SetAlpha(0.3)
end

function Auras:CreateAura(aura, set, plate)
	local frameName = set.frameName
	local aurasContainer = plate.SmoothyPlate.sp[frameName]

	local auraFrame = tremove(auraFramePool[frameName])
	if auraFrame then
		-- reuse frame
		auraFrame:SetParent(aurasContainer)
		auraFrame:SetAlpha(1)
	else
		-- create aura frame
		auraFrame = CreateFrame('Frame', nil, aurasContainer)
		local h = aurasContainer:GetHeight()
		auraFrame:SetSize(h, h)
		auraFrame:SetPoint('CENTER', 0, 0)

		createTextureFrame(auraFrame, h, h, 'CENTER', 0, 0, 1, aura.icon)

		auraFrame.cd = CreateFrame('Cooldown', nil, auraFrame.textureBack, 'CooldownFrameTemplate')
		auraFrame.cd:SetAllPoints()
		auraFrame.cd:SetReverse(true)
		auraFrame.cd:SetScript('OnCooldownDone', fadeOnFinished)

		auraFrame.cf = CreateFrame('Frame', nil, auraFrame)
		auraFrame.cf:SetFrameStrata('LOW')
		auraFrame.c = auraFrame.cf:CreateFontString(nil, 'OVERLAY')
		auraFrame.c:SetPoint('BOTTOMRIGHT', auraFrame.cd, 1, 1)
		auraFrame.c:SetFont(SP.Vars.ui.font, 10 * LayoutGet('GENERAL', 'scale'), 'OUTLINE')
		auraFrame.c:SetJustifyH('CENTER')
		auraFrame.c:SetShadowOffset(1, -1)
		auraFrame.c:SetTextColor(1, 1, 1)

		if LayoutGet(frameName, 'duration') then
			auraFrame.cd:SetHideCountdownNumbers(false)
			auraFrame.cd:SetCountdownFont(SP.Vars.ui.font, 20, 'OUTLINE')
		else
			auraFrame.cd:SetHideCountdownNumbers(true)
		end

		if LayoutGet(frameName, 'glow') then
			libGlow.ShowOverlayGlow(auraFrame)
		end
	end

	auraFrame.tex:SetTexture(aura.icon)
	auraFrame.c:SetText(aura.count)
	if not LayoutGet(frameName, 'count') or aura.count <= 1 then
		auraFrame.c:Hide()
	end

	auraFrame.cd:SetCooldown(getCooldown(aura.cooldown))

	aurasContainer.auraFrames[aura.spellId] = auraFrame

	auraFrame:Show()
end

function Auras:UpdateAura(aura, set, plate)
	local auraFrame = plate.SmoothyPlate.sp[set.frameName].auraFrames[aura.spellId]

	-- update count
	if LayoutGet(set.frameName, 'count') then
		auraFrame.c:SetText(aura.count)
		if aura.count > 1 then
			auraFrame.c:Show()
		else
			auraFrame.c:Hide()
		end
	else
		auraFrame.c:Hide()
	end

	-- update cooldown
	auraFrame.cd:SetCooldown(getCooldown(aura.cooldown))
end

function Auras:RemoveAura(aura, set, plate, containerFrame, auraFrame)
	if not containerFrame then
		containerFrame = plate.SmoothyPlate.sp[set.frameName]
		auraFrame = containerFrame.auraFrames[aura.spellId]
	end

	auraFrame:Hide()
	auraFrame.cd:Clear()
	auraFrame:SetParent(nil)
	containerFrame.auraFrames[aura.spellId] = nil
	tinsert(auraFramePool[set.frameName], auraFrame)
end

function Auras:AlignAuras(plate, auras)
	local sp = plate.SmoothyPlate.sp
	local margin = 2

	-- align only frames for changed auraSets
	local changedAuraSets = {}
	for _, aura in pairs(auras) do
		for key, set in pairs(aura.sets) do
			changedAuraSets[key] = set
		end
	end

	for _, set in pairs(changedAuraSets) do
		local direction = LayoutGet(set.frameName, 'direction')
		local aurasContainer = sp[set.frameName]
		local auraWidth = aurasContainer:GetHeight()

		local index = 0
		for _, auraFrame in pairs(aurasContainer.auraFrames) do
			local offset = (auraWidth + margin) * index
			if direction == 'TOP' then
				auraFrame:SetPoint('CENTER', 0, offset)
			elseif direction == 'BOTTOM' then
				auraFrame:SetPoint('CENTER', 0, -offset)
			elseif direction == 'LEFT' then
				auraFrame:SetPoint('CENTER', -offset, 0)
			elseif direction == 'RIGHT' then
				auraFrame:SetPoint('CENTER', offset, 0)
			end

			index = index + 1
		end
	end
end

function Auras:ClearAuras(plate, guid)
	if not aurasForGuid[guid] then
		return
	end
	local sp = plate.SmoothyPlate.sp
	-- clear every aura container
	for _, set in pairs(activeAuraSets) do
		local containerFrame = sp[set.frameName]
		for spellId, auraFrame in pairs(containerFrame.auraFrames) do
			self:RemoveAura({spellId = spellId}, set, plate, containerFrame, auraFrame)
		end
	end
	aurasForGuid[guid] = nil
end

function Auras:UNIT_ADDED(_, plate)
	self:UpdateAuras(plate, plate.SmoothyPlate.guid)
end

function Auras:UNIT_REMOVED(_, plate)
	self:ClearAuras(plate, plate.SmoothyPlate.guid)
end

function Auras:AddDebugAuras(plate)
	local auras = {}
	addAura(auras, activeAuraSets, 'Test1', GetSpellTexture(22812), 1, nil, 10, GetTime() + 8, 22812, 1)
	addAura(auras, activeAuraSets, 'Test2', GetSpellTexture(5277), 3, nil, 10, GetTime() + 8, 5277, 1)

	for _, aura in pairs(auras) do
		self:ForEachAuraSet(aura, self.CreateAura, plate)
	end
	self:AlignAuras(plate, auras)

	-- pause every auraFrame
	for _, set in pairs(activeAuraSets) do
		local auraContainer = plate.SmoothyPlate.sp[set.frameName]
		for _, auraFrame in pairs(auraContainer.auraFrames) do
			auraFrame.cd:Pause()
		end
	end
end

function Auras:customOptions()
	local optionsFrame = SP.Ace.GUI:Create('Frame')
	optionsFrame:SetTitle('Configuration')
	optionsFrame:SetLayout('Fill')
	optionsFrame:SetStatusText('Auras')
	optionsFrame:SetWidth(700)
	optionsFrame:SetHeight(500)
	optionsFrame:EnableResize(true)

	local optionsTree = {
		{
			value = 'SPELLS',
			text = 'SpellSets',
			children = {
				{
					value = 'STUNS',
					text = 'Stuns'
				},
				{
					value = 'SILENCES',
					text = 'Silences'
				},
				{
					value = 'PVPSPELLS',
					text = 'PvP Spells (GaldiatorlosSA2)'
				}
			}
		},
		{
			value = 'AURAS',
			text = 'AuraSets',
			children = {}
		}
	}

	for i, key in ipairs({'HARMFUL', 'HELPFUL', 'PLAYER', 'INCLUDE_NAME_PLATE_ONLY', 'STEAL_OR_PURGE'}) do
		local ss = customOptions.spellSets[key]
		optionsTree[1].children[i + 3] = {value = ss.key, text = ss.name}
	end
	for _, v in pairs(customOptions.spellSets) do
		if not v.isAuraType then
			tinsert(optionsTree[1].children, {value = v.key, text = v.name})
		end
	end

	for i, key in ipairs({'STUNS', 'SILENCES', 'PVPAURAS', 'CASTBYPLAYER'}) do
		local as = customOptions.auraSets[key]
		optionsTree[2].children[i] = {value = as.key, text = as.name}
	end
	for _, v in pairs(customOptions.auraSets) do
		if not v.default then
			tinsert(optionsTree[2].children, {value = v.key, text = v.name})
		end
	end

	local tree = SP.Ace.GUI:Create('TreeGroup')
	tree:SetTree(optionsTree)

	local views = {
		SPELLS = function(listName)
			if listName then
				local isDefault = defaultSpellSets[listName] ~= nil
				local spellList
				if isDefault then
					spellList = defaultSpellSets[listName]
				else
					local ss = customOptions.spellSets[listName]
					if ss.isAuraType then
						return
					end
					spellList = ss.list
				end

				tree:SetLayout('Flow')

				local container = SP.Ace.GUI:Create('InlineGroup')
				container:SetRelativeWidth(1)
				container:SetFullHeight(true)
				container:SetLayout('Flow')

				local spellListContianer = SP.Ace.GUI:Create('ScrollFrame')
				spellListContianer:SetLayout('Flow')
				spellListContianer:SetRelativeWidth(1)
				spellListContianer:SetFullHeight(true)
				container:AddChild(spellListContianer)

				local renderList, safeAddSpellEntry

				renderList = function()
					spellListContianer:ReleaseChildren()
					for spellId, v in pairs(spellList) do
						if v then
							safeAddSpellEntry(spellId)
						end
					end
				end

				safeAddSpellEntry = function(spellId)
					local spellTex = GetSpellTexture(spellId)
					local spellName = GetSpellInfo(spellId)
					if not spellName then
						return
					end
					spellList[spellId] = true

					local label = SP.Ace.GUI:Create('Label')
					label:SetRelativeWidth(0.85)
					label:SetText(spellName)
					label:SetImage(spellTex)
					label:SetImageSize(20, 20)
					spellListContianer:AddChild(label)

					if not isDefault then
						local icon = SP.Ace.GUI:Create('Icon')
						icon:SetRelativeWidth(0.149)
						icon:SetImage('Interface\\Buttons\\UI-StopButton')
						icon:SetImageSize(16, 16)
						icon.image:SetVertexColor(1, 0, 0, 1)
						icon:SetCallback(
							'OnClick',
							function()
								spellList[spellId] = nil
								renderList()
							end
						)
						spellListContianer:AddChild(icon)
					end
				end

				if not isDefault then
					local idBox = SP.Ace.GUI:Create('EditBox')
					idBox:SetLabel('Spell ID')
					idBox:SetRelativeWidth(0.79)
					tree:AddChild(idBox)

					idBox:SetCallback(
						'OnEnterPressed',
						function()
							local spellId = idBox:GetText()
							idBox:SetText('')
							spellId = tonumber(spellId)

							if spellList[spellId] then
								return
							end
							safeAddSpellEntry(spellId)
						end
					)

					local delBtn = SP.Ace.GUI:Create('Button')
					delBtn:SetRelativeWidth(0.199)
					delBtn:SetText('Delete Set')
					delBtn:SetCallback(
						'OnClick',
						function()
							customOptions.spellSets[listName] = nil
							local index = 1
							for i, v in ipairs(optionsTree[1].children) do
								if v.value == listName then
									index = i
								end
							end
							table.remove(optionsTree[1].children, index)
							tree:SelectByPath('SPELLS')
							tree:RefreshTree()
						end
					)
					tree:AddChild(delBtn)
				end

				tree:AddChild(container)

				renderList()
			else
				tree:SetLayout('List')

				local nameBox = SP.Ace.GUI:Create('EditBox')
				nameBox:SetLabel('Name')
				nameBox:DisableButton(true)
				tree:AddChild(nameBox)

				local addBtn = SP.Ace.GUI:Create('Button')
				addBtn:SetText('Add')
				addBtn:SetCallback(
					'OnClick',
					function()
						local name = nameBox:GetText()
						if name == '' then
							return
						end
						if customOptions.spellSets[name:upper()] then
							return
						end

						customOptions.spellSets[name:upper()] = {
							key = name:upper(),
							name = name,
							list = {}
						}
						tinsert(
							optionsTree[1].children,
							{
								value = name:upper(),
								text = name
							}
						)

						nameBox:SetText(nil)

						tree:SelectByPath('SPELLS', name:upper())
						tree:RefreshTree()
					end
				)
				tree:AddChild(addBtn)
			end
		end,
		AURAS = function(aurasName)
			if aurasName then
				tree:SetLayout('Flow')

				local config = customOptions.auraSets[aurasName]
				local isDefault = config.default

				local tabC = SP.Ace.GUI:Create('TabGroup')
				tabC:SetLayout('Flow')
				tabC:SetRelativeWidth(1)
				tabC:SetFullHeight(true)
				tabC:SetTabs(
					{
						{
							value = 'whitelists',
							text = 'Whitelists',
							selected = true
						},
						{
							value = 'blacklists',
							text = 'Blacklists'
						}
					}
				)

				tabC:SetCallback(
					'OnGroupSelected',
					function(_, _, key)
						tabC:ReleaseChildren()
						tabC:SetLayout('Flow')

						local lists = SP.Ace.GUI:Create('ScrollFrame')
						lists:SetLayout('Flow')
						lists:SetRelativeWidth(1)
						lists:SetFullHeight(true)

						for _, v in ipairs(optionsTree[1].children) do
							local cb = SP.Ace.GUI:Create('CheckBox')
							cb:SetRelativeWidth(1)
							cb:SetLabel(v.text)
							cb:SetValue(config[key][v.value])
							cb:SetDisabled(isDefault)
							cb:SetCallback(
								'OnValueChanged',
								function(_, _, state)
									if state then
										config[key][v.value] = true
									else
										config[key][v.value] = nil
									end
								end
							)
							lists:AddChild(cb)
						end

						tabC:AddChild(lists)
					end
				)

				local cb = SP.Ace.GUI:Create('CheckBox')
				cb:SetRelativeWidth(0.8)
				cb:SetValue(config.active)
				cb:SetLabel('Active')
				cb:SetCallback(
					'OnValueChanged',
					function(_, _, state)
						config.active = state
					end
				)
				tree:AddChild(cb)

				if not isDefault then
					local delBtn = SP.Ace.GUI:Create('Button')
					delBtn:SetRelativeWidth(0.199)
					delBtn:SetText('Delete Set')
					delBtn:SetCallback(
						'OnClick',
						function()
							-- remove layout entry
							SP.db.layout['AURAS_' .. aurasName] = nil
							-- remove aura entry
							customOptions.auraSets[aurasName] = nil
							-- remove tree entry
							local index = 1
							for i, v in ipairs(optionsTree[2].children) do
								if v.value == aurasName then
									index = i
								end
							end
							table.remove(optionsTree[2].children, index)

							tree:SelectByPath('AURAS')
							tree:RefreshTree()
						end
					)
					tree:AddChild(delBtn)
				end

				tree:AddChild(tabC)
				tabC:SelectTab('whitelists')
			else
				tree:SetLayout('List')

				local nameBox = SP.Ace.GUI:Create('EditBox')
				nameBox:SetLabel('Name')
				nameBox:DisableButton(true)
				tree:AddChild(nameBox)

				local addBtn = SP.Ace.GUI:Create('Button')
				addBtn:SetText('Add')
				addBtn:SetCallback(
					'OnClick',
					function()
						local name = nameBox:GetText()
						if name == '' then
							return
						end
						if customOptions.auraSets[name:upper()] then
							return
						end

						customOptions.auraSets[name:upper()] = {
							key = name:upper(),
							name = name,
							whitelists = {},
							blacklists = {},
							active = true,
							growthDirection = 'RIGHT'
						}
						tinsert(
							optionsTree[2].children,
							{
								value = name:upper(),
								text = name
							}
						)

						nameBox:SetText(nil)

						tree:SelectByPath('AURAS', name:upper())
						tree:RefreshTree()
					end
				)
				tree:AddChild(addBtn)
			end
		end
	}

	tree:SetCallback(
		'OnGroupSelected',
		function(_, _, key)
			tree:ReleaseChildren()
			local paths = Utils.split(key, ('\001'), true)
			local view = paths[1]
			if views[view] then
				views[view](paths[2])
			end
		end
	)

	optionsFrame:AddChild(tree)
	optionsFrame:SetCallback(
		'OnClose',
		function()
			ReloadUI()
		end
	)

	tree:SelectByPath('AURAS')
end
