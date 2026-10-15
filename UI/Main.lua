local addonName, RRP = ...
local UI = RRP.UI

local W, H = 1080, 728
local f = CreateFrame("Frame", "FavorCraftFrame", UIParent, "BackdropTemplate")
f:SetSize(W, H)
f:SetPoint("CENTER")
f:SetFrameStrata("DIALOG")
f:EnableMouse(true)
f:SetMovable(true)
f:SetClampedToScreen(true)
f:RegisterForDrag("LeftButton")
f:SetScript("OnDragStart", function(self) self:StartMoving() end)
f:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    UI.SaveWindow(self, "main")
end)
if f.SetBackdrop then
    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = {left = 11, right = 12, top = 12, bottom = 11},
    })
end
f:Hide()
if UISpecialFrames then table.insert(UISpecialFrames, f:GetName()) end

local banner = f:CreateTexture(nil, "OVERLAY")
banner:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
banner:SetSize(420, 64)
banner:SetPoint("TOP", 0, 12)
local title = UI.Label(f, "GameFontNormalLarge", "FavorCraft")
title:SetPoint("TOP", 0, -2)
title:SetWidth(360)
title:SetJustifyH("CENTER")
title:SetTextColor(1, 0.82, 0)
local subtitle = UI.Label(f, "GameFontNormal", "Merchant's Favor & Profession Planner")
subtitle:SetPoint("TOP", 0, -22)
subtitle:SetWidth(980)
subtitle:SetJustifyH("CENTER")
UI.subtitle = subtitle
local factionBar = f:CreateTexture(nil, "ARTWORK")
factionBar:SetPoint("TOPLEFT", 28, -44)
factionBar:SetPoint("TOPRIGHT", -28, -44)
factionBar:SetHeight(2)
factionBar:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
factionBar:SetVertexColor(0.75, 0.6, 0.22, 0.9)
UI.factionBar = factionBar
local titleHit = CreateFrame("Button", nil, f)
titleHit:SetSize(280, 20)
titleHit:SetPoint("TOP", 0, 0)
titleHit:RegisterForDrag("LeftButton")
titleHit:SetScript("OnDragStart", function() f:StartMoving() end)
titleHit:SetScript("OnDragStop", function()
    f:StopMovingOrSizing()
    UI.SaveWindow(f, "main")
end)
titleHit:SetScript("OnEnter", function(self)
    UI.ShowTip(self, "FavorCraft", "Merchant's Favor & Profession Planner\nWorld of Warcraft Forever | Alliance & Horde")
end)
titleHit:SetScript("OnLeave", UI.HideTip)

local close = UI.Button(f, "X", 22, 22)
close:SetPoint("TOPRIGHT", -8, -6)
close:SetStyle("red")
close:SetScript("OnClick", function() f:Hide() end)
local gear = UI.Button(f, "", 22, 22)
gear:SetPoint("TOPRIGHT", close, "TOPLEFT", -4, 0)
gear.tip = "Settings"
gear.tipLine = "Options for this window."
local gearIcon = gear:CreateTexture(nil, "OVERLAY")
gearIcon:SetSize(16, 16)
gearIcon:SetPoint("CENTER", 0, 0)
UI.SetIcon(gearIcon, "Interface\\Icons\\INV_Misc_Gear_01")
gear:SetScript("OnClick", function() UI.ToggleSettings() end)

local filter = CreateFrame("Frame", nil, f)
filter:SetPoint("TOPLEFT", 16, -52)
filter:SetPoint("TOPRIGHT", -16, -52)
filter:SetHeight(32)

local classDrop = UI.Dropdown(filter, 220, function(value) RRP.SetPreviewClass(value) end)
classDrop:SetPoint("LEFT", 0, 0)
local classChoices = {}
for _, class in ipairs(RRP.ClassOrder) do
    classChoices[#classChoices + 1] = {
        value = class,
        text = RRP.ClassNames[class] or class,
        icon = RRP.ClassTexture[class],
    }
end
classDrop:SetChoices(classChoices)

local buildsLabel = UI.Label(filter, "GameFontNormalSmall", "Builds")
buildsLabel:SetPoint("LEFT", 236, 0)
buildsLabel:SetWidth(46)
local buildNames = {"Tank", "DPS", "Healer", "Other"}
local buildChecks = {}
local buildX = 286
local buildW = {58, 52, 68, 62}
for i, name in ipairs(buildNames) do
    local check = UI.Check(filter, name, buildW[i])
    check:SetPoint("LEFT", buildX, 0)
    buildX = buildX + buildW[i]
    check.onToggle = function(on) RRP.SetBuild(name, on) end
    buildChecks[name] = check
end
buildChecks.Tank.tipLine = "Show tank recipes for the selected class. Other builds stay hidden while this is the only one checked."
buildChecks.DPS.tipLine = "Show damage recipes for the selected class. Mage, warlock, and priest use caster recipes. Hunter uses hunter and melee."
buildChecks.Healer.tipLine = "Show healing recipes for the selected class."
buildChecks.Other.tipLine = "Show utility recipes, such as bags and special tools."

local showAll = UI.Button(filter, "Show All Recipes", 148, 22)
showAll:SetPoint("RIGHT", 0, 0)
showAll.tip = "Show All Recipes"
showAll.tipLine = "Ignore the class and build filters. Choose a build again to return to them."
showAll:SetScript("OnClick", function() RRP.ToggleRole("All") end)

local nav = CreateFrame("Frame", nil, f, "BackdropTemplate")
nav:SetPoint("TOPLEFT", 16, -90)
nav:SetSize(158, 424)
UI.Paint(nav)
nav:EnableMouse(true)

local browser = CreateFrame("Frame", nil, f, "BackdropTemplate")
browser:SetPoint("TOPLEFT", 180, -90)
browser:SetSize(488, 424)
UI.Paint(browser)
browser:EnableMouse(true)

local details = CreateFrame("Frame", nil, f, "BackdropTemplate")
details:SetPoint("TOPLEFT", 674, -90)
details:SetPoint("BOTTOMRIGHT", -16, 208)
UI.Paint(details)
details:EnableMouse(true)

local selected = CreateFrame("Frame", nil, f, "BackdropTemplate")
selected:SetPoint("BOTTOMLEFT", 16, 14)
selected:SetSize(344, 186)
UI.Paint(selected)
selected:EnableMouse(true)

local materials = CreateFrame("Frame", nil, f, "BackdropTemplate")
materials:SetPoint("BOTTOMLEFT", 366, 14)
materials:SetSize(344, 186)
UI.Paint(materials)
materials:EnableMouse(true)

local purchase = CreateFrame("Frame", nil, f, "BackdropTemplate")
purchase:SetPoint("BOTTOMRIGHT", -16, 14)
purchase:SetSize(348, 186)
UI.Paint(purchase)
purchase:EnableMouse(true)

UI.BuildNav(nav)
UI.BuildBrowser(browser)
UI.BuildDetails(details)
UI.BuildPlan(selected, materials, purchase)
UI.BuildSettings(f, gear)
UI.BuildShopping()

local scanPrompt = CreateFrame("Frame", nil, f, "BackdropTemplate")
scanPrompt:SetSize(480, 118)
scanPrompt:SetPoint("CENTER", 0, 20)
scanPrompt:SetFrameLevel(f:GetFrameLevel() + 40)
UI.Paint(scanPrompt)
scanPrompt:EnableMouse(true)
scanPrompt:Hide()
local scanText = UI.Label(scanPrompt, "GameFontHighlight")
scanText:SetPoint("TOPLEFT", 16, -16)
scanText:SetSize(448, 48)
scanText:SetJustifyV("TOP")
local openProf = UI.Button(scanPrompt, "Open Profession", 170, 24)
openProf:SetPoint("BOTTOMLEFT", 16, 14)
openProf:SetScript("OnClick", function()
    if RRP.OpenProfessionBook then RRP.OpenProfessionBook() end
    if UI.RefreshScanPrompt then UI.RefreshScanPrompt() end
end)
local dismissPrompt = UI.Button(scanPrompt, "Close", 80, 24)
dismissPrompt:SetPoint("BOTTOMRIGHT", -16, 14)
dismissPrompt:SetScript("OnClick", function()
    RRP.scanPromptHidden = true
    scanPrompt:Hide()
end)

function UI.RefreshScanPrompt()
    if RRP.scanPromptHidden or not f:IsShown() then
        scanPrompt:Hide()
        return
    end
    local missing = RRP.UnscannedProfessions and RRP.UnscannedProfessions() or {}
    if #missing == 0 then
        scanPrompt:Hide()
        return
    end
    scanPrompt:Show()
    if RRP.ProfessionBookOpen and RRP.ProfessionBookOpen() then
        scanText:SetText("Please select each of your professions.")
        openProf:Hide()
    else
        scanText:SetText("Please open each of your professions so I can scan it.")
        openProf:Show()
    end
end

function UI.ApplyFactionChrome()
    local info = RRP.FactionInfo and RRP.FactionInfo()
    local accent = info and info.accent or {0.75, 0.6, 0.22}
    if f.SetBackdropBorderColor then
        f:SetBackdropBorderColor(accent[1], accent[2], accent[3], 1)
    end
    factionBar:SetVertexColor(accent[1], accent[2], accent[3], 0.95)
    if info then
        subtitle:SetText("Merchant's Favor & Profession Planner   ·   " .. info.organization .. "   ·   " .. info.location)
        subtitle:SetTextColor(accent[1], accent[2], accent[3])
    else
        subtitle:SetText("Merchant's Favor & Profession Planner")
        subtitle:SetTextColor(0.85, 0.75, 0.45)
    end
end

function UI.RefreshHeader()
    local profile = RRP.GetProfile()
    if not profile then return end
    UI.ApplyFactionChrome()
    local class = RRP.ViewClass()
    local className = RRP.ClassNames[class] or ""
    for _, item in ipairs(classChoices) do
        local note = item.value == profile.class and " (you)" or ""
        item.text = (RRP.ClassNames[item.value] or item.value) .. note
    end
    classDrop:SetChoices(classChoices)
    classDrop:SetChoice(className, RRP.ClassTexture[class])
    local yours = RRP.ClassNames[profile.class] or "your class"
    classDrop.tip = className
    classDrop.tipLine = class == profile.class
        and ("Recipes for your " .. className .. ".")
        or ("Recipes for " .. className .. ". This character is a " .. yours .. ".")
    for name, check in pairs(buildChecks) do
        check:SetChecked(RRP.BuildOn(name))
    end
    showAll:SetText(profile.showAll and "Showing All Recipes" or "Show All Recipes")
    showAll:SetStyle(profile.showAll and "armed" or "dark")
    if UI.RefreshSettings then UI.RefreshSettings() end
end

function RRP.RefreshMain()
    if not RRP.GetProfile() then return end
    RRP.SelectedRecipe()
    UI.RefreshHeader()
    UI.RefreshNav()
    UI.RefreshBrowser()
    UI.RefreshDetails()
    UI.RefreshPlan()
    if UI.RefreshScanPrompt then UI.RefreshScanPrompt() end
end

function RRP.Refresh()
    if f:IsShown() and RRP.RefreshMain then RRP.RefreshMain() end
    if RRP.RefreshShopping then RRP.RefreshShopping() end
end

function RRP.Toggle()
    if f:IsShown() then
        f:Hide()
    else
        f:Show()
        RRP.Refresh()
    end
end

f:SetScript("OnHide", function()
    UI.CloseMenus()
    if UI.settings then UI.settings:Hide() end
    UI.SaveWindow(f, "main")
end)
local grip = CreateFrame("Button", nil, f)
grip:SetSize(16, 16)
grip:SetPoint("BOTTOMRIGHT", -2, 2)
grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
grip:RegisterForDrag("LeftButton")
grip:SetScript("OnEnter", function(self)
    UI.ShowTip(self, "Scale", "Drag to make FavorCraft larger or smaller.")
end)
grip:SetScript("OnLeave", UI.HideTip)
grip:SetScript("OnDragStart", function(self)
    UI.CloseMenus()
    local x, y = GetCursorPosition()
    local parentScale = UIParent:GetEffectiveScale()
    self.startX = x / parentScale
    self.startY = y / parentScale
    self.startScale = f:GetScale() or 1
    self:SetScript("OnUpdate", function(button)
        local cx, cy = GetCursorPosition()
        cx, cy = cx / parentScale, cy / parentScale
        local delta = ((cx - button.startX) + (button.startY - cy)) / 700
        local scale = button.startScale * (1 + delta)
        if scale < 0.65 then scale = 0.65 end
        if scale > 1.45 then scale = 1.45 end
        f:SetScale(scale)
        if UI.SyncScaledFrames then UI.SyncScaledFrames() end
    end)
end)
grip:SetScript("OnDragStop", function(self)
    self:SetScript("OnUpdate", nil)
    UI.SaveWindow(f, "main")
end)

f:SetScript("OnShow", function()
    RRP.scanPromptHidden = nil
    if RRP.HookBagFrames then RRP.HookBagFrames() end
    if RRP.SyncProfessions then RRP.SyncProfessions() end
    if RRP.QueueProfessionScan then RRP.QueueProfessionScan(true) end
    RRP.Refresh()
end)

local persist = CreateFrame("Frame")
persist:RegisterEvent("ADDON_LOADED")
persist:RegisterEvent("PLAYER_LOGOUT")
persist:SetScript("OnEvent", function(_, event, arg)
    if event == "ADDON_LOADED" and arg == addonName then
        if RRP.MigrateSaved then RRP.MigrateSaved() end
        if UI.RestoreLayout then UI.RestoreLayout() end
    elseif event == "PLAYER_LOGOUT" then
        UI.SaveWindow(f, "main")
        if RRP.Shopping then UI.SaveWindow(RRP.Shopping, "shop") end
    end
end)

RRP.Window = f
if UI.RestoreLayout then UI.RestoreLayout() end
