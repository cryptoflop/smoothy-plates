local SP = LibStub("AceAddon-3.0"):GetAddon("SmoothyPlates")
_G.SmoothyPlate = {} -- Create Class Table
SmoothyPlate.__index = SmoothyPlate -- Create backfall for lookup

setmetatable(SmoothyPlate, { -- Setup cunstructor call in metatable
  __call = function (cls, ...)
    return cls._constructor(...)
  end
})

SmoothyPlate.debugFrame = false;

SmoothyPlate.elements = { HealthBar = "HEALTH", PowerBar = "POWER", CastBar = "CAST", Name = "NAME",
HealPredBar = "HEALTH", AbsorbBar = "HEALTH", PredSpark = "HEALTH", RaidIcon = "RAID_ICON" };

SmoothyPlate.elementsPlain = {}
for k, v in pairs(SmoothyPlate.elements) do
    SmoothyPlate.elementsPlain[k] = k
end

function SmoothyPlate:registerFrame(frame, layoutName, module)
    if SmoothyPlate.debugFrame or self.debug then
        frame._hide = frame.Hide;
        frame.Hide = function() end
        frame:Show()
    end

    if layoutName then
        frame:SetAlpha(SP:layout(layoutName, "opacity", module))
    end
end

function SmoothyPlate._constructor(frame, debug)
    local this = setmetatable({}, SmoothyPlate)

    if frame.SmoothyPlate then return frame.SmoothyPlate end

    this.debug = debug;

    this.sp = CreateFrame("BUTTON", "$parentSmoothedPlate", frame);
    this.sp:EnableMouse(false);
    this.sp:SetAllPoints(frame)
    this.sp:SetFrameStrata("BACKGROUND")

    this.sp:SetScale(SP.perfectScale)

    for k, v in pairs(SmoothyPlate.elements) do
        this.sp[k] = this["ConstructElement_" .. k](this, this.sp);
        this.sp[k]:SetAlpha(SP:layout(v, "opacity"))
    end

    for k, v in pairs(SmoothyPlate.elements) do
        local element = this.sp[k];
        if element.SetSize then
            local w, h = SP:layoutHW(v);
            if w and h then
                element:SetSize(w, h)
            end
        end
        if element.SetPoint then
            local parent = SP:layout(v, "parent")
            if parent then
                parent = this.sp[parent];
            else
                parent = this.sp;
            end
            local a, x, y = SP:layoutAXY(v);
            local success = xpcall(element.SetPoint, function() end, element, a, parent, x, y)
            if not success then
                -- restore old point
                SP:print("Can't anchor to that element because it's a children")
            end
        end
    end

    this.unitid = nil;
    this.health = 0;
    this.currHealth = 0;
    this.currHealPred = 0;
    this.currAbsorb = 0;

    frame.SmoothyPlate = this;
    this.sp:Hide();

    return this
end

function SmoothyPlate:Smooth(frame)
    if not self.debug then SP.smoothy:SmoothBar(frame) end
end

function SmoothyPlate:getNameplateFrame()
    return self.sp:GetParent();
end

function SmoothyPlate:GetUnit()
    return self.unitid;
end

function SmoothyPlate:ConstructElement_HealthBar(parent)

    local frameH = CreateFrame("Frame", "$parentHealthBar", parent)
    local w, h = SP:layoutHW("HEALTH");

    SP:AddBorder(frameH)

    frameH.bar = CreateFrame("StatusBar", nil, frameH)
	frameH.bar:SetStatusBarTexture(SP.BAR_TEX)
	frameH.bar:GetStatusBarTexture():SetHorizTile(false)
    frameH.bar:SetStatusBarColor(1,0,0,1)
    frameH.bar:SetSize(w - 2, h - 2)
    frameH.bar:SetPoint("CENTER", 0, 0)
    frameH.bar:SetMinMaxValues(1, 10)
    frameH.bar:SetValue(7)
    self:Smooth(frameH.bar)

	frameH.pc = frameH.bar:CreateFontString(nil, "OVERLAY")
	frameH.pc:SetPoint(SP:layoutAPXY("HEALTH_TEXT", frameH))
	frameH.pc:SetFont(SP.FONT, SP:layout("HEALTH_TEXT", "size") * SP:layout("GENERAL", "scale"), "OUTLINE")
	frameH.pc:SetJustifyH("LEFT")
	frameH.pc:SetShadowOffset(1, -1)
	frameH.pc:SetTextColor(1, 1, 1)
    frameH.pc:SetText("70%")
    frameH.pc:SetAlpha(SP:layout("HEALTH_TEXT", "opacity"))

    frameH.back = CreateFrame("Frame", "$parentBack", frameH)
    frameH.back:SetSize(w, h)
    frameH.back:SetPoint("CENTER", 0, 0)
    frameH.back:SetBackdrop(SP.stdbdne)
    frameH.back:SetBackdropColor(0,0,0,0.4)

    frameH:SetFrameLevel(4)

    return frameH;
end

function SmoothyPlate:ConstructElement_PowerBar(parent)
    local frameP = CreateFrame("Frame", "$parentPowerBar", parent)
    local w, h = SP:layoutHW("POWER")

    frameP.bar = CreateFrame("StatusBar", "$parentPowerBar", parent)
	frameP.bar:SetStatusBarTexture(SP.BAR_TEX)
    frameP.bar:GetStatusBarTexture():SetHorizTile(false)
    frameP.bar:SetSize(w - 2, h - 2)
	frameP.bar:SetPoint("CENTER", 0, 0)
    frameP.bar:SetStatusBarColor(0.9,0.9,0.1,1)
	self:Smooth(frameP.bar)

    frameP.back = CreateFrame("Frame", "$parentBack", frameP)
    frameP.back:SetSize(w, h)
    frameP.back:SetPoint("CENTER", 0, 0)
    frameP.back:SetBackdrop(SP.stdbdne)
    frameP.back:SetBackdropColor(0,0,0,0.4)

    SP:AddSingleBorders(frameP.back, 0,0,0,1);

    local hb = SP:layout("POWER", "hide border") or 'n';
    if not (hb == 'n') then
        frameP.back[hb]:Hide();
    end

    frameP:SetFrameLevel(4)

    return frameP
end

function SmoothyPlate:ConstructElement_CastBar(parent)

    local frameC = CreateFrame("Frame", "$parentCastBar", parent)
    local w, h = SP:layoutHW("CAST");

    SP:AddBorder(frameC)
    frameC:SetFrameLevel(4)

	frameC.bar = CreateFrame("StatusBar", nil, frameC)
	frameC.bar:SetStatusBarTexture(SP.BAR_TEX)
	frameC.bar:GetStatusBarTexture():SetHorizTile(false)
	frameC.bar:SetSize(w - 2, h - 2)
	frameC.bar:SetPoint("CENTER", 0, 0)
    frameC.bar:SetStatusBarColor(SP:fromRGB(255, 255, 0, 255))
    self:Smooth(frameC.bar)

    frameC.bar:SetMinMaxValues(1, 10)
    frameC.bar:SetValue(7)

    local w, h = SP:layoutHW("CAST_ICON");
    local a, x, y = SP:layoutAXY("CAST_ICON");
    local tex = GetSpellTexture(19750)
    SP:CreateTextureFrame(
        frameC,
        w, h, a, x, y,
        SP:layout("CAST_ICON", "opacity"),
        tex
    );

	frameC.name = frameC.bar:CreateFontString(nil, "OVERLAY")
	frameC.name:SetPoint(SP:layoutAPXY("CAST_TEXT", frameC)) 
	frameC.name:SetFont(SP.FONT, SP:layout("CAST_TEXT", "size") * SP:layout("GENERAL", "scale"), "OUTLINE")
	frameC.name:SetJustifyH("LEFT")
	frameC.name:SetShadowOffset(1, -1)
	frameC.name:SetTextColor(1, 1, 1)
	frameC.name:SetText("Flash of Light")

    self:registerFrame(frameC)
    frameC:Hide()

    return frameC;
end

function SmoothyPlate:ConstructElement_AbsorbBar(parent)

    local frameAB = CreateFrame("StatusBar", "$parentAbsorbBar", parent)
	frameAB:SetStatusBarTexture(SP.PRED_BAR_TEX)
	frameAB:GetStatusBarTexture():SetHorizTile(false)
    frameAB:SetStatusBarColor(1,1,1,1)
    frameAB:SetFrameLevel(3)
	self:Smooth(frameAB)

    return frameAB;
end

function SmoothyPlate:ConstructElement_HealPredBar(parent)

    local frameHP = CreateFrame("StatusBar", "$parentHealPredBar", parent)
	frameHP:SetStatusBarTexture(SP.PRED_BAR_TEX)
	frameHP:GetStatusBarTexture():SetHorizTile(false)
    frameHP:SetStatusBarColor(1,1,1,1)
    frameHP:SetFrameLevel(2)
	self:Smooth(frameHP)

    return frameHP;
end

function SmoothyPlate:ConstructElement_PredSpark(parent)

    local framePS = CreateFrame("Frame", nil, parent)
    framePS:SetSize(3, SP:layout("HEALTH", "height"))
    framePS:SetPoint("RIGHT", parent.HealthBar, 2, 0)
    framePS:SetBackdrop(SP.stdbd)
    framePS:SetBackdropColor(1,1,1,1)

    self:registerFrame(framePS)
    framePS:Hide()

    if self.debug then framePS:_hide() end

    return framePS
end

function SmoothyPlate:ConstructElement_Name(parent)

    local frameN = parent:CreateFontString(nil, "OVERLAY")
	frameN:SetFont(SP.FONT, SP:layout("NAME", "size") * SP:layout("GENERAL", "scale"), "OUTLINE")
	frameN:SetJustifyH("LEFT")
	frameN:SetShadowOffset(1, -1)
	frameN:SetTextColor(1, 1, 1)
	frameN:SetText("Name")

    return frameN;
end

function SmoothyPlate:ConstructElement_RaidIcon(parent)
    
    local frameRI = CreateFrame("Frame", "$parentRaidIcon", parent)

    frameRI.tex = frameRI:CreateTexture()
    frameRI.tex:SetAllPoints()
    frameRI.tex:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])

	SetRaidTargetIconTexture(frameRI.tex, 8);

    self:registerFrame(frameRI.tex)
    frameRI.tex:Hide()

    return frameRI;
end

function SmoothyPlate:AddUnit(unitid)
    self.unitid = unitid;

    self:UpdateName();
    self:UpdateHealth();
    self:UpdateHealthColor();
    self:UpdatePower();
    self:UpdatePowerColor();
    self:UpdateCastBarMidway();
    self:UpdateRaidTargetIcon();

    self.sp:Show()
end

function SmoothyPlate:RemoveUnit()
    self.unitid = nil;
    self.sp.CastBar:Hide()
    self.sp:Hide()
end

--------Update Elements--------

local UnitHealthMax = UnitHealthMax
local UnitHealth = UnitHealth
local UnitClass = UnitClass
local UnitIsPlayer = UnitIsPlayer
local UnitSelectionColor = UnitSelectionColor
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local PowerBarColor = PowerBarColor
local GetUnitName = GetUnitName
local UnitPowerType = UnitPowerType
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax

function SmoothyPlate:UpdateName()
    if not self.unitid then return end

    local unitName = GetUnitName(self.unitid, false)
    self.sp.Name:SetText(unitName);

end

function SmoothyPlate:UpdateHealth()
    if not self.unitid then return end

    local currHealth, maxHealth = UnitHealth(self.unitid), UnitHealthMax(self.unitid)
    self.sp.HealthBar.bar:SetMinMaxValues(0, maxHealth)
    self.sp.HealthBar.bar:SetValue(currHealth)

    self.sp.HealthBar.pc:SetText(SP:percent(currHealth, maxHealth) .. "%")
    self.currHealth = currHealth
    self.health = maxHealth

    self:UpdateHealAbsorbPrediction()

end

function SmoothyPlate:UpdateHealthColor()
    if not self.unitid then return end

    local r,g,b;
    local classFileName = select(2, UnitClass(self.unitid))

    if UnitIsPlayer(self.unitid) and classFileName then
        local color = RAID_CLASS_COLORS[classFileName]
        r,g,b = color.r, color.g, color.b
    else
        r,g,b = UnitSelectionColor(self.unitid)
    end

    if r == nil or g == nil or b == nil then
        r = 0.9; g = 0.9; b = 0.1;
    end

    -- Set Color to Class- or Thread-Color | else we use the standard yellow
    self.sp.HealthBar.bar:SetStatusBarColor(r,g,b)
    self.sp.HealthBar:SetBackdropColor(r,g,b,0.2)

end

function SmoothyPlate:UpdatePower()
    if not self.unitid then return end

    local currPower, maxPower = UnitPower(self.unitid), UnitPowerMax(self.unitid)
    self.sp.PowerBar.bar:SetMinMaxValues(0, maxPower)
    self.sp.PowerBar.bar:SetValue(currPower)

end

function SmoothyPlate:UpdatePowerColor()
    if not self.unitid then return end

    local powerType, _, r, g, b = UnitPowerType(self.unitid)
    if powerType then
        local color = PowerBarColor[powerType]
        r,g,b = color.r, color.g, color.b
    end

    -- Set Color to Powertype-Color or an alternative Power-Color
    self.sp.PowerBar.bar:SetStatusBarColor(r,g,b)
    self.sp.PowerBar:SetBackdropColor(r,g,b,0.2)

end

local GetRaidTargetIndex, SetRaidTargetIconTexture = GetRaidTargetIndex, SetRaidTargetIconTexture;
function SmoothyPlate:UpdateRaidTargetIcon()
    if not self.unitid then return end

    local icon = self.sp.RaidIcon.tex
	local index = GetRaidTargetIndex(self.unitid);

	if index then
		SetRaidTargetIconTexture(icon, index);
		icon:Show();
	else
		icon:Hide();
	end
end

local function UpdateFillBar(barWidth, previousTexture, bar, amount)
	if ( amount == 0 ) then
		return previousTexture;
	end

	bar:ClearAllPoints()
	bar:Point("TOPLEFT", previousTexture, "TOPRIGHT");
	bar:Point("BOTTOMLEFT", previousTexture, "BOTTOMRIGHT");

	bar:SetWidth(barWidth);

	return bar:GetStatusBarTexture();
end

local mathmax, UnitGetIncomingHeals, UnitGetTotalHealAbsorbs, UnitGetTotalAbsorbs = math.max, UnitGetIncomingHeals, UnitGetTotalHealAbsorbs, UnitGetTotalAbsorbs
function SmoothyPlate:UpdateHealAbsorbPrediction()
    if not self.unitid then return end

	local allIncomingHeal = UnitGetIncomingHeals(self.unitid) or 0
	local unitCurrentHealAbsorb = UnitGetTotalHealAbsorbs(self.unitid) or 0
    local totalAbsorb = UnitGetTotalAbsorbs(self.unitid) or 0
	local health, maxHealth = self.currHealth, self.health

	if(health < unitCurrentHealAbsorb) then
		unitCurrentHealAbsorb = health
	end

	local maxOverflow = 1
	if(health - unitCurrentHealAbsorb + allIncomingHeal > maxHealth * maxOverflow) then
		allIncomingHeal = maxHealth * maxOverflow - health + unitCurrentHealAbsorb
	end

    local showSpark = false
	if(health - unitCurrentHealAbsorb + allIncomingHeal + totalAbsorb >= maxHealth or health + totalAbsorb >= maxHealth) then
        showSpark = true
		if(allIncomingHeal > unitCurrentHealAbsorb) then
			totalAbsorb = mathmax(0, maxHealth - (health - unitCurrentHealAbsorb + allIncomingHeal))
		else
			totalAbsorb = mathmax(0, maxHealth - health)
		end
	end

    self.sp.PredSpark:Hide()

    self.currHealPred = allIncomingHeal
    if allIncomingHeal == 0 then
        self.sp.HealPredBar:SetMinMaxValues(0, self.health)
        self.sp.HealPredBar:SetValue(0)
    else
        self.sp.HealPredBar:SetMinMaxValues(0, self.health)
        if showSpark then
            self.sp.PredSpark:Show()
        end
        self.sp.HealPredBar:SetValue(allIncomingHeal)
    end

    self.currAbsorb = totalAbsorb
    if totalAbsorb == 0 then
        self.sp.AbsorbBar:SetMinMaxValues(0, self.health)
        self.sp.AbsorbBar:SetValue(0)
    else
        self.sp.AbsorbBar:SetMinMaxValues(0, self.health)
        if showSpark then
            self.sp.PredSpark:Show()
        end
        self.sp.AbsorbBar:SetValue(totalAbsorb)
    end

    local barWidth = self.sp.HealthBar.bar:GetWidth()
    local previousTexture = self.sp.HealthBar.bar:GetStatusBarTexture();
	previousTexture = UpdateFillBar(barWidth, previousTexture, self.sp.HealPredBar, allIncomingHeal);
	previousTexture = UpdateFillBar(barWidth, previousTexture, self.sp.AbsorbBar, totalAbsorb);

end

function SmoothyPlate:UpdateCastBarMidway()
    if not self.unitid then return end

    if UnitCastingInfo(self.unitid) then
        self:StartCasting(false)
	else
        if UnitChannelInfo(self.unitid) then
            self:StartCasting(true)
        end
	end

end

function SmoothyPlate:PrepareCast(text, texture, min, max, notInterruptible)
    if not self.unitid then return end

    self.sp.CastBar.bar:SetMinMaxValues(min, max)
    self.sp.CastBar.name:SetText(text)
    self.sp.CastBar.tex:SetTexture(texture)
    self.sp.CastBar.tex:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    if notInterruptible then
        self.sp.CastBar.bar:SetStatusBarColor(SP:fromRGB(152,152,152,255))
    else
        self.sp.CastBar.bar:SetStatusBarColor(SP:fromRGB(237,219,72,255))
    end

end

local function OnUpdateCastBarForward(self, startTime, endTime, plate, notInterruptible)
        local currentTime = GetTime() * 1000;
        self:SetValue(currentTime);
        SP.callbacks:Fire("SP_UNIT_CAST_UPDATE", plate, startTime, endTime, currentTime, notInterruptible);
end

local function OnUpdateCastBarReverse(self, startTime, endTime, plate, notInterruptible)
	local currentTime = GetTime() * 1000
    local newValue = (endTime + startTime) - currentTime;
    self:SetValue(newValue)
    SP.callbacks:Fire("SP_UNIT_CHANNEL_UPDATE", plate, startTime, endTime, newValue, notInterruptible);
end

function SmoothyPlate:StartCasting(channeled)
    if not self.unitid then return end

    self:StopCasting()
    local name, text, texture, startTime, endTime, _, _, notInterruptible;
    if not channeled then
        name, text, texture, startTime, endTime, _, _, notInterruptible = UnitCastingInfo(self.unitid)
        self.sp.CastBar.bar:SetScript("OnUpdate", function(barSelf) OnUpdateCastBarForward(barSelf, startTime, endTime, self, notInterruptible) end)
    else
        name, text, texture, startTime, endTime, _, _, notInterruptible = UnitChannelInfo(self.unitid)
        self.sp.CastBar.bar:SetScript("OnUpdate", function(barSelf) OnUpdateCastBarReverse(barSelf, startTime, endTime, self, notInterruptible) end)
    end

    if isTradeSkill or not name or not startTime or not endTime then return end

    self:PrepareCast(text, texture, startTime, endTime, notInterruptible)
    self.sp.CastBar:Show()

end

function SmoothyPlate:StopCasting()
    self.sp.CastBar.bar:SetScript("OnUpdate", nil)
    self.sp.CastBar:Hide()

    if not self.unitid then return end

    -- Do we have to do something here?

end

-------------------------------
