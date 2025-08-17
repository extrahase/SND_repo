-- ############
-- ### DATA ###
-- ############

local f = require("functions")

ITEM_LIST = require("vac_lists").Item_List
HOME_POINT = "Tuliyollal"
FREE_DESTINATION = "New Gridania"
UNCAPPED_DESTINATION = "Solution Nine"

DEBUG = false

MIN_POETICS = 1640
MIN_UNCAPPED = 1800
MIN_NUTS = 3520

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
            local itemId = f.FindItemID(item.name)
            if Inventory.GetItemCount(itemId) > 0 then
                yield("/desynth "..itemId)
                f.WaitForReady()
                f.Wait(1)
                f.CloseAddon("SalvageResult")
            end
        end
    end
end

local function SpendPoetics()
    local vendorName = POETICS_VENDOR.name
    local shopName = POETICS_VENDOR.shopName
    local poeticsAmount = Inventory.GetItemCount(28)

    f.Echo("Checking if minimum Poetics treshold is met")
    if poeticsAmount < MIN_POETICS then
        return
    end

    f.Echo("Teleporting to " .. FREE_DESTINATION .. " if not already there")
        if Svc.ClientState.TerritoryType ~= POETICS_VENDOR.zoneId then
            f.Lifestream("tp " .. FREE_DESTINATION)
            f.WaitForZone(POETICS_VENDOR.zoneId)
        end

    f.Echo("Navigating to vendor")
    f.MoveToCoordinates(37.52, -1.69, 57.55)

    f.Echo("Interacting with " .. vendorName)
    Entity.GetEntityByName(vendorName):SetAsTarget()
    Entity.Target:Interact()

    f.Echo("Waiting for " .. shopName .. " window")
    f.WaitForAddon(shopName)

    f.Echo("Navigating to Combat Supplies > Special Arms Materials")
    f.Callback2(shopName, 12, 7)
    f.Callback2(shopName, 13, 1)

    f.Echo("Buying " .. math.floor(poeticsAmount / 150) .. " Unidentifiable Shells")
    local buyAmount = math.floor(poeticsAmount / 150)
    f.BuyFromShop(shopName, 14, 6, buyAmount)

    f.Echo("Closing shop")
    f.Wait(0.5) -- wait for last purchase to be processed
    f.CloseAddon(shopName)

    f.Echo("Moving back to line up with Aetheryte lmao")
    f.MoveToCoordinates(45.64, -1.63, 55.19)
end

local function SpendUncapped()
    local vendorName = UNCAPPED_VENDOR.name
    local shopName = UNCAPPED_VENDOR.shopName
    local uncappedAmount = Inventory.GetItemCount(47)

    f.Echo("Checking if minimum Uncapped treshold is met")
    if uncappedAmount < MIN_UNCAPPED then
        return
    end

    f.Echo("Teleporting to " .. UNCAPPED_DESTINATION .. " if not already there")
        if Svc.ClientState.TerritoryType ~= UNCAPPED_VENDOR.zoneId then
            f.Lifestream("tp " .. UNCAPPED_DESTINATION)
            f.WaitForZone(UNCAPPED_VENDOR.zoneId)
            IPC.Lifestream.AethernetTeleport("Nexus Arcade")
            f.WaitForLifestream()
        end

    f.Echo("Navigating to vendor")
    f.MoveToCoordinates(-185.25, 0.66, -28.00)

    f.Echo("Interacting with " .. vendorName)
    Entity.GetEntityByName(vendorName):SetAsTarget()
    Entity.Target:Interact()

    f.Echo("Selecting shop: Allagan Tomestones of Heliometry (Other)")
    f.SelectListOption("SelectIconString", 3)

    f.Echo("Buying items from shop")
    local buyAmount = math.floor(uncappedAmount / 6 / 20)
    f.BuyFromShop(shopName, 0, 0, buyAmount)
    f.BuyFromShop(shopName, 0, 1, buyAmount)
    f.BuyFromShop(shopName, 0, 2, buyAmount)
    f.BuyFromShop(shopName, 0, 3, buyAmount)
    f.BuyFromShop(shopName, 0, 4, buyAmount)
    f.BuyFromShop(shopName, 0, 5, buyAmount)

    f.Echo("Closing shop")
    f.Wait(0.5) -- wait for last purchase to be processed
    f.CloseAddon(shopName)
end

local function SpendNuts()
    local vendorName = NUTS_VENDOR.name
    local shopName = NUTS_VENDOR.shopName
    local nutsAmount = Inventory.GetItemCount(26533)

    f.Echo("Checking if minimum Nuts treshold is met")
    if nutsAmount < MIN_NUTS then
        return
    end

    f.Echo("Teleporting to " .. HOME_POINT .. " if not already there")
    if Svc.ClientState.TerritoryType ~= NUTS_VENDOR.zoneId then
        f.Return()
        f.WaitForZone(NUTS_VENDOR.zoneId)
        IPC.Lifestream.AethernetTeleport("Bayside Bevy Marketplace")
        f.WaitForLifestream()
    end

    f.Echo("Navigating to vendor")
    f.MoveToCoordinates(25.99, -14, 126.87)

    f.Echo("Building table of shops to visit and determining max item price")
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
    f.Echo("Shops to visit: " .. table.concat(shops, ", ") .. "; max price is " .. maxPrice)

    f.Echo("Start of buy/desynth loop")
    while nutsAmount >= maxPrice do
        for _, shop in ipairs(shops) do
            f.Echo("Checking if shop selection window is open and ready")
            while not Addons.GetAddon("SelectIconString").Ready do
                f.Echo("Interacting with " .. vendorName .. " and waiting for shop selection window")
                Entity.GetEntityByName(vendorName):SetAsTarget()
                Entity.Target:Interact()
                f.Wait(0.1)
            end

            f.Echo("Selecting shop with index: " .. (shop - 1))
            f.SelectListOption("SelectIconString", shop - 1)

            f.Echo("Buying items from shop")
            for _, item in ipairs(ITEMS_TO_DESYNTH.nuts) do
                if item.shop == shop and item.price <= nutsAmount then
                    f.Echo("Buying " .. item.name .. " for " .. item.price .. " Nuts")
                    f.BuyFromShop(shopName, item.category, item.index, 1)
                    nutsAmount = Inventory.GetItemCount(26533)
                end
            end

            f.Echo("Closing shop")
            f.Wait(0.5) -- wait for last purchase to be processed
            f.CloseAddon(shopName)
        end

        f.Echo("Desynthesizing items")
        DesynthItems()
    end
end

-- ############
-- ### MAIN ###
-- ############

f.Echo("Starting script!")

f.Echo("Disabling YesAlready")
IPC.YesAlready.SetPluginEnabled(false)

f.Echo("Checking if already in correct zone for one of the vendors")
if Svc.ClientState.TerritoryType == POETICS_VENDOR.zoneId then
    f.Echo("In Poetics vendor zone, spending Poetics")
    SpendPoetics()
elseif Svc.ClientState.TerritoryType == UNCAPPED_VENDOR.zoneId then
    f.Echo("In Uncapped vendor zone, spending Uncapped")
    SpendUncapped()
elseif Svc.ClientState.TerritoryType == NUTS_VENDOR.zoneId then
    f.Echo("In Nuts vendor zone, spending Nuts")
    SpendNuts()
end

f.Echo("Initiating all spend functions")
SpendPoetics()
SpendUncapped()
SpendNuts()

f.Echo("Last Desynth before script end")
DesynthItems()

f.Echo("Enabling YesAlready")
IPC.YesAlready.SetPluginEnabled(true)

f.Echo("Script done!")