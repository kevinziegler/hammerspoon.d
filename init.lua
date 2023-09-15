require "styles"

local bootstrap = require("bootstrap")
local leaderMenu = require('leader-menus.main')

bootstrap()
hs.loadSpoon("SpoonInstall")

spoon.SpoonInstall.use_syncinstall = true
spoon.SpoonInstall:andUse("EmmyLua")


hs.hotkey.bind({'command'}, 'space', leaderMenu)
hs.alert.show("Configuration loaded")
