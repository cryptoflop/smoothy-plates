-- Author: Max David aka Vènomstrikè
-- 2016 - 2020

local SP = LibStub("AceAddon-3.0"):NewAddon("SmoothyPlates", "AceEvent-3.0", "AceTimer-3.0", "AceConsole-3.0", "AceSerializer-3.0")
local EventHandler = {}

--------------Global Variables----------------
SP.currVersion = "4.5.1"

SP.EditorBackground = "Interface\\Addons\\SmoothyPlates\\Media\\TGA\\EditorBackground"
SP.EDGE_TEX = "Interface\\Addons\\SmoothyPlates\\Media\\TGA\\border"
SP.FONT = "Interface\\Addons\\SmoothyPlates\\Media\\Font\\Purista-Medium.ttf"
SP.BAR_TEX = "Interface\\Addons\\SmoothyPlates\\Media\\TGA\\Glaze"
SP.PRED_BAR_TEX = "Interface\\Addons\\SmoothyPlates\\Media\\TGA\\Gloss"
SP.HEALER_ICON = "Interface\\Addons\\SmoothyPlates\\Media\\TGA\\healer"

--[[Interface\Tooltips\UI-Tooltip-Border]]
--"Interface\\TargetingFrame\\UI-TargetingFrame-BarFill"
--"Interface\RaidFrame\Absorb-Edge"

local GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit
local UnitIsUnit = UnitIsUnit

local aceGui, aceGuiWid, sharedMedia;

SP.stdbd = {
	bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
	tile = true,
	tileSize = 12,
	edgeFile = SP.EDGE_TEX,
	edgeSize = 1
}

SP.stdbdne = {
	bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
	tile = true,
	tileSize = 12,
	edgeSize = 0
}

SP.stdbd_edge = {
	edgeFile = SP.EDGE_TEX,
	insets = {
		left = 1,
		right = 1,
		top = 1,
		bottom = 1
	},
	edgeSize = 1,
}

function SP:AddBorder(frame)
	frame:SetBackdrop(SP.stdbd)
    frame:SetBackdropColor(0,0,0,0.6)
end

function SP:AddSingleBorders(parent, r, g, b, a)
	local size = 1;
	parent.l = CreateFrame("Frame", nil, parent)
	parent.l:SetSize(size, parent:GetHeight())
	parent.l:SetPoint("LEFT", 0, 0)
	parent.l:SetBackdrop(SP.stdbd)
    parent.l:SetBackdropColor(r,g,b,a)

	parent.r = CreateFrame("Frame", nil, parent)
	parent.r:SetSize(size, parent:GetHeight())
	parent.r:SetPoint("RIGHT", 0, 0)
	parent.r:SetBackdrop(SP.stdbd)
    parent.r:SetBackdropColor(r,g,b,a)

	parent.t = CreateFrame("Frame", nil, parent)
	parent.t:SetSize(parent:GetWidth(), size)
	parent.t:SetPoint("TOP", 0, 0)
	parent.t:SetBackdrop(SP.stdbd)
    parent.t:SetBackdropColor(r,g,b,a)

	parent.b = CreateFrame("Frame", nil, parent)
	parent.b:SetSize(parent:GetWidth(), size)
	parent.b:SetPoint("BOTTOM", 0, 0)
	parent.b:SetBackdrop(SP.stdbd)
    parent.b:SetBackdropColor(r,g,b,a)
end

function SP:CreateTextureFrame(parent, w, h, a, x, y, alpha, defText, dx, dy, dw, dh)
	parent.textureBack = CreateFrame("Frame", nil, parent)
	parent.textureBack:SetSize(w, h)
	parent.textureBack:SetPoint(a, x, y)
	parent.textureBack:SetAlpha(alpha)

    parent.tex = parent.textureBack:CreateTexture()
	parent.tex:SetAllPoints()

	if defText then
		parent.tex:SetTexture(defText)
		parent.tex:SetTexCoord(dx or 0.07, dy or 0.93, dw or 0.07, dh or 0.93)
		parent.tex:SetAllPoints()
	end

	SP:AddSingleBorders(parent.textureBack, 0,0,0,1);
end

-- all saved options in database
SP.dbo = nil;

----------------------------------------------

function SP:OnInitialize() -- the initialize part
	self:StartUp()
	--self:ScheduleTimer(function() SP:ShowLayoutGUI() end, 2.4)

	self:Print("Version: " .. SP.currVersion .. " loaded.")
end

-----------------Method Part-----------------

function SP:StartUp()
	local _, scale = GetPhysicalScreenSize()
	SP.perfectScale = 768/scale;
	SetCVar('nameplateGlobalScale', 1)

	aceGui = LibStub:GetLibrary("AceGUI-3.0", true)
	aceGuiWid = LibStub:GetLibrary("AceGUISharedMediaWidgets-1.0", true)
	sharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0", true)

	self.db = LibStub("AceDB-3.0"):New("SPDB")

	self:HandleFirstLoad()

	self:HandleMedia()

	self.callbacks = LibStub("CallbackHandler-1.0"):New(self)

	self.smoothy = LibStub("LibSmoothStatusBar-1.0")

	-------- Modules ----------

	for name, module in pairs(SP.dbo.modules.options) do
		if module.value then
			self:EnableModule(name)
		else
			self:DisableModule(name)
		end
	end

	---------------------------

	self:RegisterChatCommand("smp", "HandleChatCommand")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")

	local events = {};
	for eventName in pairs(EventHandler) do
		events[eventName] = true;
	end
	LibStub("AceEvent-3.0"):Embed(EventHandler)
	for eventName in pairs(events) do
		EventHandler:RegisterEvent(eventName)
	end

	self:RegisterEvent("NAME_PLATE_CREATED");
	self:RegisterEvent("NAME_PLATE_UNIT_ADDED");
	self:RegisterEvent("NAME_PLATE_UNIT_REMOVED");
	--self:RegisterEvent("PLAYER_TARGET_CHANGED");

end

function SP:HandleMedia()

	sharedMedia:Register("font", "Designosaur Regular", "Interface\\Addons\\SmoothyPlates\\Media\\Font\\Designosaur-Regular.ttf")
	sharedMedia:Register("font", "ElvUI Mentium", "Interface\\Addons\\SmoothyPlates\\Media\\Font\\ElvUI-Mentium.ttf")
	sharedMedia:Register("font", "Purista Medium", SP.FONT)
	sharedMedia:Register("statusbar", "Blizzard Nameplate Bar", "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill")
	sharedMedia:Register("statusbar", "Glaze", SP.BAR_TEX)
	sharedMedia:Register("statusbar", "Gloss", SP.PRED_BAR_TEX)
	sharedMedia:Register("statusbar", "Flat", "Interface\\Addons\\SmoothyPlates\\Media\\TGA\\Flat")
	sharedMedia:Register("statusbar", "Minimalist", "Interface\\Addons\\SmoothyPlates\\Media\\TGA\\Minimalist")
	sharedMedia:Register("statusbar", "Minimal", "Interface\\Addons\\SmoothyPlates\\Media\\TGA\\Minimal")

	if self.db.char.options then
		SP.FONT = sharedMedia:Fetch("font", SP.dbo.media.options.FONT.value)
		SP.BAR_TEX = sharedMedia:Fetch("statusbar", SP.dbo.media.options.BAR.value)
		SP.PRED_BAR_TEX = sharedMedia:Fetch("statusbar", SP.dbo.media.options.PRED_BAR.value)
	end

end

function SP:layout(frameName, property, module)
	local moduleName = "";
	if module then
		moduleName = string.upper(module.moduleName) .. "_";
	end
	local layoutInfo = SP.dbo.layout.options["LAYOUT_" .. moduleName .. frameName];
	if layoutInfo then
		return layoutInfo.value[property]
	else
		return nil
	end
end
function SP:layoutHW(frameName, module)
	local multiplier = SP:layout("GENERAL", "scale");
	local width, height = SP:layout(frameName, "width", module), SP:layout(frameName, "height", module);
	if not (width == nil) then width = width * multiplier end
	if not (height == nil) then height = height * multiplier end
	return width, height;
end
function SP:layoutAPXY(frameName, parent, module)
	local layoutParent = SP:layout(frameName, "parent", module);
	if layoutParent then
		parent = parent[layoutParent]
	end

	local a, x, y = self:layoutAXY(frameName, module)
	return a, parent, x, y;
end
function SP:layoutAXY(frameName, module)
	return SP:layout(frameName, "anchor", module), SP:layoutXY(frameName, module);
end
function SP:layoutXY(frameName, module)
	local multiplier = SP:layout("GENERAL", "scale");
	local x, y = SP:layout(frameName, "x", module), SP:layout(frameName, "y", module);
	if not (x == nil) then x = x * multiplier end
	if not (y == nil) then y = y * multiplier end
	return x, y;
end

function SP:DefaultDBOptions() 
	return SP:getDefaultConfig();
end

function SP:HandleFirstLoad()
	if not self.db.char.options then
		SP.dbo = self:DefaultDBOptions();
		self.db.char.options = SP.dbo;

		local frameP = aceGui:Create("Frame"); frameP:EnableResize(false)
		frameP:SetCallback("OnClose", function(widget) aceGui:Release(widget) end)
		frameP:SetLayout("Flow")
		frameP:SetWidth(260); frameP:SetHeight(140)
		local labelP = aceGui:Create("Label")
		labelP:SetText("This is the first time this AddOn is loaded. If you notice that your nameplates are not in the right shape, activate the [Bigger Nameplates]-Option in the Interface-Options. Type /smp to configure.");
		labelP:SetWidth(220)
		frameP:AddChild(labelP)
	else
		-- force default db
		-- self.db.char.options = self:DefaultDBOptions();
		if not (self.db.char.options.version == SP.currVersion) then
			-- when db has another version merge current db version options
			-- into current one
			self.db.char.options = TableMerge(self:DefaultDBOptions(), self.db.char.options)
			self:Print("Updated DB from: " .. self.db.char.options.version .. " to: " .. SP.currVersion)
			self.db.char.options.version = SP.currVersion
		end

		SP.dbo = self.db.char.options;
	end

end

function SP:CreateOptionFrame()
	if aceGui and aceGuiWid then

		local optionsFrame = aceGui:Create("Frame")
		optionsFrame:SetTitle("SmoothyPlates Options")
		optionsFrame:SetLayout("Flow")
		optionsFrame:SetStatusText("Version: " .. SP.currVersion)
		optionsFrame:SetWidth(290)
		optionsFrame:SetHeight(410)
		optionsFrame:EnableResize(false)

		local scrollFrame = aceGui:Create("ScrollFrame")
		scrollFrame:SetWidth(270)
		scrollFrame:SetHeight(330)

		for key, category in pairs(SP.dbo) do
			if category.canfigurable then
				local categoryGroup = aceGui:Create("InlineGroup")
				categoryGroup:SetTitle(category.displayName)

				for key, option in pairs(category.options) do
					local type = option.type
					local widget;

					if type == "BOOL" then
						widget = aceGui:Create("CheckBox")
						widget:SetLabel(option.displayName)
						widget:SetValue(option.value)
						widget:SetCallback("OnValueChanged", function(widget, event, value) option.value = value; end)
					elseif type == "BAR" then
						widget = aceGui:Create("LSM30_Statusbar")
						widget.list = sharedMedia:HashTable("statusbar")
						widget.SetLabel(widget, option.displayName)
						widget.SetValue(widget, option.value)
						widget:SetCallback("OnValueChanged", function(dropdown, event, value) dropdown.SetValue(dropdown, value); option.value = value; end)
					elseif type == "FONT" then
						widget = aceGui:Create("LSM30_Font")
						widget.list = sharedMedia:HashTable("font")
						widget.SetLabel(widget, option.displayName)
						widget.SetValue(widget, option.value)
						widget:SetCallback("OnValueChanged", function(dropdown, event, value) dropdown.SetValue(dropdown, value); option.value = value; end)
					else end
					
					if widget then
						categoryGroup:AddChild(widget)
					end
				end

				scrollFrame:AddChild(categoryGroup)
			end
		end

		optionsFrame:AddChild(scrollFrame)

		optionsFrame:SetCallback("OnClose", function() ReloadUI(); end)

	else
		self:print("Hmm, something went wrong while creating the options... :(")
	end
end

local lastLayout;
local anchorList = { TOP = "TOP", BOTTOM = "BOTTOM", CENTER = "CENTER", LEFT = "LEFT", RIGHT = "RIGHT", TOPLEFT = "TOPLEFT", TOPRIGHT = "TOPRIGHT", BOTTOMLEFT = "BOTTOMLEFT", BOTTOMRIGHT = "BOTTOMRIGHT" };
function SP:ShowLayoutGUI()
	lastLayout = ShallowCopy(SP.dbo.layout)

	local editorFrame = CreateFrame("Frame", "fakePlateEditor", UIParent)
	editorFrame:SetSize(456, 480)
	editorFrame:SetPoint("CENTER", 0, 0)
	editorFrame:SetBackdrop({
		bgFile = SP.EditorBackground,
		tile = false,
		edgeFile = SP.EDGE_TEX,
		edgeSize = 2
	})
	editorFrame:SetFrameLevel(0)
	editorFrame:SetFrameStrata("BACKGROUND")

	local Portrait = CreateFrame("PlayerModel", nil, editorFrame)
	Portrait:SetPoint("CENTER", 0, -40)
	Portrait:SetSize(70, 70)
	Portrait:SetUnit("player")

	local bottomContainer = CreateFrame("Frame", "$bottomContainer", editorFrame)
	bottomContainer:SetSize(440, 130)
	bottomContainer:SetPoint("BOTTOM", 0, 8)
	bottomContainer:SetBackdrop(SP.stdbd)
	bottomContainer:SetBackdropColor(0,0,0,0.7)
	bottomContainer:SetFrameStrata("BACKGROUND")

	local scrollFrame = aceGui:Create("ScrollFrame")
	scrollFrame:SetWidth(422)
	scrollFrame:SetHeight(130)
	scrollFrame:SetLayout("Flow")
	scrollFrame.frame:SetPoint("CENTER", bottomContainer, 8, 0)

	local elements = {};
	for k, v in pairs(SP.dbo.layout.options) do
		elements[k] = v.displayName;
	end

	local updateLayoutSetting;
	local elementsDD = aceGui:Create("Dropdown")
	elementsDD.frame:SetSize(170, 26)
	elementsDD:SetList(elements)
	elementsDD:SetLabel("Element")
	elementsDD:SetValue(nil)
	elementsDD:SetPoint("TOPLEFT", editorFrame, 10, -9)
	elementsDD:SetCallback("OnValueChanged", function(dropdown, event, value) dropdown.SetValue(dropdown, value); updateLayoutSetting(value); end)

	local save = aceGui:Create("Button")
	save:SetText("Save")
	save.frame:SetSize(80, 26)
	save:SetPoint("TOPRIGHT", editorFrame, -10, -24)
	save:SetCallback("OnClick", function() ReloadUI(); end)
	save.frame:Show()

	local reset = aceGui:Create("Button")
	reset:SetText("Reset")
	reset.frame:SetSize(80, 26)
	reset:SetPoint("TOPRIGHT", editorFrame, -92, -24)
	reset:SetCallback("OnClick", function() SP.dbo.layout = lastLayout; ReloadUI(); end)
	reset.frame:Show()

	local defaults = aceGui:Create("Button")
	defaults:SetText("Defaults")
	defaults.frame:SetSize(90, 26)
	defaults:SetPoint("TOPRIGHT", editorFrame, -174, -24)
	defaults:SetCallback("OnClick", function() SP.dbo.layout = SP:DefaultDBOptions().layout; ReloadUI(); end)
	defaults.frame:Show()

	local export = aceGui:Create("Button")
	export:SetText("Export")
	export.frame:SetSize(90, 26)
	export:SetPoint("TOPRIGHT", editorFrame, -10, -52)
	export:SetCallback("OnClick", function() 
		local Box = aceGui:Create("MultiLineEditBox");
		Box:SetNumLines(30)
		Box:SetWidth(800)
		Box:DisableButton(true)
		Box:SetLabel("Export")
		Box:SetPoint("CENTER", editorFrame, 0, 0)

		Box:SetText(SP:Serialize(SP.dbo));
		Box:HighlightText();
		Box:SetFocus();
		Box.frame:Show()

		local close = aceGui:Create("Button")
		close:SetText("Ok")
		close.frame:SetSize(60, 26)
		close:SetPoint("BOTTOMLEFT", Box.frame, 0, -26)
		close:SetCallback("OnClick", function() 
			Box.frame:Hide(); 
			Box = nil; 
			close.frame:Hide(); 
			close = nil; 
		end)
		close.frame:Show()
	end)
	export.frame:Show()

	local import = aceGui:Create("Button")
	import:SetText("Import")
	import.frame:SetSize(90, 26)
	import:SetPoint("TOPRIGHT", editorFrame, -100, -52)
	import:SetCallback("OnClick", function() 
		local Box = aceGui:Create("MultiLineEditBox");
		Box:SetNumLines(30)
		Box:SetWidth(800)
		Box:DisableButton(true)
		Box:SetLabel("Import")
		Box:SetPoint("CENTER", editorFrame, 0, 0)
		Box:SetText("");
		Box:HighlightText();
		Box:SetFocus();
		Box.frame:Show()

		local parse = aceGui:Create("Button")
		parse:SetText("Import")
		parse.frame:SetSize(60, 26)
		parse:SetPoint("BOTTOMLEFT", Box.frame, 0, -26)
		parse:SetCallback("OnClick", function() 
			Box.frame:Hide(); 
			parse.frame:Hide(); 
			parse = nil;

			local success, table = SP:Deserialize(Box:GetText());
			Box = nil;
			if success and table then
				SP.db.char.options = table
				SP.dbo = table
				SP:updateTestLayout(editorFrame)
			end
		end)
		parse.frame:Show()
	end)
	import.frame:Show()


	updateLayoutSetting = function(value)
		scrollFrame:ReleaseChildren();

		local layoutValues = SP.dbo.layout.options[value].value;
		local function setValue(k, v) 
			layoutValues[k] = v;
		end

		for k, v in pairs(layoutValues) do
			local widget;
			if type(v) == "string" then
				local onValueChanged;
				onValueChanged = function(dropdown, event, value)
					dropdown.SetValue(dropdown, value);
					setValue(k, value);
					SP:updateTestLayout(editorFrame);
				end

				widget = aceGui:Create("Dropdown")
				local lists = {
					parent = SmoothyPlate.elementsPlain,
					anchor = anchorList,
					["hide border"] = { t = "TOP", b = "BOTTOM", l = "LEFT", r = "RIGHT", n = "NONE" }
				}
				widget:SetList(lists[k])
				widget:SetCallback("OnValueChanged", onValueChanged)
			else
				widget = aceGui:Create("Slider")

				local sliderValues = {
					scale = { min = 1, max = 4, step = 0.1 },
					width = { min = 1, max = 200 },
					height = { min = 1, max = 200 },
					size = { min = 1, max = 100 },
					opacity = { min = 0, max = 1, step = 0.1 }
				}
				local sliderInfo = sliderValues[k];
				if not sliderInfo then sliderInfo = { min = -100, max = 100 } end

				widget:SetSliderValues(sliderInfo.min, sliderInfo.max, sliderInfo.step or 1)
				widget:SetCallback("OnValueChanged", function(slider, event, value)
					setValue(k, value);
					SP:updateTestLayout(editorFrame);
				end)
			end

			widget:SetLabel(k)
			widget:SetValue(v)
			scrollFrame:AddChild(widget)
		end
	end

	editorFrame.fakePlate = nil
	self:updateTestLayout(editorFrame)
end

function SP:updateTestLayout(editorFrame)

	if editorFrame.fakePlate then
		editorFrame.fakePlate.SmoothyPlate:RemoveUnit()
		editorFrame.fakePlate.SmoothyPlate = nil

		editorFrame.fakePlate:Hide()
		editorFrame.fakePlate:SetParent(nil)
		editorFrame.fakePlate:ClearAllPoints()
		editorFrame.fakePlate = nil
	end

	local fakePlate = CreateFrame("Frame", "$fakePlate", editorFrame)
	fakePlate:SetSize(154, 64)
	fakePlate:SetPoint("CENTER", 0, 40)
	fakePlate:SetFrameStrata("BACKGROUND")

	fakePlate:SetScale(SP.perfectScale * 1.9737)

	local sp = SmoothyPlate(fakePlate, true);
	self.callbacks:Fire("AFTER_SP_CREATION", fakePlate)

	sp:AddUnit("player")
	self.callbacks:Fire("AFTER_SP_UNIT_ADDED", fakePlate)

	editorFrame.fakePlate = fakePlate
end


-----------------Plate handling-----------------

local inArena = false
function SP:PLAYER_ENTERING_WORLD()
	PlateStorage = {}
	self.callbacks:Fire("SP_PLAYER_ENTERING_WORLD")

	if select(2, IsInInstance()) == "arena" then
		inArena = true
		self.callbacks:Fire("SP_ARENA_STATE_CHANGED", inArena)
	else
		if inArena then
			inArena = false
			self.callbacks:Fire("SP_ARENA_STATE_CHANGED", inArena)
		end
	end

end

local PlateStorage = {}

function BypassFunction() return true end

function SP:NAME_PLATE_CREATED(event, plate)
	local blizzFrame = plate:GetChildren();

	blizzFrame._Show = blizzFrame.Show
	blizzFrame.Show = BypassFunction

	SmoothyPlate(plate);
	self.callbacks:Fire("AFTER_SP_CREATION", plate)
end

function SP:NAME_PLATE_UNIT_ADDED(event, unitid)
	local plate = GetNamePlateForUnit(unitid);

	-- Personal Display
	if event and UnitIsUnit("player", unitid) then
		plate:GetChildren():_Show()
	-- Normal Plates
	else
		plate:GetChildren():Hide()
		if plate and plate.SmoothyPlate then
			plate.SmoothyPlate:AddUnit(unitid)
			PlateStorage[UnitGUID(plate.SmoothyPlate.unitid)] = plate
			self.callbacks:Fire("AFTER_SP_UNIT_ADDED", plate)
		end
	end
end

function SP:NAME_PLATE_UNIT_REMOVED(event, unitid)
	local plate = GetNamePlateForUnit(unitid);

	if unitid and plate and plate.SmoothyPlate and plate.SmoothyPlate.unitid then
		self.callbacks:Fire("BEFORE_SP_UNIT_REMOVED", plate)
		PlateStorage[UnitGUID(plate.SmoothyPlate.unitid)] = nil
		plate.SmoothyPlate:RemoveUnit()
	end
end

function SP:GetPlateByGUID(guid)
	return PlateStorage[guid]
end

function SP:forEachPlate(func)
	if not func then return end

	for guid, plate in pairs(PlateStorage) do
		if plate then
			func(plate, guid)
		end
	end
end

----------------Plate Event handling-----------------

function EventHandler:UNIT_HEALTH(event, unitid)
	if not unitid then return end
	local plate = GetNamePlateForUnit(unitid)
	if not plate or event and UnitIsUnit("player", unitid) then return end

	plate.SmoothyPlate:UpdateHealth();

end

function EventHandler:UNIT_MAXHEALTH(event, unitid)
	self:UNIT_HEALTH(event, unitid)

end

function EventHandler:UNIT_HEALTH_FREQUENT(event, unitid)
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

	SP:forEachPlate(function(plate)
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

function UNIT_SPELLCAST_CHANNEL_UPDATE(event, unitid)
	if not unitid then return end
	local plate = GetNamePlateForUnit(unitid)
	if not plate or UnitIsUnit("player", unitid) then return end

	plate.SmoothyPlate:UpdateCastBarMidway()
end

function EventHandler:UNIT_SPELLCAST_DELAYED(event, unitid)
	UNIT_SPELLCAST_CHANNEL_UPDATE(event, unitid)
end

function EventHandler:UNIT_SPELLCAST_INTERRUPTIBLE(event, unitid)
	UNIT_SPELLCAST_CHANNEL_UPDATE(event, unitid)
end

function EventHandler:UNIT_SPELLCAST_NOT_INTERRUPTIBLE(event, unitid)
	UNIT_SPELLCAST_CHANNEL_UPDATE(event, unitid)
end

-----------------------------------------------------

function SP:HandleChatCommand(cmd) -- defines what to do when a chat command is typed

	if cmd == "config" then
		self:CreateOptionFrame()
	elseif cmd == "defaults" then
		self.db.char.options = nil;
	elseif cmd == "layout" then
		self:ShowLayoutGUI();
	elseif cmd == "exportluatable" then
		local Box = aceGui:Create("MultiLineEditBox");
		Box:SetNumLines(30)
		Box:SetWidth(800)
		Box:DisableButton(true)
		Box:SetLabel("Export Table")
		Box:SetPoint("CENTER", UIParent, 0, 0)

		Box:SetText(TableToString(SP.dbo));
		Box:HighlightText();
		Box:SetFocus();
		Box.frame:Show()

		local close = aceGui:Create("Button")
		close:SetText("Close")
		close.frame:SetSize(70, 26)
		close:SetPoint("BOTTOMLEFT", Box.frame, 0, -26)
		close:SetCallback("OnClick", function() 
			Box.frame:Hide(); 
			Box = nil; 
			close.frame:Hide(); 
			close = nil; 
		end)
		close.frame:Show()
	else
		self:print("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -")
		self:print("Possible SmoothyPlates Commands:")
		self:print("   - /smp         | Show all commands")
		self:print("   - /smp config  | Show options")
		self:print("   - /smp layout  | Show Layout configurator")
		self:print("   - /smp defaults | Clears all configuration for this character and uses the default configuration.")
		self:print("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -")
	end

end

function SP:SaveDB() -- saves all infos gathered to the DB

	--

end

-----------------MISC-------------------

function SP:UnitDebuffByName(unitid, spellName) 
	for i=1,40 do 
		local d = UnitDebuff(unitid, i);
		if d == spellName then 
			return UnitDebuff(unitid, i);
		end
	end
end

---------------Convenience Methods-----------------

function SP:getBackdropWithEdge(path, tileN, tileSizeN, edgeSizeN, insetSize) -- gets an bockdrop object with the image from the path as the background
	insetSize = insetSize or 0

	return {
		edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
		bgFile = path,
		tile = tileN,
		tileSize = tileSizeN,
		edgeSize = edgeSizeN,
		insets = {
			left = insetSize,
			right = insetSize,
			top = insetSize,
			bottom = insetSize
		},
	}

end

function SP:getBackdrop(path, tileN, tileSizeN) -- gets an bockdrop object with the image from the path as the background
	return {
		bgFile = path,
		tile = tileN,
		tileSize = tileSizeN
	}

end

function SP:print(msg) -- the print funktion with the Red VFrame before every chat msg

	print("|cffff0020SmoothyPlates|r: " .. msg)

end

---------------Functional Methods-----------------

function SP:percent(is, from)

	return SP:round((is / from) * 100)

end

function SP:round(n) -- rounds a value

    return n % 1 >= 0.5 and math.ceil(n) or math.floor(n)

end

function SP:contains(tbl, value) -- returns true if the value is existent in the given tbl

	for i,n in pairs(tbl) do
		if n == value then return true end
	end

	return false

end

function SP:split(inputstr, sep, tbl) -- splits a string
		local i = 1;
        local t={};
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                t[i] = str
                i = i + 1
        end

        if tbl then return t else return t[1] end

end

function SP:fromRGB(r, g, b, a)

	return (r/255), (g/255), (b/255), (a/255)

end

function SP:getIndex(tbl, value) -- returns the index where the value is in the table

	for i,n in pairs(tbl) do
		if n == value then return i end
	end

end

function ShallowCopy(obj)
	if type(obj) ~= 'table' then return obj end
	local res = {}
	for k, v in pairs(obj) do res[ShallowCopy(k)] = ShallowCopy(v) end
	return res
end

function TableMerge(t1, t2)
    for k,v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[k] or false) == "table" then
                TableMerge(t1[k] or {}, t2[k] or {})
            else
                t1[k] = v
            end
        else
            t1[k] = v
        end
    end
    return t1
end

function StringToTable(tableString)
	local tableStringFunction = loadstring(format("%s %s", "return", tableString))
	local message, table
	if tableStringFunction then
		message, table = pcall(tableStringFunction)
	end
	if table then
		return table;
	else
		SP:print("Error importing:" .. message)
	end
end

function TableToString(inTable)
	if type(inTable) ~= "table" then
		return ""
	end

	local ret = "{\n";
	local function recurse(table, level)
		for i,v in pairs(table) do
			ret = ret..strrep("    ", level).."[";
			if(type(i) == "string") then
				ret = ret.."\""..i.."\"";
			else
				ret = ret..i;
			end
			ret = ret.."] = ";

			if(type(v) == "number") then
				ret = ret..v..",\n"
			elseif(type(v) == "string") then
				ret = ret.."\""..v:gsub("\\", "\\\\"):gsub("\n", "\\n"):gsub("\"", "\\\""):gsub("\124", "\124\124").."\",\n"
			elseif(type(v) == "boolean") then
				if(v) then
					ret = ret.."true,\n"
				else
					ret = ret.."false,\n"
				end
			elseif(type(v) == "table") then
				ret = ret.."{\n"
				recurse(v, level + 1);
				ret = ret..strrep("    ", level).."},\n"
			else
				ret = ret.."\""..tostring(v).."\",\n"
			end
		end
	end

	if(inTable) then
		recurse(inTable, 1);
	end
	ret = ret.."}";

	return ret;
end

----------------------------------------------
