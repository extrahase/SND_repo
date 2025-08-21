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

-- f.Echo("Making sure we are party-less")
-- f.LeaveParty()

f.Echo("Checking if already in a party")
if Svc.Party.Length == 0 then
    f.Echo("Not in a party, moving on")
else
    f.Echo("Already in a party, stopping script")
    return
end

f.Echo("Opening Party Finder")
f.CloseAddon("LookingForGroup")
yield("/send OEM_3")
f.WaitForAddon("LookingForGroup")

f.Echo("Trying to join existing listing")
f.Callback2("LookingForGroup", 20, 0) -- navigates to Data Center tab
f.Callback2("LookingForGroup", 21, 11) -- navigates to The Hunt tab
f.Echo("Starting loop to enter existing listings")
for run = 1, 2 do
    for listingIndex = 0, 2 do
        f.Callback3("LookingForGroup", 11, listingIndex, 0) -- clicks on next listing
        f.WaitForAddon("LookingForGroupDetail")
        f.Wait(1) -- needed for Worlds with high ping
        if Addons.GetAddon("LookingForGroupDetail"):GetAtkValue(15).ValueString == "The Hunt" then
            f.Echo("Found a listing for The Hunt, joining")
            f.SelectListOption("LookingForGroupDetail", 0) -- clicks Join Party
            f.SelectYes("SelectYesno")
            f.Wait(1) -- needed for the party join to be completed before the next check
        else
            f.Echo("Listing is not for The Hunt, going to next one")
        end
        f.CloseAddon("LookingForGroupDetail")
        if Svc.Party.Length ~= 0 then
            f.Echo("Joined a party, stopping script")
            return
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