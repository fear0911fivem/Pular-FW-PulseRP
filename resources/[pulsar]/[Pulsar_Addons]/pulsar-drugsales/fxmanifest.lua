fx_version("cerulean")
games({ "gta5" })
lua54("yes")
version("1.0.0")
author("Brandon")

ui_page("ui/build/index.html")

files({
	"ui/build/index.html",
	"ui/build/**/*",
})

client_script("@pulsar-core/exports/cl_error.lua")
client_script("@pulsar-pwnzor/client/check.lua")

shared_scripts({
	"shared/config.lua",
})

client_scripts({
	"client/main.lua",
})

server_scripts({
	"server/main.lua",
})

dependencies({
	"pulsar-core",
	"pulsar-characters",
	"pulsar-hud",
	"ox_inventory",
	"ox_target",
})
