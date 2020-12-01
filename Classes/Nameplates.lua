local SP = SmoothyPlates
local Utils = SP.Utils

local _, scale = GetPhysicalScreenSize()
SP.Vars.perfectScale = 768/scale;

SP.Ace.Event.RegisterEvent(SP, "NAME_PLATE_UNIT_ADDED", function(e, unitid) NAME_PLATE_UNIT_ADDED(unitid) end)
SP.Ace.Event.RegisterEvent(SP, "NAME_PLATE_UNIT_REMOVED", function(e, unitid) NAME_PLATE_UNIT_REMOVED(unitid) end)

local GuidToId = {};

-- other addons may set the nameplate scale after loading
SP.hookOnInit(function()
	SP.Ace.Timer.ScheduleTimer({}, function() 
		SetCVar('nameplateGlobalScale', 1)
	end, 1)
end)
SetCVar('nameplateGlobalScale', 1)

local GetNamePlateForUnit, GetNamePlates = C_NamePlate.GetNamePlateForUnit, C_NamePlate.GetNamePlates
local UnitIsUnit = UnitIsUnit
local hooksecurefunc = hooksecurefunc

function getPlateByGUID(guid)
	local unitid = GuidToId[guid]
	if unitid then
		return GetNamePlateForUnit(unitid)
	end
	return nil;
end

function forEachPlate(func)
	local plates = GetNamePlates();
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
	if unitid == "player" then return false end
	if UnitNameplateShowsWidgetsOnly(unitid) then return false end
	return true
end

hooksecurefunc(NamePlateDriverFrame, "AcquireUnitFrame", function(plate)
	if not plate.isModified then
		plate.isModified = true
		hooksecurefunc(plate.UnitFrame, "Show", function(self)
			if plateIsSupported(self.unit) then
				self:Hide()
			end
		end)
	end
end)

function BypassShow() return true end

function NAME_PLATE_UNIT_ADDED(unitid)
	if plateIsSupported(unitid) then
		local plate = GetNamePlateForUnit(unitid)
		if not plate then return end
		
		if plate.UnitFrame then
			-- hide blizzard frame
			plate.UnitFrame:Hide()
		end

		if not plate.SmoothyPlate then
			SP.SmoothyPlate(plate);
			SP.callbacks:Fire("AFTER_SP_CREATION", plate)
		end

		plate.SmoothyPlate:AddUnit(unitid)
		GuidToId[plate.SmoothyPlate.guid] = unitid
		SP.callbacks:Fire("AFTER_SP_UNIT_ADDED", plate)
	end
end

function NAME_PLATE_UNIT_REMOVED(unitid)
	local plate = GetNamePlateForUnit(unitid);
	if not plate then return end

	if plate.SmoothyPlate and plate.SmoothyPlate.unitid then
		SP.callbacks:Fire("BEFORE_SP_UNIT_REMOVED", plate)
		GuidToId[plate.SmoothyPlate.guid] = nil
		plate.SmoothyPlate:RemoveUnit()
	end
end

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
	self:UNIT_HEALTH(event, unitid)
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
		plate.SmoothyPlate:UpdateRaidTargetIcon()
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