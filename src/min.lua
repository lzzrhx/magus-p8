-- minified version of main.lua + object.lua
timer_corpse=20
timer_target=24
timer_dialog_line=24
timer_effect=16
timer_effect_poison=6
timer_spell=24
timer_spell_charm=48
width=103
height=64
state_reset="reset"
state_title="title"
state_game="game"
state_menu="menu"
state_look="look"
state_dialogue="dialogue"
state_chest="chest"
state_read="read"
state_dead="dead"
sprite_void=0
sprite_empty=1
sprite_selection=2
sprite_grave=3
sprite_chest_closed=11
sprite_chest_open=12
sprite_door_closed=82
sprite_door_open=81
sprite_companion_cat=17
sprite_companion_dog=18
status_charmed=1
status_scared=2
status_sleeping=4
status_poisoned=8
statuses=split"0b0001,0b0010,0b0100,0b1000"
flag_collision=0
flag_entity=1
state=nil
room=nil
turn=1
frame=0
prev_frame=0
blink_frame=0
blink=false
flash_frame=0
fade_frame=0
fade_chars=split"░,▒"
fade_action=nil
pal_lock=false
cam_x=0
cam_y=0
cam_offset=4
cam_x_min=0
cam_y_min=0
cam_x_diff=0
cam_y_diff=0
title_effect_num=96
title_effect_colors=split"8,9,10,11,12,13,14,15"
title_text=split(data_story_intro,"\n")
spells=split"befriend,scare,sleep,poison"
spells_cd=split"0,0,0,0"
max_followers=5
function _init()
change_state(state_title)
populate_map()
end
function _update()
if(state==state_reset)run()else blink_frame=(blink_frame+1)%2blink=blink_frame%2==0prev_frame=frame frame=flr(t()*2%2)update[state]()
end
function _draw()
if(state~=state_reset)draw[state]()draw.flash_step()draw.fade_step()
end
init={
title=function(sel)
title_idle=true
title_pos=0
end,
menu=function(sel)
sel_menu={tab=0,i=1}
end,
look=function(sel)
sel_look={spell=0,x=player.x,y=player.y}
set_look()
end,
dialogue=function(sel)
sel_dialogue=sel
end,
chest=function(sel)
sel_chest=sel
end,
read=function(sel)
sel_read=sel
end
}
update={
title=function()
if(not title_idle)title_pos+=.2
if(title_pos>=str_height(data_story_intro)*8+85and fade_frame==0)draw.play_fade(change_state,state_game)
input.title()
end,
game=function()
for e in all(entity.entities)do e:update()end
update_camera()
if(not creature.anim_playing and input.game())do_turn()
end,
menu=function()
input.menu()
end,
look=function()
if(input.look())set_look()
end,
dialogue=function()
input.dialogue()
end,
chest=function()
if(sel_chest.entity.anim_this)sel_chest.entity:anim_step()
input.chest()
end,
read=function()
input.read()
end,
dead=function()
for e in all(entity.entities)do e:update()end
input.dead()
end
}
draw={
play_fade=function(func,param)
fade_frame=5
fade_action=func and{func=func,param=param}or nil
end,
fade_step=function()
if fade_frame>0do
if(fade_frame==3)rectfill(0,0,128,128,0)else for j=0,15do for k=0,15do print("ᵉ"..fade_chars[fade_frame>#fade_chars and 6-fade_frame or fade_frame],j*8,k*8,0)end end
fade_frame-=1
if(fade_frame==3and fade_action)fade_action.func(fade_action.param)
end
end,
flash_step=function()
if(flash_frame>0)cls(state==state_game and player.hp<5and flash_frame==1and 8or 7)flash_frame-=1
end,
monochrome=function()
poke(24404,96)
pal_all(1)
sspr(0,0,128,128,0,0)
pal_set()
poke(24404,0)
end,
window_frame=function(h)
h=h or 2
if(h>0)rectfill(0,125-h*7,127,127,1)line(0,125-h*7,127,125-h*7,6)
rect(0,0,127,127,6)
pset(0,0,0)
pset(127,0,0)
pset(0,127,0)
pset(127,127,0)
end,
title=function()
cls(0)
camera(0,title_pos)
for i=1,title_effect_num do
local x,y,c=cos(t()/8+i/title_effect_num)*56,sin(t()/8+i/title_effect_num)*16+sin(t()+i*(1/title_effect_num)*5)*4,title_effect_colors[i%#title_effect_colors+1]
for j=1,3do pset(62+x+j,50+y+j,c)end
end
s_print("ᵉmagus magicus",13,45,true,true,7,4)
print("ˇˇˇˇˇˇˇˇˇˇˇˇ",19,54,6)
if not title_idle do
for k,v in pairs(title_text)do
print(v,64-str_width(v)*.5,78+k*8,5)
print(v,64-str_width(v)*.5,77+k*8,6)
end
elseif frame==0do s_print("start game ❎",38,85)end
camera(0,0)
for i=0,1do for j=0,15do
local x=j*8+flr(rnd()+.5)
print("ᵉ"..fade_chars[2],x,130*i-5,0)
print("ᵉ"..fade_chars[1],x,128*i-4,0)
end end
draw.window_frame(0)
clip(1,84,126,43)
end,
game=function()
cls()
if room do
local x0,y0,x1,y1=max(0,(room.x0-cam_x+1)*8),max(0,(room.y0-cam_y+1)*8),min(128,(room.x1-cam_x)*8),min(128,(room.y1-cam_y)*8)
if(room.z>0)pal_all(1,true)map(cam_x-cam_x_diff-1,cam_y-cam_y_diff-room.z-1,-8,-8,18,16)for e in all(entity.entities)do e:draw({x=cam_x_diff,y=cam_y_diff+room.z})end pal_unlock()
rectfill(x0,y0,x1,y1,0)
map(room.x0,room.y0,(room.x0-cam_x)*8,(room.y0-cam_y)*8,room.x1-room.x0+1,room.y1-room.y0+1)
clip(x0,y0,x1-x0,y1-y0)
else
map(cam_x-1,cam_y-1,-8,-8,18,16)
end
for e in all(entity.entities)do if(e~=player and(e.parent_class~=creature.class or e.dead))e:draw()end
for e in all(entity.entities)do if(e~=player and(e.parent_class==creature.class and not e.dead))e:draw()end
player:draw()
clip()
camera()
draw.window_frame()
local hp=max(0,player.hp/player.max_hp)
s_print("hp:",2,120,state==state_game)
if(state==state_game)rectfill(14,120,82,124,5)
if(hp>0)rectfill(14,120,14+68*hp,124,hp<.25and 8or hp<.5and 9or hp<.75and 10or 11)
s_print("menu 🅾️",98,113,state==state_game)
s_print("look ❎",98,120,state==state_game)
clip(0,0,msg.frame,128)
if(state==state_game)print(msg.txt,2,114,5)
print(msg.txt,2,113,6)
clip(msg.frame,0,msg.frame>msg.width-3and msg.width-msg.frame or 3,128)
print(msg.txt,2,112,7)
clip()
if(state==state_game or state==state_dead)msg.anim_step()
print(#player.followers,1,1,8)
end,
menu=function()
draw.game()
draw.monochrome()
line(30,22,96,22,6)
line(30,88,96,88,6)
line(29,23,29,87,6)
line(97,23,97,87,6)
rectfill(30,22,96,28,6)
local btns="cancel 🅾️  use ❎"
print(btns,29,97,5)
clip(24,0,sel_menu.tab==0and spells_cd[sel_menu.i]==0and 80or sel_menu.tab==1and inventory.num>0and inventory.items[sel_menu.i].interactable and 80or 40,128)
print(btns,29,96,6)
clip()
if sel_menu.tab==0do
print("⬅️ magick ➡️",40,23,0)
print("▶",33,25+sel_menu.i*7,6)
for i=1,tbl_len(spells)do print((spells_cd[i]>0and"("..spells_cd[i]..") "or(i==1and#player.followers>=max_followers and"(max) "or""))..spells[i],38,25+i*7,sel_menu.i==i and 6or 5)end
elseif sel_menu.tab==1do
print("⬅️ inventory ➡️",34,23,0)
if(inventory.num==0)print("empty",35,32,5)else print("▶",33,25+sel_menu.i*7,6)for i=1,inventory.num do print(inventory.items[i].name,38,25+i*7,sel_menu.i==i and 6or 5)end
elseif sel_menu.tab==2do
print("⬅️ character ➡️",34,23,0)
print("hp: "..player.hp.."/"..player.max_hp.."\nxp: "..player.xp,35,32,6)
end
end,
look=function()
draw.game()
if(state==state_look)draw.monochrome()
player:draw()
if(sel_look.entity)sel_look.entity:draw()
if(state==state_look)vec2_spr(sprite_selection,pos_to_screen(sel_look))
draw.window_frame()
local btn_x=sel_look.text.." ❎"
s_print(sel_look.spell==0and"target:"or"cast "..spells[sel_look.spell].." on:",2,113,state==state_look)
s_print(sel_look.name,2,120,state==state_look,sel_look.entity~=nil,sel_look.color,sel_look.entity and sel_look.entity.parent_class==creature.class and 0or 5)
s_print("cancel 🅾️",90,113,state==state_look)
s_print(btn_x,126-str_width(btn_x),120,state==state_look,sel_look.usable)
end,
dialogue=function()
draw.game()
draw.monochrome()
player:draw()
sel_dialogue.entity:draw()
draw.window_frame(4)
if(sel_dialogue.anim_frame[min(sel_dialogue.pos+2,#sel_dialogue.text)]<=0and frame==0)s_print("continue ❎",82,99)
s_print(sel_dialogue.entity:get_name()..":",2,99)
for k,v in pairs(sel_dialogue.text)do
local f=sel_dialogue.anim_frame[k]
if k>=sel_dialogue.pos and k<=sel_dialogue.pos+2do
local y=106+(k-sel_dialogue.pos)*7
clip(0,0,#v*4+timer_dialog_line-f,128)
s_print(v,2,y)
if(f>0and f~=#v*4+timer_dialog_line)clip(#v*4+timer_dialog_line-f,0,3,128)print(v,2,y-1,7)
if(f>0and(k==sel_dialogue.pos or sel_dialogue.anim_frame[k-1]<=0))sel_dialogue.anim_frame[k]-=3
end
end
clip()
end,
chest=function()
local e=sel_chest.entity
local n=tbl_len(e.content)
cls()
player:draw()
e:draw()
if(not chest.anim_playing)draw.monochrome()
if e.anim_frame<=0do
for i=1,n do
local f,target_pos=sel_chest.anim_frame[i],{x=52-n*8+i*16,y=52}
if i==1or sel_chest.anim_frame[i-1]<=0do
local itm=e.content[i]
if f>0do
if(i==n)e.anim_this=false
pal_all(7)
for j=0,10do
local pos=e:item_anim_pos(smoothstep(min(1,1-f/60+.025*j)),target_pos)
if(blink)vec2_spr(itm.sprite,pos)
end
pal_set()
sel_chest.anim_frame[i]-=1
if(sel_chest.anim_frame[n]<=0)chest.anim_playing=false flash_frame=2
elseif not chest.anim_playing or blink do itm:spr(target_pos.x,target_pos.y+wavy())end
end
end
end
if(not chest.anim_playing)wavy_print("take items ❎",38,85)
end,
read=function()
draw.look()
draw.monochrome()
local txt=split(sel_read.message,"\n")
local exp=max(#txt-5,0)*4
local y0,y1=34-exp,76+exp
rectfill(23,y0,103,y1,sel_read.bg)
line(24,y0-1,102,y0-1,sel_read.bg)
line(24,y1+1,102,y1+1,sel_read.bg)
for i=1,tbl_len(txt)do
print(txt[i],64-str_width(txt[i])*.5,29-exp+max(5-#txt,0)*4+i*8,sel_read.fg)
end
s_print("continue ❎",42,85+exp)
end,
dead=function()
draw.game()
draw.monochrome()
wavy_print("g a m e   o v e r",26,61,8,1)
if(frame==0)s_print("restart ❎",44,85)
end
}
input={
title=function()
if(btnp(5))if(title_idle)draw.play_fade(toggle_bool,"title_idle")else draw.play_fade(change_state,state_game)
end,
game=function()
local valid,x,y=false,player.x,player.y
if btn(0)do valid=player:action_dir(x-1,y)
elseif btn(1)do valid=player:action_dir(x+1,y)
elseif btn(2)do valid=player:action_dir(x,y-1)
elseif btn(3)do valid=player:action_dir(x,y+1)
elseif btnp(4)do change_state(state_menu)
elseif btnp(5)do change_state(state_look)end
return valid
end,
menu=function()
if btnp(0)do
sel_menu.i=1
sel_menu.tab=(sel_menu.tab-1)%3
elseif btnp(1)do
sel_menu.i=1
sel_menu.tab=(sel_menu.tab+1)%3
elseif btnp(2)and sel_menu.i>1do sel_menu.i-=1
elseif btnp(4)do change_state(state_game)
elseif sel_menu.tab==0do
if btnp(3)and sel_menu.i<tbl_len(spells)do sel_menu.i+=1
elseif btnp(5)and spells_cd[sel_menu.i]==0do
change_state(state_look)
sel_look.spell=sel_menu.i
set_look()
end
elseif sel_menu.tab==1do
if btnp(3)and sel_menu.i<inventory.num do sel_menu.i+=1
elseif btnp(5)and inventory.num>0and inventory.items[sel_menu.i].interactable do
inventory.items[sel_menu.i]:interact()
inventory.remove(inventory.items[sel_menu.i])
change_state(state_game)
end
end
end,
look=function()
if btnp(0)and sel_look.x-cam_x>0do sel_look.x-=1
elseif btnp(1)and sel_look.x-cam_x<15do sel_look.x+=1
elseif btnp(2)and sel_look.y-cam_y>0do sel_look.y-=1
elseif btnp(3)and sel_look.y-cam_y<13do sel_look.y+=1
elseif btnp(4)do
change_state(state_game)
return false
elseif btnp(5)and sel_look.spell==0and sel_look.usable do
sel_look.entity:interact()
inventory.remove(sel_look.possession)
return false
elseif btnp(5)and sel_look.spell>0and sel_look.usable do
change_state(state_game)
cast_spell(sel_look.spell,sel_look.entity)
do_turn()
spells_cd[sel_look.spell]=sel_look.spell==1and timer_spell_charm or timer_spell
return false
end
return true
end,
dialogue=function()
if(btnp(5))if(sel_dialogue.pos+2<#sel_dialogue.text)sel_dialogue.pos+=3else change_state(state_game)
end,
chest=function()
if(btnp(5))sel_chest.entity.anim_frame=0if(chest.anim_playing)for i=1,tbl_len(sel_chest.anim_frame)do sel_chest.anim_frame[i]=1end else change_state(state_game)
end,
read=function()
if(btnp(5))change_state(state_game)
end,
dead=function()
if(btnp(5))reset()
end
}
msg={
width=94,
queue={},
txt="welcome to game",
turn=0,
frame=0,
delay=0,
add=function(s)
if(msg.turn<turn)msg.queue={}msg.turn=turn msg.txt_set(s)else add(msg.queue,s)
end,
txt_set=function(s)
msg.txt=s
msg.frame=0
msg.delay=8
end,
anim_step=function()
if msg.frame>=msg.width do msg.frame=msg.width if(#msg.queue>0)msg.delay-=1if(msg.delay<=0)msg.txt_set(deli(msg.queue,1))
else msg.frame+=3end
end
}
inventory={
items={},
num=0,
add_item=function(e)
inventory.add_possession(possession.new_from_entity(e))
end,
add_possession=function(itm)
add(inventory.items,itm)
inventory.num+=1
end,
remove=function(itm)
if(itm)del(inventory.items,itm)inventory.num-=1
end
}
function reset()
change_state(state_reset)
for i=0,32767,rnd(15)do poke(i,rnd(15))end
end
function change_state(new_state,sel)
state=new_state
if(init[state])init[state](sel)
end
function pos_to_screen(pos)
return{x=8*(pos.x-cam_x),y=8*(pos.y-cam_y)}
end
function pal_set(param,lock)
if(not pal_lock)pal_lock=lock or false pal(param)
end
function pal_all(c,lock)
pal_set({0,c,c,c,c,c,c,c,c,c,c,c,c,c,c},lock or false)
end
function pal_unlock()
pal_lock=false
pal()
end
function populate_map()
for x=0,127do for y=0,67do
if(fget(mget(x,y),flag_entity))entity.entity_spawn(mget(x,y),x,y)
if(mget(x,y)==sprite_void)mset(x,y,sprite_empty)
end end
end
function collision(x,y)
if(x<0or x==width or x==128or y<0or y==height or fget(mget(x,y),flag_collision))return true
for e in all(entity.entities)do if(e.collision and e.x==x and e.y==y)return true end
return false
end
function in_reach(a,b)
return dist(a,b)<=1and(a.x==b.x or a.y==b.y or not collision(a.x,b.y)or not collision(b.x,a.y))
end
function do_turn()
for i=1,tbl_len(spells)do spells_cd[i]=max(0,spells_cd[i]-1)end
for e in all(entity.entities)do e:do_turn()end
turn+=1
end
function update_camera()
local x,y,p_x,p_y=cam_x,cam_y,player.x,player.y
if(p_x-cam_x>15-cam_offset and(room or cam_x<width-16))x=p_x-15+cam_offset
if(p_x-cam_x<cam_offset and cam_x>cam_x_min)x=p_x-cam_offset
if(p_y-cam_y>13-cam_offset and cam_y<height-14)y=p_y-13+cam_offset
if(p_y-cam_y<cam_offset and cam_y>cam_y_min)y=p_y-cam_offset
if(room==nil and cam_x<cam_x_min)x=cam_x_min
if(room==nil and cam_y<cam_y_min)y=cam_y_min
if(x~=cam_x or y~=cam_y)if(player.anim_frame>0)camera((x-cam_x)*8+player.anim_x,(y-cam_y)*8+player.anim_y)else cam_x,cam_y=x,y
end
function change_room(new_room)
room=new_room
end
function cast_spell(i,e)
msg.add("casted "..spells[i])
status=statuses[i]
e:add_status(status)
if(status==status_charmed and#player.followers>max_followers)for e in all(player.followers)do e:clear_status(status_charmed)break end
end
function set_look()
tbl_merge(sel_look,{name="none",usable=false,text="interact",color=5,possession=nil})
sel_look.entity=nil
local e=entity.entity_at(sel_look.x,sel_look.y)
if(e and sel_look.spell>0)e=e.class==enemy.class and not e.dead and not e:get_status(status_charmed)and e or nil
if(e)e:look_at(sel_look)if(sel_look.spell>0)sel_look.usable=true
if(sel_look.spell>0)sel_look.text="cast"
end
object={
class="object",
parent_class=nil,
inherit=function(self,tbl)
return setmetatable(tbl or{},{__index=self})
end
}
drawable=object:inherit({
class="drawable",
parent_class=object.class,
sprite=0,
flipped=false,
flash_frame=0,
pal_swap=split"1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16",
pal_swap_enable=false,
data_from_entity=function(e)
return{sprite=e.sprite or drawable.sprite,pal_swap=e.pal_swap or drawable.pal_swap,pal_swap_enable=e.pal_swap_enable or drawable.pal_swap_enable}
end,
vec2_spr=function(self,pos,sprite)
local sprite=sprite or self.sprite
self:spr(pos.x,pos.y,sprite)
end,
spr=function(self,x,y,sprite,no_flip)
local sprite=sprite or self.sprite
if self.flash_frame>0do
self.flash_frame-=1
pal_all(7)
elseif self.pal_swap_enable do
pal_set(self.pal_swap)
end
palt(0,false)
palt(15,true)
spr(sprite,x,y,1,1,no_flip and false or self.flipped)
pal_set()
end
})
entity=drawable:inherit({
class="entity",
parent_class=drawable.class,
entities={},
num=0,
x=0,
y=0,
name=nil,
collision=true,
interactable=true,
interact_text="interact",
entity_name=function(e)
return e.name and e.name or e.item_class and e.item_class or e.class
end,
entity_at=function(x,y)
for e in all(entity.entities)do if(e.class==item.class and e.x==x and e.y==y)return e end
for e in all(entity.entities)do if(e.class==enemy.class and e.x==x and e.y==y and not e:check_status(status_charmed)and not e.dead)return e end
for e in all(entity.entities)do if(e.x==x and e.y==y)return e end
return nil
end,
entity_spawn=function(sprite,x,y)
mset(x,y,sprite_empty)
local tbl,e_data={x=x,y=y,sprite=sprite},data_entities[sprite]
if(e_data)if(e_data.class==player.class)tbl_merge(player,tbl)local companion_sprite=rnd()>.5and sprite_companion_cat or sprite_companion_dog tbl_merge(companion,tbl_merge_new({x=x,y=y,sprite=companion_sprite},data_entities[companion_sprite]))else tbl_merge(tbl,e_data)_𝘦𝘯𝘷[tbl.class]:new(tbl)
end,
new=function(self,tbl)
local tbl=self:inherit(tbl)
entity.num=entity.num+1
tbl["id"]=entity.num
tbl["prev_x"],tbl["prev_y"]=tbl.x,tbl.y
add(entity.entities,tbl)
return tbl
end,
destroy=function(self)
del(entity.entities,self)
end,
update=function(self)end,
draw=function(self,offset,pos,sprite)
if(self:in_frame(offset))self:vec2_spr(vec2_add(pos or pos_to_screen(self),vec2_scale(offset or{x=0,y=0},8)),sprite)return true
return false
end,
get_name=function(self)
return entity.entity_name(self)
end,
look_at=function(self,tbl)
tbl_merge(tbl,{entity=self,name=self:get_name(),color=6,text=self.interact_text,usable=self.interactable and in_reach(player,self)})
end,
interact=function(self)end,
do_turn=function(self)end,
in_frame=function(self,offset)
local pos=vec2_add(self,offset or{x=0,y=0})
return pos.x>=cam_x-1and pos.x<cam_x+17and pos.y>=cam_y-1and pos.y<cam_y+15
end
})
creature=entity:inherit({
class="creature",
parent_class=entity.class,
anims={move={frames=4,dist=8},attack={frames=5,dist=6}},
anim_queue={},
anim_playing=false,
dead=false,
attacked=false,
blink_delay=0,
anim=nil,
anim_frame=0,
anim_x=0,
anim_y=0,
anim_x1=0,
anim_y1=0,
dhp=0,
dhp_turn=0,
target=nil,
target_turn=0,
status=0,
status_timer={},
max_hp=10,
ap=2,
new=function(self,tbl)
local tbl=entity.new(self,tbl)
tbl["hp"]=tbl.max_hp
return tbl
end,
update=function(self)
if self.anim_frame>0do
for e in all(creature.anim_queue)do
if(e==self)self:anim_step()
if(e.anim==creature.anims.attack)break
end
elseif prev_frame~=frame and self.blink_delay>0do self.blink_delay-=1end
end,
draw=function(self,offset)
if self:in_frame(offset)do
local sprite,x,y=self.sprite+frame*16,self:screen_pos().x,self:screen_pos().y
if self.anim_frame<=0do
if self.dead do sprite=frame==1and turn-self.dhp_turn<=1and self.blink_delay<=0and not creature.anim_playing and sprite_void or sprite_grave
elseif self.attacked and frame==1and self.blink_delay<=0and not creature.anim_playing do
sprite=sprite_void
if(state==state_game)print(abs(self.dhp),x+4-str_width(abs(self.dhp))*.5,y+1,self.dhp<0and 8or 11)
end
end
entity.draw(self,offset,self:screen_pos(),sprite)
if sprite~=sprite_void and sprite~=sprite_grave do
local pos={x=x,y=y}
if(self:check_status(status_charmed))vec2_spr(55,pos)pos.x+=6
if(self:check_status(status_sleeping))vec2_spr(54,pos)pos.x+=4
if(self:check_status(status_scared))vec2_spr(56,pos)pos.x+=3
if(self:check_status(status_poisoned))vec2_spr(53,pos)pos.x+=4
end
return true
end
return false
end,
screen_pos=function(self)
return vec2_add(pos_to_screen(self),{x=self.anim_x,y=self.anim_y})
end,
look_at=function(self,tbl)
if(not self.dead)entity.look_at(self,tbl)tbl.color=self.class==enemy.class and 2or 3return true
return false
end,
do_turn=function(self)
if(turn>self.dhp_turn)self.attacked=false
if(self.dead and turn-self.dhp_turn>timer_corpse)self:destroy()
if(self.target and(self.target.dead or turn>self.target_turn+timer_target or self.target:check_status(status_charmed)))self.target=nil
if self:check_status(status_poisoned)do
if(self==player)msg.add(self:get_name().." took poison damage")
self:take_dmg(flr(2*(.5+rnd())+.5))
end
for i=2,4do
local status=statuses[i]
if self:check_status(status)do
if(self.status_timer[status]<=0)self:clear_status(status)
self.status_timer[status]-=1
end
end
return not self.dead and self:in_frame()and not self:check_status(status_sleeping)
end,
play_anim=function(self,a,x,y,x1,y1)
tbl_merge(self,{anim=a,anim_frame=a.frames,anim_x=x*a.dist,anim_y=y*a.dist,anim_x1=(x1 or 0)*a.dist,anim_y1=(y1 or 0)*a.dist})
add(creature.anim_queue,self)
creature.anim_playing=true
end,
anim_step=function(self)
local anim_pos,x,y=smoothstep(self.anim_frame/self.anim.frames),self.anim_x,self.anim_y
if self.anim==creature.anims.attack do
x,y=self.anim_x1,self.anim_y1
if self.target do
if(self.anim_frame==self.anim.frames and self.target==player)flash_frame=2
if(self.anim_frame==self.anim.frames-3)self.target.flash_frame=2
end
end
self.anim_x=self.anim.dist*anim_pos*(x<-.1and-1or x>.1and 1or 0)
self.anim_y=self.anim.dist*anim_pos*(y<-.1and-1or y>.1and 1or 0)
self.anim_frame-=1
if self.anim_frame<=0do
del(creature.anim_queue,self)
if(#creature.anim_queue==0)creature.anim_playing=false
self.anim_x,self.anim_y=0
end
end,
move=function(self,x,y)
if not collision(x,y)and x>=0and x<128and y>=0and y<64and(x~=0or y~=0)do
if(self.x~=x)self.flipped=self.x>x
self:play_anim(creature.anims.move,self.x-x,self.y-y)
tbl_merge(self,{prev_x=self.x,prev_y=self.y,x=x,y=y})
return true
end
return false
end,
follow=function(self,other)
if(in_reach(self,{x=other.prev_x,y=other.prev_y}))self:move(other.prev_x,other.prev_y)else self:move_towards(other)
end,
move_towards_and_attack=function(self,other)
if(in_reach(self,other))self:attack(other)else self:move_towards(other)
end,
move_towards=function(self,other,reverse)
local diff_x,diff_y=reverse and self.x-other.x or other.x-self.x,reverse and self.y-other.y or other.y-self.y
local desire_x,desire_y=diff_x>0and 1or diff_x<0and-1or 0,diff_y>0and 1or diff_y<0and-1or 0
return abs(diff_x)<abs(diff_y)and self:move(self.x,self.y+desire_y)or(self:move(self.x+desire_x,self.y)or self:move(self.x,self.y+desire_y))
end,
attack=function(self,other)
msg.add(self:get_name().." attacked "..other:get_name())
if other:take_dmg(flr(self.ap*(.5+rnd())+.5))do
msg.add(self:get_name().." killed "..other:get_name())
if(other~=player)player.xp+=other.xp
else
other.target=self
self.target=other
self.target_turn,other.target_turn=turn,turn
end
self:play_anim(creature.anims.attack,0,0,other.x-self.x,other.y-self.y)
end,
add_status=function(self,status)
self.status_timer[status]=status==status_poisoned and timer_effect_poison or timer_effect
if(status==status_scared)self:clear_status(status_charmed|status_sleeping)
if(status==status_charmed or status==status_sleeping)self:clear_status(status_scared)
if(status==status_charmed)self.collision=false add(player.followers,self)
self.status=self.status|status
end,
clear_status=function(self,status)
self.status=self.status&~status
if(status==status_charmed)self.collision=true del(player.followers,self)
end,
check_status=function(self,status)
return self.status&status==status
end,
take_dmg=function(self,dmg)
self:clear_status(status_sleeping)
if(dmg<0)self:clear_status(status_poisoned)
self.blink_delay=frame==0and 2or 1
self.attacked=true
self.dhp=self.dhp_turn==turn and self.dhp-dmg or dmg*-1
self.dhp_turn=turn
self.hp=min(max(self.hp-dmg,0),self.max_hp)
if(self.hp<=0)self:kill()return true
return false
end,
kill=function(self)
self.dead=true
self.collision=false
del(player.followers,self)
if(self==player)change_state(state_dead)
end
})
player=creature:new({
class="player",
parent_class=creature.class,
interactable=false,
collision=false,
name="you",
xp=0,
max_hp=20,
followers={},
look_at=function(self,tbl)
end,
action_dir=function(self,x,y)
local valid=self:move(x,y)
for e in all(entity.entities)do
if(e.x==x and e.y==y)if e.class==enemy.class and not e:check_status(status_charmed)and not e.dead do self:attack(e)valid=true elseif e.class==stairs.class do e:trigger()valid=true end
end
return valid
end
})
companion=creature:new({
class="companion",
parent_class=creature.class,
interact_text="pet",
collision=false,
ap=1,
interact=function(self)
msg.add("you petted the "..self:get_name())
change_state(state_game)
end,
do_turn=function(self)
if creature.do_turn(self)do
if player.target do
self:move_towards_and_attack(player.target)
else
local target,prev=player,companion
for e in all(player.followers)do
if(e==self)target=prev
prev=e
end
self:follow(target)
end
elseif not self:in_frame()do
self.x,self.y=player.prev_x,player.prev_y
end
end
})
npc=creature:inherit({
class="npc",
parent_class=creature.class,
interact_text="talk",
interact=function(self)
local sel={entity=self,text=split(data_dialogue[self.sprite],"\n"),anim_frame={},pos=1}
for line in all(sel.text)do add(sel.anim_frame,timer_dialog_line+#line*4)end
change_state(state_dialogue,sel)
end
})
enemy=creature:inherit({
class="enemy",
parent_class=creature.class,
interactable=true,
ap=1,
max_hp=5,
xp=1,
look_at=function(self,tbl)
if(creature.look_at(self,tbl)and not self:check_status(status_charmed))tbl.text="attack"
end,
interact=function(self)
change_state(state_game)
player:attack(self)
do_turn()
end,
do_turn=function(self)
if self.status&status_charmed==status_charmed do companion.do_turn(self)
elseif creature.do_turn(self)do
if(self.status&status_scared==status_scared)self:move_towards(player,true)else self:move_towards_and_attack(player)
end
end
})
door=entity:inherit({
class="door",
parent_class=entity.class,
lock=0,
new=function(self,tbl)
if tbl.lock and tbl.lock>0do
for d in all(data_locks.doors)do if(d.x==tbl.x and d.y==tbl.y)tbl.lock=d.lock or 1break
end
key.set_variant(tbl,tbl.lock)
end
return entity.new(self,tbl)
end,
look_at=function(self,tbl)
entity.look_at(self,tbl)
if self.lock==0do
tbl.text=self.collision and"open"or"close"
else
tbl.text,tbl.name="unlock","locked "..tbl.name
if tbl.usable do
tbl.usable=false
for itm in all(inventory.items)do if(itm.class==key.class and itm.lock==self.lock)tbl_merge(tbl,{usable=true,possession=itm})break
end
end
end
end,
interact=function(self)
self.collision=not self.collision
self.sprite=self.collision and sprite_door_closed or sprite_door_open
if(self.lock>0)self.lock=0self.pal_swap_enable=false msg.add"unlocked door"else msg.add((self.collision and"closed"or"opened").." door")
change_state(state_game)
end
})
stairs=entity:inherit({
class="stairs",
parent_class=entity.class,
interactable=false,
collision=false,
trigger=function(self)
local stair=nil
for e in all(data_floors.stairs)do if(e.x==player.x and e.y==player.y)stair=e break end
local target_stair,delta_z=data_floors.stairs[stair.target],room and room.z or 0
room=data_floors.rooms[target_stair.room]
delta_z,cam_x_min,cam_y_min=(room and room.z or 0)-delta_z,room and target_stair.x-player.x or 0,room and target_stair.y-player.y or 0
cam_x_diff,cam_y_diff=target_stair.x-stair.x,target_stair.y-stair.y
player.x,player.y=target_stair.x,target_stair.y
cam_x,cam_y=cam_x+target_stair.x-stair.x,cam_y+target_stair.y-stair.y
msg.add("went "..(delta_z>0and"up"or"down").." stairs")
draw.play_fade(change_room,room)
end
})
sign=entity:inherit({
class="sign",
parent_class=entity.class,
interact_text="read",
message="...",
bg=15,
fg=0,
new=function(self,tbl)
for d in all(data_signs)do if(d.x==tbl.x and d.y==tbl.y)tbl.message=d.message break
end
return entity.new(self,tbl)
end,
interact=function(self)
change_state(state_read,self)
end
})
chest=entity:inherit({
class="chest",
parent_class=entity.class,
interact_text="open",
anim_playing=false,
anim_frame=0,
anim_this=false,
open=false,
content={},
new=function(self,tbl)
for d in all(data_chests)do
if d.x==tbl.x and d.y==tbl.y do
tbl.content={}
for itm in all(d.content)do
local e_data=tbl_merge_new(data_entities[itm.sprite],itm)
if(e_data.item_class==key.class)key.set_variant(e_data,e_data.item_data.lock)
add(tbl.content,possession.new_from_entity(e_data))
end
return entity.new(self,tbl)
end
end
return nil
end,
look_at=function(self,tbl)
entity.look_at(self,tbl)
tbl.usable=tbl.usable and not self.open
end,
interact=function(self)
self.open=true
self.sprite=sprite_chest_open
self.anim_frame=45
self.anim_this=true
chest.anim_playing=true
local sel={entity=self,anim_frame={}}
for itm in all(self.content)do
add(sel.anim_frame,60)
inventory.add_possession(itm)
msg.add("got "..itm.name)
end
change_state(state_chest,sel)
end,
anim_step=function(self)
if(self.anim_frame>0)self.anim_frame-=1
end,
item_anim_pos=function(self,anim_pos,target)
return{x=lerp(anim_pos+sin(anim_pos*-.5)*.75,pos_to_screen(self).x,target.x),y=lerp(anim_pos+cos(anim_pos*.9+.1)*.3-.3,pos_to_screen(self).y,target.y)}
end,
draw=function(self,offset)
if entity.draw(self,offset)and self.anim_this do
local x,y=pos_to_screen(self).x,pos_to_screen(self).y
if(blink)rectfill(x+1,y+2,x+5,y+3,7)
if(self.anim_frame>=30or self.anim_frame>10and blink)y-=(45-self.anim_frame)*.25clip(x,y,8,5)self:spr(x,y,sprite_chest_closed)clip()
end
end
})
item=entity:inherit({
class="item",
parent_class=entity.class,
collision=false,
interact_text="pick up",
new=function(self,tbl)
tbl.item_data=tbl.item_data and tbl_copy(tbl.item_data)or{}
if(tbl.item_class==key.class)key.get_data(tbl)
return entity.new(self,tbl)
end,
interact=function(self)
msg.add("picked up "..self:get_name())
inventory.add_item(self)
self:destroy()
change_state(state_game)
end
})
possession=drawable:inherit({
class="possession",
parent_class=drawable.class,
num=0,
name=nil,
interactable=true,
new=function(self,tbl)
tbl,possession.num=self:inherit(tbl),possession.num+1
tbl["id"]=possession.num
return tbl
end,
new_from_entity=function(e)
return _𝘦𝘯𝘷[e.item_class]:new(tbl_merge_new(tbl_merge_new({name=entity.entity_name(e)},drawable.data_from_entity(e)),e.item_data))
end
})
key=possession:inherit({
class="key",
parent_class=possession.class,
interactable=false,
colors={{"steel",6,13},{"gold",10,9},{"green",11,3}},
get_data=function(tbl)
for d in all(data_locks.keys)do if(d.x==tbl.x and d.y==tbl.y)tbl.item_data["lock"]=d.lock or 1break
end
key.set_variant(tbl,tbl.item_data.lock)
end,
set_variant=function(tbl,i)
if(i>1)tbl["pal_swap_enable"]=true tbl["pal_swap"]={[key.colors[1][2]]=key.colors[i][2],[key.colors[1][3]]=key.colors[i][3]}
if(entity.entity_name(tbl)=="key")tbl.name=key.colors[i][1].." key"
end
})
consumable=possession:inherit({
class="consumable",
parent_class=possession.class,
interact=function(self)
msg.add("consumed "..self.name)
if(self.dhp)player:take_dmg(-self.dhp)
end
})