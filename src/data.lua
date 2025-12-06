-- spells and items
-------------------------------------------------------------------------------
spell_names=split"befriend,terrify,slumber,venom"
spell_txt=split"turn foe to\nfriend. max 5.\nlasts until\nmax exceeded.,drive creature\nto flee in fear\nfor 16 turns.\nopen to dmg.,lull creature\ninto deep sleep\nfor 24 turns.\nwoken by dmg.,inflict poison\nupon creature.\ndealing dmg for\n3 turns."
key_names=split"iron key,gold key,green key"
consumable_names=split"cherries,orange,potion"
consumable_values=split"5,10,15"

-- entities
-------------------------------------------------------------------------------
data_entities={
 [16]={class="player"},
 [17]={class="companion",name="cat"},
 [18]={class="companion",name="dog"},
 [19]={class="npc",name="balthasar"},
 [20]={class="npc",name="dardanius"},
 [24]={class="enemy",name="slime",max_hp=2,ap=1},
 [25]={class="enemy",name="hobgoblin",max_hp=8,ap=3},
 [28]={class="enemy",name="bat",max_hp=4,ap=2},
 [27]={class="enemy",name="ghoul",max_hp=8,ap=6},
 [26]={class="enemy",name="skully",max_hp=6,ap=4},
 [29]={class="enemy",name="vampire",max_hp=14,ap=8},
 [30]={class="enemy",name="demon",max_hp=16,ap=14},
 [5]={class="stairs"},
 [6]={class="stairs"},
 [7]={class="stairs"},
 [8]={class="stairs"},
 [11]={class="chest"},
 [82]={class="door"},
 [81]={class="door",collision=false},
 [48]={class="door",lock=1},
 [49]={class="door",lock=2},
 [50]={class="door",lock=3},
 [54]={class="item",type=1}, -- tome
 [51]={class="item",type=2,value=1}, -- key 1
 [52]={class="item",type=2,value=2}, -- key 2
 [53]={class="item",type=2,value=3}, -- key 3
 [55]={class="item",type=3,value=1}, -- carrot
 [56]={class="item",type=3,value=2}, -- food 2
 [57]={class="item",type=3,value=3}, -- potion
}



-- floors
-------------------------------------------------------------------------------
data_floors={
 rooms={
  -- z,x0,y0,x1,y1
  [1]=split"1,103,0,108,6",
  [2]=split"1,103,7,111,23",
  [3]=split"-1,112,7,127,23",
  [4]=split"-1,109,0,127,6",
  [5]=split"1,103,24,107,32",
  [6]=split"-1,108,24,127,32",
  [7]=split"1,103,33,108,37",
  [8]=split"-1,109,33,119,37",
  [9]=split"1,119,33,124,37",
  [10]=split"-1,103,46,107,49",
  [11]=split"1,103,38,119,41",
  [12]=split"-1,123,51,127,62",
  [13]=split"1,103,42,119,45",
  [14]=split"-1,120,38,127,44",
  [15]=split"-2,120,44,127,50",
  [16]=split"1,108,46,112,49",
  [17]=split"-1,113,46,119,49",
  [18]=split"-1,103,51,112,57",
  [19]=split"-2,113,51,122,57",
  [20]=split"-3,103,57,122,63",
  [21]=split"-1,125,33,127,38",
 },
 stairs={
  -- x,y,room,target
  [1]=split"5,51,nil,2",
  [2]=split"104,1,1,1",
  [3]=split"94,47,nil,4",
  [4]=split"104,8,2,3",
  [5]=split"94,61,nil,6",
  [6]=split"104,22,2,5",
  [7]=split"100,57,nil,8",
  [8]=split"125,22,3,7",
  [9]=split"33,38,nil,10",
  [10]=split"110,3,4,9",
  [11]=split"32,22,nil,12",
  [12]=split"104,26,5,11",
  [13]=split"32,26,nil,14",
  [14]=split"104,31,5,13",
  [15]=split"34,27,nil,16",
  [16]=split"124,25,6,15",
  [17]=split"20,32,nil,18",
  [18]=split"109,31,6,17",
  [19]=split"58,47,nil,20",
  [20]=split"104,34,7,19",
  [21]=split"61,47,nil,22",
  [22]=split"116,36,8,21",
  [23]=split"120,36,9,24",
  [24]=split"91,39,nil,23",
  [25]=split"104,47,10,28",
  [26]=split"69,11,nil,27",
  [27]=split"104,39,11,26",
  [28]=split"71,11,nil,25",
  [29]=split"116,39,11,30",
  [30]=split"81,11,nil,29",
  [31]=split"83,11,nil,32",
  [32]=split"124,61,12,31",
  [33]=split"124,52,12,34",
  [34]=split"83,2,nil,33",
  [35]=split"81,2,nil,36",
  [36]=split"104,43,13,35",
  [37]=split"116,43,13,38",
  [38]=split"93,2,nil,37",
  [39]=split"75,3,nil,40",
  [40]=split"121,39,14,39",
  [41]=split"121,43,14,42",
  [42]=split"121,49,15,41",
  [43]=split"93,11,nil,44",
  [44]=split"109,47,16,43",
  [45]=split"95,11,nil,46",
  [46]=split"114,47,17,45",
  [47]=split"2,7,nil,48",
  [48]=split"104,52,18,47",
  [49]=split"111,52,18,50",
  [50]=split"114,52,19,49",
  [51]=split"114,56,19,52",
  [52]=split"104,58,20,51",
  [53]=split"52,36,nil,54",
  [54]=split"126,37,21,53",
  [55]=split"126,34,21,56",
  [56]=split"52,33,nil,55",
 },
}



-- chests
-------------------------------------------------------------------------------
data_chests = {
 {x=125,y=2,content=split"51"},
 {x=113,y=8,content=split"53,54"},
 {x=83,y=46,content=split"51"},
 {x=110,y=34,content=split"52"},
 {x=121,y=45,content=split"57,53,54"},
 {x=100,y=2,content=split"51"},
 {x=118,y=47,content=split"52"},
 {x=60,y=5,content=split"57,52"},
 {x=119,y=60,content=split"54"},
 {x=26,y=19,content=split"56,51"},
 {x=38,y=36,content=split"51"},
}



-- signs
-------------------------------------------------------------------------------
--[[
data_signs = {
 -- x,y,message
 split"5,58,welcome to\nthyng village",
 split"52,31,◀- vangald fortress\n-▶ woodlands",
}
]]--



-- dialogue
-------------------------------------------------------------------------------
data_dialogue={
[19]=[[greetings my dear friend magus
1.............................
1.............................
what? the dark lords? tomes?
this is distressing news for
sure. i heard tales of those
mystic tomes many years ago.
3.............................
3.............................
4.............................
4.............................
4.............................
5.............................
5.............................
5.............................
6.............................
6.............................
6.............................]],
[20]=[[salutations, friend.
1.............................
1.............................
the cursed undead armies you
say? oh dear lord!
2.............................
3.............................
3.............................
3.............................
4.............................
4.............................
4.............................
5.............................
5.............................
5.............................
6.............................
6.............................
6.............................]],
}



-- story
-------------------------------------------------------------------------------
data_story_intro=[[you spent four years attending
classes from the old masters
at the kulian academy of
magicks, followed by a three
year apprentice period in the
boundless plains with ghyle
the perceptive as your mentor.
together you journeyed cross
the plains, decoded the
mystery of the eulian scrolls,
befriended the ancient
plain-dwellers and assisted
them in defeating yutta the
knave and rulu the golem.

~ ⁙ ~

however, after completing the
apprentice period, you got
assigned your first solo
posting in the province of
myga, where you were appointed
as keeper of the sage-house in
the small village of thyng.
the house contains a rich
library and your duty is to
curate the selection and share
knowledge with the locals, as
well as to make use of your
wizardly skills in whatever
assistance is needed.

~ ⁙ ~

eight months have passed, and
while at first you felt unsure
in these unfamiliar
surroundings, you have now
grown custom to the place and
have built sturdy friendships
with your fellow villagers.
over these past months you 
have requested numerous
books from distant libraries,
and you have shared precious
learnings, that has resulted
in the introduction of new
tools, new planting
techniques, and an improved
irrigation system for the
farmers in the village. a few
weeks back you even had to use
your magical abilities in a
explosive display to fend off
a gang of wandering bandits
encroaching on the village.

~ ⁙ ~

lately things have been quiet
though, and you are really
starting to feel at ease with
the daily routine of your
posting. a sense of feeling at
home in the sage-house is
starting to build, and the
friendships gained with your
fellows brings you great joy.

~ ⁙ ~

then one day an encrypted
letter arrives. you recognize
the encryption from your
former mentor. you decrypt it
with the secret technique, and
the letter reads: "dear magus,
i am writing you this letter
of utmost urgency as the
sage-guild finds itself in a
state of great distress. the
four lords of the outer rings
have discovered the legend of
the tomes of edera.

~ ⁙ ~

legend has it that the grand
wizard edera battled the evil
god fearu five thousand years
ago during the age of chaos.
edera ventured to the
underrealms and spent fifty
torturous years in search of a
legendary magickal technique
powerful enough to defeat a
god. when she returned to the
mortal realms she had had
aquired magickal powers far
beyond what was thought
possible. she could move
planets out of their alignment
and tear holes in the cosmic
fabric. when she faced the
vile god fearu in battle he
was slayed in a moment, and
his evil plans put to rest.
what became of the secrets to
the powerful sorcery she had
discovered remained unknown,
and the knowledge of how to
perform the all-powerful
magickal techniques were
considered lost. but
information has now surfaced
leading us to believe that
what she had learned in the
underrealms was written down
on four tomes that were safely
secured and hidden at some
unknown locations.

~ ⁙ ~

the wicked lords have joined
forces in order to obtain the
tomes and plan to use its
powers for most sinister
purposes. they have sent their
demon armies to myga quite
close to where you are
presently located, where they
believe the four fragments to
be hidden.

~ ⁙ ~

i and the other masters of the
sage-guild are currently quite
preocupied in a vicous battle
in the fortress of lord
thurras of the outer rings,
but i will make haste and
journey to myra as soon as the
situation permits.

~ ⁙ ~

i'm sending you this letter of
utmost urgency to ask you to
seek out the tomes if you can,
and secure them before they
fall in the hands of the
undead armies of the four
lords. but please, pick your
battles wisely and do not
engange in any situation that
put your life in peril. i will
be with you soon to offer my
assistance.

your dear friend, ghyle."]]