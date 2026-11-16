local scripts, events, messages = {}, {}, {}
local class, raid, groupSize, zone = "WARLOCK", false, 2, "Durotar"
local selectedIndex = 1
local targetName

CreateFrame = function()
    return {
        RegisterEvent = function(_, event) events[event] = true end,
        SetScript = function(_, name, handler) scripts[name] = handler end,
    }
end
UnitClass = function() return class, class end
UnitName = function(unit)
    if unit == "player" then return "Caster" end
    if unit == "party1" then return "Passenger" end
    if unit == "target" then return targetName end
end
GetNumGroupMembers = function() return groupSize end
IsInRaid = function() return raid end
GetZoneText = function() return zone end
SendChatMessage = function(message, channel)
    assert(channel == "PARTY")
    messages[#messages + 1] = message
end
print = function() error("Summon failures must not produce chat output") end
math.random = function(count)
    assert(count == 50)
    return selectedIndex
end

assert(loadfile("SummonAnnouncements.lua"))()
local function event(name, ...)
    scripts.OnEvent(nil, name, ...)
end
event("PLAYER_LOGIN")
assert(events.UNIT_SPELLCAST_SENT and events.UNIT_SPELLCAST_START
    and events.UNIT_SPELLCAST_CHANNEL_START and events.UNIT_SPELLCAST_CHANNEL_STOP)

local seen = {}
for index = 1, 50 do
    selectedIndex = index
    event("UNIT_SPELLCAST_SENT", "player", "Passenger", "cast" .. index, 698)
    event("UNIT_SPELLCAST_CHANNEL_START", "player", "cast" .. index, 698)
    local message = messages[#messages]
    assert(#messages == index and #message <= 255)
    assert(message:find("Passenger", 1, true))
    assert(message:find("Durotar", 1, true))
    local passengerAt = message:find("Passenger", 1, true)
    local zoneAt = message:find("Durotar", 1, true)
    assert((index == 3 and zoneAt < passengerAt) or (index ~= 3 and passengerAt < zoneAt))
    assert(not seen[message], "Duplicate summon announcement: " .. message)
    seen[message] = true
end

event("UNIT_SPELLCAST_SENT", "player", "party1", "unit-cast", 698)
event("UNIT_SPELLCAST_START", "player", "unit-cast", 698)
assert(messages[#messages]:find("Passenger", 1, true))
local count = #messages

-- A cast that also reports a channel start must not announce twice.
event("UNIT_SPELLCAST_CHANNEL_START", "player", "unit-cast", 698)
assert(#messages == count)

-- A channel may have a different cast ID from its send/start events.
event("UNIT_SPELLCAST_SENT", "player", "Passenger", "sent-id", 698)
event("UNIT_SPELLCAST_START", "player", "start-id", 698)
event("UNIT_SPELLCAST_CHANNEL_START", "player", "channel-id", 698)
assert(#messages == count + 1)
assert(messages[#messages]:find("Passenger", 1, true))
count = #messages

-- Resolve a unit token at send time, before the selected target can change.
event("UNIT_SPELLCAST_SENT", "player", "party1", "snapshot", 698)
local originalUnitName = UnitName
UnitName = function(unit)
    if unit == "party1" then return "Replacement" end
    return originalUnitName(unit)
end
event("UNIT_SPELLCAST_CHANNEL_START", "player", "snapshot", 698)
assert(#messages == count + 1)
assert(messages[#messages]:find("Passenger", 1, true))
UnitName = originalUnitName
count = #messages

-- An empty passenger or cast ID must not discard the selected passenger.
targetName = "Selected Passenger"
event("UNIT_SPELLCAST_SENT", "player", "", nil, 698)
targetName = "Different Target"
event("UNIT_SPELLCAST_CHANNEL_START", "player", "fallback", 698)
assert(#messages == count + 1)
assert(messages[#messages]:find("Selected Passenger", 1, true))
count = #messages

-- A channel can still be announced when its send event was not received.
event("UNIT_SPELLCAST_CHANNEL_STOP", "player", "fallback", 698)
event("UNIT_SPELLCAST_CHANNEL_START", "player", "without-sent", 698)
event("UNIT_SPELLCAST_CHANNEL_START", "player", "without-sent", 698)
assert(#messages == count + 1)
assert(messages[#messages]:find("Different Target", 1, true))
count = #messages
targetName = nil
event("UNIT_SPELLCAST_CHANNEL_STOP", "player", "without-sent", 698)

-- A missing target at cast start can become available at channel start.
event("UNIT_SPELLCAST_SENT", "player", "", "late-target", 698)
event("UNIT_SPELLCAST_START", "player", "late-target", 698)
assert(#messages == count)
targetName = "Late Passenger"
event("UNIT_SPELLCAST_CHANNEL_START", "player", "late-target", 698)
assert(#messages == count + 1)
assert(messages[#messages]:find("Late Passenger", 1, true))
count = #messages
targetName = nil

event("UNIT_SPELLCAST_SENT", "player", "Passenger", "other", 686)
event("UNIT_SPELLCAST_START", "player", "other", 686)
event("UNIT_SPELLCAST_SENT", "party1", "Passenger", "other-player", 698)
event("UNIT_SPELLCAST_START", "party1", "other-player", 698)
event("UNIT_SPELLCAST_CHANNEL_START", "party1", "other-player", 698)
assert(#messages == count)

event("UNIT_SPELLCAST_SENT", "player", "Passenger", "interrupted", 698)
event("UNIT_SPELLCAST_SENT", "player", "Someone Else", "different", 686)
event("UNIT_SPELLCAST_START", "player", "interrupted", 698)
assert(#messages == count)

event("UNIT_SPELLCAST_SENT", "player", "Passenger", "raid", 698)
raid = true
event("UNIT_SPELLCAST_START", "player", "raid", 698)
raid = false
groupSize = 1
event("UNIT_SPELLCAST_SENT", "player", "Passenger", "solo", 698)
event("UNIT_SPELLCAST_START", "player", "solo", 698)
groupSize = 2
assert(#messages == count)

zone = ""
event("UNIT_SPELLCAST_SENT", "player", "Passenger", "no-zone", 698)
event("UNIT_SPELLCAST_START", "player", "no-zone", 698)
assert(#messages == count)

class = "MAGE"
events, scripts = {}, {}
assert(loadfile("SummonAnnouncements.lua"))()
event("PLAYER_LOGIN")
assert(not events.UNIT_SPELLCAST_SENT and not events.UNIT_SPELLCAST_START
    and not events.UNIT_SPELLCAST_CHANNEL_START and not events.UNIT_SPELLCAST_CHANNEL_STOP)
event("UNIT_SPELLCAST_SENT", "player", "Passenger", "mage", 698)
event("UNIT_SPELLCAST_START", "player", "mage", 698)
event("UNIT_SPELLCAST_CHANNEL_START", "player", "mage", 698)
assert(#messages == count)
