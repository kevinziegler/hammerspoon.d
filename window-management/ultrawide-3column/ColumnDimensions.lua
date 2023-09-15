ColumnDimensions = {
  left = nil,
  right = nil,
  main = nil,
  defaults = nil,
  __mt = {},
}

ColumnDimensions.__index = ColumnDimensions

function ColumnDimensions.__mt.__call(class, gridColumns, mainWidth)
  local sideWidth = (gridColumns - mainWidth) / 2
  local instance = {}

  function instance:__setDefaults()
    self.main  = { x = sideWidth, y = 0, h = 1, w = mainWidth }
    self.left  = { x = 0, y = 0, h = 1, w = sideWidth }
    self.right = { x = sideWidth + mainWidth, y = 0, h = 1, w = sideWidth }
  end

  instance:__setDefaults()

  return setmetatable(instance, class)
end

function ColumnDimensions:reset()
  self:__setDefaults()
end

function ColumnDimensions:growMain()
  self.left.w = self.left.w - 1

  self.main.w = self.main.w + 2
  self.main.x = self.main.x - 1

  self.right.w = self.right.w - 1
  self.right.x = self.right.x + 1
end

function ColumnDimensions:shrinkMain()
  self.left.w = self.left.w + 1

  self.main.w = self.main.w - 2
  self.main.x = self.main.x + 1

  self.right.w = self.right.w + 1
  self.right.x = self.right.x - 1
end

function ColumnDimensions:splitRight()
  self.right.h = self.right.h + 1
end

function ColumnDimensions:splitLeft()
  self.left.h = self.left.h + 1
end

function ColumnDimensions:mergeRight()
  if self.right.h > 1 then
    self.right.h = self.right.h - 1
  end
end

function ColumnDimensions:mergeLeft()
  if self.left.h > 1 then
    self.left.h = self.left.h - 1
  end
end


return setmetatable(ColumnDimensions, ColumnDimensions.__mt)
