--- @class DashboardConfiguration
--- @field active boolean
--- @field centerOnFocus boolean
--- @field centerPosition table|nil
local DashboardConfiguration = {
  active = false,
  centerOnFocus = false,
  centerPosition = nil,
  __mt = {},
}

DashboardConfiguration.__index = DashboardConfiguration

function DashboardConfiguration:setActive(bool)
  return self:__setField('active', bool)
end

function DashboardConfiguration:setCenterOnFocus(bool)
  return self:__setField('centerOnFocus', bool)
end

function DashboardConfiguration:setCenterPosition(positioning)
  return self:__setField('centerPosition', positioning)
end

function DashboardConfiguration:setMaxWidth(width)
  return self:__setField('maxWidth', width)
end

function DashboardConfiguration:setPercentStickness(stickness)
  return self:__setField('stickiness', stickiness)
end

function DashboardConfiguration:__setField(field, value)
  self[field] = value
  return self
end

return DashboardConfiguration
