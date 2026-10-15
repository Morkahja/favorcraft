local addonName, RRP = ...
local UI = RRP.UI
local ROWS = 9
local ROW_H = 34

function UI.BuildBrowser(panel)
    panel:EnableMouseWheel(true)
    panel:SetScript("OnMouseWheel", function(_, delta)
        local profile = RRP.GetProfile()
        if not profile then return end
        if delta > 0 then profile.page = math.max(1, (profile.page or 1) - 1)
        else profile.page = (profile.page or 1) + 1 end
        RRP.Refresh()
    end)

    local search = CreateFrame("EditBox", "FavorCraftSearch", panel, "InputBoxTemplate")
    search:SetSize(210, 20)
    search:SetPoint("TOPLEFT", 12, -10)
    search:SetAutoFocus(false)
    search:SetMaxLetters(40)
    search:SetFontObject(GameFontHighlightSmall)
    search:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    search:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    local placeholder = search:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    placeholder:SetPoint("LEFT", search, "LEFT", 2, 0)
    placeholder:SetText("Search recipes...")
    local suppress = false
    local function syncPlaceholder()
        if search:GetText() == "" and not search:HasFocus() then placeholder:Show() else placeholder:Hide() end
    end
    search:SetScript("OnEditFocusGained", syncPlaceholder)
    search:SetScript("OnEditFocusLost", syncPlaceholder)
    search:SetScript("OnTextChanged", function(self)
        syncPlaceholder()
        if suppress or not RRP.ready then return end
        RRP.SetSearch(self:GetText())
    end)

    local hideLearned = UI.Check(panel, "Hide learned recipes", 160)
    hideLearned:SetPoint("TOPLEFT", 250, -10)
    hideLearned.tip = "Hide learned recipes"
    hideLearned.tipLine = "Hides recipes this character already has marked learned."
    hideLearned.onToggle = function(on) RRP.SetHideLearned(on) end

    local function header(text, x, width, key, tip)
        local b = CreateFrame("Button", nil, panel)
        b:SetSize(width, 18)
        b:SetPoint("TOPLEFT", x, -36)
        b.label = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        b.label:SetAllPoints()
        b.label:SetJustifyH(key and "CENTER" or "LEFT")
        b.label:SetText(text)
        b.key = key
        b.base = text
        b:SetScript("OnClick", function()
            if key then RRP.SetSort(key) end
        end)
        b:SetScript("OnEnter", function(self)
            self.label:SetTextColor(1, 0.9, 0.45)
            if tip then UI.ShowTip(self, text, tip) end
        end)
        b:SetScript("OnLeave", function(self)
            self.label:SetTextColor(1, 0.82, 0)
            UI.HideTip()
        end)
        return b
    end
    local headers = {
        header("Recipe", 36, 200, "name", "Sort by recipe name."),
        header("Skill", 248, 48, "skill", "Sort by required skill."),
        header("Favor", 298, 48, "favor", "Sort by Merchant's Favor. This is the cost to buy the recipe once."),
        header("Learned", 348, 58, nil, "Green check: this character knows the recipe. Red x: a complete scan of that profession did not list it. Question mark: not checked yet."),
        header("Level", 408, 48, "level", "Required level of the crafted item. Green: you can use it. Orange: 1 to 3 levels above you. Red: higher than that."),
    }

    local rows = {}
    for i = 1, ROWS do
        local row = CreateFrame("Frame", nil, panel)
        row:SetSize(462, ROW_H - 2)
        row:SetPoint("TOPLEFT", 8, -56 - (i - 1) * ROW_H)
        row.bg = row:CreateTexture(nil, "BACKGROUND")
        row.bg:SetAllPoints()
        row.bg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
        row.sel = row:CreateTexture(nil, "BORDER")
        row.sel:SetAllPoints()
        row.sel:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
        row.sel:SetBlendMode("ADD")
        row.sel:Hide()
        row.hit = CreateFrame("Button", nil, row)
        row.hit:SetAllPoints()
        row.hit:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
        local highlight = row.hit:GetHighlightTexture()
        if highlight then highlight:SetAlpha(0.25) end
        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetSize(24, 24)
        row.icon:SetPoint("LEFT", 4, 0)
        row.iconHit = CreateFrame("Button", nil, row)
        row.iconHit:SetSize(24, 24)
        row.iconHit:SetPoint("LEFT", 4, 0)
        row.iconHit:SetFrameLevel(row.hit:GetFrameLevel() + 3)
        row.iconHit:SetScript("OnEnter", function(self)
            if not row.recipe then return end
            RRP.ShowRecipe(row.recipe.key)
            UI.ShowRecipeTip(self, row.recipe)
        end)
        row.iconHit:SetScript("OnLeave", UI.HideTip)
        row.iconHit:SetScript("OnClick", function()
            if not row.recipe then return end
            RRP.SetSelected(row.recipe.key, not RRP.PlanOn(row.recipe.key))
        end)
        row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        UI.GrowFont(row.name, 1.08)
        row.name:SetPoint("LEFT", 32, 0)
        row.name:SetWidth(200)
        row.name:SetJustifyH("LEFT")
        row.skill = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        UI.GrowFont(row.skill, 1.08)
        row.skill:SetPoint("LEFT", 236, 0)
        row.skill:SetWidth(48)
        row.skill:SetJustifyH("CENTER")
        row.favor = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        UI.GrowFont(row.favor, 1.08)
        row.favor:SetPoint("LEFT", 286, 0)
        row.favor:SetWidth(48)
        row.favor:SetJustifyH("CENTER")
        row.learnedMark = row:CreateTexture(nil, "OVERLAY")
        row.learnedMark:SetSize(18, 18)
        row.learnedMark:SetPoint("LEFT", 364, 0)
        row.learnedMark:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
        row.learnedMark:SetVertexColor(0.25, 0.85, 0.35)
        row.learnedMiss = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        UI.GrowFont(row.learnedMiss, 1.2)
        row.learnedMiss:SetPoint("LEFT", 360, 0)
        row.learnedMiss:SetWidth(24)
        row.learnedMiss:SetJustifyH("CENTER")
        row.learnedMiss:SetText("|cffff4444x|r")
        row.level = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        UI.GrowFont(row.level, 1.08)
        row.level:SetPoint("LEFT", 404, 0)
        row.level:SetWidth(48)
        row.level:SetJustifyH("CENTER")
        row.hit:SetScript("OnEnter", function()
            if row.recipe then RRP.ShowRecipe(row.recipe.key) end
        end)
        row.hit:SetScript("OnClick", function()
            if not row.recipe then return end
            RRP.SetSelected(row.recipe.key, not RRP.PlanOn(row.recipe.key))
        end)
        rows[i] = row
    end

    local empty = UI.Label(panel, "GameFontHighlight", "No recipes match these filters.")
    empty:SetPoint("TOPLEFT", 24, -180)
    empty:SetWidth(420)
    empty:Hide()

    local showing = UI.Label(panel, "GameFontDisableSmall")
    showing:SetPoint("BOTTOMLEFT", 12, 12)
    showing:SetWidth(220)

    local prev = CreateFrame("Button", nil, panel)
    prev:SetSize(22, 22)
    prev:SetPoint("BOTTOMRIGHT", -78, 8)
    prev:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
    prev:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
    prev:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
    local page = UI.Label(panel, "GameFontHighlightSmall")
    page:SetPoint("LEFT", prev, "RIGHT", 4, 0)
    page:SetWidth(42)
    page:SetJustifyH("CENTER")
    local nextB = CreateFrame("Button", nil, panel)
    nextB:SetSize(22, 22)
    nextB:SetPoint("LEFT", page, "RIGHT", 4, 0)
    nextB:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
    nextB:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
    nextB:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
    prev:SetScript("OnClick", function()
        local profile = RRP.GetProfile()
        if profile then profile.page = math.max(1, (profile.page or 1) - 1) end
        RRP.Refresh()
    end)
    nextB:SetScript("OnClick", function()
        local profile = RRP.GetProfile()
        if profile then profile.page = (profile.page or 1) + 1 end
        RRP.Refresh()
    end)

    function UI.RefreshBrowser()
        local profile = RRP.GetProfile()
        if not profile then return end
        local known = type(profile.known) == "table" and profile.known or {}
        local shown = profile.search or ""
        if not search:HasFocus() and search:GetText() ~= shown then
            suppress = true
            search:SetText(shown)
            suppress = false
        end
        syncPlaceholder()
        hideLearned:SetChecked(profile.hideLearned and true or false)
        for _, h in ipairs(headers) do
            local mark = ""
            local active = h.key and (profile.sortKey == h.key or (h.key == "name" and not profile.sortKey))
            if active then mark = profile.sortDesc and " v" or " ^" end
            h.label:SetText(h.base .. mark)
        end
        local list = RRP.VisibleRecipes()
        local pages = math.max(1, math.ceil(#list / ROWS))
        profile.page = math.max(1, math.min(profile.page or 1, pages))
        local start = (profile.page - 1) * ROWS + 1
        for i, row in ipairs(rows) do
            local recipe = list[start + i - 1]
            row.recipe = recipe
            if recipe then
                row:Show()
                local inPlan = RRP.PlanOn and RRP.PlanOn(recipe.key)
                local learnState = RRP.LearnState and RRP.LearnState(recipe) or (known[recipe.key] and "learned" or "unknown")
                local isKnown = learnState == "learned"
                local recommended = RRP.BuildMatch and RRP.BuildMatch(recipe)
                if inPlan then
                    row.sel:Show()
                    row.bg:SetVertexColor(0.55, 0.38, 0.05, 0.72)
                    row.name:SetTextColor(1, 0.86, 0.35)
                else
                    row.sel:Hide()
                    if i % 2 == 0 then row.bg:SetVertexColor(1, 1, 1, 0.035)
                    else row.bg:SetVertexColor(0, 0, 0, 0.2) end
                    if recommended then row.name:SetTextColor(0.95, 0.92, 0.84)
                    elseif isKnown then row.name:SetTextColor(0.45, 0.62, 0.48)
                    else row.name:SetTextColor(0.55, 0.5, 0.42) end
                end
                UI.SetIcon(row.icon, RRP.RecipeTexture(recipe))
                UI.Trim(row.name, recipe.name, 185)
                local skillR, skillG, skillB = RRP.SkillTone(recipe.profession, recipe.skill)
                row.skill:SetText(RRP.Colorize(recipe.skill or "?", skillR, skillG, skillB))
                row.skill:SetTextColor(skillR, skillG, skillB)
                local favor = RRP.RecipeFavor and RRP.RecipeFavor(recipe) or recipe.favor
                row.favor:SetText(favor or "?")
                row.favor:SetTextColor(1, 0.82, 0.35)
                if learnState == "learned" then
                    row.learnedMark:Show()
                    row.learnedMiss:Hide()
                elseif learnState == "unlearned" then
                    row.learnedMark:Hide()
                    row.learnedMiss:Show()
                    row.learnedMiss:SetText("|cffff4444x|r")
                else
                    row.learnedMark:Hide()
                    row.learnedMiss:Show()
                    row.learnedMiss:SetText("|cffaa9988?|r")
                end
                local playerLevel = UnitLevel and UnitLevel("player") or nil
                if recipe.level then
                    row.level:SetText(tostring(recipe.level))
                    row.level:SetTextColor(RRP.LevelTone(recipe.level, playerLevel))
                else
                    row.level:SetText("-")
                    row.level:SetTextColor(0.7, 0.65, 0.55)
                end
            else
                row:Hide()
            end
        end
        if #list == 0 then empty:Show() else empty:Hide() end
        if #list == 0 then
            showing:SetText("No matching recipes")
        else
            local last = math.min(#list, start + ROWS - 1)
            showing:SetText(string.format("Showing %d - %d of %d", start, last, #list))
        end
        page:SetText(profile.page .. " / " .. pages)
        prev:SetAlpha(profile.page > 1 and 1 or 0.35)
        nextB:SetAlpha(profile.page < pages and 1 or 0.35)
    end
end
