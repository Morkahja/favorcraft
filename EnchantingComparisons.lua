-- Enchanting comparisons for non-Merchant's Favor trainer, world, and vendor formulas.
-- An enchant tooltip uses effect_spell_id. A formula recipe_item_id is not a crafted item.
-- Source pages are stored and are not shown.
local addonName, Favorcraft = ...
Favorcraft = Favorcraft or {}
Favorcraft.EnchantingComparisons = {
  ["Enchant Necklace - Agility"] = {
    ["merchant_recipe_name"] = "Enchant Necklace - Agility",
    ["classification"] = "distinct",
    ["verification"] = "forever_beta_research",
    ["comparison_scope"] = "same_slot_or_effect",
    ["summary"] = "All five necklace enchants in the client reference this Merchant's Favor offering. A cloak enchant is not an alternative for a necklace.",
    ["matches"] = {}
  },
  ["Enchant Necklace - Deflection"] = {
    ["merchant_recipe_name"] = "Enchant Necklace - Deflection",
    ["classification"] = "distinct",
    ["verification"] = "forever_beta_research",
    ["comparison_scope"] = "same_slot_or_effect",
    ["summary"] = "No non-Favor necklace Deflection enchant documented; bracer Deflection is a different slot.",
    ["matches"] = {}
  },
  ["Enchant Necklace - Healing Power"] = {
    ["merchant_recipe_name"] = "Enchant Necklace - Healing Power",
    ["classification"] = "distinct",
    ["verification"] = "forever_beta_research",
    ["comparison_scope"] = "same_slot_or_effect",
    ["summary"] = "No non-Favor necklace healing enchant documented. Weapon/glove healing enchants do not replace a necklace enchant.",
    ["matches"] = {}
  },
  ["Enchant Necklace - Spell Power"] = {
    ["merchant_recipe_name"] = "Enchant Necklace - Spell Power",
    ["classification"] = "distinct",
    ["verification"] = "forever_beta_research",
    ["comparison_scope"] = "same_slot_or_effect",
    ["summary"] = "No non-Favor necklace spell-power enchant documented; weapon enchants occupy a different slot.",
    ["matches"] = {}
  },
  ["Enchant Necklace - Strength"] = {
    ["merchant_recipe_name"] = "Enchant Necklace - Strength",
    ["classification"] = "distinct",
    ["verification"] = "forever_beta_research",
    ["comparison_scope"] = "same_slot_or_effect",
    ["summary"] = "No non-Favor necklace Strength enchant documented; glove Strength enchants are a different slot.",
    ["matches"] = {}
  },
  ["Enchant Weapon - Insight"] = {
    ["merchant_recipe_name"] = "Enchant Weapon - Insight",
    ["classification"] = "distinct",
    ["verification"] = "forever_beta_research",
    ["comparison_scope"] = "same_slot_or_effect",
    ["summary"] = "No confirmed non-Favor weapon enchant with a comparable Spirit-doubling spellcast proc in the same early skill tier.",
    ["matches"] = {}
  },
  ["Enchant Weapon - Recovery"] = {
    ["merchant_recipe_name"] = "Enchant Weapon - Recovery",
    ["classification"] = "distinct",
    ["verification"] = "forever_beta_research",
    ["comparison_scope"] = "same_slot_or_effect",
    ["summary"] = "No confirmed non-Favor same-tier parry/dodge-triggered healing enchant. Endgame Lifestealing has a different trigger and Enchanting requirement.",
    ["matches"] = {}
  },
  ["Enchant Weapon - Revelation"] = {
    ["merchant_recipe_name"] = "Enchant Weapon - Revelation",
    ["classification"] = "distinct",
    ["verification"] = "forever_beta_research",
    ["comparison_scope"] = "same_slot_or_effect",
    ["summary"] = "No confirmed non-Favor same-tier proc that guarantees critical chance for the next spell; general spell-power enchant is not a proc substitute.",
    ["matches"] = {}
  },
  ["Enchant 2H Weapon - Mighty Healing Power"] = {
    ["merchant_recipe_name"] = "Enchant 2H Weapon - Mighty Healing Power",
    ["classification"] = "alternative",
    ["verification"] = "forever_beta_research",
    ["comparison_scope"] = "same_slot_or_effect",
    ["summary"] = "Comparison options: 1 non-Favor trainer/world recipes with related crafting effects.",
    ["matches"] = {
      {
        ["name"] = "Enchant Weapon - Healing Power",
        ["relation"] = "alternative",
        ["acquisition"] = "world_drop",
        ["source_verified"] = true,
        ["similarity"] = "Healing enchant for melee weapons; both use Enchanting 300",
        ["difference"] = "Favor 2H gives +100 healing and +34 damage; the world formula gives +55 healing and +19 damage. Generic weapon enchants can also be used on eligible two-handed weapons.",
        ["effect_spell_id"] = 22750,
        ["recipe_spell_id"] = 22750,
        ["required_skill"] = 300,
        ["source_name"] = "World-drop formula",
        ["source_url"] = "https://www.wowhead.com/forever/spell=22750",
        ["source_note"] = "World-drop formula",
        ["recipe_item_id"] = 18260
      }
    }
  },
  ["Enchant 2H Weapon - Mighty Spell Power"] = {
    ["merchant_recipe_name"] = "Enchant 2H Weapon - Mighty Spell Power",
    ["classification"] = "alternative",
    ["verification"] = "forever_beta_research",
    ["comparison_scope"] = "same_slot_or_effect",
    ["summary"] = "Comparison options: 1 non-Favor trainer/world recipes with related crafting effects.",
    ["matches"] = {
      {
        ["name"] = "Enchant Weapon - Spell Power",
        ["relation"] = "alternative",
        ["acquisition"] = "world_drop",
        ["source_verified"] = true,
        ["similarity"] = "Spell-power enchant for melee weapons; both use Enchanting 300",
        ["difference"] = "Favor 2H gives +55 spell power versus +30 from the world formula. Check eligibility on the target two-handed weapon.",
        ["effect_spell_id"] = 22749,
        ["recipe_spell_id"] = 22749,
        ["required_skill"] = 300,
        ["source_name"] = "World-drop formula",
        ["source_url"] = "https://www.wowhead.com/forever/spell=22749",
        ["source_note"] = "World-drop formula",
        ["recipe_item_id"] = 18259
      }
    }
  },
  ["Enchant 2H Weapon - Spellblasting"] = {
    ["merchant_recipe_name"] = "Enchant 2H Weapon - Spellblasting",
    ["classification"] = "alternative",
    ["verification"] = "forever_beta_research",
    ["comparison_scope"] = "same_slot_or_effect",
    ["summary"] = "Comparison options: 1 non-Favor trainer/world recipes with related crafting effects.",
    ["matches"] = {
      {
        ["name"] = "Enchant Weapon - Spell Power",
        ["relation"] = "alternative",
        ["acquisition"] = "world_drop",
        ["source_verified"] = true,
        ["similarity"] = "Spell power on a melee weapon; both require Enchanting 300",
        ["difference"] = "Favor 2H Spellblasting gives +65 spell power; non-Favor Weapon Spell Power gives +30. Same general effect but weaker world recipe.",
        ["effect_spell_id"] = 22749,
        ["recipe_spell_id"] = 22749,
        ["required_skill"] = 300,
        ["source_name"] = "World-drop formula",
        ["source_url"] = "https://www.wowhead.com/forever/spell=22749",
        ["source_note"] = "World-drop formula",
        ["recipe_item_id"] = 18259
      }
    }
  },
  ["Enchant Chest - Absorption"] = {
    ["merchant_recipe_name"] = "Enchant Chest - Absorption",
    ["classification"] = "alternative",
    ["verification"] = "forever_beta_research",
    ["comparison_scope"] = "same_slot_or_effect",
    ["summary"] = "Comparison options: 1 non-Favor trainer/world recipes with related crafting effects.",
    ["matches"] = {
      {
        ["name"] = "Enchant Chest - Lesser Absorption",
        ["relation"] = "alternative",
        ["acquisition"] = "trainer",
        ["source_verified"] = true,
        ["similarity"] = "Same chest-slot on-hit absorption effect",
        ["difference"] = "Favor: 25% chance to absorb 50 damage per hit; trainer Lesser Absorption: 5% chance to absorb 25. Both have a 5-second cooldown. Skill 220 vs 140.",
        ["effect_spell_id"] = 13538,
        ["recipe_spell_id"] = 13538,
        ["required_skill"] = 140,
        ["source_name"] = "Enchanting trainer",
        ["source_url"] = "https://www.wowhead.com/forever/spell=13538",
        ["source_note"] = "Enchanting trainer"
      }
    }
  },
  ["Enchant Bracer - Greater Spellpower"] = {
    ["merchant_recipe_name"] = "Enchant Bracer - Greater Spellpower",
    ["classification"] = "alternative",
    ["verification"] = "forever_beta_research",
    ["comparison_scope"] = "same_slot_or_effect",
    ["summary"] = "Comparison options: 1 non-Favor trainer/world recipes with related crafting effects.",
    ["matches"] = {
      {
        ["name"] = "Enchant Bracer - Healing Power",
        ["relation"] = "related_not_interchangeable",
        ["acquisition"] = "vendor",
        ["source_verified"] = true,
        ["similarity"] = "Same bracer slot; caster/healer throughput enchants",
        ["difference"] = "Favor +16 general spell power versus non-Favor +24 healing / +8 spell damage; a different balance of offense and healing.",
        ["effect_spell_id"] = 23802,
        ["recipe_spell_id"] = 23802,
        ["required_skill"] = 300,
        ["source_name"] = "Argent Dawn reputation quartermaster, non-Favor formula",
        ["source_url"] = "https://foreverdb.net/item/19447",
        ["source_note"] = "Argent Dawn reputation quartermaster, non-Favor formula",
        ["recipe_item_id"] = 19447
      }
    }
  },
  ["Enchant Bracer - Superior Deflection"] = {
    ["merchant_recipe_name"] = "Enchant Bracer - Superior Deflection",
    ["classification"] = "alternative",
    ["verification"] = "forever_beta_research",
    ["comparison_scope"] = "same_slot_or_effect",
    ["summary"] = "Comparison options: 1 non-Favor trainer/world recipes with related crafting effects.",
    ["matches"] = {
      {
        ["name"] = "Enchant Bracer - Deflection",
        ["relation"] = "alternative",
        ["acquisition"] = "vendor",
        ["source_verified"] = true,
        ["similarity"] = "Same bracer enchant slot and defense skill attribute",
        ["difference"] = "Favor Superior Deflection advertises +9 Defense, but its spell-effect record has a conflicting value. Non-Favor Deflection grants +7. Compare the native tooltips; skill 300 vs 235.",
        ["effect_spell_id"] = 13931,
        ["recipe_spell_id"] = 13931,
        ["required_skill"] = 235,
        ["source_name"] = "Non-Favor formula vendor (limited stock; classic vendor data)",
        ["source_url"] = "https://foreverdb.net/es/spell/13931",
        ["source_note"] = "Non-Favor formula vendor (limited stock; classic vendor data)",
        ["recipe_item_id"] = 11223
      }
    }
  },
  ["Enchant Bracer - Superior Intellect"] = {
    ["merchant_recipe_name"] = "Enchant Bracer - Superior Intellect",
    ["classification"] = "alternative",
    ["verification"] = "forever_beta_research",
    ["comparison_scope"] = "same_slot_or_effect",
    ["summary"] = "Comparison options: 1 non-Favor trainer/world recipes with related crafting effects.",
    ["matches"] = {
      {
        ["name"] = "Enchant Bracer - Greater Intellect",
        ["relation"] = "alternative",
        ["acquisition"] = "trainer",
        ["source_verified"] = true,
        ["similarity"] = "Same bracer slot, direct Intellect increase",
        ["difference"] = "Favor +9 Intellect versus trainer +7; skill 300 versus 255.",
        ["effect_spell_id"] = 20008,
        ["recipe_spell_id"] = 20008,
        ["required_skill"] = 255,
        ["source_name"] = "Profession trainer (classic trainer listing)",
        ["source_url"] = "https://www.wowhead.com/forever/spell=20008",
        ["source_note"] = "Profession trainer (classic trainer listing)"
      }
    }
  },
  ["Enchant Cloak - Agility"] = {
    ["merchant_recipe_name"] = "Enchant Cloak - Agility",
    ["classification"] = "alternative",
    ["verification"] = "forever_beta_research",
    ["comparison_scope"] = "same_slot_or_effect",
    ["summary"] = "Comparison options: 1 non-Favor trainer/world recipes with related crafting effects.",
    ["matches"] = {
      {
        ["name"] = "Enchant Cloak - Lesser Agility",
        ["relation"] = "alternative",
        ["acquisition"] = "world_drop",
        ["source_verified"] = true,
        ["similarity"] = "Same cloak slot, direct Agility increase",
        ["difference"] = "Favor +5 Agility versus world-drop +3; skill 300 versus 225.",
        ["effect_spell_id"] = 13882,
        ["recipe_spell_id"] = 13882,
        ["required_skill"] = 225,
        ["source_name"] = "World-drop formula",
        ["source_url"] = "https://www.wowhead.com/forever/spell=13882",
        ["source_note"] = "World-drop formula",
        ["recipe_item_id"] = 11206
      }
    }
  },
  ["Enchant Gloves - Arcane Power"] = {
    ["merchant_recipe_name"] = "Enchant Gloves - Arcane Power",
    ["classification"] = "alternative",
    ["verification"] = "forever_beta_research",
    ["comparison_scope"] = "same_slot_or_effect",
    ["summary"] = "Comparison options: 3 non-Favor trainer/world recipes with related crafting effects.",
    ["matches"] = {
      {
        ["name"] = "Enchant Gloves - Fire Power",
        ["relation"] = "related_not_interchangeable",
        ["acquisition"] = "world_drop",
        ["source_verified"] = true,
        ["similarity"] = "Same glove enchant slot; +20 school-specific spell damage on both",
        ["difference"] = "Favor enchant grants +20 Arcane damage; non-Favor world formula grants +20 Fire damage. Different spell schools, not interchangeable.",
        ["effect_spell_id"] = 25078,
        ["recipe_spell_id"] = 25078,
        ["required_skill"] = 300,
        ["source_name"] = "World/raid-drop formula",
        ["source_url"] = "https://www.wowhead.com/forever/spell=25078",
        ["source_note"] = "World/raid-drop formula",
        ["recipe_item_id"] = 20729
      },
      {
        ["name"] = "Enchant Gloves - Frost Power",
        ["relation"] = "related_not_interchangeable",
        ["acquisition"] = "world_drop",
        ["source_verified"] = true,
        ["similarity"] = "Same glove enchant slot; +20 school-specific spell damage on both",
        ["difference"] = "Favor enchant grants +20 Arcane damage; non-Favor world formula grants +20 Frost damage. Different spell schools, not interchangeable.",
        ["effect_spell_id"] = 25074,
        ["recipe_spell_id"] = 25074,
        ["required_skill"] = 300,
        ["source_name"] = "World/raid-drop formula",
        ["source_url"] = "https://www.wowhead.com/forever/spell=25074",
        ["source_note"] = "World/raid-drop formula",
        ["recipe_item_id"] = 20728
      },
      {
        ["name"] = "Enchant Gloves - Shadow Power",
        ["relation"] = "related_not_interchangeable",
        ["acquisition"] = "world_drop",
        ["source_verified"] = true,
        ["similarity"] = "Same glove enchant slot; +20 school-specific spell damage on both",
        ["difference"] = "Favor enchant grants +20 Arcane damage; non-Favor world formula grants +20 Shadow damage. Different spell schools, not interchangeable.",
        ["effect_spell_id"] = 25073,
        ["recipe_spell_id"] = 25073,
        ["required_skill"] = 300,
        ["source_name"] = "World/raid-drop formula",
        ["source_url"] = "https://www.wowhead.com/forever/spell=25073",
        ["source_note"] = "World/raid-drop formula",
        ["recipe_item_id"] = 20727
      }
    }
  },
  ["Enchant Gloves - Holy Power"] = {
    ["merchant_recipe_name"] = "Enchant Gloves - Holy Power",
    ["classification"] = "alternative",
    ["verification"] = "forever_beta_research",
    ["comparison_scope"] = "same_slot_or_effect",
    ["summary"] = "Comparison options: 4 non-Favor trainer/world recipes with related crafting effects.",
    ["matches"] = {
      {
        ["name"] = "Enchant Gloves - Fire Power",
        ["relation"] = "related_not_interchangeable",
        ["acquisition"] = "world_drop",
        ["source_verified"] = true,
        ["similarity"] = "Same glove enchant slot; +20 school-specific spell damage on both",
        ["difference"] = "Favor enchant grants +20 Holy damage; non-Favor world formula grants +20 Fire damage. Different spell schools, not interchangeable.",
        ["effect_spell_id"] = 25078,
        ["recipe_spell_id"] = 25078,
        ["required_skill"] = 300,
        ["source_name"] = "World/raid-drop formula",
        ["source_url"] = "https://www.wowhead.com/forever/spell=25078",
        ["source_note"] = "World/raid-drop formula",
        ["recipe_item_id"] = 20729
      },
      {
        ["name"] = "Enchant Gloves - Frost Power",
        ["relation"] = "related_not_interchangeable",
        ["acquisition"] = "world_drop",
        ["source_verified"] = true,
        ["similarity"] = "Same glove enchant slot; +20 school-specific spell damage on both",
        ["difference"] = "Favor enchant grants +20 Holy damage; non-Favor world formula grants +20 Frost damage. Different spell schools, not interchangeable.",
        ["effect_spell_id"] = 25074,
        ["recipe_spell_id"] = 25074,
        ["required_skill"] = 300,
        ["source_name"] = "World/raid-drop formula",
        ["source_url"] = "https://www.wowhead.com/forever/spell=25074",
        ["source_note"] = "World/raid-drop formula",
        ["recipe_item_id"] = 20728
      },
      {
        ["name"] = "Enchant Gloves - Shadow Power",
        ["relation"] = "related_not_interchangeable",
        ["acquisition"] = "world_drop",
        ["source_verified"] = true,
        ["similarity"] = "Same glove enchant slot; +20 school-specific spell damage on both",
        ["difference"] = "Favor enchant grants +20 Holy damage; non-Favor world formula grants +20 Shadow damage. Different spell schools, not interchangeable.",
        ["effect_spell_id"] = 25073,
        ["recipe_spell_id"] = 25073,
        ["required_skill"] = 300,
        ["source_name"] = "World/raid-drop formula",
        ["source_url"] = "https://www.wowhead.com/forever/spell=25073",
        ["source_note"] = "World/raid-drop formula",
        ["recipe_item_id"] = 20727
      },
      {
        ["name"] = "Enchant Gloves - Healing Power",
        ["relation"] = "related_not_interchangeable",
        ["acquisition"] = "world_drop",
        ["source_verified"] = true,
        ["similarity"] = "Both are high-end caster glove enchants",
        ["difference"] = "Favor provides +20 Holy spell damage; world-drop Healing Power provides +35 healing and +12 general spell damage. Damage and healing priorities differ.",
        ["effect_spell_id"] = 25079,
        ["recipe_spell_id"] = 25079,
        ["required_skill"] = 300,
        ["source_name"] = "World/raid-drop formula",
        ["source_url"] = "https://www.wowhead.com/forever/spell=25079",
        ["source_note"] = "World/raid-drop formula",
        ["recipe_item_id"] = 20730
      }
    }
  },
  ["Enchant Gloves - Natural Power"] = {
    ["merchant_recipe_name"] = "Enchant Gloves - Natural Power",
    ["classification"] = "alternative",
    ["verification"] = "forever_beta_research",
    ["comparison_scope"] = "same_slot_or_effect",
    ["summary"] = "Comparison options: 3 non-Favor trainer/world recipes with related crafting effects.",
    ["matches"] = {
      {
        ["name"] = "Enchant Gloves - Fire Power",
        ["relation"] = "related_not_interchangeable",
        ["acquisition"] = "world_drop",
        ["source_verified"] = true,
        ["similarity"] = "Same glove enchant slot; +20 school-specific spell damage on both",
        ["difference"] = "Favor enchant grants +20 Nature damage; non-Favor world formula grants +20 Fire damage. Different spell schools, not interchangeable.",
        ["effect_spell_id"] = 25078,
        ["recipe_spell_id"] = 25078,
        ["required_skill"] = 300,
        ["source_name"] = "World/raid-drop formula",
        ["source_url"] = "https://www.wowhead.com/forever/spell=25078",
        ["source_note"] = "World/raid-drop formula",
        ["recipe_item_id"] = 20729
      },
      {
        ["name"] = "Enchant Gloves - Frost Power",
        ["relation"] = "related_not_interchangeable",
        ["acquisition"] = "world_drop",
        ["source_verified"] = true,
        ["similarity"] = "Same glove enchant slot; +20 school-specific spell damage on both",
        ["difference"] = "Favor enchant grants +20 Nature damage; non-Favor world formula grants +20 Frost damage. Different spell schools, not interchangeable.",
        ["effect_spell_id"] = 25074,
        ["recipe_spell_id"] = 25074,
        ["required_skill"] = 300,
        ["source_name"] = "World/raid-drop formula",
        ["source_url"] = "https://www.wowhead.com/forever/spell=25074",
        ["source_note"] = "World/raid-drop formula",
        ["recipe_item_id"] = 20728
      },
      {
        ["name"] = "Enchant Gloves - Shadow Power",
        ["relation"] = "related_not_interchangeable",
        ["acquisition"] = "world_drop",
        ["source_verified"] = true,
        ["similarity"] = "Same glove enchant slot; +20 school-specific spell damage on both",
        ["difference"] = "Favor enchant grants +20 Nature damage; non-Favor world formula grants +20 Shadow damage. Different spell schools, not interchangeable.",
        ["effect_spell_id"] = 25073,
        ["recipe_spell_id"] = 25073,
        ["required_skill"] = 300,
        ["source_name"] = "World/raid-drop formula",
        ["source_url"] = "https://www.wowhead.com/forever/spell=25073",
        ["source_note"] = "World/raid-drop formula",
        ["recipe_item_id"] = 20727
      }
    }
  },
  ["Enchant Gloves - Superior Strength"] = {
    ["merchant_recipe_name"] = "Enchant Gloves - Superior Strength",
    ["classification"] = "alternative",
    ["verification"] = "forever_beta_research",
    ["comparison_scope"] = "same_slot_or_effect",
    ["summary"] = "Comparison options: 1 non-Favor trainer/world recipes with related crafting effects.",
    ["matches"] = {
      {
        ["name"] = "Enchant Gloves - Greater Strength",
        ["relation"] = "alternative",
        ["acquisition"] = "trainer",
        ["source_verified"] = true,
        ["similarity"] = "Same glove slot and Strength attribute",
        ["difference"] = "Favor +15 Strength versus non-Favor +10 Strength; both high-end Enchanting recipes.",
        ["effect_spell_id"] = 20013,
        ["recipe_spell_id"] = 20013,
        ["required_skill"] = 295,
        ["source_name"] = "Profession trainer or world formula listing (source can vary)",
        ["source_url"] = "https://www.wowhead.com/forever/spell=20013",
        ["source_note"] = "Profession trainer or world formula listing (source can vary)"
      }
    }
  },
  ["Enchant Off-Hand - Wisdom"] = {
    ["merchant_recipe_name"] = "Enchant Off-Hand - Wisdom",
    ["classification"] = "distinct",
    ["verification"] = "forever_beta_research",
    ["comparison_scope"] = "same_slot_or_effect",
    ["summary"] = "Other off-hand enchant spells appear in Forever client indexes, but their non-Favor trainer/drop sources have not been established.",
    ["matches"] = {}
  },
  ["Mystic Mushroom"] = {
    ["merchant_recipe_name"] = "Mystic Mushroom",
    ["classification"] = "distinct",
    ["verification"] = "forever_beta_research",
    ["comparison_scope"] = "same_slot_or_effect",
    ["summary"] = "No acquired non-Favor crafted relic with a sufficiently related effect is documented. Same-slot but unrelated relics are intentionally excluded.",
    ["matches"] = {}
  },
  ["Polished Driftwood Icon"] = {
    ["merchant_recipe_name"] = "Polished Driftwood Icon",
    ["classification"] = "distinct",
    ["verification"] = "forever_beta_research",
    ["comparison_scope"] = "same_slot_or_effect",
    ["summary"] = "No acquired non-Favor crafted relic with a sufficiently related effect is documented. Same-slot but unrelated relics are intentionally excluded.",
    ["matches"] = {}
  },
  ["Tenets of the Silver Hand"] = {
    ["merchant_recipe_name"] = "Tenets of the Silver Hand",
    ["classification"] = "distinct",
    ["verification"] = "forever_beta_research",
    ["comparison_scope"] = "same_slot_or_effect",
    ["summary"] = "No acquired non-Favor crafted relic with a sufficiently related effect is documented. Same-slot but unrelated relics are intentionally excluded.",
    ["matches"] = {}
  },
  ["Libram of Invocation"] = {
    ["merchant_recipe_name"] = "Libram of Invocation",
    ["classification"] = "distinct",
    ["verification"] = "forever_beta_research",
    ["comparison_scope"] = "same_slot_or_effect",
    ["summary"] = "No acquired non-Favor crafted relic with a sufficiently related effect is documented. Same-slot but unrelated relics are intentionally excluded.",
    ["matches"] = {}
  },
  ["Talons of Wrath"] = {
    ["merchant_recipe_name"] = "Talons of Wrath",
    ["classification"] = "distinct",
    ["verification"] = "forever_beta_research",
    ["comparison_scope"] = "same_slot_or_effect",
    ["summary"] = "No acquired non-Favor crafted relic with a sufficiently related effect is documented. Same-slot but unrelated relics are intentionally excluded.",
    ["matches"] = {}
  },
  ["Totem of Ancestral Protection"] = {
    ["merchant_recipe_name"] = "Totem of Ancestral Protection",
    ["classification"] = "distinct",
    ["verification"] = "forever_beta_research",
    ["comparison_scope"] = "same_slot_or_effect",
    ["summary"] = "No acquired non-Favor crafted relic with a sufficiently related effect is documented. Same-slot but unrelated relics are intentionally excluded.",
    ["matches"] = {}
  },
  ["Idol of the Dream"] = {
    ["merchant_recipe_name"] = "Idol of the Dream",
    ["classification"] = "distinct",
    ["verification"] = "forever_beta_research",
    ["comparison_scope"] = "same_slot_or_effect",
    ["summary"] = "No acquired non-Favor crafted relic with a sufficiently related effect is documented. Same-slot but unrelated relics are intentionally excluded.",
    ["matches"] = {}
  },
  ["Libram of Holy Alacrity"] = {
    ["merchant_recipe_name"] = "Libram of Holy Alacrity",
    ["classification"] = "distinct",
    ["verification"] = "forever_beta_research",
    ["comparison_scope"] = "same_slot_or_effect",
    ["summary"] = "No acquired non-Favor crafted relic with a sufficiently related effect is documented. Same-slot but unrelated relics are intentionally excluded.",
    ["matches"] = {}
  },
  ["Totem of Thunder"] = {
    ["merchant_recipe_name"] = "Totem of Thunder",
    ["classification"] = "distinct",
    ["verification"] = "forever_beta_research",
    ["comparison_scope"] = "same_slot_or_effect",
    ["summary"] = "No acquired non-Favor crafted relic with a sufficiently related effect is documented. Same-slot but unrelated relics are intentionally excluded.",
    ["matches"] = {}
  },
  ["Glimmering Staff"] = {
    ["merchant_recipe_name"] = "Glimmering Staff",
    ["classification"] = "distinct",
    ["verification"] = "forever_beta_research",
    ["comparison_scope"] = "same_slot_or_effect",
    ["summary"] = "The same-tier crafted staff/off-hand candidates are also Merchant's Favor recipes. No suitable non-Favor source has been established.",
    ["matches"] = {}
  },
  ["Orb of Mystic Insight"] = {
    ["merchant_recipe_name"] = "Orb of Mystic Insight",
    ["classification"] = "distinct",
    ["verification"] = "forever_beta_research",
    ["comparison_scope"] = "same_slot_or_effect",
    ["summary"] = "The same-tier crafted staff/off-hand candidates are also Merchant's Favor recipes. No suitable non-Favor source has been established.",
    ["matches"] = {}
  },
  ["Orb of Souls"] = {
    ["merchant_recipe_name"] = "Orb of Souls",
    ["classification"] = "distinct",
    ["verification"] = "forever_beta_research",
    ["comparison_scope"] = "same_slot_or_effect",
    ["summary"] = "The same-tier crafted staff/off-hand candidates are also Merchant's Favor recipes. No suitable non-Favor source has been established.",
    ["matches"] = {}
  },
  ["Soulstaff"] = {
    ["merchant_recipe_name"] = "Soulstaff",
    ["classification"] = "distinct",
    ["verification"] = "forever_beta_research",
    ["comparison_scope"] = "same_slot_or_effect",
    ["summary"] = "The same-tier crafted staff/off-hand candidates are also Merchant's Favor recipes. No suitable non-Favor source has been established.",
    ["matches"] = {}
  },
  ["Dreamstaff"] = {
    ["merchant_recipe_name"] = "Dreamstaff",
    ["classification"] = "distinct",
    ["verification"] = "forever_beta_research",
    ["comparison_scope"] = "same_slot_or_effect",
    ["summary"] = "The same-tier crafted staff/off-hand candidates are also Merchant's Favor recipes. No suitable non-Favor source has been established.",
    ["matches"] = {}
  },
  ["Radiant Staff"] = {
    ["merchant_recipe_name"] = "Radiant Staff",
    ["classification"] = "distinct",
    ["verification"] = "forever_beta_research",
    ["comparison_scope"] = "same_slot_or_effect",
    ["summary"] = "The same-tier crafted staff/off-hand candidates are also Merchant's Favor recipes. No suitable non-Favor source has been established.",
    ["matches"] = {}
  },
  ["Truesilver Conduit"] = {
    ["merchant_recipe_name"] = "Truesilver Conduit",
    ["classification"] = "distinct",
    ["verification"] = "forever_beta_research",
    ["comparison_scope"] = "same_slot_or_effect",
    ["summary"] = "The same-tier crafted staff/off-hand candidates are also Merchant's Favor recipes. No suitable non-Favor source has been established.",
    ["matches"] = {}
  },
  ["Twisting Essence Jar"] = {
    ["merchant_recipe_name"] = "Twisting Essence Jar",
    ["classification"] = "distinct",
    ["verification"] = "forever_beta_research",
    ["comparison_scope"] = "same_slot_or_effect",
    ["summary"] = "The same-tier crafted staff/off-hand candidates are also Merchant's Favor recipes. No suitable non-Favor source has been established.",
    ["matches"] = {}
  },
  ["Brilliant Wand"] = {
    ["merchant_recipe_name"] = "Brilliant Wand",
    ["classification"] = "distinct",
    ["verification"] = "forever_beta_research",
    ["comparison_scope"] = "same_slot_or_effect",
    ["summary"] = "Greater Eternal Wand is another level-55 crafted wand (item 249237), but its non-Favor acquisition path has not been established; intentionally withheld.",
    ["matches"] = {}
  }
}
return Favorcraft.EnchantingComparisons
