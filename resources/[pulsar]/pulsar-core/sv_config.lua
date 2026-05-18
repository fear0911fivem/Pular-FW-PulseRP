-- Server Configuration
local ServerConfig = {
	ID = os.time(),
	Name = "Server Name",
	Access = GetConvar("sv_access_role", 0),
}

-- Discord Configuration
local DiscordConfig = {
	Server = "",
}

-- Groups Configuration
local GroupsConfig = {
	management = {
		Id = "management",
		Name = "Management",
		Abv = "Management",
		Queue = {
			Priority = 1000,
		},
		Permission = {
			Group = "admin", -- Can restart resources
			Level = 100,
		},
	},
	dev = {
		Id = "dev",
		Name = "Developer",
		Abv = "Dev",
		Queue = {
			Priority = 1000,
		},
		Permission = {
			Group = "admin",
			Level = 100,
		},
	},
	admin = {
		Id = "admin",
		Name = "Admin",
		Abv = "Admin",
		Queue = {
			Priority = 500,
		},
		Permission = {
			Group = "staff",
			Level = 50,
		},
	},
	operations = {
		Id = "operations",
		Name = "Operations",
		Abv = "Operations",
		Queue = {
			Priority = 250,
		},
		Permission = {
			Group = "",
			Level = 0,
		},
	},
	whitelisted = {
		Id = "whitelisted",
		Name = "Whitelisted",
		Abv = "Whitelisted",
		Queue = {
			Priority = 0,
		},
		Permission = {
			Group = "",
			Level = 0,
		},
	},
}

exports("ConfigGetDiscord", function()
	return DiscordConfig
end)

exports("ConfigGetGroups", function()
	return GroupsConfig
end)

exports("ConfigGetServer", function()
	return ServerConfig
end)

exports("ConfigGetGroupById", function(groupId)
	return GroupsConfig[groupId]
end)

exports("ConfigGetGroupPermission", function(groupId)
	local group = GroupsConfig[groupId]
	if group then
		return group.Permission
	end
	return nil
end)

exports("ConfigGetGroupQueuePriority", function(groupId)
	local group = GroupsConfig[groupId]
	if group then
		return group.Queue.Priority
	end
	return 0
end)

exports("ConfigUpdateGroups", function(newGroups)
	GroupsConfig = newGroups
end)
