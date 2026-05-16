table.insert(Config.Businesses, {
	Job = "sagma",
	Benches = {
		jewelry = {
			label = "",
			targeting = {
				actionString = "Making",
				manual = true,
			},
			recipes = {
				{
					result = { name = "rlg_chain", count = 1 },
					items = {
						{ name = "goldbar", count = 10 },
						{ name = "silverbar", count = 10 },
						{ name = "diamond", count = 2 },
						{ name = "ruby", count = 2 },
					},
					time = 6500,
				},
				{
					result = { name = "lss_chain", count = 1 },
					items = {
						{ name = "goldbar", count = 10 },
						{ name = "silverbar", count = 10 },
						{ name = "diamond", count = 4 },
					},
					time = 6500,
				},
				{
					result = { name = "pepega_chain", count = 1 },
					items = {
						{ name = "goldbar", count = 10 },
						{ name = "silverbar", count = 10 },
						{ name = "diamond", count = 4 },
					},
					time = 6500,
				},
				{
					result = { name = "ssf_chain", count = 1 },
					items = {
						{ name = "goldbar", count = 10 },
						{ name = "silverbar", count = 10 },
						{ name = "diamond", count = 2 },
						{ name = "amethyst", count = 2 },
					},
					time = 6500,
				},
				{
					result = { name = "lust_chain", count = 1 },
					items = {
						{ name = "goldbar", count = 10 },
						{ name = "silverbar", count = 10 },
						{ name = "diamond", count = 1 },
						{ name = "amethyst", count = 1 },
						{ name = "sapphire", count = 1 },
						{ name = "opal", count = 1 },
					},
					time = 6500,
				},
				{
					result = { name = "mint_mate_chain", count = 1 },
					items = {
						{ name = "goldbar", count = 10 },
						{ name = "silverbar", count = 10 },
						{ name = "diamond", count = 2 },
						{ name = "emerald", count = 2 },
					},
					time = 6500,
				},
				{
					result = { name = "mint_mate_chain_2", count = 1 },
					items = {
						{ name = "goldbar", count = 10 },
						{ name = "silverbar", count = 10 },
						{ name = "diamond", count = 2 },
						{ name = "emerald", count = 2 },
					},
					time = 6500,
				},
				{
					result = { name = "snow_chain", count = 1 },
					items = {
						{ name = "goldbar", count = 10 },
						{ name = "silverbar", count = 10 },
						{ name = "diamond", count = 2 },
						{ name = "opal", count = 2 },
					},
					time = 6500,
				},
			},
		},
	},
	Name = "San Andreas Gallery of Modern Art",
	Pickups = {
		{
			id = "sagma-pickup-1",
			coords = vector3(-421.99, 30.28, 46.23),
			width = 1.0,
			length = 2.0,
			options = {
				heading = 310,
				--debugPoly=true,
				minZ = 45.23,
				maxZ = 47.83,
			},
			data = {
				business = "sagma",
			},
		},
	},
})
