-- Run from the addon directory:
--   luajit tests/planner_logic.lua
-- Compiles the UI and checks plan math. It does not open the WoW client.
local path = arg and arg[0] or "tests/planner_logic.lua"
local root = path:gsub("[/\\]tests[/\\]planner_logic%.lua$", "")
if root == path then root = "." end

local failures = 0
local function check(name, ok, detail)
    if ok then
        print("ok  " .. name)
    else
        failures = failures + 1
        print("FAIL " .. name .. (detail and (": " .. tostring(detail)) or ""))
    end
end

local uiFiles = {
    "Catalog.lua", "Schematics.lua", "Faction.lua", "Core.lua",
    "AlchemyComparisons.lua", "BlacksmithingComparisons.lua", "CookingComparisons.lua",
    "EnchantingComparisons.lua", "EngineeringComparisons.lua",
    "LeatherworkingComparisons.lua", "LeatherworkingSourceAudit.lua", "TailoringComparisons.lua", "Comparisons.lua",
    "UI/Widgets.lua", "UI/Nav.lua", "UI/Browser.lua", "UI/Details.lua",
    "UI/Plan.lua", "UI/Settings.lua", "UI/Shopping.lua", "UI/Main.lua",
}
for _, file in ipairs(uiFiles) do
    local chunk, err = loadfile(root .. "/" .. file)
    check("compile " .. file, chunk ~= nil, err)
end

local function frame()
    local f = {}
    function f:RegisterEvent() end
    function f:SetScript() end
    function f:Hide() end
    function f:Show() end
    function f:IsShown() return false end
    function f:SetSize() end
    function f:SetPoint() end
    function f:EnableMouse() end
    function f:SetMovable() end
    function f:RegisterForDrag() end
    function f:SetFrameStrata() end
    function f:SetClampedToScreen() end
    function f:SetScale() end
    return f
end

CreateFrame = function() return frame() end
UIParent = {}
UISpecialFrames = {}
SlashCmdList = {}
function GetTime() return 1000 end
function UnitName() return "Tester" end
function GetRealmName() return "Realm" end
function UnitClass() return "Warrior", "WARRIOR" end

local RRP = {}
local function loadChunk(file)
    local chunk, err = loadfile(root .. "/" .. file)
    if not chunk then error(err) end
    chunk("FavorCraft", RRP)
end
loadChunk("Catalog.lua")
loadChunk("Schematics.lua")
loadChunk("Faction.lua")
loadChunk("Core.lua")

RRPDB = {characters = {}, materials = {}, discovered = {}, scrollItems = {}}
local profile = RRP.GetProfile()
check("a new window starts with every spec", profile.roles.Tank and profile.roles.Healer and profile.roles.Melee)
check("a new window shows every class", profile.allClasses == true)
profile.showAll = true
profile.plan["Alchemy|Elixir of Lesser Intellect"] = 3
profile.plan["Alchemy|Mender's Potion"] = 5
local calc = RRP.Calculate()
check("favor is once per recipe", calc.favor == 90, calc.favor)
profile.known["Alchemy|Elixir of Lesser Intellect"] = true
calc = RRP.Calculate()
check("a learned recipe adds no favor", calc.favor == 45, calc.favor)
profile.known["Alchemy|Elixir of Lesser Intellect"] = nil
calc = RRP.Calculate()
check("two recipes selected", calc.selected == 2, calc.selected)
check("craft quantity does not add favor rows", calc.favor ~= 45 * 3 + 45 * 5, calc.favor)

profile.profession = "Alchemy"
profile.hideLearned = true
profile.known["Alchemy|Elixir of Lesser Intellect"] = true
local hidden = false
for _, recipe in ipairs(RRP.VisibleRecipes()) do
    if recipe.key == "Alchemy|Elixir of Lesser Intellect" then hidden = true end
end
check("hide learned removes the recipe", not hidden)

profile.hideLearned = false
profile.sortKey = "skill"
profile.sortDesc = false
profile.search = nil
local list = RRP.VisibleRecipes()
local ordered = true
for i = 2, #list do
    if (list[i].skill or -1) < (list[i - 1].skill or -1) then ordered = false break end
end
check("skill sort is ascending", ordered and #list > 1, #list)

profile.sortKey = "favor"
profile.sortDesc = true
list = RRP.VisibleRecipes()
local favorOrder = true
for i = 2, #list do
    if (list[i].favor or -1) > (list[i - 1].favor or -1) then favorOrder = false break end
end
check("favor sort is descending", favorOrder)

check("plan stays a selection", profile.plan["Alchemy|Elixir of Lesser Intellect"] == true)

profile.showAll = false
profile.allClasses = false
profile.previewClass = nil
profile.roles.Healer = false
profile.roles.Paladin = false
local acolyte = RRP.GetByKey("Blacksmithing|Acolyte's Chain Belt")
local protector = RRP.GetByKey("Blacksmithing|Protector's Chain Belt")
local mace = RRP.GetByKey("Blacksmithing|Thorium Greatmace")
check("warrior hides paladin plate", acolyte and not RRP.IsRelevant(acolyte))
check("warrior can see a shared weapon", mace and RRP.IsRelevant(mace))
profile.roles.Melee = false
profile.roles.Hunter = false
profile.roles.Caster = false
profile.roles.Healer = false
profile.roles.Utility = false
profile.roles.Tank = true
check("paladin tag does not hide the mace", RRP.IsRelevant(mace))
check("mace is outside a tank build", not RRP.BuildMatch(mace))
profile.profession = "Blacksmithing"
local sawTank, sawMace, sawPlate = false, false, false
for _, recipe in ipairs(RRP.VisibleRecipes()) do
    if recipe.key == "Blacksmithing|Guard's Chain Belt" then sawTank = true end
    if recipe.key == mace.key then sawMace = true end
    if recipe.key == acolyte.key then sawPlate = true end
end
check("tank filter shows warrior tank gear", sawTank)
check("tank filter hides a melee weapon", not sawMace)
check("tank filter hides paladin plate from a warrior", not sawPlate)
local utility = RRP.GetByKey("Alchemy|Dragonfire Potion")
local healerPotion = RRP.GetByKey("Alchemy|Mender's Potion")
check("tank filter includes utility recipes", utility and RRP.BuildMatch(utility))
check("tank filter hides a healer recipe", healerPotion and not RRP.BuildMatch(healerPotion))
profile.roles.Tank = false
profile.roles.Healer = true
check("healer filter includes utility recipes", RRP.BuildMatch(utility))
profile.roles.Healer = false
profile.roles.Melee = true
check("dps filter includes utility recipes", RRP.BuildMatch(utility))
RRP.EnableAllSpecs()
check("opening the window turns all specs on", profile.specMode == "all" and profile.roles.Tank and profile.roles.Healer and RRP.BuildOn("DPS"))
check("all specs shows a healer recipe", RRP.BuildMatch(healerPotion))
RRP.ShowAllSpecs()
check("the spec button moves to your spec", profile.specMode == "yours" and profile.roles.Tank and RRP.BuildOn("DPS") and not profile.roles.Healer)
RRP.SetBuild("DPS", false)
check("your spec saves tank", profile.specMode == "yours" and profile.yourSpec.Tank and not profile.yourSpec.DPS and not profile.yourSpec.Healer)
RRP.ShowAllSpecs()
check("the spec button returns to all specs", profile.specMode == "all" and profile.roles.Tank and profile.roles.Healer and RRP.BuildOn("DPS"))
RRP.ShowAllSpecs()
check("your spec restores tank only", profile.roles.Tank and not RRP.BuildOn("DPS") and not profile.roles.Healer)
check("all specs keeps paladin plate off a warrior", not RRP.IsRelevant(acolyte))
RRP.EnableAllSpecs()
RRP.SetBuild("Tank", false)
check("a spec can be turned off after all specs", not profile.roles.Tank and profile.roles.Healer)
profile.allClasses = true
profile.showAll = false
profile.previewClass = nil
profile.roles.Tank = false
profile.roles.Healer = false
profile.roles.Hunter = false
profile.roles.Caster = false
profile.roles.Melee = true
local casterPotion = RRP.GetByKey("Alchemy|Spellblasting Potion")
check("dps for every class includes caster recipes", casterPotion and RRP.IsRelevant(casterPotion) and RRP.BuildMatch(casterPotion))
check("all classes shows paladin plate", RRP.IsRelevant(acolyte))
RRP.ToggleAllClasses()
check("your class stays saved", profile.allClasses == false)
check("your class hides paladin plate", not RRP.IsRelevant(acolyte))
check("your class dps skips caster recipes", not RRP.BuildMatch(casterPotion))
profile.roles.Tank = true
profile.roles.Healer = true
profile.roles.Melee = true
profile.roles.Utility = true
profile.profession = "All"
RRP.SetPreviewClass("PALADIN")
profile.roles.Healer = true
check("paladin preview shows paladin plate", RRP.IsRelevant(acolyte))
check("tank paladin piece follows the preview", protector and RRP.IsRelevant(protector))
RRP.SetPreviewClass("MAGE")
check("mage preview hides a warrior weapon", mace and not RRP.IsRelevant(mace))
check("dps preview follows the class", profile.roles.Caster and not profile.roles.Melee)

local balance = RRP.FavorBalance()
check("missing currency stays unknown", balance == nil, balance)
check("shortfall is the unpaid favor", RRP.FavorShortfall(20, 45, false) == 25)
check("paid plan has no shortfall", RRP.FavorShortfall(45, 45, false) == 0)
check("unknown balance has no shortfall", RRP.FavorShortfall(nil, 45, false) == nil)
check("/fc is registered", SLASH_FAVORCRAFT1 == "/fc" and SLASH_FAVORCRAFT3 == "/rrp")

function UnitFactionGroup() return "Horde" end
check("horde camp", RRP.FactionInfo().organization == "Durotar Supply and Logistics")
RRP.SetPreviewClass("PALADIN")
profile.showAll = false
profile.roles.Tank = true
profile.roles.Healer = false
profile.roles.Melee = false
profile.roles.Hunter = false
profile.roles.Caster = false
profile.roles.Utility = false
profile.profession = "Blacksmithing"
local hordeTank, hordeHealerPlate = false, false
for _, recipe in ipairs(RRP.VisibleRecipes()) do
    if recipe.key == protector.key then hordeTank = true end
    if recipe.key == acolyte.key then hordeHealerPlate = true end
end
check("horde paladin tank filter shows tank plate", hordeTank)
check("horde paladin tank filter hides healer plate", not hordeHealerPlate)
function UnitFactionGroup() return "Alliance" end
check("alliance camp", RRP.FactionInfo().location == "Three Corners, Redridge Mountains")

profile.showAll = false
local chain = RRP.GetByKey("Blacksmithing|Guard's Chain Belt")
local stalkerMail = RRP.GetByKey("Leatherworking|Stalker's Mail Shoulder")
local trapper = RRP.GetByKey("Leatherworking|Trapper's Leather Belt")
local clothBoots = RRP.GetByKey("Tailoring|Flame Boots")
RRP.SetPreviewClass("HUNTER")
check("hunter skips mail under 40", chain and not RRP.IsRelevant(chain))
check("hunter wears mail from 40", stalkerMail and RRP.IsRelevant(stalkerMail))
check("hunter wears leather", trapper and RRP.IsRelevant(trapper))
check("hunter wears cloth", clothBoots and RRP.IsRelevant(clothBoots))
RRP.SetPreviewClass("SHAMAN")
check("shaman skips plate", acolyte and not RRP.IsRelevant(acolyte))
check("shaman skips mail under 40", chain and not RRP.IsRelevant(chain))
check("shaman wears mail from 40", stalkerMail and RRP.IsRelevant(stalkerMail))
RRP.SetPreviewClass("PRIEST")
check("priest skips mail", not RRP.IsRelevant(chain) and not RRP.IsRelevant(stalkerMail))
check("priest skips leather", trapper and not RRP.IsRelevant(trapper))
check("priest wears cloth", clothBoots and RRP.IsRelevant(clothBoots))
RRP.SetPreviewClass("DRUID")
check("druid skips mail", stalkerMail and not RRP.IsRelevant(stalkerMail))
check("druid wears leather", trapper and RRP.IsRelevant(trapper))
RRP.SetPreviewClass("WARRIOR")
check("warrior wears low level mail", chain and RRP.IsRelevant(chain))
profile.showAll = true
check("show all keeps mail visible", chain and RRP.IsRelevant(chain))
profile.showAll = false
profile.professions = {Alchemy = true, Blacksmithing = true}
profile.learnScan = {Alchemy = {complete = true}}
local unscanned = RRP.UnscannedProfessions()
check("an unscanned profession is listed", unscanned[1] == "Blacksmithing", table.concat(unscanned, ","))

local greenR, greenG = RRP.LevelTone(10, 12)
check("usable level is green", greenR < 0.5 and greenG > 0.8)
local orangeR, orangeG = RRP.LevelTone(15, 12)
check("three levels above is orange", orangeR > 0.9 and orangeG > 0.4 and orangeG < 0.7)
local redR, redG = RRP.LevelTone(20, 12)
check("far above level is red", redR > 0.8 and redG < 0.3)
profile.professionRanks = profile.professionRanks or {}
profile.professions = profile.professions or {}
profile.professionRanks.Blacksmithing = "89/150"
profile.professions.Blacksmithing = true
local skillR, skillG = RRP.SkillTone("Blacksmithing", 45)
check("enough skill is green", skillR < 0.5 and skillG > 0.8)
local lowR, lowG = RRP.SkillTone("Blacksmithing", 200)
check("short skill is red", lowR > 0.8 and lowG < 0.3)

local savedOld = {
    characters = {["Realm-Old"] = {plan = {["Alchemy|Mender's Potion"] = 4, ["Alchemy|Frenzy Potion"] = 0}}},
    materials = {["Alchemy|Mender's Potion"] = {outputItemID = 1}},
    scrollItems = {["Alchemy|Mender's Potion"] = 99},
    ui = {main = {scale = 0.8}},
    playerTrainer = {["Alchemy|Mender's Potion"] = true},
}
local savedNew = {characters = {["Realm-New"] = {plan = {["Alchemy|Frenzy Potion"] = 1}}}}
RRPDB = savedOld
FavorcraftDB = savedNew
RRP.MigrateSaved()
check("saved tables stay aliased", RRPDB == FavorcraftDB)
check("old plan survived as a selection", FavorcraftDB.characters["Realm-Old"].plan["Alchemy|Mender's Potion"] == true)
check("newer plan survived as a selection", FavorcraftDB.characters["Realm-New"].plan["Alchemy|Frenzy Potion"] == true)
check("zero quantity is not selected", FavorcraftDB.characters["Realm-Old"].plan["Alchemy|Frenzy Potion"] == nil)
check("scanned materials survived", FavorcraftDB.materials["Alchemy|Mender's Potion"].outputItemID == 1)
check("scroll ids survived", FavorcraftDB.scrollItems["Alchemy|Mender's Potion"] == 99)
check("window settings survived", FavorcraftDB.ui.main.scale == 0.8)
check("trainer marks survived", FavorcraftDB.playerTrainer["Alchemy|Mender's Potion"] == true)

local goggles = RRP.GetByKey("Engineering|Floppy Goggles")
local gogglesDb = RRP.Schematics[goggles.key]
RRPDB.scrollItems[goggles.key] = 111
RRPDB.materials[goggles.key] = {materials = {{itemID = 818, quantity = 8}}, outputItemID = 250510}
RRPDB.outputs[goggles.key] = {itemID = (gogglesDb.outputItemID or 0) + 7, kind = "item"}
local ref = RRP.OutputRef(goggles)
check("database crafted item is used", gogglesDb and ref and ref.itemID == gogglesDb.outputItemID and ref.itemID ~= 111, ref and ref.itemID)
check("a saved scan does not replace that item", ref.itemID ~= (gogglesDb.outputItemID or 0) + 7)
local hyperlink = RRP.OutputHyperlink(ref)
check("output link is the database item", type(hyperlink) == "string" and hyperlink == "item:" .. gogglesDb.outputItemID, hyperlink)

local keyA, keyB = "Alchemy|Elixir of Lesser Intellect", "Alchemy|Mender's Potion"
local schA, schB = RRP.Schematic(keyA), RRP.Schematic(keyB)
RRPDB.materials[keyA] = {materials = {{itemID = 818, quantity = 8}}, outputCount = 1}
RRPDB.materials[keyB] = {materials = {{itemID = 818, quantity = 12}}, outputCount = 1}
profile = RRP.GetProfile()
profile.plan = {}
profile.plan[keyA] = 3
profile.plan[keyB] = true
calc = RRP.Calculate()
local function reagentQty(sch, itemID)
    local total = 0
    for _, material in ipairs(sch.materials) do
        if material.itemID == itemID then total = total + material.quantity end
    end
    return total
end
local firstID = schA.materials[1].itemID
check("one craft uses the database quantity", calc.items[firstID] == reagentQty(schA, firstID) + reagentQty(schB, firstID), calc.items[firstID])
check("a saved reagent list is not used", (calc.items[818] or 0) == reagentQty(schA, 818) + reagentQty(schB, 818))
check("old craft quantity is not reused", calc.items[firstID] ~= reagentQty(schA, firstID) * 3 + reagentQty(schB, firstID))

local cooking = {}
for _, recipe in ipairs(RRP.Catalog) do
    if recipe.profession == "Cooking" then cooking[#cooking + 1] = recipe end
end
profile.known = {}
profile.learnScan = {}
profile.scanSig = {}
check("an unscanned recipe is not learned", RRP.LearnState(cooking[1]) == "unlearned")
check("the scan button stays until a profession is scanned", not RRP.HasScannedProfession())
RRP.RecordLearnScan("Cooking", {[cooking[1].key] = true}, false, 1)
check("a partial scan confirms the recipe it listed", RRP.LearnState(cooking[1]) == "learned")
check("a partial scan leaves the rest not learned", RRP.LearnState(cooking[2]) == "unlearned")
RRP.RecordLearnScan("Cooking", {[cooking[1].key] = true}, true, 1)
check("a complete scan marks a missing recipe unlearned", RRP.LearnState(cooking[2]) == "unlearned")
check("a complete scan keeps the listed recipe learned", RRP.LearnState(cooking[1]) == "learned")
check("a scanned profession retires the scan button", RRP.HasScannedProfession())
local learnedSpell = RRP.Schematics[cooking[2].key].spellID
RRP.MarkLearnedSpell(learnedSpell)
check("learning the recipe spell marks it learned", RRP.LearnState(cooking[2]) == "learned", RRP.LearnState(cooking[2]))
RRP.RecordLearnScan("Cooking", {[cooking[1].key] = true}, true, 1)
check("a stale scan keeps the recipe just learned", RRP.LearnState(cooking[2]) == "learned", RRP.LearnState(cooking[2]))
IsSpellKnown = function(id) return tonumber(id) == tonumber(RRP.Schematics[cooking[3].key].spellID) end
profile.known[cooking[3].key] = nil
RRP.SyncKnownSpells()
check("a known profession spell marks the recipe learned", RRP.LearnState(cooking[3]) == "learned", RRP.LearnState(cooking[3]))
IsSpellKnown = nil

local printed = {}
local realPrint = print
print = function(message) printed[#printed + 1] = tostring(message) end
GetNumTradeSkills = function() return 0 end
GetTradeSkillInfo = function() return "Fishing", "header" end
GetTradeSkillLine = function() return "Fishing", 1, 300 end
RRP.ScanProfession({quiet = true})
print = realPrint
check("opening fishing stays quiet", #printed == 0, printed[1])

printed = {}
print = function(message) printed[#printed + 1] = tostring(message) end
GetNumTradeSkills = function() return 1 end
GetTradeSkillLine = function() return "Mining", 40, 300 end
GetTradeSkillInfo = function() return "Thorium Greatmace", "optimal" end
local maceKey = "Blacksmithing|Thorium Greatmace"
local maceBefore = profile.known[maceKey]
RRP.ScanProfession({quiet = true})
print = realPrint
check("opening mining does not record blacksmithing", profile.known[maceKey] == maceBefore)
print = function(message) printed[#printed + 1] = tostring(message) end

local belt = RRP.GetByKey(maceKey)
local database = RRP.Schematics[belt.key]
GetTradeSkillLine = function() return "Blacksmithing", 200, 300 end
GetTradeSkillInfo = function() return belt.name, "optimal", 1, true end
GetTradeSkillItemLink = function()
    return "|cff0070dd|Hitem:999999::::::::60:::::|h[" .. belt.name .. "]|h|r"
end
GetTradeSkillNumReagents = function() return 1 end
GetTradeSkillReagentInfo = function() return "Copper Bar", "", 99 end
GetTradeSkillReagentItemLink = function() return "|Hitem:2840::::::::60:::::|h[Copper Bar]|h|r" end
printed = {}
RRP.ScanProfession({quiet = true})
RRP.ScanProfession({quiet = true})
print = realPrint
check("automatic profession sync stays quiet", #printed == 0, printed[1])
printed = {}
print = function(message) printed[#printed + 1] = tostring(message) end
RRP.ScanProfession({quiet = true, announce = true})
print = realPrint
check("an open FavorCraft window confirms the scan", printed[1] and printed[1]:find("Blacksmithing", 1, true) and true or false, printed[1])
check("a scan does not replace database reagents", RRP.Schematic(belt.key) == database)
check("a scan does not replace the crafted item", RRP.OutputRef(belt).itemID == database.outputItemID)
check("the open profession records that recipe", RRP.LearnState(belt) == "learned")

GetItemCount = function(id)
    if tonumber(id) == 3356 then return 4 end
    return 0
end
check("bag counts come from the inventory", RRP.BagCount(3356) == 4, RRP.BagCount(3356))
profile.professionRanks.Blacksmithing = "89/150"
GetTradeSkillLine = function() return "Blacksmithing", 75, 150 end
GetNumSkillLines = function() return 1 end
GetSkillLineInfo = function() return "Blacksmithing", false, true, 75, 103, 150 end
check("the shown profession skill is kept", RRP.ProfessionRank("Blacksmithing") == 103, RRP.ProfessionRank("Blacksmithing"))
check("skill 95 is green at 103", select(2, RRP.SkillTone("Blacksmithing", 95)) > 0.8)
check("skill 85 is green at 103", select(2, RRP.SkillTone("Blacksmithing", 85)) > 0.8)
check("skill 110 is red at 103", select(1, RRP.SkillTone("Blacksmithing", 110)) > 0.8)
GetTradeSkillLine = function() return "Blacksmithing", 90, 150 end
GetSkillLineInfo = function() return "Blacksmithing", false, true, 90, 0, 13, 150 end
profile.professionRanks.Blacksmithing = nil
check("a skill bonus counts in the shown rank", RRP.ProfessionRank("Blacksmithing") == 103, RRP.ProfessionRank("Blacksmithing"))

loadChunk("AlchemyComparisons.lua")
loadChunk("BlacksmithingComparisons.lua")
loadChunk("CookingComparisons.lua")
loadChunk("EnchantingComparisons.lua")
loadChunk("EngineeringComparisons.lua")
loadChunk("LeatherworkingComparisons.lua")
loadChunk("LeatherworkingSourceAudit.lua")
loadChunk("TailoringComparisons.lua")
loadChunk("Comparisons.lua")

local function entryNamed(view, name)
    for i = 1, #view.entries do
        if view.entries[i].name == name then return view.entries[i] end
    end
end
local intellect = RRP.ComparisonsFor(RRP.GetByKey("Alchemy|Elixir of Lesser Intellect"))
local wisdom = entryNamed(intellect, "Elixir of Wisdom")
check("all seven comparison modules are indexed", RRP.ComparisonByKey["Cooking|Venomous Smoothie"]
    and RRP.ComparisonByKey["Blacksmithing|Guard's Chain Belt"]
    and RRP.ComparisonByKey["Enchanting|Enchant Necklace - Agility"]
    and RRP.ComparisonByKey["Engineering|Dented Goggles"]
    and RRP.ComparisonByKey["Leatherworking|Brawler's Leather Hood"]
    and RRP.ComparisonByKey["Tailoring|Flame Boots"])
check("wisdom is an alternative from the catalog note", wisdom and wisdom.tier == "alternative", wisdom and wisdom.tier)
check("wisdom is labeled almost identical", wisdom and wisdom.label == "Almost Identical Item")
check("wisdom is listed before the comparable intellect elixir",
    intellect.entries[1].name == "Elixir of Wisdom" and intellect.entries[#intellect.entries].name == "Elixir of Intellect")
check("wisdom acquisition is the profession trainer", wisdom and wisdom.acquisition == "Profession trainer")
check("a researched intellect alternative is visible", entryNamed(intellect, "Elixir of Intellect").tier == "alternative")
check("merchant spell id comes from the schematic", intellect.merchantSpellID == RRP.Schematics["Alchemy|Elixir of Lesser Intellect"].spellID)
-- Alchemy's externally researched crafted items must resolve their native
-- consumable tooltips, not just the original merchant's output.
local expectedAlchemyIds = {
    ["Elixir of Minor Spirit"] = 250344,
    ["Elixir of Spirit"] = 250346,
    ["Minor Mageblood Elixir"] = 250339,
    ["Mageblood Elixir"] = 20007,
    ["Minor Mender's Potion"] = 250944,
    ["Greater Mender's Potion"] = 250947,
    ["Minor Spellblasting Potion"] = 250932,
    ["Greater Spellblasting Potion"] = 250935,
    ["Minor Frenzy Potion"] = 250938,
    ["Greater Frenzy Potion"] = 250941,
    ["Arcane Elixir"] = 9155,
    ["Greater Arcane Elixir"] = 13454,
    ["Elixir of Wisdom"] = 3383,
    ["Elixir of Intellect"] = 250354,
    ["Minor Cleric's Elixir"] = 250330,
    ["Cleric's Elixir"] = 250332,
    ["Elixir of Lesser Spirit"] = 250345,
    ["Lesser Mageblood Elixir"] = 250340,
    ["Lesser Cleric's Elixir"] = 250331,
    ["Elixir of Minor Fortitude"] = 2458,
    ["Elixir of Lesser Fortitude"] = 3825,
    ["Elixir of Greater Fortitude"] = 250335,
    ["Elixir of Defense"] = 8951,
    ["Greater Stoneshield Potion"] = 13455,
    ["Elixir of Greater Agility"] = 9187,
    ["Elixir of Greater Intellect"] = 9179,
    ["Elixir of Ogre Strength"] = 3391,
    ["Elixir of Sages"] = 250338,
    ["Elixir of the Whale"] = 250348,
    ["Elixir of Cunning"] = 250328,
    ["Elixir of Greater Strength"] = 9206,
    ["Frenzy Potion"] = 250940,
    ["Mender's Potion"] = 250946,
    ["Spellblasting Potion"] = 250934,
    ["Troll's Blood Elixir"] = 3826,
}
local alchemyMatches = 0
local mismatch = {}
local seenAlternatives = {}
for _, recipe in ipairs(RRP.Catalog) do
    if recipe.profession == "Alchemy" then
        local view = RRP.ComparisonsFor(recipe)
        for _, alternative in ipairs(view.entries or {}) do
            alchemyMatches = alchemyMatches + 1
            seenAlternatives[alternative.name] = true
            if alternative.itemID ~= expectedAlchemyIds[alternative.name] then
                mismatch[#mismatch + 1] = recipe.name .. ": " .. alternative.name
            end
        end
    end
end
local uniqueAlternatives = 0
for name in pairs(seenAlternatives) do
    uniqueAlternatives = uniqueAlternatives + 1
end
check("all Alchemy comparison links resolve researched output IDs",
    alchemyMatches == 51 and uniqueAlternatives == 35 and #mismatch == 0,
    table.concat(mismatch, ", "))
check("Forever elixir name changes use their current item IDs",
    entryNamed(RRP.ComparisonsFor(RRP.GetByKey("Alchemy|Elixir of the Phalanx")), "Elixir of Defense").itemID == 8951
    and entryNamed(RRP.ComparisonsFor(RRP.GetByKey("Alchemy|Elixir of Wicked Regeneration")), "Troll's Blood Elixir").itemID == 3826
    and entryNamed(RRP.ComparisonsFor(RRP.GetByKey("Alchemy|Elixir of the Whale")), "Elixir of Sages").itemID == 250338)
check("Alchemy item links are independent of recipe-scroll IDs",
    entryNamed(RRP.ComparisonsFor(RRP.GetByKey("Alchemy|Elixir of Lesser Spirit")), "Elixir of Minor Spirit").itemID == 250344)
local lesserSpirit = RRP.ComparisonsFor(RRP.GetByKey("Alchemy|Elixir of Lesser Spirit"))
local minorSpirit = entryNamed(lesserSpirit, "Elixir of Minor Spirit")
check("a comparable alchemy item omits the research note", lesserSpirit.header == nil and minorSpirit.label == "Comparable Item")
check("a comparable alchemy item keeps its output id", minorSpirit.itemID == 250344)

local belt = RRP.ComparisonsFor(RRP.GetByKey("Blacksmithing|Guard's Chain Belt"))
check("same-slot gear is labeled by slot rather than promised equivalent",
    belt.status == "slot" and entryNamed(belt, "Runed Copper Belt").tier == "slot")
local expectedSmithIds = {
    ["Bronze Greatsword"] = 7957,
    ["Bronze Warhammer"] = 7956,
    ["Gemmed Copper Gauntlets"] = 3474,
    ["Golden Scale Bracers"] = 6040,
    ["Green Iron Helm"] = 3836,
    ["Green Iron Leggings"] = 3842,
    ["Heavy Mithril Boots"] = 7933,
    ["Heavy Mithril Breastplate"] = 7930,
    ["Heavy Mithril Gauntlet"] = 7919,
    ["Heavy Mithril Shoulder"] = 7918,
    ["Mithril Claws"] = 250609,
    ["Mithril Plate Pants"] = 7920,
    ["Rough Bronze Boots"] = 6350,
    ["Runed Copper Belt"] = 2857,
    ["Steel Breastplate"] = 7963,
    ["Steel Plate Helm"] = 7922,
}
local smithMatches, smithUnique, smithMismatch = 0, {}, {}
for _, recipe in ipairs(RRP.Catalog) do
    if recipe.profession == "Blacksmithing" then
        local view = RRP.ComparisonsFor(recipe)
        for _, entry in ipairs(view.entries or {}) do
            smithMatches = smithMatches + 1
            smithUnique[entry.name] = entry.itemID
            if entry.itemID ~= expectedSmithIds[entry.name] then
                smithMismatch[#smithMismatch + 1] = (entry.name or "?") .. "=" .. tostring(entry.itemID)
            end
            if type(entry.acquisition) == "string" and entry.acquisition:find("http", 1, true) then
                smithMismatch[#smithMismatch + 1] = entry.name .. " shows a source link"
            end
        end
    end
end
local uniqueCount = 0
for _ in pairs(smithUnique) do uniqueCount = uniqueCount + 1 end
check("blacksmithing alternatives use the researched output ids",
    smithMatches == 61 and uniqueCount == 16 and #smithMismatch == 0,
    smithMatches .. " matches, " .. uniqueCount .. " items, " .. table.concat(smithMismatch, ", "))
check("the merchant belt stays separate from the trainer belt",
    belt.merchantItemID == 250514 and entryNamed(belt, "Runed Copper Belt").itemID == 2857)
check("mithril claws are the crafted weapon, not the plans",
    entryNamed(RRP.ComparisonsFor(RRP.GetByKey("Blacksmithing|Thorium Cestus")), "Mithril Claws").itemID == 250609)
local gauntlets = entryNamed(RRP.ComparisonsFor(RRP.GetByKey("Blacksmithing|Guard's Gloves")), "Gemmed Copper Gauntlets")
check("gemmed copper gauntlets are the crafted gloves, not the plans", gauntlets and gauntlets.itemID == 3474)
check("an unlocated plan is learned from a recipe", gauntlets and gauntlets.acquisition == "Learned from a recipe")
local copper = entryNamed(belt, "Runed Copper Belt")
check("a trainer comparison names the profession trainer",
    copper and copper.acquisition == "Profession trainer" and not copper.acquisition:find("database", 1, true))
check("same equipment slot stays without an unfinished stat note",
    copper and copper.similarities and copper.similarities[1] == "Same equipment slot."
    and (not copper.differences or #copper.differences == 0))
local minorSpirit = entryNamed(RRP.ComparisonsFor(RRP.GetByKey("Alchemy|Elixir of Lesser Spirit")), "Elixir of Minor Spirit")
local spiritText = minorSpirit and table.concat(minorSpirit.similarities or {}, " ") or ""
check("alchemy keeps the spirit comparison", spiritText:find("Spirit bonus", 1, true) and not spiritText:lower():find("compare", 1, true))
local unfinishedNote
for _, recipe in ipairs(RRP.Catalog) do
    if recipe.profession == "Alchemy" or recipe.profession == "Blacksmithing" or recipe.profession == "Cooking" then
        local view = RRP.ComparisonsFor(recipe)
        for _, entry in ipairs(view.entries or {}) do
            local text = (table.concat(entry.similarities or {}, " ") .. " " .. table.concat(entry.differences or {}, " ")):lower()
            if text:find("not yet", 1, true) or text:find("not compared", 1, true)
                or text:find("must be compared", 1, true) or text:find("must be verified", 1, true) then
                unfinishedNote = recipe.name .. ": " .. (entry.name or "")
            end
        end
    end
end
check("comparison text does not list unfinished work", unfinishedNote == nil, unfinishedNote)
local venom = RRP.ComparisonsFor(RRP.GetByKey("Cooking|Venomous Smoothie"))
local peace = entryNamed(venom, "Peace Tea")
local slimy = entryNamed(venom, "Slimy Smoothie")
check("a cooking recipe has several alternatives", #venom.entries >= 2)
check("peace tea's documented alternative and source are visible",
    peace and peace.tier == "alternative" and peace.acquisition:find("World drop", 1, true))
check("another favor smoothie uses its real item id", slimy and slimy.itemID == RRP.Schematics["Cooking|Slimy Smoothie"].outputItemID)
check("peace tea uses the researched drink, not a recipe scroll", peace and peace.itemID == 249865)
local expectedTeaIds = {
    ["Peace Tea"] = 249865,
    ["Royal Tea"] = 249866,
    ["Root Tea"] = 249867,
    ["Triage Tea"] = 249868,
    ["Sunny Tea"] = 249869,
    ["Sage's Tea"] = 249870,
}
local teaSeen, teaMismatch = 0, {}
for _, recipe in ipairs(RRP.Catalog) do
    if recipe.profession == "Cooking" then
        local view = RRP.ComparisonsFor(recipe)
        if view.merchantItemID ~= RRP.Schematics[recipe.key].outputItemID then
            teaMismatch[#teaMismatch + 1] = recipe.name .. " merchant " .. tostring(view.merchantItemID)
        end
        for _, entry in ipairs(view.entries or {}) do
            local expected = expectedTeaIds[entry.name]
            if expected then
                teaSeen = teaSeen + 1
                if entry.itemID ~= expected or entry.itemID == 249880 then
                    teaMismatch[#teaMismatch + 1] = entry.name .. "=" .. tostring(entry.itemID)
                end
            end
            if type(entry.acquisition) == "string" and entry.acquisition:find("http", 1, true) then
                teaMismatch[#teaMismatch + 1] = entry.name .. " shows a source link"
            end
        end
    end
end
check("cooking teas use the researched drink ids", teaSeen == 6 and #teaMismatch == 0,
    teaSeen .. " teas, " .. table.concat(teaMismatch, ", "))
local calcified = RRP.ComparisonsFor(RRP.GetByKey("Cooking|Calcified Smoothie"))
local triage = nil
for i = 1, #calcified.entries do
    if calcified.entries[i].name == "Triage Tea" then triage = calcified.entries[i] end
end
check("all researched tea alternatives are shown", triage and triage.tier == "alternative", triage and triage.tier)
local hood = RRP.ComparisonsFor(RRP.GetByKey("Leatherworking|Brawler's Leather Hood"))
local hoodSource = hood.sources and hood.sources[1]
local hoodSchematic = RRP.Schematics["Leatherworking|Brawler's Leather Hood"]
check("a same-name pattern has a separate additional-source listing",
    hood.status == "reported" and hood.status ~= "duplicate")
check("the hood keeps the schematic spell", hoodSchematic.spellID == 1255109 and hood.merchantSpellID == 1255109)
check("the hood scroll is not the crafted item", hood.merchantScrollID == 252798 and hood.merchantItemID == 252504 and hood.merchantScrollID ~= hood.merchantItemID)
check("the hood second source references its actual recipe scroll",
    hoodSource and hoodSource.kind == "source" and hoodSource.scrollItemID == 252798)
check("the hood names Lady Sarevess", hoodSource.lines[2] and hoodSource.lines[2]:find("Lady Sarevess", 1, true) and hoodSource.lines[2]:find("Blackfathom Deeps", 1, true))
local gloves = RRP.ComparisonsFor(RRP.GetByKey("Leatherworking|Brawler's Leather Gloves"))
local gloveText = table.concat(gloves.sources[1].lines, " ")
check("Gilnid is listed as selling rather than dropping the scroll",
    gloveText:find("Listed sale: Gilnid", 1, true) and not gloveText:find("Listed drop: Gilnid", 1, true))
check("the glove scroll stays 252777", gloves.merchantScrollID == 252777 and gloves.merchantSpellID == 1255130)
local leggings = RRP.ComparisonsFor(RRP.GetByKey("Leatherworking|Totemic Leather Leggings"))
local leggingText = table.concat(leggings.sources[1].lines, " ")
check("Kelris and the world drop stay in conflict", leggingText:find("Twilight Lord Kelris", 1, true) and leggingText:find("world drop", 1, true))
check("a blank research spell does not erase the schematic", leggings.merchantSpellID == 1255084 and leggings.merchantItemID == 252458)
local hoodCount = 0
for i = 1, #RRP.Catalog do
    if RRP.Catalog[i].key == "Leatherworking|Brawler's Leather Hood" then hoodCount = hoodCount + 1 end
end
check("the hood is not duplicated in the catalog", hoodCount == 1)
local seenSpell = {}
local spellClash = false
for key, audit in pairs(RRP.SourceAudits) do
    local sch = RRP.Schematics[key]
    if sch.scrollItemID == sch.outputItemID or sch.spellID == sch.scrollItemID then spellClash = true end
    if seenSpell[sch.spellID] then spellClash = true end
    seenSpell[sch.spellID] = true
    if audit.researchSpellID and audit.researchSpellID ~= sch.spellID then spellClash = true end
    if audit.researchScrollID and audit.researchScrollID ~= sch.scrollItemID then spellClash = true end
    if audit.researchOutputID and audit.researchOutputID ~= sch.outputItemID then spellClash = true end
end
check("researched leatherworking ids match the schematic", not spellClash)
check("wisdom is still an alchemy alternative", wisdom and wisdom.tier == "alternative")
check("flame boots has no comparison recorded", RRP.ComparisonsFor(RRP.GetByKey("Tailoring|Flame Boots")).status == "none")
local goggles = RRP.ComparisonsFor(RRP.GetByKey("Engineering|Dented Goggles"))
check("dented goggles compare with the spyglass", entryNamed(goggles, "Ornate Spyglass").tier == "alternative")
local parachute = entryNamed(RRP.ComparisonsFor(RRP.GetByKey("Engineering|SAF-T Disposable Parachute")), "Parachute Cloak")
check("parachute cloak has no invented item id", parachute and parachute.itemID == nil and parachute.tier == "alternative")
check("enchant absorption is visible as a research comparison",
    RRP.ComparisonsFor(RRP.GetByKey("Enchanting|Enchant Chest - Absorption")).status ~= "none")
check("elixir of sages uses the catalog name", RRP.ComparisonByKey["Alchemy|Elixir of Sages"] ~= nil)
local gown = RRP.ComparisonsFor(RRP.GetByKey("Tailoring|Pristine Gown"))
check("pristine gown keeps its researched alternatives", #gown.entries >= 3 and gown.status ~= "none")
local missing = RRP.ComparisonsFor({key = "Alchemy|Not A Recipe", name = "Not A Recipe", profession = "Alchemy"})
check("a missing comparison does not error", missing.status == "none" and missing.missingRecord)
-- Integration coverage: each of the 309 merchant recipes must have a
-- corresponding research view, even if no candidate is currently recorded.
local coverage = {}
local selected = 0
local missingRecords = {}
for _, recipe in ipairs(RRP.Catalog) do
    local view = RRP.ComparisonsFor(recipe)
    if not view or view.missingRecord then
        missingRecords[#missingRecords + 1] = recipe.key
    else
        local entries = view.entries or {}
        local sources = view.sources or {}
        if #entries > 0 or #sources > 0 then selected = selected + 1 end
    end
    coverage[recipe.profession] = (coverage[recipe.profession] or 0) + 1
end
check("all catalog recipes resolve to research views", #missingRecords == 0, table.concat(missingRecords, ", "))
check("all seven professions are represented in the lookup", coverage.Alchemy == 29
    and coverage.Blacksmithing == 61 and coverage.Cooking == 6
    and coverage.Enchanting == 39 and coverage.Engineering == 26
    and coverage.Leatherworking == 81 and coverage.Tailoring == 67)
check("beta comparison records are shown for the researched recipes", selected >= 150, selected)
check("an unresearched alternative still has no item id", parachute and parachute.itemID == nil)
check("no blanket unverified label on ordinary comparisons",
    belt.entries[1].label == "Same-slot Gear" and hoodSource.label == "Additional Recipe Source")
local before = profile.plan["Alchemy|Elixir of Lesser Intellect"]
RRP.ComparisonsFor(RRP.GetByKey("Alchemy|Elixir of Lesser Intellect"))
check("reading a comparison leaves the plan alone", profile.plan["Alchemy|Elixir of Lesser Intellect"] == before)

local function applyClassSpec(class)
    profile.allClasses = false
    profile.showAll = false
    profile.hideLearned = false
    profile.profession = "Alchemy"
    profile.search = nil
    profile.previewClass = class
    profile.roles.Tank = false
    profile.roles.Healer = false
    profile.roles.Melee = false
    profile.roles.Hunter = false
    profile.roles.Caster = false
    profile.roles.Paladin = false
    profile.roles.Utility = true
    if class == "WARRIOR" then
        profile.roles.Tank = true
    elseif class == "PALADIN" or class == "DRUID" or class == "SHAMAN" then
        profile.roles.Tank = true
        profile.roles.Healer = true
        if class == "PALADIN" then profile.roles.Paladin = true end
    elseif class == "PRIEST" then
        profile.roles.Healer = true
    end
    for _, role in ipairs(RRP.DPSRolesFor(class)) do
        profile.roles[role] = true
    end
end
local function alchemyCount()
    local n = 0
    for _, recipe in ipairs(RRP.VisibleRecipes()) do
        if recipe.profession == "Alchemy" then n = n + 1 end
    end
    return n
end
local function visibleKey(key)
    for _, recipe in ipairs(RRP.VisibleRecipes()) do
        if recipe.key == key then return true end
    end
    return false
end

applyClassSpec("HUNTER")
local hunterRoles = RRP.DPSRolesFor("HUNTER")
check("hunter gear dps stays hunter and melee", hunterRoles[1] == "Hunter" and hunterRoles[2] == "Melee" and #hunterRoles == 2)
check("hunter profile does not store caster", profile.roles.Caster ~= true)
check("hunter dps includes lesser arcane elixir", visibleKey("Alchemy|Lesser Arcane Elixir"))
check("hunter dps includes lesser spirit", visibleKey("Alchemy|Elixir of Lesser Spirit"))
check("hunter dps includes lesser intellect", visibleKey("Alchemy|Elixir of Lesser Intellect"))
check("hunter dps includes lesser mageblood", visibleKey("Alchemy|Lesser Mageblood Elixir"))
check("hunter dps includes greater spirit", visibleKey("Alchemy|Elixir of Greater Spirit"))
check("hunter dps includes greater mageblood", visibleKey("Alchemy|Greater Mageblood Elixir"))
check("hunter dps includes elixir of the owl", visibleKey("Alchemy|Elixir of the Owl"))
check("hunter alchemy count is 22", alchemyCount() == 22, alchemyCount())
check("hunter dps skips caster enchants", not RRP.BuildMatch(RRP.GetByKey("Enchanting|Enchant Necklace - Spell Power")))
check("hunter dps skips caster cooking", not RRP.BuildMatch(RRP.GetByKey("Cooking|Venomous Smoothie")))
check("hunter dps skips caster mail", not RRP.BuildMatch(RRP.GetByKey("Leatherworking|Skycaller's Mail Shoulder")))
profile.roles.Healer = true
RRP.SetBuild("DPS", false)
check("turning dps off hides lesser arcane", not visibleKey("Alchemy|Lesser Arcane Elixir"))
check("a healer filter still shows lesser spirit", visibleKey("Alchemy|Elixir of Lesser Spirit"))

applyClassSpec("PALADIN")
local paladinRoles = RRP.DPSRolesFor("PALADIN")
check("paladin gear dps stays melee", paladinRoles[1] == "Melee" and #paladinRoles == 1)
check("paladin dps includes caster alchemy", visibleKey("Alchemy|Lesser Arcane Elixir") and visibleKey("Alchemy|Elixir of the Owl"))
check("paladin alchemy count is 29", alchemyCount() == 29, alchemyCount())
RRP.SetBuild("DPS", false)
check("paladin without dps hides caster-only alchemy", not visibleKey("Alchemy|Spellblasting Potion") and not visibleKey("Alchemy|Lesser Arcane Elixir"))
check("paladin healer still shows mender's potion", visibleKey("Alchemy|Mender's Potion"))

applyClassSpec("SHAMAN")
check("shaman alchemy count stays 29", alchemyCount() == 29, alchemyCount())
applyClassSpec("DRUID")
check("druid alchemy count stays 29", alchemyCount() == 29, alchemyCount())
applyClassSpec("MAGE")
check("mage alchemy count stays 18", alchemyCount() == 18, alchemyCount())
applyClassSpec("PRIEST")
check("priest alchemy count stays 22", alchemyCount() == 22, alchemyCount())
applyClassSpec("WARLOCK")
check("warlock alchemy count stays 18", alchemyCount() == 18, alchemyCount())
applyClassSpec("WARRIOR")
check("warrior alchemy count stays 10", alchemyCount() == 10, alchemyCount())
check("warrior dps skips lesser arcane", not visibleKey("Alchemy|Lesser Arcane Elixir"))
applyClassSpec("ROGUE")
check("rogue alchemy count stays 7", alchemyCount() == 7, alchemyCount())
check("rogue dps skips lesser arcane", not visibleKey("Alchemy|Lesser Arcane Elixir"))

applyClassSpec("WARRIOR")
profile.showAll = true
check("show all recipes still lists every alchemy recipe", alchemyCount() == 29, alchemyCount())

applyClassSpec("HUNTER")
profile.known["Alchemy|Lesser Arcane Elixir"] = true
RRP.SetPreviewClass("MAGE")
check("switching preview class keeps the learned flag", profile.known["Alchemy|Lesser Arcane Elixir"] == true)
check("lesser arcane stays learned for a mage preview", RRP.LearnState(RRP.GetByKey("Alchemy|Lesser Arcane Elixir")) == "learned")
RRP.SetPreviewClass("HUNTER")
check("lesser arcane stays learned for a hunter preview", RRP.LearnState(RRP.GetByKey("Alchemy|Lesser Arcane Elixir")) == "learned")
profile.hideLearned = true
check("hide learned still removes lesser arcane", not visibleKey("Alchemy|Lesser Arcane Elixir"))
profile.hideLearned = false
local savedPlan = profile.plan["Alchemy|Elixir of Lesser Intellect"]
profile.roles.Caster = false
profile.specMode = "none"
profile.specsDefaulted = true
local migrated = RRP.GetProfile()
check("an older spec mode still loads", migrated.specMode == "all")
check("a saved learned flag survives", migrated.known["Alchemy|Lesser Arcane Elixir"] == true)
check("a saved plan survives", migrated.plan["Alchemy|Elixir of Lesser Intellect"] == savedPlan)
check("a saved profile does not gain a caster role", migrated.roles.Caster ~= true)

profile.allClasses = false
RRP.SetProfession("Blacksmithing")
check("blacksmithing leaves my class selected", profile.allClasses == false)
RRP.SetProfession("Leatherworking")
check("leatherworking leaves my class selected", profile.allClasses == false)
RRP.SetProfession("Tailoring")
check("tailoring leaves my class selected", profile.allClasses == false)
RRP.SetProfession("All")
check("every profession leaves my class selected", profile.allClasses == false)
profile.allClasses = false
RRP.SetProfession("Alchemy")
check("alchemy switches to all classes", profile.allClasses == true)
profile.allClasses = false
RRP.SetProfession("Enchanting")
check("enchanting switches to all classes", profile.allClasses == true)
profile.allClasses = false
RRP.SetProfession("Engineering")
check("engineering switches to all classes", profile.allClasses == true)
profile.allClasses = false
RRP.SetProfession("Cooking")
check("cooking switches to all classes", profile.allClasses == true)
local groups = RRP.ProfessionGroups
check("armor crafts lead the profession list", groups
    and groups[1][1] == "Blacksmithing" and groups[1][2] == "Leatherworking" and groups[1][3] == "Tailoring")
check("enchanting engineering and alchemy are grouped together", groups
    and groups[2][1] == "Enchanting" and groups[2][2] == "Engineering" and groups[2][3] == "Alchemy")
check("cooking is the last profession group", groups and groups[3][1] == "Cooking" and #groups == 3)

if failures > 0 then
    print(failures .. " failed")
    os.exit(1)
end
print("all planner checks passed")
