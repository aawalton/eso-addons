DoItAll = DoItAll or {}
DoItAll.AddOnName = "DoItAll"
DoItAll.AddOnVersion = 1.69
DoItAll.FCOIS = {}
DoItAll.FCOIS.FCOItemSaver_DeconstructionSelectionHandlerVersion = 0.879
DoItAll.FCOIS.deconstructionSelectionHandlerSupported = false
DoItAll.FCOIS.loaded = false
DoItAll.FCOIS.version = 0
DoItAll.extractionActive = false

local function Initialize()
	DoItAll.Settings.Initialize()
end

local function Loaded(_, loadedAddon)
    if (DoItAll.AddOnName == loadedAddon) then
        --Load libLoadedAddons
        local LIBLA = LibLoadedAddons
        if LIBLA == nil and LibStub then LIBLA = LibStub:GetLibrary("LibLoadedAddons") end
        if LIBLA == nil then d("[" .. DoItAll.AddOnName .. "]ERROR Needed library LibLoadedAddons not found. Addon is not working properly! ") return end
        --LibAddonMenu-2.0
        DoItAll.LAM = LibAddonMenu2
        if DoItAll.LAM == nil and LibStub then DoItAll.LAM = LibStub("LibAddonMenu-2.0") end
        -- Registers addon to loadedAddon library
        LIBLA:RegisterAddon(DoItAll.AddOnName, DoItAll.AddOnVersion)
        DoItAll.LIBLA = LIBLA
        --Check if FCOItemSaver is loaded in the version that supports the global DeconstructionSelectionHandler
        if FCOIS then
            local DoItAllFCOIS = DoItAll.FCOIS
            DoItAllFCOIS.loaded, DoItAllFCOIS.version = LIBLA:IsAddonLoaded(FCOIS.addonVars.gAddonName)
            if DoItAllFCOIS.loaded and DoItAllFCOIS.version >= DoItAllFCOIS.FCOItemSaver_DeconstructionSelectionHandlerVersion then
                DoItAll.FCOIS.deconstructionSelectionHandlerSupported = true
            end
        end
        Initialize()
    end
end

--[[
local function PlayerActivated()
end
]]

ZO_CreateStringId("SI_BINDING_NAME_SC_BANK_ALL", "Do It All") -- use BANK_ALL to keep the existing key binding
EVENT_MANAGER:RegisterForEvent(DoItAll.AddOnName, EVENT_ADD_ON_LOADED, Loaded)
--EVENT_MANAGER:RegisterForEvent(DoItAll.AddOnName, EVENT_PLAYER_ACTIVATED, PlayerActivated) -- for debugging
