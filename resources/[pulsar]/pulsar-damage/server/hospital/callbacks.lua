function HospitalCallbacks()
	exports["pulsar-chat"]:RegisterCommand(
		"icu",
		function(source, args, rawCommand)
			if tonumber(args[1]) then
				local char = exports['pulsar-characters']:FetchBySID(tonumber(args[1]))
				if char ~= nil then
					exports['pulsar-damage']:HospitalICUSend(char:GetData("Source"))
					exports["pulsar-chat"]:SendSystemSingle(source,
						string.format("%s Has Been Admitted To ICU", args[1]))
				else
					exports["pulsar-chat"]:SendSystemSingle(source, "State ID Not Logged In")
				end
			else
				exports["pulsar-chat"]:SendSystemSingle(source, "Invalid Arguments")
			end
		end,
		{
			help = "Sends Patient To ICU, Where They Will Remain Until Released By Medical Staff",
			params = {
				{
					name = "Target",
					help = "State ID of target",
				},
			},
		},
		1,
		{
			{
				Id = "ems",
			},
		}
	)
	exports["pulsar-chat"]:RegisterCommand(
		"release",
		function(source, args, rawCommand)
			if tonumber(args[1]) then
				local char = exports['pulsar-characters']:FetchBySID(tonumber(args[1]))
				if char ~= nil and char:GetData("ICU") ~= nil and not char:GetData("ICU").Released then
					exports['pulsar-damage']:HospitalICURelease(char:GetData("Source"))
					exports["pulsar-chat"]:SendSystemSingle(source,
						string.format("%s Has Been Released From ICU", args[1]))
				else
					exports["pulsar-chat"]:SendSystemSingle(source, "State ID Not Logged In")
				end
			else
				exports["pulsar-chat"]:SendSystemSingle(source, "Invalid Arguments")
			end
		end,
		{
			help = "Releases a patient from ICU",
			params = {
				{
					name = "Target",
					help = "State ID of target",
				},
			},
		},
		1,
		{
			{
				Id = "ems",
			},
		}
	)

	exports["pulsar-core"]:RegisterServerCallback("Hospital:Treat", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local bed = exports['pulsar-damage']:HospitalRequestBed(source)

		local cost = 100
		-- if not GlobalState["Duty:ems"] or GlobalState["Duty:ems"] == 0 then
		-- 	cost = 100
		-- end

		exports['pulsar-finance']:BillingCharge(source, cost, "Medical Services",
			"Use of facilities at St. Fiacre Medical Center")

		local f = exports['pulsar-finance']:AccountsGetOrganization("ems")
		exports['pulsar-finance']:BalanceDeposit(f.Account, cost / 2, {
			type = "deposit",
			title = "Medical Treatment",
			description = string.format("Medical Bill For %s %s", char:GetData("First"), char:GetData("Last")),
			data = {},
		}, true)

		f = exports['pulsar-finance']:AccountsGetOrganization("government")
		exports['pulsar-finance']:BalanceDeposit(f.Account, cost / 2, {
			type = "deposit",
			title = "Medical Treatment",
			description = string.format("Medical Bill For %s %s", char:GetData("First"), char:GetData("Last")),
			data = {},
		}, true)

		cb(bed)
	end)

	exports["pulsar-core"]:RegisterServerCallback("Hospital:Respawn", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if os.time() >= Player(source).state.releaseTime then
			exports['pulsar-pwnzor']:TempPosIgnore(source)
			local bed = exports['pulsar-damage']:HospitalRequestBed(source)

			local cost = 100
			-- if not GlobalState["Duty:ems"] or GlobalState["Duty:ems"] == 0 then
			-- 	cost = 100
			-- end

			exports['pulsar-finance']:BillingCharge(source, cost, "Medical Services",
				"Use of facilities at St. Fiacre Medical Center")
			exports['pulsar-core']:LoggerInfo(
				"Robbery",
				string.format(
					"%s %s (%s) Respawned Via Local EMS",
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
						type = "info",
						webhook = GetConvar("discord_log_webhook", ""),
					},
				}
			)

			local f = exports['pulsar-finance']:AccountsGetOrganization("ems")
			exports['pulsar-finance']:BalanceDeposit(f.Account, cost / 2, {
				type = "deposit",
				title = "Medical Treatment",
				description = string.format("Medical Bill For %s %s", char:GetData("First"), char:GetData("Last")),
				data = {},
			}, true)

			f = exports['pulsar-finance']:AccountsGetOrganization("government")
			exports['pulsar-finance']:BalanceDeposit(f.Account, cost / 2, {
				type = "deposit",
				title = "Medical Treatment",
				description = string.format("Medical Bill For %s %s", char:GetData("First"), char:GetData("Last")),
				data = {},
			}, true)

			cb(bed)
		else
			cb(nil)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Hospital:FindBed", function(source, data, cb)
		cb(exports['pulsar-damage']:HospitalFindBed(source, data))
	end)

	exports["pulsar-core"]:RegisterServerCallback("Hospital:OccupyBed", function(source, data, cb)
		cb(exports['pulsar-damage']:HospitalOccupyBed(source, data))
	end)

	exports["pulsar-core"]:RegisterServerCallback("Hospital:LeaveBed", function(source, data, cb)
		cb(exports['pulsar-damage']:HospitalLeaveBed(source))
	end)

	exports["pulsar-core"]:RegisterServerCallback("Hospital:RetreiveItems", function(source, data, cb)
		exports['pulsar-damage']:HospitalICUGetItems(source)
	end)

	exports["pulsar-core"]:RegisterServerCallback("Hospital:HiddenRevive", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local p = Player(source).state
		if p.isEscorting ~= nil then
			local t = Player(p.isEscorting).state
			if t ~= nil and t.isDead then
				if exports['pulsar-finance']:CryptoExchangeRemove("MALD", char:GetData("CryptoWallet"), 20) then
					cb(true)
					local tChar = exports['pulsar-characters']:FetchCharacterSource(p.isEscorting)
					if tChar ~= nil then
						exports["pulsar-core"]:ClientCallback(tChar:GetData("Source"), "Damage:Heal", true)
					else
						exports['pulsar-hud']:Notification(source, "error", "Invalid Target")
					end
				else
					cb(false)
					exports['pulsar-hud']:Notification(source, "error", "Not Enough Crypto")
				end
			end
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Hospital:SpawnICU", function(source, data, cb)
		exports["pulsar-core"]:RoutePlayerToGlobalRoute(source)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		Player(source).state.ICU = false
		TriggerClientEvent("Hospital:Client:ICU:Enter", source)
		cb(true)
	end)
end
