local Callbacks = {}
function Callbacks:ServerCallback(name, data, cb)
    exports["pulsar-core"]:ServerCallback(name, data, cb)
end

local ACTION_ID = "storage_crate_placement"

local function hidePlacementAction()
    exports["pulsar-hud"]:ActionHide(ACTION_ID)
end

local function resolveHeading(endCoords)
    if not endCoords then return 0.0 end
    local h = endCoords.heading
    if type(h) == "number" then return h end
    local r = endCoords.rotation
    if type(r) == "number" then return r end
    if type(r) == "table" and type(r.z) == "number" then return r.z end
    return 0.0
end

RegisterNetEvent("StorageCrates:Client:StartPlacement", function(tier, slot)
    if not Config or not Config.CrateTiers then
        exports["pulsar-hud"]:Notification("error", "Configuration not loaded", 5000)
        return
    end
    local tierConfig = Config.CrateTiers[tier]
    if not tierConfig then
        exports["pulsar-hud"]:Notification("error", "Invalid crate tier: " .. tostring(tier), 5000)
        return
    end

    if IsPedInAnyVehicle(PlayerPedId(), false) then
        exports["pulsar-hud"]:Notification("error", "Leave your vehicle to place a crate", 5000)
        return
    end

    local model = tierConfig.model
    if type(model) == "string" then
        model = GetHashKey(model)
    end

    if not exports["pulsar-objects"] or not exports["pulsar-objects"].PlacerStart then
        exports["pulsar-hud"]:Notification("error", "Placement system not available", 5000)
        return
    end

    exports["pulsar-hud"]:ActionShow(
        ACTION_ID,
        "{keybind}primary_action{/keybind} Place Storage Crate | {keybind}cancel_action{/keybind} Cancel | Scroll Wheel to Rotate"
    )

    local ok, err = pcall(function()
        exports["pulsar-objects"]:PlacerStart(
            model,
            "StorageCrates:Client:FinishPlacement",
            { tier = tier, slot = slot },
            true,
            "StorageCrates:Client:PlacementCancelled",
            false,
            false,
            nil,
            nil,
            nil,
            nil
        )
    end)

    if not ok then
        hidePlacementAction()
        exports["pulsar-hud"]:Notification("error", "Failed to start placement: " .. tostring(err), 5000)
    end
end)

AddEventHandler("StorageCrates:Client:PlacementCancelled", function()
    hidePlacementAction()
end)

AddEventHandler("StorageCrates:Client:FinishPlacement", function(data, endCoords)
    hidePlacementAction()

    if not data or not data.tier then
        exports["pulsar-hud"]:Notification("error", "Invalid placement data", 5000)
        return
    end

    local tier = data.tier
    local slot = data.slot
    local tierConfig = Config.CrateTiers[tier]
    if not tierConfig then
        exports["pulsar-hud"]:Notification("error", "Invalid crate tier", 5000)
        return
    end

    if not endCoords or not endCoords.coords then
        exports["pulsar-hud"]:Notification("error", "Invalid placement position", 5000)
        return
    end

    TaskTurnPedToFaceCoord(PlayerPedId(), endCoords.coords.x, endCoords.coords.y, endCoords.coords.z, 0.0)
    Wait(1000)

    local heading = resolveHeading(endCoords)

    exports["pulsar-hud"]:Progress({
        name = "storage_crate_place",
        duration = 5000,
        label = "Placing Storage Crate",
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
            task = "CODE_HUMAN_MEDIC_KNEEL",
        },
    }, function(wasCancelled)
        ClearPedTasksImmediately(PlayerPedId())
        if wasCancelled then return end
        Callbacks:ServerCallback("StorageCrates:PlaceCrate", {
            tier = tier,
            coords = endCoords.coords,
            heading = heading,
            slot = slot,
        }, function(success, errorMsg)
            if success then
                exports["pulsar-hud"]:Notification("success", "Crate placed successfully!", 5000)
            else
                exports["pulsar-hud"]:Notification("error", errorMsg or "Failed to place crate", 5000)
            end
        end)
    end)
end)
