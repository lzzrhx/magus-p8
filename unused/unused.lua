-- calculate distance between two points
function dist(a,b)
  return sqrt((b.x-a.x)^2 + (b.y-a.y)^2)
end

-- quartic polynomial smoothstep
function smoothstep(x) return x*x*(2-x*x) end

-- quadratic rational smoothstep
function smoothstep(x) return x*x/(2*x*x-2*x+1) end

-- quit cart
function quit()
  cls()
  stop()
end

-- get key for given value
function get_k(tbl,v0)
 for k,v1 in pairs(tbl) do if(v0==v1)return k end
 return 0
end

-- check if given vec2 is in table
function vec2_in_tbl(a,tbl)
 for b in all(tbl) do if(a.x==b.x and a.y==b.y)return true end
 return false
end

-- copy a table
function tbl_copy(a)
 local tbl={}
 for k,v in pairs(a) do tbl[k]=v end
 return tbl
end

-- spawn companion next to player in available tile
--[[
[[companion_x,companion_y=x,y
for i in all({-1,1}) do
  if not collision(x+i,y) then companion_x=x+i break
  elseif not collision(x,y+i) then companion_y=y+i break end
end]]--

-- glitch effect #1
function glitch1()
    o1 = flr(rnd(0x1F00)) + 0x6040
    o2 = o1 + flr(rnd(0x4)-0x2)
    len = flr(rnd(0x40))
    memcpy(o1,o2,len)
end

-- glitch effect #2
function glitch2(lines)
    local lines=lines or 64
    for i=1,lines do
        row=flr(rnd(128))
        row2=flr(rnd(127))
        if (row2>=row) row2+=1
        memcpy(0x4300, 0x6000+64*row, 64)
        memcpy(0x6000+64*row, 0x6000+64*row2, 64)
        memcpy(0x6000+64*row2, 0x4300,64)
    end
end