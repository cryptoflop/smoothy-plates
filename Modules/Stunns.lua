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

function Stunns:ENEMY_STUN(event, destGUID, sourceGUID, spellId)
    if not activeStunns[destGUID] then
        activeStunns[destGUID] = {}
    end
    activeStunns[destGUID][spellId] = true

    self:ApplyStun(destGUID)
end

function Stunns:ENEMY_STUN_FADED(event, destGUID, sourceGUID, spellId)
    if activeStunns[destGUID] and activeStunns[destGUID][spellId] then
        activeStunns[destGUID][spellId] = nil
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


local getDebuffById = Utils.getDebuffById

function Stunns:ApplyStun(guid, plate, forceHide)
    if not plate then 
        plate = getPlateByGUID(guid)
        if not plate then return end
    end
    local currStunns = activeStunns[guid]

    local smp = plate.SmoothyPlate;
    if currStunns and not forceHide then
        local expires, icon, duration = 0, nil, 0
        local _, name, iconN, durationN, expiresN, timeMod = nil, nil, 0, 0, 0, 0

        -- get the stun aura with the highest duration
        for spellId, value in pairs(currStunns) do
            if value then
                -- check if aura exists
                name, iconN, _, _, durationN, expiresN, _, _, _, _, _, _, _, _, timeMod = getDebuffById(smp.unitid, spellId)
                if name == nil then
                    -- aura is not active on target (faded)
                    currStunns[spellId] = nil
                else
                    -- check if duration is higher
                    local expiresNScaled = (expiresN - GetTime()) / timeMod
                    if expiresNScaled > expires then
                        expires = expiresNScaled
                        icon = iconN
                        duration = durationN
                    end
                end
            end
        end

        if duration > 0 then
            -- show stun frame
            smp.sp.StunnFrame.tex:SetTexture(icon)
            smp.sp.StunnFrame.tex:SetTexCoord(0.07, 0.93, 0.07, 0.93)

            smp.sp.StunnFrame.cd:SetCooldown(GetTime() - (duration - expires), duration)

            smp.sp.StunnFrame:Show()
            return
        end
    end

    smp.sp.StunnFrame:Hide()
end

function Stunns:UNIT_ADDED(event, plate)
    self:ApplyStun(plate.SmoothyPlate.guid, plate)
end

function Stunns:UNIT_REMOVED(event, plate)
    self:ApplyStun(plate.SmoothyPlate.guid, plate, true)
end