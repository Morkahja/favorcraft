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
    chunk("RedridgeRecipePlanner", RRP)
end
loadChunk("Catalog.lua")
loadChunk("Schematics.lua")
loadChunk("Faction.lua")
loadChunk("Core.lua")

RRPDB = {characters = {}, materials = {}, discovered = {}, scrollItems = {}}
local profile = RRP.GetProfile()
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
check("an unscanned recipe is unknown", RRP.LearnState(cooking[1]) == "unknown")
RRP.RecordLearnScan("Cooking", {[cooking[1].key] = true}, false, 1)
check("a partial scan confirms the recipe it listed", RRP.LearnState(cooking[1]) == "learned")
check("a partial scan leaves the rest unknown", RRP.LearnState(cooking[2]) == "unknown")
RRP.RecordLearnScan("Cooking", {[cooking[1].key] = true}, true, 1)
check("a complete scan marks a missing recipe unlearned", RRP.LearnState(cooking[2]) == "unlearned")
check("a complete scan keeps the listed recipe learned", RRP.LearnState(cooking[1]) == "learned")

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
check("an open Favorcraft window confirms the scan", printed[1] and printed[1]:find("Blacksmithing", 1, true) and true or false, printed[1])
check("a scan does not replace database reagents", RRP.Schematic(belt.key) == database)
check("a scan does not replace the crafted item", RRP.OutputRef(belt).itemID == database.outputItemID)
check("the open profession records that recipe", RRP.LearnState(belt) == "learned")

if failures > 0 then
    print(failures .. " failed")
    os.exit(1)
end
print("all planner checks passed")
