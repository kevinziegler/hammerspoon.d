function launch(applicationName)
  return function() hs.application.launchOrFocus(applicationName) end
end

function launchByBundleId(bundleId)
  return function() hs.application.launchOrFocusByBundleID(bundleId) end
end

function moveToSpace(space)
  if space then
    return function() hs.spaces.gotoSpace(space) end
  else
    return nil
  end
end

function getSpacePosition(screen, space)
    screen_spaces = hs.spaces.allSpaces()[screen]

    for pos, spaceId in ipairs(screen_spaces) do
      if spaceId == space then return pos end
    end

    return -1
end

function adjacentSpaces()
    screen = hs.screen.mainScreen():getUUID()
    screenSpaces = hs.spaces.allSpaces()[screen]
    current = hs.spaces.activeSpaceOnScreen(screen)
    position = getSpacePosition(screen, current)

    return screenSpaces[position-1], screenSpaces[position+1]
end

function sendWindowToSpace(window, spaceId)
  return function()
    hs.spaces.moveWindowToSpace(window, spaceId)
  end
end
