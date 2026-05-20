_reductions = 0

AddEventHandler('onClientResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(1000)
        exports["pulsar-core"]:RegisterClientCallback("Damage:Heal", function(s)
            if s then
                LocalPlayer.state.deadData = {}
                exports['pulsar-damage']:ReductionsReset()
            end
            exports['pulsar-damage']:Revive()
        end)

        exports["pulsar-core"]:RegisterClientCallback("Damage:FieldStabalize", function(s)
            exports['pulsar-damage']:Revive(true)
        end)

        exports["pulsar-core"]:RegisterClientCallback("Damage:Kill", function()
            ApplyDamageToPed(LocalPlayer.state.ped, 10000)
        end)

        exports["pulsar-core"]:RegisterClientCallback("Damage:Admin:Godmode", function(s)
            if s then
                exports['pulsar-hud']:ApplyBuff("godmode")
            else
                exports['pulsar-hud']:RemoveBuffType("godmode")
            end
        end)
    end
end)

RegisterNetEvent("Characters:Client:Spawned", function()
    StartThreads()

    exports['pulsar-hud']:RegisterBuff("weakness", "bandage", "#FF0049", -1, "permanent")
    exports['pulsar-hud']:RegisterBuff("godmode", "shield-virus", "#FFBB04", -1, "permanent")

    _reductions = LocalPlayer.state.Character:GetData("HPReductions") or 0
    if _reductions > 0 then
        exports['pulsar-hud']:ApplyUniqueBuff("weakness", -1)
    else
        exports['pulsar-hud']:RemoveBuffType("weakness")
    end
    exports['pulsar-damage']:CalculateMaxHp()

    if LocalPlayer.state.isDead then
        exports['pulsar-hud']:DeathTextsShow(
            (LocalPlayer.state.deadData and LocalPlayer.state.deadData.isMinor) and "knockout" or "death",
            LocalPlayer.state.isDeadTime,
            LocalPlayer.state.releaseTime)
        exports['pulsar-hud']:Dead(true)
        DoDeadEvent()
    end
end)

RegisterNetEvent("Characters:Client:Logout", function()
    if LocalPlayer.state.isDead then
        if Config.EnableDownblur then
            AnimpostfxStop("DeathFailMPIn")
        end
        exports['pulsar-hud']:DeathTextsHide()
        ClearPedTasksImmediately(ped)

        LocalPlayer.state:set("isDead", false, true)
        LocalPlayer.state:set("deadData", false, true)
        LocalPlayer.state:set("isDeadTime", false, true)
        LocalPlayer.state:set("releaseTime", false, true)
    end

    exports['pulsar-hud']:RemoveBuffType("weakness")
end)

RegisterNetEvent('UI:Client:Reset', function(apps)
    if not LocalPlayer.state.isDead and not LocalPlayer.state.isHospitalized then
        exports['pulsar-hud']:DeathTextsHide()
        exports['pulsar-hud']:Dead(false)
        if _reductions > 0 then
            exports['pulsar-hud']:ApplyUniqueBuff("weakness", -1)
        else
            exports['pulsar-hud']:RemoveBuffType("weakness")
        end
    end
end)

exports("ReductionsIncrease", function(amt)
    _reductions += amt
    exports['pulsar-hud']:ApplyUniqueBuff("weakness", -1)
    exports["pulsar-core"]:ServerCallback("Damage:SyncReductions", _reductions)
    exports['pulsar-damage']:CalculateMaxHp()
end)

exports("ReductionsReset", function()
    _reductions = 0
    exports['pulsar-hud']:RemoveBuffType("weakness")
    exports["pulsar-core"]:ServerCallback("Damage:SyncReductions", _reductions)
    exports['pulsar-damage']:CalculateMaxHp()
end)

exports("CalculateMaxHp", function()
    local ped = PlayerPedId()
    local curr = GetEntityHealth(ped)
    local currMax = GetEntityMaxHealth(ped)

    local mod = 0.25 * _reductions
    if mod > 0.8 then
        mod = 0.8
    end

    local newMax = 100 + math.ceil(100 * (1.0 - mod))

    SetEntityMaxHealth(ped, newMax)

    local newHp = curr
    if curr > newMax then
        SetEntityHealth(ped, newMax)
    end

    exports['pulsar-hud']:ForceHP()
end)

exports("WasDead", function(sid)
    return _deadCunts[sid] ~= nil
end)

exports("Revive", function(fieldTreat)
    local player = PlayerPedId()

    if LocalPlayer.state.isDead then
        DoScreenFadeOut(1000)
        while not IsScreenFadedOut() do
            Wait(10)
        end
    end

    local wasDead = LocalPlayer.state.isDead
    local wasMinor = LocalPlayer.state.deadData and LocalPlayer.state.deadData.isMinor

    if LocalPlayer.state.isDead then
        LocalPlayer.state:set("isDead", false, true)
    end
    if LocalPlayer.state.deadData then
        LocalPlayer.state:set("deadData", false, true)
    end
    if LocalPlayer.state.isDeadTime then
        LocalPlayer.state:set("isDeadTime", false, true)
    end
    if LocalPlayer.state.releaseTime then
        LocalPlayer.state:set("releaseTime", false, true)
    end

    local veh = GetVehiclePedIsIn(player)
    local seat = 0
    if veh ~= 0 then
        local m = GetEntityModel(veh)
        for k = -1, GetVehicleModelNumberOfSeats(m) do
            if GetPedInVehicleSeat(veh, k) == player then
                seat = k
            end
        end
    end

    -- if IsPedDeadOrDying(player) then
    --     local loc = GetEntityCoords(player)
    --     NetworkResurrectLocalPlayer(loc, true, true, false)
    -- end

    if veh == 0 then
        --ClearPedTasksImmediately(player)
    else
        Wait(300)
        TaskWarpPedIntoVehicle(player, veh, seat)
        Wait(300)
    end

    TriggerServerEvent("Damage:Server:Revived", wasMinor, fieldTreat)
    exports['pulsar-hud']:Dead(false)

    if not LocalPlayer.state.isHospitalized and wasDead then
        exports['pulsar-hud']:DeathTextsHide()
        SetEntityInvincible(player, LocalPlayer.state.isAdmin and LocalPlayer.state.isGodmode or false)
    end

    if _reductions > 0 then
        exports['pulsar-hud']:ApplyUniqueBuff("weakness", -1)
    else
        exports['pulsar-hud']:RemoveBuffType("weakness")
    end

    local mod = 0.25 * _reductions
    if mod > 0.8 then
        mod = 0.8
    end
    local newMax = 100 + math.ceil(100 * (1.0 - mod))

    SetEntityHealth(player, newMax)
    SetPlayerSprint(PlayerId(), true)
    ClearPedBloodDamage(player)

    if not fieldTreat then
        exports['pulsar-status']:Reset()
    end

    DoScreenFadeIn(1000)

    if not LocalPlayer.state.isHospitalized and wasDead and veh == 0 then
        exports['pulsar-animations']:EmotesPlay("reviveshit", false, 1750, true)
    end
end)

exports("Died", function()
    -- Empty for now
end)

exports("ApplyStandardDamage", function(value, armorFirst, forceKill)
    if forceKill and not _hasKO then
        _hasKO = true
    end

    ApplyDamageToPed(LocalPlayer.state.ped, value, armorFirst)
end)
