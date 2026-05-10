-- Storage Crates — register item "use" with pulsar ox_inventory bridge.
-- Callback shape: (source, slotData, itemDef) where slotData is bridge toSlot() (Slot, Name, MetaData, …).

local _registered = false

local function RegisterItemUse()
	if _registered then
		return
	end
	if not Config or not Config.CrateTiers then
		return
	end
	if GetResourceState("ox_inventory") ~= "started" or not exports.ox_inventory or not exports.ox_inventory.RegisterUse then
		return
	end

	for tier, config in pairs(Config.CrateTiers) do
		exports.ox_inventory:RegisterUse(tier, "StorageCrates", function(source, slotData, itemDef)
			local usedSlot
			if type(slotData) == "table" then
				usedSlot = slotData.Slot or slotData.slot
			end
			TriggerClientEvent("StorageCrates:Client:StartPlacement", source, tier, usedSlot)
		end)
	end

	_registered = true
end

local function tryRegister()
	RegisterItemUse()
end

AddEventHandler("onResourceStop", function(resourceName)
	if resourceName == "ox_inventory" then
		_registered = false
	end
end)

AddEventHandler("onResourceStart", function(resourceName)
	if resourceName == "ox_inventory" or resourceName == GetCurrentResourceName() then
		CreateThread(function()
			for _ = 1, 60 do
				tryRegister()
				if _registered then
					return
				end
				Wait(250)
			end
		end)
	end
end)
