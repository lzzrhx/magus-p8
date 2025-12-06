-------------------------------------------------------------------------------
-- from data.lua
-------------------------------------------------------------------------------

data_entities={
 [8]={class="stairs"},
 [3]={class="sign",name="grave",message="rest in peace",bg=13,fg=6},
}

-- signs
-------------------------------------------------------------------------------
data_signs = {
 -- x,y,message
 split"5,58,welcome to\nthyng village",
 split"52,31,◀- vangald fortress\n-▶ woodlands",
}



-------------------------------------------------------------------------------
-- from main.lua
-------------------------------------------------------------------------------

state_read="read"

init={
 -- read state
 read=function(sel)
  sel_read=sel
 end,
}

update={
 -- read state
 read=function()
  input.read()
 end,
}

draw={
 -- read state
 read=function()
  draw.look()
  draw.monochrome()
  local txt=split(sel_read.message,"\n")
  local exp=max(#txt-5,0)*4
  local y0=34-exp
  local y1=76+exp
  rectfill(23,y0,103,y1,sel_read.bg)
  line(24,y0-1,102,y0-1,sel_read.bg)
  line(24,y1+1,102,y1+1,sel_read.bg)
  for i=1,tbl_len(txt) do
   print(txt[i],64-str_width(txt[i])*0.5,29-exp+max(5-#txt,0)*4+i*8,sel_read.fg)
  end
  s_print("continue ❎",42,85+exp)
 end,
}



-------------------------------------------------------------------------------
-- from object.lua
-------------------------------------------------------------------------------

-- sign
-------------------------------------------------------------------------------
sign=entity:inherit({
 -- static vars
 class="sign",
 parent_class=entity.class,

 --vars
 interact_text="read",
 message="...",
 bg=15,
 fg=0,

 -- constructor
 new=function(self,tbl)
  for d in all(data_signs) do if d[1]==tbl.x and d[2]==tbl.y then tbl.message=d[3] break end end
  return entity.new(self,tbl)
 end,

 -- interact action
 interact=function(self)
  change_state(state_read,self)
 end,
})