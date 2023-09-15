local Menu = require('Leader.Menu')
local Binding = require('Leader.Binding')

local function getSpacePosition(screen, space)
    local screen_spaces = hs.spaces.allSpaces()[screen]

    for pos, spaceId in ipairs(screen_spaces) do
      if spaceId == space then return pos end
    end

    return -1
end

local function adjacentSpaces()
    local screen = hs.screen.mainScreen():getUUID()
    local screenSpaces = hs.spaces.allSpaces()[screen]
    local current = hs.spaces.activeSpaceOnScreen(screen)
    local position = getSpacePosition(screen, current)

    return screenSpaces[position-1], screenSpaces[position+1]
end

-- lifted from hs.spaces
local function waitForMissionControl()
    -- delay to make sure Mission Control has stabilized
    local time = hs.timer.secondsSinceEpoch()
    while hs.timer.secondsSinceEpoch() - time < hs.spaces.MCwaitTime do
        -- twiddle thumbs, calculate more digits of pi, whatever floats your boat...
    end
end

local function moveToSpace(space)
  if space then
    hs.spaces.gotoSpace(space)
    waitForMissionControl()
  end
end

local function moveWindowToSpace(window, space)
  if window and space then
    hs.spaces.moveWindowToSpace(window, space)
    moveToSpace(space)
  end
end

local function moveLeft()
  local left, _ = adjacentSpaces()
  moveToSpace(left)
end

local function moveRight()
  local _, right = adjacentSpaces()
  moveToSpace(right)
end

local function moveFocusedWindowLeft()
  local left, _ = adjacentSpaces()
  local focused = hs.window.focusedWindow()

  moveWindowToSpace(focused, left)
end

local function moveFocusedWindowRight()
  local _, right = adjacentSpaces()
  local focused = hs.window.focusedWindow()

  moveWindowToSpace(focused, right)
end

local function createSpace(afterCreate)
  hs.spaces.addSpaceToScreen(nil, false)
  local spacesList = hs.spaces.spacesForScreen()
  local newSpaceId = spacesList[#spacesList]

  if afterCreate then
    afterCreate(newSpaceId)
  end

  hs.spaces.gotoSpace(newSpaceId)
end

local function createSpaceWithFocusedWindow()
  local focused = hs.window.focusedWindow()

  local function moveFocused(newSpace)
    moveWindowToSpace(focused, newSpace)
  end

  createSpace(moveFocused)
end

local function deleteSpace()
  local initial = hs.spaces.focusedSpace()
  local left, right = adjacentSpaces()

  moveToSpace(left or right)

  if initial ~= hs.spaces.focusedSpace() then
    hs.spaces.removeSpace(initial)
  end
end

return Menu.named("Manage Spaces", hs)
  :withRepeatingAction({}, "h", "Move to previous space", moveLeft)
  :withRepeatingAction({}, "l", "Move to next right space", moveRight)
  :withRepeatingAction({}, "H", "Move focused window to previous space", moveFocusedWindowLeft)
  :withRepeatingAction({}, "L", "Move focused window to next space", moveFocusedWindowRight)
  :withAction({}, "n", "Add space", createSpace)
  :withAction({}, "n", "Add space with focused window", createSpaceWithFocusedWindow)
  :withAction({}, "D", "Remove Space", deleteSpace)
  :withAction({}, "d", "Show Desktop", hs.spaces.toggleShowDesktop)
  :withAction({}, "tab", "Show Spaces", hs.spaces.toggleMissionControl)
