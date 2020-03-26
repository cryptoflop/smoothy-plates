local SP = LibStub("AceAddon-3.0"):GetAddon("SmoothyPlates")
local Silences = SP:NewModule("Silences")

local activeSilences = {}
local UnitGUID = UnitGUID
local GetTime = GetTime
local GetSpellInfo = GetSpellInfo

local InterruptTexture

function Silences:OnEnable()

    InterruptTexture = GetSpellTexture(47528)

    SP.RegisterCallback(self, "AFTER_SP_CREATION", "CreateElement_SilenceFrame")
    SP.RegisterCallback(self, "AFTER_SP_UNIT_ADDED", "UNIT_ADDED")
    SP.RegisterCallback(self, "BEFORE_SP_UNIT_REMOVED", "UNIT_REMOVED")
    SP.RegisterCallback(self, "BEFORE_SP_UNIT_CAST_START", "UNIT_CAST_START")
    SP.RegisterCallback(self, "BEFORE_SP_UNIT_CHANNEL_START", "UNIT_CAST_START")
    SP.RegisterCallback(self, "SP_PLAYER_ENTERING_WORLD")


    self.cc = LibStub("LibCC-1.0")
    self.cc.RegisterCallback(self, "ENEMY_SILENCE")
    self.cc.RegisterCallback(self, "ENEMY_SILENCE_FADED")

end

function Silences:SP_PLAYER_ENTERING_WORLD()
    activeSilences = {} -- dont forget to clean up, kids
end

function Silences:CreateElement_SilenceFrame(event, plate)
    local sp = plate.SmoothyPlate.sp

    local w, h = SP:layoutHW("SILENCE", self);
    local a, p, x, y = SP:layoutAPXY("SILENCE", sp, self);

    sp.SilenceFrame = CreateFrame("Frame", nil, sp)
    sp.SilenceFrame:SetSize(w, h)
    sp.SilenceFrame:SetPoint(a, p, x, y)

	SP:CreateTextureFrame(
        sp.SilenceFrame,
        w, h, a, x, y,
        SP:layout("SILENCE", "opacity", self),
        InterruptTexture
    );

    sp.SilenceFrame.cd = CreateFrame("Cooldown", nil, sp.SilenceFrame.textureBack, "CooldownFrameTemplate")
    sp.SilenceFrame.cd:SetAllPoints()
    sp.SilenceFrame.cd:SetHideCountdownNumbers(false)

    plate.SmoothyPlate:registerFrame(sp.SilenceFrame, "SILENCE", self)
    sp.SilenceFrame:Hide()

end

function Silences:ENEMY_SILENCE(event, destGUID, sourceGUID, spellID)
    -- if timeForCounter is not nil the silence is an interrupt
    -- and the time cant be determined so we use 2.8 seconds
    -- because some interrupts only last 2 seconds but the majority 3 seconds

    if not activeSilences[destGUID] then activeSilences[destGUID] = {} end
    if spellID == -1 then
        activeSilences[destGUID][spellID] = GetTime() + 2.8; -- time the unit was countered + counter duration
    else
        activeSilences[destGUID][spellID] = true;
    end

    self:ApplySilence(destGUID)

end

function Silences:ENEMY_SILENCE_FADED(event, destGUID, sourceGUID, spellID)

    if activeSilences[destGUID] and activeSilences[destGUID][spellID] then
        activeSilences[destGUID][spellID] = nil
    end

    if activeSilences[destGUID] then
        local silenceCount = 0
        for i in ipairs(activeSilences[destGUID]) do silenceCount = silenceCount + 1 end
        if silenceCount == 0 then activeSilences[destGUID] = nil end
    end

    self:ApplySilence(destGUID)

end

function Silences:ApplySilence(guid, forceHide)
    local currSilence = activeSilences[guid]
    local plate = SP:GetPlateByGUID(guid)

    if currSilence and not forceHide then
        if plate then
            local expires, icon, duration = 0, nil, 0
            local _, iconN, durationN, expiresNew, timeModN = nil, 0, 0, 0

            for k,v in pairs(activeSilences[guid]) do
                if v then
                    if k == -1 then
                        iconN, durationN, expiresNew, timeModN = InterruptTexture, 2.8, v, 1
                    else
                        local spellName = GetSpellInfo(k);
                        _, iconN, _, _, durationN, expiresNew, _, _, _, _, _, _, _, _, timeModN = SP:UnitDebuffByName(plate.SmoothyPlate.unitid, spellName)
                    end

                    if expiresNew then -- to be safe if the stun-debuff does not exists on the unit (for whatever cases)
                        local exNew = (expiresNew - GetTime()) / timeModN -- timeMod for some Time-Shit accuracy (holy shat i dont want to know in wich cases)
                        if exNew > expires then
                            expires = exNew
                            icon = iconN
                            duration = durationN - 0.15  --substract 0.1 so the cooldown bling will be visible
                        end
                    end
                end
            end
            _ = nil
            if duration == 0 or not plate.SmoothyPlate.sp.SilenceFrame then return end

            plate.SmoothyPlate.sp.SilenceFrame.tex:SetTexture(icon)
            plate.SmoothyPlate.sp.SilenceFrame.tex:SetTexCoord(0.07, 0.93, 0.07, 0.93)

            plate.SmoothyPlate.sp.SilenceFrame.cd:SetCooldown(GetTime() - (duration-expires), duration)

            plate.SmoothyPlate.sp.SilenceFrame:Show()
        end
    else
        if plate then
            if plate.SmoothyPlate.sp.SilenceFrame then
                plate.SmoothyPlate.sp.SilenceFrame:Hide()
            end
        end
    end

end

function Silences:UNIT_CAST_START(event, plate)
    activeSilences[UnitGUID(plate.SmoothyPlate.unitid)] = {} -- remove all silences for this unit (cause if a cast started the unit cant be silenced...)
    self:ApplySilence(UnitGUID(plate.SmoothyPlate.unitid))
end

function Silences:UNIT_ADDED(event, plate)
    self:ApplySilence(UnitGUID(plate.SmoothyPlate.unitid))
end

function Silences:UNIT_REMOVED(event, plate)
    self:ApplySilence(UnitGUID(plate.SmoothyPlate.unitid), true)
end
