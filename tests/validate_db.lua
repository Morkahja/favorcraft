-- Run from the addon directory:
--   luajit tests/validate_db.lua
-- Counts verified fields in the built-in catalog. It does not open the WoW client,
-- so item icons and native tooltips are not claimed as checked.
local path = arg and arg[0] or "tests/validate_db.lua"
local root = path:gsub("[/\\]tests[/\\]validate_db%.lua$", "")
if root == path then root = "." end

local RRP = {}
local function loadChunk(file)
    local chunk, err = loadfile(root .. "/" .. file)
    if not chunk then
        print("failed to load " .. file .. ": " .. tostring(err))
        os.exit(1)
    end
    chunk("RedridgeRecipePlanner", RRP)
end
loadChunk("Catalog.lua")
loadChunk("Schematics.lua")

local professions = {"Alchemy", "Blacksmithing", "Cooking", "Enchanting", "Engineering", "Leatherworking", "Tailoring"}
local stats = {}
for _, name in ipairs(professions) do
    stats[name] = {
        recipes = 0, spell = 0, output = 0, reagents = 0, scroll = 0,
        itemIcon = 0, enchant = 0, incomplete = 0, trainer = 0,
    }
end

local missingKey, incompleteNames = {}, {}
for _, recipe in ipairs(RRP.Catalog) do
    local row = stats[recipe.profession]
    if not row then
        print("catalog profession is not in the report: " .. tostring(recipe.profession))
        os.exit(1)
    end
    row.recipes = row.recipes + 1
    local sch = RRP.Schematics and RRP.Schematics[recipe.key]
    if type(sch) ~= "table" then
        missingKey[#missingKey + 1] = recipe.key
    else
        if tonumber(sch.spellID) then row.spell = row.spell + 1 end
        if sch.kind == "enchant" and tonumber(sch.spellID) then
            row.output = row.output + 1
            row.enchant = row.enchant + 1
        elseif tonumber(sch.outputItemID) then
            row.output = row.output + 1
            row.itemIcon = row.itemIcon + 1
        end
        if type(sch.materials) == "table" and #sch.materials > 0 and not sch.incomplete then
            row.reagents = row.reagents + 1
        end
        if tonumber(sch.scrollItemID) then row.scroll = row.scroll + 1 end
        if sch.incomplete or not sch.spellID or (sch.kind ~= "enchant" and not sch.outputItemID)
            or not (type(sch.materials) == "table" and #sch.materials > 0) then
            row.incomplete = row.incomplete + 1
            incompleteNames[#incompleteNames + 1] = recipe.key
        end
    end
    if type(recipe.alternative) == "string" and recipe.alternative ~= "" then
        row.trainer = row.trainer + 1
    end
end

local provenance = RRP.DataProvenance or {}
print("Favorcraft database check")
print("Source: " .. tostring(provenance.source or "missing"))
print("Client build: " .. tostring(provenance.clientBuild or "missing"))
print("Imported: " .. tostring(provenance.imported or "missing"))
print("URL: " .. tostring(provenance.url or "missing"))
print("")
print(string.format("%-16s %5s %5s %6s %8s %6s %8s %10s",
    "Profession", "Rec", "Spell", "Output", "Reagents", "Scroll", "ItemIcon", "Incomplete"))
local total = {recipes = 0, spell = 0, output = 0, reagents = 0, scroll = 0, itemIcon = 0, incomplete = 0, trainer = 0}
for _, name in ipairs(professions) do
    local row = stats[name]
    print(string.format("%-16s %5d %5d %6d %8d %6d %8d %10d",
        name, row.recipes, row.spell, row.output, row.reagents, row.scroll, row.itemIcon, row.incomplete))
    for key, value in pairs(total) do total[key] = value + (row[key] or 0) end
end
print(string.format("%-16s %5d %5d %6d %8d %6d %8d %10d",
    "Total", total.recipes, total.spell, total.output, total.reagents, total.scroll, total.itemIcon, total.incomplete))
print("")
print("Item icons and native tooltips are not verified here. The client loads them from the item or spell id.")
print("Enchant rows use the spell id as the effect. They have no crafted item icon in this table.")
print("Verified trainer comparisons in the catalog: " .. total.trainer)
print("Catalog recipes with no schematic record: " .. #missingKey)
for _, key in ipairs(missingKey) do print("  missing " .. key) end
if #incompleteNames > 0 then
    print("Incomplete records:")
    for _, key in ipairs(incompleteNames) do print("  " .. key) end
end
print("Coverage is not complete." )

if #missingKey > 0 or total.recipes ~= #RRP.Catalog or #RRP.Catalog ~= 309 then
    os.exit(1)
end
