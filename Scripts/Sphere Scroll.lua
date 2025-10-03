-- ############
-- ### DATA ###
-- ############

local f = require("functions")

DEBUG = false

-- #################
-- ### FUNCTIONS ###
-- #################

-- ############
-- ### MAIN ###
-- ############

f.Echo("Starting script!")

local callbackFirst = nil
local callbackSecond = nil

f.Echo("Determining which materia I have the most of")
if Inventory.GetItemCount(5674) >= Inventory.GetItemCount(5719)
then
    f.Echo("Using Savage Might first")
    callbackFirst = 16
    callbackSecond = 20
else
    f.Echo("Using Quicktongue first")
    callbackFirst = 20
    callbackSecond = 16
end

f.Echo("Starting materia infusion loop")
for i = callbackFirst, callbackFirst + 4 do
    for k = 1, 15 do
        yield("/send KEY_1")
        f.Callback2("RelicSphereScroll", 0, i)
        f.Callback1("RelicSphereScroll", 2)
        f.WaitForAddonClose("RelicSphereScroll")
        f.Wait(2)
    end
end

for i = callbackSecond, callbackSecond + 4 do
    for k = 1, 15 do
        yield("/send KEY_1")
        f.Callback2("RelicSphereScroll", 0, i)
        f.Callback1("RelicSphereScroll", 2)
        f.WaitForAddonClose("RelicSphereScroll")
        f.Wait(2)
    end
end

f.Echo("Script done!")