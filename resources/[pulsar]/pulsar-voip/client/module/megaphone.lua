function StartUsingMegaphone(vehAnim)
	if PLAYER_CONNECTED and (not CALL_CHANNEL or CALL_CHANNEL <= 0) and not RADIO_TALKING and not USING_MICROPHONE then
		CreateThread(function()
			exports['pulsar-core']:LoggerInfo("VOIP", "Megaphone On")
			USING_MEGAPHONE = true
			if vehAnim then
				exports['pulsar-animations']:EmotesPlay("radio", false, false, true)
			else
				exports['pulsar-animations']:EmotesPlay("megaphone", false, false, true)
			end
			UpdateVOIPIndicatorStatus()
			while
				_characterLoaded
				and USING_MEGAPHONE
				and (not CALL_CHANNEL or CALL_CHANNEL <= 0)
				and not LocalPlayer.state.isDead
				and not USING_MICROPHONE
			do
				TriggerServerEvent("VOIP:Server:Megaphone:SetPlayerState", true)

				NetworkSetTalkerProximity(VOIP_CONFIG.MegaphoneRange + 0.0)
				Wait(7500)
			end

			StopUsingMegaphone()
			StopUsingMicrophone()
		end)
	end
end

function StopUsingMegaphone()
	if USING_MEGAPHONE then
		exports['pulsar-core']:LoggerInfo("VOIP", "Megaphone Off")
		USING_MEGAPHONE = false
		TriggerServerEvent("VOIP:Server:Megaphone:SetPlayerState", false)

		NetworkSetTalkerProximity(CURRENT_VOICE_MODE_DATA.Range + 0.0)
		exports['pulsar-animations']:EmotesForceCancel()
		UpdateVOIPIndicatorStatus()
	end
end

RegisterNetEvent("VOIP:Client:Megaphone:SetPlayerState", function(targetSource, state)
	if VOIP ~= nil and LocalPlayer.state.loggedIn then
		exports["pulsar-voip"]:ToggleVoice(targetSource, state, "megaphone")
	end
end)

RegisterNetEvent("VOIP:Client:Megaphone:Use", function(vehAnim)
	if not USING_MEGAPHONE then
		StartUsingMegaphone(vehAnim)
	else
		StopUsingMegaphone(vehAnim)
	end
end)

RegisterNetEvent("Characters:Client:SetData", function()
	Wait(1000)
	if LocalPlayer.state.loggedIn and USING_MEGAPHONE then
		if not CheckCharacterHasMegaphone() then
			StopUsingMegaphone()
		end
	end
end)

function CheckCharacterHasMegaphone()
	local character = LocalPlayer.state.Character
	if character then
		local states = character:GetData("States") or {}
		for k, v in ipairs(states) do
			if v == "MEGAPHONE" then
				return true
			end
		end
	end
	return false
end
