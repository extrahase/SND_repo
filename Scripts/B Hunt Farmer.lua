-- B Hunt Farmer

-- ############
-- ### DATA ###
-- ############

import("System.Numerics")

--HUNT_LOCATIONS = require("huntLocations")
--HUNT_MARKS = require("huntMarks")
--ZONE_LIST = require("vac_lists").Zone_List

local functions = require("functions")

DEBUG = false
--MOUNT_SPEED = 20.6
--TP_DELAY = 7
VBM_PRESET = "A Ranks"
HUNT_RANK = "B"

-- ############
-- ### MAIN ###
-- ############

functions.Echo("Script started!")

-- local huntMarksByRank = { }

-- for _, expansion in pairs(HUNT_MARKS) do
--     if expansion[HUNT_MARKS] then
--         for _, mark in ipairs(expansion[HUNT_MARKS]) do
--             table.insert(huntMarksByRank, mark)
--         end
--     end
-- end

functions.WaitForOutOfCombat()
yield("/vbm ar clear")
functions.MountUp()

-- build list of flags for current zone
local zoneHuntLocations = { { x = 23.6, y = 25.25 }, { x = 16.85, y = 16.95 } }

-- loop through each flag, place it and start the hunt
while true do
    for _, position in ipairs(zoneHuntLocations) do
            Instances.Map.Flag:SetFlagMapMarker(functions.ConvertToRealCoordinates(Svc.ClientState.TerritoryType, position.x, position.y))
            functions.FlyAndDestroyToFlag("Flame Sergeant Dalvag", VBM_PRESET)
    end
end

functions.Echo("Script done!")