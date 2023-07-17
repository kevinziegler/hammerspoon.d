require "styles"
require "helpers"
require "bootstrap"

local bindKeymap = require("keymaps.utilities").bindKeymap

bootstrap()
hs.loadSpoon("SpoonInstall")

spoon.SpoonInstall.use_syncinstall = true
spoon.SpoonInstall:andUse("MyRecursiveBinder")
spoon.SpoonInstall:andUse("EmmyLua")

spoon.MyRecursiveBinder.escapeKey = { {}, "escape" }
spoon.MyRecursiveBinder.helperEntryLengthInChar = 25
spoon.MyRecursiveBinder.helperEntryEachLine = 2
spoon.MyRecursiveBinder.helperFormat = recursiveBinderFormat

local singleKey = spoon.MyRecursiveBinder.singleKey

local keyMap = {
  [singleKey("space", "Alfred")] = launchByBundleId("com.runningwithcrayons.Alfred"),
  [singleKey("a", "Applications")] = bindKeymap('applications', spoon.MyRecursiveBinder),
  [singleKey("h", "Help")] = bindKeymap('help', spoon.MyRecursiveBinder),
  [singleKey("i", "Insert Text")] = bindKeymap('unicode', spoon.MyRecursiveBinder),
  [singleKey("s", "Spotify Controls")] = bindKeymap('spotify', spoon.MyRecursiveBinder),
  [singleKey("tab", "Desktop")] = bindKeymap('spaces', spoon.MyRecursiveBinder),
}

hs.hotkey.bind({'command'}, 'space', spoon.MyRecursiveBinder.recursiveBind(keyMap))
hs.alert.show("Config loaded")
