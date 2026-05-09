local isMailboxStuck = false
local lastParkingMeterRobTime = 0
local lastMailboxTime = 0
local lastPorchRobTime = 0
local porchPirateProps = {}

-- Settings
local COOLDOWN_PORCH = 30
local COOLDOWN_PARKING = 30
local COOLDOWN_MAIL = 30
local HAND_STUCK_CHANCE = 35
local PORCH_PIRATE_DOG_SPAWN_CHANCE = 15

local parkingMeters = {
    `prop_parknmeter_01`,
    `prop_parknmeter_02`,
}

local mailboxes = {
    `prop_postbox_01a`,
    `prop_letterbox_01`,
}

local porchPirateNightRequired = true
local porchPirateGuardDogModel = `a_c_rottweiler`
local porchPirateGuardDogEnabled = true

local miscOxModelTargetsRegistered = false

local function lootReceivedSuffix(label, amount)
    if type(label) ~= "string" or not label or type(amount) ~= "number" or amount < 1 then
        return ""
    end
    return (" Received %dx %s."):format(amount, label)
end

-- Events
AddEventHandler('Characters:Client:Spawn', function()
    resetMisc()
end)

AddEventHandler("Robbery:Client:Setup", function()
    setupMiscRobbery()
end)

AddEventHandler("Robbery:Client:Mailbox:Rob", function(ctx)
    if type(ctx) ~= "table" then
        return
    end
    if GlobalState["RobberiesDisabled"] then
        exports["pulsar-hud"]:Notification("error", "Temporarily Disabled, Please See City Announcements", 6000)
        return
    end

    bumAnim()
    lastMailboxTime = GetCloudTimeAsInt()
    
    exports["pulsar-games"]:MinigamePlayRoundSkillbar(1.0, 5, {
        onSuccess = function()
            if math.random(100) <= HAND_STUCK_CHANCE then
                exports["pulsar-hud"]:Notification("error", "Your hand got stuck.", 6000)
                exports["pulsar-hud"]:ActionShow("mailbox_unstuck", "{keybind}primary_action{/keybind}Unstuck Hand")
                isMailboxStuck = true
            else
                exports["pulsar-core"]:ServerCallback("Robbery:Mailbox:Success", {}, function(success, label, amount)
                    if success then
                        exports["pulsar-hud"]:Notification(
                            "success",
                            "You successfully robbed the mailbox." .. lootReceivedSuffix(label, amount),
                            6500
                        )
                    else
                        exports["pulsar-hud"]:Notification("error", "You could not take anything from the mailbox.", 6000)
                    end
                    ClearPedTasksImmediately(PlayerPedId())
                end)
            end
        end,
        onFail = function()
            exports["pulsar-core"]:ServerCallback("Robbery:Mailbox:Fail", {}, function(fail)
                exports["pulsar-hud"]:Notification("error", "You dropped the lockpick.", 6000)
                ClearPedTasksImmediately(PlayerPedId())
            end)
        end,
    }, {
        animation = false,
    }, {})
end)

AddEventHandler("Robbery:Client:ParkingMeter:Rob", function(ctx)
    if type(ctx) ~= "table" then
        return
    end
    if GlobalState["RobberiesDisabled"] then
        exports["pulsar-hud"]:Notification("error", "Temporarily Disabled, Please See City Announcements", 6000)
        return
    end

    lastParkingMeterRobTime = GetCloudTimeAsInt()
    
    exports["pulsar-games"]:MinigamePlayRoundSkillbar(1.0, 5, {
        onSuccess = function()
            exports["pulsar-core"]:ServerCallback("Robbery:ParkingMeter:Success", {}, function(success, label, amount)
                if success then
                    exports["pulsar-hud"]:Notification(
                        "success",
                        "You successfully robbed the parking meter." .. lootReceivedSuffix(label, amount),
                        6500
                    )
                else
                    exports["pulsar-hud"]:Notification("error", "You could not get any cash from the meter.", 6000)
                end
                ClearPedTasksImmediately(PlayerPedId())
            end)
        end,
        onFail = function()
            exports["pulsar-core"]:ServerCallback("Robbery:ParkingMeter:Fail", {}, function(fail)
                exports["pulsar-hud"]:Notification("error", "You dropped the lockpick.", 6000)
                ClearPedTasksImmediately(PlayerPedId())
            end)
        end,
    }, {
        animation = {
            animDict = "veh@break_in@0h@p_m_one@",
            anim = "low_force_entry_ds",
            flags = 1,
        },
    }, {})
end)

AddEventHandler("Robbery:Client:Porch:Rob", function(ctx)
    if type(ctx) ~= "table" then
        return
    end
    if GlobalState["RobberiesDisabled"] then
        exports["pulsar-hud"]:Notification("error", "Temporarily Disabled, Please See City Announcements", 6000)
        return
    end
    if not ctx.spawnIndex then
        return
    end
    local data = { spawnIndex = ctx.spawnIndex }

    lastPorchRobTime = GetCloudTimeAsInt()
    
    exports["pulsar-hud"]:Progress({
        name = "pickup_package",
        duration = 1500,
        label = "Picking up the box...",
        useWhileDead = false,
        canCancel = true,
        ignoreModifier = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = 'anim@mp_snowball',
            anim = 'pickup_snowball',
            flags = 49,
        }
    }, function(cancelled)
        if not cancelled then
            if math.random(100) <= PORCH_PIRATE_DOG_SPAWN_CHANCE and porchPirateGuardDogEnabled then
                exports["pulsar-hud"]:Notification("error", "The owner's dog is home.", 6000)
                spawnGuardDog()
                return
            end
            
            exports["pulsar-core"]:ServerCallback("Robbery:Porch:Pickup", data, function(success, label, amount)
                ClearPedTasks(PlayerPedId())
                if success then
                    exports["pulsar-hud"]:Notification(
                        "success",
                        "You took the package." .. lootReceivedSuffix(label, amount),
                        6500
                    )
                else
                    exports["pulsar-hud"]:Notification("error", "There was nothing worth taking in the package.", 6000)
                end
            end)
        end
    end)
    
    local spawnIndex = data.spawnIndex
    local prop = porchPirateProps[spawnIndex] and porchPirateProps[spawnIndex].object
    if prop and DoesEntityExist(prop) then
        pcall(function()
            exports.ox_target:removeLocalEntity(prop)
        end)
        DeleteObject(prop)
    end
    porchPirateProps[spawnIndex] = nil
end)

AddEventHandler('Keybinds:Client:KeyUp:primary_action', function()
    if isMailboxStuck then
        exports["pulsar-hud"]:ActionHide("mailbox_unstuck")
        exports["pulsar-hud"]:Progress({
            name = "hand_stuck",
            duration = 5000,
            label = "Attempting to shake hand out",
            useWhileDead = false,
            canCancel = false,
            ignoreModifier = true,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
            animation = false,
        }, function(cancelled)
            if not cancelled then
                playMinigameRetry()
            end
        end)
    end
end)

-- Setup
function setupMiscRobbery()
    if not miscOxModelTargetsRegistered then
        miscOxModelTargetsRegistered = true
        for _, model in ipairs(parkingMeters) do
            exports.ox_target:addModel(model, {
                {
                    label = "Rob Meter",
                    icon = "fas fa-hand-holding-dollar",
                    distance = 3.0,
                    canInteract = function()
                        return not isGlobalCooldownActive("parking")
                    end,
                    event = "Robbery:Client:ParkingMeter:Rob",
                },
            })
        end

        for _, model in ipairs(mailboxes) do
            exports.ox_target:addModel(model, {
                {
                    label = "Rob Mailbox",
                    icon = "fas fa-envelope",
                    distance = 3.0,
                    canInteract = function()
                        return not isGlobalCooldownActive("mailbox")
                    end,
                    event = "Robbery:Client:Mailbox:Rob",
                },
            })
        end
    end

    Citizen.CreateThread(function()
        while LocalPlayer.state.loggedIn do
            SpawnPorchPirateProps()
            Citizen.Wait(COOLDOWN_PORCH * 1000)
        end
    end)
end

function SpawnPorchPirateProps()
    if porchPirateNightRequired then
        local currentHour = GetClockHours()
        if not (currentHour < 5 or currentHour >= 20) then
            for i, propData in pairs(porchPirateProps) do
                if DoesEntityExist(propData.object) then
                    pcall(function()
                        exports.ox_target:removeLocalEntity(propData.object)
                    end)
                    DeleteObject(propData.object)
                end
                porchPirateProps[i] = nil
            end
            return
        end
    end

    local spawns = GlobalState["porchPirateSpawns"]
    if not spawns then return end

    for i, spawn in ipairs(spawns) do
        if spawn then
            if not isGlobalCooldownActive("porch") then
                if not porchPirateProps[i] then
                    createPorchPackage(i, spawn)
                end
            else
                if porchPirateProps[i] then
                    if DoesEntityExist(porchPirateProps[i].object) then
                        pcall(function()
                            exports.ox_target:removeLocalEntity(porchPirateProps[i].object)
                        end)
                        DeleteObject(porchPirateProps[i].object)
                    end
                    porchPirateProps[i] = nil
                end
            end
        end
    end
end

function createPorchPackage(index, spawn)
    RequestModel("prop_cs_package_01")
    while not HasModelLoaded("prop_cs_package_01") do
        Wait(0)
    end

    local parcelObject = CreateObject(GetHashKey("prop_cs_package_01"), spawn.x, spawn.y, spawn.z, false, false, true)
    SetEntityRotation(parcelObject, 0.0, 0.0, spawn.w or 0.0, 2, true)
    FreezeEntityPosition(parcelObject, true)
    SetModelAsNoLongerNeeded("prop_cs_package_01")
    
    porchPirateProps[index] = { object = parcelObject, spawn = spawn }

    exports.ox_target:addLocalEntity(parcelObject, {
        {
            name = ("petty_porch_package_%s"):format(index),
            label = "Pick Up Package",
            icon = "fas fa-box",
            distance = 2.0,
            spawnIndex = index,
            canInteract = function()
                return not isGlobalCooldownActive("porch")
            end,
            event = "Robbery:Client:Porch:Rob",
        },
    })
end

function spawnGuardDog()
    local playerPed = PlayerPedId()
    local dogSpawn = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 1.0, 0.0)

    RequestModel(porchPirateGuardDogModel)
    while not HasModelLoaded(porchPirateGuardDogModel) do
        Wait(0)
    end

    local dog = CreatePed(28, porchPirateGuardDogModel, dogSpawn.x, dogSpawn.y, dogSpawn.z, GetEntityHeading(playerPed), true, false)
    TaskCombatPed(dog, playerPed, 0, 16)
end

function playMinigameRetry()
    exports["pulsar-games"]:MinigamePlayRoundSkillbar(1.0, 5, {
        onSuccess = function()
            ClearPedTasks(PlayerPedId())
            exports["pulsar-hud"]:Notification("success", "You successfully unstuck your hand.", 5000)
            isMailboxStuck = false
        end,
        onFail = function()
            exports["pulsar-hud"]:Notification("error", "You begin to panic.", 6000)
            playMinigameRetry()
        end,
    }, {
        animation = false,
    }, {})
end

-- Animations
function bumAnim()
    RequestAnimDict("amb@prop_human_bum_bin@base")
    while not HasAnimDictLoaded("amb@prop_human_bum_bin@base") do
        Citizen.Wait(0)
    end
    TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@base", "base", 8.0, -8.0, -1, 1, 0, false, false, false)
end

function lookAroundAnim()
    RequestAnimDict("friends@frl@ig_1")
    while not HasAnimDictLoaded("friends@frl@ig_1") do
        Citizen.Wait(0)
    end
    TaskPlayAnim(PlayerPedId(), "friends@frl@ig_1", "idle_b_lamar", 8.0, -8.0, -1, 1, 0, false, false, false)
end

function pickupAnim()
    RequestAnimDict("friends@frl@ig_1")
    while not HasAnimDictLoaded("friends@frl@ig_1") do
        Citizen.Wait(0)
    end
    TaskPlayAnim(PlayerPedId(), "friends@frl@ig_1", "idle_b_lamar", 8.0, -8.0, -1, 1, 0, false, false, false)
end

-- Utilities
function isGlobalCooldownActive(cooldownType)
    local currentTime = GetCloudTimeAsInt()
    if cooldownType == "parking" then
        return (currentTime - lastParkingMeterRobTime) < COOLDOWN_PARKING
    elseif cooldownType == "mailbox" then
        return (currentTime - lastMailboxTime) < COOLDOWN_MAIL
    elseif cooldownType == "porch" then
        return (currentTime - lastPorchRobTime) < COOLDOWN_PORCH
    end
    return false
end

function resetMisc()
    isMailboxStuck = false
    lastParkingMeterRobTime = 0
    lastMailboxTime = 0
    lastPorchRobTime = 0
end
