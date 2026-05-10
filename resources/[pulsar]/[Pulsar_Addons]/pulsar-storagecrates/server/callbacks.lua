local Callbacks = exports["pulsar-core"]

local function GetCharacter(src)
    return exports["pulsar-characters"]:FetchCharacterSource(src)
end

local function NormalizeSid(value)
    if value == nil then return nil end
    return tostring(value):gsub("^%s+", ""):gsub("%s+$", "")
end

local function SidEquals(a, b)
    local sidA, sidB = NormalizeSid(a), NormalizeSid(b)
    if not sidA or not sidB then return false end
    if sidA == sidB then return true end

    sidA, sidB = tonumber(sidA), tonumber(sidB)
    return sidA ~= nil and sidB ~= nil and sidA == sidB
end

local function HashPassword(password)
    return password
end

local function VerifyPassword(password, hash)
    return HashPassword(password) == hash
end

local function GenerateCrateId()
    return ("crate_%s_%s"):format(os.time(), math.random(1000, 9999))
end

local function GetPlayerSid(src)
    local char = GetCharacter(src)
    if not char then return nil end

    return char, NormalizeSid(char:GetData("SID"))
end

local function Notify(src, notifType, message)
    exports["pulsar-hud"]:Notification(src, notifType, message, 5000)
end

local function SendCrateToRoute(eventName, route, crateId, data)
    for _, player in ipairs(GetPlayers()) do
        local target = tonumber(player)

        if target and (GetPlayerRoutingBucket(target) or 0) == route then
            TriggerClientEvent(eventName, target, crateId, data)
        end
    end
end

local function RemoveCrateItem(src, sid, item, slot)
    if slot ~= nil then
        if type(slot) == "table" then
            slot = slot.Slot or slot.slot
        end

        slot = tonumber(slot)

        if not slot then
            return false, "Invalid inventory slot"
        end

        local slotData = exports.ox_inventory:GetSlot(src, slot)

        if not slotData or slotData.name ~= item or (slotData.count or 0) < 1 then
            return false, "That crate item was moved. Use the crate item again."
        end

        local ok, removed, err = pcall(function()
            return exports.ox_inventory:RemoveSlot(sid, item, 1, slot, 1)
        end)

        if not ok then
            return false, ("Failed to remove item: %s"):format(tostring(removed))
        end

        return removed, err or "Failed to remove crate item"
    end

    local hasItem = exports.ox_inventory:ItemsGetFirst(sid, item, 1)

    if not hasItem then
        return false, "You don't have this crate item"
    end

    local ok, removed, err = pcall(function()
        return exports.ox_inventory:Remove(sid, 1, item, 1)
    end)

    if not ok then
        return false, ("Failed to remove item: %s"):format(tostring(removed))
    end

    return removed, err or "Failed to remove crate item"
end

local function CrateStashIsEmpty(crateId)
    local items = exports.ox_inventory:GetInventoryItems("crate:" .. crateId)
    if not items then return true end
    for _, slot in pairs(items) do
        if slot and slot.name and (slot.count or 0) > 0 then
            return false
        end
    end
    return true
end

local function GivePlayerCrateItem(source, tierItemName)
    local ok, success, response = pcall(function()
        return exports.ox_inventory:AddItem(source, tierItemName, 1, {})
    end)
    if not ok then
        return false, tostring(success)
    end
    return success, response
end

Callbacks:RegisterServerCallback("StorageCrates:PlaceCrate", function(source, data, cb)
    local char, sid = GetPlayerSid(source)

    if not char then
        cb(false, "Character not found")
        return
    end

    local tier = data.tier
    local coords = data.coords
    local heading = data.heading
    local slot = data.slot
    local route = GetPlayerRoutingBucket(source) or 0
    local tierConfig = Config.CrateTiers[tier]

    if not tierConfig then
        cb(false, "Invalid crate tier")
        return
    end

    if not coords or not coords.x or not coords.y or not coords.z then
        cb(false, "Invalid coordinates")
        return
    end

    if route == 0 and (coords.z < Config.MinPlacementHeight or coords.z > Config.MaxPlacementHeight) then
        cb(false, "Cannot place crate at this location")
        return
    end

    local removed, removeErr = RemoveCrateItem(source, sid, tier, slot)

    if not removed then
        cb(false, removeErr)
        return
    end

    local crateId = GenerateCrateId()
    local savedCoords = json.encode({
        x = coords.x,
        y = coords.y,
        z = coords.z,
        route = route,
    })

    local inserted = MySQL.Sync.execute([[
        INSERT INTO storage_crates
            (crate_id, owner_sid, tier, model, coords, heading, has_password)
        VALUES
            (?, ?, ?, ?, ?, ?, ?)
    ]], {
        crateId,
        sid,
        tier,
        tostring(tierConfig.model),
        savedCoords,
        heading,
        false,
    })

    if not inserted then
        GivePlayerCrateItem(source, tier)
        cb(false, "Failed to save crate")
        return
    end

    local crateInfo = {
        id = MySQL.Sync.fetchScalar("SELECT LAST_INSERT_ID()", {}),
        crateId = crateId,
        ownerSid = sid,
        tier = tier,
        model = tierConfig.model,
        coords = vector3(coords.x, coords.y, coords.z),
        heading = heading,
        route = route,
        hasPassword = false,
        passwordHash = nil,
    }

    _activeCrates[crateId] = crateInfo

    exports[GetCurrentResourceName()]:EnsureStashExists(crateId, tier)

    SendCrateToRoute("StorageCrates:Client:SpawnCrate", route, crateId, {
        model = tierConfig.model,
        coords = {
            x = crateInfo.coords.x,
            y = crateInfo.coords.y,
            z = crateInfo.coords.z,
        },
        heading = heading,
    })

    cb(true, crateId)
end)

Callbacks:RegisterServerCallback("StorageCrates:OpenCrate", function(source, data, cb)
    local char = GetCharacter(source)

    if not char then
        cb(false, "Character not found")
        return
    end

    local crateId = data.crateId
    local password = data.password
    local crate = GetCrateInfo(crateId)

    if not crate then
        cb(false, "Crate not found")
        return
    end

    if IsCrateInUse(crateId) and _cratesInUse[crateId] ~= source then
        cb(false, "Crate is currently in use")
        return
    end

    if crate.hasPassword then
        if not password then
            cb(false, "password_required")
            return
        end

        if not VerifyPassword(password, crate.passwordHash) then
            cb(false, "Invalid password")
            return
        end
    end

    local stashId = "crate:" .. crateId

    exports[GetCurrentResourceName()]:EnsureStashExists(crateId, crate.tier)
    SetCrateInUse(crateId, source)

    TriggerClientEvent("StorageCrates:Client:OpenStash", source, stashId)

    cb(true)
end)

Callbacks:RegisterServerCallback("StorageCrates:SetPassword", function(source, data, cb)
    local char = GetCharacter(source)

    if not char then
        cb(false, "Character not found")
        return
    end

    local crateId = data.crateId
    local password = data.password
    local crate = GetCrateInfo(crateId)

    if not crate then
        cb(false, "Crate not found")
        return
    end

    if not SidEquals(crate.ownerSid, char:GetData("SID")) then
        cb(false, "You don't own this crate")
        return
    end

    local hasPassword = password ~= nil and password ~= ""
    local passwordHash = hasPassword and HashPassword(password) or nil

    local updated = MySQL.Sync.execute([[
        UPDATE storage_crates
        SET has_password = ?, password_hash = ?
        WHERE crate_id = ?
    ]], {
        hasPassword and 1 or 0,
        passwordHash,
        crateId,
    })

    if not updated then
        cb(false, "Failed to update password")
        return
    end

    crate.hasPassword = hasPassword
    crate.passwordHash = passwordHash

    cb(true)
end)

Callbacks:RegisterServerCallback("StorageCrates:RemoveCrate", function(source, data, cb)
    local char, sid = GetPlayerSid(source)

    if not char then
        cb(false, "Character not found")
        return
    end

    local crateId = data.crateId
    local crate = GetCrateInfo(crateId)

    if not crate then
        cb(false, "Crate not found")
        return
    end

    if not SidEquals(crate.ownerSid, sid) then
        cb(false, "You don't own this crate")
        return
    end

    if IsCrateInUse(crateId) then
        cb(false, "Crate is currently in use")
        return
    end

    if not CrateStashIsEmpty(crateId) then
        cb(false, "Crate must be empty before removing")
        return
    end

    local tierItem = crate.tier
    if not tierItem or not Config.CrateTiers[tierItem] then
        cb(false, "Invalid crate tier")
        return
    end

    local added, addErr = GivePlayerCrateItem(source, tierItem)
    if not added then
        local msg = type(addErr) == "string" and addErr or "Could not return crate item (inventory full?)"
        cb(false, msg)
        return
    end

    local snap = {
        coords = {
            x = crate.coords.x,
            y = crate.coords.y,
            z = crate.coords.z,
        },
        heading = crate.heading or 0.0,
        model = crate.model,
    }

    SendCrateToRoute("StorageCrates:Client:RemoveCrate", crate.route or 0, crateId, snap)

    local deletedRows = MySQL.Sync.execute("DELETE FROM storage_crates WHERE crate_id = ?", { crateId })
    local deleteOk = (type(deletedRows) == "number" and deletedRows >= 1) or deletedRows == true
    if not deleteOk then
        exports.ox_inventory:Remove(source, 1, tierItem, 1)
        SendCrateToRoute("StorageCrates:Client:SpawnCrate", crate.route or 0, crateId, {
            model = crate.model,
            coords = snap.coords,
            heading = snap.heading,
        })
        cb(false, "Failed to remove crate from database")
        return
    end

    _activeCrates[crateId] = nil
    SetCrateInUse(crateId, nil)

    cb(true)
end)

Callbacks:RegisterServerCallback("StorageCrates:LockpickCrate", function(source, data, cb)
    local char, sid = GetPlayerSid(source)

    if not char then
        cb(false, "Character not found")
        return
    end

    local crateId = data.crateId
    local crate = GetCrateInfo(crateId)

    if not crate then
        cb(false, "Crate not found")
        return
    end

    if SidEquals(crate.ownerSid, sid) then
        cb(false, "You own this crate")
        return
    end

    if not crate.hasPassword then
        cb(false, "Crate is not locked")
        return
    end

    if IsCrateInUse(crateId) and _cratesInUse[crateId] ~= source then
        cb(false, "Crate is currently in use")
        return
    end

    local lockpickType

    if exports.ox_inventory:ItemsGetFirst(sid, "adv_lockpick", 1) then
        lockpickType = "adv_lockpick"
    elseif exports.ox_inventory:ItemsGetFirst(sid, "lockpick", 1) then
        lockpickType = "lockpick"
    end

    if not lockpickType then
        cb(false, "You need a lockpick")
        return
    end

    SetCrateInUse(crateId, source)

    cb(true, lockpickType)
end)

Callbacks:RegisterServerCallback("StorageCrates:CompleteLockpick", function(source, data, cb)
    local char, sid = GetPlayerSid(source)

    if not char then
        cb(false, "Character not found")
        return
    end

    local crateId = data.crateId
    local crate = GetCrateInfo(crateId)
    local lockpickType = data.lockpickType

    if not crate then
        SetCrateInUse(crateId, nil)
        cb(false, "Crate not found")
        return
    end

    if not data.success then
        if lockpickType and math.random() < Config.LockpickBreakChance then
            exports.ox_inventory:Remove(sid, 1, lockpickType, 1)
            Notify(source, "error", "Your lockpick broke!")
        end

        SetCrateInUse(crateId, nil)
        cb(false, "Lockpick failed")
        return
    end

    local stashId = "crate:" .. crateId

    exports[GetCurrentResourceName()]:EnsureStashExists(crateId, crate.tier)
    TriggerClientEvent("StorageCrates:Client:OpenStash", source, stashId)

    MySQL.Sync.execute([[
        UPDATE storage_crates
        SET has_password = 0, password_hash = NULL
        WHERE crate_id = ?
    ]], { crateId })

    crate.hasPassword = false
    crate.passwordHash = nil

    cb(true)
end)