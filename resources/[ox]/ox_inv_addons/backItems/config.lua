--- Defines a slot with a bone, position, and rotation
---@class Slot
---@field bone number
---@field pos vector3
---@field rot vector3

---@class OptionalVector
---@field x? number
---@field y? number
---@field z? number

--- Defines an item with properties for its placement and grouping
---@class BackItem
---@field prio number a number to define the priority of importance that the weapon should appear over others
---@field group? string which slot group the item should use. defaults to 'back'
---@field customPos? {bone?: number , pos?: OptionalVector | vector3,  rot?:  OptionalVector | vector3} optional custom position. required if ignorelimits is true
---@field ignoreLimits? boolean wether or not the item is attached regardless of available slots. requires a full custom position. a full custom position has a bone, pos as a vec3, and rot as a vec3
---@field model? number | string this is required for non-weapon items. can optionally be used for weapons in order to have the attached model different than the equipped model. like if you want a sheathed katanta on your back

---@class Config
---@field defaultSlots table<string, Slot[]>
---@field BackItems table<string, BackItem>

--- Configurations for item slots and back items
local Config = {}

--- Default slots configuration
---@type table<string, Slot[]>
Config.defaultSlots = {
    ['back'] = {
        { bone = 24818, pos = vec3(0.09, -0.16, 0.12),  rot = vec3(0.0, 180.0, 0.0) },
        { bone = 24818, pos = vec3(0.09, -0.16, 0.00),  rot = vec3(0.0, 180.0, 0.0) },
        { bone = 24818, pos = vec3(0.09, -0.16, -0.12), rot = vec3(0.0, 180.0, 0.0) }
    },
    -- ['another group'] = { -- add as many slot groups as you like for different types of items
    --     { bone = 24818, pos = vec3(0.09, -0.16, 0.12),  rot = vec3(0.0, 180.0, 0.0) },
    --     { bone = 24818, pos = vec3(0.09, -0.16, 0.00),  rot = vec3(0.0, 180.0, 0.0) },
    --     { bone = 24818, pos = vec3(0.09, -0.16, -0.12), rot = vec3(0.0, 180.0, 0.0) }
    -- },
}

--- these vehicle classes will be allowed to display all attached back items
Config.allowedVehicleClasses = {
    [8] = true,  -- motorcycles
    [13] = true, -- bicycles
    [14] = true, -- boats
}

--- Back items configuration
---@type table<string, BackItem>
Config.BackItems = {
    -- Assault rifles
    ['WEAPON_ASSAULTRIFLE'] = { prio = 3, group = 'back', visibility = 1 },
    ['WEAPON_ASSAULTRIFLE_MK2'] = { prio = 3, group = 'back', visibility = 1 },
    ['WEAPON_CARBINERIFLE'] = { prio = 3, group = 'back', visibility = 1 },
    ['WEAPON_CARBINERIFLE_MK2'] = { prio = 3, group = 'back', visibility = 1 },
    ['WEAPON_ADVANCEDRIFLE'] = { prio = 3, group = 'back', visibility = 1 },
    ['WEAPON_SPECIALCARBINE'] = { prio = 3, group = 'back', visibility = 1 },
    ['WEAPON_SPECIALCARBINE_MK2'] = { prio = 3, group = 'back', visibility = 1 },
    ['WEAPON_BULLPUPRIFLE'] = { prio = 3, group = 'back', visibility = 1 },
    ['WEAPON_BULLPUPRIFLE_MK2'] = { prio = 3, group = 'back', visibility = 1 },
    ['WEAPON_COMPACTRIFLE'] = { prio = 2, group = 'back', visibility = 1 },
    ['WEAPON_MILITARYRIFLE'] = { prio = 3, group = 'back', visibility = 1 },
    ['WEAPON_HEAVYRIFLE'] = { prio = 3, group = 'back', visibility = 1 },
    ['WEAPON_TACTICALRIFLE'] = { prio = 3, group = 'back', visibility = 1 },

    -- SMGs
    ['WEAPON_SMG'] = { prio = 2, group = 'back', visibility = 1 },
    ['WEAPON_SMG_MK2'] = { prio = 2, group = 'back', visibility = 1 },
    ['WEAPON_ASSAULTSMG'] = { prio = 2, group = 'back', visibility = 1 },
    ['WEAPON_MICROSMG'] = { prio = 2, group = 'back', visibility = 1 },
    ['WEAPON_COMBATPDW'] = { prio = 2, group = 'back', visibility = 1 },
    ['WEAPON_MACHINEPISTOL'] = { prio = 2, group = 'back', visibility = 1 },
    ['WEAPON_MINISMG'] = { prio = 2, group = 'back', visibility = 1 },
    ['WEAPON_TECPISTOL'] = { prio = 2, group = 'back', visibility = 1 },
    ['WEAPON_HKUMP_PD'] = { prio = 2, group = 'back', visibility = 1 },

    -- MGs
    ['WEAPON_MG'] = { prio = 4, group = 'back', visibility = 1 },
    ['WEAPON_COMBATMG'] = { prio = 4, group = 'back', visibility = 1 },
    ['WEAPON_COMBATMG_MK2'] = { prio = 4, group = 'back', visibility = 1 },
    ['WEAPON_GUSENBERG'] = { prio = 4, group = 'back', visibility = 1 },

    -- Shotguns
    ['WEAPON_PUMPSHOTGUN'] = { prio = 3, group = 'back', visibility = 1 },
    ['WEAPON_PUMPSHOTGUN_MK2'] = { prio = 3, group = 'back', visibility = 1 },
    ['WEAPON_SAWNOFFSHOTGUN'] = { prio = 3, group = 'back', visibility = 1 },
    ['WEAPON_ASSAULTSHOTGUN'] = { prio = 3, group = 'back', visibility = 1 },
    ['WEAPON_BULLPUPSHOTGUN'] = { prio = 3, group = 'back', visibility = 1 },
    ['WEAPON_HEAVYSHOTGUN'] = { prio = 3, group = 'back', visibility = 1 },
    ['WEAPON_DBSHOTGUN'] = { prio = 3, group = 'back', visibility = 1 },
    ['WEAPON_MUSKET'] = { prio = 3, group = 'back', visibility = 1 },
    ['WEAPON_COMBATSHOTGUN'] = { prio = 3, group = 'back', visibility = 1 },
    ['WEAPON_AUTOSHOTGUN'] = { prio = 3, group = 'back', visibility = 1 },
    ['WEAPON_BENELLIM2_PD'] = { prio = 3, group = 'back', visibility = 1 },
    ['WEAPON_BULLPUPSHOTGUN_PD'] = { prio = 3, group = 'back', visibility = 1 },

    -- Sniper rifles
    ['WEAPON_SNIPERRIFLE'] = { prio = 3, group = 'back', visibility = 1 },
    ['WEAPON_HEAVYSNIPER'] = { prio = 3, group = 'back', visibility = 1 },
    ['WEAPON_HEAVYSNIPER_MK2'] = { prio = 3, group = 'back', visibility = 1 },
    ['WEAPON_MARKSMANRIFLE'] = { prio = 3, group = 'back', visibility = 1 },
    ['WEAPON_MARKSMANRIFLE_MK2'] = { prio = 3, group = 'back', visibility = 1 },
    ['WEAPON_PRECISIONRIFLE'] = { prio = 3, group = 'back', visibility = 1 },
    ['WEAPON_SNIPERRIFLE2'] = { prio = 3, group = 'back', visibility = 1 },

    -- Launchers
    ['WEAPON_RPG'] = { prio = 5, group = 'back', visibility = 1 },
    ['WEAPON_GRENADELAUNCHER'] = { prio = 5, group = 'back', visibility = 1 },
    ['WEAPON_MINIGUN'] = { prio = 5, group = 'back', visibility = 1 },
    ['WEAPON_FIREWORK'] = { prio = 5, group = 'back', visibility = 1 },
    ['WEAPON_RAILGUN'] = { prio = 5, group = 'back', visibility = 1 },
    ['WEAPON_COMPACTLAUNCHER'] = { prio = 5, group = 'back', visibility = 1 },
    ['WEAPON_HOMINGLAUNCHER'] = { prio = 5, group = 'back', visibility = 1 },

    -- Melee
    --['WEAPON_BAT'] = { prio = 1, group = 'back', visibility = 1, customPos = { pos = { x = 0.4, y = -0.15 }, rot = { y = 270.0 } } },
    --['WEAPON_CROWBAR'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_GOLFCLUB'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_HAMMER'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_HATCHET'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_MACHETE'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_KNIFE'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_BOTTLE'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_SWITCHBLADE'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_BATTLEAXE'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_WRENCH'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_DAGGER'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_KNUCKLE'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_NIGHTSTICK'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_FLASHLIGHT'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_POOLCUE'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_STONE_HATCHET'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_SHOVEL'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_SHIV'] = { prio = 1, group = 'back', visibility = 1 },

    -- Pistols
    --['WEAPON_PISTOL'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_PISTOL_MK2'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_COMBATPISTOL'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_APPISTOL'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_PISTOL50'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_SNSPISTOL'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_SNSPISTOL_MK2'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_HEAVYPISTOL'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_VINTAGEPISTOL'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_MARKSMANPISTOL'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_REVOLVER'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_REVOLVER_MK2'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_DOUBLEACTION'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_NAVYREVOLVER'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_GADGETPISTOL'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_STUNGUN_MP'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_PISTOLXM3'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_CERAMICPISTOL'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_GLOCK19'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_FIVESEVEN_PD'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_FM1_P226_PD'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_2011_PD'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_38SNUBNOSE'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_44MAGNUM_PD'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_FNX45'] = { prio = 1, group = 'back', visibility = 1 },

    -- Tools & misc
    --['WEAPON_STUNGUN'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_FLAREGUN'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_FIREEXTINGUISHER'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_HAZARDCAN'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_PETROLCAN'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_SNOWBALL'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_FLARE'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_TEARGAS'] = { prio = 1, group = 'back', visibility = 1 },
    --['WEAPON_TASER'] = { prio = 1, group = 'back', visibility = 1 },

    -- Props / misc custom items
    ['cone'] = { prio = 1, ignoreLimits = true, model = `prop_roadcone02a`, customPos = { bone = 12844, pos = vec3(0.06, 0.0, 0.0), rot = vec3(0.0, 90.0, 0.0) } }
}


return Config