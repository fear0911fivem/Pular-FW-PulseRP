local Utils = require 'backItems.imports.utils'
local Config = require 'backItems.config'
local PlayerState = LocalPlayer.state

InvCache = {}
CurrentWeapon = nil

function UpdateBackItems()
    local formattedData = Utils.formatCachedInventory(InvCache)

    if not lib.table.matches(formattedData, PlayerState.backItems) then
        PlayerState:set('backItems', formattedData, true)
    end
end

local function shouldUpdate(slot, change)
    local backitems = Config.BackItems
    local last = InvCache[slot]
    if not change then
        return not last or backitems[last.name] ~= nil
    end
    return (last and backitems[last.name]) or (change and backitems[change.name])
end

AddEventHandler('ox_inventory:updateInventory', function(changes)
    if not changes then return end

    local needsUpdate = false

    for slot, change in pairs(changes) do
        if not needsUpdate then
            needsUpdate = shouldUpdate(slot, change)
        end

        -- if the equipped weapon's slot was cleared (dropped), clear CurrentWeapon
        if not change and CurrentWeapon and CurrentWeapon.slot == slot then
            CurrentWeapon = nil
            needsUpdate = true
        end

        InvCache[slot] = change or nil
    end

    if needsUpdate then
        UpdateBackItems()
    end
end)

local function flashlightLoop()
    if not CurrentWeapon then return end

    local state = CurrentWeapon.metadata.flashlight

    if state then
        SetFlashLightEnabled(cache.ped, true)
    end

    while CurrentWeapon do
        local currentState = IsFlashLightOn(cache.ped)
        if state ~= currentState then
            state = currentState
            PlayerState:set('flashlightState', state, true)
        end
        Wait(100)
    end
end

AddEventHandler('ox_inventory:currentWeapon', function(weapon)
    CurrentWeapon = weapon
    UpdateBackItems()

    if weapon and Utils.hasFlashLight(weapon.metadata.components) then
        flashlightLoop()
    end
end)

-- Pulsar equip/holster: sync CurrentWeapon so the back-item hide logic works
AddEventHandler('Weapons:Client:SwitchedWeapon', function(weaponName, item)
    if weaponName and item then
        CurrentWeapon = { slot = item.Slot, name = item.Name, metadata = item.MetaData or {} }
    else
        CurrentWeapon = nil
    end
    -- Defer one tick: if this fired from inside ox_inventory:updateInventory (e.g. drop of equipped weapon), InvCache is still stale. Waiting lets the backItems updateInventory
    -- handler clear InvCache first, so UpdateBackItems computes the correct state and avoids
    -- a double state-bag write that races async weapon-asset loading.
    CreateThread(function()
        Wait(0)
        UpdateBackItems()
    end)
end)

lib.onCache('ped', RefreshBackItems)

lib.onCache('vehicle', function(vehicle)
    local toggle = vehicle ~= false

    if toggle and Config.allowedVehicleClasses[GetVehicleClass(vehicle)] then
        return
    end

    PlayerState:set('hideAllBackItems', toggle, true)
    UpdateBackItems()
end)

local function load()
    while GetResourceState('ox_inventory') ~= 'started' do
        Wait(500)
    end
    InvCache = exports.ox_inventory:GetPlayerItems()
    CurrentWeapon = exports.ox_inventory:getCurrentWeapon()
    RefreshBackItems()
end

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        load()
    end
end)


AddEventHandler("Characters:Client:Spawn", load)

AddEventHandler('esx:playerLoaded', load)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', load)
