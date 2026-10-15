local addonName, RRP = ...
local UI = RRP.UI
local function attachScroll(parent, top, bottom)
    local scroll = CreateFrame("ScrollFrame", nil, parent)
    scroll:SetPoint("TOPLEFT", 8, top)
    scroll:SetPoint("BOTTOMRIGHT", -8, bottom)
    scroll:EnableMouseWheel(true)
    local child = CreateFrame("Frame", nil, scroll)
    child:SetSize(320, 40)
    scroll:SetScrollChild(child)
    local function wheel(_, delta)
        local range = scroll:GetVerticalScrollRange() or 0
        local pos = (scroll:GetVerticalScroll() or 0) - delta * 24
        if pos < 0 then pos = 0 end
        if pos > range then pos = range end
        scroll:SetVerticalScroll(pos)
    end
    scroll:SetScript("OnMouseWheel", wheel)
    child:EnableMouseWheel(true)
    child:SetScript("OnMouseWheel", wheel)
    return scroll, child
end

function UI.BuildPlan(selected, materials, purchase)
    local selectedTitle = UI.Label(selected, "GameFontNormal", "Selected Recipes")
    selectedTitle:SetPoint("TOPLEFT", 10, -8)
    local colRecipe = UI.Label(selected, "GameFontDisableSmall", "Recipe")
    colRecipe:SetPoint("TOPLEFT", 10, -28)
    local colFavor = UI.Label(selected, "GameFontDisableSmall", "Favor")
    colFavor:SetPoint("TOPLEFT", 230, -28)
    colFavor:SetWidth(40)
    colFavor:SetJustifyH("CENTER")
    local favorTip = CreateFrame("Button", nil, selected)
    favorTip:SetPoint("TOPLEFT", 230, -26)
    favorTip:SetSize(44, 16)
    favorTip:SetScript("OnEnter", function(self)
        UI.ShowTip(self, "Merchant's Favor", "Cost to buy this recipe once.")
    end)
    favorTip:SetScript("OnLeave", UI.HideTip)

    local selectedScroll, selectedChild = attachScroll(selected, -44, 54)
    local selectedRows = {}
    local selectedEmpty = UI.Label(selectedChild, "GameFontDisableSmall", "No recipes in this plan. Click a recipe to add it.")
    selectedEmpty:SetPoint("TOPLEFT", 4, -4)
    selectedEmpty:SetWidth(300)
    local function makeSelectedRow()
        local row = CreateFrame("Button", nil, selectedChild)
        row:SetSize(310, 24)
        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetSize(20, 20)
        row.icon:SetPoint("LEFT", 2, 0)
        row.iconHit = CreateFrame("Button", nil, row)
        row.iconHit:SetSize(20, 20)
        row.iconHit:SetPoint("LEFT", 2, 0)
        row.iconHit:SetScript("OnEnter", function(self)
            if not row.recipe then return end
            RRP.ShowRecipe(row.recipe.key)
            UI.ShowRecipeTip(self, row.recipe)
        end)
        row.iconHit:SetScript("OnLeave", UI.HideTip)
        row.name = UI.Label(row, "GameFontHighlight")
        row.name:SetPoint("LEFT", 26, 0)
        row.name:SetWidth(190)
        row.favor = UI.Label(row, "GameFontHighlight")
        row.favor:SetPoint("LEFT", 210, 0)
        row.favor:SetWidth(44)
        row.favor:SetJustifyH("CENTER")
        row.favor:SetTextColor(1, 0.82, 0.35)
        row.remove = CreateFrame("Button", nil, row)
        row.remove:SetSize(18, 18)
        row.remove:SetPoint("RIGHT", -2, 0)
        row.remove:SetNormalFontObject(GameFontNormalSmall)
        row.remove:SetText("|cffff5544x|r")
        row.remove:SetScript("OnClick", function()
            if row.key then RRP.SetSelected(row.key, false) end
        end)
        row.remove:SetScript("OnEnter", function(self)
            UI.ShowTip(self, "Remove", "Takes this recipe out of the plan.")
        end)
        row.remove:SetScript("OnLeave", UI.HideTip)
        row:SetScript("OnEnter", function()
            if row.key then RRP.ShowRecipe(row.key) end
        end)
        row:SetScript("OnClick", function()
            if row.key then RRP.ShowRecipe(row.key) end
        end)
        row:Hide()
        return row
    end
    local total = UI.Label(selected, "GameFontNormalSmall")
    total:SetPoint("BOTTOMLEFT", 12, 36)
    total:SetWidth(310)

    local clearBtn = UI.Button(selected, "Clear Selection", 140, 22)
    clearBtn:SetPoint("BOTTOMLEFT", 8, 8)
    clearBtn:SetStyle("red")
    clearBtn:SetScript("OnClick", function() RRP.ClearPlan() end)

    local matTitle = UI.Label(materials, "GameFontNormal", "Material Summary (all selected)")
    matTitle:SetPoint("TOPLEFT", 10, -8)
    matTitle:SetWidth(190)
    local function matHead(text, x, width)
        local s = UI.Label(materials, "GameFontDisableSmall", text)
        s:SetPoint("TOPLEFT", x, -28)
        s:SetWidth(width)
        s:SetJustifyH(x == 10 and "LEFT" or "CENTER")
        return s
    end
    matHead("Material", 18, 160)
    matHead("Needed", 190, 64)
    local inBagsHead = matHead("In Bags", 258, 70)
    local bagWarn = UI.Label(materials, "GameFontDisableSmall", "Please open your bags.")
    bagWarn:SetPoint("TOPRIGHT", -8, -8)
    bagWarn:SetWidth(140)
    bagWarn:SetJustifyH("RIGHT")
    bagWarn:SetTextColor(1, 0.72, 0.28)
    bagWarn:Hide()
    local bagTip = CreateFrame("Button", nil, materials)
    bagTip:SetSize(70, 16)
    bagTip:SetPoint("TOPLEFT", inBagsHead, "TOPLEFT", 0, 0)
    bagTip:SetScript("OnEnter", function(self)
        UI.ShowTip(self, "In Bags", "Open your bags frequently to scan the inventory.")
    end)
    bagTip:SetScript("OnLeave", UI.HideTip)
    local matScroll, matChild = attachScroll(materials, -46, 8)
    local matRows = {}
    local function makeMatRow()
        local row = CreateFrame("Frame", nil, matChild)
        row:SetSize(320, 22)
        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetSize(18, 18)
        row.icon:SetPoint("LEFT", 2, 0)
        row.name = UI.Label(row, "GameFontHighlight")
        row.name:SetPoint("LEFT", 24, 0)
        row.name:SetWidth(155)
        row.needed = UI.Label(row, "GameFontHighlight")
        row.needed:SetPoint("LEFT", 182, 0)
        row.needed:SetWidth(64)
        row.needed:SetJustifyH("CENTER")
        row.owned = UI.Label(row, "GameFontHighlightSmall")
        row.owned:SetPoint("LEFT", 250, 0)
        row.owned:SetWidth(70)
        row.owned:SetJustifyH("CENTER")
        row:Hide()
        return row
    end

    local buyTitle = UI.Label(purchase, "GameFontNormal", "Purchase Plan")
    buyTitle:SetPoint("TOPLEFT", 10, -8)
    local function buyLine(y)
        local label = UI.Label(purchase, "GameFontHighlight")
        label:SetPoint("TOPLEFT", 12, y)
        label:SetWidth(180)
        local value = UI.Label(purchase, "GameFontHighlight")
        value:SetPoint("TOPRIGHT", -12, y)
        value:SetWidth(120)
        value:SetJustifyH("RIGHT")
        return label, value
    end
    local favorLabel, favorAmount = buyLine(-36)
    favorLabel:SetText("Total Merchant's Favor")
    local affordLabel, affordValue = buyLine(-62)
    affordLabel:SetText("Can afford?")
    local yoursLabel = UI.Label(purchase, "GameFontHighlight")
    yoursLabel:SetPoint("BOTTOMLEFT", 12, 44)
    yoursLabel:SetWidth(210)
    yoursLabel:SetText("Your Merchant's Favor")
    local yoursValue = UI.Label(purchase, "GameFontHighlight")
    yoursValue:SetPoint("BOTTOMRIGHT", -12, 44)
    yoursValue:SetWidth(110)
    yoursValue:SetJustifyH("RIGHT")
    yoursValue:SetTextColor(1, 0.82, 0.35)
    local openList = UI.Button(purchase, "Open Shopping List", 320, 26)
    openList:SetPoint("BOTTOM", 0, 10)
    openList:SetStyle("red")
    openList:SetScript("OnClick", function()
        if RRP.ToggleShopping then RRP.ToggleShopping() end
    end)

    function UI.RefreshPlan()
        local profile = RRP.GetProfile()
        if not profile then return end
        local armed = RRP.clearArmed and GetTime and (GetTime() - RRP.clearArmed <= 6)
        if RRP.clearArmed and not armed then RRP.clearArmed = nil end
        clearBtn:SetText(armed and "Confirm clear" or "Clear Selection")
        clearBtn:SetStyle(armed and "armed" or "red")

        local entries = {}
        local selectedCount, favorSum, unknownFavor = 0, 0, false
        for key, count in pairs(profile.plan or {}) do
            local chosen = count == true or (type(count) == "number" and count > 0)
            local recipe = chosen and RRP.GetByKey(key)
            if recipe then
                entries[#entries + 1] = recipe
                selectedCount = selectedCount + 1
                local favor = RRP.PlanFavor and RRP.PlanFavor(recipe) or recipe.favor
                if favor and favor > 0 then favorSum = favorSum + favor
                elseif favor == nil then unknownFavor = true end
            end
        end
        table.sort(entries, function(a, b) return (a.name or "") < (b.name or "") end)
        while #selectedRows < #entries do
            selectedRows[#selectedRows + 1] = makeSelectedRow()
        end
        for i, row in ipairs(selectedRows) do
            local recipe = entries[i]
            row.recipe = recipe
            row.key = recipe and recipe.key
            if recipe then
                row:Show()
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", 0, -((i - 1) * 24))
                UI.SetIcon(row.icon, RRP.RecipeTexture(recipe))
                UI.Trim(row.name, recipe.name, 180)
                local learned = RRP.LearnState and RRP.LearnState(recipe) == "learned"
                local favor = RRP.PlanFavor and RRP.PlanFavor(recipe) or recipe.favor
                if learned then
                    row.favor:SetText("0")
                    row.favor:SetTextColor(0.55, 0.7, 0.55)
                else
                    row.favor:SetText(favor and tostring(favor) or "?")
                    row.favor:SetTextColor(1, 0.82, 0.35)
                end
            else
                row:Hide()
            end
        end
        if #entries == 0 then selectedEmpty:Show() else selectedEmpty:Hide() end
        selectedChild:SetHeight(math.max(24, #entries * 24))
        local selectedRange = selectedScroll:GetVerticalScrollRange() or 0
        if (selectedScroll:GetVerticalScroll() or 0) > selectedRange then
            selectedScroll:SetVerticalScroll(selectedRange)
        end
        total:SetText("Total    " .. selectedCount .. " selected recipes    " .. favorSum .. (unknownFavor and "+" or "") .. " Favor")

        local calc = RRP.Calculate()
        local mats = {}
        for id, amount in pairs(calc.items) do
            local owned = nil
            if RRP.BagsReadable() then owned = RRP.BagCount(id) end
            local short = 0
            if owned ~= nil then short = math.max(0, amount - owned) end
            mats[#mats + 1] = {id = id, amount = amount, owned = owned, short = short}
        end
        table.sort(mats, function(a, b)
            if a.short ~= b.short then return a.short > b.short end
            return RRP.ItemLabel(a.id) < RRP.ItemLabel(b.id)
        end)
        while #matRows < #mats do
            matRows[#matRows + 1] = makeMatRow()
        end
        for i, row in ipairs(matRows) do
            local item = mats[i]
            if item then
                row:Show()
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", 0, -((i - 1) * 22))
                UI.SetIcon(row.icon, RRP.ItemTexture(item.id))
                UI.Trim(row.name, RRP.ItemLabel(item.id), 150)
                local needR, needG, needB = 0.95, 0.92, 0.84
                if item.owned ~= nil then
                    if item.owned >= item.amount then needR, needG, needB = 0.3, 0.9, 0.35
                    else needR, needG, needB = 0.95, 0.25, 0.2 end
                end
                row.needed:SetText(RRP.Colorize(item.amount, needR, needG, needB))
                row.needed:SetTextColor(needR, needG, needB)
                if item.owned == nil then
                    row.owned:SetText("-")
                    row.owned:SetTextColor(0.7, 0.65, 0.5)
                else
                    row.owned:SetText(RRP.Colorize(item.owned, needR, needG, needB))
                    row.owned:SetTextColor(needR, needG, needB)
                end
            else
                row:Hide()
            end
        end
        matChild:SetHeight(math.max(22, #mats * 22))
        local matRange = matScroll:GetVerticalScrollRange() or 0
        if (matScroll:GetVerticalScroll() or 0) > matRange then
            matScroll:SetVerticalScroll(matRange)
        end
        if RRP.BagsStale and RRP.BagsStale() then bagWarn:Show() else bagWarn:Hide() end

        favorAmount:SetText(tostring(calc.favor) .. (calc.unknownFavor and "+" or ""))
        favorAmount:SetTextColor(1, 0.82, 0.35)
        local balance = RRP.FavorBalance()
        local shortfall = RRP.FavorShortfall(balance, calc.favor, calc.unknownFavor)
        if type(balance) == "number" then
            yoursValue:SetText(tostring(balance))
            yoursValue:SetTextColor(1, 0.82, 0.35)
        else
            yoursValue:SetText("Unknown")
            yoursValue:SetTextColor(0.7, 0.65, 0.5)
        end
        if type(balance) ~= "number" then
            affordValue:SetText("Unknown")
            affordValue:SetTextColor(0.7, 0.65, 0.5)
        elseif calc.unknownFavor then
            affordValue:SetText("Costs incomplete")
            affordValue:SetTextColor(1, 0.7, 0.3)
        elseif shortfall == 0 then
            affordValue:SetText("Yes")
            affordValue:SetTextColor(0.4, 0.9, 0.4)
        else
            affordValue:SetText("No")
            affordValue:SetTextColor(1, 0.3, 0.25)
        end
    end
end
