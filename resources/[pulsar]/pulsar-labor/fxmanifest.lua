fx_version("cerulean")
lua54("yes")
game("gta5")
version '1.0.5'
client_script("@pulsar-core/exports/cl_error.lua")
client_script("@pulsar-pwnzor/client/check.lua")

client_scripts({
  "client/**/*.lua",
})

shared_scripts({
  "shared/**/*.lua",
})

server_scripts({
  "configs/**/*.lua",
  "server/**/*.lua",
})
