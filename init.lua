require "styles"
require "helpers"
require "bootstrap"

local bindKeymap = require("keymaps.utilities").bindKeymap

bootstrap()
hs.loadSpoon("SpoonInstall")

spoon.SpoonInstall.use_syncinstall = true
spoon.SpoonInstall:andUse("RecursiveBinder")

spoon.RecursiveBinder.escapeKey = { {}, "escape" }
spoon.RecursiveBinder.helperEntryLengthInChar = 25
spoon.RecursiveBinder.helperFormat = recursiveBinderFormat

local singleKey = spoon.RecursiveBinder.singleKey

local keyMap = {
  [singleKey("space", "Alfred")] = launch("Alfred 4"),
  [singleKey("a", "Applications")] = bindKeymap('applications', spoon.RecursiveBinder),
  [singleKey("h", "Help")] = bindKeymap('help', spoon.RecursiveBinder),
  [singleKey("i", "Insert Text")] = bindKeymap('unicode', spoon.RecursiveBinder),
  [singleKey("s", "Spotify Controls")] = bindKeymap('spotify', spoon.RecursiveBinder),
  [singleKey("tab", "Desktop")] = bindKeymap('spaces', spoon.RecursiveBinder),
}

hs.hotkey.bind({'command'}, 'space', spoon.RecursiveBinder.recursiveBind(keyMap))
hs.alert.show("Config loaded")
