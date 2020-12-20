local SP = SmoothyPlates
local Utils = SP.Utils
local Trinket = SP.Addon:NewModule("Trinket", "AceTimer-3.0", "AceEvent-3.0")

-- Stolen from Healers GladiatorlosSA2
local trinketSpellIDs = {
    [195901] = true,
    [214027] = true,
    [42292] = true,
    [208683] = true, -- Gladiator's Medallion Legion
    [195710] = true, -- Honorable Medallion Legion
    [336126] = true -- Gladiator's Medallion Shadowlands
}

local playerUsedTrinket = {}

local TrinketTexture

function Trinket:OnEnable()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")

    TrinketTexture = GetSpellTexture(208683)

    SP.callbacks.RegisterCallback(self, "AFTER_SP_CREATION", "CreateElement_TrinketIcon")
    SP.callbacks.RegisterCallback(self, "AFTER_SP_UNIT_ADDED", "UNIT_ADDED")
    SP.callbacks.RegisterCallback(self, "BEFORE_SP_UNIT_REMOVED", "UNIT_REMOVED")
end

local inArena = false
function Trinket:PLAYER_ENTERING_WORLD()
    self:CleanUp()
    if select(2, IsInInstance()) == "arena" then
        inArena = true
        self:ARENA_STATE_CHANGED(true)
    else
        if inArena then
            inArena = false
            self:ARENA_STATE_CHANGED(false)
        end
    end
end

local timers = {}

function Trinket:CleanUp()
    for k, v in pairs(timers) do
        self:CancelTimer(v)
    end
    timers = {}
    playerUsedTrinket = {}
end

function Trinket:ARENA_STATE_CHANGED(isInArena)
    if isInArena then
        self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    else
        self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    end
end

function Trinket:CreateElement_TrinketIcon(event, plate)
    local sp = plate.SmoothyPlate.sp

    local w, h = SP.Layout.HW("TRINKET", self);
    local a, p, x, y = SP.Layout.APXY("TRINKET", sp, self);

    sp.TrinketIcon = CreateFrame("Frame", nil, sp)
    sp.TrinketIcon:SetSize(w, h)
    sp.TrinketIcon:SetPoint(a, p, x, y)

	Utils.createTextureFrame(
        sp.TrinketIcon,
        w, h, a, x, y,
        SP.Layout.GET("TRINKET", "opacity", self),
        TrinketTexture
    );

    sp.TrinketIcon.cd = CreateFrame("Cooldown", nil, sp.TrinketIcon, "CooldownFrameTemplate")
    sp.TrinketIcon.cd:SetAllPoints()
    sp.TrinketIcon.cd:SetHideCountdownNumbers(true)

    plate.SmoothyPlate:registerFrame(sp.TrinketIcon, "TRINKET", self)
    sp.TrinketIcon:Hide()
end

local GetTime = GetTime
local CombatLog_Object_IsA, COMBATLOG_FILTER_HOSTILE_PLAYERS, UnitGUID = CombatLog_Object_IsA, COMBATLOG_FILTER_HOSTILE_PLAYERS, UnitGUID
function Trinket:COMBAT_LOG_EVENT_UNFILTERED()
    local 
        timeStamp, eventType, hideCaster, 
        sourceGUID, sourceName, sourceFlags, 
        sourceRaidFlags, destGUID, destName, 
        destFlags, destRaidFlags, spellID, 
        spellName, spellSchool, auraType
        = CombatLogGetCurrentEventInfo()
       
    if not CombatLog_Object_IsA(destFlags, COMBATLOG_FILTER_HOSTILE_PLAYERS) or not spellID or not sourceGUID then return end

    if playerUsedTrinket[sourceGUID] then return end
    
    if trinketSpellIDs[spellID] then
        playerUsedTrinket[sourceGUID] = GetTime() + 180
        table.insert(timers,
            self:ScheduleTimer(function()
                if playerUsedTrinket[sourceGUID] then
                    playerUsedTrinket[sourceGUID] = nil
                    self:ApplyTrinket(sourceGUID)
                end
            end, 180)
        )
    else return end

    self:ApplyTrinket(sourceGUID)
end

local getPlateByGUID = SP.Nameplates.getPlateByGUID
function Trinket:ApplyTrinket(guid, plate, forceHide)
    if not plate then 
        plate = getPlateByGUID(guid)
        if not plate then return end
    end

    local smp = plate.SmoothyPlate
    if not inArena or forceHide or not UnitIsPlayer(smp.sp.unitid) then 
        smp.sp.TrinketIcon:Hide()
        return
    end

    if playerUsedTrinket[guid] then
        smp.sp.TrinketIcon.cd:SetCooldown(GetTime() - playerUsedTrinket[guid], 180)
        smp.sp.TrinketIcon:Show()
    else
        smp.sp.TrinketIcon.cd:SetCooldown(0, 0)
        smp.sp.TrinketIcon:Show()
    end
end

function Trinket:UNIT_ADDED(event, plate)
    self:ApplyTrinket(plate.SmoothyPlate.guid, plate)
end

function Trinket:UNIT_REMOVED(event, plate)
    self:ApplyTrinket(plate.SmoothyPlate.guid, plate, true)
end