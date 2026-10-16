local addonName, RRP = ...
local UI = RRP.UI

function UI.BuildDetails(panel)
    local iconBorder = CreateFrame("Button", nil, panel, "BackdropTemplate")
    iconBorder:SetSize(46, 46)
    iconBorder:SetPoint("TOPLEFT", 10, -10)
    iconBorder:SetScript("OnEnter", function(self)
        local recipe = RRP.SelectedRecipe()
        if recipe then UI.ShowRecipeTip(self, recipe) end
    end)
    iconBorder:SetScript("OnLeave", UI.HideTip)
    if iconBorder.SetBackdrop then
        iconBorder:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 10,
        })
        iconBorder:SetBackdropBorderColor(0.85, 0.7, 0.28, 1)
    end
    local icon = iconBorder:CreateTexture(nil, "OVERLAY")
    icon:SetSize(36, 36)
    icon:SetPoint("CENTER", 0, 0)

    local name = UI.Label(panel, "GameFontNormalLarge")
    name:SetPoint("TOPLEFT", 64, -8)
    name:SetPoint("TOPRIGHT", -12, -8)
    name:SetHeight(22)
    name:SetTextColor(0.45, 0.78, 1)
    local profession = UI.Label(panel, "GameFontHighlight")
    profession:SetPoint("TOPLEFT", 64, -30)
    profession:SetPoint("RIGHT", panel, "RIGHT", -12, 0)
    profession:SetHeight(16)
    local level = UI.Label(panel, "GameFontHighlightSmall")
    level:SetPoint("TOPLEFT", 64, -46)
    level:SetPoint("RIGHT", panel, "RIGHT", -12, 0)
    level:SetHeight(16)
    local pattern = UI.Label(panel, "GameFontHighlightSmall")
    pattern:SetPoint("TOPLEFT", 64, -62)
    pattern:SetPoint("RIGHT", panel, "RIGHT", -12, 0)
    pattern:SetHeight(16)

    UI.Divider(panel, -84)

    local scroll = CreateFrame("ScrollFrame", nil, panel)
    scroll:SetPoint("TOPLEFT", 8, -90)
    scroll:SetPoint("BOTTOMRIGHT", -8, 36)
    scroll:EnableMouseWheel(true)
    local child = CreateFrame("Frame", nil, scroll)
    child:SetSize(344, 40)
    scroll:SetScrollChild(child)
    local function onWheel(_, delta)
        local current = scroll:GetVerticalScroll() or 0
        local maxScroll = scroll:GetVerticalScrollRange() or 0
        local nextScroll = current - delta * 24
        if nextScroll < 0 then nextScroll = 0 end
        if nextScroll > maxScroll then nextScroll = maxScroll end
        scroll:SetVerticalScroll(nextScroll)
    end
    scroll:SetScript("OnMouseWheel", onWheel)
    child:EnableMouseWheel(true)
    child:SetScript("OnMouseWheel", onWheel)

    local materialsTitle = UI.Label(child, "GameFontNormal", "Materials")
    local function matHead(text, width, justify)
        local s = UI.Label(child, "GameFontDisableSmall", text)
        s:SetWidth(width)
        s:SetJustifyH(justify)
        return s
    end
    local headMaterial = matHead("Material", 180, "LEFT")
    local headNeeded = matHead("Needed", 64, "CENTER")
    local headBags = matHead("In Bags", 70, "CENTER")
    local materialRows = {}
    local materialStatus = UI.Label(child, "GameFontHighlightSmall")
    materialStatus:SetWidth(320)
    materialStatus:SetJustifyV("TOP")
    materialStatus:SetTextColor(1, 0.75, 0.4)

    local alert = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    alert:SetPoint("BOTTOMLEFT", 10, 10)
    alert:SetPoint("BOTTOMRIGHT", -10, 10)
    alert:SetHeight(64)
    if alert.SetBackdrop then
        alert:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 12,
            insets = {left = 3, right = 3, top = 3, bottom = 3},
        })
        alert:SetBackdropColor(0.28, 0.2, 0.05, 0.92)
        alert:SetBackdropBorderColor(0.95, 0.72, 0.2, 1)
    end
    alert:Hide()
    local alertTitle = UI.Label(alert, "GameFontNormal", "Trainer alternative")
    alertTitle:SetPoint("TOPLEFT", 10, -8)
    alertTitle:SetWidth(320)
    local alertText = UI.Label(alert, "GameFontHighlight")
    alertText:SetPoint("TOPLEFT", 10, -26)
    alertText:SetPoint("BOTTOMRIGHT", -10, 8)
    alertText:SetJustifyV("TOP")
    local forget = UI.Button(panel, "Forget discovery", 120, 20)
    forget:SetPoint("BOTTOMLEFT", 10, 12)
    forget:SetScript("OnClick", function()
        if RRP.selectedKey then RRP.ForgetDiscovered(RRP.selectedKey) end
    end)
    forget:Hide()

    local comparisonTitle = UI.Label(child, "GameFontNormal", "Recipe Comparisons")
    local intro = UI.Label(child, "GameFontDisableSmall")
    intro:SetJustifyV("TOP")
    intro:SetTextColor(0.76, 0.74, 0.66)
    intro:Hide()
    local compareRows = {}
    local compareKey = nil

    local function tone(tier)
        if tier == "duplicate" or tier == "equivalent" then return 0.35, 0.9, 0.4 end
        if tier == "alternative" then return 0.78, 0.88, 0.5 end
        if tier == "related" or tier == "slot" or tier == "reported" then return 0.95, 0.72, 0.28 end
        return 0.7, 0.66, 0.58
    end
    local function textWidth()
        local w = scroll.GetWidth and scroll:GetWidth() or 0
        if type(w) ~= "number" or w < 120 then
            w = panel.GetWidth and panel:GetWidth() or 0
            if type(w) == "number" and w > 40 then w = w - 20 end
        end
        if type(w) ~= "number" or w < 120 then w = 360 end
        return math.floor(w - 36)
    end
    local function wrapLabel(label, x, y, width)
        label:ClearAllPoints()
        label:SetPoint("TOPLEFT", x, y)
        label:SetWidth(width)
        if label.SetWordWrap then label:SetWordWrap(true) end
        label:SetJustifyH("LEFT")
        label:SetJustifyV("TOP")
    end
    local function fitHeight(label, minimum)
        label:SetHeight(900)
        local h = type(label.GetStringHeight) == "function" and label:GetStringHeight() or 0
        h = tonumber(h) or 0
        h = math.max(minimum, math.ceil(h + 2))
        label:SetHeight(h)
        return h
    end
    local function sentences(parts)
        local bits = {}
        for i = 1, #parts do
            local part = tostring(parts[i] or "")
            part = part:gsub("%.+$", "")
            if part ~= "" then bits[#bits + 1] = part .. "." end
        end
        return table.concat(bits, " ")
    end
    local function showCompareTip(owner, entry)
        if not entry then return end
        if entry.kind == "source" then
            if entry.scrollItemID and UI.ShowItemTip then
                UI.ShowItemTip(owner, entry.scrollItemID)
            else
                UI.ShowTip(owner, entry.name or "", "Pattern item ID is not available in this database.")
            end
            return
        end
        if entry.itemID and UI.ShowItemTip then
            UI.ShowItemTip(owner, entry.itemID)
            return
        end
        if entry.kind == "enchant" and entry.spellID and UI.ShowSpellTip then
            UI.ShowSpellTip(owner, entry.spellID, entry.name)
            return
        end
        local line = "An item ID is not recorded for this comparison yet."
        if entry.kind == "enchant" then
            line = "A spell ID is not recorded for this comparison yet."
        end
        UI.ShowTip(owner, entry.name or "", line)
    end
    local function materialRow(index)
        local row = materialRows[index]
        if row then return row end
        row = CreateFrame("Frame", nil, child)
        row:SetSize(340, 20)
        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetSize(16, 16)
        row.icon:SetPoint("LEFT", 0, 0)
        row.name = UI.Label(row, "GameFontHighlight")
        row.name:SetPoint("LEFT", 22, 0)
        row.name:SetWidth(170)
        row.needed = UI.Label(row, "GameFontHighlightSmall")
        row.needed:SetPoint("LEFT", 198, 0)
        row.needed:SetWidth(64)
        row.needed:SetJustifyH("CENTER")
        row.owned = UI.Label(row, "GameFontHighlightSmall")
        row.owned:SetPoint("LEFT", 268, 0)
        row.owned:SetWidth(70)
        row.owned:SetJustifyH("CENTER")
        row:EnableMouseWheel(true)
        row:SetScript("OnMouseWheel", onWheel)
        row:Hide()
        materialRows[index] = row
        return row
    end
    local function compareRow(index)
        local row = compareRows[index]
        if row then return row end
        row = CreateFrame("Frame", nil, child)
        row:SetSize(344, 40)
        row.iconHit = CreateFrame("Button", nil, row)
        row.iconHit:SetSize(18, 18)
        row.iconHit:SetPoint("TOPLEFT", 2, -2)
        row.icon = row.iconHit:CreateTexture(nil, "ARTWORK")
        row.icon:SetAllPoints()
        row.iconHit:SetScript("OnEnter", function(self) showCompareTip(self, row.entry) end)
        row.iconHit:SetScript("OnLeave", UI.HideTip)
        row.iconHit:EnableMouseWheel(true)
        row.iconHit:SetScript("OnMouseWheel", onWheel)
        row.nameHit = CreateFrame("Button", nil, row)
        row.nameHit:SetPoint("TOPLEFT", 24, 0)
        row.nameHit:SetPoint("RIGHT", -4, 0)
        row.nameHit:SetHeight(16)
        row.nameHit:SetScript("OnEnter", function(self) showCompareTip(self, row.entry) end)
        row.nameHit:SetScript("OnLeave", UI.HideTip)
        row.nameHit:EnableMouseWheel(true)
        row.nameHit:SetScript("OnMouseWheel", onWheel)
        row.title = UI.Label(row, "GameFontHighlightSmall")
        row.title:SetPoint("TOPLEFT", 24, -1)
        row.title:SetPoint("RIGHT", -4, 0)
        row.title:SetHeight(14)
        row.status = UI.Label(row, "GameFontDisableSmall")
        row.status:SetPoint("TOPLEFT", 24, -16)
        row.status:SetPoint("RIGHT", -4, 0)
        row.status:SetHeight(12)
        row.status:SetTextColor(0.75, 0.7, 0.55)
        row.acq = UI.Label(row, "GameFontHighlightSmall")
        row.acq:SetTextColor(0.9, 0.86, 0.75)
        row.body = UI.Label(row, "GameFontDisableSmall")
        row.body:SetTextColor(0.75, 0.72, 0.64)
        row:EnableMouseWheel(true)
        row:SetScript("OnMouseWheel", onWheel)
        row:Hide()
        compareRows[index] = row
        return row
    end

    local function showBody(recipe)
        local width = textWidth()
        child:SetWidth(width + 36)
        local y = 0
        materialsTitle:ClearAllPoints()
        materialsTitle:SetPoint("TOPLEFT", 4, -y)
        materialsTitle:Show()
        y = y + 20
        local schematic = recipe and RRP.Schematic and RRP.Schematic(recipe.key)
        local list = schematic and type(schematic.materials) == "table" and schematic.materials or nil
        if not list or #list == 0 then
            headMaterial:Hide()
            headNeeded:Hide()
            headBags:Hide()
            for i = 1, #materialRows do materialRows[i]:Hide() end
            materialStatus:ClearAllPoints()
            materialStatus:SetPoint("TOPLEFT", 4, -y)
            materialStatus:SetWidth(width)
            if not recipe then
                materialStatus:SetText("Materials not yet known.")
            elseif schematic and schematic.incomplete then
                materialStatus:SetText("The reagent list for this recipe is incomplete.")
            else
                materialStatus:SetText("This recipe has no reagent list in the database.")
            end
            materialStatus:Show()
            y = y + 28
        else
            materialStatus:Hide()
            headMaterial:ClearAllPoints()
            headMaterial:SetPoint("TOPLEFT", 26, -y)
            headMaterial:Show()
            headNeeded:ClearAllPoints()
            headNeeded:SetPoint("TOPLEFT", 202, -y)
            headNeeded:Show()
            headBags:ClearAllPoints()
            headBags:SetPoint("TOPLEFT", 272, -y)
            headBags:Show()
            y = y + 16
            for i = 1, #list do
                local material = list[i]
                local row = materialRow(i)
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", 4, -y)
                row:Show()
                UI.SetIcon(row.icon, RRP.ItemTexture(material.itemID))
                UI.Trim(row.name, RRP.ItemLabel(material.itemID), 160)
                row.name:SetTextColor(0.85, 0.82, 0.75)
                local owned = nil
                if RRP.BagsReadable() then owned = RRP.BagCount(material.itemID) end
                local amount = material.quantity or 0
                local needR, needG, needB = RRP.NeedColor(amount, owned)
                row.needed:SetText(RRP.Colorize(amount, needR, needG, needB))
                row.needed:SetTextColor(needR, needG, needB)
                if owned and owned > 0 then
                    row.owned:SetText(tostring(owned))
                else
                    row.owned:SetText("–")
                end
                row.owned:SetTextColor(1, 1, 1)
                y = y + 22
            end
            for i = #list + 1, #materialRows do materialRows[i]:Hide() end
        end

        y = y + 8
        if not recipe or not RRP.ComparisonsFor then
            comparisonTitle:Hide()
            intro:Hide()
            for i = 1, #compareRows do compareRows[i]:Hide() end
            compareKey = nil
            child:SetHeight(math.max(40, y))
            return
        end
        local view = RRP.ComparisonsFor(recipe)
        comparisonTitle:ClearAllPoints()
        comparisonTitle:SetPoint("TOPLEFT", 4, -y)
        comparisonTitle:Show()
        y = y + 20
        if compareKey ~= recipe.key then
            scroll:SetVerticalScroll(0)
            compareKey = recipe.key
        end

        local entries = {}
        local sources = view.sources or {}
        for i = 1, #sources do entries[#entries + 1] = sources[i] end
        local itemEntries = view.entries or {}
        for i = 1, #itemEntries do entries[#entries + 1] = itemEntries[i] end

        if type(view.header) == "string" and view.header ~= "" then
            intro:SetText(view.header)
            intro:Show()
            wrapLabel(intro, 24, -y, width)
            y = y + fitHeight(intro, 20) + 8
        else
            intro:Hide()
        end

        local shown = #entries
        if shown == 0 then shown = 1 end
        for i = 1, shown do compareRow(i) end
        for i = 1, #compareRows do
            local row = compareRows[i]
            local entry = entries[i]
            if i <= shown and (entry or #entries == 0) then
                row:Show()
                row:SetWidth(width + 32)
                row.entry = entry
                if not entry then
                    row.icon:SetTexture(nil)
                    row.title:SetText("None")
                    row.title:SetTextColor(0.7, 0.66, 0.58)
                    row.status:SetText("")
                    row.acq:SetText("")
                    row.acq:Hide()
                    row.body:SetText("")
                    row.body:Hide()
                    local rowH = 18
                    row:ClearAllPoints()
                    row:SetPoint("TOPLEFT", 0, -y)
                    row:SetHeight(rowH)
                    y = y + rowH
                else
                    local texture
                    if entry.kind == "source" and entry.scrollItemID then
                        texture = RRP.ItemTexture(entry.scrollItemID)
                        if RRP.RequestItem then RRP.RequestItem(entry.scrollItemID) end
                    else
                        texture = entry.itemID and RRP.ItemTexture(entry.itemID)
                        if entry.itemID and RRP.RequestItem then RRP.RequestItem(entry.itemID) end
                    end
                    if not texture and entry.spellID and type(GetSpellTexture) == "function" then
                        local ok, spellTexture = pcall(GetSpellTexture, entry.spellID)
                        if ok then texture = spellTexture end
                    end
                    if not texture then texture = RRP.ProfessionTexture[recipe.profession] end
                    UI.SetIcon(row.icon, texture)
                    row.title:SetText((entry.label or "Related Item") .. ": " .. (entry.name or ""))
                    row.title:SetTextColor(tone(entry.tier))
                    row.status:SetText("")
                    local sourceText
                    if entry.kind == "source" then
                        sourceText = "Same recipe from another listed source."
                    elseif type(entry.acquisition) == "string" and entry.acquisition ~= ""
                        and entry.acquisition ~= "Acquisition source not recorded." then
                        sourceText = entry.acquisition
                    end
                    local acqH = 0
                    wrapLabel(row.acq, 24, -18, width)
                    if sourceText then
                        row.acq:SetText(sourceText)
                        row.acq:Show()
                        acqH = fitHeight(row.acq, 15)
                    else
                        row.acq:SetText("")
                        row.acq:Hide()
                    end
                    local body = {}
                    if entry.kind == "source" and entry.lines then
                        for j = 1, #entry.lines do body[#body + 1] = entry.lines[j] end
                    end
                    if entry.similarities and #entry.similarities > 0 then
                        body[#body + 1] = "Similarities: " .. sentences(entry.similarities)
                    end
                    if entry.differences and #entry.differences > 0 then
                        body[#body + 1] = "Differences: " .. sentences(entry.differences)
                    end
                    local bodyText = table.concat(body, "\n")
                    local bodyH = 0
                    wrapLabel(row.body, 24, -(22 + acqH + 2), width)
                    if bodyText ~= "" then
                        row.body:SetText(bodyText)
                        row.body:Show()
                        bodyH = fitHeight(row.body, 14) + 4
                    else
                        row.body:SetText("")
                        row.body:Hide()
                    end
                    local rowH = 22 + acqH + bodyH + 6
                    row:ClearAllPoints()
                    row:SetPoint("TOPLEFT", 0, -y)
                    row:SetHeight(rowH)
                    y = y + rowH
                end
            else
                row.entry = nil
                row:Hide()
            end
        end
        child:SetHeight(math.max(40, y + 8))
    end

    function UI.RefreshDetails()
        local profile = RRP.GetProfile()
        local recipe = RRP.SelectedRecipe()
        if not recipe or not profile then
            name:SetText("No recipe selected")
            profession:SetText("")
            level:SetText("")
            pattern:SetText("")
            alert:Hide()
            forget:Hide()
            showBody(nil)
            return
        end
        UI.SetIcon(icon, RRP.RecipeTexture(recipe))
        UI.Trim(name, recipe.name, 300)
        local skill = recipe.profession or ""
        if recipe.skill then skill = skill .. "  " .. recipe.skill end
        local toneR, toneG, toneB = RRP.SkillTone(recipe.profession, recipe.skill)
        profession:SetText(RRP.Colorize(skill, toneR, toneG, toneB))
        profession:SetTextColor(toneR, toneG, toneB)
        local levelText = recipe.level and ("Level " .. recipe.level) or ""
        local playerLevel = UnitLevel and UnitLevel("player")
        local levelR, levelG, levelB = 0.9, 0.86, 0.75
        if recipe.level and type(playerLevel) == "number" then
            levelR, levelG, levelB = RRP.LevelTone(recipe.level, playerLevel)
        end
        level:SetText(levelText ~= "" and RRP.Colorize(levelText, levelR, levelG, levelB) or "")
        level:SetTextColor(levelR, levelG, levelB)
        local scrollId = RRP.ScrollID(recipe)
        pattern:SetText(scrollId and RRP.ItemLabel(scrollId) or "")
        pattern:SetTextColor(0.9, 0.86, 0.75)
        alert:Hide()
        if RRP.IsDiscovered(recipe) then forget:Show() else forget:Hide() end
        showBody(recipe)
    end
end
