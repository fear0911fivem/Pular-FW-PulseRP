local _vg = RobberyConfig.vangelico

local _alerted = nil
local _caseResetTime = nil
local _alarmSource = nil

local _alarmCoords = vector3(-630.732, -237.111, 38.078)

function StopVangelicoAlarm()
	if _alarmSource then
		TriggerClientEvent("Sounds:Client:Stop:Distance", -1, _alarmSource, "bank_alarm.ogg")
		_alarmSource = nil
	end
	GlobalState["Vangelico:Alarm"] = false
end

function PutShittyThingsOnCD()
	StopVangelicoAlarm()
	local time = _caseResetTime or os.time() + (60 * math.random(100, 140))
	GlobalState["Vangelico:State"] = 2
	GlobalState["Vangelico:InProgress"] = false
	for k, v in ipairs(_vg.cases) do
		local pId = string.format("Vangelico:Case:%s", k)
		GlobalState[pId] = time
	end

	CreateThread(function()
		while time > os.time() do
			Wait(5000)
		end
		for k, v in ipairs(_vg.cases) do
			local pId = string.format("Vangelico:Case:%s", k)
			GlobalState[pId] = nil
		end
		GlobalState["Vangelico:State"] = nil
	end)
end

function StartJewelryTimer()
	CreateThread(function()
		while os.time() < _caseResetTime do
			Wait(5000)
		end

		if GlobalState["Vangelico:State"] == 2 then
			_caseResetTime = nil
			return
		end

		PutShittyThingsOnCD()

		GlobalState["Vangelico:State"] = 2
		_caseResetTime = nil
	end)
end

AddEventHandler("Robbery:Server:Setup", function()
	GlobalState["VangelicoRequiredPd"] = _vg.requiredPolice
	GlobalState["VangelicoCases"] = _vg.cases

	CreateThread(function()
		GlobalState["Vangelico:State"] = 2
		while GetGameTimer() < _vg.serverStartWait do
			Wait(1000)
		end
		GlobalState["Vangelico:State"] = nil
	end)

	exports["pulsar-core"]:RegisterServerCallback("Robbery:Vangelico:BreakCase", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local pId = string.format("Vangelico:Case:%s", data)
		if
			(
				not GlobalState["AntiShitlord"]
				or os.time() >= GlobalState["AntiShitlord"]
				or GlobalState["Vangelico:InProgress"]
			)
			and (
				not GlobalState["RestartLockdown"]
				or (GlobalState["RestartLockdown"] and GlobalState["Vangelico:InProgress"])
			)
		then
			if GlobalState["RobberiesDisabled"] then
				exports['pulsar-hud']:Notification(source, "error",
					"Temporarily Disabled, Please See City Announcements",
					6000
				)
				return
			end
			if not GlobalState[pId] or GlobalState[pId] < os.time() and GlobalState["Vangelico:State"] ~= 2 then
				exports['pulsar-core']:LoggerInfo(
					"Robbery",
					string.format(
						"%s %s (%s) Broke Vangelico Case #%s",
						char:GetData("First"),
						char:GetData("Last"),
						char:GetData("SID"),
						data
					)
				)
				if not _caseResetTime then
					_caseResetTime = os.time() + (60 * math.random(100, 140))
					StartJewelryTimer()
					_alarmSource = source
					exports["pulsar-sounds"]:LoopLocation(source, _alarmCoords, 30.0, "bank_alarm.ogg", 0.15)
					GlobalState["Vangelico:Alarm"] = true
				end

				if not GlobalState["AntiShitlord"] or os.time() >= GlobalState["AntiShitlord"] then
					GlobalState["AntiShitlord"] = os.time() + (60 * math.random(10, 15))
				end
				GlobalState["Vangelico:InProgress"] = true

				GlobalState["Vangelico:State"] = 1
				GlobalState[pId] = _caseResetTime

				if _alerted == nil or _alerted < os.time() then
					exports['pulsar-robbery']:TriggerPDAlert(source, vector3(-630.732, -237.111, 38.078), "10-90",
						"Armed Robbery", {
							icon = 617,
							size = 0.9,
							color = 31,
							duration = (60 * 5),
						}, {
							icon = "gem",
							details = "Vangelico Jewelry",
						}, "vangelico")
					_alerted = os.time() + (60 * 60)
				end

				local luck = math.random(100)
				if luck >= 98 then
					if luck == 100 then
						--exports.ox_inventory:AddItem(char:GetData("SID"), "valuegoods", 1, {}, 1)
					end
					exports.ox_inventory:LootSetsGem(char:GetData("SID"), 1)
				end

				exports.ox_inventory:LootCustomWeightedSetWithCount(_vg.loot, char:GetData("SID"), 1)
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Robbery:Vangelico:SecureStore", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if _alerted ~= nil and _alerted >= os.time() then
			PutShittyThingsOnCD()
			GlobalState["Vangelico:State"] = 2
			exports['pulsar-hud']:Notification(source, "success", "Store Has Been Secure", 6000)
		else
			exports['pulsar-hud']:Notification(source, "error",
				"Unable To Secure Store, No Recent Crime Reported", 6000)
			exports['pulsar-core']:LoggerInfo(
				"Robbery",
				string.format(
					"%s %s (%s) Secured Vangelico",
					char:GetData("First"),
					char:GetData("Last"),
					char:GetData("SID")
				)
			)
			exports['pulsar-core']:LoggerWarn(
				"Characters",
				string.format(
					"Shitlord Cop Tried Securing Vangelico Without A Recent PD Alert %s %s (%s)",
					char:GetData("Name"),
					char:GetData("AccountID"),
					char:GetData("First"),
					char:GetData("Last"),
					char:GetData("SID")
				),
				{
					console = true,
					file = true,
					database = true,
					discord = {
						embed = true,
					},
				}
			)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Robbery:Vangelico:DisableAlarm", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char and Player(source).state.onDuty == "police" then
			if GlobalState["Vangelico:Alarm"] then
				StopVangelicoAlarm()
				exports['pulsar-hud']:Notification(source, "success", "Alarm Disabled", 5000)
			end
		end
	end)
end)
