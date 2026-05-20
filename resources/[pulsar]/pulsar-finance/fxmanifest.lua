fx_version("cerulean")
game("gta5")
lua54("yes")
version "1.0.2"
client_script("@pulsar-core/exports/cl_error.lua")
client_script("@pulsar-pwnzor/client/check.lua")
server_script("@oxmysql/lib/MySQL.lua")

client_scripts({
  "client/**/*.lua",
})

server_scripts({
  "server/**/*.lua",
})

shared_scripts({
  "shared/**/*.lua",
})

ui_page("ui/srp/index.html")

files({
  "ui/srp/index.html",
  "ui/srp/assets/*",
  "ui/srp/**/*",
  "locales/*.json",
})
