-- Hunt Train Passenger

-- ############
-- ### DATA ###
-- ############

import("System.Numerics")

HUNT_LOCATIONS = require("huntLocations")
HUNT_MARKS = require("huntMarks")
ZONE_LIST = require("vac_lists").Zone_List

local f = require("functions")

DEBUG = false
MOUNT_SPEED = 20.6
TP_DELAY = 7
VBM_PRESET = "A Ranks"
HUNT_RANK = "A"

-- ############
-- ### MAIN ###
-- ############

f.WaitForOutOfCombat()
yield("/vbm ar clear")

-- if flag in different zone: waits for HTA to do its thing
-- if flag in same zone: tries to account for HTA instance switching
f.Echo("Checking if flag is in different zone or same zone")
if Instances.Map.Flag.TerritoryId ~= Svc.ClientState.TerritoryType then -- flag is in different zone
    f.Echo("Flag in different zone --> waiting for HTA to change zones")
    f.WaitForZone(Instances.Map.Flag.TerritoryId)
    f.WaitForInstance(1) -- account for switching instances
else -- flag is in same zone
    f.Echo("Flag in same zone --> checking for instance switching")
    local numberOfInstances = IPC.Lifestream.GetNumberOfInstances()
    if numberOfInstances ~= 0 then -- checks if zone has instances
        f.Echo("Zone has instances, checking current instance")
        local currentInstance = IPC.Lifestream.GetCurrentInstance()
        if currentInstance == numberOfInstances then
            f.Echo("Already in the last instance, no need to wait")
        else
            f.Echo("Possible HTA instance switching detected, waiting 2s")
            f.Wait(2)
            if Player.IsBusy then -- if player is busy, HTA must be active
                f.Echo("Player is busy, HTA must be active, waiting for it to finish")
                f.WaitForInstance(currentInstance + 1)
            end
        end
    end
end
f.Echo("We arrived in the right zone and instance, continuing with TP/flight check")
f.Wait(1) -- sometimes player position wouldn't be accessible yet after teleporting, so we wait a bit

-- determines if (flying) or (teleporting, then flying) is better and starts travel
local etaTp, closestAetheryteId = f.CalculateEtaTp3()
local etaFlight = f.CalculateEtaFlight3()

if etaTp <= etaFlight then
    if closestAetheryteId ~= 148 and closestAetheryteId ~= 173 and closestAetheryteId ~= 175 then
    f.TpToAetheryte(closestAetheryteId)
    end
end

-- construct table with Hunt Marks for current zone
local zoneName = f.FindZoneNameByTerritoryId(Svc.ClientState.TerritoryType)
local huntMarks = { }
for _, expansion in pairs(HUNT_MARKS) do
    if expansion[HUNT_RANK] then
        for _, mark in ipairs(expansion[HUNT_RANK]) do
            if mark.zone == zoneName then
                f.Echo("Adding "..mark.name.." to hunt marks")
                table.insert(huntMarks, mark.name)
            end
        end
    end
end

f.FlyAndDestroyToFlag(huntMarks, VBM_PRESET)
f.Wait(0.5) -- to make it appear less bot-like
f.MountUp()

f.Echo("Script done!")