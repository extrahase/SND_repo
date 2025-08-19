-- ############
-- ### DATA ###
-- ############

local f = require("functions")

HUNT_MARKS = require("huntMarks")
ZONE_LIST = require("vac_lists").Zone_List

VBM_PRESET = "A Ranks"
MOUNT_SPEED = 20
RUN_SPEED = 6
TP_DELAY = 11

DEBUG = true

-- ############
-- ### MAIN ###
-- ############

f.Echo("Starting script!")

f.Echo("Waiting until out of combat")
f.WaitForOutOfCombat()

f.Echo("Out of combat, clearing VBM")
yield("/vbm ar clear")

f.Echo("Checking if flag is in different zone or same zone")
if Instances.Map.Flag.TerritoryId ~= Svc.ClientState.TerritoryType then
    f.Echo("Flag in different zone --> waiting for HTA to change zones")
    f.WaitForZone(Instances.Map.Flag.TerritoryId)
    f.WaitForInstance(1)
else
    f.Echo("Flag in same zone --> checking for instance switching")
    local numberOfInstances = IPC.Lifestream.GetNumberOfInstances()
    if numberOfInstances ~= 0 then
        f.Echo("Zone has instances, checking current instance")
        local currentInstance = IPC.Lifestream.GetCurrentInstance()
        if currentInstance == numberOfInstances then
            f.Echo("Already in the last instance, no need to wait")
        else
            f.Echo("Possible HTA instance switching detected, waiting 2s")
            f.Wait(2)
            if Player.IsBusy then
                f.Echo("Player is busy, HTA must be active, waiting for it to finish")
                f.WaitForInstance(currentInstance + 1)
            end
        end
    end
end

f.Echo("We arrived in the right zone and instance, continuing with TP/flight check")
local etaTp, closestAetheryteId = f.CalculateEtaTp3()
local etaFlight = f.CalculateEtaFlight3()
if etaTp <= etaFlight then
    if closestAetheryteId ~= 148 and closestAetheryteId ~= 173 and closestAetheryteId ~= 175 then
    f.TpToAetheryte(closestAetheryteId)
    end
end

f.Echo("Constructing table with A and S Hunt Marks for current zone")
local zoneName = f.FindZoneNameByTerritoryId(Svc.ClientState.TerritoryType)
local huntMarks = { }
for _, expansion in pairs(HUNT_MARKS) do
    if expansion["A"] then
        for _, mark in ipairs(expansion["A"]) do
            if mark.zone == zoneName then
                f.Echo("Adding " .. mark.name .. " to hunt marks")
                table.insert(huntMarks, mark.name)
            end
        end
    elseif expansion["S"] then
        for _, mark in ipairs(expansion["S"]) do
            if mark.zone == zoneName then
                f.Echo("Adding " .. mark.name .. " to hunt marks")
                table.insert(huntMarks, mark.name)
                f.Echo("Adding " .. expansion["S"][7].name .. " to hunt marks")
                table.insert(huntMarks, expansion["S"][7].name)
            end
        end
    end
end


-- f.Echo("Constructing table with Hunt Marks for current zone")
-- local huntMarks = { }
-- for _, expansion in pairs(HUNT_MARKS) do
--     if expansion["S"] then
--         for _, mark in ipairs(expansion["S"]) do
--             if mark.zone == zoneName then
--                 f.Echo("Adding " .. mark.name .. " to hunt marks")
--                 table.insert(huntMarks, mark.name)
--                 f.Echo("Adding " .. expansion["S"][7].name .. " to hunt marks")
--                 table.insert(huntMarks, expansion["S"][7].name)
--             end
--         end
--     end
-- end


f.Echo("Searching for Hunt Marks")
f.FlyAndDestroyToFlag(huntMarks, VBM_PRESET)
f.Wait(0.5) -- to make it appear less bot-like
f.MountUp()
f.FlyToCoordinates(Player.Entity.Position.X, Player.Entity.Position.Y + 20, Player.Entity.Position.Z)

f.Echo("Script done!")