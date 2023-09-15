local util = require('window-management.util')

ScreenManager = {
  screen = nil,
  filter = nil,
  spaces = nil,
  __mt = {}
}

ScreenManager.__index = ScreenManager

function ScreenManager.__mt.__call(class, screen, filter, spaces)
  local instance = setmetatable(
    {
      screen = screen,
      layouts = {},
      filter = filter,
      spaces = spaces
    },
    class
  )

  instance.filter
    :subscribe(hs.window.filter.windowCreated, instance:onWindowCreated())
    :subscribe(hs.window.filter.windowDestroyed, instance:onWindowDestroyed())
    :subscribe(hs.window.filter.windowMoved, instance:onWindowMoved())
    :subscribe(hs.window.filter.windowInCurrentSpace, instance:onWindowInCurrentSpace())

  return instance
end

function ScreenManager:setLayoutForSpace(layout, spaceNumber)
  self.layouts[spaceNumber] = layout

  util.debug("Setting LAYOUT for SPACE", layout, spaceNumber)

  if not layout then
    return
  end

  for _, window in pairs(self.filter:getWindows()) do
    util.debug("Adding WINDOW to LAYOUT", window, layout)
    layout:add(window)
  end
end

function ScreenManager:current()
  local focused = self.spaces.focusedSpace()
  return focused, self.layouts[focused]
end

function ScreenManager:__updateManagedWindows()
  local focused, layout = self:current()

  if not layout then
    return
  end

  local managed = layout:managedWindows()

  -- First, remove any windows in the layout that no longer exist in the space
  for window in pairs(managed) do
    if not self.filter:isWindowAllowed(window) then
      layout:remove(window)
    end
  end

  -- Then, Add any currently unmanaged windows in the space to the layout
  for _, window in pairs(self.filter:getWindows()) do
    if not managed[window] then
      layout:add(window)
    end
  end
end

function ScreenManager:bindableAction(action)
  local _, layout = self:current()

  if not layout or type(layout[action]) ~= 'function' then
    return nil
  end

  return function()
    self.filter:pause()
    layout[action](layout)
    self.filter:resume()
  end
end

function ScreenManager:onWindowCreated()
  return function(window)
    local focused, layout = self:current()

    util.debug("Handling create event for window", window)
    if layout then
      util.debug("Adding window to layout", window, currentLayout)
      layout:add(window)
    else
      util.debug("No layout for SPACE", focused)
    end
  end
end

function ScreenManager:onWindowDestroyed()
  return function(window)
    local _, layout = self:current()

    util.debug("Handling destroy event for WINDOW", window)
    if layout then
      util.debug("Removing WINDOW from LAYOUT", window, layout)
      layout:remove(window)
    end
  end
end

function ScreenManager:onWindowMoved()
  return function(window)
    local _, layout = self:current()

    util.debug("Handling move event for window", window)
    if layout then
      layout:onWindowMoved(window)
    end
  end
end

function ScreenManager:onWindowNotInCurrentSpace()
  return function(window)
    local _, layout = self:current()

    util.debug("Handling space change event for window", window)

    if layout then
      util.debug("Removing WINDOW from current LAYOUT", window, layout)
      layout:remove(window)
    end
  end
end

function ScreenManager:onWindowInCurrentSpace()
  return function(window)
    local _, currentLayout = self:current()

    util.debug("Handling space change to curent event for window", window)
    for _, layout in pairs(self.layouts) do
      if layout ~= currentLayout then
        util.debug("Removing WINDOW from previous LAYOUT", window, layout)
        layout:remove(window)
      end
    end

    if currentLayout then
      util.debug("Adding window to layout", window, currentLayout)
      currentLayout:add(window)
    end
  end
end

function ScreenManager:setLayoutActive(value)
  local _, layout = self:current()

  if self.layout then
    layout.active = value
  end
end

return setmetatable(ScreenManager, ScreenManager.__mt)
