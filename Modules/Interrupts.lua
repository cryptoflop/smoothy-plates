local SP = SmoothyPlates
local Utils = SP.Utils
local Interrupts = SP.Addon:NewModule('Interrupts')
local libGlow = LibStub('LibButtonGlow-1.0')

local GetTime = GetTime
local getPlateByGUID = SP.Nameplates.getPlateByGUID

local KickTexture

local activeInterrupts = {}

SP.hookOnClean(
	function()
		activeInterrupts = {}
	end
)

function Interrupts:OnEnable()
	KickTexture = GetSpellTexture(1766)

	SP.SmoothyPlate.RegisterFrame('Interrupts', 'INTERRUPT')

	SP.callbacks.RegisterCallback(self, 'AFTER_SP_CREATION', 'CreateElement_INTERRUPTS')
	SP.callbacks.RegisterCallback(self, 'AFTER_SP_UNIT_ADDED', 'UNIT_ADDED')
	SP.callbacks.RegisterCallback(self, 'BEFORE_SP_UNIT_REMOVED', 'UNIT_REMOVED')
	SP.callbacks.RegisterCallback(self, 'BEFORE_SP_UNIT_CAST_START', 'UNIT_CAST_START')
	SP.callbacks.RegisterCallback(self, 'BEFORE_SP_UNIT_CHANNEL_START', 'UNIT_CAST_START')

	self.cc = LibStub('LibInterrupt-1.0')
	self.cc.RegisterCallback(self, 'ENEMY_INTERRUPT')
	self.cc.RegisterCallback(self, 'ENEMY_INTERRUPT_FADED')
end

function Interrupts:CreateElement_INTERRUPTS(_, plate)
	local sp = plate.SmoothyPlate.sp

	local s = SP.Layout.GET('INTERRUPT', 'size')
	local a, p, x, y = SP.Layout.APXY('INTERRUPT', sp)

	sp.INTERRUPT = CreateFrame('Frame', nil, sp)
	sp.INTERRUPT:SetSize(s, s)
	sp.INTERRUPT:SetPoint(a, p, x, y)

	Utils.createTextureFrame(sp.INTERRUPT, s, s, a, 0, 0, 1, KickTexture)

	sp.INTERRUPT.cd = CreateFrame('Cooldown', nil, sp.INTERRUPT.textureBack, 'CooldownFrameTemplate')
	sp.INTERRUPT.cd:SetAllPoints()
	sp.INTERRUPT.cd:SetHideCountdownNumbers(false)
	sp.INTERRUPT.cd:SetReverse(true)

	if SP.Layout.GET('INTERRUPT', 'glow') then
		libGlow.ShowOverlayGlow(sp.INTERRUPT.textureBack)
	end

	if SP.Layout.GET('INTERRUPT', 'red border') then
		Utils.setBorderColor(sp.INTERRUPT.textureBack, unpack(SP.Vars.ui.colors.red))
	end

	plate.SmoothyPlate:hookFrame('INTERRUPT')
	sp.INTERRUPT:Hide()
end

local packCooldownInfo = Utils.packCooldownInfo

function Interrupts:ENEMY_INTERRUPT(_, destGUID, _, spellId, duration)
	activeInterrupts[destGUID] = packCooldownInfo(spellId, duration, GetTime() + duration, 1)
	self:ApplyInterrupt(destGUID)
end

function Interrupts:ENEMY_INTERRUPT_FADED(_, destGUID)
	activeInterrupts[destGUID] = nil
	self:ApplyInterrupt(destGUID)
end

local getCooldown = Utils.getCooldown

function Interrupts:ApplyInterrupt(guid, plate)
	if not plate then
		plate = getPlateByGUID(guid)
		if not plate then
			return
		end
	end
	local interrupt = activeInterrupts[guid]

	local interruptFrame = plate.SmoothyPlate.sp.INTERRUPT
	if interrupt then
		local icon
		if interrupt.spellId then
			icon = GetSpellTexture(interrupt.spellId)
		else
			icon = KickTexture
		end

		interruptFrame.tex:SetTexture(icon)
		interruptFrame.tex:SetTexCoord(0.07, 0.93, 0.07, 0.93)

		interruptFrame.cd:SetCooldown(getCooldown(interrupt))

		interruptFrame:Show()
	else
		interruptFrame:Hide()
	end
end

function Interrupts:UNIT_CAST_START(_, plate)
	self:UNIT_REMOVED(nil, plate)
end

function Interrupts:UNIT_ADDED(_, plate)
	self:ApplyInterrupt(plate.SmoothyPlate.guid)
end

function Interrupts:UNIT_REMOVED(_, plate)
	activeInterrupts[plate.SmoothyPlate.guid] = nil
	self:ApplyInterrupt(plate.SmoothyPlate.guid, plate)
end
