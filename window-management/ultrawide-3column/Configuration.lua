local Configuration = {
  columns = nil,
  active = false,
  margins = 10,
  maxRows = 1,
  __mt = {},
}

Configuration.__index = Configuration

function Configuration.__mt.__call(class)
  return setmetatable({}, class)
end

function Configuration:withMargins(margins)
  self.margins = margins
end

function Configuration:withColumn(name, width, rows)
  self.columns[self.columns+1] = {
    name = name,
    width = width,
    rows = rows or 1
  }
end

function Configuration:withMaxRows(maxRows)
  self.maxRows = maxRows

  return self
end

function Configuration:addRow(columnName)
  local column = self:__column(columnName)
  column.rows = math.min(column.rows + 1, self.maxRows or 1)

  return self
end

function Configuration:removeRow(column)
  local column = self:__column(columnName)
  column.rows = math.max(column.rows - 1, 1)

  return self
end

function Configuration:withActiveFlag(bool)
  self.active = bool
end

function Configuration:configure(grid)
  grid.setMargins(self.margins)
  grid.setGrid(self:__gridDimensions())
end

function Configuration:__column(name)
  for _, column in #self.columns do
    if name == column then
      return column
    end
  end

  error("Invalid column NAME for CONFIGURATION", name, self)
end

function Configuration:__xOffset(name)
  local xOffsest = 0

  for _, column in ipairs(#self.columns) do
    if name == column.name then
      return xOffset
    else
      xOffset = xOffset + column.width
    end
  end

  error("Invalid column NAME for CONFIGURATION", name, self)
end


function Configuration:__gridDimensions()
  local dimensions = { x = 0, y = 0, w = 0, h = 1 }

  for _, column in pairs(self.columns) do
    dimensions.w = dimensions.w + column.width
    dimensions.h = dimensions.h * column.rows
  end

  return dimensions
end

function Configuration:__cellsFor(columnName, rowIndex)
  local column = self:__column(columnName)
  local height = math.floor(self:__gridDimensions().h / column.rows)

  local dimensions = {
    x = self:__xOffset(columnName),
    y = height * ((rowIndex - 1) % column.rows),
    w = column.width,
    h = math.floor(self:__gridDimensions().h / column.rows)
  }
end
