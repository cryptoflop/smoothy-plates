SmoothyPlates.getDefaultConfig = function()
	return {
		['version'] = SmoothyPlates.Vars.currVersion,
		['options'] = {
			['hideUnimportantPets'] = true,
			['hideUnimportantTotems'] = true,
			['absorbs'] = true
		},
		['modules'] = {
			['Trinket'] = {
				['active'] = true
			},
			['Interrupts'] = {
				['active'] = true
			},
			['Healers'] = {
				['active'] = true
			},
			['Auras'] = {
				['active'] = true,
				['customOptions'] = {
					['spellSets'] = {
						HARMFUL = {
							key = 'HARMFUL',
							name = 'Harmful',
							isAuraType = true
						},
						HELPFUL = {
							key = 'HELPFUL',
							name = 'Helpful',
							isAuraType = true
						},
						PLAYER = {
							key = 'PLAYER',
							name = 'Cast By Player',
							isAuraType = true
						},
						INCLUDE_NAME_PLATE_ONLY = {
							key = 'INCLUDE_NAME_PLATE_ONLY',
							name = 'Blizzard Nameplate Auras',
							isAuraType = true
						},
						STEAL_OR_PURGE = {
							key = 'STEAL_OR_PURGE',
							name = 'Can steal or purge',
							isAuraType = true
						}
					},
					['auraSets'] = {
						STUNS = {
							key = 'STUNS',
							name = 'Stuns',
							active = true,
							default = true,
							whitelists = {STUNS = true},
							blacklists = {}
						},
						SILENCES = {
							key = 'SILENCES',
							name = 'Silences',
							active = true,
							default = true,
							showDuration = true,
							whitelists = {SILENCES = true},
							blacklists = {}
						},
						PVPAURAS = {
							key = 'PVPAURAS',
							name = 'PvP Auras (GaldiatorlosSA2)',
							active = true,
							default = true,
							whitelists = {PVPSPELLS = true},
							blacklists = {SILENCES = true, STUNS = true}
						},
						CASTBYPLAYER = {
							key = 'CASTBYPLAYER',
							name = 'Applied by Player',
							active = true,
							default = true,
							whitelists = {PLAYER = true},
							blacklists = {SILENCES = true, STUNS = true}
						}
					}
				}
			}
		},
		['media'] = {
			['FONT'] = 'Designosaur Regular',
			['BAR'] = 'Glaze',
			['PRED_BAR'] = 'Glaze'
		},
		['layout'] = {
			['GENERAL'] = {
				['scale'] = 1.1
			},
			['CAST_TEXT'] = {
				['y'] = -1,
				['x'] = 2,
				['anchor'] = 'LEFT',
				['opacity'] = 1,
				['size'] = 10
			},
			['HEALTH'] = {
				['y'] = 0,
				['x'] = 0,
				['anchor'] = 'CENTER',
				['opacity'] = 1,
				['height'] = 32,
				['width'] = 120
			},
			['HEALTH_TEXT'] = {
				['y'] = -1,
				['x'] = 0,
				['anchor'] = 'CENTER',
				['opacity'] = 1,
				['size'] = 12
			},
			['TARGET'] = {
				['y'] = -2,
				['x'] = 0,
				['anchor'] = 'BOTTOM',
				['opacity'] = 0.8,
				['height'] = 20,
				['width'] = 120,
				['parent'] = 'Name'
			},
			['CAST'] = {
				['y'] = -26,
				['x'] = 0,
				['anchor'] = 'BOTTOM',
				['height'] = 24,
				['opacity'] = 1,
				['parent'] = 'PowerBar',
				['width'] = 120
			},
			['CAST_ICON'] = {
				['y'] = 0,
				['x'] = -26,
				['height'] = 24,
				['opacity'] = 1,
				['anchor'] = 'LEFT',
				['width'] = 24
			},
			['HEALER_ICON'] = {
				['y'] = 0,
				['x'] = 0,
				['anchor'] = 'TOPLEFT',
				['height'] = 18,
				['opacity'] = 1,
				['parent'] = 'HealthBar',
				['width'] = 18
			},
			['NAME'] = {
				['y'] = 14,
				['x'] = 0,
				['anchor'] = 'TOP',
				['opacity'] = 1,
				['parent'] = 'HealthBar',
				['size'] = 12
			},
			['RAID_ICON'] = {
				['y'] = 100,
				['x'] = 0,
				['anchor'] = 'TOP',
				['height'] = 42,
				['opacity'] = 1,
				['parent'] = 'Name',
				['width'] = 42,
				['level'] = 2
			},
			['POWER'] = {
				['y'] = -3,
				['x'] = 0,
				['hide border'] = 'n',
				['parent'] = 'HealthBar',
				['height'] = 4,
				['opacity'] = 1,
				['anchor'] = 'BOTTOM',
				['width'] = 120
			},
			['TRINKET'] = {
				['y'] = 0,
				['x'] = 0,
				['anchor'] = 'TOPRIGHT',
				['height'] = 18,
				['opacity'] = 1,
				['parent'] = 'HealthBar',
				['width'] = 18,
				['level'] = 1
			},
			['INTERRUPT'] = {
				['y'] = 0,
				['x'] = 34,
				['anchor'] = 'RIGHT',
				['size'] = 35,
				['opacity'] = 1,
				['parent'] = 'HealthBar',
				['level'] = 4,
				['red border'] = false,
				['glow'] = false
			},
			['AURAS_PVPAURAS'] = {
				['y'] = 68,
				['x'] = 0,
				['anchor'] = 'TOPLEFT',
				['size'] = 26,
				['opacity'] = 1,
				['parent'] = 'HealthBar',
				['direction'] = 'RIGHT',
				['duration'] = false,
				['glow'] = false,
				['count'] = false,
				['level'] = 1
			},
			['AURAS_CASTBYPLAYER'] = {
				['y'] = 42,
				['x'] = 0,
				['anchor'] = 'TOPLEFT',
				['size'] = 26,
				['opacity'] = 1,
				['parent'] = 'HealthBar',
				['direction'] = 'RIGHT',
				['duration'] = false,
				['glow'] = false,
				['count'] = false,
				['level'] = 1
			},
			['AURAS_SILENCES'] = {
				['y'] = 0,
				['x'] = 34,
				['anchor'] = 'RIGHT',
				['size'] = 35,
				['opacity'] = 1,
				['parent'] = 'HealthBar',
				['direction'] = 'RIGHT',
				['duration'] = true,
				['glow'] = false,
				['count'] = false,
				['level'] = 1
			},
			['AURAS_STUNS'] = {
				['y'] = 0,
				['x'] = -34,
				['anchor'] = 'LEFT',
				['size'] = 35,
				['opacity'] = 1,
				['parent'] = 'HealthBar',
				['direction'] = 'LEFT',
				['duration'] = true,
				['glow'] = false,
				['count'] = false,
				['level'] = 1
			}
		}
	}
end

SmoothyPlates.getOptionsStructure = function()
	return {
		{
			['key'] = 'options',
			['displayName'] = 'Options',
			['options'] = {
				['hideUnimportantPets'] = {
					['type'] = 'BOOL',
					['displayName'] = 'Hide unimportant creatures'
				},
				['hideUnimportantTotems'] = {
					['type'] = 'BOOL',
					['displayName'] = 'Hide unimportant totems'
				},
				['absorbs'] = {
					['type'] = 'BOOL',
					['displayName'] = 'Show absorbs'
				}
			}
		},
		{
			['key'] = 'modules',
			['displayName'] = 'Modules',
			['valuePath'] = 'active',
			['options'] = {
				['Trinket'] = {
					['type'] = 'BOOL',
					['displayName'] = 'Arena Trinket'
				},
				['Interrupts'] = {
					['type'] = 'BOOL',
					['displayName'] = 'Interrupts'
				},
				['Healers'] = {
					['type'] = 'BOOL',
					['displayName'] = 'Healers'
				},
				['Auras'] = {
					['type'] = 'BOOL',
					['displayName'] = 'Auras',
					['customOptions'] = true
				}
			}
		},
		{
			['key'] = 'media',
			['displayName'] = 'Media',
			['options'] = {
				['FONT'] = {
					['value'] = 'Designosaur Regular',
					['type'] = 'FONT',
					['displayName'] = 'Font'
				},
				['BAR'] = {
					['value'] = 'Glaze',
					['type'] = 'BAR',
					['displayName'] = 'Bar'
				},
				['PRED_BAR'] = {
					['value'] = 'Glaze',
					['type'] = 'BAR',
					['displayName'] = 'Prediction Bar'
				}
			}
		}
	}
end
