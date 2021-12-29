local AGS = AwesomeGuildStore

local FilterBase = AGS.class.FilterBase
local ValueRangeFilterBase = AGS.class.ValueRangeFilterBase

local FILTER_ID = AGS.data.FILTER_ID
local SUB_CATEGORY_ID = AGS.data.SUB_CATEGORY_ID

local gettext = AGS.internal.gettext

local MIN_COUNT = 0
local MAX_COUNT = 2100000000

local TotalCountFilter = ValueRangeFilterBase:Subclass()
AGS.class.TotalCountFilter = TotalCountFilter

function TotalCountFilter:New(...)
    return ValueRangeFilterBase.New(self, ...)
end

function TotalCountFilter:Initialize()
    ValueRangeFilterBase.Initialize(self, FILTER_ID.TOTAL_COUNT_FILTER, FilterBase.GROUP_LOCAL, {
        -- TRANSLATORS: label of the total count filter
        label = gettext("Total Count Already Owned"),
        currency = CURT_MONEY,
        min = MIN_COUNT,
        max = MAX_COUNT,
        precision = 2,
        steps = { MIN_COUNT, 100000, 200000, 400000, 1000000, MAX_COUNT },
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

function TotalCountFilter:FilterLocalResult(itemData)
    local itemLink = itemData.itemLink
    local totalCount = TotalCountFilter.GetTotalCount(itemLink)
    if(self.localMin and totalCount < self.localMin) then
        return false
    elseif(self.localMax and totalCount > self.localMax) then
        return false
    end
    return true
end

function TotalCountFilter.GetTotalCount(itemLink) 
    local DBItem = IIfA.database[TotalCountFilter.GetItemID(itemLink)]

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

function TotalCountFilter.GetItemID(itemLink)
	local ret = nil
	if itemLink then
   		ret = tostring(GetItemLinkItemId(itemLink))
	end
	return ret
end