local Config = SRPStealPackage

local modelMap = Config.Package.modelMap
local vehiclesInScope = {}
local currentSeat = cache.seat
local stealingPackage = false
local searchKeybindEnabled = false
local searchKeybindId = Config.Search.keybind or 'srp_vehicle_search'
local searchActionId = 'srp-stealpackage-search'

local seatPriorityMap = {
    [1] = 'seat_pside_f',
    [2] = 'seat_dside_r',
    [3] = 'seat_pside_r',
}

local seatDoorMap = {
    seat_pside_f = 1,
    seat_dside_r = 2,
    seat_pside_r = 3,
}

local seatWindowMap = {
    seat_pside_f = 1,
    seat_dside_r = 2,
    seat_pside_r = 3,
}

local function notifyPlayer(ntype, message, duration)
    exports['pulsar-hud']:Notification(ntype or 'info', message, duration or 5000)
end

local function showTextUI(message)
    exports['pulsar-hud']:ActionShow(searchActionId, message)
end

local function hideTextUI()
    exports['pulsar-hud']:ActionHide(searchActionId)
end

local function playBreakWindowAnimation()
    local animDict = 'veh@break_in@0h@p_m_zero@'
    local animName = 'std_force_entry_ds'

    RequestAnimDict(animDict)

    local timeout = GetGameTimer() + 1500

    while not HasAnimDictLoaded(animDict) and GetGameTimer() < timeout do
        Wait(10)
    end

    if not HasAnimDictLoaded(animDict) then
        return
    end

    TaskPlayAnim(cache.ped, animDict, animName, 8.0, -8.0, 1000, 0, 0.0, false, false, false)
    Wait(850)
    ClearPedTasks(cache.ped)
    RemoveAnimDict(animDict)
end

local function playGrabPackageAnimation()
    local animDict = 'anim@mp_snowball'
    local animName = 'pickup_snowball'

    RequestAnimDict(animDict)

    local timeout = GetGameTimer() + 1500

    while not HasAnimDictLoaded(animDict) and GetGameTimer() < timeout do
        Wait(10)
    end

    if not HasAnimDictLoaded(animDict) then
        return
    end

    TaskPlayAnim(cache.ped, animDict, animName, 8.0, -8.0, 1000, 49, 0.0, false, false, false)
    Wait(1000)
    ClearPedTasks(cache.ped)
    RemoveAnimDict(animDict)
end

local function cleanupVehicle(entity, data)
    if entity and entity ~= 0 then
        exports.ox_target:removeLocalEntity(entity, {
            'srp-stealpackage:break-window',
            'srp-stealpackage:steal-package',
        })
    end

    if data.handle and DoesEntityExist(data.handle) then
        SetEntityAsMissionEntity(data.handle, true, true)
        DeleteEntity(data.handle)
    end

    data.handle = nil
end

local function prepareVehicle(entity, data)
    if not DoesEntityExist(entity) or not IsEntityVisible(entity) then
        return
    end

    local seat = data.seat
    local boneIndex = seat.boneIndex
    local coords = GetWorldPositionOfEntityBone(entity, boneIndex)

    lib.requestModel(data.modelHash)

    data.handle = CreateObjectNoOffset(data.modelHash, coords.x, coords.y, coords.z + 2.0, false, false, false)

    SetEntityAsMissionEntity(data.handle, true, true)
    SetEntityCollision(data.handle, false, false)

    local offset = data.offset
    local rot = data.rotation

    AttachEntityToEntity(
        data.handle,
        entity,
        boneIndex,
        offset.x,
        offset.y,
        offset.z,
        rot.x,
        rot.y,
        rot.z,
        true,
        true,
        false,
        false,
        1,
        true
    )

    SetModelAsNoLongerNeeded(data.modelHash)

    if not DoesEntityExist(entity) then
        return
    end

    exports.ox_target:addLocalEntity(entity, {
        {
            name = 'srp-stealpackage:break-window',
            icon = 'fa-solid fa-hand-fist',
            label = Config.Text.breakWindow,
            bones = { seat.boneName },
            distance = 0.75,
            canInteract = function(targetEntity)
                return IsVehicleWindowIntact(targetEntity, seatWindowMap[seat.boneName])
                    and GetVehicleDoorAngleRatio(targetEntity, seatDoorMap[seat.boneName]) == 0.0
            end,
            onSelect = function(selection)
                local targetEntity = selection.entity
                local netId = VehToNet(targetEntity)
                local windowIndex = seatWindowMap[seat.boneName]

                TaskTurnPedToFaceEntity(cache.ped, targetEntity, 1000)
                Wait(350)
                playBreakWindowAnimation()
                TriggerServerEvent(
                    'srp-stealpackage:server:vehicleSmashWindow',
                    netId,
                    windowIndex,
                    GetSelectedPedWeapon(cache.ped)
                )
            end,
        },
        {
            name = 'srp-stealpackage:steal-package',
            icon = 'fa-solid fa-user-secret',
            label = Config.Text.steal,
            bones = { seat.boneName },
            distance = 0.75,
            canInteract = function(targetEntity)
                return not IsVehicleWindowIntact(targetEntity, seatWindowMap[seat.boneName])
                    or GetVehicleDoorAngleRatio(targetEntity, seatDoorMap[seat.boneName]) ~= 0.0
            end,
            onSelect = function(selection)
                local targetEntity = selection.entity

                if stealingPackage then
                    return
                end

                stealingPackage = true
                TaskTurnPedToFaceEntity(cache.ped, targetEntity, 1000)
                Wait(300)
                playGrabPackageAnimation()

                if DoesEntityExist(targetEntity) and Entity(targetEntity).state[Config.StateBagName] then
                    TriggerServerEvent(
                        'srp-stealpackage:server:vehicleStealPackage',
                        VehToNet(targetEntity)
                    )
                end

                stealingPackage = false
            end,
        },
    })
end

local function vehicleCheck()
    for entityId, data in pairs(vehiclesInScope) do
        if not DoesEntityExist(entityId) then
            cleanupVehicle(entityId, data)
            vehiclesInScope[entityId] = nil
            goto skip
        end

        if not Entity(entityId).state[Config.StateBagName] then
            cleanupVehicle(entityId, data)
            vehiclesInScope[entityId] = nil
            goto skip
        end

        if data.handle and DoesEntityExist(data.handle) then
            goto skip
        end

        prepareVehicle(entityId, data)

        ::skip::
    end
end

CreateThread(function()
    while true do
        local success, exception = pcall(vehicleCheck)

        if not success then
            print(('[srp-stealpackage] vehicle attach loop failed: %s'):format(exception))
        end

        Wait(1000)
    end
end)

local function getAvailableSeat(vehicleEntity, priorityOrder)
    local vehicleSeats = {
        seatPriorityMap[priorityOrder[1]],
        seatPriorityMap[priorityOrder[2]],
        seatPriorityMap[priorityOrder[3]],
    }

    local boneIndexes = {}

    for _, boneName in pairs(vehicleSeats) do
        local boneIndex = GetEntityBoneIndexByName(vehicleEntity, boneName)

        if boneIndex ~= -1 then
            boneIndexes[#boneIndexes + 1] = {
                boneIndex = boneIndex,
                boneName = boneName,
            }
        end
    end

    if #boneIndexes < 1 then
        return false
    end

    return boneIndexes[math.random(1, #boneIndexes)]
end

local function trackVehiclePackage(entity, value)
    if not entity or entity == 0 then
        return
    end

    if vehiclesInScope[entity] then
        cleanupVehicle(entity, vehiclesInScope[entity])
    end

    if not value then
        vehiclesInScope[entity] = nil
        return
    end

    local modelHash = value[1]
    local attach = modelMap[modelHash]

    if not attach then
        return
    end

    local seat = getAvailableSeat(entity, value[2] or {})

    if not seat then
        return
    end

    vehiclesInScope[entity] = {
        modelHash = modelHash,
        seat = seat,
        offset = attach.offset,
        rotation = attach.rotation,
    }
end

AddStateBagChangeHandler(Config.StateBagName, nil, function(bagName, _, value)
    trackVehiclePackage(GetEntityFromStateBagName(bagName), value)
end)

CreateThread(function()
    while true do
        for _, entity in ipairs(GetGamePool('CVehicle')) do
            local value = Entity(entity).state[Config.StateBagName]

            if value and not vehiclesInScope[entity] then
                trackVehiclePackage(entity, value)
            end
        end

        Wait(10000)
    end
end)

RegisterNetEvent('srp-stealpackage:client:vehicleSmashWindow', function(networkId, windowIndex, vehicleCoords)
    local coords = GetEntityCoords(cache.ped)

    if #(coords - vehicleCoords) > 200.0 then
        return
    end

    local entity = NetworkGetEntityFromNetworkId(networkId)

    if not vehiclesInScope[entity] or not DoesEntityExist(entity) then
        return
    end

    local windows = Entity(entity).state.downWindows or {}

    SmashVehicleWindow(entity, windowIndex)

    windows[windowIndex] = true
    Entity(entity).state:set('downWindows', windows, true)
end)

RegisterNetEvent('srp-stealpackage:client:applyBreakWindowDamage', function(amount)
    amount = tonumber(amount) or 0

    if amount <= 0 or amount > 100 then
        return
    end

    local health = GetEntityHealth(cache.ped)

    if health <= 0 then
        return
    end

    SetEntityHealth(cache.ped, math.max(0, health - amount))
end)

local function searchVehicle()
    if not searchKeybindEnabled then
        return
    end

    searchKeybindEnabled = false
    hideTextUI()
    TriggerServerEvent('srp-stealpackage:server:vehicleSearch')
end

AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    Wait(1000)
    exports['pulsar-kbs']:Add(
        searchKeybindId,
        Config.Search.key,
        'keyboard',
        Config.Text.searchKeybindDescription,
        searchVehicle
    )
end)

local function disableKeybinds()
    searchKeybindEnabled = false
end

local function enableKeybinds(skipTextUI)
    if not cache.vehicle or not currentSeat or (currentSeat ~= -1 and currentSeat ~= 0) then
        hideTextUI()
        return
    end

    searchKeybindEnabled = true

    if not skipTextUI then
        showTextUI(Config.Text.searchTextUI:format(searchKeybindId))
    end
end

lib.onCache('seat', function(seatIndex)
    currentSeat = seatIndex
    disableKeybinds()
    enableKeybinds(true)
end)

lib.onCache('vehicle', function(vehicle)
    disableKeybinds()

    if not vehicle then
        hideTextUI()
        return
    end

    enableKeybinds(false)
end)

RegisterNetEvent('srp-stealpackage:client:vehicleKeybindCheck', function(message)
    if message then
        notifyPlayer('info', message)
    end

    disableKeybinds()
    enableKeybinds(true)
end)

CreateThread(function()
    Wait(1000)
    currentSeat = cache.seat

    if cache.vehicle then
        enableKeybinds(false)
    end
end)

exports['pulsar-core']:RegisterClientCallback('srp-stealpackage:client:progress', function(data, cb)
    exports['pulsar-hud']:Progress({
        name = data.name or 'srp_stealpackage',
        duration = data.duration or 5000,
        label = data.label or Config.Text.progressSearch,
        useWhileDead = false,
        canCancel = true,
        ignoreModifier = true,
        vehicle = data.vehicle or false,
        disarm = data.disarm ~= false,
        controlDisables = {
            disableMovement = data.disableMovement or false,
            disableCarMovement = data.disableCarMovement or false,
            disableMouse = false,
            disableCombat = true,
        },
        animation = data.animation or false,
    }, function(cancelled)
        cb(not cancelled)
    end)
end)

RegisterNetEvent('srp-stealpackage:client:receiveStartingData', function(data)
    if data and data.vehicle and data.vehicle.modelMap then
        modelMap = data.vehicle.modelMap
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    for entityId, data in pairs(vehiclesInScope) do
        cleanupVehicle(entityId, data)
    end

    hideTextUI()
end)
