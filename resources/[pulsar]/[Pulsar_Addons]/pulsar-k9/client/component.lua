-- Pulsar stack: pulsar-hud, pulsar-kbs (ox_target is used from client.lua)

Notification = {
	Error = function(_, msg, dur)
		exports["pulsar-hud"]:Notification("error", msg, dur or 3000)
	end,
	Info = function(_, msg, dur)
		exports["pulsar-hud"]:Notification("info", msg, dur or 3000)
	end,
	Success = function(_, msg, dur)
		exports["pulsar-hud"]:Notification("success", msg, dur or 3000)
	end,
}

ListMenu = {
	Show = function(_, menus)
		exports["pulsar-hud"]:ListMenuShow(menus)
	end,
}

Keybinds = {
	-- Colon calls (Keybinds:Add) pass self first.
	Add = function(_, id, key, device, label, cb)
		local defaultKey = (type(key) == "string" and key ~= "" and key) or ""
		exports["pulsar-kbs"]:Add(id, defaultKey, device or "keyboard", label, cb)
	end,
}

CreateThread(function()
	Wait(750)
	InitK9Ped()
	RegisterKeyBinds()
end)
