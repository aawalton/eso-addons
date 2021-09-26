Armory = Armory or {}
Armory.ItemCollection = {}

---------------------------------------------------------------------------------------------------
-- getCollectionStatus : Fetches collected item sets (c) code65536                     ------------
---------------------------------------------------------------------------------------------------
function Armory.getCollectionStatus()
    local collected = 0
    local total = 0
    local setId = GetNextItemSetCollectionId()

    while (setId) do
        local setSize = GetNumItemSetCollectionPieces(setId)
        if (setSize > 0) then
            collected = collected + GetNumItemSetCollectionSlotsUnlocked(setId)
            total = total + setSize
        end
        setId = GetNextItemSetCollectionId(setId)
    end

    return collected, total
end
