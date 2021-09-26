Armory = Armory or {}

---------------------------------------------------------------------------------------------------
-- Achievement Criteria : Fetches Achievement criteria                                 ------------
---------------------------------------------------------------------------------------------------
function Armory.getCriteria(achievementId, critCount)
    criteriaList = {}

    for k = 1, critCount do
        criteriaList[k] = {
            GetAchievementCriterion(achievementId, k)
        }
    end

    return criteriaList
end
