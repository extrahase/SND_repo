-- Fly to Flag

import("System.Numerics")

ZONE_LIST = require("vac_lists").Zone_List

local functions = require("functions")

MOUNT_SPEED = 20.6
TP_DELAY = 7

local etaTp, closestAetheryteId = functions.CalculateEtaTp3()

if Instances.Map.Flag.TerritoryId ~= Svc.ClientState.TerritoryType then
    Actions.Teleport(closestAetheryteId)
    functions.WaitForZoneAndReady()
    end

functions.FlyToFlag()
functions.Dismount()