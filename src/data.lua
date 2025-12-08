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
 [19]={class="npc",name="dardanius"},
 [20]={class="npc",name="balthasar"},
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



-- dialogue
-------------------------------------------------------------------------------
data_dialogue={
[19]=[[ah, ho there, most illustrious
magus! enter, i prithee, and
take thy ease awhile.
behold me, buried deep within
my books. for truly, knowledge
is the wing wherewith we fly
to heaven! art thou perchance
beset by hunger's call? may i
present thee a modest slice of
bread this shining morn? or a
cup of ale to cure the dryness
of thy noble throat?
what ho! tomes and vile demon
troops? o horrors dire! tidings
dark as midnight storms!
yet now i recollect, my grand
sire once told tales of such
tomes hidden in these very
lands. aye, 'twas many  a year
ago, i believed em' but the
ramblings of an old man.
a tome most mighty hidden oer'
yonder, deep in the ruins to
the east. but alas, he could
never set foot therein, for
the gate was sealed with a
lock forged of purest gold.
so thou wouldst seek these
fabled tomes thyself? o bravest
magus, may good fortune guard
thee on thy perilous quest, for
all our fragile fates now ride
upon thy shoulders bare. 
go forth, i pray, with
steadfast strength and safety!
and when thou return'st
triumphantly in glory, we shall
make merry, and delight in
tales of conquests bold!]],
[20]=[[hail, my cherished friend
magus. tis' ever a delight to
cross thy path and engage in
merry prattle. how dost thou
fare upon this fairest day?
what is this thou uttered?
hidden tomes? the wicked
lords? o gentle heavens,
such tidings strike terror to
the heart! alas, dear magus,
what direful plight is this!
the accursed undead shuffle
about, and may, ere long,
encircle our noble village,
vexing us with their most
ill-mannered and woeful
company! what say'st thou?
thou wilt tramp o'er hill and
hollow, to seek out those
fabled tomes, and smite those
undead armies? 
a marvel 'tis to hear!
i pray peace will return to
gladden these afflicted lands!
godspeed on thy journey,
blessed magus!]],
}



-- story
-------------------------------------------------------------------------------
data_story_intro=[[four long years didst thou
spend in learning within those
hallowed halls of the famed
kulian academy of magicks.
thou filled thy eager mind
with arcane wisdom from the
masters of that place, olde
and wise. thereafter, a
three-year apprentice period
in the boundless plains didst
thou serve with ghyle the
perceptive as thy mentor.
together ye journey'd cross
those plains, decoded the
mystery of the eulian scrolls,
befriended the ancient
plain-dwellers and assisted
them in defeating rulu the
golem, and yutta the knave,
such that peace was brought
upon those lands. and when thy
trials of tutelage were
completed the sage-guild
assigned thee thy first solo
posting.

~ ⁙ ~

the province of myga, rich
with fertile soil and
bountiful rivers. where
overgrown woodlands blanket
the lands, and the long
forsaken, crumbling keeps of
the vangald dynasty stand
eerily silent in state of
decay. aye, 'twas in that
province thou were appointed
as keeper of the sage-house,
in the village that beareth
the name of yangu. within
that house treasured books and
scrolls of knowledge rare were
kept. 'twas thine to guard,
to teach and share with the
folk of that fair village.
furthermore ye were task'd to
serve as guardian and
protector of that same
village, and lend the might of
thy skills in the art of
magicks, should the need
arise.

~ ⁙ ~

eight moons have since
passed. at first thou found
the place most strange and the
faces cold, yet time hath
softened all estrangement, and
now thou art settled, aye and
settled proper. sturdy
friendships with thy fellows
have bloomed, and thy heart
glows with tender warmth from
laughter shared among comrades
dear. by knowledge gained from
books of distant realms, sent
swiftly though the sage-guild's
network, new learnings have
taken root within these lands.
new techniques for planting 
have been devised for the
farmers, and a cunning
irrigation system contrived by
thy hand. ah, but life is not
all peaceful bliss in this
place. it must have been a
fortnight past, when bandits
vile and base  encroached,
whose trespass threaten'd ruin
and destruction. 'twas then,
with thunderous might, thou
cast forth thy spells, and ye
drove them from the village
gate. yet since that day peace
has embraced the village.

~ ⁙ ~

but lo! upon a morn most calm
and fair, a scroll guarded by
a magick seal arrives. the
seal thou knowest full well!
it is the mark of master ghyle
and thy heart beats rapid with
excitement! with secret art
thou breaketh it open and thus
the letter's message is
revealed: to thee, dear magus,
whom i hold in trust, i pen
thee now with utmost urgency.
great peril grips the guild,
for the four lords of the
outer rings have made
discovery of the legend of the
tomes of edera. know that five
thousand years have come and
gone since the age of chaos,
when mighty edera, the
grandest of mage, did stand
against fearu, god of dread.

~ ⁙ ~

she ventured underneath the
world to seek a power, so vast
it might unmake even the
divine. for fifty tormented
years she wandered the dark
abyss in search. legend tells
her journey led to the
furthest reaches of that
horrid place, ah, and after
besting unspeakable terrors in
battel, the secrets of their
cosmic powers revealed
themselves to her. she learned
techniques of divine might,
such that she could unbind the
stars themselves and tear the
fabric of heaven's veil with
the power of her spells!
she returned to our mortal
realms, and behold! saved the
world from chaos' grip, and
slayed that most evil god in
one swift stroke! yet when her
triumph's echo died away, she
vanished to the geanic cost,
and lived her days in peace.

~ ⁙ ~

the secrets of her divine
powers were deemed forever
lost. but now we hear that
what she learned was perhaps
written down in three great
tomes. each hid in some secret
place. yet now the wicked
lords conspire as one. they
have sworn to claim these
tomes, yearning to wield that
divine power for purposes most
dark and sinister. their demon
armies march forth for myga.
aye, brave magus dear, the
very same place thou dwellest!
for they believe the tomes to
be hidden there in those very
lands! the masters of the
guild and i are presently
locked in mortal battel deep
within the fortress of lord
thurras. therefore i beseech
thee, seek out the hidden
tomes, secure them swiftly
before they fall into the
fingers of those lords most
vile! yet tread with utmost
care on your journey, for it
is a quest most perilous
indeed! and soon, if fate
allow, i shall make haste and
join thee in thy quest!

thy friend forever,
ghyle.]]