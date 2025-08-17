-- ############
-- ### DATA ###
-- ############

local f = require("functions")

DEBUG = true

-- #################
-- ### FUNCTIONS ###
-- #################



-- ############
-- ### MAIN ###
-- ############

local text = System.GetClipboardText() or ""

-- normalize spacing (replace weird unicode spaces with normal ones)
text = text:gsub("[   ]", " "):gsub("%s+", " ")

-- extract world (after 🌎)
local world = text:match("🌎%s*([%a%-]+)")

-- extract aetheryte (after :aetheryte:)
local aetheryte = text:match(":aetheryte:%s*([%w' %-]+)")

-- extract coords (after 🚩)
local x, y = text:match("🚩%s*([%d%.]+)%s*,%s*([%d%.]+)")

-- safe defaults if missing
if not world then world = nil end
if not aetheryte then aetheryte = nil end
if not x or not y then x, y = nil, nil end

-- Output via f.Echo
if world then
    f.Echo("World: " .. world)
else
    f.Echo("World: N/A")
end

if aetheryte then
    f.Echo("Aetheryte: " .. aetheryte)
else
    f.Echo("Aetheryte: N/A")
end

if x and y then
    f.Echo(string.format("Coords: %s, %s", x, y))
else
    f.Echo("Coords: N/A")
end