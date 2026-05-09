-- Settings
local porchPirateSpawns = {
    vector4(331.28, 465.98, 150.19, 0.0),
    vector4(315.78, 501.34, 151.18, 0.0),
    vector4(325.79, 537.41, 152.86, 0.0),
    vector4(317.92, 562.42, 153.54, 0.0),
    vector4(223.44, 514.07, 139.77, 0.0),
}

local mailboxLoot = {
    { item = "valuegoods", min = 1, max = 3, chance = 40 },
    { item = "crypto_voucher", min = 1, max = 1, chance = 15 },
    { item = "radio_shitty", min = 1, max = 1, chance = 40 },
    { item = "sombrero", min = 1, max = 1, chance = 60 },
}

local porchLoot = {
    { item = "valuegoods", min = 1, max = 3, chance = 40 },
    { item = "crypto_voucher", min = 1, max = 1, chance = 15 },
    { item = "radio_shitty", min = 1, max = 1, chance = 40 },
    { item = "sombrero", min = 1, max = 1, chance = 60 },
}

local ALERT_METER = 35
local ALERT_MAILBOX = 35
local ALERT_PORCH = 75

local function getLootFromTable(lootTable)
    local roll = math.random(1, 100)
    local cumulativeChance = 0

    for _, loot in ipairs(lootTable) do
        cumulativeChance = cumulativeChance + loot.chance
        if roll <= cumulativeChance then
            return loot
        end
    end

    return lootTable[#lootTable]
end

local function getItemLabel(itemName)
    local def = exports.ox_inventory:ItemsGetData(itemName)
    if type(def) == "table" and type(def.label) == "string" and def.label ~= "" then
        return def.label
    end
    return itemName
end

local function givePlayerItem(src, itemName, amount)
    if not src or not itemName or type(itemName) ~= "string" or not amount or amount < 1 then
        return false
    end
    local current = exports.ox_inventory:GetItemCount(src, itemName) or 0
    local ok = exports.ox_inventory:SetItem(src, itemName, current + amount)
    if ok == true then
        return true, getItemLabel(itemName), amount
    end
    return false
end

local function PDAlert(src, content, content2, name)
    exports["pulsar-robbery"]:TriggerPDAlert(
        src,
        GetEntityCoords(GetPlayerPed(src)),
        "10-24",
        content,
        {
            icon = 500,
            size = 1,
            color = 1,
            duration = (60 * 5),
        },
        {
            icon = "shield-quartered",
            details = content2,
        },
        name
    )
end

AddEventHandler("Robbery:Server:Setup", function()
    setupCallbacks()
    GlobalState["porchPirateSpawns"] = porchPirateSpawns
end)

function setupCallbacks()
    exports["pulsar-core"]:RegisterServerCallback("Robbery:ParkingMeter:Success", function(source, data, cb)
        local src = source
        local char = exports["pulsar-characters"]:FetchCharacterSource(src)

        if not char then
            cb(false)
            return
        end

        if math.random(100) <= ALERT_METER then
            PDAlert(src, "Parking Meter Tampering", "Petty Crime", "parking")
        end

        local qty = math.random(8, 18)
        local ok, label, amt = givePlayerItem(src, "money", qty)
        if ok then
            cb(true, label, amt)
        else
            cb(false)
        end
    end)

    exports["pulsar-core"]:RegisterServerCallback("Robbery:Mailbox:Success", function(source, data, cb)
        local src = source
        local char = exports["pulsar-characters"]:FetchCharacterSource(src)

        if not char then
            cb(false)
            return
        end

        if math.random(100) <= ALERT_MAILBOX then
            PDAlert(src, "Mailbox Robbery", "Petty Crime", "mailbox")
        end

        local loot = getLootFromTable(mailboxLoot)
        if not loot or not loot.item or type(loot.item) ~= "string" or not loot.min or not loot.max then
            cb(false)
            return
        end

        local amount = math.random(loot.min, loot.max)
        local ok, label, amt = givePlayerItem(src, loot.item, amount)
        if ok then
            cb(true, label, amt)
        else
            cb(false)
        end
    end)

    exports["pulsar-core"]:RegisterServerCallback("Robbery:Porch:Pickup", function(source, data, cb)
        local src = source
        local char = exports["pulsar-characters"]:FetchCharacterSource(src)

        if not char then
            cb(false)
            return
        end

        if math.random(100) <= ALERT_PORCH then
            PDAlert(src, "Porch Pirate", "Petty Crime", "porch")
        end

        local loot = getLootFromTable(porchLoot)
        if not loot or not loot.item or type(loot.item) ~= "string" or not loot.min or not loot.max then
            cb(false)
            return
        end

        local amount = math.random(loot.min, loot.max)
        local ok, label, amt = givePlayerItem(src, loot.item, amount)
        if ok then
            cb(true, label, amt)
        else
            cb(false)
        end
    end)

    exports["pulsar-core"]:RegisterServerCallback("Robbery:ParkingMeter:Fail", function(source, data, cb)
        PDAlert(source, "Parking Meter Tampering", "Petty Crime", "parking")
        cb(false)
    end)

    exports["pulsar-core"]:RegisterServerCallback("Robbery:Mailbox:Fail", function(source, data, cb)
        PDAlert(source, "Mailbox Robbery", "Petty Crime", "mailbox")
        cb(false)
    end)
end
