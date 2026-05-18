local _vehStores = {}
ACTIVE_OWNED_VEHICLES = {} -- Vehicles that need synced to the DB
ACTIVE_OWNED_VEHICLES_SPAWNERS = {}

VEHICLES_PENDING_PROPERTIES = {}

LICENSE_PLATE_DATA = {}

_savedVehicleProperties = {}

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(1000)
        exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-vehicles')
        RegisterCallbacks()
        RegisterMiddleware()
        RegisterPersonalPlateCallbacks()
        RegisterChatCommands()
        Startup()
    end
end)

function RegisterMiddleware()
    exports['pulsar-core']:MiddlewareAdd('Characters:Spawning', function(source)
        local id = exports['pulsar-characters']:FetchCharacterSource(source):GetData('SID')
        if VEHICLE_KEYS[id] == nil then
            VEHICLE_KEYS[id] = {}
        end
        TriggerClientEvent('Vehicles:Client:UpdateKeys', source, VEHICLE_KEYS[id])
    end, 5)

    -- exports['pulsar-core']:MiddlewareAdd('playerDropped', function(source)
    --     local sourceSpawnVehicles = ACTIVE_OWNED_VEHICLES_SPAWNERS[source]
    --     if sourceSpawnVehicles and #sourceSpawnVehicles > 0 then
    --         for k, v in ipairs(sourceSpawnVehicles) do
    --             exports['pulsar-vehicles']:OwnedForceSave(v)
    --         end

    --         ACTIVE_OWNED_VEHICLES_SPAWNERS[source] = nil
    --     end
    -- end)
end

-- If the vehicle doesn't have it's properties saved, they are sent to the server
RegisterNetEvent('Vehicles:Server:PlayerSetProperties', function(veh, properties)
    if veh and DoesEntityExist(veh) and VEHICLES_PENDING_PROPERTIES[veh] and type(properties) == 'table' then
        local vState = Entity(veh).state
        if vState and vState.VIN then
            local vData = exports['pulsar-vehicles']:OwnedGetActive(vState.VIN)
            if vData then
                vData:SetData('Properties', properties)
                vData:SetData('FirstSpawn', false)
                VEHICLES_PENDING_PROPERTIES[veh] = nil
                SaveVehicle(vState.VIN)
            elseif vState.IsProtected then
                _savedVehicleProperties[vState.VIN] = properties
                VEHICLES_PENDING_PROPERTIES[veh] = nil
            end
        end
    end
end)

local tempVehicleStoreShit = { '_id', 'VIN', 'EntityId', 'LastSave', 'Flags', 'Strikes', 'GovAssigned', 'ModelType' }

function SaveVehicle(VIN)
    local veh = exports['pulsar-vehicles']:OwnedGetActive(VIN)
    if veh then
        local vehEnt = veh:GetData('EntityId')
        local vehState = Entity(vehEnt).state

        veh:SetData('DirtLevel', GetVehicleDirtLevel(vehEnt))

        veh:SetData('Fuel', tonumber(vehState.Fuel))
        veh:SetData('Damage', vehState.Damage)
        veh:SetData('DamagedParts', vehState.DamagedParts)
        veh:SetData('Mileage', vehState.Mileage)
        veh:SetData('Polish', vehState.Polish)
        veh:SetData('PurgeColor', vehState.PurgeColor)
        veh:SetData('PurgeLocation', vehState.PurgeLocation)

        if vehState.Harness ~= nil then
            veh:SetData('Harness', vehState.Harness)
        end

        if vehState.Nitrous ~= nil then
            veh:SetData('Nitrous', vehState.Nitrous)
        end

        if vehState.neonsDisabled ~= nil then
            veh:SetData('NeonsDisabled', vehState.neonsDisabled)
        end

        local data = veh:GetData()
        local VIN = veh:GetData('VIN')

        for k, v in ipairs(tempVehicleStoreShit) do
            data[v] = nil
        end

        veh:SetData('LastSave', os.time())

        local updateData = {
            Type = data.Type or 0,
            Make = data.Make or 'Unknown',
            Model = data.Model or 'Unknown',
            RegisteredPlate = data.RegisteredPlate or '',
            OwnerType = data.Owner and data.Owner.Type or data.OwnerType or 0,
            OwnerId = data.Owner and data.Owner.Id or data.OwnerId or 0,
            OwnerWorkplace = data.Owner and data.Owner.Workplace or data.OwnerWorkplace or false,
            StorageType = data.Storage and data.Storage.Type or data.StorageType or 0,
            StorageId = data.Storage and data.Storage.Id or data.StorageId or 0,
            FirstSpawn = data.FirstSpawn or false,
            Mileage = data.Mileage or 0,
            Fuel = tonumber(data.Fuel) or 100,
            DirtLevel = math.min(math.max(data.DirtLevel or 0, 0), 10.0),
            Value = data.Value or 0,
            Class = data.Class or 'Unknown',
            Vehicle = data.Vehicle or 0,
            FakePlate = data.FakePlate or false,
            RegistrationDate = data.RegistrationDate or os.time(),
            Damage = json.encode(data.Damage or {}),
            DamagedParts = json.encode(data.DamagedParts or {}),
            Polish = json.encode(data.Polish or {}),
            PurgeColor = json.encode(data.PurgeColor or {}),
            PurgeLocation = data.PurgeLocation or '',
            Harness = data.Harness or 0,
            Nitrous = data.Nitrous or 0,
            NeonsDisabled = data.NeonsDisabled or false,
            WheelFitment = json.encode(data.WheelFitment or {}),
            Donator = data.Donator or false,
            Seized = data.Seized or false,
            SeizedTime = data.SeizedTime or false,
            Properties = json.encode(data.Properties or {}),
            LastSave = os.time()
        }

        local success = MySQL.update.await(
            "UPDATE vehicles SET " ..
            "Type = ?, Make = ?, Model = ?, RegisteredPlate = ?, " ..
            "OwnerType = ?, OwnerId = ?, OwnerWorkplace = ?, " ..
            "StorageType = ?, StorageId = ?, " ..
            "FirstSpawn = ?, Mileage = ?, Fuel = ?, DirtLevel = ?, " ..
            "Value = ?, Class = ?, Vehicle = ?, FakePlate = ?, RegistrationDate = ?, " ..
            "Damage = ?, DamagedParts = ?, Polish = ?, PurgeColor = ?, " ..
            "PurgeLocation = ?, Harness = ?, Nitrous = ?, NeonsDisabled = ?, " ..
            "WheelFitment = ?, Donator = ?, Seized = ?, SeizedTime = ?, " ..
            "Properties = ?, LastSave = ? WHERE VIN = ?",
            {
                updateData.Type,
                updateData.Make,
                updateData.Model,
                updateData.RegisteredPlate,
                updateData.OwnerType,
                updateData.OwnerId,
                updateData.OwnerWorkplace,
                updateData.StorageType,
                updateData.StorageId,
                updateData.FirstSpawn,
                updateData.Mileage,
                updateData.Fuel,
                updateData.DirtLevel,
                updateData.Value,
                updateData.Class,
                updateData.Vehicle,
                updateData.FakePlate,
                updateData.RegistrationDate,
                updateData.Damage,
                updateData.DamagedParts,
                updateData.Polish,
                updateData.PurgeColor,
                updateData.PurgeLocation,
                updateData.Harness,
                updateData.Nitrous,
                updateData.NeonsDisabled,
                updateData.WheelFitment,
                updateData.Donator,
                updateData.Seized,
                updateData.SeizedTime,
                updateData.Properties,
                updateData.LastSave,
                VIN
            }
        )

        return success
    else
        return false
    end
end

--[[
    ? Owner Types:
    0 = Characters
    1 = Job Fleets


    ? Storage Types:
    0 - Impound
    1 - Garage
    2 - Property

    ? Vehicle Types:
    0 - Regular Car/Truck
    1 - Boat
    2 - Aircraft
]]

exports("StoresCreate", function(id, data)
    data = data or {}
    _vehStores[id] = data

    return {
        Key = id,
        SetData = function(self, var, data)
            _vehStores[self.Key][var] = data
        end,
        GetData = function(self, var)
            if var ~= nil and var ~= "" then
                if _vehStores[self.Key][var] ~= nil then
                    return _vehStores[self.Key][var]
                else
                    return nil
                end
            else
                return _vehStores[self.Key]
            end
        end,
        DeleteStore = function(self)
            exports['pulsar-vehicles']:StoresDelete(self.Key)
        end,
    }
end)

exports("StoresDelete", function(id)
    if _vehStores[id] then
        _vehStores[id] = nil
        collectgarbage()
    end
end)

exports("RandomModelDClass", function()
    return _models.D[math.random(#_models.D)]
end)

exports("RandomModelCClass", function()
    return _models.C[math.random(#_models.C)]
end)

exports("RandomModelBClass", function()
    return _models.B[math.random(#_models.B)]
end)

exports("RandomModelAClass", function()
    return _models.A[math.random(#_models.A)]
end)

exports("RandomModelSClass", function()
    return `taxi`
end)

exports("RandomModelXClass", function()
    return `taxi`
end)

exports("RandomName", function()
    return _vehNamesAll[math.random(#_vehNamesAll)]
end)

exports("RandomNameByMake", function(make)
    local models = _vehNames[make]
    if models then
        return models[math.random(#models)]
    end
end)

exports("GaragesGetAll", function()
    local garages = {}
    for k, v in pairs(_vehicleStorage) do
        garages[k] = {
            label = v.name,
            location = v.coords,
        }
    end
    garages['impound'] = {
        label = _vehicleImpound.name,
        location = _vehicleImpound.coords,
    }
    return garages
end)

exports("GaragesGet", function(id)
    return _vehicleStorage[id]
end)

exports("GaragesImpound", function()
    return _vehicleImpound
end)

exports("OwnedAddToCharacter",
    function(charSID, vehicleHash, vehicleType, modelType, infoData, cb, properties, defaultStorage, suppliedVIN)
        exports['pulsar-vehicles']:OwnedAdd({
            Type = 0,
            Id = charSID
        }, vehicleHash, vehicleType, modelType, infoData, cb, properties, defaultStorage, suppliedVIN)
    end)

exports("OwnedAddToFleet",
    function(jobId, jobWorkplace, vehicleLevel, vehicleHash, vehicleType, modelType, infoData, cb, properties, qual)
        if not properties then
            properties = false
        end

        local defaultStorage = false
        if type(vehicleType) ~= 'number' or vehicleType < 0 or vehicleType > 2 then
            vehicleType = 0
        end

        -- Get the fleet HQ to store vehicles in by default
        for storageId, storageData in pairs(_vehicleStorage) do
            if storageData.fleet then
                for k, v in pairs(storageData.fleet) do
                    if storageData.vehType == vehicleType and v.JobId == jobId and v.HQ then
                        defaultStorage = {
                            Type = 1,
                            Id = storageId,
                        }

                        break
                    end
                end
            end
        end

        exports['pulsar-vehicles']:OwnedAdd({
            Type = 1,
            Id = jobId,
            Workplace = jobWorkplace and jobWorkplace or false,
            Level = (type(vehicleLevel) == 'number') and vehicleLevel or 0,
            Qualification = qual,
        }, vehicleHash, vehicleType, modelType, infoData, cb, properties, defaultStorage)
    end)

-- !!! Should not be used externally
exports("OwnedAdd",
    function(ownerData, vehicleHash, vehicleType, modelType, infoData, cb, properties, defaultStorageData, suppliedVIN)
        if type(vehicleType) ~= 'number' or vehicleType < 0 or vehicleType > 2 then
            vehicleType = 0
        end

        if ownerData and ownerData.Type and ownerData.Id and type(vehicleHash) == 'number' and type(infoData) == 'table' then
            -- Detemining Default Storage Data
            local storageData = false
            if type(defaultStorageData) == 'table' and defaultStorageData.Type and defaultStorageData.Id then
                storageData = defaultStorageData
            else
                storageData = GetVehicleTypeDefaultStorage(vehicleType)
            end

            local plate = false
            if vehicleType == 0 then
                plate = exports['pulsar-vehicles']:PlateGenerate()
            end

            local VIN = suppliedVIN
            if not VIN then
                VIN = exports['pulsar-vehicles']:VINGenerateOwned()
            end

            local doc = {
                Type = vehicleType,
                Vehicle = vehicleHash,
                ModelType = modelType,
                VIN = VIN,
                RegisteredPlate = plate,
                FakePlate = false,
                Fuel = math.random(90, 100),
                OwnerType = ownerData.Type,
                OwnerId = ownerData.Id,
                OwnerWorkplace = ownerData.Workplace and ownerData.Workplace or nil,
                OwnerLevel = ownerData.Level or 0,
                StorageType = storageData and storageData.Type or 0,
                StorageId = storageData and storageData.Id or 0,
                Make = infoData.make or 'Unknown',
                Model = infoData.model or 'Unknown',
                Class = infoData.class or 'Unknown',
                Value = infoData.value or false,
                Donator = infoData.donatorFlag,
                FirstSpawn = true,
                Properties = type(properties) == 'table' and properties or false,
                RegistrationDate = os.time(),
                Mileage = 0,
                DirtLevel = 0.0,
            }

            local success = MySQL.insert.await(
                "INSERT INTO vehicles (VIN, Type, Make, Model, RegisteredPlate, OwnerType, OwnerId, OwnerWorkplace, OwnerLevel, StorageType, StorageId, " ..
                "FirstSpawn, Mileage, Fuel, DirtLevel, Value, Class, Vehicle, FakePlate, RegistrationDate, " ..
                "Damage, DamagedParts, Polish, PurgeColor, PurgeLocation, Harness, Nitrous, NeonsDisabled, " ..
                "WheelFitment, Donator, Seized, SeizedTime, Properties, Created, LastSave) " ..
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, FROM_UNIXTIME(?), FROM_UNIXTIME(?))",
                {
                    VIN,
                    vehicleType,
                    doc.Make,
                    doc.Model,
                    plate or '',
                    ownerData.Type,
                    ownerData.Id,
                    ownerData.Workplace and ownerData.Workplace or nil,
                    ownerData.Level or 0,
                    storageData and storageData.Type or 0,
                    storageData and storageData.Id or 0,
                    doc.FirstSpawn or false,
                    doc.Mileage or 0,
                    doc.Fuel or 100,
                    math.min(math.max(doc.DirtLevel or 0, 0), 10.0),
                    doc.Value or 0,
                    doc.Class or 'Unknown',
                    doc.Vehicle or 0,
                    doc.FakePlate or false,
                    doc.RegistrationDate or os.time(),
                    json.encode(doc.Damage or {}),
                    json.encode(doc.DamagedParts or {}),
                    json.encode(doc.Polish or {}),
                    json.encode(doc.PurgeColor or {}),
                    doc.PurgeLocation or '',
                    doc.Harness or 0,
                    doc.Nitrous or 0,
                    doc.NeonsDisabled or false,
                    json.encode(doc.WheelFitment or {}),
                    doc.Donator or false,
                    doc.Seized or false,
                    doc.SeizedTime or false,
                    json.encode(doc.Properties or {}),
                    os.time(),
                    os.time()
                }
            )

            if success then
                doc._id = success
                cb(true, doc)
            else
                cb(false)
            end
        else
            cb(false)
        end
    end)

exports("OwnedGetActive", function(VIN)
    if ACTIVE_OWNED_VEHICLES[VIN] then
        return ACTIVE_OWNED_VEHICLES[VIN]
    end
    return false
end)

exports("OwnedGetVIN", function(VIN, cb)
    local vehicle = MySQL.single.await(
        "SELECT VIN, Type, Make, Model, RegisteredPlate, OwnerType, OwnerId, OwnerWorkplace, StorageType, StorageId, " ..
        "FirstSpawn, Mileage, Fuel, DirtLevel, Value, Class, Vehicle, FakePlate, RegistrationDate, " ..
        "Damage, DamagedParts, Polish, PurgeColor, PurgeLocation, Harness, Nitrous, NeonsDisabled, " ..
        "WheelFitment, Donator, Seized, SeizedTime, Properties, ModelType, OwnerLevel FROM vehicles WHERE VIN = ?",
        { VIN }
    )

    if vehicle then
        if vehicle.Damage and vehicle.Damage ~= "" then
            local success, damage = pcall(json.decode, vehicle.Damage)
            if success and damage then
                vehicle.Damage = damage
            end
        end

        if vehicle.DamagedParts and vehicle.DamagedParts ~= "" then
            local success, damagedParts = pcall(json.decode, vehicle.DamagedParts)
            if success and damagedParts then
                vehicle.DamagedParts = damagedParts
            end
        end

        if vehicle.Polish and vehicle.Polish ~= "" then
            local success, polish = pcall(json.decode, vehicle.Polish)
            if success and polish then
                vehicle.Polish = polish
            end
        end

        if vehicle.PurgeColor and vehicle.PurgeColor ~= "" then
            local success, purgeColor = pcall(json.decode, vehicle.PurgeColor)
            if success and purgeColor then
                vehicle.PurgeColor = purgeColor
            end
        end

        if vehicle.WheelFitment and vehicle.WheelFitment ~= "" then
            local success, wheelFitment = pcall(json.decode, vehicle.WheelFitment)
            if success and wheelFitment then
                vehicle.WheelFitment = wheelFitment
            end
        end

        if vehicle.Properties and vehicle.Properties ~= "" then
            local success, properties = pcall(json.decode, vehicle.Properties)
            if success and properties then
                vehicle.Properties = properties
                
                if properties.GovAssigned then
                    if type(properties.GovAssigned) == 'string' then
                        local govSuccess, govAssigned = pcall(json.decode, properties.GovAssigned)
                        if govSuccess and govAssigned then
                            vehicle.GovAssigned = govAssigned
                        end
                    elseif type(properties.GovAssigned) == 'table' then
                        vehicle.GovAssigned = properties.GovAssigned
                    end
                end

            end
        end

        vehicle.Owner = {
            Type = vehicle.OwnerType,
            Id = vehicle.OwnerId,
            Workplace = vehicle.OwnerWorkplace,
            Level = vehicle.OwnerLevel
        }

        vehicle.Storage = {
            Type = vehicle.StorageType,
            Id = vehicle.StorageId
        }

        local defaultDamagedParts = {
            Axle = 100.0,
            Radiator = 100.0,
            Transmission = 100.0,
            Brakes = 100.0,
            FuelInjectors = 100.0,
            Clutch = 100.0,
            Electronics = 100.0,
        }

        if not vehicle.DamagedParts or type(vehicle.DamagedParts) ~= 'table' then
            vehicle.DamagedParts = defaultDamagedParts
        else
            for k, v in pairs(defaultDamagedParts) do
                if vehicle.DamagedParts[k] == nil then
                    vehicle.DamagedParts[k] = v
                end
            end
        end

        cb(vehicle)
    else
        cb(false)
    end
end)

exports("OwnedGetAll",
    function(vehType, ownerType, ownerId, cb, storageType, storageId, ignoreSpawned, checkFleetOwner, projection)
        local whereConditions = {}
        local params = {}

        if ownerType and ownerId then
            table.insert(whereConditions, "OwnerType = ? AND OwnerId = ?")
            table.insert(params, ownerType)
            table.insert(params, ownerId)
        end

        if checkFleetOwner and checkFleetOwner.Id then
            if checkFleetOwner.Workplace and checkFleetOwner.Workplace ~= false then
                table.insert(whereConditions,
                    "(OwnerType = 1 AND OwnerId = ? AND (OwnerWorkplace = ? OR OwnerWorkplace IS NULL) AND OwnerLevel <= ?)")
                table.insert(params, checkFleetOwner.Id)
                table.insert(params, checkFleetOwner.Workplace)
                table.insert(params, type(checkFleetOwner.Level) == 'number' and checkFleetOwner.Level or 0)
            else
                table.insert(whereConditions,
                    "(OwnerType = 1 AND OwnerId = ? AND OwnerLevel <= ?)")
                table.insert(params, checkFleetOwner.Id)
                table.insert(params, type(checkFleetOwner.Level) == 'number' and checkFleetOwner.Level or 0)
            end
        end

        if storageType ~= nil and storageId ~= nil then
            table.insert(whereConditions, "StorageType = ? AND StorageId = ?")
            table.insert(params, storageType)
            table.insert(params, storageId)
        end

        if type(vehType) == 'number' then
            table.insert(whereConditions, "Type = ?")
            table.insert(params, vehType)
        end

        local whereClause = ""
        if #whereConditions > 0 then
            whereClause = "WHERE " .. table.concat(whereConditions, " AND ")
        end

        local results = MySQL.query.await(
            "SELECT VIN, Type, Make, Model, RegisteredPlate, OwnerType, OwnerId, OwnerWorkplace, StorageType, StorageId, " ..
            "FirstSpawn, Mileage, Fuel, DirtLevel, Value, Class, Vehicle, FakePlate, RegistrationDate, " ..
            "Damage, DamagedParts, Polish, PurgeColor, PurgeLocation, Harness, Nitrous, NeonsDisabled, " ..
            "WheelFitment, Donator, Seized, SeizedTime, Properties, OwnerLevel FROM vehicles " ..
            whereClause,
            params
        )

        if results then
            local vehicles = {}
            for k, v in ipairs(results) do
                if not ignoreSpawned or (ignoreSpawned and not exports['pulsar-vehicles']:OwnedGetActive(v.VIN)) then
                    if v.Damage and v.Damage ~= "" then
                        local success, damage = pcall(json.decode, v.Damage)
                        if success and damage then
                            v.Damage = damage
                        end
                    end

                    if v.DamagedParts and v.DamagedParts ~= "" then
                        local success, damagedParts = pcall(json.decode, v.DamagedParts)
                        if success and damagedParts then
                            v.DamagedParts = damagedParts
                        end
                    end

                    if v.Polish and v.Polish ~= "" then
                        local success, polish = pcall(json.decode, v.Polish)
                        if success and polish then
                            v.Polish = polish
                        end
                    end

                    if v.PurgeColor and v.PurgeColor ~= "" then
                        local success, purgeColor = pcall(json.decode, v.PurgeColor)
                        if success and purgeColor then
                            v.PurgeColor = purgeColor
                        end
                    end

                    if v.WheelFitment and v.WheelFitment ~= "" then
                        local success, wheelFitment = pcall(json.decode, v.WheelFitment)
                        if success and wheelFitment then
                            v.WheelFitment = wheelFitment
                        end
                    end

                    if v.Properties and v.Properties ~= "" then
                        local success, properties = pcall(json.decode, v.Properties)
                        if success and properties then
                            v.Properties = properties
                            
                            if properties.GovAssigned then
                                if type(properties.GovAssigned) == 'string' then
                                    local govSuccess, govAssigned = pcall(json.decode, properties.GovAssigned)
                                    if govSuccess and govAssigned then
                                        v.GovAssigned = govAssigned
                                    end
                                elseif type(properties.GovAssigned) == 'table' then
                                    v.GovAssigned = properties.GovAssigned
                                end
                            end

                        end
                    end

                    v.Owner = {
                        Type = v.OwnerType,
                        Id = v.OwnerId,
                        Workplace = v.OwnerWorkplace,
                        Level = v.OwnerLevel
                    }

                    v.Storage = {
                        Type = v.StorageType,
                        Id = v.StorageId
                    }

                    v.Spawned = exports['pulsar-vehicles']:OwnedGetActive(v.VIN)

                    if v.Storage and v.Storage.Type == 2 then
                        local prop = exports['pulsar-properties']:Get(v.Storage.Id)
                        if prop and prop.id and prop.label then
                            v.PropertyStorage = prop
                        end
                    end

                    table.insert(vehicles, v)
                end
            end

            cb(vehicles)
        else
            cb(false)
        end
    end)

exports("OwnedGetAllActive", function()
    return ACTIVE_OWNED_VEHICLES
end)

exports("OwnedSpawn", function(source, VIN, coords, heading, cb, extraData)
    exports['pulsar-vehicles']:OwnedGetVIN(VIN, function(vehicle)
        if vehicle and not exports['pulsar-vehicles']:OwnedGetActive(VIN) then
            local spawnedVehicle = CreateVehicleFunc(vehicle.ModelType, vehicle.Vehicle, coords,
                (heading and heading + 0.0 or 0.0))
            if spawnedVehicle then
                local vehState = Entity(spawnedVehicle).state

                vehState.ServerEntity = spawnedVehicle
                vehState.Owned = true
                vehState.Owner = vehicle.Owner
                vehState.PlayerDriven = true
                vehState.VIN = vehicle.VIN
                vehState.RegisteredPlate = vehicle.RegisteredPlate
                vehState.Fuel = tonumber(vehicle.Fuel) or 100
                vehState.Locked = true
                SetVehicleDoorsLocked(spawnedVehicle, 2)

                vehState.GroupKeys = false
                if vehicle.Owner and vehicle.Owner.Type == 1 and ((not vehicle.Owner.Workplace) or vehicle.Owner.Id == "police" or vehicle.Owner.Id == "prison" or vehicle.Owner.Id == "ems") then
                    vehState.GroupKeys = vehicle.Owner.Id
                end

                vehState.Make = vehicle.Make
                vehState.Model = vehicle.Model
                vehState.Class = vehicle.Class
                vehState.Value = vehicle.Value
                vehState.Donator = vehicle.Donator

                vehState.Damage = vehicle.Damage
                vehState.DamagedParts = vehicle.DamagedParts
                vehState.Mileage = vehicle.Mileage

                vehState.WheelFitment = vehicle.WheelFitment

                if vehicle.Polish and vehicle.Polish.Expires and vehicle.Polish.Expires > os.time() then
                    vehState.Polish = vehicle.Polish
                end

                if vehicle.PurgeColor then
                    vehState.PurgeColor = vehicle.PurgeColor or { r = 255, g = 255, b = 255 }
                end

                if vehicle.PurgeLocation then
                    vehState.PurgeLocation = vehicle.PurgeLocation or "wheel_rf"
                end

                if vehicle.Harness and vehicle.Harness > 0 then
                    vehState.Harness = vehicle.Harness
                end

                if vehicle.Nitrous ~= nil then
                    vehState.Nitrous = vehicle.Nitrous
                end

                if vehicle.RegisteredPlate then
                    if vehicle.FakePlate and vehicle.FakePlate ~= 0 then
                        local fakePlateStr = vehicle.RegisteredPlate
                        if vehicle.Properties and vehicle.Properties.FakePlate then
                            fakePlateStr = vehicle.Properties.FakePlate
                        end

                        vehState.Plate = fakePlateStr
                        vehState.FakePlate = fakePlateStr
                        SetVehicleNumberPlateText(spawnedVehicle, fakePlateStr)
                    else
                        vehState.Plate = vehicle.RegisteredPlate
                        SetVehicleNumberPlateText(spawnedVehicle, vehicle.RegisteredPlate)
                    end
                else -- Its a heli or boat
                    SetVehicleNumberPlateText(spawnedVehicle, '')
                end

                if vehicle.DirtLevel and type(vehicle.DirtLevel) == 'number' then
                    SetVehicleDirtLevel(spawnedVehicle, vehicle.DirtLevel + 0.0)
                end

                if vehicle.NeonsDisabled then
                    vehState.neonsDisabled = true
                end

                if vehicle.ForcedAudio then
                    vehState.ForcedAudio = vehicle.ForcedAudio
                end

                vehState.Trailer = GetVehicleType(spawnedVehicle) == 'trailer'

                if vehicle.FirstSpawn and not vehicle.Properties then
                    VEHICLES_PENDING_PROPERTIES[spawnedVehicle] = true
                    vehState.awaitingProperties = {
                        needInit = true,
                    }
                elseif vehicle.Properties then
                    vehState.awaitingProperties = {
                        needInit = false,
                        properties = vehicle.Properties,
                        propertiesData = extraData,
                        damage = vehicle.Damage,
                    }
                end

                local vehicleStore = exports['pulsar-vehicles']:StoresCreate(vehicle.VIN, vehicle)

                vehicleStore:SetData('EntityId', spawnedVehicle)

                if vehicle.Properties then
                    vehicleStore:SetData('Properties', vehicle.Properties)
                else
                    local defaultProperties = {
                        windowTint = -1,
                        plateIndex = 0,
                        wheels = 7,
                        interiorColor = 111,
                        wheelColor = 0,
                        color2 = { r = 8, g = 8, b = 8 },
                        pearlescentColor = 16,
                        tyreSmokeColor = { r = 255, g = 255, b = 255 },
                        livery = -1,
                        neonColor = { r = 255, g = 255, b = 255 },
                        mods = {
                            trimB = -1,
                            sideSkirt = -1,
                            brakes = -1,
                            doorSpeaker = -1,
                            windows = -1,
                            vanityPlate = -1,
                            airFilter = -1,
                            xenonColor = 255,
                            roof = -1,
                            frontWheels = -1,
                            frame = -1,
                            exhaust = -1,
                            suspension = -1,
                            grille = -1,
                            steeringWheel = -1,
                            spoilers = -1,
                            transmission = -1,
                            aerials = -1,
                            seats = -1,
                            engine = -1,
                            tank = -1,
                            dashboard = -1,
                            dial = -1,
                            rearBumper = -1,
                            frontBumper = -1,
                            struts = -1,
                            customTiresR = false,
                            rightFender = -1,
                            trunk = -1,
                            horns = -1,
                            hood = -1,
                            archCover = -1,
                            customTiresF = false,
                            ornaments = -1,
                            xenon = false,
                            shifterLeavers = -1,
                            armor = -1,
                            fender = -1,
                            hydrolic = -1,
                            backWheels = -1,
                            plateHolder = -1,
                            speakers = -1,
                            turbo = false,
                            aPlate = -1,
                            engineBlock = -1,
                            trimA = -1
                        },
                        paintType = { 0, 0 },
                        color1 = { r = 8, g = 8, b = 8 },
                        extras = {
                            [0] = false,
                            [1] = false,
                            [2] = false,
                            [3] = false,
                            [4] = false,
                            [5] = false,
                            [6] = false,
                            [7] = false,
                            [8] = false,
                            [9] = false,
                            [10] = false,
                            [11] = false,
                            [12] = false
                        },
                        tyreSmoke = false,
                        neonEnabled = { false, false, false, false }
                    }
                    vehicleStore:SetData('Properties', defaultProperties)
                end
                ACTIVE_OWNED_VEHICLES[vehicle.VIN] = vehicleStore
                cb(true, vehicle, spawnedVehicle)

                if source and source > 0 then
                    -- Active Owner Stuff
                    if not ACTIVE_OWNED_VEHICLES_SPAWNERS[source] then
                        ACTIVE_OWNED_VEHICLES_SPAWNERS[source] = {}
                    end
                    table.insert(ACTIVE_OWNED_VEHICLES_SPAWNERS[source], vehicle.VIN)
                end

                -- Fix?
                local inVeh = GetPedInVehicleSeat(spawnedVehicle, -1)
                if inVeh and DoesEntityExist(inVeh) then
                    DeleteEntity(inVeh)
                end
            else
                cb(false)
            end
        else
            cb(false)
        end
    end)
end)

exports("OwnedStore", function(VIN, storageType, storageId, cb)
    local vehData = exports['pulsar-vehicles']:OwnedGetActive(VIN)
    if vehData and vehData:GetData('VIN') then
        local isSeized = vehData:GetData('Seized')
        if not isSeized then
            vehData:SetData('Storage', {
                Type = storageType,
                Id = storageId,
            })
        end

        exports['pulsar-vehicles']:OwnedDelete(vehData:GetData('VIN'), function(success)
            cb(success)
        end)
    else
        cb(false)
    end
end)

exports("OwnedDelete", function(VIN, cb, ignoredExists)
    local vehData = exports['pulsar-vehicles']:OwnedGetActive(VIN)
    if vehData and vehData:GetData('VIN') then
        local entity = vehData:GetData('EntityId')

        local ent = Entity(entity)
        if ent and ent.state then
            ent.state.Deleted = true
        end

        if entity and DoesEntityExist(entity) then
            local success = SaveVehicle(vehData:GetData('VIN'))
            if success then
                DeleteEntity(entity)
                ACTIVE_OWNED_VEHICLES[VIN] = nil
                exports['pulsar-vehicles']:StoresDelete(VIN)
                cb(true)
            end
            cb(success)
        elseif ignoredExists then
            ACTIVE_OWNED_VEHICLES[VIN] = nil
            exports['pulsar-vehicles']:StoresDelete(VIN)
            cb(true, true)
        end
    else
        cb(false)
    end
end)

exports("OwnedForceSave", function(VIN)
    local vehicleData = exports['pulsar-vehicles']:OwnedGetActive(VIN)
    if vehicleData then
        local success = SaveVehicle(VIN)
        if success then
            exports['pulsar-core']:LoggerInfo('Vehicles', 'Successfully Force Saved Vehicle: ' .. VIN)
        end
    end
end)

-- Character Storing Personal Vehicle in Property
exports("OwnedPropertiesStore", function(source, VIN, propertyId, cb)
    local character = exports['pulsar-characters']:FetchCharacterSource(source)
    local vehData = exports['pulsar-vehicles']:OwnedGetActive(VIN)
    if propertyId and character and vehData and vehData:GetData('VIN') then
        local vehOwner = vehData:GetData('Owner')
        local stateId = character:GetData('SID')
        if vehOwner.Type == 0 and stateId == vehOwner.Id then
            exports['pulsar-vehicles']:OwnedStore(VIN, 2, propertyId, cb)
        else
            cb(false)
        end
    else
        cb(false)
    end
end)

-- Get Vehicles Stored in Property
exports("OwnedPropertiesGet", function(propertyId, ownerStateId, cb)
    if ownerStateId then
        exports['pulsar-vehicles']:OwnedGetAll(0, 0, ownerStateId, cb, 2, propertyId, true)
    else
        exports['pulsar-vehicles']:OwnedGetAll(0, false, false, cb, 2, propertyId, true)
    end
end)

exports("OwnedPropertiesGetCount", function(propertyId, ignoreVIN)
    local whereConditions = { "StorageType = 2", "StorageId = ?" }
    local params = { propertyId }

    if ignoreVIN then
        table.insert(whereConditions, "VIN != ?")
        table.insert(params, ignoreVIN)
    end

    local count = MySQL.scalar.await(
        "SELECT COUNT(*) FROM vehicles WHERE " .. table.concat(whereConditions, " AND "),
        params
    )

    return count or 0
end)

exports("OwnedSeize", function(VIN, seizeState) -- Vehicle Siezure for Loans
    local vehicleData = exports['pulsar-vehicles']:OwnedGetActive(VIN)
    if vehicleData then                         -- Vehicle is currently out
        vehicleData:SetData('Seized', seizeState)
        vehicleData:SetData('SeizedTime', seizeState and os.time() or false)
        if seizeState then
            vehicleData:SetData('Storage', {
                Type = 0,
                Id = 0,
                Fine = 0,
                TimeHold = false,
            })
        end
        local success = SaveVehicle(VIN)
        return success
    else -- Vehicle is stored, update DB directly
        local updatingStorage = nil
        local vehicle = MySQL.single.await("SELECT StorageType, StorageId FROM vehicles WHERE VIN = ?", { VIN })

        if vehicle and vehicle.StorageType > 0 then -- Not Impounded
            updatingStorage = {
                Type = 0,
                Id = 0,
                Fine = 0,
                TimeHold = false,
            }
        end

        local success = MySQL.update.await(
            "UPDATE vehicles SET Properties = JSON_SET(COALESCE(Properties, '{}'), '$.Seized', ?, '$.SeizedTime', ?, '$.Storage', ?) WHERE VIN = ?",
            { seizeState, seizeState and os.time() or false, json.encode(updatingStorage), VIN }
        )

        return success
    end
end)

exports("OwnedTrack", function(VIN)
    local p = promise.new()

    local active = exports['pulsar-vehicles']:OwnedGetActive(VIN)
    if active then
        local wasTracked = active:GetData("TrackedLast")
        local vehLocation = GetEntityCoords(active:GetData("EntityId"))
        if wasTracked and wasTracked.time > os.time() then
            p:resolve(wasTracked.coords)
        else
            active:SetData("TrackedLast", {
                time = os.time() + 120,
                coords = vehLocation
            })
            p:resolve(vehLocation)
        end
    else
        exports['pulsar-vehicles']:OwnedGetVIN(VIN, function(c)
            if c.Storage.Type == 0 then
                p:resolve(exports['pulsar-vehicles']:GaragesImpound().coords)
            elseif c.Storage.Type == 1 then
                p:resolve(exports['pulsar-vehicles']:GaragesGet(c.Storage.Id).coords)
            elseif c.Storage.Type == 2 then
                local prop = exports['pulsar-properties']:Get(c.Storage.Id)
                if prop and prop.location and prop.location.garage then
                    p:resolve(vector3(prop.location.garage.x, prop.location.garage.y, prop.location.garage.z))
                else
                    p:resolve(false)
                end
            end
        end)
    end

    return Citizen.Await(p)
end)

exports("SpawnTemp",
    function(source, model, modelType, coords, heading, cb, vehicleInfoData, properties, preDamage, suppliedPlate,
             suppliedVIN, spawnAsShit)
        local spawnedVehicle = CreateVehicleFunc(modelType, model, coords, heading, spawnAsShit)
        local vehState = Entity(spawnedVehicle).state
        local plate = suppliedPlate or exports['pulsar-vehicles']:PlateGenerate(true)
        vehState.VIN = suppliedVIN or exports['pulsar-vehicles']:VINGenerateLocal()
        vehState.Owned = false
        vehState.Locked = false
        vehState.PlayerDriven = true
        vehState.Fuel = math.random(50, 100)
        vehState.Plate = plate

        vehState.ServerEntity = spawnedVehicle
        vehState.IsProtected = true

        if vehicleInfoData then
            vehState.Make = vehicleInfoData.Make
            vehState.Model = vehicleInfoData.Model
            vehState.Class = vehicleInfoData.Class
            vehState.Value = vehicleInfoData.Value
        end

        vehState.Trailer = GetVehicleType(spawnedVehicle) == 'trailer'

        vehState.VEH_IGNITION = false
        vehState.SpawnTemp = true

        if properties or preDamage then
            vehState.awaitingProperties = {
                needInit = false,
                properties = properties,
                damage = preDamage,
            }

            if preDamage then
                vehState.Damage = preDamage
            end
        end

        SetVehicleNumberPlateText(spawnedVehicle, plate)

        local inVeh = GetPedInVehicleSeat(spawnedVehicle, -1)
        if inVeh and DoesEntityExist(inVeh) then
            DeleteEntity(inVeh)
        end
        cb(spawnedVehicle, vehState.VIN, plate)
    end)

exports("Delete", function(vehicleId, cb)
    if DoesEntityExist(vehicleId) and GetEntityType(vehicleId) == 2 then
        local vehState = Entity(vehicleId).state
        if vehState and vehState.VIN and vehState.Owned then
            -- Its an owned vehicle, need to save
            exports['pulsar-vehicles']:OwnedDelete(vehState.VIN, function(success)
                if success then
                    TriggerEvent("Vehicles:Server:Deleted", vehicleId, vehState.VIN)
                end

                cb(success)
            end)
        else
            vehState.Deleted = true
            if _savedVehicleProperties[vehState.VIN] ~= nil then
                _savedVehicleProperties[vehState.VIN] = nil
            end

            DeleteEntity(vehicleId)
            TriggerEvent("Vehicles:Server:Deleted", vehicleId, vehState.VIN)
            cb(true)
        end
    else
        cb(false)
    end
end)

exports("StopDespawn", function(vehicle)
    if DoesEntityExist(vehicle) then
        local ent = Entity(vehicle)

        if ent and ent.state and ent.state.VIN and not ent.state.Owned then
            VEHICLES_PENDING_PROPERTIES[vehicle] = true

            ent.state.ServerEntity = vehicle
            ent.state.IsProtected = true
            ent.state.awaitingProperties = {
                stopDespawnInit = true,
            }
        end
    end
end)

--[[
POPTYPE_UNKNOWN = 0,
POPTYPE_RANDOM_PERMANENT 1
POPTYPE_RANDOM_PARKED 2
POPTYPE_RANDOM_PATROL 3
POPTYPE_RANDOM_SCENARIO 4
POPTYPE_RANDOM_AMBIENT 5
POPTYPE_PERMANENT 6
POPTYPE_MISSION 7
POPTYPE_REPLAY 8
POPTYPE_CACHE 9
POPTYPE_TOOL 10
]]

function GenerateLocalVehicleInfo(entity)
    if not DoesEntityExist(entity) then
        return
    end

    local entityType = GetEntityType(entity)

    -- Generate VIN for all vehicles (type 2), regardless of population type
    if entityType == 2 then
        local veh = Entity(entity)
        if not veh.state.VIN then
            veh.state.VIN = exports['pulsar-vehicles']:VINGenerateLocal()
            veh.state.Owned = false
            veh.state.Hotwired = false
            veh.state.HotwiredSuccess = false
            veh.state.PlayerDriven = false
            veh.state.Fuel = math.random(30, 100)
            veh.state.Mileage = math.random(1, 100) * 100
        end
    end
end

AddEventHandler("Vehicles:Server:GenerateVehicleInfo", GenerateLocalVehicleInfo)

-- Generate Vehicle Info on Client Request
RegisterNetEvent("Vehicles:Server:RequestGenerateVehicleInfo", function(vNet)
    local veh = NetworkGetEntityFromNetworkId(vNet)
    GenerateLocalVehicleInfo(veh)
end)

-- Lua 5.4 compatibility: Auto-generate VIN for all created vehicles
AddEventHandler('entityCreating', function(entity)
    -- Only process vehicles
    if GetEntityType(entity) == 2 then
        -- Wait for entity to fully exist before generating info
        SetTimeout(100, function()
            if DoesEntityExist(entity) then
                GenerateLocalVehicleInfo(entity)
            end
        end)
    end
end)

function ApplyOldVehicleState(veh, fuel, damage, damagedParts, mileage, engineHealth, bodyHealth, isBlownUp,
                              localProperties, lastDriven, serverSpawnedTemp)
    local ent = Entity(veh)
    if ent and ent.state and ent.state.VIN then
        ent.state.Fuel = fuel
        ent.state.Damage = damage
        ent.state.DamagedParts = damagedParts
        ent.state.Mileage = mileage
        ent.state.BlownUp = isBlownUp
        ent.state.awaitingEngineHealth = engineHealth

        ent.state.LastDriven = lastDriven
        ent.state.SpawnTemp = serverSpawnedTemp

        ent.state.awaitingBlownUp = isBlownUp

        if localProperties then
            ent.state.IsProtected = true
            ent.state.awaitingProperties = {
                needInit = false,
                properties = localProperties,
                damage = {
                    Engine = engineHealth,
                    Body = bodyHealth
                }
            }
        end
    end
end

RegisterNetEvent('Vehicles:Server:StopDespawn', function(vNet)
    local veh = NetworkGetEntityFromNetworkId(vNet)
    exports['pulsar-vehicles']:StopDespawn(veh)
end)

AddEventHandler('entityRemoved', function(entity)
    if GetEntityType(entity) == 2 then
        local ent = Entity(entity)
        if ent and ent.state and ent.state.VIN and (ent.state.Owned or ent.state.IsProtected) and not ent.state.Deleted then
            local isLocal = ent.state.IsProtected

            local vehModel = GetEntityModel(entity)
            local vehPlate = GetVehicleNumberPlateText(entity)

            local coords = vector3(GetEntityCoords(entity))
            local heading = GetEntityHeading(entity)
            local VIN = ent.state.VIN

            local fuel = ent.state.Fuel
            local damage = ent.state.Damage
            local damagedParts = ent.state.DamagedParts
            local mileage = ent.state.Mileage
            local isBlownUp = ent.state.BlownUp

            local engineHealth = GetVehicleEngineHealth(entity)
            local bodyHealth = GetVehicleBodyHealth(entity)

            local lastDriven = ent.state.LastDriven
            local spawnedTemp = ent.state.SpawnTemp

            -- exports['pulsar-core']:LoggerWarn("Vehicles", string.format("Vehicle %s Deleted Unexpectedly - Local: %s, %s %s Engine: %s, Body: %s, Blown Up: %s", ent.state.VIN, isLocal, coords, heading, engineHealth, bodyHealth, isBlownUp))

            if not isLocal then
                ACTIVE_OWNED_VEHICLES[ent.state.VIN] = nil
                exports['pulsar-vehicles']:StoresDelete(ent.state.VIN)
            end

            Wait(1000)

            if isLocal then
                exports['pulsar-vehicles']:SpawnTemp(-1, vehModel, nil, coords, heading, function(vehicleId)
                    SetVehicleBodyHealth(vehicleId, bodyHealth + 0.0)

                    ApplyOldVehicleState(vehicleId, fuel, damage, damagedParts, mileage, engineHealth, bodyHealth,
                        isBlownUp, _savedVehicleProperties[VIN], lastDriven, spawnedTemp)
                end, false, false, false, vehPlate, VIN, true)
            else
                exports['pulsar-vehicles']:OwnedSpawn(-1, VIN, coords, heading,
                    function(success, vehicleData, vehicleId)
                        if success then
                            SetVehicleBodyHealth(vehicleId, bodyHealth + 0.0)

                            ApplyOldVehicleState(vehicleId, fuel, damage, damagedParts, mileage, engineHealth, bodyHealth,
                                isBlownUp)
                        end
                    end)
            end
        end
    end
end)

AddEventHandler('explosionEvent', function(sender, ev)
    if ev and ev.f210 ~= 0 then
        local veh = NetworkGetEntityFromNetworkId(ev.f210)
        if veh and DoesEntityExist(veh) and GetEntityType(veh) == 2 then
            local vehEnt = Entity(veh)

            if vehEnt.state.VIN then
                -- print(sender, "Blew up Vehicle:", vehEnt.state.VIN)
                vehEnt.state.BlownUp = true
            end
        end
    end
end)

RegisterServerEvent('Vehicle:Server:InspectVIN', function(vNet)
    local src = source
    local veh = NetworkGetEntityFromNetworkId(vNet)
    if DoesEntityExist(veh) then
        local vState = Entity(veh).state
        if vState and vState.VIN then
            exports["pulsar-chat"]:SendServerSingle(src, 'Vehicle VIN: ' .. vState.VIN)
            TriggerClientEvent('Vehicles:Client:ViewVIN', src, vState.VIN)
        end
    end
end)

RegisterServerEvent('Vehicles:Server:FlipVehicle', function(netVeh, correctPitch)
    local vehicle = NetworkGetEntityFromNetworkId(netVeh)
    if vehicle and DoesEntityExist(vehicle) then
        local netOwner = NetworkGetEntityOwner(vehicle)
        if netOwner > 0 then
            TriggerClientEvent('Vehicles:Client:FlipVehicleRequest', netOwner, netVeh, correctPitch)
        end
    end
end)

AddEventHandler("Core:Server:ForceSave", function()
    local c = 0
    for VIN, _ in pairs(ACTIVE_OWNED_VEHICLES) do
        c = c + 1
        SaveVehicle(VIN)
    end
    exports['pulsar-core']:LoggerWarn("Vehicles", string.format("Force Saved %s Vehicles", c))
end)
