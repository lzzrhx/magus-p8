-- constants
timer_corpse=20 -- timeout for grave (turns)
timer_target=24 -- timeout for target (turns)
timer_seen_player=5 -- timeout for enemy following player when no longer visible (turns)
timer_dialog_line=24 -- timeout for next line in dialogue (frames)
timer_effect=16 -- effect timer for most status effects (turns)
timer_effect_sleeping=24 -- effect timer for sleep (turns)
timer_effect_poisoned=3 -- effect timer for poison (turns)
timer_spell=24 -- cooldown for casting spells (turns)
timer_spell_charm=48 -- cooldown for casting befriend spell (turns)
max_followers=5
max_tomes=4

-- game states
state_reset="reset"
state_title="title"
state_game="game"
state_menu="menu"
state_look="look"
state_dialogue="dialogue"
state_chest="chest"
state_read="read"
state_game_over="game_over"

-- status effects
status_charmed=0b0001
status_scared=0b0010
status_sleeping=0b0100
status_poisoned=0b1000
statuses=split"0b0001,0b0010,0b0100,0b1000"

-- sprite flags
flag_collision=0
flag_block_view=1
flag_entity=2

-- vars
state=nil -- game state
room=nil
turn=1 -- turn number
frame=0 -- animation frame (updates twice per second)
prev_frame=0 -- previous animation frame
blink_frame=0 -- frame for fast blink animations (updates 30 times per second)
blink=false
flash_frame=0
fade_frame=0
fade_chars=split"░,▒"
fade_action=nil
pal_lock=false -- lock palette setting
cam_x=0 -- camera x position
cam_y=0 -- camera y position
cam_offset=4 -- camera scroll offset
cam_x_min=0
cam_y_min=0
cam_x_diff=0
cam_y_diff=0
title_effect_num=96
title_effect_colors=split"8,9,10,11,12,13,14,15"
title_text=split(data_story_intro,"\n")
spell_cooldown=split"0,0,0,0"
keys=split"0,0,0"
consumables=split"0,0,0"
tomes=0




-- init
function _init()
change_state(state_title)
populate_map()
end

-- update
function _update()
if state==state_reset then
run()
else
blink_frame=(blink_frame+1)%2
blink=blink_frame%2==0
prev_frame=frame
frame=flr(time()*2%2)
update[state]()
end
end

-- draw
function _draw()
if state~=state_reset then
draw[state]()
draw.flash_step()
draw.fade_step()
end
end



-- init
init={
-- title state
title=function(sel)
title_idle=true
title_pos=0
end,

-- menu state
menu=function(sel)
sel_menu={tab=0,i=1}
end,

-- look state
look=function(sel)
sel_look={spell=0,x=player.x,y=player.y}
set_look()
end,

-- dialogue state
dialogue=function(sel)
sel_dialogue=sel
end,

-- chest state
chest=function(sel)
sel_chest=sel
end,

-- read state
read=function(sel)
sel_read=sel
end,
}



-- update
update={
-- title state
title=function()
if(not title_idle)title_pos+=0.2
if(title_pos>=str_height(data_story_intro)*8+85 and fade_frame==0)draw.play_fade(change_state,state_game)
input.title()
end,

-- game state
game=function()
for e in all(entity.entities) do e:update() end
update_camera()
if(not creature.anim_playing and input.game())do_turn()
end,

-- menu state
menu=function()
input.menu()
end,

-- look state
look=function()
if(input.look())set_look()
end,

-- dialogue state
dialogue=function()
input.dialogue()
end,

-- chest state
chest=function()
if(sel_chest.entity.anim_this)sel_chest.entity:anim_step()
input.chest()
end,

-- read state
read=function()
input.read()
end,

-- game over state
game_over=function()
for e in all(entity.entities) do e:update() end
input.game_over()
end,
}



-- draw
draw={
-- start playing fade
play_fade=function(func,param)
fade_frame=5
fade_action=func and {func=func,param=param} or nil
end,

-- perform fade animation step
fade_step=function()
if fade_frame>0 then
if fade_frame==3 then rectfill(0,0,128,128,0)
else for j=0,15 do for k=0,15 do print("\014"..fade_chars[fade_frame>#fade_chars and 6-fade_frame or fade_frame],j*8,k*8,0) end end end
fade_frame-=1
if(fade_frame==3 and fade_action)fade_action.func(fade_action.param)
end
end,

-- perform screen flash animation step
flash_step=function()
if flash_frame>0 then
cls(state==state_game and player.hp<5 and flash_frame==1 and 8 or 7)
flash_frame-=1
end
end,

-- monochrome mode
monochrome=function()
-- screen memory as the sprite sheet
poke(0x5f54,0x60)
pal_all(1)
sspr(0,0,128,128,0,0)
pal_set()
-- reset spritesheet
poke(0x5f54,0x00)
end,

-- window frame
window_frame=function(h)
h=h or 2
if h>0 then
rectfill(0,125-h*7,127,127,1)
line(0,125-h*7,127,125-h*7,6)
end
rect(0,0,127,127,6)
pset(0,0,0)
pset(127,0,0)
pset(0,127,0)
pset(127,127,0)
end,

-- title state
title=function()
cls(0)
camera(0,title_pos)
-- title effect
for i=1,title_effect_num do
local x=cos(time()/8+i/title_effect_num)*56
local y=sin(time()/8+i/title_effect_num)*16+sin(time()+i*(1/title_effect_num)*5)*4
local c=title_effect_colors[i%#title_effect_colors+1]
for j=1,3 do pset(62+x+j,50+y+j,c) end
end
clip(0,46-title_pos,128,8) --this is a fix for the fake-8 emulator
poke(0x5f58,0x81)
s_print("magus magicus",13,45,true,true,7,4)
poke(0x5f58,0)
clip()
print("ˇˇˇˇˇˇˇˇˇˇˇˇ",19,54,6)
-- intro text
if not title_idle then
for k,v in pairs(title_text) do
print(v,64-(str_width(v))*0.5,78+k*8,5)
print(v,64-(str_width(v))*0.5,77+k*8,6)
end
-- button legend
elseif frame==0 then s_print("start game ❎",38,85) end
camera(0,0)
-- text fade effect
for i=0,1 do for j=0,15 do
local x=j*8+flr(rnd()+0.5)
print("\014"..fade_chars[2],x,130*i-5,0)
print("\014"..fade_chars[1],x,128*i-4,0)
end end
draw.window_frame(0)
-- set clipping for fade after pressing start
clip(1,84,126,43)
end,

-- game state
game=function()
-- draw map and entities
cls()
if room then
local x0=max(0,(room[2]-cam_x+1)*8)
local y0=max(0,(room[3]-cam_y+1)*8)
local x1=min(128,(room[4]-cam_x)*8)
local y1=min(128,(room[5]-cam_y)*8)
if room[1]>0 then
pal_all(1,true)
map(cam_x-cam_x_diff-1,cam_y-cam_y_diff-room[1]-1,-8,-8,18,16)
for e in all(entity.entities) do e:draw({x=cam_x_diff,y=cam_y_diff+room[1]}) end
pal_unlock()
end
rectfill(x0,y0,x1,y1,0)
map(room[2],room[3],(room[2]-cam_x)*8,(room[3]-cam_y)*8,room[4]-room[2]+1,room[5]-room[3]+1)
clip(x0,y0,x1-x0,y1-y0)
else
map(cam_x-1,cam_y-1,-8,-8,18,16)
end
for e in all(entity.entities) do if(e~=player and (e.parent_class~=creature.class or e.dead))e:draw() end
for e in all(entity.entities) do if(e~=player and (e.parent_class==creature.class and not e.dead))e:draw() end
player:draw()
clip()
camera()
-- ui elements
draw.window_frame()
local hp=max(0,player.hp/player.max_hp)
s_print("hp:",2,120,state==state_game)
if(state==state_game)rectfill(14,120,82,124,5)
if(hp>0)rectfill(14,120,14+68*hp,124,(hp<0.25 and 8) or (hp<0.5 and 9) or (hp<0.75 and 10) or 11)
s_print("menu 🅾️",98,113,state==state_game)
s_print("look ❎",98,120,state==state_game)
-- animated message
clip(0,0,msg.frame,128)
if(state==state_game)print(msg.txt,2,114,5)
print(msg.txt,2,113,6)
clip(msg.frame,0,(msg.frame>msg.width-3 and msg.width-msg.frame) or 3,128)
print(msg.txt,2,112,7)
clip()
if(state==state_game or state==state_game_over)msg.anim_step()
end,

-- menu state
menu=function()
-- draw map and entities
draw.game()
draw.monochrome()
-- bg box
line(32,21,94,21,6)
line(32,90,94,90,6)
line(31,22,31,89,6)
line(95,22,95,89,6)
rectfill(32,21,94,27,6)
line(32,59,94,59,6)
-- button legend
local btns="cancel 🅾️  use ❎"
print(btns,30,99,5)
clip(30,0,((sel_menu.tab==0 and spell_cooldown[sel_menu.i]==0) or (sel_menu.tab==1 and tbl_sum(consumables)>0)) and 80 or 40,128)
print(btns,30,98,6)
clip()
-- magic tab
if sel_menu.tab==0 then
print("⬅️ magick ➡️",40,22,0)
print("▶",34,24+sel_menu.i*7,6)
for i=1,tbl_len(spell_names) do
local pre=spell_cooldown[i]>0 and "("..spell_cooldown[i]..") " or (i==1 and #player.followers>=max_followers and "(max) ") or ""
local y=24+i*7
print(pre..spell_names[i],39,y,sel_menu.i==i and spell_cooldown[i]==0 and 6 or 5)
if(spell_cooldown[i]>0)line(37+str_width(pre),y+1,39+str_width(pre)+str_width(spell_names[i]),y+3,5)
end
local txt = split(spell_txt[sel_menu.i],"\n")
for i=1,tbl_len(txt) do print(txt[i],34,55+i*7,6) end
-- inventory tab
elseif sel_menu.tab==1 then
print("⬅️ inventory ➡️",34,22,0)
if tbl_sum(consumables)==0 then
print("nothing",36,31,5)
else
print("▶",34,24+sel_menu.i*7,6)
local j=1
for i=1,#consumables do if(consumables[i]>0)print((consumables[i]>1 and "("..consumables[i]..") " or "")..consumable_names[i],39,24+j*7,sel_menu.i==j and 6 or 5) j+=1 end 
end
print("tomes:      "..tomes.."/"..max_tomes,34,62,6)
print(key_names[1].."s:    "..keys[1],34,69,6)
print(key_names[2].."s:    "..keys[2],34,76,6)
print(key_names[3].."s:   "..keys[3],34,83,6)
end
end,

-- look state
look=function()
-- draw map, entities and selection
draw.game()
if(state==state_look)draw.monochrome()
player:draw()
if(sel_look.entity)sel_look.entity:draw()
if(state==state_look)vec2_spr(14,pos_to_screen(sel_look))
-- ui elements
draw.window_frame()
local btn_x=sel_look.text.." ❎"
s_print(sel_look.spell==0 and "target:" or "cast "..spell_names[sel_look.spell].." on:",2,113,state==state_look)
s_print(sel_look.name,2,120,state==state_look,sel_look.entity~=nil,sel_look.color,sel_look.entity and sel_look.entity.parent_class==creature.class and 0 or 5)
s_print("cancel 🅾️",90,113,state==state_look)
s_print(btn_x,126-str_width(btn_x),120,state==state_look,sel_look.usable)
end,

-- dialogue state
dialogue=function()
draw.game()
draw.monochrome()
player:draw()
sel_dialogue.entity:draw()
draw.window_frame(4)
if (sel_dialogue.anim_frame[min(sel_dialogue.pos+2,#sel_dialogue.text)]<=0 and frame==0)s_print("continue ❎",82,99)
-- dialogue message
s_print(sel_dialogue.entity:get_name()..":",2,99)
for k,v in pairs(sel_dialogue.text) do
local f=sel_dialogue.anim_frame[k]
if k>=sel_dialogue.pos and k<=sel_dialogue.pos+2 then
local y=106+(k-sel_dialogue.pos)*7
clip(0,0,#v*4+timer_dialog_line-f,128)
s_print(v,2,y)
if f>0 and f~=#v*4+timer_dialog_line then
clip(#v*4+timer_dialog_line-f,0,3,128)
print(v,2,y-1,7)
end
if(f>0 and (k==sel_dialogue.pos or sel_dialogue.anim_frame[k-1]<=0))sel_dialogue.anim_frame[k]-=3
end
end
clip()
end,

-- chest state
chest=function()
-- vars
local e=sel_chest.entity
local n=tbl_len(e.content)
-- draw player and chest
cls()
player:draw()
e:draw()
if(not chest.anim_playing)draw.monochrome()
-- wait for chest open animation to finish
if e.anim_frame<=0 then
-- iterate through chest items
for i=1,n do
local f=sel_chest.anim_frame[i]
local target_pos={x=52-n*8+i*16,y=52}
-- wait for animation of previous item to finish before playing the next
if i==1 or sel_chest.anim_frame[i-1]<=0 then
local itm=e.content[i]
-- play animation for current item
if f>0 then
-- stop chest blinking on last item
if(i==n)e.anim_this=false
-- set item color to white
pal_all(7)
-- draw animated item with trailing echoes
for j=0,10 do
local pos=e:item_anim_pos(smoothstep(min(1,(1-(f/60))+0.025*j)),target_pos)
if(blink)vec2_spr(itm.sprite,pos)
end
-- reset palette and decrement animation frame
pal_set()
sel_chest.anim_frame[i]-=1
-- flash the screen and set chest animation to finished after last item animation is done
if sel_chest.anim_frame[n]<=0 then 
chest.anim_playing=false
flash_frame=2
end
-- draw the item bobbing up and down after the popping out of chest animation has finished
elseif not chest.anim_playing or blink then vec2_spr(itm.sprite,vec2_add(target_pos,{x=0,y=wavy()})) end
end
end
end
-- wavy button press text
if(not chest.anim_playing)wavy_print("take items ❎",38,85)
end,

-- read state
read=function()
draw.look()
draw.monochrome()
local txt=split(sel_read.message,"\n")
local exp=max(#txt-5,0)*4
local y0=34-exp
local y1=76+exp
rectfill(23,y0,103,y1,sel_read.bg)
line(24,y0-1,102,y0-1,sel_read.bg)
line(24,y1+1,102,y1+1,sel_read.bg)
for i=1,tbl_len(txt) do
print(txt[i],64-str_width(txt[i])*0.5,29-exp+max(5-#txt,0)*4+i*8,sel_read.fg)
end
s_print("continue ❎",42,85+exp)
end,

-- game over state
game_over=function()
draw.game()
draw.monochrome()
if(tomes==max_tomes) then
local s=split"you won!,congratulations!"
for i=1,#s do
local l=s[i]
for j=1,#l do s_print(sub(l,j,j),64-#l*3+(j-1)*6,i*12+32+j*1.5+wavy(j,3),true,true,10,13)
end
end
else
wavy_print("g a m e   o v e r",26,55,8,1)
if(frame==0)s_print("restart ❎",44,85)
end
end,
}



-- input
input={
-- title state
title=function()
if btnp(5) then 
if title_idle then draw.play_fade(toggle_bool,"title_idle")
else draw.play_fade(change_state,state_game) end
end
end,

-- game state
game=function()
local valid=false
local x,y=player.x,player.y
if btn(0) then valid=player:action_dir(x-1,y)
elseif btn(1) then valid=player:action_dir(x+1,y)
elseif btn(2) then valid=player:action_dir(x,y-1)
elseif btn(3) then valid=player:action_dir(x,y+1)
elseif btnp(4) then change_state(state_menu)
elseif btnp(5) then change_state(state_look) end
return valid
end,

-- menu state
menu=function()
if btnp(0) then 
sel_menu.i=1
sel_menu.tab=(sel_menu.tab-1)%2
elseif btnp(1) then
sel_menu.i=1
sel_menu.tab=(sel_menu.tab+1)%2
elseif btnp(2) and sel_menu.i>1 then sel_menu.i-=1
elseif btnp(4) then change_state(state_game)
elseif sel_menu.tab==0 then
if btnp(3) and sel_menu.i<tbl_len(spell_names) then sel_menu.i+=1
elseif btnp(5) and spell_cooldown[sel_menu.i]==0 then 
change_state(state_look)
sel_look.spell=sel_menu.i
set_look()
end
elseif sel_menu.tab==1 then
if btnp(3) and sel_menu.i<tbl_len_nonzero(consumables) then sel_menu.i+=1
elseif btnp(5) and tbl_sum(consumables)>0 then
local n=sel_menu.i
for i=1,tbl_len(consumables) do 
if(consumables[i]>0)n-=1
if(n==0)n=i break
end
msg.add("consumed "..consumable_names[n])
player:take_dmg(-consumable_values[n])
consumables[n]-=1
change_state(state_game)
end
end
end,

-- look state
look=function()
if btnp(0) and sel_look.x-cam_x>0 then sel_look.x-=1
elseif btnp(1) and sel_look.x-cam_x<15 then sel_look.x+=1
elseif btnp(2) and sel_look.y-cam_y>0 then sel_look.y-=1
elseif btnp(3) and sel_look.y-cam_y<13 then sel_look.y+=1
elseif btnp(4) then 
change_state(state_game)
return false
elseif btnp(5) and sel_look.spell==0 and sel_look.usable then
sel_look.entity:interact()
if(sel_look.key>0)keys[sel_look.key]-=1
return false
elseif btnp(5) and sel_look.spell>0 and sel_look.usable then
change_state(state_game)
cast_spell(sel_look.spell,sel_look.entity)
do_turn()
spell_cooldown[sel_look.spell]=sel_look.spell==1 and timer_spell_charm or timer_spell
return false
end
return true
end,

-- dialogue state
dialogue=function()
if btnp(5) then
local n=min(sel_dialogue.pos+2,#sel_dialogue.text)
if sel_dialogue.anim_frame[n]>0 then for i=sel_dialogue.pos,n do sel_dialogue.anim_frame[i]=0 end
elseif sel_dialogue.pos+2<#sel_dialogue.text then sel_dialogue.pos+=3
else change_state(state_game) end
end
end,

-- chest state
chest=function()
if btnp(5) then
sel_chest.entity.anim_frame=0
if chest.anim_playing then for i=1,tbl_len(sel_chest.anim_frame) do sel_chest.anim_frame[i]=1 end
elseif tomes==max_tomes then change_state(state_game_over) flash_frame=2
else change_state(state_game) end
end
end,

-- read state
read=function()
if(btnp(5))change_state(state_game)
end,

-- game over state
game_over=function()
if(btnp(5) and tomes~=max_tomes)reset()
end,
}



-- message
-------------------------------------------------------------------------------
msg={
width=94,
queue={},
txt="welcome to game",
turn=0,
frame=0,
delay=0,

-- add message
add=function(s)
if msg.turn<turn then 
msg.queue={}
msg.turn=turn
msg.txt_set(s)
else
add(msg.queue,s)
end
end,

-- set the active message
txt_set=function(s)
msg.txt=s
msg.frame=0
msg.delay=8
end,

-- animate the active massage
anim_step=function()
if msg.frame>=msg.width then msg.frame=msg.width if #msg.queue>0 then msg.delay-=1 if msg.delay<=0 then msg.txt_set(deli(msg.queue,1)) end end else msg.frame+=3 end 
end,
}



-- system
-------------------------------------------------------------------------------

-- reset cart
function reset() 
change_state(state_reset)
for i=0x0,0x7fff,rnd(0xf) do poke(i,rnd(0xf)) end
end

-- change state
function change_state(new_state,sel)
state=new_state
if(init[state])init[state](sel)
end

-- transform position to screen position
function pos_to_screen(pos)
return {x=8*(pos.x-cam_x),y=8*(pos.y-cam_y)}
end

-- change palette (if not locked)
function pal_set(param,lock)
if(not pal_lock) then
pal_lock=lock or false
pal(param)
end
end

-- change all colors (except black)
function pal_all(c,lock)
pal_set({0,c,c,c,c,c,c,c,c,c,c,c,c,c,c},lock or false)
end

-- unlock and reset palette
function pal_unlock()
pal_lock=false
pal()
end



-- game state
-------------------------------------------------------------------------------

-- iterate through all map tiles and find entities
function populate_map()
for x=0,127 do for y=0,67 do
if(fget(mget(x,y),flag_entity))entity.entity_spawn(mget(x,y),x,y)
if(mget(x,y)==0)mset(x,y,1)
end end
end

-- check for collision
function collision(x,y)
if(x<0 or x==103 or x==128 or y<0 or y==64 or fget(mget(x,y),flag_collision))return true
for e in all(entity.entities) do if(e.collision and e.x==x and e.y==y)return true end
return false
end

-- check if neighbour tile is in reach
function in_reach(a,b)
return dist(a,b)<=1 and ((a.x==b.x or a.y==b.y) or (not collision(a.x,b.y)) or (not collision(b.x,a.y)))
end

-- perform turn
function do_turn()
for i=1,tbl_len(spell_names) do spell_cooldown[i]=max(0,spell_cooldown[i]-1) end
for e in all(entity.entities) do e:do_turn() end
turn+=1
end

-- update camera position
function update_camera()
local x,y=cam_x,cam_y
local p_x,p_y=player.x,player.y
if (p_x-cam_x>15-cam_offset and (room or cam_x<87)) x=p_x-15+cam_offset
if (p_x-cam_x<cam_offset and cam_x>cam_x_min) x=p_x-cam_offset
if (p_y-cam_y>13-cam_offset and cam_y<50) y=p_y-13+cam_offset
if (p_y-cam_y<cam_offset and cam_y>cam_y_min) y=p_y-cam_offset
if (room==nil and cam_x<cam_x_min)x=cam_x_min
if (room==nil and cam_y<cam_y_min)y=cam_y_min
if (x~=cam_x or y ~= cam_y) then
if (player.anim_frame>0) then camera((x-cam_x)*8+player.anim_x,(y-cam_y)*8+player.anim_y)
else cam_x,cam_y=x,y end
end
end

-- change room
function change_room(stair)
local target_stair=data_floors.stairs[stair[4]]
local new_room=data_floors.rooms[target_stair[3]]
local delta_z=((new_room and new_room[1]) or 0) - ((room and room[1]) or 0)
cam_x_min,cam_y_min=(new_room and target_stair[1]-player.x) or 0,(new_room and target_stair[2]-player.y) or 0
cam_x_diff,cam_y_diff=target_stair[1]-stair[1],target_stair[2]-stair[2]
player.x,player.y=target_stair[1],target_stair[2]
cam_x,cam_y=cam_x+target_stair[1]-stair[1],cam_y+target_stair[2]-stair[2]
msg.add("went "..(delta_z>0 and "up" or "down").." stairs")
room=new_room
end

-- cast spell
function cast_spell(i,e)
msg.add("casted "..spell_names[i])
status=statuses[i]
e:add_status(status)
if(status==status_charmed and #player.followers>max_followers)for e in all(player.followers) do e:clear_status(status_charmed) break end
end

-- check if map coordinate is in sight or blocked
function in_sight(a,b)
local dx,dy=b.x-a.x,b.y-a.y
local step=abs(dx)>=abs(dy) and abs(dx) or abs(dy)
dx=dx/step
dy=dy/step
local x,y,prev_x,prev_y=a.x,a.y,a.x,a.y
local blocked,prev_blocked = false,false
for i=1,step+1 do
blocked = (fget(mget(x,prev_y),flag_block_view) and fget(mget(prev_x,y),flag_block_view)) or fget(mget(x,y),flag_block_view) or prev_blocked
if(blocked)return false
prev_blocked = blocked
prev_x,prev_y=x,y
x,y=a.x+flr(dx*i+0.5),a.y+flr(dy*i+0.5)
i+=1
end
return true
end

-- add item to inventory
function add_to_inventory(itm)
local t=itm.type
local v=itm.value
if(t==1)tomes+=1 return "tome"
if(t==2)keys[v]+=1 return key_names[v]
if(t==3)consumables[v]+=1 return consumable_names[v]
end



-- look state
-------------------------------------------------------------------------------

-- change look target
function set_look()
tbl_merge(sel_look,{name="none",usable=false,text="interact",color=5,key=0})
sel_look.entity=nil
local e=entity.entity_at(sel_look.x,sel_look.y)
if(e and sel_look.spell>0)e=e.class==enemy.class and not e.dead and not e:check_status(status_charmed) and e or nil
if(e) then
e:look_at(sel_look)
if(sel_look.spell>0)sel_look.usable=in_sight(player,sel_look)
end
if(sel_look.spell>0)sel_look.text="cast"
end

-- object
-------------------------------------------------------------------------------
object={
-- static vars
class="object",
parent_class=nil,

-- metatable setup
inherit=function(self,tbl)
return setmetatable(tbl or {},{__index=self})
end,

}



-- drawable
-------------------------------------------------------------------------------
drawable=object:inherit({
-- static vars
class="drawable",
parent_class=object.class,

-- vars
sprite=0,
flipped=false,
flash_frame=0,

vec2_spr=function(self,pos,sprite)
local sprite=sprite or self.sprite
self:spr(pos.x,pos.y,sprite)
end,

-- draw at given screen position
spr=function(self,x,y,sprite)
local sprite=sprite or self.sprite
if self.flash_frame>0 then
self.flash_frame-=1
pal_all(7)
end
palt(0,false)
palt(15,true)
spr(sprite,x,y,1,1,self.flipped)
pal_set()
end,
})



-- entity
-------------------------------------------------------------------------------
entity=drawable:inherit({
-- static vars
class="entity",
parent_class=drawable.class,
entities={},
num=0,

-- vars
x=0,
y=0,
name=nil,
collision=true,
interactable=true,
interact_text="interact",
turn=0,

-- (static) get entity at coordinate
entity_at=function(x,y)
for e in all(entity.entities) do if (e.class==item.class and e.x==x and e.y==y) return e end
for e in all(entity.entities) do if (e.class==enemy.class and e.x==x and e.y==y and not e:check_status(status_charmed) and not e.dead) return e end
for e in all(entity.entities) do if (e.x==x and e.y==y) return e end
return nil
end,

-- (static) spawn entity on map
entity_spawn=function(sprite,x,y)
mset(x,y,1)
local tbl={x=x,y=y,sprite=sprite}
local e_data=data_entities[sprite]
if e_data then
if e_data.class==player.class then
tbl_merge(player,tbl)
local companion_sprite=(rnd()>0.5 and 17) or 18
tbl_merge(companion,tbl_merge_new({x=x,y=y,sprite=companion_sprite},data_entities[companion_sprite]))
else
tbl_merge(tbl,e_data)
_ENV[tbl.class]:new(tbl)
end
end
end,

-- constructor
new=function(self,tbl)
local tbl=self:inherit(tbl)
entity.num=entity.num+1
tbl["id"]=entity.num
tbl["prev_x"],tbl["prev_y"]=tbl.x,tbl.y
add(entity.entities,tbl)
return tbl
end,

-- destructor
destroy=function(self)
del(entity.entities,self)
end,

-- update entity
update=function(self) end,

-- draw entity at world position (if in frame)
draw=function(self,offset,pos,sprite)
if self:in_frame(offset) then
self:vec2_spr(vec2_add((pos or pos_to_screen(self)),vec2_scale(offset or {x=0,y=0},8)),sprite)
return true
end
return false
end,

-- get name or class name of this entity
get_name=function(self)
return(self.name and self.name) or (self.item_class and self.item_class) or self.class
end,

-- look at entity
look_at=function(self,tbl)
tbl_merge(tbl,{entity=self,name=self:get_name(),color=6,text=self.interact_text,usable=self.interactable and in_reach(player,self)})
end,

-- interact with entity
interact=function(self) end,

-- perform turn actions
do_turn=function(self) end,

-- check if entity is on screen
in_frame=function(self,offset)
local pos=vec2_add(self,offset or {x=0,y=0})
return (pos.x>=cam_x-1 and pos.x<cam_x+17 and pos.y>=cam_y-1 and pos.y<cam_y+15)
end,

})



-- creature
-------------------------------------------------------------------------------
creature=entity:inherit({
-- static vars
class="creature",
parent_class=entity.class,
anims={move=split"4,8",attack=split"5,6"},
anim_queue={},
anim_playing=false,

-- vars
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
followed=false,

-- stats
max_hp=10,
ap=2,

-- constructor
new=function(self,tbl)
local tbl=entity.new(self,tbl)
tbl["hp"]=tbl.max_hp
return tbl
end,

-- update creature
update=function(self)
if self.anim_frame>0 then
for e in all(creature.anim_queue) do
if(e==self)self:anim_step()
if(e.anim==creature.anims.attack)break
end
elseif(prev_frame~=frame and self.blink_delay>0) then self.blink_delay-=1 end
end,

-- draw creature
draw=function(self,offset)
if self:in_frame(offset) then
local sprite=self.sprite+frame*16
local x,y=self:screen_pos().x,self:screen_pos().y
if self.anim_frame<=0 then
if self.dead then sprite=frame==1 and turn-self.dhp_turn<=1 and self.blink_delay<=0 and not creature.anim_playing and 0 or 3
elseif self.attacked and frame==1 and self.blink_delay<=0 and not creature.anim_playing then
sprite=0
if(state==state_game)print(abs(self.dhp),x+4-str_width(abs(self.dhp))*0.5,y+1,self.dhp<0 and 8 or 11)
end
end
entity.draw(self,offset,self:screen_pos(),sprite)
if(sprite~=0 and sprite~=3) then
local pos={x=x,y=y}
if(self:check_status(status_charmed))vec2_spr(15,pos) pos.x+=6
if(self:check_status(status_sleeping))vec2_spr(47,pos) pos.x+=4
if(self:check_status(status_scared))vec2_spr(31,pos) pos.x+=3
if(self:check_status(status_poisoned))vec2_spr(63,pos) pos.x+=4
end
return true
end
return false
end,

-- position on screen (position and animation position summed)
screen_pos=function(self)
return vec2_add(pos_to_screen(self),{x=self.anim_x,y=self.anim_y})
end,

-- look at creature
look_at=function(self,tbl)
if not self.dead then
entity.look_at(self,tbl)
tbl.color=self.class==enemy.class and not self:check_status(status_charmed) and 2 or 3
return true
end
return false
end,

-- perform turn actions
do_turn=function(self)
if(turn>self.dhp_turn)self.attacked=false
if(self.dead and turn-self.dhp_turn>timer_corpse)self:destroy()
if(self.target and (self.target.dead or turn>self.target_turn+timer_target or self.target:check_status(status_charmed)))self.target=nil
-- poisoned status
if self:check_status(status_poisoned) then
if(self==player)msg.add(self:get_name().." took poison damage")
self:take_dmg(flr(2*(0.5+rnd())+0.5))
end
for i=2,4 do
local status=statuses[i]
if(self:check_status(status)) then
if(self.status_timer[status]<=0)self:clear_status(status)
self.status_timer[status]-=1
end
end
self.turn=turn
self.followed=false
return not self.dead and self:in_frame() and not self:check_status(status_sleeping)
end,

-- start playing animation
play_anim=function(self,a,x,y,x1,y1)
tbl_merge(self,{anim=a,anim_frame=a[1],anim_x=x*a[2],anim_y=y*a[2],anim_x1=(x1 or 0)*a[2],anim_y1=(y1 or 0)*a[2]})
add(creature.anim_queue,self)
creature.anim_playing=true
end,

-- perform animation step
anim_step=function(self)
local anim_pos=smoothstep(self.anim_frame/self.anim[1])
local x,y=self.anim_x,self.anim_y
if self.anim==creature.anims.attack then
x,y=self.anim_x1,self.anim_y1
if self.target then
if(self.anim_frame==self.anim[1] and self.target==player)flash_frame=2
if(self.anim_frame==self.anim[1]-3)self.target.flash_frame=2
end
end
self.anim_x=self.anim[2]*anim_pos*((x<-0.1 and -1) or (x>0.1 and 1) or 0)
self.anim_y=self.anim[2]*anim_pos*((y<-0.1 and -1) or (y>0.1 and 1) or 0)
self.anim_frame-=1
if self.anim_frame<=0 then
del(creature.anim_queue,self)
if(#creature.anim_queue==0)creature.anim_playing=false
self.anim_x,self.anim_y=0
end
end,

-- try to move the creature to a given map coordinate
move=function(self,x,y)
if not collision(x,y) and x>=0 and x<128 and y>=0 and y<64 and (x~=0 or y~=0) then
if(self.x~=x)self.flipped=self.x>x
self:play_anim(creature.anims.move,self.x-x,self.y-y)
tbl_merge(self,{prev_x=self.x,prev_y=self.y,x=x,y=y})
return true
end
return false
end,

-- follow another entity
follow=function(self,other)
if in_reach(self,{x=other.prev_x,y=other.prev_y}) then self:move(other.prev_x,other.prev_y)
else self:move_towards(other) end
other.followed=true
end,

-- move towards another creature and attack when close
move_towards_and_attack=function(self,other)
if in_reach(self,other) then self:attack(other)
else self:move_towards(other) end
end,

-- try to move an towards another entity
move_towards=function(self,other,reverse)
local diff_x,diff_y=reverse and self.x-other.x or other.x-self.x,reverse and self.y-other.y or other.y-self.y
local desire_x, desire_y=(diff_x>0 and 1) or (diff_x<0 and -1) or 0,(diff_y>0 and 1) or (diff_y<0 and -1) or 0
return abs(diff_x)<abs(diff_y) and self:move(self.x,self.y+desire_y) or (self:move(self.x+desire_x,self.y) or self:move(self.x,self.y+desire_y))
end,

-- perform attack
attack=function(self,other)
msg.add(self:get_name().." attacked "..other:get_name())
if other:take_dmg(flr(self.ap*(0.5+rnd())+0.5)) then
msg.add(self:get_name().." killed "..other:get_name())
else 
other.target=self
self.target=other
self.target_turn,other.target_turn=turn,turn
end
self:play_anim(creature.anims.attack,0,0,other.x-self.x,other.y-self.y)
end,

add_status=function(self,status)
self.status_timer[status]=(status==status_poisoned and timer_effect_poisoned) or (status==status_sleeping and timer_effect_sleeping) or timer_effect
if(status==status_scared)self:clear_status(status_charmed | status_sleeping)
if(status==status_charmed or status==status_sleeping)self:clear_status(status_scared)
if(status==status_charmed)self.collision=false self.interactable=false add(player.followers,self)
self.status=self.status | status
end,

clear_status=function(self,status)
self.status=self.status & ~status
if(status==status_charmed)self.collision=true self.interactable=true del(player.followers,self)
end,

check_status=function(self,status)
return self.status & status==status
end,

-- take damage
take_dmg=function(self,dmg)
self:clear_status(status_sleeping)
if(dmg<0)self:clear_status(status_poisoned)
self.blink_delay=(frame==0 and 2) or 1
self.attacked=true
self.dhp=(self.dhp_turn==turn and self.dhp-dmg) or dmg*-1
self.dhp_turn=turn
self.hp=min(max(self.hp-dmg,0),self.max_hp)
if self.hp<=0 then
self:kill()
return true
end
return false
end,

-- kill creature
kill=function(self)
self.dead=true
self.collision=false
del(player.followers,self)
if(self==player)change_state(state_game_over)
end,
})



-- player
-------------------------------------------------------------------------------
player=creature:new({
-- static vars
class="player",
parent_class=creature.class,
interactable=false,
collision=false,
name="you",

-- vars
max_hp=20,
followers={},

-- look at player
look_at=function(self,tbl)
end,

-- move the player or attack if there is an enemy in the target tile
action_dir=function(self,x,y)
local valid=self:move(x,y)
for e in all(entity.entities) do
if e.x==x and e.y==y then
if e.class==enemy.class and not(e:check_status(status_charmed)) and not e.dead then
self:attack(e)
valid=true
elseif e.class==stairs.class then
e:trigger()
valid=true
end
end
end
return valid
end,
})



-- companion
-------------------------------------------------------------------------------
companion=creature:new({
-- static vars
class="companion",
parent_class=creature.class,
interact_text="pet",
collision=false,

-- vars
ap=1,

-- interact action
interact=function(self)
msg.add("you petted the "..self:get_name())
change_state(state_game)
end,

-- perform turn actions
do_turn=function(self)
if creature.do_turn(self) then
if player.target then
self:move_towards_and_attack(player.target)
else
local target=self==companion and player or companion
for e in all(player.followers) do if(e~=self and e.turn==turn and not e.followed)target=e break end
self:follow(target)
end
elseif not self:in_frame() then
self.x,self.y=player.prev_x,player.prev_y
end
end,
})



-- npc
-------------------------------------------------------------------------------
npc=creature:inherit({
-- static vars
class="npc",
parent_class=creature.class,
interact_text="talk",

-- interact action
interact=function(self)
local sel={entity=self,text=split(data_dialogue[self.sprite],"\n"),anim_frame={},pos=1}
for l in all(sel.text) do add(sel.anim_frame,timer_dialog_line+#l*4) end
change_state(state_dialogue,sel)
end,
})



-- enemy
-------------------------------------------------------------------------------
enemy = creature:inherit({
-- static vars
class="enemy",
parent_class=creature.class,
interactable=true,

-- vars
ap=1,
max_hp=5,
seen_player=0,

-- look at enemy
look_at=function(self,tbl)
if(creature.look_at(self,tbl) and not self:check_status(status_charmed))tbl.text="attack"
end,

-- attack enemy
interact=function(self)
change_state(state_game)
player:attack(self)
do_turn()
end,

-- perform turn actions
do_turn=function(self)
if self.status & status_charmed==status_charmed then companion.do_turn(self)
elseif creature.do_turn(self) then
if(in_sight(self,player))self.seen_player=turn
if (self.seen_player+timer_seen_player>turn) then
if self.status & status_scared==status_scared then self:move_towards(player,true)
else self:move_towards_and_attack(player) end
end
end
end,
})



-- door
-------------------------------------------------------------------------------
door=entity:inherit({
-- static vars
class="door",
parent_class=entity.class,

-- vars
lock=0,

-- constructor
new=function(self,tbl)
local tbl=entity.new(self,tbl)
if(tbl.collision)mset(tbl.x,tbl.y,2)
return tbl
end,

-- look at door
look_at=function(self,tbl)
entity.look_at(self,tbl)
if self.lock==0 then 
tbl.text=self.collision and "open" or "close"
else
tbl.text,tbl.name="unlock","locked "..tbl.name
if tbl.usable then
tbl.key=self.lock
tbl.usable=keys[self.lock]>0 and true or false
end
end
end,

-- interact action
interact=function(self)
self.collision=not self.collision
self.sprite=self.collision and 82 or 81
mset(self.x,self.y,self.collision and 2 or 1)
if self.lock>0 then
self.lock=0
msg.add("unlocked door")
else
msg.add((self.collision and "closed" or "opened").." door")
end
change_state(state_game)
end,
})



-- stairs
-------------------------------------------------------------------------------
stairs=entity:inherit({
-- static vars
class="stairs",
parent_class=entity.class,
interactable=false,
collision=false,

-- trigger action
trigger=function(self)
local stair=nil
for e in all(data_floors.stairs) do if(e[1]==player.x and e[2]==player.y) stair=e break end
draw.play_fade(change_room,stair)
end,
})



-- sign
-------------------------------------------------------------------------------
sign=entity:inherit({
-- static vars
class="sign",
parent_class=entity.class,

--vars
interact_text="read",
message="...",
bg=15,
fg=0,

-- constructor
new=function(self,tbl)
for d in all(data_signs) do if d[1]==tbl.x and d[2]==tbl.y then tbl.message=d[3] break end end
return entity.new(self,tbl)
end,

-- interact action
interact=function(self)
change_state(state_read,self)
end,
})



-- chest
-------------------------------------------------------------------------------
chest=entity:inherit({
-- static vars
class="chest",
parent_class=entity.class,
interact_text="open",
anim_playing=false,

-- vars
anim_frame=0,
anim_this=false,
open=false,
content={},

-- constructor
new=function(self,tbl)
for d in all(data_chests) do
if d.x==tbl.x and d.y==tbl.y then
tbl.content={}
for sprite in all(d.content) do add(tbl.content,tbl_merge_new({sprite=sprite},data_entities[sprite])) end
return entity.new(self,tbl)
end 
end
end,

-- look at chest
look_at=function(self,tbl)
entity.look_at(self,tbl)
tbl.usable=tbl.usable and not self.open
end,

-- interact action
interact = function(self)
self.open=true
self.sprite=12
self.anim_frame=45
self.anim_this=true
chest.anim_playing=true
local sel={entity=self,anim_frame={}}
for itm in all(self.content) do 
add(sel.anim_frame,60)
msg.add("got "..add_to_inventory(itm))
end
change_state(state_chest,sel)
end,

-- perform animation step
anim_step=function(self)
if(self.anim_frame>0)self.anim_frame-=1
end,

-- get content item animation position
item_anim_pos=function(self, anim_pos, target)
return {x=lerp(anim_pos+sin(anim_pos*-0.5)*0.75,pos_to_screen(self).x,target.x),y=lerp(anim_pos+cos(anim_pos*0.9+0.1)*0.3-0.3,pos_to_screen(self).y,target.y)} 
end,

-- draw chest
draw=function(self,offset)
if entity.draw(self,offset) and (self.anim_this) then
local x,y=pos_to_screen(self).x,pos_to_screen(self).y
if(blink)rectfill(x+1,y+2,x+5,y+3,7)
if(self.anim_frame>=30 or (self.anim_frame>10 and blink)) then
y-=(45-self.anim_frame)*0.25
clip(x,y,8,5)
self:spr(x,y,11)
clip()
end
end
end,

})



-- item (in world)
-------------------------------------------------------------------------------
item = entity:inherit({
-- static vars
class="item",
parent_class=entity.class,
collision=false,
interact_text="pick up",

-- interact action
interact=function(self)
msg.add("picked up "..add_to_inventory(self))
self:destroy()
change_state(state_game)
end,

})