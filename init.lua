local bootstrap = require("bootstrap")
local leaderMenu = require('leader-menus.main')

bootstrap()
hs.loadSpoon("SpoonInstall")

spoon.SpoonInstall.use_syncinstall = true
spoon.SpoonInstall:andUse("EmmyLua")

hs.styledtext.font = { name = "Berkeley Mono", size = 18 }
hs.alert.defaultStyle.radius = 7
hs.alert.defaultStyle.fillColor = { hex = "#1F2430", alpha = 0.95 }
hs.alert.defaultStyle.strokeColor = { hex = "#CBCCC6", alpha = 1.0 }
hs.alert.defaultStyle.strokeWidth = 5

hs.window.animationDuration = 0.4
hs.hotkey.bind({'command'}, 'space', leaderMenu)
hs.alert.show("Configuration loaded")
