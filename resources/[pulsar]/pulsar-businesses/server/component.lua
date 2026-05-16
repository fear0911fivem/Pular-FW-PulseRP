_pickups = {}
local startup = false
AddEventHandler('onResourceStart', function(resource)
  if resource == GetCurrentResourceName() then
    Wait(1000)
    TriggerEvent("Businesses:Server:Startup")
    exports['pulsar-core']:VersionCheck('PulsarFW/pulsar-businesses')

    exports['pulsar-core']:MiddlewareAdd("Characters:Spawning", function(source)
      TriggerClientEvent(
        "Taco:SetQueue",
        source,
        { counter = GlobalState["TacoShop:Counter"], item = GlobalState["TacoShop:CurrentItem"] }
      )
    end, 2)

    exports['pulsar-core']:MiddlewareAdd("Characters:Spawning", function(source)
      if not startup then
        startup = true
        TriggerLatentClientEvent("Businesses:Client:CreatePoly", source, 50000, _pickups)
      end
    end, 2)

    Startup()
  end
end)

local function RegisterBusinessBenches()
  while GetResourceState('ox_inventory') ~= 'started' do
    Wait(500)
  end
  for k = 1, #Config.Businesses do
    local v = Config.Businesses[k]
    if v.Benches then
      for benchId, bench in pairs(v.Benches) do
        local location = nil
        if bench.targeting and bench.targeting.poly then
          local opts = bench.targeting.poly.options or {}
          location = {
            x = bench.targeting.poly.coords.x,
            y = bench.targeting.poly.coords.y,
            z = bench.targeting.poly.coords.z,
            h = opts.heading or 0,
          }
        end
        exports.ox_inventory:CraftingRegisterBench(
          string.format('business-%s-%s', k, benchId),
          bench.label,
          bench.targeting,
          location,
          { job = { id = v.Job, grade = 0 } },
          bench.recipes,
          false
        )
      end
    end
  end
end

function Startup()
  CreateThread(RegisterBusinessBenches)

  for k = 1, #Config.Businesses do
    local v = Config.Businesses[k]
    exports['pulsar-core']:LoggerTrace("Businesses", string.format("Registering Business ^3%s^7", v.Name))
    if v.Pickups then
      for num = 1, #v.Pickups do
        local pickup = v.Pickups[num]
        table.insert(_pickups, pickup.id)
        pickup.num = num
        pickup.job = v.Job
        pickup.jobName = v.Name

        local stashId = string.format("businesses_pickup_%s", pickup.id)
        exports.ox_inventory:RegisterStash(
          stashId,
          string.format("%s Pickup #%s", v.Name, num),
          10,
          10000,
          pickup.id
        )

        pickup.data = pickup.data or {}
        pickup.data.inventory = "stash"
        pickup.data.inventoryId = stashId

        exports['pulsar-core']:LoggerTrace("Businesses",
          string.format("Registered Pickup ^3%s^7 for Business ^3%s^7", pickup.id, v.Name))

        GlobalState[string.format("Businesses:Pickup:%s", pickup.id)] = pickup
      end
    end
  end
end
