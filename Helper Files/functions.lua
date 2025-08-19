---@class f @provides various utility functions for SND scripts.
local f = {}

--#region Utility functions

---Prints a message to the game chat using /echo (only if DEBUG is enabled).
---@param message any
function f.Echo(message)
    if DEBUG then
        yield("/echo " .. tostring(message))
    end
end

---Prints an error message to the game chat using /echo.
---@param message any
function f.Error(message)
     yield("/echo " .. tostring(message))
end

---Closes an addon window via callback.
---@param addonName string
function f.CloseAddon(addonName)
    yield("/callback " .. addonName .. " true -1")
    f.WaitForAddonClose(addonName)
end

---Selects "Yes" in a confirmation dialog via callback.
---@param addonName string
function f.SelectYes(addonName)
    yield("/callback " .. addonName .. " true 0")
    f.WaitForAddonClose(addonName)
end

---Selects "No" in a confirmation dialog via callback.
---@param addonName string
function f.SelectNo(addonName)
    yield("/callback " .. addonName .. " true 1")
    f.WaitForAddonClose(addonName)
end
--#endregion

--#region Wait functions

---Waits the specified number of seconds.
---@param number number
function f.Wait(number)
    yield("/wait " .. number)
end

---Waits until the player is no longer busy.
function f.WaitForReady()
    while Player.IsBusy do
        f.Wait(0.1)
    end
end

---Waits until the player is busy.
function f.WaitForBusy()
    while not Player.IsBusy do
        f.Wait(0.1)
    end
end

---Waits until the player exits combat.
function f.WaitForOutOfCombat()
    while Player.Entity.IsInCombat do
        f.Wait(0.1)
    end
end

---Waits until the player enters combat.
function f.WaitForCombat()
    while not Player.Entity.IsInCombat do
        f.Wait(0.1)
    end
end

---Waits for vnav to finish building its mesh, pathfinding and navigating to target.
function f.WaitForVnav()
    while not IPC.vnavmesh.IsReady() or IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() do
        f.Wait(0.1)
    end
end

---Waits for vnav to be busy with pathfinding or navigating to target.
function f.WaitForVnavBusy()
    while not IPC.vnavmesh.PathfindInProgress() and not IPC.vnavmesh.IsRunning() do
        f.Wait(0.1)
    end
end

---Waits until the player is distance or less away from the target vector, or until vnav is finished.
---@param targetVector3 Vector3
---@param distance number
function f.WaitForVnavDistance(targetVector3, distance)
    f.WaitForVnavBusy()
    local dist = (targetVector3 - Entity.Player.Position):Length()
    while dist > distance do
        f.Wait(0.1)
        dist = (targetVector3 - Entity.Player.Position):Length()
    end
    IPC.vnavmesh.Stop()
end

---Waits for Lifestream to finish its current operation.
function f.WaitForLifestream()
    while IPC.Lifestream.IsBusy() do
        f.Wait(0.1)
    end
end

---Waits until a specific addon is visible and ready.
---@param addonName string
function f.WaitForAddon(addonName)
    while not Addons.GetAddon(addonName).Ready do
        f.Wait(0.1)
    end
end

---Waits until a specific addon doesn't exist anymore.
---@param addonName string
function f.WaitForAddonClose(addonName)
    while Addons.GetAddon(addonName).Exists do
        f.Wait(0.1)
    end
end

---Waits until the current world ID matches the target world ID, then waits for player to be ready and vnav to build its mesh.
---@param worldId number
function f.WaitForWorld(worldId)
    while Entity.Player.CurrentWorld ~= worldId do
        f.Wait(0.1)
    end
    f.WaitForReady()
    f.WaitForVnav()
    f.WaitForPlayerPosition()
end

---Waits until the current territory ID matches the target territory ID, then waits for player to be ready and vnav to build its mesh.
---@param territoryId number
function f.WaitForZone(territoryId)
    while Svc.ClientState.TerritoryType ~= territoryId do
        f.Wait(0.1)
    end
    f.WaitForReady()
    f.WaitForVnav()
    f.WaitForPlayerPosition()
end

---Waits until the current instance ID matches the target instance ID, then waits for player to be ready and vnav to build its mesh.
---@param instanceId number
function f.WaitForInstance(instanceId)
    if IPC.Lifestream.GetNumberOfInstances() == 0 then return end -- no instances to wait for
    while IPC.Lifestream.GetCurrentInstance() ~= instanceId do
        f.Wait(0.1)
    end
    f.WaitForReady()
    f.WaitForVnav()
    f.WaitForPlayerPosition()
end

---Waits until the player position is available. Implemented as an additional check after teleporting or changing zones in lieu of Wait(1).
function f.WaitForPlayerPosition()
    while not Player.Entity.Position do
        f.Wait(0.1)
    end
end
--#endregion

--#region Travel and teleportation functions

---Mounts up using Mount Roulette if not already mounted.
function f.MountUp()
    if not Svc.Condition[4] and Player.CanMount then
        f.WaitForOutOfCombat()
        f.WaitForReady()
        yield('/gaction "Mount Roulette"')
        f.Wait(1)
    end
end

---Dismounts if the player is mounted.
function f.Dismount()
    while Svc.Condition[4] do
        yield('/gaction "Mount Roulette"')
        f.Wait(1)
    end
end

---Mounts up and flies to the active map flag using vnav.
function f.FlyToFlag()
    f.MountUp()
    yield("/vnav flyflag")
    f.WaitForVnavBusy()
    f.WaitForVnav()
end

---Moves player to specified coordinates on the ground using vnav.
---@param x number
---@param y number
---@param z number
function f.MoveToCoordinates(x, y, z)
    IPC.vnavmesh.Stop()
    f.WaitForReady()
    f.WaitForVnav()
    yield("/vnav moveto " .. x .. " " .. y .. " " .. z)
    f.WaitForVnavBusy()
    f.WaitForVnav()
end

---Flies player to specified coordinates using vnav.
---@param x number
---@param y number
---@param z number
function f.FlyToCoordinates(x, y, z)
    IPC.vnavmesh.Stop()
    f.WaitForReady()
    f.WaitForVnav()
    yield("/vnav flyto " .. x .. " " .. y .. " " .. z)
    f.WaitForVnavBusy()
    f.WaitForVnav()
end

---Moves player to a position within a specified distance from the target position using vnav.
---@param targetPosition Vector3
---@param distance number
function f.MoveWithInDistanceTo(targetPosition, distance)
    IPC.vnavmesh.PathfindAndMoveTo(targetPosition, Entity.Player.IsMounted)
    while (targetPosition - Entity.Player.Position):Length() > distance do
        f.Wait(0.1)
    end
    IPC.vnavmesh.Stop()
end

---Executes a Lifestream command and waits until it has finished.
---@param command string
function f.Lifestream(command)
    f.Echo("Executing /li " .. command)
    IPC.vnavmesh.Stop()
    IPC.Lifestream.Abort()
    f.WaitForVnav()
    f.WaitForLifestream()
    f.WaitForOutOfCombat()
    f.WaitForReady()
    IPC.Lifestream.ExecuteCommand(command)
    f.WaitForLifestream()
end

---Uses the Return action if not on cooldown, otherwise uses Teleport to the HOME_POINT.
function f.Return()
    f.Echo("Using Return if not on cooldown; using Teleport otherwise")
    if Actions.GetActionStatus(ActionType.GeneralAction, 8) == 0 then
        f.Echo("Using Return")
        f.WaitForOutOfCombat()
        f.WaitForReady()
        Actions.ExecuteGeneralAction(8)
        f.WaitForAddon("SelectYesno")
        f.SelectYes("SelectYesno")
        f.WaitForBusy()
        f.WaitForReady()
        f.WaitForVnav()
    else
        f.Echo("Using Teleport")
        f.Lifestream("tp " .. HOME_POINT)
    end
end

---Teleports to the specified aetheryte by ID and waits for vnav to be ready.
---@param aetheryteId number
function f.TpToAetheryte(aetheryteId)
    f.Echo("Teleporting to Aetheryte ID: " .. aetheryteId)
    f.WaitForOutOfCombat()
    f.WaitForReady()
    Actions.Teleport(aetheryteId)
    f.WaitForBusy()
    f.WaitForReady()
    f.WaitForVnav()
end

---Calculates the distance between two 3D vector positions.
---@param vectorA Vector3
---@param vectorB Vector3
---@return number distance
function f.DistanceBetweenVectors(vectorA, vectorB)
    local distance = math.sqrt(
        (vectorB.X - vectorA.X)^2 +
        (vectorB.Y - vectorA.Y)^2 +
        (vectorB.Z - vectorA.Z)^2
    )
    return distance
end

---Estimates ETA to the map flag while flying.
---@return number eta
function f.CalculateEtaFlight3()
    local playerPos = Player.Entity.Position
    playerPos.Y = 0
    local flagPos = Instances.Map.Flag.Vector3
    local distance = f.DistanceBetweenVectors(playerPos, flagPos)
    local eta = distance / MOUNT_SPEED
    return eta
end

---Estimates ETA to the map flag via teleportation and flight.
---@return number eta
---@return number|nil closestAetheryteId
function f.CalculateEtaTp3()
    local aetherytePos = f.GetAetherytesInFlagZone()
    local flagPos = Instances.Map.Flag.Vector3

    local shortestDistance = math.huge
    local closestAetheryteId = nil

    for _, entry in ipairs(aetherytePos) do
        local pos = entry.position
        local id = entry.id
        local distance = f.DistanceBetweenVectors(flagPos, pos)
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
function f.GetAetherytesInFlagZone()
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

---Finds the zone name for a given territory ID.
---@param territoryId number
---@return string|nil zoneName
function f.FindZoneNameByTerritoryId(territoryId)
    for id, zone in pairs(ZONE_LIST) do
        if id == tostring(territoryId) then
            return zone.Zone
        end
    end
end

---Finds the territory ID for a given zone name.
---@param zoneName string
---@return number|nil territoryId
function f.FindTerritoryIdByZoneName(zoneName)
    for territoryId, zone in pairs(ZONE_LIST) do
        if zone.Zone == zoneName then
            return tonumber(territoryId)
        end
    end
end

---Finds the territory ID for a given zone name.
---@param worldName string
---@return number|nil territoryId
function f.FindWorldIdByWorldName(worldName)
    for worldKey, world in pairs(WORLD_ID_LIST) do
        if worldKey == worldName then
            return world.ID
        end
    end
end

-- ---Retrieves hunt positions for a given territory ID.
-- ---@param territoryId number
-- ---@return table|nil huntPositions
-- function f.GetZoneHuntLocations(territoryId)
--     for _, expansion in pairs(HUNT_LOCATIONS) do
--         for _, zone in ipairs(expansion) do
--             if zone.mapId == territoryId then
--                 return zone.positions
--             end
--         end
--     end
-- end

---Converts map coordinates to real in-world coordinates.
---@param territoryId number
---@param x number
---@param y number
---@return number territoryId
---@return number newX
---@return number newY
function f.ConvertToRealCoordinates(territoryId, x, y)
    local mapScale = (territoryId >= 397 and territoryId <= 402) and 95 or 100
    local newX = 50 * (x - 1 - (2048 / mapScale))
    local newY = 50 * (y - 1 - (2048 / mapScale))
    return territoryId, newX, newY
end
--#endregion

--#region Item and shop functions

---Buys a single item from the Market Board and closes its menus afterwards.
---Caution: Item search only works with names that don't have spaces. For others, a workaround is needed.
---@param itemName string
function f.BuyItemFromMarketBoard(itemName)
    f.Echo("Buying item: " .. itemName)
    Entity.GetEntityByName("Market Board"):SetAsTarget()
    Entity.GetEntityByName("Market Board"):Interact()
    f.WaitForAddon("ItemSearch")
    yield('/callback ItemSearch true 9 1 2 "' .. itemName .. '" "' .. itemName .. '" 5 6 7')
    f.Wait(0.5)
    f.Callback2("ItemSearch", 5, 0) -- clicks on the first item in the search results
    f.WaitForAddon("ItemSearchResult")
    f.Wait(0.5)
    f.Callback2("ItemSearchResult", 2, 0) -- clicks on the first item in the search results
    f.WaitForAddon("SelectYesno")
    f.Wait(0.5)
    f.SelectYes("SelectYesno") -- confirms the purchase
    f.Wait(0.5)
    f.CloseAddon("ItemSearchResult")
    f.CloseAddon("ItemSearch")
end

---Buys an item from shop via callback; stays in shop menu afterwards.
---@param shopName string
---@param category number
---@param index number
---@param amount number
function f.BuyFromShop(shopName, category, index, amount)
    f.WaitForAddon(shopName)
    yield("/callback " .. shopName .. " true " .. category .. " " .. index .. " " .. amount)
    repeat -- account for potentially multiple confirmation dialogues
        f.Wait(0.1)
        yield("/callback SelectYesno true 0") -- not CloseAddon because it could result in infinite Wait loop
        yield("/callback ShopExchangeItemDialog true 0") -- dialogue for Poetics vendor
        f.Wait(0.1)
    until not Addons.GetAddon("SelectYesno").Exists and not Addons.GetAddon("ShopExchangeItemDialog").Exists
    f.WaitForAddon(shopName)
end

---Navigates to a specific category in a shop UI.
---@param shopName string
---@param a number
---@param b number
function f.Callback2(shopName, a, b)
    yield("/callback " .. shopName .. " true " .. a .. " " .. b)
    f.Wait(0.1)
end

---Waits for addon to be visible and ready, then selects a list option via callback, then waits for the addon to close.
---@param addonName string
---@param a number
function f.SelectListOption(addonName, a)
    f.WaitForAddon(addonName)
    yield("/callback " .. addonName .. " true " .. a)
    f.WaitForAddonClose(addonName)
end

---Finds an item ID by item name from ITEM_LIST.
---@param item_to_find string
---@return number|nil itemId
function f.FindItemID(item_to_find)
    local search_term = string.lower(item_to_find)
    for key, item in pairs(ITEM_LIST) do
        local item_name = string.lower(item['Name'])
        if item_name == search_term then
            return key
        end
    end
    return nil
end

---Stores an item in the Saddlebag by its name.
---@param itemName string
function f.StoreItemInSaddlebag(itemName)
    f.Echo("Opening Chocobo Saddlebag")
    yield("/send OEM_4")
    f.WaitForAddon("InventoryBuddy")
    f.Error("Waiting for manual close of Saddlebag")
    f.WaitForAddonClose("InventoryBuddy")

    -- moving an item to the Saddlebag doesn't work with the current API, so this is commented out
    -- functions.Echo("Storing " .. itemName .. " in saddlebag")
    -- local itemId = functions.FindItemID(itemName)
    -- if Inventory.GetInventoryContainer(InventoryType.SaddleBag1).FreeSlots > 0 then
    --     functions.Echo("Saddlebag 1 has free space, moving " .. itemName)
    --     Inventory.GetInventoryItem(itemId):MoveItemSlot(InventoryType.SaddleBag1)
    -- elseif Inventory.GetInventoryContainer(InventoryType.SaddleBag2).FreeSlots > 0 then
    --     functions.Echo("Saddlebag 2 has free space, moving " .. itemName)
    --     Inventory.GetInventoryItem(itemId):MoveItemSlot(InventoryType.SaddleBag2)
    -- else
    --     functions.Error("No free space in saddlebags, cannot store " .. itemName)
    -- end
    -- functions.Wait(0.5)

    -- functions.Echo("Closing Chocobo Saddlebag")
    -- functions.CloseAddon("InventoryBuddy")
end
--#endregion

--#region Misc functions

---Opens the Party Finder and joins a listing from The Hunt category. If there is no listing, it creates one.
function f.JoinHuntGroup()
    -- WIP!
end

---Flies toward the map flag while scanning for and engaging hunt marks.
---@param huntMarks table<string> List of hunt mark names
---@param VbmPreset string VBM preset to use during engagement
function f.FlyAndDestroyToFlag(huntMarks, VbmPreset)
    f.Echo("Mounting and initiating flight to flag")
    f.MountUp()
    yield("/vnav flyflag")
    f.WaitForVnavBusy()

    f.Echo("Starting Search & Destroy loop")
    while IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() do
        for _, huntMarkName in pairs(huntMarks) do
            f.SearchAndDestroy(huntMarkName, VbmPreset)
            f.Wait(0.1)
        end
        f.Wait(0.1)
    end
end

---Searches for an enemy by name, moves to it, engages, and waits for combat to end.
---@param enemyName string
---@param vbmPreset string
function f.SearchAndDestroy(enemyName, vbmPreset)
    local enemy = Entity.GetEntityByName(enemyName)
    local combatOffset = 20
    if enemy ~= nil and enemy.HealthPercent > 0 then
        if enemy.DistanceTo > 100 then
            return
        end

        -- f.Echo("Found " .. enemyName .. " alive and within range, flying to position " .. offset .. "y away")
        -- -- calculate and move to a position offset units away from the enemy towards the player
        -- local direction = Entity.Player.Position - enemy.Position -- vector pointing from huntMark to player
        -- direction = direction / direction:Length() -- normalize to length 1
        -- local newPosition = enemy.Position + direction * offset -- move offset units toward playerPos
        -- -- select ground spot to land on so the end point is not in the air
        -- local groundedPos = IPC.vnavmesh.PointOnFloor(newPosition, false, 1) -- 1-yard search radius
        -- if groundedPos then
        --     newPosition = groundedPos
        -- end
        -- IPC.vnavmesh.PathfindAndMoveTo(newPosition, Entity.Player.IsMounted)

        -- f.Echo("Waiting until we are close enough to position")
        -- f.WaitForVnavDistance(newPosition, 1)
        -- f.Echo(enemyName .. " is close enough, dismounting and activating preset")
        -- f.Dismount()
        -- yield("/vbm ar set " .. vbmPreset)
        -- enemy:SetAsTarget()
        -- f.Wait(5)
        -- f.WaitForOutOfCombat()
        -- yield("/vbm ar clear")

        f.Echo("Found " .. enemyName .. " alive and within range, engaging")
        yield("/vbm ar set " .. vbmPreset)
        enemy = Entity.GetEntityByName(enemyName)
        f.MoveWithInDistanceTo(enemy.Position, combatOffset)
        enemy:SetAsTarget()
        f.Dismount()
        f.WaitForCombat()
        f.WaitForOutOfCombat()
        yield("/vbm ar clear")
    end
end

---Searches for an enemy by name, moves hoverHeight yards above it, waits until its HP is below hpTreshold%, then engages.
---@param enemyName string
---@param vbmPreset string
function f.SearchAndDestroySRank(enemyName, vbmPreset)
    local enemy = Entity.GetEntityByName(enemyName)
    local hpTresholdPercent = 95
    local waitingPositionOffset = 50
    local combatOffset = 20
    if enemy ~= nil and enemy.HealthPercent > 0 then
        f.Echo("Found " .. enemyName)
        if enemy.HealthPercent > hpTresholdPercent then
            f.Echo(enemyName .. " is above " .. hpTresholdPercent .. "% HP, moving to waiting position")
            local direction = Entity.Player.Position - enemy.Position -- vector pointing from huntMark to player
            direction = direction / direction:Length() -- normalize to length 1
            local waitingPos = enemy.Position + direction * waitingPositionOffset
            IPC.vnavmesh.PathfindAndMoveTo(waitingPos, Entity.Player.IsMounted)

            f.Echo("Clearing target and activating preset")
            Player.Entity:ClearTarget()
            yield("/vbm ar set " .. vbmPreset)

            f.Echo("Standing by and checking enemy HP periodically")
            repeat
                enemy = Entity.GetEntityByName(enemyName)
                f.Wait(0.1)
            until enemy and enemy.HealthPercent < hpTresholdPercent
        end

        f.Echo(enemyName .. "(" .. enemy.HealthPercent .. "%) is below " .. hpTresholdPercent .. "% HP, engaging")
        yield("/vbm ar set " .. vbmPreset)
        enemy = Entity.GetEntityByName(enemyName)
        enemy:SetAsTarget()
        f.MoveWithInDistanceTo(enemy.Position, combatOffset)
        f.Dismount()
        f.WaitForCombat()
        f.WaitForOutOfCombat()
        yield("/vbm ar clear")
    end
end

return f