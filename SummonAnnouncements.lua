local RITUAL_OF_SUMMONING = 698
local frame = CreateFrame("Frame")
local pendingTarget
local summonAnnounced = false
local enabled = false

local announcements = {
    "%s, your portal to %s is opening. Mind the whispers on your way through!",
    "%s, the summoning circle is ready! Step through the shadows and meet us in %s.",
    "A portal to %s is opening for %s. Please keep all limbs inside the ritual at all times.",
    "%s, your shortcut to %s is almost ready. The demons assure me it's perfectly safe.",
    "The shadows are gathering for %s's journey to %s. See you on the other side!",
    "%s, the portal to %s is taking shape. Watch your step on the way in!",
    "Summoning %s to %s! The scenic route through the void is now open.",
    "%s, your invitation to %s has been drawn in glowing runes. Please step closer.",
    "The ritual begins! %s, we're opening a path to %s just for you.",
    "%s, the shadows know the way to %s. Follow them and we'll see you soon.",
    "A doorway through the dark awaits %s. Next stop: %s!",
    "%s, your passage to %s is being prepared. The candles are doing their best.",
    "The circle is glowing, the demons are watching, and %s is headed for %s!",
    "%s, a little fel magic is clearing your path to %s. See you shortly!",
    "Calling %s through the void! Your destination is %s; your luggage can fend for itself.",
    "%s, the ritual to %s is underway. Please ignore any suspicious chanting.",
    "A portal is forming for %s. Adventure awaits on the other side in %s!",
    "%s, we're folding the distance to %s. Please stay clear of the folds.",
    "The runes are set for %s's journey to %s. All we need now is a little magic.",
    "%s, your path to %s passes through the shadows. We'll leave a candle burning.",
    "Stand by, %s! A shortcut through the void is opening to %s.",
    "%s, the summoning circle is calling you to %s. The voices are mostly helpful.",
    "For %s: one freshly conjured passage to %s, with a touch of fel.",
    "%s, we're reaching across the void to bring you to %s. Hold on to your hat!",
    "The portal has your name on it, %s. Its other end is waiting in %s.",
    "%s, your route to %s is being stitched together with shadow and a little optimism.",
    "Hear that chanting, %s? That's your invitation to join us in %s.",
    "%s, we're opening the way to %s. The summoning circle looks especially welcoming today.",
    "The void has a visitor: %s, on the way to %s. Let's make it a short visit.",
    "%s, your portal to %s is nearly here. Please do not feed the shadows.",
    "Summoning %s! The runes are pointing toward %s, and so are we.",
    "%s, a doorway to %s is opening. Knock twice if the shadows ask.",
    "%s, the path to %s is getting shorter. Thank the summoning circle!",
    "%s, we're calling you to %s. The demons have been asked to keep the route clear.",
    "The candles are lit for %s's passage to %s. Please follow the ominous glow.",
    "%s, your journey to %s is about to become considerably shorter and slightly stranger.",
    "A little chanting, a little shadow, and %s will be on the way to %s!",
    "%s, we're opening a portal to %s. Try not to make eye contact with the void.",
    "Good news, %s: the summoning circle has found a shortcut to %s!",
    "%s, the shadows are preparing your passage to %s. We saved you a spot in the circle.",
    "The ritual for %s is underway! We'll be waiting on the other side in %s.",
    "%s, your portal to %s is opening. The glowing runes mean it's working, probably.",
    "Calling across the darkness for %s! Your destination is %s.",
    "%s, we've marked a path through the void to %s. Follow the sound of chanting.",
    "%s, the distance to %s is no match for this ritual. See you soon!",
    "%s, your shortcut to %s is powered by friendship, shadow, and several willing hands.",
    "The circle is ready for %s. Pointing the other end toward %s!",
    "%s, we're summoning you to %s. Please leave any wandering demons behind.",
    "%s, a passage to %s is opening. The darkness between here and there is complimentary.",
    "%s, the ritual is beginning! Your fellow adventurers await in %s.",
}

local function passengerName(target)
    if type(target) ~= "string" or target == "" then
        return nil
    end
    if target == "target" or target == "player" or target:match("^party[1-4]$") then
        target = UnitName(target)
    end
    if type(target) == "string" and target ~= "" then
        return target
    end
end

local function announce(target)
    if type(IsInRaid) == "function" and IsInRaid() then return end
    if type(GetNumGroupMembers) ~= "function" or GetNumGroupMembers() < 2 then return end

    target = passengerName(target)
    if not target then return end

    local zone = type(GetZoneText) == "function" and GetZoneText()
    if type(zone) ~= "string" or zone == "" then
        return
    end

    local index = math.random(#announcements)
    local message
    if index == 3 then
        message = string.format(announcements[index], zone, target)
    else
        message = string.format(announcements[index], target, zone)
    end
    if #message > 255 then
        return
    end
    SendChatMessage(message, "PARTY")
    return true
end

frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(_, event, unit, arg2, arg3, arg4)
    if event == "PLAYER_LOGIN" then
        local _, class = UnitClass("player")
        enabled = class == "WARLOCK"
        if enabled then
            frame:RegisterEvent("UNIT_SPELLCAST_SENT")
            frame:RegisterEvent("UNIT_SPELLCAST_START")
            frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
            frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
        end
        return
    end

    if not enabled or unit ~= "player" then return end
    if event == "UNIT_SPELLCAST_SENT" then
        pendingTarget, summonAnnounced = nil, false
        if arg4 == RITUAL_OF_SUMMONING then
            pendingTarget = passengerName(arg2) or passengerName("target")
        end
    elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" and arg3 == RITUAL_OF_SUMMONING then
        pendingTarget, summonAnnounced = nil, false
    elseif (event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START")
        and arg3 == RITUAL_OF_SUMMONING and not summonAnnounced then
        -- The channel need not reuse the cast ID from the send event.
        local target = pendingTarget or passengerName("target")
        summonAnnounced = announce(target) or false
    end
end)
