-- Hunt Train Passenger

-- ############
-- ### DATA ###
-- ############

import("System.Numerics")

HUNT_LOCATIONS = require("huntLocations")
HUNT_MARKS = require("huntMarks")
ZONE_LIST = require("vac_lists").Zone_List

local functions = require("functions")

DEBUG = false
MOUNT_SPEED = 20.6
TP_DELAY = 7
VBM_PRESET = "A Ranks"
HUNT_RANK = "A"

-- ############
-- ### MAIN ###
-- ############

functions.Wait(1)

functions.WaitForOutOfCombat()
yield("/vbm ar clear")
functions.MountUp()

-- waits for HTA to do its thing depending on if the flag is in a new zone or not
if Instances.Map.Flag.TerritoryId ~= Svc.ClientState.TerritoryType then
    -- flag is in different zone
    functions.Echo("Waiting for HTA to change zones")
    functions.WaitForZone(Instances.Map.Flag.TerritoryId)

    -- account for switching instances
    if IPC.Lifestream.GetCurrentInstance() ~= 0 then
        while IPC.Lifestream.GetCurrentInstance() ~= 1 do
            functions.Echo("Waiting for HTA to change instances")
            functions.Wait(1)
        end
    end
else -- flag is in same zone
    if IPC.Lifestream.GetCurrentInstance() ~= 0 then -- account for switching instances
        -- just wait for now if instances are detected
        -- need to know more about how HTA handles this
        -- update: HTA teleports to closest Aetheryte, then switches instances
        -- IPC.Lifestream.GetNumberOfInstances() doesn't work atm
        functions.Echo("Possible HTA instance switching detected, waiting 15s")
        functions.Wait(15)
    end
end

-- determines if (flying) or (teleporting, then flying) is better and starts travel
local etaTp, closestAetheryteId = functions.CalculateEtaTp3()
local etaFlight = functions.CalculateEtaFlight3()

if etaTp <= etaFlight then
    if closestAetheryteId ~= 148 then
    functions.TpToAetheryte(closestAetheryteId)
    end
end

-- construct table with Hunt Marks for current zone
local zoneName = functions.FindZoneNameByTerritoryId(Svc.ClientState.TerritoryType)
local huntMarks = { }
for _, expansion in pairs(HUNT_MARKS) do
    if expansion[HUNT_RANK] then
        for _, mark in ipairs(expansion[HUNT_RANK]) do
            if mark.zone == zoneName then
                functions.Echo("Adding "..mark.name.." to hunt marks")
                table.insert(huntMarks, mark.name)
            end
        end
    end
end

functions.FlyAndDestroyToFlag(huntMarks, VBM_PRESET)

-- functions.MountUp()

functions.Echo("Script done!")