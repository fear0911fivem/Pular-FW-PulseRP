local stationStates = {}
local vehicleStations = {} -- [netId] = stationIndex

-- Initialize all station states
for i, station in ipairs(Config.Stations) do
    stationStates[i] = {
        songIndex = 1,
        startedAt = GetGameTimer(),
    }
end

local function elapsedSeconds(startedAt)
    return (GetGameTimer() - startedAt) / 1000.0
end

-- Advance to next song in a station
local function advanceSong(stationIndex)
    local station = Config.Stations[stationIndex]
    if not station then return end
    local state = stationStates[stationIndex]

    state.songIndex = state.songIndex + 1
    if state.songIndex > #station.songs then state.songIndex = 1 end
    state.startedAt = GetGameTimer()
    TriggerClientEvent('ob_radio_2:songChanged', -1, stationIndex, state.songIndex, station.songs[state.songIndex])
end

-- Song rotation thread
CreateThread(function()
    while true do
        for i, state in pairs(stationStates) do
            local station = Config.Stations[i]
            if station and station.songs[state.songIndex] then
                if elapsedSeconds(state.startedAt) >= station.songs[state.songIndex].duration then
                    advanceSong(i)
                end
            end
        end
        Wait(500)
    end
end)

-- Client requests to tune into a station
lib.callback.register('ob_radio_2:tuneIn', function(source, stationIndex, vehicleNetId)
    local station = Config.Stations[stationIndex]
    if not station then return nil end

    local state = stationStates[stationIndex]
    local song = station.songs[state.songIndex]
    local elapsed = elapsedSeconds(state.startedAt)

    local syncData = {
        songIndex = state.songIndex,
        song = song,
        offset = elapsed,
        stationIndex = stationIndex,
    }

    -- Track which vehicle is playing which station; broadcast full sync data
    if vehicleNetId then
        vehicleStations[vehicleNetId] = stationIndex
        TriggerClientEvent('ob_radio_2:vehicleStationUpdate', -1, vehicleNetId, stationIndex, syncData)
    end

    return syncData
end)

-- Client turns off radio
lib.callback.register('ob_radio_2:tuneOff', function(source, vehicleNetId)
    if vehicleNetId then
        vehicleStations[vehicleNetId] = nil
        TriggerClientEvent('ob_radio_2:vehicleStationUpdate', -1, vehicleNetId, nil)
    end
    return true
end)

-- Get what station a vehicle is playing
lib.callback.register('ob_radio_2:getVehicleStation', function(source, vehicleNetId)
    local stationIndex = vehicleStations[vehicleNetId]
    if not stationIndex then return nil end

    local station = Config.Stations[stationIndex]
    local state = stationStates[stationIndex]
    local song = station.songs[state.songIndex]
    local elapsed = elapsedSeconds(state.startedAt)

    return {
        stationIndex = stationIndex,
        songIndex = state.songIndex,
        song = song,
        offset = elapsed,
    }
end)

-- Admin skip command (requires ACE permission "ob_radio_2.skip")
-- Grant in server.cfg: add_ace group.admin "ob_radio_2.skip" allow
RegisterCommand('skipsong', function(source, args)
    -- source == 0 means it was executed from the server console
    if source ~= 0 then
        if not IsPlayerAceAllowed(source, 'ob_radio_2.skip') then
            TriggerClientEvent('ox_lib:notify', source, { title = 'Radio', description = 'You are not allowed to use this command.', type = 'error' })
            return
        end
    end

    local stationIndex = tonumber(args[1])
    if not stationIndex or not Config.Stations[stationIndex] then
        local msg = ('Usage: /skipsong <stationIndex>   (1-%d)'):format(#Config.Stations)
        if source == 0 then print(msg)
        else TriggerClientEvent('ox_lib:notify', source, { title = 'Radio', description = msg, type = 'inform' }) end
        return
    end

    advanceSong(stationIndex)

    local station = Config.Stations[stationIndex]
    local song = station.songs[stationStates[stationIndex].songIndex]
    local announce = ('Skipped on %s. Now playing: %s — %s'):format(station.label, song.title or '', song.artist or '')
    if source == 0 then print(announce)
    else TriggerClientEvent('ox_lib:notify', source, { title = 'Radio', description = announce, type = 'success' }) end
end, true) -- restricted = true (requires ACE)

-- Clean up when vehicle is deleted
AddEventHandler('entityRemoved', function(entity)
    local netId = NetworkGetNetworkIdFromEntity(entity)
    if vehicleStations[netId] then
        vehicleStations[netId] = nil
    end
end)
