-- ############
-- ### DATA ###
-- ############

import("System.Numerics")
local huntLocations = require("huntLocations")
local huntMarks = require("huntMarks")
local zoneList = require("vac_lists").Zone_List

MOUNT_SPEED = 20.6
TP_DELAY = 7
VBM_PRESET = "A Ranks"
HUNT_RANK = "B"

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

function WaitForReady()
	while Player.IsBusy do
		Wait(0.1)
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

	local zoneName = FindZoneNameByTerritoryId(Svc.ClientState.TerritoryType)

	for _, mark in pairs(huntMarksByRank) do
		if mark.zone == zoneName then
			local huntMark = Entity.GetEntityByName(mark.name)
			if huntMark ~= nil then
				MountUp()
				IPC.vnavmesh.PathfindAndMoveTo(huntMark.Position, true)
				Echo("Distance: "..tostring(huntMark.DistanceTo))
				WaitForVnav()
				huntMark:SetAsTarget()
				Dismount()
				--WaitForCombat()
				WaitForOutOfCombat()
				yield("/vbm ar clear")
				Wait(10)
				huntMark = Entity.GetEntityByName(mark.name)
				if huntMark ~= nil then
					MountUp()
					IPC.vnavmesh.PathfindAndMoveTo(huntMark.Position, true)
					Echo("Distance: "..tostring(huntMark.DistanceTo))
					WaitForVnav()
					huntMark:SetAsTarget()
					Dismount()
					--WaitForCombat()
					WaitForOutOfCombat()
					yield("/vbm ar clear")
					Wait(10)
				end
			end
		end
	end
end

function FindZoneNameByTerritoryId(territoryId)
	territoryId = tostring(territoryId)
	for id, zone in pairs(zoneList) do
		if id == territoryId then
			return zone.Zone
		end
	end
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

function GetZoneHuntLocations(territoryId)
	for _, expansion in pairs(huntLocations) do
		for _, zone in ipairs(expansion) do
			if zone.mapId == territoryId then
				return zone.positions
			end
		end
	end
end

function ConvertToRealCoordinates(territoryId, x, y)
	local mapScale = 100
	if territoryId >= 397 and territoryId <= 402 then
	    mapScale = 95
	else
	    mapScale = 100
	end
	local newX = 50 * (x - 1 - (2048 / mapScale))
	local newY = 50 * (y - 1 - (2048 / mapScale))
	return territoryId, newX, newY
end

-- ############
-- ### MAIN ###
-- ############

Echo("Script started!")

huntMarksByRank = { }

for _, expansion in pairs(huntMarks) do
	if expansion.B then
		for _, mark in ipairs(expansion.B) do
			table.insert(huntMarksByRank, mark)
		end
	end
end

WaitForOutOfCombat()
yield("/vbm ar clear")
MountUp()

-- build list of flags for current zone
zoneHuntLocations = GetZoneHuntLocations(Svc.ClientState.TerritoryType)

-- loop through each flag, place it and start the hunt
while true do
	for _, position in ipairs(zoneHuntLocations) do
		if position[HUNT_RANK] == true then
			Instances.Map.Flag:SetFlagMapMarker(ConvertToRealCoordinates(Svc.ClientState.TerritoryType, position.x, position.y))
			FlyToFlag()
			SearchAndDestroy()
		end
	end
end

Echo("Script done!")