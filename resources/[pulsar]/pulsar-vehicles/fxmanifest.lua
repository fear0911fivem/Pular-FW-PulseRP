fx_version("cerulean")
games({ "gta5" })
lua54("yes")
version '1.0.5'
client_script("@pulsar-core/exports/cl_error.lua")
client_script("@pulsar-pwnzor/client/check.lua")

client_scripts({
  '@pulsar-polyzone/client.lua',
  '@pulsar-polyzone/BoxZone.lua',
  '@pulsar-polyzone/EntityZone.lua',
  "client/**/*.lua",
})

server_scripts({
  '@oxmysql/lib/MySQL.lua',
  "server/**/*.lua",
})

shared_scripts({
  "@ox_lib/init.lua",
  "shared/**/*.lua",
})
