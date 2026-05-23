RegisterNetEvent("ListMenu:Client:Test", function()
	exports['pulsar-hud']:ListMenuShow({
		main = {
			label = "Test Menu",
			items = {
				{
					label = "Test Input",
					description = "Triggers input HUD option which lets us get input direct from user, NEAT!",
					event = "Input:Client:Test",
				},
				{
					label = "Test Item",
					description = "Test Item Description",
					submenu = "test",
				},
				{
					label = "Test Item Disabled",
					description = "Test Item Disabled Description",
					disabled = true,
				},
			},
		},
		test = {
			label = "Test Sub Menu",
			items = {
				{
					label = "Test Sub Menu Item",
					description = "Test Sub Menu Item Description",
					event = "ListMenu:Client:MenuTest",
				},
			},
		},
	})
end)

RegisterNUICallback("ListMenu:Clicked", function(data, cb)
	exports['pulsar-sounds']:UISoundsPlayFrontEnd(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET")
	exports['pulsar-hud']:ListMenuClose()
	if data.type == "server" then
		TriggerServerEvent(data.event, data.data)
	else
		TriggerEvent(data.event, data.data)
	end
	cb("ok")
end)

RegisterNUICallback("ListMenu:Back", function(data, cb)
	exports['pulsar-sounds']:UISoundsPlayFrontEnd(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET")
	TriggerEvent("ListMenu:GoBack")
	cb("ok")
end)

RegisterNUICallback("ListMenu:SubMenu", function(data, cb)
	exports['pulsar-sounds']:UISoundsPlayFrontEnd(-1, "CONTINUE", "HUD_FRONTEND_DEFAULT_SOUNDSET")
	TriggerEvent("ListMenu:EnterSubMenu", data.submenu)
	cb("ok")
end)

RegisterNUICallback("ListMenu:Close", function(data, cb)
	exports['pulsar-sounds']:UISoundsPlayFrontEnd(-1, "CANCEL", "HUD_FRONTEND_DEFAULT_SOUNDSET")
	exports['pulsar-hud']:ListMenuClose()
	TriggerEvent("ListMenu:Close")
	cb("ok")
end)

exports("ListMenuShow", function(menus)
	SetNuiFocus(true, true)
	SendNUIMessage({
		type = "SET_LIST_MENU",
		data = {
			menus = menus,
		},
	})
end)

exports("ListMenuClose", function()
	SetNuiFocus(false, false)
	SendNUIMessage({
		type = "CLOSE_LIST_MENU",
	})
	TriggerEvent("ListMenu:Client:Closed")
end)
