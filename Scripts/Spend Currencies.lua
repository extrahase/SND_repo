-- Spend Currencies

-- ############
-- ### DATA ###
-- ############

local functions = require("functions")

DEBUG = true

ITEMS_TO_DESYNTH = {
    Nuts = {
        ["Neo Kingdom Halberd"] = { a = 0, b = 4, c = 1 },
        ["Neo Kingdom Composite Bow"] = { a = 0, b = 10, c = 1 }
    },
    Poetics = {
        ["Unidentifiable Shell"] = { a = 14, b = 6, c = 13 }
    }
}

POETICS_VENDOR = {
    name = "Rowena's Representative",
    pos = { x = 38.72, y = -1.76, z = 55.77 },
    shopName = "InclusionShop",
    zoneId = 132,
    aetheryteId = 2
}

NUTS_VENDOR = {
    name = "Ryubool Ja",
    pos = { x = 25.89, y = -14, z = 127.01 },
    shopName = "ShopExchangeCurrency"
    -- TODO: Add zoneId and aetheryteId
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
    local zoneId = POETICS_VENDOR.zoneId
    local aetheryteId = POETICS_VENDOR.aetheryteId
    --local newPoeticsAmount = Inventory.GetItemCount(28)

    if Svc.ClientState.TerritoryType ~= zoneId then
        functions.TpToAetheryte(aetheryteId)
    end

    functions.MoveToCoordinates(POETICS_VENDOR.pos.x, POETICS_VENDOR.pos.y, POETICS_VENDOR.pos.z)
    functions.WaitForVnav()

    Entity.GetEntityByName(vendorName):SetAsTarget()
    Entity.Target:Interact()

    functions.WaitForAddon(shopName)

    functions.Echo("Navigating to Combat Supplies, Special Arms Materials")
    functions.NavigateToShopCategory(shopName, 12, 7)
    functions.NavigateToShopCategory(shopName, 13, 1)

    functions.Echo("Buying Unidentifiable Shells")
    functions.BuyFromShop(shopName,
        itemsToBuy["Unidentifiable Shell"].a,
        itemsToBuy["Unidentifiable Shell"].b,
        itemsToBuy["Unidentifiable Shell"].c
    )

    yield("/callback "..shopName.." true -1")
    functions.Wait(1)
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

if poeticsAmount >= 1950 and Svc.ClientState.TerritoryType == POETICS_VENDOR.zoneId then
    functions.Echo("Poetics capped and already in Gridania --> spending Poetics")
    SpendPoetics()
else
    if nutsAmount >= 3000 and Svc.ClientState.TerritoryType == 1185 then
        functions.Echo("Nuts capped and already in Tuliyollal --> spending Nuts")
        SpendNuts()
    else
        if poeticsAmount >= 1950 then
            functions.Echo("Poetics capped --> spending Poetics")
            SpendPoetics()
        end
        if nutsAmount >= 3000 then
            functions.Echo("Nuts capped --> spending Nuts")
            SpendNuts()
        end
    end
end

DesynthItems()

functions.Echo("Script done!")