local Config = require 'shared/config'

local function isIllegalItem(itemName)
	for _, illegal in ipairs(Config.K9.illegalItems) do
		if illegal == itemName then
			return true
		end
	end
	return false
end

function hasIllegalItems(target)
	for _, item in ipairs(Config.K9.illegalItems) do
		if exports.ox_inventory:GetItemCount(target, item) > 0 then
			return true
		end
	end
	return false
end

RegisterNetEvent("K9:server:spawnK9", function(model, colour, vest)
	local allowed = exports["pulsar-jobs"]:HasJob(source, Config.K9.job, nil, nil, nil, true)
	if allowed then
		TriggerClientEvent("K9:client:spawnK9", source, model, colour, vest)
	elseif Logger then
		Logger:Info("K9", "Player " .. source .. " tried to spawn K9 without proper job (Cheater?).")
	end
end)

RegisterNetEvent("K9:server:searchPerson")
AddEventHandler("K9:server:searchPerson", function(target)
	local playerHasIllegal = hasIllegalItems(target)
	if playerHasIllegal then
		TriggerClientEvent("k9:client:search_results", source, true, "person")
	else
		TriggerClientEvent("k9:client:search_results", source, false, "person")
	end
end)

RegisterNetEvent("K9:server:searchVehicle", function(vin, plate, players)
	local src = source

	if not vin or vin == "" then
		TriggerClientEvent("k9:client:search_results", src, false, "vehicle")
		return
	end

	local trunkInventory = GetContent(vin) or {}
	local containsIllegal = false

	for _, item in ipairs(trunkInventory) do
		if isIllegalItem(item.name) then
			containsIllegal = true
			break
		end
	end

	Wait(Config.K9.searchTime * 1000)
	TriggerClientEvent("k9:client:search_results", src, containsIllegal, "vehicle", trunkInventory)
end)

function GetContent(owner)
	if not owner or owner == "" then
		return {}
	end

	local adjustedOwner = owner .. "-4"

	local inventory = MySQL.query.await(
		[[
        SELECT
            id,
            count(id) as Count,
            name as Owner,
            item_id as Name,
            dropped as Temp,
            MAX(quality) as Quality,
            information as MetaData,
            slot as Slot,
            MIN(creationDate) AS CreateDate
        FROM
            inventory
        WHERE
            name = ?
        GROUP BY
            slot
        ORDER BY
            slot ASC
        ]],
		{ adjustedOwner }
	)

	local content = {}
	for _, item in ipairs(inventory) do
		table.insert(content, {
			id = item.id,
			count = item.Count,
			owner = item.Owner,
			name = item.Name,
			temp = item.Temp,
			quality = item.Quality,
			metadata = json.decode(item.MetaData or "{}"),
			slot = item.Slot,
			createDate = item.CreateDate,
		})
	end

	return content
end
