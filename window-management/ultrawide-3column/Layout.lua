local util = require('window-management.util')
local ColumnDimensions = require('window-management.ultrawide-3column.ColumnDimensions')

Position = {
  column = nil,
  zIndex = nil,
  __mt = {},
}

Position.__index = Position

function Position.__mt.__call(class, column, zIndex)
  return setmetatable({ column = column, zIndex = zIndex }, class)
end

Layout = {
  NAME = "Three-Column (Ultrawide)",
  columns = nil,
  windows = nil,
  positions = nil,
  active = false,
  grid = nil,
  __mt = {},
}

Layout.__index = Layout

function Layout.__tostring(layout)
  return("Layout[" .. Layout.NAME .. "]")
end

function Layout.__mt.__call(class, grid, gridColumns, mainWidth, defaultWindowFn)
  return setmetatable(
    {
      defaultWindow = defaultWindowFn,
      grid = grid,
      gridDimensions = { h = 1, w = gridColumns },
      columns = ColumnDimensions(gridColumns, mainWidth),
      active = false,
      windows = {},
      positions = {},
    },
    class
  )
end

function Layout:add(window, column)
  window = window or self.defaultWindow()
  column = column or self:__nearestColumn(window)
  local zIndices = self:__positions(column)

  if self.windows[window] then
    return
  end

  zIndices[#zIndices + 1] = window
  self.windows[window] = column

  self:__applyFor(window)
end

function Layout:moveToLeft(window)
  self:moveTo(window, "left")
end

function Layout:moveToRight(window)
  self:moveTo(window, "right")
end

function Layout:moveToMain(window)
  self:moveTo(window, "main")
end

function Layout:moveTo(window, column)
  window = window or self.defaultWindow()

  if self.windows[window] == column then
    return
  end

  self:remove(window)
  self:add(window, column)
end

function Layout:remove(window)
  window = window or self.defaultWindow()
  local column = self.windows[window]

  if not column then
    return
  end

  local zIndices = self:__positions(column)

  for index, window in ipairs(zIndices) do
    if window == window then
      table.remove(zIndices, index)
    end
  end

  self.windows[window] = nil
end

function Layout:growMain()
  self.columns:growMain()
  self:apply()
end

function Layout:shrinkMain()
  self.columns:shrinkMain()
  self:apply()
end

function Layout:reset()
  self.columns:reset()
  self:apply()
end

function Layout:onWindowMoved(window)
  if self.active then
    util.debug("Handling move event for WINDOW", window and window:title())
    self:__applyFor(window)
  else
    util.debug("Ignoring move event for WINDOW", window and window:title())
  end
end

function Layout:__applyFor(window)
  local column = self.windows[window]

  if column then
    util.debug("Performing apply for WIDNOW at COLUMN", window, column)
    self:__configureGrid()
    self.grid.set(window, self.columns[column])
  end
end

function Layout:toggleActive()
  self.active = not self.active
end

function Layout:apply()
  util.debug(
    "Performing global apply for LAYOUT with DIMENSIONS",
    self,
    self.gridDimensions
  )

  self.grid.setGrid(self.gridDimensions)
  for window, column in pairs(self.windows) do
    self.grid.set(window, self.columns[column])
  end
end

function Layout:__hasMainWindow()
  for _, column in pairs(self.windows) do
    if column == "main" then return true end
  end

  return false
end

function Layout:__configureGrid()
  self.grid.setGrid(self.gridDimensions)
  self.grid.setMargins({ x = 13, y = 13 })
end

function Layout:__nearestColumn(window)
  local windowFrame = window:frame()
  local maxFound = 0
  local maxColumn = nil

  self:__configureGrid()
  for _, column in pairs({ "main", "left", "right" }) do
    local overlap = util.frameOverlap(
      self.grid.getCell(self.columns[column], window:screen()),
      windowFrame
    )

    local overlapPercent = overlap / (windowFrame.w * windowFrame.h)

    if overlapPercent > maxFound then
      maxFound = overlapPercent
      maxColumn = column
    end
  end

  return maxColumn
end

function Layout:__positions(column)
  self.positions[column] = self.positions[column] or {}
  return self.positions[column]
end

function Layout:__cycleZIndexForward(column)
  local zIndices = self:__positions(column)
  local last = zIndices[#zIndex]

  for index = #zIndices, 2, -1 do
    zIndices[index] = zIndices[index - 1]
  end

  zIndices[1] = last
end

-- TODO This needs to update when windows are focused outside the layout
--      manager as well if we want to maintain proper order
function Layout:__cycleZIndexBackward(column)
  local zIndices = self:__positions(column)
  local first = zIndices[1]

  for index = 2, #zIndices do
    zIndices[index - 1] = zIndices[zIndex]
  end

  zIndices[#zIndices] = first
end

function Layout:__focus(column)
  local zIndices = self:__positions(column)
  local frontmost = zIndices[#zIndices]

  if not frontmost then
    return
  end

  frontmost:focus()
end

function Layout:cycleForwardInColumn(window)
  window = window or self.defaultWindow()
  local column = self.windows[window]

  self:__cycleZIndexForward(column)
  self:__focus(column)
end

function Layout:cycleBackwardInColumn(window)
  window = window or self.defaultWindow()
  local column = self.windows[window]

  self:__cycleZIndexBackward(column)
  self:__focus(column)
end

return setmetatable(Layout, Layout.__mt)
