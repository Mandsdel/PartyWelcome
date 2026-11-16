local classes = {
    WARRIOR = {
        title = "warrior",
        strength = "warrior's steel",
        talent = "battle cry",
        voice = "My battle cry is ready when you are.",
        welcome = "There's room beside me in the fight.",
    },
    PALADIN = {
        title = "paladin",
        strength = "paladin's Light",
        talent = "steadfast devotion",
        voice = "May the Light guide our path.",
        welcome = "Your Light is welcome here.",
    },
    HUNTER = {
        title = "hunter",
        strength = "hunter's keen eye",
        talent = "trusty companion",
        voice = "My companion is curious about our new ally.",
        welcome = "Your companion is welcome too.",
    },
    ROGUE = {
        title = "rogue",
        strength = "rogue's cunning",
        talent = "knack for mischief",
        voice = "I've checked the shadows for surprises.",
        welcome = "I promise we won't ask you to pick every lock.",
    },
    PRIEST = {
        title = "priest",
        strength = "priest's guiding faith",
        talent = "comforting presence",
        voice = "A little hope can brighten any journey.",
        welcome = "Your calm presence is a welcome sight.",
    },
    SHAMAN = {
        title = "shaman",
        strength = "shaman's elemental power",
        talent = "bond with the spirits",
        voice = "The spirits seem pleased by your arrival.",
        welcome = "There's room for your totems among friends.",
    },
    MAGE = {
        title = "mage",
        strength = "mage's arcane magic",
        talent = "spellbook",
        voice = "I'll keep the fireballs pointed away from friends.",
        welcome = "I hope your spellbook has room for adventure.",
    },
    WARLOCK = {
        title = "warlock",
        strength = "warlock's shadow magic",
        talent = "fearsome minions",
        voice = "My minions promise to behave during introductions.",
        welcome = "Your minions are welcome, as long as they behave.",
    },
    DRUID = {
        title = "druid",
        strength = "druid's wild magic",
        talent = "connection to nature",
        voice = "The wilds are in a welcoming mood.",
        welcome = "There's room in our party for every shape you take.",
    },
}

local templates = {
    "Welcome, %s! With my %s and your %s, we're ready for adventure.",
    "Well met, %s! I'll bring my %s; you bring your %s.",
    "Glad you're here, %s! My %s and your %s make a fine team.",
    "Welcome aboard, %s! Let's see what my %s and your %s can accomplish together.",
    "Good to have you, %s! Our enemies should beware my %s and your %s.",
    "Welcome, %s! I have my %s ready, and I'm glad to have your %s beside me.",
    "A %s joins the party! My %s and your %s will make this journey memorable.",
    "Greetings, %s! Between my %s and your %s, this party is in good hands.",
    "Welcome to the party, %s! I'm glad my %s can be joined by your %s.",
    "Well met, %s! Let's put my %s and your %s to good use.",
    "Welcome, %s! Adventure awaits our combination of my %s and your %s.",
    "Glad you joined us, %s! There's room for my %s and your %s in every good plan.",
    "Welcome, %s! I suspect my %s and your %s will keep things interesting.",
    "Good timing, %s! My %s could use your %s on the road ahead.",
    "Welcome, %s! Together, my %s and your %s can face whatever comes.",
    "Great to have you, %s! My %s and your %s are a combination worth celebrating.",
    "Welcome, %s! Let's take my %s and your %s on an adventure to remember.",
}

PartyWelcomePairGreetings = {}
for playerClass, player in pairs(classes) do
    local byJoiningClass = {}
    for joiningClass, joining in pairs(classes) do
        local messages = {}
        for index, template in ipairs(templates) do
            local playerStrength = index % 3 == 0 and player.talent or player.strength
            local joiningStrength = index % 2 == 0 and joining.talent or joining.strength
            messages[index] = string.format(template, joining.title, playerStrength, joiningStrength)
            if index % 3 == 1 then
                messages[index] = messages[index] .. " " .. player.voice
            elseif index % 3 == 2 then
                messages[index] = messages[index] .. " " .. joining.welcome
            end
        end
        byJoiningClass[joiningClass] = messages
    end
    PartyWelcomePairGreetings[playerClass] = byJoiningClass
end
