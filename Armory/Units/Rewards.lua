Armory = Armory or {}

---------------------------------------------------
-- Bar entry points  --
---------------------------------------------------
function Armory.getRewards(achievementId)
    rewardsList = {}

    -- check collectible rewards
    r1 = {
        GetAchievementRewardCollectible(achievementId)
    }
    if r1[1] == true then
        rewardsList['collectible'] = {
            GetCollectibleInfo(r1[2])
        }
        rewardsList['collectible']['tid'] = r1[2]
    end

    -- check collectible rewards
    r2 = {
        GetAchievementRewardDye(achievementId)
    }
    if r2[1] == true then
        rewardsList['dye'] = {
            GetDyeInfoById(r2[2])
        }
        rewardsList['dye']['tid'] = r2[2]
    end

    -- check collectible rewards
    r3 = {
        GetAchievementRewardItem(achievementId)
    }
    if r3[1] == true then
        rewardsList['item'] = {}
        rewardsList['item']['1'] = r3[2]
    end

    -- check collectible rewards
    r4 = {
        GetAchievementRewardTitle(achievementId)
    }
    if r4[1] == true then
        rewardsList['title'] = {}
        rewardsList['title']['1'] = r4[2]
    end

    return rewardsList
end
