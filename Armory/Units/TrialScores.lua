Armory = Armory or {}

Armory.raidIndex = {
    [1] = "Hel Ra Citadel",
    [2] = "Aetherian Archive",
    [3] = "Sanctum Ophidia",
    [4] = "Dragonstar Arena",
    [5] = "Maw of Lorkhaj",
    [6] = "Maelstrom Arena",
    [7] = "Halls of Fabrication",
    [8] = "Asylum Sanctorium",
    [9] = "Cloudrest",
    [11] = "Blackrose Prison",
    [12] = "Sunspire",
    [13] = "Kyne's Aegis",
    [14] = "Vateshran Hallows",
}

---------------------------------------------------------------------------------------------------
-- Trial Scores : Fetches trial scores by raid indexes                                 ------------
---------------------------------------------------------------------------------------------------
function Armory.getTrialScores()
    data = {}

    -- Loop and get each score result
    for raidIndex, raidName in ipairs(Armory.raidIndex) do
        local currentScore, maxScore = GetRaidLeaderboardLocalPlayerInfo(RAID_CATEGORY_TRIAL, raidIndex)
        local name, raidId = GetRaidLeaderboardInfo(RAID_CATEGORY_TRIAL, raidIndex)
        data[raidId] = maxScore
    end

    return data
end
