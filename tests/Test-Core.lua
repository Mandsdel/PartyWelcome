local scripts = {}
local inRaid, groupSize = false, 1
local identities, messages = {}, {}
local raidReads = 0
local playerClass = "WARRIOR"
local randomIndex = 1

CreateFrame = function()
    return {
        RegisterEvent = function() end,
        SetScript = function(_, name, handler) scripts[name] = handler end,
    }
end
GetNumGroupMembers = function() return groupSize end
IsInRaid = function() return inRaid end
UnitClass = function() return playerClass, playerClass end
UnitGUID = function(unit)
    if unit:match("^raid") then raidReads = raidReads + 1 end
    return unit == "player" and "player" or identities[unit]
end
UnitIsUnit = function() return false end
SendChatMessage = function(message, channel)
    assert(type(message) == "string" and channel == "PARTY")
    messages[#messages + 1] = message
end
math.random = function(count)
    assert(count == 50)
    return randomIndex
end

local function event(name)
    scripts.OnEvent(nil, name)
end

local function tick(elapsed)
    if scripts.OnUpdate then scripts.OnUpdate(nil, elapsed) end
end

assert(loadfile("Core.lua"))()
event("PLAYER_LOGIN")
event("PLAYER_ENTERING_WORLD")
groupSize, identities.party1 = 2, "one"
event("GROUP_ROSTER_UPDATE")
event("GROUP_ROSTER_UPDATE")
tick(1.5)
assert(#messages == 0)
tick(0.5)
assert(#messages == 1 and not scripts.OnUpdate)

-- A departure cancels the queued greeting, even if the same member rejoins.
groupSize, identities.party2 = 3, "two"
event("GROUP_ROSTER_UPDATE")
tick(1)
groupSize, identities.party2 = 2, nil
event("GROUP_ROSTER_UPDATE")
groupSize, identities.party2 = 3, "two"
event("GROUP_ROSTER_UPDATE")
tick(1)
assert(#messages == 1)
tick(1)
assert(#messages == 2)

groupSize, identities.party3 = 4, "three"
event("GROUP_ROSTER_UPDATE")
inRaid, groupSize = true, 20
event("GROUP_ROSTER_UPDATE")
tick(2)
assert(raidReads == 0 and #messages == 2 and not scripts.OnUpdate)
inRaid, groupSize = false, 4
event("GROUP_ROSTER_UPDATE")
tick(2)
assert(#messages == 2)

-- Each class has 50 different choices, selected using the player's class.
local classes = {
    "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST",
    "SHAMAN", "MAGE", "WARLOCK", "DRUID",
}
local allGreetings = {}
for _, class in ipairs(classes) do
    playerClass = class
    for index = 1, 50 do
        randomIndex = index
        groupSize, identities.party4 = 5, class .. index
        event("GROUP_ROSTER_UPDATE")
        tick(2)
        local message = messages[#messages]
        assert(not allGreetings[message], "Duplicate greeting: " .. message)
        allGreetings[message] = true
        groupSize, identities.party4 = 4, nil
        event("GROUP_ROSTER_UPDATE")
    end
end
assert(#messages == 452)

-- Simultaneous joins have independent timers and each receive a greeting.
groupSize, identities.party3 = 3, nil
event("GROUP_ROSTER_UPDATE")
groupSize, identities.party3 = 4, "new-three"
event("GROUP_ROSTER_UPDATE")
tick(1)
groupSize, identities.party4 = 5, "new-four"
event("GROUP_ROSTER_UPDATE")
tick(1)
assert(#messages == 453)
tick(1)
assert(#messages == 454)

print("PartyWelcome core checks passed")
