SetUserRadioControlEnabled(false)
SetFrontendRadioActive(false)
SetMobileRadioEnabledDuringGameplay(false)

local ped = PlayerPedId()
local veh = GetVehiclePedIsIn(ped, false)
if veh ~= 0 then
    SetVehRadioStation(veh, 'OFF')
end

-- Keep it disabled every frame while in a vehicle
CreateThread(function()
    while true do
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh ~= 0 then
            DisableControlAction(0, 85, true)  -- radio wheel
            DisableControlAction(0, 19, true)  -- radio alt
            HideHudComponentThisFrame(16)      -- hide native radio HUD
            SetUserRadioControlEnabled(false)
            SetVehRadioStation(veh, 'OFF')
            SetFrontendRadioActive(false)
            SetMobileRadioEnabledDuringGameplay(false)
            Wait(0)
        else
            SetUserRadioControlEnabled(false)
            SetFrontendRadioActive(false)
            Wait(500)
        end
    end
end)

local isWheelOpen = false
currentStation = nil
isInVehicle = false
local savedVolume = GetResourceKvpString('ob_radio_2:volume')
playerVolume = savedVolume and tonumber(savedVolume) or Config.DefaultVolume
local savedShowInfo = GetResourceKvpString('ob_radio_2:showInfo')
-- nil (never set) defaults to true (shown)
local showNowPlayingInfo = savedShowInfo ~= 'false'
radioDisabledForVehicle = false -- resource-global for spatial.lua if needed
local hasSyncedForEntry = false

-- Build a lookup of disabled models (name -> true) and model hashes
local disabledModelNames = {}
for _, name in ipairs(Config.DisabledVehicleModels or {}) do
    disabledModelNames[string.lower(name)] = true
end

local function isRadioDisabledForVehicle(veh)
    if veh == 0 then return false end
    if Config.DisableInEmergencyClass and GetVehicleClass(veh) == 18 then return true end
    if next(disabledModelNames) then
        local modelHash = GetEntityModel(veh)
        local modelName = string.lower(GetDisplayNameFromVehicleModel(modelHash) or '')
        if disabledModelNames[modelName] then return true end
    end
    return false
end

-- Poll vehicle state (more reliable than cache on resource restart)
CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)
        local wasInVehicle = isInVehicle
        isInVehicle = veh ~= 0
        radioDisabledForVehicle = isInVehicle and isRadioDisabledForVehicle(veh) or false

        -- Always send current state so NUI stays in sync after resource restarts.
        -- Bar only shows when: in a non-disabled vehicle AND user has info enabled.
        SendNUIMessage({ action = 'setInVehicle', inVehicle = isInVehicle and not radioDisabledForVehicle and showNowPlayingInfo })
        if isInVehicle ~= wasInVehicle and radioDisabledForVehicle and currentStation then
            SendNUIMessage({ action = 'stopAudio' })
            currentStation = nil
        end

        if not isInVehicle then hasSyncedForEntry = false end

        -- Sync once per vehicle entry (or first poll tick after resource restart)
        if isInVehicle and not radioDisabledForVehicle and not hasSyncedForEntry then
            hasSyncedForEntry = true

            -- Restore per-vehicle volume
            local plate = GetVehicleNumberPlateText(veh)
            if plate then
                plate = plate:gsub('%s+', '')
                local savedVehVol = GetResourceKvpString('ob_radio_2:vehvol:' .. plate)
                if savedVehVol then
                    playerVolume = tonumber(savedVehVol) or Config.DefaultVolume
                else
                    playerVolume = Config.DefaultVolume
                end
                SendNUIMessage({ action = 'setVolume', volume = playerVolume })
            end

            local netId = VehToNet(veh)
            local syncData = lib.callback.await('ob_radio_2:getVehicleStation', false, netId)
            if syncData then
                currentStation = syncData.stationIndex
                lastRadioVehicle = veh
                SendNUIMessage({
                    action = 'playStation',
                    station = Config.Stations[syncData.stationIndex],
                    stationIndex = syncData.stationIndex,
                    song = syncData.song,
                    offset = syncData.offset,
                    volume = playerVolume,
                    spatial = { volume = playerVolume, filterFreq = 22000 },
                })
            end
        elseif not isInVehicle and wasInVehicle then
            if isWheelOpen then closeWheel() end
            if currentStation then
                -- If the vehicle is destroyed, doesn't exist, or engine is off — kill audio
                local vehicleGone = not lastRadioVehicle
                    or not DoesEntityExist(lastRadioVehicle)
                    or IsEntityDead(lastRadioVehicle)
                    or not GetIsVehicleEngineRunning(lastRadioVehicle)
                if vehicleGone then
                    SendNUIMessage({ action = 'stopAudio' })
                    currentStation = nil
                else
                    SendNUIMessage({
                        action = 'updateSpatial',
                        spatial = { volume = playerVolume * 0.55, filterFreq = 1800 },
                    })
                end
            end
        end
        -- Note: spatial.lua handles ongoing in-vehicle updateSpatial with env values
        Wait(500)
    end
end)

-- Native radio disable is handled by the thread at the top of this file

-- Open radio wheel
function openWheel()
    if not isInVehicle or isWheelOpen then return end
    isWheelOpen = true

    SetTimecycleModifier('hud_def_blur')
    SetTimecycleModifierStrength(0.45)

    SendNUIMessage({
        action = 'openWheel',
        stations = Config.Stations,
        currentStation = currentStation,
        volume = playerVolume,
    })
end

-- Close radio wheel
function closeWheel()
    if not isWheelOpen then return end
    isWheelOpen = false

    ClearTimecycleModifier()
    SendNUIMessage({ action = 'closeWheel' })
end

-- Hold radio key to open wheel (default Q, rebindable in FiveM keybinds menu)
RegisterCommand('+ob_radio_wheel', function()
    if isInVehicle and not radioDisabledForVehicle then openWheel() end
end, false)
RegisterCommand('-ob_radio_wheel', function()
    if isWheelOpen then closeWheel() end
end, false)
RegisterKeyMapping('+ob_radio_wheel', 'Open Radio Wheel (hold)', 'keyboard', 'Q')

-- Volume up/down — only act while wheel is open, rebindable in FiveM keybinds menu
local function setVolume(vol)
    playerVolume = math.max(0.0, math.min(1.0, vol))
    SetResourceKvp('ob_radio_2:volume', tostring(playerVolume))

    -- Save per-vehicle volume
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh ~= 0 then
        local plate = GetVehicleNumberPlateText(veh)
        if plate then
            plate = plate:gsub('%s+', '')
            SetResourceKvp('ob_radio_2:vehvol:' .. plate, tostring(playerVolume))
        end
    end

    SendNUIMessage({ action = 'setVolume', volume = playerVolume })
end

RegisterCommand('ob_radio_vol_up', function()
    if isWheelOpen then setVolume(playerVolume + 0.05) end
end, false)
RegisterCommand('ob_radio_vol_down', function()
    if isWheelOpen then setVolume(playerVolume - 0.05) end
end, false)
RegisterKeyMapping('ob_radio_vol_up', 'Radio Volume Up', 'keyboard', 'UP')
RegisterKeyMapping('ob_radio_vol_down', 'Radio Volume Down', 'keyboard', 'DOWN')

-- Toggle the Now Playing info bar
RegisterCommand('toggleradioinfo', function()
    showNowPlayingInfo = not showNowPlayingInfo
    SetResourceKvp('ob_radio_2:showInfo', showNowPlayingInfo and 'true' or 'false')
    local msg = showNowPlayingInfo and 'Radio info bar: ^2ON^7' or 'Radio info bar: ^1OFF^7'
    lib.notify({ title = 'Radio', description = msg:gsub('%^%d', ''), type = showNowPlayingInfo and 'success' or 'error' })
end, false)
TriggerEvent('chat:addSuggestion', '/toggleradioinfo', 'Show/hide the Now Playing info while driving', {})

-- Scroll wheel navigation & control lockout while wheel is open
CreateThread(function()
    while true do
        if isWheelOpen then
            DisableControlAction(0, 19, true)  -- native radio wheel
            DisableControlAction(0, 1, true)   -- LOOK_LR (camera X)
            DisableControlAction(0, 2, true)   -- LOOK_UD (camera Y)
            DisableControlAction(0, 106, true) -- VEH_MOUSE_CONTROL_OVERRIDE
            DisableControlAction(0, 80, true)  -- VEH_CIN_CAM (C)
            DisableControlAction(0, 24, true)  -- ATTACK
            DisableControlAction(0, 25, true)  -- AIM
            DisableControlAction(0, 69, true)  -- VEH_ATTACK
            DisableControlAction(0, 70, true)  -- VEH_ATTACK2
            DisableControlAction(0, 92, true)  -- VEH_PASSENGER_AIM
            DisableControlAction(0, 114, true) -- VEH_FLY_ATTACK
            if IsDisabledControlJustPressed(0, 241) then
                SendNUIMessage({ action = 'scrollUp' })
            elseif IsDisabledControlJustPressed(0, 242) then
                SendNUIMessage({ action = 'scrollDown' })
            end
            Wait(0)
        else
            Wait(250)
        end
    end
end)

-- NUI Callbacks
RegisterNUICallback('selectStation', function(data, cb)
    local stationIndex = data.stationIndex
    if not stationIndex or not Config.Stations[stationIndex] then
        cb({})
        return
    end

    local veh = isInVehicle and GetVehiclePedIsIn(PlayerPedId(), false) or 0
    local netId = veh ~= 0 and VehToNet(veh) or nil
    local syncData = lib.callback.await('ob_radio_2:tuneIn', false, stationIndex, netId)

    if syncData then
        currentStation = stationIndex
        if veh ~= 0 then lastRadioVehicle = veh end
        SendNUIMessage({
            action = 'playStation',
            station = Config.Stations[stationIndex],
            stationIndex = stationIndex,
            song = syncData.song,
            offset = syncData.offset,
            volume = playerVolume,
            spatial = { volume = playerVolume, filterFreq = 22000 },
        })
    end

    cb({})
end)

RegisterNUICallback('turnOff', function(data, cb)
    local veh = isInVehicle and GetVehiclePedIsIn(PlayerPedId(), false) or 0
    local netId = veh ~= 0 and VehToNet(veh) or nil
    lib.callback.await('ob_radio_2:tuneOff', false, netId)
    currentStation = nil
    SendNUIMessage({ action = 'stopAudio' })
    cb({})
end)

-- Listen for server song changes
RegisterNetEvent('ob_radio_2:songChanged', function(stationIndex, songIndex, song)
    if currentStation == stationIndex then
        SendNUIMessage({
            action = 'songChanged',
            song = song,
            songIndex = songIndex,
            offset = 0,
        })
    end
end)

-- Listen for other vehicles' station updates
RegisterNetEvent('ob_radio_2:vehicleStationUpdate', function(netId, stationIndex, syncData)
    -- Spatial audio (for vehicles we're NOT in)
    TriggerEvent('ob_radio_2:nearbyVehicleUpdate', netId, stationIndex)

    -- If this is the vehicle we're currently in, sync our own station to it
    if isInVehicle then
        local myVeh = GetVehiclePedIsIn(PlayerPedId(), false)
        if myVeh ~= 0 and NetworkGetEntityIsNetworked(myVeh) and VehToNet(myVeh) == netId then
            if stationIndex == nil then
                currentStation = nil
                SendNUIMessage({ action = 'stopAudio' })
            elseif syncData then
                -- Use broadcast-embedded sync data (no extra round-trip)
                currentStation = syncData.stationIndex
                lastRadioVehicle = myVeh
                SendNUIMessage({
                    action = 'playStation',
                    station = Config.Stations[syncData.stationIndex],
                    stationIndex = syncData.stationIndex,
                    song = syncData.song,
                    offset = syncData.offset,
                    volume = playerVolume,
                    spatial = { volume = playerVolume, filterFreq = 22000 },
                })
            end
        end
    end
end)

-- Export current station for other scripts
exports('getCurrentStation', function()
    return currentStation and Config.Stations[currentStation] or nil
end)

exports('isRadioPlaying', function()
    return currentStation ~= nil
end)
