DynamicCP = DynamicCP or {}

function DynamicCP:CreateSettingsMenu()
    local LAM = LibAddonMenu2
    local panelData = {
        type = "panel",
        name = "Dynamic CP",
        displayName = "|c3bdb5eDynamic CP|r",
        author = "Kyzeragon",
        version = DynamicCP.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsData = {
        {
            type = "checkbox",
            name = "Debug",
            tooltip = "Show spammy debug chat",
            default = false,
            getFunc = function() return DynamicCP.savedOptions.debug end,
            setFunc = function(value)
                DynamicCP.savedOptions.debug = value
            end,
            width = "full",
        },
---------------------------------------------------------------------
-- constellation
        {
            type = "submenu",
            name = "Constellation Settings",
            controls = {
                {
                    type = "header",
                    name = "Labels",
                    width = "half",
                },
                {
                    type = "checkbox",
                    name = "Show labels on stars",
                    tooltip = "Show the names of champion point stars above the stars",
                    default = true,
                    getFunc = function() return DynamicCP.savedOptions.showLabels end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.showLabels = value
                        DynamicCP.RefreshLabels(value)
                    end,
                    width = "full",
                },
                {
                    type = "colorpicker",
                    name = "Passive star labels color",
                    tooltip = "Color of the labels for unslottable stars",
                    default = ZO_ColorDef:New(1, 1, 0.5),
                    getFunc = function() return unpack(DynamicCP.savedOptions.passiveLabelColor) end,
                    setFunc = function(r, g, b)
                        DynamicCP.savedOptions.passiveLabelColor = {r, g, b}
                        DynamicCP.RefreshLabels(DynamicCP.savedOptions.showLabels)
                    end,
                    width = "half",
                    disabled = function() return not DynamicCP.savedOptions.showLabels end
                },
                {
                    type = "slider",
                    name = "Passive star labels size",
                    tooltip = "Font size of the labels for unslottable stars",
                    getFunc = function() return DynamicCP.savedOptions.passiveLabelSize end,
                    default = 24,
                    min = 8,
                    max = 54,
                    step = 1,
                    setFunc = function(value)
                        DynamicCP.savedOptions.passiveLabelSize = value
                        DynamicCP.RefreshLabels(DynamicCP.savedOptions.showLabels)
                    end,
                    width = "half",
                    disabled = function() return not DynamicCP.savedOptions.showLabels end
                },
                {
                    type = "colorpicker",
                    name = "Slottable star labels color",
                    tooltip = "Color of the labels for slottable stars",
                    default = ZO_ColorDef:New(1, 1, 1),
                    getFunc = function() return unpack(DynamicCP.savedOptions.slottableLabelColor) end,
                    setFunc = function(r, g, b)
                        DynamicCP.savedOptions.slottableLabelColor = {r, g, b}
                        DynamicCP.RefreshLabels(DynamicCP.savedOptions.showLabels)
                    end,
                    width = "half",
                    disabled = function() return not DynamicCP.savedOptions.showLabels end
                },
                {
                    type = "slider",
                    name = "Slottable star labels size",
                    tooltip = "Font size of the labels for slottable stars",
                    getFunc = function() return DynamicCP.savedOptions.slottableLabelSize end,
                    default = 18,
                    min = 8,
                    max = 54,
                    step = 1,
                    setFunc = function(value)
                        DynamicCP.savedOptions.slottableLabelSize = value
                        DynamicCP.RefreshLabels(DynamicCP.savedOptions.showLabels)
                    end,
                    width = "half",
                    disabled = function() return not DynamicCP.savedOptions.showLabels end
                },
                {
                    type = "colorpicker",
                    name = "Cluster labels color",
                    tooltip = "Color of the labels for star clusters",
                    default = ZO_ColorDef:New(1, 0.7, 1),
                    getFunc = function() return unpack(DynamicCP.savedOptions.clusterLabelColor) end,
                    setFunc = function(r, g, b)
                        DynamicCP.savedOptions.clusterLabelColor = {r, g, b}
                        DynamicCP.RefreshLabels(DynamicCP.savedOptions.showLabels)
                    end,
                    width = "half",
                    disabled = function() return not DynamicCP.savedOptions.showLabels end
                },
                {
                    type = "slider",
                    name = "Cluster labels size",
                    tooltip = "Font size of the labels for star clusters",
                    getFunc = function() return DynamicCP.savedOptions.clusterLabelSize end,
                    default = 13,
                    min = 8,
                    max = 54,
                    step = 1,
                    setFunc = function(value)
                        DynamicCP.savedOptions.clusterLabelSize = value
                        DynamicCP.RefreshLabels(DynamicCP.savedOptions.showLabels)
                    end,
                    width = "half",
                    disabled = function() return not DynamicCP.savedOptions.showLabels end
                },
                {
                    type = "header",
                    name = "Other",
                    width = "half",
                },
                {
                    type = "checkbox",
                    name = "Hide background",
                    tooltip = "Hide the constellation background texture, useful if you have difficulty seeing the stars or don't like the extra clutter",
                    default = false,
                    getFunc = function() return DynamicCP.savedOptions.hideBackground end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.hideBackground = value
                    end,
                    width = "full",
                    requiresReload = true,
                },
                {
                    type = "checkbox",
                    name = "Double click to slot or unslot stars",
                    tooltip = "Double click the slottable stars to add or remove them to the hotbar, or double click the hotbar stars to unslot them",
                    default = true,
                    getFunc = function() return DynamicCP.savedOptions.doubleClick end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.doubleClick = value
                    end,
                    width = "full",
                    requiresReload = true,
                },
                {
                    type = "checkbox",
                    name = "Show total points",
                    tooltip = "Show your total champion points and for each tree on the top left of the CP screen",
                    default = true,
                    getFunc = function() return DynamicCP.savedOptions.showTotalsLabel end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.showTotalsLabel = value
                        DynamicCPInfoLabel:SetHidden(not value)
                    end,
                    width = "full",
                },
            },
        },
---------------------------------------------------------------------
-- presets window
        {
            type = "submenu",
            name = "Preset Window Settings",
            controls = {
                {
                    type = "checkbox",
                    name = "Show window with CP",
                    tooltip = "Display the window automatically when opening the Champion Points menu. You can turn this off if you do not wish to use presets",
                    default = true,
                    getFunc = function() return DynamicCP.savedOptions.showPresetsWithCP end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.showPresetsWithCP = value
                    end,
                    width = "full",
                },
                {
                    type = "dropdown",
                    name = "Preset window style",
                    tooltip = "Side Navigation Menu provides a simpler slideable menu that takes up less horizontal space.\n\nStandalone Window is an older UI from version < 2.0.0 that displays the trees next to each other instead. This option keeps the class icons.",
                    choices = {"Side Navigation Menu", "Standalone Window"},
                    choicesValues = {1, 2}, -- Apparently having "false" as a value does not work
                    getFunc = function()
                        return DynamicCP.savedOptions.useSidePresets and 1 or 2
                    end,
                    setFunc = function(value)
                        value = value == 1
                        DynamicCP:OnCancelClicked() -- clear potential stuff from the previous UI
                        DynamicCP.savedOptions.useSidePresets = value
                        DynamicCPPresetsContainer:SetHidden(false)
                        DynamicCPPresets:SetHidden(value)
                        DynamicCPSidePresets:SetHidden(not value)
                        DynamicCP:InitializeDropdowns()
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Dock standalone window",
                    tooltip = "Display the window in different positions on each constellation to avoid overlapping with stars. Recommend adjusting the scale so it fits in the Fitness tree, between Arcane Alacrity and Bashing Brutality",
                    default = true,
                    getFunc = function() return DynamicCP.savedOptions.dockWithSpace end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.dockWithSpace = value
                    end,
                    width = "full",
                    disabled = function() return DynamicCP.savedOptions.useSidePresets end
                },
                {
                    type = "slider",
                    name = "Window scale %",
                    tooltip = "Scale of the window to display. Some spacing may look weird especially at more extreme values",
                    default = 100,
                    min = 50,
                    max = 150,
                    step = 5,
                    getFunc = function() return DynamicCP.savedOptions.scale * 100 end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.scale = value / 100
                        DynamicCPPresetsContainer:SetHidden(false)
                        DynamicCP.GetSubControl():SetHidden(false)
                        DynamicCPPresets:SetScale(value / 100)
                        DynamicCPSidePresets:SetScale(value / 100)
                    end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Window opacity %",
                    tooltip = "Opacity of the window background",
                    default = 50,
                    min = 0,
                    max = 100,
                    step = 5,
                    getFunc = function() return DynamicCP.savedOptions.presetsBackdropAlpha * 100 end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.presetsBackdropAlpha = value / 100
                        DynamicCPPresetsContainer:SetHidden(false)
                        DynamicCP.GetSubControl():SetHidden(false)
                        DynamicCPPresetsBackdrop:SetAlpha(value / 100)
                        DynamicCPSidePresetsBackdrop:SetAlpha(value / 100)
                    end,
                    width = "full",
                },
            },
        },
---------------------------------------------------------------------
-- preset application
        {
            type = "submenu",
            name = "Preset Settings",
            controls = {
                {
                    type = "checkbox",
                    name = "Automatically slot stars",
                    tooltip = "After confirming a preset, automatically slot slottable stars. If there are more than 4 slottables, they are prioritized by most maxed, then most points, then star ID",
                    default = true,
                    getFunc = function() return DynamicCP.savedOptions.slotStars end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.slotStars = value
                    end,
                    width = "full",
                },
                {
                    type = "description",
                    title = "Manage Default Presets",
                    text = "You can delete ALL of the default presets using the button below. This will delete any presets that match the names of the default presets, so be careful if you made changes to any!",
                    width = "full",
                },
                {
                    type = "button",
                    name = "Delete Default Presets",
                    tooltip = "Delete all default presets. This cannot be undone!",
                    func = function()
                        DynamicCP.dbg("Deleting default presets")
                        for treeName, tree in pairs(DynamicCP.savedOptions.cp) do
                            for name, data in pairs(tree) do
                                if (DynamicCP.oldDefaultPresetNames[name] or data.isDefault == true) then
                                    DynamicCP.savedOptions.cp[treeName][name] = nil
                                end
                            end
                        end
                        DynamicCP:InitializeDropdowns()
                    end,
                    warning = "Delete all default presets. This cannot be undone!",
                    isDangerous = true,
                    width = "full",
                },
                {
                    type = "description",
                    title = nil,
                    text = "You can reset ALL of the default presets using the button below. This will delete any presets that match the names of the default presets, so be careful if you made changes to any! Then, it will add the latest updated default presets to your preset window.",
                    width = "full",
                },
                {
                    type = "button",
                    name = "Reset Default Presets",
                    tooltip = "Reset all default presets. This will delete all default presets and re-add them!",
                    func = function()
                        DynamicCP.dbg("Resetting default presets")
                        for treeName, tree in pairs(DynamicCP.savedOptions.cp) do
                            for name, data in pairs(tree) do
                                if (DynamicCP.oldDefaultPresetNames[name] or data.isDefault == true) then
                                    DynamicCP.savedOptions.cp[treeName][name] = nil
                                end
                            end
                        end

                        -- Now deep copy
                        for treeName, tree in pairs(DynamicCP.defaultPresets) do
                            for name, data in pairs(tree) do
                                DynamicCP.savedOptions.cp[treeName][name] = {}
                                for disciplineIndex, disciplineData in pairs(data) do
                                    DynamicCP.savedOptions.cp[treeName][name][disciplineIndex] = {}
                                    for skillId, points in pairs(disciplineData) do
                                        DynamicCP.savedOptions.cp[treeName][name][disciplineIndex][skillId] = points
                                    end
                                end
                            end
                        end

                        DynamicCP:InitializeDropdowns()
                    end,
                    warning = "Reset all default presets. This will delete all default presets and re-add them!",
                    isDangerous = true,
                    width = "full",
                },
            },
        },
---------------------------------------------------------------------
-- quickstars
        {
            type = "submenu",
            name = "Quickstar Panel Settings",
            controls = {
                {
                    type = "checkbox",
                    name = "Show panel on HUD",
                    tooltip = "Show a panel on your HUD that displays currently slotted stars and also allows changing the stars",
                    default = true,
                    getFunc = function() return DynamicCP.savedOptions.quickstarsShowOnHud end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.quickstarsShowOnHud = value
                        DynamicCP.InitQuickstarsScenes()
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show panel on HUD UI",
                    tooltip = "Also show the panel on the HUD UI scene, which means when your cursor is active, e.g. when typing in chatbox",
                    default = true,
                    getFunc = function() return DynamicCP.savedOptions.quickstarsShowOnHudUi end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.quickstarsShowOnHudUi = value
                        DynamicCP.InitQuickstarsScenes()
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show panel on CP screen",
                    tooltip = "Also show the panel on the CP screen",
                    default = false,
                    getFunc = function() return DynamicCP.savedOptions.quickstarsShowOnCpScreen end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.quickstarsShowOnCpScreen = value
                        DynamicCP.InitQuickstarsScenes()
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Lock panel",
                    tooltip = "Lock the panel so it can't be moved",
                    default = false,
                    getFunc = function() return DynamicCP.savedOptions.lockQuickstars end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.lockQuickstars = value
                        DynamicCPQuickstars:SetMovable(not value)
                        DynamicCPQuickstarsBackdrop:SetHidden(value)
                        if (not value) then
                            DynamicCP.ShowQuickstars()
                        end
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Use vertical buttons",
                    tooltip = "Set to ON for vertical buttons, OFF for horizontal",
                    default = true,
                    getFunc = function() return DynamicCP.savedOptions.quickstarsVertical end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.quickstarsVertical = value
                        DynamicCP.ShowQuickstars()
                        DynamicCP.ResizeQuickstars()
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Use mirrored menu side",
                    tooltip = "For vertical buttons: Set to ON to open to the left, OFF to open to the right\nFor horizontal buttons: Set to ON to open above, OFF to open below",
                    default = false,
                    getFunc = function() return DynamicCP.savedOptions.quickstarsMirrored end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.quickstarsMirrored = value
                        DynamicCP.ShowQuickstars()
                        DynamicCP.ResizeQuickstars()
                    end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Panel scale %",
                    tooltip = "Scale of the panel to display. Some spacing may look weird especially at more extreme values",
                    default = 100,
                    min = 50,
                    max = 150,
                    step = 5,
                    getFunc = function() return DynamicCP.savedOptions.quickstarsScale * 100 end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.quickstarsScale = value / 100
                        DynamicCP.ShowQuickstars()
                        DynamicCPQuickstars:SetScale(value / 100)
                    end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Panel width",
                    tooltip = "Width of the panel. Note that some star names may get cut off depending on the length",
                    default = 200,
                    min = 100,
                    max = 400,
                    step = 5,
                    getFunc = function() return DynamicCP.savedOptions.quickstarsWidth end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.quickstarsWidth = value
                        DynamicCP.ShowQuickstars()
                        DynamicCP.ResizeQuickstars()
                    end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Panel opacity %",
                    tooltip = "Opacity of the panel background",
                    default = 50,
                    min = 0,
                    max = 100,
                    step = 5,
                    getFunc = function() return DynamicCP.savedOptions.quickstarsAlpha * 100 end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.quickstarsAlpha = value / 100
                        DynamicCP.ShowQuickstars()

                        DynamicCPQuickstarsGreenButtonBackdrop:SetAlpha(value / 100)
                        DynamicCPQuickstarsBlueButtonBackdrop:SetAlpha(value / 100)
                        DynamicCPQuickstarsRedButtonBackdrop:SetAlpha(value / 100)
                        DynamicCPQuickstarsListBackdrop:SetAlpha(value / 100)
                        DynamicCPQuickstarsListCancelBackdrop:SetAlpha(value / 100)
                        DynamicCPQuickstarsListConfirmBackdrop:SetAlpha(value / 100)
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Hide slotted stars from dropdown",
                    tooltip = "Set to ON if you don't want the dropdowns to show stars that are already slotted in the current or other slots",
                    default = false,
                    getFunc = function() return DynamicCP.savedOptions.quickstarsDropdownHideSlotted end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.quickstarsDropdownHideSlotted = value
                        DynamicCP.SelectQuickstarsTab("REFRESH")
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Play sound",
                    tooltip = "Play the champion points committed sound when changing slottables",
                    default = true,
                    getFunc = function() return DynamicCP.savedOptions.quickstarsPlaySound end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.quickstarsPlaySound = value
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show cooldown",
                    tooltip = "Show a small label with a countdown indicating the 30-second cooldown on changing slottables",
                    default = true,
                    getFunc = function() return DynamicCP.savedOptions.quickstarsShowCooldown end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.quickstarsShowCooldown = value
                    end,
                    width = "half",
                },
                {
                    type = "colorpicker",
                    name = "Cooldown label color",
                    tooltip = "Color of the label for 30-second cooldown on Quickstars panel",
                    default = ZO_ColorDef:New(0.7, 0.7, 0.7),
                    getFunc = function() return unpack(DynamicCP.savedOptions.quickstarsCooldownColor) end,
                    setFunc = function(r, g, b)
                        DynamicCP.savedOptions.quickstarsCooldownColor = {r, g, b}
                        DynamicCPQuickstarsListCooldown:SetColor(unpack(DynamicCP.savedOptions.quickstarsCooldownColor))
                    end,
                    width = "half",
                    disabled = function() return not DynamicCP.savedOptions.quickstarsShowCooldown end
                },
            },
        },
---------------------------------------------------------------------
-- other
        {
            type = "submenu",
            name = "Other Settings",
            controls = {
                {
                    type = "checkbox",
                    name = "Prompt unsaved changes",
                    tooltip = "Show a warning and option to commit changes if you leave the CP screen without saving changes",
                    default = true,
                    getFunc = function() return DynamicCP.savedOptions.showLeaveWarning end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.showLeaveWarning = value
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show cooldown warning",
                    tooltip = "Show a warning if you are unable to commit changes due to ZOS's 30-second cooldown on changing slottables",
                    default = true,
                    getFunc = function() return DynamicCP.savedOptions.showCooldownWarning end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.showCooldownWarning = value
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show points on slottables pulldown",
                    tooltip = "Show the number of committed points in the pulldown beneath the slottables hotbar",
                    default = false,
                    getFunc = function() return DynamicCP.savedOptions.showPulldownPoints end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.showPulldownPoints = value
                        DynamicCP.OnSlotsChanged()
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show CP gained in chat",
                    tooltip = "Show a chatbox message when you gain champion points",
                    default = true,
                    getFunc = function() return DynamicCP.savedOptions.showPointGainedMessage end,
                    setFunc = function(value)
                        DynamicCP.savedOptions.showPointGainedMessage = value
                    end,
                    width = "full",
                },
            },
        },
    }

    DynamicCP.addonPanel = LAM:RegisterAddonPanel("DynamicCPOptions", panelData)
    LAM:RegisterOptionControls("DynamicCPOptions", optionsData)
end

function DynamicCP.OpenSettingsMenu()
    LibAddonMenu2:OpenToPanel(DynamicCP.addonPanel)
end
