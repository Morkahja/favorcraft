local addonName, RRP = ...
local UI = RRP.UI

function UI.BuildSettings(parent, gear)
    local panel = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    panel:SetSize(280, 250)
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
    help:SetSize(256, 72)
    help:SetJustifyV("TOP")
    help:SetText("/fc opens this window. /favorcraft does too, and /rrp still works. With Favorcraft open, opening Blacksmithing, Cooking, or another supported profession scans it and confirms in chat. /fc scan reads the profession that is open.")
    local version = UI.Label(panel, "GameFontDisableSmall")
    version:SetPoint("BOTTOMLEFT", 12, 10)
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
