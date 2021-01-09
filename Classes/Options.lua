local SP = SmoothyPlates
local Utils = SP.Utils

SP.hookOnInit(
	function()
		handleSharedMedia()
		SP.Ace.Console:RegisterChatCommand('smp', handleChatCommand)
		-- SP.Ace.Timer.ScheduleTimer({}, function() showLayoutGUI() end, 2)
	end
)

function handleChatCommand(cmd)
	if cmd == 'config' then
		createOptionFrame()
	elseif cmd == 'defaults' then
		SP.setCharOptions(nil)
		ReloadUI()
	elseif cmd == 'layout' then
		showLayoutGUI()
	elseif cmd == 'exportluatable' then
		local Box = SP.Ace.GUI:Create('MultiLineEditBox')
		Box:SetNumLines(30)
		Box:SetWidth(800)
		Box:DisableButton(true)
		Box:SetLabel('Export Table')
		Box:SetPoint('CENTER', UIParent, 0, 0)

		Box:SetText(Utils.tableToString(SP.db))
		Box:HighlightText()
		Box:SetFocus()
		Box.frame:Show()

		local close = SP.Ace.GUI:Create('Button')
		close:SetText('Close')
		close.frame:SetSize(70, 26)
		close:SetPoint('BOTTOMLEFT', Box.frame, 0, -26)
		close:SetCallback(
			'OnClick',
			function()
				Box.frame:Hide()
				Box = nil
				close.frame:Hide()
				close = nil
			end
		)
		close.frame:Show()
	else
		Utils.print('- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -')
		Utils.print('Possible SmoothyPlates Commands:')
		Utils.print('   - /smp         | Show all commands')
		Utils.print('   - /smp config  | Show options')
		Utils.print('   - /smp layout  | Show Layout configurator')
		Utils.print('   - /smp defaults | Clears all configuration for this character and uses the default configuration.')
		Utils.print('- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -')
	end
end

local sharedMedia
function handleSharedMedia()
	sharedMedia = LibStub:GetLibrary('LibSharedMedia-3.0', true)
	LibStub:GetLibrary('AceGUISharedMediaWidgets-1.0')

	sharedMedia:Register(
		'font',
		'Designosaur Regular',
		'Interface\\Addons\\SmoothyPlates\\Media\\Font\\Designosaur-Regular.ttf'
	)
	sharedMedia:Register('font', 'ElvUI Mentium', 'Interface\\Addons\\SmoothyPlates\\Media\\Font\\ElvUI-Mentium.ttf')
	sharedMedia:Register('font', 'Purista Medium', SP.Vars.ui.FONT)
	sharedMedia:Register('statusbar', 'Blizzard Nameplate Bar', 'Interface\\TargetingFrame\\UI-TargetingFrame-BarFill')
	sharedMedia:Register('statusbar', 'Glaze', SP.Vars.ui.textures.BAR_TEX)
	sharedMedia:Register('statusbar', 'Gloss', SP.Vars.ui.textures.PRED_BAR_TEX)
	sharedMedia:Register('statusbar', 'Flat', 'Interface\\Addons\\SmoothyPlates\\Media\\TGA\\Flat')
	sharedMedia:Register('statusbar', 'Minimalist', 'Interface\\Addons\\SmoothyPlates\\Media\\TGA\\Minimalist')
	sharedMedia:Register('statusbar', 'Minimal', 'Interface\\Addons\\SmoothyPlates\\Media\\TGA\\Minimal')

	if SP.db then
		SP.Vars.ui.font = sharedMedia:Fetch('font', SP.db.media.FONT)
		SP.Vars.ui.textures.BAR_TEX = sharedMedia:Fetch('statusbar', SP.db.media.BAR)
		SP.Vars.ui.textures.PRED_BAR_TEX = sharedMedia:Fetch('statusbar', SP.db.media.PRED_BAR)
	end
end

function createOptionFrame()
	local optionsFrame = SP.Ace.GUI:Create('Frame')
	optionsFrame:SetTitle('SmoothyPlates Options')
	optionsFrame:SetLayout('Flow')
	optionsFrame:SetStatusText('Version: ' .. SP.Vars.currVersion)
	optionsFrame:SetWidth(290)
	optionsFrame:SetHeight(410)
	optionsFrame:EnableResize(false)

	local scrollFrame = SP.Ace.GUI:Create('ScrollFrame')
	scrollFrame:SetWidth(270)
	scrollFrame:SetHeight(330)
	scrollFrame:SetLayout('Flow')

	local defaultConfig = SP.getOptionsStructure()
	for _, category in ipairs(defaultConfig) do
		local key = category.key
		local categoryGroup = SP.Ace.GUI:Create('InlineGroup')
		categoryGroup:SetTitle(category.displayName)

		local dbOptions = SP.db[key]
		for optionKey, option in pairs(category.options) do
			local type = option.type
			local inlineGroup = SP.Ace.GUI:Create('SimpleGroup')
			inlineGroup:SetLayout('Flow')
			local widget

			local optionValue = dbOptions[optionKey]
			if category.valuePath then
				optionValue = optionValue[category.valuePath]
			end
			local setValue = function(newValue)
				if category.valuePath then
					dbOptions[optionKey][category.valuePath] = newValue
				else
					dbOptions[optionKey] = newValue
				end
			end

			if type == 'BOOL' then
				widget = SP.Ace.GUI:Create('CheckBox')
				widget:SetLabel(option.displayName)
				widget:SetValue(optionValue)
				widget:SetCallback(
					'OnValueChanged',
					function(_, _, value)
						setValue(value)
					end
				)
			elseif type == 'BAR' then
				widget = SP.Ace.GUI:Create('LSM30_Statusbar')
				widget.list = sharedMedia:HashTable('statusbar')
				widget.SetLabel(widget, option.displayName)
				widget.SetValue(widget, optionValue)
				widget:SetCallback(
					'OnValueChanged',
					function(dropdown, _, value)
						dropdown.SetValue(dropdown, value)
						setValue(value)
					end
				)
			elseif type == 'FONT' then
				widget = SP.Ace.GUI:Create('LSM30_Font')
				widget.list = sharedMedia:HashTable('font')
				widget.SetLabel(widget, option.displayName)
				widget.SetValue(widget, optionValue)
				widget:SetCallback(
					'OnValueChanged',
					function(dropdown, _, value)
						dropdown.SetValue(dropdown, value)
						setValue(value)
					end
				)
			end

			if widget then
				widget:SetWidth(200)
				inlineGroup:AddChild(widget)
			end

			if option.customOptions then
				local customOptions = SP.Ace.GUI:Create('Icon')
				customOptions:SetImageSize(14, 14)
				customOptions:SetWidth(14)
				local configIcon = 'Interface\\Buttons\\UI-OptionsButton'
				-- local checkIcon = "Interface\\Buttons\\UI-CheckBox-Check"
				customOptions:SetImage(configIcon)

				customOptions:SetCallback(
					'OnClick',
					function()
						SP.Addon:GetModule(optionKey).customOptions()
						optionsFrame.frame:SetAlpha(0)
					end
				)

				inlineGroup:AddChild(customOptions)
			end

			categoryGroup:AddChild(inlineGroup)
		end

		scrollFrame:AddChild(categoryGroup)
	end

	optionsFrame:AddChild(scrollFrame)

	optionsFrame:SetCallback(
		'OnClose',
		function()
			ReloadUI()
		end
	)
end

local lastLayout
local anchorList = {
	TOP = 'TOP',
	BOTTOM = 'BOTTOM',
	CENTER = 'CENTER',
	LEFT = 'LEFT',
	RIGHT = 'RIGHT',
	TOPLEFT = 'TOPLEFT',
	TOPRIGHT = 'TOPRIGHT',
	BOTTOMLEFT = 'BOTTOMLEFT',
	BOTTOMRIGHT = 'BOTTOMRIGHT'
}

function showLayoutGUI()
	lastLayout = Utils.shallowCopy(SP.db.layout)

	local editorFrame = Utils.createSimpleFrame('fakePlateEditor', UIParent, true)
	editorFrame:SetSize(456, 480)
	editorFrame:SetPoint('CENTER', 0, 0)
	editorFrame:SetBackdrop(
		{
			bgFile = SP.Vars.ui.textures.EditorBackground,
			tile = false,
			edgeFile = SP.Vars.ui.textures.EDGE_TEX,
			edgeSize = 2
		}
	)
	editorFrame:SetFrameLevel(0)
	editorFrame:SetFrameStrata('BACKGROUND')

	local Portrait = CreateFrame('PlayerModel', nil, editorFrame)
	Portrait:SetPoint('CENTER', 0, -40)
	Portrait:SetSize(70, 70)
	Portrait:SetUnit('player')

	local bottomContainer = Utils.createSimpleFrame('$bottomContainer', editorFrame, true)
	bottomContainer:SetSize(440, 130)
	bottomContainer:SetPoint('BOTTOM', 0, 8)
	bottomContainer:SetBackdrop(SP.Vars.ui.backdrops.stdbd)
	bottomContainer:SetBackdropColor(0, 0, 0, 0.7)
	bottomContainer:SetFrameStrata('BACKGROUND')

	local scrollFrame = SP.Ace.GUI:Create('ScrollFrame')
	scrollFrame:SetWidth(422)
	scrollFrame:SetHeight(130)
	scrollFrame:SetLayout('Flow')
	scrollFrame.frame:SetPoint('CENTER', bottomContainer, 8, 0)

	local elements = {}
	for k, v in pairs(SP.SmoothyPlate.registeredFrameNames) do
		elements[v] = k
	end

	local updateLayoutSetting
	local elementsDD = SP.Ace.GUI:Create('Dropdown')
	elementsDD.frame:SetSize(170, 26)
	elementsDD:SetList(elements)
	elementsDD:SetLabel('Element')
	elementsDD:SetValue(nil)
	elementsDD:SetPoint('TOPLEFT', editorFrame, 10, -9)
	elementsDD:SetCallback(
		'OnValueChanged',
		function(dropdown, _, value)
			dropdown.SetValue(dropdown, value)
			updateLayoutSetting(value)
		end
	)

	local save = SP.Ace.GUI:Create('Button')
	save:SetText('Save')
	save.frame:SetSize(80, 26)
	save:SetPoint('TOPRIGHT', editorFrame, -10, -24)
	save:SetCallback(
		'OnClick',
		function()
			ReloadUI()
		end
	)
	save.frame:Show()

	local reset = SP.Ace.GUI:Create('Button')
	reset:SetText('x')
	reset.frame:SetSize(38, 22)
	reset:SetPoint('TOPRIGHT', editorFrame, -2, -2)
	reset:SetCallback(
		'OnClick',
		function()
			SP.db.layout = lastLayout
			ReloadUI()
		end
	)
	reset.frame:Show()

	local defaults = SP.Ace.GUI:Create('Button')
	defaults:SetText('Defaults')
	defaults.frame:SetSize(90, 26)
	defaults:SetPoint('TOPRIGHT', editorFrame, -90, -24)
	defaults:SetCallback(
		'OnClick',
		function()
			SP.db.layout = SP.getDefaultConfig().layout
			ReloadUI()
		end
	)
	defaults.frame:Show()

	local export = SP.Ace.GUI:Create('Button')
	export:SetText('Export')
	export.frame:SetSize(90, 26)
	export:SetPoint('TOPRIGHT', editorFrame, -10, -52)
	export:SetCallback(
		'OnClick',
		function()
			local Box = SP.Ace.GUI:Create('MultiLineEditBox')
			Box:SetNumLines(30)
			Box:SetWidth(800)
			Box:DisableButton(true)
			Box:SetLabel('Export')
			Box:SetPoint('CENTER', editorFrame, 0, 0)

			Box:SetText(SP.Ace.Serializer:Serialize(SP.db))
			Box:HighlightText()
			Box:SetFocus()
			Box.frame:Show()

			local close = SP.Ace.GUI:Create('Button')
			close:SetText('Ok')
			close.frame:SetSize(60, 26)
			close:SetPoint('BOTTOMLEFT', Box.frame, 0, -26)
			close:SetCallback(
				'OnClick',
				function()
					Box.frame:Hide()
					Box = nil
					close.frame:Hide()
					close = nil
				end
			)
			close.frame:Show()
		end
	)
	export.frame:Show()

	local import = SP.Ace.GUI:Create('Button')
	import:SetText('Import')
	import.frame:SetSize(90, 26)
	import:SetPoint('TOPRIGHT', editorFrame, -100, -52)
	import:SetCallback(
		'OnClick',
		function()
			local Box = SP.Ace.GUI:Create('MultiLineEditBox')
			Box:SetNumLines(30)
			Box:SetWidth(800)
			Box:DisableButton(true)
			Box:SetLabel('Import')
			Box:SetPoint('CENTER', editorFrame, 0, 0)
			Box:SetText('')
			Box:HighlightText()
			Box:SetFocus()
			Box.frame:Show()

			local parse = SP.Ace.GUI:Create('Button')
			parse:SetText('Import')
			parse.frame:SetSize(60, 26)
			parse:SetPoint('BOTTOMLEFT', Box.frame, 0, -26)
			parse:SetCallback(
				'OnClick',
				function()
					Box.frame:Hide()
					parse.frame:Hide()
					parse = nil

					local success, table = SP.Ace.Serializer:Deserialize(Box:GetText())
					Box = nil
					if success and table then
						SP.setCharOptions(table)
						updateTestLayout(editorFrame)
					end
				end
			)
			parse.frame:Show()
		end
	)
	import.frame:Show()

	updateLayoutSetting = function(frameName)
		scrollFrame:ReleaseChildren()

		local layoutValues = SP.db.layout[frameName]
		local function setValue(k, v)
			layoutValues[k] = v
		end

		for k, v in pairs(layoutValues) do
			local widget
			if type(v) == 'string' then
				local onValueChanged
				onValueChanged = function(dropdown, _, newValue)
					dropdown.SetValue(dropdown, newValue)
					setValue(k, newValue)
					updateTestLayout(editorFrame)
				end

				widget = SP.Ace.GUI:Create('Dropdown')
				local lists = {
					parent = SP.SmoothyPlate.elementsPlain,
					anchor = anchorList,
					direction = {TOP = 'TOP', BOTTOM = 'BOTTOM', LEFT = 'LEFT', RIGHT = 'RIGHT'},
					['hide border'] = {t = 'TOP', b = 'BOTTOM', l = 'LEFT', r = 'RIGHT', n = 'NONE'}
				}
				widget:SetList(lists[k])
				widget:SetCallback('OnValueChanged', onValueChanged)
			elseif type(v) == 'boolean' then
				widget = SP.Ace.GUI:Create('CheckBox')
				widget:SetCallback(
					'OnValueChanged',
					function(_, _, newValue)
						setValue(k, newValue)
						updateTestLayout(editorFrame)
					end
				)
			else
				widget = SP.Ace.GUI:Create('Slider')

				local sliderValues = {
					scale = {min = 1, max = 4, step = 0.1},
					width = {min = 1, max = 200},
					height = {min = 1, max = 200},
					size = {min = 1, max = 100},
					level = {min = 1, max = 20},
					opacity = {min = 0, max = 1, step = 0.1}
				}
				local sliderInfo = sliderValues[k]
				if not sliderInfo then
					sliderInfo = {min = -100, max = 100}
				end

				widget:SetSliderValues(sliderInfo.min, sliderInfo.max, sliderInfo.step or 1)
				widget:SetCallback(
					'OnValueChanged',
					function(_, _, newValue)
						setValue(k, newValue)
						updateTestLayout(editorFrame)
					end
				)
			end

			widget:SetLabel(k)
			widget:SetValue(v)
			scrollFrame:AddChild(widget)
		end
	end

	editorFrame.fakePlate = nil
	updateTestLayout(editorFrame)
end

function updateTestLayout(editorFrame)
	if editorFrame.fakePlate then
		editorFrame.fakePlate.SmoothyPlate:RemoveUnit()
		editorFrame.fakePlate.SmoothyPlate = nil

		editorFrame.fakePlate:Hide()
		editorFrame.fakePlate:SetParent(nil)
		editorFrame.fakePlate:ClearAllPoints()
		editorFrame.fakePlate = nil
	end

	local fakePlate = CreateFrame('Frame', '$fakePlate', editorFrame)
	fakePlate:SetSize(154, 64)
	fakePlate:SetPoint('CENTER', 0, 40)
	fakePlate:SetFrameStrata('BACKGROUND')

	fakePlate:SetScale(SP.Vars.perfectScale * 1.9737)

	local sp = SP.SmoothyPlate(fakePlate, true)
	SP.callbacks:Fire('AFTER_SP_CREATION', fakePlate)

	sp:AddUnit('player')
	SP.callbacks:Fire('AFTER_SP_UNIT_ADDED', fakePlate)

	editorFrame.fakePlate = fakePlate
end
