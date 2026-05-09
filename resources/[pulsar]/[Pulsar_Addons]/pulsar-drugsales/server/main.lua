local _drugByItem = {}

local _lastSaleOutcome = {}

local function rollSaleQuantity(weights, maxHave)
	if not weights or #weights == 0 or maxHave < 1 then
		return 1
	end

	local pool, total = {}, 0
	for _, row in ipairs(weights) do
		local q = tonumber(row.qty)
		local w = tonumber(row.weight)
		if q and w and q >= 1 and q <= maxHave and w > 0 then
			total = total + w
			pool[#pool + 1] = { qty = q, weight = w }
		end
	end

	if total <= 0 or #pool == 0 then
		return math.min(1, maxHave)
	end

	local r = math.random(1, total)
	local acc = 0
	for _, e in ipairs(pool) do
		acc = acc + e.weight
		if r <= acc then
			return e.qty
		end
	end

	return pool[#pool].qty
end

local function successCooldownMs()
	return Config.SellCooldownSuccessMs or Config.SellCooldownMs or 35000
end

local function failCooldownMs()
	local f = Config.SellCooldownFailMs
	if f and f > 0 then
		return f
	end
	return math.max(8000, math.floor(successCooldownMs() * 0.5))
end

local function cooldownRemainingMs(source)
	local prev = _lastSaleOutcome[source]
	if not prev then
		return 0
	end
	local need = prev.success and successCooldownMs() or failCooldownMs()
	local left = need - (GetGameTimer() - prev.t)
	if left < 0 then
		return 0
	end
	return left
end

local function buildDrugIndex()
	_drugByItem = {}
	for _, row in ipairs(Config.Drugs or {}) do
		if row.item then
			_drugByItem[row.item] = row
		end
	end
end


local function grantSalePayout(source, payoutDollars)
	payoutDollars = math.floor(tonumber(payoutDollars) or 0)
	if payoutDollars < 1 then
		return true
	end

	local p = Config.Payout or {}
	local currency = (p.currency or "money") == "moneyroll" and "moneyroll" or "money"
	local moneyItem = p.moneyItem or "money"

	if currency == "money" then
		return exports.ox_inventory:AddItem(source, moneyItem, payoutDollars) and true or false
	end

	local rollItem = p.moneyrollItem or "moneyroll"
	local perRoll = math.max(1, math.floor(tonumber(p.dollarsPerRoll) or 100))
	local rolls = math.floor(payoutDollars / perRoll)
	local remainder = payoutDollars - rolls * perRoll

	if rolls > 0 then
		if not exports.ox_inventory:AddItem(source, rollItem, rolls) then
			return false
		end
	end

	if remainder > 0 and p.payRemainderAsMoney ~= false then
		if not exports.ox_inventory:AddItem(source, moneyItem, remainder) then
			if rolls > 0 then
				exports.ox_inventory:RemoveItem(source, rollItem, rolls)
			end
			return false
		end
	elseif remainder > 0 and rolls == 0 then
		return false
	end

	return true
end

local function notifyPolice(coords, message)
	if not Config.PoliceAlert.enabled then
		return
	end

	local payload = {
		coords = coords,
		message = message or Config.PoliceAlert.hudMessage,
		blipSprite = Config.PoliceAlert.blipSprite,
		blipColour = Config.PoliceAlert.blipColour,
		blipScale = Config.PoliceAlert.blipScale,
		blipLabel = Config.PoliceAlert.blipLabel,
		blipDurationMs = Config.PoliceAlert.blipDurationMs,
	}

	for _, playerId in ipairs(GetPlayers()) do
		local src = tonumber(playerId)
		local duty = Player(src).state.onDuty
		if duty then
			for _, job in ipairs(Config.PoliceAlert.jobs or {}) do
				if duty == job then
					TriggerClientEvent("pulsar-drugsales:client:policeAlert", src, payload)
					exports["pulsar-hud"]:Notification(
						src,
						"info",
						payload.message,
						Config.PoliceAlert.notifyPoliceDuration
					)
					break
				end
			end
		end
	end
end

local function registerCallbacks()
	exports["pulsar-core"]:RegisterServerCallback("pulsar-drugsales:canOffer", function(source, _, cb)
		local left = cooldownRemainingMs(source)
		if left > 0 then
			cb({ ok = false, remainingMs = left })
			return
		end
		cb({ ok = true })
	end)

	exports["pulsar-core"]:RegisterServerCallback("pulsar-drugsales:attemptSale", function(source, data, cb)
		data = data or {}
		local itemName = data.item

		local drug = itemName and _drugByItem[itemName]
		if not drug then
			cb({ ok = false, reason = "invalid_item" })
			return
		end

		local leftCd = cooldownRemainingMs(source)
		if leftCd > 0 then
			cb({ ok = false, reason = "cooldown", remainingMs = leftCd })
			return
		end

		local count = exports.ox_inventory:GetItemCount(source, itemName) or 0
		if count < 1 then
			cb({ ok = false, reason = "no_item" })
			return
		end

		local qty
		if drug.quantityWeights and #drug.quantityWeights > 0 then
			qty = rollSaleQuantity(drug.quantityWeights, count)
		else
			local rq = tonumber(data.quantity)
			qty = (rq and rq >= 1) and math.floor(rq) or (Config.DefaultQuantity or 1)
			if qty < 1 or qty > 10 then
				cb({ ok = false, reason = "bad_quantity" })
				return
			end
			qty = math.min(qty, count)
		end

		if count < qty then
			cb({ ok = false, reason = "no_item" })
			return
		end

		local success = math.random() < (drug.successChance or 0.5)
		local repId = Config.Reputation.id
		local pedCoords = GetEntityCoords(GetPlayerPed(source))

		if success then
			local removed = exports.ox_inventory:RemoveItem(source, itemName, qty)
			if not removed then
				_lastSaleOutcome[source] = { t = GetGameTimer(), success = false }
				cb({ ok = false, reason = "remove_failed" })
				return
			end

			local level = exports["pulsar-characters"]:RepGetLevel(source, repId) or 0
			local mult = 1.0 + (level * (Config.RepLevelPayMultiplier or 0))
			local base = math.random(drug.baseMin or 1, drug.baseMax or drug.baseMin or 1)
			local payout = math.floor(base * qty * mult)

			if not grantSalePayout(source, payout) then
				exports.ox_inventory:AddItem(source, itemName, qty)
				_lastSaleOutcome[source] = { t = GetGameTimer(), success = false }
				cb({ ok = false, reason = "payout_failed" })
				return
			end

			exports["pulsar-characters"]:RepAdd(source, repId, (drug.repOnSuccess or 0) * qty)

			_lastSaleOutcome[source] = { t = GetGameTimer(), success = true }

			cb({
				ok = true,
				success = true,
				payout = payout,
				repGain = (drug.repOnSuccess or 0) * qty,
				quantitySold = qty,
			})
		else
			_lastSaleOutcome[source] = { t = GetGameTimer(), success = false }

			local police = false
			if Config.PoliceAlert.enabled and math.random() < (Config.PoliceAlert.chanceOnFail or 0) then
				police = true
				notifyPolice({ x = pedCoords.x, y = pedCoords.y, z = pedCoords.z })
			end

			cb({
				ok = true,
				success = false,
				police = police,
			})
		end
	end)
end

AddEventHandler("onResourceStart", function(resource)
	if resource ~= GetCurrentResourceName() then
		return
	end
	Wait(500)
	buildDrugIndex()
	local rep = Config.Reputation
	exports["pulsar-characters"]:RepCreate(rep.id, rep.label, rep.levels, rep.hidden)
	registerCallbacks()
end)

AddEventHandler("playerDropped", function()
	_lastSaleOutcome[source] = nil
end)
