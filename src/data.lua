-- entities
-------------------------------------------------------------------------------
data_entities={
  [16]={class="player"},
  [17]={class="companion",name="cat"},
  [18]={class="companion",name="dog"},
  [19]={class="npc",name="balthasar"},
  [20]={class="npc",name="dardanius"},
  [24]={class="enemy",name="slime",xp=1,max_hp=2,ap=1},
  [25]={class="enemy",name="hobgoblin",xp=3,max_hp=4,ap=3},
  [28]={class="enemy",name="bat",xp=2,max_hp=4,ap=2},
  [27]={class="enemy",name="ghoul",xp=5,max_hp=5,ap=6},
  [26]={class="enemy",name="skully",xp=4,max_hp=6,ap=4},
  [29]={class="enemy",name="vampire",xp=7,max_hp=10,ap=8},
  [30]={class="enemy",name="demon",xp=9,max_hp=8,ap=20},
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
  [10]={class="item",item_class="key",item_data={lock=1}},
  [48]={class="item",item_class="consumable",name="red potion",item_data={dhp=15}},
  [49]={class="item",item_class="consumable",name="green potion",item_data={status=0b0001}},
  [50]={class="item",item_class="consumable",name="yellow potion",item_data={}},
  --[56]={class="item",item_class="equippable",name="dagger"},
  --[57]={class="item",item_class="equippable",name="sword"},
  --[58]={class="item",item_class="equippable",name="bow"},
  --[61]={class="item",item_class="consumable",name="scroll"},
  --[62]={class="item",item_class="equippable",name="ring"},
}



-- floors
-------------------------------------------------------------------------------
data_floors={
  rooms={
    [1]={z=1,x0=103,y0=0,x1=108,y1=6},
    [2]={z=1,x0=103,y0=7,x1=111,y1=23},
    [3]={z=-1,x0=112,y0=7,x1=127,y1=23},
    [4]={z=-1,x0=109,y0=0,x1=127,y1=6},
    [5]={z=1,x0=103,y0=24,x1=127,y1=32},
    [6]={z=-1,x0=108,y0=24,x1=127,y1=32},
    [7]={z=1,x0=103,y0=33,x1=108,y1=37},
    [8]={z=-1,x0=109,y0=33,x1=119,y1=37},
  },
  stairs={
    [1]={x=5,y=51,room=nil,target=2},
    [2]={x=104,y=1,room=1,target=1},
    [3]={x=94,y=47,room=nil,target=4},
    [4]={x=104,y=8,room=2,target=3},
    [5]={x=94,y=61,room=nil,target=6},
    [6]={x=104,y=22,room=2,target=5},
    [7]={x=100,y=57,room=nil,target=8},
    [8]={x=113,y=8,room=3,target=7},
    [9]={x=34,y=38,room=nil,target=10},
    [10]={x=110,y=3,room=4,target=9},
    [11]={x=32,y=22,room=nil,target=12},
    [12]={x=104,y=26,room=5,target=11},
    [13]={x=32,y=26,room=nil,target=14},
    [14]={x=104,y=30,room=5,target=13},
    [15]={x=34,y=26,room=nil,target=16},
    [16]={x=125,y=25,room=6,target=15},
    [17]={x=20,y=32,room=nil,target=18},
    [18]={x=109,y=31,room=6,target=17},
    [19]={x=58,y=47,room=nil,target=20},
    [20]={x=104,y=34,room=7,target=19},
    [21]={x=61,y=47,room=nil,target=22},
    [22]={x=117,y=36,room=8,target=21},
  },
}



-- locks
-------------------------------------------------------------------------------
data_locks = {
  doors={
    {x=98,y=52,lock=1},
    {x=52,y=35,lock=2},
    {x=33,y=20,lock=2},
  },
  keys={
    {x=83,y=46,lock=1},
  },
}



-- chests
-------------------------------------------------------------------------------
data_chests = {
  {x=104,y=4,content={{sprite=48},{sprite=49},{sprite=50},{sprite=10,item_data={lock=1}},{sprite=10,item_data={lock=2}},{sprite=10,item_data={lock=3}}}},
}



-- signs
-------------------------------------------------------------------------------
data_signs = {
  {x=5,y=58,message="welcome to\nthyng village"},
}



-- dialogue
-------------------------------------------------------------------------------
data_dialogue={
[19]=[[hello]],
[20]=[[salutations, friend.
this is a multiline dialogue.
abcdefghijklmnopqrstuvwxyz12345
abcdefghijklmnopqrstuvwxyz12345]],
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