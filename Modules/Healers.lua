local SP = SmoothyPlates
local Utils = SP.Utils
local Healers = SP.Addon:NewModule('Healers', 'AceEvent-3.0')

local healerclasses = {
	[65] = 'Paladin: Holy',
	[105] = 'Druid: Restoration',
	[256] = 'Priest: Discipline',
	[257] = 'Priest: Holy',
	[264] = 'Shaman: Restoration',
	[270] = 'Monk: Mistweaver'
}

-- Stolen from Healers have to Die
local onlyHealerSpellIds = {
	-- Priests
	--      Discipline
	[047540] = 'PRIEST', -- Penance
	[109964] = 'PRIEST', -- Spirit shell -- not seen in disc
	[033206] = 'PRIEST', -- Pain Suppression
	[000527] = 'PRIEST', -- Purify
	[081749] = 'PRIEST', -- Atonement
	[132157] = 'PRIEST', -- Holy Nova
	--      Holy
	[000596] = 'PRIEST', -- Prayer of Healing
	[014914] = 'PRIEST', -- Holy Fire
	[002060] = 'PRIEST', -- Heal
	[034861] = 'PRIEST', -- Circle of Healing
	[064843] = 'PRIEST', -- Divine Hymn
	[047788] = 'PRIEST', -- Guardian Spirit
	[032546] = 'PRIEST', -- Binding Heal
	[077485] = 'PRIEST', -- Mastery: Echo of Light -- the passibe ability
	-- [077489] = "PRIEST", -- Echo of Light -- the aura applied by the afformentioned
	[000139] = 'PRIEST', -- Renew
	-- Druids - Restauration
	--[018562] = "DRUID", -- Swiftmend -- (also available through restoration afinity talent)
	[102342] = 'DRUID', -- Ironbark
	[033763] = 'DRUID', -- Lifebloom
	[088423] = 'DRUID', -- Nature's Cure
	-- [008936] = "DRUID", -- Regrowth -- (also available through restoration afinity talent)
	[033891] = 'DRUID', -- Incarnation: Tree of Life
	-- [048438] = "DRUID", -- Wild Growth -- disabled in WoW8: In the feral talents, level 45, you can choose Restoration Affinity, which includes Rejuv, Swiftmend, Wild Growth.
	[000740] = 'DRUID', -- Tranquility
	-- [145108] = "DRUID", -- Ysera's Gift -- (also available through restoration afinity talent)
	-- [000774] = "DRUID", -- Rejuvination -- (also available through restoration afinity talent)

	-- Shamans - Restauration
	[061295] = 'SHAMAN', -- Riptide
	[077472] = 'SHAMAN', -- Healing Wave
	[098008] = 'SHAMAN', -- Spirit link totem
	[073920] = 'SHAMAN', -- Healing Rain
	-- Paladins - Holy
	[020473] = 'PALADIN', -- Holy Shock
	[053563] = 'PALADIN', -- Beacon of Light
	[082326] = 'PALADIN', -- Holy Light
	[085222] = 'PALADIN', -- Light of Dawn
	-- Monks - Mistweaver
	[115175] = 'MONK', -- Soothing Mist
	[115310] = 'MONK', -- Revival
	--[116670] = "MONK", -- Vivify all monks have it in WoW8
	[116680] = 'MONK', -- Thunder Focus Tea
	[116849] = 'MONK' -- Life Cocoon
	-- [119611] = "MONK", -- Renewing mist
}

function Healers:OnEnable()
	SP.SmoothyPlate.RegisterFrame('Healer Icon', 'HEALER_ICON')

	self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')

	SP.callbacks.RegisterCallback(self, 'AFTER_SP_CREATION', 'CreateElement_HealerIcon')
	SP.callbacks.RegisterCallback(self, 'AFTER_SP_UNIT_ADDED', 'UNIT_ADDED')
	SP.callbacks.RegisterCallback(self, 'BEFORE_SP_UNIT_REMOVED', 'UNIT_REMOVED')
end

local healerGUIDs = {}

SP.hookOnClean(
	function()
		healerGUIDs = {}
	end
)

function Healers:CreateElement_HealerIcon(_, plate)
	local sp = plate.SmoothyPlate.sp

	local w, h = SP.Layout.HW('HEALER_ICON', self)
	local a, p, x, y = SP.Layout.APXY('HEALER_ICON', sp, self)

	local HealerIcon = CreateFrame('Frame', nil, sp)
	HealerIcon:SetFrameLevel(2)
	HealerIcon:SetSize(w, h)
	HealerIcon:SetPoint(a, p, x, y)
	HealerIcon:SetAlpha(SP.Layout.GET('HEALER_ICON', 'opacity', self))

	HealerIcon.textureBack = Utils.createSimpleFrame(nil, HealerIcon, true)
	HealerIcon.textureBack:SetSize(w, h)
	HealerIcon.textureBack:SetPoint(a, x, y)

	Utils.addBorder(HealerIcon.textureBack)
	HealerIcon.textureBack:SetBackdropColor(0, 0, 0, 0.4)

	HealerIcon.tex = HealerIcon.textureBack:CreateTexture()
	HealerIcon.tex:SetTexture(SP.Vars.ui.textures.HEALER_ICON)
	HealerIcon.tex:SetAllPoints()

	sp['HEALER_ICON'] = HealerIcon
	plate.SmoothyPlate:hookFrame('HEALER_ICON')
	HealerIcon:Hide()
end

local getPlateByGUID = SP.Nameplates.getPlateByGUID

function Healers:UNIT_ADDED(_, plate)
	local smp = plate.SmoothyPlate
	if healerGUIDs[smp.guid] then
		smp.sp.HEALER_ICON:Show()
	else
		smp.sp.HEALER_ICON:Hide()
	end
end

function Healers:UNIT_REMOVED(_, plate)
	plate.SmoothyPlate.sp.HEALER_ICON:Hide()
end

function Healers:COMBAT_LOG_EVENT_UNFILTERED()
	local _, _, _, sourceGUID, _, _, _, _, _, destFlags, _, spellID, _, _, _ = CombatLogGetCurrentEventInfo()

	if not CombatLog_Object_IsA(destFlags, COMBATLOG_FILTER_HOSTILE_PLAYERS) or not spellID or not sourceGUID then
		return
	end

	if healerGUIDs[sourceGUID] then
		return
	end

	if onlyHealerSpellIds[spellID] then
		healerGUIDs[sourceGUID] = true
		local plate = getPlateByGUID(sourceGUID)
		if plate then
			plate.SmoothyPlate.sp.HEALER_ICON:Show()
		end
	end
end

function Healers:isHealer(specId)
	if not specId then
		return false
	end

	if healerclasses[specId] then
		return true
	else
		return false
	end
end
