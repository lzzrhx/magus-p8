timer_corpse=20
timer_target=24
timer_dialog_line=24
timer_effect=24
timer_effect_poison=6
timer_spell=8
timer_spell_charm=24
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
if fade_frame==3do rectfill(0,0,128,128,0)
else for j=0,15do for k=0,15do?"ᵉ"..fade_chars[fade_frame>#fade_chars and 6-fade_frame or fade_frame],j*8,k*8,0
end end end
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
?"ˇˇˇˇˇˇˇˇˇˇˇˇ",19,54,6
if not title_idle do
for k,v in pairs(title_text)do
?v,64-str_width(v)*.5,78+k*8,5
?v,64-str_width(v)*.5,77+k*8,6
end
elseif frame==0do s_print("start game ❎",38,85)end
camera(0,0)
for i=0,1do for j=0,15do
local x=j*8+flr(rnd()+.5)
?"ᵉ"..fade_chars[2],x,130*i-5,0
?"ᵉ"..fade_chars[1],x,128*i-4,0
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
for e in all(entity.entities)do if(not e.collision)e:draw()end
for e in all(entity.entities)do if(e.collision)e:draw()end
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
if(state==state_game)?msg.txt,2,114,5
?msg.txt,2,113,6
clip(msg.frame,0,msg.frame>msg.width-3and msg.width-msg.frame or 3,128)
?msg.txt,2,112,7
clip()
if(state==state_game or state==state_dead)msg.anim_step()
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
?btns,29,97,5
clip(24,0,sel_menu.tab==0and spells_cd[sel_menu.i]==0and 80or sel_menu.tab==1and inventory.num>0and inventory.items[sel_menu.i].interactable and 80or 40,128)
?btns,29,96,6
clip()
if sel_menu.tab==0do
?"⬅️ magick ➡️",40,23,0
?"▶",33,25+sel_menu.i*7,6
for i=1,tbl_len(spells)do?(spells_cd[i]>0and"("..spells_cd[i]..") "or(i==1and#player.followers>=max_followers and"(max) "or""))..spells[i],38,25+i*7,sel_menu.i==i and 6or 5
end
elseif sel_menu.tab==1do
?"⬅️ inventory ➡️",34,23,0
if inventory.num==0do
?"empty",35,32,5
else
?"▶",33,25+sel_menu.i*7,6
for i=1,inventory.num do?inventory.items[i].name,38,25+i*7,sel_menu.i==i and 6or 5
end
end
elseif sel_menu.tab==2do
?"⬅️ character ➡️",34,23,0
?"hp: "..player.hp.."/"..player.max_hp.."\nxp: "..player.xp,35,32,6
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
if(f>0and f~=#v*4+timer_dialog_line)clip(#v*4+timer_dialog_line-f,0,3,128)?v,2,y-1,7
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
?txt[i],64-str_width(txt[i])*.5,29-exp+max(5-#txt,0)*4+i*8,sel_read.fg
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
if(status==status_charmed and#player.followers>max_followers)for e in all(player.followers)do del(player.followers,e)break end
end
function set_look()
tbl_merge(sel_look,{name="none",usable=false,text="interact",color=5,possession=nil})
sel_look.entity=nil
local e=entity.entity_at(sel_look.x,sel_look.y)
if(e and sel_look.spell>0)e=e.class==enemy.class and not e.dead and e or nil
if(e)e:look_at(sel_look)if(sel_look.spell>0)sel_look.usable=true
if(sel_look.spell>0)sel_look.text="cast"
end