_properties = {}
_insideProperties = {}

function doPropertyThings(property)
	property.id = property._id
	property.locked = property.locked or true

	if property.location then
		for k, v in pairs(property.location) do
			if v then
				for k2, v2 in pairs(v) do
					property.location[k][k2] = property.location[k][k2] + 0.0
				end
			end
		end
	end

	return property
end

function Startup()
	exports.oxmysql:execute('SELECT * FROM properties', {}, function(results)
		if not results then
			return
		end
		exports['pulsar-core']:LoggerTrace("Properties", "Loaded ^2" .. #results .. "^7 Properties", { console = true })

		for k, v in ipairs(results) do
			local property = {
				_id = v.id,
				id = v.id,
				type = v.type,
				label = v.label,
				price = v.price,
				sold = v.sold == 1,
				owner = v.owner and json.decode(v.owner) or nil,
				location = v.location and json.decode(v.location) or nil,
				upgrades = v.upgrades and json.decode(v.upgrades) or nil,
				locked = v.locked == 1,
				keys = v.keys and json.decode(v.keys) or nil,
				data = v.data and json.decode(v.data) or nil,
				foreclosed = v.foreclosed == 1,
				soldAt = v.soldAt
			}

			local p = doPropertyThings(property)
			_properties[v.id] = p
		end
	end)
end
