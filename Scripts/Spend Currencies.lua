-- ############
-- ### DATA ###
-- ############

local functions = require("functions")

ITEM_LIST = require("vac_lists").Item_List
HOME_POINT = "Tuliyollal"
FREE_DESTINATION = "New Gridania"
UNCAPPED_DESTINATION = "Solution Nine"

DEBUG = false

MIN_POETICS = 1640
MIN_UNCAPPED = 1720
MIN_NUTS = 3440

ITEMS_TO_DESYNTH = {
    poetics = { },
    uncapped = { },
    nuts = {
        { name = "Neo Kingdom Tulwar", shop = 2, category = 0, index = 0, price = 140 },
        { name = "Neo Kingdom Kite Shield", shop = 2, category = 0, index = 0, price = 140 },
        { name = "Neo Kingdom Halberd", shop = 2, category = 0, index = 4, price = 140 },
        { name = "Neo Kingdom Composite Bow", shop = 2, category = 0, index = 10, price = 140 },
        { name = "Neo Kingdom Index", shop = 3, category = 0, index = 1, price = 140 },
        { name = "Neo Kingdom Round Brush", shop = 3, category = 0, index = 3, price = 140 },
        { name = "Neo Kingdom Codex", shop = 3, category = 0, index = 5, price = 140 },
    }
}

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
    shopList = {
        "Sacks of Nuts Exchange",
        "Neo Kingdom Gear (DoW, IL 700)",
        "Neo Kingdom Gear (DoM, IL 700)",
    }
}

-- #################
-- ### FUNCTIONS ###
-- #################

local function DesynthItems()
    for _, itemCategory in pairs(ITEMS_TO_DESYNTH) do
        for _, item in pairs(itemCategory) do
            local itemId = functions.FindItemID(item.name)
            if Inventory.GetItemCount(itemId) > 0 then
                yield("/desynth "..itemId)
                functions.WaitForReady()
                functions.Wait(1)
                functions.CloseAddon("SalvageResult")
            end
        end
    end
end

local function SpendPoetics()
    local vendorName = POETICS_VENDOR.name
    local shopName = POETICS_VENDOR.shopName
    local poeticsAmount = Inventory.GetItemCount(28)

    functions.Echo("Checking if minimum Poetics treshold is met")
    if poeticsAmount < MIN_POETICS then
        return
    end

    functions.Echo("Teleporting to " .. FREE_DESTINATION .. " if not already there")
        if Svc.ClientState.TerritoryType ~= POETICS_VENDOR.zoneId then
            functions.Lifestream("tp " .. FREE_DESTINATION)
            functions.WaitForZone(POETICS_VENDOR.zoneId)
        end

    functions.Echo("Navigating to vendor")
    functions.MoveToCoordinates(37.52, -1.69, 57.55)

    functions.Echo("Interacting with " .. vendorName)
    Entity.GetEntityByName(vendorName):SetAsTarget()
    Entity.Target:Interact()

    functions.Echo("Waiting for " .. shopName .. " window")
    functions.WaitForAddon(shopName)

    functions.Echo("Navigating to Combat Supplies > Special Arms Materials")
    functions.NavigateToShopCategory(shopName, 12, 7)
    functions.NavigateToShopCategory(shopName, 13, 1)

    functions.Echo("Buying " .. math.floor(poeticsAmount / 150) .. " Unidentifiable Shells")
    local buyAmount = math.floor(poeticsAmount / 150)
    functions.BuyFromShop(shopName, 14, 6, buyAmount)

    functions.Echo("Closing shop")
    functions.Wait(0.5) -- wait for last purchase to be processed
    functions.CloseAddon(shopName)
end

local function SpendUncapped()
    local vendorName = UNCAPPED_VENDOR.name
    local shopName = UNCAPPED_VENDOR.shopName
    local uncappedAmount = Inventory.GetItemCount(47)

    functions.Echo("Checking if minimum Uncapped treshold is met")
    if uncappedAmount < MIN_UNCAPPED then
        return
    end

    functions.Echo("Teleporting to " .. UNCAPPED_DESTINATION .. " if not already there")
        if Svc.ClientState.TerritoryType ~= UNCAPPED_VENDOR.zoneId then
            functions.Lifestream("tp " .. UNCAPPED_DESTINATION)
            functions.WaitForZone(UNCAPPED_VENDOR.zoneId)
            IPC.Lifestream.AethernetTeleport("Nexus Arcade")
            functions.WaitForLifestream()
        end

    functions.Echo("Navigating to vendor")
    functions.MoveToCoordinates(-185.25, 0.66, -28.00)

    functions.Echo("Interacting with " .. vendorName)
    Entity.GetEntityByName(vendorName):SetAsTarget()
    Entity.Target:Interact()

    functions.Echo("Selecting shop: Allagan Tomestones of Heliometry (Other)")
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
    functions.Wait(0.5) -- wait for last purchase to be processed
    functions.CloseAddon(shopName)
end

local function SpendNuts()
    local vendorName = NUTS_VENDOR.name
    local shopName = NUTS_VENDOR.shopName
    local nutsAmount = Inventory.GetItemCount(26533)

    functions.Echo("Checking if minimum Nuts treshold is met")
    if nutsAmount < MIN_NUTS then
        return
    end

    functions.Echo("Teleporting to " .. HOME_POINT .. " if not already there")
    if Svc.ClientState.TerritoryType ~= NUTS_VENDOR.zoneId then
        functions.Return()
        functions.WaitForZone(NUTS_VENDOR.zoneId)
        IPC.Lifestream.AethernetTeleport("Bayside Bevy Marketplace")
        functions.WaitForLifestream()
    end

    functions.Echo("Navigating to vendor")
    functions.MoveToCoordinates(25.99, -14, 126.87)

    functions.Echo("Building table of shops to visit and determining max item price")
    local shopsSet = { }
    local shops = { }
    local maxPrice = 0
    for _, item in ipairs(ITEMS_TO_DESYNTH.nuts) do
        if not shopsSet[item.shop] then
            shopsSet[item.shop] = true
            table.insert(shops, item.shop)
        end
        if item.price > maxPrice then
            maxPrice = item.price
        end
    end
    functions.Echo("Shops to visit: " .. table.concat(shops, ", ") .. "; max price is " .. maxPrice)

    functions.Echo("Start of buy/desynth loop")
    while nutsAmount >= maxPrice do
        for _, shop in ipairs(shops) do
            functions.Echo("Checking if shop selection window is open and ready")
            while not Addons.GetAddon("SelectIconString").Ready do
                functions.Echo("Interacting with " .. vendorName .. " and waiting for shop selection window")
                Entity.GetEntityByName(vendorName):SetAsTarget()
                Entity.Target:Interact()
                functions.Wait(0.1)
            end

            functions.Echo("Selecting shop with index: " .. (shop - 1))
            functions.SelectListOption("SelectIconString", shop - 1)

            functions.Echo("Buying items from shop")
            for _, item in ipairs(ITEMS_TO_DESYNTH.nuts) do
                if item.shop == shop and item.price <= nutsAmount then
                    functions.Echo("Buying " .. item.name .. " for " .. item.price .. " Nuts")
                    functions.BuyFromShop(shopName, item.category, item.index, 1)
                    nutsAmount = Inventory.GetItemCount(26533)
                end
            end

            functions.Echo("Closing shop")
            functions.Wait(0.5) -- wait for last purchase to be processed
            functions.CloseAddon(shopName)
        end

        functions.Echo("Desynthesizing items")
        DesynthItems()
    end
end

-- ############
-- ### MAIN ###
-- ############

functions.Echo("Starting script!")

functions.Echo("Disabling YesAlready")
IPC.YesAlready.SetPluginEnabled(false)

functions.Echo("Checking if already in correct zone for one of the vendors")
if Svc.ClientState.TerritoryType == POETICS_VENDOR.zoneId then
    functions.Echo("In Poetics vendor zone, spending Poetics")
    SpendPoetics()
elseif Svc.ClientState.TerritoryType == UNCAPPED_VENDOR.zoneId then
    functions.Echo("In Uncapped vendor zone, spending Uncapped")
    SpendUncapped()
elseif Svc.ClientState.TerritoryType == NUTS_VENDOR.zoneId then
    functions.Echo("In Nuts vendor zone, spending Nuts")
    SpendNuts()
end

functions.Echo("Initiating all spend functions")
SpendPoetics()
SpendUncapped()
SpendNuts()

functions.Echo("Last Desynth before script end")
DesynthItems()

functions.Echo("Enabling YesAlready")
IPC.YesAlready.SetPluginEnabled(true)

functions.Echo("Script done!")