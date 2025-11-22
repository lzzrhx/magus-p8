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
tbl_merge(tbl,{entity=self,name=self:get_name(),color=6,text=self.interact_text,usable=self.interactable and dist(player,self)<=1})
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
if(self==player or self==companion)player.xp+=other.xp
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
if(creature.look_at(self,tbl))tbl.text="attack"
end,
interact=function(self)
change_state(state_game)
player:attack(self)
do_turn()
end,
do_turn=function(self)
if(creature.do_turn(self))if self.status&status_charmed==status_charmed do companion.do_turn(self)elseif self.status&status_scared==status_scared do self:move_towards(player,true)else self:move_towards_and_attack(player)end
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
if(self.status)player:add_status(self.status)
if(self.dhp)player:take_dmg(-self.dhp)
end
})