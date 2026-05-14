return {
    DefaultSpawns = {
        {
            id = 1,
            label = "LSIA",
            location = { x = -1044.84, y = -2749.85, z = 21.36, h = 0.0 },
        },
        {
            id = 2,
            label = "Bolingbroke Penitentiary",
            location = { x = 1767.49, y = 2501.12, z = 45.72, h = 90.70 },
        },
        {
            id = 3,
            label = "Mission Row PD",
            location = { x = 436.67, y = -974.42, z = 30.71, h = 87.87 },
        },
        {
            id = 4,
            label = "Sandy PD",
            location = { x = 1866.09, y = 3688.27, z = 34.26, h = 257.95 },
        },
    },
    PrisonSpawn = {
        id = 1,
        icon = "link",
        label = "Bolingbroke Penitentiary",
        location = { x = 1767.49, y = 2501.12, z = 45.72, h = 0.0 },
        event = "Jail:SpawnJailed",
    },
    ICUSpawn = {
        id = 1,
        icon = "hospital",
        label = "St. Fiacre Intensive Care Unit",
        location = { x = 1153.161, y = -1542.383, z = 39.537, h = 123.576 },
        event = "Hospital:SpawnICU",
    },
    LogoutLocations = {
        { -- Mt Zonah
            center = vector3(-435.59, -305.86, 35.0),
            length = 1.8,
            width = 2.2,
            options = {
                heading = 22,
                --debugPoly=true,
                minZ = 34.0,
                maxZ = 36.8
            },
        },
        { -- St Fiacre Medical Bathroom
            center = vector3(1123.17, -1546.83, 35.03),
            length = 1.4,
            width = 1.4,
            options = {
                heading = 0,
                --debugPoly=true,
                minZ = 32.63,
                maxZ = 36.63
            },
        },
        { -- St Fiacre Medical Bathroom
            center = vector3(1123.2, -1538.36, 35.03),
            length = 1.4,
            width = 1.4,
            options = {
                heading = 0,
                --debugPoly=true,
                minZ = 32.63,
                maxZ = 36.63
            },
        },
        { -- MRPD Bathroom
            center = vector3(477.96, -981.89, 30.69),
            length = 5.0,
            width = 3.6,
            options = {
                heading = 0,
                --debugPoly=true,
                minZ = 29.69,
                maxZ = 32.09
            },
        },
        { -- BCSO Bathroom
            center = vector3(1830.4, 3680.58, 38.86),
            length = 3.6,
            width = 3.2,
            options = {
                heading = 30,
                --debugPoly=true,
                minZ = 37.26,
                maxZ = 41.26
            },
        },
        { -- Pillbox
            center = vector3(304.05, -568.87, 43.28),
            length = 1.0,
            width = 2.2,
            options = {
                heading = 340,
                --debugPoly=true,
                minZ = 41.82,
                maxZ = 45.22
            },
        },
    }
}
