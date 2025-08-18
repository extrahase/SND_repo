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

-- normalize spacing but keep line breaks
clipboard = clipboard:gsub("\r\n", "\n"):gsub("\r", "\n")
clipboard = clipboard:gsub(" +", " ")

-- World = first token before :smob:
local worldName = clipboard:match("(%S+)%s*:smob:")

-- Zone = line after :smob:, up to translations
local zoneName = clipboard:match(":smob:[^\n]*\n%s*([^\n%[%]［］]+)")
zoneName = zoneName:gsub("^[^%w%p]+", "") -- strip leading non-alphanum/punct
zoneName = zoneName:gsub("[^%w%p]+$", "") -- strip trailing non-alphanum/punct
zoneName = zoneName:match("^%s*(.-)%s*$") -- final trim for safety

-- map coordinates = number pair
local mapX, mapY = clipboard:match("([%d%.]+)%s*,%s*([%d%.]+)")

f.Echo("World: " .. (worldName or "nil"))
f.Echo("Zone: " .. (zoneName or "nil"))
f.Echo("X: " .. (mapX or "nil") .. ", Y: " .. (mapY or "nil"))
--#endregion

f.Echo("Moving to " .. worldName)
f.Lifestream(worldName)

f.Echo("Moving to " .. zoneName)


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