<<<<<<< HEAD
-- ############
-- ### DATA ###
-- ############

local ITEMS_TO_DESYNTH = {
	Nuts = {
	["Neo Kingdom Index"] = { a = 0, b = 1, c = 1},
	["Neo Kingdom Round Brush"] = { a = 0, b = 3, c = 1},
	["Neo Kingdom Codex"] = { a = 0, b = 5, c = 1}
	},
	Poetics = {
	["Augmented Encounter in Lilies"] = { a = 14, b = 1, c = 1},
	["Augmented Renaissance Brush"] = { a = 14, b = 3, c = 1},
	["Augmented Faerie Fancy"] = { a = 14, b = 1, c = 1}
	}
}

local POETICS_VENDOR = {
	name = "Agora Merchant",
	pos = { x = 16.92, y = 2.8, z = 1.23 },
	shopName = "InclusionShop"
}

local NUTS_VENDOR = {
	name = "Ryubool Ja",
	pos = { x = 25.89, y = -14, z = 127.01 },
	shopName = "ShopExchangeCurrency"
}

local itemList = require("vac_lists").Item_List

-- #################
-- ### FUNCTIONS ###
-- #################

function FindItemID(item_to_find)
	local search_term = string.lower(item_to_find)
	for key, item in pairs(itemList) do
		local item_name = string.lower(item['Name'])

		if item_name == search_term then
			return key
		end
	end
	return nil
end

function Echo(message)
	yield("/echo "..tostring(message))
end

function Wait(number)
	yield("/wait "..number)
end

function WaitForReady()
	while Player.IsBusy do
		Wait(0.1)
	end
end

function WaitForVnav()
	while IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() do
		Wait(0.1)
	end
end

function WaitForAddon(name)
	while not Addons.GetAddon(name).Ready do
		Wait(0.1)
	end
end

function MoveToCoordinates(x, y, z)
	yield("/vnav moveto "..x.." "..y.." "..z)
end

function BuyFromShop(shopName, a, b, c)
	yield("/callback "..shopName.." true "..a.." "..b.." "..c)
end

function NavigateToShopCategory(shopName, a, b)
	yield("/callback "..shopName.." true "..a.." "..b)
end

function SpendPoetics()
	local vendorName = POETICS_VENDOR.name
	local shopName = POETICS_VENDOR.shopName
	local itemsToBuy = ITEMS_TO_DESYNTH.Poetics

	if Svc.ClientState.TerritoryType ~= 962 then
		Echo("Teleporting to vendor zone")
		Actions.Teleport(182)
		WaitForReady()
	end

	Echo("Moving to "..vendorName)
	MoveToCoordinates(POETICS_VENDOR.pos.x, POETICS_VENDOR.pos.y, POETICS_VENDOR.pos.z)
	WaitForVnav()

	Echo("Targeting and interacting with "..vendorName)
	Entity.GetEntityByName(vendorName):SetAsTarget()
	Entity.Target:Interact()

	Echo("Waiting for shop window")
	WaitForAddon(shopName)

	Echo("Navigating to Magical Ranged DPS, Credendum Gear")
	NavigateToShopCategory(shopName, 12, 5)
	NavigateToShopCategory(shopName, 13, 9)

	Echo("Buying two items from shop")
	BuyFromShop(shopName,
	itemsToBuy["Augmented Encounter in Lilies"].a,
	itemsToBuy["Augmented Encounter in Lilies"].b,
	itemsToBuy["Augmented Encounter in Lilies"].c)
	Wait(1)
	BuyFromShop(shopName,
	itemsToBuy["Augmented Renaissance Brush"].a,
	itemsToBuy["Augmented Renaissance Brush"].b,
	itemsToBuy["Augmented Renaissance Brush"].c)
	Wait(1)

	Echo("Navigating to Healer, Credendum Gear")
	NavigateToShopCategory(shopName, 12, 6)
	NavigateToShopCategory(shopName, 13, 9)

	Echo("Buying one item from shop")
	BuyFromShop(shopName,
	itemsToBuy["Augmented Faerie Fancy"].a,
	itemsToBuy["Augmented Faerie Fancy"].b,
	itemsToBuy["Augmented Faerie Fancy"].c)
	Wait(1)

	Echo("Closing shop")
	yield("/callback "..shopName.." true -1")
	Wait(1)

	Echo("Desynthesizing items")
	DesynthItems()		
end

function SpendNuts()
	local vendorName = NUTS_VENDOR.name
	local shopName = NUTS_VENDOR.shopName
	local itemsToBuy = ITEMS_TO_DESYNTH.Nuts
	local newNutsAmount = Inventory.GetItemCount(26533)

	if Svc.ClientState.TerritoryType ~= 1185 then
		Echo("Teleporting to vendor zone")
		Actions.Teleport(216)
		WaitForReady()
	end

	Echo("Moving to "..vendorName)
	MoveToCoordinates(NUTS_VENDOR.pos.x, NUTS_VENDOR.pos.y, NUTS_VENDOR.pos.z)
	WaitForVnav()

	Echo("Starting buy/desynth loop")
	while newNutsAmount >= 140 do
		Echo("Targeting and interacting with vendor")
		Entity.GetEntityByName(vendorName):SetAsTarget()
		Entity.Target:Interact()
	
		Echo("Waiting for shop window")
		WaitForAddon(shopName)
	
		Echo("Buying items from shop")
		for _, item in pairs(itemsToBuy) do
			if newNutsAmount >= 140 then
				BuyFromShop(shopName, item.a, item.b, item.c)
				Wait(1)
				newNutsAmount = Inventory.GetItemCount(26533)
			end
		end

		Echo("Closing shop")
		yield("/callback "..shopName.." true -1")
		Wait(1)

		Echo("Desynthesizing items")
		DesynthItems()		
	end
end

function DesynthItems()
	for _, itemCategory in pairs(ITEMS_TO_DESYNTH) do
		for itemName, _ in pairs(itemCategory) do
			local itemId = FindItemID(itemName)
			if Inventory.GetItemCount(itemId) > 0 then
				yield("/desynth "..itemId)
				WaitForReady()
				Wait(1)
			end
		end
	end
end

-- ############
-- ### MAIN ###
-- ############

Echo("Starting script!")

local poeticsAmount = Inventory.GetItemCount(28)
local nutsAmount = Inventory.GetItemCount(26533)

if poeticsAmount >= 1800 and Svc.ClientState.TerritoryType == 962 then
	Echo("Poetics capped and already in Sharlayan --> spending Poetics")
	SpendPoetics()
else
	if nutsAmount >= 3000 and Svc.ClientState.TerritoryType == 1185 then
		Echo("Nuts capped and already in Tuliyollal --> spending Nuts")
		SpendNuts()
	else
		if poeticsAmount >= 1800 then
			Echo("Poetics capped --> spending Poetics")
			SpendPoetics()
		end
		if nutsAmount >= 3000 then
			Echo("Nuts capped --> spending Nuts")
			SpendNuts()
		end
	end
end

=======
-- ############
-- ### DATA ###
-- ############

local ITEMS_TO_DESYNTH = {
	Nuts = {
	["Neo Kingdom Index"] = { a = 0, b = 1, c = 1},
	["Neo Kingdom Round Brush"] = { a = 0, b = 3, c = 1},
	["Neo Kingdom Codex"] = { a = 0, b = 5, c = 1}
	},
	Poetics = {
	["Augmented Encounter in Lilies"] = { a = 14, b = 1, c = 1},
	["Augmented Renaissance Brush"] = { a = 14, b = 3, c = 1},
	["Augmented Faerie Fancy"] = { a = 14, b = 1, c = 1}
	}
}

local POETICS_VENDOR = {
	name = "Agora Merchant",
	pos = { x = 16.92, y = 2.8, z = 1.23 },
	shopName = "InclusionShop"
}

local NUTS_VENDOR = {
	name = "Ryubool Ja",
	pos = { x = 25.89, y = -14, z = 127.01 },
	shopName = "ShopExchangeCurrency"
}

local itemList = require("vac_lists").Item_List

-- #################
-- ### FUNCTIONS ###
-- #################

function FindItemID(item_to_find)
	local search_term = string.lower(item_to_find)
	for key, item in pairs(itemList) do
		local item_name = string.lower(item['Name'])

		if item_name == search_term then
			return key
		end
	end
	return nil
end

function Echo(message)
	yield("/echo "..tostring(message))
end

function Wait(number)
	yield("/wait "..number)
end

function WaitForReady()
	while Player.IsBusy do
		Wait(0.1)
	end
end

function WaitForVnav()
	while IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() do
		Wait(0.1)
	end
end

function WaitForAddon(name)
	while not Addons.GetAddon(name).Ready do
		Wait(0.1)
	end
end

function MoveToCoordinates(x, y, z)
	yield("/vnav moveto "..x.." "..y.." "..z)
end

function BuyFromShop(shopName, a, b, c)
	yield("/callback "..shopName.." true "..a.." "..b.." "..c)
end

function NavigateToShopCategory(shopName, a, b)
	yield("/callback "..shopName.." true "..a.." "..b)
end

function SpendPoetics()
	local vendorName = POETICS_VENDOR.name
	local shopName = POETICS_VENDOR.shopName
	local itemsToBuy = ITEMS_TO_DESYNTH.Poetics

	if Svc.ClientState.TerritoryType ~= 962 then
		Echo("Teleporting to vendor zone")
		Actions.Teleport(182)
		WaitForReady()
	end

	Echo("Moving to "..vendorName)
	MoveToCoordinates(POETICS_VENDOR.pos.x, POETICS_VENDOR.pos.y, POETICS_VENDOR.pos.z)
	WaitForVnav()

	Echo("Targeting and interacting with "..vendorName)
	Entity.GetEntityByName(vendorName):SetAsTarget()
	Entity.Target:Interact()

	Echo("Waiting for shop window")
	WaitForAddon(shopName)

	Echo("Navigating to Magical Ranged DPS, Credendum Gear")
	NavigateToShopCategory(shopName, 12, 5)
	NavigateToShopCategory(shopName, 13, 9)

	Echo("Buying two items from shop")
	BuyFromShop(shopName,
	itemsToBuy["Augmented Encounter in Lilies"].a,
	itemsToBuy["Augmented Encounter in Lilies"].b,
	itemsToBuy["Augmented Encounter in Lilies"].c)
	Wait(1)
	BuyFromShop(shopName,
	itemsToBuy["Augmented Renaissance Brush"].a,
	itemsToBuy["Augmented Renaissance Brush"].b,
	itemsToBuy["Augmented Renaissance Brush"].c)
	Wait(1)

	Echo("Navigating to Healer, Credendum Gear")
	NavigateToShopCategory(shopName, 12, 6)
	NavigateToShopCategory(shopName, 13, 9)

	Echo("Buying one item from shop")
	BuyFromShop(shopName,
	itemsToBuy["Augmented Faerie Fancy"].a,
	itemsToBuy["Augmented Faerie Fancy"].b,
	itemsToBuy["Augmented Faerie Fancy"].c)
	Wait(1)

	Echo("Closing shop")
	yield("/callback "..shopName.." true -1")
	Wait(1)

	Echo("Desynthesizing items")
	DesynthItems()		
end

function SpendNuts()
	local vendorName = NUTS_VENDOR.name
	local shopName = NUTS_VENDOR.shopName
	local itemsToBuy = ITEMS_TO_DESYNTH.Nuts
	local newNutsAmount = Inventory.GetItemCount(26533)

	if Svc.ClientState.TerritoryType ~= 1185 then
		Echo("Teleporting to vendor zone")
		Actions.Teleport(216)
		WaitForReady()
	end

	Echo("Moving to "..vendorName)
	MoveToCoordinates(NUTS_VENDOR.pos.x, NUTS_VENDOR.pos.y, NUTS_VENDOR.pos.z)
	WaitForVnav()

	Echo("Starting buy/desynth loop")
	while newNutsAmount >= 140 do
		Echo("Targeting and interacting with vendor")
		Entity.GetEntityByName(vendorName):SetAsTarget()
		Entity.Target:Interact()
	
		Echo("Waiting for shop window")
		WaitForAddon(shopName)
	
		Echo("Buying items from shop")
		for _, item in pairs(itemsToBuy) do
			if newNutsAmount >= 140 then
				BuyFromShop(shopName, item.a, item.b, item.c)
				Wait(1)
				newNutsAmount = Inventory.GetItemCount(26533)
			end
		end

		Echo("Closing shop")
		yield("/callback "..shopName.." true -1")
		Wait(1)

		Echo("Desynthesizing items")
		DesynthItems()		
	end
end

function DesynthItems()
	for _, itemCategory in pairs(ITEMS_TO_DESYNTH) do
		for itemName, _ in pairs(itemCategory) do
			local itemId = FindItemID(itemName)
			if Inventory.GetItemCount(itemId) > 0 then
				yield("/desynth "..itemId)
				WaitForReady()
				Wait(1)
			end
		end
	end
end

-- ############
-- ### MAIN ###
-- ############

Echo("Starting script!")

local poeticsAmount = Inventory.GetItemCount(28)
local nutsAmount = Inventory.GetItemCount(26533)

if poeticsAmount >= 1800 and Svc.ClientState.TerritoryType == 962 then
	Echo("Poetics capped and already in Sharlayan --> spending Poetics")
	SpendPoetics()
else
	if nutsAmount >= 3000 and Svc.ClientState.TerritoryType == 1185 then
		Echo("Nuts capped and already in Tuliyollal --> spending Nuts")
		SpendNuts()
	else
		if poeticsAmount >= 1800 then
			Echo("Poetics capped --> spending Poetics")
			SpendPoetics()
		end
		if nutsAmount >= 3000 then
			Echo("Nuts capped --> spending Nuts")
			SpendNuts()
		end
	end
end

>>>>>>> 07fa72e1e953315d935e9a13f7d72f220ac0fe00
Echo("Script done!")