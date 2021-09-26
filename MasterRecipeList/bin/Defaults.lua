local ESOMRL = _G['ESOMRL']
ESOMRL.DB.Strings = ESOMRL:GetLanguage()
--[[
Saved variable values:
0 = unknown untracked
1 = unknown tracked
2 = known tracked
3 = known untracked

/script SetCVar("Language.2", "en")
/script SetCVar("Language.2", "fr")
/script SetCVar("Language.2", "de")
/script d(GetAPIVersion())

Zgoo.CommandHandler(control:GetName())
--]]


-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Character-specific addon settings.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local CharacterDefaults = {
	pRecipeTrack = {},					-- database of food recipe tracking status for this character
	fRecipeTrack = {},					-- database of furniture recipe tracking status for this character
	cOpts = {
	-- Character Status
		trackChar=true,					-- enable tracking this character's recipe data

	--	FCO ItemSaver Support
		fcoitemsaverCO=false,			-- lock current character unknown recipes
	},
}

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Account-wide addon settings.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local AccountDefaults = {
	pRecipeKnown = {},					-- database of food recipes and known status of all tracking characters
	fRecipeKnown = {},					-- database of furniture recipes and known status of all tracking characters
	aIngTrack = {},						-- database of ingredient tracking status

	aOpts = {

	-- Database version tracking
		version=0,							-- current running version
		APIversion=0,						-- tracks current running API version to only update database when client changes

	-- Inventory Icon Options
		inventoryicons=true,				-- enable inventory icons
		inventoryIT=true,					-- enable inventory icon tooltips
		inventoryTI=false,					-- enable icon text overlay
		inventoryT=true,					-- show recipe tracking icons
		inventoryW=true,					-- show writ status icons
		inventoryCK=true,					-- show current character's known recipes
		inventoryCU=false,					-- show current character's unknown recipes
		tchartK=false,                  	-- show tracking character's known recipes
		tchart=false,                   	-- enable tracking character
		foodtrackingchar="",            	-- food tracking character
		furntrackingchar="",            	-- furniture tracking character
		bagiconoffset=74,					-- inventory icon position
		storeiconoffset=24,					-- NPC vendor icon position
		gstoreiconoffset=125,           	-- guild store search result icon position
		glistingiconoffset=110,         	-- guild store listing icon position

	-- Item Tooltip Options
		known=true,							-- show 'known by' in tooltips
		sortAlpha=true,						-- alphabetize 'known by' list
		kSformat=4,							-- format for 'known by' text
		ttcolorkT={0.4,0.8,1,1},        	-- known recipe color
		ttcolork="66ccff",              	-- known recipe color (text hex)
		ttcoloruT={0.5,0.5,0.5,1},      	-- unknown recipe color
		ttcoloru="808080",              	-- unknown recipe color (text hex)
		ingrecs=true,						-- show detailed ingredients info on recipe items
		ingrecsgs=false,					-- no detailed ingredients on recipe items at guild store
		ingfood=false,						-- show detailed ingredients info on result items
		ingfoodgs=false,					-- no detailed ingredients on result items at guild store
		ingcolors=true,						-- color the ingredient list by quality
		furnCats=true,						-- show housing editor furniture category on furniture recipes and result items

	-- Auto Destroy Options
		destroyjunkrecipes=false,       	-- destroy junk recipes
		destroyjunkingredients=false,   	-- destroy junk ingredients
		ignorestolen=true,              	-- ignore Stolen Items
		debugmode=true,                 	-- enable debug mode
		maxjunkquality=2,               	-- color quality protection
		maxjunkstack=10,                	-- max amount to destroy

	-- Cooking Station Options
		opControls=true,					-- option to only show MRL controls at provisioning station
		noFilters=false,					-- clear filters on startup
		ingFilter=3,						-- override crafting station filter checkbox for "Have Ingredients"
		skillFilter=3,						-- override crafting station filter checkbox for "Have Skill"
		questFilter=3,						-- override crafting station filter checkbox for "Quest Only"
		stationstats=true,					-- cooking station stat icons
		stationicons=1,						-- stat icon style
		autoWrits=false,					-- automatically craft provisioning writs without needing to click categories
		sortByLevel=true,					-- option to sort individual cooking recipes by level or alphabetically
		sortAscending=true,					-- allows toggle for sorting ascending or descending at the cooking station

	--	FCO ItemSaver Support
		fcoitemsaverU=false,            	-- lock tracking character unknown recipes
		fcoitemsaverT=false,            	-- lock tracked items

	-- GUI state variables
		xpos=0,                         	-- GUI horizontal offset (for remembering last position)
		ypos=0,                         	-- GUI vertical offset (for remembering last position)
		export_xpos=0,						-- Export window X position
		export_ypos=0,						-- Export window Y position
		sttx={},                         	-- Crafting station tooltip horizontal offset (for remembering last position)
		stty={},                         	-- Crafting station tooltip vertical offset (for remembering last position)
		kOnly=false,						-- Toggle only showing known recipes in the app recipe list display
		uOnly=false,						-- Toggle only showing unknown recipes in the app recipe list display
		lttshow=1,                      	-- enable/disable GUI popup tooltips
		sttshow=1,                      	-- enable/disable cooking station popup tooltips
		stmarked=1,                     	-- enable/disable highlighting tracked recipes at cooking station
		tooltipstyle=0,                 	-- switch between showing recipe or result item in GUI tooltips 
		recipeconfigpanel=0,            	-- show the GUI recipe tracking config panel
		previewicon=true,					-- show icon next to furniture recipes that can be right-click 3d-previewed
		junkunmarkedrecipes=0,          	-- pin toggle required to confirm junking unmarked recipes when enabled
		junkunmarkedingredients=0,      	-- pin toggle required to confirm junking unmarked ingredients when enabled
		destroyunmarkedrecipes=0,       	-- pin toggle required to confirm destroying unmarked recipes when enabled
		destroyunmarkedingredients=0,   	-- pin toggle required to confirm destroying unmarked ingredients when enabled
	},

	mRecipeList = {							-- all current recipes & ingredients for speed and auto-update
		Provisioning = {},
		Furniture = {},
		Ingredients = { -- starter table of base game ingredients for normal type food and drinks (all the old original ingredients from before furniture was added)
			[34349] =	"/esoui/art/icons/crafting_acai_berry.dds",					-- Acai Berry
			[34311] =	"/esoui/art/icons/provisioner_apple.dds",					-- Apples
			[33755] =	"/esoui/art/icons/crafting_bananas.dds",					-- Bananas
			[34329] =	"/esoui/art/icons/crafting_components_bread_006.dds",		-- Barley
			[34309] =	"/esoui/art/icons/crafting_beets.dds",						-- Beets
			[27059] =	"/esoui/art/icons/crafting_components_malt_003.dds",		-- Bervez Juice
			[34334] =	"/esoui/art/icons/crafting_components_veg_003.dds",			-- Bittergreen
			[34324] =	"/esoui/art/icons/crafting_carrots.dds",					-- Carrots
			[27057] =	"/esoui/art/icons/quest_trollfat_001.dds",					-- Cheese
			[33772] =	"/esoui/art/icons/crafting_coffee_beans.dds",				-- Coffee
			[33768] =	"/esoui/art/icons/crafting_comberries.dds",					-- Comberry
			[34323] =	"/esoui/art/icons/crafting_corn.dds",						-- Corn
			[33753] =	"/esoui/art/icons/crafting_cooking_fish_fillet.dds",		-- Fish
			[27100] =	"/esoui/art/icons/quest_dust_001.dds",						-- Flour
			[26802] =	"/esoui/art/icons/crafting_plant_creature_vines.dds",		-- Frost Mirriam
			[28609] =	"/esoui/art/icons/crafting_vendor_fuel_meat_001.dds",		-- Game
			[26954] =	"/esoui/art/icons/crafting_components_spice_003.dds",		-- Garlic
			[27052] =	"/esoui/art/icons/crafting_components_gin_002.dds",			-- Ginger
			[34346] =	"/esoui/art/icons/crafting_components_gin_005.dds",			-- Ginkgo
			[34347] =	"/esoui/art/icons/crafting_ginseng.dds",					-- Ginseng
			[28604] =	"/esoui/art/icons/crafting_cabbage.dds",					-- Greens
			[34333] =	"/esoui/art/icons/crafting_components_berry_002.dds",		-- Guarana
			[27043] =	"/esoui/art/icons/quest_honeycomb_001.dds",					-- Honey
			[27035] =	"/esoui/art/icons/crafting_wood_gum.dds",					-- Isinglass
			[33771] =	"/esoui/art/icons/crafting_smith_potion_vendor_003.dds",	-- Jasmine
			[28610] =	"/esoui/art/icons/crafting_grapes.dds",						-- Jazbay Grapes
			[27049] =	"/esoui/art/icons/crafting_lemons.dds",						-- Lemon
			[34330] =	"/esoui/art/icons/quest_flower_001.dds",					-- Lotus
			[34308] =	"/esoui/art/icons/crafting_melo.dds",						-- Melon
			[27048] =	"/esoui/art/icons/crafting_components_malt_004.dds",		-- Metheglin
			[27064] =	"/esoui/art/icons/crafting_components_bread_004.dds",		-- Millet
			[33773] =	"/esoui/art/icons/crafting_components_spice_004.dds",		-- Mint
			[33758] =	"/esoui/art/icons/crafting_components_veg_001.dds",			-- Potato
			[34321] =	"/esoui/art/icons/crafting_cooking_grilled_chicken.dds",	-- Poultry
			[34305] =	"/esoui/art/icons/crafting_pumpkin.dds",					-- Pumpkin
			[34307] =	"/esoui/art/icons/crafting_radish.dds",						-- Radish
			[33752] =	"/esoui/art/icons/quest_food_003.dds",						-- Red Meat
			[29030] =	"/esoui/art/icons/crafting_components_bread_001.dds",		-- Rice
			[28636] =	"/esoui/art/icons/crafting_flower_mountain_flower_r2.dds",	-- Rose
			[28639] =	"/esoui/art/icons/crafting_components_bread_005.dds",		-- Rye
			[27063] =	"/esoui/art/icons/monster_plant_creature_seeds_001.dds",	-- Saltrice
			[27058] =	"/esoui/art/icons/quest_dust_004.dds",						-- Seasoning
			[28666] =	"/esoui/art/icons/crafting_cloth_stems.dds",				-- Seaweed
			[33756] =	"/esoui/art/icons/crafting_critter_rodent_toes.dds",		-- Small Game
			[34345] =	"/esoui/art/icons/crafting_components_berry_004.dds",		-- Surilie Grapes
			[28603] =	"/esoui/art/icons/crafting_components_veg_005.dds",			-- Tomato
			[34348] =	"/esoui/art/icons/crafting_components_bread_002.dds",		-- Wheat
			[33754] =	"/esoui/art/icons/crafting_critter_dom_animal_fat.dds",		-- White Meat
			[33774] =	"/esoui/art/icons/crafting_components_bread_003.dds",		-- Yeast
			[34335] =	"/esoui/art/icons/quest_bandage_001.dds",					-- Yerba Mate
		},
	}
}

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Saved Variable Initialization
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ESOMRL.DB.SetupVars()
	local worldName = GetWorldName()
	local displayName = GetDisplayName()

	if MasterRecipeList then
		if MasterRecipeList.Default ~= nil then -- remove the old non-Megaserver specific variables table
			MasterRecipeList.Default = nil
		end
		if MasterRecipeList[worldName] and MasterRecipeList[worldName][displayName] then -- clear out old obsolete saved variables for new ID-based
			local version = MasterRecipeList[worldName][displayName]["$AccountWide"]["AccountSettings"].aOpts.version
			if version and version < 1.5635 then
				MasterRecipeList = {}
			end
		end	
	end

	ESOMRL.CSV = ZO_SavedVars:NewCharacterIdSettings('MasterRecipeList', 1.5635, 'CharacterSettings', CharacterDefaults, worldName)
	ESOMRL.ASV = ZO_SavedVars:NewAccountWide('MasterRecipeList', 1.5635, 'AccountSettings', AccountDefaults, worldName)

end

function ESOMRL.DB.DefaultVars(opt)
	if opt == 1 then
		return AccountDefaults.mRecipeList.Ingredients
	else
		return CharacterDefaults.cOpts, AccountDefaults.aOpts
	end
end
