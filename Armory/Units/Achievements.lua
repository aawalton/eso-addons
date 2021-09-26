Armory = Armory or {}

---------------------------------------------------
-- Bar entry points  --
---------------------------------------------------
function Armory.getAchievements(fetchAllData)
    categories = {}
    categoryCount = GetNumAchievementCategories()
    doneAchievements = {}

    for i = 1, categoryCount do
        achievementInfo = GetAchievementCategoryInfo(i)

        -- Check if all date requested
        categories[i] = {
            GetAchievementCategoryInfo(i)
        }

        -- Get Sub category count
        subCategoryCount = categories[i][2]
        subCategories = {}
        for k = 0, subCategoryCount do
            subCategories[k] = {
                GetAchievementSubCategoryInfo(i, k)
            }

            -- Get achievements from sub category
            achievementCount = subCategories[k][2]
            achievements = {}
            achievementCriteria = {}
            achievementsRewards = {}
            relatedAchievements = {}
            for j = 0, achievementCount do
                -- achievement Id
                achievementId = GetAchievementId(i, k, j)

                -- achievement achievement info
                achievements[achievementId] = {
                    GetAchievementInfo(achievementId)
                }

                -- Save only completed ID and date
                local name, description, points, icon, completed, date, time = GetAchievementInfo(achievementId)
                if completed then
                    doneAchievements[achievementId] = date .. " " .. time
                end

                -- achievement criteria count
                critCount = GetAchievementNumCriteria(achievementId)
                if critCount > 0 then
                    achievementCriteria[achievementId] = Armory.getCriteria(achievementId, critCount)
                end

                -- add achievement rewards
                rewards = GetAchievementNumRewards(achievementId)
                if rewards > 1 then -- I am assuming 1 rewards is always the points
                    achievementsRewards[achievementId] = Armory.getRewards(achievementId)
                end

                -- check if related achievements
                firstInLine = GetFirstAchievementInLine(achievementId)
                relatedAchievements[firstInLine] = {}
                line = firstInLine
                order = 0
                while line > 0 do
                    order = order + 1
                    -- save as related achievement
                    relatedAchievements[firstInLine][line] = {
                        GetAchievementInfo(line)
                    }

                    -- Save only completed ID and date
                    local name, description, points, icon, completed, date, time = GetAchievementInfo(line)
                    if completed then
                        doneAchievements[line] = date .. " " .. time
                    end

                    relatedAchievements[firstInLine][line]['priority'] = order

                    -- get next in line
                    line = GetNextAchievementInLine(line)
                end
            end
            for j = 0, achievementCount do
                -- achievement Id
                achievementId = GetAchievementId(i, nil, j)

                -- achievement achievement info
                achievements[achievementId] = {
                    GetAchievementInfo(achievementId)
                }

                -- Save only completed ID and date
                local name, description, points, icon, completed, date, time = GetAchievementInfo(achievementId)
                if completed then
                    doneAchievements[achievementId] = date .. " " .. time
                end

                -- achievement criteria count
                critCount = GetAchievementNumCriteria(achievementId)
                if critCount > 0 then
                    achievementCriteria[achievementId] = Armory.getCriteria(achievementId, critCount)
                end

                -- add achievement rewards
                rewards = GetAchievementNumRewards(achievementId)
                if rewards > 1 then -- I am assuming 1 rewards is always the points
                    achievementsRewards[achievementId] = Armory.getRewards(achievementId)
                end

                -- check if related achievements
                firstInLine = GetFirstAchievementInLine(achievementId)
                relatedAchievements[firstInLine] = {}
                line = firstInLine
                order = 0
                while line > 0 do
                    order = order + 1
                    -- save as related achievement
                    relatedAchievements[firstInLine][line] = {
                        GetAchievementInfo(line)
                    }

                    -- Save only completed ID and date
                    local name, description, points, icon, completed, date, time = GetAchievementInfo(line)
                    if completed then
                        doneAchievements[line] = date .. " " .. time
                    end

                    relatedAchievements[firstInLine][line]['priority'] = order

                    -- get next in line
                    line = GetNextAchievementInLine(line)
                end
            end

            subCategories[k].achievements = achievements
            subCategories[k].achievementCriteria = achievementCriteria
            subCategories[k].achievementsRewards = achievementsRewards
            subCategories[k].relatedAchievements = relatedAchievements
        end

        -- Check if all date requested
        if fetchAllData then
            categories[i].subCategories = subCategories
        end
    end

    -- Return categories if full data requested
    if fetchAllData then
        return categories
    end

    return doneAchievements
end
