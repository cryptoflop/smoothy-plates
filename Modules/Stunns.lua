local SP = SmoothyPlates
local Utils = SP.Utils
local Stunns = SP.Addon:NewModule("Stuns")

local activeStunns = {}
local UnitGUID = UnitGUID
local GetTime = GetTime
local GetSpellInfo = GetSpellInfo

function Stunns:OnEnable()
    SP.callbacks.RegisterCallback(self, "AFTER_SP_CREATION", "CreateElement_StunnFrame")
    SP.callbacks.RegisterCallback(self, "AFTER_SP_UNIT_ADDED", "UNIT_ADDED")
    SP.callbacks.RegisterCallback(self, "BEFORE_SP_UNIT_REMOVED", "UNIT_REMOVED")
    SP.callbacks.RegisterCallback(self, "SP_PLAYER_ENTERING_WORLD")

    self.cc = LibStub("LibCC-1.0")
    self.cc.RegisterCallback(self, "ENEMY_STUN")
    self.cc.RegisterCallback(self, "ENEMY_STUN_FADED")
end

function Stunns:SP_PLAYER_ENTERING_WORLD()
    activeStunns = {} -- dont forget to clean up, kids
end

function Stunns:CreateElement_StunnFrame(event, plate)
    local sp = plate.SmoothyPlate.sp

    local w, h = SP.Layout.HW("STUN", self)
    local a, p, x, y = SP.Layout.APXY("STUN", sp, self)
    local tex = GetSpellTexture(1833)

    sp.StunnFrame = CreateFrame("Frame", nil, sp)
    sp.StunnFrame:SetSize(w, h)
    sp.StunnFrame:SetPoint(a, p, x, y)

    Utils.createTextureFrame(sp.StunnFrame, w, h, a, x, y, SP.Layout.GET("STUN", "opacity", self), tex)

    sp.StunnFrame.cd = CreateFrame("Cooldown", nil, sp.StunnFrame.textureBack, "CooldownFrameTemplate")
    sp.StunnFrame.cd:SetAllPoints()
    sp.StunnFrame.cd:SetHideCountdownNumbers(false)

    plate.SmoothyPlate:registerFrame(sp.StunnFrame, "STUN", self)
    sp.StunnFrame:Hide()
end

function Stunns:ENEMY_STUN(event, destGUID, sourceGUID, spellID)
    if not activeStunns[destGUID] then
        activeStunns[destGUID] = {}
    end
    activeStunns[destGUID][spellID] = true

    self:ApplyStun(destGUID)
end

function Stunns:ENEMY_STUN_FADED(event, destGUID, sourceGUID, spellID)
    if activeStunns[destGUID] and activeStunns[destGUID][spellID] then
        activeStunns[destGUID][spellID] = nil
    end

    if activeStunns[destGUID] then
        local stunnCount = 0
        for i in ipairs(activeStunns[destGUID]) do
            stunnCount = stunnCount + 1
        end
        if stunnCount == 0 then
            activeStunns[destGUID] = nil
        end
    end

    self:ApplyStun(destGUID)
end

local getPlateByGUID = SP.Nameplates.getPlateByGUID
local getUnitDebuffByName = Utils.getUnitDebuffByName

function Stunns:ApplyStun(guid, forceHide)
    local currStunn = activeStunns[guid]
    local plate = getPlateByGUID(guid)

    if currStunn and not forceHide then
        if plate then
            local expires, icon, duration = 0, nil, 0
            local _, iconN, durationN, expiresNew, timeModN = nil, 0, 0, 0
            for k, v in pairs(activeStunns[guid]) do
                if v then
                    local spellName = GetSpellInfo(k)
                    _, iconN, _, _, durationN, expiresNew, _, _, _, _, _, _, _, _, timeModN =
                        getUnitDebuffByName(plate.SmoothyPlate.unitid, spellName)
                    if expiresNew then -- to be safe if the stun-debuff does not exists on the unit (for whatever reasons)
                        local exNew = (expiresNew - GetTime()) / timeModN
                        if exNew > expires then
                            expires = exNew
                            icon = iconN
                            duration = durationN
                        end
                    end
                end
            end
            _ = nil
            if duration == 0 or not plate.SmoothyPlate.sp.StunnFrame then
                return
            end

            plate.SmoothyPlate.sp.StunnFrame.tex:SetTexture(icon)
            plate.SmoothyPlate.sp.StunnFrame.tex:SetTexCoord(0.07, 0.93, 0.07, 0.93)

            plate.SmoothyPlate.sp.StunnFrame.cd:SetCooldown(GetTime() - (duration - expires), duration)

            plate.SmoothyPlate.sp.StunnFrame:Show()
        end
    else
        if plate then
            if plate.SmoothyPlate.sp.StunnFrame then
                plate.SmoothyPlate.sp.StunnFrame:Hide()
            end
        end
    end
end

function Stunns:UNIT_ADDED(event, plate)
    self:ApplyStun(UnitGUID(plate.SmoothyPlate.unitid))
end

function Stunns:UNIT_REMOVED(event, plate)
    self:ApplyStun(UnitGUID(plate.SmoothyPlate.unitid), true)
end
