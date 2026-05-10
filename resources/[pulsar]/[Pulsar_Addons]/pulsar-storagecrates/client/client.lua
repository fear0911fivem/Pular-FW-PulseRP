

_crates = _crates or {} -- crateId -> { entity, coords, heading, model } (global for target.lua)

-- Request crates when resource starts or player spawns
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    CreateThread(function()
        Wait(3000) -- Wait for everything to initialize
        TriggerServerEvent('StorageCrates:Server:RequestCrates')
    end)
end)

-- Also request crates when player spawns
AddEventHandler('Characters:Client:Spawned', function()
    CreateThread(function()
        Wait(2000) -- Wait for character to fully load
        TriggerServerEvent('StorageCrates:Server:RequestCrates')
    end)
end)

-- Resync crates when routing bucket changes (enter/exit properties/shells)
RegisterNetEvent('Routing:Client:NewRoute', function(route)
    CreateThread(function()
        -- Give the routing change a moment to settle before requesting sync
        Wait(500)
        TriggerServerEvent('StorageCrates:Server:RequestCrates')
    end)
end)

-- Helper references
local Callbacks = {}
function Callbacks:ServerCallback(name, data, cb)
    exports["pulsar-core"]:ServerCallback(name, data, cb)
end

-- Helper function to load model
function LoadModel(model)
    RequestModel(model)
    local timeout = 0
    while not HasModelLoaded(model) do
        Wait(10)
        timeout = timeout + 1
        if timeout > 500 then -- ~5s
            print("[STORAGE-CRATES CLIENT] ERROR: Model failed to load:", model)
            return false
        end
    end
    return true
end

local function NormalizeModel(model)
    if not model then return nil end
    if type(model) == "string" then
        local asNumber = tonumber(model)
        if asNumber then return asNumber end
        return GetHashKey(model)
    end
    return model
end

_setupBusy = _setupBusy or false

RegisterNetEvent('StorageCrates:Client:SetupCrates', function(crates)
    CreateThread(function()
        if _setupBusy then return end
        _setupBusy = true

        if not crates or next(crates) == nil then
            print("[STORAGE-CRATES CLIENT] Received empty crates table")
            _setupBusy = false
            return
        end

        local crateCount = 0
        for _ in pairs(crates) do crateCount = crateCount + 1 end
        print("[STORAGE-CRATES CLIENT] Received " .. crateCount .. " crates")

        -- Remove tracked crates that are no longer in the payload
        for crateId, crateData in pairs(_crates) do
            if not crates[crateId] then
                if crateData.entity and DoesEntityExist(crateData.entity) then
                    NetworkRequestControlOfEntity(crateData.entity)
                    SetEntityAsMissionEntity(crateData.entity, true, true)
                    DeleteEntity(crateData.entity)
                    if DoesEntityExist(crateData.entity) then
                        DeleteObject(crateData.entity)
                    end
                end
                _crates[crateId] = nil
            end
        end

        for crateId, crateData in pairs(crates) do
            if not crateData then
                print("[STORAGE-CRATES CLIENT] WARNING: crateData is nil for crateId:", crateId)
                goto continue
            end
            
            if _crates[crateId] and _crates[crateId].entity and DoesEntityExist(_crates[crateId].entity) then
                print("[STORAGE-CRATES CLIENT] Crate already spawned:", crateId, "skipping")
                goto continue
            end
            
            if not crateData.coords or not crateData.coords.x then
                print("[STORAGE-CRATES CLIENT] WARNING: Invalid coords for crateId:", crateId, "coords type:", type(crateData.coords))
                goto continue
            end
            
            local model = NormalizeModel(crateData.model)
            if not model then
                print("[STORAGE-CRATES CLIENT] WARNING: No model for crateId:", crateId)
                goto continue
            end

            if not LoadModel(model) then
                print("[STORAGE-CRATES CLIENT] ERROR: Skipping crate due to model load failure:", crateId, model)
                goto continue
            end
            
            print("[STORAGE-CRATES CLIENT] Creating crate " .. crateId .. " at coords: " .. crateData.coords.x .. ", " .. crateData.coords.y .. ", " .. crateData.coords.z)
            
           
            local obj = CreateObject(model, crateData.coords.x, crateData.coords.y, crateData.coords.z, true, true, false)
            SetEntityHeading(obj, crateData.heading or 0.0)
            
            local timeout = 0
            while not DoesEntityExist(obj) and timeout < 100 do
                Wait(10)
                timeout = timeout + 1
            end
            
            if not DoesEntityExist(obj) then
                print("[STORAGE-CRATES CLIENT] ERROR: Failed to create entity for crate:", crateId)
                goto continue
            end
            
            
            local netId = NetworkGetNetworkIdFromEntity(obj)
            while not NetworkDoesNetworkIdExist(netId) do
                Wait(10)
            end
            
            _crates[crateId] = {
                entity = obj,
                coords = crateData.coords,
                heading = crateData.heading,
                model = model,
                netId = netId,
            }
            
          
            SetEntityAsMissionEntity(obj, true, true) 
            FreezeEntityPosition(obj, true)
            SetEntityCollision(obj, true, true)
            Wait(200)
            Entity(obj).state:set('isStorageCrate', true, true)
            Entity(obj).state:set('storageCrateId', crateId, true)
            
            -- Verify and retry state if needed
            Wait(100)
            local stateCheck = Entity(obj).state.isStorageCrate
            if not stateCheck then
                print("[STORAGE-CRATES CLIENT] WARNING: Entity state not set properly for crate:", crateId, "retrying...")
                Entity(obj).state:set('isStorageCrate', true, true)
                Entity(obj).state:set('storageCrateId', crateId, true)
            end
            print("[STORAGE-CRATES CLIENT] Created crate " .. crateId .. " successfully, entity: " .. obj .. ", netId: " .. netId)
            ::continue::
        end
        print("[STORAGE-CRATES CLIENT] Finished setting up " .. crateCount .. " crates")
        _setupBusy = false
        Wait(2000)
        TriggerServerEvent('StorageCrates:Server:RequestCrateInfo')
    end)
end)

RegisterNetEvent('StorageCrates:Client:SpawnCrate', function(crateId, data)
    print("[STORAGE-CRATES CLIENT] Spawning crate:", crateId)
    if _crates[crateId] then 
        print("[STORAGE-CRATES CLIENT] Crate already spawned:", crateId)
        return 
    end
    local model = NormalizeModel(data.model)
    if not model then
        print("[STORAGE-CRATES CLIENT] ERROR: No model for SpawnCrate:", crateId)
        return
    end
    if not LoadModel(model) then
        print("[STORAGE-CRATES CLIENT] ERROR: Model failed to load for SpawnCrate:", crateId, model)
        return
    end
    local obj = CreateObject(model, data.coords.x, data.coords.y, data.coords.z, true, true, false)
    SetEntityHeading(obj, data.heading)
    local timeout = 0
    while not DoesEntityExist(obj) and timeout < 50 do
        Wait(10)
        timeout = timeout + 1
    end
    if DoesEntityExist(obj) then
        print("[STORAGE-CRATES CLIENT] Crate entity created successfully:", crateId, "entity:", obj)
        _crates[crateId] = {
            entity = obj,
            coords = data.coords,
            heading = data.heading,
            model = model,
            netId = NetworkGetNetworkIdFromEntity(obj),
        }
        Entity(obj).state:set('isStorageCrate', true, true)
        Entity(obj).state:set('storageCrateId', crateId, true)
        
        FreezeEntityPosition(obj, true)
        SetEntityAsMissionEntity(obj, true, true) -- Prevents auto-cleanup
        Wait(1000) -- Small delay to ensure entity is fully networked
        TriggerServerEvent('StorageCrates:Server:RequestCrateInfo')
    else
        print("[STORAGE-CRATES CLIENT] ERROR: Failed to create crate entity:", crateId)
    end
end)

local function DeleteCrateEntity(crateId, snap)
    local crateData = _crates and _crates[crateId]
    local entity = crateData and crateData.entity
    local removed = false

    if (not entity or not DoesEntityExist(entity)) and crateData and crateData.netId then
        local entFromNet = NetworkGetEntityFromNetworkId(crateData.netId)
        if entFromNet and DoesEntityExist(entFromNet) then
            entity = entFromNet
        end
    end

    if entity and DoesEntityExist(entity) then
        local tries = 0
        while not NetworkHasControlOfEntity(entity) and tries < 50 do
            NetworkRequestControlOfEntity(entity)
            Wait(10)
            tries = tries + 1
        end

        SetEntityAsMissionEntity(entity, true, true)
        FreezeEntityPosition(entity, false)
        DeleteEntity(entity)
        if DoesEntityExist(entity) then
            DeleteObject(entity)
        end
        removed = DoesEntityExist(entity) == false
    end

    local sweepCoords = (snap and snap.coords) or (crateData and crateData.coords)
    local sweepModel = NormalizeModel((snap and snap.model) or (crateData and crateData.model))

    if crateData then
        _crates[crateId] = nil
    end

    if sweepCoords and sweepModel and LoadModel(sweepModel) then
        for _ = 1, 4 do
            local closest = GetClosestObjectOfType(sweepCoords.x + 0.0, sweepCoords.y + 0.0, sweepCoords.z + 0.0, 5.0, sweepModel, false, false, false)
            if not closest or closest == 0 or not DoesEntityExist(closest) then break end

            local tries = 0
            while not NetworkHasControlOfEntity(closest) and tries < 25 do
                NetworkRequestControlOfEntity(closest)
                Wait(10)
                tries = tries + 1
            end
            SetEntityAsMissionEntity(closest, true, true)
            FreezeEntityPosition(closest, false)
            DeleteEntity(closest)
            if DoesEntityExist(closest) then
                DeleteObject(closest)
            end
        end
    end
end

RegisterNetEvent('StorageCrates:Client:RemoveCrate', function(crateId, snap)
    if _targets and _targets[crateId] then
        local entity = _targets[crateId]
        if DoesEntityExist(entity) then
            pcall(function()
                exports.ox_target:removeLocalEntity(entity)
            end)
        end
        _targets[crateId] = nil
    end
    DeleteCrateEntity(crateId, snap)
end)

CreateThread(function()
    while true do
        Wait(2000) -- Check every 2 seconds
        for crateId, crateData in pairs(_crates) do
            if crateData.coords then
                local playerCoords = GetEntityCoords(PlayerPedId())
                local crateCoords = vector3(crateData.coords.x, crateData.coords.y, crateData.coords.z)
                local distance = #(playerCoords - crateCoords)
                if distance < 500.0 then
                    if crateData.entity and DoesEntityExist(crateData.entity) then
                        -- Make sure it stays frozen and as mission entity
                        if not IsEntityAMissionEntity(crateData.entity) then
                            SetEntityAsMissionEntity(crateData.entity, true, true)
                        end
                        FreezeEntityPosition(crateData.entity, true)
                        SetEntityCollision(crateData.entity, true, true)
                        if not Entity(crateData.entity).state.isStorageCrate then
                            Entity(crateData.entity).state:set('isStorageCrate', true, true)
                            Entity(crateData.entity).state:set('storageCrateId', crateId, true)
                        end
                    else
                        -- Entity disappeared, recreate it
                        print("[STORAGE-CRATES CLIENT] Entity missing for crate:", crateId, "recreating...")
                        local model = NormalizeModel(crateData.model)
                        if not model then
                            print("[STORAGE-CRATES CLIENT] ERROR: Missing model for recreate:", crateId)
                        elseif not LoadModel(model) then
                            print("[STORAGE-CRATES CLIENT] ERROR: Model failed to load for recreate:", crateId, model)
                        else
                            local obj = CreateObject(model, crateData.coords.x, crateData.coords.y, crateData.coords.z, true, true, false)
                            SetEntityHeading(obj, crateData.heading or 0.0)
                            
                            local timeout = 0
                            while not DoesEntityExist(obj) and timeout < 100 do
                                Wait(10)
                                timeout = timeout + 1
                            end
                            
                            if DoesEntityExist(obj) then
                                local netId = NetworkGetNetworkIdFromEntity(obj)
                                while not NetworkDoesNetworkIdExist(netId) do
                                    Wait(10)
                                end
                                
                                _crates[crateId].entity = obj
                                _crates[crateId].netId = netId
                                
                                SetEntityAsMissionEntity(obj, true, true)
                                FreezeEntityPosition(obj, true)
                                SetEntityCollision(obj, true, true)
                                
                                Wait(200)
                                Entity(obj).state:set('isStorageCrate', true, true)
                                Entity(obj).state:set('storageCrateId', crateId, true)
                                
                                print("[STORAGE-CRATES CLIENT] Recreated crate:", crateId, "entity:", obj)
                            else
                                print("[STORAGE-CRATES CLIENT] ERROR: Failed to recreate entity for crate:", crateId)
                            end
                        end
                    end
                end
            end
        end
    end
end)


RegisterNetEvent('StorageCrates:Client:OpenStash', function(stashId)
    print("[STORAGE-CRATES CLIENT] Opening stash:", stashId)
    if not stashId or (type(stashId) ~= 'string' and type(stashId) ~= 'number') then
        warn('[pulsar-storagecrates] Invalid stashId:', stashId)
        return
    end
    if exports.ox_inventory and exports.ox_inventory.openInventory then
        local success = pcall(function()
            exports.ox_inventory:openInventory('stash', stashId)
        end)
        if not success then
            TriggerEvent('ox_inventory:openInventory', 'stash', stashId)
        end
    else
        TriggerEvent('ox_inventory:openInventory', 'stash', stashId)
    end
end)

RegisterNetEvent('ox_inventory:closeInventory', function()
    TriggerServerEvent('StorageCrates:Server:InventoryClosed')
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    print("[STORAGE-CRATES CLIENT] Resource stopping, cleaning up props...")
    for crateId, crateData in pairs(_crates) do
        if crateData.entity and DoesEntityExist(crateData.entity) then
            DeleteObject(crateData.entity)
            print("[STORAGE-CRATES CLIENT] Deleted prop for crate:", crateId)
        end
    end
    for k in pairs(_crates) do
        _crates[k] = nil
    end
    print("[STORAGE-CRATES CLIENT] Cleanup complete")
end)

