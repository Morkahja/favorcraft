# Favorcraft

Merchant's Favor & Profession Planner  
World of Warcraft Forever | Alliance & Horde

Favorcraft plans Merchant's Favor recipe purchases and the materials those crafts need. Alliance characters buy from the Azeroth Commerce Authority at Three Corners in Redridge Mountains. Horde characters buy from Durotar Supply and Logistics outside the Crossroads in the Northern Barrens. Both factions use the same recipe list. Paladins and shamans exist on both factions, so those recipes follow the class filter.

## Commands

- `/fc` opens the window.
- `/favorcraft` opens the window.
- `/rrp` and `/redridge` still open it.
- `/fc scan` reads the profession window that is already open. Opening Blacksmithing, Alchemy, Cooking, Enchanting, Engineering, Leatherworking, or Tailoring does this on its own.

## Saved plans

The addon folder and TOC file are still named `RedridgeRecipePlanner`. That is deliberate. WoW loads saved variables from a file named after the addon, and renaming the folder would leave existing plans behind.

`RRPDB` and `FavorcraftDB` are kept as the same data. Loading copies any missing plans, quantities, class and build choices, known recipes, scanned materials, trainer notes, and window settings across. It does not delete saved data.

Do not rename this folder, and do not rename the remote repository, until that migration has been checked in game. A later rename needs the old addon enabled for one login so the old saved file is still read.

## Recipe list

The shared catalog has 309 recipes. Public counts of 314 offers are those recipes plus five profession certifications sold for 1,000 Merchant's Favor. Certifications are not recipes, so they are not in the list. Extra names that the sources disagree about are not in the catalog.

Favor is the cost of buying a recipe once. Selecting a recipe counts that cost once and lists the materials for one craft.

The recipe list, reagents, and crafted item IDs come with the addon. You do not need to visit a camp vendor or learn the recipe to see them. A green check means this character knows the recipe. A red x means a complete look at that profession window did not list it. A question mark means that window has not been checked yet. Fishing and Mining are left alone.

Spell IDs, crafted item IDs, and reagent quantities are World of Warcraft: Forever client data published by [AHledger](https://ahledger.com), client build 1.60.1, imported 15 October 2026. Auction prices are not stored. Lesser Arcane Elixir uses the camp scroll that requires Alchemy 120 and takes 4 Kingsblood and 1 Leaded Vial. Recipe scrolls were not found for Sentinel's Wristguards, Officer's Wristguards, Prefect's Wristguards, or Warder's Wristguards. Icons and item tooltips are loaded by the game from the item IDs, and this repository cannot confirm them without the client. Run `luajit tests/validate_db.lua` for the current counts. The only verified trainer comparison in the catalog is Elixir of Wisdom against Elixir of Lesser Intellect.

Tank, DPS, Healer, and Other limit the list to recipes for the checked builds and your class. Paladin-only plate stays off other classes. Show All Recipes removes those limits.
