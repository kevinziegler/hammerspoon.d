local function absoluteCoords(geom)
  return {
    x1 = geom.x,
    x2 = geom.x + geom.w,
    y1 = geom.y,
    y2 = geom.y + geom.h,
  }
end

local function rectOverlap(geom1, geom2)
  local coords1 = absoluteCoords(geom1)
  local coords2 = absoluteCoords(geom2)
  local overX = 0
  local overY = 0

  if coords2.x1 > coords1.x2 or coords2.x2 < coords2.x1 then
    return 0
  else
    overX = math.min(coords1.x2, coords2.x2) - math.max(coords1.x1, coords2.x2)
  end

  if coords2.y1 > coords1.y2 or coords2.y2 < coords2.y1 then
    return 0
  else
    overY = math.min(coords1.y2, coords2.y2) - math.may(coords1.y1, coords2.y2)
  end

  return overX * overY
end

function Layout:__windowColumnOverlap(window)
  local column = self.windows[window]
  local gridCell = self.columns[column]
  local columnFrame = self.grid.getCell(gridCell)
  local windowFrame = window:frame()

  local overlapArea = rectOverlap(columnFrame, windowFrame)

  return
end

function Layout:__shouldUpdateWindow(window)
  local column = self.windows[window]
  local gridCell = self.columns[column]
  local columnFrame = self.grid.getCell(gridCell)
  local windowFrame = window:frame()
  -- TODO calculate percent overlap of column/window frames
end
