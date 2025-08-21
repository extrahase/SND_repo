-- ############
-- ### DATA ###
-- ############

local f = require("functions")

HUNT_MARKS = require("huntMarks")
ZONE_LIST = require("vac_lists").Zone_List
WORLD_ID_LIST = require("vac_lists").World_ID_List

HUNT_RANK = "S"
VBM_PRESET = "A Ranks"
FREE_DESTINATION = "New Gridania"
MOUNT_SPEED = 20
RUN_SPEED = 6
TP_DELAY = 11

DEBUG = true

-- #################
-- ### FUNCTIONS ###
-- #################

-- ############
-- ### MAIN ###
-- ############

f.Echo("Starting script!")

--#region Data Extraction
f.Echo("Parsing clipboard for S Rank data")
local clipboard = System.GetClipboardText() or ""

-- normalize spacing but keep line breaks
clipboard = clipboard:gsub("\r\n", "\n"):gsub("\r", "\n")
clipboard = clipboard:gsub(" +", " ")

-- World = first token before :smob:
local worldName = clipboard:match("(%S+)%s*:smob:")

-- Instance = optional number after mob name (before translations)
local smob = clipboard:match(":smob:%s*([^\n%[%]［］]+)")
local targetInstance = 0
if smob then
    targetInstance = tonumber(smob:match("(%d+)[^%d]*$")) or 0
end

-- Zone = line after :smob:, up to translations
local zoneName = clipboard:match(":smob:[^\n]*\n%s*([^\n%[%]［］]+)")
zoneName = zoneName:gsub("^[^%w%p]+", "") -- strip leading non-alphanum/punct
zoneName = zoneName:gsub("[^%w%p]+$", "") -- strip trailing non-alphanum/punct
zoneName = zoneName:match("^%s*(.-)%s*$") -- final trim for safety

-- Aetheryte = ASCII name after :aetheryte:, ignoring exotic spaces/emojis
local aetheryteName = clipboard:match(":aetheryte:([^\n]*)")
-- skip any ASCII spaces or non-ASCII bytes
aetheryteName = aetheryteName:match("^[%s\128-\255]*([%w%p ]+)")
-- grab the ASCII name chunk
aetheryteName = aetheryteName:gsub("%s+", " "):match("^%s*(.-)%s*$")

-- map coordinates = number pair
local mapX, mapY = clipboard:match("([%d%.]+)%s*,%s*([%d%.]+)")

-- output
f.Echo("World: " .. (worldName or "nil"))
f.Echo("Zone: " .. (zoneName or "nil"))
f.Echo("Aetheryte: " .. (aetheryteName or "nil"))
f.Echo("Instance: " .. targetInstance)
f.Echo("X: " .. (mapX or "nil") .. ", Y: " .. (mapY or "nil"))
--#endregion

--#region World/Zone/Instance Checks

local targetTerritoryId = f.FindTerritoryIdByZoneName(zoneName) or 0
local targetWorldId = f.FindWorldIdByWorldName(worldName) or 0

f.Echo("Initiating world check")
if Entity.Player.CurrentWorld ~= targetWorldId then
    f.Echo("Travelling to " .. worldName)
    f.Lifestream(worldName)
    f.WaitForWorld(targetWorldId)
else
    f.Echo("Already in " .. worldName .. ", moving on")
end

f.Echo("Initiating zone check")
if Svc.ClientState.TerritoryType ~= targetTerritoryId then
    f.Echo("Teleporting to " .. aetheryteName)
    f.Lifestream("tp " .. aetheryteName)
    f.WaitForZone(targetTerritoryId)
else
    f.Echo("Already in " .. zoneName .. ", moving on")
end

f.Echo("Initiating instance check")
local instance = IPC.Lifestream.GetCurrentInstance()
if instance == 0 then
    f.Echo("No instances detected, moving on")
elseif instance == targetInstance then
    f.Echo("Already in correct instance, moving on")
else
    f.Echo("Changing to instance " .. targetInstance)
    f.ChangeInstance(targetInstance, aetheryteName)
end
--#endregion

f.Echo("Moving to map coordinates (" .. mapX .. ", " .. mapY .. ")")
Instances.Map.Flag:SetFlagMapMarker(f.ConvertToRealCoordinates(targetTerritoryId, mapX, mapY))
f.MountUp()
yield("/vnav flyflag")
f.WaitForVnavBusy()

f.Echo("Running Hunt Party Finder")
yield("/snd run Hunt Party Finder")

f.Echo("Constructing table with Hunt Marks for current zone")
local huntMarks = { }
for _, expansion in pairs(HUNT_MARKS) do
    if expansion[HUNT_RANK] then
        for _, mark in ipairs(expansion[HUNT_RANK]) do
            if mark.zone == zoneName then
                f.Echo("Adding " .. mark.name .. " to hunt marks")
                table.insert(huntMarks, mark.name)
                f.Echo("Adding " .. expansion["S"][7].name .. " to hunt marks")
                table.insert(huntMarks, expansion["S"][7].name)
            end
        end
    end
end

f.Echo("Searching for " .. HUNT_RANK .. " Ranks")
while IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() do
    for _, huntMarkName in pairs(huntMarks) do
        f.SearchAndDestroySRank(huntMarkName, VBM_PRESET)
    end
    f.Wait(0.1)
end

-- f.Error("Warning: leaving/disbanding party and teleporting in 10s")
-- f.Wait(10)
-- f.Lifestream("tp " .. FREE_DESTINATION)
-- f.LeaveParty()

f.Echo("Script done!")