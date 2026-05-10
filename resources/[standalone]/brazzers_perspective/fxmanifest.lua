fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_fxv2_oal 'yes'

author "MannyOnBrazzers"
description 'Perspective of your butthole'
version "1.0.1"

client_scripts {
    'client/*.lua',
}

server_script 'version.lua'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

ox_lib 'locale'

files {
    'classes/*.lua',
    'modules/**/*.lua',
    'locales/*.json',
}
