local _inPoly = true

local _cabinets = {
	{
		coords = vector3(224.33, 373.39, 106.15),
		length = 1.3,
		width = 1.0,
		options = {
			heading = 341,
			--debugPoly = true,
			minZ = 105.15,
			maxZ = 107.75,
		},
	},
}

local _pdAlarm = vector3(-630.732, -237.111, 38.078)
local _officeHack = vector3(226.563, 370.663, 106.556)

local _weapons = {
	[GetHashKey("WEAPON_CROWBAR")] = true,
	[GetHashKey("WEAPON_PONY")] = true,
	[GetHashKey("WEAPON_HAMMER")] = true,
	[GetHashKey("WEAPON_BAT")] = true,
	[GetHashKey("WEAPON_DRBAT")] = true,
	[GetHashKey("WEAPON_SLEDGE")] = true,
	[GetHashKey("WEAPON_GOLFCLUB")] = true,
	[GetHashKey("WEAPON_STONE_HATCHET")] = true,
	[GetHashKey("WEAPON_WRENCH")] = true,
	[GetHashKey("WEAPON_SHOVEL")] = true,
}

AddEventHandler("Robbery:Client:Setup", function()
	exports['pulsar-polyzone']:CreatePoly("vangelico", {
		vector2(-627.94396972656, -240.6435546875),
		vector2(-636.67626953125, -229.46875),
		vector2(-620.25476074219, -220.87989807129),
		vector2(-612.01623535156, -234.92085266113),
	}, {
		minZ = 35.0,
		maxZ = 40.0,
		--debugPoly = true,
	})

	exports.ox_target:addBoxZone({
		id = "vangelico-pd",
		coords = vector3(-620.09, -223.81, 38.06),
		size = vector3(1.0, 1.0, 1.2),
		rotation = 35,
		debug = false,
		minZ = 37.91,
		maxZ = 39.11,
		options = {
			{
				icon = "fas fa-calculator",
				label = "Secure Store",
				event = "Robbery:Client:Vangelico:SecureStore",
				groups = { "police" },
				canInteract = function()
					return GlobalState["Vangelico:State"] == 1
				end,
			},
		}
	})

	while not GlobalState["VangelicoCases"] do
		Wait(10)
	end

	for k, v in ipairs(GlobalState["VangelicoCases"]) do
		local pId = string.format("Vangelico:Case:%s", k)
		exports.ox_target:addBoxZone({
			id = pId,
			coords = v.coords,
			size = vector3(v.length, v.width, 2.0),
			rotation = v.options.heading or 0,
			debug = false,
			minZ = v.options.minZ,
			maxZ = v.options.maxZ,
			options = {
				{
					icon = "fas fa-hammer",
					label = "Smash Case",
					event = "Robbery:Client:Vangelico:BreakCase",
					canInteract = function()
						return (
								(GlobalState["Duty:police"] or 0) >= GlobalState["VangelicoRequiredPd"]
								or GlobalState["Vangelico:InProgress"]
							)
							and not GlobalState["RobberiesDisabled"]
							and (not GlobalState["RestartLockdown"] or (GlobalState["RestartLockdown"] and GlobalState["Vangelico:InProgress"]))
							and
							(not GlobalState["AntiShitlord"] or GetCloudTimeAsInt() > GlobalState["AntiShitlord"] or GlobalState["Vangelico:InProgress"])
							and GlobalState["Vangelico:State"] ~= 2
							and (
								(not GlobalState[pId] or GlobalState[pId] < GetCloudTimeAsInt())
								and _weapons[GetSelectedPedWeapon(LocalPlayer.state.ped)]
							)
					end,
				},
			}
		})
	end

	-- for k, v in ipairs(_cabinets) do
	-- 	local pId = string.format("Vangelico:Cabinet:%s", k)
	-- 	exports.ox_target:addBoxZone({
	-- 		id = pId,
	-- 		coords = v.coords,
	-- 		size = vector3(v.length, v.width, 2.0),
	-- 		rotation = v.options.heading or 0,
	-- 		debug = false,
	-- 		minZ = v.options.minZ,
	-- 		maxZ = v.options.maxZ,
	-- 		options = {
	-- 			{
	-- 				icon = "cabinet-filing",
	-- 				label = "Search Filing Cabinet",
	-- 				event = "Robbery:Client:Vangelico:SearchCabinet",
	-- 				canInteract = function()
	-- 					return not GlobalState[pId] and _weapons[GetSelectedPedWeapon(LocalPlayer.state.ped)]
	-- 				end,
	-- 			},
	-- 		}
	-- 	})
	-- end
end)

AddEventHandler("Robbery:Client:Vangelico:SecureStore", function(data)
	exports['pulsar-hud']:Progress({
		name = "secure_vangelico",
		duration = 30000,
		label = "Securing",
		useWhileDead = false,
		canCancel = true,
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
			exports["pulsar-core"]:ServerCallback("Robbery:Vangelico:SecureStore")
		end
	end)
end)

AddEventHandler("Robbery:Client:Vangelico:DisableAlarm", function()
	exports['pulsar-hud']:Progress({
		name = "disable_vangelico_alarm",
		duration = 10000,
		label = "Disabling Alarm",
		useWhileDead = false,
		canCancel = true,
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
			exports["pulsar-core"]:ServerCallback("Robbery:Vangelico:DisableAlarm")
		end
	end)
end)

AddEventHandler("Polyzone:Enter", function(id, point, insideZones, data)
	if id == "vangelico" then
		local _keypadOptions = {
			{
				icon = "fas fa-bell",
				label = "Disable Alarm",
				event = "Robbery:Client:Vangelico:DisableAlarm",
				groups = { "police" },
				canInteract = function()
					local dist = #(
							vector3(LocalPlayer.state.myPos.x, LocalPlayer.state.myPos.y, LocalPlayer.state.myPos.z)
							- _pdAlarm
						)
					return dist <= 2.0 and GlobalState["Vangelico:Alarm"]
				end,
			},
			-- {
			-- 	icon = "fas fa-terminal",
			-- 	label = "Hack Keypad",
			-- 	event = "Robbery:Client:Vangelico:HackKeypad",
			-- 	item = "sequencer",
			-- 	canInteract = function()
			-- 		local dist = #(
			-- 				vector3(LocalPlayer.state.myPos.x, LocalPlayer.state.myPos.y, LocalPlayer.state.myPos.z)
			-- 				- _officeHack
			-- 			)
			-- 		return dist <= 2.0 and not GlobalState["Vangelico:Lockdown"]
			-- 	end,
			-- },
			-- {
			-- 	icon = "address-card",
			-- 	label = "Use Keycard",
			-- 	event = "Robbery:Client:Vangelico:UseKeycard",
			-- 	item = "xg_keycard",
			-- 	canInteract = function()
			-- 		local dist = #(
			-- 				vector3(LocalPlayer.state.myPos.x, LocalPlayer.state.myPos.y, LocalPlayer.state.myPos.z)
			-- 				- _officeHack
			-- 			)
			-- 		return dist <= 2.0 and not GlobalState["Vangelico:Lockdown"]
			-- 	end,
			-- },
		}
		if #_keypadOptions > 0 then
			exports.ox_target:addModel(GetHashKey("hei_prop_hei_keypad_03"), _keypadOptions)
		end
	end
end)

AddEventHandler("Polyzone:Exit", function(id, point, insideZones, data)
	if id == "vangelico" then
		if exports.ox_target:zoneExists("hei_prop_hei_keypad_03") then
			exports.ox_target:removeZone("hei_prop_hei_keypad_03")
		end
	end
end)

function loadParticle()
	if not HasNamedPtfxAssetLoaded("scr_jewelheist") then
		RequestNamedPtfxAsset("scr_jewelheist")
	end
	while not HasNamedPtfxAssetLoaded("scr_jewelheist") do
		Wait(0)
	end
	SetPtfxAssetNextCall("scr_jewelheist")
end

function loadAnimation()
	loadAnimDict("missheist_jewel")
	TaskPlayAnim(PlayerPedId(), "missheist_jewel", "smash_case", 8.0, 1.0, -1, 2, 0, 0, 0, 0)
	Wait(2200)
end

AddEventHandler("Robbery:Client:Vangelico:BreakCase", function(data)
	local pId = string.format("Vangelico:Case:%s", data.index)
	if
		(not GlobalState[pId] or GlobalState[pId] < GetCloudTimeAsInt())
		and _weapons[GetSelectedPedWeapon(LocalPlayer.state.ped)]
	then
		loadParticle()
		TaskTurnPedToFaceCoord(LocalPlayer.state.ped, data.coords.x, data.coords.y, data.coords.z, 1.0)

		CreateThread(function()
			Wait(600)
			exports["pulsar-sounds"]:PlayLocation(data.coords, 10.0, "jewel_glass.ogg", 0.15)
			StartParticleFxLoopedAtCoord(
				"scr_jewel_cab_smash",
				data.coords.x,
				data.coords.y,
				data.coords.z,
				0.0,
				0.0,
				0.0,
				1.0,
				false,
				false,
				false,
				false
			)
		end)

		exports['pulsar-hud']:ProgressWithTickEvent({
			name = "vangelico_action",
			duration = (math.random(10) * 1000) + 30000,
			label = "Robbing",
			tickrate = 100,
			useWhileDead = false,
			canCancel = true,
			vehicle = false,
			disarm = false,
			ignoreModifier = true,
			controlDisables = {
				disableMovement = true,
				disableCarMovement = true,
				disableCombat = true,
			},
			animation = {
				animDict = "missheist_jewel",
				anim = "smash_case",
				flags = 17,
			},
		}, function()
			if
				(not GlobalState[pId] or GlobalState[pId] < GetCloudTimeAsInt())
				and _weapons[GetSelectedPedWeapon(LocalPlayer.state.ped)]
			then
				return
			end
			exports['pulsar-hud']:ProgressCancel()
		end, function(cancelled)
			if not cancelled then
				exports["pulsar-core"]:ServerCallback("Robbery:Vangelico:BreakCase", data.index)
			end
		end)
	end
end)
