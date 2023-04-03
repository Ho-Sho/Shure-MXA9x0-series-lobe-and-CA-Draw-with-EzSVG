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
  Name = "AutoCaverage",
  ControlType = "Button",
  ButtonType = "Toggle",
  PinStyle = "Both",
  Count = 1,
  UserPin = true
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
  UserPin = true
})