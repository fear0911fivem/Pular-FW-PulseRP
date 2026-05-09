fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'SRP'
description 'Vehicle stolen packages'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
}

client_scripts {
    'client/cl_main.lua',
}

server_scripts {
    'server/sv_main.lua',
}

dependencies {
    'ox_lib',
    'ox_target',
    'ox_inventory',
    'pulsar-characters',
    'pulsar-core',
    'pulsar-hud',
    'pulsar-kbs',
    'pulsar-vehicles',
}
