local utils = {}

function utils.Lerp(a, b, t)
    return a + (b - a) * t
end

function utils.LerpAngle(a, b, t)
    local diff = ((b - a + 180) % 360) - 180
    return a + diff * t
end

function utils.calculateForwardVector(rotation)
    local radZ = math.rad(rotation.z)
    local radX = math.rad(rotation.x)
    local cosX = math.cos(radX)

    return vector3(
        -math.sin(radZ) * cosX,
        math.cos(radZ) * cosX,
        math.sin(radX)
    )
end

function utils.calculateRightVector(forwardVector)
    local magnitude = math.sqrt(forwardVector.x^2 + forwardVector.y^2)
    if magnitude == 0 then
        return vector3(0, 0, 0)
    end
    return vector3(-forwardVector.y / magnitude, forwardVector.x / magnitude, 0)
end

function utils.constrainToMaxDistance(maxDistance, camCoords)
    local playerCoords = GetEntityCoords(cache.ped)
    local distance = #(camCoords - playerCoords)

    if distance > maxDistance then
        local direction = (camCoords - playerCoords) / distance
        return playerCoords + direction * maxDistance
    end

    return camCoords
end

function utils.checkRotationInput(cam)
    local rightAxisX = GetDisabledControlNormal(0, 220)
    local rightAxisY = GetDisabledControlNormal(0, 221)
    local rotation = GetCamRot(cam, 2)
    if rightAxisX ~= 0.0 or rightAxisY ~= 0.0 then
        local new_z = rotation.z + rightAxisX * -1.0 * (2.0) * (4.0 + 0.1)
        local new_x = math.max(math.min(80.0, rotation.x + rightAxisY * -1.0 * (2.0) * (4.0 + 0.1)), -89.5)
        SetCamRot(cam, new_x, 0.0, new_z, 2)
    end
end

return utils