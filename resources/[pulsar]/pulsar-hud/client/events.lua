local function GetFixedHUDConfig()
	return {
		layout = "default",
		statusType = "numbers",
		buffsAnchor = "compass",
		vehicle = "minimal",
		buffsAnchor2 = true,
		showRPM = true,
		hideCrossStreet = false,
		hideCompassBg = true,
		largeBars = false,
		minimapAnchor = true,
		transparentBg = false,
		maskRadio = false,
		condenseAlignment = "left",
		circleNumbers = false,
	}
end

AddEventHandler("Vehicles:Client:EnterVehicle", function(currentVehicle, currentSeat)
	GLOBAL_VEH = currentVehicle
	exports['pulsar-hud']:VehicleShow()
	--Hud.Minimap:Set()
end)

AddEventHandler("Vehicles:Client:ExitVehicle", function(currentVehicle, currentSeat)
	exports['pulsar-hud']:VehicleHide()
	GLOBAL_VEH = nil
end)

AddEventHandler("Characters:Client:Spawn", function()
	SendNUIMessage({
		type = "SET_CONFIG",
		data = {
			config = GetFixedHUDConfig(),
		},
	})

	exports['pulsar-hud']:Show()

	DisplayRadar(hasValue(LocalPlayer.state.Character:GetData("States"), "GPS"))
	exports['pulsar-hud']:ShiftLocation(hasValue(LocalPlayer.state.Character:GetData("States"), "GPS"))
end)

RegisterNetEvent("UI:Client:Reset", function(manual)
	exports['pulsar-hud']:Hide()
	SendNUIMessage({
		type = "UI_RESET",
		data = {
			manual = manual,
		},
	})

	if LocalPlayer.state.Character ~= nil then
		SendNUIMessage({
			type = "SET_CONFIG",
			data = {
				config = GetFixedHUDConfig(),
			},
		})
	end

	exports['pulsar-hud']:ActionHide()
	exports['pulsar-hud']:ListMenuClose()
	exports['pulsar-hud']:InteractionHide()
	exports["pulsar-hud"]:Notification("clear")
	exports['pulsar-hud']:ConfirmClose()
	exports['pulsar-hud']:InputClose()
	exports['pulsar-hud']:InfoOverlayClose()
	exports['pulsar-hud']:MethClose()

	TriggerEvent("UI:Client:ResetFinished", manual)

	if manual then
		Wait(2500)
		exports['pulsar-hud']:Show()
		if exports['pulsar-phone']:IsOpen() or hasValue(LocalPlayer.state.Character:GetData("States"), "GPS") then
			DisplayRadar(true)
		end
	end
end)

RegisterNetEvent("Characters:Client:Logout", function()
	TriggerEvent("UI:Client:Reset")
end)

AddEventHandler("Vehicles:Client:Seatbelt", function(state)
	SendNUIMessage({
		type = "UPDATE_SEATBELT",
		data = { seatbelt = state },
	})
end)

AddEventHandler("Vehicles:Client:Cruise", function(state)
	SendNUIMessage({
		type = "UPDATE_CRUISE",
		data = { cruise = state },
	})
end)

AddEventHandler("Vehicles:Client:Ignition", function(state)
	SendNUIMessage({
		type = "UPDATE_IGNITION",
		data = { ignition = state },
	})
end)

AddEventHandler("Vehicles:Client:Fuel", function(amount, show)
	SendNUIMessage({
		type = "UPDATE_FUEL",
		data = {
			fuel = amount,
			fuelHide = show,
		},
	})
end)

RegisterNetEvent("Status:Client:Update", function(status, value)
	SendNUIMessage({
		type = "UPDATE_STATUS_VALUE",
		data = { name = status, value = value },
	})
end)

RegisterNetEvent("Progress:Client:Progress", function(action, cb)
	exports['pulsar-hud']:Progress(action, cb)
end)

RegisterNetEvent("Progress:Client:ProgressWithStartEvent", function(action, start, finish)
	exports['pulsar-hud']:ProgressWithStartEvent(action, start, finish)
end)

RegisterNetEvent("Progress:Client:ProgressWithTickEvent", function(action, tick, finish)
	exports['pulsar-hud']:ProgressWithTickEvent(action, tick, finish)
end)

RegisterNetEvent("Progress:Client:ProgressWithStartAndTick", function(action, start, tick, finish)
	exports['pulsar-hud']:ProgressWithStartAndTick(action, start, tick, finish)
end)

RegisterNetEvent("Progress:Client:Cancel", function()
	exports['pulsar-hud']:ProgressCancel()
end)

RegisterNetEvent("Progress:Client:Fail", function()
	exports['pulsar-hud']:ProgressFail()
end)

RegisterNUICallback("Progress:Finish", function(data, cb)
	exports['pulsar-hud']:ProgressFinish()
	cb("ok")
end)

AddEventHandler("Targeting:Client:UpdateState", function(isTargeting, hasTarget)
	SendNUIMessage({
		type = (isTargeting and "SHOW_EYE" or "HIDE_EYE"),
		data = {
			icon = (type(hasTarget) == "string" and hasTarget or false),
		},
	})
end)

AddEventHandler("Targeting:Client:OpenMenu", function(menuData)
	SetNuiFocus(true, true)
	SetCursorLocation(0.5, 0.5)
	SendNUIMessage({
		type = "OPEN_MENU",
		data = {
			menu = menuData,
		},
	})
end)

AddEventHandler("Targeting:Client:CloseMenu", function()
	SetNuiFocus(false, false)
	SendNUIMessage({
		type = "CLOSE_MENU",
		data = {},
	})
end)

RegisterNetEvent("UI:Client:Configure", function()
	SetNuiFocus(false, false)
end)

RegisterNUICallback("targetingAction", function(data, cb)
	SetNuiFocus(false, false)
	SendNUIMessage({
		type = "CLOSE_MENU",
		data = {},
	})
	TriggerEvent("Targeting:Client:MenuSelect", data and data.event, data and data.data or {})
	cb("ok")
end)

RegisterNUICallback("CloseUI", function(data, cb)
	SetNuiFocus(false, false)
	cb("OK")
end)

RegisterNUICallback("SaveConfig", function(data, cb)
	cb(false)
end)
