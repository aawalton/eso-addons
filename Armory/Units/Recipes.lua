Armory = Armory or {}

---------------------------------------------------------------------------------------------------
-- Recipes : Fetches known recipes                                                     ------------
---------------------------------------------------------------------------------------------------
function Armory.getRecipes()
    recipes = {}
    knownRecipes = {}

    -- Get recipes count
    numRecipeLists = GetNumRecipeLists()
    for recipeListIndex = 1, numRecipeLists do
        -- Fetch each index option
        recipes[recipeListIndex] = {
            GetRecipeListInfo(recipeListIndex)
        }

        -- Fetch index recipes
        recipes[recipeListIndex]['recipes'] = {}
        for recipeIndex = 1, recipes[recipeListIndex][2] do
            recipes[recipeListIndex]['recipes'][recipeIndex] = {}

            -- Add basic info
            recipes[recipeListIndex]['recipes'][recipeIndex]['Info'] = {
                GetRecipeInfo(recipeListIndex, recipeIndex)
            }

            -- Add known status
            local known, name = GetRecipeInfo(recipeListIndex, recipeIndex)
            if known then
                knownRecipes[recipeListIndex .. '/' .. recipeIndex] = name
            end

            -- Add item extra info
            recipes[recipeListIndex]['recipes'][recipeIndex]['ResultItemInfo'] = {
                GetRecipeResultItemInfo(recipeListIndex, recipeIndex)
            }

            -- Add ingredients
            recipes[recipeListIndex]['recipes'][recipeIndex]['Ingredients'] = {}
            for ingredientIndex = 1, recipes[recipeListIndex]['recipes'][recipeIndex]['Info'][3] do
                recipes[recipeListIndex]['recipes'][recipeIndex]['Ingredients'][ingredientIndex] = {
                    GetRecipeIngredientItemInfo(recipeListIndex, recipeIndex, ingredientIndex)
                }
            end
        end
    end

    if Armory.fetchAllData then
        return recipes
    end

    return knownRecipes
end
