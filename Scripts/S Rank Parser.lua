-- ############
-- ### DATA ###
-- ############

local f = require("functions")

HUNT_MARKS = require("huntMarks")
ZONE_LIST = require("vac_lists").Zone_List

HUNT_RANK = "S"
VBM_PRESET = "A Ranks"
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

-- 0) Normalize line breaks early (keep one line for simple matching)
clipboard = clipboard:gsub("\r\n", "\n"):gsub("\r", "\n")

-- 1) Remove bracketed localizations BEFORE nuking non-ASCII
-- ASCII brackets:
clipboard = clipboard:gsub("%b[]", "")
-- Full-width brackets ［ … ］ (U+FF3B/U+FF3D) by UTF-8 bytes:
local LB = string.char(0xEF, 0xBC, 0xBB) -- '［'
local RB = string.char(0xEF, 0xBC, 0xBD) -- '］'
clipboard = clipboard:gsub(LB .. ".-" .. RB, "")

-- 2) Strip non-ASCII (emojis, arrows, accents) – safe for SND editor
clipboard = clipboard:gsub("[%z\1-\31\127\194-\244][\128-\191]*", "")

-- 3) Normalize whitespace
clipboard = clipboard:gsub("[\n]+", " "):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")

-- 4) Extract fields
-- World = token before :smob:
local worldName = clipboard:match("([%w%-%']+)%s*:smob:")

-- Aetheryte = text after :aetheryte: up to coords; trim it
local aetheryteName
do
  local startA, endA = clipboard:find(":aetheryte:%s*")
  if startA then
    -- From end of ':aetheryte:' up to the start of the coordinate pair
    local cStart = clipboard:find("%d+%.%d+%s*,%s*%d+%.%d+")
    local segment = clipboard:sub(endA + 1, (cStart or (#clipboard + 1)) - 1)
    -- extra safety: collapse spaces, trim
    segment = (segment:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", ""))
    aetheryteName = (#segment > 0) and segment or nil
  end
end

-- Coords = last number pair
local mapX, mapY = clipboard:match("([%d%.]+)%s*,%s*([%d%.]+)")

f.Echo("World: " .. (worldName or "nil"))
f.Echo("Aetheryte: " .. (aetheryteName or "nil"))
f.Echo("Map coordinates: " .. (mapX or "nil") .. ", " .. (mapY or "nil"))
--#endregion

f.Echo("Moving to " .. worldName .. ", " .. aetheryteName)
f.Lifestream(worldName .. ", tp " .. aetheryteName)

f.Echo("Moving to map coordinates (" .. mapX .. ", " .. mapY .. ")")
Instances.Map.Flag:SetFlagMapMarker(f.ConvertToRealCoordinates(Svc.ClientState.TerritoryType, mapX, mapY))

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