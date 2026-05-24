local zoneRadius = GetConvarInt('voice_zoneRadius', 256)
local _routeBucket = 0
local _customChannelOverride = false

function GetPlayerGridZone()
	local pos = GetEntityCoords(PlayerPedId(), false)
	local sectorX = math.max(pos.x + 8192.0, 0.0) / zoneRadius
	local sectorY = math.max(pos.y + 8192.0, 0.0) / zoneRadius
	return math.ceil(sectorX + sectorY)
end

function StartVOIPGridThreads()
	CreateThread(function()
		while _characterLoaded do
			if not _customChannelOverride then
				local newGrid = GetPlayerGridZone()
				if newGrid ~= CURRENT_GRID then
					exports['pulsar-core']:LoggerTrace('VOIP', ('Grid: %s -> %s'):format(CURRENT_GRID, newGrid))
					CURRENT_GRID = newGrid

					MumbleClearVoiceTargetChannels(1)
					MumbleAddVoiceTargetChannel(1, CURRENT_GRID)
					for g = CURRENT_GRID - 3, CURRENT_GRID + 3 do
						MumbleAddVoiceTargetChannel(1, g)
					end
				end
			else
				if CURRENT_GRID ~= _customChannelOverride then
					exports['pulsar-core']:LoggerTrace('VOIP', ('Channel Override: %s'):format(_customChannelOverride))
					CURRENT_GRID = _customChannelOverride
					MumbleClearVoiceTargetChannels(1)
					MumbleAddVoiceTargetChannel(1, CURRENT_GRID)
				end
			end
			Wait(100)
		end
	end)
end

function GetCurrentVOIPGrid()
	return CURRENT_GRID
end

RegisterNetEvent('Routing:Client:NewRoute', function(route)
	_routeBucket = route
	_customChannelOverride = _routeBucket > 1 and (1024 + _routeBucket) or false
end)

local isSpecVoiceEnabled = false
function SetSpectatorVoiceMode(enabled)
	if enabled and not isSpecVoiceEnabled then
		isSpecVoiceEnabled = true
		for _, player in ipairs(GetActivePlayers()) do
			local serverId = GetPlayerServerId(player)
			if serverId ~= PLAYER_SERVER_ID then
				MumbleAddVoiceChannelListen(MumbleGetVoiceChannelFromServerId(serverId))
			end
		end
	elseif not enabled and isSpecVoiceEnabled then
		isSpecVoiceEnabled = false
		for _, player in ipairs(GetActivePlayers()) do
			local serverId = GetPlayerServerId(player)
			if serverId ~= PLAYER_SERVER_ID then
				MumbleRemoveVoiceChannelListen(MumbleGetVoiceChannelFromServerId(serverId))
			end
		end
	end
end

CreateThread(function()
	while true do
		Wait(1000)
		if _characterLoaded then
			SetSpectatorVoiceMode(NetworkIsInSpectatorMode())
		end
	end
end)
