-- ############
-- ### DATA ###
-- ############

local functions = require("functions")

ITEM_LIST = require("vac_lists").Item_List

MAP_NAME = "Timeworn Saigaskin Map"
HOME_POINT = "Tuliyollal"
HOME_POINT_TERRITORY_ID = 1185

DEBUG = true

-- #################
-- ### FUNCTIONS ###
-- #################

function DecipherMap(mapName)
    functions.WaitForReady()
    yield("/item " .. mapName)
    functions.WaitForBusy()
    functions.WaitForReady()
end

-- ############
-- ### MAIN ###
-- ############

functions.Echo("Starting script!")

functions.Echo("Disabling YesAlready")
IPC.YesAlready.SetPluginEnabled(false)

functions.Echo("Teleporting to " .. HOME_POINT .. " if not already there")
if Svc.ClientState.TerritoryType ~= HOME_POINT_TERRITORY_ID then
    functions.Return()
    functions.WaitForZone(HOME_POINT_TERRITORY_ID)
    IPC.Lifestream.AethernetTeleport("Bayside Bevy Marketplace")
    functions.WaitForLifestream()
end

functions.Echo("Moving to Market Board")
functions.MoveToCoordinates(3.91, -14.00, 133.84)

functions.Echo("Buying first " .. MAP_NAME .. " from Market Board")
functions.BuyItemFromMarketBoard(MAP_NAME)

functions.Echo("Deciphering first " .. MAP_NAME)
DecipherMap(MAP_NAME)

functions.Echo("Buying second " .. MAP_NAME .. " from Market Board")
functions.BuyItemFromMarketBoard(MAP_NAME)

functions.Echo("Storing second " .. MAP_NAME .. " in saddlebag")
functions.StoreItemInSaddlebag(MAP_NAME)

functions.Echo("Buying third " .. MAP_NAME .. " from Market Board")
functions.BuyItemFromMarketBoard(MAP_NAME)

functions.Echo("Enabling YesAlready")
IPC.YesAlready.SetPluginEnabled(true)

functions.Echo("Script done!")