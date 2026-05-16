table.insert(Config.Restaurants, {
	Name = "Ballers Clubhouse Bar",
	Job = "ballers",
	Benches = {
		bar = {
			label = "Bar",
			targeting = {
				actionString = "Making",
				icon = "martini-glass-citrus",
				poly = {
					coords = vector3(-1.38, -1825.94, 29.15),
					w = 0.6,
					l = 1.6,
					options = {
						heading = 320,
						--debugPoly=true,
						minZ = 29.95,
						maxZ = 30.95,
					},
				},
			},
			recipes = {
				_cocktailRecipies.raspberry_mimosa,
				_cocktailRecipies.pina_colada,
				_cocktailRecipies.bloody_mary,
				_cocktailRecipies.vodka_shot,
				_cocktailRecipies.whiskey_glass,
				--_cocktailRecipies.jaeger_bomb,
				-- _genericRecipies.glass_cock,
				-- _genericRecipies.lemonade,
			},
		},
	},
	IgnoreDuty = true,
	Pickups = {
		{
			id = "ballers-clubhouse-pickup-1",
			coords = vector3(-3.31, -1827.16, 29.15),
			width = 1.6,
			length = 1.0,
			options = {
				heading = 320,
				--debugPoly=true,
				minZ = 25.95,
				maxZ = 29.95,
			},
			data = {
				business = "ballers",
			},
		},
	},
	Warmers = false,
})
