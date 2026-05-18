-- pulsar ox bridge : server side
-- makes ox_inventory pretend to be pulsar inventory so nothing else has to change
-- if something breaks its probably in here, good luck
--
-- REQUIRED in server.cfg or literally none of this loads:
--   set inventory:framework "pulsar"

local Inventory = require 'modules.inventory.server'
local Items     = require 'modules.items.server'

local function toSource(sid)
    local char = exports['pulsar-characters']:FetchBySID(tonumber(sid))
    if not char then return nil end
    return char:GetData('Source')
end

local function toTarget(owner, invType)
    invType = invType or 1
    if invType == 1 then
        local n = tonumber(owner)
        if n then return toSource(n) end
        return owner
    elseif invType == 4 then
        return (owner:sub(1, 6) ~= 'trunk-') and 'trunk-' ..owner or owner
    elseif invType == 5 then
        return (owner:sub(1 , 6) ~= 'glove-') and 'glove-' ..owner or owner
    end
    return owner
end

local function toSlot(slot, owner, invType)
    if not slot then return nil end
    local meta = slot.metadata or {}
    return {
        id = { owner = tostring(owner or ''), slot = slot.slot},
        Owner = tostring(owner or ''),
        invType = invType or 1,
        Name = slot.name,
        Label = slot.label,
        Slot = slot.slot,
        Count = slot.count,
        Quality = meta.quality or 100,
        durability = meta.durability or 100,
        CreateDate = meta.CreateDate or os.time(),
        MetaData = meta,
    }
end

-- ox calls this after setPlayerInventory to build the player data table stored on inv.player

function server.setPlayerData(player)
    if not player.groups then
        print('^1[pulsar-ox-bridge] setPlayerData no groups for' .. tostring(player.name) .. '^0')
    end
    return {
        source = player.source,
        name = player.name,
        groups = player.groups or {},
        sex = player.sex or 0,
        dateofbirth = player.dateofbirth or '',
    }
end

-- build a lookup of item states from all items that have a state field 
-- this should mirror pulsar inventories update shit 
local function buildItemStateMap()
    local stateMap = {}
    local allItems = lib.load('data.pulsar-items.index')
    if allItems then
        for _, item in ipairs(allItems) do
            if item.name and item.state then
                stateMap[item.name] = item.state
            end
        end
    end
    return stateMap
end

local ItemStateMap = buildItemStateMap()

local function updateCharacterStates(source, inv)
    local char = exports['pulsar-characters']:FetchCharacterSource(source)
    if not char then return end
    local playerStates = char:GetData('States') or {}
    local inventoryStates = {}

    -- collect all states
    for _, slotData in pairs(inv.items or {}) do
        if slotData and slotData.name then
            local state = ItemStateMap[slotData.name]
            if state then
                inventoryStates[state] = true
            end
        end
    end

    local changed = false

    -- add states from inventory that arent there?????
    for state in pairs(inventoryStates) do
        local found = false
        for _, s in ipairs(playerStates) do
            if s == state then found = true break end
        end
        if not found then
            table.insert(playerStates, state)
            changed = true
        end
    end

    -- remove state aka drops (skip script/access prefixed ones)
    for i = #playerStates, 1, -1 do
        local s = playerStates[i]
        if not inventoryStates[s]
            and s:sub(1, 6) ~= 'SCRIPT'
            and s:sub(1, 6) ~= 'ACCESS'
        then
            table.remove(playerStates, i)
            changed = true
        end
    end
    if changed then
        char:SetData('States', playerStates)
    end
end

-- cash is handled entirely by the pulsar Wallet component (char:GetData/SetData 'Cash')
-- ox shop payments route through server.canAfford / server.removeMoney in shops/server.lua
-- no money item in inventory, no bidirectional sync needed
function server.syncInventory(inv)
    if not inv?.player then return end
    updateCharacterStates(inv.player.source, inv)

    local accounts = Inventory.GetAccountItemCounts(inv)
    if not accounts then return end
    local char = exports['pulsar-characters']:FetchCharacterSource(inv.player.source)
    if not char then return end
    if accounts.money ~= nil and accounts.money ~= char:GetData('Cash') then
        char:SetData('Cash', accounts.money)
    end
end

function server.hasGroup(inv, group)
    if not inv?.player then return end
    if type(group) == 'table' then
        for name, requiredRank in pairs(group) do
            local groupRank = inv.player.groups[name]
            if groupRank then
                if type(requiredRank) == 'table' then
                    if lib.table.contains(requiredRank, groupRank) then
                        return name, groupRank
                    end
                else
                    if groupRank >= (requiredRank or 0) then
                        return name, groupRank
                    end
                end
            end
        end
    else
        local groupRank = inv.player.groups[group]
        if groupRank then return group, groupRank end
    end
end

function server.hasLicense(source, name)
    local char = exports['pulsar-characters']:FetchCharacterSource(source)
    if not char then return false end
    return char:GetData('Licenses')?[name]?.Active or false
end

local function hasValue(tbl, value)
    if not tbl then return false end
    for _, v in ipairs(tbl) do
        if v == value then return true end
    end
    return false
end

function server.hasQualification(source, name)
    local char = exports['pulsar-characters']:FetchCharacterSource(source)
    if not char then return false end
    return hasValue(char:GetData('Qualifications'), name)
end

-- duty check — reads the onDuty state bag set by pulsar-jobs
-- jobName can be a string or table of strings
function server.isOnDuty(source, jobName)
    local onDuty = Player(source).state.onDuty
    if not onDuty then return false end
    if jobName then
        if type(jobName) == 'table' then
            for _, job in ipairs(jobName) do
                if onDuty == job then return true end
            end
            return false
        end
        return onDuty == jobName
    end
    return true
end

-- reputation level check against pulsar-characters rep system
function server.hasRep(source, rep)
    if not rep then return false end
    return exports['pulsar-characters']:RepHasLevel(source, rep.id, rep.level)
end

-- used by items/shops to check a player's bank balance without withdrawing
function server.hasBalance(source, amt)
    local char = exports['pulsar-characters']:FetchCharacterSource(source)
    if not char then return false end
    local f = exports['pulsar-finance']:AccountsGetPersonal(char:GetData('SID'))
    return f ~= nil and exports['pulsar-finance']:BalanceHas(f.Account, amt)
end

-- used by items/shops to charge a player's bank account
function server.withdrawMoney(source, amt, itemLabel, count)
    local char = exports['pulsar-characters']:FetchCharacterSource(source)
    if not char then return false end
    local sid = char:GetData('SID')
    local f = exports['pulsar-finance']:AccountsGetPersonal(sid)
    if not f then return false end
    return exports['pulsar-finance']:BalanceWithdraw(f.Account, amt, {
        type               = 'withdraw',
        title              = 'Shop Purchase',
        description        = ('Bought %s x%s'):format(itemLabel or 'item', count or 1),
        transactionAccount = false,
        data               = { character = sid },
    })
end

-- ox shop system calls these two when a player buys something
function server.canAfford(source, price)
    return server.hasBalance(source, price)
end

function server.removeMoney(source, price, reason)
    return server.withdrawMoney(source, price, reason, 1)
end

-- [compType][drawableId][textureId] = itemName
local StaticMetaIndex
do
    local allItems = lib.load('data.pulsar-items.index') or {}
    local idx = {}
    for _, item in ipairs(allItems) do
        if item.staticMetadata then
            for compType, meta in pairs(item.staticMetadata) do
                if type(meta) == 'table' and meta.drawableId ~= nil and meta.textureId ~= nil then
                    idx[compType] = idx[compType] or {}
                    idx[compType][meta.drawableId] = idx[compType][meta.drawableId] or {}
                    idx[compType][meta.drawableId][meta.textureId] = item.name
                end
            end
        end
    end
    StaticMetaIndex = idx
end

-- overrides so methods inside Inventory.Items and loot functions all reference the ox functions
local _origAddItem    = Inventory.AddItem
local _origRemoveItem = Inventory.RemoveItem

-- every single pulsar resource registers item callbacks through here so this HAS to work
local ItemCallbacks = {}

Inventory.Items = {
    RegisterUse = function(self, itemName, id, cb)
        ItemCallbacks[itemName] = ItemCallbacks[itemName] or {}
        ItemCallbacks[itemName][id] = cb
    end,

    GetData = function(self, name)
        return Items(name)
    end,

    -- searches items for one whose staticMetadata[itemType] matches componentData[key1] and componentData[key2]
    GetWithStaticMetadata = function(self, itemType, key1, key2, gender, componentData)
        if not componentData then return nil end
        local val1 = componentData[key1]
        local val2 = componentData[key2]
        if val1 == nil or val2 == nil then return nil end
        local byType = StaticMetaIndex[itemType]
        if not byType then return nil end
        local byKey1 = byType[val1]
        if not byKey1 then return nil end
        return byKey1[val2]
    end,

    GetCount = function(self, owner, invType, itemName)
        local target = toTarget(owner, invType)
        if not target then return 0 end
        local inv = Inventory(target)
        if not inv then return 0 end
        return Inventory.GetItemCount(inv, itemName) or 0
    end,

    GetFirst = function(self, owner, invType, itemName)
        local target = toTarget(owner, invType)
        if not target then return nil end
        local slot = Inventory.GetSlotWithItem(Inventory(target), itemName)
        return toSlot(slot, owner, invType)
    end,

    GetAll = function(self, owner, invType, itemName, slotNum)
        local target = toTarget(owner, invType)
        if not target then return {} end
        local inv = Inventory(target)
        if not inv or not inv.items then return {} end
        local result = {}
        for _, slot in pairs(inv.items) do
            if slot.name == itemName then
                result[#result + 1] = toSlot(slot, owner, invType) 
            end
        end
        return result
    end,

    GetDurability = function(self, owner, invType, itemName, slotNum)
        local target = toTarget(owner, invType)
        if not target then return 0 end
        local slot = Inventory.GetSlot(Inventory(target), slotNum)
        if not slot then return 0 end
        return math.max(0, math.min(100, (slot.metadata or {}).durability or 100))
    end,

    Broken = function(self, owner, invType, itemName, slotNum)
        return self:GetDurability (owner, invType, itemName, slotNum) <= 0
    end,

    Has = function(self, owner, invType, itemName, count)
        return self:GetCount(owner, invType, itemName)>= (count or 1)
    end,

    HasAnyItems = function(self, source, items)
        for _, v in ipairs(items) do
            local key = v.item or v.name
            if (Inventory.GetItemCount(Inventory(source), key) or 0) >= (v.count or 1) then
                return true
            end
        end
        return false
    end,
    -- owner = SID for players, stash/container ID for everything else
    RemoveSlot = function(self, owner, name, count, slotNum, invType)
        local target = toTarget(owner, invType)
        if not target then return false end
        return Inventory.RemoveItem(Inventory(target), name, count or 1, nil, slotNum)
    end,

    -- removes by slot object reference, robbery and police use this a lot
    -- slot is the pulsar slot object with .Owner .Name .Slot .invType fields
    RemoveId = function(self, owner, invType, slot)
        local target = toTarget(owner, invType)
        if not target then return false end
        return _origRemoveItem(Inventory(target), slot.Name or slot.name, 1, nil, slot.Slot or slot.slot)
    end,

    -- plain remove by item name and count, no slot targeting
    Remove = function(self, owner, invType, itemName, count)
        local target = toTarget(owner, invType)
        if not target then return false end
        return Inventory.RemoveItem(Inventory(target), itemName, count or 1)
    end,

    -- nukes every stack of an item, robbery uses this to clear access codes etc
    RemoveAll = function(self, owner, invType, itemName)
        local target = toTarget(owner, invType)
        if not target then return true end
        local inv = Inventory(target)
        local count = Inventory.GetItemCount(inv, itemName) or 0
        if count > 0 then return Inventory.RemoveItem(inv, itemName, count)
        end
        return true
    end,

    --removes a list of items in one call, weed and drugs use this for multi-ingredient recipes
    -- items = {{ name = 'thing', count = 1 }, ...}
    RemoveList = function(self, owner, invType, items)
        for _, v in ipairs(items) do
            self:Remove(owner, invType, v.name, v.count or 1)
        end
    end,

    -- pulsar-ped calls this to find clothing items by staticMetadata (drawableId/textureId)
    -- we build an index at startup: [compType][drawableId][textureId] = itemName
    GetWithStaticMetadata = function(self, masterKey, mainIdName, textureIdName, gender, data)
        if not StaticMetaIndex then return nil end
        local byMaster = StaticMetaIndex[masterKey]
        if not byMaster then return nil end
        local byMain = byMaster[data[mainIdName]]
        if not byMain then return nil end
        local itemName = byMain[data[textureIdName]]
        if not itemName then return nil end
        local itemDef = Items(itemName)
        if not itemDef then return nil end
        return { Name = itemName, Label = itemDef.label }
    end,

}

local function injectDefaultMeta(itemName, meta, inventoryOwner)
    if type(meta) ~= 'table' then meta = {} end
    local iname   = type(itemName) == 'string' and itemName:lower() or nil
    if not iname then return meta end
    local itemDef = Items(iname)
    if not itemDef then return meta end
    -- staticMetadata baked into the item definition
    if itemDef.staticMetadata then
        for k, v in pairs(itemDef.staticMetadata) do
            if meta[k] == nil then meta[k] = v end
        end
    end
    -- type-specific auto metadata
    local mtype = itemDef.server and itemDef.server.pulsarType or 0
    if mtype == 2 and not meta.SerialNumber then
        meta.SerialNumber = math.random(100000, 999999)
    elseif mtype == 10 and not meta.Container then
        meta.Container = ('container:%d%d'):format(os.time(), math.random(1000, 9999))
    elseif mtype == 11 and not meta.Quality then
        meta.Quality = math.random(100)
    end
    if iname == 'cigarette_pack' and not meta.Count then meta.Count = 30 end
    if iname == 'crypto_voucher' then
        if not meta.CryptoCoin then meta.CryptoCoin = 'PLEB' end
        if not meta.Quantity   then meta.Quantity   = math.random(25, 50) end
    end
    -- character-data items — resolve source from inventory owner (SID or numeric source)
    if (iname == 'govid' or iname == 'phone') and inventoryOwner then
        local src = type(inventoryOwner) == 'number' and inventoryOwner or toSource(inventoryOwner)
        if src then
            local char = exports['pulsar-characters']:FetchCharacterSource(src)
            if char then
                if iname == 'govid' then
                    if not meta.Name       then meta.Name       = ('%s %s'):format(char:GetData('First') or '', char:GetData('Last') or '') end
                    if not meta.Gender     then meta.Gender     = char:GetData('Gender') == 1 and 'Female' or 'Male' end
                    if not meta.PassportID then meta.PassportID = char:GetData('User') end
                    if not meta.StateID    then meta.StateID    = char:GetData('SID') end
                    if not meta.DOB        then meta.DOB        = char:GetData('DOB') end
                elseif iname == 'phone' then
                    if not meta.PhoneNumber then meta.PhoneNumber = char:GetData('Phone') end
                end
            end
        end
    end
    return meta
end

function BuildDefaultMeta(itemName, source)
    return injectDefaultMeta(itemName, {}, source)
end

-- ox calls this when someone uses a non-weapon item with no consume set
-- translates ox slot data back into the pulsar item format that callbacks expect
function server.UseItem(source, itemName, data)
    local itemDef = Items(itemName)

    if itemDef and itemDef.server and itemDef.server.vehicleBlock then
        if GetVehiclePedIsIn(GetPlayerPed(source)) ~= 0 then
            TriggerClientEvent('HUD:Client:Notification', source, { type = 'error', message = 'Cannot use while in a vehicle', duration = 5000 })
            return
        end
    end

    -- pulsar weapon (type 2): toggle equip/unequip on client via pulsar system
    if itemDef and itemDef.server and itemDef.server.pulsarType == 2 then
        TriggerClientEvent('Weapons:Client:Use', source, {
            Name     = itemName,
            Slot     = data.slot,
            Count    = data.count or 0,
            MetaData = data.metadata or {},
            Owner    = tostring(source),
            invType  = 1,
        })
        return
    end

    -- pulsar attachments
    if itemDef and itemDef.server and itemDef.server.pulsarType == 16 then
        local component = itemDef.server.pulsarComponent
        if not component then return end
        TriggerClientEvent('Weapons:Client:UseAttachment', source, {
            itemName  = itemName,
            itemSlot  = data.slot,
            itemMeta  = data.metadata,
            component = component,
        })
        return
    end

    -- pulsar ammo (type 9): send to client for progress bar + ammo add, remove on AmmoLoaded
    if itemDef and itemDef.server and itemDef.server.pulsarType == 9 then
        TriggerClientEvent('Inventory:Client:AmmoLoad', source, {
            ammoType    = itemDef.server.ammoType,
            bulletCount = itemDef.server.bulletCount or 10,
            itemName    = itemName,
            itemSlot    = data.slot,
            itemMeta    = data.metadata,
        })
        return
    end

    local callbacks = ItemCallbacks[itemName]
    local _char = exports['pulsar-characters']:FetchCharacterSource(source)
    local _owner = _char and tostring(_char:GetData('SID')) or tostring(source)
    local pulsarItem = toSlot(data, _owner, 1)
    local animConfig = itemDef and itemDef.server and itemDef.server.animConfig

    if animConfig then
        local p = promise.new()
        exports['pulsar-core']:ClientCallback(source, 'Inventory:ItemUse', {
            anim = animConfig.anim,
            time = animConfig.time,
            pbConfig = animConfig.pbConfig,
        }, function(success)
            p:resolve(success)
        end)
        if not Citizen.Await(p) then return end
    end

    if callbacks then
        for _, cb in pairs(callbacks) do
            cb(source, pulsarItem, itemDef)
        end
    end

    -- auto remove if flagged as consumed but only if a callback didnt already pull it
    if itemDef and itemDef.server and itemDef.server.isRemoved then
        local stillThere = Inventory.GetSlot(Inventory(source), data.slot)
        if stillThere and stillThere.name == itemName then
            Inventory.RemoveItem(Inventory(source), itemName, 1, data.metadata, data.slot)
        end
    end
end

-- client resolved attachment compatibility and sends back result to persist
RegisterServerEvent('Weapons:Server:ApplyAttachment', function(req)
    local source = source
    local inv = Inventory(source)
    if not inv then return end

    local attachSlot = inv.items[req.attachItemSlot]
    if not attachSlot or attachSlot.name ~= req.attachItemName then return end

    local weapSlot = inv.items[req.weaponSlot]
    if not weapSlot or weapSlot.name ~= req.weaponName then return end
    local weapDef = Items(req.weaponName)
    if not weapDef or not weapDef.server or weapDef.server.pulsarType ~= 2 then return end

    local meta = table.clone(weapSlot.metadata or {})
    meta.WeaponComponents = req.newComponents
    Inventory.SetMetadata(inv, req.weaponSlot, meta)

    Inventory.RemoveItem(inv, req.attachItemName, 1, req.attachItemMeta, req.attachItemSlot)

    if req.returnItemName then
        Inventory.AddItem(inv, req.returnItemName, 1, {})
    end

    TriggerClientEvent('Weapons:Client:UpdateAttachments', source, req.newComponents)
end)

-- client confirmed ammo loaded after progress bar — remove the ammo box
RegisterServerEvent('Inventory:Server:AmmoLoaded', function(itemName, itemSlot, itemMeta)
    local source = source
    Inventory.RemoveItem(Inventory(source), itemName, 1, itemMeta, itemSlot)
end)

-- client saves weapon ammo into item metadata when unequipping or on timer
RegisterServerEvent('Weapon:Server:UpdateAmmo', function(slot, ammo, clip)
    local source = source
    local inv = Inventory(source)
    if not inv then return end
    slot = tonumber(slot)
    if not slot then return end
    local item = inv.items[slot]
    if not item then return end
    local meta = table.clone(item.metadata or {})
    meta.ammo = ammo
    meta.clip = clip
    Inventory.SetMetadata(inv, slot, meta)
end)

RegisterServerEvent('Weapon:Server:UpdateAmmoDiff', function(slot, ammo, clip)
    local source = source
    local inv = Inventory(source)
    if not inv then return end
    slot = tonumber(slot)
    if not slot then return end
    local item = inv.items[slot]
    if not item then return end
    local meta = table.clone(item.metadata or {})
    meta.ammo = (meta.ammo or 0) + (ammo or 0)
    meta.clip = clip
    Inventory.SetMetadata(inv, slot, meta)
end)

-- the shims that make FetchComponent('Inventory') work without changing any other resource
-- shims detect calling convention: ox-internal passes an inventory object (has .slots),
-- pulsar component calls pass the module table as self with owner/name/count args

Inventory.AddItem = function(self, owner, name, count, metadata, invType)
    if type(self) == 'table' and self.slots then
        -- called as Inventory.AddItem(inventoryObj, itemName, count, metadata)
        -- arg positions: owner=itemName, name=count, count=metadata
        local injected = injectDefaultMeta(owner, count, self.owner)
        return _origAddItem(self, owner, name, injected, metadata, invType)
    end
    local target = toTarget(owner, invType)
    if not target then
        print('^1[pulsar-ox-bridge] AddItem: could not resolve owner ' .. tostring(owner) .. '^0')
        return false
    end
    metadata = injectDefaultMeta(name, metadata, target)
    return _origAddItem(Inventory(target), name, count or 1, metadata)
end

Inventory.RemoveItem = function(self, owner, name, count, metadata, invType)
    if type(self) == 'table' and self.slots then
        return _origRemoveItem(self, owner, name, count, metadata, invType)
    end
    local target = toTarget(owner, invType)
    if not target then return false end
    return _origRemoveItem(Inventory(target), name, count or 1, metadata)
end

-- at least one item from the list must be present
Inventory.HasAnyItems = function(self, source, items)
    for _, v in ipairs(items) do
        if (Inventory.GetItemCount(Inventory(source), v.item) or 0) >= (v.count or 1) then
            return true
        end
    end
    return false
end

Inventory.SetMetadataKey = function(self, owner, key, value, invType, slotNum)
    local target = toTarget(owner, invType)
    if not target then return end
    local inv = Inventory(target)
    if not inv then return end
    for _, slot in pairs(inv.items) do
        if slot.slot == slotNum then
            local meta = slot.metadata or {}
            meta[key] = value
            Inventory.SetMetadata(inv, slot.slot, meta)
            return
        end
    end
end

Inventory.UpdateMetaData = function(self, owner, metadata, slotNum, invType)
    local inv, resolvedSlot

    -- toSlot() produces this id table; detect it so old callers keep working.
    if type(owner) == 'table' and owner.slot then
        local src = tonumber(owner.owner)
        if not src then return end
        inv = Inventory(src)
        resolvedSlot = owner.slot
        if inv and inv.items then
            local slot = inv.items[resolvedSlot]
            if not slot then return end
            local meta = slot.metadata or {}
            for k, v in pairs(metadata) do meta[k] = v end
            Inventory.SetMetadata(inv, resolvedSlot, meta)
        end
        return
    else
        -- Standard format: UpdateMetaData(owner/sid, metadata, slotNum, invType)
        local target = toTarget(owner, invType)
        if not target then return end
        inv = Inventory(target)
        resolvedSlot = slotNum
    end

    if not inv then return end
    local slot = Inventory.GetSlot(inv, resolvedSlot)
    if not slot then return end
    local meta = slot.metadata or {}
    for k, v in pairs(metadata) do
        meta[k] = v
    end
    Inventory.SetMetadata(inv, resolvedSlot, meta)
end

-- crafting calls this to know if theres space before adding output items
-- ox doesnt have a direct export for this so we dig into the inventory object
-- returns a list of free slot numbers (1-indexed, matching pulsar expectation)
Inventory.GetFreeSlotNumbers = function(self, source)
    local inv = Inventory(source)
    if not inv then return {} end
    local free = {}
    for i = 1, inv.slots do
        if not inv.items[i] or not inv.items[i].name then
            free[#free + 1] = i
        end
    end
    return free
end

-- handles opening stashes, trunks, gloveboxes, drops, shops
-- registers stashes with ox on first open so we dont have to preregister every single one
local registeredStashes = {}
local _polyInvs =  {}
local _shopDutyRestrictions = {
    ['armory:police'] = 'police',
    ['armory:doc'] = 'corrections',
}

local invTypeToOxType = {
      -- trunks / gloveboxes / drops
      [4]  = 'trunk',
      [5]  = 'glovebox',
      [10] = 'drop',
      -- stashes
      [3]  = 'stash', -- police weapon rack
      [13] = 'stash', -- apartment/personal stash
      [44] = 'stash', -- evidence case locker
      [45] = 'stash', -- personal pd/ems locker
      -- shops
      [6]   = 'shop', -- liquor store
      [7]   = 'shop', -- hardware store
      [11]  = 'shop', -- general shop
      [12]  = 'shop', -- ammunation
      [26]  = 'shop', -- medical supply
      [27]  = 'shop', -- pd armory
      [28]  = 'shop', -- hunting supplies
      [37]  = 'shop', -- doc armory
      [38]  = 'shop', -- vending
      [39]  = 'shop', -- vending
      [40]  = 'shop', -- vending
      [41]  = 'shop', -- vending
      [42]  = 'shop', -- pharmacy
      [43]  = 'shop', -- fuel station
      [61]  = 'shop', -- food wholesaler
      [62]  = 'shop', -- smoke on the water
      [74]  = 'shop', -- digital den
      [76]  = 'shop', -- winery
      [99]  = 'shop', -- fishing supplies
      [112] = 'shop',
      [115] = 'shop', -- doj shop
      [5005] = 'shop', -- cafe
}

exports['ox_inventory']:registerHook('openShop', function(payload)
    local shopType = payload.shopType
    local required = shopType and _shopDutyRestrictions[shopType]
    if not required then return true end
    local onDuty = Player(payload.source).state.onDuty
    if onDuty ~= required then
        return false
    end
    return true
end)

Inventory.OpenSecondary = function(self, source, invType, owner, vehClass, vehModel, isRaid, nameOverride, slotOverride, capacityOverride)
    if not source or not invType or not owner then return end
    owner = tostring(owner)

    local oxType  = invTypeToOxType[invType]
    local isStash = oxType == 'stash' or (oxType == nil and invType ~= 4 and invType ~= 5 and invType ~= 10)
    local stashLabel = nameOverride or ({
        [13] = 'Apartment Stash',
        [44] = 'Evidence Locker',
        [45] = 'Personal Locker',
        [3] = 'Police Weapon Rack',
    })[invType] or owner
    if isStash then
        if not registeredStashes[owner] then
            exports['ox_inventory']:RegisterStash(
                owner,
                stashLabel,
                slotOverride or 50,
                capacityOverride or 100000
            )
            registeredStashes[owner] = true
        end
        TriggerClientEvent('Inventory:Client:Load', source, { invType = invType, owner = owner })
    elseif invType == 11 then
        -- TODO: shops need ox-format definitions before this actually works
        TriggerClientEvent('Inventory:Client:Load', source, { invType = 11, owner = owner })
    elseif invType == 4 or invType == 5 then
        -- resolve vehicle server side by vin - dont trust client loop
        local oxInvType = invType == 4 and 'trunk' or 'glovebox'
        local targetEntity
        for _, entity in ipairs(GetAllVehicles()) do
            if Entity(entity).state.VIN == owner then
                targetEntity = entity
                break
            end
        end
        if targetEntity then
            local netId = NetworkGetNetworkIdFromEntity(targetEntity)
            exports['ox_inventory']:forceOpenInventory(source, oxInvType, { netid = netId })
        else
            print('^3[pulsar-ox-bridge] OpenSecondary: no vehicle found with VIN: ' .. tostring(owner) .. ' for ' .. oxInvType .. '^0')
        end
    elseif invType == 10 then
        TriggerClientEvent('Inventory:Client:Load', source, { invType = 10, owner = owner })
    end
end

Inventory.Poly = {
    Create = function(self, storage)
        if not storage or not storage.id then return end
        local inv = storage.data and storage.data.inventory
        local owner = (inv and inv.owner) or storage.id
        local slots = (inv and inv.slots) or 50
        local capacity = (inv and inv.capacity) or 100000

        local invType = inv and inv.invType or 13
        local oxType = invTypeToOxType[invType] or 'stash'
        if oxType ~= 'shop' and not registeredStashes[owner] then
            exports['ox_inventory']:RegisterStash(owner, storage.name or storage.id, slots, capacity)
            registeredStashes[owner] = true
        end
        table.insert(_polyInvs, storage.id)
        GlobalState[('Inventory:%s'):format(storage.id)] = storage
    end
}

-- state bag sync, items with a state field in their def auto-set that state on the character
-- skips SCRIPT_ and ACCESS_ prefixes, those are handled elsewhere
local function UpdateCharacterItemStates(source, itemName, adding)
    local itemDef = Items(itemName)
    if not itemDef or not itemDef.server or not itemDef.server.state then return end

    local state = itemDef.server.state
    if state:sub(1, 7) == 'SCRIPT_' or state:sub(1, 7) == 'ACCESS_' then return end

    local charState = Player(source).state
    local states    = charState.ItemStates or {}
    states[state]   = adding and true or nil
    charState:set('ItemStates', states, true)
end

exports['ox_inventory']:registerHook('addItem', function(payload)
    UpdateCharacterItemStates(payload.source, payload.item, true)
end)

exports['ox_inventory']:registerHook('removeItem', function(payload)
    UpdateCharacterItemStates(payload.source, payload.item, false)
end)

-- openInventory hook fires when ox opens any secondary inventory
-- pulsar-labor coke job listens to Inventory:Server:Opened(source, owner, invType) to track trunk opens
-- payload.inventoryId for trunks is 'trunk'..VIN so we strip the prefix for the pulsar event
exports['ox_inventory']:registerHook('openInventory', function(payload)
    local oxType     = payload.inventoryType
    local invTypeNum = ({ trunk=4, glovebox=5, drop=10, shop=11, stash=13 })[oxType] or 13
    local owner      = payload.inventoryId

    -- strip the 'trunk'/'glove' prefix ox adds so pulsar resources get the raw VIN/plate
    if oxType == 'trunk' and owner:sub(1, 6) == 'trunk-' then
        owner = owner:sub(7)
    elseif oxType == 'glovebox' and owner:sub(1, 6) == 'glove-' then
        owner = owner:sub(7)
    end

    TriggerEvent('Inventory:Server:Opened', payload.source, owner, invTypeNum)
end)

local function weightedRandom(set)
    local total = 0
    for _, v in ipairs(set) do total = total + v[1] end
    local roll = math.random() * total
    local data = 0
    for _, v in ipairs(set) do
        data = data + v[1]
        if roll <= data then return v[2] end
    end
end

local _Loot = {}

_Loot.CustomSet = function(self, set, owner, invType, count)
    local target = toTarget(owner, invType)
    if not target then return end
    local item = set[math.random(#set)]
    return _origAddItem(Inventory(target), item, count or 1)
end

_Loot.CustomSetWithCount = function(self, set, owner, invType)
    local target = toTarget(owner, invType)
    if not target then return end
    local i = set[math.random(#set)]
    return _origAddItem(Inventory(target), i.name, math.random(i.min or 1 , i.max or 1))
end


_Loot.CustomWeightedSet = function(self, set, owner, invType)
    local target = toTarget(owner, invType)
    if not target then return end
    local item = weightedRandom(set)
    if item then return _origAddItem(Inventory(target), item, 1) end
end

_Loot.CustomWeightedSetWithCount = function(self, set, owner, invType, dontAdd)
    local item = weightedRandom(set)
    if not item or not item.name then return end
    local count = math.random(item.min or 1, item.max or 1)
    if dontAdd then return { name = item.name, count = count } end
    local target = toTarget(owner, invType)
    if not target then return end 
    return _origAddItem(Inventory(target), item.name, count, item.metadata or {})
end

_Loot.CustomWeightedSetWithCountAndModifier = function(self, set, owner, invType, modifier, dontAdd)
    local item = weightedRandom(set)
    if not item or not item.name then return end
    local count = math.floor(math.random(item.min or 1, item.max or 1 ) * (modifier or 1))
    if dontAdd then return { name = item.name, count = count } end
    local target = toTarget(owner, invType)
    if not target then return end
    return _origAddItem(Inventory(target), item.name, count, item.metadata or {})
end

_Loot.Sets = {
    Gem = function(self, owner, invType)
        local target = toTarget(owner, invType)
        if not target then return end
        local gem = weightedRandom({
              {8,  'diamond'},
              {5,  'emerald'},
              {10, 'sapphire'},
              {12, 'ruby'},
              {16, 'amethyst'},
              {18, 'citrine'},
              {31, 'opal'},
        })
        if gem then _origAddItem(Inventory(target), gem, 1) end
    end,
    Ore = function(self, owner, invType, count)
        local target = toTarget(owner, invType)
        if not target then return end
        local ore = weightedRandom({
            {18, 'goldore'},
            {27, 'silverore'},
            {55, 'ironore'},
        })
        if ore then _origAddItem(Inventory(target), ore, count or 1) end
    end,
}


-- TODO: crafting system is NOT bridged
-- pulsar-crafting uses:
--   Inventory.Items:Has(source, name, count)       <- shimmed above
--   Inventory.Items:Remove(owner, invType, name, count, skipUpdate) <- skipUpdate flag ignored, should be fine
--   Inventory:GetFreeSlotNumbers(source)           <- shimmed above
--   Inventory:AddItem(source, name, count, meta)   <- shimmed above
--   Crafting:RegisterBench(id, config)             <- NOT shimmed, pulsar-crafting registers benches via FetchComponent('Crafting')
--   crafting_cooldowns DB table in MySQL           <- doesnt exist in ox db, will error on first craft
-- FIXIT: either bridge pulsar-crafting's RegisterBench into ox's RegisterCraft system,
--        or port pulsar-crafting to call exports['ox_inventory'] directly
--        for now the stub below prevents crash-on-nil but crafting wont actually work

-- stub crafting component so resources dont explode on FetchComponent('Crafting')
-- everything returns false/nil, nothing will actually craft
-- FIXIT: replace this with real logic when you get around to it
local function pulsarRecipesToOx(recipes)
    local items = {}
    for k, v in pairs(recipes) do
        local ingredients = {}
        for _, ing in ipairs(v.items or {}) do
            ingredients[ing.name:lower()] = ing.count
        end

        items[#items + 1] = {
            name = v.result.name:lower(),
            count = v.result.count or 1,
            duration = v.time or 5000,
            ingredients = ingredients,
            metadata = v.metadata or {},
            slot = #items + 1,
        }
    end
    return items
end

local function pulsarTargetToOx(targeting, location)
    if not targeting then return nil, nil end
    if targeting.poly then
        local opts = targeting.poly.options or {}
        return nil, {
            {
                coords   = targeting.poly.coords,
                size     = vector3(targeting.poly.l or 2.0, targeting.poly.w or 2.0, 2.0),
                rotation = opts.heading or 0,
                minZ     = opts.minZ,
                maxZ     = opts.maxZ,
            }
        }
    end

    if targeting.model or targeting.ped then
        return nil, nil -- handled via pulsar-targeting no ox zone needed
    end

    if not location then return nil, nil end

    local x, y, z

    if type(location) == 'vector3' or type(location) == 'vector4' then
        x, y, z = location.x, location.y, location.z
    elseif type(location) == 'table' and location.x and location.y and location.z then
        x, y, z = location.x, location.y, location.z
    else
        return nil, nil
    end

    return { vector3(x, y, z) }, nil
end

local function pulsarRestrictionsToOx(restrictions)
    if not restrictions then return nil end
    if restrictions.shared then return nil end --group restrictions
    if restrictions.job then
        return { [restrictions.job.id] = restrictions.job.grade or 0 }
    end
    return nil
end

local _benchTargets = {}

local CraftingReal = {}

  CraftingReal.RegisterBench = function(self, id, label, targeting, location, restrictions, recipes, canUseSchematics)
      local items  = pulsarRecipesToOx(recipes or {})
      local groups = pulsarRestrictionsToOx(restrictions)
      local points, zones = pulsarTargetToOx(targeting, location)

      local data = {
          label            = label,
          items            = items,
          groups           = groups,
          points           = points,
          zones            = zones,
          canUseSchematics = canUseSchematics or false,
      }

      exports['ox_inventory']:RegisterCraftingBench(id, data)

      -- store for sending to clients on spawn
      _benchTargets[#_benchTargets + 1] = {
          id        = id,
          label     = label,
          targeting = targeting,
          location  = location,
          oxData    = data,
      }

      print(('^2[pulsar-ox-bridge] Registered crafting bench: %s^0'):format(tostring(id)))
  end

CraftingReal.AddRecipieToBench = function(self, bench, id, recipe) end -- future use??
CraftingReal.CanCraft = function(self, ...) return false end
CraftingReal.StartCraft = function (self, ...) return false end
CraftingReal.Craft = { Start = function() end, End = function() end, Cancel = function () end }
CraftingReal.Schematics = { Has = function () return false end, Add = function() end }

-- expose CraftingReal to crafting_server.lua (same resource, shared global scope)
_CraftingBridge = CraftingReal

-- lifecycle hooks — wait for pulsar-core to be ready before registering middleware
CreateThread(function()
    repeat Wait(100) until pcall(function() exports['pulsar-core']:GetPlsfwVersion() end)

    local _newCharSources = {}
    exports['pulsar-core']:MiddlewareAdd('Characters:Created', function(source)
        _newCharSources[source] = true
        return true
    end, 5)

    -- on character spawn we build the plain table ox expects and call its setPlayerInventory
    -- ox then loads the DB inventory, creates the inv object, and calls our server.setPlayerData
    exports['pulsar-core']:MiddlewareAdd('Characters:Spawning', function(source)
        local char = exports['pulsar-characters']:FetchCharacterSource(source)
        if not char then return end

        local jobs   = char:GetData('Jobs') or {}
        local groups = {}
        for _, v in ipairs(jobs) do
            groups[v.Id] = v.Grade and v.Grade.Level or 0
        end

        local charFirst = char:GetData('First') or ''
        local charLast = char:GetData('Last') or ''
        local charName = (charFirst .. ' ' .. charLast):gsub('^%s+', ''):gsub('%s+$', '')
        local player = exports['pulsar-core']:FetchSource(source)
        if charName == '' and player then charName = player:GetData('Name') end
        local cash = char:GetData('Cash') or 0
        exports['ox_inventory']:setPlayerInventory({
            source      = source,
            name        = charName,
            identifier  = char:GetData('SID'),
            groups      = groups,
            sex         = char:GetData('Gender') or 0,
            dateofbirth = char:GetData('DOB') or '',
        })
        exports['ox_inventory']:SetItem(source, 'money', cash)
        if _newCharSources[source] then
            _newCharSources[source] = nil
            local startItems = {
                { name = 'govid',         count = 1 },
                { name = 'phone',         count = 1 },
                { name = 'water',         count = 5 },
                { name = 'sandwich_blt',  count = 5 },
                { name = 'bandage',       count = 5 },
                { name = 'coffee',        count = 2 },
            }

            for slot, item in ipairs(startItems) do
                exports['ox_inventory']:AddItem(source, item.name, item.count, BuildDefaultMeta(item.name, source), slot)
            end
        end

        local SID = char:GetData('SID')
        local schematicRows = MySQL.query.await('SELECT schematic FROM player_schematics WHERE citizenid = ?', { SID })
        local unlockedSchematics = {}
        for _, row in ipairs(schematicRows or {}) do
            unlockedSchematics[row.schematic] = true
        end
        Player(source).state:set('unlockedSchematics', unlockedSchematics, true)

        TriggerClientEvent('Inventory:Client:PolySetup', source, _polyInvs)
        TriggerClientEvent('ox_inventory:bridge:SetupCraftingBenches', source, _benchTargets)
    end, 5)

    -- close and remove inventory on character logout
    -- note: playerDropped is handled by ox's generic bridge/server.lua already
    exports['pulsar-core']:MiddlewareAdd('Characters:Logout', function(source)
        local inv = Inventory(source)
        if inv and inv.player then
            inv:closeInventory()
            Inventory.Remove(inv)
        end
        return true
    end, 5)

    exports['pulsar-core']:RegisterServerCallback('Inventory:Server:Open', function(source, data, cb)
        if not data or not data.invType or not data.owner then cb(false) return end
        Inventory.OpenSecondary(Inventory, source, data.invType, data.owner, data.class or false, data.model or false)
        cb(true)
    end)
end)

-- when another system modifies Cash directly (e.g. finance), keep the money item in sync
RegisterNetEvent('Characters:Server:SetData', function(src, key, data)
    if key == 'Cash' then
        exports['ox_inventory']:SetItem(src, 'money', tonumber(data) or 0)
    end
end)

-- ensure player_schematics table exists
MySQL.query([[
    CREATE TABLE IF NOT EXISTS `player_schematics` (
        `citizenid` varchar(50) NOT NULL,
        `schematic`  varchar(100) NOT NULL,
        `bench`      varchar(100) NOT NULL DEFAULT 'crafting-schematics',
        PRIMARY KEY (`citizenid`, `schematic`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
]])

-- register item use handlers for all schematic items
CreateThread(function()
    repeat Wait(100) until pcall(function() exports['pulsar-core']:GetPlsfwVersion() end)
    local InvServer = require 'modules.inventory.server'
    local schematics = lib.load('data.pulsar-crafting.schematic_config') or {}

    for schematicKey, _ in pairs(schematics) do
        local key      = schematicKey
        local itemName = 'schematic_' .. key
        InvServer.Items:RegisterUse(itemName, 'UnlockSchematic', function(source, slotData)
            local char = exports['pulsar-characters']:FetchCharacterSource(source)
            if not char then return end
            local SID = char:GetData('SID')

            local current = Player(source).state.unlockedSchematics or {}
            if current[key] then
                TriggerClientEvent('ox_lib:notify', source, {
                    title       = 'Schematic',
                    description = 'You already know this recipe!',
                    type        = 'warning',
                })
                return
            end

            exports['ox_inventory']:RemoveItem(source, itemName, 1, nil, slotData.Slot)

            MySQL.insert('INSERT IGNORE INTO player_schematics (citizenid, schematic, bench) VALUES (?, ?, ?)', {
                SID, key, 'crafting-schematics'
            })

            local updated = {}
            for k, v in pairs(current) do updated[k] = v end
            updated[key] = true
            Player(source).state:set('unlockedSchematics', updated, true)

            TriggerClientEvent('ox_lib:notify', source, {
                title       = 'Schematic Unlocked!',
                description = ('Recipe unlocked at the crafting bench.'),
                type        = 'success',
            })
        end)
    end
    local count = 0; for _ in pairs(schematics) do count = count + 1 end
    print(('^2[pulsar-ox-bridge] Registered %s schematic item use handlers^0'):format(count))
end)

-- load pulsar items from within this execution chain
-- (standalone server_scripts have their own require cache and write to a dead ItemList)
require('modules.bridge.pulsar.items')

-- expose RegisterUse as an export so external resources can register item callbacks
-- calling convention: exports['ox_inventory']:RegisterUse(itemName, id, callback)
exports('RegisterUse', function(itemName, id, cb)
    Inventory.Items:RegisterUse(itemName, id, cb)
end)

-- pulsar calling convention: CraftingRegisterBench(id, label, targeting, location, restrictions, recipes, canUseSchematics)
exports('CraftingRegisterBench', function(id, label, targeting, location, restrictions, recipes, canUseSchematics)
    CraftingReal:RegisterBench(id, label, targeting, location, restrictions, recipes, canUseSchematics)
end)

-- Inventory.Items:GetData(name) — returns ox item definition (label, weight, etc.)
exports('ItemsGetData', function(itemName)
    return Items(itemName)
end)

-- Inventory.Items:GetCount(owner, invType, name) — returns how many of an item a player has
exports('ItemsGetCount', function(owner, invType, itemName)
    local target = toTarget(owner, invType)
    if not target then return 0 end
    return Inventory.GetItemCount(Inventory(target), itemName) or 0
end)

-- Inventory:Remove(owner, invType, name, count) — removes items from a player's inventory
exports('Remove', function(owner, invType, itemName, count)
    local target = toTarget(owner, invType)
    if not target then return false end
    local inv = Inventory(target)
    if not inv then return false end
    return Inventory.RemoveItem(inv, itemName, count or 1)
end)

-- pulsar-compat server exports (bulk)

exports('ItemsHas', function(source, name, count)
    local inv = Inventory(toTarget(source, 1))
    if not inv then return false end
    return (Inventory.GetItemCount(inv, name) or 0) >= (count or 1)
end)

exports('CheckPlayerHasItem', function(source, name, count)
    local inv = Inventory(toTarget(source, 1))
    if not inv then return false end
    return (Inventory.GetItemCount(inv, name) or 0) >= (count or 1)
end)

exports('ItemsHasAnyItems', function(source, items)
    return Inventory.HasAnyItems(Inventory, source, items)
end)

exports('ItemsHasType', function(source, itemType)
    local inv = Inventory(source)
    if not inv then return false end
    for _, slot in pairs(inv.items) do
        if slot and slot.name then
            local def = Items(slot.name)
            if def and def.server and def.server.pulsarType == itemType then return true end
        end
    end
    return false
end)

exports('RemoveSlot', function(owner, name, count, slotNum, invType)
    local target = toTarget(owner, invType)
    if not target then return false end
    local inv = Inventory(target)
    if not inv then return false end
    return Inventory.RemoveItem(inv, name, count or 1, nil, slotNum)
end)

exports('RemoveId', function(owner, invType, id, name, count)
    local target = toTarget(owner, invType)
    if not target then return false end
    local inv = Inventory(target)
    if not inv then return false end
    if type(id) == 'table' then
        local itemName = id.Name or id.name or name
        local slotNum  = id.Slot or id.slot
        return _origRemoveItem(inv, itemName, count or 1, nil, slotNum)
    end
    return _origRemoveItem(inv, name, count or 1, nil, id)
end)

exports('RemoveAll', function(source)
    local inv = Inventory(source)
    if inv then Inventory.Clear(inv) end
end)

exports('RemoveList', function(owner, invType, items)
    local target = toTarget(owner, invType)
    if not target then return false end
    local inv = Inventory(target)
    if not inv then return false end
    for _, v in ipairs(items) do
        Inventory.RemoveItem(inv, v.name or v[1], v.count or v[2] or 1)
    end
    return true
end)

exports('RemoveStash', function(id)
    local inv = Inventory(tostring(id))
    if inv then Inventory.Clear(inv) end
end)

exports('ItemsGetFirst', function(owner, name, invType)
    invType = invType or 1
    local target = toTarget(owner, invType)
    if not target then return nil end
    local inv = Inventory(target)
    if not inv then return nil end
    for _, slot in pairs(inv.items) do
        if slot and slot.name == name then return toSlot(slot, owner, invType) end
    end
    return nil
end)

exports('ItemsGetAll', function(owner, invType, name)
    local target = toTarget(owner, invType)
    if not target then return {} end
    local inv = Inventory(target)
    if not inv then return {} end
    local result = {}
    for _, slot in pairs(inv.items) do
        if slot and slot.name == name then result[#result + 1] = toSlot(slot, owner, invType) end
    end
    return result
end)

exports('GetAllOfTypeNoStack', function(owner, invType, itemType)
    local target = toTarget(owner, invType)
    if not target then return {} end
    local inv = Inventory(target)
    if not inv then return {} end
    local result = {}
    for _, slot in pairs(inv.items) do
        if slot and slot.name then
            local def = Items(slot.name)
            if def and def.server and def.server.pulsarType == itemType then
                result[#result + 1] = toSlot(slot, owner, invType)
            end
        end
    end
    return result
end)

local function _getWithStaticMeta(owner, invType, key, value)
    local target = toTarget(owner, invType)
    if not target then return {} end
    local inv = Inventory(target)
    if not inv then return {} end
    local result = {}
    for _, slot in pairs(inv.items) do
        if slot and slot.name and slot.metadata and slot.metadata[key] == value then
            result[#result + 1] = toSlot(slot, owner, invType)
        end
    end
    return result
end
exports('GetWithStaticMetadata', _getWithStaticMeta)
exports('ItemsGetWithStaticMetadata', _getWithStaticMeta)

exports('SearchCharacter', function(owner, invType, name)
    local target = toTarget(owner, invType)
    if not target then return {} end
    return Inventory.Search(Inventory(target), 'slots', name) or {}
end)

exports('getUtilitySlotItem', function(source, slotType)
    local inv = Inventory(source)
    if not inv then return nil end
    for _, slot in pairs(inv.items) do
        if slot and slot.name then
            local def = Items(slot.name)
            if def and def.server and def.server.pulsarType == slotType then
                return toSlot(slot, source, 1)
            end
        end
    end
    return nil
end)

exports('SetMetaDataKey', function(owner, invType, slotNum, key, value)
    Inventory.SetMetadataKey(Inventory, owner, key, value, invType, slotNum)
end)

exports('UpdateMetaData', function(owner, invType, metadata, slotNum)
    Inventory.UpdateMetaData(Inventory, owner, metadata, slotNum, invType)
end)

exports('UpdateGovIDMugshot', function(source, mugshot)
    local inv = Inventory(source)
    if not inv then return end
    for slotNum, slot in pairs(inv.items) do
        if slot and slot.name == 'govid' then
            local meta = table.clone(slot.metadata or {})
            meta.mugshot = mugshot
            Inventory.SetMetadata(inv, slotNum, meta)
            return
        end
    end
end)

exports('LootCustomWeightedSetWithCountAndModifier', function(set, owner, invType, modifier, dontAdd)
    return _Loot.CustomWeightedSetWithCountAndModifier(_Loot, set, owner, invType, modifier, dontAdd)
end)

exports('LootCustomWeightedSetWithCount', function(set, owner, invType)
    return _Loot.CustomWeightedSetWithCount(_Loot, set, owner, invType)
end)

exports('LootCustomSet', function(set, owner, invType, count)
    return _Loot.CustomSet(_Loot, set, owner, invType, count)
end)

exports('LootCustomSetWithCount', function(set, owner, invType)
    return _Loot.CustomSetWithCount(_Loot, set, owner, invType)
end)

exports('LootSetsGem', function(owner, invType)
    return _Loot.Sets.Gem(_Loot.Sets, owner, invType)
end)

exports('CloseAll', function(source)
    if source then TriggerClientEvent('Inventory:CloseUI', source) end
end)

exports('OpenSecondary', function(source, invType, owner, ...)
    Inventory.OpenSecondary(Inventory, source, invType, owner, ...)
end)

exports('ShopOpen', function(source, shopId)
    Inventory.OpenSecondary(Inventory.Items, source, 11, ('shop:%s'):format(tostring(shopId)))
end)

exports('CraftingBenchesOpen', function(source, benchId)
    TriggerClientEvent('Crafting:Client:OpenCrafting', source, { id = benchId })
end)

exports('addCash', function(source, amount)
    if (amount or 0) <= 0 then return end
    exports['ox_inventory']:AddItem(source, 'money', amount)
end)

exports('CraftingSchematicsHasAny', function(source, schematics)
    local unlocked = Player(source).state.unlockedSchematics or {}
    for _, key in ipairs(schematics) do
        if unlocked[key] then return true end
    end
    return false
end)

exports('GetFreeSlotNumbers', function(source)
    return Inventory.GetFreeSlotNumbers(Inventory, source)
end)

exports('UnequipIfEquipped', function(source, name)
    local current = Inventory.GetCurrentWeapon(Inventory(source))
    if current and (not name or current.name == name) then
        TriggerClientEvent('Weapons:Client:ForceUnequip', source)
    end
end)

-- stubs for pulsar-specific tracking that doesn't map to ox
exports('SetItemCreateDate', function(slotId, newCreateDate)
    if type(slotId) ~= 'table' then return end
    local target = toTarget(slotId.owner, 1)
    if not target then return end
    local inv = Inventory(target)
    if not inv or not inv.items then return end
    local slot = inv.items[slotId.slot]
    if not slot then return end
    local meta = table.clone(slot.metadata or {})
    meta.CreateDate = newCreateDate
    Inventory.SetMetadata(inv, slotId.slot, meta)
end)
exports('BallisticsClear', function() end)
exports('HoldingPut', function() end)
exports('HoldingTake', function() end)

-- rebuild groups when someones job changes
AddEventHandler('Jobs:Server:JobUpdate', function(source)
    local inv = Inventory(source)
    if not inv or not inv.player then return end

    local char = exports['pulsar-characters']:FetchCharacterSource(source)
    if not char then return end

    local groups = {}
    for _, v in ipairs(char:GetData('Jobs') or {}) do
        groups[v.Id] = v.Grade and v.Grade.Level or 0
    end
    inv.player.groups = groups
end)

-- Admin commands — pulsar-chat RegisterAdminCommand

local function notify(source, ntype, msg)
    exports['pulsar-hud']:Notification(source, ntype, msg, 5000)
end

local function fetchTarget(source, sid)
    if sid == 'me' then return source end
    local targetSID = tonumber(sid)
    if not targetSID then
        notify(source, 'error', 'Invalid SID: ' .. tostring(sid))
        return nil
    end
    local char = exports['pulsar-characters']:FetchCharacterData('SID', targetSID)
    if not char then
        notify(source, 'error', 'Player with SID ' .. sid .. ' not found online')
        return nil
    end
    return char:GetData('Source')
end

exports['pulsar-chat']:RegisterAdminCommand('giveitem', function(source, args)
    local item = Items(args[2])
    if not item then
        notify(source, 'error', 'Item not found: ' .. tostring(args[2]))
        return
    end

    local target = fetchTarget(source, args[1])
    if not target then return end

    local inv   = Inventory(target)
    local count = tonumber(args[3]) and math.max(tonumber(args[3]), 1) or 1

    local success, response = Inventory.AddItem(inv, item.name, count)

    if success then
        notify(source, 'success', ('Gave %sx %s to SID %s'):format(count, item.name, args[1]))
        if server.loglevel > 0 then
            local srcInv = Inventory(source) or { label = 'console', owner = 'console' }
            lib.logger(srcInv.owner, 'admin',
                ('"%s" gave %sx %s to SID "%s"'):format(srcInv.label, count, item.name, args[1]))
        end
    else
        notify(source, 'error', ('Failed to give %sx %s (%s)'):format(count, item.name, response))
    end
end, {
    help = 'Give an item to a player by SID',
    params = {
        { name = 'SID',   help = 'Target player SID' },
        { name = 'Item',  help = 'Item name' },
        { name = 'Count', help = 'Amount' },
    },
}, -1)

exports['pulsar-chat']:RegisterAdminCommand('removeitem', function(source, args)
    local item = Items(args[2])
    if not item then
        notify(source, 'error', 'Item not found: ' .. tostring(args[2]))
        return
    end

    local target = fetchTarget(source, args[1])
    if not target then return end

    local inv   = Inventory(target)
    local count = tonumber(args[3]) and math.max(tonumber(args[3]), 1) or 1

    local success, response = Inventory.RemoveItem(inv, item.name, count, nil, nil, true)

    if not success then
        notify(source, 'error', ('Failed to remove %sx %s (%s)'):format(count, item.name, response))
        return
    end

    notify(source, 'success', ('Removed %sx %s from SID %s'):format(count, item.name, args[1]))
    if server.loglevel > 0 then
        local srcInv = Inventory(source) or { label = 'console', owner = 'console' }
        lib.logger(srcInv.owner, 'admin',
            ('"%s" removed %sx %s from SID "%s"'):format(srcInv.label, count, item.name, args[1]))
    end
end, {
    help = 'Remove an item from a player by SID',
    params = {
        { name = 'SID',   help = 'Target player SID' },
        { name = 'Item',  help = 'Item name' },
        { name = 'Count', help = 'Amount' },
        { name = 'Type',  help = 'Only remove items with matching "type" metadata', optional = true },
    },
}, -1)

exports['pulsar-chat']:RegisterAdminCommand('setitem', function(source, args)
    local item  = Items(args[2])
    local count = tonumber(args[3]) or 0

    if not item then
        notify(source, 'error', 'Item not found: ' .. tostring(args[2]))
        return
    end

    local target = fetchTarget(source, args[1])
    if not target then return end

    local inv             = Inventory(target)
    local success, response = exports.ox_inventory:SetItem(inv, item.name, count)

    if not success then
        notify(source, 'error', ('Failed to set %s to %sx (%s)'):format(item.name, count, response))
        return
    end

    notify(source, 'success', ('Set %s to %sx for SID %s'):format(item.name, count, args[1]))
    if server.loglevel > 0 then
        local srcInv = Inventory(source) or { label = 'console', owner = 'console' }
        lib.logger(srcInv.owner, 'admin',
            ('"%s" set SID "%s" %s count to %sx'):format(srcInv.label, args[1], item.name, count))
    end
end, {
    help = 'Set exact item count for a player by SID',
    params = {
        { name = 'SID',   help = 'Target player SID' },
        { name = 'Item',  help = 'Item name' },
        { name = 'Count', help = 'Amount to set' },
    },
}, -1)

exports['pulsar-chat']:RegisterAdminCommand('clearevidence', function(source, args)
    local inv          = Inventory(source)
    local group, grade = server.hasGroup(inv, shared.police)
    if not group or not server.isPlayerBoss or not server.isPlayerBoss(source, group, grade) then
        notify(source, 'error', 'No permission')
        return
    end
    MySQL.query('DELETE FROM ox_inventory WHERE name = ?', { ('evidence-%s'):format(args[1]) })
    notify(source, 'success', 'Cleared evidence locker: ' .. tostring(args[1]))
end, {
    help = 'Clear a police evidence locker by ID',
    params = {
        { name = 'locker', help = 'Locker ID to clear' },
    },
}, 1)

exports['pulsar-chat']:RegisterAdminCommand('confiscateinv', function(source, args)
    local target = fetchTarget(source, args[1])
    if not target then return end
    exports.ox_inventory:ConfiscateInventory(target)
    notify(source, 'success', 'Confiscated inventory for SID: ' .. args[1])
end, {
    help = 'Confiscate a player inventory by SID (restore with /returninv)',
    params = {
        { name = 'SID', help = 'Target player SID' },
    },
}, 1)

exports['pulsar-chat']:RegisterAdminCommand('returninv', function(source, args)
    local target = fetchTarget(source, args[1])
    if not target then return end
    exports.ox_inventory:ReturnInventory(target)
    notify(source, 'success', 'Returned inventory for SID: ' .. args[1])
end, {
    help = 'Restore a previously confiscated inventory by SID',
    params = {
        { name = 'SID', help = 'Target player SID' },
    },
}, 1)

exports['pulsar-chat']:RegisterAdminCommand('clearinv', function(source, args)
    if args[1] == 'me' then
        exports.ox_inventory:ClearInventory(source)
        notify(source, 'success', 'Cleared your inventory')
        return
    end
    local target = fetchTarget(source, args[1])
    if not target then return end
    exports.ox_inventory:ClearInventory(target)
    notify(source, 'success', 'Cleared inventory for SID: ' .. args[1])
end, {
    help = 'Wipe all items from a player inventory (SID or "me")',
    params = {
        { name = 'SID', help = 'Target SID or "me"' },
    },
}, 1)

exports['pulsar-chat']:RegisterAdminCommand('saveinv', function(source, args)
    exports.ox_inventory:SaveInventories(args[1] == 'true', false)
end, {
    help = 'Save all pending inventory changes to the database',
    params = {
        { name = 'lock', help = 'Pass "true" to lock inventory until restart', optional = true },
    },
}, -1)

exports['pulsar-chat']:RegisterAdminCommand('viewinv', function(source, args)
    if args[1] == 'me' then
        exports.ox_inventory:InspectInventory(source, source)
        return
    end
    local target = fetchTarget(source, args[1])
    if not target then return end
    exports.ox_inventory:InspectInventory(source, target)
end, {
    help = 'Inspect a player inventory without interactions (SID or "me")',
    params = {
        { name = 'SID', help = 'Target SID or "me"' },
    },
}, 1)

-- ammo item use: client fires this directly, bypassing ox's currentWeapon gate
RegisterNetEvent('ox_inventory:bridge:useAmmo', function(slot, itemName, metadata)
    local source = source
    local itemDef = Items(itemName)
    if not itemDef or not itemDef.server or itemDef.server.pulsarType ~= 9 then return end
    TriggerClientEvent('Inventory:Client:AmmoLoad', source, {
        ammoType    = itemDef.server.ammoType,
        bulletCount = itemDef.server.bulletCount or 10,
        itemName    = itemName,
        itemSlot    = slot,
        itemMeta    = metadata,
    })
end)

RegisterNetEvent('ox_inventory:bridge:openShop', function(shopId)
    local src = source
    Inventory.OpenSecondary(Inventory.Items, src, 11, tostring(shopId))
end)

RegisterNetEvent('ox_inventory:bridge:openTrunk', function(netId)
    local src = source
    local entity = NetworkGetEntityFromNetworkId(netId)
    if not entity or entity == 0 then return end
    local vin = Entity(entity).state.VIN
    if not vin then return end
    exports['ox_inventory']:forceOpenInventory(src, 'trunk', {netid = netId})
end)

local _shopPedData = nil
local function buildShopPedData()
    if _shopPedData then return _shopPedData end
    local shopDefs = lib.load('data.shops') or {}
    _shopPedData = {}
    for shopType, shopData in pairs(shopDefs) do
        if shopData.locations and shopData.npc then
            for i, loc in ipairs(shopData.locations) do
                _shopPedData[#_shopPedData+1] = {
                    id = shopType .. '_' .. i,
                    shopType = shopType,
                    locId = i,
                    name = shopData.name,
                    npc = shopData.npc,
                    coords = { x= loc.x, y = loc.y, z = loc.z, h = loc.w or 0.0 },
                    blip = shopData.blip,
                }
            end
        end
    end
    return _shopPedData
end

RegisterNetEvent('ox_inventory:bridge:getShops', function()
    TriggerClientEvent('ox_inventory:bridge:receiveShops', source, buildShopPedData())
end)

RegisterNetEvent('Weapons:Server:DoFlashFx', function(coords, netId)
    TriggerClientEvent('Weapons:Client:DoFlashFx', -1, coords.x, coords.y, coords.z, 10000, 8, 20.0, netId, 25, 1.6)
end)

RegisterNetEvent('ox_inventory:bridge:useThrowable', function(itemName, slot)
    local src = source
    local inv = Inventory(src)
    if not inv then return end
    local ok = Inventory.RemoveItem(inv, itemName, 1, nil, slot)
    if not ok then return end
    local remaining = inv.items[slot]
    if not remaining or not remaining.name then
        TriggerClientEvent('Weapons:Client:ForceUnequip', src)
    else
        TriggerClientEvent('ox_inventory:bridge:throwableUsed', src, remaining.count or 0)
    end
end)

-- Grapple relay

RegisterServerEvent('Inventory:Server:Grapple:CreateRope', function(grappleId, dest)
    TriggerClientEvent('Inventory:Client:Grapple:CreateRope', -1, source, grappleId, dest)
end)

RegisterServerEvent('Inventory:Server:Grapple:DestroyRope', function(grappleId)
    TriggerClientEvent(('Inventory:Client:Grapple:DestroyRope:%s'):format(grappleId), -1)
end)

-- degrade the grapple gun slot after a successful launch
RegisterNetEvent('Inventory:Server:DegradeLastUsed', function(amount, slot)
    local src = source
    local inv = Inventory(src)
    if not inv or not slot then return end
    slot = tonumber(slot)
    local item = inv.items[slot]
    if not item then return end
    local meta = table.clone(item.metadata or {})
    meta.durability = math.max(0, (meta.durability or 100) - amount)
    Inventory.SetMetadata(inv, slot, meta)
end)

-- Vanity items / Signs / Halloween / ERP item use registration

CreateThread(function()
    -- vanity items (overlay effect on self or nearby players)
    Inventory.Items:RegisterUse('vanityitem', 'VanityItems', function(source, item)
        local action = item?.MetaData?.CustomItemAction
        if action == 'overlay' then
            TriggerClientEvent('Inventory:Client:UseVanityItem', source, source, action, item)
        elseif action == 'overlayall' then
            TriggerClientEvent('Inventory:Client:UseVanityItem', -1, source, action, item)
        end
    end)

    -- signs (prop-holding emotes)
    for _, name in ipairs({
        'sign_dontblock', 'sign_leftturn',  'sign_nopark',     'sign_notresspass',
        'sign_rightturn', 'sign_stop',      'sign_uturn',      'sign_walkingman', 'sign_yield',
    }) do
        local n = name
        Inventory.Items:RegisterUse(n, 'Signs', function(source, item)
            TriggerClientEvent('Inventory:Client:Signs:UseSign', source, item)
        end)
    end

    -- halloween
    Inventory.Items:RegisterUse('carvedpumpkin', 'Halloween', function(source)
        TriggerClientEvent('Inventory:Client:Halloween:Pumpkin', source, 'pumpkin1')
    end)

    -- ERP
    Inventory.Items:RegisterUse('buttplug_black', 'ERP', function(source)
        TriggerClientEvent('Inventory:Client:ERP:ButtPlug', source, 'black')
    end)
    Inventory.Items:RegisterUse('buttplug_pink', 'ERP', function(source)
        TriggerClientEvent('Inventory:Client:ERP:ButtPlug', source, 'pink')
    end)
    Inventory.Items:RegisterUse('vibrator_pink', 'ERP', function(source)
        TriggerClientEvent('Inventory:Client:ERP:Vibrator', source, 'pink')
    end)
end)

-- Gang chains

CreateThread(function()
    local ItemList = require 'modules.items.shared'
    for name, itemData in pairs(ItemList) do
        if itemData.gangChain then
            local n = name
            Inventory.Items:RegisterUse(n, 'GangChains', function(source, item)
                local char = exports['pulsar-characters']:FetchCharacterSource(source)
                if not char then return end
                if n ~= char:GetData('GangChain') then
                    TriggerClientEvent('Ped:Client:ChainAnim', source)
                    Wait(3000)
                    char:SetData('GangChain', n)
                else
                    TriggerClientEvent('Ped:Client:ChainAnim', source)
                    Wait(3000)
                    char:SetData('GangChain', 'NONE')
                end
            end)
        end
    end
end)

RegisterNetEvent('Inventory:ClearGangChain', function()
    local char = exports['pulsar-characters']:FetchCharacterSource(source)
    if char then char:SetData('GangChain', 'NONE') end
end)

-- Incinerators — auto-clear when anything is dropped in

exports['ox_inventory']:registerHook('swapItems', function(payload)
    if payload.toInventory:find('incinerator_') then
        SetTimeout(0, function()
            exports['ox_inventory']:Clear(payload.toInventory)
        end)
    end
end, {
    inventoryFilter = {
        'incinerator_mrpd',
        'incinerator_sast',
        'incinerator_lmpd',
    },
})

-- Police secured compartments — weapons only

exports['ox_inventory']:registerHook('swapItems', function(payload)
    local toSlot   = payload.toSlot
    local fromSlot = payload.fromSlot
    if type(toSlot) == 'table' and fromSlot?.name and not fromSlot.name:find('WEAPON_') then
        return false
    elseif type(toSlot) == 'table' and toSlot?.name and not toSlot.name:find('WEAPON_') then
        return false
    end
end, {
    inventoryFilter = { '^polsecuredcompartment[%w]+' },
})

