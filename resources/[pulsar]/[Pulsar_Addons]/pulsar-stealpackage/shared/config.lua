SRPStealPackage = {}

local Config = SRPStealPackage

Config.Debug = false
Config.StateBagName = 'srpObjectToVehicle'

Config.Text = {
    breakWindow = 'Break Window',
    steal = 'Steal Package',
    searchKeybindDescription = 'Search the vehicle for valuables.',
    searchTextUI = '{keybind}%s{/keybind} Search for valuables',
    progressSearch = 'Searching for valuables...',
    notInsideVehicle = 'You need to be inside a vehicle.',
    vehicleOwned = 'You can only do this on local vehicles.',
    vehicleCannotBeSearched = 'This vehicle cannot be searched anymore.',
    alreadySearched = 'This vehicle has already been searched.',
    searchNothing = 'You found nothing valuable.',
    packageMissing = 'The package is no longer here.',
    packageBusy = 'Someone is already handling this package.',
    packageStolen = 'You stole the package.',
    foundItem = 'You found %sx %s.',
    addFailed = 'You do not have enough inventory space.',
    tooFar = 'You are too far away from the vehicle.',
    breakWindowDamage = 'You cut yourself on the broken glass. (-%s HP)',
}

Config.Package = {
    item = 'pachetfurat',
    models = {
        `ch_prop_ch_bag_01a`,
        `xm3_prop_xm3_backpack_01a`,
    },
    maxInteractDistance = 6.0,
    expiresAfter = 45 * 60,
    vehicleCooldown = 60 * 60,
    maxActive = 24,
    scanInterval = 45 * 1000,
    spawnChance = 100,
    maxPlayerDistance = 220.0,
    policeAlertChance = 20,
    stress = 3,
    seatPriorities = {
        { 1, 2, 3 },
        { 2, 1, 3 },
        { 3, 1, 2 },
    },
    modelMap = {
        [`ch_prop_ch_bag_01a`] = {
            offset = vector3(0.0, -0.02, 0.02),
            rotation = vector3(0.0, 0.0, 90.0),
        },
        [`xm3_prop_xm3_backpack_01a`] = {
            offset = vector3(0.0, -0.03, 0.01),
            rotation = vector3(0.0, 0.0, 180.0),
        },
    },
}

Config.BreakWindow = {
    maxDistance = 8.0,
    cooldown = 5,
    handDamage = 10,
    damageBypassWeapons = {
        [`WEAPON_CROWBAR`] = true,
    },
    policeAlertChance = 12,
    stress = 1,
}

Config.Search = {
    keybind = 'srp_vehicle_search',
    key = 'M',
    duration = 4500,
    cooldown = 25 * 60,
    sourceCooldown = 4,
    policeAlertChance = 8,
    stress = 1,
    nothingWeight = 45,
    loot = {
        { weight = 46, item = 'moneyroll', min = 1, max = 8 },
        { weight = 18, item = 'ring', min = 1, max = 1 },
        { weight = 15, item = 'watch', min = 1, max = 1 },
        { weight = 10, item = 'chain', min = 1, max = 1 },
        { weight = 7, item = 'rolex', min = 1, max = 1 },
        { weight = 4, item = 'valuegoods', min = 1, max = 1 },
    },
}

Config.ExcludedVehicleTypes = {
    bike = true,
    boat = true,
    heli = true,
    plane = true,
    submarine = true,
    trailer = true,
    train = true,
}

Config.ExcludedModels = {
    [`police`] = true,
    [`police2`] = true,
    [`police3`] = true,
    [`police4`] = true,
    [`policeb`] = true,
    [`policet`] = true,
    [`fbi`] = true,
    [`fbi2`] = true,
    [`ambulance`] = true,
    [`firetruk`] = true,
    [`taxi`] = true,
    -- ONX MODELS ( WIP )
    [`onx_polbuff`] = true,
    [`onx_polscout`] = true,
}
