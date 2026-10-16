local addonName, RRP = ...
local UI = {}
RRP.UI = UI

RRP.ProfessionTexture = {
    All = "Interface\\Icons\\INV_Misc_Book_09",
    Alchemy = "Interface\\Icons\\Trade_Alchemy",
    Blacksmithing = "Interface\\Icons\\Trade_BlackSmithing",
    Cooking = "Interface\\Icons\\INV_Misc_Food_15",
    Enchanting = "Interface\\Icons\\Trade_Engraving",
    Engineering = "Interface\\Icons\\Trade_Engineering",
    Leatherworking = "Interface\\Icons\\Trade_LeatherWorking",
    Tailoring = "Interface\\Icons\\Trade_Tailoring",
}
RRP.ClassTexture = {
    WARRIOR = "Interface\\Icons\\INV_Sword_27",
    PALADIN = "Interface\\Icons\\INV_Hammer_01",
    HUNTER = "Interface\\Icons\\INV_Weapon_Bow_07",
    ROGUE = "Interface\\Icons\\INV_ThrowingKnife_04",
    PRIEST = "Interface\\Icons\\INV_Staff_30",
    SHAMAN = "Interface\\Icons\\Spell_Nature_Lightning",
    MAGE = "Interface\\Icons\\Spell_Frost_FrostBolt02",
    WARLOCK = "Interface\\Icons\\Spell_Shadow_CurseOfMannoroth",
    DRUID = "Interface\\Icons\\Ability_Druid_Maul",
}

local FALLBACK = "Interface\\Icons\\INV_Misc_QuestionMark"
local PANEL_BACKDROP = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = {left = 3, right = 3, top = 3, bottom = 3},
}

function UI.Paint(frame)
    if not frame.SetBackdrop then return end
    frame:SetBackdrop(PANEL_BACKDROP)
    frame:SetBackdropColor(0.04, 0.035, 0.03, 0.94)
    frame:SetBackdropBorderColor(0.62, 0.48, 0.18, 1)
end

function UI.SetIcon(texture, path)
    texture:SetTexture(path or FALLBACK)
    texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
end

function RRP.ItemTexture(id)
    id = tonumber(id)
    if not id then return nil end
    if type(GetItemIcon) == "function" then
        local icon = GetItemIcon(id)
        if type(icon) == "string" or type(icon) == "number" then return icon end
    end
    if C_Item and type(C_Item.GetItemIconByID) == "function" then
        local ok, icon = pcall(C_Item.GetItemIconByID, id)
        if ok and (type(icon) == "string" or type(icon) == "number") then return icon end
    end
    if type(GetItemInfo) == "function" then
        local _, _, _, _, _, _, _, _, _, tex = GetItemInfo(id)
        if tex then return tex end
    end
    if RRP.RequestItem then RRP.RequestItem(id) end
    return nil
end

function RRP.ItemLabel(id)
    id = tonumber(id)
    if not id then return "" end
    local name = RRP.ReadItemName and RRP.ReadItemName(id)
    if name then return name end
    if RRP.RequestItem then RRP.RequestItem(id) end
    return ""
end

function RRP.RecipeTexture(recipe)
    local ref = RRP.OutputRef and RRP.OutputRef(recipe)
    local id = ref and ref.itemID
    local texture = id and RRP.ItemTexture(id)
    if not texture and id then RRP.RequestOutput(ref) end
    if texture then return texture, id end
    local spellID = ref and tonumber(ref.spellID)
    if spellID and type(GetSpellTexture) == "function" then
        local ok, spellTexture = pcall(GetSpellTexture, spellID)
        if ok and (type(spellTexture) == "string" or type(spellTexture) == "number") then
            return spellTexture, id
        end
    end
    return RRP.ProfessionTexture[recipe and recipe.profession or ""] or FALLBACK, id
end

function UI.HideTip()
    if GameTooltip then GameTooltip:Hide() end
end

function UI.ShowTip(owner, title, line)
    if not GameTooltip or not owner then return end
    GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
    GameTooltip:SetText(title or "", 1, 0.82, 0)
    if line and line ~= "" then GameTooltip:AddLine(line, 0.95, 0.95, 0.95, true) end
    GameTooltip:Show()
end

function UI.ShowNativeTip(tip, owner, recipe, anchor)
    if not tip or not recipe or not owner then return false end
    local ref = RRP.OutputRef and RRP.OutputRef(recipe)
    local link = RRP.OutputHyperlink and RRP.OutputHyperlink(ref)
    if not link then return false end
    if RRP.RequestOutput then RRP.RequestOutput(ref) end
    local owned = pcall(tip.SetOwner, tip, owner, anchor or "ANCHOR_RIGHT")
    if not owned then
        owned = pcall(tip.SetOwner, tip, owner, "ANCHOR_RIGHT")
    end
    if not owned then return false end
    local shown = false
    if ref.itemID and tip.SetItemByID then
        shown = pcall(tip.SetItemByID, tip, ref.itemID)
    end
    if not shown and ref.kind == "enchant" and ref.spellID and tip.SetSpellByID then
        shown = pcall(tip.SetSpellByID, tip, ref.spellID)
    end
    if not shown then
        shown = pcall(tip.SetHyperlink, tip, link)
    end
    if not shown and ref.kind == "enchant" and ref.spellID then
        shown = pcall(tip.SetHyperlink, tip, "spell:" .. ref.spellID)
        if not shown then
            shown = pcall(tip.SetHyperlink, tip, "enchant:" .. ref.spellID)
        end
    end
    if shown then
        tip:Show()
        return true
    end
    tip:Hide()
    return false
end

function UI.ShowSpellTip(owner, spellID, title)
    if not GameTooltip or not owner or not spellID then return end
    if C_Spell and type(C_Spell.RequestLoadSpellData) == "function" then
        pcall(C_Spell.RequestLoadSpellData, spellID)
    end
    local owned = pcall(GameTooltip.SetOwner, GameTooltip, owner, "ANCHOR_RIGHT")
    if not owned then return end
    local shown = GameTooltip.SetSpellByID and pcall(GameTooltip.SetSpellByID, GameTooltip, spellID)
    if not shown then
        shown = pcall(GameTooltip.SetHyperlink, GameTooltip, "spell:" .. spellID)
    end
    if shown then
        GameTooltip:Show()
        return
    end
    GameTooltip:ClearLines()
    GameTooltip:SetText(title or "Spell", 1, 0.82, 0)
    GameTooltip:AddLine("Spell data is still loading.", 1, 0.82, 0.4, true)
    GameTooltip:Show()
end

function UI.ShowItemTip(owner, itemID)
    if not GameTooltip or not owner or not itemID then return end
    if RRP.RequestItem then RRP.RequestItem(itemID) end
    local owned = pcall(GameTooltip.SetOwner, GameTooltip, owner, "ANCHOR_RIGHT")
    if not owned then return end
    local shown = GameTooltip.SetItemByID and pcall(GameTooltip.SetItemByID, GameTooltip, itemID)
    if not shown then
        shown = pcall(GameTooltip.SetHyperlink, GameTooltip, "item:" .. itemID)
    end
    if shown then
        GameTooltip:Show()
        return
    end
    GameTooltip:ClearLines()
    GameTooltip:SetText(RRP.ItemLabel(itemID), 1, 0.82, 0)
    GameTooltip:AddLine("Item data is still loading.", 1, 0.82, 0.4, true)
    GameTooltip:Show()
end

function UI.ShowRecipeTip(owner, recipe)
    if not GameTooltip or not recipe then return end
    if UI.ShowNativeTip(GameTooltip, owner, recipe, "ANCHOR_RIGHT") then return end
    local ref = RRP.OutputRef and RRP.OutputRef(recipe)
    GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()
    GameTooltip:SetText(recipe.name or "", 1, 0.82, 0)
    if ref and (ref.itemID or ref.spellID or ref.link) then
        GameTooltip:AddLine("Item data is still loading.", 1, 0.82, 0.4, true)
    else
        GameTooltip:AddLine("This recipe has no verified crafted item yet.", 1, 0.75, 0.4, true)
    end
    GameTooltip:Show()
end

function UI.GrowFont(fontString, scale)
    if not fontString or not fontString.GetFont then return end
    local font, size, flags = fontString:GetFont()
    if font and size then
        fontString:SetFont(font, math.floor(size * (scale or 1.2) + 0.5), flags)
    end
end

function UI.Label(parent, font, text)
    local s = parent:CreateFontString(nil, "OVERLAY", font or "GameFontHighlightSmall")
    s:SetJustifyH("LEFT")
    s:SetJustifyV("MIDDLE")
    if s.SetWordWrap then s:SetWordWrap(true) end
    if text then s:SetText(text) end
    return s
end

function UI.Trim(fontString, text, width)
    text = tostring(text or "")
    fontString:SetText(text)
    if width and fontString:GetStringWidth() > width then
        local n = #text
        while n > 1 do
            n = n - 1
            fontString:SetText(text:sub(1, n) .. "...")
            if fontString:GetStringWidth() <= width then break end
        end
    end
end

function UI.Divider(parent, y)
    local line = parent:CreateTexture(nil, "ARTWORK")
    line:SetPoint("TOPLEFT", 8, y)
    line:SetPoint("TOPRIGHT", -8, y)
    line:SetHeight(1)
    line:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    line:SetVertexColor(0.75, 0.6, 0.22, 0.85)
    return line
end

function UI.Button(parent, text, width, height)
    local b = CreateFrame("Button", nil, parent, "BackdropTemplate")
    b:SetSize(width, height)
    if b.SetBackdrop then
        b:SetBackdrop(PANEL_BACKDROP)
    end
    local label = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetPoint("CENTER", 0, 0)
    label:SetJustifyH("CENTER")
    label:SetText(text or "")
    b.label = label
    b:SetFontString(label)
    function b:ApplyColor(hot)
        if not self.SetBackdropColor then return end
        local style = self.style or "dark"
        if not self.enabled then
            self:SetBackdropColor(0.08, 0.07, 0.06, 0.8)
            self:SetBackdropBorderColor(0.3, 0.25, 0.15, 0.7)
            self.label:SetTextColor(0.45, 0.4, 0.32)
            return
        end
        if style == "red" then
            self:SetBackdropColor(hot and 0.62 or 0.45, 0.07, 0.05, 1)
            self:SetBackdropBorderColor(0.9, 0.25, 0.16, 1)
            self.label:SetTextColor(1, 0.95, 0.9)
        elseif style == "armed" then
            self:SetBackdropColor(hot and 0.42 or 0.32, 0.24, 0.06, 1)
            self:SetBackdropBorderColor(1, 0.78, 0.28, 1)
            self.label:SetTextColor(1, 0.9, 0.45)
        else
            self:SetBackdropColor(hot and 0.22 or 0.11, hot and 0.16 or 0.085, 0.05, 1)
            self:SetBackdropBorderColor(hot and 0.95 or 0.55, hot and 0.78 or 0.42, hot and 0.32 or 0.16, 1)
            self.label:SetTextColor(1, 0.9, 0.68)
        end
    end
    function b:SetStyle(style)
        self.style = style or "dark"
        self:ApplyColor(false)
    end
    function b:SetEnabledState(on)
        self.enabled = on and true or false
        self:ApplyColor(false)
    end
    b.enabled = true
    b:SetStyle("dark")
    b:SetScript("OnEnter", function(self)
        self:ApplyColor(true)
        if self.tip then UI.ShowTip(self, self.tip, self.tipLine) end
    end)
    b:SetScript("OnLeave", function(self)
        self:ApplyColor(false)
        UI.HideTip()
    end)
    return b
end

function UI.StepButton(parent, kind)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(16, 16)
    if kind == "plus" then
        b:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up")
        b:SetPushedTexture("Interface\\Buttons\\UI-PlusButton-Down")
        b:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight")
    else
        b:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up")
        b:SetPushedTexture("Interface\\Buttons\\UI-MinusButton-Down")
        b:SetHighlightTexture("Interface\\Buttons\\UI-MinusButton-Hilight")
    end
    return b
end

function UI.Check(parent, text, width)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(width or 80, 20)
    local box = b:CreateTexture(nil, "ARTWORK")
    box:SetSize(18, 18)
    box:SetPoint("LEFT", 0, 0)
    box:SetTexture("Interface\\Buttons\\UI-CheckBox-Up")
    local mark = b:CreateTexture(nil, "OVERLAY")
    mark:SetSize(18, 18)
    mark:SetPoint("CENTER", box, "CENTER", 0, 0)
    mark:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
    mark:SetVertexColor(1, 0.82, 0.25)
    mark:Hide()
    local label = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetPoint("LEFT", box, "RIGHT", 1, 0)
    label:SetText(text or "")
    label:SetTextColor(0.95, 0.9, 0.75)
    b.label = label
    function b:SetChecked(on)
        self.checked = on and true or false
        if self.checked then mark:Show() else mark:Hide() end
    end
    function b:GetChecked()
        return self.checked and true or false
    end
    b:SetScript("OnClick", function(self)
        self:SetChecked(not self:GetChecked())
        if self.onToggle then self.onToggle(self:GetChecked()) end
    end)
    b:SetScript("OnEnter", function(self)
        if self.tip then UI.ShowTip(self, self.tip, self.tipLine) end
    end)
    b:SetScript("OnLeave", UI.HideTip)
    b:SetChecked(false)
    return b
end

UI.menus = {}
function UI.CloseMenus()
    for _, menu in ipairs(UI.menus) do
        menu:Hide()
    end
end

function UI.Dropdown(parent, width, onPick)
    local b = CreateFrame("Button", nil, parent, "BackdropTemplate")
    b:SetSize(width, 30)
    if b.SetBackdrop then
        b:SetBackdrop(PANEL_BACKDROP)
        b:SetBackdropColor(0.08, 0.065, 0.04, 0.98)
        b:SetBackdropBorderColor(0.55, 0.42, 0.16, 1)
    end
    b.icon = b:CreateTexture(nil, "ARTWORK")
    b.icon:SetSize(20, 20)
    b.icon:SetPoint("LEFT", 6, 0)
    b.label = b:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    b.label:SetPoint("LEFT", 32, 0)
    b.label:SetPoint("RIGHT", -16, 0)
    b.label:SetJustifyH("LEFT")
    b.label:SetTextColor(1, 0.92, 0.75)
    b.arrow = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    b.arrow:SetPoint("RIGHT", -5, 0)
    b.arrow:SetText("v")
    b.arrow:SetTextColor(1, 0.82, 0.35)
    local menu = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    menu:SetFrameStrata("TOOLTIP")
    menu:SetScale(1)
    menu:Hide()
    if menu.SetBackdrop then
        menu:SetBackdrop(PANEL_BACKDROP)
        menu:SetBackdropColor(0.05, 0.04, 0.03, 0.98)
        menu:SetBackdropBorderColor(0.75, 0.6, 0.22, 1)
    end
    menu.rows = {}
    UI.menus[#UI.menus + 1] = menu
    function b:SetChoices(list)
        local y = 4
        for i, item in ipairs(list) do
            local row = menu.rows[i]
            if not row then
                row = CreateFrame("Button", nil, menu)
                row:SetHeight(48)
                row.icon = row:CreateTexture(nil, "ARTWORK")
                row.icon:SetSize(36, 36)
                row.icon:SetPoint("LEFT", 8, 0)
                row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                UI.GrowFont(row.text, 2)
                row.text:SetPoint("LEFT", 52, 0)
                row.text:SetPoint("RIGHT", -8, 0)
                row.text:SetJustifyH("LEFT")
                row.hi = row:CreateTexture(nil, "BACKGROUND")
                row.hi:SetAllPoints()
                row.hi:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
                row.hi:SetAlpha(0.35)
                row.hi:Hide()
                row:SetScript("OnEnter", function(self) self.hi:Show() end)
                row:SetScript("OnLeave", function(self) self.hi:Hide() end)
                menu.rows[i] = row
            end
            row:SetPoint("TOPLEFT", 3, -y)
            row:SetPoint("TOPRIGHT", -3, -y)
            row:Show()
            UI.SetIcon(row.icon, item.icon)
            row.text:SetText(item.text or "")
            local value = item.value
            row:SetScript("OnClick", function()
                menu:Hide()
                if onPick then onPick(value) end
            end)
            y = y + 48
        end
        for i = #list + 1, #menu.rows do menu.rows[i]:Hide() end
        menu:SetSize(math.max(width, 240), y + 8)
    end
    function b:SetChoice(text, icon)
        b.label:SetText(text or "")
        UI.SetIcon(b.icon, icon)
    end
    b:SetScript("OnClick", function()
        local open = menu:IsShown()
        UI.CloseMenus()
        if open then return end
        local scale = b.GetEffectiveScale and b:GetEffectiveScale() or 1
        local uiScale = UIParent and UIParent.GetEffectiveScale and UIParent:GetEffectiveScale() or 1
        if uiScale > 0 then menu:SetScale(scale / uiScale) end
        menu:ClearAllPoints()
        menu:SetPoint("TOPLEFT", b, "BOTTOMLEFT", 0, -2)
        menu:Show()
    end)
    b:SetScript("OnEnter", function(self)
        if self.SetBackdropBorderColor then self:SetBackdropBorderColor(0.95, 0.78, 0.3, 1) end
        if self.tip then UI.ShowTip(self, self.tip, self.tipLine) end
    end)
    b:SetScript("OnLeave", function(self)
        if self.SetBackdropBorderColor then self:SetBackdropBorderColor(0.55, 0.42, 0.16, 1) end
        UI.HideTip()
    end)
    b.menu = menu
    return b
end

function UI.SaveWindow(frame, key)
    if not RRPDB or not frame then return end
    RRPDB.ui = RRPDB.ui or {}
    local id = key or "main"
    local saved = RRPDB.ui[id]
    if type(saved) ~= "table" then saved = {} end
    if frame.GetPoint then
        local point, _, relative, x, y = frame:GetPoint(1)
        if point then
            saved.point, saved.rel, saved.x, saved.y = point, relative, x, y
        end
    end
    if frame.GetScale then
        local scale = frame:GetScale()
        if type(scale) == "number" then saved.scale = scale end
    end
    RRPDB.ui[id] = saved
end

function UI.SyncScaledFrames()
    local window = RRP.Window
    if not window or not window.GetScale then return end
    local scale = window:GetScale() or 1
    if RRP.Shopping and RRP.Shopping.SetScale then RRP.Shopping:SetScale(scale) end
end

function UI.RestoreLayout()
    if not RRPDB or not RRP.Window then return end
    UI.RestoreWindow(RRP.Window, "main")
    if RRP.Shopping then UI.RestoreWindow(RRP.Shopping, "shop", true) end
    if UI.SyncScaledFrames then UI.SyncScaledFrames() end
end

function UI.RestoreWindow(frame, key, positionOnly)
    if not frame then return end
    local saved = RRPDB and RRPDB.ui and RRPDB.ui[key or "main"]
    if type(saved) == "table" and not positionOnly and type(saved.scale) == "number" then
        local scale = saved.scale
        if scale < 0.65 then scale = 0.65 end
        if scale > 1.45 then scale = 1.45 end
        frame:SetScale(scale)
    end
    if saved and saved.point then
        frame:ClearAllPoints()
        frame:SetPoint(saved.point, UIParent, saved.rel or saved.point, saved.x or 0, saved.y or 0)
        return
    end
    if positionOnly or (type(saved) == "table" and type(saved.scale) == "number") then return end
    local width = (GetScreenWidth and GetScreenWidth()) or 1920
    local scale = 1
    if width < 1200 then scale = 0.7
    elseif width < 1450 then scale = 0.82
    elseif width < 1700 then scale = 0.92 end
    frame:SetScale(scale)
end
