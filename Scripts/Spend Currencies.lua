-- Spend Currencies

-- ############
-- ### DATA ###
-- ############

local functions = require("functions")

DEBUG = true

ITEMS_TO_DESYNTH = { }

POETICS_VENDOR = {
    name = "Rowena's Representative",
    shopName = "InclusionShop",
    zoneId = 132,
}

UNCAPPED_VENDOR = {
    name = "Zircon",
    shopName = "ShopExchangeCurrency",
    zoneId = 1186,
}

NUTS_VENDOR = {
    name = "Ryubool Ja",
    shopName = "ShopExchangeCurrency",
    zoneId = 1185,
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
    local poeticsAmount = Inventory.GetItemCount(28)

    if poeticsAmount < 1640 then
        return
    end

    functions.Lifestream("Poetics")

    functions.Echo("Waiting for shop window")
    functions.WaitForAddon(shopName)

    functions.Echo("Navigating to correct category")
    functions.NavigateToShopCategory(shopName, 12, 7)
    functions.NavigateToShopCategory(shopName, 13, 1)

    functions.Echo("Buying items from shop")
    local buyAmount = math.floor(poeticsAmount / 150)
    functions.BuyFromShop(shopName, 14, 6, buyAmount)

    functions.Echo("Closing shop")
    functions.CloseShop(shopName)
end

local function SpendUncapped()
    local vendorName = UNCAPPED_VENDOR.name
    local shopName = UNCAPPED_VENDOR.shopName
    local uncappedAmount = Inventory.GetItemCount(47)

    if uncappedAmount < 1720 then
        return
    end

    functions.Lifestream("Uncapped")

    functions.Echo("Waiting for shop selection window")
    functions.WaitForAddon("SelectIconString")

    functions.Echo("Navigating to correct list option")
    functions.SelectListOption("SelectIconString", 3)

    functions.Echo("Buying items from shop")
    local buyAmount = math.floor(uncappedAmount / 6 / 20)
    functions.BuyFromShop(shopName, 0, 0, buyAmount)
    functions.BuyFromShop(shopName, 0, 1, buyAmount)
    functions.BuyFromShop(shopName, 0, 2, buyAmount)
    functions.BuyFromShop(shopName, 0, 3, buyAmount)
    functions.BuyFromShop(shopName, 0, 4, buyAmount)
    functions.BuyFromShop(shopName, 0, 5, buyAmount)

    functions.Echo("Closing shop")
    functions.CloseShop(shopName)
end

local function SpendNuts()
    local vendorName = NUTS_VENDOR.name
    local shopName = NUTS_VENDOR.shopName
    local nutsAmount = Inventory.GetItemCount(26533)

    if nutsAmount < 3440 then
        return
    end

    functions.Lifestream("Nuts")

    functions.Echo("Waiting for shop selection window")
    functions.WaitForAddon("SelectIconString")

--#region saved Nut spenders
--[[
    -- Desynth
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

    -- Materia
    functions.Echo("Navigating to correct list option")
    functions.SelectListOption("SelectIconString", 0)

    functions.Echo("Buying items from shop")
    local buyAmount = math.floor(nutsAmount / 400)
    functions.BuyFromShop(shopName, 0, 9, buyAmount)
]]
--#endregion

    functions.Echo("Closing shop")
    functions.CloseShop(shopName)
end

-- ############
-- ### MAIN ###
-- ############

functions.Echo("Starting script!")

if Svc.ClientState.TerritoryType == POETICS_VENDOR.zoneId then
    functions.Echo("Poetics capped and already in vendor zone --> spending Poetics")
    SpendPoetics()
elseif Svc.ClientState.TerritoryType == UNCAPPED_VENDOR.zoneId then
    functions.Echo("Uncapped tomestones capped and already in vendor zone --> spending Uncapped tomestones")
    SpendUncapped()
elseif Svc.ClientState.TerritoryType == NUTS_VENDOR.zoneId then
    functions.Echo("Nuts capped and already in vendor zone --> spending Nuts")
    SpendNuts()
else
    SpendPoetics()
    SpendUncapped()
    SpendNuts()
end

functions.Echo("Script done!")