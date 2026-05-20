local CAMERA_DISTANCE = 3.0
local CAMERA_Z_MAX = 0.7
local CAMERA_Z_MIN = -0.75
local CAMERA_MOVE_Z_SPEED = 0.001
local CAMERA_MOVE_HEADING_SPEED = 0.25
local CAMERA_LERP_Z_SPEED = 10.0
local CAMERA_LERP_HEADING_SPEED = 5.0
local CAMERA_FOV_MAX = 70.0
local CAMERA_FOV_MIN = 5.0
local CAMERA_ZOOM_SPEED = 0.01
local CAMERA_LERP_FOV_SPEED = 5.0

local CameraViews = {
	face = { z = 0.6, fov = 10.0 },
	upper = { z = 0.2, fov = 30.0 },
	lower = { z = -0.4, fov = 30.0 },
	shoes = { z = -0.75, fov = 15.0 },
}

local LegacyViews = {
	standard = "upper",
	head = "face",
	body = "upper",
	legs = "lower",
	[0] = "upper",
	[1] = "face",
	[2] = "upper",
	[3] = "lower",
	[4] = "shoes",
}

Camera = {}

Camera.entity = nil
Camera.position = vector3(0.0, 0.0, 0.0)
Camera.pointCoords = vector3(0.0, 0.0, 0.0)
Camera.active = false
Camera.dist = 0.0
Camera.currentZ = 0.0
Camera.fov = 50.0
Camera.heading = 0.0
Camera.targetZ = 0.0
Camera.targetFov = 50.0
Camera.targetHeading = 0.0
Camera.initialHeading = 0.0
Camera.currentView = "upper"

-- Kept for old code paths that still poke these fields.
Camera.radius = 1.25
Camera.updateZoom = false
Camera.angleX = 0.0
Camera.angleY = 0.0

local function lerp(from, to, alpha)
	return from * (1.0 - alpha) + to * alpha
end

local function clamp(value, min, max)
	if value < min then
		return min
	end

	if value > max then
		return max
	end

	return value
end

function Camera.GetTargetPed()
	if TargetPed and DoesEntityExist(TargetPed) then
		return TargetPed
	end

	return PlayerPedId()
end

function Camera.ResolveView(view)
	if type(view) == "table" then
		view = view.cameraType or view.cam or view.value or view[1]
	end

	if type(view) == "string" then
		local numericView = tonumber(view)
		if numericView then
			return LegacyViews[numericView] or "upper"
		end
	end

	return LegacyViews[view] or view or "upper"
end

function Camera.Activate(delay)
	if delay then
		Wait(delay)
	end

	if not DoesCamExist(Camera.entity) then
		Camera.entity = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
	end

	local ped = Camera.GetTargetPed()
	FreezePedCameraRotation(ped, true)
	FreezeEntityPosition(ped, true)

	LocalPlayer.state.srpPedCam = true

	SetCamActive(Camera.entity, true)
	RenderScriptCams(true, true, 500, true, true)

	Camera.fov = 50.0
	Camera.currentZ = 0.5
	Camera.targetZ = 0.5
	Camera.targetFov = Camera.fov
	Camera.heading = GetEntityHeading(ped)
	Camera.targetHeading = Camera.heading
	Camera.initialHeading = Camera.heading * math.pi / 180.0
	Camera.dist, Camera.position = Camera.GetCameraDist()
	Camera.ApplyPosition()
	Camera.active = true
end

function Camera.Deactivate()
	local ped = Camera.GetTargetPed()

	ClearPedTasksImmediately(ped)

	SetCamActive(Camera.entity, false)
	RenderScriptCams(false, true, 500, true, true)

	FreezePedCameraRotation(ped, false)
	FreezeEntityPosition(ped, false)

	Camera.active = false
	LocalPlayer.state.srpPedCam = nil
end

function Camera.GetCameraDist()
	local ped = Camera.GetTargetPed()
	local pedCoords = GetEntityCoords(ped)
	local heading = GetEntityHeading(ped) * math.pi / 180.0 + math.pi / 2.0
	local offsetX = math.cos(heading)
	local offsetY = math.sin(heading)

	local ray = StartShapeTestCapsule(
		pedCoords.x,
		pedCoords.y,
		pedCoords.z + 0.5,
		pedCoords.x + offsetX * CAMERA_DISTANCE,
		pedCoords.y + offsetY * CAMERA_DISTANCE,
		pedCoords.z + 0.5,
		0.5,
		23,
		ped,
		0
	)

	local _, hit, hitCoords = GetShapeTestResult(ray)
	if hit == 1 and hitCoords then
		return #(pedCoords - hitCoords), hitCoords
	end

	return CAMERA_DISTANCE, pedCoords + CAMERA_DISTANCE * vector3(offsetX, offsetY, 0.0)
end

function Camera.ApplyPosition()
	if not DoesCamExist(Camera.entity) then
		return
	end

	local ped = Camera.GetTargetPed()
	if not DoesEntityExist(ped) then
		return
	end

	local pedCoords = GetEntityCoords(ped)

	Camera.position = vector3(Camera.position.x, Camera.position.y, pedCoords.z + Camera.currentZ)

	SetCamFov(Camera.entity, Camera.fov)
	SetCamCoord(Camera.entity, Camera.position.x, Camera.position.y, Camera.position.z)

	local halfFov = Camera.fov * math.pi / 180.0 / 2.0
	local lookOffset = -1.25 * math.sin(halfFov)
	local targetCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.0, Camera.currentZ)
	local headingVector = vector3(math.cos(Camera.initialHeading), math.sin(Camera.initialHeading), 0.0)
	local pointCoords = targetCoords + lookOffset * headingVector

	Camera.pointCoords = pointCoords
	PointCamAtCoord(Camera.entity, pointCoords.x, pointCoords.y, pointCoords.z)
end

function Camera.SelectCamera(view)
	local resolvedView = Camera.ResolveView(view)
	local config = CameraViews[resolvedView]
	if not config then
		return false
	end

	Camera.targetZ = config.z
	Camera.targetFov = config.fov
	Camera.currentView = resolvedView

	return true
end

function Camera.SetView(view)
	return Camera.SelectCamera(view)
end

function Camera.Move(dx, dy)
	dx = tonumber(dx) or 0.0
	dy = tonumber(dy) or 0.0

	Camera.targetZ = clamp(Camera.targetZ + dy * CAMERA_MOVE_Z_SPEED, CAMERA_Z_MIN, CAMERA_Z_MAX)
	Camera.targetHeading = Camera.targetHeading + dx * CAMERA_MOVE_HEADING_SPEED
end

function Camera.Zoom(dy)
	dy = tonumber(dy) or 0.0
	Camera.targetFov = clamp(Camera.targetFov + dy * CAMERA_ZOOM_SPEED, CAMERA_FOV_MIN, CAMERA_FOV_MAX)
end

function Camera.Rotate(amount)
	amount = tonumber(amount) or 0.0
	Camera.targetHeading = Camera.targetHeading + amount
end

CreateThread(function()
	while true do
		if Camera.active or FROZEN then
			DisableFirstPersonCamThisFrame()

			DisableControlAction(2, 30, true)
			DisableControlAction(2, 31, true)
			DisableControlAction(2, 32, true)
			DisableControlAction(2, 33, true)
			DisableControlAction(2, 34, true)
			DisableControlAction(2, 35, true)

			DisableControlAction(0, 25, true)
			DisableControlAction(0, 24, true)
			DisableControlAction(0, 1, true)
			DisableControlAction(0, 2, true)
			DisableControlAction(0, 106, true)
			DisableControlAction(0, 142, true)
			DisableControlAction(0, 30, true)
			DisableControlAction(0, 31, true)
			DisableControlAction(0, 21, true)
			DisableControlAction(0, 47, true)
			DisableControlAction(0, 58, true)
			DisableControlAction(0, 263, true)
			DisableControlAction(0, 264, true)
			DisableControlAction(0, 257, true)
			DisableControlAction(0, 140, true)
			DisableControlAction(0, 141, true)
			DisableControlAction(0, 143, true)
			DisableControlAction(0, 75, true)
			DisableControlAction(27, 75, true)

			if Camera.active then
				local ped = Camera.GetTargetPed()
				if DoesEntityExist(ped) then
					local frameTime = GetFrameTime()

					Camera.currentZ = lerp(Camera.currentZ, Camera.targetZ, CAMERA_LERP_Z_SPEED * frameTime)
					Camera.fov = lerp(Camera.fov, Camera.targetFov, CAMERA_LERP_FOV_SPEED * frameTime)
					Camera.heading = lerp(Camera.heading, Camera.targetHeading, CAMERA_LERP_HEADING_SPEED * frameTime)

					SetEntityHeading(ped, Camera.heading)
					Camera.ApplyPosition()
				end
			end
		end

		Wait(0)
	end
end)
