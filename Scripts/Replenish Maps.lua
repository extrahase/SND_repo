--[=====[
[[SND Metadata]]
author: shufti
version: 7
plugin_dependencies:
- Lifestream
- vnavmesh
plugins_to_disable:
- YesAlready
configs:
    Map Name:
        description: Enter the name of the map, without "Timeworn" and "Map". E.g. "Saigaskin"
        type: string
[[End Metadata]]
--]=====]

-- ############
-- ### DATA ###
-- ############

local f = require("functions")

ITEM_LIST = require("vac_lists").Item_List

HOME_POINT = "Tuliyollal"
HOME_POINT_TERRITORY_ID = 1185

DEBUG = false

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
local mapName = "Timeworn " .. Config.Get("Map Name") .. " Map"

f.Echo("Teleporting to " .. HOME_POINT .. " if not already there")
if Svc.ClientState.TerritoryType ~= HOME_POINT_TERRITORY_ID then
    f.Return()
    f.WaitForZone(HOME_POINT_TERRITORY_ID)
    IPC.Lifestream.AethernetTeleport("Bayside Bevy Marketplace")
    f.WaitForLifestream()
end

f.Echo("Moving to Market Board")
f.MoveToCoordinates(3.91, -14.00, 133.84)

f.Echo("Buying first " .. mapName .. " from Market Board")
f.BuyItemFromMarketBoard(mapName)

f.Echo("Deciphering first " .. mapName)
DecipherMap(mapName)

f.Echo("Buying second " .. mapName .. " from Market Board")
f.BuyItemFromMarketBoard(mapName)

f.Echo("Storing second " .. mapName .. " in saddlebag")
f.StoreItemInSaddlebag(mapName)

f.Echo("Buying third " .. mapName .. " from Market Board")
f.BuyItemFromMarketBoard(mapName)

f.Echo("Script done!")