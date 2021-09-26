local function GetFilterCallbackForTrait(traitTypes)
    return function(slot)
        local link = GetItemLink(slot.bagId, slot.slotIndex)
        local itemTraitType = GetItemLinkTraitInfo(link)

        for _, traitType in pairs(traitTypes) do
            if traitType == itemTraitType then return true end
        end
    end
end

local weaponTraitDropdownCallbacks = {
    {name = "None", filterCallback = GetFilterCallbackForTrait({ITEM_TRAIT_TYPE_NONE})},
    {name = "Powered", filterCallback = GetFilterCallbackForTrait({ITEM_TRAIT_TYPE_WEAPON_POWERED})},
    {name = "Charged", filterCallback = GetFilterCallbackForTrait({ITEM_TRAIT_TYPE_WEAPON_CHARGED})},
    {name = "Precise", filterCallback = GetFilterCallbackForTrait({ITEM_TRAIT_TYPE_WEAPON_PRECISE})},
    {name = "Infused", filterCallback = GetFilterCallbackForTrait({ITEM_TRAIT_TYPE_WEAPON_INFUSED})},
    {name = "Defending", filterCallback = GetFilterCallbackForTrait({ITEM_TRAIT_TYPE_WEAPON_DEFENDING})},
    {name = "Training", filterCallback = GetFilterCallbackForTrait({ITEM_TRAIT_TYPE_WEAPON_TRAINING})},
    {name = "Sharpened", filterCallback = GetFilterCallbackForTrait({ITEM_TRAIT_TYPE_WEAPON_SHARPENED})},
    {name = "Weighted", filterCallback = GetFilterCallbackForTrait({ITEM_TRAIT_TYPE_WEAPON_WEIGHTED})},
    {name = "Nirnhoned", filterCallback = GetFilterCallbackForTrait({ITEM_TRAIT_TYPE_WEAPON_NIRNHONED})},
    {name = "Intricate", filterCallback = GetFilterCallbackForTrait({ITEM_TRAIT_TYPE_WEAPON_INTRICATE})},
    {name = "Ornate", filterCallback = GetFilterCallbackForTrait({ITEM_TRAIT_TYPE_WEAPON_ORNATE})},
}
local armorTraitDropdownCallbacks = {
    {name = "None", filterCallback = GetFilterCallbackForTrait({ITEM_TRAIT_TYPE_NONE})},
    {name = "Sturdy", filterCallback = GetFilterCallbackForTrait({ITEM_TRAIT_TYPE_ARMOR_STURDY})},
    {name = "Impenetrable", filterCallback = GetFilterCallbackForTrait({ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE})},
    {name = "Reinforced", filterCallback = GetFilterCallbackForTrait({ITEM_TRAIT_TYPE_ARMOR_REINFORCED})},
    {name = "Well Fitted", filterCallback = GetFilterCallbackForTrait({ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED})},
    {name = "Training", filterCallback = GetFilterCallbackForTrait({ITEM_TRAIT_TYPE_ARMOR_TRAINING})},
    {name = "Infused", filterCallback = GetFilterCallbackForTrait({ITEM_TRAIT_TYPE_ARMOR_INFUSED})},
    {name = "Exploration", filterCallback = GetFilterCallbackForTrait({ITEM_TRAIT_TYPE_ARMOR_EXPLORATION})},
    {name = "Divines", filterCallback = GetFilterCallbackForTrait({ITEM_TRAIT_TYPE_ARMOR_DIVINES})},
    {name = "Nirnhoned", filterCallback = GetFilterCallbackForTrait({ITEM_TRAIT_TYPE_ARMOR_NIRNHONED})},
    {name = "Intricate", filterCallback = GetFilterCallbackForTrait({ITEM_TRAIT_TYPE_ARMOR_INTRICATE, ITEM_TRAIT_TYPE_WEAPON_INTRICATE})},
    {name = "Ornate", filterCallback = GetFilterCallbackForTrait({ITEM_TRAIT_TYPE_ARMOR_ORNATE, ITEM_TRAIT_TYPE_WEAPON_ORNATE})},
}
local jewelryTraitDropdownCallbacks = {
    {name = "None", filterCallback = GetFilterCallbackForTrait({ITEM_TRAIT_TYPE_NONE})},
    {name = "Healthy", filterCallback = GetFilterCallbackForTrait({ITEM_TRAIT_TYPE_JEWELRY_HEALTHY})},
    {name = "Arcane", filterCallback = GetFilterCallbackForTrait({ITEM_TRAIT_TYPE_JEWELRY_ARCANE})},
    {name = "Robust", filterCallback = GetFilterCallbackForTrait({ITEM_TRAIT_TYPE_JEWELRY_ROBUST})},
    {name = "Ornate", filterCallback = GetFilterCallbackForTrait({ITEM_TRAIT_TYPE_JEWELRY_ORNATE})},
}

local strings = {
    ["Weapon Trait"] = AdvancedFilters.strings.WeaponTrait,
    ["Armor Trait"] = AdvancedFilters.strings.ArmorTrait,
    ["Jewelry Trait"] = AdvancedFilters.strings.Jewelry .. " " .. GetString(SI_SMITHING_HEADER_TRAIT),

    ["None"] = GetString(SI_ITEMTRAITTYPE0),
    ["Powered"] = GetString(SI_ITEMTRAITTYPE1),
    ["Charged"] = GetString(SI_ITEMTRAITTYPE2),
    ["Precise"] = GetString(SI_ITEMTRAITTYPE3),
    ["Infused"] = GetString(SI_ITEMTRAITTYPE4),
    ["Defending"] = GetString(SI_ITEMTRAITTYPE5),
    ["Training"] = GetString(SI_ITEMTRAITTYPE6),
    ["Sharpened"] = GetString(SI_ITEMTRAITTYPE7),
    ["Weighted"] = GetString(SI_ITEMTRAITTYPE8),
    ["Intricate"] = GetString(SI_ITEMTRAITTYPE9),
    ["Ornate"] = GetString(SI_ITEMTRAITTYPE10),

    ["Sturdy"] = GetString(SI_ITEMTRAITTYPE11),
    ["Impenetrable"] = GetString(SI_ITEMTRAITTYPE12),
    ["Reinforced"] = GetString(SI_ITEMTRAITTYPE13),
    ["Well Fitted"] = GetString(SI_ITEMTRAITTYPE14),
    ["Exploration"] = GetString(SI_ITEMTRAITTYPE17),
    ["Divines"] = GetString(SI_ITEMTRAITTYPE18),

    ["Healthy"] = GetString(SI_ITEMTRAITTYPE21),
    ["Arcane"] = GetString(SI_ITEMTRAITTYPE22),
    ["Robust"] = GetString(SI_ITEMTRAITTYPE23),

    ["Nirnhoned"] = GetString(SI_ITEMTRAITTYPE25),
    --["Special"] = GetString(SI_ITEMTRAITTYPE27),
}

local filterInformation = {
    submenuName = "Weapon Trait",
    callbackTable = weaponTraitDropdownCallbacks,
    filterType = ITEMFILTERTYPE_WEAPONS,
    subfilters = {"All",},
    enStrings = strings,
}
AdvancedFilters_RegisterFilter(filterInformation)

filterInformation.submenuName = "Armor Trait"
filterInformation.callbackTable = armorTraitDropdownCallbacks
filterInformation.filterType = ITEMFILTERTYPE_ARMOR
filterInformation.subfilters = {"Body", "Shield",}
AdvancedFilters_RegisterFilter(filterInformation)

filterInformation.submenuName = "Jewelry Trait"
filterInformation.callbackTable = jewelryTraitDropdownCallbacks
filterInformation.subfilters = {"Jewelry",}
AdvancedFilters_RegisterFilter(filterInformation)