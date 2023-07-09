local debug = require('window-management.util').debug

Partition = require('window-management.partition')

LayoutUltrawide = {
  columns = {},
  defaultCells = {},
  addToNext = nil,
  active = nil
}

LayoutUltrawide.__index = LayoutUltrawide

local function initializeCells(gridDimensions, mainWidth)
  local sideWidth = (gridDimensions.w - mainWidth) / 2

  return {
    main = {
      x = sideWidth,
      y = 0,
      h = gridDimensions.h,
      w = mainWidth
    },

    left = {
      x = 0,
      y = 0,
      h = gridDimensions.h,
      w = sideWidth
    },

    right = {
      x = sideWidth + mainWidth,
      y = 0,
      h = gridDimensions.h,
      w = sideWidth
    },

    center = {
      x = gridDimensions.w * 0.2,
      y = gridDimensions.h * 0.2,
      w = gridDimensions.w * 0.6,
      h = gridDimensions.h * 0.6,
    }
  }
end
  }

end


function LayoutUltrawide:new(hs, grid, gridDimensions, mainWidth)
  local obj = {}
  setmetatable(obj, LayoutUltrawide)

  obj.hs = hs
  obj.grid = grid
  obj.grid.setGrid(gridDimensions)
  obj.grid.setMargins({x = 10, y = 10})
  obj.defaultCells = initializeCells(gridDimensions, mainWidth)

  obj.columns = {
    main = Partition:new(grid, obj.defaultCells.main, "Main"),
    left = Partition:new(grid, obj.defaultCells.left, "Left"),
    right = Partition:new(grid, obj.defaultCells.right, "Right"),
    center = Partition:new(grid, obj.defaultCells.center, "Center"),
  }

  obj.addToNext = obj.columns.left
  obj.returnFromCenter = {}

  return obj
end

function LayoutUltrawide:apply()
  debug("Applying layout (ultrawide)")
  for _, column in pairs(self.columns) do
    column:apply()
  end
end

function LayoutUltrawide:__addTo(partition, window)
  local current = self:__partitionFor(window)
  if current then
    debug("Removing window for move", { window = window, current = current })
    current:remove(window)
  end

  debug("Adding window to partition", {window = window, partition = partition})
  partition:add(window)
end

function LayoutUltrawide:__partitionFor(window)
  local column = self:__columnFor(window)
  return column
end

function LayoutUltrawide:__columnFor(window)
  for _, column in pairs(self.columns) do
    if column:has(window) then
      return column
    end
  end
end

function LayoutUltrawide:promoteToMain(window)
  self:__addTo(self.columns.main, window)
end

-- Remove all but front-most window from main column
function LayoutUltrawide:redistributeMain()
  error("LayoutUltrawide:redistributeMain: NOT IMPLEMENTED")
end

function LayoutUltrawide:moveLeft(window)
  debug("Move window to left column", { window = window })
  self:__addTo(self.columns.left, window)
end

function LayoutUltrawide:moveRight(window)
  debug("Move window to right column", { window = window })
  self:__addTo(self.columns.right, window)
end

function LayoutUltrawide:swapSide(window)
  debug("Swap window column", { window = window })
  self:__addTo(self:__alternate(self:__columnFor(window)), window)
end

function LayoutUltrawide:center(window)
  debug("Centering window", { window = window })
  self.returnFromCenter[window] = self:__partitionFor(window)
  self:__addTo(self.columns.center, window)
end

function LayoutUltrawide:uncenter()
  debug("Uncentering windows in layout")
  for _, window in pairs(self.columns.center:getWindows()) do
    self:__addTo(self.returnFromCenter[window] or self.columns.right, window)
  end

  self.returnFromCenter = {}
end

function LayoutUltrawide:add(window)
  if self:__partitionFor(window) then
    debug(
      "Attempted to add already-managed window to layout",
      { window = window, currentPartition = self:__partitionFor(window) })
    return
  end

  debug("Adding window to layout: ", {window = window})

  if #self.columns.main:getWindows() == 0 then
    debug("Adding window to main", {window = window})
    self:__addTo(self.columns.main, window)
  else
    debug("Adding window to column", {window = window, column=self.addToNext})
    self:__addTo(self.addToNext, window)
    self.addToNext = self:__alternate(self.addToNext)
  end

end
function LayoutUltrawide:__alternate(column)
  if column == self.columns.left then
    return self.columns.right
  else
    return self.columns.left
  end
end

function LayoutUltrawide:captureScreen()
  debug("Capturing windows in screen")
  -- TODO Exclude windows like the Hammerspoon console that force themselves
  --      to the front
  if #self.columns.main:getWindows() == 0 then
    debug("Adding window to main", { window = self.hs.window.focusedWindow() })
    self.columns.main:add(self.hs.window.focusedWindow())
  end

  for _, window in pairs(self.hs.window.allWindows()) do
    debug("Capturing window to column", {window = window})
    self:add(window)
  end
end

function LayoutUltrawide:growMain()
  debug("Growing main column dimensions")
  self.columns.left.dimensions.w = self.columns.left.dimensions.w - 1
  self.columns.main.dimensions.w = self.columns.main.dimensions.w + 2
  self.columns.right.dimensions.w = self.columns.right.dimensions.w - 1

  self.columns.main.dimensions.x = self.columns.main.dimensions.x - 1
  self.columns.right.dimensions.x = self.columns.right.dimensions.x + 1

  self:apply()
end

function LayoutUltrawide:shrinkMain()
  debug("Shrinking main column dimensions")
  self.columns.left.dimensions.w = self.columns.left.dimensions.w + 1
  self.columns.main.dimensions.w = self.columns.main.dimensions.w - 2
  self.columns.right.dimensions.w = self.columns.right.dimensions.w + 1

  self.columns.main.dimensions.x = self.columns.main.dimensions.x + 1
  self.columns.right.dimensions.x = self.columns.right.dimensions.x - 1

  self:apply()
end

function LayoutUltrawide:reset()
  self.columns.main.dimensions = self.defaultCells.main
  self.columns.left.dimensions = self.defaultCells.left
  self.columns.right.dimensions = self.defaultCells.right
  self.columns.center.dimensions = self.defaultCells.center

  self:apply()
end

return LayoutUltrawide
