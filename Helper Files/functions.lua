-- functions.lua
-- Defines 'functions' table containing reusable utilities for SND scripts
-- Also defines some globals soon(?)

--[[
huntLocations = require("huntLocations")
huntMarks = require("huntMarks")
zoneList = require("vac_lists").Zone_List
functions = require("functions")
MOUNT_SPEED = 20.6 -- Speed for flying mounts
TP_DELAY = 7 -- Time penalty for using teleport
VBM_PRESET = "A Ranks" -- Preset for VBM
HUNT_RANK = "B" -- Hunt rank to search for
]]

local functions = {}

--[[
Echo
Prints a message to chat using /echo.
Parameters:
- message (string)
]]
functions.Echo = function(message)
    if DEBUG then
        yield("/echo "..tostring(message))
    end
end

--[[
Wait
Pauses script execution for the given number of seconds.
Parameters:
- number (number)
]]
functions.Wait = function(number)
    yield("/wait "..number)
end

--[[
WaitForReady
Waits until the player is not busy.
]]
functions.WaitForReady = function()
    while Player.IsBusy do
        functions.Wait(0.1)
    end
end

--[[
WaitForBusy
Waits until the player is busy.
]]
functions.WaitForBusy = function()
    while not Player.IsBusy do
        functions.Wait(0.1)
    end
end

--[[
WaitForOutOfCombat
Waits until the player is no longer in combat.
]]
functions.WaitForOutOfCombat = function()
    while Player.Entity.IsInCombat do
        functions.Wait(0.1)
    end
end

--[[
WaitForCombat
Waits until the player enters combat.
]]
functions.WaitForCombat = function()
    while not Player.Entity.IsInCombat do
        functions.Wait(0.1)
    end
end

--[[
WaitForVnav
Waits until vnav pathfinding is finished.
External dependencies:
- vnavmesh
]]
functions.WaitForVnav = function()
    while IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() do
        functions.Wait(0.1)
    end
end

--[[
WaitForAddon
Waits until the specified addon is ready.
Parameters:
- name (string)
]]
functions.WaitForAddon = function(name)
    while not Addons.GetAddon(name).Ready do
        functions.Wait(0.1)
    end
end

--[[
WaitForZone
Waits until passed territory ID matches the current zone
]]
functions.WaitForZone = function(territoryId)
    while territoryId ~= Svc.ClientState.TerritoryType do
        functions.Wait(0.1)
    end
    functions.WaitForReady()
    functions.Wait(2)
end

--[[
MountUp
Mounts the player using Mount Roulette if possible.
]]
functions.MountUp = function()
    if not Svc.Condition[4] and Player.CanMount then
        functions.WaitForOutOfCombat()
        functions.WaitForReady()
        yield('/gaction "Mount Roulette"')
        functions.Wait(1)
    end
end

--[[
Dismount
Dismounts the player if mounted.
]]
functions.Dismount = function()
    while Svc.Condition[4] do
        yield('/gaction "Mount Roulette"')
        functions.Wait(1)
    end
end

--[[
FlyToFlag
Mounts up and flies to the current map flag using vnav.
External dependencies:
- vnavmesh
]]
functions.FlyToFlag = function()
    functions.MountUp()
    yield("/vnav flyflag")
    functions.WaitForVnav()
end

--[[
MoveToCoordinates
Moves player to specified coordinates using vnav.
Parameters:
- x, y, z (number)
External dependencies:
- vnavmesh
]]
functions.MoveToCoordinates = function(x, y, z)
    yield("/vnav moveto "..x.." "..y.." "..z)
end

--[[
DistanceBetweenVectors
Returns distance between two Vector3 positions.
Parameters:
- vectorA, vectorB (Vector3)
Returns:
- distance (number)
]]
functions.DistanceBetweenVectors = function(vectorA, vectorB)
    local distance = math.sqrt(
    (vectorB.X - vectorA.X)^2 +
    (vectorB.Y - vectorA.Y)^2 +
    (vectorB.Z - vectorA.Z)^2
    )
    return distance
end

--[[
CalculateEtaFlight3
Estimates ETA to flag when flying.
External dependencies:
- MOUNT_SPEED
Returns:
- eta (number)
]]
functions.CalculateEtaFlight3 = function()
    local playerPos = Player.Entity.Position
    local flagPos = Instances.Map.Flag.Vector3
    local distance = functions.DistanceBetweenVectors(playerPos, flagPos)
    local eta = distance / MOUNT_SPEED
    return eta
end

--[[
CalculateEtaTp3
Estimates ETA to flag if teleporting.
External dependencies:
- MOUNT_SPEED
- TP_DELAY
Returns:
- eta (number)
- closestAetheryteId (number)
]]
functions.CalculateEtaTp3 = function()
    local aetherytePos = functions.GetAetherytesInFlagZone()
    local flagPos = Instances.Map.Flag.Vector3

    local shortestDistance = math.huge
    local closestAetheryteId = nil

    for _, entry in ipairs(aetherytePos) do
        local pos = entry.position
        local id = entry.id
        local distance = functions.DistanceBetweenVectors(flagPos, pos)
        if distance < shortestDistance then
            shortestDistance = distance
            closestAetheryteId = id
        end
    end

    local eta = (shortestDistance / MOUNT_SPEED) + TP_DELAY
    return eta, closestAetheryteId
end

--[[
GetAetherytesInFlagZone
Returns a list of aetherytes (id and position) in the flag's zone.
External dependencies:
- zoneList
Returns:
- aetherytePos (table)
]]
functions.GetAetherytesInFlagZone = function()
    local flagZoneId = Instances.Map.Flag.TerritoryId
    local flagZone = ZONE_LIST[tostring(flagZoneId)]
    local aetherytePos = {}

    if flagZone and flagZone.Aetherytes then
        for _, aetheryte in ipairs(flagZone.Aetherytes) do
            local aetheryteId = tonumber(aetheryte.ID)
            if aetheryteId then
                local pos = Instances.Telepo:GetAetherytePosition(aetheryteId)
                if pos then
                    table.insert(aetherytePos, { id = aetheryteId, position = pos })
                end
            end
        end
    end

    return aetherytePos
end

--[[
BuyFromShop
Buys an item from shop via callback.
Parameters:
- shopName (string)
- a, b, c (number)
]]
functions.BuyFromShop = function(shopName, a, b, c)
    yield("/callback "..shopName.." true "..a.." "..b.." "..c)
end

--[[
NavigateToShopCategory
Navigates to a shop category via callback.
Parameters:
- shopName (string)
- a, b (number)
]]
functions.NavigateToShopCategory = function(shopName, a, b)
    yield("/callback "..shopName.." true "..a.." "..b)
end

--[[
FindItemID
Finds item ID by name from itemList.
Parameters:
- item_to_find (string)
External dependencies:
- itemList
Returns:
- item ID (number) or nil
]]
functions.FindItemID = function(item_to_find)
    local search_term = string.lower(item_to_find)
    for key, item in pairs(ITEM_LIST) do
        local item_name = string.lower(item['Name'])
        if item_name == search_term then
            return key
        end
    end
    return nil
end

--[[
FindZoneNameByTerritoryId
Returns the zone name for a given territory ID.
Parameters:
- territoryId (number)
External dependencies:
- zoneList
Returns:
- zone name (string)
]]
functions.FindZoneNameByTerritoryId = function(territoryId)
    territoryId = tostring(territoryId)
    for id, zone in pairs(ZONE_LIST) do
        if id == territoryId then
            return zone.Zone
        end
    end
end

--[[
GetZoneHuntLocations
Returns hunt positions for a given territory ID.
Parameters:
- territoryId (number)
External dependencies:
- huntLocations
Returns:
- positions (table) or nil
]]
functions.GetZoneHuntLocations = function(territoryId)
    for _, expansion in pairs(HUNT_LOCATIONS) do
        for _, zone in ipairs(expansion) do
            if zone.mapId == territoryId then
                return zone.positions
            end
        end
    end
end

--[[
ConvertToRealCoordinates
Converts map coordinates to real coordinates based on map scale.
Parameters:
- territoryId (number)
- x, y (number)
Returns:
- territoryId (number)
- newX, newY (number)
]]
functions.ConvertToRealCoordinates = function(territoryId, x, y)
    local mapScale = (territoryId >= 397 and territoryId <= 402) and 95 or 100
    local newX = 50 * (x - 1 - (2048 / mapScale))
    local newY = 50 * (y - 1 - (2048 / mapScale))
    return territoryId, newX, newY
end

--[[
SearchAndDestroy
Moves to hunt mark, targets them, dismounts, and waits until out of combat
External dependencies:
- vnavmesh
- VBM
]]
functions.SearchAndDestroy = function(huntMarkName, VbmPreset)
    local huntMark = Entity.GetEntityByName(huntMarkName)
    if huntMark ~= nil and huntMark.HealthPercent ~= 0 then
        yield("/vbm ar set "..VbmPreset)
        functions.MountUp()
        IPC.vnavmesh.PathfindAndMoveTo(huntMark.Position, true)
        functions.WaitForVnav()
        huntMark:SetAsTarget()
        functions.Dismount()
        functions.Wait(3)
        functions.WaitForOutOfCombat()
        yield("/vbm ar clear")
        if huntMarkName == "Flame Sergeant Dalvag" then
            functions.Wait(15) -- Wait for Dalvag to respawn
        end
    end
end

--[[
FlyAndDestroy
Flies to flag while searching for a hunt mark; attacks mark if found, resumes flight afterwards
External dependencies:
- vnavmesh
- VBM
]]
functions.FlyAndDestroyToFlag = function(huntMarkName, VbmPreset)
    functions.MountUp()
    yield("/vnav flyflag")

    while IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() do
        functions.SearchAndDestroy(huntMarkName, VbmPreset)
        if not(IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning()) then
            functions.MountUp()
            yield("/vnav flyflag")
        end
        functions.Wait(0.1)
    end
end

--[[
TpToAetheryte
Teleports to Aetheryte by ID
]]
functions.TpToAetheryte = function(aetheryteId)
    functions.WaitForOutOfCombat()
    functions.WaitForReady()
    Actions.Teleport(tonumber(aetheryteId))
    functions.WaitForBusy()
    functions.WaitForReady()
end

return functions