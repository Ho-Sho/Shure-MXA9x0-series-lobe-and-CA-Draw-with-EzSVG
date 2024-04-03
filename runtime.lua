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
local L_fillOpacity = 0.8
local L_strokeColor = L_fillColor
local L_strokeWidth = docSize*0.01

local L_af_fillColor = "#9bd6ed"
local L_af_fillOpacity = 0.15
local L_af_strokeColor = L_af_fillColor
local L_af_strokeWidth = docSize*0.01

local CA_fillColor = "gray"
local CA_fillOpacity = 0.8
local CA_strokeColor = "#80bbd1"
local CA_strokeWidth = docSize*0.01
local CA_De_strokeColor = "#CC9242"--"#f5d9b1"
local CA_De_strokeWidth = docSize*0.015

local Active_Color = "lime"--black"--

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
local background = nil

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
      sock:Write("< GET 0 ALL >") --MXA910
      sock:Write("< GET ALL >") --MXA920
    end , 1)
    Timer.CallAfter(function() auto_ca.EventHandler()
    end , 1.5)
    Timer.CallAfter(function() angle.EventHandler()
    end , 2.0)
  elseif evt == TcpSocket.Events.Data then
    local buffer = ""
    buffer = buffer .. sock:Read(sock.BufferLength)  -- Buffer length
    --print("#buffer:"..#buffer, buffer)
    --rx.String = buffer
    GetAutoCoverage(buffer)
    if #buffer <= 4096 then
      if autocoverage == false then
        GetLobePos(buffer, autocoverage)
      else
        GetLobePosCA(buffer, autocoverage)
      end
      buffer = ""
    end
  elseif evt == TcpSocket.Events.Closed then
    if(DebugFunction)then print("TCP socket was closed by the remote") end
  elseif evt == TcpSocket.Events.Error then
    if(DebugFunction)then print("TCP socket error") end
    DrawCampus(autocoverage, axis, nscale, nangle, nil, "Clear")
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
function DrawLobe(background, active)
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
        :setStyle("fill-opacity", L_fillOpacity)
        :setStyle("stroke", L_strokeColor)
        :setStyle("stroke-width", L_strokeWidth)
      lobeGroup:add(lobe)
      -- add text
      local lobe_txt_size = docSize*0.01 * nscale
      local lobe_txt = EzSVG.Text(i, cx - lobe_txt_size/3, cy + lobe_txt_size/3)
        :setStyle("font-size", lobe_txt_size)
        :setStyle("fill", "white")
        :setStyle("text-anchor", "start")
      lobeGroup:add(lobe_txt)
      -- draw lobe
      local lobe_line = EzSVG.Line(center , center, cx - docSize*0.01, cy + docSize*0.01)
        :setStyle("fill", L_fillColor)
      lobeGroup:add(lobe_line)

      background:add(lobeGroup)
    end
  end
end

function DrawLobe_AF(background, active)
  for i = 1, 8 do
    local posAF = lobe_af_pos[i]
    if posAF and posAF.X and posAF.Y and posAF.Z then
      local lobeAF_Group = EzSVG.Group()
      -- draw lobe center
      local cx = (posAF.X - center ) * nscale + center
      local cy = -nscale * (posAF.Y  - center) + center
      local dx = posAF.X - center
      local dy = posAF.Y - center
      -- Calculate angle with respect to the center (center, center) in radians
      local c_radian = math.atan2(dy, dx)
      local c_degree = math.deg(c_radian)
      local lobe_scale = nscale * 0.8
      local r = posAF.Z * 2 * lobe_scale
      local rx = r * 0.7
      local ry = r
      -- Calculate rotation angle with -90 degree offset
      local rotation_angle = c_degree - 90

      local lobeAF = EzSVG.Ellipse(cx, cy, rx, ry)
        :setStyle("fill", L_af_fillColor)
        :setStyle("fill-opacity", L_af_fillOpacity)
        :setStyle("stroke", L_af_strokeColor)
        :setStyle("stroke-width", L_af_strokeWidth)
        :rotate(-rotation_angle, cx, cy)
      lobeAF_Group:add(lobeAF)
      -- draw lobe center
      local L_af_line_strokeWidth = c_strokeWidth * nscale
      local lx = cx + (center - cx) * 0.08
      local ly = cy + (center - cy) * 0.08
      local lobeAF_line = EzSVG.Line(center, center, lx, ly)
        :setStyle("stroke-opacity", 0.4)
        :setStyle("stroke", L_fillColor)
        :setStyle("stroke-width", L_af_line_strokeWidth)
      lobeAF_Group:add(lobeAF_line)
      -- active
      if i == tonumber(active) then
        local active_lobeAF = EzSVG.Ellipse(cx, cy, rx, ry)
        active_lobeAF:setStyle("stroke", L_strokeColor):setStyle("stroke-width", L_strokeWidth * .5)
        :setStyle("fill", "none")
        :setStyle("opacity", 0.8)
        :rotate(-rotation_angle, cx, cy)
        lobeAF_Group:add(active_lobeAF)
      end

      background:add(lobeAF_Group)
    end
  end
end

--Draw CA Coverage----------------------------------------------------------------------------------
function DrawDynamicCA(background, active)
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
        :setStyle("fill-opacity", CA_fillOpacity)
        :setStyle("stroke-width", CA_strokeWidth)
        :setStyle("stroke", CA_strokeColor)
        :setStyle("stroke-width", CA_strokeWidth)
      Dy_CA_Group:add(dynamic_ca)
      -- active
      if i == tonumber(active) then
        local scale = 1.02
        local new_xmin = xmin - (xwidth * ((scale-1)/2) )  -- Adjusting for 1.01 times scaling
        local new_ymin = ymax - (ywidth * ((scale-1)/2) )  -- Adjusting for 1.01 times scaling
        local new_xwidth = xwidth * scale
        local new_ywidth = ywidth * scale
        -- Create the active_ca rectangle with the adjusted position and size
        local active_ca = EzSVG.Rect(new_xmin, new_ymin, new_xwidth, new_ywidth, rpoint, rpoint)
        active_ca:setStyle("stroke", Active_Color):setStyle("stroke-width", CA_strokeWidth * .5)
        :setStyle("fill", "none")
        :setStyle("opacity", 1)
        Dy_CA_Group:add(active_ca)
      end
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
      local dy_scale = nscale * 25
      local r = dy_scale
      local dynamic_ca_circle = EzSVG.Circle(cx+xmin, cy+ymax, r )
        :setStyle("fill", "white")
        :setStyle("opacity", 1)
        :setStyle("stroke", "black")
        :setStyle("stroke-width", 3)
      Dy_CA_Group:add(dynamic_ca_circle)
      -- add text
      local dynamic_ca_txt_size = docSize*0.01 * nscale
      local dynamic_ca_txt = EzSVG.Text(i, cx+xmin-dynamic_ca_txt_size/3, cy+ymax+dynamic_ca_txt_size/3 )
        :setStyle("font-size", dynamic_ca_txt_size)
        :setStyle("fill", "black")
        :setStyle("text-anchor", "start")
      Dy_CA_Group:add(dynamic_ca_txt)
      Dy_CA_Group:rotate(-nangle, center, center)

      background:add(Dy_CA_Group)
    end
  end
end

function DrawDedicatedCA(background, active)
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
        :setStyle("fill-opacity", CA_fillOpacity)
        :setStyle("stroke", CA_De_strokeColor)
        :setStyle("stroke-width", CA_De_strokeWidth)
      De_CA_Group:add(dedicated_ca)
      -- active
      if i == tonumber(active) then
        local scale = 1.02
        local new_xmin = xmin - (xwidth * ((scale-1)/2) )  -- Adjusting for 1.01 times scaling
        local new_ymin = ymax - (ywidth * ((scale-1)/2) )  -- Adjusting for 1.01 times scaling
        local new_xwidth = xwidth * scale
        local new_ywidth = ywidth * scale
        -- Create the active_ca rectangle with the adjusted position and size
        local active_ca = EzSVG.Rect(new_xmin, new_ymin, new_xwidth, new_ywidth, rpoint, rpoint)
        active_ca:setStyle("stroke", Active_Color):setStyle("stroke-width", CA_De_strokeWidth * .5)
        :setStyle("fill", "none")
        :setStyle("opacity", 1)
        De_CA_Group:add(active_ca)
      end
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
      local dy_scale = nscale * 25
      local r = dy_scale
      local dedicated_ca_circle = EzSVG.Circle(cx+xmin, cy+ymax, r )
        :setStyle("fill", "white")
        :setStyle("opacity", 1)
        :setStyle("stroke", "black")
        :setStyle("stroke-width", 3)
      De_CA_Group:add(dedicated_ca_circle)
      -- add text
      local dedicated_ca_txt_size = docSize*0.01 * nscale
      local dedicated_ca_txt = EzSVG.Text(i, cx+xmin-dedicated_ca_txt_size/3, cy+ymax+dedicated_ca_txt_size/3 )
        :setStyle("font-size", dedicated_ca_txt_size)
        :setStyle("fill", "black")
        :setStyle("text-anchor", "start")
      De_CA_Group:add(dedicated_ca_txt)
      De_CA_Group:rotate(-nangle, center, center)

      background:add(De_CA_Group)
    end
  end
end

--Draw ALL SVG----------------------------------------------------------------------------------------
function DrawCampus(autocoverage, axis, nscale, nangle, active, mode)
  nscale = scale.Value
  nangle = angle.Value
  local doc = EzSVG.Document(docSize, docSize)
  local background = EzSVG.Group()
  --Draw axis
  if axis == true then DrawAxis(background) end
  --Clear Lobe or CA
  if mode == nil then
    --Draw Lobe or CA
    if autocoverage == false then
      DrawLobe_AF(background, active)
      DrawLobe(background, active)
    else
      DrawDynamicCA(background, active)
      DrawDedicatedCA(background, active)
    end
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
  local ledlight_w = (center/center)*16 * nscale
  local ledlight_h = (center/center)*4 * nscale
  local ledlight_x = (center-mxa_w/2)+mxa_w*4/6
  local ledlight_y = (center-mxa_h/2)+mxa_h*1/8
  local ledlight = EzSVG.Rect(ledlight_x, ledlight_y, ledlight_w, ledlight_h)
  ledlight:setStyle("fill", ledlightColor)--"#3cfc22"
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

--Draw Axis----------------------------------------------------------------------------------------
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
--Draw Lobe Helper func-------------------------------------------------------------------
function LobeInfo(lines, pattern, lobe_storage)
  for _, line in ipairs(lines) do
    local index, axis, value = line:match(pattern)
    if index and axis and value then
      local lobe_num = tonumber(index)
      if not lobe_storage[lobe_num] then lobe_storage[lobe_num] = {} end
      lobe_storage[lobe_num][axis] = tonumber(value)
    end
  end
end
--Draw Lobe from Get Response-------------------------------------------------------------------
function GetLobePos(str, autocoverage)
  if type(str) == "string" and str ~= nil and str ~= "" then
    local lines = {}
    for line in str:gmatch("< REP.- >") do
      table.insert(lines, line)
    end

    local fix = "< REP (%d+) BEAM_(%a) (%d+) >"
    local af = "< REP (%d+) BEAM_(%a)_AF (%d+) >"
    local active_lobe = "< REP (%d%d?) AUTOMIX_GATE_OUT_EXT_SIG (%a+) >"
    local active_lobes = {}

    for _, line in ipairs(lines) do
      local index, sts = line:match(active_lobe)
      if index and sts == "ON" then
      table.insert(active_lobes, index)
      end
    end

    LobeInfo(lines, fix, lobe_pos)
    LobeInfo(lines, af, lobe_af_pos)

    initialized = true -- initial flag off
    --print("REP:".."lobe_pos:"..rapidjson.encode(lobe_pos) )
    --print("REP:".."lobe_af_pos:"..rapidjson.encode(lobe_af_pos) )
    DrawCampus(autocoverage, axis, nscale, nangle, active)
    for _, active in ipairs(active_lobes) do
      --print("active_lobe_index: "..active)
      DrawCampus(autocoverage, axis, nscale, nangle, active)
    end
    return lobe_num, lobe_pos, lobe_af_pos
  end
end

--Draw CA Helper func-------------------------------------------------------------------
function LobeInfoCA(lines, pattern, lobe_storage)
  for _, line in ipairs(lines) do
    --x_min--UpperLeft, y_max--UpperLeft, x_max--LowerRight, y_min--LowerRight
    local index, Xmin, Ymax, Xmax, Ymin = line:match(pattern)
    if index and Xmin and Ymax and Xmax and Ymin then
      local lobe_num = tonumber(index)
      if not lobe_storage[lobe_num] then lobe_storage[lobe_num] = {} end
      lobe_storage[lobe_num].Xmin = tonumber(Xmin)
      lobe_storage[lobe_num].Ymax = tonumber(Ymax)
      lobe_storage[lobe_num].Xmax = tonumber(Xmax)
      lobe_storage[lobe_num].Ymin = tonumber(Ymin)
    end
  end
end
function RemoveLobeInfo(lines, pattern, lobe_storage)
  for _, line in ipairs(lines) do
    local index = line:match(pattern)
    if index then
      local ca_num = tonumber(index)
      if not lobe_storage[ca_num] then lobe_storage[ca_num] = {} end
      lobe_storage[ca_num].Xmin = nil
      lobe_storage[ca_num].Ymax = nil
      lobe_storage[ca_num].Xmax = nil
      lobe_storage[ca_num].Ymin = nil
    end
  end
end
--Draw CA from Get Response-------------------------------------------------------------------
function GetLobePosCA(str, autocoverage)
  if type(str) == "string" and str ~= nil and str ~= "" then
    local lines = {}
    for line in str:gmatch("< REP.- >") do
      table.insert(lines, line)
    end

    local dynamic = "< REP (%d+) CA_DYNAMIC (%d+) (%d+) (%d+) (%d+) >"
    local dedicated = "< REP (%d+) CA_DEDICATED (%d+) (%d+) (%d+) (%d+) >"
    local remove_ca = "< REP (%d+) CA_MUTE OFF >"
    local active_ca = "< REP (%d+) AUTOMIX_GATE_OUT_CA (%a+) >"
    local active_cas = {}

    for _, line in ipairs(lines) do
      local index, sts = line:match(active_ca)
      if index and sts and sts == "ON" then
      table.insert(active_cas, index)
      end
    end

    LobeInfoCA(lines, dynamic, lobe_dynamic)
    LobeInfoCA(lines, dedicated, lobe_dedicated)
    init_ca = true -- initial flag off
    RemoveLobeInfo(lines, remove_ca, lobe_dynamic)
    RemoveLobeInfo(lines, remove_ca, lobe_dedicated)
    --print("REP:".."lobe_dynamic:["..lobe_num.."]"..rapidjson.encode(lobe_dynamic) )
    --print("REP:".."lobe_dedicated:["..lobe_num.."]"..rapidjson.encode(lobe_dedicated) )
    DrawCampus(autocoverage, axis, nscale, nangle, active)
    for _, active in ipairs(active_cas) do
      --print("acteive_ca_index: "..active)
      DrawCampus(autocoverage, axis, nscale, nangle, active)
    end
    return lobe_num, lobe_dynamic, lobe_dedicated
  end
end
--Get Auto Coverage Response-------------------------------------------------------------------
function GetAutoCoverage(str)
  if str:find("MXA920") then
    sock:Write("< GET AUTO_COVERAGE >")
    Timer.CallAfter(function()
      sock:Write("< GET 0 CA_DYNAMIC >")
      sock:Write("< GET 0 CA_DEDICATED >")
    end, 0.5)
    auto_ca.IsDisabled = false
  elseif str:find("MXA910") then
    auto_ca.Boolean = false
    auto_ca.IsDisabled = true
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
      --print("match: "..match, "flg: "..tostring(flg) )
      if flg then
        sock:Write("< GET 0 CA_DYNAMIC >")
        sock:Write("< GET 0 CA_DEDICATED >")
      end
      auto_ca.Boolean = flg
      autocoverage = flg
      if flg ~= auto_ca.Boolean then
        auto_ca.EventHandler()
      end
    end
  end
end

--fillOpacity and color
function RelationColor()
  L_af_fillColor = Controls.Lobe_FillColor.String == "" and "#9bd6ed" or Controls.Lobe_FillColor.String
  L_af_fillOpacity = Controls.Lobe_Opacity.Value == 0 and 0.15 or tonumber(string.format("%.2f", Controls.Lobe_Opacity.Value))
  L_af_strokeColor = L_af_fillColor

  CA_fillColor = Controls.CA_FillColor.String == "" and "gray" or Controls.CA_FillColor.String
  CA_fillOpacity = Controls.CA_Opacity.Value == 0 and 0.4 or tonumber(string.format("%.2f", Controls.CA_Opacity.Value))

  Active_Color = Controls.ActiveColor.String == "" and "lime" or Controls.ActiveColor.String

  L_strokeWidth = Controls.Lobe_StrokeWidth.Value == 0 and docSize*0.01 or Controls.Lobe_StrokeWidth.Value
  L_af_strokeWidth = L_strokeWidth
  CA_strokeWidth = Controls.CA_StrokeWidth.Value == 0 and docSize*0.01 or Controls.CA_StrokeWidth.Value
  CA_De_strokeWidth = Controls.CA_De_StrokeWidth.Value == 0 and docSize*0.01 or Controls.CA_De_StrokeWidth.Value

  Controls.LEDLightColor.Choices = {"red","orange","gold","yellow","yellowgreen","lime","turquoise","powderblue","cyan","skyblue","blue","purple","lightpurple","violet","orchid","pink","white"}
  if Controls.LEDLightColor.String == nil then
    ledlightColor = Controls.LEDLightColor.String == "" and "lime" or Controls.LEDLightColor.String
  else
    ledlightColor = Controls.LEDLightColor.String == "" and "lime" or Controls.LEDLightColor.String
  end
  Controls.Lobe_FillColor.String, Controls.Lobe_FillColor.Color, Controls.Lobe_Opacity.Value = L_af_fillColor, L_af_fillColor, L_af_fillOpacity
  Controls.CA_FillColor.String, Controls.CA_FillColor.Color, Controls.CA_Opacity.Value = CA_fillColor, CA_fillColor, CA_fillOpacity
  Controls.ActiveColor.String = Active_Color
  Controls.ActiveColor.Color = Active_Color
  Controls.LEDLightColor.String = ledlightColor
  Controls.LEDLightColor.Color = ledlightColor
  Controls.Lobe_StrokeWidth.Value, Controls.CA_StrokeWidth.Value, Controls.CA_De_StrokeWidth.Value = L_strokeWidth, CA_strokeWidth, CA_De_strokeWidth
  DrawCampus(autocoverage, axis, nscale, nangle, active, mode)
end
RelationColor()
Controls.Lobe_FillColor.EventHandler    = RelationColor
Controls.Lobe_Opacity.EventHandler      = RelationColor
Controls.CA_FillColor.EventHandler      = RelationColor
Controls.CA_Opacity.EventHandler        = RelationColor
Controls.LEDLightColor.EventHandler     = RelationColor
Controls.ActiveColor.EventHandler       = RelationColor
Controls.Lobe_StrokeWidth.EventHandler  = RelationColor
Controls.CA_StrokeWidth.EventHandler    = RelationColor
Controls.CA_De_StrokeWidth.EventHandler = RelationColor

--EventHandler-----------------------------------------------------------------------
auto_ca.EventHandler = function()
  if auto_ca.Boolean == false then
    auto_ca.Legend = "CA OFF"
    auto_ca.Color = "gray"
    --print("< SET AUTO_COVERAGE OFF >")
    if sock.IsConnected then sock:Write("< SET AUTO_COVERAGE OFF >") end
  else
    auto_ca.Legend = "CA ON"
    auto_ca.Color = "blue"
    --print("< SET AUTO_COVERAGE ON >")
    if sock.IsConnected then sock:Write("< SET AUTO_COVERAGE ON >") end
  end
  Timer.CallAfter(function()
    sock:Write("< GET 0 ALL >")
    sock:Write("< GET ALL >")
  end , 1)
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
