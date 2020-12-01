SmoothyPlates.getDefaultConfig = function()
    return {
        ["version"] = SmoothyPlates.Vars.currVersion,

        ["modules"] = {
            ["displayName"] = "Modules",
            ["options"] = {
                ["Stuns"] = {
                    ["value"] = true,
                    ["type"] = "BOOL",
                    ["displayName"] = "Stuns",
                },
                ["Trinket"] = {
                    ["value"] = false,
                    ["type"] = "BOOL",
                    ["displayName"] = "Arena Trinket",
                },
                ["Silences"] = {
                    ["value"] = true,
                    ["type"] = "BOOL",
                    ["displayName"] = "Silences",
                },
                ["Healers"] = {
                    ["value"] = false,
                    ["type"] = "BOOL",
                    ["displayName"] = "Healers",
                },
            },
            ["configurable"] = true,
        },

        ["media"] = {
            ["displayName"] = "Media",
            ["options"] = {
                ["FONT"] = {
                    ["value"] = "Designosaur Regular",
                    ["type"] = "FONT",
                    ["displayName"] = "Font",
                },
                ["BAR"] = {
                    ["value"] = "Glaze",
                    ["type"] = "BAR",
                    ["displayName"] = "Bar",
                },
                ["PRED_BAR"] = {
                    ["value"] = "Glaze",
                    ["type"] = "BAR",
                    ["displayName"] = "Prediction Bar",
                },
            },
            ["configurable"] = true,
        },

        ["layout"] = {
            ["displayName"] = "Layout",
            ["options"] = {
                ["LAYOUT_CAST_TEXT"] = {
                    ["value"] = {
                        ["y"] = -1,
                        ["x"] = 2,
                        ["anchor"] = "LEFT",
                        ["opacity"] = 1,
                        ["size"] = 10,
                    },
                    ["displayName"] = "Cast Text",
                },
                ["LAYOUT_GENERAL"] = {
                    ["value"] = {
                        ["scale"] = 1.1,
                    },
                    ["displayName"] = "General",
                },
                ["LAYOUT_HEALTH"] = {
                    ["value"] = {
                        ["y"] = 0,
                        ["x"] = 0,
                        ["anchor"] = "CENTER",
                        ["opacity"] = 1,
                        ["height"] = 32,
                        ["width"] = 120,
                    },
                    ["displayName"] = "Health Bar",
                },
                ["LAYOUT_HEALTH_TEXT"] = {
                    ["value"] = {
                        ["y"] = -1,
                        ["x"] = 0,
                        ["anchor"] = "CENTER",
                        ["opacity"] = 1,
                        ["size"] = 12,
                    },
                    ["displayName"] = "Health Text",
                },
                ["LAYOUT_CAST"] = {
                    ["value"] = {
                        ["y"] = -26,
                        ["x"] = 0,
                        ["anchor"] = "BOTTOM",
                        ["height"] = 24,
                        ["opacity"] = 1,
                        ["parent"] = "PowerBar",
                        ["width"] = 120,
                    },
                    ["displayName"] = "Cast Bar",
                },
                ["LAYOUT_CAST_ICON"] = {
                    ["value"] = {
                        ["y"] = 0,
                        ["x"] = -26,
                        ["height"] = 24,
                        ["opacity"] = 1,
                        ["anchor"] = "LEFT",
                        ["width"] = 24,
                    },
                    ["displayName"] = "Cast Icon",
                },
                ["LAYOUT_HEALERS_HEALER_ICON"] = {
                    ["value"] = {
                        ["y"] = 0,
                        ["x"] = 0,
                        ["anchor"] = "TOPLEFT",
                        ["height"] = 18,
                        ["opacity"] = 1,
                        ["parent"] = "HealthBar",
                        ["width"] = 18,
                    },
                    ["displayName"] = "Healer Icon",
                },
                ["LAYOUT_NAME"] = {
                    ["value"] = {
                        ["y"] = 14,
                        ["x"] = 0,
                        ["anchor"] = "TOP",
                        ["opacity"] = 1,
                        ["parent"] = "HealthBar",
                        ["size"] = 12,
                    },
                    ["displayName"] = "Name",
                },
                ["LAYOUT_CASTKICK_KICK_ALERT"] = {
                    ["value"] = {
                        ["y"] = 0,
                        ["x"] = 13,
                        ["anchor"] = "RIGHT",
                        ["height"] = 24,
                        ["opacity"] = 1,
                        ["parent"] = "CastBar",
                        ["width"] = 24,
                    },
                    ["displayName"] = "Cast Kick Alert",
                },
                ["LAYOUT_STUNS_STUN"] = {
                    ["value"] = {
                        ["y"] = 0,
                        ["x"] = -17,
                        ["anchor"] = "LEFT",
                        ["height"] = 32,
                        ["opacity"] = 1,
                        ["parent"] = "HealthBar",
                        ["width"] = 32,
                    },
                    ["displayName"] = "Stun",
                },
                ["LAYOUT_RAID_ICON"] = {
                    ["value"] = {
                        ["y"] = 66,
                        ["x"] = 0,
                        ["anchor"] = "TOP",
                        ["height"] = 42,
                        ["opacity"] = 1,
                        ["parent"] = "HealthBar",
                        ["width"] = 42,
                    },
                    ["displayName"] = "Raid Icon",
                },
                ["LAYOUT_POWER"] = {
                    ["value"] = {
                        ["y"] = -4,
                        ["x"] = 0,
                        ["hide border"] = "t",
                        ["parent"] = "HealthBar",
                        ["height"] = 4,
                        ["opacity"] = 1,
                        ["anchor"] = "BOTTOM",
                        ["width"] = 120,
                    },
                    ["displayName"] = "Power",
                },
                ["LAYOUT_TRINKET_TRINKET"] = {
                    ["value"] = {
                        ["y"] = 0,
                        ["x"] = 0,
                        ["anchor"] = "TOPRIGHT",
                        ["height"] = 18,
                        ["opacity"] = 1,
                        ["parent"] = "HealthBar",
                        ["width"] = 18,
                    },
                    ["displayName"] = "Trinket",
                },
                ["LAYOUT_SILENCES_SILENCE"] = {
                    ["value"] = {
                        ["y"] = 0,
                        ["x"] = 17,
                        ["anchor"] = "RIGHT",
                        ["height"] = 32,
                        ["opacity"] = 1,
                        ["parent"] = "HealthBar",
                        ["width"] = 32,
                    },
                    ["displayName"] = "Silence",
                },
            },
            ["configurable"] = false,
        }

    };
end


