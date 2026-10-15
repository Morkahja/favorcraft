-- Reported second sources for 11 Leatherworking Merchant's Favor patterns.
-- Identifiers below are the research claims. Comparisons.lua checks them
-- against Schematics.lua and does not replace a client ID.
-- A reported drop is not a confirmed drop, and it is not a different item.
local _, RRP = ...

local TRAINER = "Trainer listings disagree. AHledger mentions trainers, while Forever Era and Endgame Tools describe recipe items that trainers do not teach. No trainer source is shown."

RRP.SourceAudits = {
    ["Leatherworking|Brawler's Leather Hood"] = {
        researchSpellID = 1255109,
        researchScrollID = 252798,
        sources = {
            {type = "dungeon_drop", npc = "Lady Sarevess", location = "Blackfathom Deeps", verification = "reported",
             evidence = "https://endgametools.com/en/wow-forever/items/252798"},
        },
        conflicts = {TRAINER},
    },
    ["Leatherworking|Defender's Leather Hood"] = {
        researchSpellID = 1255107,
        sources = {
            {type = "dungeon_drop", npc = "Edwin VanCleef", location = "The Deadmines", verification = "reported",
             evidence = "https://www.wowhead.com/forever/npc=639/edwin-vancleef"},
        },
        conflicts = {TRAINER},
    },
    ["Leatherworking|Trapper's Leather Hood"] = {
        researchSpellID = 1255108,
        sources = {
            {type = "zone_report", location = "Shadowfang Keep, The Deadmines, and Wailing Caverns", verification = "reported",
             note = "Earlier listing, not confirmed: Fel Steed / Shadow Charger; Edwin VanCleef; a Wailing Caverns mob that was not named."},
        },
        conflicts = {TRAINER},
    },
    ["Leatherworking|Totemic Leather Hood"] = {
        sources = {
            {type = "dungeon_drop", npc = "Edwin VanCleef", location = "The Deadmines", verification = "reported",
             note = "Other dungeons are also reported. Earlier listing, not confirmed: Fel Steed / Shadow Charger (Shadowfang Keep); Ghamoo-ra (Blackfathom Deeps)."},
        },
        conflicts = {TRAINER},
    },
    ["Leatherworking|Wisdom's Leather Hood"] = {
        researchSpellID = 1255104,
        sources = {
            {type = "dungeon_drop", npc = "Edwin VanCleef", location = "The Deadmines", verification = "reported",
             note = "Shadowfang Keep is also reported. Earlier listing, not confirmed: Fel Steed / Shadow Charger."},
        },
        conflicts = {TRAINER},
    },
    ["Leatherworking|Brawler's Leather Gloves"] = {
        researchScrollID = 252777,
        sources = {
            {type = "vendor_sale", npc = "Gilnid", location = "The Deadmines", verification = "reported",
             note = "Listed as sold, not as a mob drop.",
             evidence = "https://realmfirst.net/world-of-warcraft-forever/items/252777/"},
        },
        conflicts = {TRAINER},
    },
    ["Leatherworking|Totemic Leather Gloves"] = {
        researchSpellID = 1255127,
        sources = {
            {type = "dungeon_drop", npc = "Gilnid", location = "The Deadmines", verification = "reported"},
            {type = "dungeon_drop", npc = "Mr. Smite", location = "The Deadmines", verification = "reported"},
            {type = "dungeon_drop", npc = "Bazzalan", location = "Ragefire Chasm", verification = "reported"},
        },
        conflicts = {TRAINER},
    },
    ["Leatherworking|Stormrider's Leather Gloves"] = {
        sources = {
            {type = "zone_report", location = "Shadowfang Keep, The Deadmines, Ragefire Chasm, and Wailing Caverns", verification = "reported",
             note = "Earlier listing, not confirmed: Fel Steed / Shadow Charger; Mr. Smite; Oggleflint; Deviate Faerie Dragon."},
        },
        conflicts = {TRAINER},
    },
    ["Leatherworking|Brawler's Leather Legguards"] = {
        researchSpellID = 1255087,
        sources = {
            {type = "zone_report", location = "Scarlet Monastery, Stormwind Stockade, Razorfen Kraul, Blackfathom Deeps, and Gnomeregan", verification = "reported",
             note = "Earlier listing, not confirmed: Fallen Champion; Ironspine; Dextren Ward; Aggem Thorncurse; Gelihast; Twilight Lord Kelris; Dark Iron Ambassador."},
        },
        conflicts = {TRAINER},
    },
    ["Leatherworking|Totemic Leather Leggings"] = {
        researchScrollID = 252823,
        researchOutputID = 252458,
        sources = {
            {type = "dungeon_drop", npc = "Twilight Lord Kelris", location = "Blackfathom Deeps", verification = "reported",
             evidence = "https://endgametools.com/en/wow-forever/items/252823"},
            {type = "world_drop", verification = "reported",
             note = "RealmFirst describes a general world drop instead of a Kelris drop.",
             evidence = "https://realmfirst.net/world-of-warcraft-forever/items/252823/"},
        },
        conflicts = {
            "Endgame Tools lists a Twilight Lord Kelris drop. RealmFirst lists a world drop. Those claims disagree.",
            TRAINER,
        },
    },
    ["Leatherworking|Stormrider's Leather Kilt"] = {
        researchOutputID = 252518,
        sources = {
            {type = "dungeon_drop", npc = "Bazil Thredd", location = "The Stockade", verification = "reported"},
            {type = "dungeon_drop", npc = "Aku'mai", location = "Blackfathom Deeps", verification = "reported"},
        },
        conflicts = {TRAINER},
    },
}
