fx_version("cerulean")
version '1.0.3'
client_script("@pulsar-core/exports/cl_error.lua")
client_script("@pulsar-pwnzor/client/check.lua")

game("gta5")
lua54("yes")

client_scripts({
  "interiors/**/*.lua",
  "client/**/*.lua",
})

server_scripts({
  "interiors/**/*.lua",
  "sv_config.lua",
  "server/**/*.lua",
})

shared_scripts({
  "shared/**/*.lua",
})
