local addonName, RRP = ...
local function say(message)
    print("|cffdca75fFavorCraft|r: " .. tostring(message))
end
RRP.Say = say

local function safeCall(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a, b, c = pcall(fn, ...)
    if ok then return a, b, c end
    return nil
end

local function trim(s)
    return (s or ""):gsub("^%s+", ""):gsub("%s+$", "")
end
local function normalize(s)
    s = trim(s):lower()
    s = s:gsub("^[^:]+:%s+", "") -- Recipe:, Plans:, Formula:, Pattern:, etc.
    s = s:gsub("[^%w]+", " ")
    return trim(s)
end
RRP.Normalize = normalize

local function hasToken(list, token)
    if type(list) ~= "string" or not token then return false end
    for part in list:gmatch("[^,]+") do
        if trim(part) == token then return true end
    end
    return false
end

local function itemIdFromLink(link)
    if type(link) ~= "string" then return nil end
    return tonumber(link:match("item:(%d+)"))
end

function RRP.GetProfile()
    if not RRPDB then return nil end
    local realm = (GetRealmName and GetRealmName()) or "Realm"
    local name = (UnitName and UnitName("player")) or "Player"
    local charKey = realm .. "-" .. name
    RRPDB.characters = RRPDB.characters or {}
    if not RRPDB.characters[charKey] then
        local _, class = UnitClass("player")
        local defaults = {All = false, Tank = true, Healer = true, Utility = true}
        if class == "MAGE" or class == "WARLOCK" or class == "PRIEST" then
            defaults.Caster = true
        elseif class == "SHAMAN" or class == "DRUID" then
            defaults.Melee, defaults.Caster = true, true
        elseif class == "HUNTER" then
            defaults.Hunter, defaults.Melee = true, true
        else
            defaults.Melee = true
        end
        if class == "PALADIN" then defaults.Paladin = true end
        RRPDB.characters[charKey] = {
            plan = {}, known = {}, learnScan = {}, roles = defaults, profession = "All",
            showAll = false, allClasses = true, page = 1, trainer = {}, professions = {}, professionRanks = {},
            specsDefaulted = true, specMode = "all",
        }
    end
    local p = RRPDB.characters[charKey]
    -- SavedVariables can survive addon updates. Migrate older/incomplete
    -- character profiles without discarding the player's recipe selections.
    if type(p.plan) ~= "table" then p.plan = {} end
    for key, value in pairs(p.plan) do
        if value == true then
            -- Already a selected recipe.
        elseif type(value) == "number" and value > 0 then
            p.plan[key] = true
        else
            p.plan[key] = nil
        end
    end
    if type(p.known) ~= "table" then p.known = {} end
    if type(p.learnScan) ~= "table" then p.learnScan = {} end
    if type(p.scanSig) ~= "table" then p.scanSig = {} end
    if type(p.roles) ~= "table" then p.roles = {Utility = true} end
    if type(p.profession) ~= "string" then p.profession = "All" end
    if p.allClasses == nil then p.allClasses = true end
    if type(p.page) ~= "number" then p.page = 1 end
    if p.expandIntermediate == nil then p.expandIntermediate = true end
    if type(p.professions) ~= "table" then p.professions = {} end
    if type(p.professionRanks) ~= "table" then p.professionRanks = {} end
    if type(p.scanInfo) ~= "table" then p.scanInfo = {} end
    if type(p.trainer) ~= "table" then
        p.trainer = {}
        -- Older builds stored this account-wide. Keep those marks on this character.
        if type(RRPDB.playerTrainer) == "table" then
            for k, v in pairs(RRPDB.playerTrainer) do
                if v then p.trainer[k] = true end
            end
        end
    end
    if UnitClass then
        local _, class = UnitClass("player")
        if type(class) == "string" then p.class = class end
    end
    if not p.specsDefaulted and type(p.roles) == "table" then
        p.roles.Tank = true
        p.roles.Healer = true
        p.roles.Melee, p.roles.Hunter, p.roles.Caster = false, false, false
        local class = p.previewClass or p.class
        if RRP.DPSRolesFor then
            for _, role in ipairs(RRP.DPSRolesFor(class)) do p.roles[role] = true end
        else
            p.roles.Melee = true
        end
        if class == "PALADIN" then p.roles.Paladin = true end
        p.specsDefaulted = true
    end
    if type(p.yourSpec) ~= "table" then
        local class = p.previewClass or p.class
        local spec = {Tank = false, Healer = false, DPS = true}
        if class == "WARRIOR" then spec.Tank = true
        elseif class == "PALADIN" or class == "DRUID" or class == "SHAMAN" then
            spec.Tank, spec.Healer = true, true
        elseif class == "PRIEST" then spec.Healer = true
        end
        p.yourSpec = spec
    end
    if p.specMode ~= "all" and p.specMode ~= "yours" then
        p.specMode = "all"
    end
    return p
end

function RRP.GetRecipes()
    local result = {}
    for _, r in ipairs(RRP.Catalog) do result[#result + 1] = r end
    if RRPDB and RRPDB.discovered then
        for key, d in pairs(RRPDB.discovered) do
            if not RRP.ByKey[key] then result[#result + 1] = d end
        end
    end
    table.sort(result, function(a, b)
        if a.profession ~= b.profession then return a.profession < b.profession end
        if (a.level or 0) ~= (b.level or 0) then return (a.level or 0) < (b.level or 0) end
        return a.name < b.name
    end)
    return result
end

function RRP.GetByKey(key)
    return RRP.ByKey[key] or (RRPDB and RRPDB.discovered and RRPDB.discovered[key])
end

function RRP.IsDiscovered(r)
    return r and not RRP.ByKey[r.key] and r.source == "vendor-scan"
end

function RRP.OutputRef(recipe)
    if not recipe then return nil end
    local static = RRP.Schematics and RRP.Schematics[recipe.key]
    if type(static) == "table" and not static.incomplete then
        if static.kind == "enchant" and tonumber(static.spellID) then
            return {spellID = tonumber(static.spellID), kind = "enchant"}
        end
        if tonumber(static.outputItemID) then
            return {
                itemID = tonumber(static.outputItemID),
                spellID = tonumber(static.spellID),
                kind = static.kind or "item",
            }
        end
    end
    local ref = {
        itemID = tonumber(recipe.outputItemID),
        link = recipe.outputLink,
        spellID = tonumber(recipe.spellID),
        kind = recipe.outputKind,
    }
    local saved = RRPDB and RRPDB.outputs and RRPDB.outputs[recipe.key]
    if type(saved) == "table" then
        if not ref.itemID then ref.itemID = tonumber(saved.itemID) end
        if not ref.link then ref.link = saved.link end
        if not ref.spellID then ref.spellID = tonumber(saved.spellID) end
        if not ref.kind then ref.kind = saved.kind end
    end
    local schematic = RRPDB and RRPDB.materials and RRPDB.materials[recipe.key]
    if type(schematic) == "table" then
        if not ref.itemID then ref.itemID = tonumber(schematic.outputItemID) end
        if not ref.link and type(schematic.outputLink) == "string" then ref.link = schematic.outputLink end
    end
    if type(static) == "table" then
        if not ref.itemID then ref.itemID = tonumber(static.outputItemID) end
        if not ref.spellID then ref.spellID = tonumber(static.spellID) end
        if not ref.kind and static.kind == "enchant" then ref.kind = "enchant" end
    end
    if not ref.itemID and not ref.link and not ref.spellID then return nil end
    return ref
end

function RRP.OutputHyperlink(ref)
    if not ref then return nil end
    if type(ref.link) == "string" and ref.link ~= "" then
        return ref.link:match("|H([^|]+)|h") or ref.link
    end
    if ref.itemID then return "item:" .. ref.itemID end
    if ref.spellID then
        if ref.kind == "enchant" then return "enchant:" .. ref.spellID end
        return "spell:" .. ref.spellID
    end
    return nil
end

RRP.pendingItems = {}
RRP.itemNames = {}

function RRP.RequestItem(id)
    id = tonumber(id)
    if not id then return end
    if RRP.itemNames[id] then return end
    if type(GetItemInfo) == "function" then
        local ok, name = pcall(GetItemInfo, id)
        if ok and type(name) == "string" and name ~= "" then
            RRP.itemNames[id] = name
            return
        end
    end
    if C_Item and type(C_Item.RequestLoadItemDataByID) == "function" then
        pcall(C_Item.RequestLoadItemDataByID, id)
    end
    if not RRP.pendingItems[id] then RRP.pendingItems[id] = 0 end
end

function RRP.PollPendingItems()
    if not next(RRP.pendingItems) then return end
    local ready = false
    for id, tries in pairs(RRP.pendingItems) do
        local name
        if type(GetItemInfo) == "function" then
            local ok, value = pcall(GetItemInfo, id)
            if ok then name = value end
        end
        if type(name) == "string" and name ~= "" then
            RRP.itemNames[id] = name
            RRP.pendingItems[id] = nil
            ready = true
        else
            local count = (tries or 0) + 1
            if count > 16 then RRP.pendingItems[id] = nil
            else RRP.pendingItems[id] = count end
        end
    end
    if ready and RRP.QueueRefresh then RRP.QueueRefresh() end
end

function RRP.RequestOutput(ref)
    if not ref then return end
    local id = tonumber(ref.itemID)
    if id then
        if type(GetItemInfo) == "function" then pcall(GetItemInfo, id) end
        if C_Item and type(C_Item.RequestLoadItemDataByID) == "function" then
            pcall(C_Item.RequestLoadItemDataByID, id)
        end
    end
    local spellID = tonumber(ref.spellID)
    if spellID and C_Spell and type(C_Spell.RequestLoadSpellData) == "function" then
        pcall(C_Spell.RequestLoadSpellData, spellID)
    end
end

function RRP.ScrollID(r)
    if not r then return nil end
    local static = RRP.Schematics and RRP.Schematics[r.key]
    if type(static) == "table" and tonumber(static.scrollItemID) then
        return tonumber(static.scrollItemID)
    end
    if RRPDB and RRPDB.scrollItems and RRPDB.scrollItems[r.key] then
        return RRPDB.scrollItems[r.key]
    end
    return r.scrollItemID
end

-- The built-in schematic is authoritative when it is complete.
-- A saved profession scan fills a gap only while the static record is missing or incomplete.
function RRP.Schematic(key)
    local static = RRP.Schematics and RRP.Schematics[key]
    local staticMats = type(static) == "table" and type(static.materials) == "table" and static.materials or nil
    if staticMats and #staticMats > 0 and not static.incomplete then
        return static
    end
    local saved = RRPDB and RRPDB.materials and RRPDB.materials[key]
    local savedMats = type(saved) == "table" and type(saved.materials) == "table" and saved.materials or nil
    if savedMats and #savedMats > 0 and not saved.incomplete then
        return saved
    end
    if staticMats and #staticMats > 0 then return static end
    if savedMats and #savedMats > 0 then return saved end
    return static or saved
end

local function characterID()
    local realm = (GetRealmName and GetRealmName()) or "Realm"
    local name = (UnitName and UnitName("player")) or "Player"
    return realm .. "-" .. name
end

-- Recipes confirmed learned in this session. A stale profession window can
-- still list the old recipes and must not clear these marks.
local learnedThisSession = {}

local function rememberSessionLearn(key)
    if type(key) == "string" then learnedThisSession[characterID() .. "\n" .. key] = true end
end

local function sessionKnows(key)
    return learnedThisSession[characterID() .. "\n" .. key] and true or false
end

local function spellIsKnown(spellID)
    spellID = tonumber(spellID)
    if not spellID then return false end
    if type(IsSpellKnown) == "function" then
        local ok, known = pcall(IsSpellKnown, spellID)
        if ok and known then return true end
    end
    if type(IsPlayerSpell) == "function" then
        local ok, known = pcall(IsPlayerSpell, spellID)
        if ok and known then return true end
    end
    if C_SpellBook and type(C_SpellBook.IsSpellKnown) == "function" then
        local ok, known = pcall(C_SpellBook.IsSpellKnown, spellID)
        if ok and known then return true end
    end
    return false
end

local function schematicSpell(key)
    local sch = RRP.Schematics and RRP.Schematics[key]
    if type(sch) ~= "table" then return nil end
    return tonumber(sch.spellID)
end

local function spellName(spellID)
    local name = safeCall(GetSpellInfo, spellID)
    if type(name) == "string" and name ~= "" then return name end
    if C_Spell and type(C_Spell.GetSpellName) == "function" then
        local spell = safeCall(C_Spell.GetSpellName, spellID)
        if type(spell) == "string" and spell ~= "" then return spell end
    end
    if C_Spell and type(C_Spell.GetSpellInfo) == "function" then
        local info = safeCall(C_Spell.GetSpellInfo, spellID)
        if type(info) == "table" and type(info.name) == "string" and info.name ~= "" then return info.name end
        if type(info) == "string" and info ~= "" then return info end
    end
    if C_TradeSkillUI and type(C_TradeSkillUI.GetRecipeInfo) == "function" then
        local info = safeCall(C_TradeSkillUI.GetRecipeInfo, spellID)
        if type(info) == "table" and type(info.name) == "string" and info.name ~= "" then return info.name end
    end
end

local function noteLearned(p, key, session)
    if not p or type(key) ~= "string" then return false end
    p.known = p.known or {}
    if session then rememberSessionLearn(key) end
    if p.known[key] then return false end
    p.known[key] = true
    return true
end

local function refreshLearned()
    if RRP.QueueRefresh then RRP.QueueRefresh()
    elseif RRP.Refresh then RRP.Refresh() end
end

function RRP.LearnState(recipe)
    if not recipe then return "unlearned" end
    local p = RRP.GetProfile()
    if not p then return "unlearned" end
    if p.known and p.known[recipe.key] then return "learned" end
    if sessionKnows(recipe.key) or spellIsKnown(schematicSpell(recipe.key)) then
        noteLearned(p, recipe.key, true)
        return "learned"
    end
    return "unlearned"
end

function RRP.SyncKnownSpells()
    local p = RRP.GetProfile()
    if not p or type(RRP.Schematics) ~= "table" then return false end
    local changed = false
    for key, sch in pairs(RRP.Schematics) do
        if type(sch) == "table" and spellIsKnown(sch.spellID) and noteLearned(p, key, true) then
            changed = true
        end
    end
    if changed then refreshLearned() end
    return changed
end

function RRP.RecordLearnScan(profession, seen, complete, rows)
    local p = RRP.GetProfile()
    if not p or type(profession) ~= "string" or not RRP.ProfessionsSet[profession] then return end
    p.known = p.known or {}
    p.learnScan = p.learnScan or {}
    seen = type(seen) == "table" and seen or {}
    if complete then
        local knownBefore, seenCount = 0, 0
        for _, r in ipairs(RRP.GetRecipes()) do
            if r.profession == profession and p.known[r.key] then knownBefore = knownBefore + 1 end
        end
        for _, on in pairs(seen) do
            if on then seenCount = seenCount + 1 end
        end
        -- A window that still shows the old list has fewer learned rows than we
        -- already recorded. Keep those marks until the list catches up.
        local keepKnown = seenCount < knownBefore
        for _, r in ipairs(RRP.GetRecipes()) do
            if r.profession == profession then
                local keep = seen[r.key] or sessionKnows(r.key) or spellIsKnown(schematicSpell(r.key))
                if not keep and keepKnown and p.known[r.key] then keep = true end
                p.known[r.key] = keep and true or nil
            end
        end
        local stamp = 0
        if type(time) == "function" then stamp = time() end
        p.learnScan[profession] = {complete = true, at = stamp, rows = tonumber(rows) or 0}
    else
        for key, on in pairs(seen) do
            if on then p.known[key] = true end
        end
    end
    RRP.SyncKnownSpells()
end

function RRP.MarkLearnedSpell(spellID)
    spellID = tonumber(spellID)
    if not spellID then return end
    local p = RRP.GetProfile()
    if not p then return end
    p.known = p.known or {}
    local changed, matched = false, false
    if type(RRP.Schematics) == "table" then
        for key, sch in pairs(RRP.Schematics) do
            if type(sch) == "table" and tonumber(sch.spellID) == spellID then
                matched = true
                if noteLearned(p, key, true) then changed = true end
            end
        end
    end
    if not matched then
        local name = spellName(spellID)
        local matches = {}
        if type(name) == "string" then
            local want = normalize(name)
            for _, recipe in ipairs(RRP.GetRecipes()) do
                if normalize(recipe.name) == want then matches[#matches + 1] = recipe end
            end
        end
        if #matches == 1 and noteLearned(p, matches[1].key, true) then changed = true end
    end
    if changed then refreshLearned() end
end

RRP.ClassOrder = {"WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID"}
RRP.ClassNames = {
    WARRIOR = "Warrior", PALADIN = "Paladin", HUNTER = "Hunter", ROGUE = "Rogue",
    PRIEST = "Priest", SHAMAN = "Shaman", MAGE = "Mage", WARLOCK = "Warlock", DRUID = "Druid",
}

function RRP.ViewClass()
    local p = RRP.GetProfile()
    if not p then return nil end
    return p.previewClass or p.class
end

function RRP.DPSRolesFor(class)
    if class == "MAGE" or class == "WARLOCK" or class == "PRIEST" then
        return {"Caster"}
    elseif class == "SHAMAN" or class == "DRUID" then
        return {"Melee", "Caster"}
    elseif class == "HUNTER" then
        return {"Hunter", "Melee"}
    end
    return {"Melee"}
end

-- Mana classes can drink caster Alchemy. This is not a gear role.
function RRP.UsesMana(class)
    return class == "HUNTER" or class == "PALADIN" or class == "SHAMAN"
        or class == "DRUID" or class == "PRIEST" or class == "MAGE"
        or class == "WARLOCK"
end

function RRP.LevelTone(required, have)
    if type(required) ~= "number" or type(have) ~= "number" then return 0.75, 0.7, 0.6 end
    if required <= have then return 0.3, 0.9, 0.35 end
    if required <= have + 3 then return 1, 0.55, 0.12 end
    return 0.95, 0.22, 0.18
end

function RRP.Colorize(text, r, g, b)
    text = tostring(text or "")
    if type(r) ~= "number" or type(g) ~= "number" or type(b) ~= "number" then return text end
    return string.format("|cff%02x%02x%02x%s|r",
        math.floor(r * 255 + 0.5), math.floor(g * 255 + 0.5), math.floor(b * 255 + 0.5), text)
end

function RRP.SkillTone(profession, required)
    required = tonumber(required)
    if not required then return 0.75, 0.7, 0.6 end
    local rank = RRP.ProfessionRank(profession)
    if not rank then return 0.95, 0.25, 0.2 end
    if rank >= required then return 0.3, 0.9, 0.35 end
    return 0.95, 0.25, 0.2
end

local function isSkillCap(n)
    return n == 75 or n == 150 or n == 225 or n == 300 or n == 375
end

local function rankFromText(text)
    if type(text) ~= "string" then return nil end
    return tonumber(text:match("(%d+)%s*/%s*%d+"))
end

local function skillNumber(value)
    local n = tonumber(value)
    if n and n > 0 and n <= 375 then return n end
end

-- The character sheet shows skillRank + skillModifier. Clients also put the
-- full number in a later return, so keep whichever reading is higher.
local function rankFromSkillValues(values)
    local nums = {}
    for i = 4, #values do
        local n = skillNumber(values[i])
        if n then nums[#nums + 1] = n end
    end
    local cap = 0
    for i = 1, #nums do
        if isSkillCap(nums[i]) and nums[i] > cap then cap = nums[i] end
    end
    local best
    for i = 1, #nums do
        local n = nums[i]
        if not isSkillCap(n) and (cap == 0 or n <= cap) then
            if not best or n > best then best = n end
        end
    end
    local rank = skillNumber(values[4])
    local fifth = skillNumber(values[5])
    local sixth = skillNumber(values[6])
    local function addBonus(total)
        if not total or total > 375 then return end
        if cap > 0 and total > cap then return end
        if not best or total > best then best = total end
    end
    if rank and sixth and not isSkillCap(sixth) and sixth < 40 then
        addBonus(rank + sixth)
    end
    if rank and fifth and sixth and isSkillCap(sixth) and not isSkillCap(fifth) and fifth < 40 then
        addBonus(rank + fifth)
    end
    if best then return best end
    local caps = {}
    for i = 1, #nums do
        if isSkillCap(nums[i]) then caps[#caps + 1] = nums[i] end
    end
    table.sort(caps)
    if #caps >= 2 then return caps[1] end
    return caps[1]
end

local function considerRank(best, rank)
    rank = tonumber(rank)
    if rank and (not best or rank > best) then return rank end
    return best
end

function RRP.ProfessionRank(profession)
    if not profession or profession == "" then return nil end
    local best
    if type(GetTradeSkillLine) == "function" then
        local name, rank = GetTradeSkillLine()
        if name == profession then best = considerRank(best, rank) end
    end
    local title = _G and _G.TradeSkillFrameTitleText
    local shown = _G and _G.TradeSkillRankFrameSkillRank
    local bar = _G and _G.TradeSkillRankFrame
    if title and title.GetText and (title:GetText() or ""):find(profession, 1, true) then
        if shown and shown.GetText then
            best = considerRank(best, rankFromText(shown:GetText()))
        end
        if bar and bar.GetValue then best = considerRank(best, bar:GetValue()) end
    end
    if _G then
        for i = 1, 20 do
            local nameFS = _G["SkillRankFrame" .. i .. "SkillName"]
            local rankFS = _G["SkillRankFrame" .. i .. "SkillRank"]
            if nameFS and rankFS and nameFS.GetText and rankFS.GetText and nameFS:GetText() == profession then
                best = considerRank(best, rankFromText(rankFS:GetText()))
            end
        end
    end
    if type(GetProfessions) == "function" and type(GetProfessionInfo) == "function" then
        local ids = {GetProfessions()}
        for i = 1, #ids do
            if ids[i] then
                local name, _, level, _, _, _, _, modifier = GetProfessionInfo(ids[i])
                level = tonumber(level)
                modifier = tonumber(modifier)
                if name == profession and level then
                    if modifier and modifier > 0 and modifier < 40 and level + modifier <= 375 then
                        level = level + modifier
                    end
                    best = considerRank(best, level)
                end
            end
        end
    end
    if type(GetNumSkillLines) == "function" and type(GetSkillLineInfo) == "function" then
        local n = GetNumSkillLines() or 0
        for i = 1, n do
            local values = {GetSkillLineInfo(i)}
            if not values[2] and values[1] == profession then
                best = considerRank(best, rankFromSkillValues(values))
            end
        end
    end
    local p = RRP.GetProfile()
    local text = p and p.professionRanks and p.professionRanks[profession]
    local saved = type(text) == "number" and text or nil
    if not saved and type(text) == "string" then saved = tonumber(text:match("(%d+)")) end
    best = considerRank(best, saved)
    if p and best then p.professionRanks[profession] = tostring(best) end
    return best
end

function RRP.NeedColor(amount, owned)
    amount = tonumber(amount) or 0
    if type(owned) == "number" and owned >= amount then return 0.3, 0.9, 0.35 end
    return 0.95, 0.25, 0.2
end

function RRP.RecipeFavor(recipe)
    if not recipe then return nil end
    local faction = RRP.PlayerFaction and RRP.PlayerFaction()
    local overrides = faction and RRP.FactionOverrides and RRP.FactionOverrides[faction]
    local over = overrides and overrides[recipe.key]
    if type(over) == "table" and over.favor ~= nil then return over.favor end
    return recipe.favor
end

-- Learned recipes are already owned, so they do not add a purchase cost.
function RRP.PlanFavor(recipe)
    if not recipe then return nil end
    if RRP.LearnState(recipe) == "learned" then return 0 end
    return RRP.RecipeFavor(recipe)
end

-- Hunters and shamans wear mail from item level 40. Before that they wear
-- leather and cloth. Plate stays with warriors and paladins. Cloth fits everyone.
function RRP.CanWear(recipe, class)
    if not recipe or not recipe.armor or not class then return true end
    local armor = recipe.armor
    if class == "WARRIOR" or class == "PALADIN" then return true end
    if armor == "cloth" then return true end
    if armor == "leather" then
        return class == "HUNTER" or class == "SHAMAN" or class == "ROGUE" or class == "DRUID"
    end
    if armor == "mail" then
        if class ~= "HUNTER" and class ~= "SHAMAN" then return false end
        return type(recipe.level) == "number" and recipe.level >= 40
    end
    if armor == "plate" then return false end
    return true
end

-- Class limits are separate from build tags. A Paladin role tag highlights
-- a recipe for paladins. It does not hide a weapon a warrior can equip.
function RRP.IsRelevant(r)
    local p = RRP.GetProfile()
    if not p or p.showAll or p.allClasses ~= false then return true end
    local class = p.previewClass or p.class
    if r.classes and class and not hasToken(r.classes, class) then
        return false
    end
    if not RRP.CanWear(r, class) then return false end
    local paladin = p.roles.Paladin or class == "PALADIN"
    if r.exclusive == "Paladin" and not paladin then
        return false
    elseif r.exclusive and r.exclusive ~= "Paladin" and not p.roles[r.exclusive] then
        return false
    end
    return true
end

function RRP.HasScannedProfession()
    local p = RRP.GetProfile()
    if not p or type(p.learnScan) ~= "table" then return false end
    for _, name in ipairs(RRP.Professions) do
        if name ~= "All" and type(p.learnScan[name]) == "table" then return true end
    end
    return false
end

function RRP.UnscannedProfessions()
    local p = RRP.GetProfile()
    if not p or type(p.professions) ~= "table" then return {} end
    local missing = {}
    for _, name in ipairs(RRP.Professions) do
        if name ~= "All" and p.professions[name] then
            local scan = p.learnScan and p.learnScan[name]
            if type(scan) ~= "table" then missing[#missing + 1] = name end
        end
    end
    return missing
end

function RRP.ProfessionBookOpen()
    local frames = {ProfessionsBookFrame, ProfessionsFrame, SpellBookProfessionFrame, PlayerSpellsFrame, SpellBookFrame}
    for _, frame in ipairs(frames) do
        if frame and frame.IsShown and frame:IsShown() then return true end
    end
    return false
end

function RRP.OpenProfessionBook()
    if type(ToggleProfessionsBook) == "function" then
        pcall(ToggleProfessionsBook)
        return
    end
    if type(ToggleSpellBook) ~= "function" then return end
    if BOOKTYPE_PROFESSION then
        pcall(ToggleSpellBook, BOOKTYPE_PROFESSION)
    else
        pcall(ToggleSpellBook, BOOKTYPE_SPELL or "spell")
    end
end

function RRP.BuildMatch(r)
    local p = RRP.GetProfile()
    if not p or not r or not r.roles then return false end
    if p.allRoles then return true end
    local wanted = {}
    local any = false
    if p.roles.Tank then wanted.Tank = true any = true end
    if p.roles.Healer then wanted.Healer = true any = true end
    if RRP.BuildOn("DPS") then
        any = true
        if p.allClasses ~= false then
            wanted.Melee, wanted.Hunter, wanted.Caster = true, true, true
        else
            local class = RRP.ViewClass()
            for _, role in ipairs(RRP.DPSRolesFor(class)) do wanted[role] = true end
            if r.profession == "Alchemy" and RRP.UsesMana(class) then
                wanted.Caster = true
            end
        end
    end
    -- Utility recipes stay with every build instead of a separate Other filter.
    if not any then return false end
    wanted.Utility = true
    for part in r.roles:gmatch("[^,]+") do
        if wanted[trim(part)] then return true end
    end
    return false
end

function RRP.VisibleRecipes()
    local p = RRP.GetProfile()
    local t = {}
    local q = p and normalize(p.search or "") or ""
    for _, r in ipairs(RRP.GetRecipes()) do
        if (not p or p.profession == "All" or p.profession == r.profession) and RRP.IsRelevant(r) then
            if p and not p.showAll and not RRP.BuildMatch(r) then
                -- The checked builds are the list. Show All Recipes lifts this.
            elseif p and p.hideLearned and p.known and p.known[r.key] then
                -- Hidden by the learned filter.
            elseif q == "" or normalize(r.name .. " " .. (r.roles or "")):find(q, 1, true) then
                t[#t + 1] = r
            end
        end
    end
    local key = p and p.sortKey or "name"
    local desc = p and p.sortDesc
    table.sort(t, function(a, b)
        local av, bv
        if key == "skill" then av, bv = a.skill or -1, b.skill or -1
        elseif key == "level" then av, bv = a.level or -1, b.level or -1
        elseif key == "favor" then av, bv = a.favor or -1, b.favor or -1
        else av, bv = a.name or "", b.name or "" end
        if av ~= bv then
            if desc then return av > bv end
            return av < bv
        end
        return (a.name or "") < (b.name or "")
    end)
    return t
end

function RRP.SelectedRecipe()
    local r = RRP.selectedKey and RRP.GetByKey(RRP.selectedKey)
    if r then return r end
    local list = RRP.VisibleRecipes()
    r = list[1]
    if r then RRP.selectedKey = r.key end
    return r
end

function RRP.ShowRecipe(key)
    if not key or RRP.selectedKey == key then return end
    if not RRP.GetByKey(key) then return end
    RRP.selectedKey = key
    if RRP.UI and RRP.UI.RefreshDetails then RRP.UI.RefreshDetails() end
end

function RRP.ProfessionSummary()
    local p = RRP.GetProfile()
    if not p or type(p.professions) ~= "table" then return nil end
    local names = {}
    for _, name in ipairs(RRP.Professions) do
        if p.professions[name] then
            local rank = p.professionRanks and p.professionRanks[name]
            names[#names + 1] = rank and (name .. " " .. rank) or name
        end
    end
    if #names == 0 then return nil end
    return table.concat(names, ", ")
end

function RRP.PlanOn(key)
    local p = RRP.GetProfile()
    local value = p and p.plan and key and p.plan[key]
    return value == true or (type(value) == "number" and value > 0)
end
function RRP.SetSelected(key, on)
    local p = RRP.GetProfile()
    if not p or not key then return end
    RRP.clearArmed = nil
    p.plan[key] = on and true or nil
    if RRP.Refresh then RRP.Refresh() end
end
function RRP.Increment(key, delta)
    RRP.SetSelected(key, (tonumber(delta) or 0) > 0)
end
function RRP.SetProfession(prof)
    local p = RRP.GetProfile()
    if not p then return end
    p.profession, p.page, p.professionPicked = prof, 1, true
    if RRP.BroadProfessions and RRP.BroadProfessions[prof] then
        p.allClasses = true
    end
    if RRP.AllSpecProfessions and RRP.AllSpecProfessions[prof] and RRP.EnableAllSpecs then
        RRP.EnableAllSpecs()
    end
    RRP.clearArmed = nil
    if RRP.Refresh then RRP.Refresh() end
end
function RRP.SetSearch(text)
    local p = RRP.GetProfile()
    if not p then return end
    text = trim(text or "")
    if text == "" then text = nil end
    if p.search == text then return end
    p.search = text
    p.page = 1
    RRP.clearArmed = nil
    if RRP.Refresh then RRP.Refresh() end
end
function RRP.SetQuantity(key, qty)
    RRP.SetSelected(key, (tonumber(qty) or 0) > 0)
end
function RRP.ToggleKnown(key)
    local p = RRP.GetProfile()
    if not p or not key then return end
    p.known[key] = not p.known[key] and true or nil
    if RRP.Refresh then RRP.Refresh() end
end
function RRP.SetHideLearned(on)
    local p = RRP.GetProfile()
    if not p then return end
    p.hideLearned = on and true or false
    p.page = 1
    if RRP.Refresh then RRP.Refresh() end
end
function RRP.SetSort(key)
    local p = RRP.GetProfile()
    if not p then return end
    if p.sortKey == key then p.sortDesc = not p.sortDesc
    else p.sortKey, p.sortDesc = key, false end
    p.page = 1
    if RRP.Refresh then RRP.Refresh() end
end
function RRP.SetPreviewClass(class)
    local p = RRP.GetProfile()
    if not p then return end
    local keepDps = RRP.BuildOn("DPS")
    if not class or class == "" or class == p.class then p.previewClass = nil
    else p.previewClass = class end
    if keepDps then
        p.roles.Melee, p.roles.Hunter, p.roles.Caster = false, false, false
        for _, role in ipairs(RRP.DPSRolesFor(RRP.ViewClass())) do
            p.roles[role] = true
        end
    end
    p.page = 1
    if RRP.Refresh then RRP.Refresh() end
end
function RRP.BuildOn(name)
    local p = RRP.GetProfile()
    if not p then return false end
    if name == "Tank" then return p.roles.Tank and true or false end
    if name == "Healer" then return p.roles.Healer and true or false end
    if name == "Other" then return p.roles.Utility and true or false end
    if name == "DPS" then
        for _, role in ipairs(RRP.DPSRolesFor(RRP.ViewClass())) do
            if p.roles[role] then return true end
        end
    end
    return false
end
function RRP.SetBuild(name, on)
    local p = RRP.GetProfile()
    if not p then return end
    on = on and true or false
    p.showAll = false
    p.allRoles = false
    if name == "Tank" then p.roles.Tank = on
    elseif name == "Healer" then p.roles.Healer = on
    elseif name == "Other" then p.roles.Utility = on
    elseif name == "DPS" then
        p.roles.Melee, p.roles.Hunter, p.roles.Caster = false, false, false
        if on then
            for _, role in ipairs(RRP.DPSRolesFor(RRP.ViewClass())) do
                p.roles[role] = true
            end
        end
    end
    local tank = p.roles.Tank and true or false
    local healer = p.roles.Healer and true or false
    local dps = false
    for _, role in ipairs(RRP.DPSRolesFor(p.previewClass or p.class)) do
        if p.roles[role] then dps = true end
    end
    if not tank and not healer and not dps then
        if name == "Tank" then p.roles.Tank = true tank = true
        elseif name == "Healer" then p.roles.Healer = true healer = true
        elseif name == "DPS" then
            for _, role in ipairs(RRP.DPSRolesFor(p.previewClass or p.class)) do
                p.roles[role] = true
            end
            dps = true
        end
    end
    if tank and healer and dps then
        p.specMode = "all"
    else
        p.specMode = "yours"
        p.yourSpec = {Tank = tank, Healer = healer, DPS = dps}
    end
    p.page = 1
    RRP.clearArmed = nil
    if RRP.Refresh then RRP.Refresh() end
end
function RRP.FavorBalance()
    local function match(name, count, icon)
        if type(name) == "string" and name:find("Merchant") and name:find("Favor") and type(count) == "number" then
            return count, icon, name
        end
    end
    if type(GetCurrencyListSize) == "function" and type(GetCurrencyListInfo) == "function" then
        local n = GetCurrencyListSize()
        if type(n) == "number" then
            for i = 1, n do
                local name, isHeader, _, _, _, count, icon = GetCurrencyListInfo(i)
                if not isHeader then
                    local balance, foundIcon, foundName = match(name, count, icon)
                    if balance then return balance, foundIcon, foundName end
                end
            end
        end
    end
    local api = C_CurrencyInfo
    if type(api) == "table" and type(api.GetCurrencyListSize) == "function" and type(api.GetCurrencyListInfo) == "function" then
        local n = api.GetCurrencyListSize()
        if type(n) == "number" then
            for i = 1, n do
                local info = api.GetCurrencyListInfo(i)
                if type(info) == "table" and not info.isHeader then
                    local balance, foundIcon, foundName = match(info.name, info.quantity, info.iconFileID)
                    if balance then return balance, foundIcon, foundName end
                end
            end
        end
    end
    return nil
end
function RRP.ToggleRole(role)
    local p = RRP.GetProfile()
    if not p then return end
    if role == "All" then
        p.showAll = not p.showAll
        if p.showAll then p.allRoles = false end
    else
        p.showAll = false
        p.allRoles = false
        p.roles[role] = not p.roles[role]
    end
    p.page = 1
    RRP.clearArmed = nil
    if RRP.Refresh then RRP.Refresh() end
end
local function writeSpecs(p, on)
    p.showAll = false
    p.allRoles = false
    p.roles.Tank = on and true or false
    p.roles.Healer = on and true or false
    p.roles.Melee, p.roles.Hunter, p.roles.Caster = false, false, false
    if on then
        for _, role in ipairs(RRP.DPSRolesFor(RRP.ViewClass())) do
            p.roles[role] = true
        end
        if RRP.ViewClass() == "PALADIN" then p.roles.Paladin = true end
    end
    p.specsDefaulted = true
end

function RRP.ToggleAllClasses()
    local p = RRP.GetProfile()
    if not p then return end
    p.allClasses = not (p.allClasses ~= false)
    if not p.allClasses then p.previewClass = nil end
    p.page = 1
    RRP.clearArmed = nil
    if RRP.Refresh then RRP.Refresh() end
end

local function applyYourSpec(p)
    local spec = p.yourSpec or {}
    p.showAll = false
    p.allRoles = false
    p.roles.Tank = spec.Tank and true or false
    p.roles.Healer = spec.Healer and true or false
    p.roles.Melee, p.roles.Hunter, p.roles.Caster = false, false, false
    if spec.DPS then
        for _, role in ipairs(RRP.DPSRolesFor(RRP.ViewClass())) do
            p.roles[role] = true
        end
    end
    if RRP.ViewClass() == "PALADIN" then p.roles.Paladin = true end
    p.specsDefaulted = true
    p.specMode = "yours"
end

function RRP.EnableAllSpecs()
    local p = RRP.GetProfile()
    if not p then return end
    writeSpecs(p, true)
    p.specMode = "all"
end

function RRP.ShowAllSpecs()
    local p = RRP.GetProfile()
    if not p then return end
    local nextMode = p.specMode == "yours" and "all" or "yours"
    p.showAll = false
    p.allRoles = false
    if nextMode == "yours" then applyYourSpec(p)
    else
        writeSpecs(p, true)
        p.specMode = "all"
    end
    p.page = 1
    RRP.clearArmed = nil
    if RRP.Refresh then RRP.Refresh() end
end
function RRP.ClearPlan()
    local p = RRP.GetProfile()
    if not p then return end
    local now = GetTime and GetTime() or 0
    if not RRP.clearArmed or now - RRP.clearArmed > 6 then
        RRP.clearArmed = now
        say("Click Clear Selection again to erase the shopping plan.")
        if RRP.Refresh then RRP.Refresh() end
        return
    end
    RRP.clearArmed = nil
    p.plan = {}
    say("Plan cleared.")
    if RRP.Refresh then RRP.Refresh() end
end
function RRP.ForgetDiscovered(key)
    if not key or RRP.ByKey[key] or not RRPDB or not RRPDB.discovered or not RRPDB.discovered[key] then
        return
    end
    local name = RRPDB.discovered[key].name
    RRPDB.discovered[key] = nil
    if RRPDB.materials then RRPDB.materials[key] = nil end
    if RRPDB.scrollItems then RRPDB.scrollItems[key] = nil end
    local p = RRP.GetProfile()
    if p then
        if p.plan then p.plan[key] = nil end
        if p.known then p.known[key] = nil end
        if p.trainer then p.trainer[key] = nil end
    end
    if RRP.selectedKey == key then RRP.selectedKey = nil end
    say("Removed discovered recipe" .. (name and (": " .. name) or "") .. ".")
    if RRP.Refresh then RRP.Refresh() end
end
function RRP.CycleTrainer(key)
    local p = RRP.GetProfile()
    if not p then return end
    p.trainer = p.trainer or {}
    p.trainer[key] = not p.trainer[key] and true or nil
    if RRP.Refresh then RRP.Refresh() end
end
function RRP.GetTrainerStatus(r)
    local p = RRP.GetProfile()
    if p and p.trainer and p.trainer[r.key] then
        return "Trainer: you marked this (unverified)"
    end
    return "Trainer: not verified"
end

local slotCounts

local function bagSlotCount(bag)
    if C_Container and type(C_Container.GetContainerNumSlots) == "function" then
        return tonumber(C_Container.GetContainerNumSlots(bag)) or 0
    end
    if type(GetContainerNumSlots) == "function" then
        return tonumber(GetContainerNumSlots(bag)) or 0
    end
    return 0
end

local function bagSlotItem(bag, slot)
    if C_Container and type(C_Container.GetContainerItemInfo) == "function" then
        local info = C_Container.GetContainerItemInfo(bag, slot)
        if type(info) == "table" then
            return tonumber(info.itemID), tonumber(info.stackCount) or 1
        end
    end
    if type(GetContainerItemInfo) == "function" then
        local _, count, _, _, _, _, link, _, _, id = GetContainerItemInfo(bag, slot)
        id = tonumber(id) or itemIdFromLink(link)
        if id then return id, tonumber(count) or 1 end
    end
    if type(GetContainerItemID) == "function" then
        local id = tonumber(GetContainerItemID(bag, slot))
        local count = 1
        if type(GetContainerItemInfo) == "function" then
            local _, n = GetContainerItemInfo(bag, slot)
            count = tonumber(n) or 1
        end
        return id, count
    end
end

local function readSlotCounts()
    local counts, saw = {}, false
    for bag = 0, 4 do
        local slots = bagSlotCount(bag)
        if slots > 0 then saw = true end
        for slot = 1, slots do
            local id, count = bagSlotItem(bag, slot)
            if id and count and count > 0 then
                counts[id] = (counts[id] or 0) + count
            end
        end
    end
    if saw then slotCounts = counts end
    return saw
end

function RRP.InvalidateBagCache()
    slotCounts = nil
end

function RRP.BagsReadable()
    if type(GetItemCount) == "function" then return true end
    if C_Item and type(C_Item.GetItemCount) == "function" then return true end
    if slotCounts then return true end
    return readSlotCounts()
end
local function bagCount(id)
    id = tonumber(id)
    if not id then return 0 end
    if type(GetItemCount) == "function" then
        local owned = safeCall(GetItemCount, id, false)
        if type(owned) ~= "number" then owned = safeCall(GetItemCount, id) end
        if type(owned) == "number" then return owned end
    end
    if C_Item and type(C_Item.GetItemCount) == "function" then
        local owned = safeCall(C_Item.GetItemCount, id, false)
        if type(owned) ~= "number" then owned = safeCall(C_Item.GetItemCount, id) end
        if type(owned) == "number" then return owned end
    end
    if not slotCounts then readSlotCounts() end
    if slotCounts then return slotCounts[id] or 0 end
    return 0
end
RRP.BagCount = bagCount

local function inspectSchematic(recipeID)
    local api = C_TradeSkillUI
    if not api or type(api.GetRecipeSchematic) ~= "function" then return nil end
    local sch = safeCall(api.GetRecipeSchematic, recipeID, false)
    if type(sch) ~= "table" or type(sch.reagentSlotSchematics) ~= "table" then return nil end
    local materials, incomplete = {}, false
    for _, slot in ipairs(sch.reagentSlotSchematics) do
        if slot.isRequired ~= false then
            local reagents = slot.reagents
            if type(reagents) == "table" and #reagents == 1 then
                local reagent = reagents[1]
                local id = tonumber(reagent.itemID or reagent.itemId)
                local amount = tonumber(slot.quantityRequired or reagent.quantityRequired)
                if id and amount and amount > 0 then
                    materials[id] = (materials[id] or 0) + amount
                else
                    incomplete = true
                end
            else
                incomplete = true
            end
        end
    end
    local result = {}
    for id, qty in pairs(materials) do result[#result + 1] = {itemID = id, quantity = qty} end
    table.sort(result, function(a, b) return a.itemID < b.itemID end)
    if #result == 0 then return nil end
    return {
        materials = result,
        incomplete = incomplete,
        outputItemID = tonumber(sch.outputItemID),
        outputCount = tonumber(sch.quantityMin) or 1,
    }
end

local function staticIsComplete(key)
    local static = RRP.Schematics and RRP.Schematics[key]
    return type(static) == "table" and type(static.materials) == "table" and #static.materials > 0 and not static.incomplete
end

local function storeSchematic(key, sch)
    if staticIsComplete(key) then return false end
    if not sch or type(sch.materials) ~= "table" or #sch.materials == 0 then return false end
    RRPDB.materials = RRPDB.materials or {}
    local old = RRPDB.materials[key]
    if sch.incomplete and type(old) == "table" and not old.incomplete and type(old.materials) == "table" and #old.materials > 0 then
        return false
    end
    RRPDB.materials[key] = sch
    return true
end

local function indexProfession(profession)
    local index = {}
    for _, r in ipairs(RRP.GetRecipes()) do
        if r.profession == profession then
            index[normalize(r.name)] = r
        end
    end
    return index
end

local function rememberProfession(name, rankText)
    if not RRP.ProfessionsSet[name] then return end
    local p = RRP.GetProfile()
    if not p then return end
    p.professions[name] = true
    if rankText then p.professionRanks[name] = rankText end
    if not p.professionPicked and p.profession == "All" then
        p.profession = name
        p.page = 1
    end
end

local function finishScan(profession, matched, cached, missingLinks, opts)
    local p = RRP.GetProfile()
    local sig = matched .. ":" .. cached
    if p then p.scanInfo[profession] = sig end
    if missingLinks then
        local tries = opts.rescan and ((RRP.rescanTries or 0) + 1) or 0
        RRP.rescanTries = tries
        RRP.needRescan = tries < 3
    else
        RRP.needRescan = false
        RRP.rescanTries = 0
    end
    if not opts.quiet then
        local rank = p and p.professionRanks[profession]
        local rankText = rank and (" (" .. rank .. ")") or ""
        say(profession .. rankText .. ": " .. matched .. " learned recipes, " .. cached .. " with reagents.")
    elseif (opts.announce or opts.announceChange) and not opts.rescan then
        say("Just scanned your " .. profession .. ".")
    end
    if RRP.Refresh then RRP.Refresh() end
end

local function tradeSkillFiltered()
    if type(GetTradeSkillItemNameFilter) == "function" then
        local ok, name = pcall(GetTradeSkillItemNameFilter)
        if ok and type(name) == "string" and name ~= "" then return true end
    end
    if type(GetTradeSkillSubClassFilter) == "function" then
        local ok, index = pcall(GetTradeSkillSubClassFilter)
        if ok and type(index) == "number" and index > 0 then return true end
    end
    if type(GetTradeSkillInvSlotFilter) == "function" then
        local ok, index = pcall(GetTradeSkillInvSlotFilter)
        if ok and type(index) == "number" and index > 0 then return true end
    end
    return false
end

local function seenSignature(seen, complete)
    local keys = {}
    for key, on in pairs(seen) do
        if on then keys[#keys + 1] = key end
    end
    table.sort(keys)
    return table.concat(keys, "\n") .. (complete and "\n1" or "\n0")
end

local function rememberOutput(key, record)
    if staticIsComplete(key) then
        local static = RRP.Schematics[key]
        if static.outputItemID or (static.kind == "enchant" and static.spellID) then return end
    end
    if type(record) ~= "table" then return end
    RRPDB.outputs = RRPDB.outputs or {}
    local previous = RRPDB.outputs[key]
    local previousUseful = type(previous) == "table" and (previous.itemID or previous.spellID)
    if record.itemID or record.spellID or not previousUseful then
        RRPDB.outputs[key] = record
    end
end

local function scanClassic(opts)
    if type(GetNumTradeSkills) ~= "function" or type(GetTradeSkillInfo) ~= "function" then
        return "empty"
    end
    local n = GetNumTradeSkills()
    local profName, rank, maxRank = nil, nil, nil
    if type(GetTradeSkillLine) == "function" then
        profName, rank, maxRank = GetTradeSkillLine()
    end
    if type(profName) == "string" then
        profName = trim(profName:match("^[^%(]+") or profName)
    end
    if profName and profName ~= "" and not RRP.ProfessionsSet[profName] then
        return "skip", profName .. " is not in the Merchant's Favor list."
    end
    if type(n) ~= "number" or n <= 0 then return "empty" end
    if not profName or profName == "" then
        return "empty"
    end
    if type(ExpandTradeSkillSubClass) == "function" then
        for i = GetNumTradeSkills(), 1, -1 do
            local _, skillType, _, isExpanded = GetTradeSkillInfo(i)
            if skillType == "header" and not isExpanded then
                ExpandTradeSkillSubClass(i)
            end
        end
    end
    n = GetNumTradeSkills() or 0
    local index = indexProfession(profName)
    local seen, matched, cached, missingLinks, recipeRows = {}, 0, 0, false, 0
    local collapsed = false
    local canReadReagents = type(GetTradeSkillNumReagents) == "function"
        and type(GetTradeSkillReagentInfo) == "function"
        and type(GetTradeSkillReagentItemLink) == "function"
    for i = 1, n do
        local name, skillType, _, isExpanded = GetTradeSkillInfo(i)
        if skillType == "header" then
            if not isExpanded then collapsed = true end
        elseif type(name) == "string" and name ~= "" then
            recipeRows = recipeRows + 1
            local recipe = index[normalize(name)]
            if recipe then
                seen[recipe.key] = true
                matched = matched + 1
                local tradeLink = type(GetTradeSkillItemLink) == "function" and GetTradeSkillItemLink(i) or nil
                if type(tradeLink) == "string" and tradeLink ~= "" then
                    local kind, rawId = tradeLink:match("|H(%a+):(%d+)")
                    rememberOutput(recipe.key, {
                        link = tradeLink,
                        kind = kind,
                        itemID = kind == "item" and tonumber(rawId) or nil,
                        spellID = (kind == "spell" or kind == "enchant") and tonumber(rawId) or nil,
                    })
                end
                local materials, incomplete, missing = {}, false, false
                local reagentCount = canReadReagents and (GetTradeSkillNumReagents(i) or 0) or 0
                for j = 1, reagentCount do
                    local _, _, count = GetTradeSkillReagentInfo(i, j)
                    local id = itemIdFromLink(GetTradeSkillReagentItemLink(i, j))
                    count = tonumber(count)
                    if id and count and count > 0 then
                        materials[id] = (materials[id] or 0) + count
                    else
                        incomplete = true
                        if not id then missing = true end
                    end
                end
                local list = {}
                for id, qty in pairs(materials) do list[#list + 1] = {itemID = id, quantity = qty} end
                table.sort(list, function(a, b) return a.itemID < b.itemID end)
                if missing or (reagentCount > 0 and #list == 0) then missingLinks = true end
                if #list > 0 then
                    local minMade = 1
                    if type(GetTradeSkillNumMade) == "function" then
                        local made = GetTradeSkillNumMade(i)
                        if type(made) == "number" and made > 0 then minMade = made end
                    end
                    local savedOutput = RRPDB.outputs and RRPDB.outputs[recipe.key]
                    storeSchematic(recipe.key, {
                        materials = list,
                        incomplete = incomplete,
                        outputItemID = savedOutput and savedOutput.itemID or itemIdFromLink(tradeLink),
                        outputLink = type(tradeLink) == "string" and tradeLink or nil,
                        outputCount = minMade,
                    })
                end
                local saved = RRPDB.materials and RRPDB.materials[recipe.key]
                if type(saved) == "table" and type(saved.materials) == "table" and #saved.materials > 0 then
                    cached = cached + 1
                end
            end
        end
    end
    local rankText = nil
    if type(rank) == "number" and type(maxRank) == "number" and maxRank > 0 then
        rankText = rank .. "/" .. maxRank
    end
    -- Headers alone are not a recipe list. Leave learned flags untouched.
    if recipeRows == 0 then
        rememberProfession(profName, rankText)
        if not opts.quiet then
            say(profName .. " is open, but no recipes were listed yet. Scan again in a moment.")
        end
        if RRP.Refresh then RRP.Refresh() end
        return "ok"
    end
    -- A collapsed header or an active filter hides recipes. Absence is not "unlearned".
    local complete = not collapsed and not tradeSkillFiltered()
    local sig = seenSignature(seen, complete)
    local p = RRP.GetProfile()
    if p and p.scanSig and p.scanSig[profName] == sig then
        rememberProfession(profName, rankText)
        if opts.announce and not opts.rescan then
            say("Just scanned your " .. profName .. ".")
        elseif not opts.quiet then
            say(profName .. ": no change.")
        end
        if (opts.announce or opts.announceChange) and RRP.Refresh then RRP.Refresh() end
        return "ok"
    end
    if p then
        p.scanSig = p.scanSig or {}
        p.scanSig[profName] = sig
    end
    RRP.RecordLearnScan(profName, seen, complete, recipeRows)
    rememberProfession(profName, rankText)
    finishScan(profName, matched, cached, missingLinks, opts)
    return "ok"
end

local function scanModern(opts)
    local api = C_TradeSkillUI
    if not api or type(api.GetAllRecipeIDs) ~= "function" then return "empty" end
    local ids = safeCall(api.GetAllRecipeIDs)
    if type(ids) ~= "table" then return "empty" end
    local profName = nil
    if type(GetTradeSkillLine) == "function" then
        local name = GetTradeSkillLine()
        if type(name) == "string" then profName = trim(name:match("^[^%(]+") or name) end
    end
    if profName and profName ~= "" and not RRP.ProfessionsSet[profName] then
        return "skip", profName .. " is not in the Merchant's Favor list."
    end
    if not profName and api.GetBaseProfessionInfo then
        local info = safeCall(api.GetBaseProfessionInfo)
        if type(info) == "table" and RRP.ProfessionsSet[info.professionName or ""] then
            profName = info.professionName
        end
    end
    local byName = {}
    for _, r in ipairs(RRP.GetRecipes()) do
        if not profName or r.profession == profName then
            local n = normalize(r.name)
            byName[n] = byName[n] or {}
            byName[n][#byName[n] + 1] = r
        end
    end
    local seen, matched, cached, missingLinks, sawUnlearned = {}, 0, 0, false, false
    for _, id in ipairs(ids) do
        local info = safeCall(api.GetRecipeInfo, id)
        if type(info) == "table" and type(info.name) == "string" then
            local matches = byName[normalize(info.name)]
            -- Without a profession, only an unambiguous name is safe to claim.
            if matches and (profName or #matches == 1) then
                for _, r in ipairs(matches) do
                    if not profName or r.profession == profName then
                        if info.learned == false then sawUnlearned = true end
                        if info.learned ~= false then seen[r.key] = true end
                        matched = matched + 1
                        local sch = inspectSchematic(id)
                        if sch then
                            if sch.incomplete then missingLinks = true end
                            if storeSchematic(r.key, sch) then cached = cached + 1 end
                        end
                    end
                end
            end
        end
    end
    if profName then
        -- learned == false means this list includes recipes the character has not learned.
        -- A list of only learned recipes must not mark the rest of the catalog unlearned.
        local complete = sawUnlearned and not tradeSkillFiltered()
        local sig = seenSignature(seen, complete)
        local p = RRP.GetProfile()
        if p and p.scanSig and p.scanSig[profName] == sig then
            rememberProfession(profName)
            if opts.announce and not opts.rescan then
                say("Just scanned your " .. profName .. ".")
            elseif not opts.quiet then
                say(profName .. ": no change.")
            end
            if (opts.announce or opts.announceChange) and RRP.Refresh then RRP.Refresh() end
            return "ok"
        end
        if p then
            p.scanSig = p.scanSig or {}
            p.scanSig[profName] = sig
        end
        RRP.RecordLearnScan(profName, seen, complete, matched)
        rememberProfession(profName)
        finishScan(profName, matched, cached, missingLinks, opts)
    elseif matched > 0 then
        local p = RRP.GetProfile()
        if p then
            for key in pairs(seen) do p.known[key] = true end
        end
        if not opts.quiet then
            say(matched .. " recipes matched. Open one profession window so learned flags stay accurate.")
        end
        if RRP.Refresh then RRP.Refresh() end
    else
        return "empty"
    end
    return "ok"
end

local function favorcraftOpen()
    return RRP.Window and RRP.Window.IsShown and RRP.Window:IsShown()
end

local function professionFrameShown()
    if TradeSkillFrame and TradeSkillFrame.IsShown and TradeSkillFrame:IsShown() then return true end
    if ProfessionsFrame and ProfessionsFrame.IsShown and ProfessionsFrame:IsShown() then return true end
    return false
end

local function professionWindowOpen()
    if professionFrameShown() then return true end
    if type(GetNumTradeSkills) == "function" then
        local ok, n = pcall(GetNumTradeSkills)
        if ok and type(n) == "number" and n > 0 then return true end
    end
    if C_TradeSkillUI and type(C_TradeSkillUI.IsTradeSkillReady) == "function" then
        local ok, ready = pcall(C_TradeSkillUI.IsTradeSkillReady)
        if ok and ready then return true end
    end
    return false
end

local scanning = false
local refreshQueued, rescanQueued, autoScanQueued = false, false, false
local refreshWait, rescanWait, autoScanWait, itemWait = 0, 0, 0, 0

function RRP.QueueProfessionScan(announce)
    if not RRP.ready or not professionWindowOpen() then return end
    autoScanQueued = true
    if announce and favorcraftOpen() then RRP.autoScanAnnounce = true end
end
local function runScan(opts)
    local status, info = scanClassic(opts)
    if status == "ok" or status == "skip" then
        if status == "skip" and not opts.quiet and info then say(info) end
        return
    end
    status, info = scanModern(opts)
    if status == "ok" or status == "skip" then
        if status == "skip" and not opts.quiet and info then say(info) end
        return
    end
    if opts.quiet then return end
    local p = RRP.GetProfile()
    local names = {}
    if p then
        for _, name in ipairs(RRP.Professions) do
            if p.professions[name] then names[#names + 1] = name end
        end
    end
    if #names > 0 then
        say("Open your " .. table.concat(names, " or ") .. " window, then scan again.")
    else
        say("Open your profession window, then scan again.")
    end
end

function RRP.ScanProfession(opts)
    opts = type(opts) == "table" and opts or {}
    if scanning then
        RRP.needRescan = true
        return
    end
    scanning = true
    local ok, err = pcall(runScan, opts)
    scanning = false
    if not ok and not opts.quiet then
        say("Scan failed: " .. tostring(err))
    end
    if ok and RRP.needRescan and (RRP.rescanTries or 0) < 3 then
        rescanQueued = true
    end
end

function RRP.FavorShortfall(balance, cost, unknown)
    if unknown or type(balance) ~= "number" or type(cost) ~= "number" then return nil end
    return math.max(0, cost - balance)
end

function RRP.Calculate()
    local p = RRP.GetProfile()
    local result = {favor = 0, unknownFavor = false, items = {}, unknown = {}, selected = 0, missing = 0}
    if not p or not RRPDB then return result end
    local craftsByOutput = {}
    for _, recipe in ipairs(RRP.GetRecipes()) do
        if p.known[recipe.key] then
            local d = RRP.Schematic(recipe.key)
            if type(d) == "table" and d.outputItemID and not d.incomplete
                and type(d.materials) == "table" and #d.materials > 0 then
                craftsByOutput[d.outputItemID] = d
            end
        end
    end
    -- Owned intermediates are used before crafting more of them.
    -- Leaf reagents stay as gross totals so the shopping list can show bags/need once.
    local stash = {}
    local function ownedOf(id)
        if stash[id] == nil then stash[id] = bagCount(id) end
        return stash[id]
    end
    local function addReagent(id, amount, visited)
        if p.expandIntermediate and craftsByOutput[id] and not visited[id] then
            local have = ownedOf(id)
            local take = math.min(have, amount)
            stash[id] = have - take
            local need = amount - take
            if need > 0 then
                local sch = craftsByOutput[id]
                visited[id] = true
                local crafts = math.ceil(need / math.max(1, sch.outputCount or 1))
                for _, m in ipairs(sch.materials) do
                    addReagent(m.itemID, m.quantity * crafts, visited)
                end
                visited[id] = nil
            end
        else
            result.items[id] = (result.items[id] or 0) + amount
        end
    end
    for key, qty in pairs(p.plan) do
        local r = RRP.GetByKey(key)
        local chosen = qty == true or (type(qty) == "number" and qty > 0)
        if r and chosen then
            result.selected = result.selected + 1
            local favor = RRP.PlanFavor(r)
            if favor then result.favor = result.favor + favor
            else result.unknownFavor = true end
            local sch = RRP.Schematic(key)
            if sch and type(sch.materials) == "table" and #sch.materials > 0 then
                for _, m in ipairs(sch.materials) do addReagent(m.itemID, m.quantity, {}) end
                if sch.incomplete then result.unknown[#result.unknown + 1] = r.name .. " (partial)" end
            else
                result.unknown[#result.unknown + 1] = r.name
            end
        end
    end
    for id, amount in pairs(result.items) do
        result.missing = result.missing + math.max(0, amount - bagCount(id))
    end
    table.sort(result.unknown)
    return result
end

local syncingSkills = false
function RRP.SyncProfessions()
    if not RRP.ready or not RRPDB or syncingSkills then return end
    if type(GetNumSkillLines) ~= "function" or type(GetSkillLineInfo) ~= "function" then return end
    syncingSkills = true
    if type(ExpandSkillHeader) == "function" then
        for _ = 1, 4 do
            local changed = false
            local n = GetNumSkillLines() or 0
            for i = n, 1, -1 do
                local skillName, isHeader, isExpanded = GetSkillLineInfo(i)
                if isHeader and not isExpanded and (skillName == "Professions" or skillName == "Secondary Skills") then
                    ExpandSkillHeader(i)
                    changed = true
                end
            end
            if not changed then break end
        end
    end
    local function readSkills()
        local found, ranks = {}, {}
        local n = GetNumSkillLines() or 0
        for i = 1, n do
            local values = {GetSkillLineInfo(i)}
            local skillName, isHeader = values[1], values[2]
            if not isHeader and RRP.ProfessionsSet[skillName or ""] then
                found[skillName] = true
                local shown = RRP.ProfessionRank(skillName)
                if shown then ranks[skillName] = tostring(shown) end
            end
        end
        return found, ranks
    end
    local found, ranks = readSkills()
    if not next(found) and type(ExpandSkillHeader) == "function" then
        local n = GetNumSkillLines() or 0
        for i = n, 1, -1 do
            local _, isHeader, isExpanded = GetSkillLineInfo(i)
            if isHeader and not isExpanded then ExpandSkillHeader(i) end
        end
        found, ranks = readSkills()
    end
    local p = RRP.GetProfile()
    if p and next(found) then
        p.professions = found
        for name, rankText in pairs(ranks) do p.professionRanks[name] = rankText end
        if not p.professionPicked and p.profession == "All" then
            local only, count = nil, 0
            for _, name in ipairs(RRP.Professions) do
                if found[name] then
                    count = count + 1
                    only = name
                end
            end
            if count == 1 then
                p.profession = only
                p.page = 1
            end
        end
    end
    syncingSkills = false
    if RRP.Refresh then RRP.Refresh() end
end

local function slash(msg)
    local cmd = trim(msg):lower()
    local query = cmd:match("^find%s+(.+)$") or cmd:match("^search%s+(.+)$")
    if cmd == "scan" then RRP.ScanProfession()
    elseif cmd == "list" then
        if RRP.ToggleShopping then RRP.ToggleShopping() end
    elseif cmd == "clear" then RRP.ClearPlan()
    elseif query then
        RRP.SetSearch(query)
        if RRP.Toggle and RRP.Window and not RRP.Window:IsShown() then RRP.Toggle() end
    elseif cmd == "resetview" then
        local p = RRP.GetProfile()
        if not p then return end
        p.profession, p.page, p.showAll, p.search = "All", 1, false, nil
        p.professionPicked = true
        RRP.clearArmed = nil
        if RRP.Refresh then RRP.Refresh() end
    else
        if RRP.Toggle then RRP.Toggle() end
    end
end
SLASH_FAVORCRAFT1 = "/fc"
SLASH_FAVORCRAFT2 = "/favorcraft"
SLASH_FAVORCRAFT3 = "/rrp"
SLASH_FAVORCRAFT4 = "/redridge"
SlashCmdList["FAVORCRAFT"] = slash

-- The addon folder is FavorCraft. FavorcraftDB is the saved-table name from
-- the earlier file, and it is the same table as RRPDB. Missing keys are
-- copied across. Nothing already saved is deleted.
function RRP.MigrateSaved()
    local function blank(db)
        if type(db.characters) ~= "table" then db.characters = {} end
        if type(db.materials) ~= "table" then db.materials = {} end
        if type(db.discovered) ~= "table" then db.discovered = {} end
        if type(db.scrollItems) ~= "table" then db.scrollItems = {} end
        if type(db.playerTrainer) ~= "table" then db.playerTrainer = {} end
        if type(db.ui) ~= "table" then db.ui = {} end
        if type(db.outputs) ~= "table" then db.outputs = {} end
        return db
    end
    local function fill(dst, src)
        if type(src) ~= "table" or dst == src then return end
        for _, key in ipairs({"characters", "materials", "discovered", "scrollItems", "playerTrainer", "ui", "outputs"}) do
            if type(src[key]) == "table" then
                if type(dst[key]) ~= "table" then dst[key] = {} end
                for id, value in pairs(src[key]) do
                    if dst[key][id] == nil then dst[key][id] = value end
                end
            end
        end
    end
    if type(RRPDB) ~= "table" then RRPDB = nil end
    if type(FavorcraftDB) ~= "table" then FavorcraftDB = nil end
    if RRPDB and not FavorcraftDB then
        FavorcraftDB = RRPDB
    elseif FavorcraftDB and RRPDB then
        fill(FavorcraftDB, RRPDB)
    elseif not FavorcraftDB then
        FavorcraftDB = {}
    end
    blank(FavorcraftDB)
    RRPDB = FavorcraftDB
    FavorcraftDB.addonId = "FavorCraft"
    if type(FavorcraftDB.characters) == "table" then
        for _, character in pairs(FavorcraftDB.characters) do
            if type(character) == "table" and type(character.plan) == "table" then
                for key, value in pairs(character.plan) do
                    if value == true then
                        -- Already selected.
                    elseif type(value) == "number" and value > 0 then
                        character.plan[key] = true
                    else
                        character.plan[key] = nil
                    end
                end
            end
        end
    end
end

function RRP.QueueRefresh()
    local mainOpen = RRP.Window and RRP.Window:IsShown()
    local shopOpen = RRP.Shopping and RRP.Shopping:IsShown()
    if not mainOpen and not shopOpen then return end
    refreshQueued = true
end

local eventFrame = CreateFrame("Frame")
local function register(event)
    -- This client rejects some retail/classic events. A thrown RegisterEvent
    -- aborts the rest of the file, so an unknown name must not be fatal.
    pcall(eventFrame.RegisterEvent, eventFrame, event)
end
register("ADDON_LOADED")
register("PLAYER_LOGIN")
register("SKILL_LINES_CHANGED")
register("SPELLS_CHANGED")
register("LEARNED_SPELL_IN_TAB")
register("TRADE_SKILL_SHOW")
register("TRADE_SKILL_UPDATE")
register("NEW_RECIPE_LEARNED")
register("GET_ITEM_INFO_RECEIVED")
register("BAG_UPDATE")
register("BAG_UPDATE_DELAYED")
local lastAutoAt = 0
eventFrame:SetScript("OnEvent", function(_, event, arg)
    if event == "ADDON_LOADED" and arg == addonName then
        RRP.MigrateSaved()
    elseif event == "PLAYER_LOGIN" then
        RRP.ready = true
        local p = RRP.GetProfile()
        if p and p.expandIntermediate == nil then p.expandIntermediate = true end
        RRP.SyncProfessions()
        if RRP.SyncKnownSpells then RRP.SyncKnownSpells() end
        if RRP.UI and RRP.UI.RestoreLayout then RRP.UI.RestoreLayout() end
        say("Ready. /fc opens FavorCraft.")
    elseif event == "SKILL_LINES_CHANGED" then
        RRP.SyncProfessions()
        if RRP.SyncKnownSpells then RRP.SyncKnownSpells() end
    elseif event == "SPELLS_CHANGED" or event == "LEARNED_SPELL_IN_TAB" or event == "NEW_RECIPE_LEARNED" then
        if event ~= "SPELLS_CHANGED" then RRP.MarkLearnedSpell(arg) end
        if RRP.SyncKnownSpells then RRP.SyncKnownSpells() end
        if RRP.ready and professionFrameShown() then autoScanQueued = true end
    elseif event == "TRADE_SKILL_SHOW" then
        if RRP.ready then
            autoScanQueued = true
            if favorcraftOpen() then RRP.autoScanAnnounce = true end
        end
    elseif event == "TRADE_SKILL_UPDATE" then
        local now = (GetTime and GetTime()) or 0
        if RRP.ready and (now - lastAutoAt) > 1 then autoScanQueued = true end
    elseif event == "BAG_UPDATE" or event == "BAG_UPDATE_DELAYED" then
        if RRP.InvalidateBagCache then RRP.InvalidateBagCache() end
        if RRP.ready then RRP.QueueRefresh() end
    elseif event == "GET_ITEM_INFO_RECEIVED" then
        local id = tonumber(arg)
        if id and type(GetItemInfo) == "function" then
            local ok, name = pcall(GetItemInfo, id)
            if ok and type(name) == "string" and name ~= "" then
                RRP.itemNames[id] = name
                RRP.pendingItems[id] = nil
            end
        end
        if RRP.needRescan and not scanning then rescanQueued = true end
        RRP.QueueRefresh()
    end
end)
eventFrame:SetScript("OnUpdate", function(_, elapsed)
    if RRP.PollPendingItems and next(RRP.pendingItems) then
        itemWait = itemWait + elapsed
        if itemWait > 0.3 then
            itemWait = 0
            RRP.PollPendingItems()
        end
    end
    if refreshQueued then
        refreshWait = refreshWait + elapsed
        if refreshWait > 0.15 then
            refreshQueued = false
            refreshWait = 0
            if RRP.Refresh then RRP.Refresh() end
        end
    end
    if autoScanQueued then
        autoScanWait = autoScanWait + elapsed
        if autoScanWait > 0.25 then
            autoScanQueued = false
            autoScanWait = 0
            lastAutoAt = (GetTime and GetTime()) or 0
            if scanning then
                autoScanQueued = true
            elseif not professionFrameShown() then
                if RRP.SyncKnownSpells then RRP.SyncKnownSpells() end
            else
                local announce = RRP.autoScanAnnounce and true or false
                RRP.autoScanAnnounce = false
                RRP.ScanProfession({
                    quiet = true,
                    announce = announce,
                    announceChange = favorcraftOpen(),
                })
            end
        end
    end
    if rescanQueued then
        rescanWait = rescanWait + elapsed
        if rescanWait > 0.4 then
            rescanQueued = false
            rescanWait = 0
            RRP.needRescan = false
            if RRP.ready and type(GetNumTradeSkills) == "function" and (GetNumTradeSkills() or 0) > 0 then
                RRP.ScanProfession({quiet = true, rescan = true})
            end
        end
    end
end)
