local hospitalCheckin = {
	{
		icon = "fas fa-clipboard-check",
		label = "Go On Duty",
		event = "EMS:Client:OnDuty",
		groups = { "ems" },
		reqOffDuty = true,
	},
	{
		icon = "fas fa-clipboard",
		label = "Go Off Duty",
		event = "EMS:Client:OffDuty",
		groups = { "ems" },
		reqDuty = true,
	},
	{
		icon = "fas fa-clipboard",
		label = "Check ICU Patients",
		event = "EMS:Client:CheckICUPatients",
		groups = { "ems" },
		reqDuty = true,
	},
	{
		icon = "fas fa-clipboard-check",
		label = "Check In - $100",
		event = "Hospital:Client:CheckIn",
		canInteract = function()
			if not GlobalState["Duty:ems"] or GlobalState["Duty:ems"] == 0 then
				return not LocalPlayer.state.isEscorted
					and (GlobalState["ems:pmc:doctor"] == nil or GlobalState["ems:pmc:doctor"] == 0)
			end
			return false
		end,
	},
	{
		icon = "fas fa-clipboard-check",
		label = "Check In - $100",
		event = "Hospital:Client:CheckIn",
		canInteract = function()
			if GlobalState["Duty:ems"] and GlobalState["Duty:ems"] > 0 then
				return not LocalPlayer.state.isEscorted
					and (GlobalState["ems:pmc:doctor"] == nil or GlobalState["ems:pmc:doctor"] == 0)
			end
			return false
		end,
	},
	{
		icon = "fas fa-hands-holding",
		label = "Retrieve Items",
		event = "Hospital:Client:RetreiveItems",
		canInteract = function()
			return LocalPlayer.state.Character:GetData("ICU") == nil
				or not LocalPlayer.state.Character:GetData("ICU").Items
		end,
	},
}

function Init()
	exports['pulsar-pedinteraction']:Add(
		"hospital-check-in-1",
		`u_f_m_miranda_02`,
		vector3(1125.869, -1531.991, 34.033),
		344.011,
		25.0,
		hospitalCheckin,
		"notes-medical",
		"WORLD_HUMAN_CLIPBOARD"
	)
	exports['pulsar-pedinteraction']:Add(
		"hospital-check-in-2",
		`s_f_y_scrubs_01`,
		vector3(1144.530, -1543.017, 34.033),
		274.930,
		25.0,
		hospitalCheckin,
		"notes-medical",
		"WORLD_HUMAN_CLIPBOARD"
	)
	exports['pulsar-pedinteraction']:Add(
		"hospital-check-in-3",
		`s_f_y_scrubs_01`,
		vector3(1135.842, -1539.658, 38.504),
		2.759,
		25.0,
		hospitalCheckin,
		"notes-medical",
		"WORLD_HUMAN_CLIPBOARD"
	)

	for k, v in ipairs(Config.BedModels) do
		exports.ox_target:addModel(v, {
			{
				icon = "stretcher",
				label = "Lay in Bed",
				event = "Hospital:Client:FindBed",
				distance = 1.5,
				canInteract = function()
					return LocalPlayer.state.isEscorting == nil
						and LocalPlayer.state.myEscorter == nil
						and not LocalPlayer.state.isHospitalized
				end,
			},
		})
	end

	for k, v in ipairs(Config.BedPolys) do
		exports.ox_target:addBoxZone({
			id = string.format("hospitalbed-%s", k),
			coords = v.center,
			size = vector3(v.length, v.width, 2.0),
			rotation = v.options.heading or 0,
			debug = false,
			minZ = v.options.minZ,
			maxZ = v.options.maxZ,
			options = {
				{
					icon = "stretcher",
					label = "Lay Down",
					event = "Hospital:Client:LaydownAnimation",
					onSelect = function()
						TriggerEvent("Hospital:Client:LaydownAnimation", v.laydown)
					end,
				},
			}
		})
	end
end

AddEventHandler("Hospital:Client:LaydownAnimation", function(hitting, coords)
	SetEntityCoords(LocalPlayer.state.ped, coords.x, coords.y, coords.z)
	SetEntityHeading(LocalPlayer.state.ped, coords.w)
	exports['pulsar-animations']:EmotesPlay("passout3", true)
	LocalPlayer.state:set("isHospitalized", true, true)

	while exports['pulsar-animations']:EmotesGet() == "passout3" do
		Wait(250)
	end

	-- print("Out of Bed")
	LocalPlayer.state:set("isHospitalized", false, true)
end)

AddEventHandler("Hospital:Client:RetreiveItems", function()
	exports["pulsar-core"]:ServerCallback("Hospital:RetreiveItems")
end)

AddEventHandler("Hospital:Client:HiddenRevive", function(entity, data)
	exports['pulsar-hud']:Progress({
		name = "ammo_action",
		duration = (math.random(5) + 15) * 1000,
		label = "Reviving",
		useWhileDead = false,
		canCancel = true,
		ignoreModifier = true,
		controlDisables = {
			disableMovement = false,
			disableCarMovement = false,
			disableMouse = false,
			disableCombat = true,
		},
		animation = {
			task = "CODE_HUMAN_MEDIC_KNEEL",
		},
	}, function(status)
		if not status then
			exports["pulsar-core"]:ServerCallback("Hospital:HiddenRevive", {}, function(s)
				if s then
					exports['pulsar-escort']:StopEscort()
				end
			end)
		end
	end)
end)

RegisterNetEvent("Characters:Client:Logout", function()
	if LocalPlayer.state.isHospitalized then
		LocalPlayer.state:set("isHospitalized", false, true)
	end
end)

AddEventHandler("Hospital:Client:CheckIn", function()
	exports['pulsar-hud']:ProgressWithStartEvent({
		name = "hospital_action",
		duration = 2500,
		label = "Checking In",
		useWhileDead = true,
		canCancel = true,
		ignoreModifier = true,
		controlDisables = {
			disableMovement = true,
			disableCarMovement = true,
			disableMouse = false,
			disableCombat = true,
		},
		animation = {
			anim = "clipboard_still",
		},
		disarm = true,
	}, function()
		LocalPlayer.state:set("isHospitalized", true, true)
	end, function(status)
		if not status then
			exports['pulsar-damage']:HospitalCheckIn()
		else
			LocalPlayer.state:set("isHospitalized", false, true)
		end
	end)
end)

RegisterNetEvent("Hospital:Client:GetOut", function()
	exports["pulsar-core"]:ServerCallback("Hospital:LeaveBed", {}, function()
		_doing = false
		LeaveBed()
	end)
end)

AddEventHandler("Hospital:Client:FindBed", function(event, data)
	if not event then
		return
	end
	exports['pulsar-damage']:HospitalFindBed(event.entity)
end)

RegisterNetEvent("Hospital:Client:ICU:Enter", function()
	if not IsScreenFadedOut() then
		DoScreenFadeOut(1000)
		while not IsScreenFadedOut() do
			Wait(10)
		end
	end

	local room = Config.ICUBeds[math.random(#Config.ICUBeds)]

	SetEntityCoords(LocalPlayer.state.ped, room[1], room[2], room[3], 0, 0, 0, false)
	Wait(100)
	SetEntityHeading(LocalPlayer.state.ped, room[4])
	_disabled = false

	Wait(1000)

	DoScreenFadeIn(1000)
	while not IsScreenFadedIn() do
		Wait(10)
	end
end)
