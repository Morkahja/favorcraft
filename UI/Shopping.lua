local addonName, RRP = ...
local UI = RRP.UI
local ROW_COUNT = 18
local ROW_H = 20

function UI.BuildShopping()
    local shop = CreateFrame("Frame", "FavorcraftShoppingListFrame", UIParent, "BackdropTemplate")
    shop:SetSize(600, 470)
    shop:SetPoint("CENTER")
    shop:SetFrameStrata("FULLSCREEN_DIALOG")
    shop:EnableMouse(true)
    shop:SetMovable(true)
    shop:SetClampedToScreen(true)
    shop:RegisterForDrag("LeftButton")
    shop:SetScript("OnDragStart", function(self) self:StartMoving() end)
    shop:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        UI.SaveWindow(self, "shop")
    end)
    if shop.SetBackdrop then
        shop:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = false, edgeSize = 32,
            insets = {left = 11, right = 12, top = 12, bottom = 11},
        })
        shop:SetBackdropColor(0.07, 0.06, 0.05, 1)
        shop:SetBackdropBorderColor(0.62, 0.48, 0.18, 1)
    end
    shop:Hide()
    if UISpecialFrames then table.insert(UISpecialFrames, shop:GetName()) end
    UI.RestoreWindow(shop, "shop", true)

    local title = UI.Label(shop, "GameFontNormalLarge", "Shopping List")
    title:SetPoint("TOP", 0, -14)
    title:SetWidth(360)
    title:SetJustifyH("CENTER")
    title:SetTextColor(1, 0.82, 0)
    local close = UI.Button(shop, "X", 22, 22)
    close:SetPoint("TOPRIGHT", -10, -10)
    close:SetStyle("red")
    close:SetScript("OnClick", function() shop:Hide() end)

    local summary = UI.Label(shop, "GameFontHighlightSmall")
    summary:SetPoint("TOPLEFT", 18, -40)
    summary:SetSize(420, 16)
    summary:SetJustifyV("MIDDLE")

    local copyBtn = UI.Button(shop, "Copy List", 110, 22)
    copyBtn:SetPoint("TOPRIGHT", -40, -36)
    copyBtn.tip = "Copy List"
    copyBtn.tipLine = "Opens the materials and how many you need, one item per line."

    local function columnHead(text, x, width, justify)
        local s = UI.Label(shop, "GameFontDisableSmall", text)
        s:SetPoint("TOPLEFT", x, -60)
        s:SetWidth(width)
        s:SetJustifyH(justify or "CENTER")
        return s
    end
    columnHead("Material", 40, 260, "LEFT")
    columnHead("Needed", 328, 70, "CENTER")
    columnHead("In Bags", 402, 70, "CENTER")
    columnHead("Missing", 476, 90, "CENTER")

    local rows = {}
    for i = 1, ROW_COUNT do
        local row = CreateFrame("Frame", nil, shop)
        row:SetSize(564, ROW_H)
        row:SetPoint("TOPLEFT", 18, -76 - (i - 1) * ROW_H)
        row.bg = row:CreateTexture(nil, "BACKGROUND")
        row.bg:SetAllPoints()
        row.bg:SetTexture("Interface\\Buttons\\WHITE8X8")
        if i % 2 == 0 then row.bg:SetVertexColor(0.11, 0.09, 0.07, 1)
        else row.bg:SetVertexColor(0.16, 0.13, 0.09, 1) end
        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetSize(16, 16)
        row.icon:SetPoint("LEFT", 2, 0)
        row.name = UI.Label(row, "GameFontHighlightSmall")
        row.name:SetPoint("LEFT", 22, 0)
        row.name:SetWidth(280)
        row.needed = UI.Label(row, "GameFontHighlightSmall")
        row.needed:SetPoint("LEFT", 310, 0)
        row.needed:SetWidth(70)
        row.needed:SetJustifyH("CENTER")
        row.owned = UI.Label(row, "GameFontHighlightSmall")
        row.owned:SetPoint("LEFT", 384, 0)
        row.owned:SetWidth(70)
        row.owned:SetJustifyH("CENTER")
        row.missing = UI.Label(row, "GameFontHighlightSmall")
        row.missing:SetPoint("LEFT", 458, 0)
        row.missing:SetWidth(90)
        row.missing:SetJustifyH("CENTER")
        row.hit = CreateFrame("Button", nil, row)
        row.hit:SetAllPoints()
        row.hit:SetScript("OnEnter", function(self)
            if row.itemID then UI.ShowItemTip(self, row.itemID) end
        end)
        row.hit:SetScript("OnLeave", UI.HideTip)
        row:Hide()
        rows[i] = row
    end

    local pageLabel = UI.Label(shop, "GameFontHighlightSmall")
    pageLabel:SetPoint("BOTTOM", 0, 14)
    pageLabel:SetWidth(80)
    pageLabel:SetJustifyH("CENTER")
    local prev = CreateFrame("Button", nil, shop)
    prev:SetSize(22, 22)
    prev:SetPoint("RIGHT", pageLabel, "LEFT", -4, 0)
    prev:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
    prev:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
    local nextB = CreateFrame("Button", nil, shop)
    nextB:SetSize(22, 22)
    nextB:SetPoint("LEFT", pageLabel, "RIGHT", 4, 0)
    nextB:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
    nextB:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
    local page = 1
    prev:SetScript("OnClick", function()
        page = math.max(1, page - 1)
        RRP.RefreshShopping()
    end)
    nextB:SetScript("OnClick", function()
        page = page + 1
        RRP.RefreshShopping()
    end)
    shop:EnableMouseWheel(true)
    shop:SetScript("OnMouseWheel", function(_, delta)
        if delta > 0 then page = math.max(1, page - 1) else page = page + 1 end
        RRP.RefreshShopping()
    end)

    local copy = CreateFrame("Frame", nil, shop, "BackdropTemplate")
    copy:SetSize(560, 390)
    copy:SetPoint("CENTER", 0, -8)
    copy:SetFrameLevel(shop:GetFrameLevel() + 20)
    copy:EnableMouse(true)
    if copy.SetBackdrop then
        copy:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = false, edgeSize = 24,
            insets = {left = 8, right = 8, top = 8, bottom = 8},
        })
        copy:SetBackdropColor(0.05, 0.045, 0.04, 1)
        copy:SetBackdropBorderColor(0.85, 0.68, 0.28, 1)
    end
    copy:Hide()
    local copyTitle = UI.Label(copy, "GameFontNormal", "Copy Shopping List")
    copyTitle:SetPoint("TOPLEFT", 16, -12)
    copyTitle:SetWidth(360)
    local copyNote = UI.Label(copy, "GameFontDisableSmall", "Ctrl+A, then Ctrl+C. Each line is the item and how many you need.")
    copyNote:SetPoint("TOPRIGHT", -40, -14)
    copyNote:SetWidth(280)
    copyNote:SetJustifyH("RIGHT")
    local copyClose = UI.Button(copy, "Close", 70, 20)
    copyClose:SetPoint("BOTTOMRIGHT", -12, 10)
    copyClose:SetScript("OnClick", function() copy:Hide() end)
    local scroll = CreateFrame("ScrollFrame", nil, copy)
    scroll:SetPoint("TOPLEFT", 14, -36)
    scroll:SetPoint("BOTTOMRIGHT", -14, 36)
    local edit = CreateFrame("EditBox", nil, scroll)
    edit:SetMultiLine(true)
    edit:SetFontObject("ChatFontNormal")
    edit:SetWidth(520)
    edit:SetAutoFocus(false)
    edit:SetMaxLetters(12000)
    scroll:SetScrollChild(edit)
    edit:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
        copy:Hide()
    end)
    copy:EnableMouseWheel(true)
    copy:SetScript("OnMouseWheel", function(_, delta)
        local current = scroll:GetVerticalScroll() or 0
        local maxScroll = edit:GetHeight() - scroll:GetHeight()
        if maxScroll < 0 then maxScroll = 0 end
        local nextScroll = current - delta * 28
        if nextScroll < 0 then nextScroll = 0 end
        if nextScroll > maxScroll then nextScroll = maxScroll end
        scroll:SetVerticalScroll(nextScroll)
    end)

    local function listEntries()
        local calc = RRP.Calculate()
        local entries = {}
        for id, amount in pairs(calc.items) do
            local owned = nil
            if RRP.BagsReadable() then owned = RRP.BagCount(id) end
            local missing = nil
            if owned ~= nil then missing = math.max(0, amount - owned) end
            entries[#entries + 1] = {
                id = id, amount = amount, owned = owned, missing = missing,
            }
        end
        table.sort(entries, function(a, b)
            local am, bm = a.missing or -1, b.missing or -1
            if am ~= bm then return am > bm end
            return RRP.ItemLabel(a.id) < RRP.ItemLabel(b.id)
        end)
        local full = {}
        for _, entry in ipairs(entries) do full[#full + 1] = entry end
        for _, name in ipairs(calc.unknown) do
            full[#full + 1] = {unknown = name}
        end
        return calc, full
    end

    function RRP.ShoppingText()
        local _, full = listEntries()
        local lines = {}
        for _, entry in ipairs(full) do
            if entry.id then
                lines[#lines + 1] = RRP.ItemLabel(entry.id) .. " " .. tostring(entry.amount)
            end
        end
        if #lines == 0 then lines[1] = "No materials to copy." end
        return table.concat(lines, "\n")
    end

    local function openCopy()
        local text = RRP.ShoppingText()
        local lines = 1
        for _ in text:gmatch("\n") do lines = lines + 1 end
        edit:SetText(text)
        edit:SetHeight(math.max(scroll:GetHeight() or 300, lines * 16 + 8))
        scroll:SetVerticalScroll(0)
        copy:Show()
        edit:SetFocus()
        edit:HighlightText()
    end
    copyBtn:SetScript("OnClick", openCopy)

    function RRP.RefreshShopping()
        if not shop:IsShown() then return end
        local calc, full = listEntries()
        if #full == 0 then full[1] = {empty = true} end
        local pages = math.max(1, math.ceil(#full / ROW_COUNT))
        page = math.max(1, math.min(page, pages))
        local start = (page - 1) * ROW_COUNT + 1
        for i, row in ipairs(rows) do
            local entry = full[start + i - 1]
            row.itemID = nil
            if not entry then
                row:Hide()
            else
                row:Show()
                if entry.empty then
                    row.icon:Hide()
                    row.name:SetText("No recipes selected. Click a recipe to add it.")
                    row.name:SetTextColor(0.7, 0.65, 0.5)
                    row.needed:SetText("")
                    row.owned:SetText("")
                    row.missing:SetText("")
                elseif entry.unknown then
                    UI.SetIcon(row.icon, "Interface\\Icons\\INV_Misc_QuestionMark")
                    row.icon:Show()
                    UI.Trim(row.name, entry.unknown .. "  - ingredients unknown", 270)
                    row.name:SetTextColor(1, 0.7, 0.35)
                    row.needed:SetText("-")
                    row.owned:SetText("-")
                    row.missing:SetText("Unknown")
                    row.missing:SetTextColor(1, 0.7, 0.35)
                else
                    row.itemID = entry.id
                    row.icon:Show()
                    UI.SetIcon(row.icon, RRP.ItemTexture(entry.id))
                    UI.Trim(row.name, RRP.ItemLabel(entry.id), 270)
                    row.name:SetTextColor(0.95, 0.92, 0.84)
                    row.needed:SetText(tostring(entry.amount))
                    if entry.owned == nil then
                        row.owned:SetText("-")
                        row.missing:SetText("-")
                        row.missing:SetTextColor(0.7, 0.65, 0.5)
                    else
                        row.owned:SetText(tostring(entry.owned))
                        row.missing:SetText(entry.missing > 0 and tostring(entry.missing) or "0")
                        if entry.missing > 0 then row.missing:SetTextColor(1, 0.28, 0.22)
                        else row.missing:SetTextColor(0.45, 0.85, 0.45) end
                    end
                end
            end
        end
        pageLabel:SetText(page .. " / " .. pages)
        prev:SetAlpha(page > 1 and 1 or 0.35)
        nextB:SetAlpha(page < pages and 1 or 0.35)
        summary:SetText(calc.selected .. " selected. Favor: " .. calc.favor ..
            (calc.unknownFavor and "+" or ""))
    end

    function RRP.ToggleShopping()
        if shop:IsShown() then
            shop:Hide()
            copy:Hide()
        else
            if UI.SyncScaledFrames then UI.SyncScaledFrames() end
            shop:Show()
            page = 1
            RRP.RefreshShopping()
        end
    end
    RRP.Shopping = shop
end
