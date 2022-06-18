local SP = SmoothyPlates

local _, scale = GetPhysicalScreenSize()
SP.Vars.perfectScale = 768 / scale

local GuidToId = {}

function setCVars()
	SetCVar('nameplateMinScale', 1)
	SetCVar('nameplateMaxScale', 1)
	SetCVar('nameplateGlobalScale', 1)
	SetCVar('nameplateSelectedScale', 1)
end

-- other addons may set the nameplate scale after loading
SP.hookOnInit(
	function()
		SP.Ace.Timer:ScheduleTimer(setCVars, 2)
		initHidingConditions()
	end
)

local GetNamePlateForUnit, GetNamePlates = C_NamePlate.GetNamePlateForUnit, C_NamePlate.GetNamePlates
local UnitIsUnit = UnitIsUnit

function getPlateByGUID(guid)
	local unitid = GuidToId[guid]
	if unitid then
		return GetNamePlateForUnit(unitid)
	end
	return nil
end

function forEachPlate(func)
	local plates = GetNamePlates()
	for _, plate in pairs(plates) do
		func(plate)
	end
end

SP.Nameplates = {
	getPlateByGUID = getPlateByGUID,
	forEachPlate = forEachPlate
}

----------------Plate Event handling-----------------

function plateIsSupported(unitid)
	if unitid == 'player' then
		return false
	end
	if UnitNameplateShowsWidgetsOnly(unitid) then
		return false
	end
	return true
end

function hookOnUnitFrame(plate)
	if plate.UnitFrame and not plate.UnitFrame._smp_modified then
		local hideUnitFrame = function()
			if plateIsSupported(plate.UnitFrame.unit) then
				plate.UnitFrame:Hide()
			end
		end
		plate.UnitFrame.smp_modified = true
		plate.UnitFrame:HookScript('OnShow', hideUnitFrame)
		hideUnitFrame()
	end
end

local hidingConditions = {}

function initHidingConditions()
	if SP.db.options.hideUnimportantPets then
		local UnitIsPlayer, UnitPlayerControlled, UnitCreatureType = UnitIsPlayer, UnitPlayerControlled, UnitCreatureType
		local checkCreature = function(unitid)
			return not UnitIsPlayer(unitid) and UnitPlayerControlled(unitid) and UnitCreatureType(unitid) ~= 'Totem'
		end
		table.insert(hidingConditions, checkCreature)
	end

	if SP.db.options.hideUnimportantTotems then
		local importantTotemIds = {204331, 204336, 51485, 98008, 204332, 192077, 192058, 15786}
		local importantTotemNames = {}
		-- convert ids to names
		for _, id in ipairs(importantTotemIds) do
			importantTotemNames[select(1, GetSpellInfo(id))] = true
		end
		local UnitCreatureType, UnitName = UnitCreatureType, UnitName
		local checkTotem = function(unitid)
			return UnitCreatureType(unitid) == 'Totem' and not importantTotemNames[UnitName(unitid)]
		end
		table.insert(hidingConditions, checkTotem)
	end
end

function shouldHidePlate(unitid)
	for _, condition in ipairs(hidingConditions) do
		if condition(unitid) then
			return true
		end
	end
	return false
end

local EventHandler = {}

function EventHandler:NAME_PLATE_UNIT_ADDED(_, unitid)
	if plateIsSupported(unitid) then
		local plate = GetNamePlateForUnit(unitid)
		if not plate then
			return
		end

		if not plate.SmoothyPlate then
			SP.SmoothyPlate(plate)
			hookOnUnitFrame(plate)
			SP.callbacks:Fire('AFTER_SP_CREATION', plate)
		end

		if shouldHidePlate(unitid) then
			return
		end

		plate.SmoothyPlate:AddUnit(unitid)
		GuidToId[plate.SmoothyPlate.guid] = unitid
		SP.callbacks:Fire('AFTER_SP_UNIT_ADDED', plate)
	end
end

function EventHandler:NAME_PLATE_UNIT_REMOVED(_, unitid)
	local plate = GetNamePlateForUnit(unitid)
	if not plate then
		return
	end

	if plate.SmoothyPlate and plate.SmoothyPlate.unitid then
		SP.callbacks:Fire('BEFORE_SP_UNIT_REMOVED', plate)
		GuidToId[plate.SmoothyPlate.guid] = nil
		plate.SmoothyPlate:RemoveUnit()
	end
end

function validPlate(plate)
	if plate and plate.SmoothyPlate.unitid and not UnitIsUnit('player', plate.SmoothyPlate.unitid) then
		return true
	else
		return false
	end
end

function EventHandler:UNIT_HEALTH(_, unitid)
	if not unitid then
		return
	end
	local plate = GetNamePlateForUnit(unitid)
	if not validPlate(plate) then
		return
	end

	plate.SmoothyPlate:UpdateHealth()
	plate.SmoothyPlate:UpdateTapped()
end

function EventHandler:UNIT_MAXHEALTH(event, unitid)
	self:UNIT_HEALTH(event, unitid)
end

function EventHandler:UNIT_POWER_UPDATE(_, unitid)
	if not unitid then
		return
	end
	local plate = GetNamePlateForUnit(unitid)
	if not validPlate(plate) then
		return
	end

	plate.SmoothyPlate:UpdatePower()
end

function EventHandler:UNIT_MAXPOWER(event, unitid)
	self:UNIT_POWER_UPDATE(event, unitid)
end

function EventHandler:UNIT_POWER_FREQUENT(event, unitid)
	self:UNIT_POWER_UPDATE(event, unitid)
end

function EventHandler:UNIT_DISPLAYPOWER(_, unitid)
	if not unitid then
		return
	end
	local plate = GetNamePlateForUnit(unitid)
	if not validPlate(plate) then
		return
	end

	plate.SmoothyPlate:UpdateHealthColor()
	plate.SmoothyPlate:UpdatePowerColor()
end

function EventHandler:UNIT_HEAL_PREDICTION(event, unitid)
	self:UNIT_HEALTH(event, unitid)
end

function EventHandler:UNIT_ABSORB_AMOUNT_CHANGED(event, unitid)
	self:UNIT_HEAL_PREDICTION(event, unitid)
end

function EventHandler:UNIT_HEAL_ABSORB_AMOUNT_CHANGED(event, unitid)
	self:UNIT_HEAL_PREDICTION(event, unitid)
end

function EventHandler:UNIT_NAME_UPDATE(_, unitid)
	if not unitid then
		return
	end
	local plate = GetNamePlateForUnit(unitid)
	if not validPlate(plate) then
		return
	end

	plate.SmoothyPlate:UpdateName()
	plate.SmoothyPlate:UpdateHealthColor()
	plate.SmoothyPlate:UpdatePowerColor()
end

local lastTargetPlate = nil
function EventHandler:PLAYER_TARGET_CHANGED(_)
	local plate = GetNamePlateForUnit('target')
	if lastTargetPlate then
		lastTargetPlate.SmoothyPlate:UpdateTargetIndicator()
		lastTargetPlate = nil
	end
	if not validPlate(plate) then
		return
	end

	plate.SmoothyPlate:UpdateTargetIndicator()
	lastTargetPlate = plate
end

function EventHandler:RAID_TARGET_UPDATE(_)
	forEachPlate(
		function(plate)
			plate.SmoothyPlate:UpdateRaidTargetIcon()
		end
	)
end

function EventHandler:UNIT_SPELLCAST_START(_, unitid)
	if not unitid then
		return
	end

	local plate = GetNamePlateForUnit(unitid)
	if not validPlate(plate) then
		return
	end

	SP.callbacks:Fire('BEFORE_SP_UNIT_CAST_START', plate)
	plate.SmoothyPlate:StartCasting(false)
end

function EventHandler:UNIT_SPELLCAST_STOP(_, unitid)
	if not unitid then
		return
	end
	local plate = GetNamePlateForUnit(unitid)
	if not validPlate(plate) then
		return
	end

	plate.SmoothyPlate:StopCasting()
	SP.callbacks:Fire('SP_UNIT_SPELLCAST_STOP', plate)
end

function EventHandler:UNIT_SPELLCAST_CHANNEL_START(_, unitid)
	if not unitid then
		return
	end
	local plate = GetNamePlateForUnit(unitid)
	if not validPlate(plate) then
		return
	end

	SP.callbacks:Fire('BEFORE_SP_UNIT_CHANNEL_START', plate)
	plate.SmoothyPlate:StartCasting(true)
end

function EventHandler:UNIT_SPELLCAST_CHANNEL_STOP(event, unitid)
	self:UNIT_SPELLCAST_STOP(event, unitid)
end

function EventHandler:UNIT_SPELLCAST_CHANNEL_UPDATE(_, unitid)
	if not unitid then
		return
	end
	local plate = GetNamePlateForUnit(unitid)
	if not validPlate(plate) then
		return
	end

	plate.SmoothyPlate:UpdateCastBarMidway()
end

function EventHandler:UNIT_SPELLCAST_DELAYED(event, unitid)
	self:UNIT_SPELLCAST_CHANNEL_UPDATE(event, unitid)
end

function EventHandler:UNIT_SPELLCAST_INTERRUPTIBLE(event, unitid)
	self:UNIT_SPELLCAST_CHANNEL_UPDATE(event, unitid)
end

function EventHandler:UNIT_SPELLCAST_NOT_INTERRUPTIBLE(event, unitid)
	self:UNIT_SPELLCAST_CHANNEL_UPDATE(event, unitid)
end

for eventName in pairs(EventHandler) do
	SP.Ace.Event.RegisterEvent(EventHandler, eventName, eventName)
end
