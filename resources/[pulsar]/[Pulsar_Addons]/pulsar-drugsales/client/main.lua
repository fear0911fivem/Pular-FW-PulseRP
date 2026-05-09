local _blacklist = {}
local _targetRegistered
local _salePed
local _nuiOpen = false
local _pedOfferUntil = {}

local function buildBlacklist()
	_blacklist = {}
	for _, name in ipairs(Config.PedFilters.blacklistedModels or {}) do
		_blacklist[joaat(name)] = true
	end
end

local function loadAnimDict(dict)
	if not dict or dict == "" then
		return
	end
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Wait(10)
	end
end

local function pedAllowed(entity)
	local f = Config.PedFilters
	if f.blockPlayers and IsPedAPlayer(entity) then
		return false
	end
	if f.blockDead and IsPedDeadOrDying(entity, true) then
		return false
	end
	if f.blockInVehicle and IsPedInAnyVehicle(entity, false) then
		return false
	end
	if f.blockPlayerInVehicle and IsPedInAnyVehicle(PlayerPedId(), false) then
		return false
	end
	if GetPedType(entity) == 28 then
		return false
	end
	local model = GetEntityModel(entity)
	if _blacklist[model] then
		return false
	end
	return true
end

local function playerHasCompatibleDrug()
	for _, drug in ipairs(Config.Drugs or {}) do
		if drug.item and (exports.ox_inventory:GetItemCount(drug.item) or 0) > 0 then
			return true
		end
	end
	return false
end

local function pruneInvalidPedOfferKeys()
	for e in pairs(_pedOfferUntil) do
		if not DoesEntityExist(e) then
			_pedOfferUntil[e] = nil
		end
	end
end

local function samePedOfferCooldownMs()
	return Config.SamePedOfferCooldownMs or 90000
end

local function markPedOfferCooldown(ped)
	pruneInvalidPedOfferKeys()
	if not ped or ped == 0 then
		return
	end
	_pedOfferUntil[ped] = GetGameTimer() + samePedOfferCooldownMs()
end

local function pedOfferCooldownLeftMs(ped)
	local untilT = _pedOfferUntil[ped]
	if not untilT then
		return 0
	end
	local left = untilT - GetGameTimer()
	if left <= 0 then
		_pedOfferUntil[ped] = nil
		return 0
	end
	return left
end

local function isPedOfferOnCooldown(ped)
	if not ped or not DoesEntityExist(ped) then
		return false
	end
	return pedOfferCooldownLeftMs(ped) > 0
end

local function tryNetworkControl(entity, timeoutMs)
	if not DoesEntityExist(entity) then
		return false
	end
	timeoutMs = timeoutMs or 900
	if NetworkHasControlOfEntity(entity) then
		return true
	end
	local deadline = GetGameTimer() + timeoutMs
	while GetGameTimer() < deadline do
		if NetworkHasControlOfEntity(entity) then
			return true
		end
		NetworkRequestControlOfEntity(entity)
		Wait(0)
	end
	return NetworkHasControlOfEntity(entity)
end

--- Keeps an ambient ped from being cleaned up while the menu or sale runs.
local function pinBuyerPed(buyerPed)
	if not buyerPed or not DoesEntityExist(buyerPed) then
		return
	end
	local bh = Config.BuyerHold or {}
	tryNetworkControl(buyerPed, bh.controlTimeoutMs or 900)
	SetEntityAsMissionEntity(buyerPed, true, true)
end

local function holdBuyerForSale(buyerPed)
	local bh = Config.BuyerHold or {}
	if not DoesEntityExist(buyerPed) then
		return
	end
	tryNetworkControl(buyerPed, bh.controlTimeoutMs or 900)
	SetEntityAsMissionEntity(buyerPed, true, true)
	SetPedCanRagdoll(buyerPed, false)
	SetBlockingOfNonTemporaryEvents(buyerPed, true)
	ClearPedTasksImmediately(buyerPed)
	SetEntityVelocity(buyerPed, 0.0, 0.0, 0.0)

	local playerPed = PlayerPedId()
	local faceMs = math.max(900, bh.facePlayerMs or 2200)
	TaskTurnPedToFaceEntity(buyerPed, playerPed, faceMs)
	Wait(faceMs + 200)
	ClearPedTasksImmediately(buyerPed)

	if bh.useFreeze ~= false then
		FreezeEntityPosition(buyerPed, true)
	else
		local still = math.max((Config.SaleDurationMs or 4500) + 1500, bh.standStillMs or 7000)
		TaskStandStill(buyerPed, still)
	end
end

local function releaseBuyerFromSale(buyerPed)
	if not buyerPed or not DoesEntityExist(buyerPed) then
		return
	end
	FreezeEntityPosition(buyerPed, false)
	SetBlockingOfNonTemporaryEvents(buyerPed, false)
	SetPedCanRagdoll(buyerPed, true)
	SetEntityAsMissionEntity(buyerPed, false, false)
	ClearPedTasksImmediately(buyerPed)
	local bas = Config.BuyerAfterSale or {}
	if bas.resumeWander ~= false then
		local r = bas.wanderRadius or 10.0
		local b = bas.wanderBlend or 10
		pcall(TaskWanderStandard, buyerPed, r + 0.0, math.floor(b))
	end
end

local function attachPackageProp(ped)
	local cfg = Config.PackageHandoff
	if not cfg or not cfg.enabled then
		return nil
	end
	local hash = joaat(cfg.model or "prop_drug_package_02")
	RequestModel(hash)
	local deadline = GetGameTimer() + 3500
	while not HasModelLoaded(hash) and GetGameTimer() < deadline do
		Wait(10)
	end
	if not HasModelLoaded(hash) then
		return nil
	end
	local c = GetEntityCoords(ped)
	local obj = CreateObject(hash, c.x, c.y, c.z, true, true, false)
	SetEntityAsMissionEntity(obj, true, true)
	local bone = cfg.bone or 57005
	local pos = cfg.pos or { x = 0.074, y = 0.0, z = -0.02 }
	local rot = cfg.rot or { x = 22.0, y = 96.0, z = -84.0 }
	AttachEntityToEntity(
		obj,
		ped,
		GetPedBoneIndex(ped, bone),
		pos.x + 0.0,
		pos.y + 0.0,
		pos.z + 0.0,
		rot.x + 0.0,
		rot.y + 0.0,
		rot.z + 0.0,
		true,
		true,
		false,
		true,
		1,
		true
	)
	SetModelAsNoLongerNeeded(hash)
	return obj
end

local function deletePackageProp(obj)
	if obj and DoesEntityExist(obj) then
		DetachEntity(obj, true, true)
		DeleteEntity(obj)
	end
end

local function faceEntity(ped, target)
	TaskTurnPedToFaceEntity(ped, target, 900)
	Wait(800)
end

local function playHandoff(playerPed, targetPed)
	local anim = Config.Anim or {}
	local duration = Config.SaleDurationMs or 4500

	if anim.dict and anim.name then
		loadAnimDict(anim.dict)
		local clipLen = GetAnimDuration(anim.dict, anim.name)
		if clipLen and clipLen > 0.0 then
			local oneCycleMs = math.floor(clipLen * 1000.0 + 0.5) + 75
			if oneCycleMs > 0 then
				duration = math.min(duration, oneCycleMs)
			end
		end
	end

	local pkg = attachPackageProp(playerPed)

	if anim.dict and anim.name then
		faceEntity(playerPed, targetPed)
		TaskPlayAnim(
			playerPed,
			anim.dict,
			anim.name,
			8.0,
			-8.0,
			duration,
			anim.flag or 48,
			0,
			false,
			false,
			false
		)
	end

	Wait(duration)

	if anim.dict and anim.name then
		StopAnimTask(playerPed, anim.dict, anim.name, 1.0)
	end
	deletePackageProp(pkg)
end

local function notify(msg, typ)
	exports["pulsar-hud"]:Notification(typ or "info", msg, 4500)
end

local function maxStartDistance()
	return Config.SaleMaxStartDistance or (Config.Target.distance or 2.2) + 1.4
end

local function closeDrugSalesNui()
	if not _nuiOpen then
		return
	end
	_nuiOpen = false
	SetNuiFocus(false, false)
	SendNUIMessage({ action = "drugsales:close" })
end

local function getDrugByItem(itemName)
	for _, d in ipairs(Config.Drugs or {}) do
		if d.item == itemName then
			return d
		end
	end
	return nil
end

local function runStreetSale(buyerPed, drug)
	local ped = PlayerPedId()
	if not buyerPed or not DoesEntityExist(buyerPed) then
		notify("Nobody is there anymore.", "error")
		return
	end
	if #(GetEntityCoords(ped) - GetEntityCoords(buyerPed)) > maxStartDistance() then
		notify("You are too far away.", "error")
		releaseBuyerFromSale(buyerPed)
		markPedOfferCooldown(buyerPed)
		return
	end

	holdBuyerForSale(buyerPed)
	local animOk = pcall(playHandoff, ped, buyerPed)
	if not animOk then
		releaseBuyerFromSale(buyerPed)
		markPedOfferCooldown(buyerPed)
		notify("Could not finish the handoff.", "error")
		return
	end

	local releaseDone = false
	local function safeReleaseBuyer()
		if releaseDone then
			return
		end
		releaseDone = true
		releaseBuyerFromSale(buyerPed)
	end

	SetTimeout(15000, function()
		safeReleaseBuyer()
	end)

	exports["pulsar-core"]:ServerCallback("pulsar-drugsales:attemptSale", {
		item = drug.item,
		quantity = (drug.quantityWeights and #drug.quantityWeights > 0) and 0 or (Config.DefaultQuantity or 1),
	}, function(res)
		safeReleaseBuyer()
		if not res or not res.ok then
			if res and res.reason == "cooldown" then
				notify("You need to wait before trying another sale.", "warning")
			elseif res and res.reason == "no_item" then
				notify("You do not have that anymore.", "error")
			elseif res and res.reason == "payout_failed" then
				notify("Could not add your payout (inventory full?). Your drugs were returned.", "error")
			else
				notify("You cannot do that right now.", "error")
			end
			markPedOfferCooldown(buyerPed)
			return
		end
		if res.success then
			local n = res.quantitySold or 1
			notify(string.format("Sold %d for $%s", n, res.payout or 0), "success")
		else
			local msg = "They refused and walked off."
			if res.police then
				msg = msg .. " You think someone may have called it in."
			end
			notify(msg, "warning")
		end
		markPedOfferCooldown(buyerPed)
	end)
end

local function openSaleMenu(targetPed)
	if _nuiOpen then
		return
	end

	local mcfg = Config.Menu or {}
	local items = {}

	for _, drug in ipairs(Config.Drugs or {}) do
		local c = exports.ox_inventory:GetItemCount(drug.item) or 0
		if c > 0 then
			items[#items + 1] = {
				item = drug.item,
				label = drug.label or drug.item,
				stock = c,
				baseMin = drug.baseMin or 0,
				baseMax = drug.baseMax or 0,
				randomQty = drug.quantityWeights and #drug.quantityWeights > 0,
			}
		end
	end

	if #items == 0 then
		notify("You have nothing configured to sell.", "error")
		return
	end

	pinBuyerPed(targetPed)
	_salePed = targetPed
	_nuiOpen = true
	SetNuiFocus(true, true)
	SendNUIMessage({
		action = "drugsales:open",
		data = {
			cancelLabel = mcfg.cancelLabel or "Walk away",
			items = items,
		},
	})
end

local function tryOpenSaleMenu(targetPed)
	if isPedOfferOnCooldown(targetPed) then
		notify("You've already dealt with them recently.", "warning")
		return
	end
	exports["pulsar-core"]:ServerCallback("pulsar-drugsales:canOffer", {}, function(res)
		if not res or not res.ok then
			notify("You need to wait before offering again.", "warning")
			return
		end
		openSaleMenu(targetPed)
	end)
end

RegisterNUICallback("drugsales_closed", function(_, cb)
	local ped = _salePed
	closeDrugSalesNui()
	releaseBuyerFromSale(ped)
	markPedOfferCooldown(ped)
	_salePed = nil
	cb("ok")
end)

RegisterNUICallback("drugsales_select", function(data, cb)
	cb("ok")
	closeDrugSalesNui()

	local itemName = data and data.item
	local buyerPed = _salePed
	_salePed = nil

	if not itemName or not buyerPed or not DoesEntityExist(buyerPed) then
		releaseBuyerFromSale(buyerPed)
		markPedOfferCooldown(buyerPed)
		return
	end

	local drug = getDrugByItem(itemName)
	if not drug then
		releaseBuyerFromSale(buyerPed)
		markPedOfferCooldown(buyerPed)
		return
	end

	CreateThread(function()
		runStreetSale(buyerPed, drug)
	end)
end)

local function registerTarget()
	if _targetRegistered then
		return
	end
	_targetRegistered = true

	exports.ox_target:addGlobalPed({
		{
			name = Config.Target.optionName,
			icon = Config.Target.icon,
			label = Config.Target.label,
			distance = Config.Target.distance,
			canInteract = function(entity)
				if _nuiOpen then
					return false
				end
				if not LocalPlayer.state.loggedIn then
					return false
				end
				if LocalPlayer.state.isDead or LocalPlayer.state.isCuffed or LocalPlayer.state.isHardCuffed then
					return false
				end
				if not playerHasCompatibleDrug() then
					return false
				end
				if isPedOfferOnCooldown(entity) then
					return false
				end
				return pedAllowed(entity)
			end,
			onSelect = function(data)
				tryOpenSaleMenu(data.entity)
			end,
		},
	})
end

local function unregisterTarget()
	if not _targetRegistered then
		return
	end
	exports.ox_target:removeGlobalPed(Config.Target.optionName)
	_targetRegistered = false
end

RegisterNetEvent("pulsar-drugsales:client:policeAlert", function(data)
	if not data or not data.coords then
		return
	end
	local c = data.coords
	local blip = AddBlipForCoord(c.x, c.y, c.z)
	SetBlipSprite(blip, data.blipSprite or 161)
	SetBlipColour(blip, data.blipColour or 1)
	SetBlipScale(blip, data.blipScale or 1.0)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(data.blipLabel or "Alert")
	EndTextCommandSetBlipName(blip)
	SetTimeout(data.blipDurationMs or 90000, function()
		if DoesBlipExist(blip) then
			RemoveBlip(blip)
		end
	end)
end)

RegisterNetEvent("Characters:Client:Logout", function()
	local ped = _salePed
	closeDrugSalesNui()
	releaseBuyerFromSale(ped)
	_salePed = nil
end)

AddEventHandler("onClientResourceStart", function(resource)
	if resource ~= GetCurrentResourceName() then
		return
	end
	buildBlacklist()
	registerTarget()
end)

AddEventHandler("onResourceStop", function(resource)
	if resource ~= GetCurrentResourceName() then
		return
	end
	local ped = _salePed
	closeDrugSalesNui()
	releaseBuyerFromSale(ped)
	_salePed = nil
	unregisterTarget()
end)
