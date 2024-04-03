table.insert(ctrls, {
  Name = "Image",
  ControlType = "Button",
  ButtonType = "Toggle",
  PinStyle = "Both",
  Count = 1,
  UserPin = true
})
table.insert(ctrls, {
  Name = "DocSize",
  ControlType = "Knob",
  ControlUnit = "Float",
  Min = 100,
  Max = 3200,
  DefaultValue = 3048,
  PinStyle = "Input",
  Count = 1,
  UserPin = true
})
table.insert(ctrls, {
  Name = "IP",
  ControlType = "Text",
  PinStyle = "Both",
  Count = 1,
  UserPin = true
})
-- table.insert(ctrls, {
--   Name = "Port",
--   ControlType = "Indicator",
--   ButtonType = "Text",
--   DefaultValue = 2202,
--   PinStyle = "Both",
--   Count = 1,
--   UserPin = false,
-- })
table.insert(ctrls, {
  Name = "AutoCoverage",
  ControlType = "Button",
  ButtonType = "Toggle",
  PinStyle = "Both",
  Count = 1,
  UserPin = true,
  DefaultValue = "CA OFF"
})
table.insert(ctrls, {
  Name = "Scale",
  ControlType = "Knob",
  ControlUnit = "Float",
  Min = 1,
  Max = 5,
  DefaultValue = 2.5,
  PinStyle = "Input",
  Count = 1,
  UserPin = true
})
table.insert(ctrls, {
  Name = "Angle",
  ControlType = "Knob",
  ControlUnit = "Integer",
  Min = -360,
  Max = 360,
  DefaultValue = 0,
  PinStyle = "Both",
  Count = 1,
  UserPin = true
})
table.insert(ctrls, {
  Name = "XY_Axis",
  ControlType = "Button",
  ButtonType = "Toggle",
  PinStyle = "Both",
  Count = 1,
  UserPin = true,
  DefaultValue = "OFF"
})
table.insert(ctrls, {
  Name = "Lobe_Opacity",
  ControlType = "Knob",
  ControlUnit = "Float",
  Min = 0,
  Max = 1,
  DefaultValue = 0.15,
  PinStyle = "Both",
  Count = 1,
  UserPin = true
})
table.insert(ctrls, {
  Name = "Lobe_FillColor",
  ControlType = "Text",
  PinStyle = "Both",
  Count = 1,
  UserPin = true
})
table.insert(ctrls, {
  Name = "Lobe_StrokeWidth",
  ControlType = "Knob",
  ControlUnit = "Integer",
  Min = 5,
  Max = 50,
  DefaultValue = 20,
  PinStyle = "Both",
  Count = 1,
  UserPin = true
})
table.insert(ctrls, {
  Name = "CA_Opacity",
  ControlType = "Knob",
  ControlUnit = "Float",
  Min = 0,
  Max = 1,
  DefaultValue = 0.15,
  PinStyle = "Both",
  Count = 1,
  UserPin = true
})
table.insert(ctrls, {
  Name = "CA_StrokeWidth",
  ControlType = "Knob",
  ControlUnit = "Integer",
  Min = 5,
  Max = 50,
  DefaultValue = 20,
  PinStyle = "Both",
  Count = 1,
  UserPin = true
})
table.insert(ctrls, {
  Name = "CA_De_StrokeWidth",
  ControlType = "Knob",
  ControlUnit = "Integer",
  Min = 5,
  Max = 50,
  DefaultValue = 20,
  PinStyle = "Both",
  Count = 1,
  UserPin = true
})
table.insert(ctrls, {
  Name = "CA_FillColor",
  ControlType = "Text",
  PinStyle = "Both",
  Count = 1,
  UserPin = true
})
table.insert(ctrls, {
  Name = "ActiveColor",
  ControlType = "Text",
  PinStyle = "Both",
  Count = 1,
  UserPin = true
})
table.insert(ctrls, {
  Name = "LEDLightColor",
  ControlType = "Text",
  PinStyle = "Both",
  Count = 1,
  UserPin = true
})
