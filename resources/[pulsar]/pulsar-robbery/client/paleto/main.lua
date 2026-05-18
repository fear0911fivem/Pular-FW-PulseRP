local _pb = RobberyConfig.paleto
local _sbChangeHandlers = {}
local _activePcTargets = {}

function PaletoNeedsReset()
	if _bankStates.paleto.workstation or _bankStates.paleto.vaultTerminal then
		return true
	end

	for k, v in ipairs(_pb.doorIds) do
		if not exports['ox_doorlock']:IsLocked(v) then
			return true
		end
	end

	for k, v in pairs(_bankStates.paleto.securityPower) do
		if v ~= nil then
			return true
		end
	end

	for k, v in pairs(_bankStates.paleto.officeHacks) do
		if v ~= nil then
			return true
		end
	end

	for k, v in pairs(_bankStates.paleto.drillPoints) do
		if v ~= nil then
			return true
		end
	end

	if IsPaletoPowerDisabled() then
		return true
	end

	return false
end

AddEventHandler("Robbery:Client:Setup", function()
	exports['pulsar-polyzone']:CreatePoly("bank_paleto", _pb.polyZone, {})

	exports['pulsar-polyzone']:CreateCircle("paleto_power", _pb.powerCircle.center, _pb.powerCircle.radius, _pb.powerCircle.options)

	exports['pulsar-polyzone']:CreateBox("paleto_hack_access", _pb.hackAccessBox.coords, _pb.hackAccessBox.length, _pb.hackAccessBox.width, _pb.hackAccessBox.options, {})

	for k, v in ipairs(_pb.killZones) do
		exports['pulsar-polyzone']:CreateBox(string.format("pb_killzone_%s", k), v.coords, v.length, v.width, v.options,
			v.data)
	end

	for k, v in ipairs(_pb.pcHackAreas) do
		exports['pulsar-polyzone']:CreateBox(
			string.format("paleto_hack_pc_%s", v.data.pcId),
			v.coords,
			v.length,
			v.width,
			v.options,
			v.data
		)
	end

	local pcPropModel = `prop_laptop_01a`
	RequestModel(pcPropModel)
	while not HasModelLoaded(pcPropModel) do Wait(100) end
	for k, v in ipairs(_pb.pcHackAreas) do
		local t = v.target
		local prop = CreateObject(pcPropModel, t.coords.x, t.coords.y, t.coords.z, false, false, false)
		SetEntityHeading(prop, t.options.heading or 0)
		PlaceObjectOnGroundProperly(prop)
		FreezeEntityPosition(prop, true)
	end
	SetModelAsNoLongerNeeded(pcPropModel)

	for k, v in ipairs(_pb.subStationZones) do
		exports['pulsar-polyzone']:CreateBox(
			string.format("pb_substation_%s", v.data.subStationId),
			v.coords,
			v.length,
			v.width,
			v.options,
			v.data
		)
	end

	exports.ox_target:addBoxZone({
		id = "paleto_secure",
		coords = _pb.targets.secure.coords,
		size = vector3(_pb.targets.secure.length, _pb.targets.secure.width, 2.0),
		rotation = _pb.targets.secure.options.heading,
		debug = false,
		minZ = _pb.targets.secure.options.minZ,
		maxZ = _pb.targets.secure.options.maxZ,
		options = {
			{
				icon = "fas fa-lock",
				label = "Secure Bank",
				event = "Robbery:Client:Paleto:StartSecuring",
				groups = { "police" },
				canInteract = PaletoNeedsReset,
			},
			{
				icon = "fas fa-bell",
				label = "Disable Alarm",
				event = "Robbery:Client:Paleto:DisableAlarm",
				groups = { "police" },
				canInteract = function()
					return _bankStates.paleto.fookinLasers
				end,
			},
		}
	})

	exports.ox_target:addBoxZone({
		id = "paleto_security",
		coords = _pb.targets.security.coords,
		size = vector3(_pb.targets.security.length, _pb.targets.security.width, 2.0),
		rotation = _pb.targets.security.options.heading,
		debug = false,
		minZ = _pb.targets.security.options.minZ,
		maxZ = _pb.targets.security.options.maxZ,
		options = {
			{
				icon = "fas fa-bell",
				label = "Access Door Controls",
				event = "Robbery:Client:Paleto:Doors",
				canInteract = function()
					return IsPaletoExploitInstalled() and
						not exports['ox_doorlock']:IsLocked("bank_savings_paleto_security")
				end,
			},
		}
	})

	exports.ox_target:addBoxZone({
		id = "paleto_hack_workstation",
		coords = _pb.targets.workstation.coords,
		size = vector3(_pb.targets.workstation.length, _pb.targets.workstation.width, 2.0),
		rotation = _pb.targets.workstation.options.heading,
		debug = false,
		minZ = _pb.targets.workstation.options.minZ,
		maxZ = _pb.targets.workstation.options.maxZ,
		options = {
			{
				icon = "fas fa-network-wired",
				label = "Breach Network",
				items = {
					{
						item = "adv_electronics_kit",
						count = 1,
					},
					{
						item = "vpn",
						count = 1,
					},
				},
				event = "Robbery:Client:Paleto:Workstation",
				canInteract = function()
					return IsPaletoExploitInstalled()
						and LocalPlayer.state.inPaletoWSPoint
						and (not _bankStates.paleto.workstation or GetCloudTimeAsInt() > _bankStates.paleto.workstation)
				end,
			},
		}
	})

	for k, v in ipairs(_pb.officeHacks) do
		exports.ox_target:addBoxZone({
			id = string.format("paleto_officehack_%s", k),
			coords = v.coords,
			size = vector3(v.length, v.width, 2.0),
			rotation = v.options.heading or 0,
			debug = false,
			minZ = v.options.minZ,
			maxZ = v.options.maxZ,
			options = {
				{
					icon = "fas fa-network-wired",
					label = "Upload Exploit",
					items = {
						{
							item = "adv_electronics_kit",
							count = 1,
						},
						{
							item = "vpn",
							count = 1,
						},
					},
					officeId = v.data.officeId,
					onSelect = function()
						TriggerEvent("Robbery:Client:Paleto:OfficeHack", v.data)
					end,
					canInteract = function()
						return IsPaletoExploitInstalled()
							and (
								not _bankStates.paleto.officeHacks[v.data.officeId]
								or GetCloudTimeAsInt() > _bankStates.paleto.officeHacks[v.data.officeId]
							)
					end,
				},
			}
		})
	end

	for k, v in ipairs(_pb.powerHacks) do
		exports.ox_target:addBoxZone({
			id = string.format("paleto_electricbox_%s", k),
			coords = v.coords,
			size = vector3(v.length, v.width, 2.0),
			rotation = v.options.heading or 0,
			debug = false,
			minZ = v.options.minZ,
			maxZ = v.options.maxZ,
			options = {
				{
					icon = "fas fa-terminal",
					label = "Hack Power Interface",
					item = "adv_electronics_kit",
					boxId = v.data.boxId,
					onSelect = function()
						TriggerEvent("Robbery:Client:Paleto:ElectricBox:Hack", v.data)
					end,
					canInteract = function()
						return not _bankStates.paleto.electricalBoxes[v.data.boxId]
							or GetCloudTimeAsInt() > _bankStates.paleto.electricalBoxes[v.data.boxId]
					end,
				},
			}
		})
	end

	for k, v in ipairs(_pb.lasers) do
		exports['pulsar-lasers']:Create(
			string.format("paleto_lasers_%s", k),
			v.origins,
			v.targets,
			v.options,
			false,
			function(playerBeingHit, hitPos)
				if playerBeingHit then
					exports["pulsar-core"]:ServerCallback("Robbery:Paleto:TriggeredLaser")
				end
			end
		)
	end

	for k, v in ipairs(_pb.drillPoints) do
		exports.ox_target:addBoxZone({
			id = string.format("paleto_drillpoint_%s", v.data.drillId),
			coords = v.coords,
			size = vector3(v.length, v.width, 2.0),
			rotation = v.options.heading or 0,
			debug = false,
			minZ = v.options.minZ,
			maxZ = v.options.maxZ,
			options = {
				{
					icon = "fas fa-drill",
					label = "Use Drill",
					item = "drill",
					drillId = v.data.drillId,
					onSelect = function()
						TriggerEvent("Robbery:Client:Paleto:Drill", v.data)
					end,
					canInteract = function()
						return IsPaletoExploitInstalled()
							and not exports['ox_doorlock']:IsLocked("bank_savings_paleto_vault")
							and (
								not _bankStates.paleto.drillPoints[v.data.drillId]
								or GetCloudTimeAsInt() > _bankStates.paleto.drillPoints[v.data.drillId]
							)
					end,
				},
			}
		})
	end

	exports.ox_target:addBoxZone({
		id = "paleto_office_safe",
		coords = _pb.targets.officeSafe.coords,
		size = vector3(_pb.targets.officeSafe.length, _pb.targets.officeSafe.width, 2.0),
		rotation = _pb.targets.officeSafe.options.heading,
		debug = false,
		minZ = _pb.targets.officeSafe.options.minZ,
		maxZ = _pb.targets.officeSafe.options.maxZ,
		options = {
			{
				icon = "fas fa-unlock",
				label = "Crack Safe",
				event = "Robbery:Client:Paleto:Safe",
				item = "paleto_access_codes",
				canInteract = function()
					return IsPaletoExploitInstalled()
						and not exports['ox_doorlock']:IsLocked("bank_savings_paleto_office_3")
						and (not _bankStates.paleto.officeSafe or GetCloudTimeAsInt() > _bankStates.paleto.officeSafe)
				end,
			},
		}
	})

	for k, v in ipairs(_pb.officeSearch) do
		exports.ox_target:addBoxZone({
			id = string.format("paleto_searchpoint_%s", v.data.searchId),
			coords = v.coords,
			size = vector3(v.length, v.width, 2.0),
			rotation = v.options.heading or 0,
			debug = false,
			minZ = v.options.minZ,
			maxZ = v.options.maxZ,
			options = {
				{
					icon = "fas fa-magnifying-glass",
					label = "Search",
					door = v.data.door,
					searchId = v.data.searchId,
					onSelect = function()
						TriggerEvent("Robbery:Client:Paleto:Search", v.data)
					end,
					canInteract = function()
						return IsPaletoExploitInstalled()
							and not exports['ox_doorlock']:IsLocked(v.data.door)
							and (
								not _bankStates.paleto.officeSearch[v.data.searchId]
								or GetCloudTimeAsInt() > _bankStates.paleto.officeSearch[v.data.searchId]
							)
					end,
				},
			}
		})
	end
end)

AddEventHandler("Polyzone:Enter", function(id, testedPoint, insideZones, data)
	if id == "bank_paleto" then
		LocalPlayer.state:set("inPaletoBank", true, true)

		local powerDisabled = IsPaletoPowerDisabled()
		for k, v in ipairs(_pb.lasers) do
			exports['pulsar-lasers']:SetActive(string.format("paleto_lasers_%s", k), not powerDisabled)
			exports['pulsar-lasers']:SetVisible(string.format("paleto_lasers_%s", k), not powerDisabled)
		end
	elseif id == "paleto_hack_access" and not exports['ox_doorlock']:IsLocked("pulsar_bank_savings_paleto_gate") then
		LocalPlayer.state:set("inPaletoWSPoint", true, true)
	elseif data and data.subStationId ~= nil then
		LocalPlayer.state:set("inSubStation", data.subStationId, true)
	elseif data and data.pcId ~= nil then
		local pcArea = _pb.pcHackAreas[data.pcId]
		local t = pcArea.target
		_activePcTargets[data.pcId] = true
		exports.ox_target:addBoxZone({
			id = string.format("paleto_hack_pc_target_%s", data.pcId),
			coords = t.coords,
			size = vector3(t.length, t.width, 2.0),
			rotation = t.options.heading or 0,
			debug = false,
			minZ = t.options.minZ,
			maxZ = t.options.maxZ,
			options = {
				{
					label = "Upload Exploit",
					icon = "fas fa-terminal",
					pcId = data.pcId,
					onSelect = function()
						TriggerEvent("Robbery:Client:Paleto:Upload", data)
					end,
					item = "adv_electronics_kit",
					canInteract = function()
						return (not GlobalState["Paleto:Secured"] or GetCloudTimeAsInt() > GlobalState["Paleto:Secured"])
							and (
								not _bankStates.paleto.exploits[data.pcId]
								or GetCloudTimeAsInt() > _bankStates.paleto.exploits[data.pcId]
							)
					end,
				},
			},
		})
	elseif id == "paleto_power" then
		LocalPlayer.state:set("inPaletoPower", true, true)
	end
end)

AddEventHandler("Polyzone:Exit", function(id, testedPoint, insideZones, data)
	if id == "bank_paleto" then
		if LocalPlayer.state.inPaletoBank then
			LocalPlayer.state:set("inPaletoBank", false, true)
		end
		for k, v in ipairs(_pb.lasers) do
			exports['pulsar-lasers']:SetActive(string.format("paleto_lasers_%s", k), false)
			exports['pulsar-lasers']:SetVisible(string.format("paleto_lasers_%s", k), false)
		end
	elseif id == "paleto_hack_access" then
		if LocalPlayer.state.inPaletoWSPoint then
			LocalPlayer.state:set("inPaletoWSPoint", false, true)
		end
	elseif data and data.subStationId ~= nil then
		if LocalPlayer.state.inSubStation then
			LocalPlayer.state:set("inSubStation", false, true)
		end
	elseif data and data.pcId ~= nil then
		if _activePcTargets[data.pcId] then
			_activePcTargets[data.pcId] = nil
			exports.ox_target:removeZone(string.format("paleto_hack_pc_target_%s", data.pcId))
		end
	elseif id == "paleto_power" then
		LocalPlayer.state:set("inPaletoPower", false, true)
	end
end)

AddEventHandler("Robbery:Client:Update:paleto", function()
	if LocalPlayer.state.inPaletoBank then
		local powerDisabled = IsPaletoPowerDisabled()
		for k2, v2 in ipairs(_pb.lasers) do
			exports['pulsar-lasers']:SetActive(string.format("paleto_lasers_%s", k2), not powerDisabled)
			exports['pulsar-lasers']:SetVisible(string.format("paleto_lasers_%s", k2), not powerDisabled)
		end
	end
end)

AddEventHandler("Robbery:Client:Paleto:ElectricBox:Hack", function(data)
	exports["pulsar-core"]:ServerCallback("Robbery:Paleto:ElectricBox:Hack", data, function() end)
end)

AddEventHandler("Robbery:Client:Paleto:Upload", function(data)
	exports["pulsar-core"]:ServerCallback("Robbery:Paleto:PC:Hack", data, function() end)
end)

AddEventHandler("Robbery:Client:Paleto:Workstation", function(entity, data)
	exports["pulsar-core"]:ServerCallback("Robbery:Paleto:Workstation", data, function() end)
end)

AddEventHandler("Robbery:Client:Paleto:OfficeHack", function(data)
	exports["pulsar-core"]:ServerCallback("Robbery:Paleto:OfficeHack", data, function() end)
end)

AddEventHandler("Robbery:Client:Paleto:Drill", function(data)
	exports["pulsar-core"]:ServerCallback("Robbery:Paleto:Drill", data.drillId, function() end)
end)

AddEventHandler("Robbery:Client:Paleto:Search", function(data)
	exports["pulsar-core"]:ServerCallback("Robbery:Paleto:Search", data, function() end)
end)

AddEventHandler("Robbery:Client:Paleto:Safe", function(entity, data)
	exports["pulsar-core"]:ServerCallback("Robbery:Paleto:StartSafe", {}, function(s)
		if s then
			exports['pulsar-hud']:InputShow("Input Access Code", "Access Code", {
				{
					id = "code",
					type = "number",
					options = {
						inputProps = {
							maxLength = 4,
						},
					},
				},
			}, "Robbery:Client:Paleto:SafeInput", data)
		end
	end)
end)

AddEventHandler("Robbery:Client:Paleto:SafeInput", function(values, data)
	exports["pulsar-core"]:ServerCallback("Robbery:Paleto:Safe", {
		code = values.code,
		data = data,
	}, function() end)
end)

AddEventHandler("Input:Closed", function(event, data)
	if event == "Robbery:Client:Paleto:SafeInput" then
		exports["pulsar-core"]:ServerCallback("Robbery:Paleto:Safe", {
			code = false,
			data = data,
		}, function() end)
	end
end)

AddEventHandler("Robbery:Client:Paleto:VaultTerminal", function()
	exports['pulsar-hud']:Progress({
		name = "disable_vault_pc",
		duration = math.random(45, 60) * 1000,
		label = "Disabling",
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
			anim = "type",
		},
	}, function(status)
		if not status then
			exports["pulsar-core"]:ServerCallback("Robbery:Paleto:VaultTerminal", {})
		end
	end)
end)

AddEventHandler("Robbery:Client:Paleto:Door", function(data)
	if data.officeId ~= nil then
		exports['pulsar-hud']:InputShow("Input Access Code", "Access Code", {
			{
				id = "code",
				type = "number",
				options = {
					inputProps = {
						maxLength = 4,
					},
				},
			},
		}, "Robbery:Client:Paleto:DoorInput", data)
	else
		exports["pulsar-core"]:ServerCallback("Robbery:Paleto:UnlockDoor", {
			data = data,
		})
	end
end)

AddEventHandler("Robbery:Client:Paleto:DoorInput", function(values, data)
	exports["pulsar-core"]:ServerCallback("Robbery:Paleto:UnlockDoor", {
		code = values.code,
		data = data,
	})
end)

AddEventHandler("Robbery:Client:Paleto:Doors", function(entity, data)
	exports["pulsar-core"]:ServerCallback("Robbery:Paleto:GetDoors", {}, function(menu)
		local menu = {
			main = {
				label = "Blaine Co Savings Door Controls",
				items = menu,
			},
		}

		exports['pulsar-hud']:ListMenuShow(menu)
	end)
end)

AddEventHandler("Robbery:Client:Paleto:StartSecuring", function(entity, data)
	exports['pulsar-hud']:Progress({
		name = "secure_paleto",
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
			exports["pulsar-core"]:ServerCallback("Robbery:Paleto:SecureBank", {})
		end
	end)
end)

AddEventHandler("Robbery:Client:Paleto:DisableAlarm", function(entity, data)
	exports['pulsar-hud']:Progress({
		name = "secure_paleto",
		duration = 3000,
		label = "Disabling",
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
			exports["pulsar-core"]:ServerCallback("Robbery:Paleto:DisableAlarm", {})
		end
	end)
end)

RegisterNetEvent("Robbery:Client:Paleto:CheckLasers", function()
	if LocalPlayer.state.inPaletoBank then
		local powerDisabled = IsPaletoPowerDisabled()
		for k2, v2 in ipairs(_pb.lasers) do
			exports['pulsar-lasers']:SetActive(string.format("paleto_lasers_%s", k2), not powerDisabled)
			exports['pulsar-lasers']:SetVisible(string.format("paleto_lasers_%s", k2), not powerDisabled)
		end
	end
end)
