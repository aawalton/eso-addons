local AGS = AwesomeGuildStore

local FilterBase = AGS.class.FilterBase
local ValueRangeFilterBase = AGS.class.ValueRangeFilterBase

local FILTER_ID = AGS.data.FILTER_ID
local SUB_CATEGORY_ID = AGS.data.SUB_CATEGORY_ID

local gettext = AGS.internal.gettext
local GetItemLinkWritVoucherCount = AGS.internal.GetItemLinkWritVoucherCount

local GetItemLinkItemType = GetItemLinkItemType

local ITEMTYPE_MASTER_WRIT = ITEMTYPE_MASTER_WRIT


local MIN_VALUE = 0
local MAX_VALUE = 2100000000

local UnitValueFilter = ValueRangeFilterBase:Subclass()
AGS.class.UnitValueFilter = UnitValueFilter

function UnitValueFilter:New(...)
    return ValueRangeFilterBase.New(self, ...)
end

function UnitValueFilter:Initialize()
    ValueRangeFilterBase.Initialize(self, FILTER_ID.UNIT_VALUE_FILTER, FilterBase.GROUP_LOCAL, {
        -- TRANSLATORS: label of the unit value filter
        label = gettext("Unit Value"),
        currency = CURT_MONEY,
        min = MIN_VALUE,
        max = MAX_VALUE,
        precision = 2,
        steps = { MIN_VALUE, 0.9, 1.0, 1.1, 1.2, MAX_VALUE },
        enabled = {
            [SUB_CATEGORY_ID.CONSUMABLE_ALL] = true,
            [SUB_CATEGORY_ID.CONSUMABLE_FOOD] = true,
            [SUB_CATEGORY_ID.CONSUMABLE_DRINK] = true,
            [SUB_CATEGORY_ID.CONSUMABLE_RECIPE] = true,
            [SUB_CATEGORY_ID.CONSUMABLE_POTION] = true,
            [SUB_CATEGORY_ID.CONSUMABLE_POISON] = true,
            [SUB_CATEGORY_ID.CONSUMABLE_WRIT] = true,
            [SUB_CATEGORY_ID.CONSUMABLE_MOTIF] = true,
            [SUB_CATEGORY_ID.CONSUMABLE_TOOL] = true,
            [SUB_CATEGORY_ID.CONSUMABLE_TROPHY] = true,
            [SUB_CATEGORY_ID.CRAFTING_ALL] = true,
            [SUB_CATEGORY_ID.CRAFTING_BLACKSMITHING] = true,
            [SUB_CATEGORY_ID.CRAFTING_CLOTHIER] = true,
            [SUB_CATEGORY_ID.CRAFTING_WOODWORKING] = true,
            [SUB_CATEGORY_ID.CRAFTING_JEWELRY] = true,
            [SUB_CATEGORY_ID.CRAFTING_ALCHEMY] = true,
            [SUB_CATEGORY_ID.CRAFTING_ENCHANTING] = true,
            [SUB_CATEGORY_ID.CRAFTING_PROVISIONING] = true,
            [SUB_CATEGORY_ID.CRAFTING_STYLE_MATERIAL] = true,
            [SUB_CATEGORY_ID.CRAFTING_TRAIT_MATERIAL] = true,
            [SUB_CATEGORY_ID.CRAFTING_FURNISHING_MATERIAL] = true,
            [SUB_CATEGORY_ID.MISCELLANEOUS_ALL] = true,
            [SUB_CATEGORY_ID.MISCELLANEOUS_SOUL_GEM] = true,
            [SUB_CATEGORY_ID.MISCELLANEOUS_FISHING] = true,
            [SUB_CATEGORY_ID.MISCELLANEOUS_TOOL] = true,
            [SUB_CATEGORY_ID.MISCELLANEOUS_TROPHY] = true,
        }
    })
end

function UnitValueFilter:FilterLocalResult(itemData)
    local suggestedPrice = UnitValueFilter.GetPrice(itemData.itemLink)
    local stackPrice = itemData.purchasePrice / itemData.stackCount
    local unitValue = stackPrice / suggestedPrice
    if(self.localMin and unitValue < self.localMin) then
        return false
    elseif(self.localMax and unitValue > self.localMax) then
        return false
    end
    return true
end

function UnitValueFilter.GetPrice(itemLink)
    return (LibPrice.ItemLinkToPriceGold(itemLink) or 0) / 1.20
end
