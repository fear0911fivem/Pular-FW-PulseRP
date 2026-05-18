local _atm = RobberyConfig.atms

local _atmZone
local _blip

AddEventHandler("Robbery:Client:Setup", function()
    while not GlobalState["ATMRobberyTerminal"] do
        Wait(10)
    end

    local ped = _atm.terminal.ped

    exports['pulsar-pedinteraction']:Add(
        "ATMContactPed",
        GetHashKey("s_m_y_dealer_01"),
        vector3(ped.x, ped.y, ped.z),
        ped.w,
        50.0,
        {
            {
                icon    = "fas fa-eye-slash",
                text    = "Do Illegal Things",
                isEnabled = function()
                    if exports.ox_inventory:GetItemCount(_atm.items.terminal) <= 0 then return false end
                    return not LocalPlayer.state.ATMRobbery or LocalPlayer.state.ATMRobbery <= 0
                end,
                onSelect = function()
                    TriggerEvent("Robbery:Client:ATM:UseTerminal")
                end,
            },
        },
        nil,
        "WORLD_HUMAN_STAND_MOBILE"
    )

    for k, v in ipairs(_atm.objects) do
        exports.ox_target:addModel(v, {
            {
                label = "Run Exploit",
                icon = 'fas fa-eye-slash',
                event = "Robbery:Client:ATM:StartHack",
                distance = 2.0,
                canInteract = function()
                    if LocalPlayer.state.ATMRobbery and LocalPlayer.state.ATMRobbery > 0 then
                        if _atmZone and #(_atmZone.coords - LocalPlayer.state.myPos) <= _atmZone.radius then
                            return true
                        end
                    end
                end,
            },
        })
    end
end)

AddEventHandler("Robbery:Client:ATM:UseTerminal", function()
    if GlobalState['Sync:IsNight'] then
        if (not GlobalState["ATMRobberyStartCD"]) or (GetCloudTimeAsInt() > GlobalState["ATMRobberyStartCD"]) then
            exports['pulsar-games']:MinigamePlayMemory(5, 1200, 9000, 5, 5, 5, 2, {
                onSuccess = function(data)
                    exports["pulsar-core"]:ServerCallback("Robbery:ATM:StartJob", true, function(success, location)
                        if success then
                            exports['pulsar-phone']:NotificationAddWithId("ATMRobbery", "Started - Good Luck",
                                "Access an ATM in the highlighted area", GetCloudTimeAsInt(), -1, {
                                    color = '#247919',
                                    label = 'Root',
                                    icon = 'terminal',
                                }, {
                                    accept = "dicks",
                                }, nil)

                            StartATMRobbery(location, true)
                        else
                            if location then
                                exports['pulsar-phone']:NotificationAdd("No More!",
                                    "You already have done too much today...",
                                    GetCloudTimeAsInt(), 7500, _atm.phoneApp, {}, nil)
                            end
                        end
                    end)
                end,
                onFail = function(data)
                    exports["pulsar-core"]:ServerCallback("Robbery:ATM:StartJob", false, function() end)

                    exports['pulsar-phone']:NotificationAdd("Not Today Failure", "Your skills are useless to us...",
                        GetCloudTimeAsInt(),
                        7500, _atm.phoneApp, {}, nil)
                end,
            }, {
                playableWhileDead = false,
                animation = {
                    animDict = "anim@heists@prison_heiststation@cop_reactions",
                    anim = "cop_b_idle",
                    flags = 17,
                },
            }, {})
        else
            exports['pulsar-phone']:NotificationAdd("Busy at the Moment", "Sorry, please try again in a minute.",
                GetCloudTimeAsInt(),
                7500, _atm.phoneApp, {}, nil)
        end
    else
        exports['pulsar-phone']:NotificationAdd("Come Back Later", "Sorry, please try again when it's dark.",
            GetCloudTimeAsInt(), 7500,
            _atm.phoneApp, {}, nil)
    end
end)

function StartATMRobbery(location, firstLocation)
    _atmZone = location

    if not _atmZone then return end

    if _blip then
        RemoveBlip(_blip)
    end

    _blip = AddBlipForRadius(_atmZone.coords.x, _atmZone.coords.y, _atmZone.coords.maxZ, _atmZone.radius + 0.0)
    SetBlipColour(_blip, 1)
    SetBlipAlpha(_blip, 90)

    exports["pulsar-blips"]:Add("ATMRobbery", "Target Area", _atmZone.coords, 521, 6, 1.5)

    ClearGpsPlayerWaypoint()
    SetNewWaypoint(_atmZone.coords.x, _atmZone.coords.y)

    if not firstLocation then
        exports['pulsar-phone']:NotificationAddWithId("ATMRobbery", "Well Done - Next!",
            "Access an ATM in the new highlighted area",
            GetCloudTimeAsInt() * 1000, -1, _atm.phoneApp, {
                accept = "dicks",
            }, nil)
    end
end

function EndATMRobbery()
    RemoveBlip(_blip)
    exports["pulsar-blips"]:Remove("ATMRobbery")

    _blip = nil

    exports['pulsar-phone']:NotificationRemove("ATMRobbery")
end

function DoATMProgress(label, duration, canCancel, cb)
    exports['pulsar-hud']:Progress({
        name = "installing_atm_hack",
        duration = (math.random(10) + 10) * 1000,
        label = label,
        useWhileDead = false,
        canCancel = canCancel,
        ignoreModifier = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            anim = "type",
        },
    }, function(status)
        if cb then
            cb(status)
        end
    end)
end

AddEventHandler('Robbery:Client:ATM:StartHack', function(entity)
    local coords = GetEntityCoords(LocalPlayer.state.ped)
    local alarm = false

    if math.random(100) >= 75 then
        alarm = true

        SetTimeout(8000, function()
            exports["pulsar-sounds"]:PlayLocation(coords, 20.0, "house_alarm.ogg", 0.05)
            TriggerServerEvent("Robbery:Server:ATM:AlertPolice", coords)
        end)
    end

    DoATMProgress("Connecting & Installing", (math.random(10) + 20) * 1000, true, function(status)
        if status then return end

        local size = math.random(5, 7)
        local toGet = math.random(4, 6)

        exports['pulsar-games']:MinigamePlayMemory(5, 1000, 8000, size, size, toGet, 1, {
            onSuccess = function(data)
                while LocalPlayer.state.doingAction do -- Apparently this is dumb
                    Wait(100)
                end

                DoATMProgress("Executing", (math.random(10) + 10) * 1000, false, function(status)
                    exports["pulsar-core"]:ServerCallback("Robbery:ATM:HackATM", size, function(success, location)
                        if success then
                            DoATMProgress("Uninstalling", (math.random(5) + 10) * 1000, false)
                            if location then
                                StartATMRobbery(location, false)
                            else
                                exports['pulsar-phone']:NotificationAdd("Done",
                                    "We hope to work with you more in the future.",
                                    GetCloudTimeAsInt(), 7500, _atm.phoneApp, {}, nil)
                            end
                        end

                        if not success or not location then
                            EndATMRobbery()
                        end
                    end)
                end)
            end,
            onFail = function(data)
                exports["pulsar-sounds"]:PlayLocation(coords, 20.0, "house_alarm.ogg", 0.05)

                while LocalPlayer.state.doingAction do -- Apparently this is dumb
                    Wait(100)
                end

                exports["pulsar-core"]:ServerCallback("Robbery:ATM:FailHackATM", {
                    coords = coords,
                    alarm = alarm,
                }, function()
                    DoATMProgress("Uninstalling", (math.random(5) + 10) * 1000, false)

                    EndATMRobbery()

                    exports['pulsar-phone']:NotificationAdd("Failed", "I can't believe you just did this.",
                        GetCloudTimeAsInt(), 7500,
                        _atm.phoneApp, {}, nil)
                end)
            end,
        }, {
            playableWhileDead = false,
            animation = {
                anim = "type",
            },
        }, {})
    end)
end)

RegisterNetEvent('Characters:Client:Logout')
AddEventHandler('Characters:Client:Logout', function()
    EndATMRobbery()
end)
