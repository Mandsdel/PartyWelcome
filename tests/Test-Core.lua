local scripts = {}
local inRaid, groupSize = false, 1
local identities, messages = {}, {}
local raidReads = 0
local playerClass = "WARRIOR"
local randomIndex = 1
local currentTime = 0

CreateFrame = function()
    return {
        RegisterEvent = function() end,
        SetScript = function(_, name, handler) scripts[name] = handler end,
    }
end
GetNumGroupMembers = function() return groupSize end
IsInRaid = function() return inRaid end
GetTime = function() return currentTime end
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
    assert(count == 150)
    return randomIndex
end

assert(loadfile("ExtraGreetings.lua"))()
assert(loadfile("Hallos.lua"))()

local function event(name)
    scripts.OnEvent(nil, name)
end

local function tick(elapsed)
    currentTime = currentTime + elapsed
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
currentTime = currentTime + 7
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

-- Each class has 150 different choices, selected using the player's class.
local classes = {
    "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST",
    "SHAMAN", "MAGE", "WARLOCK", "DRUID",
}
local allGreetings = {}
local allHallos = {}
for _, class in ipairs(classes) do
    assert(#PartyWelcomeHallos[class] == 150, class .. " should have 150 hi messages")
    for _, message in ipairs(PartyWelcomeHallos[class]) do
        assert(not message:lower():find("hallo", 1, true), "Non-English greeting: " .. message)
        assert(not message:lower():find("zusammen", 1, true), "Non-English greeting: " .. message)
        assert(not allHallos[message], "Duplicate hi message: " .. message)
        allHallos[message] = true
    end

    playerClass = class
    for index = 1, 150 do
        currentTime = currentTime + 10
        randomIndex = index
        groupSize, identities.party4 = 5, class .. index
        event("GROUP_ROSTER_UPDATE")
        tick(2)
        local message = messages[#messages]
        assert(not message:lower():find("hallo", 1, true), "Non-English greeting: " .. message)
        assert(not message:lower():find("zusammen", 1, true), "Non-English greeting: " .. message)
        assert(not allGreetings[message], "Duplicate greeting: " .. message)
        allGreetings[message] = true
        groupSize, identities.party4 = 4, nil
        event("GROUP_ROSTER_UPDATE")
    end
end
assert(#messages == 1352)

-- Simultaneous joins keep independent timers, but the cooldown allows one message.
currentTime = currentTime + 10
groupSize, identities.party3 = 3, nil
event("GROUP_ROSTER_UPDATE")
groupSize, identities.party3 = 4, "new-three"
event("GROUP_ROSTER_UPDATE")
tick(1)
groupSize, identities.party4 = 5, "new-four"
event("GROUP_ROSTER_UPDATE")
tick(1)
assert(#messages == 1353)
tick(1)
assert(#messages == 1353)
tick(1)
assert(#messages == 1353)

print("PartyWelcome core checks passed")
