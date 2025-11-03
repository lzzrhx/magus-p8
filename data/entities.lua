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
  [21]={class="npc",name="green guy"},
  [22]={class="npc",name="man"},
  [23]={class="npc",name="guy"},

-- enemies
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  [24]={class="npc",name="blob"},
  [25]={class="npc",name="hobgoblin"},
  [26]={class="enemy",name="skully"},
  [27]={class="npc",name="ghoul"},
  [28]={class="npc",name="bat"},
  [29]={class="enemy",name="vampire",ap=3,max_hp=8,xp=5},
  [30]={class="npc",name="demon"},

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
  [59]={class="item",item_class="cosumable",name="potion"},
  [60]={class="item",item_class="cosumable",name="potion"},
  [61]={class="item",item_class="cosumable",name="scroll"},
  [62]={class="item",item_class="equippable",name="ring"},
}