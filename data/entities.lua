-------------------------------------------------------------------------------
-- entities
-------------------------------------------------------------------------------
data_entities={

-- player
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  [16]={class="player"},

-- companions
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  [17]={class="companion",name="cat"},
  [18]={class="companion",name="dog"},

-- npcs
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  [19]={class="npc",name="dinosaur"},
  [20]={class="npc",name="mushroom man"},
  --[21]={class="npc",name="green guy"},

-- enemies
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  [24]={class="enemy",name="slime",xp=1,max_hp=2,ap=1},
  [25]={class="enemy",name="hobgoblin",xp=3,max_hp=4,ap=3},
  [28]={class="enemy",name="bat",xp=2,max_hp=4,ap=2},
  [27]={class="enemy",name="ghoul",xp=5,max_hp=5,ap=6},
  [26]={class="enemy",name="skully",xp=4,max_hp=6,ap=4},
  [29]={class="enemy",name="vampire",xp=7,max_hp=10,ap=8},
  [30]={class="enemy",name="demon",xp=9,max_hp=8,ap=20},

-- interactables
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  [5]={class="stairs"},
  [6]={class="stairs"},
  [7]={class="stairs"},
  [8]={class="stairs"},
  [3]={class="sign",name="grave",message="rest in peace",bg=13,fg=6},
  [4]={class="sign"},
  [11]={class="chest"},
  [82]={class="door"},
  [81]={class="door",collision=false},
  [9]={class="door",lock=1},

-- items
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  [10]={class="item",item_class="key",item_data={lock=1}},
  [56]={class="item",item_class="equippable",name="dagger"},
  [57]={class="item",item_class="equippable",name="sword"},
  [58]={class="item",item_class="equippable",name="bow"},
  [59]={class="item",item_class="consumable",name="potion",item_data={hp=10}},
  [60]={class="item",item_class="consumable",name="potion"},
  [61]={class="item",item_class="consumable",name="scroll"},
  [62]={class="item",item_class="equippable",name="ring"},
}