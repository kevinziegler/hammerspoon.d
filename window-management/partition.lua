--- A sub-division of an hs.grid, possibly containing child Partitions
--- @class Partition
--- @field grid|nil hs.grid
--- @field dimensions hs.geometry The dimensions of the partition in the grid
--- @field windows table The windows managed by this partition
--- @field maxChildren number The limit of direct children for this partition
Partition = {
  grid = nil,
  dimensions = {},
  windows = {},
  placeNext = nil,
  __DEBUG = false,
}

Partition.__index = Partition

local debug = require('window-management.util').debug

local function copyTable(tableToCopy)
  local copy = {}

  for key, value in pairs(tableToCopy) do
    copy[key] = value
  end

  return copy
end


--- Create a new Partition instance
---
--- @param grid hs.grid The grid instance to bind to
--- @param dimensions hs.geometry The absolute grid dimensions of the partition
--- @param name string A human-readable name for the partition
--- @return Partition
function Partition:new(grid, dimensions, name)
  local this = {}
  setmetatable(this, Partition)

  this.name = name
  this.grid = grid
  this.dimensions = copyTable(dimensions)
  this.windows = {}

  return this
end

--- Add a window to be managed by this partition
---
--- The window may be added to either the current partition itself, or to one of
--- its children, based on the partition's internal logic.  After the window is
--- added, all windows in this partition are resized to the grid dimensions
--- specified by the partition that owns that window directly.
---
--- @param window hs.window The window to add to this partition
function Partition:add(window)
  self.windows[#self.windows + 1] = window
  self:apply()
end

--- Remove a window from the current partition or of its descendants
---
--- @param window hs.window The window to remove from this partition
function Partition:remove(window)
  for index, parititionWindow in pairs(self.windows) do
    if parititionWindow == window then
      debug("Removing window", { partition = self, window = window })
      self.windows[index] = nil
      -- TODO Unsubscribe window
    end
  end
end

function Partition:has(window)
  for _, partitionWindow in pairs(self.windows) do
    if window == partitionWindow then
      return true
    end
  end

  return false
end

function Partition:getWindows()
  return self.windows
end

function Partition:updateDimensions(dimensions)
  debug(
    "Updating partition dimensions",
    { partition = self, newDimensions = dimensions }
  )

  self.dimensions = dimensions
  self:apply()
end

function Partition:apply()
  debug("Applying partition", { partition = self })

  for _, window in pairs(self.windows) do
    debug(
      "Applying dimensions to window",
      { partition = self, window = window }
    )

    self.grid.set(window, self.dimensions)
  end
end

function Partition:__repr()
  return "Partition{"
    .. "windows: " .. #self.windows .. ", "
    .. "dimensions:" .. self:__dimensionStr() .. ", "
    .. "}"
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
