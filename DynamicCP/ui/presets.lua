DynamicCP = DynamicCP or {}

local CREATE_NEW_STRING = "-- Create New --"
local MESSAGES_TOOLTIP_GAP = 24

local ROLE_TO_STRING = {
    [LFG_ROLE_DPS] = "Dps",
    [LFG_ROLE_HEAL] = "Healer",
    [LFG_ROLE_TANK] = "Tank",
}

local CLASSES = {
    Dragonknight = true,
    Sorcerer = true,
    Nightblade = true,
    Templar = true,
    Warden = true,
    Necromancer = true,
}

local ROLES = {
    Tank = true,
    Healer = true,
    Dps = true,
}

-- This is the INDEX, not ID
local TREE_TO_DISCIPLINE = {
    Green = 1,
    Blue = 2,
    Red = 3,
}

local HOTBAR_OFFSET = {
    Green = 0,
    Blue = 4,
    Red = 8,
}

local isRespeccing = false

---------------------------------------------------------------------
-- TODO: use heuristics to make non-stam/non-mag more grayed out? needs more sorting then
local libDialog = LibDialog

local selected = {
    Red = nil,
    Green = nil,
    Blue = nil,
}

---------------------------------------------------------------------
function UseSidePresets()
    return DynamicCP.savedOptions.useSidePresets
end

function GetSubControl(name)
    if (not name) then
        name = ""
    end

    if (UseSidePresets()) then
        return DynamicCPSidePresets:GetNamedChild(name)
    else
        return DynamicCPPresets:GetNamedChild(name)
    end
end
DynamicCP.GetSubControl = GetSubControl

---------------------------------------------------------------------
-- Strip control name down to just Red/Green/Blue
local function GetTreeName(name, prefix, suffix)
    return name:sub(prefix:len() + 1, name:len() - suffix:len())
end

---------------------------------------------------------------------
-- Show a message in the area under the options
local function ShowMessage(tree, text, diffText, color, numChanges, col1, col2)
    local messages = GetSubControl("Inner"):GetNamedChild(tree .. "Messages")
    if (not diffText) then diffText = "" end
    messages:SetHidden(false)

    if (UseSidePresets()) then
        numChanges = numChanges or 0
        messages:GetNamedChild("Backdrop"):SetEdgeColor(unpack(color))
        messages:GetNamedChild("Label"):SetText(text)
        messages:GetNamedChild("Tooltip"):SetHidden(diffText == nil or diffText == "")
        messages:GetNamedChild("Tooltip"):SetHeight(numChanges * 19 + 4)

        if (numChanges == 0) then
            numChanges = 1
            messages:GetNamedChild("Tooltip"):SetHeight(numChanges * 19 + 4)
            if (col1) then
                table.insert(col1, "No changes.")
            end
        end

        if (col1 ~= nil and col2 ~= nil) then
            -- Adjust width of the popup
            local col1Text = table.concat(col1, "\n")
            local col2Text = table.concat(col2, "\n")
            messages:GetNamedChild("TooltipLabel"):SetText(col1Text)
            messages:GetNamedChild("TooltipLabel2"):SetText(col2Text)
            messages:GetNamedChild("Tooltip"):SetWidth(500)
            messages:GetNamedChild("Tooltip"):SetWidth(messages:GetNamedChild("TooltipLabel"):GetTextWidth() + messages:GetNamedChild("TooltipLabel2"):GetTextWidth() + MESSAGES_TOOLTIP_GAP)
        else
            messages:GetNamedChild("TooltipLabel"):SetText(diffText)
            messages:GetNamedChild("TooltipLabel2"):SetText("")
        end

        -- Do a second panel
        if (numChanges >= 12 and col1 ~= nil and col2 ~= nil) then
            local halfLines = math.floor((numChanges + 1) / 2)

            local col1Text = table.concat(col1, "\n", 1, halfLines)
            local col2Text = table.concat(col2, "\n", 1, halfLines)
            messages:GetNamedChild("Tooltip"):SetHeight(halfLines * 19 + 4)
            messages:GetNamedChild("TooltipLabel"):SetText(col1Text)
            messages:GetNamedChild("TooltipLabel2"):SetText(col2Text)
            messages:GetNamedChild("Tooltip"):SetWidth(500)
            messages:GetNamedChild("Tooltip"):SetWidth(messages:GetNamedChild("TooltipLabel"):GetTextWidth() + messages:GetNamedChild("TooltipLabel2"):GetTextWidth() + MESSAGES_TOOLTIP_GAP)

            col1Text = table.concat(col1, "\n", halfLines + 1, #col1)
            col2Text = table.concat(col2, "\n", halfLines + 1, #col2)
            messages:GetNamedChild("TooltipExtra"):SetHidden(false)
            messages:GetNamedChild("TooltipExtra"):SetHeight(halfLines * 19 + 4)
            messages:GetNamedChild("TooltipExtraLabel"):SetText(col1Text)
            messages:GetNamedChild("TooltipExtraLabel2"):SetText(col2Text)
            messages:GetNamedChild("TooltipExtra"):SetWidth(500)
            messages:GetNamedChild("TooltipExtra"):SetWidth(messages:GetNamedChild("TooltipExtraLabel"):GetTextWidth() + messages:GetNamedChild("TooltipExtraLabel2"):GetTextWidth() + MESSAGES_TOOLTIP_GAP + 10)
        else
            messages:GetNamedChild("TooltipExtra"):SetHidden(true)
        end

        -- Need to move it upwards if it's a "delete" which means nothing is selected and it looks empty
        if (GetSubControl("Inner"):GetNamedChild(tree .. "Options"):IsHidden()) then
            messages:SetAnchor(TOP, GetSubControl("Inner"):GetNamedChild(tree .. "Dropdown"), BOTTOM, 0, 4)
        else
            messages:SetAnchor(TOP, GetSubControl("Inner"):GetNamedChild(tree .. "OptionsButtons"), BOTTOM, 0, 0)
        end
    else
        messages:SetText(diffText .. "\n\n" .. text)
        -- Need to move it upwards if it's a "delete" which means nothing is selected and it looks empty
        if (GetSubControl("Inner"):GetNamedChild(tree .. "Options"):IsHidden()) then
            messages:SetAnchor(TOP, GetSubControl("Inner"):GetNamedChild(tree), TOP, 0, 80)
        else
            messages:SetAnchor(TOP, GetSubControl("Inner"):GetNamedChild(tree), TOP, 0, 300)
        end
    end
end

local function HideMessage(tree)
    local messages = GetSubControl("Inner"):GetNamedChild(tree .. "Messages")
    messages:SetHidden(true)
end


---------------------------------------------------------------------
local function DisplayMildWarning(text)
    DynamicCPMildWarningLabel:SetText(text)
    DynamicCPMildWarning:SetHidden(false)
    DynamicCPMildWarning:ClearAnchors()
    DynamicCPMildWarning:SetAnchor(BOTTOM, DynamicCPWarning, TOP, 0, -10)
end

local function SetMildWarning(text)
    DynamicCPMildWarning:SetText(text)
end

local function HideMildWarning()
    DynamicCPMildWarning:SetHidden(true)
end


---------------------------------------------------------------------
-- Find and build string of the diff between two cp sets
-- TODO: pull the logic portion out into points.lua
local function GenerateDiff(before, after)
    local result = "Changes:"
    local col1 = {}
    local col2 = {}

    local numChanges = 0
    for disciplineIndex = 1, GetNumChampionDisciplines() do
        if (before[disciplineIndex] and after[disciplineIndex]) then
            for skillIndex = 1, GetNumChampionDisciplineSkills(disciplineIndex) do
                local skillId = GetChampionSkillId(disciplineIndex, skillIndex)
                local first = before[disciplineIndex][skillId] or 0
                local second = after[disciplineIndex][skillId] or 0
                if (first ~= second and (first ~= 0 or second ~= 0)) then
                    local line = zo_strformat("\n|cBBBBBB<<C:1>>:  <<2>> → <<3>>",
                        GetChampionSkillName(skillId),
                        first,
                        second)

                    table.insert(col1, zo_strformat("<<C:1>>", GetChampionSkillName(skillId)))
                    if (first < second) then
                        line = line .. "|c00FF00↑|r"
                        table.insert(col2, zo_strformat("<<1>> → <<2>>|c00FF00↑|r", first, second))
                    else
                        line = line .. "|cFF0000↓|r"
                        table.insert(col2, zo_strformat("<<1>> → <<2>>|cFF0000↓|r", first, second))
                    end
                    result = result .. line
                    numChanges = numChanges + 1
                end
            end
        end
    end

    if (result == "Changes:") then
        result = "|cBBBBBBNo changes.|r"
    end
    return result, numChanges, col1, col2
end


---------------------------------------------------------------------
-- Build string for this CP, but only for certain tree
local function GenerateTree(cp, tree)
    local result = "|cBBBBBB"
    local col1 = {}
    local col2 = {}
    local numLines = 0

    local disciplineIndex = TREE_TO_DISCIPLINE[tree]
    for skillIndex = 1, GetNumChampionDisciplineSkills(disciplineIndex) do
        local skillId = GetChampionSkillId(disciplineIndex, skillIndex)
        local points = cp[disciplineIndex][skillId]
        if (points ~= 0) then
            local line = zo_strformat("\n<<C:1>>:  <<2>>",
                GetChampionSkillName(skillId),
                points)
            result = result .. line
            numLines = numLines + 1
            table.insert(col1, zo_strformat("<<C:1>>", GetChampionSkillName(skillId)))
            table.insert(col2, zo_strformat("<<1>>", points))
        end
    end

    return result .. "|r", numLines, col1, col2
end


---------------------------------------------------------------------
-- When apply button is clicked
function DynamicCP:OnApplyClicked(button)
    local tree = GetTreeName(button:GetName(), GetSubControl():GetName() .. "Inner", "OptionsApplyButton")
    local presetName = selected[tree]

    if (not presetName) then
        d("You shouldn't be seeing this message! Please leave Kyzer a message saying which buttons you clicked to get here. OnApplyClicked")
        return
    end

    DynamicCP.dbg("Attempting to apply \"" .. presetName .. "\" to the " .. tree .. " tree.")

    local currentCP = DynamicCP.GetCommittedCP()

    -- First find all of the slottable skillIds to check them later
    local currentHotbar = {}
    for slotIndex = 1, 12 do
        local skillId = GetSlotBoundId(slotIndex, HOTBAR_CATEGORY_CHAMPION)
        currentHotbar[skillId] = slotIndex
    end

    if (not isRespeccing) then
        DynamicCP.ClearPendingCP()
        DynamicCP.ClearPendingSlottables()
        isRespeccing = true
    end

    -- Apply all stars within the tree
    local cp = DynamicCP.savedOptions.cp[tree][presetName]
    local disciplineIndex = TREE_TO_DISCIPLINE[tree]
    local slottablesData = {}
    local hasOverMaxPoints = false
    for skillIndex = 1, GetNumChampionDisciplineSkills(disciplineIndex) do
        local skillId = GetChampionSkillId(disciplineIndex, skillIndex)
        local numPoints = 0
        if (cp[disciplineIndex] and cp[disciplineIndex][skillId] ~= nil) then
            local maxPoints = GetChampionSkillMaxPoints(skillId)
            if (cp[disciplineIndex][skillId] > maxPoints) then
                numPoints = maxPoints
                hasOverMaxPoints = true
            else
                numPoints = cp[disciplineIndex][skillId]
            end
        else
            DynamicCP.dbg("else" .. GetChampionSkillName(skillId))
            numPoints = 0
        end

        -- Unslot slottables that are no longer slottable because of not enough points
        -- We still do this even though slottables are replaced later because user could have slotStars setting off
        if (currentHotbar[skillId] and not WouldChampionSkillNodeBeUnlocked(skillId, numPoints)) then
            DynamicCP.dbg("unslotting" .. GetChampionSkillName(skillId))
            DynamicCP.SetSlottableInIndex(currentHotbar[skillId], -1)
        end

        -- Collect slottables
        local isSlottable = CanChampionSkillTypeBeSlotted(GetChampionSkillType(skillId))
        if (isSlottable and WouldChampionSkillNodeBeUnlocked(skillId, numPoints)) then
            table.insert(slottablesData, {skillId = skillId, points = numPoints, maxPoints = GetChampionSkillMaxPoints(skillId)})
        end

        DynamicCP.SetStarPoints(disciplineIndex, skillId, numPoints)
    end

    -- Apply slottables if applicable
    if (DynamicCP.savedOptions.slotStars) then
        -- Sort by most maxed
        table.sort(slottablesData, function(item1, item2)
            local prop1 = item1.points / item1.maxPoints
            local prop2 = item2.points / item2.maxPoints
            if (prop1 == prop2) then
                if (item1.maxPoints == item2.maxPoints) then
                    -- Last resort, sort by skill id
                    return item1.skillId < item2.skillId
                end
                -- If proportions are equal, prioritize ones with higher max because idk
                return item1.maxPoints > item2.maxPoints
            end
            return prop1 > prop2
        end)

        -- Assign the first 4
        local offset = HOTBAR_OFFSET[tree]
        for i = 1, 4 do
            if (slottablesData[i]) then
                local skillId = slottablesData[i].skillId
                DynamicCP.SetSlottableInIndex(i + offset, skillId)
                DynamicCP.dbg(zo_strformat("adding <<C:1>> to slot <<2>>", GetChampionSkillName(skillId), i + offset))
            end
        end
    end

    local diffText, numChanges, col1, col2 = GenerateDiff(DynamicCP.GetCommittedCP(), cp)
    ShowMessage(tree, "|c00FF00Preset loaded!\nPress \"Confirm\" to commit.|r", diffText, {0, 1, 0, 1}, numChanges, col1, col2)
    -- Unhide confirm button and also update the cost
    GetSubControl("InnerConfirmButton"):SetHidden(false)
    GetSubControl("InnerCancelButton"):SetHidden(false)
    if (DynamicCP.NeedsRespec()) then
        GetSubControl("InnerConfirmButton"):SetText("Confirm (" .. tostring(GetChampionRespecCost()) .. " |t18:18:esoui/art/currency/currency_gold.dds|t)")
    else
        GetSubControl("InnerConfirmButton"):SetText("Confirm")
    end

    -- Show warning message
    if (hasOverMaxPoints) then
        DisplayMildWarning("Warning: the preset you applied has more than the maximum points allowed in certain stars. The points will be left as extra. Make sure to save the preset after you allocate your points to overwrite the old preset! If this was a default preset, you can also re-import all of the default presets in the add-on settings by clicking on the gear icon.")
    end
end


---------------------------------------------------------------------
-- When confirm button is clicked
function DynamicCP:OnConfirmClicked(button)
    local needsRespec = DynamicCP.NeedsRespec()
    DynamicCP.dbg("needs respec? " .. (needsRespec and "yes" or "no"))

    local function CommitPoints()
        PrepareChampionPurchaseRequest(needsRespec)
        DynamicCP.ConvertPendingPointsToPurchase()
        DynamicCP.ConvertPendingSlottablesToPurchase()
        SendChampionPurchaseRequest()

        isRespeccing = false
        DynamicCP.ClearPendingCP()
        DynamicCP.ClearPendingSlottables()
        GetSubControl("InnerConfirmButton"):SetHidden(true)
        GetSubControl("InnerCancelButton"):SetHidden(true)
        HideMessage("Green")
        HideMessage("Blue")
        HideMessage("Red")
    end

    local respecCost = "\nRedistribution cost: "  .. GetChampionRespecCost() .. " |t18:18:esoui/art/currency/currency_gold.dds|t"
    libDialog:RegisterDialog(
            DynamicCP.name,
            "ConfirmConfirmation",
            "Confirm Changes",
            "Are you sure you want to commit your points?" .. (needsRespec and respecCost or ""),
            CommitPoints,
            nil,
            nil,
            true)
    libDialog:ShowDialog(DynamicCP.name, "ConfirmConfirmation")
end


---------------------------------------------------------------------
-- When cancel button is clicked
function DynamicCP:OnCancelClicked()
    isRespeccing = false
    DynamicCP.ClearPendingCP()
    DynamicCP.ClearPendingSlottables()
    GetSubControl("InnerConfirmButton"):SetHidden(true)
    GetSubControl("InnerCancelButton"):SetHidden(true)
    HideMessage("Green")
    HideMessage("Blue")
    HideMessage("Red")
end


---------------------------------------------------------------------
-- Perform saving of CP preset
local function SavePreset(tree, oldName, presetName, newCP, message)
    if (oldName ~= CREATE_NEW_STRING) then
        DynamicCP.savedOptions.cp[tree][oldName] = nil
    end

    DynamicCP.savedOptions.cp[tree][presetName] = newCP

    DynamicCP:InitializeDropdown(tree, presetName)
    DynamicCP.dbg("|c00FF00Saved preset \"" .. presetName .. "\"|r")

    message = message or ("|c00FF00Done! Saved preset \"" .. presetName .. "\"|r")
    local treeText, numChanges, col1, col2 = GenerateTree(newCP, tree)
    ShowMessage(tree, message, treeText, {0, 1, 0, 1}, numChanges, col1, col2)
end


---------------------------------------------------------------------
-- When save button is clicked
function DynamicCP:OnSaveClicked(button, tree)
    tree = tree or GetTreeName(button:GetName(), GetSubControl():GetName() .. "Inner", "OptionsSaveButton")
    local presetName = selected[tree]
    if (presetName == nil) then
        d("You shouldn't be seeing this message! Please leave Kyzer a message saying which buttons you clicked to get here. OnSaveClicked")
        return
    end

    -- Do a deep copy
    local currentCP = DynamicCP.GetCommittedCP()
    local newCP = {}
    local disciplineIndex = TREE_TO_DISCIPLINE[tree]
    newCP[disciplineIndex] = {}
    for k, v in pairs(currentCP[disciplineIndex]) do
        newCP[disciplineIndex][k] = v
    end
    -- Also copy the other things like role and class
    if (DynamicCP.savedOptions.cp[tree][presetName]) then
        for index, _ in pairs(DynamicCP.savedOptions.cp[tree][presetName]) do
            if (index ~= disciplineIndex and type(index) ~= "number") then
                newCP[index] = {}
                for k, v in pairs(DynamicCP.savedOptions.cp[tree][presetName][index]) do
                    newCP[index][k] = v
                end
            end
        end
    end

    -- Don't want to deal with formatting, colors are stripped when parsing name from dropdown
    local newName = GetSubControl("Inner"):GetNamedChild(tree .. "OptionsTextField"):GetText()
    if (newName:find("|")) then
        ShowMessage(tree, "|cFF0000\"||\" is not allowed in preset names.|r", nil, {1, 0, 0, 1}, 0)
        return
    end

    -- New and no conflict
    if (presetName == CREATE_NEW_STRING and not DynamicCP.savedOptions.cp[tree][newName]) then
        DynamicCP.dbg("Saving to new preset")
        SavePreset(tree, presetName, newName, newCP)

    -- New but has the same name as existing... OR overwrite existing that has been selected
    elseif (presetName == CREATE_NEW_STRING or presetName == newName) then
        DynamicCP.dbg("Overwriting existing preset")
        local function OverwritePreset()
            SavePreset(tree, presetName, newName, newCP,
                "|c00FF00Done! Overwrote preset \"" .. presetName .. "\"|r")
        end

        libDialog:RegisterDialog(
            DynamicCP.name,
            "OverwriteConfirmation",
            "Overwrite Preset",
            "Overwrite the \"" .. newName .. "\" preset?\n" .. GenerateDiff(DynamicCP.savedOptions.cp[tree][newName], currentCP),
            OverwritePreset,
            nil,
            nil,
            true)
        libDialog:ShowDialog(DynamicCP.name, "OverwriteConfirmation")

    else
        d("You shouldn't be seeing this message! Please leave Kyzer a message saying which buttons you clicked to get here. OnSaveClicked fallthrough")
    end
end


---------------------------------------------------------------------
-- When focus is lost on the text field
function DynamicCP:OnTextFocusLost(textfield)
    DynamicCP.dbg("focus lost")
    local tree = GetTreeName(textfield:GetName(), GetSubControl():GetName() .. "Inner", "OptionsTextField")
    local presetName = selected[tree]
    if (presetName == nil) then
        d("You shouldn't be seeing this message! Please leave Kyzer a message saying which buttons you clicked to get here. OnTextFocusLost")
        return
    end

    if (presetName == CREATE_NEW_STRING) then
        return
    end

    local newName = GetSubControl("Inner"):GetNamedChild(tree .. "OptionsTextField"):GetText()

    if (presetName == newName) then
        return
    end

    -- We are renaming an existing preset
    SavePreset(tree, presetName, newName, DynamicCP.savedOptions.cp[tree][presetName],
        "|c00FF00Renamed preset \"" .. presetName .. "\" to \"" .. newName .. "\"|r")
end


---------------------------------------------------------------------
-- When delete button is clicked
function DynamicCP:OnDeleteClicked(button)
    local tree = GetTreeName(button:GetName(), GetSubControl():GetName() .. "Inner", "OptionsDeleteButton")
    local presetName = selected[tree]
    if (presetName == nil or presetName == CREATE_NEW_STRING) then
        d("You shouldn't be seeing this message! Please leave Kyzer a message saying which buttons you clicked to get here. OnDeleteClicked")
        return
    end

    function DeletePreset()
        DynamicCP.savedOptions.cp[tree][presetName] = nil
        DynamicCP:InitializeDropdown(tree)
        DynamicCP.dbg("Deleted " .. presetName)
        ShowMessage(tree, "|c00FF00Preset \"" .. presetName .. "\" deleted.|r", nil, {0, 1, 0, 1}, 0)
    end

    libDialog:RegisterDialog(
        DynamicCP.name,
        "DeleteConfirmation",
        "Delete Preset",
        "Delete the \"" .. presetName .. "\" preset?",
        DeletePreset,
        nil,
        nil,
        true)
    libDialog:ShowDialog(DynamicCP.name, "DeleteConfirmation")
end


---------------------------------------------------------------------
-- Hide/unhide the options
local function AdjustDividers()
    local r = not GetSubControl("Inner"):GetNamedChild("RedOptions"):IsHidden() or not GetSubControl("Inner"):GetNamedChild("RedMessages"):IsHidden()
    local g = not GetSubControl("Inner"):GetNamedChild("GreenOptions"):IsHidden() or not GetSubControl("Inner"):GetNamedChild("GreenMessages"):IsHidden()
    local b = not GetSubControl("Inner"):GetNamedChild("BlueOptions"):IsHidden() or not GetSubControl("Inner"):GetNamedChild("BlueMessages"):IsHidden()

    GetSubControl("InnerInstructions"):SetHidden(r or g or b)

    if (UseSidePresets()) then return end

    GetSubControl("InnerGreenBlueDivider"):SetHeight((g or b) and 230 or 60)
    GetSubControl("InnerBlueRedDivider"):SetHeight((r or g) and 230 or 60)
end

local function UnhideOptions(tree)
    GetSubControl("Inner"):GetNamedChild(tree .. "Options"):SetHidden(false)
    AdjustDividers()
end

local function HideOptions(tree)
    GetSubControl("Inner"):GetNamedChild(tree .. "Options"):SetHidden(true)
    AdjustDividers()
end


---------------------------------------------------------------------
-- Class/Role buttons

local function DecoratePresetName(presetName, cp)
    local class = GetUnitClass("player")
    local role = ROLE_TO_STRING[GetSelectedLFGRole()]

    if (cp.classes and not cp.classes[class]) then
        return "|c444444" .. presetName .. "|r"
    elseif (cp.roles and not cp.roles[role]) then
        return "|c444444" .. presetName .. "|r"
    else
        return "|c9FBFAF" .. presetName .. "|r"
    end
end

local function SetTextureButtonEnabled(textureButton, enabled)
    textureButton.enabled = enabled
    if (enabled) then
        textureButton:SetColor(0.9, 1, 0.9)
    else
        textureButton:SetColor(0.4, 0.3, 0.3)
    end
end

function DynamicCP:ToggleOptionButton(textureButton)
    local tree = GetTreeName(textureButton:GetName(), GetSubControl():GetName() .. "Inner", "OptionsButtons" .. (textureButton.class or textureButton.role))

    if (selected[tree] == CREATE_NEW_STRING) then
        d("You shouldn't be seeing this message! Please leave Kyzer a message saying which buttons you clicked to get here. ToggleOptionButton")
        return
    end

    SetTextureButtonEnabled(textureButton, not textureButton.enabled)
    local presetName = selected[tree]

    -- Immediately save to the preset when buttons are toggled
    if (textureButton.class) then
        if (not DynamicCP.savedOptions.cp[tree][presetName].classes) then
            DynamicCP.savedOptions.cp[tree][presetName].classes = {
                Dragonknight = true,
                Sorcerer = true,
                Nightblade = true,
                Templar = true,
                Warden = true,
                Necromancer = true,
            }
        end
        DynamicCP.savedOptions.cp[tree][presetName].classes[textureButton.class] = textureButton.enabled
    elseif (textureButton.role) then
        if (not DynamicCP.savedOptions.cp[tree][presetName].roles) then
            DynamicCP.savedOptions.cp[tree][presetName].roles = {
                Tank = true,
                Healer = true,
                Dps = true,
            }
        end
        DynamicCP.savedOptions.cp[tree][presetName].roles[textureButton.role] = textureButton.enabled
    end

    -- Update the dropdown to reflect matching or not matching
    local dropdown = ZO_ComboBox_ObjectFromContainer(GetSubControl("Inner"):GetNamedChild(tree .. "Dropdown"))
    local itemData = dropdown:GetSelectedItemData()
    itemData.name = DecoratePresetName(presetName, DynamicCP.savedOptions.cp[tree][presetName])
    dropdown:UpdateItems()
    dropdown:SelectItem(itemData)

    ZO_ComboBox_ObjectFromContainer(GetSubControl("InnerRedDropdown"))
end


---------------------------------------------------------------------
-- Open/close this window
local function TogglePresetsWindow()
    local isHidden = GetSubControl():IsHidden()
    GetSubControl():SetHidden(not isHidden)
    if (isHidden) then
        DynamicCP:InitializeDropdowns()
        DynamicCPPresetsContainer:SetHidden(false)
    end
end
DynamicCP.TogglePresetsWindow = TogglePresetsWindow


---------------------------------------------------------------------
-- Populate the dropdown with presets
function DynamicCP:InitializeDropdown(tree, desiredEntryName)
    if (tree ~= "Red" and tree ~= "Green" and tree ~= "Blue") then
        DynamicCP.dbg("You're using this wrong >:[")
        return
    end

    local function OnPresetSelected(_, _, entry)
        local presetName = entry.name:gsub("|[cC]%x%x%x%x%x%x", ""):gsub("|r", "")

        selected[tree] = presetName
        UnhideOptions(tree)

        if (presetName == CREATE_NEW_STRING) then
            local newIndex = 1
            while (DynamicCP.savedOptions.cp[tree]["Preset " .. newIndex] ~= nil) do
                newIndex = newIndex + 1
            end
            GetSubControl("Inner"):GetNamedChild(tree .. "OptionsTextField"):SetText("Preset " .. newIndex)
            GetSubControl("Inner"):GetNamedChild(tree .. "OptionsApplyButton"):SetHidden(true)
            GetSubControl("Inner"):GetNamedChild(tree .. "OptionsDeleteButton"):SetHidden(true)
            GetSubControl("Inner"):GetNamedChild(tree .. "OptionsSaveButton"):SetWidth(190)
            GetSubControl("Inner"):GetNamedChild(tree .. "OptionsButtons"):SetHidden(true)
        else
            GetSubControl("Inner"):GetNamedChild(tree .. "OptionsTextField"):SetText(presetName)
            GetSubControl("Inner"):GetNamedChild(tree .. "OptionsApplyButton"):SetHidden(false)
            GetSubControl("Inner"):GetNamedChild(tree .. "OptionsDeleteButton"):SetHidden(false)
            GetSubControl("Inner"):GetNamedChild(tree .. "OptionsSaveButton"):SetWidth(95)
            GetSubControl("Inner"):GetNamedChild(tree .. "OptionsButtons"):SetHidden(false)
        end


        local data = DynamicCP.savedOptions.cp[tree][presetName] or {}

        local buttons = GetSubControl("Inner"):GetNamedChild(tree .. "OptionsButtons")
        if (not UseSidePresets()) then
            for class, _ in pairs(CLASSES) do
                local button = buttons:GetNamedChild(class)
                SetTextureButtonEnabled(button, data.classes == nil or data.classes[class] == nil or data.classes[class]) -- Both nil or true
                -- Completely hide button rows
                button:SetHidden(not DynamicCP.savedOptions.presetsShowClassButtons)
            end
        end
        for role, _ in pairs(ROLES) do
            SetTextureButtonEnabled(buttons:GetNamedChild(role), data.roles == nil or data.roles[role] == nil or data.roles[role]) -- Both nil or true
        end

        -- If class buttons are hidden, role buttons should be anchored higher
        if (DynamicCP.savedOptions.presetsShowClassButtons and not UseSidePresets()) then
            buttons:GetNamedChild("Tank"):SetAnchor(TOP, buttons:GetNamedChild("Dragonknight"), BOTTOM, 4, 6)
            buttons:GetNamedChild("Help"):SetAnchor(TOP, buttons:GetNamedChild("Necromancer"), BOTTOM, 0, 6)
        else
            buttons:GetNamedChild("Tank"):SetAnchor(TOPLEFT, buttons, TOPLEFT, 2)
            buttons:GetNamedChild("Help"):SetAnchor(TOPRIGHT, buttons, TOPRIGHT, -2)
        end

        if (presetName == CREATE_NEW_STRING) then
            local diffText, numChanges, col1, col2 = GenerateTree(DynamicCP.GetCommittedCP(), tree)
            ShowMessage(tree, "Rename and click \"Save\" to create a new preset.", diffText, {1, 1, 1, 1}, numChanges, col1, col2)
        else
            local diffText, numChanges, col1, col2 = GenerateDiff(DynamicCP.GetCommittedCP(), data)
            ShowMessage(tree, "Click \"Apply\" to load this preset.", diffText, {1, 1, 1, 1}, numChanges, col1, col2)
        end
    end

    -- Add entries to dropdown
    local data = DynamicCP.savedOptions.cp[tree]
    local dropdown = ZO_ComboBox_ObjectFromContainer(GetSubControl("Inner"):GetNamedChild(tree .. "Dropdown"))
    local desiredEntry = nil
    dropdown:ClearItems()
    for presetName, cp in pairs(data) do
        local name = DecoratePresetName(presetName, cp)
        local entry = ZO_ComboBox:CreateItemEntry(name, OnPresetSelected)
        dropdown:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)

        if (presetName == desiredEntryName) then
            desiredEntry = entry
        end
    end
    local entry = ZO_ComboBox:CreateItemEntry("|cEBDB34" .. CREATE_NEW_STRING .. "|r", OnPresetSelected)
    dropdown:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
    dropdown:UpdateItems()

    if (desiredEntry) then
        dropdown:SelectItem(desiredEntry)
        OnPresetSelected(nil, nil, desiredEntry)
    else
        selected[tree] = nil
        HideOptions(tree)
    end
end

----------------------------------------------------------------------
local expanded = true
function DynamicCP.OnSidebarClicked()
    if (expanded) then
        -- Close it
        DynamicCPSidePresets.slide:SetDeltaOffsetX(DynamicCPSidePresets:GetWidth())
        DynamicCPSidePresetsInnerGreenMessagesTooltip.slide:SetDeltaOffsetX(400)
        DynamicCPSidePresetsInnerBlueMessagesTooltip.slide:SetDeltaOffsetX(400)
        DynamicCPSidePresetsInnerRedMessagesTooltip.slide:SetDeltaOffsetX(400)
        DynamicCPSidePresetsSidebarClose.rotateAnimation:PlayFromStart()
    else
        -- Expand it
        DynamicCPSidePresets.slide:SetDeltaOffsetX(-1 * DynamicCPSidePresets:GetWidth())
        DynamicCPSidePresetsInnerGreenMessagesTooltip.slide:SetDeltaOffsetX(-400)
        DynamicCPSidePresetsInnerBlueMessagesTooltip.slide:SetDeltaOffsetX(-400)
        DynamicCPSidePresetsInnerRedMessagesTooltip.slide:SetDeltaOffsetX(-400)
        DynamicCPSidePresetsSidebarClose.rotateAnimation:PlayBackward()
    end
    expanded = not expanded
    DynamicCPSidePresets.slideAnimation:PlayFromStart()
    DynamicCPSidePresetsInnerGreenMessagesTooltip.slideAnimation:PlayFromStart()
    DynamicCPSidePresetsInnerBlueMessagesTooltip.slideAnimation:PlayFromStart()
    DynamicCPSidePresetsInnerRedMessagesTooltip.slideAnimation:PlayFromStart()
end

---------------------------------------------------------------------
-- Entry point
function DynamicCP:InitializeDropdowns()
    if (isRespeccing) then return end -- Skip doing this so we don't overwrite

    DynamicCPSidePresets.slideAnimation = GetAnimationManager():CreateTimelineFromVirtual("ZO_LootSlideInAnimation", DynamicCPSidePresets)
    DynamicCPSidePresets.slide = DynamicCPSidePresets.slideAnimation:GetFirstAnimation()
    DynamicCPSidePresetsSidebarClose.rotateAnimation = GetAnimationManager():CreateTimelineFromVirtual("ArrowRotateAnim", DynamicCPSidePresetsSidebarClose)
    DynamicCPSidePresetsSidebarClose.rotate = DynamicCPSidePresetsSidebarClose.rotateAnimation:GetFirstAnimation()

    DynamicCPSidePresetsInnerGreenMessagesTooltip.slideAnimation = GetAnimationManager():CreateTimelineFromVirtual("ZO_LootSlideInAnimation", DynamicCPSidePresetsInnerGreenMessagesTooltip)
    DynamicCPSidePresetsInnerGreenMessagesTooltip.slide = DynamicCPSidePresetsInnerGreenMessagesTooltip.slideAnimation:GetFirstAnimation()
    DynamicCPSidePresetsInnerBlueMessagesTooltip.slideAnimation = GetAnimationManager():CreateTimelineFromVirtual("ZO_LootSlideInAnimation", DynamicCPSidePresetsInnerBlueMessagesTooltip)
    DynamicCPSidePresetsInnerBlueMessagesTooltip.slide = DynamicCPSidePresetsInnerBlueMessagesTooltip.slideAnimation:GetFirstAnimation()
    DynamicCPSidePresetsInnerRedMessagesTooltip.slideAnimation = GetAnimationManager():CreateTimelineFromVirtual("ZO_LootSlideInAnimation", DynamicCPSidePresetsInnerRedMessagesTooltip)
    DynamicCPSidePresetsInnerRedMessagesTooltip.slide = DynamicCPSidePresetsInnerRedMessagesTooltip.slideAnimation:GetFirstAnimation()

    DynamicCP:InitializeDropdown("Red")
    DynamicCP:InitializeDropdown("Green")
    DynamicCP:InitializeDropdown("Blue")
    HideMessage("Red")
    HideMessage("Green")
    HideMessage("Blue")
end