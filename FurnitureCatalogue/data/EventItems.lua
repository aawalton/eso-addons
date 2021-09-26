FurC.Books = FurC.Books or {}
FurC.Books[FURC_MORROWIND] = {
    [126157] = {},
    [126158] = {},
    [126159] = {},
    [126160] = {},
    [126161] = {},
    [126162] = {},
    [126163] = {},
    [126164] = {},
}

FurC.EventItems[FURC_DRAGONS] = {
  ["Jester Festival"] = {
    ["Jester Boxes"] = {
      [134680] = true,   -- Jester Box
    }
  }
}

FurC.EventItems[FURC_MORROWIND] = {
  ["Midyear Mayhem"] = {
    ["Boon Box"] = {
      [126157] = true,  -- Song of Pelinal, #1
      [126158] = true,  -- Song of Pelinal, #2
      [126159] = true,  -- Song of Pelinal, #3
      [126160] = true,  -- Song of Pelinal, #4
      [126161] = true,  -- Song of Pelinal, #5
      [126162] = true,  -- Song of Pelinal, #6
      [126163] = true,  -- Song of Pelinal, #7
      [126164] = true,  -- Song of Pelinal, #8
    },
  },
  ["New Life"] = {
    ["Gift Box"] = {      
      [118053] = true,   -- Common Campfire, Outdoor
      [130326] = true,   -- Witches Brazier, Primitive Log,
    },
  },
}

FurC.EventItems[FURC_KITTY] = {
  ["Witches' Festival"] = {
    ["Plunder Skull"] = {    
      [118149] = true,		   -- Block and Axe, Chopping
      [145317] = true,       -- Gravestone, Broken
    }
  }
}

FurC.EventItems[FURC_REACH] = {
  ["Witches' Festival"] = {
    ["Plunder Skull"] = {
      [130337] = true,   -- Witches Corpse, Wrapped,
      [130325] = true,   -- Witches Totem, Emphatic Warning,
      [130334] = true,   -- Witches Totem, Antler Charms,
      [130327] = true,   -- Witches Totem, Wooden Rack,
      [130328] = true,   -- Witches Skull, Horned Ram,
      [130332] = true,   -- Witches Totem, Bone Charms,
      [130340] = true,   -- Witches Totem, Gnarled Vines and Skull,
      [130339] = true,   -- Witches Totem, Twisted Vines and Skull
      [130338] = true,   -- Witches Bones, Offering,
      [145318] = true,   -- Small Gravestone
      [130302] = GetString(SI_FURC_WW),   -- Shrub, Burnt Brush"
      [130298] = GetString(SI_FURC_WW),  -- Branch, Curved Laurel
      [130296] = GetString(SI_FURC_WW),  -- Branch, Sturdy Laurel
      [130295] = GetString(SI_FURC_WW),  -- Branch, Sturdy Burnt
      [130294] = GetString(SI_FURC_WW),  -- Branch, Forked Burnt
      [130293] = GetString(SI_FURC_WW),  -- Branch, Curved Burnt
      [130301] = GetString(SI_FURC_WW),  -- Saplings, Burnt Sparse
      [130299] = GetString(SI_FURC_WW),  -- Saplings, Burnt Cluster
      [130300] = GetString(SI_FURC_WW),  -- Saplings, Burnt Tall
      [130297] = GetString(SI_FURC_WW),  -- Branch, Forked Laurel
      [130280] = GetString(SI_FURC_WW),  -- Sapling, Petrified Ashen
    }
  }
}

FurC.EventItems[FURC_HARROW] = {
  ["Anniversary Jubilee"] = { -- 2020-04-02 till 2020-04-14; 2021-04-01 till 2021-04-15
    ["Impresario"] = {
      [159464] = { itemPrice = 3 }, -- Replica Jubilee Cake 2016
      [159465] = { itemPrice = 3 }, -- Replica Jubilee Cake 2017
      [159466] = { itemPrice = 3 }, -- Replica Jubilee Cake 2018
      [159467] = { itemPrice = 3 }, -- Replica Jubilee Cake 2019
      [159470] = { itemPrice = 3 }, -- Replica Jubilee Cake 2020
      [171601] = { itemPrice = 3 }, -- Replica Jubilee Cake 2021
    }
  }
}
