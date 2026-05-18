return {
	['testburger'] = {
		label = 'Test Burger',
		weight = 220,
		degrade = 60,
		client = {
			image = 'burger_chicken.png',
			status = { hunger = 200000 },
			anim = 'eating',
			prop = 'burger',
			usetime = 2500,
			export = 'ox_inventory_examples.testburger'
		},
		server = {
			export = 'ox_inventory_examples.testburger',
			test = 'what an amazingly delicious burger, amirite?'
		},
		buttons = {
			{
				label = 'Lick it',
				action = function(slot)
					print('You licked the burger')
				end
			},
			{
				label = 'Squeeze it',
				action = function(slot)
					print('You squeezed the burger :(')
				end
			},
			{
				label = 'What do you call a vegan burger?',
				group = 'Hamburger Puns',
				action = function(slot)
					print('A misteak.')
				end
			},
			{
				label = 'What do frogs like to eat with their hamburgers?',
				group = 'Hamburger Puns',
				action = function(slot)
					print('French flies.')
				end
			},
			{
				label = 'Why were the burger and fries running?',
				group = 'Hamburger Puns',
				action = function(slot)
					print('Because they\'re fast food.')
				end
			}
		},
		consume = 0.3
	},

	['bandage'] = {
		label = 'Bandage',
		weight = 115,
		client = {
			anim = { dict = 'missheistdockssetup1clipboard@idle_a', clip = 'idle_a', flag = 49 },
			prop = { model = `prop_rolled_sock_02`, pos = vec3(-0.14, -0.14, -0.08), rot = vec3(-50.0, -50.0, 0.0) },
			disable = { move = true, car = true, combat = true },
			usetime = 2500,
		}
	},

	['black_money'] = {
		label = 'Dirty Money',
	},

	['burger'] = {
		label = 'Burger',
		weight = 220,
		client = {
			status = { hunger = 200000 },
			anim = 'eating',
			prop = 'burger',
			usetime = 2500,
			notification = 'You ate a delicious burger'
		},
	},

	['sprunk'] = {
		label = 'Sprunk',
		weight = 350,
		client = {
			status = { thirst = 200000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ld_can_01`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
			usetime = 2500,
			notification = 'You quenched your thirst with a sprunk'
		}
	},

	['parachute'] = {
		label = 'Parachute',
		weight = 8000,
		stack = false,
		client = {
			anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
			usetime = 1500
		}
	},

	['garbage'] = {
		label = 'Garbage',
	},

	['paperbag'] = {
		label = 'Paper Bag',
		weight = 1,
		stack = false,
		close = false,
		consume = 0
	},

	['identification'] = {
		label = 'Identification',
		client = {
			image = 'card_id.png'
		}
	},

	['panties'] = {
		label = 'Knickers',
		weight = 10,
		consume = 0,
		client = {
			status = { thirst = -100000, stress = -25000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_cs_panties_02`, pos = vec3(0.03, 0.0, 0.02), rot = vec3(0.0, -13.5, -1.5) },
			usetime = 2500,
		}
	},

	['lockpick'] = {
		label = 'Lockpick',
		weight = 160,
	},

	['phone'] = {
		label = 'Phone',
		weight = 190,
		stack = false,
		consume = 0,
		client = {
			add = function(total)
				if total > 0 then
					pcall(function() return exports.npwd:setPhoneDisabled(false) end)
				end
			end,

			remove = function(total)
				if total < 1 then
					pcall(function() return exports.npwd:setPhoneDisabled(true) end)
				end
			end
		}
	},

	['money'] = {
		label = 'Money',
	},

	['mustard'] = {
		label = 'Mustard',
		weight = 500,
		client = {
			status = { hunger = 25000, thirst = 25000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_food_mustard`, pos = vec3(0.01, 0.0, -0.07), rot = vec3(1.0, 1.0, -1.5) },
			usetime = 2500,
			notification = 'You.. drank mustard'
		}
	},

	['water'] = {
		label = 'Water',
		weight = 500,
		client = {
			status = { thirst = 200000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ld_flow_bottle`, pos = vec3(0.03, 0.03, 0.02), rot = vec3(0.0, 0.0, -1.5) },
			usetime = 2500,
			cancel = true,
			notification = 'You drank some refreshing water'
		}
	},

	['radio'] = {
		label = 'Radio',
		weight = 1000,
		stack = false,
		allowArmed = true
	},

	['armour'] = {
		label = 'Bulletproof Vest',
		weight = 3000,
		stack = false,
		client = {
			anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
			usetime = 3500
		}
	},

	['clothing'] = {
		label = 'Clothing',
		consume = 0,
	},

	['mastercard'] = {
		label = 'Fleeca Card',
		stack = false,
		weight = 10,
		client = {
			image = 'card_bank.png'
		}
	},

	['scrapmetal'] = {
		label = 'Scrap Metal',
		weight = 80,
	},

	["radar_scrambler"] = {
        label = "Radar scrambler",
        weight = 50,
        stack = true
    },

	-- prp-boosting
    ['bolt_cutter'] = { label = 'Bolt Cutter', weight = 500, stack = false },
    ['fake_id'] = { label = 'Fake ID', weight = 50, stack = false },
    ['empty_fake_id'] = { label = 'Blank Fake ID', weight = 50, stack = true },
    ['pdm_blowtorch'] = { label = 'Blowtorch', weight = 300, stack = false },
    ['diving_angle_grinder'] = { label = 'Angle Grinder', weight = 800, stack = false },
    ['boosting_bank_key'] = { label = 'Bank Key', weight = 50, stack = false },
    ['boosting_jewelery_key'] = { label = 'Jewelry Key', weight = 50, stack = false },
    ['boosting_pdm_key'] = { label = 'PDM Key', weight = 50, stack = false },
    ['boosting_obd_d'] = { label = 'Very Basic OBD Tools', weight = 100, stack = false },
    ['boosting_obd_c'] = { label = 'Basic OBD Tools', weight = 100, stack = false },
    ['boosting_obd_b'] = { label = 'Semi Advanced OBD Tools', weight = 100, stack = false },
    ['boosting_obd_a'] = { label = 'Advanced OBD Tools', weight = 100, stack = false },
    ['boosting_obd_s'] = { label = 'Premium OBD Tools', weight = 100, stack = false },
    ['boosting_obd_x'] = { label = 'OBD Tools', weight = 100, stack = false },
    ['boosting_vinscratch_d'] = { label = 'Vin Scratch Contract (D)', weight = 10, stack = true },
    ['boosting_vinscratch_c'] = { label = 'Vin Scratch Contract (C)', weight = 10, stack = true },
    ['boosting_vinscratch_b'] = { label = 'Vin Scratch Contract (B)', weight = 10, stack = true },
    ['boosting_vinscratch_a'] = { label = 'Vin Scratch Contract (A)', weight = 10, stack = true },
    ['boosting_vinscratch_s'] = { label = 'Vin Scratch Contract (S)', weight = 10, stack = true },
    ['boosting_contract_d'] = { label = 'Boosting Contract (D)', weight = 10, stack = true },
    ['boosting_contract_c'] = { label = 'Boosting Contract (C)', weight = 10, stack = true },
    ['boosting_contract_b'] = { label = 'Boosting Contract (B)', weight = 10, stack = true },
    ['boosting_contract_a'] = { label = 'Boosting Contract (A)', weight = 10, stack = true },
    ['boosting_contract_s'] = { label = 'Boosting Contract (S)', weight = 10, stack = true },
    ['boosting_scrap'] = { label = 'Scrap', weight = 100, stack = false },
    ['boosting_scrap_bonnet'] = { label = 'Bonnet', weight = 100, stack = false },
    ['boosting_scrap_boot'] = { label = 'Boot', weight = 100, stack = false },
    ['boosting_scrap_door_dside_f'] = { label = 'Door', weight = 100, stack = false },
    ['boosting_scrap_door_dside_r'] = { label = 'Door', weight = 100, stack = false },
    ['boosting_scrap_door_pside_f'] = { label = 'Door', weight = 100, stack = false },
    ['boosting_scrap_door_pside_r'] = { label = 'Door', weight = 100, stack = false },
    ['boosting_scrap_wheel_lf'] = { label = 'Wheel', weight = 100, stack = false },
    ['boosting_scrap_wheel_lr'] = { label = 'Wheel', weight = 100, stack = false },
    ['boosting_scrap_wheel_rf'] = { label = 'Wheel', weight = 100, stack = false },
    ['boosting_scrap_wheel_rr'] = { label = 'Wheel', weight = 100, stack = false },
    ['boosting_hack_a'] = { label = 'Green Pendrive', weight = 10, stack = true },
    ['boosting_hack_b'] = { label = 'Blue Pendrive', weight = 10, stack = true },
    ['boosting_hack_c'] = { label = 'Aqua Pendrive', weight = 10, stack = true },
    ['boosting_hack_d'] = { label = 'White Pendrive', weight = 10, stack = true },
    ['boosting_hack_s'] = { label = 'Purple Pendrive', weight = 10, stack = true },
    ['boosting_hack_x'] = { label = 'Red Pendrive', weight = 10, stack = true },
    ['boosting_tablet'] = { label = 'Boosting Tablet', weight = 100, stack = false },

    -- prp-farming
    ['farm_pot_small'] = { label = 'Small Pot', weight = 500 },
    ['farm_pot_medium'] = { label = 'Medium Pot', weight = 750 },
    ['farm_pot_large'] = { label = 'Large Pot', weight = 1000 },
    ['farm_water_can'] = { label = 'Watering Can', weight = 300 },
    ['farm_fertilizer'] = { label = 'Fertilizer', weight = 200 },
    ['seeds_lettuce'] = { label = 'Lettuce Seeds', weight = 50 },
    ['seeds_tomato'] = { label = 'Tomato Seeds', weight = 50 },
    ['seeds_strawberry'] = { label = 'Strawberry Seeds', weight = 50 },
    ['seeds_grape'] = { label = 'Grape Seeds', weight = 50 },
    ['seeds_cucumber'] = { label = 'Cucumber Seeds', weight = 50 },
    ['seeds_eggplant'] = { label = 'Eggplant Seeds', weight = 50 },
    ['seeds_onion'] = { label = 'Onion Seeds', weight = 50 },
    ['seeds_potato'] = { label = 'Potato Seeds', weight = 50 },
    ['seeds_watermelon'] = { label = 'Watermelon Seeds', weight = 50 },
    ['seeds_banana'] = { label = 'Banana Seeds', weight = 50 },
    ['seeds_apple'] = { label = 'Apple Seeds', weight = 50 },
    ['seeds_wheat'] = { label = 'Wheat Seeds', weight = 50 },
    ['seeds_soy'] = { label = 'Soy Seeds', weight = 50 },
    ['farm_lettuce'] = { label = 'Organic Lettuce', weight = 200 },
    ['farm_tomato'] = { label = 'Organic Tomato', weight = 200 },
    ['farm_strawberry'] = { label = 'Organic Strawberry', weight = 200 },
    ['farm_grape'] = { label = 'Organic Grape', weight = 200 },
    ['farm_cucumber'] = { label = 'Organic Cucumber', weight = 200 },
    ['farm_eggplant'] = { label = 'Organic Eggplant', weight = 200 },
    ['farm_onion'] = { label = 'Organic Onion', weight = 200 },
    ['farm_potato'] = { label = 'Organic Potato', weight = 200 },
    ['farm_watermelon'] = { label = 'Organic Watermelon', weight = 200 },
    ['farm_banana'] = { label = 'Organic Banana', weight = 200 },
    ['farm_apple'] = { label = 'Organic Apple', weight = 200 },
    ['farm_wheat'] = { label = 'Organic Wheat', weight = 200 },
    ['farm_soy'] = { label = 'Organic Soy Bean', weight = 200 },

    -- prp-fishing
    ['basic_fishing_rod'] = { label = 'Basic Fishing Rod', weight = 800 },
    ['sport_fishing_rod'] = { label = 'Sport Fishing Rod', weight = 1000 },
    ['professional_fishing_rod'] = { label = 'Professional Fishing Rod', weight = 1200 },
    ['prodigy_fishing_rod'] = { label = 'Prodigy Fishing Rod', weight = 1400 },
    ['aqua_fishing_rod'] = { label = 'Aqua Fishing Rod', weight = 1500 },
    ['sunset_fishing_rod'] = { label = 'Sunset Fishing Rod', weight = 1500 },
    ['golden_fishing_rod'] = { label = 'Golden Fishing Rod', weight = 1500 },
    ['fishing_bait_worm'] = { label = 'Worm Bait', weight = 10 },
    ['fishing_bait_lugworm'] = { label = 'Lugworm Bait', weight = 10 },
    ['fishing_bait_radiated'] = { label = 'Radiated Bait', weight = 10 },
    ['small_bullhead'] = { label = 'Bullhead', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_bullhead'] = { label = 'Bullhead', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_bullhead'] = { label = 'Bullhead', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_carp'] = { label = 'Carp', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_carp'] = { label = 'Carp', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_carp'] = { label = 'Carp', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_catfish'] = { label = 'Catfish', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_catfish'] = { label = 'Catfish', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_catfish'] = { label = 'Catfish', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_perch'] = { label = 'Perch', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_perch'] = { label = 'Perch', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_perch'] = { label = 'Perch', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_rainbow_trout'] = { label = 'Rainbow Trout', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_rainbow_trout'] = { label = 'Rainbow Trout', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_rainbow_trout'] = { label = 'Rainbow Trout', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_northern_pike'] = { label = 'Northern Pike', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_northern_pike'] = { label = 'Northern Pike', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_northern_pike'] = { label = 'Northern Pike', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_atlantic_croaker'] = { label = 'Atlantic Croaker', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_atlantic_croaker'] = { label = 'Atlantic Croaker', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_atlantic_croaker'] = { label = 'Atlantic Croaker', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_atlantic_mackerel'] = { label = 'Atlantic Mackerel', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_atlantic_mackerel'] = { label = 'Atlantic Mackerel', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_atlantic_mackerel'] = { label = 'Atlantic Mackerel', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_flounder'] = { label = 'Flounder', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_flounder'] = { label = 'Flounder', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_flounder'] = { label = 'Flounder', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_red_mullet'] = { label = 'Red Mullet', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_red_mullet'] = { label = 'Red Mullet', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_red_mullet'] = { label = 'Red Mullet', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_sardine'] = { label = 'Sardine', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_sardine'] = { label = 'Sardine', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_sardine'] = { label = 'Sardine', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_red_snapper'] = { label = 'Red Snapper', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_red_snapper'] = { label = 'Red Snapper', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_red_snapper'] = { label = 'Red Snapper', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_salmon'] = { label = 'Salmon', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_salmon'] = { label = 'Salmon', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_salmon'] = { label = 'Salmon', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_striped_bass'] = { label = 'Striped Bass', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_striped_bass'] = { label = 'Striped Bass', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_striped_bass'] = { label = 'Striped Bass', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_tuna'] = { label = 'Tuna', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_tuna'] = { label = 'Tuna', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_tuna'] = { label = 'Tuna', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_breamfish'] = { label = 'Bream Fish', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_breamfish'] = { label = 'Bream Fish', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_breamfish'] = { label = 'Bream Fish', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_hake'] = { label = 'Hake', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_hake'] = { label = 'Hake', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_hake'] = { label = 'Hake', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_barracuda'] = { label = 'Barracuda', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_barracuda'] = { label = 'Barracuda', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_barracuda'] = { label = 'Barracuda', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_coralgrouper'] = { label = 'Coral Grouper', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_coralgrouper'] = { label = 'Coral Grouper', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_coralgrouper'] = { label = 'Coral Grouper', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_drumfish'] = { label = 'Drum Fish', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_drumfish'] = { label = 'Drum Fish', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_drumfish'] = { label = 'Drum Fish', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_jellyfish'] = { label = 'Blue Jellyfish', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_jellyfish'] = { label = 'Blue Jellyfish', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_jellyfish'] = { label = 'Blue Jellyfish', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_jellyfish_orange'] = { label = 'Orange Jellyfish', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_jellyfish_orange'] = { label = 'Orange Jellyfish', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_jellyfish_orange'] = { label = 'Orange Jellyfish', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_jellyfish_red'] = { label = 'Red Jellyfish', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_jellyfish_red'] = { label = 'Red Jellyfish', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_jellyfish_red'] = { label = 'Red Jellyfish', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_jellyfish_green'] = { label = 'Green Jellyfish', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_jellyfish_green'] = { label = 'Green Jellyfish', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_jellyfish_green'] = { label = 'Green Jellyfish', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_jellyfish_pink'] = { label = 'Pink Jellyfish', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_jellyfish_pink'] = { label = 'Pink Jellyfish', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_jellyfish_pink'] = { label = 'Pink Jellyfish', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_jellyfish_purple'] = { label = 'Purple Jellyfish', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_jellyfish_purple'] = { label = 'Purple Jellyfish', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_jellyfish_purple'] = { label = 'Purple Jellyfish', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_jellyfish_rainbow'] = { label = 'Rainbow Jellyfish', weight = 300, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_jellyfish_rainbow'] = { label = 'Rainbow Jellyfish', weight = 300, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_jellyfish_rainbow'] = { label = 'Rainbow Jellyfish', weight = 300, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_golden_fish'] = { label = 'Golden Fish', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_golden_fish'] = { label = 'Golden Fish', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_golden_fish'] = { label = 'Golden Fish', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_atlantic_croaker_rad'] = { label = 'Radiated Atlantic Croaker', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_atlantic_croaker_rad'] = { label = 'Radiated Atlantic Croaker', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_atlantic_croaker_rad'] = { label = 'Radiated Atlantic Croaker', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_barracuda_rad'] = { label = 'Radiated Barracuda', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_barracuda_rad'] = { label = 'Radiated Barracuda', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_barracuda_rad'] = { label = 'Radiated Barracuda', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_breamfish_rad'] = { label = 'Radiated Breamfish', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_breamfish_rad'] = { label = 'Radiated Breamfish', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_breamfish_rad'] = { label = 'Radiated Breamfish', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_bullhead_rad'] = { label = 'Radiated Bullhead', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_bullhead_rad'] = { label = 'Radiated Bullhead', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_bullhead_rad'] = { label = 'Radiated Bullhead', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_carp_rad'] = { label = 'Radiated Carp', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_carp_rad'] = { label = 'Radiated Carp', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_carp_rad'] = { label = 'Radiated Carp', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_catfish_rad'] = { label = 'Radiated Catfish', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_catfish_rad'] = { label = 'Radiated Catfish', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_catfish_rad'] = { label = 'Radiated Catfish', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_coralgrouper_rad'] = { label = 'Radiated Coral Grouper', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_coralgrouper_rad'] = { label = 'Radiated Coral Grouper', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_coralgrouper_rad'] = { label = 'Radiated Coral Grouper', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_drumfish_rad'] = { label = 'Radiated Drumfish', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_drumfish_rad'] = { label = 'Radiated Drumfish', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_drumfish_rad'] = { label = 'Radiated Drumfish', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_flounder_rad'] = { label = 'Radiated Flounder', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_flounder_rad'] = { label = 'Radiated Flounder', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_flounder_rad'] = { label = 'Radiated Flounder', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_hake_rad'] = { label = 'Radiated Hake', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_hake_rad'] = { label = 'Radiated Hake', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_hake_rad'] = { label = 'Radiated Hake', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_northern_pike_rad'] = { label = 'Radiated Northern Pike', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_northern_pike_rad'] = { label = 'Radiated Northern Pike', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_northern_pike_rad'] = { label = 'Radiated Northern Pike', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_perch_rad'] = { label = 'Radiated Perch', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_perch_rad'] = { label = 'Radiated Perch', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_perch_rad'] = { label = 'Radiated Perch', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_rainbow_trout_rad'] = { label = 'Radiated Rainbow Trout', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_rainbow_trout_rad'] = { label = 'Radiated Rainbow Trout', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_rainbow_trout_rad'] = { label = 'Radiated Rainbow Trout', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_red_mullet_rad'] = { label = 'Radiated Red Mullet', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_red_mullet_rad'] = { label = 'Radiated Red Mullet', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_red_mullet_rad'] = { label = 'Radiated Red Mullet', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_red_snapper_rad'] = { label = 'Radiated Red Snapper', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_red_snapper_rad'] = { label = 'Radiated Red Snapper', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_red_snapper_rad'] = { label = 'Radiated Red Snapper', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_salmon_rad'] = { label = 'Radiated Salmon', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_salmon_rad'] = { label = 'Radiated Salmon', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_salmon_rad'] = { label = 'Radiated Salmon', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_sardine_rad'] = { label = 'Radiated Sardine', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_sardine_rad'] = { label = 'Radiated Sardine', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_sardine_rad'] = { label = 'Radiated Sardine', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_striped_bass_rad'] = { label = 'Radiated Striped Bass', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_striped_bass_rad'] = { label = 'Radiated Striped Bass', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_striped_bass_rad'] = { label = 'Radiated Striped Bass', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['small_tuna_rad'] = { label = 'Radiated Tuna', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['medium_tuna_rad'] = { label = 'Radiated Tuna', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['large_tuna_rad'] = { label = 'Radiated Tuna', weight = 225, buttons = { { label = 'Cut Fish', action = function(slot) TriggerServerEvent('prp-fishing:server:cutFish', slot) end } } },
    ['fishing_boot'] = { label = 'Fishing Boot', weight = 1000 },
    ['fish_meat'] = { label = 'Fish Meat', weight = 100 },
    ['pr_trophy_fish_january'] = { label = 'Fishing Trophy (January)', weight = 2000 },
    ['pr_trophy_fish_february'] = { label = 'Fishing Trophy (February)', weight = 2000 },
    ['pr_trophy_fish_march'] = { label = 'Fishing Trophy (March)', weight = 2000 },
    ['pr_trophy_fish_april'] = { label = 'Fishing Trophy (April)', weight = 2000 },
    ['pr_trophy_fish_may'] = { label = 'Fishing Trophy (May)', weight = 2000 },
    ['pr_trophy_fish_june'] = { label = 'Fishing Trophy (June)', weight = 2000 },
    ['pr_trophy_fish_july'] = { label = 'Fishing Trophy (July)', weight = 2000 },
    ['pr_trophy_fish_august'] = { label = 'Fishing Trophy (August)', weight = 2000 },
    ['pr_trophy_fish_september'] = { label = 'Fishing Trophy (September)', weight = 2000 },
    ['pr_trophy_fish_october'] = { label = 'Fishing Trophy (October)', weight = 2000 },
    ['pr_trophy_fish_november'] = { label = 'Fishing Trophy (November)', weight = 2000 },
    ['pr_trophy_fish_december'] = { label = 'Fishing Trophy (December)', weight = 2000 },

    -- prp-lumberjack
    ['oak_log'] = { label = 'Low Softwood Log', weight = 10000, stack = false },
    ['cedar_log'] = { label = 'Medium Softwood Log', weight = 10000, stack = false },
    ['pine_log'] = { label = 'High Softwood Log', weight = 10000, stack = false },
    ['olive_log'] = { label = 'Hardwood Log', weight = 10000, stack = false },
    ['forest_tree_log'] = { label = 'Hard Hardwood Log', weight = 10000, stack = false },
    ['oak_plank'] = { label = 'Oak Plank', weight = 100, stack = 50 },
    ['cedar_plank'] = { label = 'Medium Softwood Plank', weight = 100, stack = 50 },
    ['pine_plank'] = { label = 'High Softwood Plank', weight = 100, stack = 50 },
    ['olive_plank'] = { label = 'Hardwood Plank', weight = 100, stack = 50 },
    ['forest_tree_plank'] = { label = 'Hard Hardwood Plank', weight = 100, stack = 50 },

    -- prp-metaldetector
    ['metaldetector'] = { label = 'Metal Detector', weight = 1500 },
    ['treasure_chest'] = { label = 'Treasure Chest', weight = 500 },
    ['treasure_key'] = { label = 'Treasure Key', weight = 100 },
    ['gold_coin'] = { label = 'Gold Coin', weight = 50, stack = 99 },
    ['gold'] = { label = 'Gold', weight = 500, stack = 50 },
    ['silver'] = { label = 'Silver', weight = 500, stack = 50 },

    -- prp-mining
    ['iron_ore'] = { label = 'Iron Ore', weight = 500, stack = 50 },
    ['copper_ore'] = { label = 'Copper Ore', weight = 500, stack = 50 },
    ['zinc_ore'] = { label = 'Zinc Ore', weight = 500, stack = 50 },
    ['aluminium_ore'] = { label = 'Aluminium Ore', weight = 500, stack = 50 },
    ['lithium_ore'] = { label = 'Lithium Ore', weight = 500, stack = 50 },
    ['nickel_ore'] = { label = 'Nickel Ore', weight = 500, stack = 50 },
    ['magnesium_ore'] = { label = 'Magnesium Ore', weight = 500, stack = 50 },
    ['gold_ore'] = { label = 'Gold Ore', weight = 500, stack = 50 },
    ['diamond_ore'] = { label = 'Diamond Ore', weight = 500, stack = 50 },
    ['limestone_ore'] = { label = 'Limestone Ore', weight = 500, stack = 50 },
    ['basic_looking_ore'] = { label = 'Stone Ore', weight = 500, stack = 50 },
    ['gem_ore'] = { label = 'Gem Ore', weight = 500, stack = 50 },
    ['zinc'] = { label = 'Zinc', weight = 500, stack = 50 },
    ['aluminium'] = { label = 'Aluminium', weight = 500, stack = 50 },
    ['nickel'] = { label = 'Nickel', weight = 500, stack = 50 },
    ['magnesium'] = { label = 'Magnesium', weight = 500, stack = 50 },
    ['diamond'] = { label = 'Diamond', weight = 500, stack = 50 },
    ['limestone'] = { label = 'Limestone', weight = 500, stack = 50 },
    ['basic_looking'] = { label = 'Stone', weight = 500, stack = 50 },
    ['gem'] = { label = 'Gem', weight = 500, stack = 50 },
    ['sapphire_gem'] = { label = 'Sapphire', weight = 100, stack = 50 },
    ['ruby_gem'] = { label = 'Ruby', weight = 100, stack = 50 },
    ['emerald_gem'] = { label = 'Emerald', weight = 100, stack = 50 },
    ['topaz_gem'] = { label = 'Topaz', weight = 100, stack = 50 },

    -- prp-notebook
    ['notebook'] = { label = 'Notebook', weight = 200, buttons = { { label = 'Duplicate', action = function(slot) TriggerServerEvent('prp-notebook:server:duplicateNotebook', slot) end } } },

    -- prp-policeutils
    ['spikesbox'] = { label = 'Spike Strip Box', weight = 2000, stack = false },
    ['spikebox_pilot'] = { label = 'Spike Strip Remote', weight = 200, stack = false },
    ['placeable_gps'] = { label = 'GPS Tracker', weight = 100, stack = false },
    ['shootable_gps'] = { label = 'GPS Tracker (Shootable)', weight = 50, stack = true },

    -- prp-pressurewash
    ['pressurewash'] = { label = 'Pressure Wash Generator', weight = 5000, stack = false },
    ['petrolcan'] = { label = 'Petrol Can', weight = 1000, stack = false },
    ['watercanister'] = { label = 'Water Canister', weight = 1000, stack = false },

    -- prp-racing
    ['racing_tablet'] = { label = 'Racing Tablet', weight = 500, stack = false },
    ['pink_slip'] = { label = 'Pink Slip Claim', weight = 5, stack = false },

    -- prp-scenes
    ['spray_can'] = { label = 'Spray Can', weight = 1, stack = false },
    ['spray_remover'] = { label = 'Spray Remover', weight = 1, stack = false },

    -- prp-security
    ['security_camera'] = { label = 'Security Camera', weight = 0, stack = false },
    ['motion_sensor'] = { label = 'Motion Sensor', weight = 0, stack = false },
    ['privacy_tool'] = { label = 'Device Pry Tool', weight = 0, stack = false },

    -- prp-aerialrun
    ['ar_pendrive_a'] = { label = 'Encrypted Pendrive', weight = 50, stack = false },
    ['ar_pendrive_b'] = { label = 'Decrypted Pendrive', weight = 50, stack = false },
    ['ar_start_item'] = { label = 'Supply Drop Pass', weight = 50, stack = false },

    -- prp-atmrob
    ['atm_bomb'] = { label = 'Small Explosive', weight = 200, stack = false },
    ['metal_rope'] = { label = 'Metal Rope', weight = 500, stack = false },

    -- prp-drugs
    ['drugs_pot_small'] = { label = 'Small Drug Pot', weight = 1000, stack = false },
    ['drugs_pot_medium'] = { label = 'Medium Drug Pot', weight = 2000, stack = false },
    ['drugs_pot_large'] = { label = 'Large Drug Pot', weight = 3000, stack = false },
    ['drugs_water_can'] = { label = 'Watering Can', weight = 500, stack = false },
    ['drugs_fertilizer'] = { label = 'Fertilizer', weight = 1000, stack = false },
    ['seeds_weed_1a'] = { label = 'Regular Grape Ape Seed', weight = 100 },
    ['seeds_weed_1b'] = { label = 'Cherry Kush Seed', weight = 100 },
    ['seeds_weed_2a'] = { label = 'Martian Candy Seed', weight = 100 },
    ['seeds_weed_2b'] = { label = 'Exodus Seed', weight = 100 },
    ['seeds_weed_2c'] = { label = 'Headband Seed', weight = 100 },
    ['seeds_cocaine'] = { label = 'Cocaine Seeds', weight = 100 },
    ['weed_1a'] = { label = 'Crop of Regular Grape Ape', weight = 100 },
    ['weed_1b'] = { label = 'Crop of Cherry Kush', weight = 100 },
    ['weed_2a'] = { label = 'Crop of Martian Candy', weight = 100 },
    ['weed_2b'] = { label = 'Crop of Exodus', weight = 100 },
    ['weed_2c'] = { label = 'Crop of Headband', weight = 100 },
    ['cocaine_leaf'] = { label = 'Coca Leaf', weight = 100 },
    ['rolling_paper'] = { label = 'Rolling Paper', weight = 0 },
    ['joint_1a'] = { label = '(Joint) Regular Grape Ape', weight = 200 },
    ['joint_1b'] = { label = '(Joint) Cherry Kush', weight = 200 },
    ['joint_2a'] = { label = '(Joint) Martian Candy', weight = 200 },
    ['joint_2b'] = { label = '(Joint) Exodus', weight = 200 },
    ['joint_2c'] = { label = '(Joint) Headband', weight = 200 },
    ['cocaine_container'] = { label = 'Mixing Container', weight = 500, stack = false, close = true, buttons = { { label = 'Shake', action = function(slot) TriggerServerEvent('prp-drugs:server:cocaine:shakeContainer', slot) end } } },
    ['cocaine_solvent'] = { label = 'Solvent', weight = 1000 },
    ['cocaine_drying_rack'] = { label = 'Drying Rack', weight = 15000, stack = false },
    ['cocaine_paste'] = { label = 'Coca Paste', weight = 100 },
    ['cocaine_smelter'] = { label = 'Smelting Furnace', weight = 25000, stack = false },
    ['limestone_dust'] = { label = 'Limestone Dust', weight = 100 },
    ['cocaine_powder'] = { label = 'Coca Powder', weight = 100 },
    ['cocaine_brick'] = { label = 'Cocaine Brick', weight = 1000, stack = false },
    ['cocaine'] = { label = 'Cocaine', weight = 100, stack = false },
    ['wood_log'] = { label = 'Wood Log', weight = 2300, stack = false },
    ['wood_plank'] = { label = 'Wood Plank', weight = 1600, stack = false },
    ['meth_kit'] = { label = 'Lab Kit', weight = 20000, stack = false },
    ['meth_cooker_low'] = { label = 'Small Meth Cooker', weight = 20000, stack = false },
    ['meth_cooker_mid'] = { label = 'Medium Meth Cooker', weight = 20000, stack = false },
    ['meth_cooker_high'] = { label = 'Large Meth Cooker', weight = 20000, stack = false },
    ['meth_cooler_low'] = { label = 'Small Meth Cooler', weight = 5000, stack = false },
    ['meth_cooler_mid'] = { label = 'Medium Meth Cooler', weight = 5000, stack = false },
    ['meth_cooler_high'] = { label = 'Large Meth Cooler', weight = 5000, stack = false },
    ['meth_explosive'] = { label = 'Explosive', weight = 2000, stack = false },
    ['meth'] = { label = 'Meth', weight = 100 },
    ['meth_slop'] = { label = 'Wet Slop', weight = 0.05 },
    ['meth_hose'] = { label = 'Rubber Hose', weight = 1000 },
    ['meth_pseudo'] = { label = 'Pseudoephedrine Extract', weight = 5 },
    ['meth_redpowder'] = { label = 'Red Phosphorus Powder', weight = 5 },
    ['meth_lithium'] = { label = 'Lithium Strips', weight = 5 },
    ['meth_ammonia_barrel'] = { label = 'Barrel of Ammonia', weight = 50000 },
    ['meth_lab_card'] = { label = 'Laboratory Card', weight = 1, degrade = 2880, stack = false },

    -- prp-gun-smuggling
    ['gun_smuggling_contract_smg'] = { label = 'SMG Contract', weight = 10, stack = false },
    ['gun_smuggling_contract_smg_large'] = { label = 'Large SMG Contract', weight = 10, stack = false },
    ['gun_smuggling_contract_rifle'] = { label = 'Rifle Contract', weight = 10, stack = false },
    ['gun_smuggling_contract_chaos'] = { label = 'Rifle+ Contract', weight = 10, stack = false },
    ['gun_smuggling_crate'] = { label = 'Gun Crate', weight = 5000, stack = false },
    ['gun_parts'] = { label = 'Gun Parts', weight = 200, stack = true },
    ['military_gun_parts'] = { label = 'Military Gun Parts', weight = 200, stack = true },
    ['smg_slide'] = { label = 'SMG Slide', weight = 100, stack = true },
    ['smg_lower'] = { label = 'SMG Lower', weight = 100, stack = true },
    ['smg_upper'] = { label = 'SMG Upper', weight = 100, stack = true },
    ['smg_barrel'] = { label = 'SMG Barrel', weight = 100, stack = true },
    ['smg_grip'] = { label = 'SMG Grip', weight = 100, stack = true },
    ['smg_trigger'] = { label = 'SMG Trigger', weight = 100, stack = true },
    ['ammo_smg'] = { label = 'SMG Ammo', weight = 50, stack = true },
    ['blueprint_smg_parts'] = { label = 'Blueprint: SMG Parts', weight = 10, stack = true },
    ['blueprint_smg_minismg'] = { label = 'Blueprint: Mini SMG', weight = 10, stack = false },
    ['blueprint_smg_microsmg'] = { label = 'Blueprint: Micro SMG', weight = 10, stack = false },
    ['blueprint_smg_uzi'] = { label = 'Blueprint: Uzi', weight = 10, stack = false },
    ['blueprint_smg_smgpistol'] = { label = 'Blueprint: SMG Pistol', weight = 10, stack = false },
    ['blueprint_smg_machinepistol'] = { label = 'Blueprint: Machine Pistol', weight = 10, stack = false },
    ['blueprint_for_smg_basic_parts'] = { label = 'Blueprint: SMG Basic Parts', weight = 10, stack = true },
    ['blueprint_for_smg_semi_advanced_parts'] = { label = 'Blueprint: SMG Semi-Advanced Parts', weight = 10, stack = true },
    ['blueprint_for_smg_advanced_parts'] = { label = 'Blueprint: SMG Advanced Parts', weight = 10, stack = true },
    ['smg_medium_slide'] = { label = 'Medium SMG Slide', weight = 100, stack = true },
    ['smg_medium_lower'] = { label = 'Medium SMG Lower', weight = 100, stack = true },
    ['smg_medium_upper'] = { label = 'Medium SMG Upper', weight = 100, stack = true },
    ['smg_medium_barrel'] = { label = 'Medium SMG Barrel', weight = 100, stack = true },
    ['smg_medium_grip'] = { label = 'Medium SMG Grip', weight = 100, stack = true },
    ['smg_medium_trigger'] = { label = 'Medium SMG Trigger', weight = 100, stack = true },
    ['blueprint_smg_medium_parts'] = { label = 'Blueprint: Medium SMG Parts', weight = 10, stack = true },
    ['blueprint_smg_assaultsmg'] = { label = 'Blueprint: Assault SMG', weight = 10, stack = false },
    ['blueprint_smg_gusenberg'] = { label = 'Blueprint: Gusenberg', weight = 10, stack = false },
    ['blueprint_smg_smg_mk2'] = { label = 'Blueprint: SMG Mk II', weight = 10, stack = false },
    ['rifle_slide'] = { label = 'Rifle Slide', weight = 100, stack = true },
    ['rifle_lower'] = { label = 'Rifle Lower', weight = 100, stack = true },
    ['rifle_upper'] = { label = 'Rifle Upper', weight = 100, stack = true },
    ['rifle_barrel'] = { label = 'Rifle Barrel', weight = 100, stack = true },
    ['rifle_grip'] = { label = 'Rifle Grip', weight = 100, stack = true },
    ['rifle_trigger'] = { label = 'Rifle Trigger', weight = 100, stack = true },
    ['ammo_rifle'] = { label = 'Rifle Ammo', weight = 50, stack = true },
    ['blueprint_rifle_parts'] = { label = 'Blueprint: Rifle Parts', weight = 10, stack = true },
    ['blueprint_rifle_compactrifle'] = { label = 'Blueprint: Compact Rifle', weight = 10, stack = false },
    ['blueprint_rifle_assaultrifle'] = { label = 'Blueprint: Assault Rifle', weight = 10, stack = false },
    ['blueprint_rifle_bullpuprifle'] = { label = 'Blueprint: Bullpup Rifle', weight = 10, stack = false },
    ['blueprint_rifle_tacticalrifle'] = { label = 'Blueprint: Tactical Rifle', weight = 10, stack = false },
    ['blueprint_for_rifle_basic_parts'] = { label = 'Blueprint: Rifle Basic Parts', weight = 10, stack = true },
    ['blueprint_for_rifle_semi_advanced_parts'] = { label = 'Blueprint: Rifle Semi-Advanced Parts', weight = 10, stack = true },
    ['blueprint_for_rifle_advanced_parts'] = { label = 'Blueprint: Rifle Advanced Parts', weight = 10, stack = true },

    -- prp-horde
    ['horde_revive'] = { label = 'Horde Health Token', weight = 100 },
    ['horde_crate_key'] = { label = 'Horde Crate Key', weight = 100 },
    ['horde_small'] = { label = 'Horde Small Item', weight = 5 },
    ['horde_medium'] = { label = 'Horde Medium Item', weight = 8 },
    ['horde_big'] = { label = 'Horde Big Item', weight = 10 },

    -- prp-outposts
    ['outposts_exchange_card'] = { label = 'Exchange Access Card', weight = 10, stack = false, close = true },
    ['outposts_clue_taxi'] = { label = 'Taxi Receipt', weight = 10 },
    ['outposts_clue_delivery'] = { label = 'Delivery Note', weight = 10 },
    ['outposts_clue_washing'] = { label = 'Laundry Slip', weight = 10 },

    -- prp-pettycrime
    ['envelope'] = { label = 'Envelope', weight = 10 },
    ['catalog_envelope'] = { label = 'Catalog Envelope', weight = 20 },
    ['letter'] = { label = 'Letter', weight = 5 },
    ['pp_small_1'] = { label = 'Small Package', weight = 500, stack = false },
    ['pp_small_2'] = { label = 'Small Package', weight = 500, stack = false },
    ['pp_small_3'] = { label = 'Small Package', weight = 500, stack = false },
    ['pp_medium_1'] = { label = 'Medium Package', weight = 1000, stack = false },
    ['pp_large_1'] = { label = 'Large Package', weight = 2000, stack = false },

    -- prp-point-control
    ['point_control_contract'] = { label = 'Point Control Contract', weight = 10, stack = false },
    ['point_control_crate'] = { label = 'Capture Crate', weight = 500, stack = false },
    ['point_control_plans'] = { label = 'Point Control Plans', weight = 10, stack = false },
    ['point_control_map'] = { label = 'Map with Drop Points', weight = 10, stack = false },

    -- prp-seabattle
    ['seabattle_start'] = { label = 'Sea Battle Pass', weight = 10, stack = false },
    ['sb_boat_rope'] = { label = 'Rope', weight = 100, stack = false },

    -- prp-seahunt
    ['sea_hunt_start'] = { label = 'Blue Folder', weight = 100 },
    ['diving_rebreather'] = { label = 'Diving Rebreather', weight = 300 },

    -- prp-warehouse-robbery
    ['warehouse_entry'] = { label = 'Warehouse Entry', weight = 10, stack = false },
    ['warehouse_fuse'] = { label = 'Warehouse Fuse', weight = 50 },
    ['warehouse_bomb'] = { label = 'Warehouse Bomb', weight = 100, stack = false },
    ['ocean_run_entry'] = { label = 'Ocean Run Entry', weight = 10, stack = false },
    ['smuggling_nas'] = { label = 'NAS Device', weight = 2000, stack = false },
    ['smuggling_hdd'] = { label = 'Hard Drive', weight = 200 },
}
