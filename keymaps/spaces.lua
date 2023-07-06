return function(binder)
  local singleKey = binder.singleKey
  local function mapActionToSpaces(keyMap, screen, actionFn, descriptionFormat)
    local nameMap = hs.spaces.missionControlSpaceNames() or {}

    for id,name in pairs(nameMap[screen]) do
      local description = string.format(descriptionFormat, name)
      local numberSubstringIndex = string.find(name, '%d')
      local desktopNumber = string.sub(name, (numberSubstringIndex))
      keyMap[singleKey(tostring(desktopNumber), description)] = actionFn(id)
    end
  end

  return function()
    local screen = hs.screen.mainScreen():getUUID()
    local spaceLeft, spaceRight = adjacentSpaces()

    local keyMap = {
        [singleKey("d", "Show Desktop")] = hs.spaces.toggleShowDesktop,
        [singleKey("tab", "Show Spaces")] = hs.spaces.toggleMissionControl,
        [singleKey("h", "Move Left")] = moveToSpace(spaceLeft),
        [singleKey("l", "Move Right")] = moveToSpace(spaceRight),
    }

    mapActionToSpaces(keyMap, screen, moveToSpace, "Go to %s")
    spoon.RecursiveBinder.recursiveBind(keyMap)()
  end
end
