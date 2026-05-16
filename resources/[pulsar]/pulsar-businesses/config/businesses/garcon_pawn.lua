table.insert(Config.Businesses, {
	Job = "garcon_pawn",
	Benches = {
		-- regular = {
		--     label = "Make Electronics",
		--     targeting = {
		--         actionString = "Making",
		--         icon = "microchip",
		--         poly = {
		--             coords = vector3(377.86, -820.56, 29.3),
		--             w = 2.8,
		--             l = 1.4,
		--             options = {
		--                 heading = 0,
		--                 --debugPoly=true,
		--                 minZ = 28.3,
		--                 maxZ = 29.5
		--             },
		--         },
		--     },
		--     recipes = {
		--         {
		--             result = { name = "radio_shitty", count = 1 },
		--             items = {
		--                 { name = "electronic_parts", count = 2 },
		--                 { name = "plastic", count = 5 },
		--                 { name = "copperwire", count = 1 },
		--                 { name = "glue", count = 2 },
		--             },
		--             time = 6500,
		--         },
		--         {
		--             result = { name = "phone", count = 1 },
		--             items = {
		--                 { name = "electronic_parts", count = 1 },
		--                 { name = "plastic", count = 2 },
		--                 { name = "glue", count = 1 },
		--             },
		--             time = 2000,
		--         },
		--     },
		-- },
	},
	Name = "Garcon Pawn",
	Pickups = {
		{
			id = "garcon-pawn-pickup-1",
			coords = vector3(-225.87, 6235.17, 31.79),
			width = 4.2,
			length = 0.6,
			options = {
				heading = 315,
				--debugPoly=true,
				minZ = 28.39,
				maxZ = 32.39,
			},
			data = {
				business = "garcon_pawn",
			},
		},
		{
			id = "garcon-pawn-pickup-2",
			coords = vector3(-228.98, 6228.6, 31.79),
			width = 4.6,
			length = 1.0,
			options = {
				heading = 225,
				--debugPoly=true,
				minZ = 28.39,
				maxZ = 32.39,
			},
			data = {
				business = "garcon_pawn",
			},
		},
		{
			id = "garcon-pawn-pickup-3",
			coords = vector3(-217.25, 6223.11, 31.79),
			width = 5.6,
			length = 0.8,
			options = {
				heading = 225,
				--debugPoly=true,
				minZ = 28.39,
				maxZ = 32.39,
			},
			data = {
				business = "garcon_pawn",
			},
		},

		{
			id = "garcon-pawn-pickup-4",
			coords = vector3(-222.07, 6227.88, 31.79),
			width = 5.6,
			length = 0.8,
			options = {
				heading = 225,
				--debugPoly=true,
				minZ = 28.39,
				maxZ = 32.39,
			},
			data = {
				business = "garcon_pawn",
			},
		},
	},
})
