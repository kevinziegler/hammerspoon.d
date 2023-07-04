Partition = require('window-management.partition')

LayoutUltrawide = {
  columns = {},
  __DEBUG = true,
}

local function debug(message, ...)
  local values = { ... }
  if LayoutUltrawide.__DEBUG then
    for key, value in pairs(values) do
      message = message .. " " .. key .. ": " .. hs.inspect(value)
    end
    print(message)
  end
end

local function initializeColumns(grid, gridDimensions, mainWidth)
  local sideWidth = (gridDimensions.w - mainWidth) / 2
  return {
    main = Partition:new(
      grid,
      { x = sideWidth, y = 0, h = gridDimensions.h, w = mainWidth },
      Partition.SPLITS.VERTICAL
    ),

    left = Partition:new(
      grid,
      { x = 0, y = 0, h = gridDimensions.h, w = sideWidth },
      Partition.SPLITS.VERTICAL
    ),

    right = Partition:new(
      grid,
      { x = sideWidth + mainWidth, y = 0, h = gridDimensions.h, w = sideWidth },
      Partition.SPLITS.VERTICAL
    ),

    center = Partition:new(
      grid,
      {
        x = gridDimensions.w * 0.2,
        y = gridDimensions.h * 0.2,
        w = gridDimensions.w * 0.6,
        h = gridDimensions.h * 0.6,
      },
      Partition.SPLITS.VERTICAL
    ),
  }

end

LayoutUltrawide.__index = LayoutUltrawide

function LayoutUltrawide:new(hs, grid, gridDimensions, mainWidth)
  local obj = {}
  setmetatable(obj, LayoutUltrawide)

  obj.hs = hs
  obj.grid = grid
  obj.grid.setGrid(gridDimensions)
  obj.grid.setMargins({x = 10, y = 10})

  obj.columns = initializeColumns(grid, gridDimensions, mainWidth)

  obj.returnFromCenter = {}

  return obj
end

function LayoutUltrawide:apply()
  for _, column in self.columns do
    column:apply()
  end
end

function LayoutUltrawide:__addTo(partition, window)
  local current = self:__partitionFor(window)
  if current then
    current:remove(window)
  end

  debug("Adding window to partition: ", self.hs.inspect(window), partition:__repr())

  partition:add(window)
end

function LayoutUltrawide:__partitionFor(window)
  local column = self:__columnFor(window)

  if column then
    return column:getPartitionFor(window)
  end
end

function LayoutUltrawide:__columnFor(window)
  for _, column in pairs(self.columns) do
    if column:getPartitionFor(window) then
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
  self:__addTo(self.columns.left, window)
end

function LayoutUltrawide:moveRight(window)
  self:__addTo(self.columns.right, window)
end

function LayoutUltrawide:swapSide(window)
  local current = self:__columnFor(window)
  local destination = self.columns.left

  if current == self.columns.left then
    destination = self.columns.right
  end

  if current then
    current:remove(window)
  end

  destination:add(window)
end

-- function LayoutUltrawide:moveForward(window)
--   error("NOT IMPLEMENTED!")
-- end

-- function LayoutUltrawide:moveBackward(window)
--   error("NOT IMPLEMENTED!")
-- end

function LayoutUltrawide:center(window)
  self.returnFromCenter[window] = self:__partitionFor(window)
  self:__addTo(self.columns.center, window)
end

function LayoutUltrawide:uncenter()
  -- TODO Does this fail if the partition gets destroyed between when we center
  --      the window and then try to pop the window back to place?
  for _, window in pairs(self.columns.center:getWindows()) do
    self:__addTo(
      self.returnFromCenter[window] or self.columns.right,
      window
    )

    self.returnFromCenter[window] = nil
  end

  self.returnFromCenter = {}
end

function LayoutUltrawide:captureScreen()
  -- TODO Exclude windows like the Hammerspoon console that force themselves
  --      to the front
  local addToNext = self.columns.left

  if #self.columns.main:getWindows() == 0 then
    debug("Adding window to main", self.hs.window.focusedWindow())
    self.columns.main:add(self.hs.window.focusedWindow())
  end

  for _, window in pairs(self.hs.window.allWindows()) do
    debug("Capturing window: ", window)

    if not self:__partitionFor(window) then
      self:__addTo(addToNext, window)
      if addToNext == self.columns.left then
        addToNext = self.columns.right
      else
        addToNext = self.columns.left
      end
    end
  end
end


return LayoutUltrawide
