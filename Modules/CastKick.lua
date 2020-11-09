local SP = SmoothyPlates
local Utils = SP.Utils
local CastKick = SP.Addon:NewModule("CastKick", "AceTimer-3.0", "AceEvent-3.0")

local LibOverlayGlow = LibStub("LibButtonGlow-1.0");

function CastKick:OnEnable()
    InterruptTexture = GetSpellTexture(47528)

    SP.callbacks.RegisterCallback(self, "AFTER_SP_CREATION", "CreateElement_KickIcon")

    SP.callbacks.RegisterCallback(self, "SP_UNIT_CAST_UPDATE", 'CHECK_FORWARDS')
    SP.callbacks.RegisterCallback(self, "SP_UNIT_CHANNEL_UPDATE", 'CHECK_BACKWARDS')
    SP.callbacks.RegisterCallback(self, "SP_UNIT_SPELLCAST_STOP", 'ON_CAST_STOP')

    SP.callbacks.RegisterCallback(self, "BEFORE_SP_UNIT_REMOVED", "UNIT_REMOVED")
end

function CastKick:CHECK_FORWARDS(event, plate, startTime, endTime, currTime, notInterruptible)
    if notInterruptible then  
        self:HIDE_KICK(plate.sp);
        return
    end

    local dur = endTime - startTime;
    local third = startTime + (dur / 3);

    if currTime >= third then
        self:SHOW_KICK(plate.sp);
    end
end

function CastKick:CHECK_BACKWARDS(event, plate, startTime, endTime, currTime, notInterruptible)
    if notInterruptible then  
        self:HIDE_KICK(plate.sp);
        return
    end

    local dur = endTime - startTime;
    local third = startTime + (dur / 3);

    if currTime <= third then
        self:SHOW_KICK(plate.sp);
    end
end

function CastKick:SHOW_KICK(sp)
    if not sp.KickIcon:IsShown() then
        sp.KickIcon:Show()
        LibOverlayGlow.ShowOverlayGlow(sp.KickIcon.textureBack)
    end
end

function CastKick:HIDE_KICK(sp)
    if sp.KickIcon:IsShown() then
        LibOverlayGlow.HideOverlayGlow(sp.KickIcon.textureBack)
        sp.KickIcon:Hide()
    end
end

function CastKick:ON_CAST_STOP(event, plate) 
    self:HIDE_KICK(plate.SmoothyPlate.sp)
end

function layout(property)
    return SP.db.layout.LAYOUT_CASTKICK_KICK_ALERT[property];
end

function CastKick:CreateElement_KickIcon(event, plate)
    local sp = plate.SmoothyPlate.sp

    local w, h = SP.Layout.HW("KICK_ALERT", self);
    local a, p, x, y = SP.Layout.APXY("KICK_ALERT", sp, self);

    sp.KickIcon = CreateFrame("Frame", nil, sp)
    sp.KickIcon:SetSize(w, h)
    sp.KickIcon:SetPoint(a, p, x, y)

    Utils.createTextureFrame(
        sp.KickIcon,
        w, h, a, x, y,
        SP.Layout.GET("KICK_ALERT", "opacity", self),
        InterruptTexture
    );

    plate.SmoothyPlate:registerFrame(sp.KickIcon, "KICK_ALERT", self)  

    sp.KickIcon:Hide()

end

function CastKick:UNIT_REMOVED(event, plate)
    self:HIDE_KICK(plate.SmoothyPlate.sp);
end
