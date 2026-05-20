local _actionCooldowns = {}
local SAVINGS_ACCOUNT_CREATION_FEE = 500

local function GetCharacterSummaryBySID(stateId)
	local sid = tonumber(stateId)
	if not sid then
		return false
	end

	local result = MySQL.single.await("SELECT SID, First, Last FROM characters WHERE SID = ?", {
		sid
	})

	if not result then
		return false
	end

	return {
		stateId = tonumber(result.SID) or sid,
		firstName = result.First or "",
		lastName = result.Last or "",
	}
end

function RegisterBankingCallbacks()
	exports["pulsar-core"]:RegisterServerCallback("Finance:Paycheck", function(source, data, cb)
		local pState = Player(source).state
		pState.gettingPaycheck = true
		local char = exports['pulsar-characters']:FetchCharacterSource(source)

		local salary = char:GetData("Salary") or {}
		local amt = 0
		local mts = 0
		for k, v in pairs(salary) do
			amt = amt + v.total
			mts = mts + v.minutes
		end

		if amt > 0 then
			char:SetData("Salary", {})
			exports['pulsar-finance']:BalanceDeposit(
				exports['pulsar-finance']:AccountsGetPersonal(char:GetData("SID")).Account, amt, {
					type = 'paycheck',
					title = "Paycheck",
					description = string.format('Paycheck For %s Minutes Worked', mts),
					data = salary
				})
		end

		cb({
			total = amt,
			minutes = mts,
		})
		pState.gettingPaycheck = false
	end)

	exports["pulsar-core"]:RegisterServerCallback("Banking:RegisterAccount", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)

		if char ~= nil then
			if data and data.type == "personal_savings" then
				if not exports['pulsar-finance']:WalletModify(source, -SAVINGS_ACCOUNT_CREATION_FEE, true) then
					cb(false)
					return
				end

				local acc = exports['pulsar-finance']:AccountsCreatePersonalSavings(char:GetData("SID"))
				if not acc then
					exports['pulsar-finance']:WalletModify(source, SAVINGS_ACCOUNT_CREATION_FEE, true)
					cb(false)
					return
				end

				acc.Permissions = {
					MANAGE = true,
					BALANCE = true,
					WITHDRAW = true,
					DEPOSIT = true,
					TRANSACTIONS = true,
				}

				if acc and data.name and #tostring(data.name) > 0 then
					MySQL.query.await("UPDATE bank_accounts SET name = ? WHERE account = ?", {
						tostring(data.name),
						acc.Account
					})
					acc.Name = tostring(data.name)
				end

				cb(acc)
			else
				cb(false)
			end
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Banking:RenameAccount", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local accountData = data and exports['pulsar-finance']:AccountsGet(data.account)

		if char and accountData and data.name and HasBankAccountPermission(source, accountData, "MANAGE", char:GetData("SID")) then
			MySQL.query.await("UPDATE bank_accounts SET name = ? WHERE account = ?", {
				tostring(data.name),
				accountData.Account
			})

			cb(true)
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Banking:AddJoint", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char and data and data.target > 0 then
			local results = MySQL.Sync.fetchAll('SELECT * FROM characters WHERE SID = @sid', {
				['@sid'] = data.target
			})

			if results and #results > 0 then
				local tChar = results[1]
				if tChar.User == char:GetData("User") then
					exports['pulsar-core']:LoggerInfo("Billing",
						string.format(
							"%s %s (%s) [%s] Tried Adding Their Other Character (SID: %s) To a Joint Bank Account (Account: %s).",
							char:GetData("First"), char:GetData("Last"), char:GetData("SID"), char:GetData("User"),
							tChar.SID, data.account), {
							console = true,
							file = true,
							database = true,
							discord = {
								embed = true,
								type = 'info',
								webhook = GetConvar('discord_log_webhook', ''),
							}
						})

					cb(false)
				else
					cb(exports['pulsar-finance']:AccountsAddPersonalSavingsJointOwner(data.account, data.target))
				end
			else
				cb(false)
			end
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Banking:AddJointDetails", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local target = tonumber(data and data.stateId)
		local accountData = data and exports['pulsar-finance']:AccountsGet(data.account)

		if not char or not target or not accountData or accountData.Type ~= "personal_savings" then
			cb(false, "Invalid state id.")
			return
		end

		if not HasBankAccountPermission(source, accountData, "MANAGE", char:GetData("SID")) then
			cb(false, "You don't have permission to manage this account.")
			return
		end

		local results = MySQL.Sync.fetchAll('SELECT * FROM characters WHERE SID = @sid', {
			['@sid'] = target
		})

		if not results or #results == 0 then
			cb(false, "Invalid state id.")
			return
		end

		local targetCharacter = results[1]
		if targetCharacter.User == char:GetData("User") then
			cb(false, "Invalid account owner.")
			return
		end

		local success = exports['pulsar-finance']:AccountsAddPersonalSavingsJointOwner(accountData.Account, target)

		if success then
			cb({
				stateId = tonumber(targetCharacter.SID) or target,
				firstName = targetCharacter.First or "",
				lastName = targetCharacter.Last or "",
			})
		else
			cb(false, "Something went wrong with adding the joint owner, please try again.")
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Banking:RemoveJoint", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local accountData = data and exports['pulsar-finance']:AccountsGet(data.account)

		if char and accountData and HasBankAccountPermission(source, accountData, "MANAGE", char:GetData("SID")) then
			cb(exports['pulsar-finance']:AccountsRemovePersonalSavingsJointOwner(data.account, data.target))
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Banking:ValidateReceiver", function(source, data, cb)
		local receiver = tonumber(data and data.receiver)

		if not receiver then
			cb(false)
			return
		end

		if data and data.transferType == "STATE_ID" then
			local character = GetCharacterSummaryBySID(receiver)
			local personalAccount = character and exports['pulsar-finance']:AccountsGetPersonal(receiver)
			cb(personalAccount and character or false)
			return
		end

		local account = exports['pulsar-finance']:AccountsGet(receiver)

		if not account then
			cb(false)
			return
		end

		if account.Type == "personal" or account.Type == "personal_savings" then
			cb(GetCharacterSummaryBySID(account.Owner) or {
				stateId = tonumber(account.Owner) or 0,
				firstName = "",
				lastName = account.Name or tostring(account.Account),
			})
		else
			cb({
				stateId = 0,
				firstName = "",
				lastName = account.Name or tostring(account.Account),
			})
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Banking:DeleteAccount", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		local accountNumber = type(data) == "table" and (data.account or data.accountNumber) or data

		if not char or not accountNumber then
			cb(false)
			return
		end

		local SID = tostring(char:GetData("SID"))
		local accountData = exports['pulsar-finance']:AccountsGet(accountNumber)

		if not accountData or accountData.Type ~= "personal_savings" or accountData.Owner ~= SID then
			cb(false)
			return
		end

		local personalAccount = exports['pulsar-finance']:AccountsGetPersonal(SID)
		if not personalAccount then
			personalAccount = exports['pulsar-finance']:AccountsCreatePersonal(SID)
		end

		if not personalAccount then
			cb(false)
			return
		end

		local balance = tonumber(accountData.Balance) or 0
		if balance > 0 then
			exports['pulsar-finance']:BalanceDeposit(personalAccount.Account, balance, {
				type = "transfer",
				title = "Account Closure",
				description = string.format("Remaining balance transferred from closed account: %s.", accountData.Account),
				transactionAccount = accountData.Account,
				data = {
					character = char:GetData("SID"),
				},
			}, true)
		end

		MySQL.query.await("DELETE FROM bank_accounts_permissions WHERE account = ?", {
			accountData.Account
		})

		local deleted = MySQL.query.await("DELETE FROM bank_accounts WHERE account = ? AND type = ? AND owner = ?", {
			accountData.Account,
			"personal_savings",
			SID
		})

		cb(deleted and deleted.affectedRows and deleted.affectedRows > 0)
	end)

	exports["pulsar-core"]:RegisterServerCallback("Banking:GetAccounts", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char then
			local SID = char:GetData("SID")

			local eQry =
			"SELECT account, type, job, workplace, jobPermissions FROM bank_accounts_permissions WHERE (type = ? AND jointOwner = ?)"

			local params = {
				1,
				tostring(SID)
			}

			local charJobs = char:GetData("Jobs") or {}
			for k, v in ipairs(charJobs) do
				if v.Workplace and v.Workplace.Id then
					eQry = eQry .. " OR (type = ? AND job = ? AND workplace = ?)"
					table.insert(params, 0)
					table.insert(params, v.Id)
					table.insert(params, v.Workplace.Id)
				end

				eQry = eQry .. " OR (type = ? AND job = ? AND workplace = ?)"
				table.insert(params, 0)
				table.insert(params, v.Id)
				table.insert(params, "")
			end

			local pData = MySQL.query.await(eQry, params) or {}

			local jobBankAccounts = {}
			local jobBankPerms = {}

			for k, v in ipairs(pData) do
				if v.type == 0 and v.job then
					if not jobBankPerms[v.account] then
						jobBankPerms[v.account] = { v }
					else
						table.insert(jobBankPerms[v.account], v)
					end

					table.insert(jobBankAccounts, v.account)
				elseif v.type == 1 then
					table.insert(jobBankAccounts, v.account)
				end
			end

			local qry =
			"SELECT account as Account, balance as Balance, type as Type, owner as Owner, name as Name FROM bank_accounts WHERE (type = ? AND owner = ?) OR (type = ? AND owner = ?)"
			if jobBankAccounts and #jobBankAccounts > 0 then
				qry = string.format(
					"SELECT account as Account, balance as Balance, type as Type, owner as Owner, name as Name FROM bank_accounts WHERE account IN (%s) OR (type = ? AND owner = ?) OR (type = ? AND owner = ?)",
					table.concat(jobBankAccounts, ","))
			end

			local availableAccounts = MySQL.query.await(qry, {
				"personal",
				tostring(SID),
				"personal_savings",
				tostring(SID)
			}) or {}

			local jointOwnerStuff = {}

			for k, v in ipairs(availableAccounts) do
				if v.Type == "personal_savings" and v.Owner == tostring(SID) then
					table.insert(jointOwnerStuff, v.Account)
				end
			end

			local jointOwnerData = {}
			if #jointOwnerStuff > 0 then
				local jO = MySQL.query.await(
					string.format(
						"SELECT account, jointOwner FROM bank_accounts_permissions WHERE account IN (%s) AND type = ?",
						table.concat(jointOwnerStuff, ",")), {
						1
					}) or {}

				for k, v in ipairs(jO) do
					local owner = GetCharacterSummaryBySID(v.jointOwner) or {
						stateId = tonumber(v.jointOwner) or 0,
						firstName = "State",
						lastName = tostring(v.jointOwner),
					}

					if not jointOwnerData[v.account] then
						jointOwnerData[v.account] = { owner }
					else
						table.insert(jointOwnerData[v.account], owner)
					end
				end
			end

			local availableAccountsData = {}
			local accountTransactionData = {}

			for _, account in ipairs(availableAccounts) do
				if account.Type == "personal" then
					account.Permissions = {
						MANAGE = true,
						BALANCE = true,
						WITHDRAW = true,
						DEPOSIT = true,
						TRANSACTIONS = true,
					}
					table.insert(availableAccountsData, account)
				elseif account.Type == "personal_savings" then
					account.Permissions = {
						MANAGE = account.Owner == tostring(SID),
						BALANCE = true,
						WITHDRAW = true,
						DEPOSIT = true,
						TRANSACTIONS = true,
					}
					account.JointOwners = jointOwnerData[account.Account] or {}

					table.insert(availableAccountsData, account)
				elseif account.Type == "organization" then
					local jPData = jobBankPerms[account.Account]
					if jPData then
						for _, job in ipairs(jPData) do
							local workplace = false
							if job.workplace and job.workplace ~= "" and #job.workplace > 0 then
								workplace = job.workplace
							end
							local jobPermissions = exports['pulsar-jobs']:GetPermissionsFromJob(
								source,
								job.job,
								workplace
							)

							if jobPermissions then
								account.Permissions = {}
								local permList = json.decode(job.jobPermissions or "{}")
								for perm, jobPerm in pairs(permList) do
									if jobPermissions[jobPerm] then
										account.Permissions[perm] = true
									else
										account.Permissions[perm] = false
									end
								end

								table.insert(availableAccountsData, account)
								break
							end
						end
					end
				end
			end

			cb(availableAccountsData, PENDING_BILLS[SID])
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Banking:GetAccountsLite", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)

		if not char then
			cb({})
			return
		end

		local SID = tostring(char:GetData("SID"))
		local accounts = MySQL.query.await(
			"SELECT account as Account, balance as Balance, type as Type, owner as Owner, name as Name FROM bank_accounts WHERE (type = ? AND owner = ?) OR (type = ? AND owner = ?)",
			{
				"personal",
				SID,
				"personal_savings",
				SID,
			}
		) or {}

		if #accounts == 0 then
			local personalAccount = exports['pulsar-finance']:AccountsCreatePersonal(SID)

			if personalAccount then
				accounts = { personalAccount }
				char:SetData("BankAccount", personalAccount.Account)
			end
		end

		for _, account in ipairs(accounts) do
			account.Permissions = {
				MANAGE = account.Type == "personal" or account.Owner == SID,
				BALANCE = true,
				WITHDRAW = true,
				DEPOSIT = true,
				TRANSACTIONS = true,
			}

			account.JointOwners = {}
		end

		cb(accounts)
	end)

	exports["pulsar-core"]:RegisterServerCallback("Banking:GetRecentTransactions", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)

		if not char or type(data) ~= "table" or type(data.accounts) ~= "table" then
			cb({
				data = {},
				pages = 1,
				more = false,
			})
			return
		end

		local SID = char:GetData("SID")
		local limit = math.floor(tonumber(data.perPage) or 25)
		limit = math.max(1, math.min(limit, 50))

		local allowedAccounts = {}
		local seenAccounts = {}

		for _, accountNumber in ipairs(data.accounts) do
			local normalizedAccount = tonumber(accountNumber)

			if normalizedAccount and not seenAccounts[normalizedAccount] then
				local accountData = exports['pulsar-finance']:AccountsGet(normalizedAccount)

				if accountData and HasBankAccountPermission(source, accountData, "TRANSACTIONS", SID) then
					seenAccounts[normalizedAccount] = true
					table.insert(allowedAccounts, normalizedAccount)
				end
			end
		end

		if #allowedAccounts == 0 then
			cb({
				data = {},
				pages = 1,
				more = false,
			})
			return
		end

		local placeholders = {}
		local params = {}

		for _, accountNumber in ipairs(allowedAccounts) do
			table.insert(placeholders, "?")
			table.insert(params, accountNumber)
		end

		table.insert(params, limit + 1)

		local query = (
			"SELECT type as Type, account as Account, title as Title, timestamp as Timestamp, amount as Amount, description as Description FROM bank_accounts_transactions WHERE account IN (%s) ORDER BY timestamp DESC LIMIT ?"
		):format(table.concat(placeholders, ","))

		local transactions = MySQL.query.await(query, params) or {}

		local isMore = false
		if #transactions > limit then
			table.remove(transactions)
			isMore = true
		end

		cb({
			data = transactions,
			pages = 1,
			more = isMore,
		})
	end)

	exports["pulsar-core"]:RegisterServerCallback("Banking:GetAccountsTransactions", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if char and data?.account and data?.perPage then
			local offset = data?.offset or 0
			if data?.page then
				offset = data.perPage * (data.page - 1)
			end

			local transactions = MySQL.query.await(
				"SELECT type as Type, account as Account, title as Title, timestamp as Timestamp, amount as Amount, description as Description FROM bank_accounts_transactions WHERE account = ? ORDER BY timestamp DESC LIMIT ? OFFSET ?",
				{
					data.account,
					data.perPage + 1,
					offset
				}) or {}

			local pages = data.page or 1
			local isMore = false
			if #transactions > data.perPage then
				table.remove(transactions)

				pages += 1
				isMore = true
			end

			cb({
				data = transactions,
				pages = pages,
				more = isMore,
			})
		else
			cb(false)
		end
	end)

	exports["pulsar-core"]:RegisterServerCallback("Banking:DoAccountAction", function(source, data, cb)
		local char = exports['pulsar-characters']:FetchCharacterSource(source)
		if not char or not data then
			cb(false)
			return
		end

		local SID = char:GetData("SID")
		local account, action = data.account, data.action
		if not account or not action then
			cb(false)
			return
		end

		local accountData = exports['pulsar-finance']:AccountsGet(account)
		if accountData then
			if _actionCooldowns[source] and _actionCooldowns[source] > GetGameTimer() then
				exports['pulsar-core']:LoggerWarn("Pwnzor",
					string.format(
						"%s %s (%s) Triggered 2 Bank Account Actions in 2 Seconds They Are Probably Cheating (%s)",
						char:GetData("First"), char:GetData("Last"), char:GetData("SID"), json.encode(data)), {
						console = true,
						file = false,
						database = true,
						discord = {
							embed = true,
							type = 'error',
							webhook = GetConvar('discord_pwnzor_webhook', ''),
						}
					}, {
						data = data
					})
				exports['pulsar-pwnzor']:Screenshot(char:GetData("SID"), "Bank Account Actions Cooldown Exceeded")

				cb(false)
				return
			end

			_actionCooldowns[source] = GetGameTimer() + 2000

			if action == "WITHDRAW" then
				local withdrawAmount = tonumber(data.amount)
				if
					withdrawAmount
					and withdrawAmount > 0
					and accountData.Balance >= withdrawAmount
					and HasBankAccountPermission(source, accountData, action, SID)
				then
					local wSucc = exports['pulsar-finance']:BalanceWithdraw(accountData.Account, withdrawAmount, {
						type = "withdraw",
						title = "Cash Withdrawal",
						description = data.description or "No Description",
						transactionAccount = false,
						data = {
							character = SID,
						},
					})

					if wSucc then
						exports['pulsar-finance']:WalletModify(source, withdrawAmount, true)
						cb(true, exports['pulsar-finance']:BalanceGet(accountData.Account))
						return
					end
				end
			elseif action == "DEPOSIT" then
				local depositAmount = tonumber(data.amount)
				if
					depositAmount
					and depositAmount > 0
					and HasBankAccountPermission(source, accountData, action, SID)
				then
					if exports['pulsar-finance']:WalletModify(source, -depositAmount, true) then
						local dSucc = exports['pulsar-finance']:BalanceDeposit(accountData.Account, depositAmount, {
							type = "deposit",
							title = "Cash Deposit",
							description = data.description or "No Description",
							transactionAccount = false,
							data = {
								character = SID,
							},
						})

						if dSucc then
							cb(true, exports['pulsar-finance']:BalanceGet(accountData.Account))
							return
						end
					end
				end
			elseif action == "TRANSFER" then
				local transferAmount = tonumber(data.amount)
				local targetAccount = false
				if data.targetType then
					targetAccount = exports['pulsar-finance']:AccountsGetPersonal(data.target)
				else
					targetAccount = exports['pulsar-finance']:AccountsGet(tonumber(data.target))
				end

				if transferAmount and transferAmount > 0 and targetAccount then
					if
						accountData.Balance >= transferAmount
						and HasBankAccountPermission(source, accountData, "WITHDRAW", SID)
					then
						local p = promise.new()

						if targetAccount.Type == "personal" or targetAccount.Type == "personal_savings" then
							local results = MySQL.Sync.fetchAll('SELECT * FROM characters WHERE SID = @sid', {
								['@sid'] = tonumber(targetAccount.Owner)
							})

							if results and #results > 0 then
								local tChar = results[1]
								if tChar.User == char:GetData("User") and tChar.SID ~= char:GetData("SID") then
									exports['pulsar-core']:LoggerInfo("Billing",
										string.format(
											"%s %s (%s) [%s] Tried Bank Transferring to their other character (SID: %s, Account: %s).",
											char:GetData("First"), char:GetData("Last"), char:GetData("SID"),
											char:GetData("User"), tChar.SID, targetAccount.Account), {
											console = true,
											file = true,
											database = true,
											discord = {
												embed = true,
												type = 'info',
												webhook = GetConvar('discord_log_webhook', ''),
											}
										})

									p:resolve(false)
								else
									p:resolve(true)
								end
							else
								p:resolve(false)
							end
						else
							p:resolve(true)
						end

						local canTransfer = Citizen.Await(p)

						if canTransfer then
							local success = exports['pulsar-finance']:BalanceWithdraw(accountData.Account,
								transferAmount, {
									type = "transfer",
									title = "Outgoing Bank Transfer",
									description = string.format(
										"Transfer to Account: %s.%s",
										targetAccount.Account,
										(data.description and (" Description: " .. data.description) or "")
									),
									data = {
										character = SID,
									},
								})

							if success then
								local success2 = exports['pulsar-finance']:BalanceDeposit(targetAccount.Account,
									transferAmount, {
										type = "transfer",
										title = "Incoming Bank Transfer",
										description = string.format(
											"Transfer from Account: %s.%s",
											accountData.Account,
											(data.description and (" Description: " .. data.description) or "")
										),
										transactionAccount = accountData.Account,
										data = {
											character = SID,
										},
									})
								cb(success2, exports['pulsar-finance']:BalanceGet(accountData.Account))
								return
							end
						end
					end
				end
			end
		end
		cb(false)
	end)
end
