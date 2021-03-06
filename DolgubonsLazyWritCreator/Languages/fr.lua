-----------------------------------------------------------------------------------
-- Addon Name: Dolgubon's Lazy Writ Crafter
-- Creator: Dolgubon (Joseph Heinzle)
-- Addon Ideal: Simplifies Crafting Writs as much as possible
-- Addon Creation Date: March 14, 2016
--
-- File Name: Languages/fr.lua
-- File Description: French Localization
-- Load Order Requirements: None
-- 
-----------------------------------------------------------------------------------

function WritCreater.langWritNames() --Exacts!!!  I know for german alchemy writ is Alchemistenschrieb - so ["G"] = schrieb, and ["A"]=Alchemisten
	local names = {
	["G"] = "Commande",
	[CRAFTING_TYPE_ENCHANTING] = "d'enchantement",
	[CRAFTING_TYPE_BLACKSMITHING] = "forge",
	[CRAFTING_TYPE_CLOTHIER] = "tailleur",
	[CRAFTING_TYPE_PROVISIONING] = "cuisine",
	[CRAFTING_TYPE_WOODWORKING] = "bois",
	[CRAFTING_TYPE_ALCHEMY] = "d'alchimie",
	[CRAFTING_TYPE_JEWELRYCRAFTING] = "joaillerie",
	}
	return names
end

function WritCreater.writCompleteStrings()
	local strings = {
	["place"] = "Placer les produits dans la caisse",
	["sign"] = "Signer le manifeste",
	["masterStart"] = "<Accepter le contrat>",
	["masterSign"] = "<Finir le travail.>",
	["masterPlace"] = "J'ai accompli la t",
	["Rolis Hlaalu"] = "Rolis Hlaalu",
	["Deliver"] = "Livre",
	}
	return strings
end


local function myLower(str)
	return zo_strformat("<<z:1>>",str)
end

function WritCreater.langCraftKernels()
	return 
	{
		["enchante"] = CRAFTING_TYPE_ENCHANTING,
		["forge"] = CRAFTING_TYPE_BLACKSMITHING,
		["couture"] = CRAFTING_TYPE_CLOTHIER,
		["tailleur"] = CRAFTING_TYPE_CLOTHIER,
		["cuisine"] = CRAFTING_TYPE_PROVISIONING,
		["bois"] = CRAFTING_TYPE_WOODWORKING,
		["alchimi"] = CRAFTING_TYPE_ALCHEMY,
		["joaillier"] = CRAFTING_TYPE_JEWELRYCRAFTING,
	}
end

function WritCreater.getWritAndSurveyType()
	if not WritCreater.langCraftKernels then return end
	
	local kernels = WritCreater.langCraftKernels()
	local craftType
	for kernel, craft in pairs(kernels) do
		if string.find(myLower(itemName), myLower(kernel)) then
			craftType = craft
		end
	end
	return craftType
end

function WritCreater.langMasterWritNames()
	local names = {
	["M"] 							= "magistral",
	["M1"] 							= "magistral",
	[CRAFTING_TYPE_ALCHEMY]			= "concoction",
	[CRAFTING_TYPE_ENCHANTING]		= "glyphe",
	[CRAFTING_TYPE_PROVISIONING]	= "festin",
	["plate"]						= "protection",
	["tailoring"]					= "tenue",
	["leatherwear"]					= "v??tement",
	["weapon"]						= "arme",
	["shield"]						= "bouclier",
	}
return names

end

function WritCreater.languageInfo() --exacts!!!

local craftInfo = 
	{
		[ CRAFTING_TYPE_CLOTHIER] = 
		{
			["pieces"] = --exact!!
			{
				[1] = "robe",
				[2] = "pourpoint",
				[3] = "chaussures",
				[4] = "gants",
				[5] = "chapeau",
				[6] = "braies",
				[7] = "??paulettes",
				[8] = "baudrier",
				[9] = "gilet",
				[10]= "bottes",
				[11]= "brassards",
				[12]= "casque",
				[13]= "gardes",
				[14]= "??paules",
				[15]= "ceinture",
			},
			["match"] = --exact!!! This is not the material, but rather the prefix the material gives to equipment. e.g. Homespun Robe, Linen Robe
			{
				[1] = "artisanal", --lvtier one of mats
				[2] = "lin",	--l
				[3] = "coton",
				[4] = "araign??e",
				[5] = "??bonite",
				[6] = "kresh",
				[7] = "fer",
				[8] = "argent",
				[9] = "tissombre",
				[10]= "ancestrale",
				[11]= "brut",
				[12]= "peau",
				[13]= "cuir",
				[14]= "compl??te",
				[15]= "d??chue",
				[16]= "clout??",
				[17]= "ferhide",
				[18]= "superbes",
				[19]= "ombre",
				[20]= "pourpre",
			},
			["names"] = --Does not strictly need to be exact, but people would probably appreciate it
			{
				[1] = "Jute",
				[2] = "Flax",
				[3] = "Cotton",
				[4] = "Spidersilk",
				[5] = "Ebonthread",
				[6] = "Kresh Fiber",
				[7] = "Ironthread",
				[8] = "Silverweave",
				[9] = "Void Cloth",
				[10]= "Ancestor Silk",
				[11]= "Rawhide",
				[12]= "Hide",
				[13]= "Leather",
				[14]= "Thick Leather",
				[15]= "Fell Hide",
				[16]= "Topgrain Hide",
				[17]= "Iron Hide",
				[18]= "Superb Hide",
				[19]= "Shadowhide",
				[20]= "Rubedo Leather",
			}		
		},
		[CRAFTING_TYPE_BLACKSMITHING] = 
		{
			["pieces"] = --exact!!
			{
				[1] = "hache",
				[2] = "masse",
				[3] = "??p??e",
				[4] = "bataille",
				[5] = "arme",
				[6] = "longue",
				[7] = "dague",
				[8] = "cuirasse",
				[9] = "solerets",
				[10] = "gantelet",
				[11] = "heaume",
				[12] = "gr??ves",
				[13] = "spalli??re",
				[14] = "gaine",
			},
			["match"] = --exact!!! This is not the material, but rather the prefix the material gives to equipment. e.g. Iron Axe, Steel Axe
			{
				[1] = "fer",
				[2] = "acier",
				[3] = "orichalque",
				[4] = "dwemer",
				[5] = "??bonite",
				[6] = "calcinium",
				[7] = "galatite",
				[8] = "mercure",
				[9] = "vide",
				[10]= "cuprite",
			},
			["names"] = --Does not strictly need to be exact, but people would probably appreciate it
			{
				[1] = "Iron Ingots",
				[2] = "Steel Ingots",
				[3] = "Orichalc Ingots",
				[4] = "Dwarven Ingots",
				[5] = "Ebony Ingots",
				[6] = "Calcinium Ingots",
				[7] = "Galatite Ingots",
				[8] = "Quicksilver Ingots",
				[9] = "Voidsteel Ingots",
				[10]= "Rubedite Ingots",
			}
		},
		[CRAFTING_TYPE_WOODWORKING] = 
		{
			["pieces"] = --Exact!!!
			{
				[1] = "arc",
				[3] = "infernal",
				[4] ="glace",
				[5] ="foudre",
				[6] ="r??tablissement",
				[2] ="bouclier",
			},
			["match"] = --exact!!! This is not the material, but rather the prefix the material gives to equipment. e.g. Maple Bow. Oak Bow.
			{
				[1] = "??rable",
				[2] =  "ch??ne",
				[3] =  "h??tre",
				[4] = "noyer",
				[5] = "if",
				[6] =  "bouleau",
				[7] = "fr??ne",
				[8] = "acajou",
				[9] = "nuit",
				[10] = "roux",
			},
			["names"] = --Does not strictly need to be exact, but people would probably appreciate it
			{
				[1] = "Sanded Maple",
				[2] = "Sanded Oak",
				[3] = "Sanded Beech",
				[4] = "Sanded Hickory",
				[5] = "Sanded Yew",
				[6] = "Sanded Birch",
				[7] = "Sanded Ash",
				[8] = "Sanded Mahogany",
				[9] = "Sanded Nightwood",
				[10]= "Sanded Ruby Ash",
			}
		},
		[CRAFTING_TYPE_JEWELRYCRAFTING] = 
		{
			["pieces"] = --Exact!!!
			{
				[1] = "anneau",
				[2] = "collier",

			},
			["match"] = --exact!!! This is not the material, but rather the prefix the material gives to equipment. e.g. Maple Bow. Oak Bow.
			{
				[1] = "??tain", -- 1
				[2] = "cuivre", -- 26
				[3] = "argent", -- CP10
				[4] = "??lectrum", --CP80
				[5] = "platine", -- CP150
			},

		},
		[CRAFTING_TYPE_ENCHANTING] = 
		{
			["pieces"] = --exact!!
			{
				{"vigoureux",45833,1},
				{"vital",45831,1},
				{"magie",45832,1},
			},
			["match"] = --exact!!! The names of glyphs. The prefix (in English) So trifling glyph of magicka, for example
			{
				{"insignifiant",45855},
				{"inf??rieur",45856},
				{"petit",45857},
				{"l??ger",45806},
				{"mineur",45807},
				{"lesser",45808},
				{"mod??r??",45809},
				{"moyen",45810},
				{"fort",45811},
				{"bon",45812},
				{"majeur",45813},
				{"grandiose",45814},
				{"splendide",45815},
				{"monumental",45816},
				{"vraiment",{68341,68340}},
				{"superbe",{64509,64508}},
				
			},
			["quality"] = 				
			{
				{"??pique",45853},
				{"l??gendaire",45854},
				{"", 45850} -- default, if nothing is mentioned
			}
		},
	}

	return craftInfo

end

function WritCreater.masterWritQuality()
	return {{"??pique",4},{"l??gendaire",5}}
end


function WritCreater.langEssenceNames() --exact!

local essenceNames =  
	{
		[1] = "oko", --health
		[2] = "deni", --stamina
		[3] = "makko", --magicka
	}
	return essenceNames
end

function WritCreater.langPotencyNames() --exact!! Also, these are all the positive runestones - no negatives needed.
	local potencyNames = 
	{
		[1] = "Jora", --Lowest potency stone lvl
		[2] = "Porade",
		[3] = "J??ra",
		[4] = "Jejora",
		[5] = "Odra",
		[6] = "Pojora",
		[7] = "Edora",
		[8] = "Jaera",
		[9] = "Pora",
		[10]= "Denara",
		[11]= "R??ra",
		[12]= "D??rado",
		[13]= "Rekura",
		[14]= "Kura",
		[15]= "Rejera",
		[16]= "Repora", --v16 potency stone
		
	}
	return potencyNames
end

local enExceptions = {
	["original"]  = {
		[1] = "sant??",
		[2] = "vigueur",
		[3] = "magique",
	},
	["corrected"] = {
		[1] = "vital",
		[2] = "vigoureux",
		[3] = "magie",
	},
}


function WritCreater.bankExceptions(condition)
	if string.find(condition, "livrez") then
		return ""
	end
	condition = string.gsub(condition, ":", " ")
	for i = 1, #bankExceptions["original"] do
		condition = string.gsub(condition,bankExceptions["original"][i],bankExceptions["corrected"][i])
	end
	return condition
end


function WritCreater.questExceptions(condition)
	condition = string.gsub(condition, "??"," ")
	condition = string.lower(condition)
	condition = string.gsub(condition,"commandes","commande")
	return condition
end

function WritCreater.enchantExceptions(condition)
	condition = string.lower(condition)
	condition = string.gsub(condition, "??"," ")
	condition = string.gsub(condition,"livrez","deliver")
	for i = 1, #enExceptions["original"] do
		if string.find(condition, enExceptions["original"][i]) then
			condition = string.gsub(condition, enExceptions["original"][i],enExceptions["corrected"][i])
		end
	end
	return condition
end


function WritCreater.langTutorial(i) --sentimental
	local t = {
		[5]="Une derni??re chose ?? savoir.\n/dailyreset est une commande vous indiquant le temps avant le reset des qu??tes d'artisanat.",
		[4]="Pour finir, vous pouvez choisir d'activer ou non cet addon pour chaque profession.\nPar d??faut, les fonctionnalit??es sont activ??s.\nSi vous souhaitez les d??sactiver, vous pouvez le faire via le panneau d'options.",
		[3]="Vous devez ??galement d??cider si cette fen??tre doit ??tre affich??e ?? la station d'artisanat.\nLa fen??tre vous indiquera combien de mat??riaux sont n??cessaires la commande demande mais aussi leur nombre en votre possession.",
		[2]="Le premier param??tre est l'activation du craft automatique.\nS'il est activ?? lors de l'interaction avec une station d'artisanat, l'addon fabriquera automatiquement les objets requis.",
		[1]="Merci d'utiliser Dolgubon's Lazy Writ Crafter!\nIl y a quelques param??tres ?? d??finir avant de commencer.\nVous pourrez changer ceux-ci ?? tout moment dans le panneau d'options.",
 	}
	return t[i]
end

function WritCreater.langTutorialButton(i,onOrOff) --sentimental and short pls
	local tOn = 
	{
		[1]="Par d??faut",
		[2]="Activ??",
		[3]="Afficher",
		[4]="Continuer",
		[5]="Terminer",
	}
	local tOff=
	{
		[1]="Continuer",
		[2]="D??sactiv??",
		[3]="Ne pas afficher",
	}
	if onOrOff then
		return tOn[i]
	else
		return tOff[i]
	end
end

local function runeMissingFunction (ta,essence,potency)
	local missing = {}
	if not ta["bag"] then
		missing[#missing + 1] = "|rTa|cf60000"
	end
	if not essence["bag"] then
		missing[#missing + 1] =  "|cffcc66"..essence["slot"].."|cf60000"
	end
	if not potency["bag"] then
		missing[#missing + 1] = "|c0066ff"..potency["slot"].."|r"
	end
	local text = ""
	for i = 1, #missing do
		if i ==1 then
			text = "|cf60000La glyphe ne peux ??tre craft??e. Vous n'avez aucune "..missing[i]
		else
			text = text.." ou "..missing[i]
		end
	end
	return text

end

WritCreater.strings = WritCreater.strings or {}

WritCreater.strings["runeReq"] 						= function (essence, potency) return zo_strformat("|c2dff00L'artisanat requiert 1 |rTa|c2dff00, 1 |cffcc66<<1>>|c2dff00 et 1 |c0066ff<<2>>|r",essence ,potency) end
WritCreater.strings["runeMissing"]						= runeMissingFunction
WritCreater.strings["notEnoughSkill"]					= "Votre comp??tence d???artisanat n???est pas assez ??lev??e pour fabriquer l?????quipement requis"
WritCreater.strings["smithingMissing"] 				= "\n|cf60000Vous n'avez pas assez de mat??riaux|r"
WritCreater.strings["craftAnyway"] 					= "Crafter quand m??me"
WritCreater.strings["smithingEnough"] 					= "\n|c2dff00Vous avez suffisamment de mat??riaux|r"
WritCreater.strings["craft"] 							= "|c00ff00Fabriquer|r"
WritCreater.strings["complete"] 						= "|c00FF00Commande r??alis??e.|r"
WritCreater.strings["craftingstopped"] 				= "Crat interrompu. Veuillez v??rifier que l'addon a craft?? le bon objet."
WritCreater.strings["crafting"] 						= "|c00ff00Fabrication ...|r"
WritCreater.strings["craftIncomplete"] 				= "|cf60000La fabrication ne peux ??tre r??alis??e.\nMat??riaux insuffisants.|r"
WritCreater.strings["moreStyle"] 						= "|cf60000Vous n'avez aucune pierre de style utilisable de d??finie|r"
WritCreater.strings["moreStyleSettings"]				= "|cf60000Vous n'avez pas de pierre de style utilisable.\nVous devriez probablement en autoriser plus dans le menu R??glages > Extensions.|r"
WritCreater.strings["moreStyleKnowledge"]				= "|cf60000Vous n'avez pas de pierre de style utilisable.\nIl se pourrait que vous ayez besoin d'apprendre ?? fabriquer plus de styles.|r"
WritCreater.strings["smithingReqM"] 					= function (amount, type, more) return zo_strformat( "La fabrication utilisera <<1>> <<2>> (|cf60000Vous en avez besoin de <<3>>|r)"    ,amount, type, more) end
WritCreater.strings["smithingReqM2"] 					= function (amount,type,more)     return zo_strformat( "\nMais aussi <<1>> <<2>> (|cf60000Vous en avez besoin de <<3>>|r)" ,amount, type, more) end
WritCreater.strings["smithingReq"] 					= function (amount,type, current) return zo_strformat( "La fabrication utilisera <<1>> <<2>> (|c2dff00<<3>> disponible|r)"  ,amount, type, current) end
WritCreater.strings["smithingReq2"] 					= function (amount,type, current) return zo_strformat( "\nMais aussi <<1>> <<2>> (|c2dff00<<3>> disponible|r)" ,amount, type, current) end
WritCreater.strings["dailyreset"] 						= function (till) d(zo_strformat("<<1>> heures et <<2>> minutes avant le reset journalier.",till["hour"],till["minute"])) end
WritCreater.strings["lootReceived"]					= "<<1>> a ??t?? re??u (You have <<2>>)"
WritCreater.strings["lootReceivedM"]					= "<<1>> a ??t?? re??u"
WritCreater.strings["countSurveys"]					= "Vous avez <<1>> rep??rages"
WritCreater.strings["countVouchers"]					= "Vous avez <<1>> Coupons de Commande non-acquis"
WritCreater.strings["includesStorage"]				= "Le total inclus <<1>> qui sont dans les coffres de domicile"
WritCreater.strings["surveys"]						= "Rep??rages d'artisanat"
WritCreater.strings["sealedWrits"]					= "Commandes scell??es"
WritCreater.strings["withdrawItem"]				= function(amount, link, remaining) return "Dolgubon's Lazy Writ Crafter a r??cup??r?? " .. amount .. " " .. link .. " (reste en banque : " .. remaining .. ")." end -- in Bank for German
WritCreater.strings['fullBag']						= "Vous n???avez plus de place dans votre sac. Merci de le vider."
WritCreater.strings['masterWritSave']				= "Dolgubon's Lazy Writ Crafter vous a ??vit?? d???accepter accidentellement une commande de ma??tre ! Allez dans le menu R??glages > Extensions pour d??sactiver cette option."
WritCreater.strings['missingLibraries']			= "Dolgubon's Lazy Writ Crafter a besoin des librairies ind??pendantes suivantes. Merci de t??l??charger, installer ou activer ces librairies :"
WritCreater.strings['resetWarningMessageText']		= "La r??initialisation quotidienne des commandes aura lieu dans <<1>> heure(s) et <<2>> minute(s).\nVous pouvez personnaliser ou d??sactiver cet avertissement dans les r??glages."
WritCreater.strings['resetWarningExampleText']		= "L???avertissement ressemblera ?? ??a"



local DivineMats =
{
	{"Ghost Eyes", "Vampire Hearts", "Werewolf Claws", "'Special' Candy", "Chopped Hands", "Zombie Guts", "Bat Livers", "Lizard Brains", "Witches Hats", "Distilled Boos", "Singing Toads"},
	{"Sock Puppets", "Jester Hats", "Pure Laughter", "Tempering Alloys", "Red Herrings", "Rotten Tomatoes", "Pint Real Axe Links", "Crowned Imposters", "Mudpies"},
	{"Fireworks", "Presents", "Crackers", "Reindeer Bells", "Elven Hats", "Pine Needles", "Essences of Time", "Ephemeral Lights"},

}

local function shouldDivinityprotocolbeactivatednowornotitshouldbeallthetimebutwhateveritlljustbeforabit()
	if true then return false end
	if GetDate()%10000 == 1031 then return 1 end
	if GetDate()%10000 == 401 then return 2 end
	if GetDate()%10000 == 1231 then return 3 end
	return false
end
local function wellWeShouldUseADivineMatButWeHaveNoClueWhichOneItIsSoWeNeedToAskTheGodsWhichDivineMatShouldBeUsed() local a= math.random(1, #DivineMats ) return DivineMats[a] end
local l = shouldDivinityprotocolbeactivatednowornotitshouldbeallthetimebutwhateveritlljustbeforabit()


if l then
	DivineMats = DivineMats[l]
	local DivineMat = wellWeShouldUseADivineMatButWeHaveNoClueWhichOneItIsSoWeNeedToAskTheGodsWhichDivineMatShouldBeUsed()
	WritCreater.strings.smithingReqM = function (amount, _,more) return zo_strformat( "Crafting will use <<1>> <<4>> (|cf60000You need <<3>>|r)" ,amount, type, more, DivineMat) end
	WritCreater.strings.smithingReqM2 = function (amount, _,more) return zo_strformat( "As well as <<1>> <<4>> (|cf60000You need <<3>>|r)" ,amount, type, more, DivineMat) end
	WritCreater.strings.smithingReq = function (amount, _,more) return zo_strformat( "Crafting will use <<1>> <<4>> (|c2dff00<<3>> available|r)" ,amount, type, more, DivineMat) end
	WritCreater.strings.smithingReq2 = function (amount, _,more) return zo_strformat( "As well as <<1>> <<4>> (|c2dff00<<3>> available|r)" ,amount, type, more, DivineMat) end
end


WritCreater.optionStrings = WritCreater.optionStrings or {}

WritCreater.optionStrings.nowEditing                   = "Vous modifier le r??glage de %s"
WritCreater.optionStrings.accountWide                  = "Configuration Globale"
WritCreater.optionStrings.characterSpecific            = " Configuration Specifique par personnage"
WritCreater.optionStrings.useCharacterSettings         = "Utiliser des options de personnage" -- de
WritCreater.optionStrings.useCharacterSettingsTooltip  = "Utilise des options sp??cifiques pour ce personnage uniquement" --de

WritCreater.optionStrings["style tooltip"]                            = function (styleName, styleStone) return zo_strformat("Allow the <<1>> style, which uses <<2>> to be used for crafting",styleName) end 
WritCreater.optionStrings["show craft window"]                        = "Afficher la fen??tre de craft"
WritCreater.optionStrings["show craft window tooltip"]                = "Afficher la fen??tre de craft automatique lorsque la station d'artisanat est ouverte"
WritCreater.optionStrings["autocraft"]                                = "Craft automatique"
WritCreater.optionStrings["autocraft tooltip"]                        = "Activer cette option lancera automatiquement la fabrication des objets lors de l'interaction avec la station d'artisanat. Si la fen??tre n'est pas affich??e, cette option sera activ??e."
WritCreater.optionStrings["blackmithing"]                             = "Forge"
WritCreater.optionStrings["blacksmithing tooltip"]                    = "Activer l'addon ?? la forge"
WritCreater.optionStrings["clothing"]                                 = "Tailleur"
WritCreater.optionStrings["clothing tooltip"]                         = "Activer l'addon au tailleur"
WritCreater.optionStrings["enchanting"]                               = "Enchantement"
WritCreater.optionStrings["enchanting tooltip"]                       = "Activer l'addon ?? la table d'enchantement"
WritCreater.optionStrings["alchemy"]                                  = "Alchimie"
WritCreater.optionStrings["alchemy tooltip"]   	                  	  = "Activer l'addon ?? la table d'alchimie"
WritCreater.optionStrings["provisioning"]                             = "Cuisine"
WritCreater.optionStrings["provisioning tooltip"]                     = "Activer l'addon ?? la table cuisine"
WritCreater.optionStrings["woodworking"]                              = "Travail du Bois"
WritCreater.optionStrings["woodworking tooltip"]                      = "Activer l'addon pour le travail du bois"
WritCreater.optionStrings["jewelry crafting"]							= "Joaillerie"
WritCreater.optionStrings["jewelry crafting tooltip"]					= "Activer l'addon pour Joaillerie"
WritCreater.optionStrings["style stone menu"]                         = "Utilisation des mat??riaux de style"
WritCreater.optionStrings["style stone menu tooltip"]                 = "S??lectionnez quelles pierres de style utiliser"
WritCreater.optionStrings["exit when done"]							  = "Quitter l'atelier lorsque termin??"
WritCreater.optionStrings["exit when done tooltip"]					  = "Quitter l'atelier automatiquement lorsque toutes les fabrications ont ??t?? r??alis??es"
WritCreater.optionStrings["automatic complete"]						  = "Interactions automatiques de qu??tes"
WritCreater.optionStrings["automatic complete tooltip"]				  = "Accepte et valide automatiquement les qu??tes en interagissant avec les panneaux et coffres d'artisanat."
WritCreater.optionStrings["new container"]							  = "Conserver le statut nouveau"
WritCreater.optionStrings["new container tooltip"]					  = "Conserver le statut nouveau pour les conteneurs de r??compenses de commande"
WritCreater.optionStrings["master"]									  = "Commandes de ma??tre"
WritCreater.optionStrings["master tooltip"]							  = "D??sactiver l???extension pour les Commandes de ma??tre"
WritCreater.optionStrings["right click to craft"]						= "Clic-Droit pour Fabriquer"
WritCreater.optionStrings["right click to craft tooltip"]				= "Si cela est sur ON, l???extension fabriquera les commandes de ma??tre que vous lui dites de faire apr??s avoir clic-droit sur une commande scell??e"
WritCreater.optionStrings["crafting submenu"]							= "Fabrication des objets de commande"
WritCreater.optionStrings["crafting submenu tooltip"]					= "D??sactiver l???extension pour des commandes sp??cifiques"
WritCreater.optionStrings["timesavers submenu"]							= "??conomies de temps"
WritCreater.optionStrings["timesavers submenu tooltip"]					= "Divers ??conomies de temps"
WritCreater.optionStrings["loot container"]						  		= "Ouvrir le conteneur quand re??u"
WritCreater.optionStrings["loot container tooltip"]				  		= "Ouvrir le conteneur de r??compenses de commande lorsque vous les recevez"
WritCreater.optionStrings["master writ saver"]							= "Sauvegarder commande de ma??tre"
WritCreater.optionStrings["master writ saver tooltip"]					= "Emp??cher l???acceptation de Commande de ma??tre"
WritCreater.optionStrings["loot output"]								= "Alerte sur les r??compenses pr??cieuses"
WritCreater.optionStrings["loot output tooltip"]						= "Afficher un message lorsque des objets de grande valeur sont re??us d'une commande d'artisanat"
WritCreater.optionStrings["writ grabbing"]								= "Prendre les mat??riaux de commande"
WritCreater.optionStrings["writ grabbing tooltip"]						= "Prendre les mat??riaux requis pour les commandes (ex. Nirnroot, Ta, etc.) de la banque" 
WritCreater.optionStrings["autoloot behaviour"]							= "Loot automatique"
WritCreater.optionStrings["autoloot behaviour tooltip"]					= "S??lectionner comment l'addon loote les conteneurs de r??compense de qu??te"
WritCreater.optionStrings["autoloot behaviour choices"]					= {"Param??tres du menu d'options Gameplay", "Loot automatique", "Ne pas looter"}
WritCreater.optionStrings["style tooltip"]                            = function (styleName, styleStone) return zo_strformat("Autoriser le style <<1>> , qui utilise <<2>> lors de la cr??ation",styleName) end 
WritCreater.optionStrings["hide when done"]								= "Cacher quand termin??"
WritCreater.optionStrings["hide when done tooltip"]						= "Cacher la fen??tre de l'extension quand tous les objets ont ??t?? fabriqu??s"
WritCreater.optionStrings['reticleColour']								= "Changer la couleur du r??ticule"
WritCreater.optionStrings['reticleColourTooltip']						= "Change la couleur du r??ticule si vous avez une commande, termin??e ou non, ?? l???atelier"
WritCreater.optionStrings['autoCloseBank']								= "Dialogue automatique ?? la banque"
WritCreater.optionStrings['autoCloseBankTooltip']						= "Entre et sort automatiquement du dialogue ?? la banque, s???il y a des objet ?? en retirer"
WritCreater.optionStrings['despawnBanker']								= "Renvoyer le banquier"
WritCreater.optionStrings['despawnBankerTooltip']						= "Renvoie automatiquement l???assistant banquier apr??s avoir retir?? les objets"
WritCreater.optionStrings['dailyResetWarnTime']							= "Minutes avant r??initialisation"
WritCreater.optionStrings['dailyResetWarnTimeTooltip']					= "Combien de minutes avant la r??initialisation quotidienne l???avertissement doit ??tre affich??"
WritCreater.optionStrings['dailyResetWarnType']							= "Avertissement de r??initialisation quotidienne"
WritCreater.optionStrings['dailyResetWarnTypeTooltip']					= "Quel type d???avertissement doit ??tre affich?? quand la r??initialisation des qu??tes quotidienne est sur le point d???avoir lieu"
WritCreater.optionStrings['dailyResetWarnTypeChoices']					={ "Aucun", "Type 1", "Type 2", "Type 3", "Type 4", "Tous"}
WritCreater.optionStrings['stealingProtection']							= "Protection contre le vol"
WritCreater.optionStrings['stealingProtectionTooltip']					= "Vous emp??che de voler tant qu???une commande est dans votre journal"
WritCreater.optionStrings['noDELETEConfirmJewelry']						= "Destruction de joaillerie facile"
WritCreater.optionStrings['noDELETEConfirmJewelryTooltip']				= "Ajouter automatiquement le texte de confirmation DETRUIRE ?? la bo??te de dialogue de destruction de joaillerie"
WritCreater.optionStrings['suppressQuestAnnouncements']					= "Cacher les annonces de qu??te des commandes"
WritCreater.optionStrings['suppressQuestAnnouncementsTooltip']			= "Cache le texte au centre de l?????cran quand vous commencez une commande, ou que vous cr??ez un objet pour une commande."


function WritCreater.langStationNames()
	return
	{["Atelier de forge"] = 1, ["Atelier de couture"] = 2, 
	 ["Table d'enchantement"] = 3,["??tabli d'alchimie"] = 4, ["Feu de cuisine"] = 5, ["Atelier de travail du bois"] = 6, ["Atelier de joaillerie"] = 7, }
end

function WritCreater.langWritRewardBoxes () return {
	[1] = "R??cipient d'alchimiste",
	[2] = "coffre d'enchanteur",
	[3] = "paquet de cuisinier",
	[4] = "caisse de forgeron",
	[5] = "sacoche de tailleur",
	[6] = "caisse de travailleur du bois",
	[7] = "coffre de joailler",
	[8] = "cargaison",
}
end

function WritCreater.getTaString()
	return "ta"
end

WritCreater.lang = "fr"

-- WritCreater.needTranslations = "https://www.esoui.com/forums/showpost.php?p=41147&postcount=9"