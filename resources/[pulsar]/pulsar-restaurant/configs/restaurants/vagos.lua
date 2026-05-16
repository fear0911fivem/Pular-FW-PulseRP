table.insert(Config.Restaurants, {
	Name = "Vagos Clubhouse Bar",
	Job = "vagos",
	Benches = {
		bar = {
			label = "Bar",
			targeting = {
				actionString = "Making",
				icon = "martini-glass-citrus",
				poly = {
					coords = vector3(338.41, -1989.41, 24.21),
					w = 4.0,
					l = 0.8,
					options = {
						heading = 320,
						--debugPoly=true,
						minZ = 22.01,
						maxZ = 26.01,
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
			id = "vagos-clubhouse-pickup-1",
			coords = vector3(336.4, -1988.5, 24.21),
			width = 1.4,
			length = 0.8,
			options = {
				heading = 321,
				--debugPoly=true,
				minZ = 24.21,
				maxZ = 25.01,
			},
			data = {
				business = "vagos",
			},
		},
	},
	Warmers = false,
})
