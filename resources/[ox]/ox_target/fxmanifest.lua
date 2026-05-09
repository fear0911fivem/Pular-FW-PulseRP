-- FX Information
fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'

-- Resource Information
name 'ox_target'
author 'Overextended'
version '1.17.3'
repository 'https://github.com/communityox/ox_target'
description 'Ox Target in React, conversion made by AutLaaw. Boilerplate used: "https://github.com/project-error/fivem-react-boilerplate-lua", all credits go to the original authors.'

-- Manifest
ui_page 'web/build/index.html'

shared_scripts {
  '@ox_lib/init.lua',
  'config.lua',
}

client_scripts {
  'client/main.lua',
}

server_scripts {
  'server/main.lua'
}

files {
  'web/build/index.html',
  'web/build/**/*',
  'locales/*.json',
  'client/api.lua',
  'client/utils.lua',
  'client/state.lua',
  'client/debug.lua',
  'client/defaults.lua',
  'client/framework/nd.lua',
  'client/framework/ox.lua',
  'client/framework/esx.lua',
  'client/framework/qbx.lua',
  'client/framework/pulsar.lua',
  'client/compat/qtarget.lua',
}

provide 'qtarget'

dependency 'ox_lib'
