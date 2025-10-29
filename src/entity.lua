-------------------------------------------------------------------------------
-- object
-------------------------------------------------------------------------------

object = {
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
    class="entity",
    entities={},
    name="unknown",
    x=0,
    y=0,
    sprite=0,
    collision=true,
    attacked=false,
    attacked_no=0,
    hp=10,
    ap=2,
    hostile=false,

    -- constructor
    new = function(self, table)
        local new_entity = self:inherit(table)
        add(self.entities, new_entity)
        return new_entity
    end,

    -- set hit
    hit = function(self)
        self.attacked = true
        self.attacked_no=no
    end,

    -- update entity
    update = function(self)
        if (no > self.attacked_no) self.attacked = false
    end,

    -- draw entity
    draw = function(self)
        if (self.x >= cam_x and self.x < cam_x+16 and self.y >= cam_y and self.y < cam_y+16) then
            sprite = (self.attacked and frame == 0 and self.sprite) or (self.attacked and frame == 1 and empty) or self.sprite+frame*16
            spr(sprite,8*(self.x-cam_x),8*(self.y-cam_y))
        end
    end,

    -- get entity at coordinate
    get = function(x,y)
        for e in all(entity.entities) do
            if (e.x == x and e.y == y) return e
        end
        return nil
    end,

    -- try to move the entity to a given map coordinate
    move = function (self,x,y)
        if not collision(x,y) and x >= 0 and x < width and y >= 0 and y < height and (x ~= 0 or y ~= 0) then
            self.x = x
            self.y = y
            return true
        end
        return false
    end,

    -- perform attack
    attack = function(self, other)
        if(self == player or other == player) log:add(self.name .. " attacked " .. other.name)
        other.hp-=flr(self.ap*(0.5+rnd())+0.5)
        other:hit()
        if (other.hp <= 0) then 
            if(self == player) then
                log:add(self.name .. " killed " .. other.name)
                self.xp+=other.xp
            end
            del(entity.entities, other)
        end
    end,

    -- spawn entity on map
    spawn = function(sprite,x,y)
        mset(x,y,empty)
        -- get entity data
        entity_data = data.entities[sprite]
        if (entity_data ~= nil) then
            -- set up player
            if (entity_data.class == player.class) then
                player.x=x
                player.y=y
                player.sprite=sprite
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
                elseif (table.class == interactable.class) then
                    interactable:new(table)
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
-- player
-------------------------------------------------------------------------------

player = entity:new({
    class="player",
    name="you",
    xp=0,
    -- handle input
    input = function(self)
        valid = false
        if (btnp(⬆️)) valid = self:action_dir(self.x,self.y-1)
        if (btnp(➡️)) valid = self:action_dir(self.x+1,self.y)
        if (btnp(⬇️)) valid = self:action_dir(self.x,self.y+1)
        if (btnp(⬅️)) valid = self:action_dir(self.x-1,self.y)
        if (btnp(🅾️)) valid = self:action_wait()
        return valid
    end,

    -- move the player or attack if enemy in target tile
    action_dir = function(self, x,y)
        if (self:move(x,y)) then
            log:add("you moved")
            return true
        else
            e = entity.get(x,y)
            if (e ~= nil) then
                if (e.hostile) then
                    self:attack(e)
                    return true
                end
            end
        end
        return false
    end,

    -- wait one turn
    action_wait = function(self)
        log:add("you waited")
        return true
    end,
})


-------------------------------------------------------------------------------
-- pet
-------------------------------------------------------------------------------

pet = entity:inherit({
    class="pet",
})


-------------------------------------------------------------------------------
-- npc
-------------------------------------------------------------------------------

npc = entity:inherit({
    class="npc",
})


-------------------------------------------------------------------------------
-- enemy
-------------------------------------------------------------------------------

enemy = entity:inherit({
    class="enemy",
    hostile = true,
    ap = 1,
    hp = 5,
    xp=1,

    -- update function
    update = function(self)
        entity.update(self)
        if (self.hostile) then
            if (dist_simp(self,player) <= 1) then
                self:attack(player)
            else
                self:move_towards(player)
            end
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
})


-------------------------------------------------------------------------------
-- interactable
-------------------------------------------------------------------------------

interactable = entity:inherit({
    class="interactable",
})


-------------------------------------------------------------------------------
-- item
-------------------------------------------------------------------------------

item = entity:inherit({
    class="item",
})
