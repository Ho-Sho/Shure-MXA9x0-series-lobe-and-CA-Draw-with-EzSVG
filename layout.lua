local CurrentPage = PageNames[props["page_index"].Value]
local Colors = {
  Black     = {0,0,0}, --Black
  White     = {255,255,255}, --White
  Green     = {178,255,51}, --Shure Green
  Gray      = {105,105,105}, --Light Gray
  OffGray   = {124,124,124},
  LightBlue = {240,248,255} --Normal Background Color
}
--local ContPins = "Unit Information~"
if CurrentPage == "Control" then
  table.insert(graphics,{
    Type = "GroupBox",
    Fill = Colors.LightBlue,
    CornerRadius = 8,
    StrokeColor = Colors.Black,
    StrokeWidth = 1,
    Position = {10,10},
    Size = {890,590}
  })
  table.insert(graphics,{
    Type = "Text",
    Text = "IP Adress:",
    Position = {25,25},
    Color = Colors.Black,
    Size = {130,15},
    FontSize = 12,
    HTextAlign = "Right"
  })
  table.insert(graphics,{
    Type = "Text",
    Text = "MXA Lobe or CA",
    Position = {25,65},
    Color = Colors.Black,
    Size = {130,15},
    FontSize = 12,
    HTextAlign = "Right"
  })
  table.insert(graphics,{
    Type = "GroupBox",
    Text = "Option",
    Fill = Colors.White,
    CornerRadius = 8,
    StrokeColor = Colors.Black,
    StrokeWidth = 1,
    Position = {535,25},
    Size = {350,170},
    FontSize = 12,
    HTextAlign = "Left"
  })
  table.insert(graphics,{
    Type = "Text",
    Text = "Scale",
    Position = {560,50},
    Color = Colors.Black,
    Size = {130,30},
    FontSize = 12,
    HTextAlign = "Left"
  })
  table.insert(graphics,{
    Type = "Text",
    Text = "Rotale Angle",
    Position = {560,80},
    Color = Colors.Black,
    Size = {130,30},
    FontSize = 12,
    HTextAlign = "Left"
  })
  table.insert(graphics,{
    Type = "Text",
    Text = "XY_Axis ON/OFF",
    Position = {560,125},
    Color = Colors.Black,
    Size = {130,30},
    FontSize = 12,
    HTextAlign = "Left"
  })
  table.insert(graphics,{
    Type = "Text",
    Text = "AutoCaverage Mode",
    Position = {560,155},
    Color = Colors.Black,
    Size = {130,30},
    FontSize = 12,
    HTextAlign = "Left"
  })
  table.insert(graphics,{
    Type = "Text",
    Text = "--Only MXA920",
    Position = {750,155},
    Color = Colors.Black,
    Size = {130,30},
    FontSize = 12,
    HTextAlign = "Left"
  })

  -- System
  layout["IP"] = {
    Style = "Indicator",
    Position = {155,25},
    Size = {130,15},
    Color = Colors.White,
    FontSize = 12,
    HTextAlign = "Center",
    IsReadOnly = false
  }
  layout["Scale"] = {
    PrettyName = "Scale",
    Style = "Text",
    FontSize = 12,
    HTextAlign = "Center",
    Margin = 5,
    Position = {690,50},
    Size = {55,30}
  }
  layout["Angle"] = {
    PrettyName = "Angle",
    Style = "Text",
    FontSize = 12,
    HTextAlign = "Center",
    Margin = 5,
    Position = {690,80},
    Size = {55,30}
  }
  layout["XY_Axis"] = {
    PrettyName = "XY_Axis",
    Style = "Button",
    FontSize = 12,
    Color = Colors.White,
    OffColor = Colors.OffGray,
    UnlinkOffColor = true,
    StrokeWidth = 1,
    Margin = 5,
    Position = {690,125},
    Size = {55,30}
  }
  layout["AutoCaverage"] = {
    PrettyName = "AutoCaverage",
    Style = "Button",
    FontSize = 12,
    Color = Colors.White,
    OffColor = Colors.OffGray,
    UnlinkOffColor = true,
    StrokeWidth = 1,
    Margin = 5,
    Position = {690,155},
    Size = {55,30},
  }
  layout["Image"] = {
    PrettyName = "Image",
    Style = "Button",
    Color = Colors.Black,
    OffColor = Colors.Black,
    UnlinkOffColor = true,
    StrokeWidth = 1,
    Margin = 2,
    Position = {25,80},
    Size = {500,500}
  }
end