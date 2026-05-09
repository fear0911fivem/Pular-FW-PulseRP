Config = {}

Config.Reputation = {
	id = "drug_dealer",
	label = "Drug Dealer",
	-- Set hidden = true to hide from generic reputation views (labor phone list uses RepView)
	hidden = false,
	levels = {
		{ label = "Rank 1", value = 1500 },
		{ label = "Rank 2", value = 3000 },
		{ label = "Rank 3", value = 6000 },
		{ label = "Rank 4", value = 9000 },
		{ label = "Rank 5", value = 12000 },
	},
}

Config.RepLevelPayMultiplier = 0.06


Config.Payout = {
	currency = "moneyroll", -- "money" | "moneyroll"
	moneyItem = "money",
	moneyrollItem = "moneyroll",
	dollarsPerRoll = 100,
	payRemainderAsMoney = true,
}

Config.Target = {
	label = "Offer drugs",
	icon = "fas fa-cannabis",
	distance = 2.2,
	optionName = "pulsar_drugsales_offer",
}

Config.SellCooldownSuccessMs = 5000
Config.SellCooldownFailMs = 0
Config.SamePedOfferCooldownMs = 90000

Config.BuyerAfterSale = {
	resumeWander = true,
	wanderRadius = 10.0,
	wanderBlend = 10,
}

Config.SaleDurationMs = 4500
Config.SaleMaxStartDistance = 3.6

Config.Menu = {
	cancelLabel = "Walk away",
}

Config.BuyerHold = {
	controlTimeoutMs = 900,
	standStillMs = 8000,
	useFreeze = true,
	facePlayerMs = 2200,
}

Config.PackageHandoff = {
	enabled = true,
	model = "prop_drug_package_02",
	bone = 57005,
	pos = { x = 0.1, y = 0.02, z = -0.02 },
	rot = { x = 10.0, y = 95.0, z = -90.0 },
}

Config.DefaultQuantity = 1

Config.Drugs = {
	{
		item = "weed_joint",
		label = "Weed joint",
		baseMin = 45,
		baseMax = 95,
		successChance = 0.72,
		repOnSuccess = 4,
		quantityWeights = {
			{ qty = 1, weight = 72 },
			{ qty = 2, weight = 20 },
			{ qty = 3, weight = 8 },
		},
	},
}

Config.PedFilters = {
	blockPlayers = true,
	blockDead = true,
	blockInVehicle = true,
	blockPlayerInVehicle = true,
	blacklistedModels = {
		"s_m_y_cop_01",
		"s_f_y_cop_01",
		"s_m_y_hwaycop_01",
		"s_m_y_sheriff_01",
		"s_f_y_sheriff_01",
		"s_m_y_ranger_01",
		"s_m_y_swat_01",
		"s_m_m_armoured_01",
		"s_m_m_armoured_02",
		"s_m_m_prisguard_01",
		"s_m_y_prismuscl_01",
		"s_m_y_prisoner_01",
		"u_m_y_prisoner_01",
	},
}

Config.PoliceAlert = {
	enabled = true,
	chanceOnFail = 5,
	jobs = { "police" },
	blipSprite = 161,
	blipColour = 1,
	blipScale = 1.0,
	blipLabel = "Possible drug sale",
	hudMessage = "Report: suspicious hand-to-hand exchange",
	notifyPoliceDuration = 6500,
	blipDurationMs = 90000,
}

Config.Anim = {
	dict = "mp_common",
	name = "givetake1_a",
	-- 48 = upper body + control; 49 adds repeat and loops the clip for the whole sale duration.
	flag = 48,
}
