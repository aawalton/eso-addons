--- ESO-Database.com Export AddOn for http://www.eso-database.com
--- written by Keldor
---
--- Please report bugs at http://www.eso-database.com/en/contact/

----
--- Initialize global Variables
----
ESODatabaseExport = {}
ESODatabaseExport.Name = "ESODatabaseExport"
ESODatabaseExport.DisplayName = "ESO-Database.com Export"
ESODatabaseExport.AddonVersion = "4.4.4"
ESODatabaseExport.AddonVersionInt = 4404
ESODatabaseExport.SavedVariablesName = "ESODBDataExportV4"
ESODatabaseExport.NumKeepStats = 12
ESODatabaseExport.VariableVersion = 22
ESODatabaseExport.ScanInterval = 60000 -- 1 Minute
ESODatabaseExport.ScanGuildInterval = 1800000 -- 30 Min
ESODatabaseExport.LeaderboardScanInterval = 3600000 -- 1 Hour
ESODatabaseExport.TimedActivitiesScanInterval = 3600000 -- 1 Hour
ESODatabaseExport.DataExportDelay = 800
ESODatabaseExport.ExportGuildsInterval = 250
ESODatabaseExport.ExportGuildMembersStartDelay = 3200
ESODatabaseExport.ExportGuildMembersRunInterval = 250
ESODatabaseExport.ExportGuildMembersPerRun = 20
ESODatabaseExport.SessionTimestamp = 0
ESODatabaseExport.Default = {
	Stats = {}
}
ESODatabaseExport.AccountWideDefault = {
	Guilds = {},
	Leaderboards = {},
	TimedActivities = {},
	Unknown = {
		Recipes = {},
	},
}
ESODatabaseExport.GlobalStore = {
	Lang = "",
	FenceSellsUsed = 0,
	FenceLaundersUsed = 0,
	DisableLootTracking = false,
	CurrentLockPickDifficulty = "",
	LastCompleteQuestRepeatType = "",
	MailCache = {
		GuildStore = {},
		WorthyReward = {},
	},
	GuildMemberExportQueue = {},
}


----
--- Initialize local Variables
----
local sv -- Saved variables
local ssv -- Saved variables stats for current game session
local svAccount -- Saved variables for account wide data


----
--- Export Functions
----
function ESODatabaseExport.InitSessionStatEntry()

	ESODatabaseExport.SessionTimestamp = GetTimeStamp()

	table.insert(sv.Stats, ESODBExportStats:GetDefault(ESODatabaseExport.SessionTimestamp))

	sv.Stats = ESODBExportStats:CleanupStatsTable(sv.Stats, ESODatabaseExport.NumKeepStats)
	ssv = sv.Stats[1]
end

function ESODatabaseExport.ClearUnknownValues()

	svAccount.Unknown.Recipes = {}
end

function ESODatabaseExport.InitStatisticsDefaultValues()

	local _, sellsUsed = GetFenceSellTransactionInfo()
	local _, laundersUsed = GetFenceLaunderTransactionInfo()

	ESODatabaseExport.GlobalStore.FenceSellsUsed = sellsUsed
	ESODatabaseExport.GlobalStore.FenceLaundersUsed = laundersUsed
end

function ESODatabaseExport.ExportMetaData()

	local characterName, megaserver = ESODBExportUtils:GetCharacterInfo()

	sv.Id = tonumber(GetCurrentCharacterId())
	sv.Timestamp = ESODatabaseExport.SessionTimestamp
	sv.AddonVersion = ESODatabaseExport.AddonVersionInt
	svAccount.AddonVersion = ESODatabaseExport.AddonVersionInt
	sv.Lang = ESODatabaseExport.GlobalStore.Lang
    sv.Megaserver = megaserver
	sv.CharacterName = characterName
	sv.Gender = GetUnitGender("player")
	sv.RaceId = GetUnitRaceId("player")
	sv.ClassId = GetUnitClassId("player")
	sv.AllianceId = GetUnitAlliance("player")
end

function ESODatabaseExport.ExportCharacterBaseInfo()

	local _, isEmperor = GetAchievementCriterion(935, 1)

	sv.Title = GetUnitTitle("player")
	sv.Emperor = isEmperor
	sv.AchievementPoints = GetEarnedAchievementPoints()
	sv.AvailableSkillPoints = GetAvailableSkillPoints()
	sv.AlliancePoints = GetCarriedCurrencyAmount(CURT_ALLIANCE_POINTS)
	sv.ZoneId = GetZoneId(GetCurrentMapZoneIndex())

	ssv.Playtime = GetSecondsPlayed()

	ESODatabaseExport.ExportMundus()
end

function ESODatabaseExport.ExportMundus()

	sv.MundusAbilityId = nil

	local numBuffs = GetNumBuffs("player")
	for i = 1, numBuffs do
		local _, _, _, _, _, _, _, _, _, _, id = GetUnitBuffInfo("player", i)
		if ESODBExportUtils:inTable(id, ESODBExportConst.MundusAbilityIds) == true then
			sv.MundusAbilityId = id
		end
	end
end

function ESODatabaseExport.ExportJusticeInfo()
	sv.Bounty = GetFullBountyPayoffAmount()
	sv.InfamyLevel = GetInfamyLevel(GetInfamy())
end

function ESODatabaseExport.ExportPrimaryHouse()

	local primaryHouse = GetHousingPrimaryHouse()
	if primaryHouse > 0 then
		sv.PrimaryResidence = GetCollectibleIdForHouse(primaryHouse)
	end
end

function ESODatabaseExport.EventAntiquityDiggingGameOver(_, gameOverFlags)

	if gameOverFlags == ANTIQUITY_DIGGING_GAME_OVER_FLAGS_VICTORY then
		ssv.Antiquity.DiggingVictory = ssv.Antiquity.DiggingVictory + 1
		ssv.Antiquity.DiggingTotal = ssv.Antiquity.DiggingTotal + 1

	elseif gameOverFlags == ANTIQUITY_DIGGING_GAME_OVER_FLAGS_ANTIQUITY_BROKEN then
		ssv.Antiquity.DiggingAntiquityBroken = ssv.Antiquity.DiggingAntiquityBroken + 1
		ssv.Antiquity.DiggingTotal = ssv.Antiquity.DiggingTotal + 1

	elseif gameOverFlags == ANTIQUITY_DIGGING_GAME_OVER_FLAGS_OUT_OF_TIME then
		ssv.Antiquity.DiggingOutOfTime = ssv.Antiquity.DiggingOutOfTime + 1
		ssv.Antiquity.DiggingTotal = ssv.Antiquity.DiggingTotal + 1
	end
end

function ESODatabaseExport.EventAntiquityDiggingBonusLootUnearthed()
	ssv.Antiquity.DiggingBonusLootUnearthed = ssv.Antiquity.DiggingBonusLootUnearthed + 1
end

function ESODatabaseExport.EventAntiquityDiggingAntiquityUnearthed()

	local antiquityId = GetTrackedAntiquityId()
	local difficulty = GetAntiquityDifficulty(antiquityId)
	local difficultyIndex = ESODBExportUtils:GetAntiquityDifficultyIndex(difficulty)

	if difficultyIndex ~= "" then
		ssv.AntiquityDifficulty[difficultyIndex] = ssv.AntiquityDifficulty[difficultyIndex] + 1
	end
end

function ESODatabaseExport.EventAntiquityLeadAcquired()
	ssv.Antiquity.LeadAcquired = ssv.Antiquity.LeadAcquired + 1
end

function ESODatabaseExport.EventCollectibleUseResult(_, result)

	if result == COLLECTIBLE_USAGE_BLOCK_REASON_NOT_BLOCKED then

		local actionSlotIndex = GetCurrentQuickslot()
		local actionSlotItemLink = GetSlotItemLink(actionSlotIndex)
		local collectibleId = GetCollectibleIdFromLink(actionSlotItemLink)

		-- Antiquarian's Eye
		if collectibleId == GetAntiquityScryingToolCollectibleId() then
			ssv.Antiquity.AntiquariansEyeUsed = ssv.Antiquity.AntiquariansEyeUsed + 1
		end
	end
end

function ESODatabaseExport.EventAntiquityDigSitesOnMap(_, antiquityId)

	local difficulty = GetAntiquityDifficulty(antiquityId)
	local difficultyIndex = ESODBExportUtils:GetAntiquityDifficultyIndex(difficulty)

	if difficultyIndex ~= "" then
		ssv.AntiquityScryingDifficulty[difficultyIndex] = ssv.AntiquityScryingDifficulty[difficultyIndex] + 1
	end

	ssv.Antiquity.ScryingTotal = ssv.Antiquity.ScryingTotal + 1
end

function ESODatabaseExport.EventAntiquityUpdated(_, antiquityId)
	ESODatabaseExport.ExportAntiquityInfo(antiquityId)
end

function ESODatabaseExport.EventItemSetCollectionUpdated(_, itemSetId)
	ESODatabaseExport.ExportItemSetCollectionSet(itemSetId)
end

function ESODatabaseExport.EventTimedActivityProgressUpdated(_, index, _, _, complete)

	local timedActivityType = GetTimedActivityType(index)
	if complete == true then
		if timedActivityType == TIMED_ACTIVITY_TYPE_DAILY then
			ssv.TimedActivities.Daily = ssv.TimedActivities.Daily + 1
		elseif timedActivityType == TIMED_ACTIVITY_TYPE_WEEKLY then
			ssv.TimedActivities.Weekly = ssv.TimedActivities.Weekly + 1
		end
	end
end

function ESODatabaseExport.ExportCharacterStats()

	sv.CharStats = {}
	sv.CharStats.ArmorRating = GetPlayerStat(STAT_ARMOR_RATING)
	sv.CharStats.AttackPower = ESODBExportUtils:GetPlayerStat(STAT_ATTACK_POWER)
	sv.CharStats.Block = ESODBExportUtils:GetPlayerStat(STAT_BLOCK)
	sv.CharStats.CriticalResistance = ESODBExportUtils:GetPlayerStat(STAT_CRITICAL_RESISTANCE)
	sv.CharStats.CriticalStrike = ESODBExportUtils:GetPlayerStat(STAT_CRITICAL_STRIKE)
	sv.CharStats.ResistCold = ESODBExportUtils:GetPlayerStat(STAT_DAMAGE_RESIST_COLD)
	sv.CharStats.ResistDisease = ESODBExportUtils:GetPlayerStat(STAT_DAMAGE_RESIST_DISEASE)
	sv.CharStats.ResistDrown = ESODBExportUtils:GetPlayerStat(STAT_DAMAGE_RESIST_DROWN)
	sv.CharStats.ResistEarth = ESODBExportUtils:GetPlayerStat(STAT_DAMAGE_RESIST_EARTH)
	sv.CharStats.ResistFire = ESODBExportUtils:GetPlayerStat(STAT_DAMAGE_RESIST_FIRE)
	sv.CharStats.ResistGeneric = ESODBExportUtils:GetPlayerStat(STAT_DAMAGE_RESIST_GENERIC)
	sv.CharStats.ResistMagic = ESODBExportUtils:GetPlayerStat(STAT_DAMAGE_RESIST_MAGIC)
	sv.CharStats.ResistOblivion = ESODBExportUtils:GetPlayerStat(STAT_DAMAGE_RESIST_OBLIVION)
	sv.CharStats.ResistPhysical = ESODBExportUtils:GetPlayerStat(STAT_DAMAGE_RESIST_PHYSICAL)
	sv.CharStats.ResistPoison = ESODBExportUtils:GetPlayerStat(STAT_DAMAGE_RESIST_POISON)
	sv.CharStats.ResistShock = ESODBExportUtils:GetPlayerStat(STAT_DAMAGE_RESIST_SHOCK)
	sv.CharStats.ResistStart = ESODBExportUtils:GetPlayerStat(STAT_DAMAGE_RESIST_START)
	sv.CharStats.Dodge = ESODBExportUtils:GetPlayerStat(STAT_DODGE)
	sv.CharStats.HealingTaken = ESODBExportUtils:GetPlayerStat(STAT_HEALING_TAKEN)
	sv.CharStats.HealthMax = ESODBExportUtils:GetPlayerStat(STAT_HEALTH_MAX)
	sv.CharStats.HealthRegenCombat = ESODBExportUtils:GetPlayerStat(STAT_HEALTH_REGEN_COMBAT)
	sv.CharStats.HealthRegenIdle = ESODBExportUtils:GetPlayerStat(STAT_HEALTH_REGEN_IDLE)
	sv.CharStats.MagickaMax = ESODBExportUtils:GetPlayerStat(STAT_MAGICKA_MAX)
	sv.CharStats.MagickaRegenCombat = ESODBExportUtils:GetPlayerStat(STAT_MAGICKA_REGEN_COMBAT)
	sv.CharStats.MagickaRegenIdle = ESODBExportUtils:GetPlayerStat(STAT_MAGICKA_REGEN_IDLE)
	sv.CharStats.Miss = ESODBExportUtils:GetPlayerStat(STAT_MISS)
	sv.CharStats.Mitigation = ESODBExportUtils:GetPlayerStat(STAT_MITIGATION)
	sv.CharStats.MountStaminaMax = ESODBExportUtils:GetPlayerStat(STAT_MOUNT_STAMINA_MAX)
	sv.CharStats.MountStaminaRegenCombat = ESODBExportUtils:GetPlayerStat(STAT_MOUNT_STAMINA_REGEN_COMBAT)
	sv.CharStats.MountStaminaRegenMoving = ESODBExportUtils:GetPlayerStat(STAT_MOUNT_STAMINA_REGEN_MOVING)
	sv.CharStats.Parry = ESODBExportUtils:GetPlayerStat(STAT_PARRY)
	sv.CharStats.PhysicalPenetration = ESODBExportUtils:GetPlayerStat(STAT_PHYSICAL_PENETRATION)
	sv.CharStats.PhysicalResist = ESODBExportUtils:GetPlayerStat(STAT_PHYSICAL_RESIST)
	sv.CharStats.Power = ESODBExportUtils:GetPlayerStat(STAT_POWER)
	sv.CharStats.SpellCritical = ESODBExportUtils:GetPlayerStat(STAT_SPELL_CRITICAL)
	sv.CharStats.SpellMitigation = ESODBExportUtils:GetPlayerStat(STAT_SPELL_MITIGATION)
	sv.CharStats.SpellPenetration = ESODBExportUtils:GetPlayerStat(STAT_SPELL_PENETRATION)
	sv.CharStats.SpellPower = ESODBExportUtils:GetPlayerStat(STAT_SPELL_POWER)
	sv.CharStats.SpellResist = ESODBExportUtils:GetPlayerStat(STAT_SPELL_RESIST)
	sv.CharStats.StaminaMax = ESODBExportUtils:GetPlayerStat(STAT_STAMINA_MAX)
	sv.CharStats.StaminaRegenCombat = ESODBExportUtils:GetPlayerStat(STAT_STAMINA_REGEN_COMBAT)
	sv.CharStats.StaminaRegenIdle = ESODBExportUtils:GetPlayerStat(STAT_STAMINA_REGEN_IDLE)
	sv.CharStats.WeaponPower = ESODBExportUtils:GetPlayerStat(STAT_WEAPON_POWER)

end

function ESODatabaseExport.ExportTimedActivities()

	svAccount.TimedActivities.Lang = ESODatabaseExport.GlobalStore.Lang
	svAccount.TimedActivities.Timestamp = GetTimeStamp()
	svAccount.TimedActivities.Daily = {}
	svAccount.TimedActivities.Weekly = {}

	if IsTimedActivitySystemAvailable() == true then

		local numActivities = GetNumTimedActivities()
		if numActivities > 0 then
			for index = 1, numActivities do

				local rewards = {}
				local type = GetTimedActivityType(index)
				local id = GetTimedActivityId(index)
				local difficulty = GetTimedActivityDifficulty(index)
				local name = GetTimedActivityName(index)
				local description = GetTimedActivityDescription(index)
				local numRewards = GetNumTimedActivityRewards(index)
				local uniqueID = type .. "-" .. id .. "-" .. difficulty

				if numRewards > 0 then
					for rewardIndex = 1, numRewards do

						local rewardId, quantity = GetTimedActivityRewardInfo(index, rewardIndex)
						local rewardData = REWARDS_MANAGER:GetInfoForReward(rewardId, quantity)

						table.insert(rewards, {
							Id = rewardId,
							Quantity = quantity,
							Name = rewardData:GetFormattedName(),
							Icon = rewardData:GetKeyboardIcon(),
						})
					end
				end

				if type == TIMED_ACTIVITY_TYPE_DAILY then

					local tableIndex = ESODBExportUtils:SetTableIndexByFieldValue(svAccount.TimedActivities.Daily, "UniqueId", uniqueID, {
						UniqueId = uniqueID,
					})

					svAccount.TimedActivities.Daily[tableIndex].Id = id
					svAccount.TimedActivities.Daily[tableIndex].Difficulty = difficulty
					svAccount.TimedActivities.Daily[tableIndex].Name = name
					svAccount.TimedActivities.Daily[tableIndex].Description = description
					svAccount.TimedActivities.Daily[tableIndex].Rewards = rewards

				elseif type == TIMED_ACTIVITY_TYPE_WEEKLY then

					local tableIndex = ESODBExportUtils:SetTableIndexByFieldValue(svAccount.TimedActivities.Weekly, "UniqueId", uniqueID, {
						UniqueId = uniqueID,
					})

					svAccount.TimedActivities.Weekly[tableIndex].Id = id
					svAccount.TimedActivities.Weekly[tableIndex].Difficulty = difficulty
					svAccount.TimedActivities.Weekly[tableIndex].Name = name
					svAccount.TimedActivities.Weekly[tableIndex].Description = description
					svAccount.TimedActivities.Weekly[tableIndex].Rewards = rewards
				end
			end
		end
	end
end

function ESODatabaseExport.ExportRidingStats()

	local inventoryBonus, maxInventoryBonus, staminaBonus, maxStaminaBonus, speedBonus, maxSpeedBonus = GetRidingStats()

	sv.RidingStats = {}
	sv.RidingStats.InventoryBonus = inventoryBonus
	sv.RidingStats.MaxInventoryBonus = maxInventoryBonus
	sv.RidingStats.StaminaBonus = staminaBonus
	sv.RidingStats.MaxStaminaBonus = maxStaminaBonus
	sv.RidingStats.SpeedBonus = speedBonus
	sv.RidingStats.MaxSpeedBonus = maxSpeedBonus
end

function ESODatabaseExport.ExportLevel()

	sv.Level = {}
	sv.Level.EffectiveLevel = GetUnitEffectiveLevel("player")
	sv.Level.Level = GetUnitLevel("player")
	sv.Level.XP = GetUnitXP("player")
	sv.Level.XPMax = GetUnitXPMax("player")

	ESODatabaseExport.ExportCharacterStats()
end

function ESODatabaseExport.ExportChampionRank()

	sv.Level.ChampionPoints = GetPlayerChampionPointsEarned()
	sv.Level.ChampionXPCurrent = GetPlayerChampionXP()
	sv.Level.ChampionXPMax = GetNumChampionXPInChampionPoint(sv.Level.ChampionPoints)
	sv.Level.ChampionAttribute = GetChampionPointPoolForRank(sv.Level.ChampionPoints + 1)
end

function ESODatabaseExport.ExportAvA()

	local avaRank, avaCurrentPoints, avaMaxPoints = ESODBExportUtils:GetCurrentAvARankProgress()

	sv.AvA = {}
	sv.AvA.Rank = avaRank
	sv.AvA.RankName = zo_strformat(SI_UNIT_NAME, GetAvARankName(sv.Gender, avaRank))
	sv.AvA.RankPoints = avaCurrentPoints
	sv.AvA.RankPointsMax = avaMaxPoints
end

function ESODatabaseExport.ExportGold()

	local characterGold = GetCarriedCurrencyAmount(CURT_MONEY)
	local bankGold = GetBankedCurrencyAmount(CURT_MONEY)

	ssv.Gold.Total = characterGold + bankGold
	ssv.Gold.Character = characterGold
	ssv.Gold.Bank = bankGold
end

function ESODatabaseExport.ExportTelVarStones()

	local characterTelVarStones = GetCarriedCurrencyAmount(CURT_TELVAR_STONES)
	local bankTelVarStones = GetBankedCurrencyAmount(CURT_TELVAR_STONES)

	ssv.TelVarStones.Total = characterTelVarStones + bankTelVarStones
	ssv.TelVarStones.Character = characterTelVarStones
	ssv.TelVarStones.Bank = bankTelVarStones

	if characterTelVarStones > ssv.TelVarStones.HighestAmountOnCharacter then
		ssv.TelVarStones.HighestAmountOnCharacter = characterTelVarStones
	end
end

function ESODatabaseExport.ExportTradeskills()

	sv.Tradeskills = {}

	for _, craftingType in pairs(ESODBExportConst.Tradeskills) do

		local skillType, skillIndex = GetCraftingSkillLineIndices(craftingType)
		local _, rank = GetSkillLineInfo(skillType, skillIndex)
		local lastRankXP, nextRankXP, currentXP = GetSkillLineXPInfo(skillType, skillIndex)
		local tableIndex = ESODBExportUtils:SetTableIndexByFieldValue(sv.Tradeskills, "Id", craftingType, {
			Id = craftingType,
		})

		sv.Tradeskills[tableIndex]["Rank"] = rank
		sv.Tradeskills[tableIndex]["CurrentXP"] = (currentXP - lastRankXP)
		sv.Tradeskills[tableIndex]["NextRankXP"] = (nextRankXP - lastRankXP)
		sv.Tradeskills[tableIndex]["Traits"] = {}

		local numLines = GetNumSmithingResearchLines(craftingType)
		if numLines > 0 then
			for researchLineIndex = 1, numLines do

				local _, _, numTraits, _ = GetSmithingResearchLineInfo(craftingType, researchLineIndex)
				if numTraits > 0 then

					local lineTableIndex = ESODBExportUtils:SetTableIndexByFieldValue(sv.Tradeskills[tableIndex].Traits, "Id", researchLineIndex, {
						Id = researchLineIndex,
						List = {},
					})

					sv.Tradeskills[tableIndex].Traits[lineTableIndex].List = {}

					for traitIndex = 1, numTraits do

						local traitType, _, known = GetSmithingResearchLineTraitInfo(craftingType, researchLineIndex, traitIndex)
						local traitTableIndex = ESODBExportUtils:SetTableIndexByFieldValue(sv.Tradeskills[tableIndex].Traits[lineTableIndex].List, "Id", traitType, {
							Id = traitType,
						})

						sv.Tradeskills[tableIndex].Traits[lineTableIndex].List[traitTableIndex]["Line"] = researchLineIndex
						sv.Tradeskills[tableIndex].Traits[lineTableIndex].List[traitTableIndex]["Trait"] = traitType
						sv.Tradeskills[tableIndex].Traits[lineTableIndex].List[traitTableIndex]["Known"] = known

						-- Export research timers
						ESODatabaseExport.ExportResearchTimers(craftingType, researchLineIndex, traitIndex, traitType)
					end
				end
			end
		end
	end
end

function ESODatabaseExport.ExportResearchTimers(craftingType, researchLineIndex, traitIndex, traitType)

	if type(ESODBExportConst.TradeskillResearchTypes[craftingType]) ~= "nil" then

		local durationSecs, timeRemainingSecs = GetSmithingResearchLineTraitTimes(craftingType, researchLineIndex, traitIndex)
		if durationSecs then

			local startTime = GetTimeStamp() - (durationSecs - timeRemainingSecs)
			local endTime = startTime + durationSecs

			if type(sv.ResearchTimers) == "nil" then
				sv.ResearchTimers = {}
			end

			local lookupKey = tonumber(craftingType .. researchLineIndex .. traitIndex .. traitType)
			local tableIndex = ESODBExportUtils:SetTableIndexByFieldValue(sv.ResearchTimers, "LookupKey", lookupKey, {
				LookupKey = lookupKey
			})

			sv.ResearchTimers[tableIndex]["Type"] = craftingType
			sv.ResearchTimers[tableIndex]["Line"] = researchLineIndex
			sv.ResearchTimers[tableIndex]["Trait"] = traitType
			sv.ResearchTimers[tableIndex]["StartTime"] = startTime
			sv.ResearchTimers[tableIndex]["EndTime"] = endTime
		end
	end
end

function ESODatabaseExport.ExportAlchemyTraits()

	local tableIndex = ESODBExportUtils:GetTableIndexByFieldValue(sv.Tradeskills, "Id", CRAFTING_TYPE_ALCHEMY)
	if tableIndex ~= false then

		for _, itemId in pairs(ESODBExportConst.Alchemy.Reagents) do

			local itemLink = string.format("|H1:item:%i:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId)

			for i = 1, 4 do
				local known, traitName = GetItemLinkReagentTraitInfo(itemLink, i)
				if known then

					local traitIndex = ESODBExportUtils:AlchemyTraitNameToIndex(traitName)
					if traitIndex ~= nil then

						local traitId = tonumber(itemId .. traitIndex)
						local traitTableIndex = ESODBExportUtils:GetTableIndexByFieldValue(sv.Tradeskills[tableIndex].Traits, "TraitId", traitId)
						if traitTableIndex == false then
							table.insert(sv.Tradeskills[tableIndex].Traits, {
								TraitId = traitId,
								Id = itemId,
								Trait = traitIndex
							})
						end
					end
				end
			end
		end
	end
end

function ESODatabaseExport.ExportEnchantingRuneTraits()

	local tableIndex = ESODBExportUtils:GetTableIndexByFieldValue(sv.Tradeskills, "Id", CRAFTING_TYPE_ENCHANTING)
	if tableIndex ~= false then
		for _, itemId in pairs(ESODBExportConst.Enchanting.Runes) do

			local itemLink = string.format("|H1:item:%i:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId)
			local known = GetItemLinkEnchantingRuneName(itemLink)

			if known then
				local traitTableIndex = ESODBExportUtils:GetTableIndexByFieldValue(sv.Tradeskills[tableIndex].Traits, "Id", itemId)
				if traitTableIndex == false then
					table.insert(sv.Tradeskills[tableIndex].Traits, {
						Id = itemId
					})
				end
			end
		end
	end
end

function ESODatabaseExport.ExportSkillLines()

	sv.SkillLines = {}

	local numSkillTypes = GetNumSkillTypes()
	for skillType = 1, numSkillTypes do

		local numSkillLines = GetNumSkillLines(skillType)
		for skillLineIndex = 1, numSkillLines do

			local skillLineId = GetSkillLineId(skillType, skillLineIndex)
			local _, rank = GetSkillLineInfo(skillType, skillLineIndex)
			local lastRankXP, nextRankXP, currentXP = GetSkillLineXPInfo(skillType, skillLineIndex)

			table.insert(sv.SkillLines, {
				Id = skillLineId,
				Rank = rank,
				CurrentXP = (currentXP - lastRankXP),
				NextRankXP = (nextRankXP - lastRankXP)
			})
		end
	end
end

function ESODatabaseExport.ExportAchievements()

	sv.Achievements = {}

	local numCategories = GetNumAchievementCategories()
	for categoryIndex = 1, numCategories do

		local _, numSubCategories, numAchievements = GetAchievementCategoryInfo(categoryIndex)

		if numAchievements > 0 then
			for i = 1, numAchievements do
				local achievementId = GetAchievementId(categoryIndex, nil, i)
				ESODatabaseExport.ExportAchievementById(achievementId)
			end
		end

		if numSubCategories > 0 then
			for subCategoryIndex = 1, numSubCategories do

				local _, subNumAchievements = GetAchievementSubCategoryInfo(categoryIndex, subCategoryIndex)

				if subNumAchievements > 0 then
					for i = 1, subNumAchievements do
						local achievementId = GetAchievementId(categoryIndex, subCategoryIndex, i)
						ESODatabaseExport.ExportAchievementById(achievementId)
					end
				end
			end
		end
	end
end

function ESODatabaseExport.ExportAchievementById(achievementId)

	local _, _, _, _, completed = GetAchievementInfo(achievementId)

	if completed == true then

		table.insert(sv.Achievements, {
			achievementId = achievementId,
			completed = true,
			timestamp = tonumber(Id64ToString(GetAchievementTimestamp(achievementId)))
		})

		-- Get previous achievements in line
		local lineIds = ESODBExportUtils:GetAchievementsInLine(achievementId)
		if #lineIds > 0 then
			for _, lineAchievementId in pairs(lineIds) do
				_, _, _, _, completed = GetAchievementInfo(lineAchievementId)
				table.insert(sv.Achievements, {
					achievementId = lineAchievementId,
					completed = true,
					timestamp = tonumber(Id64ToString(GetAchievementTimestamp(lineAchievementId)))
				})
			end
		end
	else

		local numCriteria = GetAchievementNumCriteria(achievementId)
		if numCriteria > 0 then

			local criterions = {}
			for j = 1, numCriteria do

				local _, numCompleted, _ = GetAchievementCriterion(achievementId, j)
				table.insert(criterions, {
					index = j,
					numCompleted = numCompleted,
				})
			end

			table.insert(sv.Achievements, {
				achievementId = achievementId,
				completed = false,
				criterions = criterions,
			})
		end
	end
end

function ESODatabaseExport.ExportRecipe(_, recipeListIndex, recipeIndex)

    local known, name = GetRecipeInfo(recipeListIndex, recipeIndex)
    local recipeItemLink = GetRecipeResultItemLink(recipeListIndex, recipeIndex)
    local _, _, _, recipeItemId = ZO_LinkHandler_ParseLink(recipeItemLink)

    if recipeItemId ~= "" and type(recipeItemId) ~= "nil" then

		-- Ensure the value is a number
		recipeItemId = tonumber(recipeItemId)

        if known == true then
            table.insert(sv.Recipes, recipeItemId)
        end

        if type(ESODBExportRecipes.Known[recipeItemId]) == "nil" then
            if ESODBExportUtils:GetTableIndexByFieldValue(svAccount.Unknown.Recipes, "Id", recipeItemId) == false then
                local _, icon, _, _, quality = GetRecipeResultItemInfo(recipeListIndex, recipeIndex)
                local listName = GetRecipeListInfo(recipeListIndex)
                table.insert(svAccount.Unknown.Recipes, {
                    Id = recipeItemId,
                    Name = zo_strformat(SI_TOOLTIP_ITEM_NAME, name),
                    CategoryName = listName,
                    Quality = quality,
                    Icon = icon,
                })
            end
        end
    end
end

function ESODatabaseExport.ExportRecipes()

	sv.Recipes = {}

	local numLists = GetNumRecipeLists()
	for recipeListIndex = 1, numLists do
		local _, numRecipes = GetRecipeListInfo(recipeListIndex)
		if numRecipes > 0 then
			for recipeIndex = 1, numRecipes do
                ESODatabaseExport.ExportRecipe(nil, recipeListIndex, recipeIndex)
			end
		end
	end
end

function ESODatabaseExport.ExportQuestById(questId)
	table.insert(sv.Quests, questId)
end

function ESODatabaseExport.ExportCompletedQuests()

	sv.Quests = {}

	local questId = GetNextCompletedQuestId()
	while questId ~= nil do
		questId = tonumber(questId)
		ESODatabaseExport.ExportQuestById(questId)
		questId = GetNextCompletedQuestId(questId)
	end
end

function ESODatabaseExport.ExportLoreBook(_, categoryIndex, collectionIndex, bookIndex)

	local _, _, known = GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex)
	local bookItemLink = GetLoreBookLink(categoryIndex, collectionIndex, bookIndex, LINK_STYLE_BRACKETS)
	local _, _, _, bookItemId = ZO_LinkHandler_ParseLink(bookItemLink)

	if bookItemId ~= "" and known then
		table.insert(sv.LoreBooks, tonumber(bookItemId))
	end
end

function ESODatabaseExport.ExportLoreBooks()

	sv.LoreBooks = {}
	sv.LoreBookCollections = {}

	local numCategories = GetNumLoreCategories()
	if numCategories > 0 then
		for categoryIndex = 1, numCategories do
			local _, numCollections = GetLoreCategoryInfo(categoryIndex)
			if numCollections > 0 then
				for collectionIndex = 1, numCollections do

					local nameCollection, _, numKnownBooks, totalBooks = GetLoreCollectionInfo(categoryIndex, collectionIndex)

					if totalBooks > 0 then

						if numKnownBooks == totalBooks then
							table.insert(sv.LoreBookCollections, nameCollection)
						else

							for bookIndex = 1, totalBooks do
								ESODatabaseExport.ExportLoreBook(nil, categoryIndex, collectionIndex, bookIndex)
							end
						end
					end
				end
			end
		end
	end
end

function ESODatabaseExport.ExportCollectiblesForCategory(categoryIndex, subCategoryIndex, numCollectibles)

    if numCollectibles > 0 then
        for collectibleIndex = 1, numCollectibles do
            local collectibleId = GetCollectibleId(categoryIndex, subCategoryIndex, collectibleIndex)
			ESODatabaseExport.ExportCollectibleById(collectibleId)
        end
    end
end

function ESODatabaseExport.ExportCollectibleById(collectibleId)

	local _, _, _, _, unlocked, _, active, categoryType = GetCollectibleInfo(collectibleId)

	-- Valid category
	if type(ESODBExportConst.CollectionsCategoryTypes[categoryType]) ~= "nil" then

		local nickname = GetCollectibleNickname(collectibleId)

		-- Only add nickname property for entries with this value to reduce file size
		if nickname ~= "" then
			table.insert(sv.Collectibles, {
				Id = collectibleId,
				Unlocked = unlocked,
				Active = active,
				Nickname = nickname
			})
		else
			table.insert(sv.Collectibles, {
				Id = collectibleId,
				Unlocked = unlocked,
				Active = active
			})
		end
	end
end

function ESODatabaseExport.ExportCollectibles()

    sv.Collectibles = {}

    local numCategories = GetNumCollectibleCategories()
    if numCategories > 0 then
        for categoryIndex = 1, numCategories do

            local _, numSubCategories, numCollectibles = GetCollectibleCategoryInfo(categoryIndex)
            ESODatabaseExport.ExportCollectiblesForCategory(categoryIndex, nil, numCollectibles)

            if numSubCategories > 0 then
                for subCategoryIndex = 1, numSubCategories do
                    local _, subNumCollectibles = GetCollectibleSubCategoryInfo(categoryIndex, subCategoryIndex)
                    ESODatabaseExport.ExportCollectiblesForCategory(categoryIndex, subCategoryIndex, subNumCollectibles)
                end
            end
        end
    end
end

function ESODatabaseExport.EventCollectibleNotificationNew(_, collectibleId)
	ESODatabaseExport.ExportCollectibleById(collectibleId)
end

function ESODatabaseExport.ExportAntiquityInfo(antiquityId)

	local numRecovered = GetNumAntiquitiesRecovered(antiquityId)
	if numRecovered > 0 then

		local numLoreEntriesAcquired = GetNumAntiquityLoreEntriesAcquired(antiquityId)
		local tableIndex = ESODBExportUtils:SetTableIndexByFieldValue(sv.Antiquities, "Id", antiquityId, {
			Id = antiquityId,
			Recovered = 0,
			LoreEntriesAcquired = 0
		})

		sv.Antiquities[tableIndex].Recovered = numRecovered
		sv.Antiquities[tableIndex].LoreEntriesAcquired = numLoreEntriesAcquired
	end
end

function ESODatabaseExport.ExportItemSetCollectionSet(itemSetId)

	local numPieces = GetNumItemSetCollectionPieces(itemSetId)
	if numPieces > 0 then
		for i = 1, numPieces do
			local pieceId = GetItemSetCollectionPieceInfo(itemSetId, i)
			if IsItemSetCollectionPieceUnlocked(pieceId) == true then
				local tableIndex = ESODBExportUtils:GetTableIndexByFieldValue(sv.ItemSetCollectionPieces, "PieceId", pieceId)
				if tableIndex == false then
					table.insert(sv.ItemSetCollectionPieces, {
						PieceId = pieceId
					})
				end
			end
		end
	end
end

function ESODatabaseExport.ExportAntiquities()

	sv.Antiquities = {}

	for antiquityId in pairs(ESODBExportAntiquities.Known) do
		ESODatabaseExport.ExportAntiquityInfo(antiquityId)
	end
end

function ESODatabaseExport.ExportItemSetCollections()

	sv.ItemSetCollectionPieces = {}

	for itemSetId in pairs(ESODBExportItemSetCollection.Known) do
		ESODatabaseExport.ExportItemSetCollectionSet(itemSetId)
	end
end

function ESODatabaseExport.ExportGuildRecruitment(tableIndex, guildID)

	local recruitmentStatus = GetGuildRecruitmentStatus(guildID)
	if recruitmentStatus == GUILD_RECRUITMENT_STATUS_ATTRIBUTE_VALUE_LISTED then

		local recruitmentMessage, headerMessage, _, primaryFocus, secondaryFocus, personality, language, minimumCP = GetGuildRecruitmentInfo(guildID)
		svAccount.Guilds[tableIndex].Recruitment = {
			RecruitmentMessage = recruitmentMessage,
			HeaderMessage = headerMessage,
			PrimaryFocus = primaryFocus,
			SecondaryFocus = secondaryFocus,
			Personality = personality,
			Language = language,
			MinimumCP = minimumCP,
			StartTime = GetGuildRecruitmentStartTime(guildID),
			EndTime = GetGuildRecruitmentEndTime(guildID),
			RoleDPS = GetGuildRecruitmentRoleValue(guildID, LFG_ROLE_DPS),
			RoleHeal = GetGuildRecruitmentRoleValue(guildID, LFG_ROLE_HEAL),
			RoleTank = GetGuildRecruitmentRoleValue(guildID, LFG_ROLE_TANK)
		}
	else
		svAccount.Guilds[tableIndex].Recruitment = {}
	end
end

function ESODatabaseExport.ExportGuildMembersFromQueue()

	local maxIndex = #ESODatabaseExport.GlobalStore.GuildMemberExportQueue
	if maxIndex > 0 then

		local runnerDelay = 0

		for _, guildId in ipairs(ESODatabaseExport.GlobalStore.GuildMemberExportQueue) do

			local updaterRuns = 1
			local guildNumMembers = GetNumGuildMembers(guildId)

			local tableIndex = ESODBExportUtils:SetTableIndexByFieldValue(svAccount.Guilds, "Id", guildId, {
				Id = guildID
			})

			if guildNumMembers >= ESODatabaseExport.ExportGuildMembersPerRun then
				updaterRuns = math.floor(guildNumMembers / ESODatabaseExport.ExportGuildMembersPerRun)
			end

			for runnerNumber = 1, updaterRuns do

				local runnerName = ESODatabaseExport.Name .. "ExportGuildMembers_" .. guildId .. "_" .. runnerNumber
				runnerDelay = runnerDelay + ESODatabaseExport.ExportGuildMembersRunInterval

				EVENT_MANAGER:UnregisterForUpdate(runnerName)
				EVENT_MANAGER:RegisterForUpdate(runnerName, runnerDelay, function()

					local runnerStartIndex = ((runnerNumber - 1) * ESODatabaseExport.ExportGuildMembersPerRun)
					local runnerEndIndex = runnerStartIndex + ESODatabaseExport.ExportGuildMembersPerRun

					if runnerNumber == updaterRuns then
						runnerEndIndex = guildNumMembers
					end

					ESODatabaseExport.ExportGuildMembers(guildId, tableIndex, runnerStartIndex, runnerEndIndex)
					EVENT_MANAGER:UnregisterForUpdate(runnerName)
				end)
			end
		end

		ESODatabaseExport.GlobalStore.GuildMemberExportQueue = {}
	end
end

function ESODatabaseExport.ExportGuildMembers(guildID, tableIndex, startIndex, endIndex)

	local i = 0
	for m = startIndex, endIndex, 1 do

		local hasCharacter, characterName, _, classId, alliance, level, championRank = GetGuildMemberCharacterInfo(guildID, m)
		if hasCharacter then
			i = #svAccount.Guilds[tableIndex].Members
			svAccount.Guilds[tableIndex].Members[(i + 1)] = {
				CharacterName = zo_strformat(SI_UNIT_NAME, characterName),
				ClassId = classId,
				AllianceId = alliance,
				Level = level,
				ChampionRank = championRank
			}
		end
	end
end

function ESODatabaseExport.ExportGuild(guildIndex)

	local guildID = GetGuildId(guildIndex)
	local guildName = GetGuildName(guildID)
	local _, _, leaderName = GetGuildInfo(guildID)
	local guildLeaderCharacterName = ESODBExportUtils:GetGuildLeaderCharacterName(guildID, leaderName)
	local guildTraderInfo = GetGuildOwnedKioskInfo(guildID)

	if type(guildTraderInfo) ~= "nil" then
		guildTraderInfo = zo_strformat(SI_GUILD_HIRED_TRADER, guildTraderInfo)
	else
		guildTraderInfo = ""
	end

	local tableIndex = ESODBExportUtils:SetTableIndexByFieldValue(svAccount.Guilds, "Id", guildID, {
		Id = guildID
	})

	svAccount.Guilds[tableIndex]["Name"] = guildName
	svAccount.Guilds[tableIndex]["Megaserver"] = sv.Megaserver
	svAccount.Guilds[tableIndex]["AllianceId"] = GetGuildAlliance(guildID)
	svAccount.Guilds[tableIndex]["FoundedDate"] = GetGuildFoundedDate(guildID)
	svAccount.Guilds[tableIndex]["LeaderCharacterName"] = guildLeaderCharacterName
	svAccount.Guilds[tableIndex]["GuildTrader"] = guildTraderInfo
	svAccount.Guilds[tableIndex]["Members"] = {}
	svAccount.Guilds[tableIndex]["Recruitment"] = {}

	table.insert(sv.Guilds, guildID)
	table.insert(ESODatabaseExport.GlobalStore.GuildMemberExportQueue, guildID)

	ESODatabaseExport.ExportGuildRecruitment(tableIndex, guildID)
end

function ESODatabaseExport.ExportGuilds()

	ESODatabaseExport.GlobalStore.GuildMemberExportQueue = {}
	sv.Guilds = {}
	svAccount.Guilds = {}

	local guildCount = GetNumGuilds()
	if guildCount > 0 then

		for guildIndex = 1, guildCount, 1 do
			ESODatabaseExport.ExportGuild(guildIndex)
		end

		-- Export guild members for guilds
		local exportName = ESODatabaseExport.Name .. "ExportGuildMembersQueue"
		EVENT_MANAGER:UnregisterForUpdate(exportName)
		EVENT_MANAGER:RegisterForUpdate(exportName, ESODatabaseExport.ExportGuildMembersStartDelay, function()
			ESODatabaseExport.ExportGuildMembersFromQueue()
			EVENT_MANAGER:UnregisterForUpdate(exportName)
		end)
	end
end

function ESODatabaseExport.ExportTitles()

	sv.Titles = {}

	local numTitles = GetNumTitles()
	if numTitles > 0 then
		for titleIndex = 1, numTitles do
			table.insert(sv.Titles, GetTitle(titleIndex))
		end
	end
end

function ESODatabaseExport.QueryLeaderboardData()

	-- Must be called before accessing leaderboard data
	-- When the data is ready, EVENT_RAID_LEADERBOARD_DATA_CHANGED is fired
	QueryRaidLeaderboardData()
end

function ESODatabaseExport.QueryBattlegroundData()

	-- Must be called before accessing leaderboard data
	-- When the data is ready, EVENT_BATTLEGROUND_LEADERBOARD_DATA_CHANGED is fired
	QueryBattlegroundLeaderboardData()
end

function ESODatabaseExport.ExportTrialLeadeboards()

	local _, megaserver = ESODBExportUtils:GetCharacterInfo()

	svAccount.TrialLeaderboards = {}
	svAccount.TrialLeaderboards.Megaserver = megaserver
	svAccount.TrialLeaderboards.AddonVersion = ESODatabaseExport.AddonVersionInt
	svAccount.TrialLeaderboards.Timestamp = GetTimeStamp()
	svAccount.TrialLeaderboards.Trials = {}
	svAccount.TrialLeaderboards.Weekly = {}

	ESODatabaseExport.ExportTrialScores()
	ESODatabaseExport.ExportWeeklyTrialScores()
end

function ESODatabaseExport.ExportBattlegroundLeadeboards()

	local _, megaserver = ESODBExportUtils:GetCharacterInfo()

	svAccount.BattlegroundLeaderboards = {}
	svAccount.BattlegroundLeaderboards.Megaserver = megaserver
	svAccount.BattlegroundLeaderboards.AddonVersion = ESODatabaseExport.AddonVersionInt
	svAccount.BattlegroundLeaderboards.Timestamp = GetTimeStamp()
	svAccount.BattlegroundLeaderboards.Battlegrounds = {}

	ESODatabaseExport.ExportBattlegroundScores()
end

function ESODatabaseExport.ExportTrialScores()

	for _, raidCategory in pairs(ESODBExportConst.TrialTypes) do

		local numRaids, hasWeekly = GetNumRaidLeaderboards(raidCategory)

		if hasWeekly == true then

			local _, raidId = GetRaidOfTheWeekLeaderboardInfo(raidCategory)

			ESODBExportUtils:SetTableIndexByFieldValue(svAccount.TrialLeaderboards.Weekly, "RaidUniqueId", raidCategory .. "-" .. raidId, {
				RaidUniqueId = raidCategory .. "-" .. raidId,
				RaidId = raidId,
				RaidCategory = raidCategory,
				Scores = {}
			})
		end

		if numRaids > 0 then

			local position = 0
			local lastRank = 0

			for raidIndex = 1, numRaids do

				local _, raidId = GetRaidLeaderboardInfo(raidCategory, raidIndex)
				local numEntries = GetNumTrialLeaderboardEntries(raidIndex)

				position = 0
				lastRank = 0

				if numEntries > 0 then

					local raidTableIndex = ESODBExportUtils:SetTableIndexByFieldValue(svAccount.TrialLeaderboards.Trials, "RaidUniqueId", raidCategory .. "-" .. raidId, {
						RaidUniqueId = raidCategory .. "-" .. raidId,
						RaidId = raidId,
						RaidCategory = raidCategory,
						Scores = {}
					})

					local j = 0
					for i = 1, numEntries, 1 do

						local ranking, charName, score, rowClassId, allianceId, displayName = GetTrialLeaderboardEntryInfo(raidIndex, i)
						if ranking > 0 then

							if ranking ~= position then
								lastRank = lastRank + 1
								position = ranking
							end

							svAccount.TrialLeaderboards.Trials[raidTableIndex].Scores[j] = {
								Rank = lastRank,
								CharName = charName,
								Score = score,
								ClassId = rowClassId,
								AllianceId = allianceId,
								UserId = displayName
							}

							j = j + 1
						end
					end
				end
			end
		end
	end
end

function ESODatabaseExport.ExportWeeklyTrialScores()

	local _, trialRaidId = GetRaidOfTheWeekLeaderboardInfo(RAID_CATEGORY_TRIAL)
	local numTrialEntries = GetNumTrialOfTheWeekLeaderboardEntries()

	if numTrialEntries > 0 then

		local raidTableIndex = ESODBExportUtils:SetTableIndexByFieldValue(svAccount.TrialLeaderboards.Weekly, "RaidUniqueId", RAID_CATEGORY_TRIAL .. "-" .. trialRaidId, {
			RaidUniqueId = RAID_CATEGORY_TRIAL .. "-" .. trialRaidId,
			RaidId = trialRaidId,
			RaidCategory = RAID_CATEGORY_TRIAL,
			Scores = {}
		})

		svAccount.TrialLeaderboards.Weekly[raidTableIndex].Scores = {}

		local j = 0
		local position = 0
		local lastRank = 0

		for i = 1, numTrialEntries, 1 do

			local ranking, charName, score, rowClassId, allianceId, displayName = GetTrialOfTheWeekLeaderboardEntryInfo(i)

			if ranking ~= position then
				position = ranking
				lastRank = lastRank + 1
			end

			svAccount.TrialLeaderboards.Weekly[raidTableIndex].Scores[j] = {
				Rank = lastRank,
				CharName = charName,
				Score = score,
				ClassId = rowClassId,
				AllianceId = allianceId,
				UserId = displayName
			}

			j = j + 1
		end
	end

	local _, classRaidId = GetRaidOfTheWeekLeaderboardInfo(RAID_CATEGORY_CHALLENGE)
	local numClasses = GetNumClasses()

	if numClasses > 0 then

		local raidTableIndex = ESODBExportUtils:SetTableIndexByFieldValue(svAccount.TrialLeaderboards.Weekly, "RaidUniqueId", RAID_CATEGORY_CHALLENGE .. "-" .. classRaidId, {
			RaidUniqueId = RAID_CATEGORY_CHALLENGE .. "-" .. classRaidId,
			RaidId = classRaidId,
			RaidCategory = RAID_CATEGORY_CHALLENGE,
			Scores = {}
		})

		svAccount.TrialLeaderboards.Weekly[raidTableIndex].Scores = {}

		local j = 0

		for classIndex = 1, numClasses do

			local classId = GetClassInfo(classIndex)
			local numClassEntries = GetNumChallengeOfTheWeekLeaderboardEntries(classId)

			if numClassEntries > 0 then

				local position = 0
				local lastRank = 0

				for i = 1, numClassEntries, 1 do

					local ranking, charName, score, rowClassId, allianceId, displayName = GetChallengeOfTheWeekLeaderboardEntryInfo(classId, i)

					if ranking ~= position then
						position = ranking
						lastRank = lastRank + 1
					end

					svAccount.TrialLeaderboards.Weekly[raidTableIndex].Scores[j] = {
						Rank = lastRank,
						CharName = charName,
						Score = score,
						ClassId = rowClassId,
						AllianceId = allianceId,
						UserId = displayName
					}

					j = j + 1
				end
			end
		end
	end
end

function ESODatabaseExport.ExportBattlegroundScores()

	local position = 0
	local lastRank = 0

	for _, battlegroundType in pairs(ESODBExportConst.BattlegroundTypes) do

		local numEntries = GetNumBattlegroundLeaderboardEntries(battlegroundType)

		position = 0
		lastRank = 0

		if numEntries > 0 then

			local battlegroundTableIndex = ESODBExportUtils:SetTableIndexByFieldValue(svAccount.BattlegroundLeaderboards.Battlegrounds, "BattlegroundId", battlegroundType, {
				BattlegroundId = battlegroundType,
				Scores = {}
			})

			local j = 0
			for i = 1, numEntries, 1 do

				local ranking, displayName, charName, score = GetBattlegroundLeaderboardEntryInfo(battlegroundType, i)
				if ranking > 0 then

					if ranking ~= position then
						lastRank = lastRank + 1
						position = ranking
					end

					svAccount.BattlegroundLeaderboards.Battlegrounds[battlegroundTableIndex].Scores[j] = {
						Rank = lastRank,
						CharName = charName,
						Score = score,
						UserId = displayName
					}

					j = j + 1
				end
			end
		end
	end
end


----
--- Event Functions
----
function ESODatabaseExport.EventDisableLootTracking()
	ESODatabaseExport.GlobalStore.DisableLootTracking = true
end

function ESODatabaseExport.EventEnableLootTracking()
	ESODatabaseExport.GlobalStore.DisableLootTracking = false
end

function ESODatabaseExport.EventMoneyUpdate(_, newMoney, oldMoney, reason)

    local moneyEarned = newMoney - oldMoney
    local moneyValue = 0
    local moneyValueEarned = 0
    local moneyValuePaid = 0
    local moneyKey = ""

    -- Money looted from enemies, chests
    if reason == CURRENCY_CHANGE_REASON_LOOT then
        moneyKey = "EarnedLoot"
        moneyValue = moneyEarned
        moneyValueEarned = moneyEarned

        if moneyValue > ssv.Gold.HighestAmountLootedGold then
            ssv.Gold.HighestAmountLootedGold = moneyValue
        end

    -- Money gained from item sale to merchant
    -- Money lost from item purchase from merchant
    elseif reason == CURRENCY_CHANGE_REASON_VENDOR then

        if moneyEarned < 0 then
            moneyKey = "PaidMerchant"
            moneyValue = (moneyEarned * -1)
            moneyValuePaid = moneyValue

            if moneyValue > ssv.Gold.MostExpensivePurchaseMerchant then
                ssv.Gold.MostExpensivePurchaseMerchant = moneyValue
            end
        else
            moneyKey = "EarnedMerchant"
            moneyValue = moneyEarned
            moneyValueEarned = moneyEarned

            if moneyValue > ssv.Gold.BestSellMerchant then
                ssv.Gold.BestSellMerchant = moneyValue
            end
        end

    -- Money received from quest reward
    elseif reason == CURRENCY_CHANGE_REASON_QUESTREWARD then
        moneyKey = "EarnedQuest"
        moneyValue = moneyEarned
        moneyValueEarned = moneyEarned

    -- Money received from antiquity reward
    elseif reason == CURRENCY_CHANGE_REASON_ANTIQUITY_REWARD then
        moneyKey = "EarnedAntiquityReward"
        moneyValue = moneyEarned
        moneyValueEarned = moneyEarned

    -- Money paid to npc during quest conversation
    elseif reason == CURRENCY_CHANGE_REASON_CONVERSATION then
        moneyKey = "PaidQuestConversation"
        moneyValue = (moneyEarned * -1)
        moneyValuePaid = moneyValue

    -- Money paid to upgrade backpack
    elseif reason == CURRENCY_CHANGE_REASON_BAGSPACE then
        moneyKey = "PaidUpgradeBackpack"
        moneyValue = (moneyEarned * -1)
        moneyValuePaid = moneyValue

    -- Money paid for Wayshrine travel
    elseif reason == CURRENCY_CHANGE_REASON_TRAVEL_GRAVEYARD then
        moneyKey = "PaidWayshrineTravel"
        moneyValue = (moneyEarned * -1)
        moneyValuePaid = moneyValue

        -- The Fast travel event is not fired for payed fast travels
        ssv.FastTravel = ssv.FastTravel + 1

    -- Money paid for mount feed
    elseif reason == CURRENCY_CHANGE_REASON_FEED_MOUNT then
        moneyKey = "PaidMountFeed"
        moneyValue = (moneyEarned * -1)
        moneyValuePaid = moneyValue

    -- Money paid for item repair
    elseif reason == CURRENCY_CHANGE_REASON_VENDOR_REPAIR then
        moneyKey = "PaidRepair"
        moneyValue = (moneyEarned * -1)
        moneyValuePaid = moneyValue

        if moneyValue > ssv.Gold.MostExpensiveRepair then
            ssv.Gold.MostExpensiveRepair = moneyValue
        end

    -- Money paid at guild store to buy an item
    elseif reason == CURRENCY_CHANGE_REASON_TRADINGHOUSE_PURCHASE then
        moneyKey = "PaidStore"
        moneyValue = (moneyEarned * -1)
        moneyValuePaid = moneyValue

        ssv.Trading.NumGuildStoreBuys = ssv.Trading.NumGuildStoreBuys + 1

        if moneyValue > ssv.Gold.MostExpensivePurchaseGuildStore then
            ssv.Gold.MostExpensivePurchaseGuildStore = moneyValue
        end

    -- Money paid for respec attributes
    elseif reason == CURRENCY_CHANGE_REASON_RESPEC_ATTRIBUTES then
        moneyKey = "PaidRespecAttributes"
        moneyValue = (moneyEarned * -1)
        moneyValuePaid = moneyValue

    -- Money paid for respec morphs
    elseif reason == CURRENCY_CHANGE_REASON_RESPEC_MORPHS then
        moneyKey = "PaidRespecMorphs"
        moneyValue = (moneyEarned * -1)
        moneyValuePaid = moneyValue

    -- Money paid for respec skills
    elseif reason == CURRENCY_CHANGE_REASON_RESPEC_SKILLS then
        moneyKey = "PaidRespecSkills"
        moneyValue = (moneyEarned * -1)
        moneyValuePaid = moneyValue

    -- Money paid for adding items to tradehouse
    elseif reason == CURRENCY_CHANGE_REASON_TRADINGHOUSE_LISTING then
        moneyKey = "PaidStoreSell"
        moneyValue = (moneyEarned * -1)
        moneyValuePaid = moneyValue

    -- Stolen gold
    elseif reason == CURRENCY_CHANGE_REASON_LOOT_STOLEN then

        if moneyEarned > 0 then
            moneyValueEarned = moneyEarned
            ssv.Justice.PickpocketGold = ssv.Justice.PickpocketGold + moneyEarned

            if moneyEarned > ssv.Gold.HighestAmountPickpocketGold then
                ssv.Gold.HighestAmountPickpocketGold = moneyEarned
            end
        end

    -- Money received from fence
    elseif reason == CURRENCY_CHANGE_REASON_SELL_STOLEN then
        moneyKey = "EarnedFence"
        moneyValue = moneyEarned
        moneyValueEarned = moneyEarned

        if moneyValue > ssv.Gold.BestSellFence then
            ssv.Gold.BestSellFence = moneyValue
        end

    -- Money paid for launder items
    elseif reason == CURRENCY_CHANGE_REASON_VENDOR_LAUNDER then
        moneyKey = "PaidLaunder"
        moneyValue = (moneyEarned * -1)
        moneyValuePaid = moneyValue

        if moneyValue > ssv.Gold.MostExpensiveLaunder then
            ssv.Gold.MostExpensiveLaunder = moneyValue
        end
    end

    -- Set category gold amount
    if moneyKey ~= "" and moneyValue >= 0 then
        ssv.Gold[moneyKey] = ssv.Gold[moneyKey] + moneyValue
    end

    -- Increase total earned money
    if moneyValueEarned > 0 then
        ssv.Gold.EarnedTotal = ssv.Gold.EarnedTotal + moneyValueEarned
    end

    -- Increase total paid money
    if moneyValuePaid > 0 then
        ssv.Gold.PaidTotal = ssv.Gold.PaidTotal + moneyValuePaid
    end

	ESODatabaseExport.ExportGold()
end

function ESODatabaseExport.EventTelVarStoneUpdate(_, newTelVarStones, oldTelVarStones, reason)

	local telVarStonesEarned = newTelVarStones - oldTelVarStones
	local telVarStonesValue = 0
	local telVarStonesValueEarned = 0
	local telVarStonesValueLost = 0
	local telVarStonesKey = ""

	-- Tel'Var stones from NPC
	if reason == CURRENCY_CHANGE_REASON_LOOT then
		telVarStonesKey = "EarnedNPC"
		telVarStonesValue = telVarStonesEarned
		telVarStonesValueEarned = telVarStonesEarned

		if telVarStonesValueEarned > ssv.TelVarStones.MostEarnedNPC then
			ssv.TelVarStones.MostEarnedNPC = telVarStonesValueEarned
		end

	-- Lost player death/eraned player kill
	elseif reason == CURRENCY_CHANGE_REASON_PVP_KILL_TRANSFER then

		-- Player death
		if telVarStonesEarned < 0 then
			telVarStonesKey = "LostPlayer"
			telVarStonesValue = (telVarStonesEarned * -1)
			telVarStonesValueLost = telVarStonesValue

			if telVarStonesValueLost > ssv.TelVarStones.MostLostPlayer then
				ssv.TelVarStones.MostLostPlayer = telVarStonesValueLost
			end
		else
			telVarStonesKey = "EarnedPlayer"
			telVarStonesValue = telVarStonesEarned
			telVarStonesValueLost = telVarStonesValue

			if telVarStonesValueEarned > ssv.TelVarStones.MostEarnedPlayer then
				ssv.TelVarStones.MostEarnedPlayer = telVarStonesValueEarned
			end
		end

	-- Lost death
	elseif reason == CURRENCY_CHANGE_REASON_DEATH then

		telVarStonesKey = "LostDeath"
		telVarStonesValue = (telVarStonesEarned * -1)
		telVarStonesValueLost = telVarStonesValue

		if telVarStonesValueLost > ssv.TelVarStones.MostLostDeath then
			ssv.TelVarStones.MostLostDeath = telVarStonesValueLost
		end

	-- Lost vendor
	elseif reason == CURRENCY_CHANGE_REASON_VENDOR then
		telVarStonesKey = "LostVendor"
		telVarStonesValue = (telVarStonesEarned * -1)
		telVarStonesValueLost = telVarStonesValue

		if telVarStonesValueLost > ssv.TelVarStones.MostExpensivePurchase then
			ssv.TelVarStones.MostExpensivePurchase = telVarStonesValueLost
		end
	end

	-- Set category tel var stones
	if telVarStonesKey ~= "" and telVarStonesValue >= 0 then
		ssv.TelVarStones[telVarStonesKey] = ssv.TelVarStones[telVarStonesKey] + telVarStonesValue
	end

	-- Increase total earned tel var stones
	if telVarStonesValueEarned > 0 then
		ssv.TelVarStones.EarnedTotal = ssv.TelVarStones.EarnedTotal + telVarStonesValueEarned
	end

	-- Increase total lost tel var stones
	if telVarStonesValueLost > 0 then
		ssv.TelVarStones.LostTotal = ssv.TelVarStones.LostTotal + telVarStonesValueLost
	end

	ESODatabaseExport.ExportTelVarStones()
end

function ESODatabaseExport.EventLootRecived(_, _, itemLink, quantity, _, _, self, isPickpocketLoot, _, _, isStolen)

	-- Track only own items
	if not self then
		return
	end

	-- No item logging when bank, shop, merchant... window is open
	if ESODatabaseExport.GlobalStore.DisableLootTracking == true then
		return
	end

	local indexName = ""
	local qualityIndex = ""
	local itemType = GetItemLinkItemType(itemLink)
	local quality = GetItemLinkDisplayQuality(itemLink)

	if quality == ITEM_DISPLAY_QUALITY_TRASH then
		qualityIndex = "Trash"
	elseif quality == ITEM_DISPLAY_QUALITY_NORMAL then
		qualityIndex = "Normal"
	elseif quality == ITEM_DISPLAY_QUALITY_MAGIC then
		qualityIndex = "Magic"
	elseif quality == ITEM_DISPLAY_QUALITY_ARCANE then
		qualityIndex = "Arcane"
	elseif quality == ITEM_DISPLAY_QUALITY_ARTIFACT then
		qualityIndex = "Artifact"
	elseif quality == ITEM_DISPLAY_QUALITY_LEGENDARY then
		qualityIndex = "Legendary"
	end

	if qualityIndex ~= "" then
		ssv.LootQuality[qualityIndex] = ssv.LootQuality[qualityIndex] + quantity
	end

	if itemType == ITEMTYPE_ARMOR then
		indexName = "Armors"
	elseif itemType == ITEMTYPE_WEAPON then
		indexName = "Weapons"
	elseif itemType == ITEMTYPE_BLACKSMITHING_RAW_MATERIAL then
		indexName = "BlacksmithingMats"
	elseif itemType == ITEMTYPE_CLOTHIER_RAW_MATERIAL then
		indexName = "ClothierMats"
	elseif itemType == ITEMTYPE_WOODWORKING_RAW_MATERIAL then
		indexName = "WoodworkingMats"
	elseif itemType == ITEMTYPE_ENCHANTING_RUNE_ASPECT or itemType == ITEMTYPE_ENCHANTING_RUNE_ESSENCE or itemType == ITEMTYPE_ENCHANTING_RUNE_POTENCY then
		indexName = "EnchantingRunes"
	elseif itemType == ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL then
		indexName = "JewelryCraftingMats"
	elseif itemType == ITEMTYPE_STYLE_MATERIAL then
		indexName = "StyleMaterial"
	elseif itemType == ITEMTYPE_DRINK then
		indexName = "Drinks"
	elseif itemType == ITEMTYPE_FOOD then
		indexName = "Foods"
	elseif itemType == ITEMTYPE_SOUL_GEM then
		indexName = "SoulGems"
	elseif itemType == ITEMTYPE_RECIPE then
		indexName = "Recipes"
	elseif itemType == ITEMTYPE_LOCKPICK or itemType == ITEMTYPE_TOOL then
		indexName = "Lockpicks"
	elseif itemType == ITEMTYPE_INGREDIENT then
		indexName = "Ingredients"
	elseif itemType == ITEMTYPE_REAGENT then
		indexName = "Reagents"
	elseif itemType == ITEMTYPE_POTION then
		indexName = "Potions"
	elseif itemType == ITEMTYPE_TROPHY then
		indexName = "Trophies"
	elseif IsAlchemySolvent(itemType) == true then
		indexName = "AlchemyBase"
	elseif itemType == ITEMTYPE_GLYPH_ARMOR or itemType == ITEMTYPE_GLYPH_JEWELRY  or itemType == ITEMTYPE_GLYPH_WEAPON then
		indexName = "Glyphs"
	elseif itemType == ITEMTYPE_TRASH then
		indexName = "Trash"
	elseif itemType == ITEMTYPE_LURE then
		indexName = "Lure"
	elseif itemType == ITEMTYPE_FISH then
		indexName = "Fishing"
	elseif itemType == ITEMTYPE_COLLECTIBLE then
		indexName = "Collectible"
	end

	if indexName ~= "" then
		ssv.Loot[indexName] = ssv.Loot[indexName] + quantity
	end

	if isPickpocketLoot == true or isStolen == true then
		ssv.Justice.PickpocketItems = ssv.Justice.PickpocketItems + quantity
		ssv.Justice["LootQuality" .. qualityIndex] = ssv.Justice["LootQuality" .. qualityIndex] + quantity
	end
end

function ESODatabaseExport.EventUnitDeathStateChanged(_, unitTag, isDead)

	if unitTag == "player" and isDead == true and not IsPlayerInAvAWorld() then
		ssv.Combat.Dead = ssv.Combat.Dead + 1
	elseif unitTag == "player" and not isDead then
		ssv.Combat.Alive = ssv.Combat.Alive + 1
	end
end

function ESODatabaseExport.EventPlayerDead()
	if IsPlayerInAvAWorld() then
		ssv.Kills.AvADeads = ssv.Kills.AvADeads + 1
	end
end

function ESODatabaseExport.EventBeginLockpick()
	ESODatabaseExport.GlobalStore.CurrentLockPickDifficulty = GetLockQuality()
	ssv.Lockpicking.Total = ssv.Lockpicking.Total + 1
end

function ESODatabaseExport.TrackLockpicking(lockpickEventType)

	local difficultIndex = ESODBExportUtils:GetLockpickingDifficultyIndex(ESODatabaseExport.GlobalStore.CurrentLockPickDifficulty)
	if type(difficultIndex) ~= "nil" then
		ssv.Lockpicking[difficultIndex] = ssv.Lockpicking[difficultIndex] + 1
	end

	ssv.Lockpicking[lockpickEventType] = ssv.Lockpicking[lockpickEventType] + 1
end

function ESODatabaseExport.EventLockpickSuccess()
	ESODatabaseExport.TrackLockpicking("Success")
end

function ESODatabaseExport.EventLockpickFailed()
	ESODatabaseExport.TrackLockpicking("Fail")
end

function ESODatabaseExport.EventLockpickBroke()
	ssv.Lockpicking.Broke = ssv.Lockpicking.Broke + 1
end

function ESODatabaseExport.EventCombatEvent(_, result, _, abilityName, _, _, sourceName, sourceType, targetName, targetType, hitValue, _, damageType, _, _, _, _, overflow)

	--
	-- Track slaughterfish deads
	--
    if result == ACTION_RESULT_KILLING_BLOW and targetType == COMBAT_UNIT_TYPE_PLAYER then
		if ESODBExportUtils:GetSlaughterfishAttackStatus(abilityName) then
			ssv.Combat.DeathsSlaughterfish = ssv.Combat.DeathsSlaughterfish + 1
		end
    end

	--
	-- Track kill stats
	--
	if (sourceType == COMBAT_UNIT_TYPE_PLAYER or sourceType == COMBAT_UNIT_TYPE_PLAYER_PET or sourceType == COMBAT_UNIT_TYPE_GROUP) and (targetType == COMBAT_UNIT_TYPE_NONE or targetType == COMBAT_UNIT_TYPE_OTHER) then

		-- Tracking NPC and player kills
		if result == ACTION_RESULT_KILLING_BLOW and (sourceType == COMBAT_UNIT_TYPE_PLAYER or sourceType == COMBAT_UNIT_TYPE_PLAYER_PET) then
			ssv.Kills.AvAKills = ssv.Kills.AvAKills + 1
		elseif result == ACTION_RESULT_DIED or result == ACTION_RESULT_DIED_XP then

			local specialNPCKey = ESODBExportNPC:GetSpecialNPCKey(targetName)
			if type(specialNPCKey) ~= "nil" then
				ssv.Kills[specialNPCKey] = ssv.Kills[specialNPCKey] + 1
			end

			ssv.Kills.Kills = ssv.Kills.Kills + 1
		end
	end

	--
	-- Track damage and heal stats
	--
	if hitValue > 0 and (sourceType ~= COMBAT_UNIT_TYPE_NONE or targetType ~= COMBAT_UNIT_TYPE_NONE) then

		-- Heal event
		if ESODBExportUtils:GetCombatIsHeal(result) == true then

			-- Heal in
			if targetType == COMBAT_UNIT_TYPE_PLAYER or targetType == COMBAT_UNIT_TYPE_PLAYER_PET then
				ssv.Combat.HealIn = ssv.Combat.HealIn + hitValue

				if overflow > 0 then
					ssv.Combat.HealInOverflow = ssv.Combat.HealInOverflow + overflow
				end
			end

			-- Heal out
			if sourceType == COMBAT_UNIT_TYPE_PLAYER or sourceType == COMBAT_UNIT_TYPE_OTHER or sourceType == COMBAT_UNIT_TYPE_OTHER then
				ssv.Combat.HealOut = ssv.Combat.HealOut + hitValue

				if overflow > 0 then
					ssv.Combat.HealOutOverflow = ssv.Combat.HealOutOverflow + overflow
				end
			end

		-- Damage event
		elseif ESODBExportUtils:GetCombatIsDamage(result) == true then

			-- Damage out event
			if damageType > 0 and (targetType == COMBAT_UNIT_TYPE_NONE or targetType == COMBAT_UNIT_TYPE_OTHER or targetType == COMBAT_UNIT_TYPE_TARGET_DUMMY) and (sourceType == COMBAT_UNIT_TYPE_PLAYER or sourceType == COMBAT_UNIT_TYPE_PLAYER_PET) then

				if targetType == COMBAT_UNIT_TYPE_TARGET_DUMMY then
					ssv.Combat.DummyDmgOut = ssv.Combat.DummyDmgOut + hitValue
				else
					ssv.Combat.DmgOut = ssv.Combat.DmgOut + hitValue
				end

			-- Damage in event
			elseif sourceName ~= "" and damageType > 0 and (targetType == COMBAT_UNIT_TYPE_PLAYER or targetType == COMBAT_UNIT_TYPE_PLAYER_PET) and sourceType ~= COMBAT_UNIT_TYPE_PLAYER then
				ssv.Combat.DmgIn = ssv.Combat.DmgIn + hitValue
			end
		end
	end
end

function ESODatabaseExport.EventFastTravel()
	ssv.FastTravel = ssv.FastTravel + 1
end

function ESODatabaseExport.EventQuestAdded()
	ssv.Quest.Add = ssv.Quest.Add + 1
end

function ESODatabaseExport.EventQuestCompleteDialog(_, journalIndex)
	ESODatabaseExport.GlobalStore.LastCompleteQuestRepeatType = GetJournalQuestRepeatType(journalIndex)
end

function ESODatabaseExport.EventQuestRemoved(_, isCompleted, _, questName, _, _, questID)

	if isCompleted then

		local writType = ESODBExportUtils:GetWritType(questName)
		if writType ~= CRAFTING_WRIT_NONE then

			local indexName = ""
			if writType == ESODBExportConst.TradeskillWrits.CRAFTING_WRIT_ALCHEMIST then
				indexName = "AlchemistWritsCompleted"
			elseif writType == ESODBExportConst.TradeskillWrits.CRAFTING_WRIT_BLACKSMITH then
				indexName = "BlacksmithWritsCompleted"
			elseif writType == ESODBExportConst.TradeskillWrits.CRAFTING_WRIT_CLOTHIER then
				indexName = "ClothierWritsCompleted"
			elseif writType == ESODBExportConst.TradeskillWrits.CRAFTING_WRIT_ENCHANTER then
				indexName = "EnchanterWritsCompleted"
			elseif writType == ESODBExportConst.TradeskillWrits.CRAFTING_WRIT_PROVISIONER then
				indexName = "ProvisionerWritsCompleted"
			elseif writType == ESODBExportConst.TradeskillWrits.CRAFTING_WRIT_WOODWORKER then
				indexName = "WoodworkerWritsCompleted"
			elseif writType == ESODBExportConst.TradeskillWrits.CRAFTING_WRIT_JEWELRYCRAFTING then
				indexName = "JewelryCraftingWritsCompleted"
			end

			if indexName ~= "" then
				ssv.Crafting[indexName] = ssv.Crafting[indexName] + 1
			end
		end

		if ESODatabaseExport.GlobalStore.LastCompleteQuestRepeatType ~= QUEST_REPEAT_NOT_REPEATABLE and ESODatabaseExport.GlobalStore.LastCompleteQuestRepeatType ~= QUEST_REPEAT_EVENT_RESET then
			ssv.Quest.Repeatable = ssv.Quest.Repeatable + 1
		end

		ssv.Quest.Complete = ssv.Quest.Complete + 1

		ESODatabaseExport.ExportQuestById(questID)
	else
		ssv.Quest.Remove = ssv.Quest.Remove + 1
	end

	ESODatabaseExport.GlobalStore.LastCompleteQuestRepeatType = ""
end

function ESODatabaseExport.EventCraftCompleted(_, craftSkill)

	local keyName = ""

	if craftSkill == CRAFTING_TYPE_BLACKSMITHING then
		keyName = "Blacksmithing"
	elseif craftSkill == CRAFTING_TYPE_CLOTHIER then
		keyName = "Clothier"
	elseif craftSkill == CRAFTING_TYPE_ENCHANTING then
		keyName = "Enchanting"
		ESODatabaseExport.ExportEnchantingRuneTraits()
	elseif craftSkill == CRAFTING_TYPE_ALCHEMY then
		keyName = "Alchemy"
	elseif craftSkill == CRAFTING_TYPE_PROVISIONING then
		keyName = "Provisioning"
	elseif craftSkill == CRAFTING_TYPE_WOODWORKING then
		keyName = "Woodworking"
	elseif craftSkill == CRAFTING_TYPE_JEWELRYCRAFTING then
		keyName = "Jewelrycrafting"
	end

	if keyName ~= "" then
		ssv.Crafting[keyName] = ssv.Crafting[keyName] + 1
	end
end

function ESODatabaseExport.EventGroupInviteResponse(_, _, response)

	if response == GROUP_INVITE_RESPONSE_ACCEPTED then
		ssv.GroupInvitesAccepted = ssv.GroupInvitesAccepted + 1
	end
end

function ESODatabaseExport.EventGuildSelfJoinedGuild()
	ssv.GuildJoin = ssv.GuildJoin + 1
	ESODatabaseExport.ExportGuilds()
end

function ESODatabaseExport.EventGuildSelfLeftGuild()
	ssv.GuildLeave = ssv.GuildLeave + 1
	ESODatabaseExport.ExportGuilds()
end

function ESODatabaseExport.EventShowBook()
	ssv.BooksOpened = ssv.BooksOpened + 1
end

function ESODatabaseExport.EventBankedMoneyUpdate()

	local characterGold = GetCarriedCurrencyAmount(CURT_MONEY)
	local bankGold = GetBankedCurrencyAmount(CURT_MONEY)

	ssv.Gold.Total = characterGold + bankGold
	ssv.Gold.Character = characterGold
	ssv.Gold.Bank = bankGold
end

function ESODatabaseExport.EventBankedTelVarStonesUpdate()

	local characterTelVarStones = GetCarriedCurrencyAmount(CURT_TELVAR_STONES)
	local bankTelVarStones = GetBankedCurrencyAmount(CURT_TELVAR_STONES)

	ssv.TelVarStones.Total = characterTelVarStones + bankTelVarStones
	ssv.TelVarStones.Character = characterTelVarStones
	ssv.TelVarStones.Bank = bankTelVarStones

	if characterTelVarStones > ssv.TelVarStones.HighestAmountOnCharacter then
		ssv.TelVarStones.HighestAmountOnCharacter = characterTelVarStones
	end
end

function ESODatabaseExport.EventExperienceUpdate(_, reason, _, previousExperience, currentExperience)

	local diff = (currentExperience - previousExperience)

	ssv.Points.ExperiencePoints = ssv.Points.ExperiencePoints + diff

	local reasonIndex = ""

	if reason == PROGRESS_REASON_KILL then
		reasonIndex = "Kill"
	elseif reason == PROGRESS_REASON_QUEST then
		reasonIndex = "Quest"
	elseif reason == PROGRESS_REASON_KEEP_REWARD then
		reasonIndex = "Keep"
	elseif reason == PROGRESS_REASON_SCRIPTED_EVENT then
		reasonIndex = "ScriptedEvent"

		-- Track completed world events
		local poiEventType = ESODBExportUtils:GetPoiEventType()
		if poiEventType == ESODBExportConst.POIEventType.DARK_ANCHOR then
			ssv.WorldEvents.DarkAnchor = ssv.WorldEvents.DarkAnchor + 1
		elseif poiEventType == ESODBExportConst.POIEventType.ABYSSAL_GEYSERS then
			ssv.WorldEvents.AbyssalGeyser = ssv.WorldEvents.AbyssalGeyser + 1
		elseif poiEventType == ESODBExportConst.POIEventType.HARROWSTORM then
			ssv.WorldEvents.Harrowstorm = ssv.WorldEvents.Harrowstorm + 1
		end

	elseif reason == PROGRESS_REASON_LOCK_PICK then
		reasonIndex = "LockPick"
	elseif reason == PROGRESS_REASON_DISCOVER_POI then
		reasonIndex = "POIDiscovered"
	elseif reason == PROGRESS_REASON_COMPLETE_POI then
		reasonIndex = "POICompleted"
	elseif reason == PROGRESS_REASON_OVERLAND_BOSS_KILL then
		reasonIndex = "OverlandBossKill"
	end

	if reasonIndex ~= "" then
		ssv.ExperiencePointsSource[reasonIndex] = ssv.ExperiencePointsSource[reasonIndex] + diff
	end
end

function ESODatabaseExport.EventChampionPointGained()
	sv.Level.ChampionPoints = GetPlayerChampionPointsEarned()
	sv.Level.ChampionXPCurrent = GetPlayerChampionXP()
	sv.Level.ChampionXPMax = GetNumChampionXPInChampionPoint(sv.Level.ChampionPoints)
	sv.Level.ChampionAttribute = GetChampionPointPoolForRank(sv.Level.ChampionPoints + 1)
end

function ESODatabaseExport.EventLevelUpdate()

	sv.AvailableSkillPoints = GetAvailableSkillPoints()

	ESODatabaseExport.ExportLevel()
end

function ESODatabaseExport.EventChampionLevelAchieved()
	ESODatabaseExport.ExportChampionRank()
end

function ESODatabaseExport.EventAlliancePointUpdate(_, _, _, difference)

	if difference > 0 then
		ssv.Points.AlliancePoints = ssv.Points.AlliancePoints + difference
	end

	ESODatabaseExport.ExportAvA()
end

function ESODatabaseExport.EventInventoryItemDestroyed()
	ssv.Loot.Destroyed = ssv.Loot.Destroyed + 1
end

function ESODatabaseExport.EventJusticePickpocketFailed()
	ssv.Justice.PickpocketFailed = ssv.Justice.PickpocketFailed + 1
end

function ESODatabaseExport.EventJusticeBountyPayoffAmountUpdated(_, oldBounty, newBounty)

	if newBounty > oldBounty then
		ssv.Justice.BountyReceived = ssv.Justice.BountyReceived + (newBounty - oldBounty)
	elseif newBounty == 0 and oldBounty ~= 0 then
		ssv.Justice.BountyPaid = ssv.Justice.BountyPaid + oldBounty
	end

	ESODatabaseExport.ExportJusticeInfo()
end

function ESODatabaseExport.EventJusticeStolenItemsRemoved()
	ssv.Justice.NumItemsRemoved = ssv.Justice.NumItemsRemoved + 1
	ESODatabaseExport.ExportJusticeInfo()
end

function ESODatabaseExport.EventJusticeFenceUpdate(_, sellsUsed, laundersUsed)

	local numSells = sellsUsed - ESODatabaseExport.GlobalStore.FenceSellsUsed
	local numLaunders = laundersUsed - ESODatabaseExport.GlobalStore.FenceLaundersUsed

	if numSells > 0 then
		ssv.Justice.FenceSells = ssv.Justice.FenceSells + numSells
	end

	if numLaunders > 0 then
		ssv.Justice.FenceLaunders = ssv.Justice.FenceLaunders + numLaunders
	end

	ESODatabaseExport.GlobalStore.FenceSellsUsed = sellsUsed
	ESODatabaseExport.GlobalStore.FenceLaundersUsed = laundersUsed
end

function ESODatabaseExport.EventMailInboxUpdate()

	ESODatabaseExport.GlobalStore.MailCache.GuildStore = {}
	ESODatabaseExport.GlobalStore.MailCache.WorthyReward = {}

	local numMails = GetNumMailItems()
	if numMails > 0 then

		local mailId = GetNextMailId()
		while mailId ~= nil do

			local _, attachedMoney = GetMailAttachmentInfo(mailId)

			if attachedMoney > 0 then

				local _, _, subject = GetMailItemInfo(mailId)
				local _, returned, fromSystem, fromCustomerService = GetMailFlags(mailId)

				if ESODBExportUtils:IsGuildStoreMail(mailId, returned, fromSystem, fromCustomerService) then
					ESODatabaseExport.GlobalStore.MailCache.GuildStore[mailId] = attachedMoney
				elseif ESODBExportUtils:IsWorthyRewardMail(subject, returned, fromSystem, fromCustomerService) then
					ESODatabaseExport.GlobalStore.MailCache.WorthyReward[mailId] = attachedMoney
				end
			end

			mailId = GetNextMailId(mailId)
		end
	end
end

function ESODatabaseExport.EventMailTakeAttachedMoneySuccess(_, mailId)

	if type(ESODatabaseExport.GlobalStore.MailCache.GuildStore[mailId]) ~= "nil" then
		ssv.Gold.EarnedGuildStore = ssv.Gold.EarnedGuildStore + ESODatabaseExport.GlobalStore.MailCache.GuildStore[mailId]
		ssv.Gold.EarnedTotal = ssv.Gold.EarnedTotal + ESODatabaseExport.GlobalStore.MailCache.GuildStore[mailId]

		ssv.Trading.NumGuildStoreSells = ssv.Trading.NumGuildStoreSells + 1

		if ESODatabaseExport.GlobalStore.MailCache.GuildStore[mailId] > ssv.Gold.BestSellGuildStore then
			ssv.Gold.BestSellGuildStore = ESODatabaseExport.GlobalStore.MailCache.GuildStore[mailId]
		end
	end

	if type(ESODatabaseExport.GlobalStore.MailCache.WorthyReward[mailId]) ~= "nil" then
		ssv.Gold.EarnedWorthyReward = ssv.Gold.EarnedWorthyReward + ESODatabaseExport.GlobalStore.MailCache.WorthyReward[mailId]
		ssv.Gold.EarnedTotal = ssv.Gold.EarnedTotal + ESODatabaseExport.GlobalStore.MailCache.WorthyReward[mailId]
	end
end

function ESODatabaseExport.EventSellReceipt(_, _, itemQuantity)
	ssv.Trading.NumMerchantSells = ssv.Trading.NumMerchantSells + itemQuantity
end

function ESODatabaseExport.EventBuyReceipt(_, _, _, entryQuantity)
	ssv.Trading.NumMerchantBuys = ssv.Trading.NumMerchantBuys + entryQuantity
end

function ESODatabaseExport.EventBuybackReceipt(_, _, itemQuantity, money)

	ssv.Trading.NumMerchantBuybacks = ssv.Trading.NumMerchantBuybacks + itemQuantity
	ssv.Gold.PaidBuyback = ssv.Gold.PaidBuyback + money

	if money > ssv.Gold.MostExpensiveBuyback then
		ssv.Gold.MostExpensiveBuyback = money
	end
end

function ESODatabaseExport.EventDuelFinished(_, duelResult, wasLocalPlayersResult)

	if duelResult == DUEL_RESULT_WON then
		if wasLocalPlayersResult == true then
			ssv.Duels.Won = ssv.Duels.Won + 1
		else
			ssv.Duels.Lost = ssv.Duels.Lost + 1
		end
	end
end

function ESODatabaseExport.EventTraitLearned()
	ESODatabaseExport.ExportAlchemyTraits()
	ESODatabaseExport.ExportEnchantingRuneTraits()
end

function ESODatabaseExport.EventSmithingTraitResearchCompleted(_, craftingSkillType, researchLineIndex, traitIndex)

	local tableIndex = ESODBExportUtils:GetTableIndexByFieldValue(sv.Tradeskills, "Id", craftingSkillType)
	if tableIndex ~= false then
		local lineTableIndex = ESODBExportUtils:GetTableIndexByFieldValue(sv.Tradeskills[tableIndex].Traits, "Id", researchLineIndex)
		if lineTableIndex == false then
			table.insert(sv.Tradeskills[tableIndex].Traits, {
				Id = researchLineIndex,
				List = {},
			})
			lineTableIndex = #sv.Tradeskills[tableIndex].Traits
			sv.Tradeskills[tableIndex].Traits[lineTableIndex].List = {}
		end

		local traitType = GetSmithingResearchLineTraitInfo(craftingSkillType, researchLineIndex, traitIndex)
		local traitTableIndex = ESODBExportUtils:SetTableIndexByFieldValue(sv.Tradeskills[tableIndex].Traits[lineTableIndex].List, "Id", traitType, {
			Id = traitType
		})

		sv.Tradeskills[tableIndex].Traits[lineTableIndex].List[traitTableIndex]["Line"] = researchLineIndex
		sv.Tradeskills[tableIndex].Traits[lineTableIndex].List[traitTableIndex]["Trait"] = traitType
		sv.Tradeskills[tableIndex].Traits[lineTableIndex].List[traitTableIndex]["Known"] = true
	end
end

function ESODatabaseExport.EventSkillRankUpdate(_, skillType)

	if skillType == SKILL_TYPE_TRADESKILL then
		ESODatabaseExport.ExportTradeskills()
	elseif skillType == SKILL_TYPE_AVA then
		ESODatabaseExport.ExportAvA()
	end

	ESODatabaseExport.ExportSkillLines()
end

function ESODatabaseExport.EventGuildRecruitmentInfoUpdated(_, guildId)

	local tableIndex = ESODBExportUtils:SetTableIndexByFieldValue(svAccount.Guilds, "Id", guildID, {
		Id = guildID
	})

	ESODatabaseExport.ExportGuildRecruitment(tableIndex, guildId)
end

function ESODatabaseExport.EventChampionPurchaseResult(_ , result)

	if result == CHAMPION_PURCHASE_SUCCESS then
		ESODatabaseExport.ExportCharacterStats()
	end
end

function ESODatabaseExport.EventTitleUpdate(_, unitTag)

	if unitTag == "player" then
		sv.Title = GetUnitTitle("player")
	end
end

function ESODatabaseExport.EventAchievementAwarded(_, _, _, id)
	sv.AchievementPoints = GetEarnedAchievementPoints()
	ESODatabaseExport.ExportAchievementById(id)
end

function ESODatabaseExport.EventSkillPointsChanged()
	sv.AvailableSkillPoints = GetAvailableSkillPoints()
end

function ESODatabaseExport.EventSkillRespecResult(_, result)

	if result == RESPEC_RESULT_SUCCESS then
		sv.AvailableSkillPoints = GetAvailableSkillPoints()
	end
end

function ESODatabaseExport.EventZoneChanged()
	sv.ZoneId = GetZoneId(GetCurrentMapZoneIndex())
end

function ESODatabaseExport.EventHousingPrimaryResidenceSet()
	ESODatabaseExport.ExportPrimaryHouse()
end


----
--- This function is called every ESODBExport.ScanInterval seconds and on AddOn loaded.
----
function ESODatabaseExport.Export()

	local eventBaseName = ESODatabaseExport.Name .. "Delayed"
	local exportDelay = 0

	exportDelay = exportDelay + ESODatabaseExport.DataExportDelay
	EVENT_MANAGER:UnregisterForUpdate(eventBaseName .. "ExportBaseData")
	EVENT_MANAGER:RegisterForUpdate(eventBaseName .. "ExportBaseData", exportDelay, function()
		ESODatabaseExport.ExportLevel()
		ESODatabaseExport.ExportChampionRank()
		ESODatabaseExport.ExportPrimaryHouse()
		ESODatabaseExport.ExportRidingStats()
		ESODatabaseExport.ExportGold()
		ESODatabaseExport.ExportTelVarStones()
		ESODatabaseExport.ExportAvA()
		ESODatabaseExport.ExportJusticeInfo()
		ESODatabaseExport.ExportCharacterBaseInfo()
		ESODatabaseExport.ExportCharacterStats()
		EVENT_MANAGER:UnregisterForUpdate(eventBaseName .. "ExportBaseData")
	end)
end

----
--- This function is called only once when the AddOn has loaded.
----
function ESODatabaseExport.ExportOnce()

	local eventBaseName = ESODatabaseExport.Name .. "Delayed"
	local exportDelay = ESODatabaseExport.DataExportDelay -- Delay after ESODatabaseExport.Export()

	exportDelay = exportDelay + ESODatabaseExport.DataExportDelay
	EVENT_MANAGER:UnregisterForUpdate(eventBaseName .. "ExportTitles")
	EVENT_MANAGER:RegisterForUpdate(eventBaseName .. "ExportTitles", exportDelay, function()
		ESODatabaseExport.ExportTitles()
		EVENT_MANAGER:UnregisterForUpdate(eventBaseName .. "ExportTitles")
	end)

	exportDelay = exportDelay + ESODatabaseExport.DataExportDelay
	EVENT_MANAGER:UnregisterForUpdate(eventBaseName .. "ExportTradeskills")
	EVENT_MANAGER:RegisterForUpdate(eventBaseName .. "ExportTradeskills", exportDelay, function()
		ESODatabaseExport.ExportTradeskills()
		EVENT_MANAGER:UnregisterForUpdate(eventBaseName .. "ExportTradeskills")
	end)

	exportDelay = exportDelay + ESODatabaseExport.DataExportDelay
	EVENT_MANAGER:UnregisterForUpdate(eventBaseName .. "ExportAlchemyTraits")
	EVENT_MANAGER:RegisterForUpdate(eventBaseName .. "ExportAlchemyTraits", exportDelay, function()
		ESODatabaseExport.ExportAlchemyTraits()
		EVENT_MANAGER:UnregisterForUpdate(eventBaseName .. "ExportAlchemyTraits")
	end)

	exportDelay = exportDelay + ESODatabaseExport.DataExportDelay
	EVENT_MANAGER:UnregisterForUpdate(eventBaseName .. "ExportEnchantingRuneTraits")
	EVENT_MANAGER:RegisterForUpdate(eventBaseName .. "ExportEnchantingRuneTraits", exportDelay, function()
		ESODatabaseExport.ExportEnchantingRuneTraits()
		EVENT_MANAGER:UnregisterForUpdate(eventBaseName .. "ExportEnchantingRuneTraits")
	end)

	exportDelay = exportDelay + ESODatabaseExport.DataExportDelay
	EVENT_MANAGER:UnregisterForUpdate(eventBaseName .. "ExportSkillLines")
	EVENT_MANAGER:RegisterForUpdate(eventBaseName .. "ExportSkillLines", exportDelay, function()
		ESODatabaseExport.ExportSkillLines()
		EVENT_MANAGER:UnregisterForUpdate(eventBaseName .. "ExportSkillLines")
	end)

	exportDelay = exportDelay + ESODatabaseExport.DataExportDelay
	EVENT_MANAGER:UnregisterForUpdate(eventBaseName .. "ExportAchievements")
	EVENT_MANAGER:RegisterForUpdate(eventBaseName .. "ExportAchievements", exportDelay, function()
		ESODatabaseExport.ExportAchievements()
		EVENT_MANAGER:UnregisterForUpdate(eventBaseName .. "ExportAchievements")
	end)

	exportDelay = exportDelay + ESODatabaseExport.DataExportDelay
	EVENT_MANAGER:UnregisterForUpdate(eventBaseName .. "ExportRecipes")
	EVENT_MANAGER:RegisterForUpdate(eventBaseName .. "ExportRecipes", exportDelay, function()
		ESODatabaseExport.ExportRecipes()
		EVENT_MANAGER:UnregisterForUpdate(eventBaseName .. "ExportRecipes")
	end)

	exportDelay = exportDelay + ESODatabaseExport.DataExportDelay
	EVENT_MANAGER:UnregisterForUpdate(eventBaseName .. "ExportCompletedQuests")
	EVENT_MANAGER:RegisterForUpdate(eventBaseName .. "ExportCompletedQuests", exportDelay, function()
		ESODatabaseExport.ExportCompletedQuests()
		EVENT_MANAGER:UnregisterForUpdate(eventBaseName .. "ExportCompletedQuests")
	end)

	exportDelay = exportDelay + ESODatabaseExport.DataExportDelay
	EVENT_MANAGER:UnregisterForUpdate(eventBaseName .. "ExportLoreBooks")
	EVENT_MANAGER:RegisterForUpdate(eventBaseName .. "ExportLoreBooks", exportDelay, function()
		ESODatabaseExport.ExportLoreBooks()
		EVENT_MANAGER:UnregisterForUpdate(eventBaseName .. "ExportLoreBooks")
	end)

	exportDelay = exportDelay + ESODatabaseExport.DataExportDelay
	EVENT_MANAGER:UnregisterForUpdate(eventBaseName .. "ExportCollectibles")
	EVENT_MANAGER:RegisterForUpdate(eventBaseName .. "ExportCollectibles", exportDelay, function()
		ESODatabaseExport.ExportCollectibles()
		EVENT_MANAGER:UnregisterForUpdate(eventBaseName .. "ExportCollectibles")
	end)

	exportDelay = exportDelay + ESODatabaseExport.DataExportDelay
	EVENT_MANAGER:UnregisterForUpdate(eventBaseName .. "ExportAntiquities")
	EVENT_MANAGER:RegisterForUpdate(eventBaseName .. "ExportAntiquities", exportDelay, function()
		ESODatabaseExport.ExportAntiquities()
		EVENT_MANAGER:UnregisterForUpdate(eventBaseName .. "ExportAntiquities")
	end)

	exportDelay = exportDelay + ESODatabaseExport.DataExportDelay
	EVENT_MANAGER:UnregisterForUpdate(eventBaseName .. "ExportItemSetCollections")
	EVENT_MANAGER:RegisterForUpdate(eventBaseName .. "ExportItemSetCollections", exportDelay, function()
		ESODatabaseExport.ExportItemSetCollections()
		EVENT_MANAGER:UnregisterForUpdate(eventBaseName .. "ExportItemSetCollections")
	end)

	exportDelay = exportDelay + ESODatabaseExport.DataExportDelay
	EVENT_MANAGER:UnregisterForUpdate(eventBaseName .. "ExportTimedActivities")
	EVENT_MANAGER:RegisterForUpdate(eventBaseName .. "ExportTimedActivities", exportDelay, function()
		ESODatabaseExport.ExportTimedActivities()
		EVENT_MANAGER:UnregisterForUpdate(eventBaseName .. "ExportTimedActivities")
	end)
end

----
--- This function is called when the user's interface loads and their
--- character is activated after logging in or performing a reload of the UI.
----
function ESODatabaseExport.PlayerActivated()
	ESODBExportUtils.OldAddonDetection()
end

----
--- This function is called when the user's interface loads and their
--- character is activated after logging in or performing a reload of the UI.
---
--- Informs about unsupported client language
----
function ESODatabaseExport.InvalidClientWarning()
	EVENT_MANAGER:UnregisterForEvent(ESODatabaseExport.Name, EVENT_PLAYER_ACTIVATED)
	ESODBExportUtils:PrintMessage(string.format(GetString(ESODB_LANGUAGE_ALERT), ESODatabaseExport.GlobalStore.Lang))
end

----
--- OnAddOnLoaded
----
function ESODatabaseExport.OnAddOnLoaded(_, addonName)

	if addonName ~= ESODatabaseExport.Name then return end

	EVENT_MANAGER:UnregisterForEvent(ESODatabaseExport.Name, EVENT_ADD_ON_LOADED)

	if ESODBExportUtils:IsSupportedLanguage() == false then
		EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_PLAYER_ACTIVATED, ESODatabaseExport.InvalidClientWarning)
		return
	end

    -- Register saved variables
	sv = ZO_SavedVars:NewCharacterIdSettings(ESODatabaseExport.SavedVariablesName , ESODatabaseExport.VariableVersion, nil, ESODatabaseExport.Default)
	svAccount = ZO_SavedVars:NewAccountWide(ESODatabaseExport.SavedVariablesName, ESODatabaseExport.VariableVersion, nil, ESODatabaseExport.AccountWideDefault)

	----
	---  Init
	----
	ESODatabaseExport.GlobalStore.Lang = string.lower(GetCVar("Language.2"))

	ESODatabaseExport.InitSessionStatEntry()
	ESODatabaseExport.ClearUnknownValues()
	ESODatabaseExport.InitStatisticsDefaultValues()
	ESODatabaseExport.ExportMetaData()
	ESODatabaseExport.Export()
	ESODatabaseExport.ExportOnce()
	ESODatabaseExport.ExportGuilds()


	-- Event filters for performance
	EVENT_MANAGER:AddFilterForEvent(ESODatabaseExport.Name, EVENT_COMBAT_EVENT, REGISTER_FILTER_IS_IN_GAMEPAD_PREFERRED_MODE, false)
	EVENT_MANAGER:AddFilterForEvent(ESODatabaseExport.Name, EVENT_COMBAT_EVENT, REGISTER_FILTER_IS_ERROR, false)

	----
	---  Register Events
	----
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_PLAYER_ACTIVATED, ESODatabaseExport.PlayerActivated)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_MONEY_UPDATE, ESODatabaseExport.EventMoneyUpdate)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_TELVAR_STONE_UPDATE, ESODatabaseExport.EventTelVarStoneUpdate)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_LOOT_RECEIVED, ESODatabaseExport.EventLootRecived)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_UNIT_DEATH_STATE_CHANGED, ESODatabaseExport.EventUnitDeathStateChanged)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_PLAYER_DEAD, ESODatabaseExport.EventPlayerDead)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_BEGIN_LOCKPICK, ESODatabaseExport.EventBeginLockpick)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_LOCKPICK_SUCCESS, ESODatabaseExport.EventLockpickSuccess)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_LOCKPICK_FAILED, ESODatabaseExport.EventLockpickFailed)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_LOCKPICK_BROKE, ESODatabaseExport.EventLockpickBroke)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_COMBAT_EVENT, ESODatabaseExport.EventCombatEvent)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_END_FAST_TRAVEL_INTERACTION, ESODatabaseExport.EventFastTravel)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_END_FAST_TRAVEL_KEEP_INTERACTION, ESODatabaseExport.EventFastTravel)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_QUEST_ADDED, ESODatabaseExport.EventQuestAdded)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_QUEST_COMPLETE_DIALOG, ESODatabaseExport.EventQuestCompleteDialog)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_QUEST_REMOVED, ESODatabaseExport.EventQuestRemoved)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_CRAFT_COMPLETED, ESODatabaseExport.EventCraftCompleted)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_GROUP_INVITE_RESPONSE, ESODatabaseExport.EventGroupInviteResponse)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_GUILD_SELF_JOINED_GUILD, ESODatabaseExport.EventGuildSelfJoinedGuild)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_GUILD_SELF_LEFT_GUILD, ESODatabaseExport.EventGuildSelfLeftGuild)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_SHOW_BOOK, ESODatabaseExport.EventShowBook)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_BANKED_MONEY_UPDATE, ESODatabaseExport.EventBankedMoneyUpdate)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_BANKED_TELVAR_STONES_UPDATE, ESODatabaseExport.EventBankedTelVarStonesUpdate)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_EXPERIENCE_GAIN, ESODatabaseExport.EventExperienceUpdate)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_CHAMPION_POINT_GAINED, ESODatabaseExport.EventChampionPointGained)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_LEVEL_UPDATE, ESODatabaseExport.EventLevelUpdate)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_CHAMPION_LEVEL_ACHIEVED, ESODatabaseExport.EventChampionLevelAchieved)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_ALLIANCE_POINT_UPDATE, ESODatabaseExport.EventAlliancePointUpdate)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_INVENTORY_ITEM_DESTROYED, ESODatabaseExport.EventInventoryItemDestroyed)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_TRAIT_LEARNED, ESODatabaseExport.EventTraitLearned)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED, ESODatabaseExport.EventSmithingTraitResearchCompleted)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_SKILL_RANK_UPDATE, ESODatabaseExport.EventSkillRankUpdate)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_GUILD_RECRUITMENT_INFO_UPDATED, ESODatabaseExport.EventGuildRecruitmentInfoUpdated)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_CHAMPION_PURCHASE_RESULT, ESODatabaseExport.EventChampionPurchaseResult)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_TITLE_UPDATE, ESODatabaseExport.EventTitleUpdate)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_ACHIEVEMENT_AWARDED, ESODatabaseExport.EventAchievementAwarded)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_SKILL_POINTS_CHANGED, ESODatabaseExport.EventSkillPointsChanged)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_SKILL_RESPEC_RESULT, ESODatabaseExport.EventSkillRespecResult)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_ZONE_CHANGED, ESODatabaseExport.EventZoneChanged)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_HOUSING_PRIMARY_RESIDENCE_SET, ESODatabaseExport.EventHousingPrimaryResidenceSet)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_RAID_LEADERBOARD_DATA_CHANGED, ESODatabaseExport.ExportTrialLeadeboards)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_BATTLEGROUND_LEADERBOARD_DATA_CHANGED, ESODatabaseExport.ExportBattlegroundLeadeboards)

	-- Justice events
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_JUSTICE_PICKPOCKET_FAILED, ESODatabaseExport.EventJusticePickpocketFailed)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_JUSTICE_BOUNTY_PAYOFF_AMOUNT_UPDATED, ESODatabaseExport.EventJusticeBountyPayoffAmountUpdated)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_JUSTICE_STOLEN_ITEMS_REMOVED, ESODatabaseExport.EventJusticeStolenItemsRemoved)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_JUSTICE_FENCE_UPDATE, ESODatabaseExport.EventJusticeFenceUpdate)

	-- Guildstore events
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_MAIL_INBOX_UPDATE, ESODatabaseExport.EventMailInboxUpdate)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_MAIL_TAKE_ATTACHED_MONEY_SUCCESS, ESODatabaseExport.EventMailTakeAttachedMoneySuccess)

	-- Trading events
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_SELL_RECEIPT, ESODatabaseExport.EventSellReceipt)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_BUY_RECEIPT, ESODatabaseExport.EventBuyReceipt)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_BUYBACK_RECEIPT, ESODatabaseExport.EventBuybackReceipt)

	-- Duel Events
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_DUEL_FINISHED, ESODatabaseExport.EventDuelFinished)

	-- Trigger export functions
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_SMITHING_TRAIT_RESEARCH_STARTED, ESODatabaseExport.ExportTradeskills)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_COLLECTIBLE_NOTIFICATION_NEW, ESODatabaseExport.EventCollectibleNotificationNew)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_RECIPE_LEARNED, ESODatabaseExport.ExportRecipe)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_LORE_BOOK_LEARNED, ESODatabaseExport.ExportLoreBook)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_RIDING_SKILL_IMPROVEMENT, ESODatabaseExport.ExportRidingStats)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_SKILL_LINE_ADDED, ESODatabaseExport.ExportSkillLines)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_LORE_BOOK_LEARNED_SKILL_EXPERIENCE, ESODatabaseExport.ExportSkillLines)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_LORE_COLLECTION_COMPLETED_SKILL_EXPERIENCE, ESODatabaseExport.ExportSkillLines)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_SKILL_XP_UPDATE, ESODatabaseExport.ExportSkillLines)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_PLAYER_TITLES_UPDATE, ESODatabaseExport.ExportTitles)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_JUSTICE_NOW_KOS, ESODatabaseExport.ExportJusticeInfo)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_JUSTICE_NO_LONGER_KOS, ESODatabaseExport.ExportJusticeInfo)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_JUSTICE_INFAMY_UPDATED, ESODatabaseExport.ExportJusticeInfo)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_JUSTICE_GOLD_REMOVED, ESODatabaseExport.ExportJusticeInfo)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_RAID_TRIAL_COMPLETE, ESODatabaseExport.QueryLeaderboardData)

	-- Antiquity events
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_ANTIQUITY_DIGGING_GAME_OVER, ESODatabaseExport.EventAntiquityDiggingGameOver)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_ANTIQUITY_DIGGING_BONUS_LOOT_UNEARTHED, ESODatabaseExport.EventAntiquityDiggingBonusLootUnearthed)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_ANTIQUITY_DIGGING_ANTIQUITY_UNEARTHED, ESODatabaseExport.EventAntiquityDiggingAntiquityUnearthed)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_ANTIQUITY_LEAD_ACQUIRED, ESODatabaseExport.EventAntiquityLeadAcquired)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_COLLECTIBLE_USE_RESULT, ESODatabaseExport.EventCollectibleUseResult)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_REVEAL_ANTIQUITY_DIG_SITES_ON_MAP, ESODatabaseExport.EventAntiquityDigSitesOnMap)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_ANTIQUITY_UPDATED, ESODatabaseExport.EventAntiquityUpdated)

	-- Item Set Collection events
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_ITEM_SET_COLLECTION_UPDATED, ESODatabaseExport.EventItemSetCollectionUpdated)

	-- Timed Activity
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED, ESODatabaseExport.EventTimedActivityProgressUpdated)

	-- Loot tracking disable events
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_OPEN_BANK, ESODatabaseExport.EventDisableLootTracking)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_OPEN_GUILD_BANK, ESODatabaseExport.EventDisableLootTracking)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_MAIL_OPEN_MAILBOX, ESODatabaseExport.EventDisableLootTracking)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_OPEN_TRADING_HOUSE, ESODatabaseExport.EventDisableLootTracking)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_OPEN_STORE, ESODatabaseExport.EventDisableLootTracking)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_CRAFTING_STATION_INTERACT, ESODatabaseExport.EventDisableLootTracking)

	-- Loot tracking enable events
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_CLOSE_BANK, ESODatabaseExport.EventEnableLootTracking)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_CLOSE_GUILD_BANK, ESODatabaseExport.EventEnableLootTracking)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_MAIL_CLOSE_MAILBOX, ESODatabaseExport.EventEnableLootTracking)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_CLOSE_TRADING_HOUSE, ESODatabaseExport.EventEnableLootTracking)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_CLOSE_STORE, ESODatabaseExport.EventEnableLootTracking)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_END_CRAFTING_STATION_INTERACT, ESODatabaseExport.EventEnableLootTracking)


	----
	---  Register update intervalls
	----
	EVENT_MANAGER:RegisterForUpdate(ESODatabaseExport.Name .. "ExportInterval", ESODatabaseExport.ScanInterval, ESODatabaseExport.Export)
	EVENT_MANAGER:RegisterForUpdate(ESODatabaseExport.Name .. "ExportGuildsInterval", ESODatabaseExport.ScanGuildInterval, ESODatabaseExport.ExportGuilds)
	EVENT_MANAGER:RegisterForUpdate(ESODatabaseExport.Name .. "LeaderboardsInterval", ESODatabaseExport.LeaderboardScanInterval, function() ESODatabaseExport.QueryLeaderboardData() ESODatabaseExport.QueryBattlegroundData() end)
	EVENT_MANAGER:RegisterForUpdate(ESODatabaseExport.Name .. "TimedActivitiesInterval", ESODatabaseExport.TimedActivitiesScanInterval, ESODatabaseExport.ExportTimedActivities)
end


----
--- AddOn init
----
EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_ADD_ON_LOADED, ESODatabaseExport.OnAddOnLoaded)
SLASH_COMMANDS["/esodb"] = ESODBExportCommand.Handle
