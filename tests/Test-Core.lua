local scripts = {}
local inRaid, groupSize = false, 1
local identities, messages = {}, {}
local raidReads = 0
local playerClass = "WARRIOR"
local memberClasses = { party1 = "HUNTER", party2 = "MAGE", party3 = "ROGUE", party4 = "DRUID" }
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
UnitClass = function(unit)
    local class = unit == "player" and playerClass or memberClasses[unit]
    return class, class
end
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
    assert(count == 150 or count == 17)
    assert(randomIndex <= count)
    return randomIndex
end

assert(loadfile("ExtraGreetings.lua"))()
assert(loadfile("Hallos.lua"))()
assert(loadfile("WelcomeGreetings.lua"))()

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
assert(messages[1] == PartyWelcomeHallos.WARRIOR[1])

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

-- Hi messages remain unchanged; welcomes cover every ordered class pair.
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
    for _, joiningClass in ipairs(classes) do
        memberClasses.party4 = joiningClass
        local choices = PartyWelcomePairGreetings[class][joiningClass]
        assert(#choices == 17, class .. " / " .. joiningClass .. " should have 17 welcomes")
        for index = 1, #choices do
            currentTime = currentTime + 10
            randomIndex = index
            groupSize, identities.party4 = 5, class .. joiningClass .. index
            event("GROUP_ROSTER_UPDATE")
            tick(2)
            local message = messages[#messages]
            assert(message == choices[index], "Wrong welcome for " .. class .. " / " .. joiningClass)
            assert(#message <= 255, "Welcome exceeds the chat limit: " .. message)
            assert(not allGreetings[message], "Duplicate greeting: " .. message)
            allGreetings[message] = true
            groupSize, identities.party4 = 4, nil
            event("GROUP_ROSTER_UPDATE")
        end
    end
end
assert(#messages == 1379)

-- Simultaneous joins keep independent timers, but the cooldown allows one message.
currentTime = currentTime + 10
randomIndex = 1
groupSize, identities.party3 = 3, nil
event("GROUP_ROSTER_UPDATE")
groupSize, identities.party3 = 4, "new-three"
event("GROUP_ROSTER_UPDATE")
tick(1)
groupSize, identities.party4 = 5, "new-four"
event("GROUP_ROSTER_UPDATE")
tick(1)
assert(#messages == 1380)
assert(messages[#messages] == PartyWelcomePairGreetings.DRUID.ROGUE[1])
tick(1)
assert(#messages == 1380)
tick(1)
assert(#messages == 1380)

-- A queued member can move to another slot before the welcome is sent.
currentTime = currentTime + 10
groupSize, identities.party4 = 4, nil
event("GROUP_ROSTER_UPDATE")
groupSize, identities.party4, memberClasses.party4 = 5, "moving", "MAGE"
event("GROUP_ROSTER_UPDATE")
identities.party3, identities.party4 = "moving", "new-three"
memberClasses.party3, memberClasses.party4 = "MAGE", "ROGUE"
event("GROUP_ROSTER_UPDATE")
tick(2)
assert(messages[#messages] == PartyWelcomePairGreetings.DRUID.MAGE[1])

-- A missing joining class is reported and uses the existing general welcome.
currentTime = currentTime + 10
groupSize, identities.party3 = 4, nil
identities.party3, identities.party4 = "new-three", nil
memberClasses.party3 = "ROGUE"
event("GROUP_ROSTER_UPDATE")
groupSize, identities.party4, memberClasses.party4 = 5, "unknown", nil
event("GROUP_ROSTER_UPDATE")
local originalPrint, notice = print, nil
print = function(message) notice = message end
tick(2)
print = originalPrint
assert(notice and notice:find("class is unavailable", 1, true))
assert(messages[#messages] ~= PartyWelcomePairGreetings.DRUID.MAGE[1])
assert(#messages == 1382)

print("PartyWelcome core checks passed")
