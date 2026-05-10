fx_version "cerulean"
games { "gta5" }

author "Nass"
version "1.0.0"

dependencies {
    'pulsar-objects',
    'pulsar-core',
    'ox_inventory',
    'ox_target',
}

shared_scripts {
    "@ox_lib/init.lua",
    "shared/config.lua"
}

client_scripts {
    "@pulsar-core/exports/cl_error.lua",
    "client/client.lua",
    "client/placement.lua",
    "client/target.lua"
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "@pulsar-core/exports/sv_error.lua",
    "shared/config.lua", -- Ensure config loads on server too
    "server/server.lua",
    "server/callbacks.lua",
    "server/items.lua"
}

lua54 "yes"

