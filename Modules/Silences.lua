local SP = SmoothyPlates
local Utils = SP.Utils
local Silences = SP.Addon:NewModule("Silences")

local GetTime = GetTime
local GetSpellInfo = GetSpellInfo
local getPlateByGUID = SP.Nameplates.getPlateByGUID

local InterruptTexture

local activeSilences = {}

function Silences:OnEnable()
    InterruptTexture = GetSpellTexture(47528)

    SP.callbacks.RegisterCallback(self, "AFTER_SP_CREATION", "CreateElement_SilenceFrame")
    SP.callbacks.RegisterCallback(self, "AFTER_SP_UNIT_ADDED", "UNIT_ADDED")
    SP.callbacks.RegisterCallback(self, "BEFORE_SP_UNIT_REMOVED", "UNIT_REMOVED")
    SP.callbacks.RegisterCallback(self, "BEFORE_SP_UNIT_CAST_START", "UNIT_CAST_START")
    SP.callbacks.RegisterCallback(self, "BEFORE_SP_UNIT_CHANNEL_START", "UNIT_CAST_START")

    self.cc = LibStub("LibCC-1.0")
    self.cc.RegisterCallback(self, "ENEMY_SILENCE")
    self.cc.RegisterCallback(self, "ENEMY_SILENCE_FADED")
end

function Silences:CreateElement_SilenceFrame(event, plate)
    local sp = plate.SmoothyPlate.sp

    local w, h = SP.Layout.HW("SILENCE", self);
    local a, p, x, y = SP.Layout.APXY("SILENCE", sp, self);

    sp.SilenceFrame = CreateFrame("Frame", nil, sp)
    sp.SilenceFrame:SetSize(w, h)
    sp.SilenceFrame:SetPoint(a, p, x, y)

	Utils.createTextureFrame(
        sp.SilenceFrame,
        w, h, a, x, y,
        SP.Layout.GET("SILENCE", "opacity", self),
        InterruptTexture
    );

    sp.SilenceFrame.cd = CreateFrame("Cooldown", nil, sp.SilenceFrame.textureBack, "CooldownFrameTemplate")
    sp.SilenceFrame.cd:SetAllPoints()
    sp.SilenceFrame.cd:SetHideCountdownNumbers(false)

    plate.SmoothyPlate:registerFrame(sp.SilenceFrame, "SILENCE", self)
    sp.SilenceFrame:Hide()
end

function Silences:ENEMY_SILENCE(event, destGUID, sourceGUID, spellId)
    if spellId == -1 then
        -- time the unit was countered + counter duration
        activeSilences[destGUID] = { expires = GetTime() + 2.8 }
    else
        activeSilences[destGUID] = { spellId = spellId }
    end

    self:ApplySilence(destGUID)
end

function Silences:ENEMY_SILENCE_FADED(event, destGUID, sourceGUID, spellID)
    activeSilences[destGUID] = nil
    self:ApplySilence(destGUID)
end

local getUnitDebuffByName = Utils.getUnitDebuffByName

function Silences:ApplySilence(guid, plate, forceHide)
    if not plate then 
        plate = getPlateByGUID(guid)
        if not plate then return end
    end
    local currSilence = activeSilences[guid]

    local smp = plate.SmoothyPlate;
    if currSilence and not forceHide then
        local expires, icon, duration = 0, nil, 0
        local _, iconN, durationN, expiresNew, timeModN = nil, 0, 0, 0

        if currSilence.spellId then
            local spellName = GetSpellInfo(currSilence.spellId);
            _, iconN, _, _, durationN, expiresNew, _, _, _, _, _, _, _, _, timeModN = getUnitDebuffByName(smp.unitid, spellName)
        else
            iconN, durationN, expiresNew, timeModN = InterruptTexture, 2.8, currSilence.expires, 1
        end

        if expiresNew then -- to be safe if the stun-debuff does not exists on the unit (for whatever cases)
            local exNew = (expiresNew - GetTime()) / timeModN -- timeMod for some Time-Shit accuracy (i dont want to know in wich cases)
            if exNew > expires then
                expires = exNew
                icon = iconN
                duration = durationN - 0.15  --substract 0.1 so the cooldown bling will be visible
            end
        end
        
        if duration == 0 or not smp.sp.SilenceFrame then return end

        smp.sp.SilenceFrame.tex:SetTexture(icon)
        smp.sp.SilenceFrame.tex:SetTexCoord(0.07, 0.93, 0.07, 0.93)

        smp.sp.SilenceFrame.cd:SetCooldown(GetTime() - (duration-expires), duration)

        smp.sp.SilenceFrame:Show()
    else
        if smp.sp.SilenceFrame then
            smp.sp.SilenceFrame:Hide()
        end
    end
end

function Silences:UNIT_CAST_START(event, plate)
    activeSilences[plate.SmoothyPlate.guid] = nil
    self:ApplySilence(plate.SmoothyPlate.guid)
end

function Silences:UNIT_ADDED(event, plate)
    self:ApplySilence(plate.SmoothyPlate.guid)
end

function Silences:UNIT_REMOVED(event, plate)
    self:ApplySilence(plate.SmoothyPlate.guid, plate, true)
end