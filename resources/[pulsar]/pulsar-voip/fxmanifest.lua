game("gta5")
fx_version("cerulean")
version "1.0.1"
client_script("@pulsar-core/exports/cl_error.lua")
client_script("@pulsar-pwnzor/client/check.lua")

lua54("yes")

client_scripts({
  "client/**/*.lua",
})

server_scripts({
  "server/**/*.lua",
})

shared_scripts({
  "shared/**/*.lua",
})
