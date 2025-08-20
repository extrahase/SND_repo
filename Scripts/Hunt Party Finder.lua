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
-- WIP!

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