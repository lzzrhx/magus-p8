function dist(a,b)
return max(abs(b.x-a.x),abs(b.y-a.y))
end
function str_width(s)
return print(s,0,-128)
end
function str_height(s)
return tbl_len(split(s,"\n"))
end
function tbl_copy(a)
local tbl={}
for k,v in pairs(a)do tbl[k]=v end
return tbl
end
function tbl_merge_new(a,b)
local tbl={}
for k,v in pairs(a)do tbl[k]=v end
for k,v in pairs(b)do tbl[k]=v end
return tbl
end
function tbl_merge(a,b)
for k,v in pairs(b)do a[k]=v end return a
end
function tbl_len(tbl)
local n=0
for k,v in pairs(tbl)do n+=1end
return n
end
function smoothstep(x)
return x*x*(3-2*x)
end
function lerp(val,min,max)
return(max-min)*val+min
end
function vec2_add(a,b)
return{x=a.x+b.x,y=a.y+b.y}
end
function vec2_scale(a,b)
return{x=a.x*b,y=a.y*b}
end
function vec2_spr(s,pos)
palt(0,false)
palt(15,true)
spr(s,pos.x,pos.y)
palt()
end
function toggle_bool(b)
_𝘦𝘯𝘷[b]=not _𝘦𝘯𝘷[b]
end
function wavy(i,h,s,o)
return sin(t()*(s or 1.25)+(i or 1)*(o or.06))*(h or 3)
end
function wavy_print(s,x,y,c0,c1,h)
for i=1,#s do s_print(sub(s,i,i),x+i*4,y+wavy(i,h),true,true,c0,c1)end
end
function s_print(s,x,y,c1e,c0e,c0,c1)
local c0,c1=c0 or 6,c1 or 5
if(c1e~=false)print(s,x,y+1,c1)
if(c0e~=false)print(s,x,y,c0)
end