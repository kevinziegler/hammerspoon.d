LayoutTwoColumn = {
  NAME = "2-Column Layout",
  grid = nil,
  dimensions = nil,
  width = nil,
  windows = nil,
  __mt = {}
}

function LayoutTwoColumn.__mt.__call(class, grid, width, leftWidth)
  width = width or 24
  leftWidth = leftWidth or 12

  if width < leftWidth then
    error("Specified left-column width exceeeds total width")
  end

  grid.setGrid({ w = width, h = 1, x = 0, y = 0 })
  grid.setMargins({x = 10, y = 10})

  return setmetatable(
    {
      grid = grid,
      dimensions = {
        left = { x = 0, y = 0, w = leftWidth, h = 1},
        right = { x = leftWidth, y = 0, w = width - leftWidth, h = 1},
      },

      windows = {
        left = {},
        right = {}
      }

    }, class)
end

function LayoutTwoColumn:extendLeft()
  if self.dimensions.right.w < 2 then
    print("Cannot shrink right column any further!")
    return
  end

  self.dimensions.left.w = self.dimensions.left.w + 1
  self.dimensions.right.w = self.dimensions.right.w - 1
  self.dimensions.right.x = self.dimensions.right.x + 1
end

function LayoutTwoColumn:extendRight()
  if self.dimensions.left.w < 2 then
    print("Cannot shrink left column any further!")
    return
  end

  self.dimensions.left.w = self.dimensions.left.w - 1
  self.dimensions.right.w = self.dimensions.right.w + 1
  self.dimensions.right.x = self.dimensions.right.x - 1
end

function LayoutTwoColumn:addLeft(window)
  self.windows.left[#self.windows.left + 1] = window
end

function LayoutTwoColumn:addRight(window)
  self.windows.left[#self.windows.right + 1] = window
end

function LayoutTwoColumn:apply()
  for _, window in pairs(self.windows.left) do
    self.grid.set(window, self.dimensions.left)
  end

  for _, window in pairs(self.windows.right) do
    self.grid.set(window, self.dimensions.right)
  end
end

function LayoutTwoColumn:unmanage(window)
  for position, managed in pairs(self.windows.left) do
    if managed == window then
      table.remove(self.widows.left, position)
    end
  end

  for position, managed in pairs(self.windows.right) do
    if managed == window then
      table.remove(self.widows.right, position)
    end
  end

  return nil
end

function LayoutTwoColumn:__sideForWindow(window)
  for position, managed in pairs(self.windows.left) do
    if managed == window then
      return "left"
    end
  end

  for position, managed in pairs(self.windows.right) do
    if managed == window then
      return "right"
    end
  end

  return nil
end

function LayoutTwoColumn:swapSide(window)
  local current = self:__sideForWindow(window)

  self:unmanage(window)

  if current == "left" then
    self:addRight(window)
  elseif current == "right" then
    self:addLeft(window)
  else
    error("Invalid position for window: " .. current)
  end
end
