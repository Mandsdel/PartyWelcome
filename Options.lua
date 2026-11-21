local frame = CreateFrame("Frame")

local function registerOptions()
    local panel = CreateFrame("Frame", "PartyWelcomeSettingsPanel", UIParent)
    panel.name = "PartyWelcome"
    panel:Hide()
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("PartyWelcome")

    local description = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    description:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -18)
    description:SetWidth(500)
    description:SetJustifyH("LEFT")
    description:SetText("Basic hello message (leave empty to use the original random greetings):")

    local input = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    input:SetSize(400, 30)
    input:SetPoint("TOPLEFT", description, "BOTTOMLEFT", 5, -12)
    input:SetAutoFocus(false)
    input:SetMaxLetters(255)

    local status = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    status:SetPoint("TOPLEFT", input, "BOTTOMLEFT", -5, -12)
    status:SetWidth(500)
    status:SetJustifyH("LEFT")
    status:SetText("Applies to both hi and welcome messages. Saved per character.")

    local save = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    save:SetSize(80, 24)
    save:SetPoint("TOPLEFT", status, "BOTTOMLEFT", 0, -12)
    save:SetText("Save")
    local function saveGreeting()
        local text = input:GetText()
        if #text > 255 then
            status:SetText("Message is too long: party chat allows at most 255 bytes.")
            return
        end
        PartyWelcomeDB.basicGreeting = text:match("%S") and text or nil
        input:SetText(PartyWelcomeDB.basicGreeting or "")
        input:ClearFocus()
        status:SetText("Saved. Empty messages use the original random greetings.")
    end
    save:SetScript("OnClick", saveGreeting)
    input:SetScript("OnEnterPressed", saveGreeting)
    input:SetScript("OnEscapePressed", function(self)
        self:SetText(PartyWelcomeDB.basicGreeting or "")
        self:ClearFocus()
    end)

    local _, class = UnitClass("player")
    local summon
    if class == "WARLOCK" then
        summon = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
        summon:SetSize(26, 26)
        summon:SetPoint("TOPLEFT", save, "BOTTOMLEFT", 0, -20)
        summon:SetScript("OnClick", function(self)
            PartyWelcomeDB.basicSummon = self:GetChecked() and true or false
        end)
        local label = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        label:SetPoint("LEFT", summon, "RIGHT", 4, 0)
        label:SetText("Basic Summon Message")
        local hint = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        hint:SetPoint("TOPLEFT", summon, "BOTTOMLEFT", 0, -6)
        hint:SetWidth(500)
        hint:SetJustifyH("LEFT")
        hint:SetText("Uses: <target> is being summoned to <zone>. Please click the portal to assist")
    end

    panel:SetScript("OnShow", function()
        input:SetText(PartyWelcomeDB.basicGreeting or "")
        if summon then summon:SetChecked(PartyWelcomeDB.basicSummon == true) end
    end)
    if Settings and type(Settings.RegisterCanvasLayoutCategory) == "function"
        and type(Settings.RegisterAddOnCategory) == "function" then
        local category = Settings.RegisterCanvasLayoutCategory(panel, "PartyWelcome")
        Settings.RegisterAddOnCategory(category)
    elseif type(InterfaceOptions_AddCategory) == "function" then
        InterfaceOptions_AddCategory(panel)
    else
        print("|cff00bfffPartyWelcome:|r AddOns options registration is unavailable.")
    end
end

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(_, event, name)
    if event == "ADDON_LOADED" and name == "PartyWelcome" then
        if PartyWelcomeDB ~= nil and type(PartyWelcomeDB) ~= "table" then
            print("|cff00bfffPartyWelcome:|r Invalid saved settings were reset.")
        end
        if type(PartyWelcomeDB) ~= "table" then PartyWelcomeDB = {} end
        if PartyWelcomeDB.basicGreeting ~= nil
            and (type(PartyWelcomeDB.basicGreeting) ~= "string" or #PartyWelcomeDB.basicGreeting > 255) then
            PartyWelcomeDB.basicGreeting = nil
            print("|cff00bfffPartyWelcome:|r Invalid basic hello message was cleared.")
        end
        if PartyWelcomeDB.basicSummon ~= nil and type(PartyWelcomeDB.basicSummon) ~= "boolean" then
            PartyWelcomeDB.basicSummon = false
            print("|cff00bfffPartyWelcome:|r Invalid basic summon setting was disabled.")
        end
    elseif event == "PLAYER_LOGIN" then
        if type(PartyWelcomeDB) ~= "table" then PartyWelcomeDB = {} end
        registerOptions()
    end
end)
