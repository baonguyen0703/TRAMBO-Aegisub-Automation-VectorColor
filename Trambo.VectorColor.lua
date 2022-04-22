script_name="@TRAMBO: Vector Color"
script_description="Add and delete vector color tags"
script_author="TRAMBO"
script_version="1.0"

include ("karaskel.lua") -- karaskel.lua written by Niels Martin Hansen, Rodrigo Braz Monteiro

--Main 
function main(sub, sel, act)
  local meta, styles = karaskel.collect_head(sub,false)
  sel = open_dialog(sub,sel)
  aegisub.set_undo_point(script_name)
  return sel   
end

function open_dialog(sub,sel)
  local meta, styles = karaskel.collect_head(sub,false)
  local line = sub[sel[1]]
  local tVColor = getVectorColor(sub,sel,styles,line)
  local vc1 = tVColor[1]
  local vc2 = tVColor[2]
  local vc3 = tVColor[3]
  local vc4 = tVColor[4]
  
  GUI = 
  {
    -- position labels
    { class = "label", x = 1, y = 0, width = 1, height = 1, label = "Top L"},
    { class = "label", x = 2, y = 0, width = 1, height = 1, label = "Top R"},
    { class = "label", x = 3, y = 0, width = 1, height = 1, label = "Bottom L"},
    { class = "label", x = 4, y = 0, width = 1, height = 1, label = "Bottom R"},
    { class = "label", x = 5, y = 0, width = 1, height = 1, label = "Mode"},
    
    --1vc
    { class = "checkbox", x = 0, y = 1, width = 1, height = 1, label = "Main", value = true, name = "main"},
    { class = "coloralpha", x = 1, y = 1, width = 1, height = 1, name = "tl1", value = vc1[1]},
    { class = "coloralpha", x = 2, y = 1, width = 1, height = 1, name = "tr1", value = vc1[2]},
    { class = "coloralpha", x = 3, y = 1, width = 1, height = 1, name = "bl1", value = vc1[3]},
    { class = "coloralpha", x = 4, y = 1, width = 1, height = 1, name = "br1", value = vc1[4]},
    
    --2vc
    { class = "checkbox", x = 0, y = 2, width = 1, height = 1, label = "Second", value = false, name = "second"},
    { class = "coloralpha", x = 1, y = 2, width = 1, height = 1, name = "tl2", value = vc2[1]},
    { class = "coloralpha", x = 2, y = 2, width = 1, height = 1, name = "tr2", value = vc2[2]},
    { class = "coloralpha", x = 3, y = 2, width = 1, height = 1, name = "bl2", value = vc2[3]},
    { class = "coloralpha", x = 4, y = 2, width = 1, height = 1, name = "br2", value = vc2[4]},
    
    --3vc
    { class = "checkbox", x = 0, y = 3, width = 1, height = 1, label = "Border", value = false, name = "bord"},
    { class = "coloralpha", x = 1, y = 3, width = 1, height = 1, name = "tl3", value = vc3[1]},
    { class = "coloralpha", x = 2, y = 3, width = 1, height = 1, name = "tr3", value = vc3[2]},
    { class = "coloralpha", x = 3, y = 3, width = 1, height = 1, name = "bl3", value = vc3[3]},
    { class = "coloralpha", x = 4, y = 3, width = 1, height = 1, name = "br3", value = vc3[4]},
    
    --4vc
    { class = "checkbox", x = 0, y = 4, width = 1, height = 1, label = "Shadow", value = false, name = "shad"},
    { class = "coloralpha", x = 1, y = 4, width = 1, height = 1, name = "tl4", value = vc4[1]},
    { class = "coloralpha", x = 2, y = 4, width = 1, height = 1, name = "tr4", value = vc4[2]},
    { class = "coloralpha", x = 3, y = 4, width = 1, height = 1, name = "bl4", value = vc4[3]},
    { class = "coloralpha", x = 4, y = 4, width = 1, height = 1, name = "br4", value = vc4[4]},
    
    --mode
    { class = "dropdown", x = 5, y = 1, width = 1, height = 1, name = "mode1", items = {"Add", "Delete"}, value = "Add"},
    { class = "dropdown", x = 5, y = 2, width = 1, height = 1, name = "mode2", items = {"Add", "Delete"}, value = "Add"},
    { class = "dropdown", x = 5, y = 3, width = 1, height = 1, name = "mode3", items = {"Add", "Delete"}, value = "Add"},
    { class = "dropdown", x = 5, y = 4, width = 1, height = 1, name = "mode4", items = {"Add", "Delete"}, value = "Add"}
    
  }
  
  --buttons
  local ok = ".                     Apply                     ."
  local cancel = ".                     Cancel                     ."
  buttons = {ok,cancel}
  
  choice, res = aegisub.dialog.display(GUI,buttons)
  
  --choices
  if choice == ok then
    local name = {res.main, res.second, res.bord, res.shad}
    local mode = {res.mode1, res.mode2, res.mode3, res.mode4}
    local c1 = {res.tl1, res.tr1, res.bl1, res.br1}
    local c2 = {res.tl2, res.tr2, res.bl2, res.br2}
    local c3 = {res.tl3, res.tr3, res.bl3, res.br3}
    local c4 = {res.tl4, res.tr4, res.bl4, res.br4}
    local tc = {c1, c2, c3, c4}
    
    for si,li in ipairs(sel) do
      local l = sub[li]
      local firstBlock = string.match(l.text, "{.-}")
      
      for i=1,4,1 do
        local n = tostring(i)
        if name[i] == true then
          --delete old tags
          if firstBlock ~= nil then
            local oldc = "\\" .. n .. "vc(.-%))"
            if string.find(l.text, oldc) then
              l.text = string.gsub(l.text, oldc, "",1)
            end
            
            local olda = "\\" .. n .. "va(.-%))"
            if string.find(l.text, olda) then 
                l.text = string.gsub(l.text, olda, "",1) 
            end
            --update
            firstBlock = string.match(l.text, "{.-}")
          end
          
          if mode[i] == "Add" then
            local vctag = "\\" .. n .. "vc(" .. color_from_style(tc[i][1]) .. "," .. color_from_style(tc[i][2]) .. "," .. color_from_style(tc[i][3]) .. "," .. color_from_style(tc[i][4]) .. ")"
            
            local vatag = ""
            if alpha_from_style(tc[i][1]) ~= "&H00&" or alpha_from_style(tc[i][2]) ~= "&H00&" or alpha_from_style(tc[i][3]) ~= "&H00&" or alpha_from_style(tc[i][4]) ~= "&H00&" then 
              vatag = "\\" .. n .. "va(" .. alpha_from_style(tc[i][1]) .. "," .. alpha_from_style(tc[i][2]) .. "," .. alpha_from_style(tc[i][3]) .. "," .. alpha_from_style(tc[i][4]) .. ")"
            end
            
            
            if firstBlock == nil then 
              l.text = "{" .. vctag .. vatag .. "}" .. l.text
            else
              local tag = string.match(l.text, '{(.-)}')
              tag = "{" .. tag .. vctag .. vatag .. "}"
              l.text = string.gsub(l.text, "{(.-)}", tag,1)  
            end
          end
        end
      end
      sub[li] = l
    end
  end
  
  return sel
end

function getVectorColor(sub,sel,styles,line)
  local t = {{},{},{},{}}
  
  if string.find(line.text,"{.-}") then
    local firstBlock = string.match(line.text,"{.-}")
    for i=1,4,1 do 
      local n = tostring(i)
      if string.find(firstBlock, n .. "vc%(") then
        local tca = {"","","",""}
        local tc = {}
        local ta = {"00","00","00","00"}
        --get vc tag
        local vc = string.match(firstBlock, n .. "vc.-%)")
        --extract vc
        for v in string.gmatch(vc,"&.-&") do
          local ctemp = string.gsub(string.gsub(v,"&",""),"H","")
          table.insert(tc,ctemp)
        end
        
        --if va tag found
        if string.find(firstBlock, n .. "va%(") then
          ta = {}
          --get va tag
          local va = string.match(firstBlock, n .. "va.-%)")
          --extract va
          for v in string.gmatch(va,"&.-&") do
            local atemp = string.gsub(string.gsub(v,"&",""),"H","")
            table.insert(ta,atemp)
          end
        end
        --create color alpha
        for j=1,4,1 do 
          tca[j] = "&H" .. ta[j] .. tc[j] .. "&"
        end
        
        t[i] = tca
      else
        t[i] = {"","","",""}
      end
    end
  else
    for j=1,4,1 do t[j] = {"","","",""} end
  end
 
  return t
end
--send to Aegisub's automation list
aegisub.register_macro(script_name,script_description,main,macro_validation)