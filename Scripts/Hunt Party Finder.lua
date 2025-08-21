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

f.Echo("Starting script!")

f.Echo("Making sure we are party-less")
f.LeaveParty()

f.Echo("Opening Party Finder")
f.CloseAddon("LookingForGroup")
yield("/send OEM_3")
f.WaitForAddon("LookingForGroup")

f.Echo("Joining existing listing")
f.Callback2("LookingForGroup", 20, 0) -- navigates to Data Center tab
f.Callback2("LookingForGroup", 21, 11) -- navigates to The Hunt tab
f.Echo("Starting loop to enter existing listings")
for i = 0, 3 do
    f.Callback3("LookingForGroup", 11, i, 0) -- clicks on next listing
    for k = 1, 10 do
        if not Addons.GetAddon("LookingForGroupDetail").Ready then
            f.Wait(0.1)
        else
            f.Wait(1)
            f.SelectListOption("LookingForGroupDetail", 0) -- clicks Join Party
            f.SelectYes("SelectYesno")
        end
    end
end

f.Echo("Creating new listing")
f.Callback2("LookingForGroup", 20, 0) -- navigates to Data Center tab
f.Callback2("LookingForGroup", 21, 11) -- navigates to The Hunt tab
f.SelectListOption("LookingForGroup", 14) -- clicks on Recruit Members
f.WaitForAddon("LookingForGroupCondition")
f.Callback2("LookingForGroupCondition", 12, 11) -- selects The Hunt as Duty
f.Callback2("LookingForGroupCondition", 32, 1) -- selects Remove role restrictions for all remaining openings.
f.SelectListOption("LookingForGroupCondition", 0) -- clicks Recruit Members
f.CloseAddon("LookingForGroupCondition")
f.CloseAddon("LookingForGroup")

f.Echo("Script done!")