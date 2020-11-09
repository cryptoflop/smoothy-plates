local SP = SmoothyPlates
local Utils = SP.Utils

local _, scale = GetPhysicalScreenSize()
SP.Vars.perfectScale = 768/scale;
SetCVar('nameplateGlobalScale', 1)


SP.Ace.Event.RegisterEvent(SP, "NAME_PLATE_UNIT_ADDED", function(e, unitid) NAME_PLATE_UNIT_ADDED(unitid) end);
SP.Ace.Event.RegisterEvent(SP, "NAME_PLATE_UNIT_REMOVED", function(e, unitid) NAME_PLATE_UNIT_REMOVED(unitid) end);


local GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit
local UnitIsUnit = UnitIsUnit
local UnitGUID = UnitGUID

local PlateStorage = {}

function BypassFunction() return true end

-- blizz frame does not exists at this point
-- function NAME_PLATE_CREATED(event, plate) end

function NAME_PLATE_UNIT_ADDED(unitid)
	local plate = GetNamePlateForUnit(unitid);

	local blizzFrame = plate.UnitFrame;

	blizzFrame._Show = blizzFrame.Show
	blizzFrame.Show = BypassFunction
	blizzFrame:Hide();

	SP.SmoothyPlate(plate);
	SP.callbacks:Fire("AFTER_SP_CREATION", plate)

	-- Personal Display
	if UnitIsUnit("player", unitid) then
		plate:GetChildren():_Show()
	-- Normal Plates
	else
		plate:GetChildren():Hide()
		if plate and plate.SmoothyPlate then
			plate.SmoothyPlate:AddUnit(unitid)
			PlateStorage[UnitGUID(plate.SmoothyPlate.unitid)] = plate
			SP.callbacks:Fire("AFTER_SP_UNIT_ADDED", plate)
		end
	end
end

function NAME_PLATE_UNIT_REMOVED(unitid)
	local plate = GetNamePlateForUnit(unitid);

	if unitid and plate and plate.SmoothyPlate and plate.SmoothyPlate.unitid then
		SP.callbacks:Fire("BEFORE_SP_UNIT_REMOVED", plate)
		PlateStorage[UnitGUID(plate.SmoothyPlate.unitid)] = nil
		plate.SmoothyPlate:RemoveUnit()
	end
end

function getPlateByGUID(guid)
	return PlateStorage[guid]
end

function forEachPlate(func)
	if not func then return end

	for guid, plate in pairs(PlateStorage) do
		if plate then
			func(plate, guid)
		end
	end
end

SP.Nameplates = {
	getPlateByGUID = getPlateByGUID,
	forEachPlate = forEachPlate
}

----------------Plate Event handling-----------------

local EventHandler = {}

function EventHandler:UNIT_HEALTH(event, unitid)
	if not unitid then return end
	local plate = GetNamePlateForUnit(unitid)
	if not plate or event and UnitIsUnit("player", unitid) then return end

	plate.SmoothyPlate:UpdateHealth();
end

function EventHandler:UNIT_MAXHEALTH(event, unitid)
	self:UNIT_HEALTH(event, unitid)
end

function EventHandler:UNIT_POWER_UPDATE(event, unitid)
	if not unitid then return end
	local plate = GetNamePlateForUnit(unitid)
	if not plate or UnitIsUnit("player", unitid) then return end

	plate.SmoothyPlate:UpdatePower();
end

function EventHandler:UNIT_MAXPOWER(event, unitid)
	self:UNIT_POWER_UPDATE(event, unitid)
end

function EventHandler:UNIT_POWER_FREQUENT(event, unitid)
	self:UNIT_POWER_UPDATE(event, unitid)
end

function EventHandler:UNIT_DISPLAYPOWER(event, unitid)
	if not unitid then return end
	local plate = GetNamePlateForUnit(unitid)
	if not plate or UnitIsUnit("player", unitid) then return end

	plate.SmoothyPlate:UpdateHealthColor();
	plate.SmoothyPlate:UpdatePowerColor();
end

function EventHandler:UNIT_HEAL_PREDICTION(event, unitid)
	if not unitid then return end
	local plate = GetNamePlateForUnit(unitid)
	if not plate or UnitIsUnit("player", unitid) then return end

	plate.SmoothyPlate:UpdateHealAbsorbPrediction()
end

function EventHandler:UNIT_ABSORB_AMOUNT_CHANGED(event, unitid)
	self:UNIT_HEAL_PREDICTION(event, unitid)
end

function EventHandler:UNIT_HEAL_ABSORB_AMOUNT_CHANGED(event, unitid)
	self:UNIT_HEAL_PREDICTION(event, unitid)
end

function EventHandler:UNIT_NAME_UPDATE(event, unitid)
	if not unitid then return end
	local plate = GetNamePlateForUnit(unitid)
	if not plate or UnitIsUnit("player", unitid) then return end

	plate.SmoothyPlate:UpdateName();
	plate.SmoothyPlate:UpdateHealthColor();
	plate.SmoothyPlate:UpdatePowerColor();
end

function EventHandler:PLAYER_TARGET_CHANGED(event, unitid)
	self:UNIT_NAME_UPDATE(event, unitid)
end

function EventHandler:RAID_TARGET_UPDATE(event)
	forEachPlate(function(plate)
		plate.SmoothyPlate:UpdateRaidTargetIcon();
	end)
end

function EventHandler:UNIT_SPELLCAST_START(event, unitid)
	if not unitid then return end

	local plate = GetNamePlateForUnit(unitid)
	if not plate or UnitIsUnit("player", unitid) then return end

	SP.callbacks:Fire("BEFORE_SP_UNIT_CAST_START", plate)
	plate.SmoothyPlate:StartCasting(false)
end

function EventHandler:UNIT_SPELLCAST_STOP(event, unitid)
	if not unitid then return end
	local plate = GetNamePlateForUnit(unitid)
	if not plate or UnitIsUnit("player", unitid) then return end

	plate.SmoothyPlate:StopCasting()
	SP.callbacks:Fire("SP_UNIT_SPELLCAST_STOP", plate)
end

function EventHandler:UNIT_SPELLCAST_CHANNEL_START(event, unitid)
	if not unitid then return end
	local plate = GetNamePlateForUnit(unitid)
	if not plate or UnitIsUnit("player", unitid) then return end

	SP.callbacks:Fire("BEFORE_SP_UNIT_CHANNEL_START", plate)
	plate.SmoothyPlate:StartCasting(true)

end

function EventHandler:UNIT_SPELLCAST_CHANNEL_STOP(event, unitid)
	self:UNIT_SPELLCAST_STOP(event, unitid)
end

function EventHandler:UNIT_SPELLCAST_CHANNEL_UPDATE(event, unitid)
	if not unitid then return end
	local plate = GetNamePlateForUnit(unitid)
	if not plate or UnitIsUnit("player", unitid) then return end

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