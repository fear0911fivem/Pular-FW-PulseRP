name("Pulsar Framework - Clothing System")
author("[Alzar]")
lua54("yes")
fx_version("cerulean")
game("gta5")
version "1.0.2"
client_script("@pulsar-core/exports/cl_error.lua")
client_script("@pulsar-pwnzor/client/check.lua")

ui_page("ui/dist/index.html")

files({
  "ui/dist/*.*",
  "ui/dist/**/*",
  "ui/dist/**/*.*",
  "ui/src/assets/**/*",
  "ui/src/assets/**/*.*",
})

client_scripts({
  "storeData.lua",
  "tattoos.lua",
  "config.lua",
  "utils/*.lua",
  "client/**/*.lua",
})

server_scripts({
  '@oxmysql/lib/MySQL.lua',
  "config.lua",
  "utils/*.lua",
  "server/**/*.lua",
})
