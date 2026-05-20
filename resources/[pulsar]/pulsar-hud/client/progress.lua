template_action          = {
	name            = "",
	duration        = 0,
	label           = "",
	useWhileDead    = false,
	canCancel       = true,
	ignoreModifier  = false,
	disarm          = true,
	controlDisables = {
		disableMovement    = false,
		disableCarMovement = false,
		disableMouse       = false,
		disableCombat      = false,
	},
}

local progress_action    = nil
local _mdfr              = 1.0
local disableMouse       = false
local wasCancelled       = false
local wasFinished        = false
local isAnim             = false
local isProp             = false
local isPropTwo          = false -- kept for backwards compat; not used with new array flow
local prop_net           = nil   -- kept for backwards compat; not used with new array flow
local propTwo_net        = nil   -- kept for backwards compat; not used with new array flow
local _runProgressThread = false

-- MARK: New Prop Attachment
local _prop_nets         = {}
local function _ensureVec3(t)
	if not t then return { x = 0.0, y = 0.0, z = 0.0 } end
	return { x = t.x or 0.0, y = t.y or 0.0, z = t.z or 0.0 }
end

local function _toHash(model)
	if type(model) == "number" then
		return model
	end
	return GetHashKey(model)
end

local function _loadModel(hash)
	if not IsModelInCdimage(hash) then return false end
	RequestModel(hash)
	local timeout = GetGameTimer() + 5000
	while not HasModelLoaded(hash) do
		Wait(0)
		if GetGameTimer() > timeout then
			return false
		end
	end
	return true
end

---@param player number ped
---@param spec table { model, bone?, coords?/pos?, rotation?/rot? }
local function _attachProp(player, spec)
	if not spec or not spec.model then return nil end

	local bone      = spec.bone or 60309
	local coords    = _ensureVec3(spec.coords or spec.pos)
	local rot       = _ensureVec3(spec.rotation or spec.rot)

	local modelHash = _toHash(spec.model)
	if not _loadModel(modelHash) then return nil end

	local p = GetEntityCoords(player)
	local obj = CreateObject(modelHash, p.x, p.y, p.z, true, true, true)
	if not DoesEntityExist(obj) then return nil end

	local netid = ObjToNet(obj)
	SetNetworkIdExistsOnAllMachines(netid, true)
	NetworkSetNetworkIdDynamic(netid, true)
	SetNetworkIdCanMigrate(netid, false)

	AttachEntityToEntity(
		obj,
		player,
		GetPedBoneIndex(player, bone),
		coords.x, coords.y, coords.z,
		rot.x, rot.y, rot.z,
		true, true, false, true, 1, true
	)

	table.insert(_prop_nets, netid)
	SetModelAsNoLongerNeeded(modelHash)
	return netid
end

local function _cleanupAllProps()
	for i = #_prop_nets, 1, -1 do
		local netid = _prop_nets[i]
		if netid ~= nil and NetworkDoesEntityExistWithNetworkId(netid) then
			local obj = NetToObj(netid)
			if DoesEntityExist(obj) then
				DeleteEntity(obj)
			end
		end
		_prop_nets[i] = nil
	end
end

local function _asPropArray(prop)
	if not prop then return {} end
	if prop[1] ~= nil then
		return prop -- already an array
	else
		return { prop } -- single spec
	end
end

local function deepcopy(orig)
	if type(orig) ~= 'table' then return orig end
	local copy = {}
	for k, v in pairs(orig) do
		copy[deepcopy(k)] = deepcopy(v)
	end
	return copy
end
---------------------------------------

function runMdfr(duration)
	local c = 0
	CreateThread(function()
		exports['pulsar-hud']:ApplyUniqueBuff("prog_mod", duration / 1000, false)
		while LocalPlayer.state.loggedIn and c < duration / 1000 do
			c = c + 1
			Wait(1000)
		end
		exports['pulsar-hud']:RemoveBuffType("prog_mod")
		_mdfr = 1.0
	end)
end

exports("ProgressCurrentAction", function()
	return progress_action and progress_action.name or ""
end)

exports("Progress", function(action, finish)
	_doProgress(action, nil, nil, finish)
end)

exports("ProgressWithStartEvent", function(action, start, finish)
	_doProgress(action, start, nil, finish)
end)

exports("ProgressWithTickEvent", function(action, tick, finish)
	_doProgress(action, nil, tick, finish)
end)

exports("ProgressWithStartAndTick", function(action, start, tick, finish)
	_doProgress(action, start, tick, finish)
end)

exports("ProgressModifier", function(p, t)
	if _mdfr ~= 1.0 then
		return false
	end
	_mdfr = p / 100.0
	runMdfr(t)
	return true
end)

exports("ProgressCancel", function(force)
	if progress_action == nil then return end
	if progress_action.canCancel or force then
		wasCancelled = true
		_doFinish()
		SendNUIMessage({
			type = "CANCEL_PROGRESS",
		})
	end
end)

exports("ProgressFail", function()
	wasCancelled = true
	_doFinish()
	SendNUIMessage({
		type = "FAIL_PROGRESS",
	})
end)

exports("ProgressFinish", function()
	wasFinished = true
	_doFinish()
end)

AddEventHandler("Keybinds:Client:KeyUp:cancel_action", function()
	if not LocalPlayer.state.doingAction then return end
	exports['pulsar-hud']:ProgressCancel()
end)

RegisterNetEvent("Characters:Client:Logout")
AddEventHandler("Characters:Client:Logout", function()
	exports['pulsar-hud']:ProgressCancel()
end)

function normalizePAct(passed)
	local c = deepcopy(template_action)
	for k, v in pairs(passed or {}) do
		c[k] = v
	end
	return c
end

function _doProgress(action, start, tick, finish)
	local player = LocalPlayer.state.ped
	LocalPlayer.state.invBusy = true
	progress_action = normalizePAct(action)

	if ((not IsEntityDead(player)) and not LocalPlayer.state.isDead) or progress_action.useWhileDead then
		if not LocalPlayer.state.doingAction then
			_doActionStart(player, progress_action)

			LocalPlayer.state.doingAction = true
			wasCancelled = false
			isAnim = false
			isProp = false
			isPropTwo = false
			wasFinished = false

			if not progress_action.ignoreModifier then
				progress_action.duration = progress_action.duration * _mdfr
			end

			SendNUIMessage({
				type = "START_PROGRESS",
				data = {
					duration = progress_action.duration,
					label = progress_action.label,
				},
			})

			CreateThread(function()
				if start ~= nil then
					start()
				end

				if tick ~= nil then
					CreateThread(function()
						while LocalPlayer.state.doingAction do
							if progress_action.tickrate ~= nil then
								Wait(progress_action.tickrate)
							else
								Wait(0)
							end

							if LocalPlayer.state.doingAction and not (wasCancelled or wasFinished) then
								tick()
							end
						end
					end)
				end

				while LocalPlayer.state.doingAction do
					Wait(1)
					if (IsEntityDead(player) and not progress_action.useWhileDead) or not LocalPlayer.state.loggedIn then
						exports['pulsar-hud']:ProgressCancel()
					end
				end

				if finish ~= nil then
					finish(wasCancelled)
				end
			end)
		else
			exports["pulsar-hud"]:Notification("error", "Already Doing An Action", 5000)
		end
	else
		exports["pulsar-hud"]:Notification("error", "Already Doing An Action", 5000)
	end
end

function _doActionStart(player, action)
	_runProgressThread = true

	CreateThread(function()
		while _runProgressThread do
			_disableInput(player, action.controlDisables)
			Wait(1)
		end
	end)

	CreateThread(function()
		while _runProgressThread do
			if LocalPlayer.state.doingAction then
				if not isAnim then
					if action.animation then
						if action.animation.task ~= nil then
							if GetVehiclePedIsIn(LocalPlayer.state.ped) == 0 then
								TaskStartScenarioInPlace(player, action.animation.task, 0, true)
							end
						elseif action.animation.animDict ~= nil and action.animation.anim ~= nil then
							if action.animation.flags == nil then
								local disables = action.controlDisables or {}
								action.animation.flags = (disables.disableMovement and 1) or 49
							end

							if DoesEntityExist(player) and not LocalPlayer.state.isDead then
								loadAnimDict(action.animation.animDict)
								TaskPlayAnim(player, action.animation.animDict, action.animation.anim, 3.0, 1.0, -1,
									action.animation.flags, 0, 0, 0, 0)
							end

							CreateThread(function()
								while LocalPlayer.state.doingAction do
									if LocalPlayer.state.doingAction and not IsEntityPlayingAnim(player, action.animation.animDict, action.animation.anim, 3) then
										TaskPlayAnim(player, action.animation.animDict, action.animation.anim, 3.0, 1.0,
											-1, action.animation.flags, 0, 0, 0, 0)
									end
									Wait(1000)
								end
							end)
						elseif action.animation.anim ~= nil then
							exports['pulsar-animations']:EmotesPlay(action.animation.anim, false, action.duration, true)
						else
							if GetVehiclePedIsIn(LocalPlayer.state.ped) == 0 then
								TaskStartScenarioInPlace(player, "PROP_HUMAN_BUM_BIN", 0, true)
							end
						end
					end

					if action.disarm then
						TriggerEvent('ox_inventory:disarm', LocalPlayer.state.ped, true)
					end

					isAnim = true
				end

				if not isProp then
					local hasAny = false
					local props = {}

					for _, p in ipairs(_asPropArray(action.prop)) do
						if p and (p.model ~= nil) then
							props[#props + 1] = p
						end
					end

					if action.propTwo and action.propTwo.model ~= nil then
						props[#props + 1] = action.propTwo
					end

					for i = 1, #props do
						local netid = _attachProp(player, props[i])
						if netid ~= nil then
							hasAny = true
						end
					end

					if hasAny then
						isProp = true
					end
				end

				if action.vehicle and not IsPedInAnyVehicle(player) then
					exports['pulsar-hud']:ProgressFail()
				end
			end
			Wait(0)
		end
	end)
end

function _doFinish()
	LocalPlayer.state.invBusy = false
	LocalPlayer.state.doingAction = false
	_doCleanup(progress_action)
end

function _doCleanup(action)
	_cleanupAllProps()

	prop_net = nil
	propTwo_net = nil

	if action and action.animation then
		if action.animation.animDict ~= nil and action.animation.anim ~= nil then
			StopAnimTask(LocalPlayer.state.ped, action.animation.animDict, action.animation.anim, 1.0)
		elseif action.animation.anim ~= nil then
			exports['pulsar-animations']:EmotesForceCancel()
		else
			if action.animation.task ~= nil and not IsPedInAnyVehicle(LocalPlayer.state.ped, true) then
				ClearPedTasks(LocalPlayer.state.ped)
			end
		end
	end

	_runProgressThread = false
	progress_action = nil
end

function loadAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		RequestAnimDict(dict)
		Wait(5)
	end
end

function _disableInput(ped, disables)
	if disables.disableMouse then
		DisableControlAction(0, 1, true) -- LookLeftRight
		DisableControlAction(0, 2, true) -- LookUpDown
		DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
	end

	if disables.disableMovement then
		DisableControlAction(0, 22, true) -- INPUT_JUMP
		DisableControlAction(0, 23, true) -- enter
		DisableControlAction(0, 30, true) -- disable left/right
		DisableControlAction(0, 31, true) -- disable forward/back
		DisableControlAction(0, 36, true) -- INPUT_DUCK
		DisableControlAction(0, 21, true) -- disable sprint
		DisableControlAction(0, 44, true) -- disable cover
	end

	if disables.disableCarMovement then
		DisableControlAction(0, 63, true) -- veh turn left
		DisableControlAction(0, 64, true) -- veh turn right
		DisableControlAction(0, 71, true) -- veh forward
		DisableControlAction(0, 72, true) -- veh backwards
		DisableControlAction(0, 75, true) -- disable exit vehicle
	end

	if disables.disableCombat then
		DisablePlayerFiring(PlayerId(), true) -- Disable weapon firing
		DisableControlAction(0, 24, true) -- disable attack
		DisableControlAction(0, 25, true) -- disable aim
		DisableControlAction(1, 37, true) -- disable weapon select
		DisableControlAction(0, 47, true) -- disable weapon
		DisableControlAction(0, 58, true) -- disable weapon
		DisableControlAction(0, 140, true) -- disable melee
		DisableControlAction(0, 141, true) -- disable melee
		DisableControlAction(0, 142, true) -- disable melee
		DisableControlAction(0, 143, true) -- disable melee
		DisableControlAction(0, 263, true) -- disable melee
		DisableControlAction(0, 264, true) -- disable melee
		DisableControlAction(0, 257, true) -- disable melee
	end
end
