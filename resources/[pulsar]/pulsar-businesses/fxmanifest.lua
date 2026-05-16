fx_version("cerulean")
games({ "gta5" })
lua54("yes")
client_script("@pulsar-core/exports/cl_error.lua")
client_script("@pulsar-pwnzor/client/check.lua")

description("Pulsar Framework Businesses Script")
name("Pulsar Framework: pulsar-businesses")
author("Dr Nick")
version '1.0.3'

client_scripts({
  "client/**/*.lua",
})

server_scripts({
  '@oxmysql/lib/MySQL.lua',
  "config/sv_config.lua",
  "config/businesses/*.lua",
  "server/**/*.lua",
})

shared_scripts({
  "shared/**/*.lua",
})

files({
  "dui/bowling/app.js",
  "dui/bowling/index.html",
  "dui/bowling/*.png",
  "dui/bowling/gifs/*.gif",
  "dui/tvs/app.js",
  "dui/tvs/index.html",
})
