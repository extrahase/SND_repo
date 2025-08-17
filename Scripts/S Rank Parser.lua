-- ############
-- ### DATA ###
-- ############

local f = require("functions")

HUNT_MARKS = require("huntMarks")
ZONE_LIST = require("vac_lists").Zone_List

HUNT_RANK = "S"
VBM_PRESET = "A Ranks"
MOUNT_SPEED = 20.6
TP_DELAY = 7

DEBUG = true

-- #################
-- ### FUNCTIONS ###
-- #################



-- ############
-- ### MAIN ###
-- ############

f.Echo("Starting script!")

f.Echo("Parsing clipboard for S Rank data")
local clipboard = System.GetClipboardText() or ""

-- remove emojis and weird spaces first, then remove spaces
clipboard = clipboard:gsub("[%z\1-\31\127\194-\244][\128-\191]*", "")
clipboard = clipboard:gsub("%s+", "")

-- World = first word before :smob:
local worldName = clipboard:match("(.-):smob:")
-- Aetheryte = after :aetheryte:
local aetheryteName = clipboard:match(":aetheryte:%s*([^%d,]+)")
-- coords = last number pair
local mapX, mapY = clipboard:match("([%d%.]+)%s*,%s*([%d%.]+)")
f.Echo("World: " .. (worldName or "nil") .. ", Aetheryte: " .. (aetheryteName or "nil") .. ", Coords: (" .. (mapX or "nil") .. ", " .. (mapY or "nil") .. ")")

f.Echo("Moving to " .. worldName .. ", " .. aetheryteName)
f.Lifestream(worldName .. ", tp " .. aetheryteName)

f.Echo("Moving to coordinates (" .. mapX .. ", " .. mapY .. ")")
yield("/snd run Fly to Flag")

f.Echo("Constructing table with Hunt Marks for current zone")
local zoneName = f.FindZoneNameByTerritoryId(Svc.ClientState.TerritoryType)
local huntMarks = { }
for _, expansion in pairs(HUNT_MARKS) do
    if expansion[HUNT_RANK] then
        for _, mark in ipairs(expansion[HUNT_RANK]) do
            if mark.zone == zoneName or mark.zone == "all" then
                f.Echo("Adding " .. mark.name .. " to hunt marks")
                table.insert(huntMarks, mark.name)
            end
        end
    end
end

f.Echo("Searching for " .. HUNT_RANK .. " Ranks")
f.WaitForVnavBusy()
while IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() do
    for _, huntMarkName in pairs(huntMarks) do
        f.SearchAndDestroySRank(huntMarkName, VBM_PRESET)
    end
    f.Wait(0.1)
end

f.Echo("Script done!")