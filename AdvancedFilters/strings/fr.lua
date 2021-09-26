local util = AdvancedFilters.util
local enStrings = AdvancedFilters.ENstrings

local afPrefixNormal    = enStrings.AFPREFIXNORMAL
local afPrefixError     = string.format(enStrings.AFPREFIX, " ERREUR")

local strings = {
    --WEAPON
    OneHand = "Une main",
    TwoHand = "Deux mains",
    TwoHandAxe = "2M "..util.Localize(SI_WEAPONTYPE1),
    TwoHandSword = "2M "..util.Localize(SI_WEAPONTYPE3),
    TwoHandHammer = "2M "..util.Localize(SI_WEAPONTYPE2),

    Repair = "Réparation",

    --MATERIALS
    Blacksmithing = "Forge",
    Clothier = "Couture",
    Woodworking = "Travail du bois",
    Alchemy = "Alchimie",
    Enchanting = "Enchantement",
    Provisioning = "Approvisionnement",

    Glyphs = "Glyphes",

    --DROPDOWN CONTEXT MENU
    ResetToAll           = "Tout réinitialiser",
    InvertDropdownFilter = "Inverser filtre: %s",

    --LAM settings menu
    lamDescription = "",
    lamHideItemCount = "Cacher le compteur d'objet",
    lamHideItemCountTT = "Cache le nombre d'objets présents dans la sous-catégorie (affiché entre parenthèses en bas de l'inventaire à côté du nombre d'objet total).",
    lamHideItemCountColor = "Couleur du compteur d'objet",
    lamHideItemCountColorTT = "Détermine la couleur du compteur d'objet affiché en bas de l'inventaire.",
    lamHideSubFilterLabel = "Cacher le nom de la sous-catégorie",
    lamHideSubFilterLabelTT = "Retire le texte indiquant le nom de la sous-catégorie (affiché en haut de l'inventaire à gauche).",
    lamGrayOutSubFiltersWithNoItems = "Désactiver les sous-catégories sans objets",
    lamGrayOutSubFiltersWithNoItemsTT = "Masque le bouton des sous-catégories ne comportant aucun objet.",
    lamShowIconsInFilterDropdowns = "Afficher les icônes dans le menu déroulant",
    lamShowIconsInFilterDropdownsTT = "Affiche les icônes des sous-catégories d'objet dans le menu déroulant de filtrage par type d'objet.",
    lamDebugOutput = "Déboguage",

    --Error messages
    errorCheckChatPlease    = afPrefixError .. " Veuillez lire le message d'erreur du chat!",
    errorLibrayMissing      = afPrefixError .. " La bibliothèque requise \'%s\' n'est pas chargée. Cet addon ne fonctionnera pas correctement!",
}

setmetatable(strings, {__index = enStrings})
AdvancedFilters.strings = strings
