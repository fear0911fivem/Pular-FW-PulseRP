name("Pulsar Framework Restaurant")
author("[Alzar, Dr Nick]")
version '1.0.4'
lua54("yes")
fx_version("cerulean")
game("gta5")
client_script("@pulsar-core/exports/cl_error.lua")
client_script("@pulsar-pwnzor/client/check.lua")

client_scripts({
  "client/**/*.lua",
})

server_scripts({
  "configs/config.lua",
  "configs/recipies.lua",
  "configs/restaurants/**/*.lua",
  "server/**/*.lua",
})
