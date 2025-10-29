-------------------------------------------------------------------------------
-- globals
-------------------------------------------------------------------------------

-- constants
empty=1    -- sprite no for the empty map tile
width=128   -- area width
height=64  -- area height
margin=2   -- left / right margin

-- vars
cam_x=0    -- camera y position
cam_y=0    -- camera x position
no=1       -- turn number
frame=0    -- animation frame number

-- enum, flags
flags={
    collision=0,
    --unused_one=1,
    --unused_two=2,
    --unused_three=3,
    --unused_four=4,
    --unused_five=5,
    --unused_six=6,
    entity=7,
}


-------------------------------------------------------------------------------
-- log
-------------------------------------------------------------------------------

log={
    -- initialize log entries table
    entries={"welcome to game"},

    -- add message to log
    add = function(self, message)
        add(self.entries,no .. ": " .. message)
    end,
}


-------------------------------------------------------------------------------
-- ui
-------------------------------------------------------------------------------

ui = {
    -- draw ui
    draw = function(self)
        -- bottom ui box
        rectfill(0,104,127,127,0)
        line(0,104,127,104,6)
        line(0,119,128,119,6)
        -- left
        print("pos:" .. player.x .. "-" .. player.y,margin,127-7*3,6)
        print("hp: " .. player.hp,margin,127-7*2,6)
        -- right
        ui_z="🅾️ wait"
        ui_x="❎ menu"
        print(ui_z,128-str_width(ui_z)-margin,127-7*3,6)
        print(ui_x,128-str_width(ui_x)-margin,127-7*2,6)
        -- bottom text
        print(log.entries[#log.entries],margin,127-6*1,6)
        -- frame
        line(0,0,127,0,6)     -- top
        line(127,0,127,127,6) -- right
        line(0,127,127,127,6) -- bottom
        line(0,0,0,127,6)     -- left
        pset(0,0,0)
        pset(127,0,0)
        pset(0,127,0)
        pset(127,127,0)
    end,
}


-------------------------------------------------------------------------------
-- built-in functions
-------------------------------------------------------------------------------

-- built-in init function
function _init()
    populate_map()
end

-- built-in update function
function _update()
    -- get player input and perform turn
    if (player:input()) turn()
    -- set animation frame
    frame = flr(t() * 2 % 2)
end

-- built-in draw function
function _draw()
    -- clear screen
    cls()
    -- draw map
    map(cam_x,cam_y)
    -- draw entities
    for e in all(entity.entities) do e:draw() end
    ui:draw()
end


-------------------------------------------------------------------------------
-- utils
-------------------------------------------------------------------------------

-- calculate distance between two points
function dist(a,b)
    return sqrt((b.x-a.x)^2 + (b.y-a.y)^2)
end

-- calculate distance between two points (simple)
function dist_simp(a,b)
    return max(abs(b.x-a.x),abs(b.y-a.y))
end

-- calculate string width
function str_width(s)
    return print(s,0,-10)
end

-- merge table b into table a
function tbl_merge(a,b)
    for k,v in pairs(b) do
        a[k] = v
    end
end


-------------------------------------------------------------------------------
-- system
-------------------------------------------------------------------------------

-- perform turn
function turn()
    -- update entities
    for e in all(entity.entities) do e:update() end
    -- update camera
    update_camera()
    -- increment turn counter
    no+=1
end

-- update camera position
function update_camera()
    if (player.x - cam_x > 11 and cam_x < width-16) then
        cam_x = player.x - 11
    elseif (player.x - cam_x < 4 and cam_x > 0) then
        cam_x = player.x - 4
    elseif (player.y - cam_y > 8 and cam_y < height-16) then
        cam_y = player.y - 8
    elseif (player.y - cam_y < 4 and cam_y > 0) then
        cam_y = player.y - 4
    end
end


-------------------------------------------------------------------------------
-- world
-------------------------------------------------------------------------------

-- iterate through all map tiles and find entities
function populate_map()
    for x=0,127 do
        for y=0,63 do
            if (mget(x,y) == 0) mset(x,y,empty)
            if (fget(mget(x,y),flags.entity)) entity.spawn(mget(x,y),x,y)
        end
    end
end

-- check for collision
function collision(x,y)
    if (fget(mget(x,y),flags.collision)) return true
    e = entity.get(x,y)
    if (e ~= nil and e.collision) return true
    return false
end
