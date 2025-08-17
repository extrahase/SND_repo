-- Fly to Flag

import("System.Numerics")

local f = require("functions")
ZONE_LIST = require("vac_lists").Zone_List

DEBUG = false
MOUNT_SPEED = 20.6
TP_DELAY = 7

local etaTp, closestAetheryteId = f.CalculateEtaTp3()

if Instances.Map.Flag.TerritoryId ~= Svc.ClientState.TerritoryType then
    f.TpToAetheryte(closestAetheryteId)
    f.WaitForZone(Instances.Map.Flag.TerritoryId)
    end

f.FlyToFlag()
f.Dismount()