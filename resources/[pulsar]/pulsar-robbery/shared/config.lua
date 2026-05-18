RobberyConfig = {
    -- FLEECA
    fleeca = {
        serverStartWait   = 1000 * 60 * math.random(60, 90), -- ms delay after server boot before robberies open; randomised each restart
        requiredPolice    = 0,                                -- minimum on-duty police count required
        cooldown          = { min = 4, max = 6 },             -- hours between robberies at the same bank; picked randomly in range
        laptopAttempts    = 2,                                -- failed laptop minigames before the item is consumed

        items = {
            laptop   = "green_laptop", -- item name must exactly match the items database
            thermite = "thermite",
            drill    = "drill",
        },

        games = {
            drill = {
                passes   = 1,     -- number of passes required to succeed
                duration = 25000, -- ms per pass
                config   = {},
            },
            laptop = {
                countdown  = 3,             -- seconds before the game starts
                timer      = { 1800, 2200 }, -- ms range for each tile reveal
                limit      = 30000,         -- total time limit in ms
                difficulty = 3,
                chances    = 4,             -- tile misses allowed inside the minigame before it counts as a failure
                isShuffled = false,
                anim       = false,
            },
            thermite = {
                countdown  = 3,
                preview    = 1750,  -- ms to show the pattern before it hides
                timer      = 9000,  -- total time to reproduce the pattern
                passReduce = 500,   -- ms shaved off timer per successful pass
                base       = 10,    -- number of tiles to memorise
                cols       = 5,
                rows       = 5,
                anim       = false,
            },
        },

        -- STEP 1: enter the bank zone (outer polyzone; each location's coords/width/length)
        -- STEP 2: use laptop at points.laptopLoc to hack the vault door (green_laptop)
        -- STEP 3: wait for the time-lock countdown (~2–4 min)
        -- STEP 4: place thermite at points.thermiteLoc to blow the vault gate
        -- STEP 5: drill the safe zones inside the vault (loots targets)
        -- (police): secure the bank to auto-reset it
        locations = {
            fleeca_hawick_east = { -- key
                id     = "fleeca_hawick_east", -- id mirrors the key
                label  = "East Hawick Ave",
                coords = vector3(311.5, -282.35, 54.16),
                width  = 13.2, length = 11.6,
                options = { heading = 340, minZ = 53.16, maxZ = 58.16 },
                reset   = { coords = vector3(309.15, -281.37, 54.16), length = 0.4, width = 0.4, options = { heading = 340, minZ = 53.56, maxZ = 55.76 } },
                points = { -- points: world coords where the player stands to trigger the interaction
                    laptopLoc   = { coords = vector3(311.202, -284.257, 54.165), heading = 161.541 }, -- laptopLoc = vault keypad / laptop terminal
                    thermiteLoc = { coords = vector3(313.2626, -285.3768, 54.50795), heading = 166.280 }, -- thermiteLoc = vault gate thermite placement
                },
                doors = { vaultDoor = { object = 2121050683, step = -0.60, originalHeading = 249.866 } },
                loots = { -- loots: drill targets inside the vault (registered as ox_target zones)
                    --   options.name must be globally unique ; used as the ox_target zone ID
                    { coords = vector3(314.22, -282.97, 54.16), width = 0.2,  length = 2.8,  options = { name = "hawick_east_1", heading = 340, minZ = 53.16, maxZ = 55.56 } },
                    { coords = vector3(315.77, -285.06, 54.16), width = 2.0,  length = 0.2,  options = { name = "hawick_east_2", heading = 339, minZ = 53.16, maxZ = 55.56 } },
                    { coords = vector3(315.22, -288.37, 54.16), width = 2.95, length = 0.2,  options = { name = "hawick_east_3", heading = 340, minZ = 53.16, maxZ = 55.56 } },
                    { coords = vector3(312.36, -289.4,  54.16), width = 0.2,  length = 3.8,  options = { name = "hawick_east_4", heading = 340, minZ = 53.16, maxZ = 55.56 } },
                    { coords = vector3(310.86, -286.81, 54.16), width = 2.95, length = 0.2,  options = { name = "hawick_east_5", heading = 339, minZ = 53.16, maxZ = 55.56 } },
                },
            },
            fleeca_hawick_west = {
                id     = "fleeca_hawick_west",
                label  = "West Hawick Ave",
                coords = vector3(-353.26, -53.09, 49.04),
                width  = 12.4, length = 14.0,
                options = { heading = 340, minZ = 48.04, maxZ = 52.04 },
                reset   = { coords = vector3(-356.0, -52.24, 49.04), length = 0.4, width = 0.4, options = { heading = 340, minZ = 48.64, maxZ = 50.24 } },
                points = {
                    laptopLoc   = { coords = vector3(-353.713, -54.698, 49.037), heading = 160.637 },
                    thermiteLoc = { coords = vector3(-351.7869, -56.2472, 49.36483), heading = 163.485 },
                },
                doors = { vaultDoor = { object = 2121050683, step = -0.60, originalHeading = 250.860 } },
                loots = {
                    { coords = vector3(-350.84, -53.73, 49.04), width = 0.45, length = 2.95, options = { name = "hawick_west_1", heading = 340, minZ = 48.04, maxZ = 50.44 } },
                    { coords = vector3(-349.23, -55.87, 49.04), width = 2.0,  length = 0.2,  options = { name = "hawick_west_2", heading = 340, minZ = 48.04, maxZ = 50.44 } },
                    { coords = vector3(-349.77, -59.17, 49.04), width = 2.95, length = 0.2,  options = { name = "hawick_west_3", heading = 341, minZ = 48.04, maxZ = 50.44 } },
                    { coords = vector3(-352.62, -60.26, 49.04), width = 0.2,  length = 3.8,  options = { name = "hawick_west_4", heading = 340, minZ = 48.04, maxZ = 50.44 } },
                    { coords = vector3(-354.13, -57.68, 49.04), width = 2.95, length = 0.2,  options = { name = "hawick_west_5", heading = 341, minZ = 48.04, maxZ = 50.44 } },
                },
            },
            fleeca_delperro = {
                id     = "fleeca_delperro",
                label  = "Boulevard Del Perro",
                coords = vector3(-1212.59, -335.36, 37.78),
                width  = 12.4, length = 14.0,
                options = { heading = 207, minZ = 36.78, maxZ = 40.78 },
                reset   = { coords = vector3(-1214.56, -336.0, 37.78), length = 0.4, width = 0.4, options = { heading = 25, minZ = 37.38, maxZ = 39.18 } },
                points = {
                    laptopLoc   = { coords = vector3(-1210.908, -336.374, 37.781), heading = 207.123 },
                    thermiteLoc = { coords = vector3(-1208.644, -335.7033, 38.10191), heading = 209.101 },
                },
                doors = { vaultDoor = { object = 2121050683, step = -0.60, originalHeading = 296.864 } },
                loots = {
                    { coords = vector3(-1209.8,  -333.39, 37.78), width = 0.2,  length = 2.95, options = { name = "delperro_1", heading = 26, minZ = 36.78, maxZ = 39.18 } },
                    { coords = vector3(-1207.2,  -333.65, 37.78), width = 2.0,  length = 0.2,  options = { name = "delperro_2", heading = 27, minZ = 36.78, maxZ = 39.18 } },
                    { coords = vector3(-1205.2,  -336.32, 37.78), width = 2.95, length = 0.2,  options = { name = "delperro_3", heading = 27, minZ = 36.78, maxZ = 39.18 } },
                    { coords = vector3(-1206.37, -339.1,  37.78), width = 0.2,  length = 3.8,  options = { name = "delperro_4", heading = 27, minZ = 36.78, maxZ = 39.18 } },
                    { coords = vector3(-1209.31, -338.44, 37.78), width = 2.95, length = 0.2,  options = { name = "delperro_5", heading = 26, minZ = 36.78, maxZ = 39.18 } },
                },
            },
            fleeca_great_ocean = {
                id     = "fleeca_great_ocean",
                label  = "Great Ocean Highway",
                coords = vector3(-2959.0, 479.93, 15.7),
                width  = 13.2, length = 14.0,
                options = { heading = 177, minZ = 14.7, maxZ = 18.7 },
                reset   = { coords = vector3(-2958.92, 478.64, 15.7), length = 0.4, width = 0.4, options = { heading = 0, minZ = 15.1, maxZ = 16.9 } },
                points = {
                    laptopLoc   = { coords = vector3(-2957.010, 481.691, 15.697), heading = 270.583 },
                    thermiteLoc = { coords = vector3(-2956.255, 483.9868, 16.0309), heading = 269.528 },
                },
                doors = { vaultDoor = { object = 2121050683, step = -0.60, originalHeading = 357.542 } },
                loots = {
                    { coords = vector3(-2958.89, 484.14, 15.7), width = 0.2,  length = 2.95, options = { name = "great_ocean_1", heading = 88, minZ = 14.7, maxZ = 17.1 } },
                    { coords = vector3(-2957.34, 486.26, 15.7), width = 2.0,  length = 0.2,  options = { name = "great_ocean_2", heading = 88, minZ = 14.7, maxZ = 17.1 } },
                    { coords = vector3(-2954.02, 486.68, 15.7), width = 2.95, length = 0.2,  options = { name = "great_ocean_3", heading = 88, minZ = 14.7, maxZ = 17.1 } },
                    { coords = vector3(-2952.18, 484.3,  15.7), width = 0.2,  length = 3.8,  options = { name = "great_ocean_4", heading = 88, minZ = 14.7, maxZ = 17.1 } },
                    { coords = vector3(-2954.21, 482.1,  15.7), width = 2.95, length = 0.2,  options = { name = "great_ocean_5", heading = 88, minZ = 14.7, maxZ = 17.1 } },
                },
            },
            fleeca_route68 = {
                id     = "fleeca_route68",
                label  = "Route 68",
                coords = vector3(1177.01, 2710.92, 38.09),
                width  = 12.4, length = 14.0,
                options = { heading = 359, minZ = 37.09, maxZ = 41.09 },
                reset   = { coords = vector3(1179.12, 2710.69, 38.09), length = 0.4, width = 0.4, options = { heading = 0, minZ = 37.49, maxZ = 39.29 } },
                points = {
                    laptopLoc   = { coords = vector3(1176.091, 2712.595, 38.088), heading = 4.828 },
                    thermiteLoc = { coords = vector3(1173.74, 2713.073, 38.41225), heading = 3.455 },
                },
                doors = { vaultDoor = { object = 2121050683, step = -0.60, originalHeading = 90.0 } },
                loots = {
                    { coords = vector3(1173.72, 2710.48, 38.09), width = 0.2,  length = 2.95, options = { name = "route68_1", heading = 0,   minZ = 37.09, maxZ = 39.49 } },
                    { coords = vector3(1171.51, 2711.88, 38.09), width = 2.0,  length = 0.2,  options = { name = "route68_2", heading = 359, minZ = 37.09, maxZ = 39.49 } },
                    { coords = vector3(1170.94, 2715.19, 38.09), width = 2.95, length = 0.2,  options = { name = "route68_3", heading = 0,   minZ = 37.09, maxZ = 39.49 } },
                    { coords = vector3(1173.24, 2717.08, 38.09), width = 0.2,  length = 3.8,  options = { name = "route68_4", heading = 0,   minZ = 37.09, maxZ = 39.49 } },
                    { coords = vector3(1175.57, 2715.2,  38.09), width = 2.95, length = 0.2,  options = { name = "route68_5", heading = 0,   minZ = 37.09, maxZ = 39.49 } },
                },
            },
            fleeca_vespucci = {
                id     = "fleeca_vespucci",
                label  = "Vespucci Blvd",
                coords = vector3(146.18, -1043.61, 29.37),
                width  = 13.4, length = 12.8,
                options = { heading = 340, minZ = 28.37, maxZ = 32.37 },
                reset   = { coords = vector3(144.66, -1042.92, 29.37), length = 0.4, width = 0.4, options = { heading = 340, minZ = 28.57, maxZ = 30.77 } },
                points = {
                    laptopLoc   = { coords = vector3(147.043, -1045.367, 29.368), heading = 165.714 },
                    thermiteLoc = { coords = vector3(148.9605, -1047.058, 29.70366), heading = 165.708 },
                },
                doors = { vaultDoor = { object = 2121050683, step = -0.60, originalHeading = 249.846 } },
                loots = {
                    { coords = vector3(149.93,  -1044.61, 29.37), width = 0.2,  length = 2.95, options = { name = "vespucci_1", heading = 340, minZ = 28.37, maxZ = 30.77 } },
                    { coords = vector3(151.48,  -1046.72, 29.37), width = 2.0,  length = 0.2,  options = { name = "vespucci_2", heading = 340, minZ = 28.37, maxZ = 30.77 } },
                    { coords = vector3(150.64,  -1049.96, 29.37), width = 2.95, length = 0.4,  options = { name = "vespucci_3", heading = 340, minZ = 28.37, maxZ = 30.77 } },
                    { coords = vector3(148.07,  -1051.01, 29.37), width = 0.2,  length = 3.8,  options = { name = "vespucci_4", heading = 339, minZ = 28.37, maxZ = 30.77 } },
                    { coords = vector3(146.48,  -1048.4,  29.37), width = 2.95, length = 0.2,  options = { name = "vespucci_5", heading = 340, minZ = 28.37, maxZ = 30.77 } },
                },
            },
        },

        -- loot tables (drawn when a trolley is looted in Step 5)
        -- each entry: { weight, { name, min, max [, metadata] } }; weights are relative — higher = more common
        loot = {
            trolley = {
                cash = {
                    { 60, { name = "moneyroll",  min = 200, max = 250 } },
                    { 33, { name = "moneyband",  min = 22,  max = 28  } },
                    { 5,  { name = "valuegoods", min = 14,  max = 20  } },
                    { 2,  { name = "moneybag",   min = 1,   max = 1,  metadata = { CustomAmt = { Min = 15000, Random = 5000 } } } },
                },
                gold = {
                    { 85, { name = "goldbar",  min = 50, max = 70 } },
                    { 15, { name = "moneybag", min = 1,  max = 1,  metadata = { CustomAmt = { Min = 40000, Random = 10000 } } } },
                },
                gems = {
                    { 20, { name = "opal",     min = 1, max = 1 } },
                    { 20, { name = "citrine",  min = 1, max = 1 } },
                    { 20, { name = "amethyst", min = 1, max = 1 } },
                    { 15, { name = "ruby",     min = 1, max = 1 } },
                    { 15, { name = "sapphire", min = 1, max = 1 } },
                    { 5,  { name = "emerald",  min = 1, max = 1 } },
                    { 5,  { name = "diamond",  min = 1, max = 1 } },
                },
            },
        },
        -- hash = full trolley prop, empty = after looting, hand = prop held during loot anim
        trolleyTypes = {
            { hash = `hei_prop_hei_cash_trolly_01`,   empty = `hei_prop_hei_cash_trolly_03`,    hand = `hei_prop_heist_cash_pile`,  type = "cash" },
            { hash = `ch_prop_cash_low_trolly_01a`,   empty = `mythic_prop_diamond_empty`,       hand = `hei_prop_heist_cash_pile`,  type = "cash" },
            { hash = `ch_prop_cash_low_trolly_01b`,   empty = `mythic_prop_diamond_emptyb`,      hand = `hei_prop_heist_cash_pile`,  type = "cash" },
            { hash = `ch_prop_cash_low_trolly_01c`,   empty = `mythic_prop_diamond_emptyc`,      hand = `hei_prop_heist_cash_pile`,  type = "cash" },
            { hash = `ch_prop_ch_cash_trolly_01a`,    empty = `mythic_prop_diamond_empty`,       hand = `hei_prop_heist_cash_pile`,  type = "cash" },
            { hash = `ch_prop_ch_cash_trolly_01b`,    empty = `mythic_prop_diamond_emptyb`,      hand = `hei_prop_heist_cash_pile`,  type = "cash" },
            { hash = `ch_prop_ch_cash_trolly_01c`,    empty = `mythic_prop_diamond_emptyc`,      hand = `hei_prop_heist_cash_pile`,  type = "cash" },
            { hash = `ch_prop_gold_trolly_01a`,       empty = `mythic_prop_diamond_empty`,       hand = `ch_prop_gold_bar_01a`,      type = "gold" },
            { hash = `ch_prop_gold_trolly_01b`,       empty = `mythic_prop_diamond_emptyb`,      hand = `ch_prop_gold_bar_01a`,      type = "gold" },
            { hash = `ch_prop_gold_trolly_01c`,       empty = `mythic_prop_diamond_emptyc`,      hand = `ch_prop_gold_bar_01a`,      type = "gold" },
            -- gems trolleys (disabled until gem loot is tuned):
            -- { hash = `ch_prop_diamond_trolly_01a`, empty = `mythic_prop_diamond_empty`,    hand = `ch_prop_vault_dimaondbox_01a`, type = "gems" },
            -- { hash = `ch_prop_diamond_trolly_01b`, empty = `mythic_prop_diamond_emptyb`,   hand = `ch_prop_vault_dimaondbox_01a`, type = "gems" },
            -- { hash = `ch_prop_diamond_trolly_01c`, empty = `mythic_prop_diamond_emptyc`,   hand = `ch_prop_vault_dimaondbox_01a`, type = "gems" },
        },
    },

    -- BOBCAT
    bobcat = {
        serverStartWait = 1000 * 60 * math.random(60, 120),
        requiredPolice  = 4,
        resetTime       = 60 * 60 * 8, -- seconds until the heist resets

        -- STEP 1: thermite exterior door / STEP 2: thermite front door
        -- STEP 3: hack secured door (blue_laptop at frontPCHack) / STEP 5: breach vault door
        locations = {
            extrDoor    = { coords = vector3(882.174, -2258.287, 30.541),    heading = 178.102 }, -- Step 1
            startDoor   = { coords = vector3(880.3293, -2264.466, 30.59444), heading = 178.102 }, -- Step 2
            securedDoor = { coords = vector3(882.976, -2268.013, 30.468) },                       -- Step 3 (unlocked via frontPCHack)
            vaultDoor   = { coords = vector3(890.41, -2285.601, 30.467),     heading = 93.374 },  -- Step 5
        },

        -- ox_target interaction zones for key actions
        targets = {
            -- Step 3: hack the front PC to bypass the secured door (blue_laptop)
            frontPCHack = {
                coords  = vector3(875.15, -2263.83, 30.47),
                length  = 0.8, width = 1.2,
                options = { heading = 354, minZ = 28.92, maxZ = 31.32 },
            },
            -- Step 4: collect C4 charges to breach the vault
            c4 = {
                coords  = vector3(873.44, -2294.37, 30.47),
                length  = 1.4, width = 1.4,
                options = { heading = 355, minZ = 29.47, maxZ = 31.67 },
            },
            -- Step 5: disable vault security system before looting
            securityHack = {
                coords  = vector3(887.07, -2299.13, 30.47),
                length  = 3.0, width = 1.0,
                options = { heading = 264, minZ = 29.47, maxZ = 31.27 },
            },
            -- (police): secure the facility to end the heist
            secure = {
                coords  = vector3(876.94, -2262.69, 30.47),
                length  = 0.8, width = 1.4,
                options = { heading = 356, minZ = 29.87, maxZ = 31.47 },
            },
        },

        -- STEP 6: loot crates inside the vault; data.type maps to a key in loot
        lootZones = {
            { coords = vector3(881.8,  -2282.79, 30.47), width = 2.0,  length = 1.4, options = { heading = 333, minZ = 29.47, maxZ = 31.67 }, data = { id = 1, type = "guns-c2",   amount = 2, bonus = 8  } },
            { coords = vector3(882.55, -2285.82, 30.47), width = 1.15, length = 1.8, options = { heading = 341, minZ = 29.47, maxZ = 31.27 }, data = { id = 2, type = "guns-c2",   amount = 2, bonus = 8  } },
            { coords = vector3(886.63, -2286.84, 30.59), width = 1.4,  length = 2.0, options = { heading = 0,   minZ = 29.59, maxZ = 30.99 }, data = { id = 3, type = "guns",      amount = 3, bonus = 15 } },
            { coords = vector3(887.01, -2282.06, 30.47), width = 1.2,  length = 2.2, options = { heading = 354, minZ = 29.47, maxZ = 31.27 }, data = { id = 4, type = "components", amount = 4, bonus = 10 } },
        },

        pedLocations = {
            vector4(883.967, -2276.069, 30.468, 46.108),  vector4(887.204, -2275.289, 30.468, 78.713),
            vector4(887.706, -2276.708, 30.468, 70.493),  vector4(890.998, -2276.155, 30.468, 76.662),
            vector4(891.644, -2278.115, 30.468, 61.522),  vector4(893.985, -2275.837, 30.468, 72.070),
            vector4(894.188, -2278.598, 30.468, 67.238),  vector4(896.048, -2282.575, 30.468, 39.264),
            vector4(892.170, -2286.094, 30.468, 352.334), vector4(893.804, -2284.555, 30.468, 10.603),
            vector4(894.432, -2288.290, 30.468, 1.191),   vector4(892.147, -2289.318, 30.468, 353.226),
            vector4(893.299, -2292.591, 30.468, 353.592), vector4(891.166, -2293.612, 30.468, 343.993),
            vector4(887.185, -2294.485, 30.468, 290.266), vector4(884.734, -2291.749, 30.468, 276.584),
            vector4(880.892, -2293.349, 30.468, 272.596), vector4(878.148, -2295.895, 30.468, 312.062),
            vector4(876.398, -2290.847, 30.468, 256.690), vector4(879.946, -2291.485, 30.468, 265.639),
            vector4(874.683, -2296.097, 30.468, 300.001), vector4(877.389, -2295.764, 30.468, 323.910),
            vector4(872.100, -2291.334, 30.468, 259.871), vector4(869.719, -2288.677, 30.468, 249.077),
            vector4(868.316, -2288.768, 30.468, 245.280), vector4(869.559, -2293.151, 30.468, 282.122),
            vector4(872.193, -2297.360, 30.468, 297.501), vector4(874.321, -2294.222, 30.468, 277.020),
            vector4(895.646, -2287.415, 30.468, 13.802),  vector4(894.001, -2277.819, 30.468, 59.191),
        },

        interiorCoords = vector3(883.4142, -2282.372, 31.44168),

        polyZone = {
            vector2(907.62103271484, -2256.4008789062), vector2(884.54675292969, -2254.3540039062),
            vector2(884.14483642578, -2258.1083984375), vector2(875.30352783203, -2257.1977539062),
            vector2(875.5947265625,  -2253.6535644531), vector2(862.10314941406, -2252.4174804688),
            vector2(858.14068603516, -2301.7275390625), vector2(864.97967529297, -2302.4465332031),
            vector2(862.97448730469, -2326.4291992188), vector2(893.88073730469, -2329.2299804688),
            vector2(898.49328613281, -2282.5910644531), vector2(905.71173095703, -2282.4621582031),
            vector2(905.96569824219, -2275.7841796875), vector2(902.26873779297, -2275.3005371094),
            vector2(902.99908447266, -2266.6032714844), vector2(906.78369140625, -2266.6918945312),
        },
        polyZoneOptions = { minZ = 25.34613609314, maxZ = 35.549388885498 },

        -- guard ped weapon pool (spawned inside the facility)
        weapons = {
            `WEAPON_APPISTOL`,
            `WEAPON_MG`,
            `WEAPON_COMBATMG`,
            `WEAPON_ASSAULTRIFLE`,
            `WEAPON_COMPACTRIFLE`,
            `WEAPON_SMG`,
            `WEAPON_ASSAULTSHOTGUN`,
            `WEAPON_SAWNOFFSHOTGUN`,
        },

        -- schematic loot pools
        schematics = {
            standard = {
                "schematic_fnx", "schematic_combat_pistol", "schematic_57", "schematic_snsmk2",
                "schematic_glock", "schematic_m9a3", "schematic_tact2011", "schematic_p226",
                "schematic_deagle", "schematic_l5", "schematic_revolver", "schematic_38_snubnose",
                "schematic_38_custom", "schematic_44_magnum", "schematic_mp5",
            },
            c2 = {
                "schematic_microsmg", "schematic_mp9", "schematic_miniuzi",
            },
            combined = {
                "schematic_fnx", "schematic_combat_pistol", "schematic_57", "schematic_snsmk2",
                "schematic_glock", "schematic_m9a3", "schematic_tact2011", "schematic_p226",
                "schematic_deagle", "schematic_l5", "schematic_revolver", "schematic_38_snubnose",
                "schematic_38_custom", "schematic_44_magnum", "schematic_mp5",
                "schematic_microsmg", "schematic_mp9", "schematic_miniuzi",
            },
            attachments = {
                "schematic_smg_ammo", "schematic_weapon_flashlight", "schematic_pistol_ext_mag",
                "schematic_smg_ext_mag", "schematic_pistol_suppressor", "schematic_smg_suppressor",
            },
        },

        -- weighted loot table per zone type; { weight, { name, min, max [, metadata] } }
        loot = {
            ["guns"] = {
                { 10, { name = "BOBCAT_38SNUBNOSE2",  min = 1, max = 1, metadata = { ammo = 100, clip = 0, Company = { name = "Bobcat Security", stolen = true } } } },
                { 10, { name = "BOBCAT_38SNUBNOSE3",  min = 1, max = 1, metadata = { ammo = 100, clip = 0, Company = { name = "Bobcat Security", stolen = true } } } },
                { 10, { name = "BOBCAT_57",           min = 1, max = 1, metadata = { ammo = 100, clip = 0, Company = { name = "Bobcat Security", stolen = true } } } },
                { 10, { name = "BOBCAT_SNSPISTOL",    min = 1, max = 1, metadata = { ammo = 100, clip = 0, Company = { name = "Bobcat Security", stolen = true } } } },
                { 10, { name = "BOBCAT_P226",         min = 1, max = 1, metadata = { ammo = 100, clip = 0, Company = { name = "Bobcat Security", stolen = true } } } },
                { 10, { name = "BOBCAT_M9A3",         min = 1, max = 1, metadata = { ammo = 100, clip = 0, Company = { name = "Bobcat Security", stolen = true } } } },
                { 10, { name = "BOBCAT_2011",         min = 1, max = 1, metadata = { ammo = 100, clip = 0, Company = { name = "Bobcat Security", stolen = true } } } },
                { 10, { name = "BOBCAT_GLOCK19_CIV",  min = 1, max = 1, metadata = { ammo = 100, clip = 0, Company = { name = "Bobcat Security", stolen = true } } } },
                { 5,  { name = "BOBCAT_DOUBLEACTION", min = 1, max = 1, metadata = { ammo = 100, clip = 0, Company = { name = "Bobcat Security", stolen = true } } } },
                { 5,  { name = "WEAPON_L5",           min = 1, max = 1, metadata = { ammo = 100, clip = 0, Company = { name = "Bobcat Security", stolen = true } } } },
                { 5,  { name = "BOBCAT_PISTOL50",     min = 1, max = 1, metadata = { ammo = 100, clip = 0, Company = { name = "Bobcat Security", stolen = true } } } },
                { 5,  { name = "BOBCAT_REVOLVER",     min = 1, max = 1, metadata = { ammo = 100, clip = 0, Company = { name = "Bobcat Security", stolen = true } } } },
            },
            ["guns-c2"] = {
                { 22, { name = "BOBCAT_38SNUBNOSE2", min = 1, max = 1, metadata = { ammo = 100, clip = 0, Company = { name = "Bobcat Security", stolen = true } } } },
                { 22, { name = "BOBCAT_38SNUBNOSE3", min = 1, max = 1, metadata = { ammo = 100, clip = 0, Company = { name = "Bobcat Security", stolen = true } } } },
                { 10, { name = "BOBCAT_38CUSTOM",    min = 1, max = 1, metadata = { ammo = 100, clip = 0, Company = { name = "Bobcat Security", stolen = true } } } },
                { 10, { name = "BOBCAT_44MAGNUM",    min = 1, max = 1, metadata = { ammo = 100, clip = 0, Company = { name = "Bobcat Security", stolen = true } } } },
                { 6,  { name = "BOBCAT_REVOLVER",    min = 1, max = 1, metadata = { ammo = 100, clip = 0, Company = { name = "Bobcat Security", stolen = true } } } },
                { 6,  { name = "BOBCAT_PISTOL50",    min = 1, max = 1, metadata = { ammo = 100, clip = 0, Company = { name = "Bobcat Security", stolen = true } } } },
                { 6,  { name = "BOBCAT_L5",          min = 1, max = 1, metadata = { ammo = 100, clip = 0, Company = { name = "Bobcat Security", stolen = true } } } },
                { 7,  { name = "BOBCAT_PP19",        min = 1, max = 1, metadata = { ammo = 100, clip = 0, Company = { name = "Bobcat Security", stolen = true } } } },
                { 7,  { name = "BOBCAT_MPX",         min = 1, max = 1, metadata = { ammo = 100, clip = 0, Company = { name = "Bobcat Security", stolen = true } } } },
                { 2,  { name = "BOBCAT_MP9",         min = 1, max = 1, metadata = { ammo = 100, clip = 0, Company = { name = "Bobcat Security", stolen = true } } } },
                { 2,  { name = "BOBCAT_MINIUZI",     min = 1, max = 1, metadata = { ammo = 100, clip = 0, Company = { name = "Bobcat Security", stolen = true } } } },
            },
            ["components"] = {
                { 15, { name = "ATTCH_WEAPON_FLASHLIGHT", min = 1,  max = 1  } },
                { 15, { name = "scuba_gear",              min = 1,  max = 1  } },
                { 15, { name = "AMMO_SMG",                min = 3,  max = 10 } },
                { 15, { name = "AMMO_SHOTGUN",            min = 3,  max = 10 } },
                { 10, { name = "ATTCH_PISTOL_EXT_MAG",   min = 1,  max = 1  } },
                { 10, { name = "ATTCH_PISTOL_SILENCER",  min = 1,  max = 1  } },
                { 10, { name = "ATTCH_SMG_EXT_MAG",      min = 1,  max = 1  } },
                { 10, { name = "ATTCH_SMG_SILENCER",     min = 1,  max = 1  } },
            },
        },
    },

    -- LOMBANK
    lombank = {
        serverStartWait = 1000 * 60 * math.random(60, 90),
        requiredPolice  = 0,
        resetTime       = 60 * 60 * 8,

        -- STEP 1: disable power boxes to deactivate lasers (hack or thermite per box)
        powerBoxes = {
            { isThermite = false, coords = vector3(85.45, -812.77, 31.36), length = 1.0, width = 1.4, options = { heading = 343, minZ = 31.16, maxZ = 32.96 }, data = { boxId = 1, ptFxPoint = vector3(85.37447, -812.7527, 32.08653) } },
            { isThermite = false, coords = vector3(55.65, -832.02, 31.07), length = 1.0, width = 1.4, options = { heading = 340, minZ = 30.47, maxZ = 33.27 }, data = { boxId = 2, ptFxPoint = vector3(55.73209, -831.9764, 32.08678) } },
            { isThermite = true,  coords = vector3(88.81, -1080.09, 29.3), length = 1.6, width = 1.4, options = { heading = 336, minZ = 28.3,  maxZ = 30.5  }, data = { boxId = 3, thermitePoint = { coords = vector3(89.09108, -1080.605, 29.54803), heading = 71.914 }, ptFxPoint = vector3(89.09108, -1080.605, 29.54803) } },
        },

        -- STEP 2: thermite doors in sequence to progress deeper into the bank
        --   lobbyGate → vaultGate → (lowerVaultGate or upperVaultGate) → lowerVaultRooms
        thermitePoints = {
            lobbyGate = {
                coords = vector3(17.5381, -920.9682, 30.07446), heading = 249.549,
                door = "pulsar_lombank_front_gate", requiredDoors = {},
            },
            vaultGate = {
                coords = vector3(24.04349, -932.0154, 30.25345), heading = 166.307,
                door = "pulsar_lombank_upper_gate", requiredDoors = { "pulsar_lombank_front_gate" },
            },
            upperVaultGate = {
                coords = vector3(22.34634, -942.4745, 30.26073), heading = 249.518,
                door = "pulsar_lombank_upper_vault_gate",
                requiredDoors = { "pulsar_lombank_front_gate", "pulsar_lombank_upper_gate", "pulsar_lombank_upper_vault" },
            },
            lowerVaultGate = {
                coords = vector3(25.865, -929.0033, 26.09646), heading = 74.396,
                door = "pulsar_lombank_lower_gate",
                requiredDoors = { "pulsar_lombank_front_gate", "pulsar_lombank_upper_gate" },
            },
            lowerVaultRoom1 = {
                coords = vector3(24.48319, -913.9099, 26.09066), heading = 76.141,
                door = "pulsar_lombank_lower_room_1",
                requiredDoors = { "pulsar_lombank_front_gate", "pulsar_lombank_upper_gate", "pulsar_lombank_lasers", "pulsar_lombank_lower_vault" },
            },
            lowerVaultRoom2 = {
                coords = vector3(33.44628, -917.2109, 26.08794), heading = 250.554,
                door = "pulsar_lombank_lower_room_2",
                requiredDoors = { "pulsar_lombank_front_gate", "pulsar_lombank_upper_gate", "pulsar_lombank_lasers", "pulsar_lombank_lower_vault" },
            },
            lowerVaultRoom3 = {
                coords = vector3(27.05835, -906.868, 26.08865), heading = 76.141,
                door = "pulsar_lombank_lower_room_3",
                requiredDoors = { "pulsar_lombank_front_gate", "pulsar_lombank_upper_gate", "pulsar_lombank_lasers", "pulsar_lombank_lower_vault" },
            },
            lowerVaultRoom4 = {
                coords = vector3(36.03009, -910.1262, 26.09541), heading = 250.554,
                door = "pulsar_lombank_lower_room_4",
                requiredDoors = { "pulsar_lombank_front_gate", "pulsar_lombank_upper_gate", "pulsar_lombank_lasers", "pulsar_lombank_lower_vault" },
            },
        },

        -- STEP 3: hack vault doors with purple laptop (requires gates already thermited)
        hackPoints = {
            upperVaultDoor = {
                coords = vector3(21.330, -939.860, 29.903), heading = 161.625,
                config = { countdown = 3, timer = { 1500, 2200 }, limit = 20000, difficulty = 4, chances = 6, isShuffled = false, anim = false },
                door = "pulsar_lombank_upper_vault",
                requiredDoors = { "lombank_front_gate", "lombank_upper_gate" },
            },
            lowerVaultDoor = {
                coords = vector3(28.094, -921.723, 25.738), heading = 250.137,
                config = { countdown = 3, timer = { 1500, 2200 }, limit = 20000, difficulty = 4, chances = 6, isShuffled = false, anim = false },
                door = "pulsar_lombank_lower_vault", forceOpen = true,
                requiredDoors = { "pulsar_lombank_front_gate", "pulsar_lombank_upper_gate", "pulsar_lombank_lasers" },
            },
        },

        -- STEP 4: drill upper vault walls to open the upper vault
        upperVaultPoints = {
            { coords = vector3(24.18, -941.61, 29.9), length = 0.6, width = 2.2, options = { heading = 340, minZ = 29.3, maxZ = 31.7 }, wallId = 1 },
            { coords = vector3(26.84, -942.42, 29.9), length = 0.6, width = 2.2, options = { heading = 340, minZ = 29.3, maxZ = 31.7 }, wallId = 2 },
            { coords = vector3(27.5,  -944.83, 29.9), length = 0.6, width = 2.2, options = { heading = 251, minZ = 29.3, maxZ = 31.7 }, wallId = 3 },
        },

        -- STEP 5: loot gold carts inside the lower vault rooms
        rooms = {
            { coords = vector3(22.14, -913.35, 25.74), length = 3.8, width = 4.4, options = { heading = 340, minZ = 24.74, maxZ = 27.54 }, roomId = 1 },
            { coords = vector3(35.55, -918.27, 25.74), length = 3.8, width = 4.4, options = { heading = 340, minZ = 24.74, maxZ = 27.54 }, roomId = 2 },
            { coords = vector3(24.7,  -906.27, 25.74), length = 3.8, width = 4.4, options = { heading = 340, minZ = 24.74, maxZ = 27.54 }, roomId = 3 },
            { coords = vector3(38.18, -911.16, 25.74), length = 3.8, width = 4.4, options = { heading = 340, minZ = 24.74, maxZ = 27.54 }, roomId = 4 },
        },

        -- gold cart prop hashes (used for spawning lootable carts in rooms)
        carts = {
            `prop_large_gold`,
            `prop_large_gold_alt_a`,
            `prop_large_gold_alt_b`,
            `prop_large_gold_alt_c`,
        },

        deathBox = {
            coords  = vector3(24.86, -921.78, 25.74),
            length  = 7.4, width = 7.8,
            options = { heading = 340, minZ = 24.74, maxZ = 28.74 },
            data    = { isDeath = true, tpCoords = vector3(2.593, -935.504, 29.905), door = "pulsar_lombank_lasers" },
        },

        polyZones = {
            death = {
                vertices = {
                    vector2(-316.5087890625,  -2439.6040039062), vector2(-319.24176025391, -2436.7438964844),
                    vector2(-326.0520324707,  -2431.16796875),   vector2(-327.56423950195, -2433.0493164062),
                    vector2(-321.0280456543,  -2438.8662109375), vector2(-321.59643554688, -2438.9645996094),
                    vector2(-328.29962158203, -2433.2578125),    vector2(-331.92529296875, -2437.6667480469),
                    vector2(-321.82626342773, -2446.1845703125),
                },
                options = { minZ = 5.4941825866699, maxZ = 11.6915531158447 },
                data    = { isDeath = true, tpCoords = vector3(-291.188, -2406.996, 6.901), door = "pulsar_coke_garage" },
            },
            bank = {
                vertices = {
                    vector2(-0.41744011640549, -933.08654785156), vector2(14.137574195862, -893.74298095703),
                    vector2(47.590084075928,   -905.93432617188), vector2(31.678886413574, -949.58227539062),
                    vector2(1.5427644252777,   -938.97210693359),
                },
                options = {},
            },
            power = {
                vertices = {
                    vector2(43.716075897217,  -811.39093017578), vector2(43.310741424561, -812.01684570312),
                    vector2(46.399833679199,  -813.21368408203), vector2(42.919136047363, -823.21014404297),
                    vector2(49.144268035889,  -825.46929931641), vector2(53.048881530762, -814.73663330078),
                    vector2(46.760047912598,  -812.44616699219),
                },
                options = { minZ = 29.4411277771, maxZ = 34.817783355713 },
                data    = { isDeath = true, tpCoords = vector3(2.593, -935.504, 29.905), door = "pulsar_lombank_hidden_entrance" },
            },
        },

        -- (police): secure the bank to end the heist
        secureZone = {
            coords  = vector3(7.69, -923.1, 29.9),
            length  = 2.8, width = 1.6,
            options = { heading = 340, minZ = 28.9, maxZ = 30.7 },
        },
    },

    -- MAZEBANK
    mazebank = {
        serverStartWait = 1000 * 60 * math.random(60, 90),
        requiredPolice  = 0,
        resetTime       = 60 * 60 * 6,

        -- STEP 1: disable power grid — hack (isThermite=false) or thermite (isThermite=true) each box
        electric = {
            { isThermite = false, coords = vector3(-1304.94, -803.99, 17.58), length = 0.8, width = 1.2, options = { heading = 303, minZ = 16.58, maxZ = 18.98 }, data = { boxId = 1, ptFxPoint = vector3(-1304.799, -803.7391, 17.62313) } },
            { isThermite = false, coords = vector3(-1286.22, -834.59, 17.1),  length = 0.6, width = 1.0, options = { heading = 308, minZ = 16.5,  maxZ = 18.7  }, data = { boxId = 2, ptFxPoint = vector3(-1286.22,  -834.5959, 17.58015) } },
            { isThermite = true,  coords = vector3(-1381.05, -830.55, 19.08), length = 0.6, width = 0.8, options = { heading = 14,  minZ = 17.08, maxZ = 20.08 }, data = { boxId = 3, thermitePoint = { coords = vector3(-1381.041, -830.7778, 19.095), heading = 18.270 }, ptFxPoint = vector3(-1381.041, -830.7778, 19.095) } },
        },

        -- STEP 2: thermite lobby/gate/vault doors in sequence (requiredDoors gates each placement)
        doors = {
            { coords = vector3(-1307.724, -817.6955, 16.80672), heading = 305.704, door = "pulsar_mazebank_tills",      requiredDoors = {} },
            { coords = vector3(-1301.999, -819.1389, 16.88831), heading = 306.572, door = "pulsar_mazebank_gate",       requiredDoors = { "pulsar_mazebank_tills" } },
            { coords = vector3(-1295.787, -816.8411, 17.15724), heading = 217.537, door = "pulsar_mazebank_vault_gate", requiredDoors = { "pulsar_mazebank_tills", "pulsar_mazebank_gate" } },
        },

        -- STEP 3: hack vault door with red laptop (requires tills + gate open)
        hacks = {
            {
                coords = vector3(-1299.680, -816.679, 16.779), heading = 308.857,
                requiredDoors = { "pulsar_mazebank_tills", "pulsar_mazebank_gate" },
                doorId = 1,
                doorConfig = { object = `v_ilev_cbankvauldoor01`, step = 0.8, originalHeading = 306.902 },
                config = { countdown = 3, timer = { 1700, 2400 }, limit = 20000, difficulty = 4, chances = 6, isShuffled = false, anim = false },
            },
        },

        -- STEP 4: lockpick individual office doors (requires mazebank_offices unlocked first)
        officeDoors = {
            { coords = vector3(-1300.430, -831.591, 17.075), door = "pulsar_mazebank_office_1", requiredDoors = { "mazebank_offices" } },
            { coords = vector3(-1297.972, -834.860, 17.075), door = "pulsar_mazebank_office_2", requiredDoors = { "mazebank_offices" } },
            { coords = vector3(-1292.914, -841.591, 17.075), door = "pulsar_mazebank_office_3", requiredDoors = { "mazebank_offices" } },
        },

        -- STEP 5: hack office PCs to loot desks (each desk requires its office door)
        desks = {
            { coords = vector3(-1296.43, -827.92, 17.07), length = 1.2, width = 3.0, options = { heading = 306, minZ = 16.07, maxZ = 17.87 }, requiredDoors = { "pulsar_mazebank_offices", "pulsar_mazebank_office_1" }, data = { deskId = 1 } },
            { coords = vector3(-1293.37, -832.03, 17.07), length = 1.2, width = 3.0, options = { heading = 307, minZ = 16.07, maxZ = 17.87 }, requiredDoors = { "pulsar_mazebank_offices", "pulsar_mazebank_office_2" }, data = { deskId = 2 } },
            { coords = vector3(-1287.19, -837.78, 17.07), length = 1.2, width = 3.0, options = { heading = 307, minZ = 16.07, maxZ = 17.87 }, requiredDoors = { "pulsar_mazebank_offices", "pulsar_mazebank_office_3" }, data = { deskId = 3 } },
        },

        -- STEP 6: drill vault walls to breach the vault
        drillPoints = {
            { coords = vector3(-1293.04, -816.81, 16.78), length = 0.6, width = 2.0, options = { heading = 308, minZ = 16.58, maxZ = 18.18 }, data = { wallId = 1 } },
            { coords = vector3(-1291.2,  -818.81, 16.78), length = 0.8, width = 1.8, options = { heading = 305, minZ = 16.38, maxZ = 18.18 }, data = { wallId = 2 } },
            { coords = vector3(-1291.28, -820.56, 16.78), length = 2.0, width = 0.6, options = { heading = 306, minZ = 16.18, maxZ = 18.18 }, data = { wallId = 3 } },
            { coords = vector3(-1293.2,  -821.57, 16.78), length = 1.8, width = 0.8, options = { heading = 307, minZ = 16.58, maxZ = 17.78 }, data = { wallId = 4 } },
            { coords = vector3(-1294.69, -821.32, 16.78), length = 0.2, width = 1.6, options = { heading = 308, minZ = 16.58, maxZ = 17.98 }, data = { wallId = 5 } },
            { coords = vector3(-1296.16, -819.15, 16.78), length = 0.4, width = 1.8, options = { heading = 308, minZ = 16.58, maxZ = 17.98 }, data = { wallId = 6 } },
        },

        polyZone = {
            vertices = {
                vector2(-1305.3043212891, -832.20843505859), vector2(-1313.142578125,  -837.57971191406),
                vector2(-1322.0520019531, -826.35705566406), vector2(-1320.9718017578, -825.19079589844),
                vector2(-1311.0677490234, -817.70617675781), vector2(-1297.9323730469, -808.08953857422),
                vector2(-1290.2984619141, -818.11029052734), vector2(-1290.3094482422, -820.55517578125),
                vector2(-1284.7360839844, -828.54858398438), vector2(-1288.2290039062, -831.19177246094),
                vector2(-1283.6013183594, -838.04913330078), vector2(-1294.6595458984, -846.15374755859),
            },
            options = {},
        },

        -- (police): secure the bank to end the heist
        secureZone = {
            coords  = vector3(-1301.14, -826.27, 16.78),
            length  = 1.4, width = 0.6,
            options = { heading = 37, minZ = 15.78, maxZ = 17.38 },
        },
    },

    -- PALETO
    paleto = {
        serverStartWait = 1000 * 60 * math.random(60, 120),
        requiredPolice  = 0,
        resetTime       = 60 * 60 * 8,

        -- boundary / always-active (not robbery steps, referenced by the system)
        polyZone = {
            vector2(-129.5386505127, 6470.3793945312),
            vector2(-103.76642608643, 6444.1923828125),
            vector2(-82.150863647461, 6466.1552734375),
            vector2(-107.7488861084, 6491.7861328125),
        },

        powerCircle = {
            center  = vector3(-169.13, 6296.62, 31.49),
            radius  = 1000.0,
            options = { useZ = false },
        },

        -- kill zones: active while their respective door is locked; player is tp'd out if entered
        killZones = {
            { coords = vector3(-104.65, 6460.56, 31.63), length = 4.8, width = 4.8, options = { heading = 315, minZ = 30.63, maxZ = 33.43 }, data = { isDeath = true, tpCoords = vector3(-113.465, 6460.281, 31.468), door = "pulsar_bank_savings_paleto_office_1" } },
            { coords = vector3(-97.26, 6467.69, 31.63), length = 4.8, width = 4.8, options = { heading = 315, minZ = 30.63, maxZ = 33.23 }, data = { isDeath = true, tpCoords = vector3(-113.465, 6460.281, 31.468), door = "pulsar_bank_savings_paleto_office_2" } },
            { coords = vector3(-105.54, 6477.56, 31.63), length = 6.0, width = 4.8, options = { heading = 45,  minZ = 30.63, maxZ = 33.43 }, data = { isDeath = true, tpCoords = vector3(-113.465, 6460.281, 31.468), door = "pulsar_bank_savings_paleto_office_3" } },
            { coords = vector3(-98.41, 6461.68, 31.63), length = 4.65,width = 5.4, options = { heading = 315, minZ = 30.63, maxZ = 33.63 }, data = { isDeath = true, tpCoords = vector3(-113.465, 6460.281, 31.468), door = "pulsar_bank_savings_paleto_vault"    } },
            { coords = vector3(-93.12, 6465.23, 31.63), length = 7.0, width = 3.6, options = { heading = 315, minZ = 30.63, maxZ = 33.23 }, data = { isDeath = true, tpCoords = vector3(-113.465, 6460.281, 31.468), door = "pulsar_bank_savings_paleto_security"  } },
        },

        -- all door IDs managed by the heist (used for reset checks)
        doorIds = {
            "pulsar_bank_savings_paleto_office_1",
            "pulsar_bank_savings_paleto_office_2",
            "pulsar_bank_savings_paleto_office_3",
            "pulsar_bank_savings_paleto_corridor_1",
            "pulsar_bank_savings_paleto_corridor_2",
            "pulsar_bank_savings_paleto_security",
            "pulsar_bank_savings_paleto_back_1",
            "pulsar_bank_savings_paleto_back_2",
            "pulsar_bank_savings_paleto_gate",
            "pulsar_bank_savings_paleto_vault",
        },

        -- doors the security panel unlocks; requireCode=true means players need an access code
        doorsGarbage = {
            { doorId = "pulsar_bank_savings_paleto_corridor_1", label = "Tellers",          requireCode = false, data = { id = 1, door = "pulsar_bank_savings_paleto_corridor_1" } },
            { doorId = "pulsar_bank_savings_paleto_corridor_2", label = "Security Hallway", requireCode = false, data = { id = 2, door = "pulsar_bank_savings_paleto_corridor_2" } },
            { doorId = "pulsar_bank_savings_paleto_office_1",   label = "Office #1",        requireCode = true,  data = { id = 3, officeId = 1, door = "pulsar_bank_savings_paleto_office_1" } },
            { doorId = "pulsar_bank_savings_paleto_office_2",   label = "Office #2",        requireCode = true,  data = { id = 4, officeId = 2, door = "pulsar_bank_savings_paleto_office_2" } },
            { doorId = "pulsar_bank_savings_paleto_office_3",   label = "Office #3",        requireCode = true,  data = { id = 5, officeId = 3, door = "pulsar_bank_savings_paleto_office_3" } },
        },

        -- STEP 1: hack all 4 remote PCs to install the exploit (adv_electronics_kit)
        --  each entry is a large polyzone the player walks into; the target sub-table is
        --  the precise ox_target box that appears inside it for the "Upload Exploit" interaction
        pcHackAreas = {
            { coords = vector3(-179.37, 6148.54, 42.64), length = 10.2, width = 21.2, options = { heading = 315, minZ = 41.64, maxZ = 47.64 }, data = { pcId = 1 }, target = { coords = vector3(-179.37, 6148.54, 42.64), length = 1.2, width = 1.2, options = { heading = 315, minZ = 41.64, maxZ = 44.64 } } },
            { coords = vector3(432.57, 6465.72, 35.78),  length = 27.1, width = 8.4,  options = { heading = 230, minZ = 34.78, maxZ = 38.78 }, data = { pcId = 2 }, target = { coords = vector3(432.57,  6465.72, 35.78),  length = 1.2, width = 1.2, options = { heading = 230, minZ = 34.78, maxZ = 37.78 } } },
            { coords = vector3(-2174.1, 4290.36, 49.05), length = 9.6,  width = 7.6,  options = { heading = 326, minZ = 48.05, maxZ = 50.45 }, data = { pcId = 3 }, target = { coords = vector3(-2174.1, 4290.36, 49.05), length = 1.2, width = 1.2, options = { heading = 326, minZ = 48.05, maxZ = 51.05 } } },
            { coords = vector3(3616.07, 5024.11, 11.45), length = 7.6,  width = 9.0,  options = { heading = 290, minZ = 10.45, maxZ = 13.65 }, data = { pcId = 4 }, target = { coords = vector3(3616.07, 5024.11, 11.45), length = 1.2, width = 1.2, options = { heading = 290, minZ = 10.45, maxZ = 13.45 } } },
        },

        -- STEP 2: destroy remote substations with thermite to begin cutting power
        --  subStations = thermite placement + explosion points for each substation
        --  subStationZones = player detection polyzones around each substation
        subStations = {
            { id = 1, thermite = { coords = vector3(2586.039, 5065.303, 45.04548), heading = 197.966 }, explosions = { vector3(2593.786, 5060.913, 45.546), vector3(2587.667, 5058.760, 45.743), vector3(2592.805, 5064.298, 45.285) } },
            { id = 2, thermite = { coords = vector3(1353.959, 6386.733, 33.19492), heading = 90.234  }, explosions = { vector3(1349.453, 6380.395, 34.416), vector3(1349.467, 6387.196, 33.801), vector3(1341.865, 6386.671, 33.874), vector3(1341.857, 6380.379, 34.431) } },
            { id = 3, thermite = { coords = vector3(-288.9897, 6027.154, 31.55255), heading = 133.697 }, explosions = { vector3(-293.155, 6021.172, 32.111), vector3(-289.357, 6017.341, 32.062), vector3(-287.331, 6021.060, 31.930), vector3(-290.942, 6024.837, 32.593) } },
            { id = 4, thermite = { coords = vector3(239.3452, 6405.226, 31.8286), heading = 111.934  }, explosions = { vector3(235.663, 6403.994, 32.199), vector3(237.823, 6398.830, 32.178), vector3(233.731, 6396.820, 32.259), vector3(231.195, 6402.163, 32.031), vector3(228.429, 6399.177, 31.395), vector3(229.807, 6395.989, 31.771) } },
        },

        subStationZones = {
            { coords = vector3(2589.08, 5060.17, 44.92), length = 20.4, width = 21.2, options = { heading = 16,  minZ = 43.92, maxZ = 51.52 }, data = { subStationId = 1 } },
            { coords = vector3(1346.19, 6383.21, 33.41), length = 34.6, width = 25.2, options = { heading = 0,   minZ = 32.41, maxZ = 39.21 }, data = { subStationId = 2 } },
            { coords = vector3(-288.54, 6019.09, 31.55), length = 20.2, width = 14.6, options = { heading = 45,  minZ = 30.55, maxZ = 35.55 }, data = { subStationId = 3 } },
            { coords = vector3(234.31, 6402.54, 31.65), length = 19.8, width = 27.6, options = { heading = 26,  minZ = 30.65, maxZ = 35.45 }, data = { subStationId = 4 } },
        },

        -- STEP 3: hack the 4 power interface boxes around the map (adv_electronics_kit)
        -- completing all substations + all boxes triggers IsPaletoPowerDisabled() = gate opens + lasers off
        powerHacks = {
            { coords = vector3(-442.17, 5602.08, 68.38), length = 0.6, width = 1.0, options = { heading = 4,   minZ = 67.98, maxZ = 69.78 }, data = { boxId = 1, ptFxPoint = vector3(-442.168, 5601.922, 68.80035) } },
            { coords = vector3(8.99, 6221.59, 31.47), length = 0.4, width = 0.8, options = { heading = 28,  minZ = 30.87, maxZ = 32.67 }, data = { boxId = 2, ptFxPoint = vector3(8.950461, 6221.659, 31.73336) } },
            { coords = vector3(2872.15, 4869.36, 62.29), length = 1.0, width = 0.6, options = { heading = 31,  minZ = 62.09, maxZ = 63.69 }, data = { boxId = 3, ptFxPoint = vector3(2872.163, 4869.374, 62.93316) } },
            { coords = vector3(-83.59, 6131.98, 30.46), length = 1.2, width = 0.6, options = { heading = 319, minZ = 30.26, maxZ = 32.26 }, data = { boxId = 4, ptFxPoint = vector3(-83.68681, 6132,     31.04742) } },
        },

        -- STEP 4 (cont.): workstation inside the bank — accessible once gate opens (power disabled)
        -- hackAccessBox is the polyzone that sets inPaletoWSPoint; workstation targets are below
        hackAccessBox = {
            coords  = vector3(-107.04, 6474.16, 31.63),
            length  = 1.8, width = 1.2,
            options = { heading = 315, minZ = 30.63, maxZ = 32.63 },
        },

        -- STEP 5: breach the back of the bank (requires exploits + power disabled)
        --   thermite the two back doors, then use door hacks / lockpick / security power to get inside
        doorThermite = {
            { coords = vector3(-97.33757, 6475.071, 31.50123), heading = 136.012, door = "pulsar_bank_savings_paleto_back_1", requiredDoors = {} },
            { coords = vector3(-118.7633, 6477.372, 31.57678), heading = 221.941, door = "pulsar_bank_savings_paleto_back_2", requiredDoors = {}, requireExploit = false },
        },

        lockpickPoints = {
            { coords = vector3(-111.549, 6468.489, 31.634), door = "" },
        },

        hackPoints = {
            { coords = vector3(-102.342, 6463.234, 31.634), heading = 224.469, door = "pulsar_bank_savings_paleto_vault", requiredDoors = {} },
        },

        doorHacks = {
            { coords = vector3(-97.26, 6475.09, 31.3),  length = 0.6, width = 0.4, options = { heading = 46,  minZ = 30.7,  maxZ = 32.5  } },
            { coords = vector3(-118.76, 6477.38, 31.57), length = 1.0, width = 0.6, options = { heading = 317, minZ = 30.37, maxZ = 32.77 } },
        },

        securityPower = {
            { coords = vector3(-118.4007, 6470.696, 31.65586), heading = 137.899, powerId = 1, requiredDoors = { "pulsar_bank_savings_paleto_back_2" }, ptfx = { vector3(-118.3559, 6470.742, 32.59674), vector3(-118.112, 6470.457, 31.36404) } },
            { coords = vector3(-92.64053, 6469.752, 31.7244),  heading = 319.835, powerId = 2, requiredDoors = { "pulsar_bank_savings_paleto_back_1" }, ptfx = { vector3(-92.68832, 6469.708, 32.62043), vector3(-92.9099, 6469.972, 31.36724)  } },
        },

        -- lasers inside the vault corridor; active until power is disabled (IsPaletoPowerDisabled)
        lasers = {
            { origins = vec3(-101.190002, 6467.169922, 33.935001), targets = { vec3(-101.503998, 6463.251953, 30.646000), vec3(-100.108002, 6464.666016, 30.634001), vec3(-104.019997, 6464.421875, 30.634001) }, options = { travelTimeBetweenTargets = { 1.0, 1.0 }, waitTimeAtTargets = { 0.0, 0.0 }, randomTargetSelection = true, name = "paleto1" } },
            { origins = vec3(-104.024002, 6464.348145, 33.953999), targets = { vec3(-100.125999, 6464.629883, 30.643999), vec3(-101.486000, 6463.270020, 30.635000), vec3(-101.257004, 6467.187012, 30.634001) }, options = { travelTimeBetweenTargets = { 1.0, 1.0 }, waitTimeAtTargets = { 0.0, 0.0 }, randomTargetSelection = true, name = "paleto2" } },
            { origins = vec3(-102.140999, 6462.520996, 33.980000), targets = { vec3(-103.057999, 6465.428223, 30.634001), vec3(-102.267998, 6466.155762, 30.634001), vec3(-99.417999, 6465.327148, 30.634001), vec3(-102.188004, 6462.559082, 30.634001), vec3(-104.000999, 6464.437988, 30.634001), vec3(-101.267998, 6467.199219, 30.634001) }, options = { travelTimeBetweenTargets = { 1.0, 1.0 }, waitTimeAtTargets = { 0.0, 0.0 }, randomTargetSelection = true, name = "paleto3" } },
            { origins = vec3(-99.348999, 6465.328125, 34.018002),  targets = { vec3(-102.271004, 6466.204102, 30.634001), vec3(-103.042999, 6465.412109, 30.634001), vec3(-102.177002, 6462.564941, 30.634001), vec3(-101.299004, 6467.194824, 30.634001), vec3(-99.428001, 6465.315918, 30.634001), vec3(-101.489998, 6463.266113, 30.635000), vec3(-100.100998, 6464.654785, 30.643999) }, options = { travelTimeBetweenTargets = { 1.0, 1.0 }, waitTimeAtTargets = { 0.0, 0.0 }, randomTargetSelection = true, name = "paleto4" } },
        },

        -- STEP 6: office hacks — upload exploit to each office computer to unlock its door (adv_electronics_kit + vpn)
        officeHacks = {
            { coords = vector3(-103.82, 6460.55, 31.63), length = 1.4, width = 0.8, options = { heading = 314, minZ = 30.63, maxZ = 32.63 }, data = { door = "pulsar_bank_savings_paleto_office_1", officeId = 1 } },
            { coords = vector3(-98.16, 6466.24, 31.63), length = 1.4, width = 0.8, options = { heading = 315, minZ = 30.63, maxZ = 32.43 }, data = { door = "pulsar_bank_savings_paleto_office_2", officeId = 2 } },
            { coords = vector3(-104.85, 6479.08, 31.63), length = 1.4, width = 0.8, options = { heading = 317, minZ = 28.43, maxZ = 32.43 }, data = { door = "pulsar_bank_savings_paleto_office_3", officeId = 3 } },
        },

        -- STEP 6 (continued): search desks inside each office once its door is unlocked
        officeSearch = {
            { coords = vector3(-103.98, 6458.19, 31.63), length = 2.2, width = 0.8, options = { heading = 315, minZ = 30.63, maxZ = 32.23 }, data = { door = "pulsar_bank_savings_paleto_office_1", searchId = 1 } },
            { coords = vector3(-106.94, 6460.9,  31.63), length = 1.8, width = 0.6, options = { heading = 315, minZ = 30.63, maxZ = 32.23 }, data = { door = "pulsar_bank_savings_paleto_office_1", searchId = 2 } },
            { coords = vector3(-94.96, 6467.06, 31.63), length = 2.2, width = 0.8, options = { heading = 315, minZ = 30.63, maxZ = 32.23 }, data = { door = "pulsar_bank_savings_paleto_office_2", searchId = 3 } },
            { coords = vector3(-97.89, 6470.08, 31.63), length = 1.8, width = 0.6, options = { heading = 315, minZ = 30.63, maxZ = 32.23 }, data = { door = "pulsar_bank_savings_paleto_office_2", searchId = 4 } },
            { coords = vector3(-108.29, 6478.6,  31.63), length = 2.2, width = 0.8, options = { heading = 315, minZ = 30.63, maxZ = 32.23 }, data = { door = "pulsar_bank_savings_paleto_office_3", searchId = 5 } },
            { coords = vector3(-102.78, 6476.56, 31.63), length = 2.4, width = 0.6, options = { heading = 315, minZ = 30.63, maxZ = 32.23 }, data = { door = "pulsar_bank_savings_paleto_office_3", searchId = 6 } },
        },

        -- STEP 7: drill the vault door (requires exploit installed + vault door unlocked)
        drillPoints = {
            { coords = vector3(-97.61, 6464.32, 31.63), length = 0.6, width = 1.2, options = { heading = 315, minZ = 30.83, maxZ = 33.23 }, data = { drillId = 1 } },
            { coords = vector3(-95.85, 6462.88, 31.63), length = 0.6, width = 1.2, options = { heading = 315, minZ = 30.83, maxZ = 33.23 }, data = { drillId = 2 } },
            { coords = vector3(-95.7, 6460.14, 31.63), length = 0.6, width = 1.2, options = { heading = 45,  minZ = 30.83, maxZ = 33.23 }, data = { drillId = 3 } },
            { coords = vector3(-97.03, 6458.83, 31.63), length = 0.6, width = 1.2, options = { heading = 45,  minZ = 30.83, maxZ = 33.23 }, data = { drillId = 4 } },
            { coords = vector3(-99.41, 6458.79, 31.63), length = 0.6, width = 1.2, options = { heading = 315, minZ = 30.83, maxZ = 33.23 }, data = { drillId = 5 } },
            { coords = vector3(-100.33, 6459.83, 31.63), length = 0.6, width = 1.2, options = { heading = 315, minZ = 30.83, maxZ = 33.23 }, data = { drillId = 6 } },
            { coords = vector3(-101.47, 6461.05, 31.63), length = 0.6, width = 1.2, options = { heading = 315, minZ = 30.83, maxZ = 33.23 }, data = { drillId = 7 } },
        },

        -- ox_target interaction zones (step labels in comments)
        targets = {
            -- step 2: breach network terminal (adv_electronics_kit + vpn, requires all 4 exploits)
            workstation = {
                coords  = vector3(-106.12, 6473.87, 31.63),
                length  = 1.2, width = 0.6,
                options = { heading = 315, minZ = 31.03, maxZ = 32.43 },
            },
            -- step 5: security panel — controls internal doors (requires exploit + gate unlocked)
            security = {
                coords  = vector3(-91.76, 6464.78, 31.63),
                length  = 1.4, width = 0.8,
                options = { heading = 315, minZ = 30.63, maxZ = 32.43 },
            },
            -- step 6: office #3 safe — crack safe (paleto_access_codes item, requires office 3 door)
            officeSafe = {
                coords  = vector3(-105.27, 6480.67, 31.63),
                length  = 0.8, width = 0.6,
                options = { heading = 45, minZ = 31.43, maxZ = 32.83 },
            },
            -- police only: secure the bank after a robbery
            secure = {
                coords  = vector3(-109.57, 6461.51, 31.64),
                length  = 0.6, width = 0.4,
                options = { heading = 315, minZ = 31.24, maxZ = 32.84 },
            },
        },
    },

    -- VANGELICO
    vangelico = {
        serverStartWait = 1000 * 60 * math.random(60, 70), -- ms delay after server boot
        requiredPolice  = 0,                                -- minimum on-duty police

        -- STEP 1: smash jewelry cases with a melee weapon to collect loot
        cases = {
            { coords = vector3(-626.36, -239.02, 38.06), length = 0.6, width = 1.2, options = { heading = 36,  minZ = 37.46, maxZ = 38.66 } },
            { coords = vector3(-625.29, -238.26, 38.06), length = 0.6, width = 1.2, options = { heading = 36,  minZ = 37.46, maxZ = 38.66 } },
            { coords = vector3(-627.19, -234.94, 38.06), length = 0.6, width = 1.2, options = { heading = 36,  minZ = 37.46, maxZ = 38.66 } },
            { coords = vector3(-626.15, -234.16, 38.06), length = 0.6, width = 1.2, options = { heading = 36,  minZ = 37.46, maxZ = 38.66 } },
            { coords = vector3(-626.58, -233.58, 38.06), length = 0.6, width = 1.2, options = { heading = 36,  minZ = 37.46, maxZ = 38.66 } },
            { coords = vector3(-627.63, -234.33, 38.06), length = 0.6, width = 1.2, options = { heading = 36,  minZ = 37.46, maxZ = 38.66 } },
            { coords = vector3(-619.87, -234.89, 38.06), length = 0.6, width = 1.2, options = { heading = 36,  minZ = 37.46, maxZ = 38.66 } },
            { coords = vector3(-618.83, -234.12, 38.06), length = 0.6, width = 1.2, options = { heading = 36,  minZ = 37.46, maxZ = 38.66 } },
            { coords = vector3(-620.49, -232.93, 38.06), length = 0.6, width = 1.2, options = { heading = 36,  minZ = 37.46, maxZ = 38.66 } },
            { coords = vector3(-623.67, -228.57, 38.06), length = 0.6, width = 1.2, options = { heading = 36,  minZ = 37.46, maxZ = 38.66 } },
            { coords = vector3(-625.31, -227.4,  38.06), length = 0.6, width = 1.2, options = { heading = 36,  minZ = 37.46, maxZ = 38.66 } },
            { coords = vector3(-624.01, -230.75, 38.06), length = 0.6, width = 1.2, options = { heading = 306, minZ = 37.46, maxZ = 38.66 } },
            { coords = vector3(-622.63, -232.58, 38.06), length = 0.6, width = 1.2, options = { heading = 306, minZ = 37.46, maxZ = 38.66 } },
            { coords = vector3(-621.47, -228.92, 38.06), length = 0.6, width = 1.2, options = { heading = 306, minZ = 37.46, maxZ = 38.66 } },
            { coords = vector3(-620.16, -230.76, 38.06), length = 0.6, width = 1.2, options = { heading = 306, minZ = 37.46, maxZ = 38.66 } },
            { coords = vector3(-617.12, -230.19, 38.06), length = 0.6, width = 1.2, options = { heading = 306, minZ = 37.46, maxZ = 38.66 } },
            { coords = vector3(-617.89, -229.12, 38.06), length = 0.6, width = 1.2, options = { heading = 306, minZ = 37.46, maxZ = 38.66 } },
            { coords = vector3(-619.26, -227.27, 38.06), length = 0.6, width = 1.2, options = { heading = 306, minZ = 37.46, maxZ = 38.66 } },
        },

        -- (police): secure the store to reset it; loot drawn per case smashed
        loot = {
            { 8,  { name = "rolex",    min = 5,  max = 12 } },
            { 20, { name = "watch",    min = 8,  max = 14 } },
            { 30, { name = "chain",    min = 8,  max = 16 } },
            { 25, { name = "ring",     min = 10, max = 20 } },
            { 25, { name = "earrings", min = 10, max = 22 } },
        },
    },

    -- MONEYTRUCK
    moneytruck = {
        spawnRate = 1000 * 60 * 60 * 2, -- ms; how long before a spawned truck is deleted

        loot = {
            fleeca = {
                { 60, { name = "moneyroll", min = 160, max = 210 } },
                { 25, { name = "moneyband", min = 16,  max = 21  } },
                { 15, { name = "moneybag",  min = 1,   max = 3   } },
            },
            bobcat = {
                { 60, { name = "moneyroll", min = 190, max = 230 } },
                { 25, { name = "moneyband", min = 19,  max = 23  } },
                { 15, { name = "moneybag",  min = 1,   max = 3   } },
            },
        },

        -- pool of world positions trucks can spawn at; depleted sequentially, refilled when empty
        spawnHolding = {
            vector4(855.208, -2306.472, 30.346, 175.001), vector4(981.240, -2508.671, 28.302, 353.925),
            vector4(690.640, -2287.796, 28.089, 355.932), vector4(733.442, -1907.685, 29.292, 174.127),
            vector4(837.710, -1990.537, 29.301,  81.766), vector4(909.788, -1519.038, 30.590, 267.368),
            vector4(222.403, 1255.156, 225.460,  12.525), vector4(-61.567, 1960.274,190.186, 296.237),
            vector4(810.427, 2154.283, 52.278, 155.035), vector4(1225.317, 2745.066, 38.006,  86.496),
            vector4(2003.305, 3039.629, 47.215, 327.551), vector4(2659.275, 3277.859, 55.241, 310.082),
            vector4(1643.865, 4838.119, 42.028,   5.168), vector4(1977.816, 5170.238, 47.639, 311.102),
            vector4(-664.951, 5820.383, 17.331, 246.640), vector4(-316.341, 6313.394, 32.287, 227.753),
            vector4(67.027, 6306.323, 31.239, 297.784), vector4(427.864, 6469.139, 28.785, 227.899),
            vector4(1870.702, 6408.105, 46.566, 292.889), vector4(1428.166, 6348.081, 23.985,  67.333),
            vector4(2890.848, 4381.497, 50.337, 110.257), vector4(590.198, 608.871,128.911, 115.103),
            vector4(1037.606, -129.035, 74.189,  54.630), vector4(-20.035, -224.632, 46.176, 340.416),
            vector4(39.552, -381.556, 39.921,  70.484), vector4(231.276, -8.360, 73.615, 247.305),
            vector4(454.992, 212.942,103.101, 248.137), vector4(713.750, 250.600, 93.125, 239.612),
            vector4(848.769, 511.266,125.919, 159.235), vector4(1221.754, 365.209, 81.991, 330.920),
            vector4(580.384, 130.427, 98.041, 342.991), vector4(180.276, 305.306,105.374,  91.564),
            vector4(1278.336, 1924.527, 82.058,  37.980), vector4(837.738, 2130.094, 52.298, 168.306),
            vector4(738.472,  2533.734, 73.164,  93.708), vector4(576.480, 2798.457, 42.103, 100.108),
            vector4(1728.332, 3318.403, 41.223,  18.286), vector4(2356.620, 4893.210, 42.064, 223.946),
            vector4(1378.120, 4308.063, 37.136, 303.243), vector4(344.629, 3389.860, 36.416, 110.597),
            vector4(1913.799, 3900.549, 32.607,  52.463), vector4(2466.083, 4105.216, 38.065, 155.136),
        },
    },

    -- STORE
    store = {
        serverStartWait = 10 * 60 * math.random(60, 70), -- ms delay after server boot
        requiredPolice  = 0,                              -- no police minimum for store robberies

        items = {
            register   = "lockpick",
            safeCrack  = "safecrack_kit",
            sequencer  = "sequencer",
        },

        locations = {
            store1  = { id = "store1",  coords = vector3(-48.59, -1751.52,  29.42), width = 14.6, length = 13.4, options = { heading = 50,  minZ = 28.42, maxZ = 31.82 } },
            store2  = { id = "store2",  coords = vector3(-1826.95, 792.96, 138.22), width = 14.6, length = 13.4, options = { heading = 43,  minZ = 137.22,maxZ = 140.22} },
            store3  = { id = "store3",  coords = vector3(-711.93, -909.84,  19.22), width = 14.6, length = 13.4, options = { heading = 0,   minZ = 18.22, maxZ = 21.22 } },
            store4  = { id = "store4",  coords = vector3(1704.21, 4925.27,  42.06), width = 14.6, length = 13.4, options = { heading = 324, minZ = 41.06, maxZ = 43.06 } },
            store5  = { id = "store5",  coords = vector3(2676.53, 3286.28,  55.24), width = 14.6, length = 13.4, options = { heading = 330, minZ = 54.24, maxZ = 57.24 } },
            store6  = { id = "store6",  coords = vector3(1734.64, 6417.04,  35.04), width = 14.6, length = 13.4, options = { heading = 333, minZ = 34.04, maxZ = 37.04 } },
            store7  = { id = "store7",  coords = vector3(544.53, 2666.06,  42.16), width = 14.6, length = 13.4, options = { heading = 6,   minZ = 41.16, maxZ = 44.16 } },
            store8  = { id = "store8",  coords = vector3(1962.25, 3746.62,  32.34), width = 14.6, length = 13.4, options = { heading = 28,  minZ = 31.34, maxZ = 34.34 } },
            store9  = { id = "store9",  coords = vector3(29.65, -1342.67,  29.5),  width = 14.6, length = 13.4, options = { heading = 0,   minZ = 28.5,  maxZ = 31.5  } },
            store10 = { id = "store10", coords = vector3(378.72, 329.66, 103.57), width = 14.6, length = 13.4, options = { heading = 346, minZ = 102.57,maxZ = 105.57} },
            store11 = { id = "store11", coords = vector3(-3044.97, 588.05,   7.91), width = 14.6, length = 13.4, options = { heading = 19,  minZ = 6.91,  maxZ = 9.91  } },
            store12 = { id = "store12", coords = vector3(-3246.45, 1005.58,  12.83), width = 14.6, length = 13.4, options = { heading = 357, minZ = 11.83, maxZ = 14.83 } },
            store13 = { id = "store13", coords = vector3(2552.78, 386.17, 108.62), width = 14.6, length = 13.4, options = { heading = 359, minZ = 107.62,maxZ = 110.62} },
            store14 = { id = "store14", coords = vector3(1159.1, -319.31,  69.21), width = 14.6, length = 13.4, options = { heading = 280, minZ = 68.21, maxZ = 71.21 } },
            store15 = { id = "store15", coords = vector3(297.268, -1266.357, 28.518),width = 14.6, length = 13.4, options = { heading = 181, minZ = 28.518,maxZ = 31.518} },
            store16 = { id = "store16", coords = vector3(165.77, 6641.32,  31.7),  width = 13.4, length = 11.6, options = { heading = 315, minZ = 30.5,  maxZ = 34.1  } },
        },

        safes = {
            { id = "safe1",  coords = vector3(1962.1, 3750.45, 32.34), width = 0.4, length = 1.2, options = { heading = 30,  minZ = 31.94, maxZ = 33.74 }, data = { id = 1,  coords = vector3(1962.1, 3750.45, 32.34) } },
            { id = "safe2",  coords = vector3(2674.39, 3289.41, 55.24), width = 0.4, length = 1.2, options = { heading = 60,  minZ = 54.84, maxZ = 56.64 }, data = { id = 2,  coords = vector3(2674.39, 3289.41, 55.24) } },
            { id = "safe3",  coords = vector3(1708.08, 4920.66, 42.06), width = 0.6, length = 0.4, options = { heading = 325, minZ = 40.86, maxZ = 42.06 }, data = { id = 3,  coords = vector3(1708.08, 4920.66, 42.06) } },
            { id = "safe4",  coords = vector3(1737.72, 6419.32, 35.04), width = 0.4, length = 1.2, options = { heading = 334, minZ = 34.64, maxZ = 36.44 }, data = { id = 4,  coords = vector3(1737.72, 6419.32, 35.04) } },
            { id = "safe5",  coords = vector3(171.18, 6642.34, 31.7),  width = 0.4, length = 1.2, options = { heading = 314, minZ = 31.3,  maxZ = 33.1  }, data = { id = 5,  coords = vector3(171.18, 6642.34, 31.7)  } },
            { id = "safe6",  coords = vector3(-168.74, 6319.02, 30.59), width = 0.6, length = 0.4, options = { heading = 225, minZ = 29.39, maxZ = 31.59 }, data = { id = 6,  coords = vector3(-168.74, 6319.02, 30.59) } },
            { id = "safe7",  coords = vector3(-3249.66, 1007.7,  12.83), width = 0.4, length = 1.2, options = { heading = 264, minZ = 12.43, maxZ = 14.23 }, data = { id = 7,  coords = vector3(-3249.66, 1007.7,  12.83) } },
            { id = "safe8",  coords = vector3(-3048.8, 588.78,  7.91), width = 0.4, length = 1.2, options = { heading = 289, minZ = 7.51,  maxZ = 9.31  }, data = { id = 8,  coords = vector3(-3048.8, 588.78,  7.91) } },
            { id = "safe9",  coords = vector3(-2959.62, 386.74, 14.04), width = 0.6, length = 0.4, options = { heading = 355, minZ = 12.84, maxZ = 15.04 }, data = { id = 9,  coords = vector3(-2959.62, 386.74, 14.04) } },
            { id = "safe10", coords = vector3(-1829.38, 798.6,  138.18),width = 0.6, length = 0.4, options = { heading = 313, minZ = 136.98,maxZ = 138.18}, data = { id = 10, coords = vector3(-1829.38, 798.6,  138.18)} },
            { id = "safe11", coords = vector3(543.07, 2662.48, 42.16), width = 0.4, length = 1.2, options = { heading = 6,   minZ = 41.76, maxZ = 43.36 }, data = { id = 11, coords = vector3(543.07, 2662.48, 42.16) } },
            { id = "safe12", coords = vector3(1169.57, 2717.84, 37.16), width = 0.6, length = 0.4, options = { heading = 88,  minZ = 35.96, maxZ = 38.16 }, data = { id = 12, coords = vector3(1169.57, 2717.84, 37.16) } },
            { id = "safe13", coords = vector3(2549.45, 388.22,108.62), width = 0.4, length = 1.2, options = { heading = 86,  minZ = 108.22,maxZ = 109.82}, data = { id = 13, coords = vector3(2549.45, 388.22,108.62) } },
            { id = "safe14", coords = vector3(1159.2, -314.07, 69.21), width = 0.6, length = 0.4, options = { heading = 100, minZ = 68.01, maxZ = 69.21 }, data = { id = 14, coords = vector3(1159.2, -314.07, 69.21) } },
            { id = "safe15", coords = vector3(381.37, 332.47,103.57), width = 0.4, length = 1.2, options = { heading = 346, minZ = 103.17,maxZ = 104.77}, data = { id = 15, coords = vector3(381.37, 332.47,103.57) } },
            { id = "safe16", coords = vector3(-1478.67, -375.68, 39.16), width = 0.6, length = 0.4, options = { heading = 223, minZ = 37.96, maxZ = 40.16 }, data = { id = 16, coords = vector3(-1478.67, -375.68, 39.16) } },
            { id = "safe17", coords = vector3(-1221.13, -916.19, 11.33), width = 0.6, length = 0.4, options = { heading = 123, minZ = 10.13, maxZ = 12.33 }, data = { id = 17, coords = vector3(-1478.67, -375.68, 39.16) } },
            { id = "safe18", coords = vector3(1126.75, -979.81, 45.42), width = 0.6, length = 0.4, options = { heading = 188, minZ = 44.22, maxZ = 46.42 }, data = { id = 18, coords = vector3(1126.75, -979.81, 45.42) } },
            { id = "safe19", coords = vector3(-709.99, -904.16, 19.22), width = 0.6, length = 0.4, options = { heading = 268, minZ = 18.02, maxZ = 19.22 }, data = { id = 19, coords = vector3(-709.99, -904.16, 19.22) } },
            { id = "safe20", coords = vector3(31.48, -1339.27, 29.5),  width = 0.4, length = 1.2, options = { heading = 1,   minZ = 29.1,  maxZ = 30.7  }, data = { id = 20, coords = vector3(31.48, -1339.27, 29.5)  } },
            { id = "safe21", coords = vector3(-43.62, -1748.17, 29.42), width = 0.6, length = 0.6, options = { heading = 51,  minZ = 28.22, maxZ = 29.42 }, data = { id = 21, coords = vector3(-43.62, -1748.17, 29.42) } },
            { id = "safe22", coords = vector3(302.29, -1268.55, 29.52), width = 0.4, length = 0.6, options = { heading = 269, minZ = 26.52, maxZ = 29.72 }, data = { id = 22, coords = vector3(302.29, -1268.55, 29.52) } },
        },

        registerLoot = {
            { 99, { name = "moneyroll", min = 1, max = 3 } },
            { 1,  { name = "moneyband", max = 1          } },
        },

        safeLoot = {
            { 85, { name = "moneyroll",  min = 10, max = 20 } },
            { 13, { name = "moneyband",  min = 1,  max = 3  } },
            { 2,  { name = "valuegoods", min = 1,  max = 3  } },
        },
    },

    -- ATMS
    atms = {
        maxRobberies = 15, -- max ATM hits per player per session

        -- terminal zone where players start the ATM job
        terminal = {
            ped     = vector4(699.528, -1261.740, 25.444, 180.716),
            length  = 1.2,
            width   = 1.2,
            options = { heading = 0, minZ = 25.5, maxZ = 28.5 },
        },

        -- city = true means lower-rep players can access it
        areas = {
            { coords = vector3(-1421.514, -164.651, 47.587), radius = 400.0, city = true  },
            { coords = vector3(-236.920, -862.055, 30.423), radius = 400.0, city = true  },
            { coords = vector3(-49.921, -1751.744, 29.421), radius = 400.0, city = true  },
            { coords = vector3(1099.503, 2687.090, 38.721), radius = 400.0               },
            { coords = vector3(1856.481, 3732.085, 33.137), radius = 400.0               },
            { coords = vector3(1721.703, 6405.138, 37.410), radius = 400.0               },
            { coords = vector3(-303.475, 6231.736, 38.460), radius = 400.0               },
            { coords = vector3(-974.370, -1835.689, 21.205), radius = 400.0               },
            { coords = vector3(-1116.592, 2673.240, 18.349), radius = 400.0               },
            { coords = vector3(202.766, 6616.819, 31.656), radius = 400.0               },
            { coords = vector3(1671.253, 4843.808, 42.052), radius = 400.0               },
            { coords = vector3(3.202, -920.910, 29.530), radius = 200.0, city = true },
            { coords = vector3(3.202, -920.910, 29.530), radius = 90.0,  city = true },
            { coords = vector3(-1272.29, -662.39,  15.97), radius = 150.0, city = true  },
            { coords = vector3(-1272.29, -662.39,  15.97), radius = 150.0, city = true  },
            { coords = vector3(-260.337, 173.989,  88.353), radius = 400.0, city = true },
        },

        loot = {
            { 85, { name = "moneyroll", min = 10, max = 20 } },
            { 15, { name = "moneyband", min = 1,  max = 3  } },
        },

        lootHigh = {
            { 80, { name = "moneyroll", min = 15, max = 25 } },
            { 20, { name = "moneyband", min = 1,  max = 4  } },
        },

        objects = {
            `prop_atm_01`,
            `prop_atm_02`,
            `prop_atm_03`,
            `prop_fleeca_atm`,
        },

        items = {
            terminal = "vpn",
        },

        phoneApp = {
            color = '#247919',
            label = 'Root',
            icon  = 'terminal',
        },
    },
}
