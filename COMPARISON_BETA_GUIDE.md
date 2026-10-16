# FavorCraft: beta profession comparisons

**Status:** Playable research feature, not a guarantee of current server drop rates.

## Principle

FavorCraft shows the recipe/item information collected in the WoW Forever research
datasets now, so players can compare it and report corrections while the game is
in beta. It does **not** demand that every database listing has been independently
observed during the current play session.

AHledger is credited in the main README and its client-derived schematics remain
the source for the 309 Merchant's Favor recipe IDs, outputs, and reagents.
The comparison modules additionally cite Forever Era, Wowhead Forever,
WoW Professions, Endgame Tools, and other research pages as recorded per entry.

Data/source attribution does not mean an unrelated recipe has the same crafting
spell or is guaranteed to drop from a named mob on today's server build.

## Player-facing categories

- **Same Recipe:** An explicitly identified identical crafting recipe, not merely
  a similar item or name. No confirmed duplicate is currently claimed.
- **Same Effect:** Explicitly documented matching effect and conditions.
- **Comparable Item:** Published comparison of items serving related functions;
  read the stated differences before choosing.
- **Related Item:** Related effects or equipment category, without claiming that
  the items are interchangeable.
- **Same-slot Gear:** Two pieces for the same slot. This *alone* does not imply
  comparable stats.
- **Additional Recipe Source:** A database lists another way to acquire the
  same pattern. The pattern item tooltip, not the crafted-armor tooltip, is shown.
- **No Comparison Recorded:** No matching research record. It does not imply
  that no alternative exists.

These are classifications of the **relationship**, not tiers of publication
certainty. The source, individual effect differences, and conflicts can remain
visible where relevant.

## Profession data bundled in this repo

| Profession | Merchant catalog | Comparison data |
|---|---:|---|
| Alchemy | 29 | Related elixirs, potions, effects and trainer comparisons |
| Blacksmithing | 61 | 61 equipment/weapon comparisons, many matching by slot only |
| Cooking | 6 | Smoothies compared to teas and other smoothies |
| Enchanting | 39 | Enchants, staves, wands and relics; same slot != same effect |
| Engineering | 26 | Bombs, parachutes, gadgets and goggles; 2 additional research-only records |
| Leatherworking | 81 | 11 additional recipe-source listings; remainder retained |
| Tailoring | 67 | Gowns, dropped cloth alternatives, and bag comparisons |
| **Total** | **309** | **All seven research datasets loaded** |

All 309 Merchant recipes have bundled spell IDs and reagent lists in Schematics.lua.
Crafted-item/output IDs and recipe-scroll IDs are separate fields.

The Engineering research files contain Gnomish Army Knife and Loot-A-Rang.
Their presence in research does **not** make them Merchant's Favor purchases.

## How it appears in-game

Hover a recipe. Recipe Comparisons appears beneath the crafting materials in
the right-hand pane. Its source/effect summary and every available researched
alternative are scrollable. Click the recipe only to add or remove it from the
purchase plan.

Sources reported for Leatherworking are shown as additional paths to obtain the
**same recipe pattern**, not new crafted equipment.

When a comparison's external alternative does not yet have an output item/spell
ID in the source records or bundle, FavorCraft displays the written research
and an ID-unavailable tooltip instead of making up an ID. Fully resolved
merchant alternatives can use their native client item tooltip.

## Updates

Edit each profession's comparison Lua module and source-audit data directly.
Keep the client data IDs in Schematics.lua when they agree; never overwrite
them with lookalike item IDs or a recipe scroll ID.

Use the following to validate before packaging:

```bash
luajit tests/validate_db.lua
luajit tests/planner_logic.lua
```

Confirm scroll sizing and native tooltips in the actual WoW Forever client,
because automated tests do not render the game UI.
