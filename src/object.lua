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
  if self.flash_frame>0 and flash_frame<=0 then
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
  if(room and (pos.x<=room[2] or pos.x>=room[4] or pos.y<=room[3] or pos.y>=room[5]))return false
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
  if not self.dead then
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
  end
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
   if(self==player)sfx(63,2,0,2)
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
  sfx(60,3,0,10)
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
  if(dmg>0)self.flash_frame=2
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
    if player.target and not player.target.dead then
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
  sfx(63,3,24,5)
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
  sfx(63,3,8,10)
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
  sfx(4,3)
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
   if(self.anim_frame>=30 or (self.anim_frame>2 and blink)) then
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
  sfx(62,3,0,8)
 end,

})