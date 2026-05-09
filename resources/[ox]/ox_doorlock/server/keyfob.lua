local keyfobRange = 10.0

local function findNearestAccessibleDoor(playerId)
    local playerPed = GetPlayerPed(playerId)
    local playerCoords = GetEntityCoords(playerPed)
    local nearestDistance = keyfobRange
    local nearestDoorId = nil

    local player = GetPlayer(playerId)
    if not player then return nil, nil end

    local doors = exports.ox_doorlock:getAllDoors()
    if not doors then return nil, nil end

    for _, door in pairs(doors) do
        if door.coords then
            local distance = #(playerCoords - door.coords)

            if distance <= keyfobRange then
                local hasAccess = false

                if door.groups then
                    local filter = {}
                    for job, grade in pairs(door.groups) do
                        filter[job] = grade
                    end

                    if door.workplace then
                        filter.workplace = door.workplace
                    end
                    if door.permissions then
                        filter.permissions = door.permissions
                    end
                    if door.onduty then
                        filter.onduty = door.onduty
                    end

                    hasAccess = IsPlayerInGroup(player, filter)
                end

                if not door.groups and door.items then
                    hasAccess = DoesPlayerHaveItem(player, door.items) ~= nil
                end

                if not door.groups and not door.items then
                    hasAccess = true
                end

                if hasAccess and distance < nearestDistance then
                    nearestDistance = distance
                    nearestDoorId = door.id
                end
            end
        end
    end

    return nearestDoorId, nearestDistance
end

RegisterNetEvent('ox_doorlock:useKeyfob', function(data)
    local playerId = source
    local doorId, distance = findNearestAccessibleDoor(playerId)

    if not doorId then
        TriggerClientEvent('ox_doorlock:useKeyfobClient', playerId, 'keyfob', false)
        return
    end

    local door = exports.ox_doorlock:getDoor(doorId)
    if door and door.auto then
        local newState = door.state == 1 and 0 or 1
        local success = exports.ox_doorlock:setDoorState(doorId, newState)

        if success then
            TriggerClientEvent('ox_doorlock:useKeyfobClient', playerId, 'keyfob', true, doorId, newState)
        else
            TriggerClientEvent('ox_doorlock:useKeyfobClient', playerId, 'keyfob', false)
        end
    else
        TriggerClientEvent('ox_doorlock:useKeyfobClient', playerId, 'keyfob', false)
    end
end)

exports('getKeyfobRange', function()
    return keyfobRange
end)
