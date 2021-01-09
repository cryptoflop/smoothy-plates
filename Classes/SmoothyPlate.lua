local SP = SmoothyPlates
local Utils = SP.Utils

local SmoothyPlate = {} -- Create Class Table
SmoothyPlate.__index = SmoothyPlate -- Create backfall for lookup

setmetatable(
	SmoothyPlate,
	{
		-- Setup cunstructor call in metatable
		__call = function(cls, ...)
			return cls._constructor(...)
		end
	}
)

-- Convenience functions for getting saved frame positions/anchors
local Layout = nil
Layout = {
	GET = function(frameName, property)
		local layoutInfo = SP.db.layout[frameName]
		if layoutInfo then
			return layoutInfo[property]
		else
			return nil
		end
	end,
	HW = function(frameName, module)
		local multiplier = Layout.GET('GENERAL', 'scale')
		local width, height = Layout.GET(frameName, 'width', module), Layout.GET(frameName, 'height', module)
		if not (width == nil) then
			width = width * multiplier
		end
		if not (height == nil) then
			height = height * multiplier
		end
		return width, height
	end,
	APXY = function(frameName, parent, module)
		local layoutParent = Layout.GET(frameName, 'parent', module)
		if layoutParent then
			parent = parent[layoutParent]
		end

		local a, x, y = Layout.AXY(frameName, module)
		return a, parent, x, y
	end,
	AXY = function(frameName, module)
		return Layout.GET(frameName, 'anchor', module), Layout.XY(frameName, module)
	end,
	XY = function(frameName, module)
		local multiplier = Layout.GET('GENERAL', 'scale')
		local x, y = Layout.GET(frameName, 'x', module), Layout.GET(frameName, 'y', module)
		if not (x == nil) then
			x = x * multiplier
		end
		if not (y == nil) then
			y = y * multiplier
		end
		return x, y
	end
}

SmoothyPlate.debugFrame = false

SmoothyPlate.elements = {
	HealthBar = 'HEALTH',
	PowerBar = 'POWER',
	CastBar = 'CAST',
	Name = 'NAME',
	TargetIndicator = 'TARGET',
	AbsorbBar = 'HEALTH',
	RaidIcon = 'RAID_ICON'
}

SmoothyPlate.elementsPlain = {}
for k, _ in pairs(SmoothyPlate.elements) do
	SmoothyPlate.elementsPlain[k] = k
end

SmoothyPlate.registeredFrameNames = {}
function SmoothyPlate.RegisterFrame(name, frameName, defaultLayout)
	if defaultLayout and not SP.db.layout[frameName] then
		SP.db.layout[frameName] = defaultLayout
	end
	SmoothyPlate.registeredFrameNames[name] = frameName
end

local hiddenElements = {AbsorbBar = true}
for frameName, key in pairs(SmoothyPlate.elements) do
	if not hiddenElements[frameName] then
		SmoothyPlate.RegisterFrame(frameName, key)
	end
end

function SmoothyPlate:hookFrame(frameName, frame)
	if not frame then
		frame = self.sp[frameName]
		if not frame then
			print('Tried to hook nil frame: ' .. frameName)
			return
		end
	end

	if SmoothyPlate.debugFrame or self.debug then
		frame._hide = frame.Hide
		frame.Hide = function()
		end
		frame:Show()
	end

	if frameName then
		frame:SetAlpha(Layout.GET(frameName, 'opacity'))
		frame:SetFrameLevel(Layout.GET(frameName, 'level') or 1)
	end
end

function SmoothyPlate._constructor(frame, debug)
	local this = setmetatable({}, SmoothyPlate)

	if frame.SmoothyPlate then
		return frame.SmoothyPlate
	end

	this.debug = debug

	this.sp = CreateFrame('BUTTON', '$parentSmoothedPlate', frame)
	this.sp:EnableMouse(false)
	this.sp:SetAllPoints(frame)
	this.sp:SetFrameStrata('BACKGROUND')

	this.sp:SetScale(SP.Vars.perfectScale)

	for k, v in pairs(SmoothyPlate.elements) do
		this.sp[k] = this['ConstructElement_' .. k](this, this.sp)
		this.sp[k]:SetAlpha(Layout.GET(v, 'opacity'))
	end

	for k, v in pairs(SmoothyPlate.elements) do
		local element = this.sp[k]
		if element.SetSize then
			local w, h = Layout.HW(v)
			if w and h then
				element:SetSize(w, h)
			end
		end
		if element.SetPoint then
			local parent = Layout.GET(v, 'parent')
			if parent then
				parent = this.sp[parent]
			else
				parent = this.sp
			end
			local a, x, y = Layout.AXY(v)
			local success =
				xpcall(
				element.SetPoint,
				function()
				end,
				element,
				a,
				parent,
				x,
				y
			)
			if not success then
				-- restore old point
				Utils.print("Can't anchor to that element because it's a children")
			end
		end
	end

	this.unitid = nil
	this.guid = nil
	this.health = 0
	this.currHealth = 0
	this.currHealPred = 0
	this.currAbsorb = 0

	frame.SmoothyPlate = this
	this.sp:Hide()

	return this
end

function SmoothyPlate:Smooth(frame)
	if not self.debug then
		SP.smoothy:SmoothBar(frame)
	end
end

function SmoothyPlate:getNameplateFrame()
	return self.sp:GetParent()
end

function SmoothyPlate:GetUnit()
	return self.unitid
end

function SmoothyPlate:ConstructElement_HealthBar(parent)
	local frameH = Utils.createSimpleFrame('$parentHealthBar', parent, true)
	local h, w = Layout.HW('HEALTH')
	frameH:SetFrameLevel(0)

	frameH.bar = CreateFrame('StatusBar', nil, frameH)
	frameH.bar:SetStatusBarTexture(SP.Vars.ui.textures.BAR_TEX)
	frameH.bar:GetStatusBarTexture():SetHorizTile(false)
	frameH.bar:SetSize(h - 2, w - 2)
	frameH.bar:SetPoint('CENTER', 0, 0)
	frameH.bar:SetMinMaxValues(1, 10)
	frameH.bar:SetValue(7)
	frameH.bar:SetFrameLevel(1)
	self:Smooth(frameH.bar)

	frameH.pc = frameH.bar:CreateFontString(nil, 'OVERLAY')
	frameH.pc:SetPoint(Layout.AXY('HEALTH_TEXT'))
	frameH.pc:SetFont(SP.Vars.ui.font, Layout.GET('HEALTH_TEXT', 'size') * Layout.GET('GENERAL', 'scale'), 'OUTLINE')
	frameH.pc:SetJustifyH('LEFT')
	frameH.pc:SetShadowOffset(1, -1)
	frameH.pc:SetTextColor(1, 1, 1)
	frameH.pc:SetText('70%')
	frameH.pc:SetAlpha(Layout.GET('HEALTH_TEXT', 'opacity'))

	frameH.back = Utils.createSimpleFrame('$parentBack', frameH, true)
	frameH.back:SetSize(h, w)
	frameH.back:SetPoint('CENTER', 0, 0)
	frameH.back:SetBackdrop(SP.Vars.ui.backdrops.stdbd)
	frameH.back:SetBackdropColor(0, 0, 0, 0.4)

	return frameH
end

function SmoothyPlate:ConstructElement_TargetIndicator(parent)
	local frameT = Utils.createSimpleFrame('$parentTargetIndicator', parent, true)

	frameT:SetSize(Layout.HW('TARGET'))
	frameT:SetPoint(Layout.AXY('TARGET'))
	frameT:SetFrameLevel(2)
	frameT:SetAlpha(Layout.GET('TARGET', 'opacity'))

	-- frameT:SetBackdrop(SP.Vars.ui.backdrops.stdbd)
	-- frameT:SetBackdropColor(unpack(SP.Vars.ui.colors.red))

	-- TARGET_INDICATOR
	frameT.tex = frameT:CreateTexture()
	frameT.tex:SetTexture(SP.Vars.ui.textures.TARGET)
	frameT.tex:SetAllPoints()

	-- frameT.tex:SetRotation(-0.785)
	-- frameT.tex:SetVertexColor(unpack(SP.Vars.ui.colors.red));

	return frameT
end

function SmoothyPlate:ConstructElement_PowerBar(parent)
	local frameP = Utils.createSimpleFrame('$parentPowerBar', parent, true)
	local w, h = Layout.HW('POWER')

	frameP.bar = CreateFrame('StatusBar', nil, frameP)
	frameP.bar:SetStatusBarTexture(SP.Vars.ui.textures.BAR_TEX)
	frameP.bar:GetStatusBarTexture():SetHorizTile(false)
	frameP.bar:SetSize(w - 2, h - 2)
	frameP.bar:SetPoint('CENTER', 0, 0)
	frameP.bar:SetStatusBarColor(0.9, 0.9, 0.1, 1)
	self:Smooth(frameP.bar)

	frameP.back = Utils.createSimpleFrame('$parentBack', frameP, true)
	frameP.back:SetSize(w, h)
	frameP.back:SetPoint('CENTER', 0, 0)
	frameP.back:SetBackdrop(SP.Vars.ui.backdrops.stdbdne)
	frameP.back:SetBackdropColor(0, 0, 0, 0.4)

	Utils.addSingleBorders(frameP.back, 0, 0, 0, 1)

	local hb = Layout.GET('POWER', 'hide border') or 'n'
	if not (hb == 'n') then
		frameP.back[hb]:Hide()
	end

	frameP:SetFrameLevel(4)

	return frameP
end

function SmoothyPlate:ConstructElement_CastBar(parent)
	local frameC = Utils.createSimpleFrame('$parentCastBar', parent, true)
	local w, h = Layout.HW('CAST')

	Utils.addBorder(frameC)

	frameC.bar = CreateFrame('StatusBar', nil, frameC)
	frameC.bar:SetStatusBarTexture(SP.Vars.ui.textures.BAR_TEX)
	frameC.bar:GetStatusBarTexture():SetHorizTile(false)
	frameC.bar:SetSize(w - 2, h - 2)
	frameC.bar:SetPoint('CENTER', 0, 0)
	frameC.bar:SetStatusBarColor(Utils.fromRGB(255, 255, 0, 255))
	-- self:Smooth(frameC.bar)

	frameC.bar:SetMinMaxValues(1, 10)
	frameC.bar:SetValue(7)

	w, h = Layout.HW('CAST_ICON')
	local a, x, y = Layout.AXY('CAST_ICON')
	local tex = GetSpellTexture(19750)
	Utils.createTextureFrame(frameC, w, h, a, x, y, Layout.GET('CAST_ICON', 'opacity'), tex)

	frameC.name = frameC.bar:CreateFontString(nil, 'OVERLAY')
	frameC.name:SetPoint(Layout.APXY('CAST_TEXT', frameC))
	frameC.name:SetFont(SP.Vars.ui.font, Layout.GET('CAST_TEXT', 'size') * Layout.GET('GENERAL', 'scale'), 'OUTLINE')
	frameC.name:SetJustifyH('LEFT')
	frameC.name:SetShadowOffset(1, -1)
	frameC.name:SetTextColor(1, 1, 1)
	frameC.name:SetText('Flash of Light')

	self:hookFrame('CAST', frameC)
	frameC:Hide()

	return frameC
end

function SmoothyPlate:ConstructElement_AbsorbBar(parent)
	local frameAB = CreateFrame('StatusBar', '$parentAbsorbBar', parent)

	if SP.db.options.absorbs then
		local h, w = Layout.HW('HEALTH')
		frameAB:SetSize(h - 4, w)
		frameAB:SetStatusBarTexture(SP.Vars.ui.textures.PRED_BAR_TEX)
		frameAB:GetStatusBarTexture():SetHorizTile(false)
		frameAB:SetStatusBarColor(1, 1, 1, 0.6)
		frameAB:SetFrameLevel(1)
		self:Smooth(frameAB)
		frameAB.active = true
	end

	return frameAB
end

function SmoothyPlate:ConstructElement_Name(parent)
	local frameN = parent:CreateFontString(nil, 'OVERLAY')
	frameN:SetFont(SP.Vars.ui.font, Layout.GET('NAME', 'size') * Layout.GET('GENERAL', 'scale'), 'OUTLINE')
	frameN:SetJustifyH('LEFT')
	frameN:SetShadowOffset(1, -1)
	frameN:SetTextColor(1, 1, 1)
	frameN:SetText('Name')

	return frameN
end

function SmoothyPlate:ConstructElement_RaidIcon(parent)
	local frameRI = CreateFrame('Frame', '$parentRaidIcon', parent)

	frameRI.tex = frameRI:CreateTexture()
	frameRI.tex:SetAllPoints()
	frameRI.tex:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])

	SetRaidTargetIconTexture(frameRI.tex, 8)

	self:hookFrame('RAID_ICON', frameRI)
	frameRI:Hide()

	return frameRI
end

local UnitGUID = UnitGUID
function SmoothyPlate:AddUnit(unitid)
	self.unitid = unitid
	self.guid = UnitGUID(unitid)

	self:UpdateName()
	self:UpdateHealth()
	self:UpdateHealthColor()
	self:UpdatePower()
	self:UpdatePowerColor()
	self:UpdateCastBarMidway()
	self:UpdateRaidTargetIcon()
	self:UpdateTargetIndicator()

	self.sp:Show()
end

function SmoothyPlate:RemoveUnit()
	self.unitid = nil
	self.guid = nil
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
local UnitIsUnit = UnitIsUnit

function SmoothyPlate:UpdateTargetIndicator()
	if not self.unitid then
		return
	end

	if UnitIsUnit('target', self.unitid) or self.debug then
		self.sp.TargetIndicator:Show()
	else
		self.sp.TargetIndicator:Hide()
	end
end

function SmoothyPlate:UpdateName()
	if not self.unitid then
		return
	end

	local unitName = GetUnitName(self.unitid, false)
	self.sp.Name:SetText(unitName)
end

function SmoothyPlate:UpdateHealth()
	if not self.unitid then
		return
	end

	local currHealth, maxHealth = UnitHealth(self.unitid), UnitHealthMax(self.unitid)
	self.sp.HealthBar.bar:SetMinMaxValues(0, maxHealth)
	self.sp.HealthBar.bar:SetValue(currHealth)

	self.sp.HealthBar.pc:SetText(Utils.percent(currHealth, maxHealth) .. '%')
	self.currHealth = currHealth
	self.health = maxHealth

	self:UpdateHealAbsorbPrediction()
end

local UnitIsTapDenied = UnitIsTapDenied

function SmoothyPlate:UpdateTapped()
	if not self.unitid then
		return
	end

	if not UnitIsPlayer(self.unitid) and UnitIsTapDenied(self.unitid) then
		-- tapped by other players, use gray
		self.sp.HealthBar.bar:SetStatusBarColor(0.6, 0.6, 0.6)
		self.sp.HealthBar:SetBackdropColor(0.6, 0.6, 0.6, 0.2)
	end
end

function SmoothyPlate:UpdateHealthColor()
	if not self.unitid then
		return
	end

	local r, g, b

	if UnitIsPlayer(self.unitid) then
		local classFileName = select(2, UnitClass(self.unitid))
		local color = RAID_CLASS_COLORS[classFileName]
		if color then
			r, g, b = color.r, color.g, color.b
		end
	else
		r, g, b = UnitSelectionColor(self.unitid)
	end

	if r == nil or g == nil or b == nil then
		r = 0.9
		g = 0.9
		b = 0.1
	end

	-- Set Color to Class- or Thread-Color | else we use the standard yellow
	self.sp.HealthBar.bar:SetStatusBarColor(r, g, b)
	self.sp.HealthBar:SetBackdropColor(r, g, b, 0.2)

	self:UpdateTapped()
end

function SmoothyPlate:UpdatePower()
	if not self.unitid then
		return
	end

	local currPower, maxPower = UnitPower(self.unitid), UnitPowerMax(self.unitid)
	self.sp.PowerBar.bar:SetMinMaxValues(0, maxPower)
	self.sp.PowerBar.bar:SetValue(currPower)
end

function SmoothyPlate:UpdatePowerColor()
	if not self.unitid then
		return
	end

	local powerType, _, r, g, b = UnitPowerType(self.unitid)
	if powerType then
		local color = PowerBarColor[powerType]
		r, g, b = color.r, color.g, color.b
	end

	-- Set Color to Powertype-Color or an alternative Power-Color
	self.sp.PowerBar.bar:SetStatusBarColor(r, g, b)
	self.sp.PowerBar:SetBackdropColor(r, g, b, 0.2)
end

local GetRaidTargetIndex, SetRaidTargetIconTexture, mathmin = GetRaidTargetIndex, SetRaidTargetIconTexture, math.min
function SmoothyPlate:UpdateRaidTargetIcon()
	if not self.unitid then
		return
	end

	local icon = self.sp.RaidIcon
	local index = GetRaidTargetIndex(self.unitid)

	if index then
		SetRaidTargetIconTexture(icon.tex, index)
		icon:Show()
	else
		icon:Hide()
	end
end

local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs

function SmoothyPlate:UpdateHealAbsorbPrediction()
	if not self.unitid then
		return
	end

	local absorb = UnitGetTotalAbsorbs(self.unitid) or 0

	-- absorb = 300000

	local sp = self.sp
	local AbsorbBar = sp.AbsorbBar
	local HealthBar = sp.HealthBar.bar

	absorb = mathmin(absorb, self.health - self.currHealth)
	self.currAbsorb = absorb

	local barWidth = HealthBar:GetWidth()
	local currHealthPercent = (self.currHealth / self.health) * 100
	local offsetX = (currHealthPercent / 100) * barWidth

	AbsorbBar:Hide()
	if (offsetX >= (barWidth - 1)) then
		return
	end

	if absorb > 0 and AbsorbBar.active then
		AbsorbBar:SetPoint('TOPLEFT', HealthBar, offsetX, 0)
		AbsorbBar:SetPoint('BOTTOMLEFT', HealthBar, offsetX, 0)
		AbsorbBar:SetMinMaxValues(0, self.health)
		AbsorbBar:SetValue(absorb)
		AbsorbBar:Show()
	end
end

function SmoothyPlate:UpdateCastBarMidway()
	if not self.unitid then
		return
	end

	if UnitCastingInfo(self.unitid) then
		self:StartCasting(false)
	else
		if UnitChannelInfo(self.unitid) then
			self:StartCasting(true)
		end
	end
end

function SmoothyPlate:PrepareCast(text, texture, min, max, notInterruptible)
	if not self.unitid then
		return
	end

	self.sp.CastBar.bar:SetMinMaxValues(min, max)
	self.sp.CastBar.name:SetText(text)
	self.sp.CastBar.tex:SetTexture(texture)
	self.sp.CastBar.tex:SetTexCoord(0.07, 0.93, 0.07, 0.93)

	if notInterruptible then
		self.sp.CastBar.bar:SetStatusBarColor(Utils.fromRGB(152, 152, 152, 255))
	else
		self.sp.CastBar.bar:SetStatusBarColor(Utils.fromRGB(237, 219, 72, 255))
	end
end

local function OnUpdateCastBarForward(self)
	local currentTime = GetTime() * 1000
	self:SetValue(currentTime)
end

local function OnUpdateCastBarReverse(self, startTime, endTime)
	local currentTime = GetTime() * 1000
	local newValue = (endTime + startTime) - currentTime
	self:SetValue(newValue)
end

function SmoothyPlate:StartCasting(channeled)
	if not self.unitid then
		return
	end

	-- TODO: the cast bar still seems laggy...
	-- dont know what it is. maybe it is a result of the nameplate scale?
	self:StopCasting()
	local name, text, texture, startTime, endTime, notInterruptible, updateFunc, isTradeSkill, _
	local bar = self.sp.CastBar.bar
	if channeled then
		name, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo(self.unitid)
		updateFunc = function()
			OnUpdateCastBarReverse(bar, startTime, endTime)
		end
	else
		name, text, texture, startTime, endTime, isTradeSkill, _, notInterruptible = UnitCastingInfo(self.unitid)
		updateFunc = function()
			OnUpdateCastBarForward(bar, startTime, endTime)
		end
	end

	if isTradeSkill or not name or not startTime or not endTime then
		return
	end

	self:PrepareCast(text, texture, startTime, endTime, notInterruptible)
	bar:SetScript('OnUpdate', updateFunc)
	self.sp.CastBar:Show()
end

function SmoothyPlate:StopCasting()
	self.sp.CastBar.bar:SetScript('OnUpdate', nil)
	self.sp.CastBar:Hide()
end

-------------------------------

SP.Layout = Layout
SP.SmoothyPlate = SmoothyPlate
