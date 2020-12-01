local SP = SmoothyPlates
local Utils = SP.Utils
local Stunns = SP.Addon:NewModule("Stuns")

local activeStunns = {}
local GetTime = GetTime
local GetSpellInfo = GetSpellInfo

function Stunns:OnEnable()
    SP.callbacks.RegisterCallback(self, "AFTER_SP_CREATION", "CreateElement_StunnFrame")
    SP.callbacks.RegisterCallback(self, "AFTER_SP_UNIT_ADDED", "UNIT_ADDED")
    SP.callbacks.RegisterCallback(self, "BEFORE_SP_UNIT_REMOVED", "UNIT_REMOVED")

    self.cc = LibStub("LibCC-1.0")
    self.cc.RegisterCallback(self, "ENEMY_STUN")
    self.cc.RegisterCallback(self, "ENEMY_STUN_FADED")
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

local getPlateByGUID = SP.Nameplates.getPlateByGUID

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
        for i in pairs(activeStunns[destGUID]) do
            stunnCount = stunnCount + 1
        end
        if stunnCount == 0 then
            activeStunns[destGUID] = nil
        end
    end

    self:ApplyStun(destGUID)
end

local getUnitDebuffByName = Utils.getUnitDebuffByName

function Stunns:ApplyStun(guid, plate, forceHide)
    if not plate then 
        plate = getPlateByGUID(guid)
        if not plate then return end
    end
    local currStunn = activeStunns[guid]

    local smp = plate.SmoothyPlate;
    if currStunn and not forceHide then
        local expires, icon, duration = 0, nil, 0
        local _, iconN, durationN, expiresNew, timeModN = nil, 0, 0, 0
        for k, v in pairs(activeStunns[guid]) do
            if v then
                local spellName = GetSpellInfo(k)
                _, iconN, _, _, durationN, expiresNew, _, _, _, _, _, _, _, _, timeModN =
                    getUnitDebuffByName(smp.unitid, spellName)
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
        if duration == 0 or not smp.sp.StunnFrame then
            return
        end

        smp.sp.StunnFrame.tex:SetTexture(icon)
        smp.sp.StunnFrame.tex:SetTexCoord(0.07, 0.93, 0.07, 0.93)

        smp.sp.StunnFrame.cd:SetCooldown(GetTime() - (duration - expires), duration)

        smp.sp.StunnFrame:Show()
    else
        if smp.sp.StunnFrame then
            smp.sp.StunnFrame:Hide()
        end
    end
end

function Stunns:UNIT_ADDED(event, plate)
    self:ApplyStun(plate.SmoothyPlate.guid, plate)
end

function Stunns:UNIT_REMOVED(event, plate)
    self:ApplyStun(plate.SmoothyPlate.guid, plate, true)
end