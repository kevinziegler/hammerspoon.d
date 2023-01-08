require "styles"
require "helpers"
require "bootstrap"
local unicode = require("unicode")
-- require "org-capture"
-- require "layouts"

bootstrap()
hs.loadSpoon("SpoonInstall")

spoon.SpoonInstall.use_syncinstall = true
spoon.SpoonInstall:andUse("RecursiveBinder")

spoon.RecursiveBinder.escapeKey = { {}, "escape" }
spoon.RecursiveBinder.helperEntryLengthInChar = 25
spoon.RecursiveBinder.helperFormat = recursiveBinderFormat

local singleKey = spoon.RecursiveBinder.singleKey

function mapActionToSpaces(keyMap, screen, actionFn, descriptionFormat)
  screenSpaces = hs.spaces.allSpaces()[screen]
  nameMap = hs.spaces.missionControlSpaceNames()

  for id,name in pairs(nameMap[screen]) do
    description = string.format(descriptionFormat, name)
    numberSubstringIndex = string.find(name, '%d')
    desktopNumber = string.sub(name, (numberSubstringIndex))
    keyMap[singleKey(tostring(desktopNumber), description)] = actionFn(id)
  end
end

function windowMap()
  keyMap = {}
  screen = hs.screen.mainScreen():getUUID()

  keyMap[singleKey("space", "Select Window")] = function()
    ex = hs.expose.new()
    ex:show()
  end

  activeWindow = hs.window.frontmostWindow()
  if not activeWindow then return end

  function activeWindowToSpace(spaceId)
    return sendWindowToSpace(activeWindow, spaceId)
  end

  mapActionToSpaces(keyMap, screen, activeWindowToSpace, "Send to %s")
  spoon.RecursiveBinder.recursiveBind(keyMap)()
end

function spacesMap()
  screen = hs.screen.mainScreen():getUUID()

  spaceLeft, spaceRight = adjacentSpaces()
  keyMap = {
      [singleKey("d", "Show Desktop")] = hs.spaces.toggleShowDesktop,
      [singleKey("tab", "Show Spaces")] = hs.spaces.toggleMissionControl,
      [singleKey("space", "App Windows")] = expose,
      [singleKey("h", "Move Left")] = moveToSpace(spaceLeft),
      [singleKey("l", "Move Right")] = moveToSpace(spaceRight),
  }

  mapActionToSpaces(keyMap, screen, moveToSpace, "Go to %s")
  spoon.RecursiveBinder.recursiveBind(keyMap)()
end

orgCaptureTree = getOrgCaptureKeys()
orgCaptureMap = captureKeyBindings(orgCaptureTree, singleKey)

local keyMap = {
  [singleKey("space", "Alfred")] = launch("Alfred 4"),
  [singleKey("a", "Applications")] = {
    [singleKey("o", "Open")] = {
      [singleKey("e", "Emacs")]    = launch("Emacs"),
      [singleKey("f", "Firefox")]  = launch("Firefox"),
      [singleKey("t", "iTerm")]    = launch("iTerm"),
      [singleKey("c", "Calendar")] = launch("Fantastical"),
      [singleKey("F", "Finder")]   = launch("Finder"),
      [singleKey("m", "Mail")]     = launch("Mimestream"),
      [singleKey("s", "Spotify")]  = launch("Spotify"),
      [singleKey("S", "Slack")]    = launch("Slack"),
    },
  },
  [singleKey("h", "Help")] = {
    [singleKey("a", "Activity Monitor")] = launch("Activity Monitor"),
    [singleKey("R", "Reload Config")] = hs.reload,
    [singleKey("C", "Launch Console")] = launch("Hammerspoon"),
  },
  [singleKey("i", "Insert Text")] = unicode.keymapTable(singleKey),
    },
    [singleKey("z", unicode.zoidberg_of_disapproval)] = insertText(unicode.zoidberg_of_disapproval),
  },
  [singleKey("o", "Org Capture")] = orgCaptureMap,
  [singleKey("s", "Spotify Controls")] = {
    [singleKey("space", "Play/Pause")] = hs.spotify.playpause,
    [singleKey("n", "Play Next")] = hs.spotify.next,
    [singleKey("p", "Play Previous")] = hs.spotify.previous,
  },

  [singleKey("tab", "Desktop")] = spacesMap,
  [singleKey("w", "Window")] = windowMap,
}

hs.hotkey.bind({'command'}, 'space', spoon.RecursiveBinder.recursiveBind(keyMap))
hs.alert.show("Config loaded")
