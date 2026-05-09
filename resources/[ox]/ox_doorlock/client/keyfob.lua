local keyfobRange = 10.0

RegisterNetEvent('ox_doorlock:useKeyfobClient', function(itemName, success, doorId, doorState)
    if not success then
        exports['pulsar-sounds']:UISoundsPlayFrontEnd(-1, "OOB_Cancel", "GTAO_FM_Events_Soundset")
        return
    end

    if doorState == 1 then -- Locked
        exports['pulsar-sounds']:UISoundsPlayFrontEnd(-1, "OOB_Cancel", "GTAO_FM_Events_Soundset")
    else                   -- Unlocked
        exports['pulsar-sounds']:UISoundsPlayFrontEnd(-1, "Bomb_Disarmed", "GTAO_Speed_Convoy_Soundset")
    end

    local playerPed = PlayerPedId()
    if not IsEntityPlayingAnim(playerPed, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 3) then
        RequestAnimDict('anim@mp_player_intmenu@key_fob@')
        while not HasAnimDictLoaded('anim@mp_player_intmenu@key_fob@') do
            Wait(0)
        end
        TaskPlayAnim(playerPed, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 8.0, 8.0, 1000, 48, 0, false, false,
            false)
    end
end)

exports('useKeyfob', function(data, slot)
    TriggerServerEvent('ox_doorlock:useKeyfob', data)
end)

exports['pulsar-kbs']:Add("doors_garage_fob", "f10", "keyboard", "Doors - Use Garage Keyfob", function()
    if exports.ox_inventory:Search('count', 'keyfob') == 0 then
        exports['pulsar-hud']:Notification("error", "You do not have a keyfob.")
        return
    end
    exports.ox_doorlock:useKeyfob()
end)

exports('getKeyfobRange', function()
    return keyfobRange
end)
