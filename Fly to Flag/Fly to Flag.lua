import("System.Numerics")
local zoneList = require("vac_lists").Zone_List
local functions = require("functions")

MOUNT_SPEED = 20.6
TP_DELAY = 7

local etaTp, closestAetheryteId = functions.CalculateEtaTp3()
local etaFlight = functions.CalculateEtaFlight3()

if Instances.Map.Flag.TerritoryId ~= Svc.ClientState.TerritoryType then
    Actions.Teleport(closestAetheryteId)
end

if etaTp <= etaFlight then
    functions.WaitForReady()
    Actions.Teleport(closestAetheryteId)
    functions.Wait(5)
else
    functions.Echo("Flight is better")
end

functions.FlyToFlag()
functions.Dismount()