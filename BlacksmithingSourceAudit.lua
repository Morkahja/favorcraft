-- Reported second sources for 15 Blacksmithing Merchant's Favor plans.
-- Identifiers below are the research claims. Comparisons.lua checks them
-- against Schematics.lua and does not replace a client ID.
-- A reported drop is not a confirmed drop, and it is not a different item.
local _, RRP = ...

RRP.SourceAudits = RRP.SourceAudits or {}
local audits = {
    ["Blacksmithing|Veteran's Gloves"] = {
        researchSpellID = 1252257,
        researchScrollID = 251360,
        sources = {
            {type = "dungeon_drop", npc = "Sneed", location = "The Deadmines", verification = "reported"},
            {type = "dungeon_drop", npc = "Cookie", location = "The Deadmines", verification = "reported"},
            {type = "dungeon_drop", npc = "Jergosh the Invoker", location = "Ragefire Chasm", verification = "reported"},
        },
    },
    ["Blacksmithing|Guard's Gloves"] = {
        researchSpellID = 1252258,
        researchScrollID = 251361,
        sources = {
            {type = "dungeon_drop", npc = "Taragaman the Hungerer", location = "Ragefire Chasm", verification = "reported"},
        },
    },
    ["Blacksmithing|Protector's Gloves"] = {
        researchSpellID = 1252259,
        researchScrollID = 251362,
        sources = {
            {type = "dungeon_drop", npc = "Rhahk'Zor", location = "The Deadmines", verification = "reported"},
            {type = "dungeon_drop", npc = "Mr. Smite", location = "The Deadmines", verification = "reported"},
            {type = "zone_report", location = "Shadowfang Keep and Ragefire Chasm", verification = "reported"},
        },
    },
    ["Blacksmithing|Acolyte's Gloves"] = {
        researchSpellID = 1252260,
        researchScrollID = 251363,
        sources = {
            {type = "dungeon_drop", npc = "Rhahk'Zor", location = "The Deadmines", verification = "reported"},
            {type = "zone_report", location = "Shadowfang Keep and Ragefire Chasm", verification = "reported"},
        },
    },
    ["Blacksmithing|Crusader's Gloves"] = {
        researchSpellID = 1252261,
        researchScrollID = 251364,
        sources = {
            {type = "dungeon_drop", npc = "Rhahk'Zor", location = "The Deadmines", verification = "reported"},
            {type = "dungeon_drop", npc = "Sneed", location = "The Deadmines", verification = "reported"},
            {type = "zone_report", location = "Shadowfang Keep", verification = "reported"},
        },
    },
    ["Blacksmithing|Veteran's Silvered Chain Helm"] = {
        researchSpellID = 1252277,
        researchScrollID = 251380,
        sources = {
            {type = "dungeon_drop", npc = "Fenrus the Devourer", location = "Shadowfang Keep", verification = "reported"},
            {type = "dungeon_drop", npc = "Targorr the Dread", location = "The Stockade", verification = "reported"},
        },
    },
    ["Blacksmithing|Guard's Silvered Chain Helm"] = {
        researchSpellID = 1252278,
        researchScrollID = 251381,
        sources = {
            {type = "dungeon_drop", npc = "Fel Steed / Shadow Charger", location = "Shadowfang Keep", verification = "reported"},
        },
    },
    ["Blacksmithing|Protector's Silvered Chain Helm"] = {
        researchSpellID = 1252279,
        researchScrollID = 251382,
        sources = {
            {type = "dungeon_drop", npc = "Targorr the Dread", location = "The Stockade", verification = "reported"},
            {type = "dungeon_drop", npc = "Lady Sarevess", location = "Blackfathom Deeps", verification = "reported"},
            {type = "dungeon_drop", npc = "Ghamoo-ra", location = "Blackfathom Deeps", verification = "reported"},
            {type = "zone_report", location = "Shadowfang Keep", verification = "reported"},
        },
    },
    ["Blacksmithing|Acolyte's Silvered Chain Helm"] = {
        researchSpellID = 1252280,
        researchScrollID = 251383,
        sources = {
            {type = "dungeon_drop", npc = "Lady Sarevess", location = "Blackfathom Deeps", verification = "reported"},
        },
    },
    ["Blacksmithing|Crusader's Silvered Chain Helm"] = {
        researchSpellID = 1252281,
        researchScrollID = 251384,
        sources = {
            {type = "dungeon_drop", npc = "Ghamoo-ra", location = "Blackfathom Deeps", verification = "reported"},
            {type = "dungeon_drop", npc = "Lady Sarevess", location = "Blackfathom Deeps", verification = "reported"},
            {type = "dungeon_drop", npc = "Targorr the Dread", location = "The Stockade", verification = "reported"},
        },
    },
    ["Blacksmithing|Veteran's Silvered Chain Leggings"] = {
        researchSpellID = 1252272,
        researchScrollID = 251375,
        sources = {
            {type = "dungeon_drop", npc = "Dextren Ward", location = "The Stockade", verification = "reported"},
            {type = "dungeon_drop", npc = "Gelihast", location = "Blackfathom Deeps", verification = "reported"},
            {type = "dungeon_drop", npc = "Old Serra'kis", location = "Blackfathom Deeps", verification = "reported"},
        },
    },
    ["Blacksmithing|Guard's Silvered Chain Leggings"] = {
        researchSpellID = 1252273,
        researchScrollID = 251376,
        sources = {
            {type = "dungeon_drop", npc = "Dextren Ward", location = "The Stockade", verification = "reported"},
            {type = "dungeon_drop", npc = "Aku'mai", location = "Blackfathom Deeps", verification = "reported"},
        },
    },
    ["Blacksmithing|Protector's Silvered Chain Leggings"] = {
        researchSpellID = 1252274,
        researchScrollID = 251377,
        sources = {
            {type = "dungeon_drop", npc = "Hamhock", location = "The Stockade", verification = "reported"},
            {type = "dungeon_drop", npc = "Lorgus Jett", location = "Blackfathom Deeps", verification = "reported"},
            {type = "dungeon_drop", npc = "Gelihast", location = "Blackfathom Deeps", verification = "reported"},
            {type = "dungeon_drop", npc = "Aku'mai", location = "Blackfathom Deeps", verification = "reported"},
        },
    },
    ["Blacksmithing|Acolyte's Silvered Chain Leggings"] = {
        researchSpellID = 1252275,
        researchScrollID = 251378,
        sources = {
            {type = "dungeon_drop", npc = "Agathelos the Raging", location = "Razorfen Kraul", verification = "reported"},
            {type = "dungeon_drop", npc = "Aku'mai", location = "Blackfathom Deeps", verification = "reported"},
        },
    },
    ["Blacksmithing|Crusader's Silvered Chain Leggings"] = {
        researchSpellID = 1252276,
        researchScrollID = 251379,
        sources = {
            {type = "dungeon_drop", npc = "Kam Deepfury", location = "The Stockade", verification = "reported"},
            {type = "dungeon_drop", npc = "Overlord Ramtusk", location = "Razorfen Kraul", verification = "reported"},
        },
    },
}
for key, audit in pairs(audits) do
    RRP.SourceAudits[key] = audit
end
