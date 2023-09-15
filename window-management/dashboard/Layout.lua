local util = require('window-management.util')

local function equalDimensions(dimensions1, dimensions2)
  return dimensions1.h == dimensions2.h and dimensions1.w == dimensions1.w
end

--- @class Dashboard
--- @field grid hs.grid Reference to the Hammerspoon grid module
Dashboard = {
  NAME = "Dashboard",
  grid = nil,
  configuration = nil,
  windows = {},
  focused = nil,
  pinned = nil,
  active = false,
  __nullCell = { x = -100, y = -100, w = 0, h = 0 },
  __mt = {}
}

Dashboard.__index = Dashboard

--- Create a new dashboard Dashboard layout instance
---
--- @param hsGrid hs.grid The hammerspoon global object
--- @param configuration DashboardConfiguration The layout configuration
function Dashboard.__mt.__call(class, hsGrid, configuration)
  return setmetatable(
    {
      grid = hsGrid,
      windows = {},
      configuration = configuration
    },
    class
  )
end

--- Add a window to this layout instance
---
--- New windows are added to the end of the dashboard
---
--- @param window hs.window The window to add
function Dashboard:add(window)
  local managed = self:__windowPosition(window)
  local initialDimensions = self:__dimensions()

  if managed then
    return false
  end

  self.windows[#self.windows + 1] = window

  if equalDimensions(self:__dimensions(), initialDimensions) then
    self:__applyFor(window, #self.windows)
  else
    self:apply()
  end

  return true
end

function Dashboard:remove(window)
  local index = self:__windowPosition(window)
  local initialDimensions = self:__dimensions()

  if index then
    table.remove(self.windows, index)
  end

  if not equalDimensions(self:__dimensions(), initialDimensions) then
    self:apply()
  end
end

--- Apply the window sizes/positions specified for this layout
---
--- If the `windowSet` parameter is specified, then only windows in windowSet
--- will be updated, unless the layout is operataing in 'active' mode.  If the
--- layout is in 'active' mode, then all windows managed by the layout will be
--- be updated.
function Dashboard:apply()
  self.grid.setGrid(self:__dimensions())

  for position, window in ipairs(self.windows) do
    self:__applyFor(window, position)
  end
end

function Dashboard:__applyFor(window, position)
  position = position or self:__windowPosition(window)

  local cell = self:__cellAt(position)
  util.debug("Setting WINDOW in POSITION: ", window:title(), position)

  if self:__isValid(cell) then
    self.grid.set(window, cell)
  else
    util.debug("Invalid position for WINDOW: ", window:title())
  end
end

function Dashboard:onWindowMoved(window)
  if not self:add(window) and self.active then
    self:apply()
  end
end

--- Set the curent layout to be 'active'
---
--- As an active layout, this layout will always update its managed windows,
--- assuming that actions to move/resize windows outside this layout should be
--- overridden
function Dashboard:makeActive()
  self.active = true
  self:apply()
end

--- Disable the 'active' mode for this layout
function Dashboard:makePassive()
  self.active = false
  self:apply()
end

--- Center a window on the screen
---
--- The window will also be added to the table of windows managed by the layout
--- if it was not already managed.
function Dashboard:center()
end

function Dashboard:uncenter()
end

--- Move the specified window to a cell determined by directionFn, if valid
---
--- Note that the cell produced by applying vector may be invalid (out of
--- bounds) for the current grid.  If this is the case then no changes will
--- be applied.  Also, due to hs.grid conventions, the y-axis is inverted - a
--- positive y value will move a window lower on the screen, and vice-versa.
---
--- @param window hs.window The window to move
--- @param vector table Vecor of x,y deltas for the cell position
function Dashboard:__move(window, vector)
  local currentPosition = self:__windowPosition(window)
  local cell = self:__cellAt(currentPosition)
  cell.x = cell.x + (vector.x or 0)
  cell.y = cell.y + (vector.y or 0)

  local newPosition = self:__positionFor(cell)

  if currentPosition and newPosition and self:__isValid(cell) then
    self:__swapPositions(currentPosition, newPosition)
    -- TODO Re-apply layout after swap
  end
end

--- Check if a cell is valid for the layout's current grid dimensions
---
--- @param cell table The cell to check
--- @return boolean True if the cell is valid in the grid, false otherwise
function Dashboard:__isValid(cell)
  local dimensions = self:__dimensions()

  return cell
    and cell.x >= 0
    and cell.y >= 0
    and cell.x <= dimensions.w
    and cell.y <= dimensions.h
end

function Dashboard:__positionFor(cell)
  local dimensions = self:__dimensions()
  local position =  cell.x + (cell.y * dimensions.w)

  if cell.y < 0 or cell.y >= dimensions.h then
    return nil
  end

  if position > #self.windows then
    return #self.windows
  end

  return position
end

--- Given a position, return the hs.grid cell for that position
---
--- The supplied position index should be a valid index into the list of
--- windows managed by this layout.  If the supplied position is invalid, then
--- an always-invalid 'null' cell will be returned instead
---
--- @param position integer|nil The position index
--- @return table The cell to represent this position in the layout's grid
function Dashboard:__cellAt(position)
  local dimensions = self:__dimensions()

  if not self.windows[position] then
    return self.__nullCell
  end

  return {
    x = math.floor((position - 1) % dimensions.w),
    y = math.floor((position - 1) / dimensions.w),
    w = 1,
    h = 1,
  }
end

--- Get the current grid dimensions for this layout
---
--- The size of the grid is determined by the number of windows managed by the
--- layout, with each window occupying a single 1x1 cell in the grid.
---
--- @return table the geometry of the grid
function Dashboard:__dimensions()
  local base = math.sqrt(#self.windows)
  local height = math.floor(base)
  local width = math.ceil(base)

  return {
    h = (height * width >= #self.windows) and height or height + 1,
    w = width
  }
end

--- Get the position index of a window in the layout
---
--- This position is the index looking at the list of managed windows.  If the
--- queried window is not managed in the layout, nil is returned instead.
---
--- @param window hs.window The window to find in the list
--- @return number|nil The position index for the window
function Dashboard:__windowPosition(window)
  for position, managedWindow in pairs(self.windows) do
    if window == managedWindow then
      return position
    end
  end

  return nil
end

--- Swap the windows at the two supplied positions in the layout
---
--- Both positions should be valid indices for the table of windows managed by
--- this layout.
---
--- @param position1 integer The first position to swap
--- @param position2 integer The second position to swap
function Dashboard:__swapPositions(position1, position2)
  local window1 = self.windows[position1]
  local window2 = self.windows[position2]

  if not window1 or not window2 then
    print("WARNING: Attempt to swap windows with 1 or more invalid positions!")
    return
  end

  self.windows[position1] = window2
  self.windows[position2] = window1

  self:apply()
end

function Dashboard:__updateToGrid()
  local centered = self:__centeredWindow()
  local updates = {}
  local stickiness = self.configuration.stickiness

  for position, window in pairs(self.windows) do
    updates[window] = window ~= centered
      and self:__windowAreaInCell(window, position) >= stickiness
  end

  return updates
end

function Dashboard:__windowAreaInCell(window, position)
  local cell = self.grid.getCell(self:__cellAt(position), window:screen())
  local windowFrame = window:frame()

  return util.frameOverlap(cell, windowFrame) / (windowFrame.w * windowFrame.h)
end

function Dashboard:__centeredWindow()
  return self.pinned or (self.configuration.centerOnFocus and self.focused)
end

function Dashboard:onFocusChanged(window)
  local wasFocused = self.focused
  if self.configuration.centerOnFocus then
    self.focused = window
  end

  self:__applyFor(window)

  if wasFocused then
    self:__applyFor(wasFocused)
  end
end

return setmetatable(Dashboard, Dashboard.__mt)
