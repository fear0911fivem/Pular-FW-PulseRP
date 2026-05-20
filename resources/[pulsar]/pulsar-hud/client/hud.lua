local _toggled = false
local _paused = false
local _vehToggled = false
local _overlayToggled = false
local _statuses = {}
local _statusCount = 0

local _idsCd = false
local _zoomLevel = GetResourceKvpInt("zoomLevel") or 3
local MINIMAP_Y_OFFSET = -0.0445
local MINIMAP_MASK_Y_OFFSET = 0.002
local MINIMAP_BLUR_Y_OFFSET = -0.018
local UNARMED_WEAPON = GetHashKey("WEAPON_UNARMED")
local PISTOL_WEAPON_GROUP = GetHashKey("GROUP_PISTOL")
local _lastAmmoVisible = nil
local _lastAmmoType = nil
local _lastAmmoMagazine = nil
local _lastAmmoTotal = nil
local _lastAmmoGrayOut = nil

local AIRCRAFT_CLASSES = {
	[15] = true,
	[16] = true,
}

local AIRCRAFT_GEAR_STATES = {
	[1] = true,
	[2] = true,
	[3] = false,
	[4] = false,
	[5] = false,
}

local _zoomLevels = {
	900,
	1000,
	1100,
	1200,
	1300,
	1400,
}

-- CreateThread(function()
-- 	Wait(4000)
-- 	if not GetResourceKvpInt("zoomLevel") then
-- 		SetResourceKvpInt("zoomLevel", 3)
-- 		_zoomLevel = 3
-- 		SetRadarZoom(_zoomLevels[3])
-- 	end

-- 	SetRadarZoom(_zoomLevels[_zoomLevel])
-- end)

function GetMinimapAnchor()
	local minimap = {}
	local resX, resY = GetActiveScreenResolution()
	local aspectRatio = GetAspectRatio()
	local scaleX = 1 / resX
	local scaleY = 1 / resY
	local minimapRawX, minimapRawY
	SetScriptGfxAlign(string.byte('L'), string.byte('B'))
	if IsBigmapActive() then
		minimapRawX, minimapRawY = GetScriptGfxPosition(-0.003975, 0.022 + (-0.460416666))
		minimap.width = scaleX * (resX / (2.52 * aspectRatio))
		minimap.height = scaleY * (resY / (2.3374))
	else
		minimapRawX, minimapRawY = GetScriptGfxPosition(-0.0045, MINIMAP_Y_OFFSET + (-0.188888))
		minimap.width = scaleX * (resX / (4 * aspectRatio))
		minimap.height = scaleY * (resY / (5.674))
	end
	ResetScriptGfxAlign()
	minimap.leftX = minimapRawX
	minimap.rightX = minimapRawX + minimap.width
	minimap.topY = minimapRawY
	minimap.bottomY = minimapRawY + minimap.height
	minimap.X = minimapRawX + (minimap.width / 2)
	minimap.Y = minimapRawY + (minimap.height / 2)
	return minimap
end

AddEventHandler('onClientResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		-- Hud.Minimap:Set()

		SetBlipAlpha(GetNorthRadarBlip(), 0.0)

		SetMinimapComponentPosition("minimap", "L", "B", -0.0045, MINIMAP_Y_OFFSET, 0.150, 0.18888)
		SetMinimapComponentPosition("minimap_mask", "L", "B", 0.020, MINIMAP_MASK_Y_OFFSET, 0.111, 0.159)
		SetMinimapComponentPosition("minimap_blur", "L", "B", -0.03, MINIMAP_BLUR_Y_OFFSET, 0.266, 0.237)

		SetRadarBigmapEnabled(true, false)
		Wait(0)
		SetRadarBigmapEnabled(false, false)
		DisplayRadar(0)

		SendNUIMessage({
			type = "UPDATE_MM_POS",
			data = { position = GetMinimapAnchor() },
		})

		exports["pulsar-kbs"]:Add("show_interaction", "F1", "keyboard", "Hud - Show Interaction Menu", function()
			if not IsPauseMenuActive() then
				exports['pulsar-hud']:InteractionShow()
			end
		end)

		-- exports["pulsar-kbs"]:Add("map_zoom_in", "PageUp", "keyboard", "Minimap - Zoom In", function()
		-- 	Hud.Minimap:In()
		-- end)

		-- exports["pulsar-kbs"]:Add("map_zoom_out", "PageDown", "keyboard", "Minimap - Zoom Out", function()
		-- 	Hud.Minimap:Out()
		-- end)

		exports["pulsar-kbs"]:Add("ui_toggle", "F11", "keyboard", "Hud - Toggle HUD", function()
			exports['pulsar-hud']:Toggle()
		end)

		exports["pulsar-kbs"]:Add("ids_toggle", "u", "keyboard", "Hud - Toggle IDs", function()
			if not _idsCd then
				exports['pulsar-hud']:IDToggle()
			end
		end)

		exports["pulsar-core"]:RegisterClientCallback("HUD:GetTargetInfront", function(data, cb)
			local originCoords = GetOffsetFromEntityInWorldCoords(LocalPlayer.state.ped, 0, 0.5, -0.5)
			local destinationCoords = GetOffsetFromEntityInWorldCoords(LocalPlayer.state.ped, 0, 1.0, -0.5)
			local castedRay = StartShapeTestSweptSphere(originCoords, destinationCoords, 1.0, 8, LocalPlayer.state.ped, 4)
			local _, hitting, endCoords, surfaceNormal, entity = GetShapeTestResult(castedRay)

			if hitting == 1 then
				local playerId = NetworkGetPlayerIndexFromPed(entity)
				if playerId ~= 0 then
					cb(GetPlayerServerId(playerId))
				else
					cb(nil)
				end
			else
				cb(nil)
			end
		end)

		exports["pulsar-core"]:RegisterClientCallback("HUD:PutOnBlindfold", function(data, cb)
			exports['pulsar-hud']:Progress({
				name = "blindfold_action",
				duration = 6000,
				label = data,
				useWhileDead = false,
				canCancel = true,
				disarm = false,
				controlDisables = {
					disableMovement = true,
					disableCarMovement = true,
					disableMouse = false,
					disableCombat = true,
				},
				animation = {
					animDict = "random@mugging4",
					anim = "struggle_loop_b_thief",
					flags = 49,
				},
			}, function(cancelled)
				cb(not cancelled)
			end)
		end)
	end
end)

function deepcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == "table" then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[deepcopy(orig_key)] = deepcopy(orig_value)
		end
		setmetatable(copy, deepcopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

function hasValue(tbl, value)
	for k, v in ipairs(tbl or {}) do
		if v == value or (type(v) == "table" and hasValue(v, value)) then
			return true
		end
	end
	return false
end

local function GetAmmoType(weapon)
	return GetWeapontypeGroup(weapon) == PISTOL_WEAPON_GROUP and "short" or "long"
end

local function SendAmmoData(data)
	if
		_lastAmmoVisible == data.visible
		and _lastAmmoType == data.ammoType
		and _lastAmmoMagazine == data.magazine
		and _lastAmmoTotal == data.total
		and _lastAmmoGrayOut == data.grayOut
	then
		return
	end

	_lastAmmoVisible = data.visible
	_lastAmmoType = data.ammoType
	_lastAmmoMagazine = data.magazine
	_lastAmmoTotal = data.total
	_lastAmmoGrayOut = data.grayOut

	SendNUIMessage({
		type = "UPDATE_AMMO",
		data = data,
	})
end

local function GetCurrentAmmoData()
	local ped = LocalPlayer.state.ped or PlayerPedId()

	if not ped or ped == 0 or not DoesEntityExist(ped) or LocalPlayer.state.isDead then
		return {
			visible = false,
		}
	end

	local weapon = GetSelectedPedWeapon(ped)

	if not weapon or weapon == 0 or weapon == UNARMED_WEAPON then
		return {
			visible = false,
		}
	end

	local hasClip, clipAmmo = GetAmmoInClip(ped, weapon)
	if type(hasClip) == "number" and clipAmmo == nil then
		clipAmmo = hasClip
		hasClip = true
	end

	local magazine = hasClip and (tonumber(clipAmmo) or 0) or 0
	local totalAmmo = GetAmmoInPedWeapon(ped, weapon)
	totalAmmo = tonumber(totalAmmo) or 0

	if not hasClip and totalAmmo <= 0 then
		return {
			visible = false,
		}
	end

	local reserve = math.max(totalAmmo - magazine, 0)

	return {
		visible = true,
		ammoType = GetAmmoType(weapon),
		magazine = magazine,
		total = reserve,
		grayOut = magazine <= 0,
	}
end

local function GetAircraftData(vehicle)
	if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
		return false
	end

	local rotation = GetEntityRotation(vehicle, 2)
	local gear = nil

	if DoesVehicleHaveLandingGear(vehicle) then
		local gearState = GetLandingGearState(vehicle)
		gear = AIRCRAFT_GEAR_STATES[gearState]

		if gear == nil then
			gear = false
		end
	end

	return {
		agl = math.ceil(GetEntityHeightAboveGround(vehicle)),
		altitude = math.ceil(GetEntityCoords(vehicle).z),
		airSpeed = math.ceil(GetEntitySpeed(vehicle) * 2.237),
		pitch = rotation.x,
		roll = -rotation.y,
		gear = gear,
	}
end

CreateThread(function()
	while true do
		if not _paused and not IsPauseMenuActive() then
			local ammoData = GetCurrentAmmoData()
			SendAmmoData(ammoData)
			Wait(ammoData.visible and 25 or 200)
		else
			SendAmmoData({
				visible = false,
			})
			Wait(300)
		end
	end
end)

CreateThread(function()
	while true do
		HideHudComponentThisFrame(2)

		if DisplayAmmoThisFrame then
			DisplayAmmoThisFrame(false)
		end

		Wait(0)
	end
end)

exports("IsDisabled", function()
	return (
		LocalPlayer.state.isDead
		or LocalPlayer.state.isCuffed
		or LocalPlayer.state.doingAction
		or LocalPlayer.state.inventoryOpen
		or LocalPlayer.state.phoneOpen
		or LocalPlayer.state.crafting
		or LocalPlayer.state.isHospitalized
		or LocalPlayer.state.myEscorter ~= nil
		or LocalPlayer.state.InventoryDisabled
	)
end)

exports("IsDisabledAllowDead", function()
	return (
		LocalPlayer.state.isCuffed
		or LocalPlayer.state.inventoryOpen
		or LocalPlayer.state.phoneOpen
		or LocalPlayer.state.crafting
		or LocalPlayer.state.isHospitalized
		or LocalPlayer.state.InventoryDisabled
	)
end)

exports("ForceHP", function()
	SendNUIMessage({
		type = "UPDATE_HP",
		data = {
			hp = (GetEntityHealth(LocalPlayer.state.ped) - 100),
			maxHp = (GetEntityMaxHealth(LocalPlayer.state.ped) - 100),
			armor = GetPedArmour(LocalPlayer.state.ped),
		},
	})
end)

exports("Show", function()
	if _toggled then
		return
	end

	local fuel = nil
	if GLOBAL_VEH ~= nil and DoesEntityExist(GLOBAL_VEH) then
		local vehState = Entity(GLOBAL_VEH).state
		fuel = vehState.Fuel
	end

	local ped = PlayerPedId()
	SendNUIMessage({
		type = "SHOW_HUD",
		data = {
			hp = (GetEntityHealth(ped) - 100),
			maxHp = (GetEntityMaxHealth(ped) - 100),
			armor = GetPedArmour(ped),
			fuel = fuel,
		},
	})
	_toggled = true
	StartThreads()

	if GLOBAL_VEH ~= nil then
		exports['pulsar-hud']:VehicleShow()
	end
end)

exports("Hide", function()
	if not _toggled then
		return
	end

	SendNUIMessage({
		type = "HIDE_HUD",
	})
	_toggled = false

	if not exports['pulsar-phone']:IsOpen() then
		DisplayRadar(false)
	end
	exports['pulsar-hud']:VehicleHide()
end)

exports("Toggle", function()
	SendNUIMessage({
		type = "TOGGLE_HUD",
	})
	_toggled = not _toggled
	if _toggled then
		StartThreads()

		if GLOBAL_VEH ~= nil then
			exports['pulsar-hud']:VehicleShow()
		else
			exports['pulsar-hud']:VehicleHide()
		end
	else
		if not exports['pulsar-phone']:IsOpen() and not hasValue(LocalPlayer.state.Character:GetData("States"), "GPS") then
			DisplayRadar(false)
		end
		exports['pulsar-hud']:VehicleHide()
	end
end)

exports("IsShowing", function()
	return _toggled
end)

exports("ShiftLocation", function(status)
	SendNUIMessage({
		type = "SHIFT_LOCATION",
		data = { shift = status, position = GetMinimapAnchor() },
	})
end)

exports("OverlayShow", function(data)
	if _overlayToggled then
		return
	end

	SendNUIMessage({
		type = "SHOW_OVERLAY",
		data = { data },
	})
	_overlayToggled = true
end)

exports("OverlayHide", function(data)
	if not _overlayToggled then
		return
	end

	SendNUIMessage({
		type = "HIDE_OVERLAY",
	})
	_overlayToggled = false
end)

exports("VehicleShow", function()
	if _vehToggled then
		return
	end

	SendNUIMessage({
		type = "SHOW_VEHICLE",
		data = {
			position = GetMinimapAnchor()
		}
	})
	_vehToggled = true
	StartVehicleThreads()
end)

exports("VehicleHide", function()
	if not _vehToggled then
		return
	end

	SendNUIMessage({
		type = "HIDE_VEHICLE",
	})
	_vehToggled = false
end)

exports("VehicleToggle", function()
	SendNUIMessage({
		type = "TOGGLE_VEHICLE",
	})
	_vehToggled = not _vehToggled
	if _vehToggled then
		StartVehicleThreads()
	end
end)

exports("RegisterStatus", function(name, current, max, icon, color, flash, update, options)
	local data = {
		name = name,
		max = max,
		value = current,
		icon = icon,
		color = color,
		flash = flash,
		options = options,
	}

	if update then
		SendNUIMessage({
			type = "UPDATE_STATUS",
			data = { status = data },
		})
	else
		SendNUIMessage({
			type = "REGISTER_STATUS",
			data = { status = data },
		})
		_statusCount = _statusCount + 1
	end

	_statuses[name] = data
end)

exports("ResetStatus", function()
	SendNUIMessage({
		type = "RESET_STATUSES",
	})
end)

exports("IDToggle", function()
	if not _showingIds then
		if not _idsCd then
			ShowIds()
			_idsCd = true
			SetTimeout(6000, function()
				exports['pulsar-hud']:IDToggle()
			end)
		end
	else
		_showingIds = false
		SetTimeout(10000, function()
			_idsCd = false
		end)
	end
end)

exports("Dead", function(state)
	SendNUIMessage({
		type = "SET_DEAD",
		data = {
			state = state,
		},
	})
end)

exports("GemTableOpen", function(quality)
	SendNUIMessage({
		type = "SHOW_GEM_TABLE",
		data = {
			info = quality
		}
	})
end)

exports("GemTableClose", function()
	SendNUIMessage({
		type = "CLOSE_GEM_TABLE",
		data = {},
	})
end)

exports("MethOpen", function(config)
	SetNuiFocus(true, true)
	SetNuiFocusKeepInput(false)
	SendNUIMessage({
		type = "OPEN_METH",
		data = {
			config = config,
		}
	})
end)

exports("MethClose", function()
	SetNuiFocus(false, false)
	SetNuiFocusKeepInput(false)
	SendNUIMessage({
		type = "CLOSE_METH",
		data = {},
	})
end)

exports("DeathTextsShow", function(type, deathTime, timer, keyOverride)
	SendNUIMessage({
		type = "DO_DEATH_TEXT",
		data = {
			key = exports["pulsar-kbs"]:GetKey(keyOverride or "secondary_action") or 'Unknown',
			f1Key = exports["pulsar-kbs"]:GetKey(keyOverride or "show_interaction") or 'Unknown',
			type = type,
			deathTime = deathTime,
			timer = timer,
			medicalPrice = 1500 -- (not GlobalState["Duty:ems"] or GlobalState["Duty:ems"] == 0) and 150 or 5000
		},
	})
end)

exports("DeathTextsRelease", function()
	SendNUIMessage({
		type = "DO_DEATH_RELEASING",
		data = {},
	})
end)

exports("DeathTextsHide", function()
	SendNUIMessage({
		type = "HIDE_DEATH_TEXT",
		data = {},
	})
end)

exports("FlashbangDo", function(duration, strength)
	SendNUIMessage({
		type = "SET_FLASHBANGED",
		data = {
			duration = duration,
			strength = strength,
		}
	})
end)

exports("FlashbangEnd", function()
	SendNUIMessage({
		type = "CLEAR_FLASHBANGED",
	})
end)

exports("UpdateVoip", function(level, talking, iconOverride)
	SendNUIMessage({
		type = "SET_VOIP_LEVEL",
		data = {
			level = level,
			talking = talking,
			icon = iconOverride,
		}
	})
end)

exports("NOS", function(level)
	SendNUIMessage({
		type = "UPDATE_NOS",
		data = {
			nos = level,
		}
	})
end)

AddEventHandler("Characters:Client:Updated", function(key)
	if key == "States" then
		if not IsPedInAnyVehicle(PlayerPedId(), true) then
			DisplayRadar(
				LocalPlayer.state.phoneOpen or hasValue(LocalPlayer.state.Character:GetData("States"), "GPS")
			)
			exports['pulsar-hud']:ShiftLocation(
				LocalPlayer.state.phoneOpen or hasValue(LocalPlayer.state.Character:GetData("States"), "GPS")
			)
		end
	end
end)

function GetLocation()
	local pos = GetEntityCoords(LocalPlayer.state.ped)

	if LocalPlayer.state.tpLocation then
		pos = vector3(
			LocalPlayer.state.tpLocation.x,
			LocalPlayer.state.tpLocation.y,
			LocalPlayer.state.tpLocation.z
		)
	end

	local direction = GetDirection(GetEntityHeading(LocalPlayer.state.ped))
	local var1, var2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
	local area = GetLabelText(GetNameOfZone(pos.x, pos.y, pos.z))

	return {
		main = GetStreetNameFromHashKey(var1),
		cross = GetStreetNameFromHashKey(var2),
		area = area,
		direction = direction,
	}
end

function GetDirection(heading)
	if (heading >= 0 and heading < 45) or (heading >= 315 and heading < 360) then
		return "N"
	elseif heading >= 45 and heading < 135 then
		return "W"
	elseif heading >= 135 and heading < 225 then
		return "S"
	elseif heading >= 225 and heading < 315 then
		return "E"
	end
end

function DrawText3D(position, text, r, g, b)
	local onScreen, _x, _y = World3dToScreen2d(position.x, position.y, position.z + 1)
	local dist = #(GetGameplayCamCoords() - position)

	local scale = (1 / dist) * 2
	local fov = (1 / GetGameplayCamFov()) * 100
	local scale = scale * fov

	if onScreen then
		if not useCustomScale then
			SetTextScale(0.0 * scale, 0.55 * scale)
		else
			SetTextScale(0.0 * scale, customScale)
		end
		SetTextFont(0)
		SetTextProportional(1)
		SetTextColour(r, g, b, 255)
		SetTextDropshadow(0, 0, 0, 0, 255)
		SetTextEdge(2, 0, 0, 0, 150)
		SetTextDropShadow()
		SetTextOutline()
		SetTextEntry("STRING")
		SetTextCentre(1)
		AddTextComponentString(text)
		DrawText(_x, _y)
	end
end

_showingIds = false
function ShowIds()
	_showingIds = true
	local nearPlayers = {}

	local showInvisible = LocalPlayer.state.isDev

	CreateThread(function()
		while _showingIds do
			for _, data in ipairs(nearPlayers) do
				local targetPed = GetPlayerPed(data.id)
				if data.SID ~= nil and (IsEntityVisible(targetPed) or showInvisible) then
					DrawText3D(GetPedBoneCoords(targetPed, 0), data.SID, 255, 255, 255)
				end
			end
			Wait(0)
		end
	end)

	CreateThread(function()
		while _showingIds do
			nearPlayers = {}
			local playerCoords = GetEntityCoords(LocalPlayer.state.ped)

			if exports['pulsar-admin']:NoClipIsActive() then
				playerCoords = exports['pulsar-admin']:NoClipGetPos()
			end

			for _, id in ipairs(GetActivePlayers()) do
				local targetPed = GetPlayerPed(id)
				if DoesEntityExist(targetPed) then
					local source = GetPlayerServerId(id)
					local distance = #(
						vector3(playerCoords.x, playerCoords.y, playerCoords.z)
						- GetEntityCoords(targetPed)
					)
					if distance <= 25 and GlobalState[string.format("SID:%s", source)] ~= nil then
						table.insert(nearPlayers, {
							id = id,
							SID = GlobalState[string.format("SID:%s", source)],
							source = source,
							distance = distance,
						})
					end
				end
			end
			Wait(2000)
		end
	end)
end

function StartThreads()
	CreateThread(function()
		while _toggled do
			if IsPauseMenuActive() and not _paused then
				_paused = true

				SendNUIMessage({
					type = "TOGGLE_HUD",
				})

				if _vehToggled then
					SendNUIMessage({
						type = "TOGGLE_VEHICLE",
					})
				end
			end

			if not _paused then
				SendNUIMessage({
					type = "UPDATE_LOCATION",
					data = { location = GetLocation() },
				})
				Wait(200)
				SendNUIMessage({
					type = "UPDATE_HP",
					data = {
						hp = (GetEntityHealth(LocalPlayer.state.ped) - 100),
						maxHp = (GetEntityMaxHealth(LocalPlayer.state.ped) - 100),
						armor = GetPedArmour(LocalPlayer.state.ped),
					},
				})
				Wait(200)
			else
				if not IsPauseMenuActive() then
					SendNUIMessage({
						type = "TOGGLE_HUD",
					})

					if _vehToggled then
						SendNUIMessage({
							type = "TOGGLE_VEHICLE",
						})
					end
					_paused = false
				end
				Wait(400)
			end
		end
	end)
end

function StartVehicleThreads()
	if not _toggled then
		return
	end

	local class = GetVehicleClass(GLOBAL_VEH)

	if class == 8 or class == 13 or class == 14 or class == 15 or class == 16 then
		SendNUIMessage({
			type = "HIDE_SEATBELT",
		})
	else
		SendNUIMessage({
			type = "SHOW_SEATBELT",
		})
	end

	CreateThread(function()
		DisplayRadar(true)
		while _vehToggled do
			local speed = math.ceil(GetEntitySpeed(GLOBAL_VEH) * 2.237)
			SendNUIMessage({
				type = "UPDATE_SPEED",
				data = { speed = speed },
			})
			Wait(100)
		end

		if LocalPlayer.state.Character ~= nil then
			DisplayRadar(hasValue(LocalPlayer.state.Character:GetData("States"), "GPS"))
		end
	end)

	CreateThread(function()
		while _vehToggled do
			if GLOBAL_VEH then
				SendNUIMessage({
					type = "UPDATE_RPM",
					data = { rpm = GetVehicleCurrentRpm(GLOBAL_VEH) },
				})
				Wait(10)
			end
		end
	end)

	if AIRCRAFT_CLASSES[class] then
		CreateThread(function()
			while _vehToggled do
				SendNUIMessage({
					type = "UPDATE_AIRCRAFT",
					data = {
						aircraftData = GetAircraftData(GLOBAL_VEH),
					},
				})

				Wait(0)
			end

			SendNUIMessage({
				type = "UPDATE_AIRCRAFT",
				data = {
					aircraftData = false,
				},
			})
		end)
	else
		SendNUIMessage({
			type = "UPDATE_AIRCRAFT",
			data = {
				aircraftData = false,
			},
		})
	end

	if GetPedInVehicleSeat(GLOBAL_VEH, -1) ~= LocalPlayer.state.ped then
		CreateThread(function()
			local lastIgnition = Entity(GLOBAL_VEH).state.VEH_IGNITION
			while _vehToggled do
				Wait(1000)

				if GLOBAL_VEH then
					local ignitionState = Entity(GLOBAL_VEH).state.VEH_IGNITION
					if lastIgnition ~= ignitionState then
						lastIgnition = ignitionState

						SendNUIMessage({
							type = "UPDATE_IGNITION",
							data = { ignition = ignitionState },
						})
					end
				end
			end
		end)
	end

	if class ~= 13 then
		CreateThread(function()
			while _vehToggled do
				local checkEngine = false

				if GLOBAL_VEH then
					local ent = Entity(GLOBAL_VEH)

					if class ~= 14 and class ~= 15 and class ~= 16 then
						local damageStuff = ent.state.DamagedParts or {}

						for k, v in pairs(damageStuff) do
							if type(v) == "number" and v < 25.0 then
								checkEngine = true
							end
						end
					end

					if GetVehicleEngineHealth(GLOBAL_VEH) <= 400.0 then
						checkEngine = true
					end
				end

				SendNUIMessage({
					type = "UPDATE_ENGINELIGHT",
					data = { checkEngine = checkEngine },
				})

				Wait(10000)
			end
		end)
	else
		SendNUIMessage({
			type = "UPDATE_ENGINELIGHT",
			data = { checkEngine = false },
		})
	end
end

-- CreateThread(function()
-- 	SetMapZoomDataLevel(0, 0.96, 0.9, 0.08, 0.0, 0.0) -- Level 0
-- 	SetMapZoomDataLevel(1, 1.6, 0.9, 0.08, 0.0, 0.0) -- Level 1
-- 	SetMapZoomDataLevel(2, 8.6, 0.9, 0.08, 0.0, 0.0) -- Level 2
-- 	SetMapZoomDataLevel(3, 12.3, 0.9, 0.08, 0.0, 0.0) -- Level 3
-- 	SetMapZoomDataLevel(4, 22.3, 0.9, 0.08, 0.0, 0.0) -- Level 4
-- end)

CreateThread(function()
	SetRadarZoom(1200)
end)

-- function DoRadarFix()
-- 	CreateThread(function()
-- 		Wait(300)
-- 		SetRadarZoom(_zoomLevels[6])
-- 		Wait(300)
-- 		SetRadarZoom(_zoomLevels[4])
-- 		Wait(300)
-- 		SetRadarZoom(_zoomLevels[1])
-- 		Wait(300)
-- 		SetRadarZoom(_zoomLevels[_zoomLevel])
-- 	end)
-- end

AddEventHandler("Keybinds:Client:KeyUp:cancel_action", function()
	if _overlayToggled then
		exports['pulsar-hud']:OverlayHide()
	end
end)
