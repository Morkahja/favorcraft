-- Faction display for the two Merchant's Favor camps.
-- Both factions can be paladins and shamans, so those recipes follow the
-- class filter. This file only describes which camp the character buys from.
local _, RRP = ...
RRP = RRP or {}

RRP.Factions = {
    Alliance = {
        id = "Alliance",
        organization = "Azeroth Commerce Authority",
        location = "Three Corners, Redridge Mountains",
        camp = "Redridge Mountains trade camp",
        accent = {0.45, 0.62, 0.95},
    },
    Horde = {
        id = "Horde",
        organization = "Durotar Supply and Logistics",
        location = "Outside the Crossroads, Northern Barrens",
        camp = "Northern Barrens trade camp",
        accent = {0.90, 0.32, 0.22},
    },
}

function RRP.PlayerFaction()
    if type(UnitFactionGroup) ~= "function" then return nil end
    local faction = UnitFactionGroup("player")
    if faction == "Alliance" or faction == "Horde" then return faction end
    return nil
end

function RRP.FactionInfo(faction)
    if faction == nil then faction = RRP.PlayerFaction() end
    return RRP.Factions[faction]
end
