-- ###############
-- ### OUTLINE ###
-- ###############

--[[
How a Hunt Train works:
	1. read train announcement (from Discord, HuntAlerts catches most of these, very difficult to replicate)
	2. move to target world and Aetheryte (provided by HuntAlerts, otherwise /li and teleport is needed)
	3. set conductor (context menu on right click or pasting name into HTA)
	4. join/make PF listing (one-click button in HTA, manually otherwise)
	loop start
	5. shout by conductor, HTA sets flag
	6. if flag in different zone: HTA teleports to closest Aetheryte
	if instances exist for zone
		a) if not in instance 1: HTA switches to instance 1
		b) if two A marks killed: HTA teleports to Aetheryte (unsure which), switches to instance 2
	7. if flag in same zone, decide whether it's better to fly or tp and then fly
	8. fly to flag position
	9. [TODO] search and destroy hunt mark
	loop end

SND is started via a macro that is executed by HTA after receiving a conductor message with a flag payload.
Therefore, the macro needs to handle everything starting at step 6. without getting in HTA's way.
]] 

-- ############
-- ### DATA ###
-- ############

import("System.Numerics")
local huntLocations = require("huntLocations")
local zoneList = require("vac_lists").Zone_List

MOUNT_SPEED = 20.6
TP_DELAY = 7
VBM_PRESET = "A Ranks"

-- #################
-- ### FUNCTIONS ###
-- #################

function WaitForVnav()
	while IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() do
		Wait(0.1)
	end
end

function Echo(message)
	yield("/echo "..tostring(message))
end

function Wait(number)
	yield("/wait "..number)
end

function WaitForZoneAndReady()
	while Instances.Map.Flag.TerritoryId ~= Svc.ClientState.TerritoryType do
		Wait(0.1)
	end
	WaitForReady()
end

function WaitForReady()
	while Player.IsBusy do
		Wait(0.1)
	end
end

function CorrectFlagPosition()
end

function DistanceBetweenVectors(vectorA, vectorB)
	local distance = math.sqrt(
	(vectorB.X - vectorA.X)^2 +
	(vectorB.Y - vectorA.Y)^2 +
	(vectorB.Z - vectorA.Z)^2
	)
	return distance
end

function CalculateEtaFlight3()
	local playerPos = Player.Entity.Position
	local flagPos = Instances.Map.Flag.Vector3
	local distance = DistanceBetweenVectors(playerPos, flagPos)
	local eta = distance / MOUNT_SPEED
	return eta
end

function CalculateEtaTp3()
	local aetherytePos = GetAetherytesInFlagZone()
	local flagPos = Instances.Map.Flag.Vector3

    local shortestDistance = math.huge -- start with infinity
    local closestAetheryteId = nil

    for _, entry in ipairs(aetherytePos) do
        local pos = entry.position
        local id = entry.id

        local distance = DistanceBetweenVectors(flagPos, pos)

        if distance < shortestDistance then
            shortestDistance = distance
            closestAetheryteId = id
        end
    end

	local distance = shortestDistance
	local eta = (distance / MOUNT_SPEED) + TP_DELAY

	return eta, closestAetheryteId
end

function GetAetherytesInFlagZone()
	-- get zone from map flag
	local flagZoneId = Instances.Map.Flag.TerritoryId
	-- find all Aetherytes in zone and store position in aetheryteIds
	local flagZone = zoneList[tostring(flagZoneId)]
	local aetherytePos = {}

	if flagZone and flagZone.Aetherytes then
	    for _, aetheryte in ipairs(flagZone.Aetherytes) do
	        -- convert ID to number if needed
	        local aetheryteId = tonumber(aetheryte.ID)
	        if aetheryteId then
	            -- get Vector3 position
	            local pos = Instances.Telepo:GetAetherytePosition(aetheryteId)
	            if pos then
			        -- store both ID and position
			        table.insert(aetherytePos, {
			            id = aetheryteId,
			            position = pos
			        })
	            end
	        end
	    end
	end

	return(aetherytePos)
end

function FlyToFlag()
	MountUp()
	yield("/vnav flyflag")
	WaitForVnav()
end

function MountUp()
	if not Svc.Condition[4] and Player.CanMount then
		WaitForOutOfCombat()
		WaitForReady()
		yield('/gaction "Mount Roulette"')
		Wait(1)
	end
end

function Dismount()
	while Svc.Condition[4] do
		yield('/gaction "Mount Roulette"')
		Wait(1)
	end
end

function SearchAndDestroy()
	yield("/vbm ar clear")
	yield("/vbm ar set "..VBM_PRESET)
	yield("/targetenemy")
	Dismount()
	WaitForCombat()
	WaitForOutOfCombat()
	yield("/vbm ar clear")
end

function WaitForCombat()
	while not Player.Entity.IsInCombat do
		Wait(0.1)
	end
end

function WaitForOutOfCombat()
	while Player.Entity.IsInCombat do
		Wait(0.1)
	end
end

-- ############
-- ### MAIN ###
-- ############

WaitForOutOfCombat()
yield("/vbm ar clear")
MountUp()

-- waits for HTA to do its thing depending on if the flag is in a new zone or not
if Instances.Map.Flag.TerritoryId ~= Svc.ClientState.TerritoryType then
	-- flag is in different zone
	Echo("Waiting for HTA to change zones")
	WaitForZoneAndReady()

	-- account for switching instances
	if IPC.Lifestream.GetCurrentInstance() ~= 0 then
		while IPC.Lifestream.GetCurrentInstance() ~= 1 do
			Echo("Waiting for HTA to change instances")
			Wait(1)
		end
	end
else -- flag is in same zone
	if IPC.Lifestream.GetCurrentInstance() ~= 0 then -- account for switching instances
		-- just wait for now if instances are detected
		-- need to know more about how HTA handles this
		-- IPC.Lifestream.GetNumberOfInstances() also doesn't work atm
		Echo("Possible HTA instance switching detected, waiting 10s")
		Wait(10)
	end
end

CorrectFlagPosition()

-- determines if (flying) or (teleporting, then flying) is better and starts travel
local etaTp, closestAetheryteId = CalculateEtaTp3()
local etaFlight = CalculateEtaFlight3()

if etaTp <= etaFlight then
	WaitForReady()
	Actions.Teleport(closestAetheryteId)
	Wait(5)
else
	Echo("Flight is better")
end

WaitForReady()
FlyToFlag()
SearchAndDestroy()
MountUp()

Echo("Script done!")