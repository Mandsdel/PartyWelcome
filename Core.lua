local defaultGreeting = "Hey, welcome friend"

local previousMembers
local previousWasRaid = false
local ready = false

local function createOptions()
    if not Settings or not Settings.RegisterVerticalLayoutCategory
        or not Settings.RegisterAddOnSetting or not Settings.CreateInput
        or not Settings.VarType or not Settings.VarType.String then
        print("|cff00bfffPartyWelcome:|r Options panel is unavailable on this client.")
        return
    end

    local category = Settings.RegisterVerticalLayoutCategory("PartyWelcome")
    local setting = Settings.RegisterAddOnSetting(
        category,
        "PARTYWELCOME_GREETING",
        "greeting",
        PartyWelcomeDB,
        Settings.VarType.String,
        "Welcome message",
        defaultGreeting
    )
    Settings.CreateInput(category, setting, 255, "Message sent in party chat when someone joins your party.")
    Settings.RegisterAddOnCategory(category)
end

local function getMemberIdentity(unit)
    if type(UnitGUID) == "function" then
        local guid = UnitGUID(unit)
        if type(guid) == "string" then
            return guid
        end
    end

    if type(UnitName) == "function" then
        local name, realm = UnitName(unit)
        if type(name) == "string" and name ~= "" then
            return name .. "-" .. (type(realm) == "string" and realm or "")
        end
    end

    return nil
end

local function collectMembers()
    local members = {}
    if type(GetNumGroupMembers) ~= "function" then
        return members, false, false
    end

    local groupSize = GetNumGroupMembers()
    local inRaid = type(IsInRaid) == "function" and IsInRaid() or false
    if type(groupSize) ~= "number" or groupSize < 2 then
        return members, false, inRaid
    end

    local isParty = not inRaid
    local count = inRaid and groupSize or math.min(groupSize - 1, 4)
    local playerGuid = type(UnitGUID) == "function" and UnitGUID("player")

    for index = 1, count do
        local unit = (inRaid and "raid" or "party") .. index
        local isPlayer = type(UnitIsUnit) == "function" and UnitIsUnit(unit, "player")
        local identity = getMemberIdentity(unit)

        if not isPlayer and identity ~= nil and (playerGuid == nil or identity ~= playerGuid) then
            members[identity] = true
        end
    end

    return members, isParty, inRaid
end

local function updateRoster(announceNewMembers)
    local members, isParty, inRaid = collectMembers()

    if announceNewMembers and isParty and not previousWasRaid and previousMembers ~= nil
        and type(SendChatMessage) == "function" and PartyWelcomeDB.greeting ~= "" then
        for identity in pairs(members) do
            if not previousMembers[identity] then
                SendChatMessage(PartyWelcomeDB.greeting, "PARTY")
            end
        end
    end

    previousMembers = members
    previousWasRaid = inRaid
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:SetScript("OnEvent", function(_, event, name)
    if event == "ADDON_LOADED" then
        if name ~= "PartyWelcome" then
            return
        end
        PartyWelcomeDB = type(PartyWelcomeDB) == "table" and PartyWelcomeDB or {}
        if type(PartyWelcomeDB.greeting) ~= "string" then
            PartyWelcomeDB.greeting = defaultGreeting
        end
        return
    end

    if event == "PLAYER_LOGIN" then
        updateRoster(false)
        createOptions()
        return
    end

    if event == "PLAYER_ENTERING_WORLD" then
        updateRoster(false)
        ready = true
        return
    end

    updateRoster(ready)
end)
