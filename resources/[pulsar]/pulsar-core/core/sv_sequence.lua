local _cachedSeq = {}
local _loading = {}

exports("SequenceGet", function(key)
	if _cachedSeq[key] ~= nil then
		_cachedSeq[key].sequence += 1
		_cachedSeq[key].dirty = true
		return _cachedSeq[key].sequence
	else
		local maxValue = 1000
		if key == "Character" then
			local result = MySQL.scalar.await('SELECT MAX(SID) FROM characters')
			if result then
				maxValue = result
			end
		end

		_cachedSeq[key] = {
			id = key,
			sequence = maxValue,
			dirty = true,
		}
		_cachedSeq[key].sequence += 1
		return _cachedSeq[key].sequence
	end
end)

exports("SequenceSave", function()
	local queries = {}
	for k, v in pairs(_cachedSeq) do
		if v.dirty then
			table.insert(queries, {
				query =
				"INSERT INTO sequence (id, sequence) VALUES(?, ?) ON DUPLICATE KEY UPDATE sequence = VALUES(sequence)",
				values = {
					k,
					v.sequence,
				},
			})

			v.dirty = false
		end
	end

	MySQL.transaction(queries)
end)

AddEventHandler("Core:Server:StartupReady", function()
	local t = MySQL.rawExecute.await("SELECT id, sequence FROM sequence")
	for k, v in ipairs(t) do
		_cachedSeq[v.id] = {
			id = v.id,
			sequence = v.sequence,
			dirty = false,
		}
	end
end)

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(1000)
		exports['pulsar-core']:TasksRegister("sequence_save", 10, function()
			exports['pulsar-core']:SequenceSave()
		end)
	end
end)

AddEventHandler("Core:Server:ForceSave", function()
	exports['pulsar-core']:SequenceSave()
end)
