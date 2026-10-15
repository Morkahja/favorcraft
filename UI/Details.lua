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
    name:SetPoint("TOPLEFT", 64, -10)
    name:SetPoint("TOPRIGHT", -12, -10)
    name:SetHeight(22)
    name:SetTextColor(0.45, 0.78, 1)
    local requires = UI.Label(panel, "GameFontHighlight")
    requires:SetPoint("TOPLEFT", 64, -32)
    requires:SetPoint("RIGHT", panel, "RIGHT", -12, 0)
    requires:SetHeight(16)
    local meta = UI.Label(panel, "GameFontHighlightSmall")
    meta:SetPoint("TOPLEFT", 64, -48)
    meta:SetPoint("RIGHT", panel, "RIGHT", -12, 0)
    meta:SetHeight(16)
    local craftedTitle = UI.Label(panel, "GameFontNormal", "Crafted item")
    craftedTitle:SetPoint("TOPLEFT", 12, -64)
    local effect = UI.Label(panel, "GameFontHighlightSmall")
    effect:SetPoint("TOPLEFT", 12, -84)
    effect:SetPoint("RIGHT", panel, "RIGHT", -12, 0)
    effect:SetHeight(20)
    effect:SetJustifyV("TOP")

    UI.Divider(panel, -110)
    local materialsTitle = UI.Label(panel, "GameFontNormal", "Materials (one craft)")
    materialsTitle:SetPoint("TOPLEFT", 12, -116)
    local materialRows = {}
    for i = 1, MATERIAL_ROWS do
        local row = CreateFrame("Frame", nil, panel)
        row:SetSize(360, 20)
        row:SetPoint("TOPLEFT", 12, -136 - (i - 1) * 20)
        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetSize(16, 16)
        row.icon:SetPoint("LEFT", 0, 0)
        row.name = UI.Label(row, "GameFontHighlight")
        row.name:SetPoint("LEFT", 22, 0)
        row.name:SetWidth(230)
        row.qty = UI.Label(row, "GameFontHighlightSmall")
        row.qty:SetPoint("RIGHT", 0, 0)
        row.qty:SetWidth(90)
        row.qty:SetJustifyH("RIGHT")
        row:Hide()
        materialRows[i] = row
    end
    local materialStatus = UI.Label(panel, "GameFontHighlightSmall")
    materialStatus:SetPoint("TOPLEFT", 12, -138)
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
                UI.Trim(row.name, RRP.ItemLabel(material.itemID), 220)
                local owned = nil
                if RRP.BagsReadable() then owned = RRP.BagCount(material.itemID) end
                if owned == nil then
                    row.qty:SetText(tostring(material.quantity))
                else
                    row.qty:SetText(material.quantity .. "  (" .. owned .. " in bags)")
                end
            else
                row:Hide()
            end
        end
        if #list > #materialRows then
            local last = materialRows[#materialRows]
            last.icon:SetTexture(nil)
            last.name:SetText("+" .. (#list - #materialRows + 1) .. " more")
            last.qty:SetText("")
        end
    end
    local function showCrafted(recipe)
        local ref = RRP.OutputRef and RRP.OutputRef(recipe)
        if ref and ref.kind == "enchant" and ref.spellID then
            effect:SetText("Hover the icon to see this enchant.")
            effect:SetTextColor(0.75, 0.7, 0.6)
            return
        end
        if ref and (ref.itemID or ref.link) then
            effect:SetText("Hover the icon to see this item.")
            effect:SetTextColor(0.75, 0.7, 0.6)
            return
        end
        effect:SetText("This recipe is incomplete. No crafted item is on record.")
        effect:SetTextColor(1, 0.75, 0.4)
    end

    function UI.RefreshDetails()
        local profile = RRP.GetProfile()
        local recipe = RRP.SelectedRecipe()
        if not recipe or not profile then
            name:SetText("No recipe selected")
            requires:SetText("Choose a profession or turn on Show All Recipes.")
            meta:SetText("")
            effect:SetText("")
            alert:Hide()
            for _, row in ipairs(materialRows) do row:Hide() end
            materialStatus:SetText("Materials not yet known.")
            materialStatus:Show()
            forget:Hide()
            return
        end
        local learnState = RRP.LearnState and RRP.LearnState(recipe) or "unknown"
        UI.SetIcon(icon, RRP.RecipeTexture(recipe))
        UI.Trim(name, recipe.name, 340)
        local yours = profile.professionRanks and profile.professionRanks[recipe.profession]
        local skill = recipe.skill and (recipe.profession .. "  " .. recipe.skill) or (recipe.profession or "Profession")
        if yours then skill = skill .. "    You " .. yours end
        requires:SetText(skill)
        requires:SetTextColor(RRP.SkillTone(recipe.profession, recipe.skill))
        local learned = "|cffaa9988Not checked|r"
        if learnState == "learned" then learned = "|cff66dd88Learned|r"
        elseif learnState == "unlearned" then learned = "|cffff4444Not learned|r" end
        local level = recipe.level and ("Level " .. recipe.level) or "Level not listed"
        local rep = "Rep: " .. (recipe.reputation or "None")
        meta:SetText(level .. "   " .. learned .. "   " .. rep)
        showCrafted(recipe)
        local scrollId = RRP.ScrollID(recipe)
        if scrollId then
            meta:SetText(meta:GetText() .. "   Scroll: " .. RRP.ItemLabel(scrollId))
        end
        showMaterials(recipe)
        if recipe.alternative and recipe.alternative ~= "" then
            alertText:SetText(recipe.alternative)
            alert:Show()
        else
            alert:Hide()
        end
        if RRP.IsDiscovered(recipe) then forget:Show() else forget:Hide() end
    end
end
