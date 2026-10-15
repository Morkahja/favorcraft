local addonName, RRP = ...
local UI = RRP.UI

function UI.BuildSettings(parent, gear)
    local panel = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    panel:SetSize(280, 448)
    panel:SetPoint("TOPRIGHT", gear, "BOTTOMRIGHT", 0, -4)
    panel:SetFrameLevel(parent:GetFrameLevel() + 30)
    UI.Paint(panel)
    panel:EnableMouse(true)
    panel:Hide()
    UI.settings = panel

    local function note(parentFrame, y, height, text)
        local label = UI.Label(parentFrame, "GameFontDisableSmall", text)
        label:SetPoint("TOPLEFT", 12, y)
        label:SetSize(256, height)
        label:SetJustifyV("TOP")
        label:SetTextColor(0.65, 0.6, 0.5)
        return label
    end

    local title = UI.Label(panel, "GameFontNormal", "Settings")
    title:SetPoint("TOPLEFT", 12, -12)
    note(panel, -34, 42, "Plan Merchant's Favor purchases, explore profession recipes, and track crafting materials across Azeroth.")

    local reset = UI.Button(panel, "Reset window position", 256, 22)
    reset:SetPoint("TOPLEFT", 12, -82)
    reset:SetScript("OnClick", function()
        local frame = RRP.Window
        if not frame then return end
        frame:ClearAllPoints()
        frame:SetPoint("CENTER")
        frame:SetScale(1)
        if UI.SyncScaledFrames then UI.SyncScaledFrames() end
        UI.SaveWindow(frame, "main")
    end)
    note(panel, -108, 16, "Restore the default window position and scale.")

    local expand = UI.Check(panel, "Expand intermediate crafts", 250)
    expand:SetPoint("TOPLEFT", 12, -132)
    expand.tip = "Expand intermediate crafts"
    expand.tipLine = "Use materials already in your bags. If a required material can be crafted with a known FavorCraft recipe, calculate the ingredients needed to make the remainder."
    expand.onToggle = function(on)
        local profile = RRP.GetProfile()
        if not profile then return end
        profile.expandIntermediate = on and true or false
        RRP.Refresh()
    end
    note(panel, -154, 62, "Use materials already in your bags. If a required material can be crafted with a known FavorCraft recipe, calculate the ingredients needed to make the remainder.")

    UI.Divider(panel, -224)
    local credits = UI.Label(panel, "GameFontNormal", "Credits")
    credits:SetPoint("TOPLEFT", 12, -234)
    local authorLine = UI.Label(panel, "GameFontHighlightSmall", "Author: Babunigaming")
    authorLine:SetPoint("TOPLEFT", 12, -256)
    if authorLine.SetWordWrap then authorLine:SetWordWrap(false) end
    authorLine:SetTextColor(0.9, 0.86, 0.75)
    local moreInfo = UI.Button(panel, "More info", 88, 18)
    moreInfo:SetPoint("LEFT", authorLine, "RIGHT", 8, 0)
    local coauthor = UI.Label(panel, "GameFontHighlightSmall", "Co-author & Original Concept: Danoozy")
    coauthor:SetPoint("TOPLEFT", 12, -278)
    coauthor:SetWidth(256)
    coauthor:SetHeight(16)
    if coauthor.SetWordWrap then coauthor:SetWordWrap(false) end
    coauthor:SetTextColor(0.9, 0.86, 0.75)

    local dataTitle = UI.Label(panel, "GameFontNormal", "Data Attribution")
    dataTitle:SetPoint("TOPLEFT", 12, -306)
    local dataLine = UI.Label(panel, "GameFontHighlightSmall", "Recipe and reagent data: AHledger")
    dataLine:SetPoint("TOPLEFT", 12, -328)
    dataLine:SetTextColor(0.9, 0.86, 0.75)
    note(panel, -346, 14, "ahledger.com")
    note(panel, -362, 16, "WoW Forever client data, build 1.60.1.")

    local social = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    social:SetSize(248, 176)
    social:SetPoint("TOPRIGHT", moreInfo, "TOPLEFT", -8, 8)
    social:SetFrameLevel(panel:GetFrameLevel() + 5)
    UI.Paint(social)
    social:EnableMouse(true)
    social:Hide()
    local socialTitle = UI.Label(social, "GameFontNormal", "Babunigaming")
    socialTitle:SetPoint("TOPLEFT", 12, -10)
    local linkBox = CreateFrame("EditBox", nil, social, "InputBoxTemplate")
    linkBox:SetSize(210, 20)
    linkBox:SetPoint("BOTTOMLEFT", 16, 12)
    linkBox:SetAutoFocus(false)
    linkBox:SetFontObject(GameFontHighlightSmall)
    linkBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    local linkNote = UI.Label(social, "GameFontDisableSmall", "Ctrl+C copies the link.")
    linkNote:SetPoint("BOTTOMLEFT", 12, 34)
    linkNote:SetWidth(220)
    local function showLink(url)
        linkBox:SetText(url)
        linkBox:SetFocus()
        linkBox:HighlightText()
    end
    local instagram = UI.Button(social, "Instagram", 224, 22)
    instagram:SetPoint("TOPLEFT", 12, -32)
    instagram:SetScript("OnClick", function()
        showLink("https://www.instagram.com/babunigaming/")
    end)
    local youtube = UI.Button(social, "YouTube", 224, 22)
    youtube:SetPoint("TOPLEFT", 12, -58)
    youtube:SetScript("OnClick", function()
        showLink("https://www.youtube.com/@babunigaming")
    end)
    local curse = UI.Button(social, "CurseForge", 224, 22)
    curse:SetPoint("TOPLEFT", 12, -84)
    curse:SetScript("OnClick", function()
        showLink("https://www.curseforge.com/members/babunigaming")
    end)
    moreInfo:SetScript("OnClick", function()
        if social:IsShown() then
            social:Hide()
        else
            social:Show()
            showLink("https://www.youtube.com/@babunigaming")
        end
    end)
    panel:SetScript("OnHide", function() social:Hide() end)

    local version = UI.Label(panel, "GameFontDisableSmall")
    version:SetPoint("BOTTOMLEFT", 12, 8)
    version:SetWidth(256)
    local ver = GetAddOnMetadata and GetAddOnMetadata(addonName, "Version")
    version:SetText(ver and ("Version " .. ver) or "")

    function UI.ToggleSettings()
        if panel:IsShown() then
            panel:Hide()
            return
        end
        UI.CloseMenus()
        local profile = RRP.GetProfile()
        expand:SetChecked(not profile or profile.expandIntermediate ~= false)
        panel:Show()
    end
    function UI.RefreshSettings()
        if not panel:IsShown() then return end
        local profile = RRP.GetProfile()
        expand:SetChecked(not profile or profile.expandIntermediate ~= false)
    end
end
