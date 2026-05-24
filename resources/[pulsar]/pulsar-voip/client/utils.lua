function GetVOIPMumbleAddress()
	local externalAddress = GetConvar('voice_externalAddress', 'false')
	local externalPort = GetConvarInt('voice_externalPort', 0)
	if externalAddress ~= 'false' and externalPort > 0 then
		return externalAddress, externalPort
	end

	local gsAddress = GlobalState.MumbleAddress
	local gsPort = GlobalState.MumblePort
	if gsAddress and gsPort and gsPort > 0 then
		return gsAddress, gsPort
	end

	local defaultEndpoint = GetCurrentServerEndpoint()
	local defaultAddress, defaultPort
	for match in string.gmatch(defaultEndpoint, "[^:]+") do
		if not defaultAddress then
			defaultAddress = match
		elseif not defaultPort then
			defaultPort = tonumber(match)
		end
	end
	return defaultAddress, defaultPort
end

function LoadAnim(dict)
	while not HasAnimDictLoaded(dict) do
		RequestAnimDict(dict)
		Wait(10)
	end
end
