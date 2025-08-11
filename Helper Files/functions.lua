---@class functions @provides various utility functions for SND scripts.
local functions = {}

---Prints a message to the game chat using /echo (only if DEBUG is enabled).
---@param message string
function functions.Echo(message)
    if DEBUG then
        yield("/echo " .. tostring(message))
    end
end

--#region Wait functions

---Waits the specified number of seconds.
---@param number number
function functions.Wait(number)
    yield("/wait " .. number)
end

---Waits until the player is no longer busy.
function functions.WaitForReady()
    while Player.IsBusy do
        functions.Wait(0.1)
    end
end

---Waits until the player is busy.
function functions.WaitForBusy()
    while not Player.IsBusy do
        functions.Wait(0.1)
    end
end

---Waits until the player exits combat.
function functions.WaitForOutOfCombat()
    while Player.Entity.IsInCombat do
        functions.Wait(0.1)
    end
end

---Waits until the player enters combat.
function functions.WaitForCombat()
    while not Player.Entity.IsInCombat do
        functions.Wait(0.1)
    end
end

---Waits for vnav to finish building its mesh, pathfinding and navigating to target.
function functions.WaitForVnav()
    while not IPC.vnavmesh.IsReady() or IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() do
        functions.Wait(0.1)
    end
end

---Waits until a specific UI addon is ready.
---@param name string
function functions.WaitForAddon(name)
    for i = 1, 10 do
        if not Addons.GetAddon(name).Ready then
        functions.Wait(0.1)
        end
    end
end

---Waits until the zone ID matches the target territory ID, then waits for player to be ready and vnav to build its mesh.
---@param territoryId number
function functions.WaitForZone(territoryId)
    while territoryId ~= Svc.ClientState.TerritoryType do
        functions.Wait(0.1)
    end
    functions.WaitForReady()
    functions.WaitForVnav()
    functions.Wait(1) -- additional wait still neded it seems :()
end

---Waits for HTA to change to the specified instance if any exist, then waits for player to be ready and vnav to build its mesh.
---@param instanceId number
function functions.WaitForInstance(instanceId)
    if IPC.Lifestream.GetNumberOfInstances() ~= 0 and IPC.Lifestream.GetCurrentInstance() ~= instanceId then
        functions.Echo("Waiting for HTA to change instances")
        while IPC.Lifestream.GetCurrentInstance() ~= instanceId do
            functions.Wait(0.1)
        end
        functions.WaitForReady()
        functions.WaitForVnav()
    end
end
--#endregion

---Mounts up using Mount Roulette if not already mounted.
function functions.MountUp()
    if not Svc.Condition[4] and Player.CanMount then
        functions.WaitForOutOfCombat()
        functions.WaitForReady()
        yield('/gaction "Mount Roulette"')
        functions.Wait(1)
    end
end

---Dismounts if the player is mounted.
function functions.Dismount()
    while Svc.Condition[4] do
        yield('/gaction "Mount Roulette"')
        functions.Wait(1)
    end
end

---Executes a Lifestream command.
---@param command string
function functions.Lifestream(command)
    functions.Echo("Executing /li " .. command)
    yield("/vnav stop")
    functions.WaitForOutOfCombat()
    functions.WaitForReady()
    yield("/li " .. command)
end

---Buys a single item from the Market Board and closes its menus afterwards.
---Caution: Item search only works with names that don't have spaces. For others, a workaround is needed.
---@param itemName string
function functions.BuyItemFromMarketBoard(itemName)
    functions.Echo("Buying item: " .. itemName)
    functions.BuyItemFromMarketBoard(itemName)
    functions.WaitForAddon("ItemSearch")
    yield("/callback ItemSearch true 9 1 2 " .. itemName .. " " .. itemName .. " 5 6 7")
    functions.Wait(1)
    yield("/callback ItemSearch true 5 17")
    functions.WaitForAddon("ItemSearchResult")
    yield("/callback ItemSearchResult true 2 0")
    functions.WaitForAddon("SelectYesno")
    yield("/callback SelectYesno true 0")
    functions.WaitForAddon("ItemSearchResult")
    yield("/callback ItemSearchResult true -1")
    functions.WaitForAddon("ItemSearch")
    yield("/callback ItemSearch true -1")
    --future function that closes addon and therefore waits until its no longer active
    --WIP!
end

---Mounts up and flies to the active map flag using vnav.
function functions.FlyToFlag()
    functions.MountUp()
    yield("/vnav flyflag")
    functions.WaitForVnav()
end

---Moves player to specified coordinates using vnav.
---@param x number
---@param y number
---@param z number
function functions.MoveToCoordinates(x, y, z)
    yield("/vnav moveto " .. x .. " " .. y .. " " .. z)
end

---Calculates the distance between two 3D vector positions.
---@param vectorA Vector3
---@param vectorB Vector3
---@return number distance
function functions.DistanceBetweenVectors(vectorA, vectorB)
    local distance = math.sqrt(
        (vectorB.X - vectorA.X)^2 +
        (vectorB.Y - vectorA.Y)^2 +
        (vectorB.Z - vectorA.Z)^2
    )
    return distance
end

---Estimates ETA to the map flag while flying.
---@return number eta
function functions.CalculateEtaFlight3()
    local playerPos = Player.Entity.Position
    playerPos.Y = 0
    local flagPos = Instances.Map.Flag.Vector3
    local distance = functions.DistanceBetweenVectors(playerPos, flagPos)
    local eta = distance / MOUNT_SPEED
    return eta
end

---Estimates ETA to the map flag via teleportation and flight.
---@return number eta
---@return number|nil closestAetheryteId
function functions.CalculateEtaTp3()
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

---Returns a list of aetherytes (id and position) in the flag’s zone.
---@return table aetherytePos
function functions.GetAetherytesInFlagZone()
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

---Buys an item from a shop via callback.
---@param shopName string
---@param a number
---@param b number
---@param c number
function functions.BuyFromShop(shopName, a, b, c)
    yield("/callback " .. shopName .. " true " .. a .. " " .. b .. " " .. c)

    -- timed check in case SelectYesno is auto-confirmed by YesAlready
    for i = 1, 10 do
        if not Addons.GetAddon("SelectYesno").Ready then
            functions.Wait(0.1)
        end
    end

    yield("/callback SelectYesno true 0")
    functions.Wait(1)
end

---Closes the shop window via callback.
---@param shopName string
function functions.CloseShop(shopName)
    yield("/callback " .. shopName .. " true -1")
    functions.Wait(1)
end

---Navigates to a specific category in a shop UI.
---@param shopName string
---@param a number
---@param b number
function functions.NavigateToShopCategory(shopName, a, b)
    yield("/callback " .. shopName .. " true " .. a .. " " .. b)
    functions.Wait(1)
end

---Selects a list option in an addon window via callback.
---@param addonName string
---@param a number
function functions.SelectListOption(addonName, a)
    yield("/callback " .. addonName .. " true " .. a)
    functions.Wait(1)
end

---Finds an item ID by item name from ITEM_LIST.
---@param item_to_find string
---@return number|nil itemId
function functions.FindItemID(item_to_find)
    local search_term = string.lower(item_to_find)
    for key, item in pairs(ITEM_LIST) do
        local item_name = string.lower(item['Name'])
        if item_name == search_term then
            return key
        end
    end
    return nil
end

---Gets the zone name for a given territory ID.
---@param territoryId number
---@return string|nil zoneName
function functions.FindZoneNameByTerritoryId(territoryId)
    for id, zone in pairs(ZONE_LIST) do
        if id == tostring(territoryId) then
            return zone.Zone
        end
    end
end

---Retrieves hunt positions for a given territory ID.
---@param territoryId number
---@return table|nil huntPositions
function functions.GetZoneHuntLocations(territoryId)
    for _, expansion in pairs(HUNT_LOCATIONS) do
        for _, zone in ipairs(expansion) do
            if zone.mapId == territoryId then
                return zone.positions
            end
        end
    end
end

---Converts map coordinates to real in-world coordinates.
---@param territoryId number
---@param x number
---@param y number
---@return number territoryId
---@return number newX
---@return number newY
function functions.ConvertToRealCoordinates(territoryId, x, y)
    local mapScale = (territoryId >= 397 and territoryId <= 402) and 95 or 100
    local newX = 50 * (x - 1 - (2048 / mapScale))
    local newY = 50 * (y - 1 - (2048 / mapScale))
    return territoryId, newX, newY
end

---Searches for a hunt mark by name, moves to it, engages, and waits for combat to end.
---@param huntMarkName string
---@param VbmPreset string
function functions.SearchAndDestroy(huntMarkName, VbmPreset)
    local huntMark = Entity.GetEntityByName(huntMarkName)
    if huntMark ~= nil and huntMark.HealthPercent ~= 0 then
        yield("/echo Distance to " .. huntMark.Name .. ": " .. math.floor(huntMark.DistanceTo))
        yield("/vbm ar set " .. VbmPreset)
        functions.MountUp()
        huntMark.Position.Y = huntMark.Position.Y + 50 -- offset to avoid ground collision
        IPC.vnavmesh.PathfindAndMoveTo(huntMark.Position, true)
        functions.WaitForVnav()
        huntMark:SetAsTarget()
        functions.Dismount()
        functions.Wait(5)
        functions.WaitForOutOfCombat()
        yield("/vbm ar clear")
    end
end

---Flies toward the map flag while scanning for and engaging hunt marks.
---@param huntMarks table<string> List of hunt mark names
---@param VbmPreset string VBM preset to use during engagement
function functions.FlyAndDestroyToFlag(huntMarks, VbmPreset)
    functions.MountUp()
    yield("/vnav flyflag")

    while IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() do
        for _, huntMarkName in pairs(huntMarks) do
            --functions.Echo("Searching for " .. huntMarkName)
            functions.SearchAndDestroy(huntMarkName, VbmPreset)
        end
        functions.Wait(0.1)
    end
end

---Teleports to the specified aetheryte by ID and waits for vnav to be ready.
---@param aetheryteId number
function functions.TpToAetheryte(aetheryteId)
    functions.WaitForOutOfCombat()
    functions.WaitForReady()
    Actions.Teleport(tonumber(aetheryteId))
    functions.WaitForBusy()
    functions.WaitForReady()
    functions.WaitForVnav()
end

return functions