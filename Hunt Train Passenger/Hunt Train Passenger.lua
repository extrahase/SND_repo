-- ############
-- ### DATA ###
-- ############

import("System.Numerics")
local huntLocations = require("huntLocations")
local zoneList = require("vac_lists").Zone_List
local functions = require("functions")

MOUNT_SPEED = 20.6
TP_DELAY = 7
VBM_PRESET = "A Ranks"

-- ############
-- ### MAIN ###
-- ############

functions.WaitForOutOfCombat()
yield("/vbm ar clear")
functions.MountUp()

-- waits for HTA to do its thing depending on if the flag is in a new zone or not
if Instances.Map.Flag.TerritoryId ~= Svc.ClientState.TerritoryType then
    -- flag is in different zone
    functions.Echo("Waiting for HTA to change zones")
    functions.WaitForZoneAndReady()

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
        -- IPC.Lifestream.GetNumberOfInstances() also doesn't work atm
        functions.Echo("Possible HTA instance switching detected, waiting 10s")
        functions.Wait(10)
    end
end

functions.CorrectFlagPosition()

-- determines if (flying) or (teleporting, then flying) is better and starts travel
local etaTp, closestAetheryteId = functions.CalculateEtaTp3()
local etaFlight = functions.CalculateEtaFlight3()

if etaTp <= etaFlight then
    functions.WaitForReady()
    Actions.Teleport(closestAetheryteId)
    functions.Wait(5)
else
    functions.Echo("Flight is better")
end

functions.WaitForReady()
functions.FlyToFlag()
functions.SearchAndDestroy()
functions.MountUp()

functions.Echo("Script done!")