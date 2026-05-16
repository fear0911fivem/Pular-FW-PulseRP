_pickups = {}
_warmers = {}
_fridges = {}

local function RegisterRestaurantBenches()
	while GetResourceState('ox_inventory') ~= 'started' do
		Wait(500)
	end
	for k = 1, #Config.Restaurants do
		local v = Config.Restaurants[k]
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
					string.format('restaurant-%s-%s', k, benchId),
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
	CreateThread(RegisterRestaurantBenches)

	for k = 1, #Config.Restaurants do
		local v = Config.Restaurants[k]
		exports['pulsar-core']:LoggerTrace("Restaurant", string.format("Registering Restaurant ^3%s^7", v.Name))

		if v.Pickups then
			for num = 1, #v.Pickups do
				local pickup = v.Pickups[num]
				table.insert(_pickups, pickup.id)
				pickup.num = num
				pickup.job = v.Job
				pickup.jobName = v.Name

				local stashId = string.format("restaurant_pickup_%s", pickup.id)
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

				exports['pulsar-core']:LoggerTrace("Restaurant", string.format("Registered Pickup ^3%s^7 for Restaurant ^3%s^7", pickup.id, v.Name))

				GlobalState[string.format("Restaurant:Pickup:%s", pickup.id)] = pickup
			end
		end

		if v.Warmers then
			for i = 1, #v.Warmers do
				local warmer = v.Warmers[i]
				if warmer.restrict and warmer.restrict.jobs then
					for j = 1, #warmer.restrict.jobs do
						local jobId = warmer.restrict.jobs[j]
						if _warmers[jobId] == nil then
							_warmers[jobId] = {}
						end
						table.insert(_warmers[jobId], warmer.id)
					end
				end

				local stashId = string.format("restaurant_warmer_%s", warmer.id)
				exports.ox_inventory:RegisterStash(
					stashId,
					string.format("%s Warmer", v.Name),
					80,
					100000,
					warmer.id
				)

				warmer.data = warmer.data or {}
				warmer.data.inventory = "stash"
				warmer.data.inventoryId = stashId

				exports['pulsar-core']:LoggerTrace("Restaurant", string.format("Registered Warmer ^3%s^7 for Restaurant ^3%s^7", warmer.id, v.Name))

				GlobalState[string.format("Restaurant:Warmers:%s", warmer.id)] = warmer
			end
		end

		if v.Fridges then
			for i = 1, #v.Fridges do
				local fridge = v.Fridges[i]
				if fridge.restrict and fridge.restrict.jobs then
					for j = 1, #fridge.restrict.jobs do
						local jobId = fridge.restrict.jobs[j]
						if _fridges[jobId] == nil then
							_fridges[jobId] = {}
						end
						table.insert(_fridges[jobId], fridge.id)
					end
				end

				local stashId = string.format("restaurant_fridge_%s", fridge.id)
				exports.ox_inventory:RegisterStash(
					stashId,
					string.format("%s Fridge", v.Name),
					80,
					100000,
					fridge.id
				)

				fridge.data = fridge.data or {}
				fridge.data.inventory = "stash"
				fridge.data.inventoryId = stashId

				exports['pulsar-core']:LoggerTrace("Restaurant", string.format("Registered Fridge ^3%s^7 for Restaurant ^3%s^7", fridge.id, v.Name))

				GlobalState[string.format("Restaurant:Fridges:%s", fridge.id)] = fridge
			end
		end
	end
end
