LayoutSideColumn = {
  NAME = "Two-Column Sidecar",
  main = {},
  side = {},
  grid = nil,
  rows = 0,
  columns = 0,
  mainWidth = 0,
  centered = nil,
  __mt = {},
}

LayoutSideColumn.__index = LayoutSideColumn

function LayoutSideColumn.__mt.__call(class, hsGrid, rows, columns, mainWidth)
  return setmetatable(
    {
      grid = hsGrid,
      rows = rows,
      columns = columns,
      mainWidth = mainWidth,
      main = {},
      side = {},
    },
    class
  )
end

function LayoutSideColumn:growMain()
  self.mainWidth = math.min(self.mainWidth + 1, self.columns - 1)
end

function LayoutSideColumn:shrinkMain()
  self.mainWidth = math.max(self.mainWidth - 1, 1)
end

function LayoutSideColumn:add(window)
  if self:__mainIndex(window) or self:__sideIndex(window) then
    return
  end

  if #self.main == 0 then
    self.main[1] = window
  else
    self.side[#self.side+1] = window
  end

  self:apply()
end

function LayoutSideColumn:moveToMain(window)
  self:remove(window)
  self.main[#self.main + 1] = window

  self:apply()
end

function LayoutSideColumn:moveToRight(window)
  self:remove(window)
  self.side[#self.main + 1] = window

  self:apply()
end

function LayoutSideColumn:__mainIndex(window)
  for index, managed in pairs(self.main) do
    if managed == window then return index end
  end

  return nil
end

function LayoutSideColumn:__sideIndex(window)
  for index, managed in pairs(self.side) do
    if managed == window then return index end
  end

  return nil
end

function LayoutSideColumn:center(window)
  self:add(window)
  if self:__mainIndex(window) then return end
  self.centered = window
end

function LayoutSideColumn:remove(window)
  local index = self:__mainIndex(window)

  if index then
    table.remove(self.main, index)
    return true
  end

  index = self:__sideIndex(window)

  if index then
    table.remove(self.side, index)
    return true
  end

  return false
end

function LayoutSideColumn:addRow()
  self.rows = self.rows + 1
  self:apply()
end

function LayoutSideColumn:removeRow()
  self.rows = math.max(1, self.rows - 1)
  self:apply()
end

function LayoutSideColumn:apply()
  self.grid.setGrid({ x = 0, y = 0, w = self.columns, h = self.rows })

  for _, window in pairs(self.main) do
    self.grid.set(window, self:__mainColumnDimensions())
  end

  for index, window in pairs(self.side) do
    if self.centered == window then
      window:moveToUnit({0.1, 0.1, 0.8, 0.8})
    else
      self.grid.set(window, self:__sideColumnDimensions((index - 1) % self.rows))
    end
  end
end

function LayoutSideColumn:__sideColumnDimensions(row)
  return { x = self.mainWidth, y = row, h = 1, w = self.columns - self.mainWidth }
end

function LayoutSideColumn:__mainColumnDimensions()
  return { x = 0, y = 0, h = self.rows, w = self.mainWidth }
end

return setmetatable(LayoutSideColumn, LayoutSideColumn.__mt)
