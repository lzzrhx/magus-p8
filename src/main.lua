-- globals
-------------------------------------------------------------------------------

-- constants
timer_corpse=20 -- timeout for grave (turns)
timer_target=24 -- timeout for target (turns)
timer_dialog_line=24 -- timeout for next line in dialogue (frames)
timer_effect=16 -- effect timer for most status effects (turns)
timer_effect_poison=6 -- effect timer for poison (turns)
timer_spell=24 -- cooldown for casting spells (turns)
timer_spell_charm=0 -- cooldown for casting befriend spell (turns)
max_followers=5

-- game states
state_reset="reset"
state_title="title"
state_game="game"
state_menu="menu"
state_look="look"
state_dialogue="dialogue"
state_chest="chest"
state_read="read"
state_dead="dead"

-- status effects
status_charmed=0b0001
status_scared=0b0010
status_sleeping=0b0100
status_poisoned=0b1000
statuses=split"0b0001,0b0010,0b0100,0b1000"

-- sprite flags
flag_collision=0
flag_entity=1

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
spells=split"befriend,scare,sleep,poison"
spells_cd=split"0,0,0,0"



-- built-in functions
-------------------------------------------------------------------------------

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
  frame=flr(t()*2%2)
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
-------------------------------------------------------------------------------
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
-------------------------------------------------------------------------------
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

 -- dead state
 dead=function()
  for e in all(entity.entities) do e:update() end
  input.dead()
 end,
}



-- draw
-------------------------------------------------------------------------------
draw={
 -- start playing fade
 play_fade=function(func,param)
  fade_frame=5
  fade_action=func and {func=func,param=param} or nil
 end,

 -- perform fade animation step
 fade_step=function()
  if fade_frame>0 then
   if fade_frame==3 do rectfill(0,0,128,128,0)
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
   local x=cos(t()/8+i/title_effect_num)*56
   local y=sin(t()/8+i/title_effect_num)*16+sin(t()+i*(1/title_effect_num)*5)*4
   local c=title_effect_colors[i%#title_effect_colors+1]
   for j=1,3 do pset(62+x+j,50+y+j,c) end
  end
  -- main title
  s_print("\014magus magicus",13,45,true,true,7,4)
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
  if(state==state_game or state==state_dead)msg.anim_step()
 end,

 -- menu state
 menu=function()
  -- draw map and entities
  draw.game()
  draw.monochrome()
  -- bg box
  line(30,22,96,22,6)
  line(30,88,96,88,6)
  line(29,23,29,87,6)
  line(97,23,97,87,6)
  rectfill(30,22,96,28,6)
  -- button legend
  local btns="cancel 🅾️  use ❎"
  print(btns,29,97,5)
  clip(24,0,(sel_menu.tab==0 and spells_cd[sel_menu.i]==0 and 80) or (sel_menu.tab==1 and inventory.num>0 and inventory.items[sel_menu.i].interactable and 80) or 40,128)
  print(btns,29,96,6)
  clip()
  -- magic tab
  if sel_menu.tab==0 then
   print("⬅️ magick ➡️",40,23,0)
   print("▶",33,25+sel_menu.i*7,6)
   for i=1,tbl_len(spells) do print((spells_cd[i]>0 and "("..spells_cd[i]..") " or (i==1 and #player.followers>=max_followers and "(max) " or ""))..spells[i],38,25+i*7,sel_menu.i==i and 6 or 5) end
  -- inventory tab
  elseif sel_menu.tab==1 then
   print("⬅️ inventory ➡️",34,23,0)
   if inventory.num==0 do
    print("empty",35,32,5)
   else
    print("▶",33,25+sel_menu.i*7,6)
    for i=1,inventory.num do print(inventory.items[i].name,38,25+i*7,sel_menu.i==i and 6 or 5) end
   end
  -- character tab
  elseif sel_menu.tab==2 then
   print("⬅️ character ➡️",34,23,0)
   print("hp: "..player.hp.."/"..player.max_hp.."\nxp: "..player.xp,35,32,6)
  end
 end,

 -- look state
 look=function()
  -- draw map, entities and selection
  draw.game()
  if(state==state_look)draw.monochrome()
  player:draw()
  if(sel_look.entity)sel_look.entity:draw()
  if(state==state_look)vec2_spr(2,pos_to_screen(sel_look))
  -- ui elements
  draw.window_frame()
  local btn_x=sel_look.text.." ❎"
  s_print(sel_look.spell==0 and "target:" or "cast "..spells[sel_look.spell].." on:",2,113,state==state_look)
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
     elseif not chest.anim_playing or blink then itm:spr(target_pos.x,target_pos.y+wavy()) end
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

 -- dead state
 dead=function()
  draw.game()
  draw.monochrome()
  wavy_print("g a m e   o v e r",26,61,8,1)
  if(frame==0)s_print("restart ❎",44,85)
 end,
}



-- input
-------------------------------------------------------------------------------
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
   sel_menu.tab=(sel_menu.tab-1)%3
  elseif btnp(1) then
   sel_menu.i=1
   sel_menu.tab=(sel_menu.tab+1)%3
  elseif btnp(2) and sel_menu.i>1 then sel_menu.i-=1
  elseif btnp(4) then change_state(state_game)
  elseif sel_menu.tab==0 then
   if btnp(3) and sel_menu.i<tbl_len(spells) then sel_menu.i+=1
   elseif btnp(5) and spells_cd[sel_menu.i]==0 then 
    change_state(state_look)
    sel_look.spell=sel_menu.i
    set_look()
   end
  elseif sel_menu.tab==1 then
   if btnp(3) and sel_menu.i<inventory.num then sel_menu.i+=1
   elseif btnp(5) and inventory.num>0 and inventory.items[sel_menu.i].interactable then
    inventory.items[sel_menu.i]:interact()
    inventory.remove(inventory.items[sel_menu.i])
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
   inventory.remove(sel_look.possession)
   return false
  elseif btnp(5) and sel_look.spell>0 and sel_look.usable then
   change_state(state_game)
   cast_spell(sel_look.spell,sel_look.entity)
   do_turn()
   spells_cd[sel_look.spell]=sel_look.spell==1 and timer_spell_charm or timer_spell
   return false
  end
  return true
 end,

 -- dialogue state
 dialogue=function()
  if btnp(5) then
   if sel_dialogue.pos+2<#sel_dialogue.text then sel_dialogue.pos+=3
   else change_state(state_game) end
  end
 end,

 -- chest state
 chest=function()
  if btnp(5) then
   sel_chest.entity.anim_frame=0
   if chest.anim_playing then for i=1,tbl_len(sel_chest.anim_frame) do sel_chest.anim_frame[i]=1 end
   else change_state(state_game) end
  end
 end,

 -- read state
 read=function()
  if(btnp(5))change_state(state_game)
 end,

 -- dead state
 dead=function()
  if(btnp(5))reset()
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



-- inventory
-------------------------------------------------------------------------------
inventory={
 items={},
 num=0,

 -- convert item (from world) to possession and add to inventory
 add_item=function(e)
  inventory.add_possession(possession.new_from_entity(e))
 end,

 -- add possession to inventory
 add_possession=function(itm)
  add(inventory.items,itm)
  inventory.num+=1
 end,

 -- remove possession from inventory
 remove=function(itm)
  if itm then
   del(inventory.items,itm)
   inventory.num-=1
  end
 end
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
 for i=1,tbl_len(spells) do spells_cd[i]=max(0,spells_cd[i]-1) end
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
function change_room(new_room)
 room=new_room
end

-- cast spell
function cast_spell(i,e)
 msg.add("casted "..spells[i])
 status=statuses[i]
 e:add_status(status)
 if(status==status_charmed and #player.followers>max_followers)for e in all(player.followers) do e:clear_status(status_charmed) break end
end



-- look state
-------------------------------------------------------------------------------

-- change look target
function set_look()
 tbl_merge(sel_look,{name="none",usable=false,text="interact",color=5,possession=nil})
 sel_look.entity=nil
 local e=entity.entity_at(sel_look.x,sel_look.y)
 if(e and sel_look.spell>0)e=e.class==enemy.class and not e.dead and not e:check_status(status_charmed) and e or nil
 if(e) then
  e:look_at(sel_look)
  if(sel_look.spell>0)sel_look.usable=true
 end
 if(sel_look.spell>0)sel_look.text="cast"
end