local SP = SmoothyPlates
local Utils = SP.Utils
local Silences = SP.Addon:NewModule("Silences")

local GetTime = GetTime
local GetSpellInfo = GetSpellInfo
local getPlateByGUID = SP.Nameplates.getPlateByGUID

local KickTexture

local activeSilences = {}

function Silences:OnEnable()
    KickTexture = GetSpellTexture(1766)

    SP.callbacks.RegisterCallback(self, "AFTER_SP_CREATION", "CreateElement_SilenceFrame")
    SP.callbacks.RegisterCallback(self, "AFTER_SP_UNIT_ADDED", "UNIT_ADDED")
    SP.callbacks.RegisterCallback(self, "BEFORE_SP_UNIT_REMOVED", "UNIT_REMOVED")
    SP.callbacks.RegisterCallback(self, "BEFORE_SP_UNIT_CAST_START", "UNIT_CAST_START")
    SP.callbacks.RegisterCallback(self, "BEFORE_SP_UNIT_CHANNEL_START", "UNIT_CAST_START")

    self.cc = LibStub("LibCC-1.0")
    self.cc.RegisterCallback(self, "ENEMY_SILENCE")
    self.cc.RegisterCallback(self, "ENEMY_SILENCE_FADED")

    self.cc.RegisterCallback(self, "ENEMY_KICK")
    self.cc.RegisterCallback(self, "ENEMY_KICK_FADED")
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
        KickTexture
    );

    sp.SilenceFrame.cd = CreateFrame("Cooldown", nil, sp.SilenceFrame.textureBack, "CooldownFrameTemplate")
    sp.SilenceFrame.cd:SetAllPoints()
    sp.SilenceFrame.cd:SetHideCountdownNumbers(false)

    -- sp.SilenceFrame.kick = CreateFrame("Frame", nil, sp.SilenceFrame)
    -- sp.SilenceFrame.kick:SetSize(18, 18)
    -- sp.SilenceFrame.kick:SetPoint("TOPRIGHT", sp.SilenceFrame.textureBack, 0, 0)

	-- Utils.createTextureFrame(
    --     sp.SilenceFrame.kick,
    --     18, 18, "CENTER", 0, 0,
    --     1,
    --     KickTexture
    -- );

    -- sp.SilenceFrame.kick:Hide()

    plate.SmoothyPlate:registerFrame(sp.SilenceFrame, "SILENCE", self)
    sp.SilenceFrame:Hide()
end

function Silences:EnsureSilences(destGUID)
    if not activeSilences[destGUID] then
        activeSilences[destGUID] = {}
    end
end

function Silences:CleanSilences(destGUID)
    if activeSilences[destGUID] then
        local silenceCount = 0
        for i in pairs(activeSilences[destGUID]) do
            silenceCount = silenceCount + 1
        end
        if silenceCount == 0 then
            activeSilences[destGUID] = nil
        end
    end
end

function Silences:ENEMY_SILENCE(event, destGUID, sourceGUID, spellId)
    self:EnsureSilences(destGUID)
    activeSilences[destGUID][spellId] = { kick = false }
    self:ApplySilence(destGUID)
end

function Silences:ENEMY_SILENCE_FADED(event, destGUID, sourceGUID, spellId)
    self:EnsureSilences(destGUID)
    activeSilences[destGUID][spellId] = nil
    self:CleanSilences(destGUID)
    self:ApplySilence(destGUID)
end

function Silences:ENEMY_KICK(event, destGUID, sourceGUID, spellId, duration)
    self:EnsureSilences(destGUID)
    activeSilences[destGUID][spellId] = { duration = duration, expires = GetTime() + duration, kick = true }
    self:ApplySilence(destGUID)
end

function Silences:ENEMY_KICK_FADED(event, destGUID, sourceGUID, spellId)
    self:EnsureSilences(destGUID)
    activeSilences[destGUID][spellId] = nil
    self:CleanSilences(destGUID)
    self:ApplySilence(destGUID)
end

local getDebuffById = Utils.getDebuffById

function Silences:ApplySilence(guid, plate, forceHide)
    if not plate then 
        plate = getPlateByGUID(guid)
        if not plate then return end
    end
    local currSilences = activeSilences[guid]

    local smp = plate.SmoothyPlate;
    if currSilences and not forceHide then
        local expires, icon, duration, isKick = 0, nil, 0, false
        local _, name, iconN, durationN, expiresN, timeMod = nil, nil, 0, 0, 0, 0

        -- get the silence with the highest duration
        for spellId, silence in pairs(currSilences) do
            if silence then
                if silence.kick then
                    name, iconN, durationN, expiresN, timeMod = "Kick", GetSpellTexture(spellId) or KickTexture, silence.duration, silence.expires, 1
                else
                    -- check if silence aura exists
                    name, iconN, _, _, durationN, expiresN, _, _, _, _, _, _, _, _, timeMod = getDebuffById(smp.unitid, spellId)
                    if name == nil then
                        currSilences[spellId] = nil
                    end
                end

                if name then
                    -- check if duration is higher
                    local expiresNScaled = (expiresN - GetTime()) / timeMod
                    if expiresNScaled > expires then
                        expires = expiresNScaled
                        icon = iconN
                        duration = durationN
                        isKick = silence.kick
                    end
                end
            end
        end

        if duration > 0 then
            smp.sp.SilenceFrame.tex:SetTexture(icon)
            smp.sp.SilenceFrame.tex:SetTexCoord(0.07, 0.93, 0.07, 0.93)

            smp.sp.SilenceFrame.cd:SetCooldown(GetTime() - (duration - expires), duration)

            if isKick then
                Utils.setBorderColor(smp.sp.SilenceFrame.textureBack, 1, 0, 0, 1)
            else
                Utils.setBorderColor(smp.sp.SilenceFrame.textureBack, 0, 0, 0, 1)
            end

            smp.sp.SilenceFrame:Show()
            return
        end
    end

    smp.sp.SilenceFrame:Hide()
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