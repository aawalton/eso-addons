NetWorth = {}

local SlashCommandHelper = ZO_Object:Subclass()

function SlashCommandHelper:New(...)
    local obj = ZO_Object.New(self)
    obj:Initialize(...)
    return obj
end

function SlashCommandHelper:Initialize()
    local function SlashCommandCallback()
        return self:SlashCommandCallback()
    end

    self.command = LibSlashCommander:Register({"/networth", "/nw", "/nm"}, SlashCommandCallback, "Calculate net worth of all assets")
end

function SlashCommandHelper:SlashCommandCallback()
    -- iterate over items in IIfA
    local networth = 0
    for itemIdOrLink, DBItem in pairs(IIfA.database) do
        -- find the item link
        local itemLink
        if NetWorth:IsItemLink(itemIdOrLink) then
            itemLink = itemIdOrLink
        else
            itemLink = NetWorth.GetItemLinkFromItemId(itemIdOrLink)
        end

        -- skip bound items
        local isBound = IsItemLinkBound( itemLink )
        if not isBound then

            -- get price
            local price = (LibPrice.ItemLinkToPriceGold(itemLink) or 0) / 1.20

            -- get count
            local itemCount = 0
            for locname, data in pairs(DBItem.locations) do
                for bagSlot, qty in pairs(data.bagSlot) do
                    itemCount = itemCount + (qty or 0)
                end
            end

            -- accumulate value
            local value = itemCount * price
            networth = networth + value
            -- if value > 10000000 then
            --     d(itemLink)
            --     d(string.format("%s x %s = %s", CommaValue(itemCount), CommaValue(price), CommaValue(value), itemLink))
            -- end
        end
    end

    local totalCurrency = NetWorth.GetTotalCurrency()
    networth = networth + totalCurrency

    d(string.format("Total net worth: %s", CommaValue(networth)))

end

function NetWorth:IsItemLink(link)
	local _, _, type = ZO_LinkHandler_ParseLink(link)
	return type == "item"
end

function NetWorth.GetItemLinkFromItemId(itemId)
    return string.format("|H1:item:%d:%d:50:0:0:0:0:0:0:0:0:0:0:0:0:%d:%d:0:0:%d:0|h|h", itemId, 0, ITEMSTYLE_NONE, 0, 10000)
end

function CommaValue(amount)
    local formatted = amount
    while true do  
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k==0) then
        break
        end
    end
    return formatted
end

function NetWorth.GetTotalCurrency()

    local totalGold = 0
    local totalTV = 0
    local totalAP = 0
    local totalWV = 0
    local assets = IIfA.data.assets

    for i=1, GetNumCharacters() do
        local charName, _, _, _, _, alliance, charId, _ = GetCharacterInfo(i)
        charName = zo_strformat(SI_UNIT_NAME, charName)

        if assets[charId] ~= nil then
            totalGold = totalGold + (assets[charId].gold or 0)
            totalTV = totalTV + (assets[charId].tv or 0)
            totalAP = totalAP + (assets[charId].ap or 0)
            totalWV = totalWV + (assets[charId].wv or 0)
        end

    end
    -- d(string.format("Total Gold: %s", CommaValue(totalGold)))
    -- d(string.format("Total Tel Var: %s", CommaValue(totalTV * 3)))
    -- d(string.format("Total Alliance Points: %s", CommaValue(totalAP / 5)))
    -- d(string.format("Total Writ Vouchers: %s", CommaValue(totalWV * 1000)))
    return totalGold + totalTV * 3 + totalAP / 5 + totalWV * 1000
end

NetWorth.SlashCommandHelper = SlashCommandHelper:New()
