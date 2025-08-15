-- ############
-- ### DATA ###
-- ############

local f = require("functions")

MAP_NAME = "Timeworn Loboskin Map"

DEBUG = true

-- #################
-- ### FUNCTIONS ###
-- #################

function DecipherMap(mapName)
    f.WaitForReady()
    yield("/item " .. mapName)
    f.WaitForReady()
end

-- ############
-- ### MAIN ###
-- ############

f.Echo("Starting script!")

f.Echo("Moving to Market Board")
f.Lifestream("mb")

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

f.Echo("Script done!")