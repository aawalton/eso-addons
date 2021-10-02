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

local TotalValueFilter = ValueRangeFilterBase:Subclass()
AGS.class.TotalValueFilter = TotalValueFilter

function TotalValueFilter:New(...)
    return ValueRangeFilterBase.New(self, ...)
end

function TotalValueFilter:Initialize()
    ValueRangeFilterBase.Initialize(self, FILTER_ID.TOTAL_VALUE_FILTER, FilterBase.GROUP_LOCAL, {
        -- TRANSLATORS: label of the total value filter
        label = gettext("Total Value Already Owned"),
        currency = CURT_MONEY,
        min = MIN_VALUE,
        max = MAX_VALUE,
        precision = 2,
        steps = { MIN_VALUE, 100000, 200000, 400000, 1000000, MAX_VALUE },
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

local rawItemTypes = {
    [ITEMTYPE_BLACKSMITHING_RAW_MATERIAL] = true,
    [ITEMTYPE_CLOTHIER_RAW_MATERIAL] = true,
    [ITEMTYPE_WOODWORKING_RAW_MATERIAL] = true,
    [ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL] = true,
    [ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER] = true,
    [ITEMTYPE_RAW_MATERIAL] = true,
    [ITEMTYPE_JEWELRY_RAW_TRAIT] = true,
}

function TotalValueFilter:FilterLocalResult(itemData)
    local totalValue = TotalValueFilter.GetTotalValue(itemData)
    if(self.localMin and totalValue < self.localMin) then
        return false
    elseif(self.localMax and totalValue > self.localMax) then
        return false
    end

    if (self.localMin or self.localMax) then
        local itemType = GetItemLinkItemType(itemData.itemLink)    
        if (rawItemTypes[itemType]) then return false end
    end
    return true
end

function TotalValueFilter.GetTotalValue(itemData)
    local stackPrice = itemData.purchasePrice / itemData.stackCount
    return TotalValueFilter.GetTotalCount(itemData.itemLink) * stackPrice
end

function TotalValueFilter.GetTotalCount(itemLink) 
    local totalValue = 0
    local DBItem = IIfA.database[TotalValueFilter.GetItemID(itemLink)]

    local itemCount = 0
    if (DBItem) then
        for locname, data in pairs(DBItem.locations) do
            for bagSlot, qty in pairs(data.bagSlot) do
                itemCount = itemCount + (qty or 0)
            end
        end
    end
    return itemCount
end

function TotalValueFilter.GetPrice(itemLink)
    return (LibPrice.ItemLinkToPriceGold(itemLink) or 0) / 1.20
end

function TotalValueFilter.GetItemID(itemLink)
	local ret = nil
	if itemLink then
   		ret = tostring(GetItemLinkItemId(itemLink))
	end
	return ret
end