local addonName, RRP = ...
local UI = RRP.UI

function UI.BuildNav(panel)
    local buttons = {}
    local y = -8
    local function addDivider()
        y = y - 5
        local line = panel:CreateTexture(nil, "ARTWORK")
        line:SetPoint("TOPLEFT", 18, y)
        line:SetSize(122, 1)
        line:SetTexture("Interface\\Buttons\\WHITE8X8")
        line:SetVertexColor(0.72, 0.58, 0.24, 0.9)
        y = y - 8
    end
    local function addButton(name)
        local b = CreateFrame("Button", nil, panel, "BackdropTemplate")
        b:SetSize(142, 38)
        b:SetPoint("TOPLEFT", 8, y)
        y = y - 42
        if b.SetBackdrop then
            b:SetBackdrop({
                bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                tile = true, tileSize = 16, edgeSize = 10,
                insets = {left = 2, right = 2, top = 2, bottom = 2},
            })
        end
        b.icon = b:CreateTexture(nil, "ARTWORK")
        b.icon:SetSize(24, 24)
        b.icon:SetPoint("LEFT", 6, 0)
        UI.SetIcon(b.icon, RRP.ProfessionTexture[name])
        b.text = b:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        UI.GrowFont(b.text, 1.05)
        b.text:SetPoint("LEFT", 36, 0)
        b.text:SetPoint("RIGHT", -6, 0)
        b.text:SetJustifyH("LEFT")
        b.text:SetJustifyV("MIDDLE")
        b.text:SetText(name)
        b.profession = name
        b:SetScript("OnClick", function()
            UI.CloseMenus()
            RRP.SetProfession(name)
        end)
        b:SetScript("OnEnter", function(self)
            local profile = RRP.GetProfile()
            local line = "Show recipes from every profession."
            if name ~= "All" then
                if profile and profile.professions and profile.professions[name] then
                    local rank = profile.professionRanks and profile.professionRanks[name]
                    line = rank and ("Your skill: " .. rank) or "You know this profession."
                else
                    line = "Not recorded on this character yet."
                end
            end
            UI.ShowTip(self, name, line)
            if self.profession ~= (profile and profile.profession) and self.SetBackdropBorderColor then
                self:SetBackdropBorderColor(0.85, 0.68, 0.28, 0.9)
            end
        end)
        b:SetScript("OnLeave", function(self)
            UI.HideTip()
            UI.RefreshNav()
        end)
        buttons[#buttons + 1] = b
    end
    addButton("All")
    y = y - 2
    local groups = RRP.ProfessionGroups or {}
    for g, group in ipairs(groups) do
        if g > 1 then addDivider() end
        for _, name in ipairs(group) do
            addButton(name)
        end
    end

    local scan = UI.Button(panel, "Scan profession", 142, 24)
    scan:SetPoint("BOTTOMLEFT", 8, 10)
    scan.tip = "Scan profession"
    scan.tipLine = "Open a profession window so FavorCraft can read the recipes you know."
    scan:SetScript("OnClick", function()
        if UI.ShowScanHelp then UI.ShowScanHelp() end
    end)
    scan:Hide()

    function UI.RefreshNav()
        local profile = RRP.GetProfile()
        local current = profile and profile.profession or "All"
        for _, b in ipairs(buttons) do
            local selected = b.profession == current
            local mine = profile and profile.professions and profile.professions[b.profession]
            if b.SetBackdropColor then
                if selected then
                    b:SetBackdropColor(0.42, 0.3, 0.07, 0.95)
                    b:SetBackdropBorderColor(0.95, 0.75, 0.25, 1)
                else
                    b:SetBackdropColor(0.07, 0.06, 0.045, 0.5)
                    b:SetBackdropBorderColor(0.28, 0.22, 0.1, 0.35)
                end
            end
            local rank = profile and profile.professionRanks and profile.professionRanks[b.profession]
            b.text:SetText(rank and (b.profession .. "\n" .. rank) or b.profession)
            if selected then b.text:SetTextColor(1, 0.86, 0.4)
            elseif mine then b.text:SetTextColor(0.75, 0.95, 0.7)
            else b.text:SetTextColor(0.82, 0.78, 0.68) end
        end
        if RRP.HasScannedProfession and RRP.HasScannedProfession() then scan:Hide()
        else scan:Show() end
    end
end
