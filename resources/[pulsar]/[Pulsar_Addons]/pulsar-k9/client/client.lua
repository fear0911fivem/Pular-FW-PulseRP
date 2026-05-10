local Config = require 'shared/config'

local activate_k9 = false
local k9_name = Config.K9.DogName
local k9_id = false
local searching = false
local following = true
local currentDogDoor = nil

local sit = Config.K9.Animations.sit
local laydown = Config.K9.Animations.laydown
local searchhit = Config.K9.Animations.searchhit

local function PlayAnimation(dict, anim)
  RequestAnimDict(dict)
  while not HasAnimDictLoaded(dict) do
    Wait(5)
  end
  local DOG = NetworkGetEntityFromNetworkId(k9_id)
  following = false
  TaskPlayAnim(DOG, dict, anim, 8.0, -8.0, -1, 2, 0.0, 0, 0, 0)
end

local function K9AttackorFollow(target)
  local DOG = NetworkGetEntityFromNetworkId(k9_id)
  if target then
    SetCanAttackFriendly(DOG, true, true)
    TaskPutPedDirectlyIntoMelee(DOG, target, 0.0, -1.0, 0.0, false)
    following = false
    Notification:Error(k9_name .. " is attacking!", 2000)
  else
    TaskFollowToOffsetOfEntity(DOG, PlayerPedId(), 0.5, -1.0, 0.0, 5.0, -1, 1.0, true)
    following = true
    Notification:Info(k9_name .. " is following.", 2000)
  end
end

local function DespawnK9()
  if k9_id then
    local DOG = NetworkGetEntityFromNetworkId(k9_id)
    if DoesEntityExist(DOG) then
      DeleteEntity(DOG)
    end
  end
  following = true
  k9_id = false
  searching = false
end

local function CheckK9Conditions()
  if k9_id then
    local DOG = NetworkGetEntityFromNetworkId(k9_id)
    local DOG_COORDS = GetEntityCoords(DOG)
    local PLAYER_COORDS = GetEntityCoords(PlayerPedId())
    local DISTANCE = #(DOG_COORDS - PLAYER_COORDS)
    if DISTANCE > 100 and not IsPedInAnyVehicle(DOG, false) then
      K9AttackorFollow(false)
    end
    if IsEntityDead(DOG) or IsEntityDead(PlayerPedId()) then
      DespawnK9()
    end
  end
end

local function EnableK9(bool)
  SetPedRelationshipGroupHash(PlayerPedId(), GetHashKey("PLAYER_POLICE"))
  if bool then
    activate_k9 = true
    while activate_k9 do
      Wait(15000)
      CheckK9Conditions()
    end
  end
end

local function K9Found(status, type)
  local time = math.random(500, 1500)
  if type == 'vehicle' then
    time = math.random(1500, 3500)
  end
  Wait(time)
  if status then
    Notification:Success("Dog Alerted!", 4000)
    searching = false
    PlayAnimation(searchhit.dict, searchhit.anim)
    Wait(2500)
    PlayAnimation(sit.dict, sit.anim)
    following = false
  else
    Notification:Error("Dog did not alert", 4000)
    following = true
  end
end

local function GetClosestVehicleDoor(vehicle)
  local PLAYER = GetEntityCoords(PlayerPedId(), false)
  local BACKLEFT = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "door_dside_r"))
  local BACKRIGHT = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "door_pside_r"))
  local BLDISTANCE = #(PLAYER - BACKLEFT)
  local BRDISTANCE = #(PLAYER - BACKRIGHT)

  local FOUND_DOOR = false

  if BLDISTANCE < BRDISTANCE then
    FOUND_DOOR = 2
  else
    FOUND_DOOR = 3
  end

  return FOUND_DOOR
end

local function GetClosestVehicle(coords, radius)
  if not coords then
    return nil
  end

  local closestVehicle = nil
  local closestDistance = radius or 10.0

  local vehicles = GetGamePool("CVehicle")
  for _, vehicle in ipairs(vehicles) do
    local vehicleCoords = GetEntityCoords(vehicle)
    local distance = #(coords - vehicleCoords)
    if distance < closestDistance then
      closestVehicle = vehicle
      closestDistance = distance
    end
  end

  return closestVehicle
end

local function K9ToggleVehicle(target)
  searching = false
  local DOG = NetworkGetEntityFromNetworkId(k9_id)
  local PLAYER_COORDS = GetEntityCoords(PlayerPedId())
  local VEHICLE = GetClosestVehicle(PLAYER_COORDS, 10.0)

  if not VEHICLE then
    Notification:Error("No nearby vehicle found.", 4000)
    return
  end

  local DOOR = GetClosestVehicleDoor(VEHICLE)
  local VEHICLE_COORDS = GetEntityCoords(VEHICLE)
  local DOG_COORDS = GetEntityCoords(DOG)
  local SEAT = (DOOR == 3) and "seat_pside_r" or "seat_dside_r"

  if #(VEHICLE_COORDS - DOG_COORDS) < 5 or target then
    if IsEntityAttached(DOG) then
      following = false
      SetEntityInvincible(DOG, true)
      SetPedCanRagdoll(DOG, false)

      local doorToUse = currentDogDoor or DOOR
      local DOOR_COORDS = GetOffsetFromEntityInWorldCoords(VEHICLE, (doorToUse == 3) and 1.0 or -1.0, 0.0, 0.0)

      if DOOR_COORDS and (DOOR_COORDS.x ~= 0 or DOOR_COORDS.y ~= 0 or DOOR_COORDS.z ~= 0) then
        local _, groundZ = GetGroundZFor_3dCoord(DOOR_COORDS.x, DOOR_COORDS.y, DOOR_COORDS.z, false)
        SetVehicleDoorOpen(VEHICLE, doorToUse, false, false)
        Wait(500)
        DetachEntity(DOG, false, false)
        SetEntityCoords(DOG, DOOR_COORDS.x, DOOR_COORDS.y, groundZ, false, false, false, false)
        ClearPedTasks(DOG)
        currentDogDoor = nil
        Wait(1500)
        K9AttackorFollow(target)
        SetPedCanRagdoll(DOG, true)
        SetEntityInvincible(DOG, false)
        SetVehicleDoorShut(VEHICLE, doorToUse, false)
      end
    else
      following = true
      SetVehicleDoorOpen(VEHICLE, DOOR, false, false)
      Wait(1500)
      AttachEntityToEntity(DOG, VEHICLE, GetEntityBoneIndexByName(VEHICLE, SEAT), 0.0, -0.25, 0.40, 0.0, 0.0, 0, false,
        false, false, true, 20, true)
      PlayAnimation(sit.dict, sit.anim)
      currentDogDoor = DOOR
      SetVehicleDoorShut(VEHICLE, DOOR, false)
    end
  else
    Notification:Error(k9_name .. " is too far away!", 4000)
  end
end

local function GetPlayers()
  local players = {}
  for i = 0, 256 do
    if NetworkIsPlayerActive(i) then
      table.insert(players, i)
    end
  end
  return players
end

local function K9SearchPerson()
  following = false
  local TARGET = GetPlayerSourceAheadOfPlayer()

  if TARGET and TARGET > 0 then
    TriggerServerEvent("K9:server:searchPerson", TARGET)
  else
    Notification:Error(k9_name .. " was unable to locate person.", 4500)
  end
end

function GetPlayerId(target_ped)
  local players = GetPlayers()
  for a = 1, #players do
    local ped = GetPlayerPed(players[a])
    local server_id = GetPlayerServerId(players[a])
    if target_ped == ped then
      return server_id
    end
  end
  return 0
end

local function K9SearchVehicle()
  following = false
  local PLAYER_COORDS = GetEntityCoords(PlayerPedId())
  local VEHICLE = GetClosestVehicle(PLAYER_COORDS, 10.0)
  local vehState = Entity(VEHICLE).state
  local PLATE = GetVehicleNumberPlateText(VEHICLE)
  local DOG = NetworkGetEntityFromNetworkId(k9_id)
  local VEHICLE_COORDS = GetEntityCoords(VEHICLE)
  local DOG_COORDS = GetEntityCoords(DOG)

  if #(VEHICLE_COORDS - PLAYER_COORDS) > 5.0 or #(VEHICLE_COORDS - DOG_COORDS) > 5.0 then
    Notification:Error("Both you and " .. k9_name .. " must be near the vehicle.", 4000)
    return
  end

  Notification:Success(k9_name .. " is searching..", 4500)

  local PLAYERS = {}
  local MAX_SEATS = GetVehicleMaxNumberOfPassengers(VEHICLE)
  for i = -1, MAX_SEATS do
    local TARGET = GetPedInVehicleSeat(VEHICLE, i)
    if TARGET and DoesEntityExist(TARGET) then
      local SERVER_ID = GetPlayerServerId(NetworkGetPlayerIndexFromPed(TARGET))
      if SERVER_ID and SERVER_ID > 0 then
        table.insert(PLAYERS, SERVER_ID)
      end
    end
  end

  TriggerServerEvent("K9:server:searchVehicle", vehState.VIN, PLATE, PLAYERS)
  searching = true

  local offsets = {
    GetOffsetFromEntityInWorldCoords(VEHICLE, 2.0, -2.0, 0.0),
    GetOffsetFromEntityInWorldCoords(VEHICLE, 2.0, 2.0, 0.0),
    GetOffsetFromEntityInWorldCoords(VEHICLE, -2.0, 2.0, 0.0),
    GetOffsetFromEntityInWorldCoords(VEHICLE, -2.0, -2.0, 0.0)
  }

  for _, offset in ipairs(offsets) do
    if searching then
      TaskGoToCoordAnyMeans(DOG, offset.x, offset.y, offset.z, 5.0, 0, false, 1, 10.0)
      Wait(2500)
    else
      break
    end
  end

  searching = false
  Notification:Success(k9_name .. " has completed the search.", 4500)
end

local function GetPlayersInRadius(min, max)
  local players = GetPlayers()
  local IN_RANGE = {}
  for a = 1, #players do
    local PED = GetPlayerPed(players[a])
    local PED_COORDS = GetEntityCoords(PED)
    local PLAYER_COORDS = GetEntityCoords(PlayerPedId())
    local DISTANCE = #(PED_COORDS - PLAYER_COORDS)

    if DISTANCE <= max and DISTANCE >= min then
      table.insert(IN_RANGE, PED)
    end
  end
  return IN_RANGE
end

local function K9SearchArea()
  Notification:Info(k9_name .. " is searching the vicinity.", 4000)
  local PLAYERS = GetPlayersInRadius(20, 75)

  for i = 1, #PLAYERS do
    following = false
    Notification:Info(k9_name .. " found a scent.", 4000)
    local DOG = NetworkGetEntityFromNetworkId(k9_id)
    local DOG_COORDS = GetEntityCoords(DOG)
    local COORDS = GetEntityCoords(PLAYERS[i])
    TaskGoToCoordAnyMeans(DOG, COORDS.x, COORDS.y, COORDS.z, 5.0, 0, false, 1, 10.0)

    while #(DOG_COORDS - COORDS) > 2 do
      Wait(1000)
      DOG_COORDS = GetEntityCoords(DOG)
      if following then
        break
      end
    end

    if following then
      Notification:Info(k9_name .. " is no longer tracking.", 4000)
      break
    end
    Notification:Info(k9_name .. " lost the scent.", 4000)
    K9AttackorFollow(false)
    Wait(2000)
  end
end

local function RequestNetworkControl()
  NetworkRequestControlOfNetworkId(k9_id)
  while not NetworkHasControlOfNetworkId(k9_id) do
    Wait(500)
    NetworkRequestControlOfNetworkId(k9_id)
  end
end

function GetPlayerSourceAheadOfPlayer()
  local PLAYER = PlayerPedId()
  local COORDS = GetEntityCoords(PLAYER)
  local OFFSET = GetOffsetFromEntityInWorldCoords(PLAYER, 0.0, 2.0, 0.0)
  local RAY = StartShapeTestCapsule(COORDS.x, COORDS.y, COORDS.z, OFFSET.x, OFFSET.y, OFFSET.z, 0.5, 12, PLAYER, 7)
  local HIT, PED = GetShapeTestResult(RAY)

  if HIT then
    return GetPlayerId(PED)
  else
    return false
  end
end

AddEventHandler("Characters:Client:Spawn", function()
  if exports["pulsar-jobs"]:HasJob(Config.K9.job, nil, nil, nil, true) then
    EnableK9(true)
  end
end)

RegisterNetEvent('Characters:Client:Logout')
AddEventHandler('Characters:Client:Logout', function()
  if k9_id then
    DespawnK9()
  end
end)

AddStateBagChangeHandler("onDuty", nil, function(bagName, _, value)
  if bagName ~= ("player:%s"):format(GetPlayerServerId(PlayerId())) then
    return
  end
  if value == Config.K9.job and exports["pulsar-jobs"]:HasJob(Config.K9.job, nil, nil, nil, true) then
    EnableK9(true)
  end
end)

function InitK9Ped()
  local dogProps = Config.K9.DogModelProps[2]
  local dogModel = dogProps.Dog
  local dogSpawn = Config.K9.DogCoords
  local dogCoords = vector3(dogSpawn.x, dogSpawn.y, dogSpawn.z)
  local dogHeading = dogSpawn.w

  RequestModel(dogModel)
  CreateThread(function()
    while not HasModelLoaded(dogModel) do
      Wait(0)
    end

    local dogPed = CreatePed(28, dogModel, dogCoords.x, dogCoords.y, dogCoords.z, dogHeading, false, false)
    SetPedComponentVariation(dogPed, 0, 0, dogProps.Colour, 0)
    SetPedComponentVariation(dogPed, dogProps.Vest, 0, 1, 0)
    SetBlockingOfNonTemporaryEvents(dogPed, true)
    SetPedFleeAttributes(dogPed, 0, false)
    SetEntityInvincible(dogPed, true)
    FreezeEntityPosition(dogPed, true)

    RequestAnimDict(sit.dict)
    while not HasAnimDictLoaded(sit.dict) do
      Wait(0)
    end

    TaskPlayAnim(dogPed, sit.dict, sit.anim, 8.0, -8.0, -1, 1, 0.0, false, false, false)

    exports.ox_target:addBoxZone({
      name = "k9_unit",
      coords = dogCoords,
      size = vector3(1.5, 1.6, 5.2),
      rotation = dogHeading,
      debug = false,
      options = {
        {
          name = "pd_k9_unit",
          icon = "paw",
          label = "PD K9 Unit",
          event = "pulsar-k9:client:menu",
          job = Config.K9.job,
          distance = 3.0,
        },
      },
    })
  end)
end

RegisterNetEvent('pulsar-k9:client:menu', function()
  local K9Purchase = {
    main = {
      label = "🐶 | Police K9 Menu",
      items = {}
    }
  }

  table.insert(K9Purchase.main.items, {
    label = "🐕‍🦺 | Take out K9",
    description = "Here you can take out one of the department's available dogs",
    event = "pulsar-k9:client:PurchaseDog"
  })

  table.insert(K9Purchase.main.items, {
    label = "🐕 | Return K9",
    description = "Here you can return one of the department's K9 Dogs",
    event = "pulsar-k9:client:ReturnDoggo"
  })

  ListMenu:Show(K9Purchase)
end)

RegisterNetEvent('puksar-k9:client:ReturnDoggo', function()
  if k9_id then
    DespawnK9()
    Notification:Success("You returned the K9 Unit!", 4000)
  else
    Notification:Error("No K9 Unit to return!", 4000)
  end
end)

RegisterNetEvent('pulsar-k9:client:PurchaseDog', function()
  if k9_id then
    DespawnK9()
    Notification:Info("Returned K9 Unit.", 4000)
  end

  local K9DogsMenu = {
    main = {
      label = "🐶 | Choose Your K9 Dog",
      items = {}
    }
  }

  for k, v in pairs(Config.K9.DogModelProps) do
    table.insert(K9DogsMenu.main.items, {
      label = v.Header,
      description = v.Description,
      event = "pulsar-k9:client:SpawnHandler",
      data = {
        model = v.Dog,
        colour = v.Colour,
        vest = v.Vest
      }
    })
  end

  ListMenu:Show(K9DogsMenu)
end)

RegisterNetEvent('pulsar-k9:client:SpawnHandler', function(data)
  TriggerServerEvent("K9:server:spawnK9", data.model, data.colour, data.vest)
end)

RegisterNetEvent('K9:client:spawnK9', function(DawgHash, colour, vest)
  local playerPed = PlayerPedId()
  local pos = GetEntityCoords(playerPed)
  local heading = GetEntityHeading(playerPed)
  local forwardVector = GetEntityForwardVector(playerPed)
  local spawnPos = vector3(
    pos.x + forwardVector.x,
    pos.y + forwardVector.y,
    pos.z - 1
  )

  RequestModel(DawgHash)
  while not HasModelLoaded(DawgHash) do
    Wait(5)
    RequestModel(DawgHash)
  end

  local DOG = CreatePed(28, DawgHash, spawnPos.x, spawnPos.y, spawnPos.z, heading, true, true)
  k9_id = NetworkGetNetworkIdFromEntity(DOG)
  RequestNetworkControl()
  DOG = NetworkGetEntityFromNetworkId(k9_id)
  SetPedComponentVariation(DOG, 0, 0, colour, 0)
  SetPedComponentVariation(DOG, vest, 0, 1, 0)
  SetBlockingOfNonTemporaryEvents(DOG, true)
  SetPedFleeAttributes(DOG, 0, false)
  SetPedRelationshipGroupHash(DOG, GetHashKey("PLAYER_POLICE"))
  SetPedArmour(DOG, 25)
  SetEntityHeading(DOG, 90)
  local BLIP = AddBlipForEntity(DOG)
  SetBlipAsFriendly(BLIP, true)
  SetBlipSprite(BLIP, 442)
  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString(k9_name)
  EndTextCommandSetBlipName(BLIP)
  K9AttackorFollow(false)
  EnableK9(true)
end)

RegisterNetEvent('k9:client:search_results', function(status, type, inventory)
  if status then
    K9Found(status, type)
  end

  if inventory and #inventory > 0 then
    local itemDetails = {}
    for _, item in ipairs(inventory) do
      table.insert(itemDetails, string.format("%s (x%d)", item.name, item.count))
    end
    local notificationMessage = "Suspicious scent found."
    Notification:Success(notificationMessage, 8000)
  else
    Notification:Info("Vehicle seems to be empty.", 6000)
  end
end)

function RegisterKeyBinds()
  Keybinds:Add('caninecommanders', Config.K9.K9KeyCommands, 'keyboard', 'Police - K9 Commands', function()
    TriggerEvent('pulsar-k9:client:CommandsMenu')
  end)
  Keybinds:Add('cannineattackfollow', Config.K9.K9KeyFollowAttack, 'keyboard', 'Police - K9 Follow / Attack', function()
    TriggerEvent('pulsar-k9:client:Commands', { action = 'followAttack' })
  end)
end

RegisterNetEvent('pulsar-k9:client:CommandsMenu', function()
  if not activate_k9 then
    Notification:Error("No active K9 available.", 4000)
    return
  end

  local k9CommandsMenu = {
    main = {
      label = "Police K9 Commands",
      items = {}
    }
  }

  local commandOptions = {
    { label = "🧍 K9 Stand", description = "Make your K9 dog stand up", action = "stand" },
    { label = "🔈 K9 Sit", description = "Make your K9 dog sit down", action = "sit" },
    { label = "🔈 K9 Lay Down", description = "Make your K9 dog lay down", action = "laydown" },
    { label = "🚗 K9 Search Vehicle", description = "Make your K9 search a nearby vehicle", action = "searchVehicle" },
    { label = "🚘 K9 Enter / Exit Vehicle", description = "Tell your K9 to enter a vehicle", action = "enterVehicle" },
    { label = "🧍 K9 Search Person", description = "Make your K9 search a nearby person", action = "searchDude" },
    { label = "🌍 K9 Search Area", description = "Make your K9 search the area", action = "searchArea" }
  }

  for _, command in ipairs(commandOptions) do
    table.insert(k9CommandsMenu.main.items, {
      label = command.label,
      description = command.description,
      event = "pulsar-k9:client:Commands",
      data = { action = command.action }
    })
  end

  ListMenu:Show(k9CommandsMenu)
end)

RegisterNetEvent('pulsar-k9:client:Commands', function(data)
  local action = data.action
  if action == "followAttack" then
    if activate_k9 then
      if IsPlayerFreeAiming(PlayerId()) then
        local bool, target = GetEntityPlayerIsFreeAimingAt(PlayerId())
        if bool and IsEntityAPed(target) then
          following = false
          local DOG = NetworkGetEntityFromNetworkId(k9_id)
          if IsEntityAttached(DOG) then
            K9ToggleVehicle(target)
          else
            K9AttackorFollow(target)
          end
        end
      else
        if not following then
          K9AttackorFollow(false)
          following = true
        end
      end
    else
      Notification:Error("No active K9 available.", 4000)
    end
  elseif action == "stand" then
    local DOG = NetworkGetEntityFromNetworkId(k9_id)
    if DoesEntityExist(DOG) then
      ClearPedTasks(DOG)
    end
  elseif action == "sit" then
    PlayAnimation(sit.dict, sit.anim)
  elseif action == "laydown" then
    PlayAnimation(laydown.dict, laydown.anim)
  elseif action == "searchVehicle" then
    K9SearchVehicle()
  elseif action == "enterVehicle" then
    K9ToggleVehicle(false)
  elseif action == "searchDude" then
    K9SearchPerson()
  elseif action == "searchArea" then
    K9SearchArea()
  else
    Notification:Error("Unknown command action.", 4000)
  end
end)
