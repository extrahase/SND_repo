-- B Hunt Farmer

-- ############
-- ### DATA ###
-- ############

import("System.Numerics")
local huntLocations = require("huntLocations")
local huntMarks = require("huntMarks")
local zoneList = require("vac_lists").Zone_List
local functions = require("functions")

MOUNT_SPEED = 20.6
TP_DELAY = 7
VBM_PRESET = "A Ranks"
HUNT_RANK = "B"

-- ############
-- ### MAIN ###
-- ############

functions.Echo("Script started!")

local huntMarksByRank = { }

for _, expansion in pairs(huntMarks) do
    if expansion.B then
        for _, mark in ipairs(expansion.B) do
            table.insert(huntMarksByRank, mark)
        end
    end
end

functions.WaitForOutOfCombat()
yield("/vbm ar clear")
functions.MountUp()

-- build list of flags for current zone
local zoneHuntLocations = functions.GetZoneHuntLocations(Svc.ClientState.TerritoryType)

-- loop through each flag, place it and start the hunt
while true do
    for _, position in ipairs(zoneHuntLocations) do
        if position[HUNT_RANK] == true then
            Instances.Map.Flag:SetFlagMapMarker(functions.ConvertToRealCoordinates(Svc.ClientState.TerritoryType, position.x, position.y))
            functions.FlyToFlag()
            functions.SearchAndDestroy()
        end
    end
end

functions.Echo("Script done!")