local Sounds = {
	["SELECT"] = { id = -1, sound = "SELECT", library = "HUD_FRONTEND_DEFAULT_SOUNDSET" },
	["BACK"] = { id = -1, sound = "CANCEL", library = "HUD_FRONTEND_DEFAULT_SOUNDSET" },
	["UPDOWN"] = { id = -1, sound = "NAV_UP_DOWN", library = "HUD_FRONTEND_DEFAULT_SOUNDSET" },
	["DISABLED"] = { id = -1, sound = "ERROR", library = "HUD_FRONTEND_DEFAULT_SOUNDSET" },
}

LocalPlayer.state.isNaked = false

RegisterNetEvent("UI:Client:Reset", function(apps)
	SetNuiFocus(false, false)
	SendNUIMessage({
		type = "UI_RESET",
		data = {},
	})

	SendNUIMessage({
		type = "SET_TATTOOS_DATA",
		data = {
			data = PedTattoos
		},
	})
end)

RegisterNUICallback("FrontEndSound", function(data, cb)
	cb("ok")
	if Sounds[data.sound] ~= nil then
		exports['pulsar-sounds']:UISoundsPlayFrontEnd(Sounds[data.sound].id, Sounds[data.sound].sound,
			Sounds[data.sound].library)
	end
end)

RegisterNUICallback("Save", function(data, cb)
	if _currentState ~= nil then
		exports['pulsar-ped']:CustomizationSave(cb)
	else
		cb(false)
	end
end)

RegisterNUICallback("Cancel", function(data, cb)
	cb(exports['pulsar-ped']:CustomizationCancel())
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

local nakedPed = nil
local nakedState = {
	toggle = false,
	head = false,
	torso = false,
	pants = false,
	shoes = false,
}

local function normalizeNakedState(data)
	if type(data) ~= "table" then
		local enabled = data == true
		return {
			toggle = enabled,
			head = enabled,
			torso = enabled,
			pants = enabled,
			shoes = enabled,
		}
	end

	local state = {
		head = data.head == true,
		torso = data.torso == true,
		pants = data.pants == true,
		shoes = data.shoes == true,
	}
	state.toggle = data.toggle == true or state.head or state.torso or state.pants or state.shoes
	return state
end

local function copyPedPart(target, source)
	if target == nil or source == nil then
		return
	end

	for key, value in pairs(source) do
		target[key] = value
	end
end

local function setPedPart(target, values)
	if target == nil or values == nil then
		return
	end

	for key, value in pairs(values) do
		target[key] = value
	end
end

local function restoreComponent(name)
	copyPedPart(
		nakedPed.customization.components[name],
		LocalPed.customization.components[name]
	)
end

local function restoreProp(name)
	copyPedPart(
		nakedPed.customization.props[name],
		LocalPed.customization.props[name]
	)
end

function ToggleNekked(data)
	local state = normalizeNakedState(data)
	nakedState = state

	if state.toggle then
		LocalPlayer.state.isNaked = true
		nakedPed = deepcopy(LocalPed)
		local isMale = LocalPlayer.state.Character:GetData("Gender") == 0

		if isMale then
			if state.torso then
				setPedPart(nakedPed.customization.components.torso, { drawableId = 15, textureId = 0 })
				setPedPart(nakedPed.customization.components.torso2, { drawableId = 252, textureId = 0 })
				setPedPart(nakedPed.customization.components.undershirt, { drawableId = 15, textureId = 0 })
				setPedPart(nakedPed.customization.components.kevlar, { drawableId = 0, textureId = 0 })
			else
				restoreComponent("torso")
				restoreComponent("torso2")
				restoreComponent("undershirt")
				restoreComponent("kevlar")
			end

			if state.pants then
				setPedPart(nakedPed.customization.components.leg, { drawableId = 21, textureId = 0 })
			else
				restoreComponent("leg")
			end

			if state.shoes then
				setPedPart(nakedPed.customization.components.shoes, { drawableId = 34, textureId = 0 })
			else
				restoreComponent("shoes")
			end
		else
			if state.torso then
				setPedPart(nakedPed.customization.components.torso, { drawableId = 15, textureId = 0 })
				setPedPart(nakedPed.customization.components.torso2, { drawableId = 15, textureId = 0 })
				setPedPart(nakedPed.customization.components.undershirt, { drawableId = 14, textureId = 0 })
				setPedPart(nakedPed.customization.components.kevlar, { drawableId = 0, textureId = 0 })
			else
				restoreComponent("torso")
				restoreComponent("torso2")
				restoreComponent("undershirt")
				restoreComponent("kevlar")
			end

			if state.pants then
				setPedPart(nakedPed.customization.components.leg, { drawableId = 15, textureId = 0 })
			else
				restoreComponent("leg")
			end

			if state.shoes then
				setPedPart(nakedPed.customization.components.shoes, { drawableId = 35, textureId = 0 })
			else
				restoreComponent("shoes")
			end
		end

		if state.torso then
			setPedPart(nakedPed.customization.components.bag, { drawableId = 0, textureId = 0 })
			setPedPart(nakedPed.customization.components.badge, { drawableId = 0, textureId = 0 })
			setPedPart(nakedPed.customization.components.accessory, { drawableId = 0, textureId = 0 })
		else
			restoreComponent("bag")
			restoreComponent("badge")
			restoreComponent("accessory")
		end

		if state.head then
			setPedPart(nakedPed.customization.components.mask, { drawableId = 0, textureId = 0 })
			setPedPart(nakedPed.customization.props.hat, { disabled = true })
			setPedPart(nakedPed.customization.props.glass, { disabled = true })
			setPedPart(nakedPed.customization.props.ear, { disabled = true })
		else
			restoreComponent("mask")
			restoreProp("hat")
			restoreProp("glass")
			restoreProp("ear")
		end

		exports['pulsar-ped']:ApplyToPed(nakedPed)
	else
		LocalPlayer.state.isNaked = false
		exports['pulsar-ped']:ApplyToPed(LocalPed)
		nakedPed = nil
		nakedState = {
			toggle = false,
			head = false,
			torso = false,
			pants = false,
			shoes = false,
		}
	end
end

RegisterNUICallback("ToggleNekked", function(data, cb)
	ToggleNekked(data)
	cb("ok")
end)

RegisterNUICallback("SetClothingToggle", function(data, cb)
	if type(data) ~= "table" or data.key == nil then
		cb(false)
		return
	end

	nakedState[data.key] = data.value == true
	nakedState.toggle = nakedState.head or nakedState.torso or nakedState.pants or nakedState.shoes
	ToggleNekked(nakedState)
	cb("ok")
end)

local cameraDragX = 0
local cameraDragY = 0

local function getCameraType(data)
	if type(data) == "table" then
		return data.cameraType or data.cam or data.value or data[1]
	end

	return data
end

local function getCameraDelta(data, key, fallback)
	if type(data) ~= "table" then
		return tonumber(data) or fallback or 0
	end

	return tonumber(data[key]) or fallback or 0
end

RegisterNUICallback("ChangeCamera", function(data, cb)
	local cameraType = getCameraType(data)
	cb(Camera.SelectCamera(cameraType))
end)

RegisterNUICallback("CameraMove", function(data, cb)
	cb("ok")
	Camera.Move(getCameraDelta(data, "dx"), getCameraDelta(data, "dy"))
end)

RegisterNUICallback("rotation:setClicked", function(data, cb)
	cb("yes")

	if type(data) == "table" and data.state == true then
		cameraDragX = tonumber(data.x) or cameraDragX
		cameraDragY = tonumber(data.y) or cameraDragY
	end
end)

RegisterNUICallback("rotation:rotatePlayer", function(data, cb)
	cb("yes")

	if type(data) ~= "table" then
		return
	end

	local x = tonumber(data.x)
	local y = tonumber(data.y)
	if not x then
		return
	end

	y = y or cameraDragY

	local multiplier = 1.0
	if data.control and not data.shift then
		multiplier = 0.5
	elseif data.shift and not data.control then
		multiplier = 2.0
	end

	Camera.Move((x - cameraDragX) * multiplier, (y - cameraDragY) * multiplier)

	cameraDragX = x
	cameraDragY = y
end)

RegisterNUICallback("RotateLeft", function(data, cb)
	cb("ok")
	Camera.Rotate(15.0)
end)

RegisterNUICallback("RotateRight", function(data, cb)
	cb("ok")
	Camera.Rotate(-15.0)
end)

RegisterNUICallback("Zoom", function(data, cb)
	cb("ok")

	local dy = 0
	if type(data) == "table" then
		dy = tonumber(data.dy) or tonumber(data.zoom) or 0
	else
		dy = tonumber(data) or 0
	end

	if math.abs(dy) < 1.0 then
		dy = dy * 2000.0
	end

	Camera.Zoom(dy)
end)

RegisterNUICallback("Animation", function(data, cb)
	cb("ok")
	if _playingIdle then
		ClearPedTasks(PlayerPedId())
		_playingIdle = false
	else
		PlayIdleAnimation()
	end
end)

RegisterNUICallback("SetPedHeadBlendData", function(data, cb)
	cb("OK")
	if LocalPed == nil or LocalPed.customization == nil or LocalPed.customization.face[data.face] == nil then
		return
	end

	LocalPed.customization.face[data.face][data.type] = data.value
	if LocalPlayer.state.isNaked then
		nakedPed.customization.face[data.face][data.type] = data.value
		exports['pulsar-ped']:ApplyToPed(nakedPed)
	else
		exports['pulsar-ped']:ApplyToPed(LocalPed)
	end
end)

RegisterNUICallback("SetPed", function(data, cb)
	local model = GetHashKey(data.value)
	RequestModel(model)
	local c = 0
	while not HasModelLoaded(model) do
		Wait(1)
		c = c + 1
		if c >= 2000 then
			cb(false)
			return
		end
	end
	cb(true)

	LocalPed.model = data.value
	if LocalPlayer.state.isNaked then
		nakedPed.model = data.value
	end
	if _data ~= nil then
		_data.Ped.model = data.value
	end

	SetPlayerModel(PlayerId(), model)
	player = PlayerPedId()
	TargetPed = player
	if Camera and Camera.active then
		FreezePedCameraRotation(player, true)
		FreezeEntityPosition(player, true)
	end
	SetEntityMaxHealth(player, 200)
	SetEntityHealth(player, GetEntityMaxHealth(player))
	LocalPlayer.state.ped = player
	SetPedDefaultComponentVariation(player)
	SetEntityAsMissionEntity(player, true, true)
	SetModelAsNoLongerNeeded(model)

	if data.value == "mp_f_freemode_01" or data.value == "mp_m_freemode_01" then
		if LocalPlayer.state.isNaked then
			exports['pulsar-ped']:ApplyToPed(nakedPed)
		else
			exports['pulsar-ped']:ApplyToPed(LocalPed)
		end
	end
end)

RegisterNUICallback("SetPedFaceFeature", function(data, cb)
	cb("OK")
	if LocalPed == nil or LocalPed.customization == nil then
		return
	end

	LocalPed.customization.face.features[data.index] = data.value
	if LocalPlayer.state.isNaked then
		nakedPed.customization.face.features[data.index] = data.value
		exports['pulsar-ped']:ApplyToPed(nakedPed)
	else
		exports['pulsar-ped']:ApplyToPed(LocalPed)
	end
end)

RegisterNUICallback("SetPedHeadOverlay", function(data, cb)
	cb("OK")
	if LocalPed == nil or LocalPed.customization == nil or LocalPed.customization.overlay[data.type] == nil then
		return
	end

	if data.extraType == "opacity" then
		LocalPed.customization.overlay[data.type].opacity = data.value
	else
		LocalPed.customization.overlay[data.type][data.extraType] = data.value
	end
	if LocalPlayer.state.isNaked then
		if data.extraType == "opacity" then
			nakedPed.customization.overlay[data.type].opacity = data.value
		else
			nakedPed.customization.overlay[data.type][data.extraType] = data.value
		end
		exports['pulsar-ped']:ApplyToPed(nakedPed)
	else
		exports['pulsar-ped']:ApplyToPed(LocalPed)
	end
end)

RegisterNUICallback("SetPedHeadOverlayColor", function(data, cb)
	cb("OK")
	if LocalPed == nil or LocalPed.customization == nil or LocalPed.customization.overlay[data.type] == nil then
		return
	end

	local colorType = data.extraType or data.color or "color1"
	LocalPed.customization.overlay[data.type][colorType] = data.value
	if LocalPlayer.state.isNaked then
		nakedPed.customization.overlay[data.type][colorType] = data.value
		exports['pulsar-ped']:ApplyToPed(nakedPed)
	else
		exports['pulsar-ped']:ApplyToPed(LocalPed)
	end
end)

RegisterNUICallback("SetPedComponentVariation", function(data, cb)
	cb("OK")
	LocalPed.customization.components[data.name][data.type] = data.value
	if not LocalPlayer.state.isNaked then
		exports['pulsar-ped']:ApplyToPed(LocalPed)
	else
		if data.name == "hair" then
			nakedPed.customization.components[data.name][data.type] = data.value
			exports['pulsar-ped']:ApplyToPed(nakedPed)
		end
	end
end)

RegisterNUICallback("SetPedPropIndex", function(data, cb)
	cb("OK")
	LocalPed.customization.props[data.name][data.type] = data.value
	if not LocalPlayer.state.isNaked then
		exports['pulsar-ped']:ApplyToPed(LocalPed)
	end
end)

RegisterNUICallback("SetPedHairColor", function(data, cb)
	cb("OK")
	LocalPed.customization.colors[data.name][data.type].index = data.value
	if LocalPlayer.state.isNaked then
		nakedPed.customization.colors[data.name][data.type].index = data.value
		exports['pulsar-ped']:ApplyToPed(nakedPed)
	else
		exports['pulsar-ped']:ApplyToPed(LocalPed)
	end
end)

RegisterNUICallback("SetPedHairOverlay", function(data, cb)
	cb("OK")

	LocalPed.customization.hairOverlay = data.value
	if LocalPlayer.state.isNaked then
		nakedPed.customization.hairOverlay = data.value
		exports['pulsar-ped']:ApplyToPed(nakedPed)
	else
		exports['pulsar-ped']:ApplyToPed(LocalPed)
	end
end)

RegisterNUICallback("SetPedEyeColor", function(data, cb)
	cb("OK")
	LocalPed.customization.eyeColor = data.value
	if LocalPlayer.state.isNaked then
		nakedPed.customization.eyeColor = data.value
		exports['pulsar-ped']:ApplyToPed(nakedPed)
	else
		exports['pulsar-ped']:ApplyToPed(LocalPed)
	end
end)

RegisterNUICallback("AddPedTattoo", function(data, cb)
	cb("OK")
	table.insert(LocalPed.customization.tattoos, {
		Name = "",
		Collection = "",
		Hash = "",
		Zone = data.type,
	})
	if LocalPlayer.state.isNaked then
		table.insert(nakedPed.customization.tattoos, {
			Name = "",
			Collection = "",
			Hash = "",
			Zone = data.type,
		})
		exports['pulsar-ped']:ApplyToPed(nakedPed, true)
	else
		exports['pulsar-ped']:ApplyToPed(LocalPed, true)
	end
end)

RegisterNUICallback("RemovePedTattoo", function(data, cb)
	cb("OK")
	table.remove(LocalPed.customization.tattoos, data.index + 1)
	if LocalPlayer.state.isNaked then
		table.remove(nakedPed.customization.tattoos, data.index + 1)
		exports['pulsar-ped']:ApplyToPed(nakedPed, true)
	else
		exports['pulsar-ped']:ApplyToPed(LocalPed, true)
	end
end)

RegisterNUICallback("SetPedTattoo", function(data, cb)
	cb("OK")
	LocalPed.customization.tattoos[data.index + 1] = data.data
	if LocalPlayer.state.isNaked then
		nakedPed.customization.tattoos[data.index + 1] = data.data
		exports['pulsar-ped']:ApplyToPed(nakedPed, true)
	else
		exports['pulsar-ped']:ApplyToPed(LocalPed, true)
	end
end)

RegisterNUICallback("GetNumHairColors", function(data, cb)
	cb("OK")
	SendNUIMessage({
		type = "SET_HAIR_COLORS_MAX",
		data = {
			max = GetNumHairColors(),
			maxOverlays = #Config.CustomHairOverlays
		},
	})
end)

RegisterNUICallback("GetPedHairRgbColor", function(data, cb)
	cb("OK")
	local red, green, blue = GetPedHairRgbColor(data.colorId)
	SendNUIMessage({
		type = "SET_HAIR_COLOR_RGB",
		data = {
			type = data.type,
			name = data.name,
			rgb = "rgb(" .. red .. ", " .. green .. ", " .. blue .. ")",
		},
	})
end)

local function isStoreDrawableHidden(section, componentId, gender, drawableId)
	local hidden = GlobalState["ClothingStoreHidden"]
	local sectionHidden = hidden and hidden[section]
	local componentHidden = sectionHidden and sectionHidden[componentId]
	local genderHidden = componentHidden and componentHidden[gender]

	return genderHidden and genderHidden[tostring(drawableId)] == true
end

RegisterNUICallback("GetNumberOfPedDrawableVariations", function(data, cb)
	cb("OK")

	local gender = LocalPlayer.state.Character:GetData("Gender")
	local comps = {}
	for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), data.componentId) do
		if not isStoreDrawableHidden("components", data.componentId, gender, i) then
			table.insert(comps, i)
		end
	end
	SendNUIMessage({
		type = "SET_MAX_DRAWABLE",
		data = {
			id = data.componentId,
			type = "components",
			max = comps,
		},
	})
end)

RegisterNUICallback("GetNumberOfPedTextureVariations", function(data, cb)
	cb("OK")
	SendNUIMessage({
		type = "SET_MAX_TEXTURE",
		data = {
			id = data.componentId,
			textureId = data.textureId,
			type = "components",
			max = GetNumberOfPedTextureVariations(PlayerPedId(), data.componentId, data.drawableId),
		},
	})
end)

RegisterNUICallback("GetNumberOfPedPropDrawableVariations", function(data, cb)
	cb("OK")

	local gender = LocalPlayer.state.Character:GetData("Gender")
	local comps = {}
	for i = 0, GetNumberOfPedPropDrawableVariations(PlayerPedId(), data.componentId) do
		if not isStoreDrawableHidden("props", data.componentId, gender, i) then
			table.insert(comps, i)
		end
	end
	SendNUIMessage({
		type = "SET_MAX_DRAWABLE",
		data = {
			id = data.componentId,
			type = "props",
			max = comps,
		},
	})
end)

RegisterNUICallback("GetNumberOfPedPropTextureVariations", function(data, cb)
	cb("OK")
	SendNUIMessage({
		type = "SET_MAX_TEXTURE",
		data = {
			id = data.componentId,
			textureId = data.textureId,
			type = "props",
			max = GetNumberOfPedPropTextureVariations(PlayerPedId(), data.componentId, data.drawableId),
		},
	})
end)
