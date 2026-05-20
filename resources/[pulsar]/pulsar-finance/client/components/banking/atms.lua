local atmObjects = {
	`prop_atm_01`,
	`prop_atm_02`,
	`prop_atm_03`,
	`prop_fleeca_atm`,
	`prop_atm_01_dam`,
	`hei_prop_atm`,
	`ch_prop_ch_atm01`
}

local atmPolys = {
	{
		center = vector3(240.93, 217.63, 106.28),
		length = 12.4,
		width = 1.0,
		options = {
			heading = 340,
			--debugPoly=true,
			minZ = 105.88,
			maxZ = 107.28,
		},
	},
	{
		center = vector3(264.32, 205.55, 106.29),
		length = 5.0,
		width = 1.0,
		options = {
			heading = 340,
			--debugPoly=true,
			minZ = 105.89,
			maxZ = 107.29,
		},
	},
	{
		center = vector3(-1314.81, -821.29, 16.78),
		length = 1.4,
		width = 0.4,
		options = {
			heading = 307,
			--debugPoly=true,
			minZ = 15.78,
			maxZ = 18.38,
		},
	},
	{
		center = vector3(-1313.04, -820.14, 16.78),
		length = 1.2,
		width = 0.4,
		options = {
			heading = 307,
			--debugPoly=true,
			minZ = 15.98,
			maxZ = 18.38,
		},
	},
	{
		center = vector3(-1311.39, -818.94, 16.78),
		length = 1.4,
		width = 0.4,
		options = {
			heading = 307,
			--debugPoly=true,
			minZ = 16.18,
			maxZ = 18.38,
		},
	},
}

function AddBankingATMs()
	for k, v in ipairs(atmObjects) do
		exports.ox_target:addModel(v, {
			{
				label = "Use ATM",
				icon = "dollar-sign",
				event = "Banking:Client:StartOpenATM",
				distance = 3.0,
			},
		})
	end

	for k, v in ipairs(atmPolys) do
		exports.ox_target:addBoxZone({
			id = "atm-" .. k,
			coords = v.center,
			size = vector3(v.length, v.width, 2.0),
			rotation = v.options.heading,
			debug = false,
			minZ = v.options.minZ,
			maxZ = v.options.maxZ,
			options = {
				{
					label = "Use ATM",
					icon = "dollar-sign",
					event = "Banking:Client:StartOpenATM",
					distance = 3.0,
				},
			}
		})
	end
end

AddEventHandler("Banking:Client:StartOpenATM", function(entityData)
	exports['pulsar-hud']:Progress({
		name = "atm_inserting",
		duration = 3000,
		label = "Inserting Card",
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
			animDict = "amb@prop_human_atm@male@idle_a",
			anim = "idle_b",
			flags = 49,
		},
		disarm = true,
	}, function(cancelled)
		if not cancelled then
			FinanceOpenBanking("ATM", {
				depositVisible = false,
				street = "ATM",
				maxWithdraw = 5000,
			})
		end
	end)
end)
