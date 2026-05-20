local menus = {}
local currentItems = {}
local stack = {}
local requestedInteractions = false

local function RequestInteractionRegistrations()
	if requestedInteractions then
		return
	end

	requestedInteractions = true
	CreateThread(function()
		Wait(250)
		TriggerEvent("PulsarHud:Client:RegisterInteractions")
		requestedInteractions = false
	end)
end

local function InteractionItemsAsMenu(items)
	local is = {}
	for k, v in pairs(items) do
		local show = true
		if v.shouldShow then
			show = v.shouldShow()
		end

		if v.labelFunc then
			v.label = v.labelFunc()
		end

		if show then
			table.insert(is, {
				id = k,
				label = v.label,
				icon = v.icon,
				action = v.action,
				data = show,
			})
		end
	end
	return is
end

exports("InteractionItemsAsMenu", InteractionItemsAsMenu)

exports("InteractionHide", function()
	SetNuiFocus(false, false)
	SendNUIMessage({
		type = "SHOW_INTERACTION_MENU",
		data = {
			toggle = false,
		},
	})
end)

exports("InteractionShow", function()
	if not exports['pulsar-hud']:IsDisabledAllowDead() then
		exports['pulsar-phone']:Close()
		exports.ox_inventory:closeInventory()

		if next(menus) == nil then
			RequestInteractionRegistrations()
			Wait(300)
		end

		SetNuiFocus(true, true)
		SetCursorLocation(0.5, 0.5)
		local is = InteractionItemsAsMenu(menus)
		stack = { is }
		SendNUIMessage({
			type = "SET_INTERACTION_LAYER",
			data = {
				layer = 0,
			},
		})
		SendNUIMessage({
			type = "SHOW_INTERACTION_MENU",
			data = {
				toggle = true,
			},
		})
		SendNUIMessage({
			type = "SET_INTERACTION_MENU_ITEMS",
			data = {
				items = is,
			},
		})
	end
end)

exports("InteractionRegisterMenu", function(id, label, icon, action, shouldShow, labelFunc)
	if not action then
		action = function() end
	end
	menus[id] = {
		label = label,
		icon = icon,
		shouldShow = shouldShow,
		action = action,
		labelFunc = labelFunc,
	}
end)

exports("InteractionRefresh", RequestInteractionRegistrations)

exports("InteractionShowMenu", function(items)
	local is = InteractionItemsAsMenu(items)
	stack[#stack + 1] = is
	SendNUIMessage({
		type = "SET_INTERACTION_LAYER",
		data = {
			layer = #stack,
		},
	})
	SendNUIMessage({
		type = "SET_INTERACTION_MENU_ITEMS",
		data = {
			items = is,
		},
	})
end)

exports("InteractionBack", function()
	stack[#stack] = nil
	SendNUIMessage({
		type = "SET_INTERACTION_LAYER",
		data = {
			layer = #stack - 1,
		},
	})
	SendNUIMessage({
		type = "SET_INTERACTION_MENU_ITEMS",
		data = {
			items = stack[#stack],
		},
	})
end)

RegisterNUICallback("Interaction:Trigger", function(data, cb)
	for k, v in ipairs(stack[#stack]) do
		if v.id == data.id then
			if v.action then
				v.action(v.data)
			end
			exports['pulsar-sounds']:UISoundsPlayFrontEnd(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET")
			return cb(true)
		end
	end
	cb(true)
end)

RegisterNUICallback("Interaction:Hide", function(data, cb)
	exports['pulsar-hud']:InteractionHide()
	exports['pulsar-sounds']:UISoundsPlayFrontEnd(-1, "CANCEL", "HUD_FRONTEND_DEFAULT_SOUNDSET")
	cb(true)
end)

RegisterNUICallback("Interaction:Back", function(data, cb)
	exports['pulsar-hud']:InteractionBack()
	exports['pulsar-sounds']:UISoundsPlayFrontEnd(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET")
	cb(true)
end)

AddEventHandler('onClientResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		RequestInteractionRegistrations()
	end
end)

AddEventHandler("Characters:Client:Spawn", function()
	RequestInteractionRegistrations()
end)
