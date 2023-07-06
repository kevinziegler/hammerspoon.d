require "styles"

local bootstrap = require("bootstrap")
local keymapUtils = require("keymaps.utilities")

local function bindKeymap(keymap)
  keymapUtils.bindKeymap(keymap, spoon.MyRecursiveBinder)
end

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
  [singleKey("space", "Alfred")] = keymapUtils.launch("Alfred 4"),
  [singleKey("a", "Applications")] = bindKeymap('applications'),
  [singleKey("h", "Help")] = bindKeymap('help'),
  [singleKey("i", "Insert Text")] = bindKeymap('unicode'),
  [singleKey("s", "Spotify Controls")] = bindKeymap('spotify'),
  [singleKey("tab", "Desktop")] = bindKeymap('spaces'),
}

hs.hotkey.bind({'command'}, 'space', bindKeymap(keyMap))
hs.alert.show("Configuration loaded")
