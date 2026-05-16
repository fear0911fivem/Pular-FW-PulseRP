table.insert(Config.Restaurants, {
	Name = "Aztecas Clubhouse Bar",
	Job = "aztecas",
	Benches = {
		bar = {
			label = "Bar",
			targeting = {
				actionString = "Making",
				icon = "martini-glass-citrus",
				poly = {
					coords = vector3(495.22, -1529.94, 29.29),
					w = 0.6,
					l = 1.8,
					options = {
						heading = 320,
						--debugPoly=true,
						minZ = 29.89,
						maxZ = 31.09,
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
			id = "aztecas-clubhouse-pickup-1",
			coords = vector3(494.08, -1532.34, 29.29),
			width = 1.0,
			length = 1.0,
			options = {
				heading = 320,
				--debugPoly=true,
				minZ = 29.09,
				maxZ = 30.09,
			},
			data = {
				business = "aztecas",
			},
		},
	},
	Warmers = false,
})
