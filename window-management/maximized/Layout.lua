Layout = {
  NAME = "Maximized",
  windows = {},
  active = false,
  maximizedUnitRect = { 0.01, 0.01, 0.98, 0.98 },
  __mt = {},
}

function Layout.__mt.__call(class)
  return setmetatable({ windows = {}, active = false }, class)
end

Layout.__index = Layout

function Layout:makeActive()
  self.active = true
  self:apply()
  return self
end

function Layout:makePassive()
  self.active = false
  return self
end

function Layout:add(window)
  self:remove(window)
  self.windows[#self.windows + 1] = window

  self:apply()
end

function Layout:remove(window)
  for index, managed in pairs(self.windows) do
    if window == managed then
      table.remove(self.windows, index)
    end
  end
end

function Layout:apply()
  for _, window in pairs(self.windows) do
    window:move(self.maximizedUnitRect)
  end
end

function Layout:onWindowMoved(window)
  if self.active then
    self:apply()
  end
end

return Layout
