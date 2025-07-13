import("System.Numerics")
local zoneList = require("vac_lists").Zone_List

MOUNT_SPEED = 20.6
TP_DELAY = 7

function Echo(message)
	yield("/echo "..tostring(message))
end

function Wait(number)
	yield("/wait "..number)
end

function WaitForReady()
	while Player.IsBusy do
		Wait(0.1)
	end
end

function WaitForOutOfCombat()
	while Player.Entity.IsInCombat do
		Wait(0.1)
	end
end

function WaitForVnav()
	while IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() do
		Wait(0.1)
	end
end

function MountUp()
	if not Svc.Condition[4] and Player.CanMount then
		WaitForOutOfCombat()
		WaitForReady()
		yield("/gaction \"Mount Roulette\"")
		Wait(1)
	end
end

function FlyToFlag()
	MountUp()
	yield("/vnav flyflag")
	WaitForVnav()
end

function Dismount()
	while Svc.Condition[4] do
		yield('/gaction "Mount Roulette"')
		Wait(1)
	end
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

local etaTp, closestAetheryteId = CalculateEtaTp3()
local etaFlight = CalculateEtaFlight3()

if Instances.Map.Flag.TerritoryId ~= Svc.ClientState.TerritoryType then
	Actions.Teleport(closestAetheryteId)
end

if etaTp <= etaFlight then
	WaitForReady()
	Actions.Teleport(closestAetheryteId)
	Wait(5)
else
	Echo("Flight is better")
end

FlyToFlag()
Dismount()