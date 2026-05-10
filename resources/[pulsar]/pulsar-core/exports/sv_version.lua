local ENABLED = false

local _pending = {}
local _registered = {}
local _queued = 0
local _running = false
local _startTime = nil

local function PrintReport()
	if #_pending == 0 then
		_running = false
		return
	end

	local outdated, errors = {}, {}
	for i = 1, #_pending do
		local d = _pending[i]
		if d.status == 'outdated' then
			outdated[#outdated + 1] = d
		elseif d.status == 'error' then
			errors[#errors + 1] = d
		end
	end

	local sort = function(a, b) return a.name < b.name end
	table.sort(outdated, sort)
	table.sort(errors, sort)

	local n_out, n_err = #outdated, #errors

	exports['pulsar-core']:LoggerInfo('Version', '')
	exports['pulsar-core']:LoggerInfo('Version', '^5============================================================^0')
	exports['pulsar-core']:LoggerInfo('Version', '^5       . * ✦ PULSAR FRAMEWORK — VERSION REPORT ✦ * .       ^0')
	exports['pulsar-core']:LoggerInfo('Version', '^5============================================================^0')

	if n_out == 0 and n_err == 0 then
		exports['pulsar-core']:LoggerInfo('Version', ('^2  ✓  All %d resources are up to date!^0'):format(#_pending))
	else
		for i = 1, n_out do
			local d = outdated[i]
			exports['pulsar-core']:LoggerWarn('Version',
				('  ^1✗^0  %-30s ^1%s^0 → ^2%s^0  ^3%s^0'):format(d.name, d.current, d.newest, d.repoUrl))
		end
		for i = 1, n_err do
			exports['pulsar-core']:LoggerWarn('Version',
				('  ^3?^0  %-30s ^3Unable to check^0'):format(errors[i].name))
		end
		exports['pulsar-core']:LoggerInfo('Version', '^5----------------------------------------------------------^0')
		exports['pulsar-core']:LoggerInfo('Version',
			('^2  ✓  %d up to date^0   ^1✗  %d outdated^0   ^3?  %d unable to check^0'):format(#_pending - n_out - n_err, n_out, n_err))
	end

	exports['pulsar-core']:LoggerInfo('Version', '^5============================================================^0')
	exports['pulsar-core']:LoggerInfo('Version', '')

	_pending, _queued, _running, _startTime = {}, 0, false, nil
end

exports('VersionCheck', function(repo)
	if not ENABLED then return end

	local resource = GetInvokingResource() or GetCurrentResourceName()
	if not resource or _registered[resource] then return end

	_registered[resource] = true
	_queued = _queued + 1

	if not _running then
		_startTime, _running = GetGameTimer(), true
		CreateThread(function()
			while true do
				local snapshot = _queued
				Wait(4000)
				if GetGameTimer() - _startTime >= 8000 and _queued == snapshot and #_pending >= _queued then
					PrintReport()
					return
				end
			end
		end)
	end

	local current = (GetResourceMetadata(resource, 'version', 0) or ''):match('%d+%.%d+%.%d+') or ''
	local name = resource:gsub('(%a)([%w]*)', function(a, b) return a:upper() .. b end)

	PerformHttpRequest(('https://api.github.com/repos/%s/releases/latest'):format(repo), function(statusCode, body)
		local entry = {
			name = name,
			current = current,
			repoUrl = ('https://github.com/%s/releases/latest'):format(repo),
			status = 'error',
		}

		if statusCode == 200 and body then
			local data = json.decode(body)
			if data and not data.prerelease then
				local newest = data.tag_name and data.tag_name:match('%d+%.%d+%.%d+')
				if newest then
					entry.newest = newest
					entry.status = newest == current and 'ok' or 'outdated'
				end
			end
		elseif statusCode == 403 or statusCode == 429 then
			entry.status = 'ratelimited'
		end

		_pending[#_pending + 1] = entry
	end, 'GET', '', { ['User-Agent'] = 'Pulsar-VersionCheck' })
end)