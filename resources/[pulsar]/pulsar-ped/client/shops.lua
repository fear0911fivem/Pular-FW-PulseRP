local withinPedShop = false
local pedShopActionSuppressed = false

local function GetPedShopAction(pedShop)
	local action =
	"{keybind}primary_action{/keybind} Clothing Store ($%s) | {keybind}secondary_action{/keybind} Wardrobe"
	if pedShop == "barber" then
		action = "{keybind}primary_action{/keybind} Barber Shop ($%s)"
	elseif pedShop == "tattoo" then
		action = "{keybind}primary_action{/keybind} Tattoo Parlor ($%s)"
	elseif pedShop == "surgery" then
		action = "{keybind}primary_action{/keybind} Plastic Surgery ($%s)"
	end

	return string.format(action, GetPedShopCost(pedShop))
end

function HidePedShopAction()
	pedShopActionSuppressed = true
	exports['pulsar-hud']:ActionHide("pedshop")
end

function RestorePedShopAction()
	pedShopActionSuppressed = false

	if withinPedShop then
		exports['pulsar-hud']:ActionShow("pedshop", GetPedShopAction(withinPedShop))
	end
end

function CreateSpecificPolyzoneType(type, id, data)
	if data.type == "poly" then
		exports['pulsar-polyzone']:CreatePoly(id, data.points, {
			minZ = data.minZ,
			maxZ = data.maxZ,
		}, {
			pedShop = type,
		})
	elseif data.type == "box" then
		exports['pulsar-polyzone']:CreateBox(id, data.center, data.length, data.width, {
			heading = data.heading,
			minZ = data.minZ,
			maxZ = data.maxZ,
		}, {
			pedShop = type,
		})
	end
end

function CreateShops()
	for k, v in ipairs(_clothingStores) do
		CreateSpecificPolyzoneType("clothing", "clothing_store_" .. k, v)
	end

	for k, v in ipairs(_barberShops) do
		CreateSpecificPolyzoneType("barber", "barber_shop_" .. k, v)
	end

	for k, v in ipairs(_tattooShops) do
		CreateSpecificPolyzoneType("tattoo", "tattoo_shop_" .. k, v)
	end

	CreateSpecificPolyzoneType("surgery", "plastic_surgery", _plasticSurgery)
end

function CreateShopsBlips()
	for k, v in ipairs(_clothingStores) do
		if v.blip then
			exports["pulsar-blips"]:Add("clothing_store_" .. k, "Clothing Store", v.blip, 73, 44)
		end
	end

	for k, v in ipairs(_barberShops) do
		exports["pulsar-blips"]:Add("barber_shop_" .. k, "Barbers", v.center, 71, 42)
	end

	for k, v in ipairs(_tattooShops) do
		exports["pulsar-blips"]:Add("tattoo_shop_" .. k, "Tattoo Parlor", v.center, 75, 48)
	end

	exports["pulsar-blips"]:Add("plastic_surgery", "Plastic Surgeon", _plasticSurgery.center, 362, 7)
end

function GetPedShopCost(t)
	if t == "clothing" then
		return GlobalState["Ped:Pricing"]["SHOP"]
	else
		return GlobalState["Ped:Pricing"][string.upper(t)]
	end
end

AddEventHandler("Polyzone:Enter", function(id, point, insideZone, data)
	if data.pedShop then
		withinPedShop = data.pedShop
		if not pedShopActionSuppressed then
			exports['pulsar-hud']:ActionShow("pedshop", GetPedShopAction(withinPedShop))
		end
	end
end)

AddEventHandler("Polyzone:Exit", function(id, point, insideZone, data)
	if withinPedShop and data and data.pedShop then
		withinPedShop = false
		exports['pulsar-hud']:ActionHide("pedshop")
	end
end)

AddEventHandler("Keybinds:Client:KeyUp:primary_action", function()
	if withinPedShop and LocalPlayer.state.loggedIn then
		local shopType = "SHOP"
		if withinPedShop ~= "clothing" then
			shopType = string.upper(withinPedShop)
		end

		local playerPed = PlayerPedId()
		local x, y, z = table.unpack(GetEntityCoords(playerPed))

		exports['pulsar-ped']:CustomizationShow(shopType, {
			x = x,
			y = y,
			z = z,
			h = 326.637,
		})
	end
end)

RegisterNetEvent("Peds:Customization:Client:AdminAbuse", function(shopType)
	local playerPed = PlayerPedId()
	local x, y, z = table.unpack(GetEntityCoords(playerPed))
	local h = GetEntityHeading(playerPed)
	local _type = "shop"

	if shopType <= 0 or shopType > 3 then
		_type = "shop"
	end
	if shopType == 1 then
		_type = "surgery"
	end
	if shopType == 2 then
		_type = "barber"
	end
	if shopType == 3 then
		_type = "tattoo"
	end

	exports['pulsar-ped']:CustomizationShow(string.upper(_type), {
		x = x,
		y = y,
		z = z,
		h = h,
	})
end)

AddEventHandler("Keybinds:Client:KeyUp:secondary_action", function()
	if withinPedShop and LocalPlayer.state.loggedIn then
		local shopType = "SHOP"
		if withinPedShop ~= "clothing" then
			shopType = string.upper(withinPedShop)
		end

		HidePedShopAction()
		exports['pulsar-ped']:WardrobeShow()
	end
end)

AddEventHandler("ListMenu:Client:Closed", function()
	if pedShopActionSuppressed and not _currentState then
		RestorePedShopAction()
	end
end)
