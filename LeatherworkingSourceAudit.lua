-- Reported second sources for 17 Leatherworking Merchant's Favor patterns.
-- Identifiers below are the research claims. Comparisons.lua checks them
-- against Schematics.lua and does not replace a client ID.
-- A reported drop is not a confirmed drop, and it is not a different item.
local _, RRP = ...

local TRAINER = "Trainer listings disagree. AHledger mentions trainers, while Forever Era and Endgame Tools describe recipe items that trainers do not teach. No trainer source is shown."

RRP.SourceAudits = RRP.SourceAudits or {}
local audits = {
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
        researchScrollID = 252800,
        sources = {
            {type = "dungeon_drop", npc = "Edwin VanCleef", location = "The Deadmines", verification = "reported",
             evidence = "https://www.wowhead.com/forever/npc=639/edwin-vancleef"},
        },
        conflicts = {TRAINER},
    },
    ["Leatherworking|Trapper's Leather Hood"] = {
        researchSpellID = 1255108,
        researchScrollID = 252799,
        sources = {
            {type = "dungeon_drop", npc = "Edwin VanCleef", location = "The Deadmines", verification = "reported"},
            {type = "zone_report", location = "Shadowfang Keep and Wailing Caverns", verification = "reported"},
        },
        conflicts = {TRAINER},
    },
    ["Leatherworking|Totemic Leather Hood"] = {
        researchSpellID = 1255106,
        researchScrollID = 252801,
        sources = {
            {type = "dungeon_drop", npc = "Edwin VanCleef", location = "The Deadmines", verification = "reported"},
            {type = "dungeon_drop", npc = "Ghamoo-ra", location = "Blackfathom Deeps", verification = "reported"},
            {type = "zone_report", location = "Shadowfang Keep", verification = "reported"},
        },
        conflicts = {TRAINER},
    },
    ["Leatherworking|Wisdom's Leather Hood"] = {
        researchSpellID = 1255104,
        researchScrollID = 252803,
        sources = {
            {type = "dungeon_drop", npc = "Edwin VanCleef", location = "The Deadmines", verification = "reported"},
            {type = "zone_report", location = "Shadowfang Keep", verification = "reported"},
        },
        conflicts = {TRAINER},
    },
    ["Leatherworking|Brawler's Leather Gloves"] = {
        researchSpellID = 1255130,
        researchScrollID = 252777,
        sources = {
            {type = "dungeon_drop", npc = "Gilnid", location = "The Deadmines", verification = "reported",
             evidence = "https://realmfirst.net/world-of-warcraft-forever/items/252777/"},
        },
        conflicts = {TRAINER},
    },
    ["Leatherworking|Defender's Leather Gloves"] = {
        researchSpellID = 1255128,
        researchScrollID = 252779,
        sources = {
            {type = "dungeon_drop", npc = "Mr. Smite", location = "The Deadmines", verification = "reported"},
            {type = "dungeon_drop", npc = "Cookie", location = "The Deadmines", verification = "reported"},
        },
        conflicts = {TRAINER},
    },
    ["Leatherworking|Trapper's Leather Gloves"] = {
        researchSpellID = 1255129,
        researchScrollID = 252778,
        sources = {
            {type = "dungeon_drop", npc = "Gilnid", location = "The Deadmines", verification = "reported"},
            {type = "dungeon_drop", npc = "Cookie", location = "The Deadmines", verification = "reported"},
            {type = "dungeon_drop", npc = "Lord Cobrahn", location = "Wailing Caverns", verification = "reported"},
        },
        conflicts = {TRAINER},
    },
    ["Leatherworking|Totemic Leather Gloves"] = {
        researchSpellID = 1255127,
        researchScrollID = 252780,
        sources = {
            {type = "dungeon_drop", npc = "Gilnid", location = "The Deadmines", verification = "reported"},
            {type = "dungeon_drop", npc = "Mr. Smite", location = "The Deadmines", verification = "reported"},
            {type = "dungeon_drop", npc = "Bazzalan", location = "Ragefire Chasm", verification = "reported"},
        },
        conflicts = {TRAINER},
    },
    ["Leatherworking|Stormrider's Leather Gloves"] = {
        researchSpellID = 1255126,
        researchScrollID = 252781,
        sources = {
            {type = "dungeon_drop", npc = "Mr. Smite", location = "The Deadmines", verification = "reported"},
            {type = "dungeon_drop", npc = "Oggleflint", location = "Ragefire Chasm", verification = "reported"},
            {type = "dungeon_drop", npc = "Deviate Faerie Dragon", location = "Wailing Caverns", verification = "reported"},
            {type = "zone_report", location = "Shadowfang Keep", verification = "reported"},
        },
        conflicts = {TRAINER},
    },
    ["Leatherworking|Wisdom's Leather Gloves"] = {
        researchSpellID = 1255125,
        researchScrollID = 252782,
        sources = {
            {type = "dungeon_drop", npc = "Gilnid", location = "The Deadmines", verification = "reported"},
            {type = "dungeon_drop", npc = "Mr. Smite", location = "The Deadmines", verification = "reported"},
            {type = "zone_report", location = "Shadowfang Keep and Ragefire Chasm", verification = "reported"},
        },
        conflicts = {TRAINER},
    },
    ["Leatherworking|Brawler's Leather Legguards"] = {
        researchSpellID = 1255087,
        researchScrollID = 252820,
        sources = {
            {type = "zone_report", location = "Scarlet Monastery, The Stockade, Razorfen Kraul, Blackfathom Deeps, and Gnomeregan", verification = "reported"},
        },
        conflicts = {TRAINER},
    },
    ["Leatherworking|Defender's Leather Kilt"] = {
        researchSpellID = 1255085,
        researchScrollID = 252822,
        sources = {
            {type = "zone_report", location = "Scarlet Monastery, The Stockade, Razorfen Kraul, Blackfathom Deeps, and Gnomeregan", verification = "reported"},
        },
        conflicts = {TRAINER},
    },
    ["Leatherworking|Trapper's Leather Legguards"] = {
        researchSpellID = 1255086,
        researchScrollID = 252821,
        sources = {
            {type = "zone_report", location = "The Stockade, Razorfen Kraul, and Blackfathom Deeps", verification = "reported"},
        },
        conflicts = {TRAINER},
    },
    ["Leatherworking|Totemic Leather Leggings"] = {
        researchSpellID = 1255084,
        researchScrollID = 252823,
        researchOutputID = 252458,
        sources = {
            {type = "dungeon_drop", npc = "Twilight Lord Kelris", location = "Blackfathom Deeps", verification = "reported",
             evidence = "https://endgametools.com/en/wow-forever/items/252823"},
            {type = "world_drop", verification = "reported",
             evidence = "https://realmfirst.net/world-of-warcraft-forever/items/252823/"},
        },
        conflicts = {
            "Endgame Tools lists a Twilight Lord Kelris drop. RealmFirst lists a world drop. Those claims disagree.",
            TRAINER,
        },
    },
    ["Leatherworking|Stormrider's Leather Kilt"] = {
        researchSpellID = 1255083,
        researchScrollID = 252824,
        researchOutputID = 252518,
        sources = {
            {type = "dungeon_drop", npc = "Bazil Thredd", location = "The Stockade", verification = "reported"},
            {type = "dungeon_drop", npc = "Aku'mai", location = "Blackfathom Deeps", verification = "reported"},
        },
        conflicts = {TRAINER},
    },
    ["Leatherworking|Wisdom's Leather Leggings"] = {
        researchSpellID = 1255082,
        researchScrollID = 252825,
        sources = {
            {type = "dungeon_drop", npc = "Kam Deepfury", location = "The Stockade", verification = "reported"},
            {type = "dungeon_drop", npc = "Gelihast", location = "Blackfathom Deeps", verification = "reported"},
            {type = "dungeon_drop", npc = "Old Serra'kis", location = "Blackfathom Deeps", verification = "reported"},
            {type = "dungeon_drop", npc = "Twilight Lord Kelris", location = "Blackfathom Deeps", verification = "reported"},
        },
        conflicts = {TRAINER},
    },
}
for key, audit in pairs(audits) do
    RRP.SourceAudits[key] = audit
end
