local addonName, RRP = ...
local UI = RRP.UI
local MATERIAL_ROWS = 5

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
    local materialsTitle = UI.Label(panel, "GameFontNormal", "Materials")
    materialsTitle:SetPoint("TOPLEFT", 12, -92)
    local function matHead(text, x, width)
        local s = UI.Label(panel, "GameFontDisableSmall", text)
        s:SetPoint("TOPLEFT", x, -112)
        s:SetWidth(width)
        s:SetJustifyH(x < 40 and "LEFT" or "CENTER")
        return s
    end
    matHead("Material", 34, 180)
    matHead("Needed", 220, 64)
    matHead("In Bags", 290, 70)
    local materialRows = {}
    for i = 1, MATERIAL_ROWS do
        local row = CreateFrame("Frame", nil, panel)
        row:SetSize(360, 20)
        row:SetPoint("TOPLEFT", 12, -130 - (i - 1) * 20)
        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetSize(16, 16)
        row.icon:SetPoint("LEFT", 0, 0)
        row.name = UI.Label(row, "GameFontHighlight")
        row.name:SetPoint("LEFT", 22, 0)
        row.name:SetWidth(180)
        row.needed = UI.Label(row, "GameFontHighlightSmall")
        row.needed:SetPoint("LEFT", 208, 0)
        row.needed:SetWidth(64)
        row.needed:SetJustifyH("CENTER")
        row.owned = UI.Label(row, "GameFontHighlightSmall")
        row.owned:SetPoint("LEFT", 278, 0)
        row.owned:SetWidth(70)
        row.owned:SetJustifyH("CENTER")
        row:Hide()
        materialRows[i] = row
    end
    local materialStatus = UI.Label(panel, "GameFontHighlightSmall")
    materialStatus:SetPoint("TOPLEFT", 12, -132)
    materialStatus:SetWidth(360)
    materialStatus:SetHeight(32)
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

    local comparisonTitle = UI.Label(panel, "GameFontNormal", "Recipe Comparisons")
    comparisonTitle:SetPoint("TOPLEFT", 12, -236)
    comparisonTitle:Hide()
    local comparisonNote = UI.Label(panel, "GameFontDisableSmall")
    comparisonNote:SetPoint("TOPLEFT", 12, -254)
    comparisonNote:SetSize(344, 28)
    comparisonNote:SetJustifyV("TOP")
    comparisonNote:SetTextColor(0.65, 0.6, 0.5)
    comparisonNote:Hide()
    local scroll = CreateFrame("ScrollFrame", nil, panel)
    scroll:SetPoint("TOPLEFT", 8, -284)
    scroll:SetPoint("BOTTOMRIGHT", -8, 40)
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
    local COMPARE_ROWS = 16
    local ROW_H = 76
    -- All research summaries are scrollable, not clipped into fixed 76px rows.
    local intro = UI.Label(child, "GameFontDisableSmall")
    intro:SetPoint("TOPLEFT", 24, 0)
    intro:SetWidth(316)
    intro:SetJustifyV("TOP")
    intro:SetTextColor(0.76, 0.74, 0.66)
    intro:Hide()
    local compareRows = {}
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
    for i = 1, COMPARE_ROWS do
        local row = CreateFrame("Frame", nil, child)
        row:SetSize(344, ROW_H)
        row:SetPoint("TOPLEFT", 0, -((i - 1) * ROW_H))
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
        row.acq:SetPoint("TOPLEFT", 24, -30)
        row.acq:SetPoint("RIGHT", -4, 0)
        row.acq:SetHeight(12)
        row.acq:SetTextColor(0.9, 0.86, 0.75)
        row.body = UI.Label(row, "GameFontDisableSmall")
        row.body:SetPoint("TOPLEFT", 24, -44)
        row.body:SetPoint("RIGHT", -4, 0)
        row.body:SetHeight(30)
        row.body:SetJustifyV("TOP")
        row.body:SetTextColor(0.75, 0.72, 0.64)
        row:EnableMouseWheel(true)
        row:SetScript("OnMouseWheel", onWheel)
        row:Hide()
        compareRows[i] = row
    end
    scroll:Hide()
    local compareKey = nil
    local function tone(tier)
        if tier == "duplicate" or tier == "equivalent" then return 0.35, 0.9, 0.4 end
        if tier == "alternative" then return 0.78, 0.88, 0.5 end
        if tier == "related" or tier == "slot" or tier == "reported" then return 0.95, 0.72, 0.28 end
        return 0.7, 0.66, 0.58
    end
    local function fitHeight(label, minimum)
        label:SetHeight(900)
        local h = type(label.GetStringHeight) == "function" and label:GetStringHeight() or 0
        h = tonumber(h) or 0
        h = math.max(minimum, math.ceil(h + 2))
        label:SetHeight(h)
        return h
    end
    local function sourceDomain(entry)
        local refs = entry and entry.references
        local url = refs and refs[1]
        if type(url) ~= "string" then return nil end
        return url:match("^https?://([^/]+)")
    end
    local function showComparisons(recipe)
        if not recipe or not RRP.ComparisonsFor then
            comparisonTitle:Hide()
            comparisonNote:Hide()
            scroll:Hide()
            compareKey = nil
            return
        end
        local view = RRP.ComparisonsFor(recipe)
        comparisonTitle:Show()
        comparisonNote:Hide()
        scroll:Show()
        scroll:ClearAllPoints()
        scroll:SetPoint("TOPLEFT", 8, -254)
        scroll:SetPoint("BOTTOMRIGHT", -8, alert:IsShown() and 78 or 36)
        if compareKey ~= recipe.key then
            scroll:SetVerticalScroll(0)
            compareKey = recipe.key
        end

        local offset = 0
        if type(view.header) == "string" and view.header ~= "" then
            intro:SetText(view.header)
            intro:Show()
            intro:ClearAllPoints()
            intro:SetPoint("TOPLEFT", 24, 0)
            offset = fitHeight(intro, 20) + 12
        else
            intro:Hide()
        end

        local entries = {}
        local sources = view.sources or {}
        for i = 1, #sources do entries[#entries + 1] = sources[i] end
        local itemEntries = view.entries or {}
        for i = 1, #itemEntries do entries[#entries + 1] = itemEntries[i] end
        if #entries == 0 then
            local row = compareRows[1]
            row:Show()
            row.entry = nil
            row.icon:SetTexture(nil)
            row.title:SetText(RRP.ComparisonLabel and RRP.ComparisonLabel.none or "No Comparison Recorded")
            row.title:SetTextColor(0.7, 0.66, 0.58)
            row.status:SetText("")
            row.acq:SetText("")
            row.body:SetText(view.note or "No comparison has been recorded for this recipe yet.")
            row.body:ClearAllPoints()
            row.body:SetPoint("TOPLEFT", 24, -26)
            local rowH = 28 + fitHeight(row.body, 24) + 8
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", 0, -offset)
            row:SetHeight(rowH)
            for i = 2, #compareRows do compareRows[i]:Hide() end
            child:SetHeight(offset + rowH)
            return
        end

        local shown = math.min(#entries, #compareRows)
        for i = 1, #compareRows do
            local row = compareRows[i]
            local entry = entries[i]
            if i <= shown and entry then
                row:Show()
                row.entry = entry
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
                    sourceText = "Other sources listed for this same recipe pattern"
                else
                    sourceText = "Acquisition: " .. (entry.acquisition or "Source not recorded.")
                end
                row.acq:SetText(sourceText)
                row.acq:ClearAllPoints()
                row.acq:SetPoint("TOPLEFT", 24, -18)
                local acqH = fitHeight(row.acq, 15)

                local body = {}
                if entry.kind == "source" and entry.lines then
                    for j = 1, #entry.lines do body[#body + 1] = entry.lines[j] end
                end
                if entry.similarities and #entry.similarities > 0 then
                    body[#body + 1] = "Similarities: " .. table.concat(entry.similarities, " ")
                end
                if entry.differences and #entry.differences > 0 then
                    body[#body + 1] = "Differences: " .. table.concat(entry.differences, " ")
                end
                local domain = sourceDomain(entry)
                if domain then body[#body + 1] = "Reference: " .. domain end
                if shown < #entries and i == shown then
                    body[#body + 1] = "+" .. (#entries - shown) .. " more comparisons."
                end
                row.body:SetText(table.concat(body, "\n"))
                row.body:ClearAllPoints()
                row.body:SetPoint("TOPLEFT", 24, -(22 + acqH + 4))
                local rowH = 22 + acqH + 4 + fitHeight(row.body, 25) + 10
                row:SetHeight(math.max(ROW_H, rowH))
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", 0, -offset)
                offset = offset + row:GetHeight()
            else
                row.entry = nil
                row:Hide()
            end
        end
        child:SetHeight(math.max(ROW_H, offset))
    end

    local function showMaterials(recipe)
        local schematic = RRP.Schematic and RRP.Schematic(recipe.key)
        local list = schematic and type(schematic.materials) == "table" and schematic.materials or nil
        if not list or #list == 0 then
            for _, row in ipairs(materialRows) do row:Hide() end
            materialStatus:Show()
            if schematic and schematic.incomplete then
                materialStatus:SetText("The reagent list for this recipe is incomplete.")
            else
                materialStatus:SetText("This recipe has no reagent list in the database.")
            end
            return
        end
        materialStatus:Hide()
        for i, row in ipairs(materialRows) do
            local material = list[i]
            if material then
                row:Show()
                UI.SetIcon(row.icon, RRP.ItemTexture(material.itemID))
                UI.Trim(row.name, RRP.ItemLabel(material.itemID), 170)
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
            else
                row:Hide()
            end
        end
        if #list > #materialRows then
            local last = materialRows[#materialRows]
            last.icon:SetTexture(nil)
            last.name:SetText("+" .. (#list - #materialRows + 1) .. " more")
            last.needed:SetText("")
            last.owned:SetText("")
        end
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
            for _, row in ipairs(materialRows) do row:Hide() end
            materialStatus:SetText("Materials not yet known.")
            materialStatus:Show()
            forget:Hide()
            showComparisons(nil)
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
        showMaterials(recipe)
        if recipe.alternative and recipe.alternative ~= "" then
            alertText:SetText(recipe.alternative)
            alert:Show()
        else
            alert:Hide()
        end
        if RRP.IsDiscovered(recipe) then forget:Show() else forget:Hide() end
        showComparisons(recipe)
    end
end
