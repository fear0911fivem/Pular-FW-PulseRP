envFilterFreq = 22000
envVolumeMul = 1.0

-- Distance above entity we need to hit something to count as "covered" (tunnel/bridge/overpass)
local COVER_CHECK_HEIGHT = 40.0
-- Z threshold where we assume "underground"
local UNDERGROUND_Z = -5.0
-- Speed (m/s) where wind noise saturates
local MAX_WIND_SPEED = 40.0

-- Returns a 0..1 factor of how "open" the cabin is (broken windows + open doors)
local function cabinOpenness(veh)
    if veh == 0 then return 0 end
    local openness = 0
    -- 4 main windows (front left/right, rear left/right)
    for i = 0, 3 do
        if not IsVehicleWindowIntact(veh, i) then
            openness = openness + 0.2
        end
    end
    -- 4 main doors (ratio > 0.1 = opening)
    for i = 0, 3 do
        if GetVehicleDoorAngleRatio(veh, i) > 0.1 then
            openness = openness + 0.25
        end
    end
    return math.min(openness, 1.0)
end

local function detectEnvironment(ped)
    -- Underwater: heaviest filter + lowest volume (GTA native check)
    if IsEntityInWater(ped) then
        return 600, 0.35
    end

    local veh = GetVehiclePedIsIn(ped, false)
    local entity = (veh ~= 0) and veh or ped

    -- Interior lookup via natives (more reliable than raycasts)
    local interior = GetInteriorFromEntity(entity)
    if interior ~= 0 then
        -- Check if the interior is an enclosed room vs an open-air interior (e.g. garage with door up)
        local roomKey = GetRoomKeyFromEntity(entity)
        if roomKey ~= 0 and roomKey ~= -1 then
            -- Fully enclosed interior room: heavy muffle
            return 3000, 0.75
        end
        -- Interior exists but no specific room: slight muffle (e.g. carpark open area)
        return 5500, 0.9
    end

    local coords = GetEntityCoords(entity)

    -- Underground check: if player Z is very low AND there's ceiling above
    if coords.z < UNDERGROUND_Z then
        return 2500, 0.8
    end

    -- Check for a roof/overpass above using raycast (GTA's native shape test)
    local handle = StartShapeTestRay(
        coords.x, coords.y, coords.z + 0.5,
        coords.x, coords.y, coords.z + COVER_CHECK_HEIGHT,
        1, -- map intersection flags
        entity,
        0
    )
    local _, hit, hitCoords = GetShapeTestResult(handle)
    if hit == 1 then
        -- Distance to the thing above us tells us if it's a thick tunnel or just a bridge
        local coverDistance = hitCoords.z - coords.z
        if coverDistance < 8.0 then
            -- Close ceiling — proper tunnel/indoor feel
            return 5500, 0.9
        else
            -- High overhang — overpass/bridge, lighter effect
            return 9000, 0.97
        end
    end

    -- Fully outdoors, clear sky
    return 22000, 1.0
end

-- Applies wind-noise + cabin-openness attenuation on top of the base environment values
local function applyWindEffects(veh, baseFilter, baseVolume)
    if veh == 0 then return baseFilter, baseVolume end
    local openness = cabinOpenness(veh)
    if openness < 0.05 then return baseFilter, baseVolume end

    local speed = GetEntitySpeed(veh) -- m/s
    local speedRatio = math.min(1.0, speed / MAX_WIND_SPEED)

    -- Combined intensity: openness * speed
    local windIntensity = openness * speedRatio

    -- At full wind: drop filter to ~4000Hz, reduce volume by up to 30%
    local filterDrop = windIntensity * 18000   -- up to 18kHz drop (22000 → 4000)
    local volumeDrop = windIntensity * 0.30    -- up to 30% drop

    local newFilter = math.max(3000, baseFilter - filterDrop)
    local newVolume = baseVolume * (1.0 - volumeDrop)
    return newFilter, newVolume
end

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)
        local f, v = detectEnvironment(ped)
        f, v = applyWindEffects(veh, f, v)
        envFilterFreq, envVolumeMul = f, v
        Wait(300)
    end
end)
