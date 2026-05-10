fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'ob_radio_2'
description 'Custom synced radio system with GTA V-style wheel UI'
author 'Obtaizen'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client/main.lua',
    'client/environment.lua',
    'client/spatial.lua',
}

server_scripts {
    'server/main.lua',
}

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/css/*.css',
    'web/js/*.js',
    'web/img/*',
    'songs/*.ogg',
}

dependencies {
    'ox_lib',
}
