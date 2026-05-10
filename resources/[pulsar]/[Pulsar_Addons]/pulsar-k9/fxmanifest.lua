fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'AutLaaw'
description 'K-9 for Pulsar (pulsar-jobs, pulsar-hud, pulsar-kbs, ox_target, ox_inventory)'

client_scripts {
    'client/*'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*'
}

shared_scripts {
    '@ox_lib/init.lua',
    'shared/*.lua',
}

dependencies {
    'ox_lib',
    'oxmysql',
    'ox_target',
    'pulsar-core',
    'pulsar-jobs',
    'pulsar-hud',
    'pulsar-kbs',
    'ox_inventory',
}
