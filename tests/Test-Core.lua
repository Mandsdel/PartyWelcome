local eventHandler
local inRaid, groupSize = false, 1
local identities, messages = {}, 0
local raidReads = 0

CreateFrame = function()
    return {
        RegisterEvent = function() end,
        UnregisterEvent = function() end,
        SetScript = function(_, _, handler) eventHandler = handler end,
    }
end
GetNumGroupMembers = function() return groupSize end
IsInRaid = function() return inRaid end
UnitGUID = function(unit)
    if unit:match("^raid") then raidReads = raidReads + 1 end
    return unit == "player" and "player" or identities[unit]
end
UnitIsUnit = function() return false end
SendChatMessage = function(message, channel)
    assert(message == "Hey, welcome friend" and channel == "PARTY")
    messages = messages + 1
end

assert(loadfile("Core.lua"))()
eventHandler(nil, "ADDON_LOADED", "PartyWelcome")
eventHandler(nil, "PLAYER_LOGIN")
eventHandler(nil, "PLAYER_ENTERING_WORLD")
groupSize, identities.party1 = 2, "one"
eventHandler(nil, "GROUP_ROSTER_UPDATE")
eventHandler(nil, "GROUP_ROSTER_UPDATE")
assert(messages == 1)
inRaid, groupSize = true, 20
eventHandler(nil, "GROUP_ROSTER_UPDATE")
assert(raidReads == 0 and messages == 1)
inRaid, groupSize, identities.party2 = false, 3, "two"
eventHandler(nil, "GROUP_ROSTER_UPDATE")
assert(messages == 1)
groupSize, identities.party3 = 4, "three"
eventHandler(nil, "GROUP_ROSTER_UPDATE")
assert(messages == 2)
PartyWelcomeDB.greeting = ""
groupSize, identities.party4 = 5, "four"
eventHandler(nil, "GROUP_ROSTER_UPDATE")
assert(messages == 2)
print("PartyWelcome core checks passed")
