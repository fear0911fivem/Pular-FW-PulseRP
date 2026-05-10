local nearbyVehicles = {} -- [netId] = stationIndex (from broadcasts)
lastRadioVehicle = nil    -- resource-global, also updated from main.lua when entering a vehicle

AddEventHandler('ob_radio_2:nearbyVehicleUpdate', function(netId, stationIndex)
    nearbyVehicles[netId] = stationIndex
end)

local function findNearestRadioVehicle(playerCoords)
    local closestDist = Config.MaxAudioDistance + 1
    local closestVeh = nil

    -- First, try the player's last-known vehicle (works even if broadcast was missed)
    if lastRadioVehicle and DoesEntityExist(lastRadioVehicle) then
        local dist = #(playerCoords - GetEntityCoords(lastRadioVehicle))
        if dist < Config.MaxAudioDistance then
            closestDist = dist
            closestVeh = lastRadioVehicle
        end
    end

    -- Then scan nearby vehicles from broadcast list
    for _, vehicle in ipairs(GetGamePool('CVehicle')) do
        if DoesEntityExist(vehicle) and vehicle ~= lastRadioVehicle and NetworkGetEntityIsNetworked(vehicle) then
            local netId = NetworkGetNetworkIdFromEntity(vehicle)
            if nearbyVehicles[netId] then
                local dist = #(playerCoords - GetEntityCoords(vehicle))
                if dist < closestDist then
                    closestDist = dist
                    closestVeh = vehicle
                end
            end
        end
    end

    return closestVeh, closestDist
end

local function getOpenOrBrokenDoorCount(vehicle)
    local doorCount = GetNumberOfVehicleDoors(vehicle)
    local openCount = 0

    for i = 0, doorCount - 1 do
        local isDoorOpen = GetVehicleDoorAngleRatio(vehicle, i) > 0.0
        local isDoorDamaged = IsVehicleDoorDamaged(vehicle, i)

        if isDoorOpen or isDoorDamaged then
            openCount = openCount + 1
        end
    end

    return openCount
end

local function getVehicleRoofOcclusion(vehicle)
    if not vehicle or not DoesEntityExist(vehicle) then
        return 0.55, 1800
    end

    local vehicleClass = GetVehicleClass(vehicle)

    local hasRoof = DoesVehicleHaveRoof(vehicle)
    local isVehicleABike = (vehicleClass == 8 or vehicleClass == 13)

    -- Bikes and convertibles with no roof have minimal occlusion
    if isVehicleABike or not hasRoof then
        return 0.65, 22000
    end

    -- Get roof state and corresponding occlusion values
    local roofState = GetConvertibleRoofState(vehicle)
    local roofOcclusion = Config.AudioRoofOcclusion[roofState] or Config.AudioRoofOcclusion[0]

    -- Start with base occlusion from roof state
    local occlusionValue = roofOcclusion.occlusion
    local cutoffFrequency = roofOcclusion.cutoff

    -- Adjust occlusion based on open/broken doors and windows
    local openDoors = getOpenOrBrokenDoorCount(vehicle)
    local hasBrokenWindows = not AreAllVehicleWindowsIntact(vehicle)

    -- Each broken window adds 0.10 occlusion and 1500 Hz cutoff increase
    if hasBrokenWindows then
        occlusionValue = occlusionValue + 0.10
        cutoffFrequency = cutoffFrequency + 1500
    end

    -- Each open/broken door adds 0.05 occlusion and 1500 Hz cutoff increase
    if openDoors > 0 then
        occlusionValue = occlusionValue + (openDoors * 0.05)
        cutoffFrequency = cutoffFrequency + (openDoors * 1500)
    end

    -- Clamp values to reasonable ranges
    occlusionValue = math.max(0.0, occlusionValue)
    cutoffFrequency = math.min(22000, cutoffFrequency)

    return occlusionValue, cutoffFrequency
end

CreateThread(function()
    while true do
        if isInVehicle and currentStation then
            -- Inside vehicle — apply environment effects (wind, tunnel, interior, etc.)
            SendNUIMessage({
                action = 'updateSpatial',
                spatial = {
                    volume = playerVolume * (envVolumeMul or 1.0),
                    filterFreq = envFilterFreq or 22000,
                },
            })
            Wait(500)
        elseif currentStation then
            -- Check if last radio vehicle is destroyed
            if lastRadioVehicle and (not DoesEntityExist(lastRadioVehicle) or IsEntityDead(lastRadioVehicle)) then
                SendNUIMessage({ action = 'stopAudio' })
                currentStation = nil
                lastRadioVehicle = nil
                Wait(500)
                goto continue
            end

            -- Outside vehicle but radio still playing
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)

            local vehicle, dist = findNearestRadioVehicle(playerCoords)
            local bodyBlockVolume, bodyBlockFilter = getVehicleRoofOcclusion(vehicle)

            -- Clamp distance to MaxAudioDistance for calculation (so it saturates at silent)
            local clampedDist = math.min(dist, Config.MaxAudioDistance)
            local distRatio = clampedDist / Config.MaxAudioDistance
            local volume = bodyBlockVolume * (1.0 - distRatio) * playerVolume
            local filterFreq = bodyBlockFilter - (distRatio * (bodyBlockFilter - 300))

            -- Combine with environment effects
            volume = volume * (envVolumeMul or 1.0)
            filterFreq = math.min(filterFreq, envFilterFreq or 22000)

            SendNUIMessage({
                action = 'updateSpatial',
                spatial = { volume = volume, filterFreq = filterFreq },
            })
            Wait(150)
        else
            Wait(500)
        end
        ::continue::
    end
end)
