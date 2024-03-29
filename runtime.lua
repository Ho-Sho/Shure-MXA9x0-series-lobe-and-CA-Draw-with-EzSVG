--Debug Function
---------------------------------------------------------
function DebugFormat(string) -- Format strings containing non-printable characters so we can see what they are
  local visual = ""
  for i=1,#string do
    local byte = string:sub(i,i)
    if string.byte(byte) >= 32 and string.byte(byte) <= 126 then
      visual = visual..byte
    else
      visual = visual..string.format("[%02xh]",string.byte(byte))
    end
  end
  return visual
end

DebugTx = false
DebugRx = false
DebugFunction = false
DebugPrint = Properties["Debug Print"].Value

-- A function to determine common print statement scenarios for troubleshooting
function SetupDebugPrint()
  if DebugPrint=="Tx/Rx" then
    DebugTx,DebugRx=true,true
  elseif DebugPrint=="Tx" then
    DebugTx=true
  elseif DebugPrint=="Rx" then
    DebugRx=true
  elseif DebugPrint=="Function Calls" then
    DebugFunction=true
  elseif DebugPrint=="All" then
    DebugTx,DebugRx,DebugFunction=true,true,true
  end
end

SetupDebugPrint()

---------------------------------------------------------
rapidjson = require 'rapidjson'
EzSVG = require 'EzSVG'

local rx = Controls.Rx
local docSize = Controls.DocSize.Value --must be larger than 3048
local center = docSize ~= nil and docSize/2 or nil
local buffer = ""
local fillColor = "lightblue"
local fillOpacity = 0.7
local strokeColor = fillColor
local strokeWidth = 1
local cx_fillColor = "red" --X axis color
local cy_fillColor = "green" --Y axis color
local c_fillOpacity = 0.8
local c_strokeColor = cx_fillColor
local c_strokeWidth = docSize*0.001

local L_fillColor = "#325a75"
local L_fillOpacity = 0.7
local L_strokeColor = L_fillColor
local L_strokeWidth = docSize*0.01

local L_af_fillColor = "#9bd6ed"
local L_af_fillOpacity = 0.15
local L_af_strokeColor = L_af_fillColor
local L_af_strokeWidth = docSize*0.01

local CA_fillColor = "gray"
local CA_fillOpacity = 0.2
local CA_strokeColor = "#80bbd1"
local CA_De_strokeColor = "#f5d9b1"
local CA_strokeWidth = docSize*0.01

local lobe_pos = {}
local lobe_af_pos = {}
for i = 1, 8 do
  lobe_pos[i] = {X = nil, Y = nil, Z = nil}
  lobe_af_pos[i] = {X = nil, Y = nil, Z = nil}
end
local lobe_dynamic = {}
local lobe_dedicated = {}
for i = 1, 8 do
  lobe_dynamic[i] = {Xmin = nil, Ymax = nil, Xmax = nil, Ymin = nil}
  lobe_dedicated[i] = {Xmin = nil, Ymax = nil, Xmax = nil, Ymin = nil}
end

local initialized = false
local init_ca = false
local auto_ca = Controls["AutoCoverage"]
local autocoverage = false
local nscale = 1--default
local scale = Controls["Scale"]
local nangle = 0
local angle = Controls["Angle"]
local xy_axis = Controls["XY_Axis"]
local axis = true

---------------------------------------------------------------------------------
ip = Controls["IP"]
port = 2202 --Controls["Port"]
shure = { Host = "" } --{ Host = "", Port = "" }
-- Build TCP Client---------------------------------------------------------------
sock = TcpSocket.New()
sock.ReadTimeout = 0
sock.WriteTimeout = 5
sock.ReconnectTimeout = 5

--Sock EventHandler
sock.EventHandler = function(sock, evt, err)
  if evt == TcpSocket.Events.Connected then
    if(DebugFunction)then print("TCP socket is Connected") end
    Timer.CallAfter(function()
      sock:Write("< GET 0 ALL >")
      sock:Write("< GET ALL >")
    end , 1)
  elseif evt == TcpSocket.Events.Data then
    buffer = buffer .. sock:Read(sock.BufferLength)  -- Buffer length
    --print(buffer)
    --rx.String = buffer
    GetAutoCoverage(buffer)

    if autocoverage == false then
      GetLobePos(buffer, autocoverage)
    else
      GetLobePosCA(buffer, autocoverage)
    end

    buffer = ""
  elseif evt == TcpSocket.Events.Closed then
    if(DebugFunction)then print("TCP socket was closed by the remote") end
  elseif evt == TcpSocket.Events.Error then
    if(DebugFunction)then print("TCP socket error") end
  elseif evt == TcpSocket.Events.Timeout then
    if(DebugFunction)then print("TCP socket timeout") end
  end
end

--Connect Function--------------------------------------------------------------
Connect = function()
  ip = Controls["IP"]; --port = Contorls["Port"]
  if (ip.String ~= "") then --(ip.String ~= "" and port.String ~= "")
    shure.Host = ip.String --shure.port = port.Stirng
    if(DebugFunction)then print("Connet to Shure Device IP : "..ip.String) end
    sock:Connect(shure.Host, 2202 )--(shure.Host, shure.Port )
    if(DebugFunction)then print("TCP socket is Connecting") end
  else
    if(DebugFunction)then print("IP Address Not Set") end
    ip.String = "Enter MXA's IP"
  end
end
ip.EventHandler = Connect
Connect()

------------------------------------------------------------------------------
function DrawSVG(svgData) --Draw SVG
  Controls.Image.Legend = rapidjson.encode({
    DrawChrome = false, -- Removes the button face and edges
    IconData = Crypto.Base64Encode(svgData),
  })
end
--Draw Lobe Coverage-----------------------------------------------------------
function DrawLobe(background)
  for i = 1, 8 do
    local pos = lobe_pos[i]
    if pos and pos.X and pos.Y and pos.Z then
      local lobeGroup = EzSVG.Group()
      -- draw lobe center
      local cx = (pos.X - center ) * nscale + center
      local cy = -nscale * (pos.Y  - center) + center
      local lobe_scale = nscale * 0.1
      local r = pos.Z * 2 * lobe_scale
      local lobe = EzSVG.Circle(cx, cy, r)
        :setStyle("fill", L_fillColor)
        :setStyle("opacity", L_fillOpacity)
        :setStyle("stroke", L_strokeColor)
        :setStyle("stroke-width", L_strokeWidth)
      lobeGroup:add(lobe)
      -- add text
      local lobe_txt_size = docSize*0.015 * nscale
      local lobe_txt = EzSVG.Text(i, cx - lobe_txt_size/3, cy + lobe_txt_size/3)
        :setStyle("font-size", lobe_txt_size)
        :setStyle("fill", "white")
      lobeGroup:add(lobe_txt)
      -- draw lobe
      local lobe_line = EzSVG.Line(center , center, cx - docSize*0.01, cy + docSize*0.01)
        :setStyle("fill", "#325a75")
      lobeGroup:add(lobe_line)

      background:add(lobeGroup)
    end
  end
end

function DrawLobe_AF(background)
  for i = 1, 8 do
    local posAF = lobe_af_pos[i]
    if posAF and posAF.X and posAF.Y and posAF.Z then
      local lobeAF_Group = EzSVG.Group()
      -- draw lobe center
      local cx = (posAF.X - center ) * nscale + center
      local cy = -nscale * (posAF.Y  - center) + center
      local lobe_scale = nscale * 0.8
      local r = posAF.Z * 2 * lobe_scale
      local lobeAF = EzSVG.Circle(cx, cy, r)
        :setStyle("fill", L_af_fillColor)
        :setStyle("opacity", L_af_fillOpacity)
        :setStyle("stroke", L_af_strokeColor)
        :setStyle("stroke-width", L_af_strokeWidth)
      lobeAF_Group:add(lobeAF)

      local L_af_line_strokeWidth = c_strokeWidth * nscale
      local lx = cx + (center - cx) * 0.08
      local ly = cy + (center - cy) * 0.08
      local lobeAF_line = EzSVG.Line(center, center, lx, ly)
        :setStyle("opacity", 0.6)
        :setStyle("stroke", "#325a75")
        :setStyle("stroke-width", L_af_line_strokeWidth)
      lobeAF_Group:add(lobeAF_line)

      background:add(lobeAF_Group)
    end
  end
end

--Draw CA Coverage----------------------------------------------------------------------------------
function DrawDynamicCA(background)
  for i = 1, 8 do
    local pos = lobe_dynamic[i]
    if pos and pos.Xmin and pos.Ymax and pos.Xmax and pos.Ymin then
      local Dy_CA_Group = EzSVG.Group()
      -- draw ca
      local xmin = (pos.Xmin - center) * nscale + center
      local ymax = (pos.Ymax - center) * -nscale + center
      local xwidth = (pos.Xmax - pos.Xmin) * nscale
      local ywidth = (pos.Ymax - pos.Ymin) * nscale
      local rpoint = xwidth / 50
      local dynamic_ca = EzSVG.Rect(xmin, ymax, xwidth, ywidth, rpoint, rpoint)
        :setStyle("fill", CA_fillColor)
        :setStyle("opacity", CA_fillOpacity)
        :setStyle("stroke", CA_strokeColor)
        :setStyle("stroke-width", CA_strokeWidth)
      Dy_CA_Group:add(dynamic_ca)
      -- Dash Line
      local cx = xwidth / 2
      local cy = ywidth / 2
      local dash_line_strokeWidth = 2.5 * nscale
      local dynamic_ca_dash_line = EzSVG.Line(center, center, cx+xmin, cy+ymax)
        :setStyle("opacity", 0.6)
        :setStyle("stroke", "black")
        :setStyle("stroke-width", dash_line_strokeWidth)
        :setStyle("stroke-dasharray", "10*nscale, 10*nscale")
      Dy_CA_Group:add(dynamic_ca_dash_line)
      -- add circle
      local dy_scale = nscale * 30
      local r = dy_scale
      local dynamic_ca_circle = EzSVG.Circle(cx+xmin, cy+ymax, r )
        :setStyle("fill", "white")
        :setStyle("opacity", 1)
        :setStyle("stroke", "black")
        :setStyle("stroke-width", 3)
      Dy_CA_Group:add(dynamic_ca_circle)
      -- add text
      local dynamic_ca_txt_size = docSize*0.015 * nscale
      local dynamic_ca_txt = EzSVG.Text(i, cx+xmin-dynamic_ca_txt_size/3, cy+ymax+dynamic_ca_txt_size/3 )
        :setStyle("font-size", dynamic_ca_txt_size)
        :setStyle("fill", "black")
      Dy_CA_Group:add(dynamic_ca_txt)
      Dy_CA_Group:rotate(-nangle, center, center)

      background:add(Dy_CA_Group)
    end
  end
end

function DrawDedicatedCA(background)
  for i = 1, 8 do
    local pos = lobe_dedicated[i]
    if  pos and pos.Xmin and pos.Ymax and pos.Xmax and pos.Ymin then
      local De_CA_Group = EzSVG.Group()
      -- draw ca
      local xmin = (pos.Xmin - center) * nscale + center
      local ymax = (pos.Ymax - center) * -nscale + center
      local xwidth = (pos.Xmax - pos.Xmin) * nscale
      local ywidth = (pos.Ymax - pos.Ymin) * nscale
      local rpoint = xwidth / 50
      local dedicated_ca = EzSVG.Rect(xmin, ymax, xwidth, ywidth, rpoint, rpoint)
        :setStyle("fill", CA_fillColor)
        :setStyle("opacity", CA_fillOpacity)
        :setStyle("stroke", CA_De_strokeColor)
        :setStyle("stroke-width", CA_strokeWidth)
      De_CA_Group:add(dedicated_ca)
      -- Dash Line
      local cx = xwidth / 2
      local cy = ywidth / 2
      local dash_line_strokeWidth = 2.5 * nscale
      local dedicated_ca_dash_line = EzSVG.Line(center, center, cx+xmin, cy+ymax)
        :setStyle("opacity", 0.6)
        :setStyle("stroke", "black")
        :setStyle("stroke-width", dash_line_strokeWidth)
        :setStyle("stroke-dasharray", "10*nscale, 10*nscale")
      De_CA_Group:add(dedicated_ca_dash_line)
      -- add circle
      local dy_scale = nscale * 30
      local r = dy_scale
      local dedicated_ca_circle = EzSVG.Circle(cx+xmin, cy+ymax, r )
        :setStyle("fill", "white")
        :setStyle("opacity", 1)
        :setStyle("stroke", "black")
        :setStyle("stroke-width", 3)
      De_CA_Group:add(dedicated_ca_circle)
      -- add text
      local dedicated_ca_txt_size = docSize*0.015 * nscale
      local dedicated_ca_txt = EzSVG.Text(i, cx+xmin-dedicated_ca_txt_size/3, cy+ymax+dedicated_ca_txt_size/3 )
        :setStyle("font-size", dedicated_ca_txt_size)
        :setStyle("fill", "black")
      De_CA_Group:add(dedicated_ca_txt)
      De_CA_Group:rotate(-nangle, center, center)

      background:add(De_CA_Group)
    end
  end
end


--Draw ALL SVG----------------------------------------------------------------------------------------
function DrawCampus(autocoverage, axis, nscale, nangle)
  nscale = scale.Value
  nangle = angle.Value
  local doc = EzSVG.Document(docSize, docSize)
  local background = EzSVG.Group()

  --Draw axis
  if axis == true then DrawAxis(background) end
  --Draw Lobe or CA
  if autocoverage == false then
    DrawLobe_AF(background, nangle)
    DrawLobe(background, nangle)
  else
    DrawDynamicCA(background, nangle)
    DrawDedicatedCA(background, nangle)
  end

  -- add a MXA to the document
  local mxa_w = (center/center)*60 * nscale
  local mxa_h = (center/center)*60 * nscale
  local mxa_x = center-(mxa_w/2)
  local mxa_y = center-(mxa_h/2)
  local MXA = EzSVG.Rect(mxa_x, mxa_y , mxa_w, mxa_h, 5, 5)
  local mxa_style_width = docSize*0.03 * nscale
  MXA:setStyle("fill", "white")
     :setStyle("fill-opacity", 1)
     :setStyle("stroke-width", mxa_style_width)
  background:add(MXA)

  -- add a small green rectangle to the top-right corner of the square
  local ledlight_w = (center/center)*12 * nscale
  local ledlight_h = (center/center)*5 * nscale
  local ledlight_x = (center-mxa_w/2)+mxa_w*4/6
  local ledlight_y = (center-mxa_h/2)+mxa_h*1/8
  local ledlight = EzSVG.Rect(ledlight_x, ledlight_y, ledlight_w, ledlight_h)
  ledlight:setStyle("fill", "#3cfc22")
  background:add(ledlight)
  local logofont_size = docSize*0.005 * nscale
  local logoLabel = EzSVG.Text("SHURE", ledlight_x, ledlight_y)
          :setStyle("font-size", logofont_size)
          :setStyle("fill", "black")
  background:add(logoLabel)
  --angle
  background:rotate(nangle, center, center)
  doc:add(background)

  -- add 8 lobes to the document
  svgData = doc:toString()
  DrawSVG(svgData)

end

function DrawAxis(background)
  -- draw the X-axis (red) and label
  local xLine = EzSVG.Line(center, docSize*0.05, center, docSize-(docSize*0.05) )
  xLine:setStyle("stroke", cx_fillColor)
      :setStyle("stroke-width", c_strokeWidth)
      :setStyle("fill-opacity", c_fillOpacity)
  background:add(xLine)
  local xLabel = EzSVG.Text("X", docSize-(docSize*0.05), center-(docSize*0.01) )
      :setStyle("font-size", docSize*0.03)
      :setStyle("fill", cy_fillColor)
  background:add(xLabel)
  local xlabel_half_point = center+center/2 --1524+712 = 2236
  local cm = xlabel_half_point-center -- 2236/4
  local meter = math.floor( cm / nscale+0.5) /100
  local xhalfLabel = EzSVG.Text( meter.."m", xlabel_half_point, center )
      :setStyle("font-size", docSize*0.03)
      :setStyle("fill", cy_fillColor)
  local m_xlabel_half_point = center-center/2
  local m_cm = m_xlabel_half_point-center
  local m_meter = math.floor( m_cm / nscale+0.5) /100
  local m_xhalfLabel = EzSVG.Text( m_meter.."m", m_xlabel_half_point, center )
      :setStyle("font-size", docSize*0.03)
      :setStyle("fill", cy_fillColor)
  background:add(xhalfLabel)
  background:add(m_xhalfLabel)

  -- draw the Y-axis (green) and label
  local yLine = EzSVG.Line(docSize*0.05, center, docSize-(docSize*0.05), center)
  yLine:setStyle("stroke", cy_fillColor)
      :setStyle("stroke-width", c_strokeWidth)
      :setStyle("fill-opacity", c_fillOpacity)
  background:add(yLine)
  local yLabel = EzSVG.Text("Y", center+docSize*0.01, docSize-(docSize*0.03) )
      :setStyle("font-size", docSize*0.03)
      :setStyle("fill", cx_fillColor)
  background:add(yLabel)
  local m_ylabel_half_point = center+center/2
  local m_cm = m_ylabel_half_point-center
  local m_meter = math.floor( m_cm / nscale+0.5) /100
  local m_yhalfLabel = EzSVG.Text("-" ..m_meter.."m", center, m_ylabel_half_point )
      :setStyle("font-size", docSize*0.03)
      :setStyle("fill", cx_fillColor)
  local ylabel_half_point = center-center/2
  local cm = ylabel_half_point-center
  local meter = math.floor( cm / nscale+0.5) /100 * -1
  local yhalfLabel = EzSVG.Text(meter.."m", center, ylabel_half_point )
      :setStyle("font-size", docSize*0.03)
      :setStyle("fill", cx_fillColor)
  background:add(yhalfLabel)
  background:add(m_yhalfLabel)
end

--Draw Lobe from Get Response-------------------------------------------------------------------
function GetLobePos(str, autocoverage)
  if type(str) == "string" then
    if str ~= nil and str ~= "" then
      local lines = {}
      for line in str:gmatch("< REP.- >") do
        table.insert(lines, line)
      end

      local fix = "< REP (%d) BEAM_(%a) (%d+) >"
      local af = "< REP (%d) BEAM_(%a)_AF (%d+) >"

      for _, line in ipairs(lines) do
        local index, axis, value = line:match(fix)
        if index and axis and value then
          lobe_num = tonumber(index)
          if not lobe_pos[lobe_num] then lobe_pos[lobe_num] = {} end
          if not initialized then
            lobe_pos[lobe_num][axis] = tonumber(value)
          end
        end
      end

      for _, line in ipairs(lines) do
        local index, axis, value = line:match(af)
        if index and axis and value then
          lobe_num = tonumber(index)
          if not lobe_af_pos[lobe_num] then lobe_af_pos[lobe_num] = {} end
          if not initialized then
            lobe_af_pos[lobe_num][axis] = tonumber(value)
          end
        end
      end

      initialized = true

      for _, line in ipairs(lines) do
        local index, axis, value = line:match(fix)
        if index and axis and value then
          lobe_num = tonumber(index)
          if not lobe_pos[lobe_num] then lobe_pos[lobe_num] = {} end
          lobe_pos[lobe_num][axis] = tonumber(value)
        end
      end
      for i = 1, 8 do
        if not lobe_pos[i] then lobe_pos[i] = {} end
        if not lobe_pos[i].X then lobe_pos[i].X = nil end
        if not lobe_pos[i].Y then lobe_pos[i].Y = nil end
        if not lobe_pos[i].Z then lobe_pos[i].Z = nil end
      end

      for _, line in ipairs(lines) do
        local index, axis, value = line:match(af)
        if index and axis and value then
          lobe_num = tonumber(index)
          if not lobe_af_pos[lobe_num] then lobe_af_pos[lobe_num] = {} end
          lobe_af_pos[lobe_num][axis] = tonumber(value)
        end
      end
      for i = 1, 8 do
        if not lobe_af_pos[i] then lobe_af_pos[i] = {} end
        if not lobe_af_pos[i].X then lobe_af_pos[i].X = nil end
        if not lobe_af_pos[i].Y then lobe_af_pos[i].Y = nil end
        if not lobe_af_pos[i].Z then lobe_af_pos[i].Z = nil end
      end
      --print("REP:".."lobe_pos:"..rapidjson.encode(lobe_pos) )
      --print("REP:".."lobe_af_pos:"..rapidjson.encode(lobe_af_pos) )
      DrawCampus(autocoverage, axis, nscale, nangle)
      return lobe_num, lobe_pos, lobe_af_pos
    end
  end
end
--Draw CA from Get Response-------------------------------------------------------------------
function GetLobePosCA(str, autocoverage)
  if type(str) == "string" then
    if str ~= nil and str ~= "" then
      local lines = {}
      for line in str:gmatch("< REP.- >") do
        table.insert(lines, line)
      end

      local dynamic = "< REP (%d+) CA_DYNAMIC (%d+) (%d+) (%d+) (%d+) >"
      local dedicated = "< REP (%d+) CA_DEDICATED (%d+) (%d+) (%d+) (%d+) >"

      for _, line in ipairs(lines) do
        local index, Xmin, Ymax, Xmax, Ymin = line:match(dynamic)
        --x_min--UpperLeft, y_max--UpperLeft, x_max--LowerRight, y_min--LowerRight
        if index and Xmin and Ymax and Xmax and Ymin then
          lobe_num = tonumber(index)
          if not lobe_dynamic[lobe_num] then lobe_dynamic[lobe_num] = {} end
          if not init_ca then
            lobe_dynamic[lobe_num].Xmin = tonumber(Xmin)
            lobe_dynamic[lobe_num].Ymax = tonumber(Ymax)
            lobe_dynamic[lobe_num].Xmax = tonumber(Xmax)
            lobe_dynamic[lobe_num].Ymin = tonumber(Ymin)
          end
        end
      end

      for _, line in ipairs(lines) do
        local index, Xmin, Ymax, Xmax, Ymin = line:match(dedicated)
        if index and Xmin and Ymax and Xmax and Ymin then
          lobe_num = tonumber(index)
          if not lobe_dedicated[lobe_num] then lobe_dedicated[lobe_num] = {} end
          if not init_ca then
            lobe_dedicated[lobe_num].Xmin = tonumber(Xmin)
            lobe_dedicated[lobe_num].Ymax = tonumber(Ymax)
            lobe_dedicated[lobe_num].Xmax = tonumber(Xmax)
            lobe_dedicated[lobe_num].Ymin = tonumber(Ymin)
          end
        end
      end

      init_ca = true -- initial flag off

      for _, line in ipairs(lines) do
        local index, Xmin, Ymax, Xmax, Ymin = line:match(dynamic)
        --x_min--UpperLeft, y_max--UpperLeft, x_max--LowerRight, y_min--LowerRight
        if index and Xmin and Ymax and Xmax and Ymin then
          lobe_num = tonumber(index)
          if not lobe_dynamic[lobe_num] then lobe_dynamic[lobe_num] = {} end
          lobe_dynamic[lobe_num].Xmin = tonumber(Xmin)
          lobe_dynamic[lobe_num].Ymax = tonumber(Ymax)
          lobe_dynamic[lobe_num].Xmax = tonumber(Xmax)
          lobe_dynamic[lobe_num].Ymin = tonumber(Ymin)
        end
      end
      for i = 1, 8 do
        if not lobe_dynamic[i] then lobe_dynamic[i] = {} end
        if not lobe_dynamic[i].Xmin then lobe_dynamic[i].Xmin = nil end
        if not lobe_dynamic[i].Ymax then lobe_dynamic[i].Ymax = nil end
        if not lobe_dynamic[i].Xmax then lobe_dynamic[i].Xmax = nil end
        if not lobe_dynamic[i].Ymin then lobe_dynamic[i].Ymin = nil end
      end

      for _, line in ipairs(lines) do
        local index, Xmin, Ymax, Xmax, Ymin = line:match(dedicated)
        if index and Xmin and Ymax and Xmax and Ymin then
          lobe_num = tonumber(index)
          if not lobe_dedicated[lobe_num] then lobe_dedicated[lobe_num] = {} end
          lobe_dedicated[lobe_num].Xmin = tonumber(Xmin)
          lobe_dedicated[lobe_num].Ymax = tonumber(Ymax)
          lobe_dedicated[lobe_num].Xmax = tonumber(Xmax)
          lobe_dedicated[lobe_num].Ymin = tonumber(Ymin)
        end
      end
      for i = 1, 8 do
        if not lobe_dedicated[i] then lobe_dedicated[i] = {} end
        if not lobe_dedicated[i].Xmin then lobe_dedicated[i].Xmin = nil end
        if not lobe_dedicated[i].Ymax then lobe_dedicated[i].Ymax = nil end
        if not lobe_dedicated[i].Xmax then lobe_dedicated[i].Xmax = nil end
        if not lobe_dedicated[i].Ymin then lobe_dedicated[i].Ymin = nil end
      end
      --print("REP:".."lobe_dynamic:["..lobe_num.."]"..rapidjson.encode(lobe_dynamic) )
      --print("REP:".."lobe_dedicated:["..lobe_num.."]"..rapidjson.encode(lobe_dedicated) )
      DrawCampus(autocoverage, axis, nscale, nangle)
      return lobe_num, lobe_dynamic, lobe_dedicated
    end
  end
end

function GetAutoCoverage(str)
  if str:find("MXA920") then
    sock:Write("< GET AUTO_COVERAGE >")
    Timer.CallAfter(function()
      sock:Write("< GET 0 CA_DYNAMIC >")
      sock:Write("< GET 0 CA_DEDICATED >")
    end, 0.5)
  elseif  str:find("MXA910") then
    auto_ca.Boolean = false
    auto_ca.Legend = "CA OFF"
    auto_ca.Color = "gray"
    autocoverage = false
    DrawCampus(autocoverage, axis, nscale, nangle)
  end
  if type(str) == "string" and str ~= "" then
    local CA = "< REP AUTO_COVERAGE (%a+) >"
    local match = str:match(CA)
    if match ~= nil then
      local flg = (match == "ON")
      --print(match, flg)

      if flg then
        sock:Write("< GET 0 CA_DYNAMIC >")
        sock:Write("< GET 0 CA_DEDICATED >")
      end

      if flg ~= auto_ca.Boolean then
        auto_ca.Boolean = flg
        autocoverage = flg
        auto_ca.EventHandler()
      end
    end
  end
end

--EventHandler-----------------------------------------------------------------------
auto_ca.EventHandler = function()
  if auto_ca.Boolean == false then
    auto_ca.Legend = "CA OFF"
    auto_ca.Color = "gray"
    --print("< SET AUTO_COVERAGE OFF >")
    sock:Write("< SET AUTO_COVERAGE OFF >")
  else
    auto_ca.Legend = "CA ON"
    auto_ca.Color = "blue"
    --print("< SET AUTO_COVERAGE ON >")
    sock:Write("< SET AUTO_COVERAGE ON >")
    Timer.CallAfter(function()
      sock:Write("< GET 0 CA_DYNAMIC >")
      sock:Write("< GET 0 CA_DEDICATED >")
    end, 0.5)
  end
  DrawCampus(autocoverage, axis, nscale, nangle)
end

--scaling
scale.EventHandler = function()
  -- Get the current scale value
  nscale = scale.Value
  -- Create a new SVG document
  DrawCampus(autocoverage, axis, nscale, nangle)
end
scale.EventHandler()

--rotate
angle.EventHandler = function()
  nangle = angle.Value
  if math.abs(angle.Value) == 360 then
    angle.Value = 0
  end
  DrawCampus(autocoverage, axis, nscale, nangle)

end

--Axis ON/OFF
xy_axis.EventHandler = function(arg)
  axis = xy_axis.Boolean
  if arg == "ON" then
    xy_axis.Boolean = true
    xy_axis.Legend = "ON"
    xy_axis.Color = "green"
  else
    xy_axis.Legend = axis and "ON" or "OFF"
    xy_axis.Color = axis and "green" or "gray"
  end
  DrawCampus(autocoverage, axis, nscale, nangle)
end
xy_axis.EventHandler("OFF")

auto_ca.Boolean = false
--auto_ca.EventHandler()
