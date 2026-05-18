local _inPoly = nil
local _polys = {}

AddEventHandler("Characters:Client:Spawn", function()
	FleecaThreads()
end)

AddEventHandler("Robbery:Client:Setup", function()
	_polys = {}

	while GlobalState["FleecaRobberies"] == nil do
		Wait(10)
	end

	for k, v in ipairs(GlobalState["FleecaRobberies"]) do
		local bankData = GlobalState[string.format("FleecaRobberies:%s", v)]
		exports['pulsar-polyzone']:CreateBox(bankData.id, bankData.coords, bankData.width, bankData.length,
			bankData.options)
		_polys[bankData.id] = true

		SetupFleecaVaults(bankData)

		if bankData.reset ~= nil then
			exports.ox_target:addBoxZone({
				id = string.format("fleeca-%s-reset", bankData.id),
				coords = bankData.reset.coords,
				size = vector3(bankData.reset.length, bankData.reset.width, 2.0),
				rotation = bankData.reset.options.heading or 0,
				debug = false,
				minZ = bankData.reset.options.minZ,
				maxZ = bankData.reset.options.maxZ,
				options = {
					{
						icon = "fas fa-lock",
						label = "Secure Bank",
						groups = { "police" },
						bankId = bankData.id,
						onSelect = function(data)
							TriggerEvent("Robbery:Client:Fleeca:StartSecuring", data.bankId)
						end,
						canInteract = function()
							local fleeca = LocalPlayer.state.fleeca
							local vaultDoor = GlobalState[string.format("Fleeca:%s:VaultDoor", fleeca)]
							return (
								(
									vaultDoor ~= nil
									and (vaultDoor.state == 2 or vaultDoor.state == 3)
								)
								or not exports['ox_doorlock']:IsLocked(string.format("%s_gate", fleeca))
							)
						end,
					},
				}
			})
		end
	end

	exports["pulsar-core"]:RegisterClientCallback("Robbery:Fleeca:Keypad:Vault", function(data, cb)
		exports['pulsar-games']:MinigamePlayKeypad(data, 5, 10000, false, {
			onSuccess = function(data)
				cb(true, data)
			end,
			onFail = function(data)
				cb(false, data)
			end,
		}, {
			useWhileDead = false,
			vehicle = false,
			controlDisables = {
				disableMovement = true,
				disableCarMovement = true,
				disableMouse = false,
				disableCombat = true,
			},
			animation = {
				animDict = "amb@prop_human_atm@male@idle_a",
				anim = "idle_b",
				flags = 49,
			},
		})
	end)
end)

AddEventHandler("Polyzone:Enter", function(id, testedPoint, insideZones, data)
	if _polys[id] and GlobalState[id] == nil and GlobalState[string.format("FleecaRobberies:%s", id)] ~= nil then
		_inPoly = id
		LocalPlayer.state:set("fleeca", id, true)
	end
end)

AddEventHandler("Polyzone:Exit", function(id, testedPoint, insideZones, data)
	if _polys[id] then
		_inPoly = nil
		if LocalPlayer.state.fleeca ~= nil then
			LocalPlayer.state:set("fleeca", nil, true)
		end
	end
end)

RegisterNetEvent("Robbery:Client:Fleeca:OpenVaultDoor", function(fleecaId)
	if GlobalState[string.format("FleecaRobberies:%s", fleecaId)] ~= nil then
		local myCoords = GetEntityCoords(LocalPlayer.state.ped)
		if #(myCoords - GlobalState[string.format("FleecaRobberies:%s", fleecaId)].coords) <= 100 then
			OpenDoor(
				GlobalState[string.format("FleecaRobberies:%s", fleecaId)].points.laptopLoc.coords,
				GlobalState[string.format("FleecaRobberies:%s", fleecaId)].doors.vaultDoor
			)
		end
	end
end)

RegisterNetEvent("Robbery:Client:Fleeca:CloseVaultDoor", function(fleecaId)
	if GlobalState[string.format("FleecaRobberies:%s", fleecaId)] ~= nil then
		local myCoords = GetEntityCoords(LocalPlayer.state.ped)
		if #(myCoords - GlobalState[string.format("FleecaRobberies:%s", fleecaId)].coords) <= 100 then
			CloseDoor(
				GlobalState[string.format("FleecaRobberies:%s", fleecaId)].points.laptopLoc.coords,
				GlobalState[string.format("FleecaRobberies:%s", fleecaId)].doors.vaultDoor
			)
		end
	end
end)

AddEventHandler("Robbery:Client:Fleeca:StartSecuring", function(entity, data)
	exports['pulsar-hud']:Progress({
		name = "secure_fleeca",
		duration = 30000,
		label = "Securing",
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
			anim = "cop3",
		},
	}, function(status)
		if not status then
			exports["pulsar-core"]:ServerCallback("Robbery:Fleeca:SecureBank", {})
		end
	end)
end)

AddEventHandler("Robbery:Client:Fleeca:Drill", function(entity, data)
	exports["pulsar-core"]:ServerCallback("Robbery:Fleeca:Drill", data, function() end)
end)

RegisterNetEvent("Robbery:Client:Fleeca:LootSuccess")
AddEventHandler("Robbery:Client:Fleeca:LootSuccess", function()
	loadAnimDict("pickup_object")
	TaskPlayAnim(LocalPlayer.state.ped, "pickup_object", "pickup_low", 8.0, 1.0, 2000, 48, 0, false, false, false)
end)

function OpenDoor(checkOrigin, door)
	local obj =
		GetClosestObjectOfType(checkOrigin[1], checkOrigin[2], checkOrigin[3], 25.0, door.object, false, false, false)

	if obj ~= 0 and tonumber(string.format("%.3f", GetEntityHeading(obj))) == door.originalHeading then
		local count = 0
		repeat
			SetEntityHeading(obj, GetEntityHeading(obj) + door.step)
			count = count + 1
			Wait(10)
		until count == 150
	end
end

function CloseDoor(checkOrigin, door)
	local obj =
		GetClosestObjectOfType(checkOrigin[1], checkOrigin[2], checkOrigin[3], 25.0, door.object, false, false, false)

	if obj ~= 0 and tonumber(string.format("%.3f", GetEntityHeading(obj))) ~= door.originalHeading then
		local count = 0
		repeat
			SetEntityHeading(obj, GetEntityHeading(obj) - door.step)
			count = count + 1
			Wait(10)
		until count == 150
	end
end

function SetupFleecaVaults(bankData)
	for k, v in ipairs(bankData.loots) do
		exports.ox_target:addBoxZone({
			id = string.format("fleeca-%s", v.options.name),
			coords = v.coords,
			size = vector3(v.width, v.length, 2.0),
			rotation = v.options.heading or 0,
			debug = false,
			minZ = v.options.minZ,
			maxZ = v.options.maxZ,
			options = {
				{
					icon = "fas fa-drill",
					label = "Use Drill",
					item = "drill",
					bankId = bankData.id,
					lootName = v.options.name,
					lootIndex = k,
					onSelect = function(data)
						TriggerEvent("Robbery:Client:Fleeca:Drill", data.bankId, { id = data.lootName, index = data.lootIndex })
					end,
					canInteract = function()
						local fleeca = LocalPlayer.state.fleeca
						local vaultDoor = GlobalState[string.format("Fleeca:%s:VaultDoor", fleeca)]
						local lootKey = string.format("Fleeca:%s:Loot:%s", fleeca, v.options.name)
						return vaultDoor ~= nil
							and vaultDoor.state == 3
							and (GlobalState[lootKey] == nil or GetCloudTimeAsInt() >= GlobalState[lootKey])
							and (k <= 2 or not exports['ox_doorlock']:IsLocked(string.format("%s_gate", fleeca)))
					end,
				},
			}
		})
	end
end
