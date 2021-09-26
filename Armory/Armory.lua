Armory = {
    name = "Armory",
    version = "3.0.4",
    variableVersion = 17,
    author = "@Aaxc",
    account = GetDisplayName(),
    character = GetUnitName("player"),
    total = GetEarnedAchievementPoints(),
    fetchAllData = false,
    Default = {},
    AccountDefault = {},
}

-------------------------------------------------------------------------------------------------
-- Libraries --
-------------------------------------------------------------------------------------------------
local LAM = LibAddonMenu2

Export = {
    name = "Export"
}

-- Export function
function Export:Init()
    Armory.savedVariables = ZO_SavedVars:NewCharacterIdSettings("ArmoryExport", Armory.variableVersion, nil, Armory.Default)
    Armory.accountVariables = ZO_SavedVars:NewAccountWide("ArmoryExport", Armory.variableVersion, nil, Armory.AccountDefault)

    -- Create main user data array
    local characterCount = GetNumCharacters()
    local mainData = {}
    local mainCharacter = {}
    local MxName = Armory.character .. "^Mx"
    local FxName = Armory.character .. "^Fx"

    for c = 1, characterCount do
        local characterInfo = {
            GetCharacterInfo(c)
        }
        if characterInfo[1] == MxName or characterInfo[1] == FxName then
            mainCharacter = {
                GetCharacterInfo(c)
            }
        end
    end

    -- Set general status
    mainData.FullInfo = Armory.fetchAllData

    -- Get raid scores
    mainData.Trials = {}
    mainData.Trials = Armory.getTrialScores()

    -- Get all achievement data, if requested
    mainData.EarnedAchievementPoints = GetEarnedAchievementPoints()
    if Armory.fetchAllData then
        mainData.content = {
            AchievementCategoryCount = GetNumAchievementCategories(),
            AchievementCategories = Armory.getAchievements(true)
        }
    else
        -- Get completed achievements
        mainData.DoneAchievements = Armory.getAchievements(false)
    end

    -- Get Additonal info
    local ISCollected, ISTotal = Armory.getCollectionStatus()

    mainData.misc = {
        Recipes = Armory.getRecipes(),
        ItemSetsCollected = ISCollected,
        ItemSetsTotal = ISTotal,


        -- Stylepages = Armory.getStylepages()
        -- Rubeboxes = Armory.getRunebox()
    }

    Armory.savedVariables.ServerName = GetWorldName()
    Armory.savedVariables.CharacterInfo = mainCharacter
    Armory.savedVariables.ChampionPoints = GetPlayerChampionPointsEarned()
    Armory.savedVariables.TotalAchievementPoints = GetTotalAchievementPoints()
    Armory.savedVariables.ActiveTitle = GetTitle(GetCurrentTitleIndex())
    Armory.savedVariables.MainData = mainData
end

-- Main armory data
function Armory:Initialize()
    Export:Init()
    Armory.inCombat = IsUnitInCombat("player")
end

-- Update on new achievement
function Armory.AchievementChanged(eventCode, name, points, id, link)
    d('Armory: ' .. link)
end

-- Get Set items
function Armory:GetSetItems(itemSetId)
    local setItems = {}
    for i = 1, GetNumItemSetCollectionPieces(itemSetId) do
        local itemId, _ = GetItemSetCollectionPieceInfo(itemSetId, i)
        table.insert(setItems, itemId)
    end

    return setItems
end

-- Then we create an event handler function which will be called when the "addon loaded" event
-- occurs. We'll use this to initialize our addon after all of its resources are fully loaded.
function Armory.OnAddOnLoaded(event, addonName)
    if addonName == Armory.name then
        EVENT_MANAGER:UnregisterForEvent(Armory.name, EVENT_ADD_ON_LOADED)
        Armory:Initialize()
        Armory.CreateSettingsWindow()
    end
end

-- Initialize command request
function commands(extra)
    Armory.fetchAllData = true
    Export:Init()
    d('Armory: Full info fetched. This is only for development purpuses. Generates a large file!')
end

-- Run export on logout
ZO_PreHook("Logout", function()
    Export:Init()
end)

-- Run export on quit
ZO_PreHook("Quit", function()
    Export:Init()
end)

SLASH_COMMANDS["/armoryupdate"] = commands

-------------------------------------------------------------------------------------------------
-- Manage slash commands --
-------------------------------------------------------------------------------------------------
function Armory.CreateSettingsWindow()
    local panelData = {
        type = "panel",
        name = "Armory Export",
        displayName = "Armory Export for www.eso-armory.com",
        author = "|c277ecdAaxc|r",
        version = Armory.version,
        slashCommand = "/armorysettings",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    local cntrlOptionsPanel = LAM:RegisterAddonPanel("Aaxc_Armory", panelData)

    local vericode = Armory.accountVariables.verificationCode
    if (vericode ~= nil and vericode ~= '') then
        vericode = '****************'
    end

    local optionsData = {
        {
            type = "header",
            name = "General",
        },
        {
            type = "editbox",
            name = "Verification code",
            tooltip = "Your www.eso-armory.com verification code",
            getFunc = function() return vericode end,
            setFunc = function(newValue)
                if newValue:find('*', 1, true) then
                    -- ignore, we don't resave the asterixes
                else
                    Armory.accountVariables.verificationCode = newValue
                end
                print('****************')
            end,
            isMultiline = false, --boolean
            width = "--",
            warning = "Will need to reload the UI for data to be saved",
        },
    }
    LAM:RegisterOptionControls("Aaxc_Armory", optionsData)
end

-- Finally, we'll register our event handler function to be called when the proper event occurs.
EVENT_MANAGER:RegisterForEvent("ArmoryLoaded", EVENT_ADD_ON_LOADED, Armory.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent("ArmoryAchievementChanged", EVENT_ACHIEVEMENT_AWARDED, Armory.AchievementChanged)
