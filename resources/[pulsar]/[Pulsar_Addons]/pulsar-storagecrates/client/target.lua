
local _crates = _crates or {} 
local _crateInfos = {} 

local Callbacks = {}
function Callbacks:ServerCallback(name, data, cb)
    exports["pulsar-core"]:ServerCallback(name, data, cb)
end

local Progress = exports['pulsar-hud']
local Minigame = exports['pulsar-games']


CreateThread(function()
    while true do
        Wait(5000) 
        TriggerServerEvent('StorageCrates:Server:RequestCrateInfo')
    end
end)


RegisterNetEvent('StorageCrates:Client:ReceiveCrateInfo', function(crateInfos)
    _crateInfos = crateInfos or {}
end)


local function GetCrateIdFromEntity(entity)
    local entState = Entity(entity).state
    if entState.isStorageCrate then
        return entState.storageCrateId
    end
    return nil
end


local function GetCrateInfo(crateId)
    return _crateInfos[crateId]
end


CreateThread(function()
    Wait(2000) 
    local crateModels = {}
    for tier, tierConfig in pairs(Config.CrateTiers) do
        local model = tierConfig.model
        if type(model) == "string" then
            model = GetHashKey(model)
        end
        crateModels[model] = true
    end
    for model, _ in pairs(crateModels) do
        pcall(function()
            exports.ox_target:addModel(model, {
                {
                    label = 'Open Crate',
                    icon = 'fas fa-box-open',
                    distance = 2.0,
                    canInteract = function(entity)
                        return Entity(entity).state?.isStorageCrate
                    end,
                    onSelect = function(data)
                        local crateId = GetCrateIdFromEntity(data.entity)
                        if crateId then
                            local crateInfo = GetCrateInfo(crateId)
                            if crateInfo then
                                OpenCrate(crateId, crateInfo)
                            end
                        end
                    end,
                },
                {
                    label = 'Set/Change Password',
                    icon = 'fas fa-lock',
                    distance = 2.0,
                    canInteract = function(entity)
                        local crateId = GetCrateIdFromEntity(entity)
                        if not crateId then return false end
                        local crateInfo = GetCrateInfo(crateId)
                        return crateInfo and crateInfo.isOwner
                    end,
                    onSelect = function(data)
                        local crateId = GetCrateIdFromEntity(data.entity)
                        if crateId then
                            local crateInfo = GetCrateInfo(crateId)
                            if crateInfo then
                                SetPassword(crateId, crateInfo.hasPassword)
                            end
                        end
                    end,
                },
                {
                    label = 'Remove Password',
                    icon = 'fas fa-unlock',
                    distance = 2.0,
                    canInteract = function(entity)
                        local crateId = GetCrateIdFromEntity(entity)
                        if not crateId then return false end
                        local crateInfo = GetCrateInfo(crateId)
                        return crateInfo and crateInfo.isOwner and crateInfo.hasPassword
                    end,
                    onSelect = function(data)
                        local crateId = GetCrateIdFromEntity(data.entity)
                        if crateId then
                            RemovePassword(crateId)
                        end
                    end,
                },
                {
                    label = 'Pick Up Crate',
                    icon = 'fas fa-trash',
                    distance = 2.0,
                    canInteract = function(entity)
                        local crateId = GetCrateIdFromEntity(entity)
                        if not crateId then return false end
                        local crateInfo = GetCrateInfo(crateId)
                        return crateInfo and crateInfo.isOwner
                    end,
                    onSelect = function(data)
                        local crateId = GetCrateIdFromEntity(data.entity)
                        if crateId then
                            RemoveCrate(crateId)
                        end
                    end,
                },
                {
                    label = 'Lockpick Crate',
                    icon = 'fas fa-unlock-alt',
                    distance = 2.0,
                    canInteract = function(entity)
                        local crateId = GetCrateIdFromEntity(entity)
                        if not crateId then return false end
                        local crateInfo = GetCrateInfo(crateId)
                        return crateInfo and not crateInfo.isOwner and crateInfo.hasPassword
                    end,
                    onSelect = function(data)
                        local crateId = GetCrateIdFromEntity(data.entity)
                        if crateId then
                            LockpickCrate(crateId)
                        end
                    end,
                },
            })
        end)
    end
end)


function OpenCrate(crateId, crateInfo)
    print("[STORAGE-CRATES CLIENT] OpenCrate called, crateId:", crateId)
    print("[STORAGE-CRATES CLIENT] crateInfo:", json.encode(crateInfo))
    if not crateInfo.hasPassword then
        print("[STORAGE-CRATES CLIENT] Opening crate directly (no password)")
        Callbacks:ServerCallback("StorageCrates:OpenCrate", {
            crateId = crateId,
        }, function(success, errorMsg)
            print("[STORAGE-CRATES CLIENT] OpenCrate callback, success:", success, "errorMsg:", errorMsg)
            if not success then
                if errorMsg == "password_required" then
                    RequestPassword(crateId)
                else
                    exports['pulsar-hud']:Notification("error", errorMsg or "Failed to open crate", 5000)
                end
            end
        end)
    else
        print("[STORAGE-CRATES CLIENT] Password required")
        RequestPassword(crateId)
    end
end

function RequestPassword(crateId)
    exports['pulsar-hud']:InputShow(
        "Enter Password",
        "Enter the crate password",
        {
            {
                id = "password",
                label = "Password",
                type = "text",
                options = {
                    inputProps = {
                        maxLength = 30,
                    },
                },
            },
        },
        "StorageCrates:Client:PasswordInput",
        {
            crateId = crateId,
            action = "open",
        }
    )
end


RegisterNetEvent("StorageCrates:Client:PasswordInput", function(values, data)
    if not values or not values.password then return end
    
    local password = values.password
    local crateId = data.crateId
    local action = data.action
    
    if action == "open" then
        Callbacks:ServerCallback("StorageCrates:OpenCrate", {
            crateId = crateId,
            password = password,
        }, function(success, errorMsg)
            if success then
                exports['pulsar-hud']:Notification("success", "Crate opened", 3000)
            else
                exports['pulsar-hud']:Notification("error", errorMsg or "Failed to open crate", 5000)
            end
        end)
    end
end)


function SetPassword(crateId, hasPassword)
    local title = hasPassword and 'Change Password' or 'Set Password'
    local desc = hasPassword and 'Enter new password (leave empty to remove)' or 'Enter password'
    
    exports['pulsar-hud']:InputShow(
        title,
        desc,
        {
            {
                id = "password",
                label = "Password",
                type = "text",
                options = {
                    inputProps = {
                        maxLength = 30,
                    },
                },
            },
        },
        "StorageCrates:Client:SetPasswordInput",
        {
            crateId = crateId,
            hasPassword = hasPassword,
        }
    )
end


RegisterNetEvent("StorageCrates:Client:SetPasswordInput", function(values, data)
    if not values or not data then return end
    
    local password = values.password or ""
    local crateId = data.crateId
    local hasPassword = data.hasPassword
    
    Callbacks:ServerCallback("StorageCrates:SetPassword", {
        crateId = crateId,
        password = password,
    }, function(success, errorMsg)
        if success then
            if password == "" then
                exports['pulsar-hud']:Notification("success", "Password removed", 3000)
            else
                exports['pulsar-hud']:Notification("success", hasPassword and "Password changed" or "Password set", 3000)
            end
        else
            exports['pulsar-hud']:Notification("error", errorMsg or "Failed to set password", 5000)
        end
    end)
end)

function RemovePassword(crateId)
    Callbacks:ServerCallback("StorageCrates:SetPassword", {
        crateId = crateId,
        password = "",
    }, function(success, errorMsg)
        if success then
            exports['pulsar-hud']:Notification("success", "Password removed", 3000)
        else
            exports['pulsar-hud']:Notification("error", errorMsg or "Failed to remove password", 5000)
        end
    end)
end


function RemoveCrate(crateId)
    _removeInProgress = _removeInProgress or {}
    if _removeInProgress[crateId] then return end
    _removeInProgress[crateId] = true

    local ped = PlayerPedId()
    ClearPedSecondaryTask(ped)
    ClearPedTasksImmediately(ped)

    local dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@"
    RequestAnimDict(dict)
    local tries = 0
    while not HasAnimDictLoaded(dict) and tries < 50 do
        Wait(20)
        tries = tries + 1
    end

    Progress:Progress({
        name = 'pickup_crate_' .. crateId,
        duration = 3500,
        label = 'Picking up crate...',
        useWhileDead = false,
        canCancel = true,
        vehicle = false,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableCombat = true,
        },
        animation = {
            animDict = dict,
            anim = "machinic_loop_mechandplayer",
            flags = 49,
        },
    }, function(wasCancelled)
        _removeInProgress[crateId] = nil
        ClearPedTasksImmediately(PlayerPedId())

        if wasCancelled then return end

        Callbacks:ServerCallback("StorageCrates:RemoveCrate", {
            crateId = crateId,
        }, function(success, errorMsg)
            if success then
                exports['pulsar-hud']:Notification("success", "Crate picked up", 3000)
            else
                exports['pulsar-hud']:Notification("error", errorMsg or "Failed to pick up crate", 5000)
            end
        end)
    end)
end


function LockpickCrate(crateId)
    Callbacks:ServerCallback("StorageCrates:LockpickCrate", {
        crateId = crateId,
    }, function(success, lockpickType, errorMsg)
        if not success then
            exports['pulsar-hud']:Notification("error", errorMsg or "Cannot lockpick this crate", 5000)
            return
        end
        local rate, difficulty
        if lockpickType == "adv_lockpick" then
            rate = Config.AdvLockpickRoundRate or 1.2
            difficulty = Config.AdvLockpickRoundDifficulty or 6
        else
            rate = Config.LockpickRoundRate or 1.6
            difficulty = Config.LockpickRoundDifficulty or 3
        end
        exports['pulsar-games']:MinigamePlayRoundSkillbar(rate, difficulty, {
            onSuccess = function()
                CreateThread(function()
                    pcall(function()
                        exports['pulsar-games']:MinigameEnd()
                    end)
                    SetNuiFocus(false, false)
                    SetNuiFocusKeepInput(false)
                    ClearPedTasksImmediately(PlayerPedId())
                    Callbacks:ServerCallback("StorageCrates:CompleteLockpick", {
                        crateId = crateId,
                        success = true,
                        lockpickType = lockpickType, 
                    }, function(success, errorMsg)
                        if success then
                            exports['pulsar-hud']:Notification("success", "Crate unlocked!", 3000)
                        else
                            exports['pulsar-hud']:Notification("error", errorMsg or "Failed to unlock crate", 5000)
                        end
                    end)
                end)
            end,
            onFail = function()
                pcall(function()
                    exports['pulsar-games']:MinigameEnd()
                end)
                SetNuiFocus(false, false)
                SetNuiFocusKeepInput(false)
                ClearPedTasksImmediately(PlayerPedId())
                Callbacks:ServerCallback("StorageCrates:CompleteLockpick", {
                    crateId = crateId,
                    success = false,
                    lockpickType = lockpickType, 
                }, function() end)
                exports['pulsar-hud']:Notification("error", "Lockpick failed", 5000)
            end,
        }, {
            useWhileDead = false,
            vehicle = false,
        })
    end)
end
