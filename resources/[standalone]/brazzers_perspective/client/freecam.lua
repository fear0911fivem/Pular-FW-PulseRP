local utils = require 'modules.utils.client.main'
local config = lib.load('config')

---@type brazzers_freecam
---@diagnostic disable-next-line: missing-fields
local freecam = lib.load('classes.freecam')
local playerState = LocalPlayer.state

lib.locale()

if not config.enableFreeCam then return end

-- -------------------------------------------------------------------------- --
--                                  Functions                                 --
-- -------------------------------------------------------------------------- --

---@param bool boolean
local function blockFreeCam(bool)
    freecam.block = bool
end

exports('blockFreeCam', blockFreeCam)

local function disableControls()
    DisableControlAction(0, 30, true)
    DisableControlAction(0, 31, true)
    DisableControlAction(0, 32, true)
    DisableControlAction(0, 33, true)
    DisableControlAction(0, 34, true)
    DisableControlAction(0, 35, true)
end

---@param key string type
---@param value boolean
local function handleMovement(key, value)
    if not freecam.cam then return end

    local movementMap = {
        forward = function() freecam.movement = vector3(freecam.movement.x, value and 1 or 0, freecam.movement.z) end,
        backward = function() freecam.movement = vector3(freecam.movement.x, value and -1 or 0, freecam.movement.z) end,
        left = function() freecam.movement = vector3(value and 1 or 0, freecam.movement.y, freecam.movement.z) end,
        right = function() freecam.movement = vector3(value and -1 or 0, freecam.movement.y, freecam.movement.z) end,
        up = function() freecam.movement = vector3(freecam.movement.x, freecam.movement.y, value and 1 or 0) end,
        down = function() freecam.movement = vector3(freecam.movement.x, freecam.movement.y, value and -1 or 0) end
    }

    if movementMap[key] then movementMap[key]() end
end

local function disableFreeCam()
    if not freecam.cam then return end
    SetCamActive(freecam.cam, false)
    RenderScriptCams(false, true, config.ease, true, true)
    DestroyCam(freecam.cam, true)
    freecam.cam = nil
    freecam.lock = false
    playerState:set("freeCam", false, true)
end

local function freeCamThread()
    CreateThread(function()
        while freecam.cam do
            if not freecam.lock then
                disableControls()
                utils.checkRotationInput(freecam.cam)
                if freecam.movement.x or freecam.movement.y or freecam.movement.z then
                    local camCoords = GetCamCoord(freecam.cam)
                    local camRot = GetCamRot(freecam.cam, 2)

                    local forwardVector = utils.calculateForwardVector(camRot)
                    local rightVector = utils.calculateRightVector(forwardVector)

                    local newCoords = camCoords +
                    forwardVector * freecam.movement.y * config.speed +
                    rightVector * freecam.movement.x * config.speed +
                    vector3(0, 0, freecam.movement.z * config.speed)

                    newCoords = utils.constrainToMaxDistance(config.distance, newCoords)
                    SetCamCoord(freecam.cam, newCoords.x, newCoords.y, newCoords.z)
                end
            end
            if freecam.lock then
                local myCoords, camCoords = GetEntityCoords(cache.ped), GetCamCoord(freecam.cam)
                local distance = #(myCoords - camCoords)
                if distance > config.distance then
                    return disableFreeCam()
                end
            end

            Wait(0)
        end
    end)
end

local function createFreeCam()
    local rotation, mode = GetGameplayCamRot(2), GetFollowPedCamViewMode()
    local coords = mode == 4 and GetEntityCoords(cache.ped) - (GetEntityForwardVector(cache.ped) * 1.0) or GetGameplayCamCoord()
    freecam.cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", coords.x, coords.y, mode == 4 and coords.z + 0.5 or coords.z, rotation.x, rotation.y, rotation.z, freecam.fov, true, 2)
    RenderScriptCams(true, true, config.ease, true, true)
    freeCamThread()
    playerState:set("freeCam", true, true)
end

-- -------------------------------------------------------------------------- --
--                                  Keybinds                                  --
-- -------------------------------------------------------------------------- --

lib.addKeybind({
    name = '_freeCamEnable',
    description = locale('freemCamEnable'),
    defaultKey = config.keys.enableFreeCam,
    onPressed = function()
        if playerState.zoom then return end
        if freecam.block then return end
        if freecam.cam then return disableFreeCam() end
        createFreeCam()
    end,
})

lib.addKeybind({
    name = '_freeCamLock',
    description = locale('freeCamLock'),
    defaultKey = config.keys.freeCamLock,
    onPressed = function()
        if not freecam.cam then return end
        freecam.lock = not freecam.lock
    end,
})

lib.addKeybind({
    name = '_freeCamForward',
    description = locale('freeCamForward'),
    defaultKey = config.keys.freeCamForward,
    onPressed = function() handleMovement('forward', true) end,
    onReleased = function() handleMovement('forward', false) end
})

lib.addKeybind({
    name = '_freeCamBackward',
    description = locale('freeCamBackward'),
    defaultKey = config.keys.freeCamBackward,
    onPressed = function() handleMovement('backward', true) end,
    onReleased = function() handleMovement('backward', false) end
})

lib.addKeybind({
    name = '_freeCamLeft',
    description = locale('freeCamLeft'),
    defaultKey = config.keys.freeCamLeft,
    onPressed = function() handleMovement('left', true) end,
    onReleased = function() handleMovement('left', false) end
})

lib.addKeybind({
    name = '_freeCamRight',
    description = locale('freeCamRight'),
    defaultKey = config.keys.freeCamRight,
    onPressed = function() handleMovement('right', true) end,
    onReleased = function() handleMovement('right', false) end
})

lib.addKeybind({
    name = '_freeCamUp',
    description = locale('freeCamUp'),
    defaultKey = config.keys.freeCamUp,
    onPressed = function() handleMovement('up', true) end,
    onReleased = function() handleMovement('up', false) end
})

lib.addKeybind({
    name = '_freeCamDown',
    description = locale('freeCamDown'),
    defaultKey = config.keys.freeCamDown,
    onPressed = function() handleMovement('down', true) end,
    onReleased = function() handleMovement('down', false) end
})

-- -------------------------------------------------------------------------- --
--                                   Exports                                  --
-- -------------------------------------------------------------------------- --