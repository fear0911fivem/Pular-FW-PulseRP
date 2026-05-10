Config = Config or {}

print("[STORAGE-CRATES] config.lua loaded")

Config.CrateTiers = {
    ["storage_box_small"] = {
        label = "Small Storage Box",
        model = `sm_prop_smug_crate_m_01a`, -- Adjust model as needed
        maxSlots = 20,
        maxWeight = 20000, -- 20kg in grams
    },
    ["storage_box_medium"] = {
        label = "Medium Storage Box",
        model = `v_res_tre_storagebox`,
        maxSlots = 30,
        maxWeight = 35000, -- 35kg
    },
    ["storage_box_large"] = {
        label = "Large Storage Box",
        model = `xm_prop_rsply_crate04b`, 
        maxSlots = 50,
        maxWeight = 50000, -- 50kg
    },
}

-- Lockpick configuration
Config.LockpickItem = {"lockpick", "adv_lockpick"} -- Change to your lockpick item name
Config.LockpickBreakChance = 0.3 -- 30% chance to break on fail
Config.LockpickMinigameTime = 5000 -- 5 seconds for minigame
Config.LockpickProgressTime = 10000 -- 10 seconds for progress bar
-- Circle (round) minigame tuning:
-- - rate: higher = faster (harder)
-- - difficulty: percent window size (lower = harder). Minimum enforced by pulsar-games is 2.
-- Regular lockpick (harder)
Config.LockpickRoundRate = 1.6 -- Faster = harder
Config.LockpickRoundDifficulty = 3 -- Lower = harder
-- Advanced lockpick (easier)
Config.AdvLockpickRoundRate = 1.2 -- Slower = easier
Config.AdvLockpickRoundDifficulty = 6 -- Higher = easier

-- Placement settings
Config.PlacementDistance = 2.0 -- Max distance to place from player
Config.MinPlacementHeight = -50.0 -- Prevent placing in void
Config.MaxPlacementHeight = 1000.0 -- Prevent placing too high

