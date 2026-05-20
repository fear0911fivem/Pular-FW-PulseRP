local currentBankView = false
local currentBankOptions = {}
local lastAccountsPayload = {}
local lastSummaryPayload = {
	changeInLast7Days = {},
}
local lastTransactionsPayload = {}
local FinanceSendBankingData
local transactionsRequestId = 0

function SendReactMessage(action, data)
	SendNUIMessage({
		action = action,
		data = data,
	})
end

local function AwaitServerCallback(name, data, timeoutMs, ...)
	local p = promise.new()
	local resolved = false
	local fallback = { ... }

	if timeoutMs == nil then
		timeoutMs = 8000
	end

	if #fallback == 0 then
		fallback = { false }
	end

	exports["pulsar-core"]:ServerCallback(name, data or {}, function(...)
		if resolved then
			return
		end

		resolved = true
		p:resolve({ ... })
	end)

	if timeoutMs and timeoutMs > 0 then
		CreateThread(function()
			Wait(timeoutMs)

			if not resolved then
				resolved = true
				p:resolve(fallback)
			end
		end)
	end

	local result = Citizen.Await(p)
	return table.unpack(result)
end

local function Notify(type, message)
	if GetResourceState("pulsar-hud") == "started" then
		exports["pulsar-hud"]:Notification(type, message)
	end
end

local function GetCurrentUnixSeconds()
	if type(GetCloudTimeAsInt) == "function" then
		local success, timestamp = pcall(GetCloudTimeAsInt)

		if success and tonumber(timestamp) then
			return tonumber(timestamp)
		end
	end

	return 0
end

local function DateToUnixSeconds(year, month, day, hour, min, sec)
	year = tonumber(year)
	month = tonumber(month)
	day = tonumber(day)
	hour = tonumber(hour) or 0
	min = tonumber(min) or 0
	sec = tonumber(sec) or 0

	if not year or not month or not day then
		return GetCurrentUnixSeconds()
	end

	year = year - (month <= 2 and 1 or 0)

	local era = math.floor(year / 400)
	local yearOfEra = year - era * 400
	local monthPrime = month + (month > 2 and -3 or 9)
	local dayOfYear = math.floor((153 * monthPrime + 2) / 5) + day - 1
	local dayOfEra = yearOfEra * 365 + math.floor(yearOfEra / 4) - math.floor(yearOfEra / 100) + dayOfYear
	local daysSinceEpoch = era * 146097 + dayOfEra - 719468

	return daysSinceEpoch * 86400 + hour * 3600 + min * 60 + sec
end

local function GetWeekday(unixSeconds)
	local daysSinceEpoch = math.floor((tonumber(unixSeconds) or 0) / 86400)

	return (daysSinceEpoch + 4) % 7
end

local function TimestampToMillis(value)
	if type(value) == "number" then
		if value < 100000000000 then
			return value * 1000
		end

		return value
	end

	if type(value) == "string" then
		local year, month, day, hour, min, sec = value:match("(%d+)%-(%d+)%-(%d+)%s+(%d+):(%d+):(%d+)")

		if not year then
			year, month, day, hour, min, sec = value:match("(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)")
		end

		if year then
			return DateToUnixSeconds(year, month, day, hour, min, sec) * 1000
		end
	end

	return GetCurrentUnixSeconds() * 1000
end

local function NormalizePermissions(permissions)
	permissions = permissions or {}

	return {
		MANAGE = permissions.MANAGE == true,
		BALANCE = permissions.BALANCE ~= false,
		WITHDRAW = permissions.WITHDRAW ~= false,
		DEPOSIT = permissions.DEPOSIT ~= false,
		TRANSACTIONS = permissions.TRANSACTIONS ~= false,
	}
end

local function NormalizeJointOwners(owners)
	local normalized = {}

	for _, owner in ipairs(owners or {}) do
		if type(owner) == "table" then
			local stateId = tonumber(owner.stateId or owner.SID or owner.sid or owner.jointOwner)
			table.insert(normalized, {
				stateId = stateId or 0,
				firstName = owner.firstName or owner.First or owner.first or "State",
				lastName = owner.lastName or owner.Last or owner.last or tostring(stateId or owner.jointOwner or ""),
			})
		else
			local stateId = tonumber(owner)
			table.insert(normalized, {
				stateId = stateId or 0,
				firstName = "State",
				lastName = tostring(stateId or owner),
			})
		end
	end

	return normalized
end

local function NormalizeAccount(account, index)
	local accountNumber = tonumber(account.Account or account.accountNumber or account.account) or account.Account or account.accountNumber

	return {
		id = tonumber(accountNumber) or index,
		accountNumber = accountNumber,
		name = account.Name or account.name or tostring(accountNumber),
		balance = tonumber(account.Balance or account.balance) or 0,
		type = account.Type or account.type or "personal",
		owner = tonumber(account.Owner or account.owner) or account.Owner or account.owner,
		frozen = account.Frozen == true or account.frozen == true,
		permissions = NormalizePermissions(account.Permissions or account.permissions),
		jointOwners = NormalizeJointOwners(account.JointOwners or account.jointOwners),
	}
end

local function NormalizeAccounts(accounts)
	local normalized = {}

	for index, account in ipairs(accounts or {}) do
		table.insert(normalized, NormalizeAccount(account, index))
	end

	return normalized
end

local function NormalizeTransaction(transaction, accountNumber, index)
	local amount = tonumber(transaction.Amount or transaction.amount) or 0
	local createdAt = TimestampToMillis(transaction.Timestamp or transaction.timestamp or transaction.createdAt)
	local normalizedAccount = tonumber(transaction.Account or transaction.accountNumber or accountNumber)
		or transaction.Account
		or transaction.accountNumber
		or accountNumber

	return {
		id = transaction.ID or transaction.id or string.format("%s-%s-%s", tostring(normalizedAccount), tostring(createdAt), index),
		accountNumber = normalizedAccount,
		title = transaction.Title or transaction.title or "Transaction",
		description = transaction.Description or transaction.description or "",
		amount = amount,
		type = transaction.Type or transaction.type or (amount >= 0 and "DEPOSIT" or "WITHDRAW"),
		createdAt = createdAt,
	}
end

local function NormalizeTransactions(response, accountNumber)
	local transactions = {}
	local rows = response

	if type(response) == "table" and response.data then
		rows = response.data
	end

	for index, transaction in ipairs(rows or {}) do
		table.insert(transactions, NormalizeTransaction(transaction, accountNumber, index))
	end

	return transactions
end

local function SortTransactions(transactions)
	table.sort(transactions, function(a, b)
		return (a.createdAt or 0) > (b.createdAt or 0)
	end)

	return transactions
end

local function BuildSummary(transactions)
	local days = { 0, 0, 0, 0, 0, 0, 0 }

	for _, transaction in ipairs(transactions or {}) do
		local weekday = GetWeekday(math.floor((transaction.createdAt or 0) / 1000))
		local index = weekday == 0 and 7 or weekday
		days[index] = days[index] + (tonumber(transaction.amount) or 0)
	end

	return {
		changeInLast7Days = days,
	}
end

local function GetPlayerData()
	local character = LocalPlayer.state.Character

	if not character then
		return {
			character = {
				stateId = 0,
				firstName = "",
				lastName = "",
			},
			cash = 0,
		}
	end

	return {
		character = {
			stateId = character:GetData("SID") or 0,
			firstName = character:GetData("First") or "",
			lastName = character:GetData("Last") or "",
		},
		cash = character:GetData("Cash") or 0,
	}
end

local function GetCurrentTimestampMillis()
	local timestamp = GetCurrentUnixSeconds()

	if timestamp <= 0 and type(GetGameTimer) == "function" then
		timestamp = math.floor(GetGameTimer() / 1000)
	end

	return timestamp * 1000
end

local function FindLocalAccount(accountNumber)
	local normalizedAccount = tostring(accountNumber or "")

	for _, account in ipairs(lastAccountsPayload or {}) do
		if tostring(account.accountNumber or "") == normalizedAccount then
			return account
		end
	end

	return nil
end

local function ApplyLocalBankingAction(data, balance)
	local action = data and data.type
	local amount = math.floor(tonumber(data and data.amount) or 0)
	local account = FindLocalAccount(data and data.account)

	if not action or amount <= 0 or not account then
		return
	end

	local signedAmount = amount
	local title = "Cash Deposit"
	local description = data.description or "No Description"

	if action == "WITHDRAW" then
		signedAmount = -amount
		title = "Cash Withdrawal"
	elseif action == "TRANSFER" then
		signedAmount = -amount
		title = "Outgoing Bank Transfer"
		description = string.format(
			"Transfer to Account: %s.%s",
			tostring(data.receiver or ""),
			(data.description and (" Description: " .. data.description) or "")
		)
	end

	if tonumber(balance) then
		account.balance = tonumber(balance)
	else
		account.balance = math.max(0, (tonumber(account.balance) or 0) + signedAmount)
	end

	transactionsRequestId = transactionsRequestId + 1

	table.insert(lastTransactionsPayload, 1, {
		id = string.format("local-%s-%s-%s", tostring(account.accountNumber), tostring(GetGameTimer()), action),
		accountNumber = account.accountNumber,
		title = title,
		description = description,
		amount = signedAmount,
		type = string.lower(action),
		createdAt = GetCurrentTimestampMillis(),
	})

	while #lastTransactionsPayload > 50 do
		table.remove(lastTransactionsPayload)
	end

	lastSummaryPayload = BuildSummary(lastTransactionsPayload)
	FinanceSendBankingData()
	FinanceSendPlayerUpdate()
end

local function FetchInitialTransactions(accounts)
	local transactions = {}
	local accountNumbers = {}

	for _, account in ipairs(accounts or {}) do
		if account.permissions and account.permissions.TRANSACTIONS then
			table.insert(accountNumbers, account.accountNumber)
		end
	end

	if #accountNumbers > 0 then
		local response = AwaitServerCallback("Banking:GetRecentTransactions", {
			accounts = accountNumbers,
			perPage = 25,
		}, 1000, {
			data = {},
			pages = 1,
			more = false,
		})

		transactions = NormalizeTransactions(response)
		return SortTransactions(transactions)
	end

	for _, account in ipairs(accounts or {}) do
		if account.permissions and account.permissions.TRANSACTIONS then
			local response = AwaitServerCallback("Banking:GetAccountsTransactions", {
				account = account.accountNumber,
				perPage = 10,
				offset = 0,
			}, 900, {
				data = {},
				pages = 1,
				more = false,
			})

			for _, transaction in ipairs(NormalizeTransactions(response, account.accountNumber)) do
				table.insert(transactions, transaction)
			end
		end
	end

	return SortTransactions(transactions)
end

function FinanceSendPlayerUpdate()
	SendReactMessage("banking:setPlayer", GetPlayerData())
end

function FinanceSendBankingData()
	SendReactMessage("banking:setAccounts", lastAccountsPayload)
	SendReactMessage("banking:setSummary", lastSummaryPayload)
	SendReactMessage("banking:setTransactions", lastTransactionsPayload)
end

local function RefreshTransactionsAsync(accounts)
	transactionsRequestId = transactionsRequestId + 1
	local requestId = transactionsRequestId

	CreateThread(function()
		local transactions = FetchInitialTransactions(accounts)

		if currentBankView == "bank" and requestId == transactionsRequestId then
			lastSummaryPayload = BuildSummary(transactions)
			lastTransactionsPayload = transactions
			FinanceSendBankingData()
			FinanceSendPlayerUpdate()
		end
	end)
end

function FinanceRefreshBanking(preferLite)
	if preferLite == nil then
		preferLite = currentBankView == "atm"
	end

	local accounts

	if preferLite then
		accounts = AwaitServerCallback("Banking:GetAccountsLite", {}, 1500, {})

		if type(accounts) ~= "table" or #accounts == 0 then
			accounts = AwaitServerCallback("Banking:GetAccounts", {}, 2000, accounts or {})
		end
	else
		accounts = AwaitServerCallback("Banking:GetAccounts", {}, 2500, {})
	end

	if not accounts then
		accounts = {}
	end

	if not preferLite and type(accounts) == "table" and #accounts == 0 then
		accounts = AwaitServerCallback("Banking:GetAccountsLite", {}, 1500, accounts) or accounts
	end

	if type(accounts) ~= "table" then
		lastAccountsPayload = {}
		lastSummaryPayload = BuildSummary({})
		lastTransactionsPayload = {}
		FinanceSendBankingData()
		FinanceSendPlayerUpdate()
		return false
	end

	local normalizedAccounts = NormalizeAccounts(accounts)

	lastAccountsPayload = normalizedAccounts
	if preferLite then
		lastSummaryPayload = BuildSummary({})
		lastTransactionsPayload = {}
	else
		lastSummaryPayload = BuildSummary(lastTransactionsPayload or {})
	end

	FinanceSendBankingData()
	FinanceSendPlayerUpdate()

	if preferLite then
		if currentBankView == "bank" then
			RefreshTransactionsAsync(normalizedAccounts)
		end

		return true
	end

	transactionsRequestId = transactionsRequestId + 1
	local requestId = transactionsRequestId
	local transactions = FetchInitialTransactions(normalizedAccounts)

	if requestId ~= transactionsRequestId then
		return true
	end

	lastSummaryPayload = BuildSummary(transactions)
	lastTransactionsPayload = transactions

	FinanceSendBankingData()
	FinanceSendPlayerUpdate()

	return true
end

local function PushBankingOpenState(view, options)
	SendReactMessage("banking:setView", view == "ATM" and "ATM" or "BANKING")

	if view == "ATM" then
		SendReactMessage("banking:setDepositVisible", options.depositVisible ~= false)
		SendReactMessage("banking:atm:setData", {
			street = options.street or "ATM",
			maxWithdraw = options.maxWithdraw or 5000,
		})
	else
		SendReactMessage("banking:setDepositVisible", true)
	end

	SendReactMessage("banking:setVisible", true)
end

function FinanceOpenBanking(view, options)
	currentBankView = view == "ATM" and "atm" or "bank"
	options = options or {}
	currentBankOptions = options
	transactionsRequestId = transactionsRequestId + 1

	SetNuiFocus(true, true)
	PushBankingOpenState(view, options)
	lastAccountsPayload = {}
	lastSummaryPayload = BuildSummary({})
	lastTransactionsPayload = {}
	FinanceSendBankingData()
	FinanceSendPlayerUpdate()

	CreateThread(function()
		for _ = 1, 24 do
			Wait(250)

			if currentBankView then
				PushBankingOpenState(view, currentBankOptions)
				FinanceSendBankingData()
				FinanceSendPlayerUpdate()
			end
		end
	end)

	CreateThread(function()
		if view == "ATM" then
			Wait(100)
			if currentBankView then
				FinanceRefreshBanking(true)
			end

			Wait(900)
			if currentBankView then
				FinanceRefreshBanking(true)
			end

			return
		end

		Wait(100)
		if currentBankView then
			FinanceRefreshBanking(true)
		end

		Wait(800)
		if currentBankView then
			FinanceRefreshBanking(false)
		end

		Wait(2500)
		if currentBankView then
			FinanceRefreshBanking(false)
		end
	end)
end

function FinanceCloseBanking(playAtmAnimation)
	SetNuiFocus(false, false)
	SendReactMessage("banking:setVisible", false)
	SendReactMessage("banking:close")

	if playAtmAnimation and currentBankView == "atm" then
		exports["pulsar-hud"]:Progress({
			name = "atm_removing",
			duration = 1500,
			label = "Removing Card",
			useWhileDead = false,
			canCancel = false,
			ignoreModifier = true,
			controlDisables = {
				disableMovement = true,
				disableCarMovement = true,
				disableMouse = false,
				disableCombat = true,
			},
			animation = {
				animDict = "amb@prop_human_atm@male@idle_a",
				anim = "idle_b",
				flags = 49,
			},
			disarm = true,
		}, function() end)
	end

	currentBankView = false
	currentBankOptions = {}
	transactionsRequestId = transactionsRequestId + 1
end

RegisterNUICallback("banking:close", function(_, cb)
	FinanceCloseBanking(true)
	cb(true)
end)

RegisterNUICallback("banking:doAction", function(data, cb)
	data = data or {}

	if not currentBankView then
		cb({
			success = false,
			error = "Banking is not open.",
		})
		return
	end

	local success, balance = AwaitServerCallback("Banking:DoAccountAction", {
		account = data.account,
		action = data.type,
		amount = tonumber(data.amount),
		description = data.description,
		targetType = data.transferType == "STATE_ID",
		target = tonumber(data.receiver),
	}, 1500, false)

	if success then
		if data.type == "DEPOSIT" then
			Notify("success", string.format("You Deposited $%s", data.amount))
		elseif data.type == "WITHDRAW" then
			Notify("success", string.format("You Withdrew $%s", data.amount))
		elseif data.type == "TRANSFER" then
			Notify("success", string.format("You Transferred $%s", data.amount))
		end

		ApplyLocalBankingAction(data, balance)

		cb({
			success = true,
		})

		CreateThread(function()
			Wait(250)

			if currentBankView then
				FinanceRefreshBanking(currentBankView == "atm")
			end
		end)

		return
	end

	cb({
		success = false,
		error = "Something went wrong, please try again.",
	})
end)

RegisterNUICallback("banking:validateReceiver", function(data, cb)
	local receiver = AwaitServerCallback("Banking:ValidateReceiver", data or {}, 3500, false)
	cb(receiver or false)
end)

RegisterNUICallback("banking:addJointOwner", function(data, cb)
	local owner, error = AwaitServerCallback("Banking:AddJointDetails", data or {}, 5000, false, "Invalid state id.")

	if owner then
		FinanceRefreshBanking()
	end

	cb({
		success = owner or false,
		error = error or "Invalid state id.",
	})
end)

RegisterNUICallback("banking:deleteJointOwner", function(data, cb)
	data = data or {}

	local success = AwaitServerCallback("Banking:RemoveJoint", {
		account = data.account,
		target = tonumber(data.stateId),
	}, 5000, false)

	if success then
		FinanceRefreshBanking()
	end

	cb({
		success = success == true,
		error = success and nil or "Failed to delete joint owner.",
	})
end)

RegisterNUICallback("banking:saveAccount", function(data, cb)
	local success = AwaitServerCallback("Banking:RenameAccount", data or {}, 5000, false)

	if success then
		FinanceRefreshBanking()
	end

	cb(success == true)
end)

RegisterNUICallback("banking:deleteAccount", function(data, cb)
	local success = AwaitServerCallback("Banking:DeleteAccount", data or {}, 5000, false)

	if success then
		FinanceRefreshBanking()
	end

	cb(success == true)
end)

RegisterNUICallback("banking:createAccount", function(accountName, cb)
	local account = AwaitServerCallback("Banking:RegisterAccount", {
		type = "personal_savings",
		name = accountName,
	}, 5000, false)

	if account then
		FinanceRefreshBanking()
	end

	cb({
		success = account ~= false and account ~= nil,
		error = account and nil or "You don't have enough money to create an account.",
	})
end)

RegisterNUICallback("banking:getTransactions", function(data, cb)
	data = data or {}

	local response = AwaitServerCallback("Banking:GetAccountsTransactions", {
		account = data.accountNumber,
		perPage = 25,
		offset = data.offset or 0,
	}, 1000, {
		data = {},
		pages = 1,
		more = false,
	})

	cb(NormalizeTransactions(response, data.accountNumber))
end)

RegisterNUICallback("banking:exportTransactions", function(_, cb)
	cb(false)
end)

RegisterNUICallback("banking:copy", function(copy, cb)
	local text = tostring(copy or "")

	if lib and lib.setClipboard then
		lib.setClipboard(text)
	else
		SendNUIMessage({
			type = "clipboard",
			data = text,
		})
	end

	cb(true)
end)

RegisterNUICallback("GET_LOCALES", function(_, cb)
	local defaultLocale = GetConvar("ox:locale", "en")
	local rawLocale = LoadResourceFile(GetCurrentResourceName(), ("locales/%s.json"):format(defaultLocale))

	if not rawLocale then
		defaultLocale = "en"
		rawLocale = LoadResourceFile(GetCurrentResourceName(), "locales/en.json") or "{}"
	end

	local ok, decoded = pcall(json.decode, rawLocale)

	if not ok or type(decoded) ~= "table" then
		decoded = {}
	end

	cb({
		locales = json.encode({
			[defaultLocale] = {
				translation = decoded,
			},
		}),
		defaultLocale = defaultLocale,
	})
end)
