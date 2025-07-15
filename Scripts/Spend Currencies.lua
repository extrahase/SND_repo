-- Spend Currencies

-- ############
-- ### DATA ###
-- ############

local functions = require("functions")

DEBUG = false

ITEMS_TO_DESYNTH = {
    Nuts = {
        ["Neo Kingdom Index"] = { a = 0, b = 1, c = 1},
        ["Neo Kingdom Round Brush"] = { a = 0, b = 3, c = 1},
        ["Neo Kingdom Codex"] = { a = 0, b = 5, c = 1}
    },
    Poetics = {
        ["Augmented Bunny's Crescent"] = { a = 14, b = 0, c = 1},
        ["Augmented Bluebird's Nest"] = { a = 14, b = 0, c = 1}
    }
}

POETICS_VENDOR = {
    name = "Agora Merchant",
    pos = { x = 16.92, y = 2.8, z = 1.23 },
    shopName = "InclusionShop"
}

NUTS_VENDOR = {
    name = "Ryubool Ja",
    pos = { x = 25.89, y = -14, z = 127.01 },
    shopName = "ShopExchangeCurrency"
}

ITEM_LIST = require("vac_lists").Item_List

-- #################
-- ### FUNCTIONS ###
-- #################

local function DesynthItems()
    for _, itemCategory in pairs(ITEMS_TO_DESYNTH) do
        for itemName, _ in pairs(itemCategory) do
            local itemId = functions.FindItemID(itemName)
            if Inventory.GetItemCount(itemId) > 0 then
                yield("/desynth "..itemId)
                functions.WaitForReady()
                functions.Wait(1)
            end
        end
    end
end

local function SpendPoetics()
    local vendorName = POETICS_VENDOR.name
    local shopName = POETICS_VENDOR.shopName
    local itemsToBuy = ITEMS_TO_DESYNTH.Poetics
    --local newPoeticsAmount = Inventory.GetItemCount(28)

    if Svc.ClientState.TerritoryType ~= 962 then
        functions.TpToAetheryte(182)
    end

    functions.MoveToCoordinates(POETICS_VENDOR.pos.x, POETICS_VENDOR.pos.y, POETICS_VENDOR.pos.z)
    functions.WaitForVnav()

    Entity.GetEntityByName(vendorName):SetAsTarget()
    Entity.Target:Interact()

    functions.WaitForAddon(shopName)

    functions.Echo("Navigating to Physical Ranged DPS, Credendum Gear")
    functions.NavigateToShopCategory(shopName, 12, 4)
    functions.NavigateToShopCategory(shopName, 13, 9)

    functions.BuyFromShop(shopName,
        itemsToBuy["Augmented Bluebird's Nest"].a,
        itemsToBuy["Augmented Bluebird's Nest"].b,
        itemsToBuy["Augmented Bluebird's Nest"].c)
    functions.Wait(1)

    functions.Echo("Navigating to Healer, Credendum Gear")
    functions.NavigateToShopCategory(shopName, 12, 6)
    functions.NavigateToShopCategory(shopName, 13, 9)

    functions.BuyFromShop(shopName,
        itemsToBuy["Augmented Bunny's Crescent"].a,
        itemsToBuy["Augmented Bunny's Crescent"].b,
        itemsToBuy["Augmented Bunny's Crescent"].c)
    functions.Wait(1)

    yield("/callback "..shopName.." true -1")
    functions.Wait(1)

    DesynthItems()
    --local newPoeticsAmount = Inventory.GetItemCount(28)

    Entity.GetEntityByName(vendorName):SetAsTarget()
    Entity.Target:Interact()

    functions.WaitForAddon(shopName)

    functions.Echo("Navigating to Physical Ranged DPS, Credendum Gear")
    functions.NavigateToShopCategory(shopName, 12, 4)
    functions.NavigateToShopCategory(shopName, 13, 9)

    functions.BuyFromShop(shopName,
    itemsToBuy["Augmented Bluebird's Nest"].a,
    itemsToBuy["Augmented Bluebird's Nest"].b,
    itemsToBuy["Augmented Bluebird's Nest"].c)

    yield("/callback "..shopName.." true -1")
    functions.Wait(1)

    DesynthItems()
    --local newPoeticsAmount = Inventory.GetItemCount(28)
end

local function SpendNuts()
    local vendorName = NUTS_VENDOR.name
    local shopName = NUTS_VENDOR.shopName
    local itemsToBuy = ITEMS_TO_DESYNTH.Nuts
    local newNutsAmount = Inventory.GetItemCount(26533)

    if Svc.ClientState.TerritoryType ~= 1185 then
        functions.TpToAetheryte(216)
    end

    functions.Echo("Moving to "..vendorName)
    functions.MoveToCoordinates(NUTS_VENDOR.pos.x, NUTS_VENDOR.pos.y, NUTS_VENDOR.pos.z)
    functions.WaitForVnav()

    functions.Echo("Starting buy/desynth loop")
    while newNutsAmount >= 140 do
        functions.Echo("Targeting and interacting with vendor")
        Entity.GetEntityByName(vendorName):SetAsTarget()
        Entity.Target:Interact()
    
        functions.Echo("Waiting for shop window")
        functions.WaitForAddon(shopName)
    
        functions.Echo("Buying items from shop")
        for _, item in pairs(itemsToBuy) do
            if newNutsAmount >= 140 then
                functions.BuyFromShop(shopName, item.a, item.b, item.c)
                functions.Wait(1)
                newNutsAmount = Inventory.GetItemCount(26533)
            end
        end

        functions.Echo("Closing shop")
        yield("/callback "..shopName.." true -1")
        functions.Wait(1)

        functions.Echo("Desynthesizing items")
        DesynthItems()		
    end
end

-- ############
-- ### MAIN ###
-- ############

functions.Echo("Starting script!")

local poeticsAmount = Inventory.GetItemCount(28)
local nutsAmount = Inventory.GetItemCount(26533)

if poeticsAmount >= 1800 and Svc.ClientState.TerritoryType == 962 then
    functions.Echo("Poetics capped and already in Sharlayan --> spending Poetics")
    SpendPoetics()
else
    if nutsAmount >= 3000 and Svc.ClientState.TerritoryType == 1185 then
        functions.Echo("Nuts capped and already in Tuliyollal --> spending Nuts")
        SpendNuts()
    else
        if poeticsAmount >= 1800 then
            functions.Echo("Poetics capped --> spending Poetics")
            SpendPoetics()
        end
        if nutsAmount >= 3000 then
            functions.Echo("Nuts capped --> spending Nuts")
            SpendNuts()
        end
    end
end

functions.Echo("Script done!")