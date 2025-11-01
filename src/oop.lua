-------------------------------------------------------------------------------
-- object
-------------------------------------------------------------------------------

object = {

    -- static vars
    class="object",
    parent_class=nil,

    -- metatable setup
    inherit = function(self, table)
        table=table or {}
        setmetatable(table,{
            __index=self
        })
        return table
    end,

}



-------------------------------------------------------------------------------
-- entity
-------------------------------------------------------------------------------

entity = object:inherit({
    
    -- static vars
    class="entity",
    parent_class=object.class,
    entities={},
    num=0,

    -- vars
    name=nil,
    x=0,
    y=0,
    sprite=0,
    collision=true,
    interactable=true,
    interact_dist=1,
    interact_text="interact",

    -- constructor
    new = function(self, table)
        local new_entity = self:inherit(table)
        entity.num=entity.num+1
        new_entity["id"] = entity.num
        new_entity["prev_x"] = new_entity.x
        new_entity["prev_y"] = new_entity.y
        add(self.entities, new_entity)
        return new_entity
    end,

    -- update entity
    update = function(self)
    end,

    -- perform turn actions
    do_turn = function(self)
    end,

    -- check if entity is on screen
    in_frame = function(self)
        return (self.x >= cam_x-1 and self.x < cam_x+17 and self.y >= cam_y-1 and self.y < cam_y+17-ui_h)
    end,

    -- draw entity
    draw = function(self)
        if (self:in_frame()) then
            sprite = self.sprite
            spr(sprite,pos_to_screen(self).x,pos_to_screen(self).y)
        end
    end,

    -- interact action
    interact = function(self)
    end,

    -- get entity at coordinate
    get = function(x,y)
        for e in all(entity.entities) do
            if (e.x == x and e.y == y) return e
        end
        return nil
    end,

    -- spawn entity on map
    spawn = function(sprite,x,y)
        mset(x,y,sprites.empty)
        -- get entity data
        entity_data = data.entities[sprite]
        if (entity_data ~= nil) then
            -- set up player
            if (entity_data.class == player.class) then
                player.x=x
                player.y=y
                player.sprite=sprite
                -- spawn player pet
                pet_sprite = (rnd() > 0.5 and sprites.pet_cat) or (sprites.pet_dog)
                pet_table = {x=x-1,y=y,sprite=pet_sprite}
                tbl_merge(pet_table,data.entities[pet_sprite])
                pet:new(pet_table)
            else
                -- set up data table
                table = {x=x,y=y,sprite=sprite}
                -- add data to table
                tbl_merge(table,entity_data)
                -- create new entity of given class
                if (table.class == pet.class) then
                    pet:new(table)
                elseif (table.class == npc.class) then 
                    npc:new(table)
                elseif (table.class == enemy.class) then 
                    enemy:new(table)
                elseif (table.class == sign.class) then
                    for e in all(data.signs) do 
                        if (e.x==x and e.y==y) then 
                            table.message=e.message 
                            break
                        end
                    end
                    sign:new(table)
                elseif (table.class == chest.class) then 
                    chest:new(table)
                elseif (table.class == stairs.class) then 
                    stairs:new(table)
                elseif (table.class == door.class) then
                    door:new(table)
                elseif (table.class == item.class) then 
                    item:new(table)
                else
                    entity:new(table)
                end
            end
        end
    end,
})



-------------------------------------------------------------------------------
-- creature
-------------------------------------------------------------------------------

creature = entity:inherit({
    
    -- static vars
    class="creature",
    parent_class=entity.class,
    anims={move={frames=3,dist=8},attack={frames=5,dist=6}},
    anim_playing=false,

    -- vars
    hostile=false,
    attacked=false,
    dead=false,
    dhp=0,
    dhp_turn=0,
    ap=2,
    max_hp=10,
    blink_delay=0,
    anim=nil,
    anim_frame=0,
    anim_x=0,
    anim_y=0,

    -- constructor
    new = function(self, table)
        local new_entity = entity.new(self, table)
        new_entity["hp"] = new_entity.max_hp
        return new_entity
    end,

    -- update creature
    update = function(self)
        if (self.anim_frame > 0) then 
            self:anim_step()
        elseif (prev_frame~=frame and self.blink_delay > 0) then
            self.blink_delay-=1
        end
    end,

    -- perform turn actions
    do_turn = function(self)
        if (turn > self.dhp_turn) then
            self.attacked = false
            if (self.dead and (turn-self.dhp_turn) > timer_grave) del(entity.entities, self)
        end
        return (not self.dead and self:in_frame())
    end,

    -- start playing animation
    play_anim = function(self,a,x,y)
        self.anim=a
        self.anim_frame=a.frames
        self.anim_x=x*a.dist
        self.anim_y=y*a.dist
        entity.anim_playing=true
    end,

    -- play animation
    anim_step = function(self)
        --anim_r=smoothstep(self.anim_frame/4)
        anim_r=self.anim_frame/self.anim.frames
        self.anim_x=self.anim.dist*anim_r*((self.anim_x < -0.1 and -1) or (self.anim_x > 0.1 and 1) or 0)
        self.anim_y=self.anim.dist*anim_r*((self.anim_y < -0.1 and -1) or (self.anim_y > 0.1 and 1) or 0)
        self.anim_frame-=1
        if (self.anim_frame<=0) then
            entity.anim_playing=false
            self.anim_x=0
            self.anim_y=0
        end
    end,

    -- draw creature
    draw = function(self)
        if (self:in_frame()) then
            sprite = self.sprite+frame*16
            -- dead
            if (self.dead) then
                sprite = sprites.grave
                if (frame == 1 and (turn - self.dhp_turn) <= 1 and self.blink_delay<=0)  sprite = sprites.void
            -- under attack
            elseif (self.attacked and frame == 1 and self.blink_delay<=0) then
                sprite = sprites.void
                print(abs(self.dhp),pos_to_screen(self).x+self.anim_x+4-str_width(abs(self.dhp))*0.5,pos_to_screen(self).y+self.anim_y+1,self.dhp<0 and 8 or 11)
            end
            -- render sprite and overlay
            spr(sprite,pos_to_screen(self).x+self.anim_x,pos_to_screen(self).y+self.anim_y)
        end
    end,

    -- kill creature
    kill = function(self)
        self.dead = true
        self.collision = false
        if (self == player) state = state_dead
    end,

    -- try to move the entity to a given map coordinate
    move = function (self,x,y)
        if not collision(x,y) and x >= 0 and x < width and y >= 0 and y < height and (x ~= 0 or y ~= 0) then
            self.prev_x = self.x
            self.prev_y = self.y
            self:play_anim(creature.anims.move,self.x-x,self.y-y)
            self.x = x
            self.y = y
            return true
        end
        return false
    end,

    move_towards_and_attack = function(self, other)
        if (dist_simp(self,other) <= 1 and ((self.x==other.x or self.y==other.y) or (self.x==other.x and not collision({x=self.x,y=other.y}) or not collision({x=other.x,y=self.y})))) then
            self:attack(other)
        else
            self:move_towards(other)
        end
    end,

    -- try to move an towards another entity
    move_towards = function(self, other)
        diff_x = other.x - self.x
        diff_y = other.y - self.y
        desire_x = (diff_x > 0 and 1) or (diff_x < 0 and -1) or 0
        desire_y = (diff_y > 0 and 1) or (diff_y < 0 and -1) or 0
        valid = ((abs(diff_x) < abs(diff_y)) and self:move(self.x,self.y+desire_y) or (self:move(self.x+desire_x,self.y) or self:move(self.x,self.y+desire_y)))
    end,

    -- follow another entity
    follow = function(self, other)
        if (dist_simp_xy(self.x,self.y,other.prev_x,other.prev_y) == 1) then
            self:move(other.prev_x,other.prev_y)
        else
            self:move_towards(other)
        end
    end,

    -- perform attack
    attack = function(self, other)
        if(self == player or other == player) log:add(self.name .. " attacked " .. other.name)
        if (other:take_dmg(flr(self.ap*(0.5+rnd())+0.5))) then
            log:add(self.name .. " killed " .. other.name)
            if (self == player) self.xp+=other.xp
        end
        self:play_anim(creature.anims.attack,other.x-self.x,other.y-self.y)
    end,

    -- take damage
    take_dmg = function(self,dmg)
        self.blink_delay=(frame==0 and 2) or 1
        if(self == player) draw:flash()
        self.attacked = true
        self.dhp=(self.dhp_turn==turn and self.dhp - dmg) or dmg*-1
        self.dhp_turn=turn
        self.hp-=dmg
        if (self.hp <= 0) then
            self:kill()
            return true
        end
        return false
    end,
})



-------------------------------------------------------------------------------
-- player
-------------------------------------------------------------------------------

player = creature:new({

    -- static vars
    class="player",
    parent_class=creature.class,
    interactable=false,

    -- vars
    name="you",
    xp=0,
    inventory={},

    -- move the player or attack if enemy in target tile
    action_dir = function(self, x,y)
        valid = false
        if (self:move(x,y)) then
            --log:add("you moved")
            valid = true
        end
        for e in all(entity.entities) do
            if (e.x==x and e.y==y) do
                if (e.class==enemy.class and e.hostile and not e.dead) then
                    self:attack(e)
                    valid = true
                elseif (e.class==stairs.class) then
                    e:trigger()
                    valid = true
                end
            end
        end
        return valid
    end,

    -- wait one turn
    action_wait = function(self)
        log:add("you waited")
        return true
    end,

    -- add item to inventory
    add_inventory = function(self,id)
        add(self.inventory,id)
    end,
})



-------------------------------------------------------------------------------
-- pet
-------------------------------------------------------------------------------

pet = creature:inherit({

    -- static vars
    class="pet",
    parent_class=creature.class,
    collision=false,

    -- perform turn actions
    do_turn = function(self)
        if creature.do_turn(self) then
            self:follow(player)
        end
    end
})



-------------------------------------------------------------------------------
-- npc
-------------------------------------------------------------------------------

npc = creature:inherit({

    -- static vars
    class="npc",
    parent_class=creature.class,

    -- perform turn actions
    do_turn = function(self)
        if creature.do_turn(self) then
        end
    end
})



-------------------------------------------------------------------------------
-- enemy
-------------------------------------------------------------------------------

enemy = creature:inherit({

    -- static vars
    class="enemy",
    parent_class=creature.class,
    hostile = true,

    -- vars
    ap = 1,
    max_hp = 5,
    xp=1,

    -- perform turn actions
    do_turn = function(self)
        if creature.do_turn(self) then
            if (self.hostile) then
                self:move_towards_and_attack(player)
            end
        end
    end,
})


-------------------------------------------------------------------------------
-- sign
-------------------------------------------------------------------------------

sign = entity:inherit({

    -- static vars
    class="sign",
    parent_class=entity.class,

    --vars
    message="...",
    bg=15,
    fg=0,
    interact_text="read",

    -- interact action
    interact = function(self)
        change_state(state_read)
        sel.read.text=self.message
        sel.read.fg=self.fg
        sel.read.bg=self.bg
    end,

})


-------------------------------------------------------------------------------
-- door
-------------------------------------------------------------------------------

door = entity:inherit({

    -- static vars
    class="door",
    parent_class=entity.class,

    -- vars
    locked=0,

    -- interact action
    interact = function(self)
        self.collision = not self.collision
        self.sprite = self.collision and 82 or 81
        log:add((self.collision and "closed" or "opened") .. " door")
        change_state(state_game)
    end,

})


-------------------------------------------------------------------------------
-- chest
-------------------------------------------------------------------------------

chest = entity:inherit({

    -- static vars
    class="chest",
    parent_class=entity.class,
    interact_text="open",

    -- interact action
    interact = function(self)
        log:add("opened chest")
        change_state(state_game)
    end,

})


-------------------------------------------------------------------------------
-- item
-------------------------------------------------------------------------------

item = entity:inherit({

    -- static vars
    class="item",
    parent_class=entity.class,
    collision=false,
    interact_text="pick up",

    -- interact action
    interact = function(self)
        log:add("picked up " .. self.name)
        player:add_inventory(self.sprite)
        del(entity.entities, self)
        change_state(state_game)
    end,

})

-------------------------------------------------------------------------------
-- stairs
-------------------------------------------------------------------------------

stairs = entity:inherit({

    -- static vars
    class="stairs",
    parent_class=entity.class,
    interactable=false,
    collision=false,

    -- trigger action
    trigger = function(self)
        log:add("went on stairs")
    end,

})
