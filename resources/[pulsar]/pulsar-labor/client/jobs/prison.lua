local _joiner = nil
local _working = false
local _state = nil
local _nodes = nil
local eventHandlers = {}

AddEventHandler("Labor:Client:Setup", function() end)

RegisterNetEvent("Prison:Client:OnDuty", function(joiner, time)
	_working = true
	_joiner = joiner
	_state = 0

	eventHandlers["receive"] = RegisterNetEvent(string.format("Prison:Client:%s:Receive", joiner), function(data)
		_nodes = data
		_state = 1

		for k, v in ipairs(_nodes.locations) do
			local id = string.format("PrisonNode%s", v.data.id)

			exports["pulsar-blips"]:Add(id, data.blip.name, v.coords, data.blip.sprite or 188, data.blip.color or 56,
				0.8)
            if v.type == "box" then
                exports.ox_target:addBoxZone({
                    name = id,
                    coords = v.coords,
                    size = vector3(v.length, v.width, 2.0),
                    rotation = v.options.heading or 0,
                    debug = false,
                    minZ = v.options.minZ,
                    maxZ = v.options.maxZ,
                    options = {
                        {
                            icon = "fa-solid fa-hand-pointer",
                            label = data.action,
                            data = v.data,
                            onSelect = function(opt)
                                local d = opt and opt.data or opt
                                if not d then return end
                                TriggerEvent(string.format("Labor:Client:%s:Action", joiner), d)
                            end,
                            canInteract = function(data)
                                return _working and _state == 1
                            end,
                        },
                    }
                })
            elseif v.type == "circle" then
                exports.ox_target:addSphereZone({
                    name = id,
                    coords = v.coords,
                    radius = v.radius,
                    debug = false,
                    options = {
                        {
                            icon = "fa-solid fa-hand-pointer",
                            label = data.action,
                            data = v.data,
                            onSelect = function(opt)
                                local d = opt and opt.data or opt
                                if not d then return end
                                TriggerEvent(string.format("Labor:Client:%s:Action", joiner), d)
                            end,
                            canInteract = function(data)
                                return _working and _state == 1
                            end,
                        },
                    }
                })
            elseif v.type == "poly" then
                exports.ox_target:addPolyZone({
                    name = id,
                    points = v.points,
                    debug = false,
                    options = {
                        {
                            icon = "fa-solid fa-hand-pointer",
                            label = data.action,
                            data = v.data,
                            onSelect = function(opt)
                                local d = opt and opt.data or opt
                                if not d then return end
                                TriggerEvent(string.format("Labor:Client:%s:Action", joiner), d)
                            end,
                            canInteract = function(data)
                                return _working and _state == 1
                            end,
                        },
                    }
                })
            end

        end
    end)

    eventHandlers["action"] = AddEventHandler(string.format("Labor:Client:%s:Action", joiner), function(data)
        exports['pulsar-hud']:Progress({
            name = "prison_action",
            duration = data.duration,
            label = data.label,
            useWhileDead = false,
            canCancel = true,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
            animation = data.animation,
        }, function(status)
            if not status then
                exports["pulsar-core"]:ServerCallback("Prison:Action", data.id, function(s)
                    local id = string.format("PrisonNode%s", data.id)
                    if exports.ox_target:zoneExists(id) then
                        exports.ox_target:removeZone(id)
                    end
                    exports["pulsar-blips"]:Remove(id)
                end)
            end
        end)
    end)

	eventHandlers["cleanup"] = AddEventHandler(string.format("Labor:Client:%s:Cleanup", joiner), function()
        if _nodes ~= nil then
            for k, v in ipairs(_nodes.locations) do
                local id = string.format("PrisonNode%s", v.data.id)
                if exports.ox_target:zoneExists(id) then
                    exports.ox_target:removeZone(id)
                end
                exports["pulsar-blips"]:Remove(id)
            end
        end

		_nodes = nil
		_state = 0
	end)
end)

AddEventHandler("Prison:Client:StartJob", function()
	exports["pulsar-core"]:ServerCallback("Prison:StartJob", _joiner, function(state)
		if not state then
			exports["pulsar-hud"]:Notification("error", "Unable To Start Job")
		end
	end)
end)

RegisterNetEvent("Prison:Client:OffDuty", function(time)
	for k, v in pairs(eventHandlers) do
		RemoveEventHandler(v)
	end

    if _nodes ~= nil then
        for k, v in ipairs(_nodes.locations) do
            local id = string.format("PrisonNode%s", v.data.id)
            if exports.ox_target:zoneExists(id) then
                exports.ox_target:removeZone(id)
            end
            exports["pulsar-blips"]:Remove(id)
        end
    end

	_joiner = nil
	_working = false
	_nodes = nil
	_state = nil
	eventHandlers = {}
end)
