local textures = {
	TOOLTIP_BORDER = [[Interface\Tooltips\UI-Tooltip-Border]],
	TOOLTIP_BG = [[Interface\Tooltips\UI-Tooltip-Background]],
	--"Interface\\TargetingFrame\\UI-TargetingFrame-BarFill"
	--"Interface\RaidFrame\Absorb-Edge"
	EditorBackground = 'Interface\\Addons\\SmoothyPlates\\Media\\TGA\\EditorBackground',
	EDGE_TEX = 'Interface\\Addons\\SmoothyPlates\\Media\\TGA\\UI-Tooltip-Border',
	BAR_TEX = 'Interface\\Addons\\SmoothyPlates\\Media\\TGA\\Glaze',
	PRED_BAR_TEX = 'Interface\\Addons\\SmoothyPlates\\Media\\TGA\\Gloss',
	HEALER_ICON = 'Interface\\Addons\\SmoothyPlates\\Media\\TGA\\healer',
	TARGET = 'Interface\\Addons\\SmoothyPlates\\Media\\TGA\\targetglowup'
}

local callbacks = {}
local callbacksInstance = LibStub('CallbackHandler-1.0'):New(callbacks)
callbacks.Fire = function(_, event, ...)
	callbacksInstance:Fire(event, ...)
end

local Ace = {
	GUI = 3.0,
	Timer = 3.0,
	Event = 3.0,
	Console = 3.0,
	Serializer = 3.0
}
for k, v in pairs(Ace) do
	Ace[k] = LibStub:GetLibrary('Ace' .. k .. '-' .. string.format('%.1f', v))
end

_G.SmoothyPlates = {
	Vars = {
		currVersion = '6.0.1',
		ui = {
			textures = textures,
			colors = {
				green = {0.132, 0.852, 0.123},
				red = {0.852, 0.123, 0.123}
			},
			font = 'Interface\\Addons\\\\Media\\Font\\Purista-Medium.ttf',
			backdrops = {
				stdbd = {
					bgFile = textures.TOOLTIP_BG,
					edgeFile = textures.TOOLTIP_BORDER,
					edgeSize = 16,
					insets = { left = 4, right = 4, top = 4, bottom = 4 }
				},
				stdbdne = {
					bgFile = textures.TOOLTIP_BG,
					tile = true,
					tileSize = 16,
					edgeSize = 0
				},
				stdbde = {
					edgeFile = textures.EDGE_TEX,
					edgeSize = 16
				}
			}
		}
	},
	initFunctions = {},
	hookOnInit = (function(func)
		table.insert(SmoothyPlates.initFunctions, func)
	end),
	cleanFunctions = {},
	hookOnClean = (function(func)
		table.insert(SmoothyPlates.cleanFunctions, func)
	end),
	smoothy = LibStub('LibSmoothStatusBar-1.0'),
	callbacks = callbacks,
	Ace = Ace
}
