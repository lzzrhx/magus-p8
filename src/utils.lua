-- utils
-------------------------------------------------------------------------------

-- calculate (chebyshev) distance between two points
function dist(a,b)
 return max(abs(b.x-a.x),abs(b.y-a.y))
end

-- get string width (in pixels)
function str_width(s)
 return print(s,0,-128)
end

-- get string height (in lines)
function str_height(s)
 return tbl_len(split(s,"\n"))
end

-- merge table a and b into a new table
function tbl_merge_new(a,b)
 local tbl={}
 tbl_merge(tbl,a)
 tbl_merge(tbl,b)
 return tbl
end

-- merge table b into table a
function tbl_merge(a,b)
 for k,v in pairs(b) do a[k]=v end
 return a
end

-- get length of table
function tbl_len(tbl)
 local n=0
 for k,v in pairs(tbl) do n+=1 end
 return n
end

-- cubic polynomial smoothstep
function smoothstep(x)
 return x*x*(3-2*x)
end

-- linear interpolation
function lerp(val,min,max)
 return (max-min)*val+min
end

-- add two 2d vectors
function vec2_add(a,b)
 return {x=a.x+b.x,y=a.y+b.y}
end

-- scale a 2d vector
function vec2_scale(a,b)
 return {x=a.x*b,y=a.y*b}
end

-- draw sprite with 2d vector screen coordinate
function vec2_spr(s,pos)
 palt(0,false)
 palt(15,true)
 spr(s,pos.x,pos.y)
 palt()
end

-- toggle a boolean value
function toggle_bool(b)
 _ENV[b]=not _ENV[b]
end

-- wavy value
function wavy(i,h,s,o)
 return sin(t()*(s or 1.25)+(i or 1)*(o or 0.06))*(h or 3)
end

-- wavy text
function wavy_s_print(s,x,y,c0,c1,h)
 for i=1,#s do s_print(sub(s,i,i),x+i*4,y+wavy(i,h),true,true,c0,c1) end
end

-- print with shadow
function s_print(s,x,y,c1e,c0e,c0,c1)
 local c0,c1=c0 or 6,c1 or 5
 if(c1e~=false)print(s,x,y+1,c1)
 if(c0e~=false)print(s,x,y,c0)
end

-- sum all values in table
function tbl_sum(tbl)
 local n=0
 for i in all(tbl) do n+=i end
 return n
end

-- count non-zero values in table
function tbl_len_nonzero(tbl)
 local n=0
 for sub_tbl in all(tbl) do if(sub_tbl>0)n+=1 end
 return n
end