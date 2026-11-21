local frames, registered = {}, {}
local class = "WARLOCK"
local methods = {}
function methods:RegisterEvent() end
function methods:SetScript(event, handler) self.scripts[event] = handler end
function methods:SetText(text) self.text = text end
function methods:GetText() return self.text or "" end
function methods:SetChecked(value) self.checked = value end
function methods:GetChecked() return self.checked end
function methods:CreateFontString() return CreateFrame("FontString", nil, self) end
setmetatable(methods, { __index = function() return function() end end })
function CreateFrame(kind, name, parent, template)
    local frame = setmetatable({ kind = kind, name = name, parent = parent,
        template = template, scripts = {} }, { __index = methods })
    frames[#frames + 1] = frame
    return frame
end
Settings = {
    RegisterCanvasLayoutCategory = function(panel, name)
        assert(name == "PartyWelcome")
        return panel
    end,
    RegisterAddOnCategory = function(panel) registered[#registered + 1] = panel end,
}
UnitClass = function() return class, class end
UIParent = {}

local function start()
    local first = #frames + 1
    assert(loadfile("Options.lua"))()
    local events = frames[first]
    events.scripts.OnEvent(events, "ADDON_LOADED", "PartyWelcome")
    events.scripts.OnEvent(events, "PLAYER_LOGIN")
    return registered[#registered], first
end

PartyWelcomeDB = {}
local panel, first = start()
local input, save, summon
for index = first, #frames do
    local widget = frames[index]
    if widget.kind == "EditBox" then input = widget end
    if widget.kind == "Button" and widget.text == "Save" then save = widget end
    if widget.kind == "CheckButton" then summon = widget end
end
assert(panel and input and save and summon)
panel.scripts.OnShow()
input:SetText("My greeting")
save.scripts.OnClick()
assert(PartyWelcomeDB.basicGreeting == "My greeting")
input:SetText(string.rep("x", 256))
save.scripts.OnClick()
assert(PartyWelcomeDB.basicGreeting == "My greeting")
input:SetText("   ")
save.scripts.OnClick()
assert(PartyWelcomeDB.basicGreeting == nil)
summon:SetChecked(true)
summon.scripts.OnClick(summon)
assert(PartyWelcomeDB.basicSummon == true)
summon:SetChecked(false)
summon.scripts.OnClick(summon)
assert(PartyWelcomeDB.basicSummon == false)

class = "MAGE"
local magePanel, mageFirst = start()
assert(magePanel ~= panel)
for index = mageFirst, #frames do
    assert(frames[index].kind ~= "CheckButton", "Summon setting must only appear for warlocks")
end
print("PartyWelcome options checks passed")
