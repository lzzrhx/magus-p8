-- globals
-------------------------------------------------------------------------------

-- constants
timer_corpse=20 -- timeout for grave (turns)
timer_target=3 -- timeout for target (turns)
timer_dialog_line=24 -- timeout for next line in dialogue (frames)
width=103 -- area width
height=64 -- area height

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

-- sprites
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

-- status effects
status_poisoned=0b0001
status_sleeping=0b0010
status_charmed=0b0100
status_scared=0b1000

-- sprite flags
flag_collision=0
flag_entity=1
--flag_unused_two=2
--flag_unused_three=3
--flag_unused_four=4
--flag_unused_five=5
--flag_unused_six=6
--flag_unused_seven=7

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
fade_chars={"░","▒"}
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
title_effect_colors={8,9,10,11,12,13,14,15}
title_text=split(data_story_intro,"\n")

spells={"beguile","terrify","sleep","teleport",}

-- options
option_disable_flash=false



-- built-in functions
-------------------------------------------------------------------------------

-- init
function _init()
  change_state(state_title)
  populate_map()
end

-- update
function _update()
  if(state==state_reset)then
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
  if(state~=state_reset)then
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
    sel_look={x=player.x,y=player.y}
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
    fade_action=(func and {func=func,param=param}) or nil
  end,

  -- perform fade animation step
  fade_step=function()
    if(fade_frame>0)then
      if (fade_frame==3) do rectfill(0,0,128,128,0)
      else for j=1,16 do for k=1,16 do print("\014"..fade_chars[(fade_frame>#fade_chars) and (6-fade_frame) or fade_frame],(j-1)*8,(k-1)*8,0) end end end
      fade_frame-=1
      if(fade_frame==3 and fade_action)fade_action.func(fade_action.param)
    end
  end,

  -- perform screen flash animation step
  flash_step=function()
    if(not option_disable_flash and flash_frame>0)then
      cls((state==state_game and player.hp<5 and flash_frame==1 and 8) or 7)
      flash_frame-=1
    end
  end,

  -- monochrome mode
  monochrome=function(c)
    c=c or 1
    -- screen memory as the sprite sheet
    poke(0x5f54,0x60)
    pal_all(c)
    sspr(0,0,128,128,0,0)
    pal_set()
    -- reset spritesheet
    poke(0x5f54,0x00)
  end,

  -- window frame
  window_frame=function(ui_h)
    ui_h=ui_h or 2
    if (ui_h>0) then
      rectfill(0,125-ui_h*7,127,127,1)
      line(0,125-ui_h*7,127,125-ui_h*7,6)
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
      x=cos(t()/8+i/title_effect_num)*56
      y=sin(t()/8+i/title_effect_num)*16+sin(t()+i*(1/title_effect_num)*5)*4
      c=title_effect_colors[i%(#title_effect_colors)+1]
      for j=1,3 do pset(62+x+j,50+y+j,c) end
    end
    -- main title
    s_print("\014magus magicus",13,45,7,4)
    print("ˇˇˇˇˇˇˇˇˇˇˇˇ",19,54,6)
    -- intro text
    if (not title_idle) then
      for k,v in pairs(title_text) do
        print(v,64-(str_width(v))*0.5,86+(k-1)*8,5)
        print(v,64-(str_width(v))*0.5,85+(k-1)*8,6)
      end
    -- button legend
    elseif (frame==0) then s_print("start game ❎",38,85) end
    camera(0,0)
    -- text fade effect
    for i=0,1 do for j=0,15 do
      x=j*8+rnd_1()
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
    if(room) then
      if (room.z>0) then
        pal_all(1,true)
        map(cam_x-1-cam_x_diff,cam_y-1-cam_y_diff-room.z,-8,-8,18,16)
        for e in all(entity.entities) do e:draw({x=cam_x_diff,y=cam_y_diff+room.z}) end
        pal_unlock()
      end
      x0=max(0,(room.x0-cam_x+1)*8)
      y0=max(0,(room.y0-cam_y+1)*8)
      x1=min(128,(room.x1-cam_x)*8)
      y1=min(128,(room.y1-cam_y)*8)
      rectfill(x0,y0,x1,y1,0)
      map(room.x0,room.y0,8*(room.x0-cam_x),8*(room.y0-cam_y),room.x1-room.x0+1,room.y1-room.y0+1)
      clip(x0,y0,x1-x0,y1-y0)
    else
      map(cam_x-1,cam_y-1,-8,-8,18,16)
    end
    for e in all(entity.entities) do if (not e.collision) e:draw() end
    for e in all(entity.entities) do if (e.collision) e:draw() end
    clip()
    -- vars
    hp_ratio=max(0,player.hp/player.max_hp)
    s_btn_z="menu 🅾️"
    s_btn_x="look ❎"
    camera()
    draw.window_frame()
    -- animated message
    clip(0,0,msg.frame,128)
    if(state==state_game)print(msg.txt,2,114,5)
    print(msg.txt,2,113,6)
    clip(msg.frame,0,(msg.frame>msg.width-3 and msg.width-msg.frame) or 3,128)
    print(msg.txt,2,112,7)
    clip()
    if(state==state_game or state==state_dead)msg.anim_step()
    -- ui elements (shadow)
    if(state==state_game)then
      print("hp:",2,121,5)
      rectfill(14,120,82,124,5)
      print(s_btn_z,98,114,5)
      print(s_btn_x,98,121,5)
    end
    -- ui elements
    print("hp:",2,120,6)
    if(hp_ratio>0)rectfill(14,120,14+68*hp_ratio,124,(hp_ratio<0.25 and 8) or (hp_ratio<0.5 and 9) or (hp_ratio<0.75 and 10) or 11)
    print(s_btn_z,98,113,6)
    print(s_btn_x,98,120,6)
  end,

  -- menu state
  menu=function()
    -- draw map and entities
    draw.game()
    draw.monochrome()
    -- vars
    s_btns="cancel 🅾️  use ❎"
    -- bg box
    y=5
    line(30,22,96,22,6)
    line(30,88,96,88,6)
    line(29,23,29,87,6)
    line(97,23,97,87,6)
    rectfill(30,22,96,28,6)
    -- button legend
    print(s_btns,29,97,5)
    clip(24,0,(sel_menu.tab==0 and 80) or (sel_menu.tab==1 and inventory.num>0 and inventory.items[sel_menu.i].interactable and 80) or 40,128)
    print(s_btns,29,96,6)
    clip()
    -- magic tab
    if (sel_menu.tab==0) then
      print("⬅️ magick ➡️",40,23,0)
      print("▶",33,25+sel_menu.i*7,6)
      for i=1,tbl_len(spells) do print(spells[i],38,25+i*7,sel_menu.i==i and 6 or 5) end
    -- inventory tab
    elseif (sel_menu.tab==1) then
      print("⬅️ inventory ➡️",34,23,0)
      if (inventory.num==0) do
        print("empty",35,32,5)
      else
        print("▶",33,25+sel_menu.i*7,6)
        for i=1,inventory.num do print(inventory.items[i].name,38,25+i*7,sel_menu.i==i and 6 or 5) end
      end
    -- character tab
    elseif (sel_menu.tab==2) then
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
    if(state==state_look)vec2_spr(sprite_selection,pos_to_screen(sel_look))
    draw.window_frame()
    -- vars
    s_btn_z="cancel 🅾️"
    s_btn_x=sel_look.text.." ❎"
    -- ui elements (shadow)
    if(state==state_look)then
      print("target:",2,114,5)
      print(sel_look.name,2,121,(sel_look.entity and sel_look.entity~=player and sel_look.entity.parent_class==creature.class and 0) or 5)
      print(s_btn_z,90,114,5)
      print(s_btn_x,126-str_width(s_btn_x),121,5)
    end
    -- ui elements
    print("target:",2,113,6)
    if(sel_look.entity and sel_look.entity~=player)print(sel_look.name,2,120,sel_look.color)
    print(s_btn_z,90,113,6)
    if(sel_look.usable)print(s_btn_x,126-str_width(s_btn_x),120,6)
  end,

  -- dialogue state
  dialogue=function()
    draw.game()
    draw.monochrome()
    player:draw()
    sel_dialogue.entity:draw()
    draw.window_frame(4)
    -- dialogue message
    s_print(sel_dialogue.entity:get_name()..":",2,99)
    for k,v in pairs(sel_dialogue.text) do
      f=sel_dialogue.anim_frame[k]
      if (k>=sel_dialogue.pos and k<=sel_dialogue.pos+2) then
        y=106+(k-sel_dialogue.pos)*7
        clip(0,0,#v*4+timer_dialog_line-f,128)
        s_print(v,2,y)
        if (f>0 and f~=#v*4+timer_dialog_line) then
          clip(#v*4+timer_dialog_line-f,0,3,128)
          print(v,2,y-1,7)
        end
        if(f>0 and (k==sel_dialogue.pos or sel_dialogue.anim_frame[k-1]<=0))sel_dialogue.anim_frame[k]-=3
      end
    end
    clip()
    -- button legend
    if (sel_dialogue.anim_frame[min(sel_dialogue.pos+2,#sel_dialogue.text)]<=0 and frame==0)s_print("continue ❎",82,99)
  end,

  -- chest state
  chest=function()
    -- vars
    chest_e=sel_chest.entity
    num_itms=tbl_len(chest_e.content)
    -- draw player and chest
    cls()
    player:draw()
    chest_e:draw()
    if (not chest.anim_playing)draw.monochrome()
    -- wait for chest open animation to finish
    if (chest_e.anim_frame<=0) then
      -- iterate through chest items
      for i=1,num_itms do
        f=sel_chest.anim_frame[i]
        target_pos={x=52-num_itms*8+i*16,y=52}
        -- wait for animation of previous item to finish before playing the next
        if (i==1 or sel_chest.anim_frame[i-1]<=0) then
          itm=chest_e.content[i]
          -- play animation for current item
          if (f>0) then
            -- stop chest blinking on last item
            if(i==num_itms)chest_e.anim_this=false
            -- set item color to white
            pal_all(7)
            -- draw animated item with trailing echoes
            for j=0,10 do
              pos=chest_e:item_anim_pos(smoothstep(min(1,(1-(f/60))+0.025*j)),target_pos)
              if(blink)vec2_spr(itm.sprite,pos)
            end
            -- reset palette and decrement animation frame
            pal_set()
            sel_chest.anim_frame[i]-=1
            -- flash the screen and set chest animation to finished after last item animation is done
            if (sel_chest.anim_frame[num_itms]<=0) then 
              chest.anim_playing=false
              flash_frame=2
            end
          -- draw the item bobbing up and down after the popping out of chest animation has finished
          elseif (not chest.anim_playing or blink) then itm:spr(target_pos.x,target_pos.y+wavy()) end
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
    txt=split(sel_read.message,"\n")
    txt_exp=max(#txt-5,0)*4
    y0=34-txt_exp
    y1=76+txt_exp
    rectfill(23,y0,103,y1,sel_read.bg)
    line(24,y0-1,102,y0-1,sel_read.bg)
    line(24,y1+1,102,y1+1,sel_read.bg)
    for i=1,tbl_len(txt) do
      print(txt[i],64-str_width(txt[i])*0.5,29-txt_exp+max(5-#txt,0)*4+i*8,sel_read.fg)
    end
    s_print("continue ❎",42,85+txt_exp)
  end,

  -- dead state
  dead=function()
    draw.game()
    draw.monochrome()
    wavy_print("g a m e   o v e r",26,61,8,1)
    if (frame==0) then s_print("restart ❎",44,85) end
  end,
}



-- input
-------------------------------------------------------------------------------
input={
  -- title state
  title=function()
    if(btnp(5)) then 
      if (title_idle) then draw.play_fade(toggle_bool,"title_idle")
      else draw.play_fade(change_state,state_game) end
    end
  end,

  -- game state
  game=function()
    valid=false
    x,y=player.x,player.y
    if (btn(0)) then valid=player:action_dir(x-1,y)
    elseif (btn(1)) then valid=player:action_dir(x+1,y)
    elseif (btn(2)) then valid=player:action_dir(x,y-1)
    elseif (btn(3)) then valid=player:action_dir(x,y+1)
    elseif (btnp(4)) then change_state(state_menu)
    elseif (btnp(5)) then change_state(state_look) end
    return valid
  end,

  -- menu state
  menu=function()
    if(btnp(0)) then 
      sel_menu.i=1
      sel_menu.tab=(sel_menu.tab-1)%3
    end
    if(btnp(1)) then
      sel_menu.i=1
      sel_menu.tab=(sel_menu.tab+1)%3
    end
    if(btnp(4))change_state(state_game)
    if(btnp(2) and sel_menu.i>1)sel_menu.i-=1
    if (sel_menu.tab==0) then
      if(btnp(3) and sel_menu.i<tbl_len(spells))sel_menu.i+=1
      if(btnp(5)) then
        change_state(state_look)
      end
    end
    if (sel_menu.tab==1) then
      if(btnp(3) and sel_menu.i<inventory.num)sel_menu.i+=1
      if(btnp(5) and inventory.num>0 and inventory.items[sel_menu.i].interactable) then
        itm=inventory.items[sel_menu.i]
        inventory.remove(itm)
        itm:interact()
        change_state(state_game)
      end
    end
  end,

  -- look state
  look=function()
    if(btnp(0)and sel_look.x-cam_x>0)sel_look.x-=1
    if(btnp(1)and sel_look.x-cam_x<15)sel_look.x+=1
    if(btnp(2)and sel_look.y-cam_y>0)sel_look.y-=1
    if(btnp(3)and sel_look.y-cam_y<13)sel_look.y+=1
    if (btnp(4)) then 
      change_state(state_game)
      return false
    end
    if (btnp(5) and sel_look.usable) then
      sel_look.entity:interact()
      inventory.remove(sel_look.possession)
      return false
    end
    return true
  end,

  -- dialogue state
  dialogue=function()
    if (btnp(5)) then
      if (sel_dialogue.pos+2<#sel_dialogue.text) then sel_dialogue.pos+=3
      else change_state(state_game) end
    end
  end,

  -- chest state
  chest=function()
    if (btnp(5)) then
      if(chest.anim_playing) then 
        sel_chest.entity.anim_frame=0
        for i=1,tbl_len(sel_chest.anim_frame) do sel_chest.anim_frame[i]=1 end
      else
        change_state(state_game)
      end
    end
  end,

  -- read state
  read=function()
    if (btnp(5)) change_state(state_game)
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
    if (msg.turn<turn) then 
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
  anim_step=function() if (msg.frame>=msg.width) then msg.frame=msg.width if (#msg.queue>0) then msg.delay-=1 if (msg.delay<=0) then msg.txt_set(deli(msg.queue,1)) end end else msg.frame+=3 end end,
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
    if (itm) then
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

-- quit cart
function quit()
  cls()
  stop()
end

-- change state
function change_state(new_state,sel)
  state=new_state
  if(init[state])init[state](sel)
end



-- game state
-------------------------------------------------------------------------------

-- iterate through all map tiles and find entities
function populate_map()
  for x=0,127 do for y=0,67 do
    if(fget(mget(x,y),flag_entity))entity.entity_spawn(mget(x,y),x,y)
    if(mget(x,y)==sprite_void)mset(x,y,sprite_empty)
  end end
end

-- check for collision
function collision(x,y)
  if(x<0 or x==width or x==128 or y<0 or y==height or fget(mget(x,y),flag_collision))return true
  for e in all(entity.entities) do if (e.collision and e.x==x and e.y==y) return true end
  return false
end

-- check if neighbour tile is in reach
function in_reach(a,b)
  return ((dist(a,b)<=1) and ((a.x==b.x or a.y==b.y) or (not collision(a.x,b.y)) or (not collision(b.x,a.y))))
end

-- perform turn
function do_turn()
  for e in all(entity.entities) do e:do_turn() end
  turn+=1
end

-- update camera position
function update_camera()
  x,y=cam_x,cam_y
  p_x,p_y=player.x,player.y
  if (p_x-cam_x>15-cam_offset and (room or cam_x<width-16)) x=p_x-15+cam_offset
  if (p_x-cam_x<cam_offset and cam_x>cam_x_min) x=p_x-cam_offset
  if (p_y-cam_y>13-cam_offset and cam_y<height-14) y=p_y-13+cam_offset
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



-- look state
-------------------------------------------------------------------------------

-- change look target
function set_look()
  tbl_merge(sel_look,{name="none",usable=false,text="interact",color=5,possession=nil})
  sel_look.entity=nil
  e=entity.entity_at(sel_look.x,sel_look.y)
  if(e)e:look_at(sel_look)
end