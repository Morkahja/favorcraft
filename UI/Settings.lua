local addonName, RRP = ...
local UI = RRP.UI

function UI.BuildSettings(parent, gear)
    local panel = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    panel:SetSize(280, 390)
    panel:SetPoint("TOPRIGHT", gear, "BOTTOMRIGHT", 0, -4)
    panel:SetFrameLevel(parent:GetFrameLevel() + 30)
    UI.Paint(panel)
    panel:EnableMouse(true)
    panel:Hide()
    UI.settings = panel

    local title = UI.Label(panel, "GameFontNormal", "Settings")
    title:SetPoint("TOPLEFT", 12, -10)
    local about = UI.Label(panel, "GameFontHighlightSmall")
    about:SetPoint("TOPLEFT", 12, -30)
    about:SetSize(256, 64)
    about:SetJustifyV("TOP")
    about:SetText("Merchant's Favor planner for WoW Forever. Both factions use the same recipe list. Paladin plate stays hidden unless Paladin is selected. Reagents and crafted items are Forever client data published by AHledger (ahledger.com).")

    local reset = UI.Button(panel, "Reset position", 256, 22)
    reset:SetPoint("TOPLEFT", 12, -102)
    reset:SetScript("OnClick", function()
        local frame = RRP.Window
        if not frame then return end
        frame:ClearAllPoints()
        frame:SetPoint("CENTER")
        frame:SetScale(1)
        if UI.SyncScaledFrames then UI.SyncScaledFrames() end
        UI.SaveWindow(frame, "main")
    end)

    local expand = UI.Check(panel, "Use crafted materials in bags", 250)
    expand:SetPoint("TOPLEFT", 12, -134)
    expand.tip = "Crafted materials"
    expand.tipLine = "If you already have an item this plan can craft, those bags are used before its reagents are added."
    expand.onToggle = function(on)
        local profile = RRP.GetProfile()
        if not profile then return end
        profile.expandIntermediate = on and true or false
        RRP.Refresh()
    end
    local help = UI.Label(panel, "GameFontDisableSmall")
    help:SetPoint("TOPLEFT", 12, -164)
    help:SetSize(256, 60)
    help:SetJustifyV("TOP")
    help:SetText("/fc opens this window. /favorcraft does too. With FavorCraft open, opening Blacksmithing, Cooking, or another supported profession scans it and confirms in chat. /fc scan reads the profession that is open.")

    local authorCaption = UI.Label(panel, "GameFontDisableSmall", "Author")
    authorCaption:SetPoint("TOPLEFT", 12, -230)
    local authorName = UI.Label(panel, "GameFontHighlight", "Babunigaming")
    authorName:SetPoint("TOPLEFT", 12, -246)
    local moreInfo = UI.Button(panel, "More info", 110, 20)
    moreInfo:SetPoint("TOPLEFT", 12, -266)
    local coauthor = UI.Label(panel, "GameFontHighlightSmall", "Co-author Danoozy. Danoozy came up with the idea, and that is what led to the hours spent sitting with FavorCraft, thinking it through, and polishing it.")
    coauthor:SetPoint("TOPLEFT", 12, -292)
    coauthor:SetSize(256, 56)
    coauthor:SetJustifyV("TOP")

    local social = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    social:SetSize(248, 176)
    social:SetPoint("TOPRIGHT", panel, "TOPLEFT", -8, -220)
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
