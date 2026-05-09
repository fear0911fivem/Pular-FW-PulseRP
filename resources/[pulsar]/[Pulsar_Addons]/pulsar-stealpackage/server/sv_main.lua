local Config = SRPStealPackage

local activePackages = {}
local packageCooldowns = {}
local searchedVehicles = {}
local sourceSearchCooldowns = {}
local windowCooldowns = {}
local packageBusy = {}
local searchBusy = {}

local function debugPrint(message)
    if Config.Debug then
        print(('[srp-stealpackage] %s'):format(message))
    end
end

local function notify(source, ntype, message, duration)
    exports['pulsar-hud']:Notification(source, ntype or 'info', message, duration or 5000)
end

local function getVehicleState(vehicle)
    if not DoesEntityExist(vehicle) then
        return nil
    end

    local entity = Entity(vehicle)
    return entity and entity.state or nil
end

local function setVehiclePackageState(vehicle, value)
    local state = getVehicleState(vehicle)

    if state then
        state:set(Config.StateBagName, value, true)
    end
end

local function getVehicleNetId(vehicle)
    if not DoesEntityExist(vehicle) then
        return nil
    end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)

    if not netId or netId == 0 then
        return nil
    end

    return netId
end

local function ensureLocalVehicleState(vehicle)
    local state = getVehicleState(vehicle)

    if state and not state.VIN then
        TriggerEvent('Vehicles:Server:GenerateVehicleInfo', vehicle)
        state = getVehicleState(vehicle)
    end

    return state
end

local function getVehicleKey(vehicle)
    local state = ensureLocalVehicleState(vehicle)

    if state and state.VIN then
        return state.VIN
    end

    return ('net:%s'):format(getVehicleNetId(vehicle) or vehicle)
end

local function isAllowedVehicleType(vehicle)
    if Config.ExcludedModels[GetEntityModel(vehicle)] then
        return false
    end

    if GetVehicleType then
        local vehicleType = GetVehicleType(vehicle)

        if vehicleType and Config.ExcludedVehicleTypes[vehicleType] then
            return false
        end
    end

    return true
end

local function isLocalVehicle(vehicle)
    local state = ensureLocalVehicleState(vehicle)

    if not state then
        return false
    end

    return not state.Owned and not state.SpawnTemp and not state.IsProtected and not state.Deleted
end

local function getActivePackageCount()
    local count = 0

    for _ in pairs(activePackages) do
        count = count + 1
    end

    return count
end

local function addStress(source, amount)
    if amount and amount > 0 and GetResourceState('pulsar-status') == 'started' then
        exports['pulsar-status']:Add(source, 'PLAYER_STRESS', amount)
    end
end

local function damagePlayerForBrokenWindow(source, ped, clientWeaponHash)
    local damage = Config.BreakWindow.handDamage or 0

    if damage <= 0 then
        return
    end

    local weaponHash = clientWeaponHash

    if GetSelectedPedWeapon then
        weaponHash = GetSelectedPedWeapon(ped)
    end

    if Config.BreakWindow.damageBypassWeapons and Config.BreakWindow.damageBypassWeapons[weaponHash] then
        return
    end

    TriggerClientEvent('srp-stealpackage:client:applyBreakWindowDamage', source, damage)
    notify(source, 'error', Config.Text.breakWindowDamage:format(damage), 3500)
end

local function triggerPoliceAlert(source, vehicle, title, chance)
    if not chance or chance <= 0 or math.random(100) > chance then
        return
    end

    if GetResourceState('pulsar-robbery') ~= 'started' then
        return
    end

    local coords = GetEntityCoords(vehicle)

    exports['pulsar-robbery']:TriggerPDAlert(source, coords, '10-60', title, {
        icon = 225,
        size = 0.9,
        color = 1,
        duration = 60 * 5,
    }, {
        icon = 'car',
        details = 'Vehicle Theft',
    }, 'srp-stealpackage')
end

local function addInventoryItem(source, itemName, count, metadata)
    local char = exports['pulsar-characters']:FetchCharacterSource(source)

    if not char then
        return false
    end

    return exports.ox_inventory:AddItem(char:GetData('SID'), itemName, count or 1, metadata or {}, 1)
end

local function getItemLabel(itemName)
    local itemData = exports.ox_inventory:ItemsGetData(itemName)
    return itemData and itemData.label or itemName
end

local function randomLoot()
    local totalWeight = Config.Search.nothingWeight or 0

    for _, entry in ipairs(Config.Search.loot) do
        totalWeight = totalWeight + entry.weight
    end

    local roll = math.random(1, totalWeight)

    if roll <= (Config.Search.nothingWeight or 0) then
        return nil
    end

    roll = roll - (Config.Search.nothingWeight or 0)

    for _, entry in ipairs(Config.Search.loot) do
        if roll <= entry.weight then
            local min = entry.min or 1
            local max = entry.max or min
            local count = math.random(min, max)

            return entry.item, count
        end

        roll = roll - entry.weight
    end

    return nil
end

local function clearPackage(netId, cooldown)
    local data = activePackages[netId]
    local vehicle = data and data.vehicle or NetworkGetEntityFromNetworkId(netId)

    if vehicle and DoesEntityExist(vehicle) then
        if cooldown then
            packageCooldowns[getVehicleKey(vehicle)] = os.time() + Config.Package.vehicleCooldown
        end

        setVehiclePackageState(vehicle, nil)
    end

    activePackages[netId] = nil
    packageBusy[netId] = nil
end

local function cleanupPackages()
    local now = os.time()

    for key, expires in pairs(packageCooldowns) do
        if expires <= now then
            packageCooldowns[key] = nil
        end
    end

    for key, expires in pairs(searchedVehicles) do
        if expires <= now then
            searchedVehicles[key] = nil
        end
    end

    for netId, data in pairs(activePackages) do
        local vehicle = data.vehicle
        local state = vehicle and getVehicleState(vehicle) or nil

        if not vehicle or not DoesEntityExist(vehicle) then
            clearPackage(netId, false)
        elseif data.expires <= now then
            clearPackage(netId, true)
        elseif not state or not state[Config.StateBagName] then
            clearPackage(netId, false)
        end
    end
end

local function isNearAnyPlayer(vehicle)
    local coords = GetEntityCoords(vehicle)

    for _, playerId in ipairs(GetPlayers()) do
        local ped = GetPlayerPed(tonumber(playerId))

        if ped and ped ~= 0 and DoesEntityExist(ped) then
            if #(coords - GetEntityCoords(ped)) <= Config.Package.maxPlayerDistance then
                return true
            end
        end
    end

    return false
end

local function canSeedPackage(vehicle)
    if not DoesEntityExist(vehicle) or GetEntityType(vehicle) ~= 2 then
        return false
    end

    local netId = getVehicleNetId(vehicle)

    if not netId or activePackages[netId] then
        return false
    end

    local state = getVehicleState(vehicle)

    if state and state[Config.StateBagName] then
        return false
    end

    if not isAllowedVehicleType(vehicle) or not isLocalVehicle(vehicle) then
        return false
    end

    if packageCooldowns[getVehicleKey(vehicle)] then
        return false
    end

    return isNearAnyPlayer(vehicle)
end

local function seedPackage(vehicle)
    local netId = getVehicleNetId(vehicle)

    if not netId then
        return
    end

    local priorities = Config.Package.seatPriorities
    local priority = priorities[math.random(1, #priorities)]
    local models = Config.Package.models or { Config.Package.model }

    if #models < 1 then
        return
    end

    local model = models[math.random(1, #models)]

    if not model then
        return
    end

    activePackages[netId] = {
        vehicle = vehicle,
        expires = os.time() + Config.Package.expiresAfter,
    }

    setVehiclePackageState(vehicle, {
        model,
        priority,
    })

    debugPrint(('seeded package on netId %s'):format(netId))
end

local function scanVehicles()
    if GetResourceState('pulsar-vehicles') ~= 'started' then
        return
    end

    cleanupPackages()

    if getActivePackageCount() >= Config.Package.maxActive then
        return
    end

    local vehicles = GetAllVehicles()

    for i = #vehicles, 2, -1 do
        local j = math.random(i)
        vehicles[i], vehicles[j] = vehicles[j], vehicles[i]
    end

    for _, vehicle in ipairs(vehicles) do
        if getActivePackageCount() >= Config.Package.maxActive then
            break
        end

        if canSeedPackage(vehicle) and math.random(100) <= Config.Package.spawnChance then
            seedPackage(vehicle)
        end
    end
end

CreateThread(function()
    Wait(10000)

    while true do
        local success, err = pcall(scanVehicles)

        if not success then
            print(('[srp-stealpackage] vehicle scan failed: %s'):format(err))
        end

        Wait(Config.Package.scanInterval)
    end
end)

RegisterNetEvent('srp-stealpackage:server:vehicleSmashWindow', function(netId, windowIndex, weaponHash)
    local source = source

    if type(netId) ~= 'number' or type(windowIndex) ~= 'number' then
        return
    end

    if windowIndex < 1 or windowIndex > 3 then
        return
    end

    local vehicle = NetworkGetEntityFromNetworkId(netId)

    if not vehicle or not DoesEntityExist(vehicle) or not activePackages[netId] then
        return
    end

    local ped = GetPlayerPed(source)

    if #(GetEntityCoords(ped) - GetEntityCoords(vehicle)) > Config.BreakWindow.maxDistance then
        return
    end

    local cooldownKey = ('%s:%s'):format(source, netId)

    if windowCooldowns[cooldownKey] and windowCooldowns[cooldownKey] > os.time() then
        return
    end

    windowCooldowns[cooldownKey] = os.time() + Config.BreakWindow.cooldown

    TriggerClientEvent(
        'srp-stealpackage:client:vehicleSmashWindow',
        -1,
        netId,
        windowIndex,
        GetEntityCoords(vehicle)
    )

    addStress(source, Config.BreakWindow.stress)
    damagePlayerForBrokenWindow(source, ped, weaponHash)
    triggerPoliceAlert(source, vehicle, 'Vehicle Break-In', Config.BreakWindow.policeAlertChance)
end)

RegisterNetEvent('srp-stealpackage:server:vehicleStealPackage', function(netId)
    local source = source

    if type(netId) ~= 'number' then
        return
    end

    local vehicle = NetworkGetEntityFromNetworkId(netId)

    if not vehicle or not DoesEntityExist(vehicle) or not activePackages[netId] then
        return notify(source, 'error', Config.Text.packageMissing)
    end

    if packageBusy[netId] then
        return notify(source, 'error', Config.Text.packageBusy)
    end

    local ped = GetPlayerPed(source)

    if #(GetEntityCoords(ped) - GetEntityCoords(vehicle)) > Config.Package.maxInteractDistance then
        return notify(source, 'error', Config.Text.tooFar)
    end

    packageBusy[netId] = source

    if not addInventoryItem(source, Config.Package.item, 1, {}) then
        packageBusy[netId] = nil
        return notify(source, 'error', Config.Text.addFailed)
    end

    clearPackage(netId, true)
    addStress(source, Config.Package.stress)
    triggerPoliceAlert(source, vehicle, 'Vehicle Package Theft', Config.Package.policeAlertChance)
    notify(source, 'success', Config.Text.packageStolen)
end)

RegisterNetEvent('srp-stealpackage:server:vehicleSearch', function()
    local source = source
    local now = os.time()

    if sourceSearchCooldowns[source] and sourceSearchCooldowns[source] > now then
        return TriggerClientEvent('srp-stealpackage:client:vehicleKeybindCheck', source)
    end

    sourceSearchCooldowns[source] = now + Config.Search.sourceCooldown

    local ped = GetPlayerPed(source)
    local vehicle = GetVehiclePedIsIn(ped, false)

    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
        return TriggerClientEvent('srp-stealpackage:client:vehicleKeybindCheck', source, Config.Text.notInsideVehicle)
    end

    if not isAllowedVehicleType(vehicle) then
        return TriggerClientEvent('srp-stealpackage:client:vehicleKeybindCheck', source, Config.Text.vehicleCannotBeSearched)
    end

    if not isLocalVehicle(vehicle) then
        return TriggerClientEvent('srp-stealpackage:client:vehicleKeybindCheck', source, Config.Text.vehicleOwned)
    end

    local key = getVehicleKey(vehicle)

    if searchedVehicles[key] and searchedVehicles[key] > now then
        return TriggerClientEvent('srp-stealpackage:client:vehicleKeybindCheck', source, Config.Text.alreadySearched)
    end

    if searchBusy[key] then
        return TriggerClientEvent('srp-stealpackage:client:vehicleKeybindCheck', source, Config.Text.vehicleCannotBeSearched)
    end

    searchBusy[key] = source

    exports['pulsar-core']:ClientCallback(source, 'srp-stealpackage:client:progress', {
        name = 'srp_search_vehicle',
        duration = Config.Search.duration,
        label = Config.Text.progressSearch,
        vehicle = true,
        disableCarMovement = true,
        disarm = false,
    }, function(success)
        searchBusy[key] = nil

        if not success then
            return TriggerClientEvent('srp-stealpackage:client:vehicleKeybindCheck', source)
        end

        ped = GetPlayerPed(source)
        local currentVehicle = GetVehiclePedIsIn(ped, false)

        if currentVehicle ~= vehicle or not DoesEntityExist(vehicle) then
            return TriggerClientEvent('srp-stealpackage:client:vehicleKeybindCheck', source, Config.Text.notInsideVehicle)
        end

        if not isLocalVehicle(vehicle) then
            return TriggerClientEvent('srp-stealpackage:client:vehicleKeybindCheck', source, Config.Text.vehicleOwned)
        end

        searchedVehicles[key] = os.time() + Config.Search.cooldown

        local itemName, count = randomLoot()

        addStress(source, Config.Search.stress)
        triggerPoliceAlert(source, vehicle, 'Vehicle Search', Config.Search.policeAlertChance)

        if not itemName then
            return TriggerClientEvent('srp-stealpackage:client:vehicleKeybindCheck', source, Config.Text.searchNothing)
        end

        local state = getVehicleState(vehicle) or {}
        local metadata = {
            VIN = state.VIN,
            Plate = GetVehicleNumberPlateText(vehicle),
        }

        if not addInventoryItem(source, itemName, count, metadata) then
            return TriggerClientEvent('srp-stealpackage:client:vehicleKeybindCheck', source, Config.Text.addFailed)
        end

        TriggerClientEvent(
            'srp-stealpackage:client:vehicleKeybindCheck',
            source,
            Config.Text.foundItem:format(count, getItemLabel(itemName))
        )
    end)
end)

lib.callback.register('srp-stealpackage:server:adminVehicleGet', function()
    local vehicles = {}

    for netId, data in pairs(activePackages) do
        if data.vehicle and DoesEntityExist(data.vehicle) then
            vehicles[#vehicles + 1] = {
                netId = netId,
                coords = GetEntityCoords(data.vehicle),
            }
        end
    end

    return vehicles
end)

AddEventHandler('playerDropped', function()
    local source = source

    sourceSearchCooldowns[source] = nil

    for netId, busySource in pairs(packageBusy) do
        if busySource == source then
            packageBusy[netId] = nil
        end
    end

    for key, busySource in pairs(searchBusy) do
        if busySource == source then
            searchBusy[key] = nil
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    local packageNetIds = {}

    for netId in pairs(activePackages) do
        packageNetIds[#packageNetIds + 1] = netId
    end

    for _, netId in ipairs(packageNetIds) do
        clearPackage(netId, false)
    end
end)
