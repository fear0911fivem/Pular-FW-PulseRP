-- pulsar ox bridge : client side
-- handles client side inv events for pulsar compatibility

local Items = require 'modules.items.client'

-- Pulsar Weapons bridge
-- Ports pulsar-inventory weapon equip/unequip with draw anims,
-- ammo tracking in metadata, and ammo item type-checking

local _weapItemDefs = {}
do
    local _all = lib.load('data.pulsar-items.index') or {}
    for _, item in ipairs(_all) do
        if item.name then _weapItemDefs[item.name] = item end
    end
end

local _equipped              = nil   -- { Name, Slot, Count, MetaData, Owner, invType }
local _equippedData          = nil
local _weapLoggedIn          = false
local _throwableConfirmedAmmo = nil  -- set by server after item removal; re-anchors detection

local function _loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do RequestAnimDict(dict) Wait(5) end
end

local function _doHolsterBlockers()
    CreateThread(function()
        while LocalPlayer.state.holstering do
            DisablePlayerFiring(PlayerPedId(), true)
            for _, c in ipairs({ 14,15,16,17,24,25,50,68,91,99,115,142 }) do
                DisableControlAction(0, c, true)
            end
            Wait(0)
        end
    end)
end

local _wAnims = {
    Cop = {
        Holster = function(ped)
            LocalPlayer.state:set('holstering', true, false)
            _doHolsterBlockers()
            local dict = 'reaction@intimidation@cop@unarmed'
            _loadAnimDict(dict)
            TaskPlayAnim(ped, dict, 'intro', 10.0, 2.3, -1, 49, 1, 0, 0, 0)
            Wait(600)
            SetCurrentPedWeapon(ped, GetHashKey('WEAPON_UNARMED'), true)
            RemoveAllPedWeapons(ped)
            ClearPedTasks(ped)
            LocalPlayer.state:set('holstering', false, false)
        end,
        Draw = function(ped, hash, ammoHash, ammo, clip, item, itemData)
            LocalPlayer.state:set('holstering', true, false)
            _doHolsterBlockers()
            RemoveAllPedWeapons(ped)
            local dict = 'reaction@intimidation@cop@unarmed'
            _loadAnimDict(dict)
            TaskPlayAnim(ped, dict, 'intro', 10.0, 2.3, -1, 49, 1, 0, 0, 0)
            Wait(600)
            SetPedAmmoToDrop(ped, 0)
            local actualClip = clip or GetWeaponClipSize(hash)
            local actualReserve = itemData.isThrowable and (item.Count or 1) or (ammo or 0)
            _ghostBullet = (actualClip == 0 and actualReserve == 0)
            -- give at least 1 clip bullet so GTA keeps the weapon in hand when ammo=0
            GiveWeaponToPed(ped, hash, math.max(1, actualClip), true, true)
            SetPedAmmoByType(ped, ammoHash, actualReserve)
            if item.MetaData and item.MetaData.WeaponTint then SetPedWeaponTintIndex(ped, hash, item.MetaData.WeaponTint) end
            if item.MetaData and item.MetaData.WeaponComponents then
                for _, v in pairs(item.MetaData.WeaponComponents) do GiveWeaponComponentToPed(ped, hash, GetHashKey(v.attachment)) end
            end
            SetCurrentPedWeapon(ped, hash, 1)
            -- only restore clip if > 0; restoring to 0 makes GTA auto-switch to unarmed
            if actualClip > 0 then SetAmmoInClip(ped, hash, actualClip) end
            ClearPedTasks(ped)
            LocalPlayer.state:set('holstering', false, false)
        end,
    },
    Holster = {
        OH = function(ped)
            LocalPlayer.state:set('holstering', true, false)
            _doHolsterBlockers()
            local dict, anim = 'reaction@intimidation@1h', 'outro'
            local dur = GetAnimDuration(dict, anim) * 1000
            _loadAnimDict(dict)
            TaskPlayAnim(ped, dict, anim, 1.0, 1.0, -1, 50, 0, 0, 0, 0)
            Wait(dur - 2200)
            SetCurrentPedWeapon(ped, GetHashKey('WEAPON_UNARMED'), true)
            Wait(300)
            RemoveAllPedWeapons(ped)
            ClearPedTasks(ped)
            Wait(800)
            LocalPlayer.state:set('holstering', false, false)
        end,
    },
    Draw = {
        OH = function(ped, hash, ammoHash, ammo, clip, item, itemData)
            LocalPlayer.state:set('holstering', true, false)
            _doHolsterBlockers()
            local dict, anim = 'reaction@intimidation@1h', 'intro'
            RemoveAllPedWeapons(ped)
            local dur = GetAnimDuration(dict, anim) * 1000
            _loadAnimDict(dict)
            TaskPlayAnim(ped, dict, anim, 1.0, 1.0, -1, 50, 0, 0, 0, 0)
            Wait(900)
            SetPedAmmoToDrop(ped, 0)
            local actualClip = clip or GetWeaponClipSize(hash)
            local actualReserve = itemData.isThrowable and (item.Count or 1) or (ammo or 0)
            _ghostBullet = (actualClip == 0 and actualReserve == 0)
            -- give at least 1 clip bullet so GTA keeps the weapon in hand when ammo=0
            GiveWeaponToPed(ped, hash, math.max(1, actualClip), true, true)
            SetPedAmmoByType(ped, ammoHash, actualReserve)
            if item.MetaData and item.MetaData.WeaponTint then SetPedWeaponTintIndex(ped, hash, item.MetaData.WeaponTint) end
            if item.MetaData and item.MetaData.WeaponComponents then
                for _, v in pairs(item.MetaData.WeaponComponents) do GiveWeaponComponentToPed(ped, hash, GetHashKey(v.attachment)) end
            end
            SetCurrentPedWeapon(ped, hash, 1)
            -- only restore clip if > 0; restoring to 0 makes GTA auto-switch to unarmed
            if actualClip > 0 then SetAmmoInClip(ped, hash, actualClip) end
            Wait(500)
            ClearPedTasks(ped)
            Wait(1200)
            LocalPlayer.state:set('holstering', false, false)
        end,
    },
}

-- true when we gave a ghost bullet to hold a 0-ammo weapon in hand
-- must be zeroed before _updateAmmo reads clip so we don't save the phantom round
local _ghostBullet = false

local function _updateAmmo(item, isDiff)
    if not item then return end
    local itemData = _weapItemDefs[item.Name]
    if not itemData or itemData.isThrowable then return end
    local ped = PlayerPedId()
    local _, wep = GetCurrentPedWeapon(ped, true)
    local hash = GetHashKey(itemData.weapon or item.Name)
    if hash ~= wep then return end
    local _, clip = GetAmmoInClip(ped, hash)
    local ammo = GetAmmoInPedWeapon(ped, hash)
    if ammo == (item.MetaData.ammo or 0) and clip == (item.MetaData.clip or 0) then return end
    -- update local cache so next comparison uses current values
    item.MetaData.ammo = ammo
    item.MetaData.clip = clip
    if isDiff then
        TriggerServerEvent('Weapon:Server:UpdateAmmoDiff', item.Slot, ammo, clip)
    else
        TriggerServerEvent('Weapon:Server:UpdateAmmo', item.Slot, ammo, clip)
    end
end

local function _runWeaponThreads()
    CreateThread(function()
        while _equipped ~= nil and _weapLoggedIn do
            _updateAmmo(_equipped)
            Wait(20000)
        end
    end)
    if not (_equippedData and _equippedData.isThrowable) then return end
    _throwableConfirmedAmmo = nil
    CreateThread(function()
        local ammoHash = GetHashKey(_equippedData.ammoType or 'AMMO_GRENADE')
        local prevAmmo = GetPedAmmoByType(PlayerPedId(), ammoHash)
        local waiting  = false  -- blocked until server confirms removal + sends back count
        while _equipped ~= nil and _weapLoggedIn do
            -- server confirmed removal: re-anchor prevAmmo to real inventory count
            if _throwableConfirmedAmmo then
                prevAmmo = _throwableConfirmedAmmo
                _throwableConfirmedAmmo = nil
                waiting = false
            end
            if not waiting then
                local currAmmo = GetPedAmmoByType(PlayerPedId(), ammoHash)
                if currAmmo >= 0 and currAmmo < prevAmmo then
                    waiting = true  -- gate all further detection until server responds
                    prevAmmo = currAmmo
                    local capturedItem = _equipped
                    local capturedData = _equippedData
                    exports['ox_inventory']:closeInventory()
                    TriggerServerEvent('ox_inventory:bridge:useThrowable', capturedItem.Name, capturedItem.Slot)
                    local wname = string.upper(capturedData.name or '')
                    if wname == 'WEAPON_SMOKEGRENADE' then
                        TriggerEvent('Weapons:Client:SmokeGrenade')
                    elseif wname == 'WEAPON_FLASHBANG' then
                        TriggerEvent('Weapons:Client:Flashbang')
                    end
                end
            end
            Wait(50)
        end
        _throwableConfirmedAmmo = nil
    end)
end

WEAPONS = {
    GetEquippedHash = function(self)
        if not _equipped then return nil end
        local d = _weapItemDefs[_equipped.Name]
        return GetHashKey(d and d.weapon or _equipped.Name)
    end,
    GetEquippedItem = function(self) return _equipped end,
    IsEligible = function(self) return true end,

    Equip = function(self, item)
        local ped = PlayerPedId()
        local itemData = _weapItemDefs[item.Name]
        if not itemData then return end
        local hash = GetHashKey(itemData.weapon or item.Name)
        local ammoHash = GetHashKey(itemData.ammoType or 'AMMO_PISTOL')
        local meta = item.MetaData or {}
        if _equipped then WEAPONS:Unequip(_equipped) end
        -- pre-register BEFORE the animation so the mismatch checker (200ms tick)
        -- doesn't disarm us between SetCurrentPedWeapon and the end of Equip
        client.ignoreweapons[hash] = true
        if LocalPlayer.state.onDuty == 'police' then
            _wAnims.Cop.Draw(ped, hash, ammoHash, meta.ammo or 0, meta.clip or 0, item, itemData)
        else
            _wAnims.Draw.OH(ped, hash, ammoHash, meta.ammo or 0, meta.clip or 0, item, itemData)
        end
        _equipped = item
        _equippedData = itemData
        TriggerEvent('Weapons:Client:SwitchedWeapon', item.Name, item, itemData)
        SetWeaponsNoAutoswap(true)
        _runWeaponThreads()
    end,

    Unequip = function(self, item, diff)
        if not item then return end
        local ped = PlayerPedId()
        local itemData = _weapItemDefs[item.Name]
        if not itemData then return end
        local hash = GetHashKey(itemData.weapon or item.Name)
        -- zero out ghost bullet before reading ammo so we don't save phantom round
        if _ghostBullet then
            SetAmmoInClip(ped, hash, 0)
            _ghostBullet = false
        end
        _updateAmmo(item, diff)
        if LocalPlayer.state.onDuty == 'police' then
            _wAnims.Cop.Holster(ped)
        else
            _wAnims.Holster.OH(ped)
        end
        SetPedAmmoByType(ped, GetHashKey(itemData.ammoType or 'AMMO_PISTOL'), 0)
        if item.MetaData and item.MetaData.WeaponComponents then
            for _, v in pairs(item.MetaData.WeaponComponents) do
                RemoveWeaponComponentFromPed(ped, hash, GetHashKey(v.attachment))
            end
        end
        -- stop ignoring this hash — weapon is holstered
        client.ignoreweapons[hash] = nil
        _equipped = nil
        _equippedData = nil
        TriggerEvent('Weapons:Client:SwitchedWeapon', false)
    end,

    UnequipIfEquipped = function(self)
        if _equipped then WEAPONS:Unequip(_equipped) end
    end,

    UnequipIfEquippedNoAnim = function(self)
        if not _equipped then return end
        local ped = PlayerPedId()
        local itemData = _weapItemDefs[_equipped.Name]
        if itemData then
            local hash = GetHashKey(itemData.weapon or _equipped.Name)
            if _ghostBullet then SetAmmoInClip(ped, hash, 0); _ghostBullet = false end
            _updateAmmo(_equipped)
            SetPedAmmoByType(ped, GetHashKey(itemData.ammoType or 'AMMO_PISTOL'), 0)
            client.ignoreweapons[hash] = nil
        end
        SetCurrentPedWeapon(ped, GetHashKey('WEAPON_UNARMED'), true)
        RemoveAllPedWeapons(ped)
        _equipped = nil
        _equippedData = nil
        TriggerEvent('Weapons:Client:SwitchedWeapon', false)
    end,

    Ammo = {
        Add = function(self, data)
            if not _equipped then return end
            local itemData = _weapItemDefs[_equipped.Name]
            if not itemData then return end
            local ped = PlayerPedId()
            local ammoHash = GetHashKey(itemData.ammoType or 'AMMO_PISTOL')
            local count = data.bulletCount or 10
            SetPedAmmoByType(ped, ammoHash, GetPedAmmoByType(ped, ammoHash) + count)
            _ghostBullet = false
        end,
    },
}

-- ammo box use (type 9): server fires this, client shows progress bar then confirms back
RegisterNetEvent('Inventory:Client:AmmoLoad', function(ammoData)
    if not _equipped then
        exports['pulsar-hud']:Notification('error', 'No Weapon Equipped', 5000)
        return
    end
    local itemData = _weapItemDefs[_equipped.Name]
    if not itemData or itemData.ammoType ~= ammoData.ammoType then
        exports['pulsar-hud']:Notification('error', 'Wrong Ammo Type', 5000)
        return
    end
    -- capture before bar — disarm during progress would clear _equipped
    local capturedEquipped = _equipped
    local capturedAmmoType = itemData.ammoType
    local p = promise.new()
    exports['pulsar-hud']:Progress({
        duration  = 3000,
        label     = 'Loading Ammo',
        canCancel = true,
        disarm    = false,
    }, function(cancelled) p:resolve(not cancelled) end)
    if not Citizen.Await(p) then return end
    local ped = PlayerPedId()
    local ammoHash = GetHashKey(capturedAmmoType)
    local count = ammoData.bulletCount or 10
    SetPedAmmoByType(ped, ammoHash, GetPedAmmoByType(ped, ammoHash) + count)
    _ghostBullet = false
    if capturedEquipped.MetaData then
        capturedEquipped.MetaData.ammo = (capturedEquipped.MetaData.ammo or 0) + count
    end
    TriggerServerEvent('Inventory:Server:AmmoLoaded', ammoData.itemName, ammoData.itemSlot, ammoData.itemMeta)
end)

-- server confirms throwable removed from inventory; re-anchors ammo tracking
RegisterNetEvent('ox_inventory:bridge:throwableUsed', function(remaining)
    if not _equipped or not _equippedData or not _equippedData.isThrowable then return end
    local ped      = PlayerPedId()
    local ammoHash = GetHashKey(_equippedData.ammoType or 'AMMO_GRENADE')
    SetPedAmmoByType(ped, ammoHash, remaining)
    _throwableConfirmedAmmo = remaining
end)

-- smoke grenade: poll projectile until it stops moving, then trigger server particle effect
local _prevSmokeCoords = 0
AddEventHandler('Weapons:Client:SmokeGrenade', function()
    CreateThread(function()
        local done = false
        while not done do
            local outCoords = vector3(0, 0, 0)
            local _, coords = GetProjectileNearPed(PlayerPedId(), `WEAPON_SMOKEGRENADE`, 1000.0, outCoords, 0, 1)
            if _prevSmokeCoords ~= 0 and #(coords - _prevSmokeCoords) < 0.5 then done = true end
            _prevSmokeCoords = coords
            Wait(1000)
        end
        TriggerServerEvent('Particles:Server:DoFx', _prevSmokeCoords, 'smoke')
    end)
end)

local _flashTimersRunning = 0
local _totalFlashShakeAmp = 0.0

local function _disableFiringFor(duration)
    local until_ = GetGameTimer() + duration
    CreateThread(function()
        while GetGameTimer() < until_ do
            DisablePlayerFiring(PlayerId(), true)
            Wait(1)
        end
    end)
end

local function _doFlashFx(shakeAmp, time)
    _flashTimersRunning = _flashTimersRunning + 1
    _totalFlashShakeAmp = _totalFlashShakeAmp + shakeAmp
    local ped = PlayerPedId()
    _loadAnimDict('anim@heists@ornate_bank@thermal_charge')
    AnimpostfxPlay('Dont_tazeme_bro', 0, true)
    TaskPlayAnim(ped, 'anim@heists@ornate_bank@thermal_charge', 'cover_eyes_intro', 8.0, 8.0, time, 50, 8.0)
    _disableFiringFor(time * 0.75)
    exports['pulsar-sounds']:LoopOne('flashbang.ogg', 0.1 * _totalFlashShakeAmp)
    Wait(time)
    _flashTimersRunning = _flashTimersRunning - 1
    _totalFlashShakeAmp = _totalFlashShakeAmp - shakeAmp
    if _flashTimersRunning == 0 then
        ClearPedTasks(ped)
        AnimpostfxStop('Dont_tazeme_bro')
        exports['pulsar-sounds']:FadeOne('flashbang.ogg')
    else
        exports['pulsar-sounds']:LoopOne('flashbang.ogg', 0.1 * _totalFlashShakeAmp)
    end
end

AddEventHandler('Weapons:Client:Flashbang', function()
    SetTimeout(1500, function()
        local _, coords, prop = GetProjectileNearPed(PlayerPedId(), `WEAPON_FLASHBANG`, 1000.0, false)
        if not coords then return end
        AddExplosion(coords.x, coords.y, coords.z, 25, 0.0, true, true, true)
        TriggerServerEvent('Weapons:Server:DoFlashFx', coords, NetworkGetNetworkIdFromEntity(prop) or prop)
        ClearAreaOfProjectiles(coords.x, coords.y, coords.z, 10.0)
    end)
end)

RegisterNetEvent('Weapons:Client:DoFlashFx', function(x, y, z, stunTime, afterTime, radius, netId, damage, lethalRange)
    local ped = PlayerPedId()
    if #(vector3(x, y, z) - GetEntityCoords(ped)) >= 100 then return end
    _loadAnimDict('anim@heists@ornate_bank@thermal_charge')
    local headPos = GetPedBoneCoords(ped, `SKEL_Head`, 0, 0, 0)
    local pos     = vector3(x, y, z)
    local dist    = #(GetEntityCoords(ped) - pos)
    local fDist   = #(headPos - pos)
    local dSq     = dist * dist
    local falloutMulti          = 0.02 / (radius / 8.0)
    local stunMulti             = falloutMulti * dSq
    local effectFalloffStunTime = math.floor(stunTime * stunMulti + 0.5)
    local actualStunTime        = math.max(1, (stunTime * effectFalloffStunTime) * 1000)
    local handle = StartShapeTestLosProbe(x, y, z, headPos.x, headPos.y, headPos.z, 293, 0, 4)
    local result, hit, endCoords, surfNorm, entityHit = 1, nil, nil, nil, nil
    while result == 1 do
        result, hit, endCoords, surfNorm, entityHit = GetShapeTestResult(handle)
        Wait(1)
    end
    if fDist <= radius and result == 2 and entityHit == ped then
        local pct = (radius - fDist) / radius
        _doFlashFx(pct, stunTime * pct)
    end
end)

local _spawnedBenchEntities = {}
local _pendingBenches       = nil
local _PedInteraction       = nil
local _Targeting            = nil
local _vendingSetup = false

local function setupVendingMachines()
    if _vendingSetup then return end
    _vendingSetup = true
    local shops = lib.load('data.shops') or {}
    for key, shop in pairs(shops) do
        if shop.models and shop.icon and shop.text then
            local shopType = key:match('^shop:(.+)$')
            if shopType then
                for _, model in ipairs(shop.models) do
                    local st = shopType
                    exports.ox_target:addModel(model, {
                        {
                            label    = shop.text,
                            icon     = shop.icon,
                            distance = 3.0,
                            onSelect = function() TriggerEvent('Shop:Client:OpenShop', nil, st) end,
                        },
                    })
                end
            end
        end
    end
end

local function setupAllBenches()
    if not _pendingBenches or not _PedInteraction then return end

    setupVendingMachines()

    for _, bench in ipairs(_pendingBenches) do
        -- register in client CraftingBenches so openInventory can find the bench data
        if bench.oxData then
            exports['ox_inventory']:RegisterCraftingBench(bench.id, bench.oxData)
        end

        local id        = bench.id
        local targeting = bench.targeting
        local location  = bench.location

        if not targeting or not location then goto continue end

        local coords, heading
        if type(location) == 'vector3' or type(location) == 'vector4' then
            coords  = vector3(location.x, location.y, location.z)
            heading = 0.0
        elseif type(location) == 'table' and location.x and location.y and location.z then
            coords  = vector3(location.x, location.y, location.z)
            heading = location.h or 0.0
        else
            goto continue
        end

        local menu = {
            {
                icon  = targeting.icon or 'fa-hammer',
                text  = bench.label or 'Craft',
                event = 'Crafting:Client:OpenCrafting',
                data  = { id = id },
            },
        }

        local oxOptions = {{ label = menu[1].text, icon = menu[1].icon, distance = 2.0, onSelect = function() TriggerEvent(menu[1].event, nil, menu[1].data) end }}

        if targeting.ped then
            exports['pulsar-pedinteraction']:Add(
                id,
                GetHashKey(targeting.ped.model),
                coords,
                heading,
                25.0,
                menu,
                targeting.icon or 'fa-hammer',
                targeting.ped.task
            )
        elseif targeting.model then
            local obj = CreateObject(GetHashKey(targeting.model), coords.x, coords.y, coords.z, false, true, false)
            FreezeEntityPosition(obj, true)
            SetEntityHeading(obj, heading)
            _spawnedBenchEntities[id] = obj
            exports.ox_target:addLocalEntity(obj, oxOptions)
        elseif targeting.poly then
            exports.ox_target:addBoxZone({
                id      = id,
                coords  = targeting.poly.coords,
                size    = vector3(targeting.poly.w or 2.0, targeting.poly.l or 2.0, 2.0),
                options = oxOptions,
            })
        end

        ::continue::
    end
end

-- cache schematic bench oxData so we can build per-player locked states
local _schematicBenchOxData = nil

RegisterNetEvent('ox_inventory:bridge:SetupCraftingBenches', function(benches)
    _pendingBenches = benches
    -- capture schematic bench data for per-player unlock injection
    for _, bench in ipairs(benches) do
        if bench.id == 'crafting-schematics' and bench.oxData then
            _schematicBenchOxData = bench.oxData
            break
        end
    end
    CreateThread(function()
        Wait(2000)
        _PedInteraction = exports['pulsar-pedinteraction']
        setupAllBenches()
    end)
end)

AddEventHandler('Crafting:Client:OpenCrafting', function(ent, data)
    local craftingData = data or ent
    if craftingData.id == 'crafting-schematics' and _schematicBenchOxData then
        -- apply per-player unlock states before opening
        local unlocked = LocalPlayer.state.unlockedSchematics or {}
        local modifiedItems = {}
        for i, item in ipairs(_schematicBenchOxData.items or {}) do
            local newItem = table.clone(item)
            newItem.metadata = table.clone(item.metadata or {})
            newItem.metadata.locked = not unlocked[newItem.metadata.schematic]
            modifiedItems[i] = newItem
        end
        local modifiedData = table.clone(_schematicBenchOxData)
        modifiedData.items = modifiedItems
        exports['ox_inventory']:RegisterCraftingBench('crafting-schematics', modifiedData)
    end
    exports['ox_inventory']:openInventory('crafting', { id = craftingData.id, index = 1 })
end)



-- Inventory shim

-- every pulsar resource gets Inventory via FetchComponent('Inventory') not a global
-- we build the client shim table and register it as the Inventory component
local ClientInventory = {
    -- pulsar-targeting gates interactions behind these item checks
    Check = {
        Player = {
            HasItem = function(self, item, count)
                return (exports['ox_inventory']:Search('count', item) or 0) >= (count or 1)
            end,

            -- all items must be present
            HasItems = function(self, items)
                for _, v in ipairs(items) do
                    if (exports['ox_inventory']:Search('count', v.item or v.name) or 0) < (v.count or 1) then
                        return false
                    end
                end
                return true
            end,

            -- at least one item from the list
            HasAnyItems = function(self, items)
                for _, v in ipairs(items) do
                    if (exports['ox_inventory']:Search('count', v.item or v.name) or 0) >= (v.count or 1) then
                        return true
                    end
                end
                return false
            end,
        }
    },

    -- pulsar-laptop calls this after ItemsLoaded fires to populate its item list
    Items = {
        GetData = function(self)
            return exports['ox_inventory']:Items() or {}
        end,

        GetCount = function(self, item)
            return exports['ox_inventory']:Search('count', item) or 0
        end,

        Has = function(self, item, count)
            return self:GetCount(item) >= (count or 1)
        end,

        -- pulsar-ped calls this to check if the player has a cosmetic item equipped
        -- searches item definitions for staticMetadata matching ped appearance
        -- our items don't carry staticMetadata so we always return nil (safe — means "not catalogued item")
        GetWithStaticMetadata = function(self, masterKey, mainIdName, textureIdName, gender, data)
            return nil
        end,
    },

    -- pulsar-phone calls Inventory.Close:All() before opening
    Close = {
        All = function(self)
            exports['ox_inventory']:closeInventory()
        end,
    },
    -- TODO rename functions when others updated otherwise errors
    Container = {
        Open = function(self, data)
                exports['pulsar-core']:ServerCallback('Inventory:Server:Open', data, function(state)
                -- state is true on success; ox handles the actual UI open server-side
            end)
        end,
    },

    StaticTooltip = {
        Open = function(self, item)
            SendNUIMessage({ action = 'OPEN_STATIC_TOOLTIP', data = { item = item } })
        end,
        Close = function(self)
            SendNUIMessage({ action = 'CLOSE_STATIC_TOOLTIP', data = {} })
        end,
    },
}

local _itemUseRegistered = false

AddEventHandler('onClientResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    if not _itemUseRegistered then
        exports['pulsar-core']:RegisterClientCallback('Inventory:ItemUse', function(data, cb)
            if data.anim and (not data.pbConfig or not data.pbConfig.animation) then
                exports['pulsar-animations']:EmotesPlay(data.anim, false, data.time, true)
            end

            if data.pbConfig then
                exports['pulsar-hud']:Progress({
                    name = data.pbConfig.name,
                    duration = data.time,
                    label = data.pbConfig.label,
                    useWhileDead = data.pbConfig.useWhileDead,
                    canCancel = data.pbConfig.canCancel,
                    vehicle = data.pbConfig.vehicle,
                    disarm = data.pbConfig.disarm,
                    ignoreModifier = data.pbConfig.ignoreModifier or true,
                    animation = data.pbConfig.animation or false,
                    controlDisables = {
                        disableMovement = data.pbConfig.disableMovement,
                        disableCarMovement = data.pbConfig.disableCarMovement,
                        disableMouse = data.pbConfig.disableMouse,
                        disableCombat = data.pbConfig.disableCombat,
                    },
                }, function(cancelled)
                    pcall(exports['pulsar-animations'].EmotesForceCancel, exports['pulsar-animations'])
                    cb(not cancelled)
                end)
            else
                cb(true)
            end
        end)
        _itemUseRegistered = true
    end

end)

RegisterNetEvent('Inventory:Client:HealthModifier')
AddEventHandler('Inventory:Client:HealthModifier', function(healthMod)
    local ped = LocalPlayer.state.ped
    local newHealth = math.min(180, GetEntityHealth(ped) + healthMod)
    if newHealth > GetEntityHealth(ped) then SetEntityHealth(ped, math.floor(newHealth)) end
end)

RegisterNetEvent('Inventory:Client:ArmourModifier')
AddEventHandler('Inventory:Client:ArmourModifier', function(mod)
    if not LocalPlayer.state.armourModCooldown or LocalPlayer.state.armourModCooldown <= GetGameTimer() then
        local newArmour = math.min(60, GetPedArmour(LocalPlayer.state.ped) + mod)
        if newArmour > GetPedArmour(LocalPlayer.state.ped) then SetPedArmour(LocalPlayer.state.ped, math.floor(newArmour)) end
        LocalPlayer.state.armourModCooldown = GetGameTimer() + 300000
    end
end)

local _energyCd = false
RegisterNetEvent('Inventory:Client:SpeedyBoi')
AddEventHandler('Inventory:Client:SpeedyBoi', function(modifier, duration, cd, skipScreenEffects)
    if not _energyCd then
        _energyCd = true
        CreateThread(function()
            local c = 0
            if not skipScreenEffects then AnimpostfxPlay('DrugsTrevorClownsFight', 0, true) end
            while LocalPlayer.state.loggedIn and c < duration do
                c = c + 1
                SetPedMoveRateOverride(PlayerPedId(), modifier)
                Wait(1)
            end
            SetPedMoveRateOverride(PlayerPedId(), 0.0)
            AnimpostfxStop('DrugsTrevorClownsFight')
            Wait(cd)
            _energyCd = false
        end)
    end
end)

RegisterNetEvent('Inventory:Client:ProgressModifier')
AddEventHandler('Inventory:Client:ProgressModifier', function(modifier, duration)
    exports['pulsar-hud']:ProgressModifier(modifier, duration)
end)

-- force close when logging out, save weapon ammo
RegisterNetEvent('Characters:Client:Logout')
AddEventHandler('Characters:Client:Logout', function()
    exports['ox_inventory']:closeInventory()
    if _equipped then WEAPONS:UnequipIfEquippedNoAnim() end
    _weapLoggedIn = false
end)

-- enable everything on spawn
RegisterNetEvent('Characters:Client:Spawn')
AddEventHandler('Characters:Client:Spawn', function()
    _weapLoggedIn = true
    LocalPlayer.state:set('invBusy', false, true)
    LocalPlayer.state:set('invHotKeys', true, false)
    LocalPlayer.state:set('canUseWeapons', true, false)
    TriggerEvent('Inventory:Client:ItemsLoaded')
end)

-- disable weapons on death, save ammo state
AddEventHandler('Ped:Client:Died', function()
    exports['ox_inventory']:closeInventory()
    LocalPlayer.state:set('canUseWeapons', false, false)
    if _equipped then WEAPONS:UnequipIfEquippedNoAnim() end
end)

-- secondary inventory opens, this one was a pain in the ass to figure out
RegisterNetEvent('Inventory:Client:Load', function(data)
    -- trunk/glovebox (invtype 4/5) handled server-side via forceOpenInventory
    if data.invType == 10 then
        exports['ox_inventory']:openInventory('drop', { id = data.owner })
    elseif data.invType == 11 then
        exports['ox_inventory']:openInventory('shop', { type = data.owner })
    else
        -- everything else (13, 25, 44, 45, 81, etc.) is a registered stash
        exports['ox_inventory']:openInventory('stash', { id = data.owner })
    end
end)

-- server said close it
RegisterNetEvent('Inventory:CloseUI', function()
    exports['ox_inventory']:closeInventory()
end)

-- weapon equip/unequip toggle from server
RegisterNetEvent('Weapons:Client:Use', function(data)
    if not data then return end
    if _equipped and _equipped.Slot == data.Slot then
        WEAPONS:Unequip(data)
    else
        WEAPONS:Equip(data)
    end
end)

-- force unequip (arrest, disarm, admin, etc.)
RegisterNetEvent('Weapons:Client:ForceUnequip', function()
    if _equipped then WEAPONS:UnequipIfEquippedNoAnim() end
    TriggerEvent('ox_inventory:disarm', true)
end)

-- server updated ammo count in our slot (e.g. after confiscation)
RegisterNetEvent('Weapons:Client:UpdateCount', function(slot, count)
    if _equipped and _equipped.Slot == slot then
        local itemData = _weapItemDefs[_equipped.Name]
        if itemData then SetPedAmmoByType(PlayerPedId(), GetHashKey(itemData.ammoType or 'AMMO_PISTOL'), count) end
    end
end)

RegisterNetEvent('Weapons:Client:UpdateAttachments', function(components)
    if not _equipped then return end
    local itemData = _weapItemDefs[_equipped.Name]
    local hash = GetHashKey(itemData and itemData.weapon or _equipped.Name)
    local ped = PlayerPedId()
    for k, v in pairs(_equipped.MetaData and _equipped.MetaData.WeaponComponents or {}) do
        if not components[k] then RemoveWeaponComponentFromPed(ped, hash, GetHashKey(v.attachment)) end
    end
    for k, v in pairs(components) do
        GiveWeaponComponentToPed(ped, hash, GetHashKey(v.attachment))
    end
    if _equipped.MetaData then _equipped.MetaData.WeaponComponents = components end
end)

-- pulsar weapon attatchments 
RegisterNetEvent('Weapons:Client:UseAttachment', function(data)
    if not _equipped then
        exports['pulsar-hud']:Notification('error', 'No weapon equipped', 3000)
        return
    end

    local itemDef = _weapItemDefs[_equipped.Name]
    local weaponHashName = itemDef and itemDef.weapon or _equipped.Name
    local componentHash = data.component and data.component.strings and data.component.strings[weaponHashName]

    if not componentHash then
        exports['pulsar-hud']:Notification('error', 'This attachment is not compatible with your weapon', 3000)
        return
    end

    local currentComponents = table.clone((_equipped.MetaData and _equipped.MetaData.WeaponComponents) or {})
    local returnItemName = nil

    for k, v in pairs(currentComponents) do
        if v.attachType == data.component.type then
            returnItemName = k
            currentComponents[k] = nil
            break
        end
    end

    currentComponents[data.itemName] = {
        attachment = componentHash,
        attachType = data.component.type,
    }

    TriggerServerEvent('Weapons:Server:ApplyAttachment', {
        weaponSlot     = _equipped.Slot,
        weaponName     = _equipped.Name,
        attachItemSlot = data.itemSlot,
        attachItemName = data.itemName,
        attachItemMeta = data.itemMeta,
        newComponents  = currentComponents,
        returnItemName = returnItemName,
    })
end)

-- bullet loading: server found compatible weapons, show weapon picker + count input
RegisterNetEvent('Inventory:Client:LoadBullets', function(data)
    local function loadInto(weapon)
        local input = lib.inputDialog(('Load into %s'):format(weapon.label), {
            {
                type    = 'number',
                label   = ('Bullets to load (have %d)'):format(data.haveCount),
                default = data.haveCount,
                min     = 1,
                max     = data.haveCount,
            }
        })
        if not input or not input[1] then return end
        local count = math.floor(tonumber(input[1]) or 0)
        if count < 1 then return end
        local p = promise.new()
        exports['pulsar-hud']:Progress({
            duration  = 3000,
            label     = 'Loading Ammo',
            canCancel = true,
            disarm    = false,
        }, function(cancelled) p:resolve(not cancelled) end)
        if not Citizen.Await(p) then return end
        TriggerServerEvent('Inventory:Server:LoadBullets', weapon.slot, data.itemName, count)
    end

    if #data.weapons == 1 then
        loadInto(data.weapons[1])
    else
        local options = {}
        for _, w in ipairs(data.weapons) do
            local weapon = w
            options[#options + 1] = {
                title       = ('Slot %d — %s'):format(weapon.slot, weapon.label),
                description = ('Reserve: %d bullets'):format(weapon.currentAmmo),
                onSelect    = function() loadInto(weapon) end,
            }
        end
        lib.registerContext({ id = 'bullet_load_pick', title = 'Load Bullets — Pick Weapon', options = options })
        lib.showContext('bullet_load_pick')
    end
end)

-- server confirmed load — add bullets to ped if this weapon is equipped
RegisterNetEvent('Inventory:Client:BulletsLoaded', function(weaponSlot, count)
    if not _equipped or _equipped.Slot ~= weaponSlot then return end
    local itemData = _equippedData
    if not itemData then return end
    local ped = PlayerPedId()
    local ammoHash = GetHashKey(itemData.ammoType or 'AMMO_PISTOL')
    SetPedAmmoByType(ped, ammoHash, GetPedAmmoByType(ped, ammoHash) + count)
    _ghostBullet = false
    _equipped.MetaData.ammo = (_equipped.MetaData.ammo or 0) + count
end)

-- prevents using items while already mid-use
RegisterNetEvent('Inventory:Client:InUse', function(state)
    LocalPlayer.state:set('invBusy', state, true)
end)

-- lock inventory and disarm when cuffed
AddStateBagChangeHandler('isCuffed', ('player:%s'):format(cache.serverId), function(_, _, value)
    LocalPlayer.state:set('invBusy', value or false, false)
    if value then
        exports['ox_inventory']:closeInventory()
        if _equipped then WEAPONS:UnequipIfEquippedNoAnim() end
        TriggerEvent('ox_inventory:disarm', true)
    end
end)

-- same thing on death
AddStateBagChangeHandler('isDead', ('player:%s'):format(cache.serverId), function(_, _, value)
    LocalPlayer.state:set('invBusy', value or false, false)
    if value then
        exports['ox_inventory']:closeInventory()
        if _equipped then WEAPONS:UnequipIfEquippedNoAnim() end
        TriggerEvent('ox_inventory:disarm', true)
    end
end)

AddStateBagChangeHandler('doingAction', ('player:%s'):format(cache.serverId), function(_, _, value)
    LocalPlayer.state:set('invBusy', value or false, false)
end)

local ClientItems = require 'modules.items.shared'
local allItems = lib.load('data.pulsar-items.index')

if allItems then
    local count = 0
    for _, item in ipairs(allItems) do
        if item.name then
            -- normalize key same as server: weapons stay uppercase, everything else lowercase
            local storeKey = (item.name:sub(1, 7):lower() == 'weapon_') and item.name or item.name:lower()
            -- type 2 (weapons) and type 9 (ammo) must always overwrite ox's data/weapons.lua entries
            -- ox sets weapon=true/ammo=true on those which hijacks useSlot into native paths
            local forceOverwrite = item.type == 2 or item.type == 9
            if forceOverwrite or not ClientItems[storeKey] then
                local entry = {
                    name = storeKey,  -- must match slot.name so Items[slot.name] resolves
                    label = item.label or item.name,
                    description = item.description or nil,
                    weight = item.weight or 0,
                    stack = item.isStackable ~= false and (item.isStackable or true),
                    close = item.closeUi or true,
                    count = 0,
                }
                -- type 9 ammo: export path bypasses the currentWeapon gate in useSlot
                if item.type == 9 then
                    entry.client = {}
                    entry.export = function(itemData, slotData)
                        TriggerServerEvent('ox_inventory:bridge:useAmmo', slotData.slot, slotData.name, slotData.metadata)
                    end
                end
                ClientItems[storeKey] = entry
                count = count + 1
            end
        end
    end
    print(string.format('^2[pulsar-ox-bridge] registered %d items client-side^0', count))
end

local pulsarItemCache = {}

AddEventHandler('ox_inventory:updateInventory', function(changes)
    if _equipped and changes and changes[_equipped.Slot] ~= nil then
        local newSlotData = changes[_equipped.Slot]
        if not newSlotData or not newSlotData.count then
            WEAPONS:UnequipIfEquippedNoAnim()
        end
    end
    pulsarItemCache = {}
    local idx = 0
    for slot, slotData in pairs (PlayerData.inventory or {}) do
        if slotData and slotData.name then
            idx = idx + 1
            pulsarItemCache[idx] = {
                Name = slotData.name,
                Label = slotData.label or slotData.name,
                Slot = slot,
                Count = slotData.count or 0,
                Quality = (slotData.metadata or {}).quality or 100,
                MetaData = slotData.metadata or {},
                Owner = tostring(cache.serverId),
                invType = 1,
            }
        end
    end
    TriggerEvent('Inventory:Client:Cache', pulsarItemCache)
end)

-- swap has item checks to use local cache (avoid server roundtrip per frame)
ClientInventory.Check.Player.HasItem = function(self, item, count)
    if next(pulsarItemCache) then
        local total = 0
        for _, slot in pairs(pulsarItemCache) do
            if slot.Name == item then total = total + (slot.Count or 0) end
        end
        return total >= (count or 1)
    end
    return (exports['ox_inventory']:Search('count', item) or 0) >= (count or 1)
end

ClientInventory.Check.Player.HasItems = function(self, items)
    for _,v in ipairs(items) do
        local name = v.item or v.name
        local needed = v.count or 1
        local total = 0
        for _, slot in pairs(pulsarItemCache) do
            if slot.Name == name then total = total + (slot.Count or 0) end
        end
        if total < needed then return false end
    end
    return true
end

ClientInventory.Check.Player.HasAnyItems = function(self, items)
    for _, v in ipairs(items) do
        local name = v.item or v.name
        local needed = v.count or 1
        local total = 0
        for _, slot in pairs(pulsarItemCache) do
            if slot.Name == name then total = total + (slot.Count or 0) end
        end
        if total >= needed then return true end
    end
    return false
end

ClientInventory.Items.GetCount = function(self, item)
    local total = 0
    for _, slot in pairs(pulsarItemCache) do
        if slot.Name == item then total = total + (slot.Count or 0) end
    end
    return total
end

ClientInventory.Items.Has = function(self, item, count)
    return ClientInventory.Items:GetCount(item) >= (count or 1)
end

ClientInventory.Shop = {
    Open = function(self, shopId)
       TriggerServerEvent('ox_inventory:bridge:openShop', shopId) 
    end,
}

AddEventHandler('Inventory:Client:Trunk', function(entity)
    TriggerServerEvent('ox_inventory:bridge:openTrunk', NetworkGetNetworkIdFromEntity(entity.entity))    
end)

AddEventHandler('Characters:Client:Spawn', function()
    TriggerServerEvent('ox_inventory:bridge:getShops')
end)

RegisterNetEvent('ox_inventory:bridge:receiveShops', function(shops)
    if not shops then return end
    for _, v in ipairs(shops) do
        local shopData = v
        exports['pulsar-pedinteraction']:Add(
            'shop-' .. v.id,
            GetHashKey(v.npc),
            vector3(v.coords.x, v.coords.y, v.coords.z),
            v.coords.h,
            25.0,
            {{
                icon = 'sack-dollar',
                text = v.name or 'Shop',
                event = 'Shop:Client:OpenShop',
                data = { shopType = v.shopType, locId = v.locId },
            }},
            'shop'
        )
        if v.blip then
            exports['pulsar-blips']:Add(
                'inventory_shop_' .. v.id,
                v.name,
                vector3(v.coords.x, v.coords.y, v.coords.z),
                v.blip.id,
                v.blip.colour,
                v.blip.scale
            )
        end
    end
end)

AddEventHandler('Shop:Client:OpenShop', function(obj, data)
    local shopData = data or obj -- pedinteraction fires (data) as sole arg; other callers use (obj, data)
    if type(shopData) == 'string' then
        exports['ox_inventory']:openInventory('shop', { type = 'shop:' .. shopData })
    else
        exports['ox_inventory']:openInventory('shop', { type = shopData.shopType, id = shopData.locId })
    end
end)

local _inInvPoly = nil

RegisterNetEvent('Inventory:Client:PolySetup', function(locs)
    if not locs then return end
    for _, id in ipairs(locs) do
        local data = GlobalState[('Inventory:%s'):format(id)]
        if data then
            if data.data then
                data.data.isInventory = true
                data.data.name = data.name
            end
            if data.type == 'box' then
                exports['pulsar-polyzone']:CreateBox(data.id, data.coords, data.length, data.width, data.options, data.data)
            elseif data.type == 'poly' then
                exports['pulsar-polyzone']:CreatePoly(data.id, data.points, data.options, data.data)
            else
                exports['pulsar-polyzone']:CreateCircle(data.id, data.coords, data.radius, data.options, data.data)
            end
        end
    end
end)

AddEventHandler('Polyzone:Enter', function(id, testedPoint, insideZones, data)
    if not data or not data.isInventory then return end
    exports['pulsar-hud']:ActionShow('ox-inv-poly', 'Open ' .. (data.name or 'Storage'))
    _inInvPoly = data
    LocalPlayer.state:set('_inInvPoly', data, false)
end)

AddEventHandler('Polyzone:Exit', function(id, testedPoint, insideZones, data)
    if not data or not data.isInventory then return end
    exports['pulsar-hud']:ActionHide('ox-inv-poly')
    if LocalPlayer.state.inventoryOpen then
        client.closeInventory()
    end
    _inInvPoly = nil
    LocalPlayer.state:set('_inInvPoly', nil, false)
end)

-- pulsar-compat client exports

exports('StaticTooltipOpen', function(item)
    ClientInventory.StaticTooltip:Open(item)
end)

exports('StaticTooltipClose', function()
    ClientInventory.StaticTooltip:Close()
end)

exports('CraftingBenchesOpen', function(benchId)
    TriggerEvent('Crafting:Client:OpenCrafting', nil, { id = benchId })
end)

exports('Disable', function()
    LocalPlayer.state:set('invBusy', true, false)
end)

exports('Enable', function()
    LocalPlayer.state:set('invBusy', false, false)
end)

exports('GetEquippedHash', function()
    return WEAPONS:GetEquippedHash()
end)

exports('getCurrentWeapon', function()
    return WEAPONS:GetEquippedItem()
end)

exports('openNearbyInventory', function(serverId)
    exports['ox_inventory']:openInventory('player', serverId)
end)

-- ItemsGetData(name?) — mirrors server export for client-side callers
-- no args: returns the full Items table; with name: returns single item definition
exports('ItemsGetData', function(itemName)
    if itemName then
        return Items(itemName)
    end
    return Items
end)

exports('ItemsHas', function(name, count)
    if next(pulsarItemCache) then
        local total = 0
        for _, slot in pairs(pulsarItemCache) do
            if slot.Name == name then total = total + (slot.Count or 0) end
        end
        return total >= (count or 1)
    end
    return (exports['ox_inventory']:Search('count', name) or 0) >= (count or 1)
end)

exports('ItemsGetWithStaticMetadata', function(masterKey, mainIdName, textureIdName, gender, data)
    for k, v in pairs(Items) do
        if v.staticMetadata ~= nil
            and v.staticMetadata[masterKey] ~= nil
            and v.staticMetadata[masterKey][gender] ~= nil
            and v.staticMetadata[masterKey][gender][mainIdName] == data[mainIdName]
            and v.staticMetadata[masterKey][gender][textureIdName] == data[textureIdName]
        then
            return k
        end
    end
    return nil
end)

-- Grapple hook

local EARLY_STOP_MULTIPLIER     = 0.5
local DEFAULT_GTA_FALL_DISTANCE = 8.3
local DEFAULT_GRAPPLE_OPTIONS   = { waitTime = 0.5, grappleSpeed = 20.0 }
local GRAPPLEHASH               = `WEAPON_BULLPUPSHOTGUN`

CAN_GRAPPLE_HERE = true

local Grapple = {}

local function DirectionToRotation(dir, roll)
    local z     = -(math.deg(math.atan(dir.x, dir.y)))
    local rotpos = vector3(dir.z, #vector2(dir.x, dir.y), 0.0)
    local x     = math.deg(math.atan(rotpos.x, rotpos.y))
    return vector3(x, roll, z)
end

local function RotationToDirection(rot)
    local rotZ     = math.rad(rot.z)
    local rotX     = math.rad(rot.x)
    local cosOfRotX = math.abs(math.cos(rotX))
    return vector3(-(math.sin(rotZ)) * cosOfRotX, math.cos(rotZ) * cosOfRotX, math.sin(rotX))
end

local function RayCastGamePlayCamera(dist)
    local camRot = GetGameplayCamRot()
    local camPos = GetGameplayCamCoord()
    local dir    = RotationToDirection(camRot)
    local dest   = camPos + (dir * dist)
    local ray    = StartShapeTestRay(camPos.x, camPos.y, camPos.z, dest.x, dest.y, dest.z, 17, -1, 0)
    local _, hit, endPos, _, entityHit = GetShapeTestResult(ray)
    if hit == 0 then endPos = dest end
    return hit, endPos, entityHit
end

function GrappleCurrentAimPoint(dist)
    return RayCastGamePlayCamera(dist or 40)
end

local function _waitForFall(pid, ped, stopDistance)
    SetPlayerFallDistance(pid, 10.0)
    while GetEntityHeightAboveGround(ped) > stopDistance do
        SetPedCanRagdoll(ped, false)
        Wait(0)
    end
    SetPlayerFallDistance(pid, DEFAULT_GTA_FALL_DISTANCE)
end

local function PinRope(rope, ped, boneId, dest)
    PinRopeVertex(rope, 0, dest.x, dest.y, dest.z)
    local boneCoords = GetPedBoneCoords(ped, boneId, 0.0, 0.0, 0.0)
    PinRopeVertex(rope, GetRopeVertexCount(rope) - 1, boneCoords.x, boneCoords.y, boneCoords.z)
end

function Grapple.new(dest, options)
    local self = {}
    options = options or {}
    for k, v in pairs(DEFAULT_GRAPPLE_OPTIONS) do
        if options[k] == nil then options[k] = v end
    end

    local grappleId = options.grappleId or math.random((-2^32)+1, 2^32-1)
    local pid       = options.plyServerId and GetPlayerFromServerId(options.plyServerId) or PlayerId()
    local ped       = GetPlayerPed(pid)
    local oldPedRef = ped
    local heading   = GetEntityHeading(ped)
    local start     = GetEntityCoords(ped)
    local notMyPed  = options.plyServerId and options.plyServerId ~= GetPlayerServerId(PlayerId())
    local dir       = (dest - start) / #(dest - start)
    local length    = #(dest - start)
    local finished  = false
    local rope

    if pid ~= -1 then
        rope = AddRope(dest.x, dest.y, dest.z, 0.0, 0.0, 0.0, 0.0, 4, 0.0, 0.0, 1.0, false, false, false, 5.0, false)
        LoadRopeData(rope, 'ropeFamily3')
        RopeLoadTextures()
        ped = ClonePed(ped, 0, 0, 0)
        SetEntityHeading(ped, heading)
        SetEntityAlpha(oldPedRef, 0, 0)
        for _, v in ipairs(GetGamePool('CObject')) do
            if Entity(v).state.backWeapon and IsEntityAttachedToEntity(v, oldPedRef) then
                SetEntityAlpha(v, 0, 0)
            end
        end
    end

    local function _setupDestroyEventHandler()
        local eventName = ('Inventory:Client:Grapple:DestroyRope:%s'):format(grappleId)
        RegisterNetEvent(eventName)
        local ev
        ev = AddEventHandler(eventName, function()
            self.destroy(false)
            RemoveEventHandler(ev)
        end)
    end

    function self._handleRope(r, p, boneIndex, d)
        CreateThread(function()
            while not finished do PinRope(r, p, boneIndex, d) Wait(0) end
            DeleteChildRope(r)
            DeleteRope(r)
        end)
    end

    function self.activateSync()
        if pid == -1 then return end
        local distTraveled = 0.0
        local currentPos   = start
        local lastPos      = currentPos
        local rot          = DirectionToRotation(-dir, 0.0) + vector3(90.0, 0.0, 0.0)
        local lastRot      = rot

        Wait(options.waitTime * 1000)
        while not finished and distTraveled < length do
            local fwd = dir * options.grappleSpeed * GetFrameTime()
            distTraveled = distTraveled + #fwd
            if distTraveled > length then
                distTraveled = length
                currentPos   = dest
            else
                currentPos = currentPos + fwd
            end
            SetEntityCoords(ped, currentPos.x, currentPos.y, currentPos.z)
            SetEntityRotation(ped, rot.x, rot.y, rot.z)
            if distTraveled > 3 and HasEntityCollidedWithAnything(ped) == 1 then
                local c = lastPos - (dir * EARLY_STOP_MULTIPLIER)
                SetEntityCoords(ped, c.x, c.y, c.z)
                SetEntityRotation(ped, lastRot.x, lastRot.y, lastRot.z)
                break
            end
            lastPos = currentPos
            lastRot = rot
            if not notMyPed then SetGameplayCamFollowPedThisUpdate(ped) end
            Wait(0)
        end

        if not notMyPed then
            local coords = GetEntityCoords(ped)
            local pedrot = GetEntityRotation(ped)
            SetEntityCoords(oldPedRef, coords.x, coords.y, coords.z)
            SetEntityRotation(oldPedRef, pedrot.x, pedrot.y, pedrot.z)
        else
            FreezeEntityPosition(ped, true, true)
        end

        self.destroy()
        _waitForFall(pid, ped, 3.0)

        CreateThread(function()
            Wait(200)
            for _, v in ipairs(GetGamePool('CObject')) do
                if Entity(v).state.backWeapon and IsEntityAttachedToEntity(v, oldPedRef) then
                    SetEntityAlpha(v, 255, 0)
                end
            end
        end)
    end

    function self.activate() CreateThread(self.activateSync) end

    function self.destroy(shouldTrigger)
        finished = true
        if shouldTrigger ~= false then
            if pid ~= -1 then
                CreateThread(function()
                    if notMyPed then
                        local loops = 0
                        while #(GetEntityCoords(ped) - GetEntityCoords(oldPedRef)) > 2 and loops < 20 do
                            loops = loops + 1
                            Wait(32)
                        end
                    end
                    DeleteEntity(ped)
                    SetEntityAlpha(oldPedRef, 255, 0)
                end)
            end
            TriggerServerEvent('Inventory:Server:Grapple:DestroyRope', grappleId)
        end
    end

    if pid ~= -1 then
        self._handleRope(rope, ped, 0x49D9, dest)
        if notMyPed then self.activate() end
    end
    if options.plyServerId == nil then
        TriggerServerEvent('Inventory:Server:Grapple:CreateRope', grappleId, dest)
    else
        _setupDestroyEventHandler()
    end

    return self
end

local _grappleEquipped    = false
local _shownGrappleButton = false

local function GrappleThreads()
    local ply = PlayerId()

    CreateThread(function()
        while _grappleEquipped and cache.weapon == GRAPPLEHASH do
            local freeAiming = IsPlayerFreeAiming(ply)
            local hit        = GrappleCurrentAimPoint(40)
            if not _shownGrappleButton and freeAiming and hit and CAN_GRAPPLE_HERE then
                _shownGrappleButton = true
                exports['pulsar-hud']:ActionShow('grapple', '{key}Shoot{/key} To Grapple')
            elseif _shownGrappleButton and (not freeAiming or not hit or not CAN_GRAPPLE_HERE) then
                _shownGrappleButton = false
                exports['pulsar-hud']:ActionHide('grapple')
            end
            Wait(250)
        end
    end)

    CreateThread(function()
        while _grappleEquipped and cache.weapon == GRAPPLEHASH do
            if IsControlJustReleased(0, 257) and IsPlayerFreeAiming(ply) and _grappleEquipped and CAN_GRAPPLE_HERE then
                local hit, pos = GrappleCurrentAimPoint(40)
                if hit then
                    local slotToDegrade = _equipped and _equipped.Slot
                    _grappleEquipped    = false
                    _shownGrappleButton = false
                    exports['pulsar-hud']:ActionHide('grapple')
                    local g = Grapple.new(pos)
                    g.activate()
                    if slotToDegrade then
                        TriggerServerEvent('Inventory:Server:DegradeLastUsed', 25, slotToDegrade)
                    end
                    Wait(1000)
                    WEAPONS:UnequipIfEquippedNoAnim()
                end
            end
            Wait(0)
        end
    end)
end

lib.onCache('weapon', function(weapon)
    if weapon == GRAPPLEHASH then
        _grappleEquipped = true
        SetTimeout(100, GrappleThreads)
    else
        _grappleEquipped = false
    end
end)

RegisterNetEvent('Inventory:Client:Grapple:CreateRope')
AddEventHandler('Inventory:Client:Grapple:CreateRope', function(plyServerId, grappleId, dest)
    if plyServerId == GetPlayerServerId(PlayerId()) then return end
    Grapple.new(dest, { plyServerId = plyServerId, grappleId = grappleId })
end)

-- Vanity items

RegisterNetEvent('Inventory:Client:UseVanityItem')
AddEventHandler('Inventory:Client:UseVanityItem', function(sender, action, itemData)
    if not LocalPlayer.state.loggedIn then return end
    local senderClient = GetPlayerFromServerId(sender)
    local isMe         = sender == LocalPlayer.state.ID

    if action == 'overlay' then
        exports['pulsar-hud']:OverlayShow(itemData)
    elseif action == 'overlayall' then
        if senderClient < 0 and not isMe then return end
        if not senderClient then return end
        local myPed   = LocalPlayer.state.ped
        local sendPed = GetPlayerPed(senderClient)
        if DoesEntityExist(sendPed) then
            local dist = #(GetEntityCoords(sendPed) - GetEntityCoords(myPed))
            if dist <= 4.0 and HasEntityClearLosToEntity(myPed, sendPed, 17) then
                exports['pulsar-hud']:OverlayShow(itemData)
            end
        end
    end
    SetTimeout(10000, function() exports['pulsar-hud']:OverlayHide() end)
end)

-- Signs

RegisterNetEvent('Inventory:Client:Signs:UseSign')
AddEventHandler('Inventory:Client:Signs:UseSign', function(item)
    if item.Name then
        exports['pulsar-animations']:EmotesPlay(item.Name, false, false, false)
    end
end)

-- Halloween

RegisterNetEvent('Inventory:Client:Halloween:Pumpkin')
AddEventHandler('Inventory:Client:Halloween:Pumpkin', function(emote)
    exports['pulsar-sounds']:PlayDistance(20.0, 'evillaugh.ogg', 0.2)
    exports['pulsar-animations']:EmotesPlay(emote, false, false, false)
end)

-- ERP

RegisterNetEvent('Inventory:Client:ERP:ButtPlug')
AddEventHandler('Inventory:Client:ERP:ButtPlug', function(color)
    exports['pulsar-animations']:EmotesPlay(('erp_buttplug_%s'):format(color), false, false, false)
end)

RegisterNetEvent('Inventory:Client:ERP:Vibrator')
AddEventHandler('Inventory:Client:ERP:Vibrator', function(color)
    exports['pulsar-sounds']:PlayDistance(20.0, 'vibrator.ogg', 0.2)
    exports['pulsar-animations']:EmotesPlay(('erp_vibrator_%s'):format(color), false, false, false)
end)

