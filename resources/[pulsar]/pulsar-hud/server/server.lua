local _uircd = {}

local function GetFixedHUDConfig()
  return {
    layout = "default",
    statusType = "numbers",
    buffsAnchor = "compass",
    vehicle = "minimal",
    buffsAnchor2 = true,
    showRPM = true,
    hideCrossStreet = false,
    hideCompassBg = true,
    largeBars = false,
    minimapAnchor = true,
    transparentBg = false,
    maskRadio = false,
    condenseAlignment = "left",
    circleNumbers = false,
  }
end

AddEventHandler('onResourceStart', function(resource)
  if resource == GetCurrentResourceName() then
    Wait(1000)
    RegisterItems()
    RegisterChatCommands()
    exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-hud')

    exports['pulsar-core']:MiddlewareAdd("Characters:Creating", function(source, cData)
      return {
        {
          HUDConfig = GetFixedHUDConfig(),
        },
      }
    end)
    exports['pulsar-core']:MiddlewareAdd("Characters:Spawning", function(source)
      local char = exports['pulsar-characters']:FetchCharacterSource(source)
      if char ~= nil then
        char:SetData("HUDConfig", GetFixedHUDConfig())
      end
    end, 1)

    exports["pulsar-core"]:RegisterServerCallback("HUD:SaveConfig", function(source, data, cb)
      local char = exports['pulsar-characters']:FetchCharacterSource(source)
      if char ~= nil then
        char:SetData("HUDConfig", GetFixedHUDConfig())
        cb(true)
      else
        cb(false)
      end
    end)

    exports["pulsar-core"]:RegisterServerCallback("HUD:RemoveBlindfold", function(source, data, cb)
      local char = exports['pulsar-characters']:FetchCharacterSource(source)
      if char ~= nil then
        local tarState = Player(data).state
        if tarState.isBlindfolded then
          exports["pulsar-core"]:ClientCallback(source, "HUD:PutOnBlindfold", "Removing Blindfold",
            function(isSuccess)
              if isSuccess then
                if exports.ox_inventory:AddItem(char:GetData("SID"), "blindfold", 1, {}, 1) then
                  tarState.isBlindfolded = false
                  TriggerClientEvent("VOIP:Client:Gag:Use", data)
                else
                  exports['pulsar-hud']:Notification(source, "error",
                    "Failed Adding Item")
                  cb(false)
                end
              end
            end)
        else
          exports['pulsar-hud']:Notification(source, "error", "Target Not Blindfolded")
          cb(false)
        end
      else
        cb(false)
      end
    end)
  end
end)

function RegisterItems()
  exports.ox_inventory:RegisterUse("blindfold", "HUD", function(source, item, itemData)
    exports["pulsar-core"]:ClientCallback(source, "HUD:GetTargetInfront", {}, function(target)
      if target ~= nil then
        local tarState = Player(target).state
        if not tarState.isBlindfolded then
          exports["pulsar-core"]:ClientCallback(source, "HUD:PutOnBlindfold", "Blindfolding",
            function(isSuccess)
              if isSuccess then
                if tarState.isCuffed then
                  if exports.ox_inventory:RemoveSlot(item.Owner, item.Name, 1, item.Slot, 1) then
                    tarState.isBlindfolded = true
                    TriggerClientEvent("VOIP:Client:Gag:Use", target)
                  else
                    exports['pulsar-hud']:Notification(source, "error",
                      "Failed Removing Item")
                  end
                else
                  exports['pulsar-hud']:Notification(source, "error",
                    "Target Not Cuffed")
                end
              end
            end)
        else
          exports['pulsar-hud']:Notification(source, "error",
            "Target Already Blindfolded")
        end
      else
        exports['pulsar-hud']:Notification(source, "error", "Nobody Near To Blindfold")
      end
    end)
  end)
end

RegisterNetEvent('ox_inventory:ready', function()
  if GetResourceState(GetCurrentResourceName()) == 'started' then
    RegisterItems()
  end
end)

function RegisterChatCommands()
  exports["pulsar-chat"]:RegisterCommand("uir", function(source, args, rawCommand)
    if not _uircd[source] or os.time() > _uircd[source] then
      TriggerClientEvent("UI:Client:Reset", source, true)
      _uircd[source] = os.time() + (60 * 5)
    else
      exports["pulsar-chat"]:SendSystemSingle(source, "You're Trying To Do This Too Much, Stop.")
    end
  end, {
    help = "Resets UI",
  })

  exports["pulsar-chat"]:RegisterAdminCommand("testblindfold", function(source, args, rawCommand)
    local char = exports['pulsar-characters']:FetchCharacterSource(source)
    if char ~= nil then
      Player(source).state.isBlindfolded = not Player(source).state.isBlindfolded
    end
  end, {
    help = "Test Blindfold",
  })

  -- exports["pulsar-chat"]:RegisterAdminCommand("notif", function(source, args, rawCommand)
  -- 	exports['pulsar-hud']:Notification(source, "success", "This is a test, lul")
  -- end, {
  -- 	help = "Test Notification",
  -- })

  -- exports["pulsar-chat"]:RegisterAdminCommand("list", function(source, args, rawCommand)
  -- 	TriggerClientEvent("ListMenu:Client:Test", source)
  -- end, {
  -- 	help = "Test List Menu",
  -- })

  -- exports["pulsar-chat"]:RegisterAdminCommand("input", function(source, args, rawCommand)
  -- 	TriggerClientEvent("Input:Client:Test", source)
  -- end, {
  -- 	help = "Test Input",
  -- })

  -- exports["pulsar-chat"]:RegisterAdminCommand("confirm", function(source, args, rawCommand)
  -- 	TriggerClientEvent("Confirm:Client:Test", source)
  -- end, {
  -- 	help = "Test Confirm Dialog",
  -- })

  -- exports["pulsar-chat"]:RegisterAdminCommand("skill", function(source, args, rawCommand)
  -- 	TriggerClientEvent("Minigame:Client:Skillbar", source)
  -- end, {
  -- 	help = "Test Skill Bar",
  -- })

  -- exports["pulsar-chat"]:RegisterAdminCommand("scan", function(source, args, rawCommand)
  -- 	TriggerClientEvent("Minigame:Client:Scanner", source)
  -- end, {
  -- 	help = "Test Scanner",
  -- })

  -- exports["pulsar-chat"]:RegisterAdminCommand("sequencer", function(source, args, rawCommand)
  -- 	TriggerClientEvent("Minigame:Client:Sequencer", source)
  -- end, {
  -- 	help = "Test Sequencer",
  -- })

  -- exports["pulsar-chat"]:RegisterAdminCommand("keypad", function(source, args, rawCommand)
  -- 	TriggerClientEvent("Minigame:Client:Keypad", source)
  -- end, {
  -- 	help = "Test Keypad",
  -- })

  -- exports["pulsar-chat"]:RegisterAdminCommand("scrambler", function(source, args, rawCommand)
  -- 	TriggerClientEvent("Minigame:Client:Scrambler", source)
  -- end, {
  -- 	help = "Test Scrambler",
  -- })

  -- exports["pulsar-chat"]:RegisterAdminCommand("memory", function(source, args, rawCommand)
  -- 	TriggerClientEvent("Minigame:Client:Memory", source)
  -- end, {
  -- 	help = "Test Memory",
  -- })
end
