local RENT_AMOUNT    = 2000
local RENT_INTERVAL  = 7 * 24 * 60 * 60   -- 7 days in seconds
local GRACE_PERIOD   = 3 * 24 * 60 * 60   -- 3 days in seconds

local function AptLabel(apt)
	return string.format("%s - Room %s", apt.buildingLabel or apt.buildingName or "Apartment", apt.roomLabel or "?")
end

local function SendRentEmail(source, subject, body)
	if not source or source <= 0 then return end
	exports["pulsar-phone"]:EmailSend(source, "rent@pulse.gov", os.time(), subject, body)
end

-- Attempt to charge rent from the character's personal bank account.
-- Updates DB and in-memory state. Sends email for success or failure.
function ProcessRentPayment(source, characterSID, aptId)
	local apt = _aptData[aptId]
	if not apt then return false end

	local account = exports["pulsar-finance"]:AccountsGetPersonal(characterSID)
	if not account or not account.Account then
		exports["pulsar-hud"]:Notification(source, "error", "No bank account found — rent could not be collected")
		return false
	end

	local ok = exports["pulsar-finance"]:BalanceCharge(account.Account, RENT_AMOUNT, {
		type        = "bill",
		title       = "Apartment Rent",
		description = string.format("Weekly rent — %s", AptLabel(apt)),
	})

	local now = os.time()

	if ok then
		MySQL.update.await(
			"UPDATE apartment_assignments SET rent_paid_at = ?, rent_grace_until = NULL WHERE apartment_id = ? AND character_sid = ?",
			{ now * 1000, aptId, characterSID }
		)

		local entry = _assignedApartments[aptId]
		if entry then
			entry.rentPaidAt    = now
			entry.rentGraceUntil = nil
		end

		SendRentEmail(source,
			"Rent Payment Confirmed",
			string.format(
				"Your weekly rent of <b>$%s</b> for <b>%s</b> has been charged.<br><br>" ..
				"Next payment due: <b>%s</b><br><br>Thank you for your continued tenancy.",
				RENT_AMOUNT,
				AptLabel(apt),
				os.date("%B %d, %Y", now + RENT_INTERVAL)
			)
		)
		return true
	else
		-- Insufficient funds — open a grace period
		local graceUntil = now + GRACE_PERIOD

		MySQL.update.await(
			"UPDATE apartment_assignments SET rent_grace_until = ? WHERE apartment_id = ? AND character_sid = ?",
			{ graceUntil * 1000, aptId, characterSID }
		)

		local entry = _assignedApartments[aptId]
		if entry then
			entry.rentGraceUntil = graceUntil
		end

		SendRentEmail(source,
			"Rent Payment Failed — Action Required",
			string.format(
				"We were unable to charge <b>$%s</b> rent for <b>%s</b>.<br><br>" ..
				"A <b>3-day grace period</b> has been opened. If payment is not collected by <b>%s</b> your apartment will be repossessed.<br><br>" ..
				"Ensure your bank account has sufficient funds.",
				RENT_AMOUNT,
				AptLabel(apt),
				os.date("%B %d, %Y", graceUntil)
			)
		)

		exports["pulsar-hud"]:Notification(source, "error",
			string.format("Rent of $%s failed — 3 days to resolve before eviction", RENT_AMOUNT)
		)
		return false
	end
end

-- Called when a character comes online. Handles eviction, grace-period reminders,
-- and triggering a payment when rent falls due.
function CheckRentDue(source, characterSID)
	local aptId = GetCharacterApartment(characterSID)
	if not aptId or not _aptData[aptId] then return end

	local entry = _assignedApartments[aptId]
	if not entry then return end

	local now = os.time()

	-- Grace period expired — evict
	if entry.rentGraceUntil and now > entry.rentGraceUntil then
		local apt = _aptData[aptId]
		exports["pulsar-core"]:LoggerInfo("Custom Apartments",
			string.format("Evicting character %s from apt %s — grace period expired", characterSID, aptId),
			{ console = true }
		)
		ReleaseApartmentAssignment(aptId, characterSID, false)
		exports["pulsar-hud"]:Notification(source, "error", "Your apartment has been repossessed due to unpaid rent")
		SendRentEmail(source,
			"Apartment Repossession Notice",
			string.format(
				"Due to non-payment of rent, your apartment at <b>%s</b> has been repossessed.<br><br>" ..
				"Visit the reception desk to request a new unit.",
				apt and AptLabel(apt) or "your unit"
			)
		)
		return
	end

	-- Still in grace period — remind them
	if entry.rentGraceUntil then
		local daysLeft = math.max(0, math.floor((entry.rentGraceUntil - now) / 86400))
		exports["pulsar-hud"]:Notification(source, "warning",
			string.format("Rent overdue! $%s needed. %s day(s) until eviction.", RENT_AMOUNT, daysLeft)
		)
		return
	end

	-- Check if a payment is now due
	local rentDue = false
	if not entry.rentPaidAt then
		-- First payment triggers after the first full week of tenancy
		local secondsSinceAssigned = now - math.floor(entry.assignedAt / 1000)
		rentDue = secondsSinceAssigned >= RENT_INTERVAL
	else
		rentDue = (now - entry.rentPaidAt) >= RENT_INTERVAL
	end

	if rentDue then
		ProcessRentPayment(source, characterSID, aptId)
	end
end

-- Periodic server-side sweep: checks every 5 minutes for any online player whose
-- rent has come due or whose grace period has expired while they were online.
CreateThread(function()
	Wait(15000) -- give Startup() time to complete on resource boot
	while true do
		Wait(300000) -- 5 minutes
		for _, playerSrc in ipairs(GetPlayers()) do
			local src  = tonumber(playerSrc)
			local char = exports["pulsar-characters"]:FetchCharacterSource(src)
			if char then
				local sid = char:GetData("SID")
				if sid then
					CheckRentDue(src, tonumber(sid))
				end
			end
		end
	end
end)
