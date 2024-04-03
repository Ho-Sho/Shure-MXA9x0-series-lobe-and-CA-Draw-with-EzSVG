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
    Position = {535,65},
    Size = {350,515},
    FontSize = 12,
    HTextAlign = "Left"
  })
  table.insert(graphics,{
    Type = "Text",
    Text = "Scale",
    Position = {560,90},
    Color = Colors.Black,
    Size = {130,30},
    FontSize = 12,
    HTextAlign = "Left"
  })
  table.insert(graphics,{
    Type = "Text",
    Text = "Rotate Angle",
    Position = {560,120},
    Color = Colors.Black,
    Size = {130,30},
    FontSize = 12,
    HTextAlign = "Left"
  })
  table.insert(graphics,{
    Type = "Text",
    Text = "XY_Axis ON/OFF",
    Position = {560,165},
    Color = Colors.Black,
    Size = {130,30},
    FontSize = 12,
    HTextAlign = "Left"
  })
  table.insert(graphics,{
    Type = "Text",
    Text = "AutoCoverage Mode",
    Position = {560,195},
    Color = Colors.Black,
    Size = {130,30},
    FontSize = 12,
    HTextAlign = "Left"
  })
  table.insert(graphics,{
    Type = "Text",
    Text = "--Only MXA920",
    Position = {750,195},
    Color = Colors.Black,
    Size = {130,30},
    FontSize = 12,
    HTextAlign = "Left"
  })
  table.insert(graphics,{
    Type = "Text",
    Text = "Lobe Opacity",
    Position = {555,265},
    Color = Colors.Black,
    Size = {130,30},
    FontSize = 12,
    HTextAlign = "Left"
  })
  table.insert(graphics,{
    Type = "Text",
    Text = "Lobe FillColor",
    Position = {555,295},
    Color = Colors.Black,
    Size = {130,30},
    FontSize = 12,
    HTextAlign = "Left"
  })
  table.insert(graphics,{
    Type = "Text",
    Text = "Lobe Stroke Width",
    Position = {555,325},
    Color = Colors.Black,
    Size = {130,30},
    FontSize = 12,
    HTextAlign = "Left"
  })
  table.insert(graphics,{
    Type = "Text",
    Text = "CA Opacity",
    Position = {555,355},
    Color = Colors.Black,
    Size = {130,30},
    FontSize = 12,
    HTextAlign = "Left"
  })
  table.insert(graphics,{
    Type = "Text",
    Text = "CA FillColor",
    Position = {555,385},
    Color = Colors.Black,
    Size = {130,30},
    FontSize = 12,
    HTextAlign = "Left"
  })
  table.insert(graphics,{
    Type = "Text",
    Text = "CA Dynamic\nStrokeWidth",
    Position = {555,415},
    Color = Colors.Black,
    Size = {130,30},
    FontSize = 12,
    HTextAlign = "Left"
  })
  table.insert(graphics,{
    Type = "Text",
    Text = "CA Dedicated\nStroke Width",
    Position = {555,450},
    Color = Colors.Black,
    Size = {130,30},
    FontSize = 12,
    HTextAlign = "Left"
  })
  table.insert(graphics,{
    Type = "Text",
    Text = "Active Color",
    Position = {555,480},
    Color = Colors.Black,
    Size = {130,30},
    FontSize = 12,
    HTextAlign = "Left"
  })
  table.insert(graphics,{
    Type = "Text",
    Text = "LED Light Color",
    Position = {555,510},
    Color = Colors.Black,
    Size = {130,30},
    FontSize = 12,
    HTextAlign = "Left"
  })
  table.insert(graphics,{
    Type = "Text",
    Text = "--Not control color\n  Appearance only",
    Position = {690,540},
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
  layout["Scale"] = {
    PrettyName = "Scale",
    Style = "Text",
    FontSize = 12,
    HTextAlign = "Center",
    Margin = 5,
    Position = {690,90},
    Size = {55,30}
  }
  layout["Angle"] = {
    PrettyName = "Angle",
    Style = "Text",
    FontSize = 12,
    HTextAlign = "Center",
    Margin = 5,
    Position = {690,120},
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
    Position = {690,165},
    Size = {55,30}
  }
  layout["AutoCoverage"] = {
    PrettyName = "AutoCoverage",
    Style = "Button",
    FontSize = 12,
    Color = Colors.White,
    OffColor = Colors.OffGray,
    UnlinkOffColor = true,
    StrokeWidth = 1,
    Margin = 5,
    Position = {690,195},
    Size = {55,30},
  }
  layout["Lobe_Opacity"] = {
    PrettyName = "Lobe Opacity",
    Style = "Text",
    FontSize = 12,
    HTextAlign = "Center",
    Margin = 5,
    Position = {690,265},
    Size = {55,30}
  }
  layout["Lobe_FillColor"] = {
    PrettyName = "Lobe FillColor",
    Style = "Text",
    FontSize = 12,
    HTextAlign = "Center",
    Margin = 5,
    Position = {690,295},
    Size = {86,30}
  }
  layout["Lobe_StrokeWidth"] = {
    PrettyName = "Lobe StrokeWidth",
    Style = "Text",
    FontSize = 12,
    HTextAlign = "Center",
    Margin = 5,
    Position = {690,325},
    Size = {55,30}
  }
  layout["CA_Opacity"] = {
    PrettyName = "CA Opacity",
    Style = "Text",
    FontSize = 12,
    HTextAlign = "Center",
    Margin = 5,
    Position = {690,355},
    Size = {55,30}
  }
  layout["CA_FillColor"] = {
    PrettyName = "CA FillColor",
    Style = "Text",
    FontSize = 12,
    HTextAlign = "Center",
    Margin = 5,
    Position = {690,385},
    Size = {86,30}
  }
  layout["CA_StrokeWidth"] = {
    PrettyName = "CA Dynamic StrokeWidth",
    Style = "Text",
    FontSize = 12,
    HTextAlign = "Center",
    Margin = 5,
    Position = {690,415},
    Size = {55,30}
  }
  layout["CA_De_StrokeWidth"] = {
    PrettyName = "CA Dedicated StrokeWidth",
    Style = "Text",
    FontSize = 12,
    HTextAlign = "Center",
    Margin = 5,
    Position = {690,450},
    Size = {55,30}
  }
  layout["ActiveColor"] = {
    PrettyName = "Active Color",
    Style = "Text",
    FontSize = 12,
    HTextAlign = "Center",
    Margin = 5,
    Position = {690,480},
    Size = {86,30}
  }
  layout["LEDLightColor"] = {
    PrettyName = "LED Light Color",
    Style = "ComboBox",
    FontSize = 12,
    HTextAlign = "Center",
    Margin = 5,
    Position = {690,510},
    Size = {86,30}
  }
end
