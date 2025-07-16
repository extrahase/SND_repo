-- Fly to Flag

import("System.Numerics")

local functions = require("functions")
ZONE_LIST = require("vac_lists").Zone_List

DEBUG = false
MOUNT_SPEED = 20.6
TP_DELAY = 7

local etaTp, closestAetheryteId = functions.CalculateEtaTp3()

if Instances.Map.Flag.TerritoryId ~= Svc.ClientState.TerritoryType then
    functions.TpToAetheryte(closestAetheryteId)
    functions.WaitForZone(Instances.Map.Flag.TerritoryId)
    end

functions.FlyToFlag()
functions.Dismount()