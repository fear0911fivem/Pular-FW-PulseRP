_curBed = nil
_done = false

_healEnd = nil
_leavingBed = false

AddEventHandler('onClientResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		Init()

		while GlobalState["HiddenHospital"] == nil do
			Wait(5)
		end

		exports['pulsar-pedinteraction']:Add("HiddenHospital", `s_m_m_doctor_01`, GlobalState["HiddenHospital"].coords,
			GlobalState["HiddenHospital"].heading, 25.0, {
				{
					icon = "heart-pulse",
					text = "Revive Escort (20 $MALD)",
					event = "Hospital:Client:HiddenRevive",
					data = LocalPlayer.state.isEscorting or {},
					isEnabled = function()
						if LocalPlayer.state.isEscorting ~= nil and not LocalPlayer.state.isDead then
							local ps = Player(LocalPlayer.state.isEscorting).state
							return ps.isDead and not (ps.deadData and ps.deadData.isMinor)
						else
							return false
						end
					end,
				},
			}, 'suitcase-medical', false, true, {
				animDict = "mp_prison_break",
				anim = "hack_loop",
			})

		exports['pulsar-polyzone']:CreateBox('hospital-check-in-zone-1', vector3(1146.37, -1538.66, 35.03), 2.8, 1.2, {
			heading = 0,
			--debugPoly=true,
			minZ = 32.63,
			maxZ = 36.63
		}, {})

		exports['pulsar-polyzone']:CreateBox('hospital-check-in-zone-2', vector3(1129.59, -1534.96, 35.03), 2.8, 1.2, {
			heading = 3,
			--debugPoly=true,
			minZ = 32.63,
			maxZ = 36.63
		}, {})

		exports['pulsar-polyzone']:CreateBox('hospital-check-in-zone-3', vector3(1142.82, -1537.74, 39.5), 2.8, 1.2, {
			heading = 88,
			--debugPoly=true,
			minZ = 37.1,
			maxZ = 41.1
		}, {})

		exports.ox_target:addBoxZone({
			id = "icu-checkout",
			coords = vector3(1147.83, -1542.54, 39.5),
			size = vector3(2.8, 0.8, 2.6),
			rotation = 0,
			debug = false,
			minZ = 38.5,
			maxZ = 41.1,
			options = {
				{
					icon = "bell-concierge",
					label = "Request Personnel",
					event = "Hospital:Client:RequestEMS",
					canInteract = function()
						return (LocalPlayer.state.Character:GetData("ICU") ~= nil and not LocalPlayer.state.Character:GetData("ICU").Released) and
							(not _done or _done < GetCloudTimeAsInt())
					end,
				}
			}
		})

		exports['pulsar-polyzone']:CreatePoly("hospital-icu-area", {
			vector2(1144.3436279297, -1541.1220703125),
			vector2(1144.3024902344, -1560.3250732422),
			vector2(1148.193359375, -1560.3918457031),
			vector2(1154.2583007812, -1560.4184570312),
			vector2(1154.3413085938, -1555.5563964844),
			vector2(1154.4481201172, -1548.7468261719),
			vector2(1154.1629638672, -1540.7801513672)
		}, {
			--debugPoly=true,
			minZ = 38.50,
			maxZ = 40.53
		})
	end
end)

AddEventHandler("Hospital:Client:RequestEMS", function()
	if not _done or _done < GetCloudTimeAsInt() then
		TriggerServerEvent("EmergencyAlerts:Server:DoPredefined", "icurequest")
		_done = GetCloudTimeAsInt() + (60 * 10)
	end
end)

exports("HospitalCheckIn", function()
	exports["pulsar-core"]:ServerCallback('Hospital:Treat', {}, function(bed)
		if bed ~= nil then
			_countdown = Config.HealTimer
			LocalPlayer.state:set("isHospitalized", true, true)
			exports['pulsar-damage']:HospitalSendToBed(Config.Beds[bed], false, bed)
		else
			exports["pulsar-hud"]:Notification("error", 'No Beds Available')
		end
	end)
end)

exports("HospitalSendToBed", function(bed, isRp, bedId)
	local gotobed = false

	if bedId then
		local p = promise.new()
		exports["pulsar-core"]:ServerCallback('Hospital:OccupyBed', bedId, function(s)
			p:resolve(s)
		end)

		gotobed = Citizen.Await(p)
	else
		gotobed = true
	end

	_bedId = bedId

	if bed ~= nil and gotobed then
		SetBedCam(bed)
		if isRp then
			_healEnd = GetCloudTimeAsInt()
			exports['pulsar-hud']:DeathTextsShow("hospital_rp", GetCloudTimeAsInt(), _healEnd, "primary_action")
		else
			_healEnd = GetCloudTimeAsInt() + (60 * 1)
			exports['pulsar-hud']:DeathTextsShow("hospital", GetCloudTimeAsInt(), _healEnd, "primary_action")
			SetTimeout(((_healEnd - GetCloudTimeAsInt()) - 10) * 1000, function()
				if LocalPlayer.state.loggedIn and LocalPlayer.state.isHospitalized then
					LocalPlayer.state.deadData = {}
					exports['pulsar-damage']:ReductionsReset()
					exports['pulsar-damage']:Revive()
				end
			end)
		end
	else
		exports["pulsar-hud"]:Notification("error", 'Invalid Bed or Bed Occupied')
	end
end)

exports("HospitalFindBed", function(object)
	local coords = GetEntityCoords(object)
	exports["pulsar-core"]:ServerCallback('Hospital:FindBed', coords, function(bed)
		if bed ~= nil then
			exports['pulsar-damage']:HospitalSendToBed(Config.Beds[bed], true, bed)
		else
			exports['pulsar-damage']:HospitalSendToBed({
				x = coords.x,
				y = coords.y,
				z = coords.z,
				h = GetEntityHeading(object),
				freeBed = true,
			}, true)
		end
	end)
end)

exports("HospitalLeaveBed", function()
	exports["pulsar-core"]:ServerCallback('Hospital:LeaveBed', _bedId, function()
		_bedId = nil
	end)
end)

local _bedId = nil

local _inCheckInZone = false

AddEventHandler('Polyzone:Enter', function(id, point, insideZone, data)
	if id == 'hospital-check-in-zone-1' or id == 'hospital-check-in-zone-2' or id == 'hospital-check-in-zone-3' then
		_inCheckInZone = true

		if not LocalPlayer.state.isEscorted and (GlobalState["ems:pmc:doctor"] == nil or GlobalState["ems:pmc:doctor"] == 0) then
			if not GlobalState["Duty:ems"] or GlobalState["Duty:ems"] == 0 then
				exports['pulsar-hud']:ActionShow("medical",
					'{keybind}primary_action{/keybind} Check In {key}$100{/key}')
			else
				exports['pulsar-hud']:ActionShow("medical",
					'{keybind}primary_action{/keybind} Check In {key}$100{/key}')
			end
		end
	end
end)

AddEventHandler('Polyzone:Exit', function(id, point, insideZone, data)
	if id == 'hospital-check-in-zone-1' or id == 'hospital-check-in-zone-2' or id == 'hospital-check-in-zone-3' then
		_inCheckInZone = false
		exports['pulsar-hud']:ActionHide("medical")
	elseif id == "hospital-icu-area" and LocalPlayer.state.loggedIn then
		if LocalPlayer.state.Character:GetData("ICU") and not LocalPlayer.state.Character:GetData("ICU").Released then
			TriggerEvent("Hospital:Client:ICU:Enter")
		end
	end
end)

AddEventHandler('Keybinds:Client:KeyUp:primary_action', function()
	if _inCheckInZone then
		if not LocalPlayer.state.doingAction and not LocalPlayer.state.isEscorted and (GlobalState["ems:pmc:doctor"] == nil or GlobalState["ems:pmc:doctor"] == 0) then
			TriggerEvent('Hospital:Client:CheckIn')
		end
	else
		if _curBed ~= nil and LocalPlayer.state.isHospitalized and GetCloudTimeAsInt() > _healEnd and not _leavingBed then
			_leavingBed = true
			exports['pulsar-hud']:DeathTextsRelease()
			LeaveBed()
		end
	end
end)
