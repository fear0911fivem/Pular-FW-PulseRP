fx_version("cerulean")
games({ "gta5" })
lua54("yes")
version '1.0.8'
client_script("@pulsar-core/exports/cl_error.lua")
client_script("@pulsar-pwnzor/client/check.lua")

data_file("SCALEFORM_DLC_FILE")("stream/int3232302352.gfx")

client_scripts({
  "config.lua",
  "client/*.lua",
  --'demo_games.lua',
})

server_scripts({
  "config.lua",
  "server/*.lua",
})

ui_page("ui/dist/index.html")
files({
  "ui/dist/index.html",
  "ui/dist/*.png",
  "ui/dist/*.webp",
  "ui/dist/*.js",
  "ui/dist/*.css",
  "ui/dist/*.mp3",
  "ui/dist/*.ttf",
  "ui/dist/*.woff2",
  "stream/int3232302352.gfx",
})
