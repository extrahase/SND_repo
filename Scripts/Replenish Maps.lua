-- ############
-- ### DATA ###
-- ############

local f = require("functions")

ITEM_LIST = require("vac_lists").Item_List

MAP_NAME = "Timeworn Saigaskin Map"
HOME_POINT = "Tuliyollal"
HOME_POINT_TERRITORY_ID = 1185

DEBUG = true

-- #################
-- ### FUNCTIONS ###
-- #################

function DecipherMap(mapName)
    f.WaitForReady()
    yield("/item " .. mapName)
    f.WaitForBusy()
    f.WaitForReady()
end

-- ############
-- ### MAIN ###
-- ############

f.Echo("Starting script!")

f.Echo("Disabling YesAlready")
IPC.YesAlready.SetPluginEnabled(false)

f.Echo("Teleporting to " .. HOME_POINT .. " if not already there")
if Svc.ClientState.TerritoryType ~= HOME_POINT_TERRITORY_ID then
    f.Return()
    f.WaitForZone(HOME_POINT_TERRITORY_ID)
    IPC.Lifestream.AethernetTeleport("Bayside Bevy Marketplace")
    f.WaitForLifestream()
end

f.Echo("Moving to Market Board")
f.MoveToCoordinates(3.91, -14.00, 133.84)

f.Echo("Buying first " .. MAP_NAME .. " from Market Board")
f.BuyItemFromMarketBoard(MAP_NAME)

f.Echo("Deciphering first " .. MAP_NAME)
DecipherMap(MAP_NAME)

f.Echo("Buying second " .. MAP_NAME .. " from Market Board")
f.BuyItemFromMarketBoard(MAP_NAME)

f.Echo("Storing second " .. MAP_NAME .. " in saddlebag")
f.StoreItemInSaddlebag(MAP_NAME)

f.Echo("Buying third " .. MAP_NAME .. " from Market Board")
f.BuyItemFromMarketBoard(MAP_NAME)

f.Echo("Enabling YesAlready")
IPC.YesAlready.SetPluginEnabled(true)

f.Echo("Script done!")