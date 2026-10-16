# FavorCraft

Merchant's Favor & Profession Planner  
World of Warcraft Forever | Alliance & Horde

Babunigaming built FavorCraft. Danoozy is the co-author who came up with the idea, and that idea is what led to the hours spent sitting with it, thinking it through, and polishing it.

FavorCraft plans Merchant's Favor recipe purchases and the materials those crafts need. Alliance characters buy from the Azeroth Commerce Authority at Three Corners in Redridge Mountains. Horde characters buy from Durotar Supply and Logistics outside the Crossroads in the Northern Barrens. Both factions use the same recipe list. Paladins and shamans exist on both factions, so those recipes follow the class filter.

## Commands

- `/fc` opens the window.
- `/favorcraft` opens the window.
- `/rrp` and `/redridge` still open it from the earlier name.
- `/fc scan` reads the profession window that is already open. Opening Blacksmithing, Alchemy, Cooking, Enchanting, Engineering, Leatherworking, or Tailoring does this on its own.

## Saved plans

The addon folder and TOC file are named `FavorCraft`. WoW loads saved variables from a file with that same name. `FavorcraftDB` stays as the saved table name so an older file still fills in plans, known recipes, scanned materials, and window settings. `RRPDB` is the same table. Loading copies any missing keys across and does not delete saved data.

## Recipe list

The shared catalog has 309 recipes. Public counts of 314 offers are those recipes plus five profession certifications sold for 1,000 Merchant's Favor. Certifications are not recipes, so they are not in the list. Extra names that the sources disagree about are not in the catalog.

Favor is the cost of buying a recipe once. Selecting a recipe counts that cost once and lists the materials for one craft.

The recipe list, reagents, and crafted item IDs come with the addon. You do not need to visit a camp vendor or learn the recipe to see them. A green check means this character knows the recipe. A red x means this character has not learned it. Fishing and Mining are left alone.

Spell IDs, crafted item IDs, and reagent quantities are World of Warcraft: Forever client data published by [AHledger](https://ahledger.com), client build 1.60.1, imported 15 October 2026. Auction prices are not stored. Lesser Arcane Elixir uses the camp scroll that requires Alchemy 120 and takes 4 Kingsblood and 1 Leaded Vial. Recipe scrolls were not found for Sentinel's Wristguards, Officer's Wristguards, Prefect's Wristguards, or Warder's Wristguards. Icons and item tooltips are loaded by the game from the item IDs, and this repository cannot confirm them without the client. Run `luajit tests/validate_db.lua` for the current counts. The only verified trainer comparison in the catalog is Elixir of Wisdom against Elixir of Lesser Intellect.

Tank, DPS, and Healer limit the list to recipes for the checked specs and the selected class. Utility recipes, such as bags and tools, stay in each of those specs. Opening the window checks all three. The spec button switches between All specs and My spec. Boxes you set on My spec are saved. Closing the window and opening it returns to All specs. All classes shows every class and keeps the spec checks. My class limits the list to this character, and that choice stays saved. Choosing Alchemy, Cooking, Enchanting, or Engineering switches the button back to All classes. Show All Recipes removes the class and spec limits.

## Profession comparisons (beta)

FavorCraft includes comparison research for **all seven professions**, in the
right-hand pane below each recipe's materials. Hover a recipe to view its
comparable items, related equipment, and database-listed alternative sources.
The addon presents the researched data so players can evaluate it during the
WoW Forever beta, without requiring a separate player observation for every
entry. This does not imply identical effects or guaranteed current drop rates.

Blacksmithing same-slot gear is labeled as such rather than treated as an
equivalent upgrade. The 11 Leatherworking additional-source reports refer to
the **same recipe pattern**, not to other crafted items. Item/spell IDs are
never guessed; external alternatives without usable IDs show the documented
comparison instead of a native tooltip.

Research data can be corrected as the beta changes. See
[Comparison Beta Guide](COMPARISON_BETA_GUIDE.md) for the category rules,
profession coverage, and testing notes.

## Credits

- Author: [Babunigaming](https://www.curseforge.com/members/babunigaming)
- Co-author: Danoozy, who came up with the idea and is the reason those hours went into sitting with FavorCraft, thinking it through, and polishing it
- CurseForge: [Babunigaming](https://www.curseforge.com/members/babunigaming)
- Instagram: [babunigaming](https://www.instagram.com/babunigaming/)
- YouTube: [BABUNI GAMING](https://www.youtube.com/@babunigaming)
