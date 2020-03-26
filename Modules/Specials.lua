local SP = LibStub("AceAddon-3.0"):GetAddon("SmoothyPlates")
local SPLS = SP:NewModule("Specials", "AceEvent-3.0")

-- Specials Module for SmoothyPlates
-- Shows important CD's of enemy players and hooks it to the target plate

-- Specials is 85% complete

--------------Global Variables----------------

local classSpecials = {
	-- "Mage: Arcane"
	[62] = {
          [65802] = 300, --block
          [12472] = 180, --eisige adern,
          [113724] = 45 --ring of frost
         },
	-- "Mage: Fire"
	[63] = {
          [65802] = 300, --block
          [12472] = 180, --eisige adern,
          [113724] = 45 --ring of frost
         },
	-- "Mage: Frost"
	[64] = {
          [65802] = 300, --block
          [12472] = 180, --eisige adern,
          [153595] = 30 --kometenhagel
         },
    -- "Paladin: Holy"
	[65] = {
          [31842] = 180, --zornige vergeltung,
          [31821] = 180, --aura der hingabe,
          [63148] = 300 --gottesschild
         },
    -- "Paladin: Protection"
	[66] = {
          [63148] = 300, --gottesschild
          [31884] = 120, --zornige vergeltung,
          [31850] = 180 --ardent defender
         },
    -- "Paladin: Retribution"
	[70] = {
          [63148] = 300, --gottesschild
          [31884] = 120, --zornige vergeltung,
          [498] = 60 --göttlicher schutz
         },
    -- "Warrior: Arms"
	[71] = {
          [46924] = 60, --bladi,
          [1719] = 180, --tollkühnheit,
          [118038] = 120 --durch das schwert umkommen
         },
    -- "Warrior: Fury"
	[72] = {
          [107574] = 90, --avatar,
          [1719] = 180, --tollkühnheit,
          [118038] = 120 --durch das schwert umkommen
         },
    -- "Warrior: Protection"
	[73] = {
          [871] = 180, --schildwall,
          [12975] = 180, --letztes gefecht,
          [178367] = 45 --heldenhafter sprung
         },
    -- "Druid: Balance"
	[102] = {
          [22812] = 60, --baumrinde,
          [48505] = 30, --sternregen,
          [102560] = 180 --inkarnation: erwählter der elune,
         },
    -- "Druid: Feral"
	[103] = {
          [102543] = 180, --inkarnation: König des Dschungels,
          [61336] = 180, --überlebensinstinkte,
          [158497] = 20 --traum der cenarius,
         },
    -- "Druid: Guardian"
	[104] = {
          [102558] = 180, --inkarnation: Sohn von Ursoc,
          [61336] = 180, --überlebensinstinkte,
          [158501] = 20 --traum der cenarius,
         },
    -- "Druid: Restoration"
	[105] = {
          [22812] = 60, --baumrinde,
          [33891] = 180, --inkarnation: Baum des Lebens,
          [102342] = 60 --eisenborke
         },
    -- "Death Knight: Blood"
	[250] = {
          [48792] = 180, --eisige gegenwehr,
          [108200] = 60, --unbarmherziger winter,
          [108201] = 60 --entweihter boden,
         },
    -- "Death Knight: Frost"
	[251] = {
          [48792] = 180, --eisige gegenwehr,
          [108194] = 30, --ersticken,
          [152279] = 120 --sindragosas hauch
         },
    -- "Death Knight: Unholy"
	[252] = {
          [48792] = 60, --eisige gegenwehr,
          [108194] = 30, --ersticken,
          [49206] = 180 --gargoly,
         },
    -- "Hunter: Beast Mastery"
	[253] = {
          [148467] = 120, --abschreckung,
          [121818] = 300, --stampede,
          [60192] = 30 --eiskältefalle
         },
    -- "Hunter: Marksmanship"
	[254] = {
          [148467] = 120, --abschreckung,
          [121818] = 300, --stampede,
          [60192] = 30 --eiskältefalle
         },
    -- "Hunter: Survival"
	[255] = {
          [148467] = 120, --abschreckung,
          [121818] = 300, --stampede,
          [60192] = 30 --eiskältefalle
         },
    -- "Priest: Discipline"
	[256] = {
          [46193] = 15, --machtwort: schild
          [33206] = 180, --schmertzunterdrückung,
          [112833] = 30 -- spectral guise
         },
    -- "Priest: Holy"
	[257] = {
          [46193] = 15, --machtwort: schild
          [33206] = 180, --schmertzunterdrückung,
          [112833] = 30 -- spectral guise
         },
    -- "Priest: Shadow"
	[258] = {
          [46193] = 15, --machtwort: schild
          [33206] = 180, --schmertzunterdrückung,
          [112833] = 30 -- spectral guise
         },
    -- "Rogue: Assassination"
	[259] = {
          [5277] = 120, --entrinnen,
          [44290] = 300, --verschwinden,
          [81549] = 90 --mantel der schatten
         },
    -- "Rogue: Combat"
	[260] = {
          [5277] = 120, --entrinnen,
          [44290] = 300, --verschwinden,
          [81549] = 90 --mantel der schatten
         },
    -- "Rogue: Subtlety"
	[261] = {
          [5277] = 120, --entrinnen,
          [44290] = 300, --verschwinden,
          [81549] = 90 --mantel der schatten
         },
    -- "Shaman: Elemental"
	[262] = {
          [30823] = 60, --schamanistische wut,
          [114050] = 180, --aszendenz,
          [79206] = 120 --gunst des geistwandlers,
         },
    -- "Shaman: Enhancement"
	[263] = {
          [30823] = 60, --schamanistische wut,
          [114051] = 180, --aszendenz,
          [51533] = 120 --wildgeist
         },
    -- "Shaman: Restoration"
	[264] = {
          [79206] = 120, --gunst des geistwandlers,
          [114052] = 180, --aszendenz
          [108269] = 45 -- totem der energiespeicherung
         },
    -- "Warlock: Affliction"
	[265] = {
          [108359] = 120, --finstere regeneration,
          [108416] = 60, --opferpakt,
          [110913] = 180 --finsterer handel,
         },
    -- "Warlock: Demonology"
	[266] = {
          [108359] = 120, --finstere regeneration,
          [108416] = 60, --opferpakt,
          [110913] = 180 --finsterer handel,
         },
    -- "Warlock: Destruction"
	[267] = {
          [108359] = 120, --finstere regeneration,
          [104773] = 180, --erbarmungslose entschlossenheit,
          [108416] = 60 --opferpakt,
         },
    -- "Monk: Brewmaster"
	[268] = {
          [115080] = 90, --berührung des todes,
          [122783] = 90, --Magiediffusion,
          [137562] = 120 --schlüpfriges gebräu
         },
    -- "Monk: Windwalker"
	[269] = {
          [115080] = 90, --berührung des todes,
          [122783] = 90, --Magiediffusion,
          [137562] = 120 --schlüpfriges gebräu
         },
    -- "Monk: Mistweaver"
	[270] = {
          [116849] = 120, --lebenskukon,
          [119996] = 25, --tranaszendenz: transfer,
          [137562] = 120 --schlüpfriges gebräu
         }
}

local InArena = false
local used = false
local TP = nil
local AT = nil
local trinketicon = nil
local nextFreeSlot = 1
local EnemySpellList = {}
local enemys = {}


----------------------------------------------

function SPLS:OnInitialize()

	-- Loaded

end

function SPLS:OnEnable()

	SP:print("Module: Specials, was enabled")

	if select(1, UnitFactionGroup("player")) == "Horde" then trinketicon = select(10, GetItemInfo(122706)) else trinketicon = select(10, GetItemInfo(122707)) end

	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	--self:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
  --self:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")

	self:LNR_RegisterCallback("LNR_ON_TARGET_PLATE_ON_SCREEN");

end

function SPLS:OnDisable()

	-- Module: Specials, was disabled

end

function SPLS:ARENA_OPPONENT_UPDATE()
  if used then return end

  used = true
	EnemySpellList = {}
	enemys = {}
	local numOpps = GetNumArenaOpponentSpecs()
	for i = 1, numOpps do
		local unitTable = {}
		for i2, n2 in pairs(classSpecials[GetArenaOpponentSpec(i)]) do
			EnemySpellList[i2] = n2
			unitTable[i2] = 0
		end
		unitTable["trinket"] = 0
		enemys["arena" .. i] = unitTable
	end

end

function SPLS:PLAYER_ENTERING_WORLD()
	local instanceType = select(2, IsInInstance())

	if instanceType == "arena" then
		InArena = true
    used = false
		self:RegisterEvent("ARENA_OPPONENT_UPDATE")
		--self:ARENA_PREP_OPPONENT_SPECIALIZATIONS()
	else
    if InArena then self:disableSpecials() end
		InArena = false
		self:UnregisterEvent("ARENA_OPPONENT_UPDATE")
	end
end

function SPLS:LNR_ON_TARGET_PLATE_ON_SCREEN(event, plateFrame, plateData)
	if not InArena then return end
	if SP:getUnitIDFromName(plateData.name) == AT then return end

	if AT then
		self:disableSpecials()
	end

	TP = SP:getSmoothFrame(plateFrame)
	AT = SP:getUnitIDFromName(plateData.name)

  self:enableSpecials()
	self:updateSpecials()

end

function SPLS:COMBAT_LOG_EVENT_UNFILTERED(event, timeStamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, auraType)
	if not spellID then return end
	if not CombatLog_Object_IsA(destFlags,COMBATLOG_FILTER_HOSTILE_PLAYERS) then return end

    if not unitID or unitID == "target" then unitID = SP:getUnitIDFromName(UnitName("target")) end

	if spellID == 59752 or spellID == 42292 then
		self:trinketUsed(unitID)
		return
	end

	if self:IsSpecialSpell(spellID) then
		self:SpecialSpellUsed(spellID, unitID)
	end

end

function SPLS:SpecialSpellUsed(spellID, unitID)

	local dur = EnemySpellList[spellID]

	SP:ScheduleTimer(function() enemys[unitID][spellID] = 0; end, dur)

	enemys[unitID][spellID] = SP:getMilliEndTime(dur)

  SP:print("Special Spell Used")

  if unitID == AT then self:updateSpecials() end

end

function SPLS:IsSpecialSpell(spellID)

	for i,n in pairs(EnemySpellList) do
		if i == spellID then return true end
	end

	return false

end

function SPLS:trinketUsed(unitID)
  --if not enemys[unitID] then return end --because we use spellID of PVP Trinket it could be possible that pets could also trigger it

  SP:print("Trinket used")

  local dur = 120

  enemys[unitID].trinket = SP:getMilliEndTime(dur)

	SP:ScheduleTimer(function() enemys[unitID].trinket = 0; end, dur)

  if unitID == AT then self:updateSpecials() end

end

function SPLS:FreeSpecial(unitID, spellID)

	--

end

function SPLS:disableSpecials()

	for i,n in pairs(TP.slots) do
		n:Hide()
    if n.tid then SP:CancelTimer(n.tid) end
    n.cd:SetSize(16, 0)
	end

  TP.trinket:Hide()
  SP:CancelTimer(TP.trinket.tid)
  TP.trinket.cd:SetSize(16, 16)

  TP.slotsInit = false

end

function SPLS:enableSpecials()
	if not enemys[AT] then return end

  if not TP.slotsInit then

    local num = 0
    for i,n in pairs(enemys[AT]) do
      if i ~= "trinket" then
        num = num + 1
        TP.slots[num]:SetBackdrop(SP:getBackdrop(SP:getIcon(i)))
        TP.slots[num].cd:SetSize(16, 0)
        TP.slots[num].id = i
      end
    end

    TP.trinket:SetBackdrop(SP:getBackdrop(trinketicon))
    TP.trinket.cd:SetSize(16, 0)
    TP.trinket.id = "trinket"

    TP.slotsInit = true

  end

	for i,n in pairs(TP.slots) do n:Show() end
  TP.trinket:Show()

end

function SPLS:updateSpecials()

	for i,n in pairs(TP.slots) do
    print(enemys[AT][n.id])
    if enemys[AT][n.id] ~= 0 then
      self:hookCDTimer(n, enemys[AT][n.id] - GetTime())
    end
	end

  if enemys[AT][TP.trinket.id] ~= 0 then
    self:hookCDTimer(TP.trinket, enemys[AT][TP.trinket.id] - GetTime())
  end

end

function SPLS:hookCDTimer(frame, sec)

  SP:print("Hook called")
  frame.cd:SetSize(16, 16)
  local interval = sec/16

end
