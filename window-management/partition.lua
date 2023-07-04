Partition = {
  grid = nil,
  dimensions = nil,
  children = nil,
  windows = nil,
  splitBy = nil,
  placeNext = nil,
  __DEBUG = false,
  SPLITS = {
    VERTICAL = "vertical",
    HORIZONTAL = "horizonal",
  },
}

Partition.__index = Partition

local function debug(message)
  if Partition.__DEBUG then
    print(message)
  end
end

function Partition:new(grid, dimensions, splitBy, windows)
  local this = {}
  setmetatable(this, Partition)

  this.grid = grid
  this.dimensions = dimensions
  this.splitBy = splitBy
  this.children = {}
  this.windows = windows or {}
  this.onDestroy = {}

  return this
end

--- Add a window to be managed by this partition
function Partition:add(window)
  if self:isParent() then
    self:__addToChildren(window)
  else
    self.windows[#self.windows + 1] = window
    -- TODO Subscribe to window events
  end

  self:apply()
end

function Partition:remove(window)
  -- TODO Need to handle case where removing a window leaves this partition
  -- empty
  if self:isParent() then
    for _, child in pairs(self.children) do
      child:remove(window)

      if #child:getWindows() == 0 then
        self:__removeChild(child)
      end
    end
  else
    for index, parititionWindow in pairs(self.windows) do
      if parititionWindow == window then
        self.windows[index] = nil
      end
    end
    -- TODO Unsubscribe window
  end
end

function Partition:split(window)
  -- Move all windows to an initial child partition the first time we split
  if #self.children == 0 then
    self:__addChild(self.windows)
    self.windows = {}
  end

  -- Remove the window if its already managed by a child partition
  if self:getPartitionFor(window) then
    self:remove(window)
  end

  self.__addChild({ window })
  self.placeNext = 1
end

function Partition:merge()
  if #self.children == 0 then
    return
  end

  local last = self.children[#self.children]
  local newLast = self.children[#self.children - 1]

  for _, window in pairs(last:getWindows()) do
    newLast:add(window)
  end

  table.remove(self.children, #self.children)
  self:__unsplitMaybe()
end

function Partition:getPartitionFor(window)
  return (
    self:__findWindowInWindows(window) or self:__findWindowInChildren(window)
  )
end

function Partition:isAncestorOf(partition)
  for _, child in pairs(self.children) do
    if child == partition or child:isAncestorOf(partition) then
      return true
    end
  end

  return false
end

function Partition:getWindows()
  if #self.windows > 0 then
    debug("getWindows: Returning partition windows")
    return self.windows
  else
    debug("getWindows: Returning child windows")

    local allWindows = {}
    for _, child in pairs(self.children) do
      for _, window in pairs(child:getWindows()) do
        allWindows[#allWindows+1] = window
      end
    end

    return allWindows
  end
end

function Partition:updateDimensions(dimensions)
  self.dimensions = dimensions
  self:updateChildDimensions()
  self:apply()
end

function Partition:updateChildDimensions()
  local positionBy = "x"
  local sizeBy = "w"

  if self.splitBy == "vertical" then
    positionBy = "y"
    sizeBy = "h"
  end

  local unit = math.floor(self.dimensions[sizeBy] / #self.children)

  local function newDimensions(index)
    local updated = { table.unpack(self.dimensions) }
    updated[sizeBy] = unit
    updated[positionBy] = self.dimensions[positionBy] + (unit * (index - 1))

    return updated
  end

  for index, child in self.children do
    child:updateDimensions(newDimensions(index))
  end
end

function Partition:isParent()
  return #self.children > 0
end

function Partition:apply()
  debug("Applying partition: " .. self:__repr())
  for _, window in pairs(self.windows) do
    debug("Setting window " .. window:id() .. " to " .. self:__dimensionStr())
    self.grid.set(window, self.dimensions)
  end

  for _, child in pairs(self.children) do
    child:apply()
  end
end

function Partition:destroy(parent)
  for _, handler in pairs(self.onDestroy) do
    handler(parent)
  end
end

function Partition:__findWindowInWindows(window)
  for _, windowInPartition in pairs(self.windows) do
    if window == windowInPartition then
      return self
    end
  end
end

function Partition:__findWindowInChildren(window)
  for _, child in pairs(self.children) do
    local childWithWindow = child:getPartitionFor(window)
    if childWithWindow then
      return childWithWindow
    end
  end
end

function Partition:__addChild(windows)
  if not self.splitBy then
    error("Cannot split partition: No split direction defined! Partition: " .. self:__repr())
  end

  self.children[#self.children + 1] = Partition:new(
    self.grid,
    self.dimensions,
    (self.splitBy == "horizontal" and "vertical") or "horizontal",
    windows or {}
  )

  self:apply()
end

function Partition:__removeChild(partition)
  for index, child in pairs(self.children) do
    if partition == child then
      table.remove(self.children, index)
    end
  end
end

function Partition:__unsplitMaybe()
  if #self.children > 1 then
    return
  end

  -- TODO Need to handle any subscription changes here as well
  self.windows = self.children[1].windows
  self.children = {}
end

function Partition:__addToChildren(window)
  self.children[self.placeNext]:add(window)
  self.placeNext = (self.placeNext + 1) % #self.children
end

function Partition:__repr()
  return "Partition["
    .. "windows: " .. #self.windows .. ", "
    .. "children: " .. #self.children .. ", "
    .. "dimensions:" .. self:__dimensionStr()
    .. "]"
end

function Partition:__dimensionStr()
  return "{ "
    .. "x: " .. self.dimensions.x .. ", "
    .. "y: " .. self.dimensions.y .. ", "
    .. "w: " .. self.dimensions.w .. ", "
    .. "h: " .. self.dimensions.h .. ", "
    .. "}"
end

return Partition
