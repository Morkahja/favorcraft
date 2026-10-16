-- Shared comparison engine for the seven profession research packages.
-- Names are joined to FavorCraft schematics for item and spell IDs.
-- A research label is not treated as verified when the record still says
-- the effect, the source, or the spell ID needs checking.
local _, RRP = ...

local RANK = {duplicate=1,equivalent=2,alternative=3,related=4,slot=5,reported=6,none=7}
local LABEL = {
    duplicate="Same Recipe",
    equivalent="Same Effect",
    alternative="Comparable Item",
    related="Related Item",
    slot="Same-slot Gear",
    reported="Additional Recipe Source",
    none="None",
}
RRP.ComparisonLabel=LABEL

local function lower(value)
    return type(value) == "string" and value:lower() or ""
end
local function has(value, needle)
    return lower(value):find(needle, 1, true) ~= nil
end
local function sameSlot(record, match)
    local scope=record and record.comparison_scope or ""
    return scope=="same_slot_only" or scope=="same_slot_or_weapon_category"
        or (match and match.similarity=="equipment_slot")
        or (match and match.similarity=="weapon_or_slot")
end

local function qualityToken(value)
    if type(value) == "number" then
        if value == 2 then return "uncommon" end
        if value == 3 then return "rare" end
        if value == 4 then return "epic" end
        if value == 1 then return "common" end
        return nil
    end
    if type(value) ~= "string" or value == "" then return nil end
    local low = value:lower()
    if low == "green" or low == "uncommon" then return "uncommon" end
    if low == "blue" or low == "rare" then return "rare" end
    if low == "purple" or low == "epic" then return "epic" end
    if low == "white" or low == "common" then return "common" end
    return low
end

-- Same-slot trainer gear is only useful when quality matches and the required
-- levels are close. A blue level-15 Favor piece is not compared with a green
-- level-10 trainer piece.
local function weakSlotOnly(record, match)
    if not sameSlot(record, match) then return false end
    local merchantQuality = qualityToken(record.quality or record.item_quality or record.itemQuality)
    local matchQuality = qualityToken(match.quality or match.item_quality or match.itemQuality)
    local merchantLevel = tonumber(record.required_level or record.requiredLevel or record.level)
    local matchLevel = tonumber(match.required_level or match.requiredLevel or match.level)
    if merchantQuality and matchQuality and merchantQuality == matchQuality
        and merchantLevel and matchLevel and math.abs(merchantLevel - matchLevel) <= 3 then
        return false
    end
    return true
end

-- Beta policy: source-backed comparisons are shown without a separate
-- in-game confirmation step. Labels describe relationships, not certainty
-- that any individual boss/vendor stocks the item in the current build.
local function classify(record, match, catalogBacked)
    if not match then return "none" end
    if record.exact_trainer_duplicate_confirmed == true or record.exact_duplicate_confirmed == true then
        return "duplicate"
    end
    if sameSlot(record,match) then return "slot" end
    local relation=match.relation or record.classification or ""
    if relation=="possible_duplicate" or relation=="related_unverified"
        or relation=="related_not_interchangeable" then return "related" end
    if relation=="equivalent" and match.same_effect==true then return "equivalent" end
    if catalogBacked or relation=="alternative" or relation=="equivalent" then return "alternative" end
    return "related"
end

local function cleanPlace(place)
    if type(place) ~= "string" or place == "" then return nil end
    place = place:gsub("%s*%([^)]*[Ww]owhead[^)]*%)", "")
    place = place:gsub("%s*%([^)]*[Dd]atabase[^)]*%)", "")
    place = place:gsub("%s*[Dd]atabase listing%.?", "")
    place = place:gsub("^Drop:%s*", "")
    place = place:gsub("^%s+", ""):gsub("%s+$", "")
    if place == "" or place:find("not confirmed", 1, true) then return nil end
    return place
end

local function soften(text)
    if type(text) ~= "string" then return "" end
    text = text:gsub("[Nn]on%-Favor world formula", "This")
    text = text:gsub("[Tt]he world formula", "This")
    text = text:gsub("[Nn]on%-Favor formula", "")
    text = text:gsub("[Nn]on%-Favor ", "")
    text = text:gsub("%s+", " ")
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    text = text:gsub("^,%s*", ""):gsub(",%s*$", "")
    return text
end
local function formulaOnly(place)
    if type(place) ~= "string" or place == "" then return true end
    local low = place:lower()
    if low == "world-drop formula" or low == "world/raid-drop formula" then return true end
    if low:find("^vendor%s*%(") then return true end
    if low:find("formula", 1, true) or low:find("listing", 1, true) then return true end
    return false
end
local function acquisition(match)
    local raw=match and match.acquisition or ""
    local indexed=match and match.source_verified==true or false
    local place=cleanPlace(match and (match.source_note or match.source_name))
    place = soften(place)
    if formulaOnly(place) then place = nil end
    if raw=="world_drop" or raw=="drop" then
        return place and ("World drop: "..place) or "World drop",indexed
    elseif raw=="trainer" or raw=="trainer_client_index" then
        return "Profession trainer",indexed
    elseif raw=="merchants_favor" then return "Merchant's Favor vendor",true
    elseif raw=="recipe_item" or raw=="" or raw=="unverified" or raw=="source_unverified"
        or raw=="recipe_item_source_unresolved" or raw=="recipe_source_unverified" then
        return "Learned from a recipe",false
    elseif raw=="vendor" or raw=="vendor_sale" then
        return place and ("Vendor: "..place) or "Vendor",indexed
    end
    return place and (raw..": "..place) or raw,indexed
end

local UNFINISHED = {
    "must be compared", "must be verified", "not yet", "separately verify",
    "no quantified", "no exact trainer", "not confirmed", "need item data",
    "needs item data", "do not display", "were not compared", "not an equivalent",
    "compare potency", "no verified close", "until independently verified",
    "not consistently present",
}
local function unfinished(text)
    local low = text:lower()
    for i = 1, #UNFINISHED do
        if low:find(UNFINISHED[i], 1, true) then return true end
    end
    return false
end
local function statedParts(text)
    local parts = {}
    if type(text) ~= "string" or text == "" then return parts end
    local padded = text
    if not padded:find("%.%s*$") then padded = padded .. "." end
    for sentence in padded:gmatch("(.-)%.%s*") do
        for clause in (sentence .. ";"):gmatch("(.-)%s*;%s*") do
            clause = soften(clause)
            if clause ~= "" and not unfinished(clause) then parts[#parts + 1] = clause end
        end
    end
    return parts
end
local function isDifference(text)
    local low = text:lower()
    return low:find("differ", 1, true) or low:find("versus", 1, true)
        or low:find("instead", 1, true) or low:find("unlike", 1, true)
        or low:find("stronger", 1, true) or low:find("overlap", 1, true)
        or low:find("lower-tier", 1, true) or low:find("tier", 1, true)
end
local function addFinding(sims, diffs, text)
    if isDifference(text) then diffs[#diffs + 1] = text
    else sims[#sims + 1] = text end
end
local function points(match, summary)
    local sims, diffs = {}, {}
    if match.similarity == "equipment_slot" then
        sims[#sims + 1] = "Same equipment slot."
    elseif match.similarity == "weapon_or_slot" then
        sims[#sims + 1] = "Same weapon category."
    else
        local found = statedParts(match.similarity)
        for i = 1, #found do sims[#sims + 1] = found[i] end
    end
    -- Keep this list dense. A leading nil makes Lua treat the array as empty.
    local blobs = {}
    local function addBlob(value)
        if type(value) == "string" and value ~= "" then blobs[#blobs + 1] = value end
    end
    addBlob(match.difference)
    addBlob(match.differences)
    addBlob(match.similarity_and_difference)
    addBlob(match.similarities_and_differences)
    addBlob(match.tier_context)
    addBlob(match.levelTiersContext)
    for i = 1, #blobs do
        local found = statedParts(blobs[i])
        for j = 1, #found do diffs[#diffs + 1] = found[j] end
    end
    if #diffs == 0 then
        local found = statedParts(summary)
        for i = 1, #found do
            if not found[i]:find("Both craft equipment", 1, true) then
                addFinding(sims, diffs, found[i])
            end
        end
    end
    return sims, diffs
end

local function schematic(name)
    if type(name) ~= "string" or type(RRP.Schematics) ~= "table" or type(RRP.Professions) ~= "table" then
        return nil
    end
    for i = 1, #RRP.Professions do
        local prof = RRP.Professions[i]
        if prof ~= "All" then
            local row = RRP.Schematics[prof .. "|" .. name]
            if type(row) == "table" then return row, prof .. "|" .. name end
        end
    end
end

local function copyMatches(raw, fallbackName)
    local list = {}
    if type(raw.matches) == "table" then
        for i = 1, #raw.matches do
            if type(raw.matches[i]) == "table" then list[#list + 1] = raw.matches[i] end
        end
    end
    return list
end

local function idState(researchId, currentId)
    researchId = tonumber(researchId)
    currentId = tonumber(currentId)
    if researchId and currentId and researchId == currentId then return "matches" end
    if researchId and currentId and researchId ~= currentId then return "conflict" end
    if researchId and not currentId then return "research only" end
    if not researchId and currentId then return "schematic kept" end
    return "absent"
end

local function sourceLine(src)
    local kind = src.type or "dungeon_drop"
    if kind == "vendor_sale" then
        return "Listed sale: " .. (src.npc or "unspecified vendor")
            .. (src.location and (" (" .. src.location .. ")") or "") .. "."
    elseif kind == "world_drop" then
        return "Also listed as a general world drop."
    elseif kind == "zone_report" or kind == "dungeon_report" then
        return "Other listings mention " .. (src.location or "unspecified locations") .. "."
    end
    return "Listed dungeon drop: " .. (src.npc or "unspecified creature")
        .. (src.location and (" (" .. src.location .. ")") or "") .. "."
end

local function genericSources(raw)
    local list = {}
    if type(raw.otherSources) ~= "table" then return list end
    for i = 1, #raw.otherSources do
        local src = raw.otherSources[i]
        if type(src) == "table" then
            local npc, location = src.name, nil
            if type(src.name) == "string" then
                local who, where = src.name:match("^(.-)%s*%((.+)%)%s*$")
                if who and who ~= "" then npc, location = who, where end
            end
            list[#list + 1] = {
                type = src.type == "vendor" and "vendor_sale" or "dungeon_drop",
                npc = npc,
                location = location,
                verification = "reported",
                evidence = src.url,
            }
        end
    end
    return list
end

local function buildAcquisition(key, name, raw, catalog, merchant)
    local audit = RRP.SourceAudits and RRP.SourceAudits[key]
    local reported = audit and audit.sources or nil
    if type(reported) ~= "table" or #reported == 0 then reported = genericSources(raw) end
    if #reported == 0 then return nil end
    local lines = {}
    local scrollId = merchant and tonumber(merchant.scrollItemID)
        or (audit and tonumber(audit.researchScrollID))
    for i = 1, #reported do lines[#lines + 1] = sourceLine(reported[i]) end
    if audit and type(audit.conflicts) == "table" then
        for i = 1, #audit.conflicts do
            local note = audit.conflicts[i]
            if type(note) == "string" and not note:find("Trainer listings disagree", 1, true) then
                lines[#lines + 1] = note
            end
        end
    end
    local idCheck = nil
    if audit then
        idCheck = {
            spell = idState(audit.researchSpellID, merchant and merchant.spellID),
            scroll = idState(audit.researchScrollID, merchant and merchant.scrollItemID),
            output = idState(audit.researchOutputID, merchant and merchant.outputItemID),
        }
    end
    return {{
        tier = "reported",
        label = LABEL.reported,
        name = name,
        kind = "source",
        sameRecipe = true,
        acquisitionVerified = false,
        verification = "reported",
        scrollItemID = scrollId,
        lines = lines,
        references = (function()
            local urls={}
            for i=1,#reported do
                if type(reported[i].evidence)=="string" then urls[#urls+1]=reported[i].evidence end
            end
            return urls
        end)(),
        idCheck = idCheck,
        conflicts = audit and audit.conflicts or nil,
    }}
end

local function buildView(profession, name, raw)
    local key = profession .. "|" .. name
    local catalog = RRP.GetByKey and RRP.GetByKey(key)
    local merchant = RRP.Schematics and RRP.Schematics[key]
    local matches = copyMatches(raw, name)
    local entries = {}
    for i = 1, #matches do
        local match = matches[i]
        if weakSlotOnly(raw, match) then
            match = nil
        end
        if match then
        local matchName = match.name or name
        local slotOnly = sameSlot(raw, match)
        local catalogBacked = catalog and type(catalog.alternative) == "string" and catalog.alternative:find(matchName, 1, true)
        local tier = classify(raw, match, catalogBacked)
        local where, verified = acquisition(match)
        if catalogBacked and has(catalog.alternative, "trainer") then
            where = "Profession trainer"
            verified = true
        end
        local sims, diffs = points(match, raw.summary)
        if catalogBacked and catalog.alternative then
            diffs[#diffs + 1] = catalog.alternative
        end
        local sch = schematic(matchName)
        -- Explicit IDs from research can supply tooltips for non-merchant
        -- alternatives. A formula item is not the enchant, and a researched
        -- effect spell is not replaced by a same-name Merchant's Favor spell.
        local itemID=tonumber(match.outputItemID or match.output_item_id or match.crafted_item_id)
        local recipeSpellID=tonumber(match.recipeSpellID or match.recipe_spell_id)
        local spellID=tonumber(match.effect_spell_id)
        local kind
        if type(sch) == "table" then
            if not recipeSpellID then recipeSpellID=tonumber(sch.spellID) end
            if sch.kind == "enchant" then
                if not spellID then spellID=tonumber(sch.spellID) end
                kind="enchant"
                itemID=nil
            else
                itemID=tonumber(sch.outputItemID) or itemID
                kind=sch.kind or "item"
            end
        elseif spellID then
            kind="enchant"
            itemID=nil
        elseif itemID then kind="item" end
        local refs = {}
        if type(match.source_url) == "string" then refs[#refs + 1] = match.source_url end
        if type(match.evidence_urls) == "table" then
            for r = 1, #match.evidence_urls do refs[#refs + 1] = match.evidence_urls[r] end
        end
        entries[#entries + 1] = {
            tier = tier,
            label = (name == "Elixir of Lesser Intellect" and matchName == "Elixir of Wisdom")
                and "Almost Identical Item" or (LABEL[tier] or LABEL.related),
            name = matchName,
            acquisition = where,
            acquisitionVerified = verified,
            similarities = sims,
            differences = diffs,
            itemID = itemID,
            spellID = spellID,
            recipeSpellID = recipeSpellID,
            kind = kind,
            references = refs,
            verification = match.verification or raw.verification,
            sourceType = match.acquisition,
            sameRecipe = match.relation == "possible_duplicate",
        }
        end
    end
    table.sort(entries, function(a, b)
        local function rank(entry)
            if entry.label == "Almost Identical Item" then return 0 end
            return RANK[entry.tier] or 9
        end
        local ar, br = rank(a), rank(b)
        if ar ~= br then return ar < br end
        return (a.name or "") < (b.name or "")
    end)
    local best = "none"
    for i = 1, #entries do
        if (RANK[entries[i].tier] or 9) < (RANK[best] or 9) then best = entries[i].tier end
    end
    local note = nil
    local sources = buildAcquisition(key, name, raw, catalog, merchant)
    local header = nil
    if #entries == 0 and sources then best = "reported" end
    return {
        key = key,
        profession = profession,
        name = name,
        status = best,
        label = LABEL[best],
        entries = entries,
        sources = sources,
        note = note,
        header = header,
        verification = raw.verification,
        merchantSpellID = merchant and tonumber(merchant.spellID) or nil,
        merchantScrollID = merchant and tonumber(merchant.scrollItemID) or nil,
        merchantItemID = merchant and merchant.kind ~= "enchant" and tonumber(merchant.outputItemID) or nil,
        merchantKind = merchant and merchant.kind or nil,
        inCatalog = catalog ~= nil,
    }
end

local function recordsFrom(package)
    if type(package) ~= "table" then return {} end
    if type(package.recipes) == "table" and type(package.recipes[1]) == "table" then
        local list = {}
        for i = 1, #package.recipes do
            local raw = package.recipes[i]
            if type(raw) == "table" then
                local name = raw.merchant_recipe_name
                if not name and type(raw.key) == "string" then name = raw.key:match("^[^|]+|(.+)$") end
                if name then list[#list + 1] = {name = name, raw = raw} end
            end
        end
        return list
    end
    local list = {}
    for key, raw in pairs(package) do
        if type(raw) == "table" and (raw.classification or raw.merchant_recipe_name or raw.matches or raw.otherSources or raw.note) then
            local name = raw.merchant_recipe_name or key
            if type(name) == "string" then list[#list + 1] = {name = name, raw = raw} end
        end
    end
    return list
end

local SOURCES = {
    {"Alchemy", "AlchemyComparisons"},
    {"Blacksmithing", "BlacksmithingComparisons"},
    {"Cooking", "CookingComparisons"},
    {"Enchanting", "EnchantingComparisons"},
    {"Engineering", "EngineeringComparisons"},
    {"Leatherworking", "LeatherworkingComparisons"},
    {"Tailoring", "Comparisons"},
}

local function tailoringPackage()
    local box = RRP.Comparisons
    if type(box) == "table" and type(box.Tailoring) == "table" then return box.Tailoring end
    return nil
end

local NAME_FIX = {
    ["Alchemy|Elixir of the Sages"] = "Elixir of Sages",
}

function RRP.RebuildComparisons()
    RRP.ComparisonByKey = {}
    RRP.ComparisonBySpell = {}
    for i = 1, #SOURCES do
        local profession, field = SOURCES[i][1], SOURCES[i][2]
        local package = profession == "Tailoring" and tailoringPackage() or RRP[field]
        local rows = recordsFrom(package)
        for r = 1, #rows do
            local name = rows[r].name
            local proposed = profession .. "|" .. name
            if RRP.GetByKey and not RRP.GetByKey(proposed) and NAME_FIX[proposed] then
                name = NAME_FIX[proposed]
            end
            local view = buildView(profession, name, rows[r].raw)
            RRP.ComparisonByKey[view.key] = view
            if view.merchantSpellID then RRP.ComparisonBySpell[view.merchantSpellID] = view end
        end
    end
end

local function blank(reason)
    return {
        status = "none",
        label = LABEL.none,
        entries = {},
        note = nil,
        missingRecord = true,
        reason = reason,
    }
end

function RRP.ComparisonsFor(recipe)
    if type(recipe) ~= "table" then return blank("missing recipe") end
    if not RRP.ComparisonByKey then RRP.RebuildComparisons() end
    local key = recipe.key
    if not key and recipe.profession and recipe.name then key = recipe.profession .. "|" .. recipe.name end
    local found = key and RRP.ComparisonByKey[key]
    if not found and recipe.spellID then found = RRP.ComparisonBySpell[tonumber(recipe.spellID)] end
    if not found and key and RRP.Schematics and RRP.Schematics[key] then
        found = RRP.ComparisonBySpell[tonumber(RRP.Schematics[key].spellID)]
    end
    if not found then return blank("no comparison record") end
    return found
end

function RRP.ComparisonReport()
    if not RRP.ComparisonByKey then RRP.RebuildComparisons() end
    local order = {"Alchemy", "Blacksmithing", "Cooking", "Enchanting", "Engineering", "Leatherworking", "Tailoring"}
    local lines = {
        "# FavorCraft comparison coverage",
        "",
        "Beta research listings are displayed for comparison. Similarity does not mean identical effects or guaranteed drop availability. No item IDs are invented.",
        "",
        "Alchemy research names Elixir of the Sages; the catalog name is Elixir of Sages. Leatherworking source listings refer to the merchant recipe pattern, not its crafted armor.",
        "",
    }
    local unresolved = {}
    for p = 1, #order do
        local profession = order[p]
        local catalog, records = 0, 0
        local buckets = {duplicate = 0, equivalent = 0, alternative = 0, related = 0, slot = 0, reported = 0, none = 0, missing = 0}
        local itemIDs, recipeIDs, tooltips, sources = 0, 0, 0, 0
        local seen = {}
        if type(RRP.Catalog) == "table" then
            for i = 1, #RRP.Catalog do
                local recipe = RRP.Catalog[i]
                if recipe.profession == profession then
                    catalog = catalog + 1
                    local view = RRP.ComparisonByKey[recipe.key]
                    if not view then
                        buckets.missing = buckets.missing + 1
                        unresolved[#unresolved + 1] = profession .. " | " .. recipe.name .. " | missing | No research record for this catalog recipe."
                    else
                        seen[recipe.key] = true
                        records = records + 1
                        buckets[view.status] = (buckets[view.status] or 0) + 1
                        for e = 1, #view.entries do
                            local entry = view.entries[e]
                            if not entry.sameRecipe and entry.recipeSpellID then recipeIDs = recipeIDs + 1 end
                            if entry.itemID or (entry.kind == "enchant" and entry.spellID) then
                                tooltips = tooltips + 1
                                if entry.itemID and not entry.sameRecipe then itemIDs = itemIDs + 1 end
                            end
                            if entry.acquisitionVerified then sources = sources + 1 end
                        end
                        if view.status ~= "equivalent" and view.status ~= "duplicate" and view.status ~= "alternative" then
                            unresolved[#unresolved + 1] = profession .. " | " .. recipe.name .. " | " .. view.status .. " | " .. (view.verification or "no verification flag")
                        end
                    end
                end
            end
        end
        for key, view in pairs(RRP.ComparisonByKey) do
            if view.profession == profession and not seen[key] then
                records = records + 1
                unresolved[#unresolved + 1] = profession .. " | " .. view.name .. " | extra | Research record is not in the FavorCraft catalog."
            end
        end
        lines[#lines + 1] = "## " .. profession
        lines[#lines + 1] = "- Merchant's Favor recipes in the catalog: " .. catalog
        lines[#lines + 1] = "- Research records matched to the catalog: " .. (catalog - buckets.missing)
        lines[#lines + 1] = "- Recipes with comparison candidates: " .. ((catalog - buckets.missing) - buckets.none - buckets.reported)
        lines[#lines + 1] = "- Verified duplicate recipes: " .. buckets.duplicate
        lines[#lines + 1] = "- Verified equivalent items: " .. buckets.equivalent
        lines[#lines + 1] = "- Verified alternatives: " .. buckets.alternative
        lines[#lines + 1] = "- Related item comparisons: " .. buckets.related
        lines[#lines + 1] = "- Same-slot gear comparisons: " .. buckets.slot
        lines[#lines + 1] = "- Additional database-listed sources: " .. buckets.reported
        lines[#lines + 1] = "- Records without comparisons: " .. buckets.none
        lines[#lines + 1] = "- Catalog recipes with no research record: " .. buckets.missing
        lines[#lines + 1] = "- Alternative item IDs resolved: " .. itemIDs
        lines[#lines + 1] = "- Alternative recipe IDs resolved: " .. recipeIDs
        lines[#lines + 1] = "- Native tooltip coverage: " .. tooltips
        lines[#lines + 1] = "- Acquisition sources verified: " .. sources
        lines[#lines + 1] = ""
    end
    lines[#lines + 1] = "## Unresolved or conflicting records"
    lines[#lines + 1] = ""
    lines[#lines + 1] = "A row here is not fully verified. Duplicate, equivalent, and alternative counts above are the only rows treated as verified comparisons."
    lines[#lines + 1] = ""
    for i = 1, #unresolved do lines[#lines + 1] = "- " .. unresolved[i] end
    lines[#lines + 1] = ""
    lines[#lines + 1] = "## Leatherworking acquisition check"
    lines[#lines + 1] = ""
    lines[#lines + 1] = "Research identifiers were compared with the existing client schematic. A match was kept. A blank research field did not erase a schematic ID. No schematic ID was replaced."
    lines[#lines + 1] = ""
    if type(RRP.SourceAudits) == "table" then
        local keys = {}
        for key in pairs(RRP.SourceAudits) do keys[#keys + 1] = key end
        table.sort(keys)
        for i = 1, #keys do
            local view = RRP.ComparisonByKey[keys[i]]
            local block = view and view.sources and view.sources[1]
            local check = block and block.idCheck or {}
            lines[#lines + 1] = "- " .. (view and view.name or keys[i])
                .. " | spell " .. tostring(view and view.merchantSpellID) .. " (" .. tostring(check.spell) .. ")"
                .. " | scroll " .. tostring(view and view.merchantScrollID) .. " (" .. tostring(check.scroll) .. ")"
                .. " | output " .. tostring(view and view.merchantItemID) .. " (" .. tostring(check.output) .. ")"
            if block and block.conflicts then
                for c = 1, #block.conflicts do
                    lines[#lines + 1] = "  - Conflict: " .. block.conflicts[c]
                end
            end
        end
    end
    lines[#lines + 1] = ""
    return table.concat(lines, "\n")
end

RRP.RebuildComparisons()
