local utils = require 'modules.utils.client.main'
local config = lib.load('config')

---@type brazzers_zoom
---@diagnostic disable-next-line: missing-fields
local zoom = lib.load('classes.zoom')
local playerState = LocalPlayer.state

if not config.enableZoom then return end

-- -------------------------------------------------------------------------- --
--                                  Functions                                 --
-- -------------------------------------------------------------------------- --

---@param bool boolean
local function blockZoom(bool)
    zoom.block = bool
end

exports('blockZoom', blockZoom)

local function createCamera()
    local rotation, mode = GetGameplayCamRot(2), GetFollowPedCamViewMode()
    -- We check for first person to setup the zoom properly for first person without making it look like shit
    local coords = mode == 4 and GetEntityCoords(cache.ped) + (GetEntityForwardVector(cache.ped) * 1.0) or GetGameplayCamCoord()
    zoom.cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", coords.x, coords.y, mode == 4 and coords.z + 0.5 or coords.z, rotation.x, rotation.y, rotation.z, zoom.fov, true, 2)
    RenderScriptCams(true, true, config.ease, true, true)
    playerState:set("zoom", true, true)
end

local function disableZoom()
    local mode = GetFollowPedCamViewMode()
    SetCamActive(zoom.cam, false)
    -- We have to check for first person here because cam likes going into the body with ease param higher than 0
    RenderScriptCams(false, true, mode == 4 and 0 or config.ease, true, true)
    DestroyCam(zoom.cam, true)
    zoom.active = false
    zoom.cam = nil
    playerState:set("zoom", false, true)
end

local function zoomThread()
    local previousCoords, previousRotation = GetGameplayCamCoord(), GetGameplayCamRot(2)

    CreateThread(function()
        while zoom.active do
            local rotation, mode = GetGameplayCamRot(2), GetFollowPedCamViewMode()
            local coords = mode == 4 and GetEntityCoords(cache.ped) + (GetEntityForwardVector(cache.ped) * 1.0) or GetGameplayCamCoord()

            -- This is to fix the retarded glitchy cam when you run and stop running (if you find a better way pr it)
            local smoothCoords = vector3(
                utils.Lerp(previousCoords.x, coords.x, 0.2), 
                utils.Lerp(previousCoords.y, coords.y, 0.2),
                utils.Lerp(previousCoords.z, mode == 4 and coords.z + 0.5 or coords.z, 0.2)
            )
            local smoothRot = vector3(
                utils.LerpAngle(previousRotation.x, rotation.x, 0.2),
                utils.LerpAngle(previousRotation.y, rotation.y, 0.2),
                utils.LerpAngle(previousRotation.z, rotation.z, 0.2)
            )

            SetCamCoord(zoom.cam, smoothCoords.x, smoothCoords.y, smoothCoords.z)
            SetCamRot(zoom.cam, smoothRot.x, smoothRot.y, smoothRot.z, 2)

            previousCoords = smoothCoords
            previousRotation = smoothRot

            if IsPlayerFreeAiming(cache.playerId) and zoom.active then
                disableZoom()
            end

            Wait(0)
        end
    end)
end

local function enableZoom()
    zoom.active = true
    if not zoom.cam then createCamera() end

    SetCamFov(zoom.cam, zoom.fov)
    SetCamActive(zoom.cam, true)
    RenderScriptCams(true, true, config.ease, true, true)
    zoomThread()
end

-- -------------------------------------------------------------------------- --
--                                  Keybinds                                  --
-- -------------------------------------------------------------------------- --

lib.addKeybind({
    name = '_zoom',
    description = locale('zoom'),
    defaultKey = config.keys.zoom,
    defaultMapper = 'MOUSE_BUTTON',
    onPressed = function(self)
        if playerState.freeCam then return end
        if zoom.block then return end
        if IsPlayerFreeAiming(cache.playerId) then return end
        enableZoom()
    end,
    onReleased = function(self)
        if playerState.freeCam then return end
        if IsPlayerFreeAiming(cache.playerId) then return end
        disableZoom()
    end
})