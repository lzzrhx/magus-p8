-- glitch effect
function glitch1()
    o1 = flr(rnd(0x1F00)) + 0x6040
    o2 = o1 + flr(rnd(0x4)-0x2)
    len = flr(rnd(0x40))
    memcpy(o1,o2,len)
end

-- glitch effect
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

-- calculate distance between two points
function dist(a,b)
  return sqrt((b.x-a.x)^2 + (b.y-a.y)^2)
end

-- quartic polynomial smoothstep
function smoothstep(x) return x*x*(2-x*x) end

-- quadratic rational smoothstep
function smoothstep(x) return x*x/(2*x*x-2*x+1) end

--[[companion_x,companion_y=x,y
for i in all({-1,1}) do
  if not collision(x+i,y) then companion_x=x+i break
  elseif not collision(x,y+i) then companion_y=y+i break end
end]]--

--[[
l_w=0
if (k==1 or (title_text[k-1]=="" and v~="~ ⁙ ~")) do
  l=sub(v,1,1)
  l_w=(l=="i" and 5) or ((l=="y" or l=="t") and 6) or 7
  v=sub(v,2,-1)
  print("\014"..l,64-(str_width(v)+l_w)*0.5,83+(k-1)*8,5)
  print("\014"..l,64-(str_width(v)+l_w)*0.5,82+(k-1)*8,6)
end]]--

--if(sel_look.spell>0)for i=1,spell_dist*2 do for j=1,spell_dist*2 do rectfill(pos_to_screen(player).x+(i-1-spell_dist)*8,pos_to_screen(player).y+(j-1-spell_dist)*8,pos_to_screen(player).x+(i+1-spell_dist)*8,pos_to_screen(player).y+(j+1-spell_dist)*8,3) end end

-- quit cart
function quit()
  cls()
  stop()
end